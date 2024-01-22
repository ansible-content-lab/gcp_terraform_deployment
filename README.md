# gcp_terraform_deployment

This is the template that will deploy Ansible on GCP. While this template will work with any Ansible deployment on GCP, this is intended to be a starting point for customers that purchase Ansible Automation Platform subscriptions from the GCP marketplace. Take this template and enhance/improve/update based on the resources that you need for your AAP deployment.

## Introduction

This template performs the following actions in the order listed.

| Step | Description |
| ---- | ----------- |
| Create a deployment ID | Creates a random string that will be used in tagging for correlating the resources used with a deployment of AAP. |
| Create a virtual network | Creates a virtual network with subnets with a CIDR block.|
| Create subnets | Creates the subnets for automation controller, execution environments, private automation hub, and Event-Driven Ansible. |
| Create a firewall rules | Creates a firewall roules group that allows AAP ports within the VPC and HTTPS and automation mesh ports externally. |

## Getting Started

This section will walk through deploying the GCP infrastructure and Ansible Automation Platform.

You may also download the this repository from GitHub and modify to suit your needs.

### GCP Credentials

This terraform template requires GCP credentials, which can be set in different places, through environment variables, or the gcloud CLI profile `gcloud auth application-default login`
The easiest, and most portable, approach will be to set `GOOGLE_APPLICATION_CREDENTIALS` environment variable to the path of the service account JSON file.

## Deploying Ansible Automation Platform

This section will walk through deploying the GCP infrastructure and Ansible Automation Platform.

### Checklist

- [ ] Download this repository
- [ ] Terraform installed locally (`terraform`)
- [ ] Configure the GCP environment variable for authentication

### Deploying infrastructure

Assuming that all variables are configured properly and your GCP account has permission to deploy the resources defined in this template.

Initialize Terraform

```bash
terraform init -upgrade
```

Validate configuration
```bash
terraform validate
```

Check the plan

```bash
terraform plan -out=test-plan.tfplan
```

Apply infrastructure

```bash
terraform apply
```
Confirm to create infrastructure or pass in the `-auto-approve` parameter.

## Uninstall

This will permanently remove all data and infrastructure from the Google cloud, so only run this if you are sure that you want to delete all traces of the deployment.

```bash
terraform destroy
```
Confirm to destroy infrastructure or pass in the `-auto-approve` parameter.

## Linting Terraform

We recommend using [tflint](https://github.com/terraform-linters/tflint) to help with maintaining terraform syntax and standards.

### Initialize
```bash
tflint --init
```
### Running tflint
```bash
tflint --recursive
```