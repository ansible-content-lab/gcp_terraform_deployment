terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "=5.12.0"
    }
  }
  required_version = ">= 1.5.4"
}

resource "google_compute_global_address" "private_ip_address" {
  name = "private-ip-address"
  purpose = "VPC_PEERING"
  address = "172.16.4.0"
  address_type = "INTERNAL"
  prefix_length = 24
  network = var.vpc_network_id
}

resource "google_service_networking_connection" "private_vpc_connection" {
  depends_on = [ google_compute_global_address.private_ip_address ]

  network = var.vpc_network_id
  service = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [ google_compute_global_address.private_ip_address.name ]
  #deletion_policy = "ABANDON"
}

resource "google_sql_database_instance" "aap_infrastructure_db_instance" {
  depends_on = [google_service_networking_connection.private_vpc_connection]

  name = "aap-infrastructure-${var.deployment_id}-db"
  database_version = format("POSTGRES_%s", var.database_version)
  region = var.region
  root_password = var.infrastructure_db_password
  instance_type = "CLOUD_SQL_INSTANCE"
  deletion_protection = var.deletion_protection_enabled

  settings {
    tier = var.tier
    edition = var.edition
    availability_type = var.availability_type
    deletion_protection_enabled = var.deletion_protection_enabled
    disk_size = var.disk_size
    disk_type = var.disk_type

    ip_configuration {
      ipv4_enabled = var.ipv4_enabled
      private_network = var.vpc_network_id
    }
  }
}

resource "google_sql_database" "controller" {
  name = "controller"
  instance = google_sql_database_instance.aap_infrastructure_db_instance.name
  charset = var.db_charset
  collation = var.db_collation
  depends_on = [ google_sql_database_instance.aap_infrastructure_db_instance ]
  deletion_policy = var.database_deletion_policy
}

resource "google_sql_database" "hub" {
  name = "hub"
  instance = google_sql_database_instance.aap_infrastructure_db_instance.name
  charset = var.db_charset
  collation = var.db_collation
  depends_on = [ google_sql_database_instance.aap_infrastructure_db_instance ]
  deletion_policy = var.database_deletion_policy
}

resource "google_sql_database" "eda" {
  name = "eda"
  instance = google_sql_database_instance.aap_infrastructure_db_instance.name
  charset = var.db_charset
  collation = var.db_collation
  depends_on = [ google_sql_database_instance.aap_infrastructure_db_instance ]
  deletion_policy = var.database_deletion_policy
}
