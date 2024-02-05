#!/bin/bash
set -o nounset
set -o errexit

if [ -z ${USER_NAMESPACE+x} ]; then
  read -p "Enter the developer namespace name: " USER_NAMESPACE
fi

NEW_POD_MAX_MEMORY_LIMIT="16Gi"
NEW_CONTAINER_MAX_CPU_LIMIT="4"
NEW_POD_MAX_CPU_LIMIT="12"

N_LIMIT_RANGE=$(kubectl get limits -n $USER_NAMESPACE --no-headers | wc -l)

if [[ $N_LIMIT_RANGE -eq 0 ]]; then
  echo "There are no LimitRanges."
  exit 0
fi

if [[ $N_LIMIT_RANGE -gt 1 ]]; then
  echo "There are ${N_LIMIT_RANGE} LimitRanges in $USER_NAMESPACE, unclear which to edit. Please increase container and pod memory limit to ${NEW_POD_MAX_MEMORY_LIMIT} manually."
  exit 0
fi

LIMIT_RANGE=$(kubectl get limits -n $USER_NAMESPACE --no-headers -o custom-columns=":metadata.name")

PATCH="{\"spec\":{\"limits\":[{\"type\":\"Container\",\"max\":{\"cpu\":\"${NEW_CONTAINER_MAX_CPU_LIMIT}\",\"memory\":\"${NEW_POD_MAX_MEMORY_LIMIT}\"}},{\"type\":\"Pod\",\"max\":{\"cpu\":\"${NEW_POD_MAX_CPU_LIMIT}\",\"memory\":\"${NEW_POD_MAX_MEMORY_LIMIT}\"}}]}}"

kubectl patch LimitRange $LIMIT_RANGE \
  --type=merge -p \
  "${PATCH}" \
  -n $USER_NAMESPACE
