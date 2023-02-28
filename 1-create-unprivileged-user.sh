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

IP_NAME=devspaces-demo
kubectl get oauths cluster -o json | \
  jq 'if .spec.identityProviders and (.spec.identityProviders|any(.name == "'"$IP_NAME"'")) 
    then . 
    else .spec.identityProviders += [{
      "name":"'"$IP_NAME"'",
      "mappingMethod":"claim",
      "type":"HTPasswd",
      "htpasswd":{
        "fileData":{
          "name":"htpass-secret"
        }
      }
    }]
    end' | \
  kubectl apply -f -
