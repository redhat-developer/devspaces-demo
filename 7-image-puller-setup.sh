#!/bin/bash
set -o nounset
set -o errexit

# Create the subscription image puller operator

# The following code is commented out because it doesn't work and 
# we need to manually subscribe and create the CR...
#
# PATCH='{"spec":{"components":{"imagePuller":{"enable": false}}}}'
# kubectl patch checluster devspaces \
#   --type=merge -p \
#   "${PATCH}" \
#   -n openshift-devspaces

kubectl apply -f - <<EOF
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: kubernetes-imagepuller-operator
  namespace: openshift-operators
spec:
  channel: stable
  installPlanApproval: Automatic
  name: kubernetes-imagepuller-operator
  source: community-operators
  sourceNamespace: openshift-marketplace
EOF

# Get a list of images to be pulled

## 1. from a default list
declare -a IMAGES=( quay.io/devspaces/code-rhel8:3.3 quay.io/devspaces/idea-rhel8:3.3 quay.io/devspaces/machineexec-rhel8:3.3 quay.io/devspaces/theia-endpoint-rhel8:3.3 quay.io/devspaces/theia-rhel8:3.3 quay.io/devspaces/udi-rhel8:3.3 registry.redhat.io/devspaces/traefik-rhel8@sha256:ac76f74f0e4b3d2ca5e929b2b49632a98cb28a6c94a48b7775423805343ed057 )
echo "There are ${#IMAGES[@]} default images to pull"

## 2. from the external images list
if [ -v DEVSPACES_HOST ]; then
  echo "Retrieving external images from https://${DEVSPACES_HOST}/plugin-registry/v3/external_images.txt"
  EXTERNAL_IMAGES=($(curl -k -sSL https://${DEVSPACES_HOST}/plugin-registry/v3/external_images.txt))
  IMAGES=( "${IMAGES[@]}" "${EXTERNAL_IMAGES[@]}" )
  echo "Found ${#EXTERNAL_IMAGES[@]} external images for a total of ${#IMAGES[@]}"
fi

## 3. from a running workspace
if [ -v DEVELOPER_NAMESPACE ]; then
  echo "Retrieving images from any Pod in ${DEVELOPER_NAMESPACE} namespace"
  RUNNING_WORKSPACE_IMAGES=($(kubectl get pods -n ${DEVELOPER_NAMESPACE} -o json | jq -r '.items[].spec | (.initContainers[].image, .containers[].image)'))
  IMAGES=( "${IMAGES[@]}" "${RUNNING_WORKSPACE_IMAGES[@]}" )
  echo "Found ${#RUNNING_WORKSPACE_IMAGES[@]} Pod images for a total of ${#IMAGES[@]}"
fi

## 4. remove duplicates
IMAGES=( $(printf "%s\n" "${IMAGES[@]}" | sort -u) )
echo "After removing duplicates there are ${#IMAGES[@]} images:"
printf "%s\n" "${IMAGES[@]}"

echo "The resulting image list:"
IMAGES_LIST=""
for ((i = 0; i < ${#IMAGES[@]}; ++i)); do
    position=$(( $i + 1 ))
    IMAGES_LIST+="img-$position=${IMAGES[$i]};"
done
echo "${IMAGES_LIST}"

echo "Wait one minute for the Kubernetes Image Puller Operator to be up and running."
sleep 60

# Create or patch a KubernetesImagePuller CR with images: "${IMAGES_LIST}"
kubectl apply -f - <<EOF
apiVersion: che.eclipse.org/v1alpha1
kind: KubernetesImagePuller
metadata:
  name: image-puller
  namespace: openshift-devspaces
spec:
  configMapName: k8s-image-puller
  daemonsetName: k8s-image-puller
  deploymentName: kubernetes-image-puller
  imagePullerImage: 'quay.io/eclipse/kubernetes-image-puller:next'
  images: "${IMAGES_LIST}"
EOF

# To verify if a list of image is pre-pulled:
#
# IMAGES=( quay.io/devspaces/code-rhel8:3.3 quay.io/devspaces/idea-rhel8:3.3 )
# for img in "${IMAGES[@]}"; do kubectl get pods --all-namespaces -o jsonpath="{.items[*].spec.containers[*].image}" |tr -s '[[:space:]]' '\n' | grep $img |uniq -c; done
# 
