#!/bin/bash
set -o nounset
set -o errexit

if [ -z ${BASE64_GH_OAUTH_CLIENT_ID+x} ]; then 
  echo "Error: BASE64_GH_OAUTH_CLIENT_ID is unset"
  exit 1
fi

if [ -z ${BASE64_GH_OAUTH_CLIENT_SECRET+x} ]; then 
  echo "Error: BASE64_GH_OAUTH_CLIENT_SECRET is unset"
  exit 1
fi

createOAuthSecret() {
cat << EOF | kubectl apply -f -
  kind: Secret
  apiVersion: v1
  metadata:
    name: github-oauth-config
    namespace: openshift-devspaces
  type: Opaque
  data:
    id: ${BASE64_GH_OAUTH_CLIENT_ID}
    secret: ${BASE64_GH_OAUTH_CLIENT_SECRET}
EOF
}

setOAuthSecret() {
  kubectl patch checluster devspaces --type=merge -p '{"spec":{"gitServices":{"github":[{"endpoint":"https://github.com","secretName":"github-oauth-config"}]}}}' -n openshift-devspaces
}

createOAuthSecret
setOAuthSecret
