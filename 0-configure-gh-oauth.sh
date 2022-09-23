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
  type: Opaque
  data:
    id: ${BASE64_GH_OAUTH_CLIENT_ID}
    secret: ${BASE64_GH_OAUTH_CLIENT_SECRET}
EOF
