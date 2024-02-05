#!/bin/bash
set -o nounset
set -o errexit

DSC_VERSION=${DSC_VERSION:-next}

cd /tmp

# 1. get install script
curl -sSLO https://raw.githubusercontent.com/redhat-developer/devspaces-chectl/devspaces-3-rhel-8/build/scripts/installDscFromContainer.sh; chmod +x installDscFromContainer.sh

# 2. install to $HOME/dsc/
./installDscFromContainer.sh quay.io/devspaces/dsc:${DSC_VERSION} -t $HOME --verbose

# 3. create a link to make sure it's in PATH
ln -s $HOME/dsc/bin/dsc $HOME/.local/bin/dsc
