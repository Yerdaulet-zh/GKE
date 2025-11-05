# resource "google_compute_address" "nat" {
#   name         = "nat-external-ip"
#   address_type = "EXTERNAL"
#   network_tier = "PREMIUM"

#   depends_on = [
#     google_project_service.api
#   ]
# }

# resource "google_compute_router" "router" {
#   name    = "nat-router"
#   network = google_compute_network.vpc_network.id
# }

# # resource "google_compute_router_nat" "router" {
# #   name                               = "nat"
# #   router                             = google_compute_router.router.name
# #   nat_ip_allocate_option             = "MANUAL_ONLY"
# #   source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"
# #   nat_ips                            = [google_compute_address.nat.self_link]

# #   subnetwork {
# #     name                    = google_compute_subnetwork.subnets["subnet_1"].self_link
# #     source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
# #   }
# # }


# resource "google_compute_router_nat" "nat_gateway" {
#   # ... other NAT configuration (router, region, etc.) ...

#   router = google_compute_router.router.name
#   region = google_compute_router.router.region
#   name   = "my-multi-subnet-nat"

#   # Configure NAT to automatically allocate IPs
#   nat_ip_allocate_option = "AUTO_ONLY"

#   # Specify how to handle primary and secondary IP ranges
#   source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

#   # --- The Key Change: Use a dynamic block to iterate over all subnets ---
#   dynamic "subnetwork" {
#     for_each = google_compute_subnetwork.subnets # Assuming 'subnets' is a map of subnetwork resources
#     content {
#       name = subnetwork.value.self_link
#       # Specify to NAT all primary and secondary IP ranges for this subnet
#       source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
#     }
#   }
# }
