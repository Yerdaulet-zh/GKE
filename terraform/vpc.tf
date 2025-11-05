# VPC
resource "google_compute_network" "vpc_network" {
  name                            = "gke-vpc-network"
  delete_default_routes_on_create = true
  auto_create_subnetworks         = false
  mtu                             = 1460
  routing_mode                    = "REGIONAL"
  depends_on                      = [google_project_service.api]
  description                     = "Custom VPC for GKE and workloads"
}

# Remove this route to make the VPC fully private
# You need this route for the NAT gateway.
resource "google_compute_route" "default_route" {
  name             = "default-internet-route"
  network          = google_compute_network.vpc_network.id
  dest_range       = "0.0.0.0/0"
  next_hop_gateway = "default-internet-gateway"
}