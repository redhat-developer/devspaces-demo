#!/bin/bash
set -o nounset
set -o errexit

UDI_IMAGE=${UDI_IMAGE:-quay.io/devspaces/udi-rhel8:3.3}

PATCH='{"spec":{"devEnvironments":{"defaultComponents":[{"name": "universal-developer-image", "container": {"image": "' 
PATCH+="${UDI_IMAGE}"
PATCH+='"}}]}}}'

kubectl patch checluster devspaces \
  --type=merge -p \
  "${PATCH}" \
  -n openshift-devspaces
