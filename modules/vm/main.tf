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
  tags = [ "aap-infrastructure-${var.deployment_id}" ]
  boot_disk {
    initialize_params {
      image = var.machine_image
    }
  }
  network_interface {
    network = var.vpc_network_id
    subnetwork = var.vpc_subnetwork_name
    access_config {
    }
  }
  metadata = {
    ssh-keys = "${var.infrastructure_admin_username}:${file(var.infrastructure_admin_ssh_public_key_filepath)}"
  }
  
  labels = var.persistent_tags
}

resource "terraform_data" "aap_infrastructure_sshkey" {
  depends_on = [  google_compute_instance.aap_infrastructure_vm ]

  count = var.app_tag == "controller" ? 1: 0
  connection {
      type = "ssh"
      user = var.infrastructure_admin_username
      host = google_compute_instance.aap_infrastructure_vm.network_interface[0].access_config[0].nat_ip
      private_key = "${file(var.infrastructure_admin_ssh_private_key_filepath)}"
  }
  provisioner "file" {
    source = var.infrastructure_admin_ssh_private_key_filepath
    destination = "/home/${var.infrastructure_admin_username}/.ssh/infrastructure_ssh_private_key.pem"
  }
  provisioner "remote-exec" {
    inline = [
      "chmod 0600 /home/${var.infrastructure_admin_username}/.ssh/infrastructure_ssh_private_key.pem",
    ]
  }
}

resource "terraform_data" "aap_subscription_manager" {
  depends_on = [ google_compute_instance.aap_infrastructure_vm ]

  triggers_replace = [
    google_compute_instance.aap_infrastructure_vm.id
  ]
  connection {
    type = "ssh"
    user = var.infrastructure_admin_username
    host = google_compute_instance.aap_infrastructure_vm.network_interface[0].access_config[0].nat_ip
    private_key = file(var.infrastructure_admin_ssh_private_key_filepath)
  }
  provisioner "remote-exec" {
    inline = [
      "sudo subscription-manager register --username ${var.aap_red_hat_username} --password ${var.aap_red_hat_password} --auto-attach",
      "sudo subscription-manager config --rhsm.manage_repos=1",
      "yes | sudo dnf upgrade"
      ]
  }
}
