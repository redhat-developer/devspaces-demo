#!/bin/bash
set -o nounset
set -o errexit

IDE_DEFINITION=${IDE_DEFINITION:-https://eclipse-che.github.io/che-plugin-registry/main/v3/plugins/che-incubator/che-code/insiders/devfile.yaml}

PATCH='{"spec":{"devEnvironments":{"defaultEditor":"' 
PATCH+="${IDE_DEFINITION}"
PATCH+='"}}}'

kubectl patch checluster devspaces \
  --type=merge -p \
  "${PATCH}" \
  -n openshift-devspaces
