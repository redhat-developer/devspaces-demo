[![Contribute (nightly)](https://img.shields.io/static/v1?label=nightly%20Che&message=for%20maintainers&logo=eclipseche&color=FDB940&labelColor=525C86)](https://che-dogfooding.apps.che-dev.x6e0.p1.openshiftapps.com/#https://github.com/che-incubator/devspaces-demo)

### [Supporting slides](https://docs.google.com/presentation/d/1PUwPsY8TosHMsQT0iMe6zLD4wrd66U_oot2_oSIM9F0/edit?usp=sharing)

# Preparation

### Install Dev Spaces next

To deploy Dev Spaces next (early release builds) we use `installDevSpacesFromLatestIIB.sh` (in the short term we should be able to use `dsc`).

Before running this script `oc`, `jq` and `git` should be pre-installed and you should be logged in as an admin to the OpenShift cluster.

```bash
git clone https://github.com/redhat-developer/devspaces.git && \
cd devspaces/product &&
./installDevSpacesFromLatestIIB.sh --next
```

### Configure GitHub OAuth

First create a [GitHub OAuth App](https://www.eclipse.org/che/docs/stable/administration-guide/configuring-oauth-2-for-github/#setting-up-the-github-oauth-app_che) and then use the following instructions to create a secret and patch the Dev Spaces CheCluster CR:
```bash
export BASE64_GH_OAUTH_CLIENT_ID=<your-id>
export BASE64_GH_OAUTH_CLIENT_SECRET=<your-secret>
./1-configure-gh-oauth.sh
```

### Create a few unprivileged OCP users (besides kubeadmin)

```bash
# This is optional
export OPENSHIFT_USER=<your-username>
export OPENSHIFT_PASSWORD=<your-password>
./2-create-unprivileged-user.sh
```

### Configure SCC and privileges for Podman build
```bash
export OPENSHIFT_USER=<your-username>
./3-create-container-build-scc.sh
```

### Set the default editor to VS Code
```bash
kubectl patch checluster devspaces \
  --type=merge -p \
  '{"spec":{"devEnvironments":{"defaultEditor":"che-incubator/che-code/insiders"}}}' \
  -n openshift-devspaces
```

or, to get the upstream VS Code...

```bash
kubectl patch checluster devspaces \
  --type=merge -p \
  '{"spec":{"devEnvironments":{"defaultEditor":"https://raw.githubusercontent.com/l0rd/devworkspace-demo/container-contributions/vs-code.yml"}}}' \
  -n openshift-devspaces
```

### Set the default dev image to be the one published on quay.io
```bash
kubectl patch checluster devspaces \
  --type=merge -p \
  '{"spec":{"devEnvironments":{"defaultComponents":[{"name": "universal-developer-image", "container": {"image": "quay.io/devspaces/udi-rhel8:3.1"}}]}}}' \
  -n openshift-devspaces
```

### Use the latest upstream DevWorkspace
```bash
# This is required because of an issue with the current 
# DW operator version bundled with nightly Dev Spaces
./4-patch-dw-subcription.sh
```

# Run the demo

## STEP 1 - Start an IDE with a link (and show the power of URL parameters)

- Start an empty VS Code workspace
- Start a workspace pre-fixing a GitHub repository URL with the Dev Spaces URL
- Use the che-editor parameter
- Switch branch using a different URL

## STEP 2 - Use OAuth flow to automatically configure git

Once Dev Spaces has been authorized to get access to GitHub information:

- Opening a private repository works out of the box
- `git commit && git push` works out of the box

## STEP 3 - Test your application on Kubernetes (no need to oc login)

- `oc apply -f deployment.yaml` works out of the box to test the application
- To test changes a user can build (`mvn clean install`), push to local (`podman push`) and update (`oc rollout restart deploy`)  

## STEP 4 - Add a database to your development environment (using a devfile)

- Edit the workspace configuration adding a postgres container component to the devfile (`git commit && git push`)
- Delete the workspace and restart it using the factory link

## STEP 5 - Restricted network support (optional)

## STEP 6 - Image puller / ephemeral storage for faster workspaces startup (optional)

# Cleanup

```
```
