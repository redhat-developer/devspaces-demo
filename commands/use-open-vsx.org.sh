#!/bin/bash
set -o nounset
set -o errexit

OPEN_VSX_URL="https://open-vsx.org"

PATCH='{"spec":{"components":{"pluginRegistry":{"openVSXURL":"' 
PATCH+="${OPEN_VSX_URL}"
PATCH+='"}}}}'

kubectl patch checluster devspaces \
  --type=merge -p \
  "${PATCH}" \
  -n openshift-devspaces
