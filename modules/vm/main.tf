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

resource "google_compute_instance" "default" {
  depends_on = [ random_string.infrastructure_vm_deployment_id ]
  name = "vm-${var.deployment_id}-${var.app_tag}-${random_string.infrastructure_vm_deployment_id.id}"
  machine_type =  var.machine_type
  zone         =  var.zone

  boot_disk {
    initialize_params {
      image = "aap-installer-1704995744-x86-64"
    }
  }

  network_interface {
    network = "vpc-${var.deployment_id}-aap"
    subnetwork = "subnet-${var.deployment_id}-${var.app_tag}"
  }

  labels = {
      "purpose" = "automation"
      "environment" = "ansible-automation-platform"
      "deployment" = "aap-infrastructure-${var.deployment_id}"
    }
}
