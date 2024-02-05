#!/bin/bash
set -o nounset
set -o errexit

if [ -z ${API_URL+x} ]; then
    read -p "Enter OpenShift API URL: " API_URL
fi

if [ -z ${API_TOKEN+x} ]; then
    read -p "Enter OpenShift API token: " API_TOKEN
fi

oc login --insecure-skip-tls-verify=true --server="$API_URL" --token="$API_TOKEN"
