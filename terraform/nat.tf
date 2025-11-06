resource "google_compute_address" "nat" {
  name         = "nat-external-ip"
  address_type = "EXTERNAL"
  network_tier = "PREMIUM"

  depends_on = [
    google_project_service.api
  ]
}

resource "google_compute_router" "router" {
  name    = "nat-router"
  network = google_compute_network.vpc_network.id
  region  = var.region
}

# resource "google_compute_router_nat" "router" {
#   name                               = "nat"
#   router                             = google_compute_router.router.name
#   nat_ip_allocate_option             = "MANUAL_ONLY"
#   source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"
#   nat_ips                            = [google_compute_address.nat.self_link]

#   subnetwork {
#     name                    = google_compute_subnetwork.subnets["subnet_1"].self_link
#     source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
#   }
# }


resource "google_compute_router_nat" "nat" {
  name                               = "gke-regional-nat-gateway-europe-west8"
  router                             = google_compute_router.router.name
  region                             = google_compute_router.router.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = false
    filter = "ERRORS_ONLY"
  }
}
