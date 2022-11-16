#!/bin/bash
set -o nounset
set -o errexit

if [[ -z $USER_NAMESPACE ]]; then
  echo "Error: USER_NAMESPACE is not set"
  exit 1
fi

# Set container and pod memory limit to NEW_LIMIT
NEW_LIMIT="16Gi"
N_LIMIT_RANGE=$(kubectl get limits -n opentlc-mgr-che --no-headers | wc -l)

if [[ $N_LIMIT_RANGE -eq 0 ]]; then
  echo "There are no LimitRanges."
  exit 0
fi

if [[ $N_LIMIT_RANGE -gt 1 ]]; then
  echo "There are ${N_LIMIT_RANGE} LimitRanges in $USER_NAMESPACE, unclear which to edit. Please increase container and pod memory limit to ${NEW_LIMIT} manually."
  exit 0
fi

LIMIT_RANGE=$(kubectl get limits -n opentlc-mgr-che --no-headers -o custom-columns=":metadata.name")

PATCH="{\"spec\":{\"limits\":[{\"type\":\"Container\",\"max\":{\"cpu\":\"4\",\"memory\":\"${NEW_LIMIT}\"}},{\"type\":\"Pod\",\"max\":{\"cpu\":\"4\",\"memory\":\"${NEW_LIMIT}\"}}]}}"

kubectl patch LimitRange $LIMIT_RANGE \
  --type=merge -p \
  "${PATCH}" \
  -n $USER_NAMESPACE
