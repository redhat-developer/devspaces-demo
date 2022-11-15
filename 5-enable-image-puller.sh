#!/bin/bash
set -o nounset
set -o errexit

PATCH='{"spec":{"components":{"imagePuller":{"enable": true}}}}'

kubectl patch checluster devspaces \
  --type=merge -p \
  "${PATCH}" \
  -n openshift-devspaces

############################################
# In case the command above doesn't work the
# subscription can be created manually
# 
# kubectl apply -f - <<EOF
# apiVersion: operators.coreos.com/v1alpha1
# kind: Subscription
# metadata:
#   name: kubernetes-imagepuller-operator
#   namespace: openshift-operators
# spec:
#   channel: stable
#   installPlanApproval: Automatic
#   name: kubernetes-imagepuller-operator
#   source: community-operators
#   sourceNamespace: openshift-marketplace
# EOF
#
