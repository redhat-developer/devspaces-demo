#!/bin/bash
set -o nounset
set -o errexit

USER=${OPENSHIFT_USER:-janedoe}
PASSWORD=${OPENSHIFT_PASSWORD:-janedoe}
HTPASSWD_FILE="/tmp/crwhtpasswd"
[[ -f "$HTPASSWD_FILE" ]] && htpasswd -bB ${HTPASSWD_FILE} $USER $PASSWORD || htpasswd -cbB ${HTPASSWD_FILE} $USER $PASSWORD 
htpwd_encoded="$(cat $HTPASSWD_FILE | base64 -w 0)"

cat <<EOF | oc apply -f -
apiVersion: v1
kind: Secret
metadata:
  creationTimestamp: null
  name: htpass-secret
  namespace: openshift-config
data:
  htpasswd: ${htpwd_encoded}
EOF

# if there are no indentityProviders
if [[ $(kubectl get oauth cluster -o=jsonpath='{.spec.identityProviders[*].name}' | wc -c) -eq 0 ]]; then
  kubectl patch oauths cluster --type merge -p '
  spec:
    identityProviders:
      - name: htpasswd
        mappingMethod: claim
        type: HTPasswd
        htpasswd:
          fileData:
            name: htpass-secret
  '
# if the htpasswd identityProvider doesn't exist
elif [[ $(kubectl get oauth cluster -o=jsonpath='{.spec.identityProviders[?(@.name=="htpasswd")]}' | wc -c) -eq 0 ]]; then
  kubectl patch oauth cluster --type='json' -p '[
    {
      "op":"add","path":"/spec/identityProviders/1",
      "value":{
        "name":"htpasswd",
        "mappingMethod":"claim",
        "type":"HTPasswd",
        "htpasswd":
          {"fileData":
            {"name":"htpass-secret"}
          }
      }
    }
  ]'
fi
