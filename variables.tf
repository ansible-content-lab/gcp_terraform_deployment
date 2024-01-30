variable "deployment_id" {
  description = "Creates a random string that will be used in tagging for correlating the resources used with a deployment of AAP."
  type = string
  validation {
    condition = (length(var.deployment_id) == 8 || length(var.deployment_id) == 0) && (can(regex("^[a-z]", var.deployment_id)) || var.deployment_id == "")
    error_message = "deployment_id length should be 8 chars and should contain lower case alphabets only"
  }
}

variable "region" {
  description = "GCP region."
  type = string
  default = "us-east1"
}

variable "zone" {
  description = "GCP availability zone"
  type = string
  default = "us-east1-b"
}

variable "machine_type" {
  description = "Machine type to use for VM creation."
  type = string
  default = "n2-standard-2"
}

variable "infrastructure_db_username" {
  description = "PostgreSQL username."
  type = string
  default = "postgres"
}

variable "infrastructure_db_password" {
  description = "Initial PostgreSQL root password during creation."
  type = string
  sensitive = true
}

variable "infrastructure_controller_count" {
  description = "The number of instances for controller"
  type = number
  default = 2
}

variable "infrastructure_controller_machine_type" {
  description = "The number of instances for controller"
  type = string
  default = "n2-standard-2"
}

variable "infrastructure_eda_count" {
  description = "The number of EDA instances"
  type = number
  default = 0
}
variable "infrastructure_eda_machine_type" {
  description = "The number of instances for controller"
  type = string
  default = "n2-standard-2"
}

variable "infrastructure_execution_count" {
  description = "The number of execution instances"
  type = number
  default = 0
}

variable "infrastructure_execution_machine_type" {
  description = "The number of instances for controller"
  type = string
  default = "n2-standard-2"
}

variable "infrastructure_hub_count" {
  description = "The number of instances for hub"
  type = number
  default = 1
}

variable "infrastructure_hub_machine_type" {
  description = "The number of instances for controller"
  type = string
    default = "n2-standard-2"
}

variable "user" {
  description = "Username"
  type    = string
  default = "admin"
}
variable "aap_red_hat_username" {
  description = "Red Hat account name that will be used for Subscription Management."
  type = string
}

variable "aap_red_hat_password" {
  description = "Red Hat account password."
  type = string
  sensitive = true
}

variable "aap_admin_password" {
  description = "The admin password to create for Ansible Automation Platform application."
  type = string
  sensitive = true
}

variable "infrastructure_aap_installer_inventory_path" {
  description = "Inventory path on the installer host"
  default = "/home/awx/inventory_gcp.txt"
  type = string
}

variable "infrastructure_admin_ssh_public_key_filepath" {
  description = "Public ssh key file path."
  type = string
  default = "~/.ssh/id_rsa.pub"
}

variable "infrastructure_admin_ssh_private_key_filepath" {
  description = "Private ssh key file path."
  type = string
  default = "~/.ssh/id_rsa"
}

variable "infrastructure_admin_username" {
  type = string
  default = "awx"
  description = "The admin username of the VM that will be deployed."
  nullable = false
}
