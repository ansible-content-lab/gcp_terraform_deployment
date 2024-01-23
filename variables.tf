variable "deployment_id" {
  description = "Creates a random string that will be used in tagging for correlating the resources used with a deployment of AAP."
  type = string
  validation {
    condition = (length(var.deployment_id) == 8 || length(var.deployment_id) == 0) && (can(regex("^[a-z]", var.deployment_id)) || var.deployment_id == "")
    error_message = "deployment_id length should be 8 chars and should contain lower case alphabets only"
  }
}

variable "region" {
  description = "GCP region"
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
