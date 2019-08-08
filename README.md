## Docker build
 docker build .

## Docker run
docker run -p 27017:27017 mongo
docker run -p 8087:8087 -e "PORT=8087" -e "DB_CONNECTION_STRING=mongodb://192.168.126.186" 547e24e698ff

## Terraform
Create account secret on azure here:
https://www.terraform.io/docs/providers/azurerm/auth/service_principal_client_secret.html

az ad sp create-for-rbac --role="Contributor" --scopes="/subscriptions/a723289e-cec5-4992-b4b5-caefd0fd82c1"

{
  "appId": "8054868f-de24-4a28-94e4-7f3372fd383f",
  "displayName": "azure-cli-2019-08-08-12-51-03",
  "name": "http://azure-cli-2019-08-08-12-51-03",
  "password": "d7169ea1-df3e-44dc-8c24-5ed20b52a8ad",
  "tenant": "13794713-9d51-48f8-b678-6bf46fa7d127"
}

You must create account for remote state on:

https://app.terraform.io/signup?utm_source=blog&utm_campaign=intro_tf_cloud_remote

token:
ya8tXU8d7JuePg.atlasv1.0aXNeij2zOBFCtjCzYey1PnifyE04uAl6KMSbw0c8A2dFXKQO5yT47yAQILm3hXuYmw



## Problem

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

## Application Requirements

- Runs on Node.js 8.11.1 LTS
- MongoDB as Database
- Environment variables:
    - PORT - Application HTTP Exposed Port
    - DB_CONNECTION_STRING - Database connection string `mongodb://[username:password@]host1[:port1][,host2[:port2],...[,hostN[:portN]]][/[database][?options]]`

## Run Application
- Install dependencies `npm install`
- Run `npm start`
- Connect to `http://<hostname|IP>:<ENV.PORT>`

## Problem Requirements

1. Automate the creation of the infrastructure and the setup of the application.
2. Recover from crashes. Implement a method autorestart the service on crash
3. Backup the logs and database with rotation of 7 days
4. Notify any CPU peak
5. Implements a CI/CD pipeline for the code
6. Scale when the number of request are greater than 10 req /sec