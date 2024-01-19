locals {
  create_deployment_id = var.deployment_id != "" ? 0 : 1
  # Common tags to be assigned to all resources
  persistent_tags = {
    purpose = "automation"
    environment = "ansible-automation-platform"
    deployment = "aap-infrastructure-${var.deployment_id}"
  }
}

terraform {
  required_providers {
    random = {
      source = "hashicorp/random"
      version = "~> 3.6.0"
    }
    google = {
      source  = "hashicorp/google"
      version = "=5.12.0"
    }
  }
  required_version = ">= 1.5.4"
}

provider "google" {
  project = "agcp-001-dev"
  region = "us-east1"
}

# Create deployment_id
resource "random_string" "deployment_id" {
  count = local.create_deployment_id
  length = 8
  special = false
  upper = false
  numeric = false
}