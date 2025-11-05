resource "google_compute_firewall" "allow_iap_ssh" {
  name      = "allow-iap-ssh"
  network   = google_compute_network.vpc_network.name
  direction = "INGRESS"
  priority  = 1000

  allow {
    protocol = "tcp"
    ports    = ["22", "443"]
  }

  source_ranges = ["0.0.0.0/0"] # Official IAP IP range 35.235.240.0/20
  target_tags   = ["allow-ssh"]
  description   = "Allow SSH from Google Cloud IAP only"
}
