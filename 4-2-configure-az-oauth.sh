#!/bin/bash
set -o nounset
set -o errexit

if [ -z ${BASE64_AZ_OAUTH_APP_ID+x} ]; then 
  echo "Error: BASE64_AZ_OAUTH_APP_ID is unset"
  exit 1
fi

if [ -z ${BASE64_AZ_OAUTH_CLIENT_SECRET+x} ]; then 
  echo "Error: BASE64_AZ_OAUTH_CLIENT_SECRET is unset"
  exit 1
fi

createOAuthSecret() {
cat << EOF | kubectl apply -f -
  kind: Secret
  apiVersion: v1
  metadata:
    name: azure-devops-oauth-config
    namespace: openshift-devspaces
    labels:
      app.kubernetes.io/part-of: che.eclipse.org
      app.kubernetes.io/component: oauth-scm-configuration
    annotations:
      che.eclipse.org/oauth-scm-server: azure-devops
  type: Opaque
  data:
    id: ${BASE64_AZ_OAUTH_APP_ID}
    secret: ${BASE64_AZ_OAUTH_CLIENT_SECRET}
EOF
}

createOAuthSecret
