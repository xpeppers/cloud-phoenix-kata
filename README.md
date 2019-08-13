## Description
 
The project is a solution of the problem 

https://github.com/xpeppers/cloud-phoenix-kata

The app was dockerized using a Dockerfile and deployed on a AKS Azure Cluster deployed Terraform.

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

`DOCKER_REPO`

`DOCKER_USERNAME`

`DOCKER_PASSWORD`

If you don't want to rebuild the app these variables are not required and you have to comment the `before_script` step in `.travis.yml` file.

These variables are required in Travis, take from the previous step:

`API_KEY`

`APP_ID`

`INSTRUMENTATION_KEY`

Save `kube_config` Terraform output to a private repo, create a GITHUB_ACCESS_TOKEN and change the line accordling:

`- curl -o config https://$GITHUB_ACCESS_TOKEN@raw.githubusercontent.com/iosdal/privaterepo/master/.kube/config`

pointing to your private repo containing the kubernetes credentials.

Travis CI steps explained:

- install: install kubectl,helm binaries and copy Kubernetes config file;
- before_script: build the app using `Dockerfile` and push to Docker registry;
- script: all the required components are deployed on the Kubernetes cluster:
    - helm installing on the cluster;
    - mongodb with a PVC to persist data;
    - installation of the `azure-k8s-metrics-adapter` and the custom-metric used by the `hpa`;
    - deployment of the app itself in `deployment`;
    - deployment of nginx ingress controller;
    - deployment of the monitoring parts using prometheus+grafana;
    - output of the nginx public ip address and grafana password.

After running the CI and waiting few minutes for having all the resources running, obtain the public ip of the app using:

`kubectl get service -l app=nginx-ingress --namespace demo`

Point the browser to this public IP.

For acceding grafana use 

`export POD_NAME=$(kubectl get pods --namespace monitoring -l "app=grafana,release=grafana" -o jsonpath="{.items[0].metadata.name}")`

and

`kubectl --namespace monitoring port-forward $POD_NAME 3000`

with password obtained in CI or from:

`kubectl get secret --namespace monitoring grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo`


## Note regarding Problem Requirements

1. `GET /crash` and `GET /generatecert` are blocked by `ingress-controller`;
2. Recover from crashes are implemented by kubernetes;
4. The logs are saved in `azurerm_log_analytics_workspace` with a retention period of 30 days (>7);
5. The database are in a separate pvc but unfortunally Azure volume plugin are not supported by Volume Snapshot Alpha for Kubernetes. So some strategies for backupping are possible but not achieved in the project. For example using Microsoft Recovery Service form tha Azure portal is possible to backup the vm on wich the cluster is running. Other method for backupping the db is to use simple mongodbdump (https://docs.mongodb.com/manual/tutorial/backup-and-restore-tools/) with a cronjob and a bash script; 
5. Notify any CPU peak -> possible using azure portal or using an alert on a Dashboard in Grafana (not implemented but I known how to do...). 
7. Scale when the number of request are greater than 10 req /sec -> achieved using this metric adapter https://github.com/Azure/azure-k8s-metrics-adapter and a custom metric. The original app was modified to include Application Insights SDK https://docs.microsoft.com/en-us/azure/azure-monitor/app/nodejs. Other methods are possible, using prometheus metrics for instance, but not tested.


## Various

Being only a demo, some parts are not production ready:
- mongodb require username and password and maybe as a service using Atlas (kubernetes is not a perfet fit for prodution db);
- https with certificate
- secure helm
- implement mongodb backup
- some variables passing
- terraform deploy included in CI and remote state...

