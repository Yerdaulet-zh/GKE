resource "google_compute_instance" "bastion" {
  name         = "bastion-host"
  machine_type = "e2-micro"
  zone         = "${var.region}-a"
  tags         = ["bastion", "allow-ssh"]

  boot_disk {
    initialize_params {
      # Ubuntu 22.04 LTS (Jammy) image
      image = "projects/ubuntu-os-cloud/global/images/family/ubuntu-2204-lts"
      size  = 20
      type  = "pd-balanced"
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.subnets["subnet_2"].id

    # ADDING THIS BLOCK ASSIGNS AN EPHEMERAL PUBLIC IP
    access_config {}
  }

  #   metadata = {
  #     ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  #   }

  service_account {
    email  = google_service_account.gke_node_sa.email
    scopes = ["cloud-platform"]
  }
}
