[![Contribute](https://www.eclipse.org/che/contribute.svg)](https://workspaces.openshift.com#https://github.com/che-incubator/devspaces-demo)
  
[![Contribute (nightly)](https://img.shields.io/static/v1?label=nightly%20Che&message=for%20maintainers&logo=eclipseche&color=FDB940&labelColor=525C86)](https://che-dogfooding.apps.che-dev.x6e0.p1.openshiftapps.com/#https://github.com/che-incubator/devspaces-demo)

### [Supporting slides](https://docs.google.com/presentation/d/1PUwPsY8TosHMsQT0iMe6zLD4wrd66U_oot2_oSIM9F0/edit?usp=sharing)

# Preparation

You can either `git clone` this repository locally and run the following preparations steps from your terminal OR you can start a Dev Spaces development environment and run the commands from the IDE itself ([start on RH Developer Sandbox](https://workspaces.openshift.com/#https://github.com/che-incubator/devspaces-demo) or [start on the Che team dogfooding instance (internal only)](https://che-dogfooding.apps.che-dev.x6e0.p1.openshiftapps.com/#https://github.com/che-incubator/devspaces-demo)).

Pre-requisites: `oc`, `jq` and `git` should be pre-installed and you should be logged in as an admin of the target OpenShift cluster.

| :warning: WARNING                                                                                     |
|-------------------------------------------------------------------------------------------------------|
| Run `oc login` as an administrator on the target OpenShift cluster before running the following steps.|

```bash
# STEP 1: Install Dev Spaces next
git submodule init && git submodule update && git -C devspaces checkout devspaces-3-rhel-8 &&
cd devspaces/product && ./installDevSpacesFromLatestIIB.sh --next && \
oc patch OperatorHub cluster --type json -p '[{"op": "add", "path": "/spec/disableAllDefaultSources", "value": false}]' # re-enable default catalog sources

| :ship: NOTE                                                                                        |
|-------------------------------------------------------------------------------------------------------|
| If you want to install the **latest** stable release-in-progress (instead of the **next** CI build), you can use `./installDevSpacesFromLatestIIB.sh --latest`.|

```bash
# STEP 2: Day one configurations
# Create OpenShift unprivileged user (can be skipped if such a user already exist) 
./1-create-unprivileged-user.sh
# Configure workspace idling timeout (for demo purposes we disable it)
./2-disable-workspace-idling.sh
# Enable container build capabilites 
# c.f. https://che.eclipseprojects.io/2022/10/10/@mloriedo-building-container-images.html
./3-enable-container-build.sh
# Configure GitHub OAuth
# c.f. https://www.eclipse.org/che/docs/stable/administration-guide/configuring-oauth-2-for-github/#setting-up-the-github-oauth-app_che
export BASE64_GH_OAUTH_CLIENT_ID=<your-id>
export BASE64_GH_OAUTH_CLIENT_SECRET=<your-secret>
./4-configure-gh-oauth.sh
# Enable the Kubernetes Image Puller Operator
# c.f. https://github.com/che-incubator/kubernetes-image-puller-operator
./5-enable-image-puller.sh
```

Run the following script to pre-pull all the images of a pre-defined workspace (the workspace should be running in the developer namespace):

```bash
# export DEVELOPER_NAMESPACE="${OPENSHIFT_USER}-devspaces" <== if not set 'johndoe-devspaces' is used
./configure-image-puller.sh
```


Additional commands to patch Dev Spaces to use upstream images:

```bash
# Use upstream VS Code
export IDE_DEFINITION="https://eclipse-che.github.io/che-plugin-registry/main/v3/plugins/che-incubator/che-code/insiders/devfile.yaml"
./change-default-ide.sh

# Use upstream UDI
export UDI_IMAGE="quay.io/devspaces/udi-rhel8:3.3"
./change-default-component.sh

# Use upstream nightly DevWorkspace operator build
./patch-dw-subcription.sh
```

Depending on the cluster setup, if a `LimitRange` exists in the user namespace, you may have to adjust user namespace resource quotas to start workspaces with VS Code and IntelliJ:

```
export USER_NAMESPACE="USER NAMESPACE HERE"
./increase-namepsace-quotas.sh
```

# Run the demo

For STEP 3 and STEP 4, this [demo microservice project](https://github.com/dkwon17/quarkus-api-example/tree/devspaces) can be forked and used. When forking, confirm that the `devspaces` branch is copied to the fork.

## STEP 1 - Start an IDE with a link (and show the power of URL parameters)

- Start an empty VS Code workspace
- Start a workspace pre-fixing a GitHub repository URL with the Dev Spaces URL
- Use the che-editor parameter
  - To start a project with IntelliJ: `{CHE_HOST}/#{GIT_PROJECT_URL}?che-editor=che-incubator/che-idea/latest`
- Switch branch using a different URL

## STEP 2 - Use OAuth flow to automatically configure git

Once Dev Spaces has been authorized to get access to GitHub information:

- Opening a private repository works out of the box
- `git commit && git push` works out of the box

NOTE: The GitHub OAuth prompt will appear when starting a workspace with a GitHub repository in STEP 1.

NOTE: After accepting the OAuth prompt, to reset the OAuth flow so that the prompt appears again:

1. Delete the `devworkspace-merged-git-credentials`, `git-credentials-secret-*`, and `personal-access-token-*` secrets in the user namespace
2. Go to `https://github.com/settings/applications`, and revoke access for the OAuth app

## STEP 3 - Test your application on Kubernetes (no need to oc login)

- `oc apply -f deployment.yaml` works out of the box to test the application
- To test changes a user can build (`mvn clean install`), push to local (`podman push`) and update (`oc rollout restart deploy`)  

### If using the forked demo project:
- Start a workspace from the `devspaces` branch.
- Run the build (`Package` task).
- Build and push the application image to the OpenShift local registry by running the commands from the following tasks in this order: `Build Image`, `Login to local OpenShift registry`, `Push Image`.
- Deploy the application (Deployments, Services, etc.) with `oc apply -f template/app.yaml`
- Test the `/food` GET endpoint by running `curl -i quarkus-api-example/food` which returns all resources from the PostgreSQL database.
- To deploy and test subsequent changes users can run `Package`, `Build Image`, `Push Image` again, then run `oc rollout restart deploy quarkus-api-example`

This example shows ability to build, package, deploy and test applications from within the workspace.

## STEP 4 - Add a database to your development environment (using a devfile)
- Edit the workspace configuration adding a postgres container component to the devfile (`git commit && git push`)
- Delete the workspace and restart it using the factory link

### If using the forked demo project:
- To show it is possible to run the application within the workspace pod with a PostgreSQL container (in the same workspace pod), add the following container definition to the `components` section of the devfile using the VS Code editor:
    ```
    - name: postgresql
    container:
        image: 'quay.io/centos7/postgresql-13-centos7@sha256:994f5c622e2913bda1c4a7fa3b0c7e7f75e7caa3ac66ff1ed70ccfe65c40dd75'
        env:
        - name: POSTGRESQL_USER
            value: user
        - name: POSTGRESQL_PASSWORD
            value: password
        - name: POSTGRESQL_DATABASE
            value: food_db
        - name: PGDATA
            value: /tmp/pgdata
    ```
- Run `git add devfile.yaml`. Then, commit and push to the fork.
- Stop the current workspace and start a new workspace with the updated devfile, and wait until the new workspace starts.
- To run the application, run the command from the `Start Development mode (Hot reload + debug)` task. This runs a Maven goal that runs the Quarkus project in [Dev mode](https://quarkus.io/guides/getting-started#development-mode).
- Verify that the application is running by clicking `Open` on the `Listening on port 8080` VS Code notification.

This example shows that dependencies needed for development (in this case, the PostgreSQL database) is available within the workspace pod by adding new components in the devfile.

## STEP 5 - Restricted network support (optional)

## STEP 6 - Image puller / ephemeral storage for faster workspaces startup (optional)

## STEP 7 - Monitoring

# Cleanup

```
```
