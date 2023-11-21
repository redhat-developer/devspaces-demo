[![Open](https://img.shields.io/static/v1?label=open%20in&message=developer%20sandbox&logo=eclipseche&color=FDB940&labelColor=525C86)](https://workspaces.openshift.com/#https://github.com/redhat-developer/devspaces-demo/tree/20231122-prep)

### [Supporting slides](https://docs.google.com/presentation/d/1PUwPsY8TosHMsQT0iMe6zLD4wrd66U_oot2_oSIM9F0/edit?usp=sharing)

# Preparation

### Create a Developer Sandbox Account if you don't have one yet

Follow the instructions on [Red Hat Developer Sandbox web page](https://developers.redhat.com/developer-sandbox) to create an account. This will allow you to start a cloud development environment running this repository.

### Provision an OpenShift cluster and copy the cluster API URL and token

The cluster should run OpenShift 4.10 or later. And Dev Spaces should not be installed there. Once you have access to it **as an admin**, copy the API URL and token:

| Select "Copy login command"   |  Copy OpenShift API URL and token 
:------------------------------:|:--------------------------------------:
![alt text](images/open-login-command.png "Open \"Copy login command\"") | ![alt text](images/copy-api-url-and-token.png "Copy URL and token")


### Open this repository in a cloud development environment

Once you are done, click the badge ![Open](https://img.shields.io/static/v1?label=open%20in&message=developer%20sandbox&logo=eclipseche&color=FDB940&labelColor=525C86) at the top of this page. After a few seconds you should see VS Code running in your browser with the source code of this repository.

| CDE Startup   |  CDE Running VS Code
:------------------------------:|:--------------------------------------:
![alt text](images/startup.png "CDE Startup") | ![alt text](images/vscode.png "CDE Running VS Code")

The cloud development environment that you started runs in a container with all the pre-requisties to run this demo. 

<!-- VS Code has some predefined "Devfile" tasks commands that can be used to run this demo steps.

|  Run Tasks Menu  |  Devfile Tasks
:------------------------------:|:--------------------------------------:
![alt text](images/run-task-menu.png "Run Tasks Menu") | ![alt text](images/devfile-tasks.png "Devfile Tasks") -->


# Dev Spaces Deployment

Open a terminal in VS Code (`Terminal -> New Terminal`) and execute the following commands:
```bash
# Login to your OpenShift cluster
# When prompted provide the API URL and Token retrieved in the preparation section
./commands/login.sh 

# Install OpenShift Dev Spaces CLI (`dsc`)
./commands/download-cli.sh

# Deploy OpenShift Dev Spaces
./commands/deploy.sh latest
```

Congratulations, you have just deployed OpenShift Dev Spaces. Follow the "Users Dashboard" link to log in to Dev Spaces.

|  `dsc server:deploy`  |  Users Dashboard
:------------------------------:|:--------------------------------------:
![alt text](images/deploy-successful.png "dsc server:deploy") | ![alt text](images/dashboard.png "Users dashboard")

# Dev Spaces Configuration

### Configure [GitHub OAuth](https://access.redhat.com/documentation/en-us/red_hat_openshift_dev_spaces/3.9/html/administration_guide/configuring-devspaces#configuring-oauth-2-for-github) flow (or [Bitbucket](https://access.redhat.com/documentation/en-us/red_hat_openshift_dev_spaces/3.9/html/administration_guide/configuring-devspaces#configuring-oauth-2-for-a-bitbucket-server), [Gitlab](https://access.redhat.com/documentation/en-us/red_hat_openshift_dev_spaces/3.9/html/administration_guide/configuring-devspaces#configuring-oauth-2-for-gitlab), [AzureDevops](https://access.redhat.com/documentation/en-us/red_hat_openshift_dev_spaces/3.9/html/administration_guide/configuring-devspaces#configuring-oauth-2-for-microsoft-azure-devops-services))

```bash
./commands/configure-gh-oauth.sh
```

### Patch the [CheCluster Custom Resource](https://doc.crds.dev/github.com/eclipse-che/che-operator/org.eclipse.che/CheCluster/v2)

The following scripts will patch the `CheCluster` custom resource named `devspaces` in the `openshift-devspaces` namespace.

```bash
# Disable inactive cloud development environment idling
./commands/disable-idling.sh
# Change the default development container to be upstream UDI
./commands/change-dev-container.sh quay.io/devfile/universal-developer-image
# Change the default IDE
./commands/change-default-ide.sh
# Use open-vsx.org rather than the embedded open-vsx registry
./commands/use-open-vsx.org.sh
```

A lot more can be configured using the CheCluster custom resource. Try editing the CR from the OpenShift Console.

### Enable the [Kubernetes Image Puller](https://access.redhat.com/documentation/en-us/red_hat_openshift_dev_spaces/3.9/html/administration_guide/configuring-devspaces#caching-images-for-faster-workspace-start)

```bash
./commands/enable-image-puller.sh
```

Run the following script to configure the [Kubernetes Image Puller](https://github.com/che-incubator/kubernetes-image-puller-operator) to pre-pull all the images of a pre-defined workspace (the workspace should be running in the developer namespace):

```bash
./commands/configure-image-puller.sh
```

### Configure the Getting Started samples in Users dashboard

[Link to the documentation article](https://access.redhat.com/documentation/en-us/red_hat_openshift_dev_spaces/3.9/html/administration_guide/configuring-devspaces#configuring-getting-started-samples)

### Additional (optional) customizations

```bash
# Use nightly DevWorkspace operator build
./commands/additionals/patch-dw-subcription.sh
# Sometimes increasing the developer namespace resource
# quotas is required (especially to run IntelliJ)
./commands/additionals/increase-resource-range.sh
```

### Airgap specific customization

OpenShift Dev Spaces is designed to run on restricted networks. The documentation article to install OpenShift Dev Spaces in such a network can be found [here](https://access.redhat.com/documentation/en-us/red_hat_openshift_dev_spaces/3.9/html/administration_guide/installing-devspaces#installing-devspaces-in-a-restricted-environment).

# Run the demo

For STEP 3 and STEP 4, this [demo microservice project](https://github.com/dkwon17/quarkus-api-example/tree/devspaces) can be forked and used. When forking, confirm that the `devspaces-demo` branch is copied to the fork.

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
