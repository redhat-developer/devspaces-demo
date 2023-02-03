#!/bin/bash
set -o nounset
set -o errexit

PATCH='{"spec":{"components":{"dashboard": {"headerMessage": {"show": false, "text": ""}}}}}'

kubectl patch checluster devspaces \
  --type=merge -p \
  "${PATCH}" \
  -n openshift-devspaces
