#!/bin/bash
set -o nounset
set -o errexit

PATCH='{"spec":{"devEnvironments":{"disableContainerBuildCapabilities": false}}}'

kubectl patch checluster devspaces \
  --type=merge -p \
  "${PATCH}" \
  -n openshift-devspaces
