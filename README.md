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
| Create a database server | Creates a PostgreSQL database instance and the necessary databases inside of it for the controller, hub, and Event-Driven Ansible components. |
| Create a vpc peering | Creates a vpc peering between vpc network and a google's vpc network where SQL instance resides. |
| Create the controller VMs | Creates VMs for controller with the public IP attached. |
| Create the execution nodes VMs | Creates VMs for execution nodes (if enabled) with the public IP attached. |
| Create the hub VMs | Creates VMs for private automation hub with the public IP attached. |
| Create the Event-Driven Ansible VMs | Creates VMs for Event-Driven Ansible (if enabled) with the public IP attached. |
| Register the VMs with Red Hat | Uses RHEL subscription manager to register each virtual machine for required RPM repos. |
| Update the VMs | Updates each VM deployed with latest kernel and packages. |
| Setup one controller VM as the installer | Configures the installer VMs with a private SSH key so that it can communicate with the other VMs that are part of the installation process and configures the installer inventory file based on the VMs that were created as part of this process. |
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

The variables below are required for running this template

| Variable | Description |
| -------- | ----------- |
| `infrastructure_db_username` | Username that will be the admin of the new database server. |
| `infrastructure_db_password` | Password of the admin of the new database server. |
| `aap_admin_password` | The admin password to create for Ansible Automation Platform application. |
| `aap_red_hat_password` | The Red Hat account password. |
| `aap_red_hat_username` | This is your Red Hat account name that will be used for Subscription Management (https://access.redhat.com/management). |

The variables below are optional for running this template

| Variable | Description |
| -------- | ----------- |
| `deployment_id` | This is a random string that will be used in tagging for correlating the resources used with a deployment of AAP. It is lower case alpha chars between 2-10 char length. If not provided, template will generate the deployment_id. |
| `infrastructure_controller_count` | The number of instances for controller. |
| `infrastructure_controller_machine_type` | The SKU which should be used for controller Virtual Machine. |
| `infrastructure_eda_count` | The number of instances for Event-Driven Ansible. |
| `infrastructure_eda_machine_type` | The SKU which should be used for Event-Driven Ansible Virtual Machine. |
| `infrastructure_execution_count` | The number of instances for execution. |
| `infrastructure_execution_machine_type` | The SKU which should be used for execution Virtual Machine. |
| `infrastructure_hub_count` | The number of instances for hub. |
| `infrastructure_hub_machine_type` | The SKU which should be used for hub Virtual Machine. |
| `infrastructure_admin_ssh_public_key_filepath` | SSH public key path. |
| `infrastructure_admin_ssh_private_key_filepath` | SSH private key path. |

Additional variables can be found in variables.tf, modules/database/variables.tf, modules/vm/variables.tf, modules/vpc/variables.tf

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

### Installing Red Hat Ansible Automation Platform

At this point you can ssh into one of the controller nodes and run the installer. The example below assumes the default variables.tf values for `infrastructure_admin_username` and `infrastructure_admin_ssh_private_key_filepath`.

```bash
ssh -i ~/.ssh/id_rsa gcp-user@<controller-public-ip>
```

We provided a sample inventory that could be used to deploy AAP.
You might need to edit the inventory to fit your needs.

Before you start the installation, you need to attach Ansible Automation Platform to the system where you're running the installer. 

Find the pool id for Ansible Automation Platform subscription using command
```bash
sudo subscription-manager list --all --available
```

Attach subscription to all the VMs
```bash
sudo subscription-manager attach --pool=<pool-id>
```

Run the installer to deploy Ansible Automation Platform
```bash
$ cd /opt/ansible-automation-platform/installer/
$ sudo ./setup.sh -i inventory_gcp
```

For more information, read the install guide from https://access.redhat.com/documentation/en-us/red_hat_ansible_automation_platform/

## Uninstall

This will permanently remove all data and infrastructure from the Google cloud, so only run this if you are sure that you want to delete all traces of the deployment.

```bash
terraform destroy
```
Confirm to destroy infrastructure or pass in the `-auto-approve` parameter.

*Note*: If terraform destroy gets stuck on deleting the network connection, you can manually delete the network connection in the GCP console then run `terraform destroy` again

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