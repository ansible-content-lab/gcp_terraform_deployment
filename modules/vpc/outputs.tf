output "network_id" {
  value = google_compute_network.aap_infrastructure_vpc.id
  description = "The id of the VPC being created"
}