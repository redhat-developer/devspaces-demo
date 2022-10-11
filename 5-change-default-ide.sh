#!/bin/bash
set -o nounset
set -o errexit

IDE_DEFINITION=${IDE_DEFINITION:-che-incubator/che-code/insiders}

PATCH='{"spec":{"devEnvironments":{"defaultEditor":"' 
PATCH+="${IDE_DEFINITION}"
PATCH+='"}}}'

kubectl patch checluster devspaces \
  --type=merge -p \
  "${PATCH}" \
  -n openshift-devspaces
