#!/bin/bash

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
