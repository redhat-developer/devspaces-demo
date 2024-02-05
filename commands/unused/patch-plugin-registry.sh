#!/bin/bash
set -o nounset
set -o errexit

TARGET_EDITOR="che-incubator/che-code/insiders"
SUBSTITUTION="s/image: quay.io\/devspaces\/code-rhel8:3.3/image: quay.io\/mloriedo\/che-code:default-folder/"

kubectl exec -ti -n openshift-devspaces deployment/plugin-registry \
    -- sed -i "${SUBSTITUTION}" \
    /var/www/html/v3/plugins/"${TARGET_EDITOR}"/devfile.yaml