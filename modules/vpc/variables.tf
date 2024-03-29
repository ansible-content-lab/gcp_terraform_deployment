variable "deployment_id" {
  description = "Creates a random string that will be used in tagging for correlating the resources used with a deployment of AAP."
  type = string
  validation {
    condition = (length(var.deployment_id) == 8 || length(var.deployment_id) == 0) && (can(regex("^[a-z]", var.deployment_id)) || var.deployment_id == "")
    error_message = "deployment_id length should be 8 chars and should contain lower case alphabets only"
  }
}

variable "infrastructure_vpc_subnets" {
  type = list(object({
    name = string
    cidr_block = string
  }))
  default = [{
    name = "controller"
    cidr_block = "172.16.0.0/24"
  },
   {
    name = "execution"
    cidr_block = "172.16.1.0/24"
  },
  {
    name = "hub"
    cidr_block = "172.16.2.0/24"
  },
  {
    name = "eda"
    cidr_block = "172.16.3.0/24"
  }]
}

variable "region" {
  description = "GCP region"
  type = string
}