output "vm_private_ip" {
  description = "Private IP address assigned to the instance"
  value = google_compute_instance.aap_infrastructure_vm.network_interface.0.network_ip
}

output "vm_public_ip" {
  description = "Public IP address assigned to the instance"
  value = google_compute_instance.aap_infrastructure_vm.network_interface.0.access_config.0.nat_ip
}