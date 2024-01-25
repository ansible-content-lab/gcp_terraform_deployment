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
  region = var.region
  zone = var.zone
}

# Create deployment_id
resource "random_string" "deployment_id" {
  count = local.create_deployment_id
  length = 8
  special = false
  upper = false
  numeric = false
}

#
# Network
#
module "vnet" {
  depends_on = [ random_string.deployment_id ]

  source = "./modules/vpc"
  deployment_id = var.deployment_id == "" ? random_string.deployment_id[0].id : var.deployment_id
  region = var.region
}

module "database" {
  depends_on = [ random_string.deployment_id , module.vnet ]

  source = "./modules/database"
  deployment_id = var.deployment_id == "" ? random_string.deployment_id[0].id : var.deployment_id
  region = var.region
  infrastructure_db_password = var.infrastructure_db_password
  vpc_network_id = module.vnet.network_id
  persistent_tags = local.persistent_tags
}

module "controller" {
  depends_on = [ module.vnet ]
  source = "./modules/vm"

  count = var.infrastructure_controller_count
  app_tag = "controller-${count.index + 1}-"
  deployment_id = var.deployment_id
  machine_type = var.machine_type
  zone = var.zone
  vpc_network_id = module.vnet.network_id
  vpc_subnetwork_name = "subnet-${var.deployment_id}-controller"
  persistent_tags = local.persistent_tags
}

module "hub" {
  depends_on = [ module.vnet ]
  source = "./modules/vm"

  count = var.infrastructure_hub_count
  app_tag = "hub-${count.index + 1}-"
  deployment_id = var.deployment_id
  machine_type = var.machine_type
  zone = var.zone
  vpc_network_id = module.vnet.network_id
  vpc_subnetwork_name = "subnet-${var.deployment_id}-hub"
  persistent_tags = local.persistent_tags
}

module "execution" {
  depends_on = [ module.vnet ]
  source = "./modules/vm"

  count = var.infrastructure_execution_count
  app_tag = "execution-${count.index + 1}-"
  deployment_id = var.deployment_id
  machine_type = var.machine_type
  zone = var.zone
  vpc_network_id = module.vnet.network_id
  vpc_subnetwork_name = "subnet-${var.deployment_id}-execution"
  persistent_tags = local.persistent_tags
}

module "eda" {
  depends_on = [ module.vnet ]
  source = "./modules/vm"

  count = var.infrastructure_eda_count
  app_tag = "eda-${count.index + 1}-"
  deployment_id = var.deployment_id
  machine_type = var.machine_type
  zone = var.zone
  vpc_network_id = module.vnet.network_id
  vpc_subnetwork_name = "subnet-${var.deployment_id}-eda"
  persistent_tags = local.persistent_tags
}