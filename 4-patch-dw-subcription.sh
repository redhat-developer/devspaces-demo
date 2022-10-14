#!/bin/bash
set -o nounset
set -o errexit

# Add DevWorkspace upstream catalog source
kubectl apply -f - <<EOF
apiVersion: operators.coreos.com/v1alpha1
kind: CatalogSource
metadata:
  name: devworkspace-operator-catalog
  namespace: openshift-marketplace
spec:
  sourceType: grpc
  image: quay.io/devfile/devworkspace-operator-index:next
  publisher: Red Hat
  displayName: DevWorkspace Operator Catalog
  updateStrategy:
    registryPoll:
      interval: 5m
EOF

# Patch the DevWorkspace operator subscription to use the upstream catalog source
SUB_NAME="devworkspace-operator-fast-devspaces-fast-openshift-operators"
SUB_NS="openshift-operators"
kubectl patch subscription "${SUB_NAME}" -n "${SUB_NS}" \
  --type=merge -p \
  '{"spec":{"channel":"next", "source":"devworkspace-operator-catalog", "sourceNamespace":"openshift-marketplace"}}'
