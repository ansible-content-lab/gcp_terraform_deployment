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
}

variable "database_version" {
  description = "Postgres database version"
  type = string
  default = "15"
}

variable "deletion_protection_enabled" {
  description = "Enables protection of an instance from accidental deletion across all surfaces (API, gcloud, Cloud Console and Terraform)."
  type = bool
  default = false
}

variable "infrastructure_db_password" {
  description = "PostgreSQL password."
  type = string
  sensitive = true
}

variable "tier" {
  description = "The tier for the master instance."
  type = string
  default = "db-f1-micro"
}

variable "edition" {
  description = "The edition of the instance, can be ENTERPRISE or ENTERPRISE_PLUS."
  type = string
  default = "ENTERPRISE"
}

variable "availability_type" {
  description = "The availability type for the master instance.This is only used to set up high availability for the PostgreSQL instance. Can be either `ZONAL` or `REGIONAL`."
  type = string
  default = "REGIONAL"
}

variable "disk_size" {
  description = "The disk size, in GB, for the master instance."
  type = number
  default = 10
}

variable "disk_type" {
  description = "The disk type for the master instance."
  type = string
  default = "PD_SSD"
}

variable "db_collation" {
  description = "The collation for the default database. Example: 'en_US.UTF8'"
  type = string
  default = "en_US.UTF8"
}

variable "db_charset" {
  description = "The charset for the default database"
  type = string
  default = "UTF8"
}

variable "database_deletion_policy" {
  description = "The deletion policy for the database. Setting ABANDON allows the resource to be abandoned rather than deleted. This is useful for Postgres, where databases cannot be deleted from the API if there are users other than cloudsqlsuperuser with access. Possible values are: \"ABANDON\"."
  type = string
  default = "DELETE"
}

variable "vpc_network_id" {
  type = string
  description = "VPC network name"
}

variable "sql_db_address" {
  type = string
  description = "SQL db instance ip address"
  default = "172.16.4.0"
}

variable "ipv4_enabled" {
  description = "Whether the databse instance is assigned a public IP address or not."
  default = false
  type = bool
}