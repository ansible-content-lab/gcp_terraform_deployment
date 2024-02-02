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
  app_tag = "controller"
  deployment_id = var.deployment_id
  machine_type = var.infrastructure_controller_machine_type
  zone = var.zone
  vpc_network_id = module.vnet.network_id
  vpc_subnetwork_name = "subnet-${var.deployment_id}-controller"
  persistent_tags = local.persistent_tags
  infrastructure_admin_ssh_public_key_filepath = var.infrastructure_admin_ssh_public_key_filepath
  infrastructure_admin_ssh_private_key_filepath = var.infrastructure_admin_ssh_private_key_filepath
  infrastructure_admin_username = var.infrastructure_admin_username
  aap_red_hat_username = var.aap_red_hat_username
  aap_red_hat_password = var.aap_red_hat_password
}

module "hub" {
  depends_on = [ module.vnet ]
  source = "./modules/vm"

  count = var.infrastructure_hub_count
  app_tag = "hub"
  deployment_id = var.deployment_id
  machine_type = var.infrastructure_hub_machine_type
  zone = var.zone
  vpc_network_id = module.vnet.network_id
  vpc_subnetwork_name = "subnet-${var.deployment_id}-hub"
  persistent_tags = local.persistent_tags
  infrastructure_admin_ssh_public_key_filepath = var.infrastructure_admin_ssh_public_key_filepath
  infrastructure_admin_ssh_private_key_filepath = var.infrastructure_admin_ssh_private_key_filepath
  infrastructure_admin_username = var.infrastructure_admin_username
  aap_red_hat_username = var.aap_red_hat_username
  aap_red_hat_password = var.aap_red_hat_password
}

module "execution" {
  depends_on = [ module.vnet ]
  source = "./modules/vm"

  count = var.infrastructure_execution_count
  app_tag = "execution"
  deployment_id = var.deployment_id
  machine_type = var.infrastructure_execution_machine_type
  zone = var.zone
  vpc_network_id = module.vnet.network_id
  vpc_subnetwork_name = "subnet-${var.deployment_id}-execution"
  persistent_tags = local.persistent_tags
  infrastructure_admin_ssh_public_key_filepath = var.infrastructure_admin_ssh_public_key_filepath
  infrastructure_admin_ssh_private_key_filepath = var.infrastructure_admin_ssh_private_key_filepath
  infrastructure_admin_username = var.infrastructure_admin_username
  aap_red_hat_username = var.aap_red_hat_username
  aap_red_hat_password = var.aap_red_hat_password
}

module "eda" {
  depends_on = [ module.vnet ]
  source = "./modules/vm"

  count = var.infrastructure_eda_count
  app_tag = "eda"
  deployment_id = var.deployment_id
  machine_type = var.infrastructure_eda_machine_type
  zone = var.zone
  vpc_network_id = module.vnet.network_id
  vpc_subnetwork_name = "subnet-${var.deployment_id}-eda"
  persistent_tags = local.persistent_tags
  infrastructure_admin_ssh_public_key_filepath = var.infrastructure_admin_ssh_public_key_filepath
  infrastructure_admin_ssh_private_key_filepath = var.infrastructure_admin_ssh_private_key_filepath
  infrastructure_admin_username = var.infrastructure_admin_username
  aap_red_hat_username = var.aap_red_hat_username
  aap_red_hat_password = var.aap_red_hat_password
}

resource "terraform_data" "copy_inventory" {
for_each = { for host, instance in flatten(module.controller[*].vm_public_ip): host => instance }

  provisioner "file" {
    connection {
      type = "ssh"
      user = var.infrastructure_admin_username
      host = each.value
      private_key = file(var.infrastructure_admin_ssh_private_key_filepath)
    }
     content = templatefile("${path.module}/templates/inventory.j2", {
        aap_controller_hosts = module.controller[*].vm_private_ip
        aap_ee_hosts = module.execution[*].vm_private_ip
        aap_hub_hosts = module.hub[*].vm_private_ip
        aap_eda_hosts = module.eda[*].vm_private_ip
        aap_eda_allowed_hostnames = module.eda[*].vm_public_ip
        infrastructure_db_username = var.infrastructure_db_username
        infrastructure_db_password = var.infrastructure_db_password
        aap_red_hat_username = var.aap_red_hat_username
        aap_red_hat_password= var.aap_red_hat_password
        aap_db_host = module.database.infrastructure_controller_name
        aap_db_private_ip = module.database.private_ip_address
        aap_admin_password = var.aap_admin_password
        infrastructure_admin_username = var.infrastructure_admin_username
      })
      destination = var.infrastructure_aap_installer_inventory_path
  }

  provisioner "file" {
    connection {
      type = "ssh"
      user = var.infrastructure_admin_username
      host = each.value
      private_key = file(var.infrastructure_admin_ssh_private_key_filepath)
    }
    content = templatefile("${path.module}/templates/config.j2", {
        aap_controller_hosts = module.controller[*].vm_private_ip
        aap_ee_hosts = module.execution[*].vm_private_ip
        aap_hub_hosts = module.hub[*].vm_private_ip
        aap_eda_hosts = module.eda[*].vm_private_ip
        infrastructure_admin_username = var.infrastructure_admin_username
    })
    destination = "/home/${var.infrastructure_admin_username}/.ssh/config"
  }

  provisioner "remote-exec" {
    connection {
      type = "ssh"
      user = var.infrastructure_admin_username
      host = each.value
      private_key = file(var.infrastructure_admin_ssh_private_key_filepath)
    }
      inline = [
        "chmod 0644 /home/${var.infrastructure_admin_username}/.ssh/config",
        "sudo cp /home/${var.infrastructure_admin_username}/.ssh/config /root/.ssh/config",
        "sudo cp ${var.infrastructure_aap_installer_inventory_path} /opt/ansible-automation-platform/installer/inventory_gcp",
        "sudo automation-controller-service stop",
        "sudo systemctl stop receptor",
        "sudo usermod awx -d /var/lib/awx -s /bin/bash"
      ]
  }
}