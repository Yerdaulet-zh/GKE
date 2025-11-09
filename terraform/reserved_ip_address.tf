# resource "google_compute_address" "static_external_ip" {
#   name = "my-reserved-external-ip"

#   # Required: The region where the IP address will be reserved.
#   # Note: Global IP addresses use the 'google_compute_global_address' resource instead.
#   region = var.region

#   # Optional: Defaults to "EXTERNAL" but can be explicitly set.
#   address_type = "EXTERNAL"

#   # Optional: Setting the desired IP version. Defaults to IPV4.
#   ip_version = "IPV4"
# }

# output "external_ip_address" {
#   description = "The reserved static external IP address"
#   value       = google_compute_address.static_external_ip.address
# }
