terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "=5.12.0"
    }
  }
  required_version = ">= 1.5.4"
}

resource "google_compute_network" "aap_infrastructure_vpc" {
  name = "vpc-${var.deployment_id}-aap"
  auto_create_subnetworks = false
  mtu = 1460
}

resource "google_compute_subnetwork" "aap_infrastructure_subnets" {
  count = length(var.infrastructure_vpc_subnets)
  name = "subnet-${var.deployment_id}-${var.infrastructure_vpc_subnets[count.index]["name"]}"
  ip_cidr_range = var.infrastructure_vpc_subnets[count.index]["cidr_block"]
  region = var.region
  network = google_compute_network.aap_infrastructure_vpc.id

  depends_on = [ google_compute_network.aap_infrastructure_vpc ]
}

resource "google_compute_firewall" "aap_infrastructure_firewall_rules" {
  name = "aap-infrastructure-${var.deployment_id}-firewall"
  network = google_compute_network.aap_infrastructure_vpc.id
  description = "Creates firewall rule targeting tagged instances"
  target_tags = [ "aap-infrastructure-${var.deployment_id}" ]
  allow {
    protocol  = "tcp"
    ports     = ["22","80", "443", "5432","8443","27199"]
  }
  source_ranges = [ "0.0.0.0/0"]

  depends_on = [ google_compute_network.aap_infrastructure_vpc ]
}