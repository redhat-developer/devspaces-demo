#!/bin/bash
set -o nounset
set -o errexit

PATCH='{"spec":{"devEnvironments":{"secondsOfInactivityBeforeIdling": -1}}}'

kubectl patch checluster devspaces \
  --type=merge -p \
  "${PATCH}" \
  -n openshift-devspaces
