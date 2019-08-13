## Description
 
The project is a solution of the problem 
https://github.com/xpeppers/cloud-phoenix-kata

The app was dockerized using a Dockerfile and deployed on a AKS Azure Cluster deployed by Terraform.

The CI part use Travis, Github for source repository and Docker Hub for the image registry.

Both the app and Mongodb are deployed on the AKS by the travis CI.

For achieving the target I use also helm chart for Mongodb and Nginx.

The scaling part is done using this
https://github.com/Azure/azure-k8s-metrics-adapter
implementation of the Kubernetes Custom Metrics API and External Metrics API for Azure Services plus the Horizontal Pod Autoscale.

The monitoring solution use both helm chart for Prometheus+Grafana.

The logging part use the Azure Insight for the log retention.

## Terraform

Before starting clone the entire project.

This part require Terraform https://www.terraform.io/ (tested with v0.12.5) an Azure account and a service principal as described here:
https://www.terraform.io/docs/providers/azurerm/auth/service_principal_client_secret.html

Once obtained put it in azure.auto.tfvars under terraform directory:

`client_id= "XXX"`
`client_secret = "XXX"`
`tenant_id = "XXX"`
`subscription_id = "XXX"`

and deploy using terraform apply.

5 resources will be created:

- azurerm_resource_group : resource group containing all the deployment
- azurerm_kubernetes_cluster : selfexplaining
- azurerm_application_insight and azurerm_application_insights_api_key : used for metrics and scaling parts
- azurerm_log_analytics_workspace : log workspace

At the end terraform will output 
`app_id` 
`full_permissions_api_key`
`instrumentation_key` 
`kube_config`

Save it, these variables are required in the next step by Travis CI.


## Travis CI

This part require to connect your Travis server with the repo where you clone the entire project.

I use
https://travis-ci.org
connected to my repo in GitHub.
You must set these variables to point to your Docker Hub in Travis before run CI:
DOCKER_REPO
DOCKER_USERNAME
DOCKER_PASSWORD
If you don't want to rebuild the app these variables are not required and you have to comment the `script` step in `.travis.yml` file.

These variables are required in Travis, take from the previous step:
`API_KEY`
`APP_ID`
`INSTRUMENTATION_KEY`

Save `kube_config` Terraform output to a private repo, create a GITHUB_ACCESS_TOKEN and change the line 
`- curl -o config https://$GITHUB_ACCESS_TOKEN@raw.githubusercontent.com/iosdal/privaterepo/master/.kube/config`
pointing to your private repo containing the kubernetes credentials.

`.travis.yml` steps explained:
- install: install kubectl,helm binaries and copy Kubernetes config file;
- script: build the app using `Dockerfile` and push to Docker registry;
- deploy: all the required components are deployed on the Kubernetes cluster:
    - helm installing on the cluster;
    - mongodb with a PVC to persist data;
    - installation of the `azure-k8s-metrics-adapter` and the custom-metric used by the `hpa`;
    - deployment of the app itself in `deployment`;
    - deployment of nginx ingress controller;
    - deployment of the monitoring parts using prometheus+grafana;
    - output of the nginx public ip address and grafana password.

After running the CI and waiting few minutes for having all the resources running, obtain the public ip of the app using:

`kubectl get service -l app=nginx-ingress --namespace demo`

For acceding grafana use 
`export POD_NAME=$(kubectl get pods --namespace monitoring -l "app=grafana,release=grafana" -o jsonpath="{.items[0].metadata.name}")`
and
`kubectl --namespace monitoring port-forward $POD_NAME 3000`


## Note regarding Problem Requirements

1. `GET /crash` and `GET /generatecert` are blocked by `ingress-controller`;
2. Recover from crashes are implemented by kubernetes;
4. The logs are saved in `azurerm_log_analytics_workspace` with a retention period of 30 days (>7)
5. The database are saved in a  7 days
5. Notify any CPU peak
7. Scale when the number of request are greater than 10 req /sec


## Various

Being only a demo, some parts are not production ready:
- mongodb require username and password and maybe as a service using Atlas (kubernetes is not a perfet fit for prodution db);
- https with certificate
- some variables passing...


The Travis CI read the `.travis.yml` file, build the 

The development team has released the phoenix application code.
Your task, if you want to accept it, is to create the production infrastructure
for the Phoenix application. You must pay attention to some unwanted features
that were introduced during development. In particular:

- `GET /crash` kill the application process
- `GET /generatecert` is not optimized and creates resource consumption peaks

## General Requirements

- You may use whatever programming language/platform you prefer. Use something that you know well.
- You must release your work with an OSI-approved open source license of your choice.
- You must deliver the sources, with a README that explains how to run it.
- Add the code to your own Github account and send us the link.


## Problem Requirements

1. Automate the creation of the infrastructure and the setup of the application.
2. Recover from crashes. Implement a method autorestart the service on crash
3. Backup the logs and database with rotation of 7 days
4. Notify any CPU peak
5. Implements a CI/CD pipeline for the code
6. Scale when the number of request are greater than 10 req /sec