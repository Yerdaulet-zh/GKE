resource "google_container_node_pool" "nginx" {
  name     = "nginx-node-pool"
  location = var.cluster_location
  cluster  = google_container_cluster.gke_cluster.name

  # --- 1. SCALABILITY & HA  ---

  # The cluster is zonal thus omitted 
  # node_locations = [
  #   var.cluster_location
  # ]

  initial_node_count = 1

  autoscaling {
    min_node_count = 1
    max_node_count = 2
  }

  # --- 2. RELIABILITY: Management (Essential for operations) ---
  management {
    auto_repair  = true # Essential: GKE replaces unhealthy nodes
    auto_upgrade = true # Essential: GKE applies patches/versions automatically
  }

  # --- 3. NODE CONFIGURATION & SECURITY ---
  node_config {
    machine_type    = "e2-medium"      # Good starting point, adjust as needed
    disk_size_gb    = 20               # Recommended to increase default 100GB disk size for logs/images
    disk_type       = "pd-ssd"         # Recommended for better I/O performance
    image_type      = "COS_CONTAINERD" # Google specific Container-Optimized OS with containerd
    preemptible     = false            # SPOT
    service_account = google_service_account.gke_node_sa.email

    # Security Hardening: Disable legacy metadata endpoints
    metadata = {
      disable-legacy-endpoints = "true"
    }

    # Provide OAuth scopes (URLs of GCP services' API which needed by the nodes)
    oauth_scopes = local.node_oauth_scopes

    labels = {
      environment = "production"
      team        = "devops"
      app         = "reverse-proxy"
    }

    shielded_instance_config {
      enable_integrity_monitoring = true
      enable_secure_boot          = true
    }

    # Optional: Enable Customer Managed Encryption Key (CMEK) for boot disks
    # boot_disk_kms_key = var.boot_disk_kms_key_self_link 

    # If using GPU (currently commented out):
    # guest_accelerator {
    #   type  = "nvidia-tesla-k80"
    #   count = 1
    # }
  }

  timeouts {
    create = "30m"
    update = "20m"
  }
}
