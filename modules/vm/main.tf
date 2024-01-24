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

resource "random_string" "infrastructure_vm_deployment_id" {
  length = 8
  special = false
  upper = false
  numeric = false
}

resource "google_compute_instance" "aap_infrastructure_vm" {
  depends_on = [ random_string.infrastructure_vm_deployment_id ]
  name = "vm-${var.deployment_id}-${var.app_tag}-${random_string.infrastructure_vm_deployment_id.id}"
  machine_type = var.machine_type
  zone = var.zone
  boot_disk {
    initialize_params {
      image = "aap-installer-1704995744-x86-64"
    }
  }
  network_interface {
    network = var.vpc_network_id
    subnetwork = "subnet-${var.deployment_id}-${var.app_tag}"
  }
  labels = var.persistent_tags
}
