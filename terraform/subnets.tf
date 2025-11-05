resource "google_compute_subnetwork" "subnets" {
  for_each                 = local.subnets
  name                     = each.value.name
  ip_cidr_range            = each.value.cidr
  network                  = google_compute_network.vpc_network.id
  stack_type               = "IPV4_ONLY"
  private_ip_google_access = true

  secondary_ip_range {
    range_name    = "pods-cidr-range"
    ip_cidr_range = each.value.pods_range
  }

  secondary_ip_range {
    range_name    = "services-cidr-range"
    ip_cidr_range = each.value.services_range
  }
}
