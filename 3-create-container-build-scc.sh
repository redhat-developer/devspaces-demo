#!/bin/bash
set -o nounset
set -o errexit

OPENSHIFT_USER=${OPENSHIFT_USER:-janedoe}

# Create SCC
kubectl apply -f - <<EOF
apiVersion: security.openshift.io/v1
kind: SecurityContextConstraints
metadata:
  name: container-build
allowHostDirVolumePlugin: false
allowHostIPC: false
allowHostNetwork: false
allowHostPID: false
allowHostPorts: false
allowPrivilegeEscalation: true
allowPrivilegedContainer: false
allowedCapabilities:
  - SETUID
  - SETGID
defaultAddCapabilities: null
fsGroup:
  type: MustRunAs
# Temporary workaround for https://github.com/devfile/devworkspace-operator/issues/884
priority: 20
readOnlyRootFilesystem: false
requiredDropCapabilities:
  - KILL
  - MKNOD
runAsUser:
  type: MustRunAsRange
seLinuxContext:
  type: MustRunAs
supplementalGroups:
  type: RunAsAny
users: []
groups: []
volumes:
  - configMap
  - downwardAPI
  - emptyDir
  - persistentVolumeClaim
  - projected
  - secret
EOF

# Create the cluster role get-n-update-container-build-scc
kubectl apply -f - <<EOF
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: get-n-update-container-build-scc
rules:
- apiGroups:
  - "security.openshift.io"
  resources:
  - "securitycontextconstraints"
  resourceNames:
  - "container-build"
  verbs:
  - "get"
  - "update"
EOF

# Add the role to the DevWorkspace controller Service Account
oc adm policy add-cluster-role-to-user \
       get-n-update-container-build-scc \
       system:serviceaccount:openshift-operators:devworkspace-controller-serviceaccount

# Add the SCC to $OPENSHIFT_USER
oc adm policy add-scc-to-user container-build ${OPENSHIFT_USER}
