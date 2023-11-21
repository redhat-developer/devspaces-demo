#!/bin/bash
set -o nounset
set -o errexit

if [ -z ${1+x} ]; then
    OLM_CHANNEL=${OLM_CHANNEL:-latest}
else
    OLM_CHANNEL=${1}
fi

echo "Using channel ${OLM_CHANNEL}"

dsc server:deploy --olm-channel="${OLM_CHANNEL}"
