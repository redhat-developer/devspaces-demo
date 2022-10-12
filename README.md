[![Contribute (nightly)](https://img.shields.io/static/v1?label=nightly%20Che&message=for%20maintainers&logo=eclipseche&color=FDB940&labelColor=525C86)](https://che-dogfooding.apps.che-dev.x6e0.p1.openshiftapps.com/#https://github.com/che-incubator/devspaces-demo)

### [Supporting slides](https://docs.google.com/presentation/d/1PUwPsY8TosHMsQT0iMe6zLD4wrd66U_oot2_oSIM9F0/edit?usp=sharing)

# Preparation

Git clone this repository and run following commands locally or from a Dev Spaces development environment ([developer sandbox](https://workspaces.openshift.com/#https://github.com/che-incubator/devspaces-demo) or [dogfooding instance](https://che-dogfooding.apps.che-dev.x6e0.p1.openshiftapps.com/#https://github.com/che-incubator/devspaces-demo)).

Pre-requisites: `oc`, `jq` and `git` should be pre-installed and you should be logged in as an admin of the target OpenShift cluster.

```bash
# STEP 0: Install Dev Spaces next
git -C devspaces checkout devspaces-3-rhel-8 &&
cd devspaces/product &&
./installDevSpacesFromLatestIIB.sh --next

# STEP 1: Configure GitHub OAuth (c.f. https://www.eclipse.org/che/docs/stable/administration-guide/configuring-oauth-2-for-github/#setting-up-the-github-oauth-app_che
# export BASE64_GH_OAUTH_CLIENT_ID=<your-id>
# export BASE64_GH_OAUTH_CLIENT_SECRET=<your-secret>
./1-configure-gh-oauth.sh

# STEP 2: Create an OpenShift unprivileged user (can be skipped if such a user already exist)
# export OPENSHIFT_USER=<your-username>
# export OPENSHIFT_PASSWORD=<your-password>
./2-create-unprivileged-user.sh

# STEP 3: Configure Dev Spaces for container build (c.f. https://che.eclipseprojects.io/2022/10/10/@mloriedo-building-container-images.html
./3-create-container-build-scc.sh

# STEP 4: Use upstream nightly DevWorkspace operator build
./4-patch-dw-subcription.sh

# STEP 5: Change the default IDE to be upstream VS Code
export IDE_DEFINITION="https://eclipse-che.github.io/che-plugin-registry/main/v3/plugins/che-incubator/che-code/insiders/devfile.yaml"
./5-change-default-ide.sh

# STEP 6: Change default component image to be the UDI from quay.io
export UDI_IMAGE="quay.io/devspaces/udi-rhel8:3.1"
./6-change-default-component.sh

# STEP 7: Setup the image puller
# export DEVELOPER_NAMESPACE="${OPENSHIFT_USER}-devspaces"
# export DEVSPACES_HOST=<devspaces-hostname>
./7-image-puller-setup.sh

# STEP 8: Disable workspace idling
./8-disable-workspace-idling.sh
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
