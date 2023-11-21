#!/bin/bash
set -o nounset
set -o errexit

if [ -z ${IDE_DEFINITION+x} ]; then
    echo ""
    echo "IntelliJ id:"
    echo "  che-incubator/che-idea/latest"
    echo ""

    echo "Upstream VS Code defintion URL:"
    echo "  https://eclipse-che.github.io/che-plugin-registry/main/v3/plugins/che-incubator/che-code/insiders/devfile.yaml"

    echo ""
    echo "Upstream IntelliJ defintion URL:"
    echo "  https://eclipse-che.github.io/che-plugin-registry/main/v3/plugins/che-incubator/che-idea/next/devfile.yaml"

    echo ""
    echo "Upstream PyCharm defintion URL:"
    echo "  https://eclipse-che.github.io/che-plugin-registry/main/v3/plugins/che-incubator/che-pycharm/next/devfile.yaml"

    read -p "Enter IDE definition URL or id: " IDE_DEFINITION
fi


PATCH='{"spec":{"devEnvironments":{"defaultEditor":"' 
PATCH+="${IDE_DEFINITION}"
PATCH+='"}}}'

kubectl patch checluster devspaces \
  --type=merge -p \
  "${PATCH}" \
  -n openshift-devspaces
