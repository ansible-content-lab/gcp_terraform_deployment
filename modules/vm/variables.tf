variable "deployment_id" {
  description = "Creates a random string that will be used in tagging for correlating the resources used with a deployment of AAP."
  type = string
  validation {
    condition = (length(var.deployment_id) == 8 || length(var.deployment_id) == 0) && (can(regex("^[a-z]", var.deployment_id)) || var.deployment_id == "")
    error_message = "deployment_id length should be 8 chars and should contain lower case alpha chars only"
  }
}

variable "app_tag" {
  description = "AAP tag used in VM name."
  type = string
}

variable "machine_type" {
  description = "Machine type to use for VM creation."
  type = string
}

variable "zone" {
  description = "GCP availability zone"
  type = string
  default = "us-east1-b"
}

variable "vpc_network_id" {
  type = string
  description = "VPC network name"
}

variable "vpc_subnetwork_name" {
  type = string
  description = "VPC subnetwork name"
}

variable persistent_tags {
  description = "Persistent tags"
  type = map(string)
}

variable "infrastructure_admin_ssh_public_key_filepath" {
  description = "Public ssh key file path."
  type = string
}

variable "infrastructure_admin_ssh_private_key_filepath" {
  description = "Private ssh key file path."
  type = string
}

variable "infrastructure_admin_username" {
  type = string
  description = "The admin username of the VM that will be deployed."
  nullable = false
}

variable "aap_red_hat_username" {
  description = "The RedHat Account name"
  type = string
}

variable "aap_red_hat_password" {
  description = "The Red Hat account password."
  type = string
  sensitive = true
}
