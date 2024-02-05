#!/bin/bash
set -o nounset
set -o errexit

if [ -z ${1+x} ]; then
    UDI_IMAGE=${UDI_IMAGE:-quay.io/devspaces/udi-rhel8:latest}
else
    UDI_IMAGE=${1}
fi

PATCH='{"spec":{"devEnvironments":{"defaultComponents":[{"name": "universal-developer-image", "container": {"image": "' 
PATCH+="${UDI_IMAGE}"
PATCH+='"}}]}}}'

kubectl patch checluster devspaces \
  --type=merge -p \
  "${PATCH}" \
  -n openshift-devspaces
