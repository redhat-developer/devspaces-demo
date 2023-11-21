#!/bin/bash
set -o nounset
set -o errexit

echo ""
echo "If you haven't done so you need to create a GitHub OAuth Application first https://github.com/settings/applications/new" 
echo "Dev Spaces documentation:" 
echo "   https://access.redhat.com/documentation/en-us/red_hat_openshift_dev_spaces/3.9/html/administration_guide/configuring-devspaces#configuring-oauth-2-for-github-setting-up-the-github-oauth-app"
echo ""

if [ -z ${GH_OAUTH_CLIENT_ID+x} ]; then
    read -p "Enter GitHub OAuth Client ID: " GH_OAUTH_CLIENT_ID
fi

if [ -z ${GH_OAUTH_CLIENT_SECRET+x} ]; then
    read -p "Enter GitHub OAuth Client Secret: " GH_OAUTH_CLIENT_SECRET
fi

createOAuthSecret() {
cat << EOF | kubectl apply -f -
  kind: Secret
  apiVersion: v1
  metadata:
    name: github-oauth-config
    namespace: openshift-devspaces
    labels:
      app.kubernetes.io/part-of: che.eclipse.org
      app.kubernetes.io/component: oauth-scm-configuration
    annotations:
      che.eclipse.org/oauth-scm-server: github
      che.eclipse.org/scm-server-endpoint: https://github.com
  type: Opaque
  stringData:
    id: ${GH_OAUTH_CLIENT_ID}
    secret: ${GH_OAUTH_CLIENT_SECRET}
EOF
}

setOAuthSecret() {
  kubectl patch checluster devspaces --type=merge -p '{"spec":{"gitServices":{"github":[{"endpoint":"https://github.com","secretName":"github-oauth-config"}]}}}' -n openshift-devspaces
}

createOAuthSecret
setOAuthSecret # <== not needed, but if not set GitHub doesn't show in the OpenShift console CheCluster details
