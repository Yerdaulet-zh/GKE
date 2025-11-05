resource "google_container_cluster" "gke_cluster" {
  name     = var.cluster_name
  location = var.cluster_location

  # The cluster is zonal
  # node_locations = [
  #   var.cluster_location
  # ]

  # --- SECURITY & HARDENING ---
  deletion_protection   = false
  enable_shielded_nodes = true
  enable_legacy_abac    = false

  private_cluster_config {
    enable_private_endpoint = var.enable_private_endpoint
    enable_private_nodes    = var.enable_private_nodes

    # The dedicated /28 internal IP range for the Google-managed Control Plane. 
    # Must not overlap with any VPC network ranges.
    master_ipv4_cidr_block = var.master_ipv4_cidr_block

    # Specifies the existing subnetwork in your VPC where the GKE private endpoint IP will be provisioned.
    # private_endpoint_subnetwork = google_compute_subnetwork.subnets["subnet_1"].self_link

    # Configuration block for controlling access to the private endpoint from other regions.
    master_global_access_config {
      # When false (recommended default), access to the private API endpoint is restricted 
      # to resources within the cluster's region only.
      enabled = false
    }
  }

  master_authorized_networks_config {
    cidr_blocks {
      cidr_block   = local.subnets.subnet_1.cidr
      display_name = "Admin/Bastion Access"
    }
    cidr_blocks {
      cidr_block   = local.subnets.subnet_2.cidr
      display_name = "Admin/Bastion Access"
    }
  }

  workload_identity_config {
    # This is the Workload Identity Pool name
    workload_pool = "${var.project_id}.svc.id.goog"
  }

  binary_authorization {
    evaluation_mode = "PROJECT_SINGLETON_POLICY_ENFORCE"
  }

  database_encryption {
    state    = "ENCRYPTED"
    key_name = data.google_kms_crypto_key.gke_db_encryption_key.id
  }

  # --- NETWORKING (VPC-NATIVE) ---
  network    = google_compute_network.vpc_network.id
  subnetwork = google_compute_subnetwork.subnets["subnet_1"].name

  ip_allocation_policy {
    cluster_secondary_range_name  = google_compute_subnetwork.subnets["subnet_1"].secondary_ip_range[0].range_name # Uses "private-pods"
    services_secondary_range_name = google_compute_subnetwork.subnets["subnet_1"].secondary_ip_range[1].range_name # Uses "private-services"
  }

  # --- LOGGING & MONITORING ---
  logging_config {
    enable_components = ["SYSTEM_COMPONENTS", "APISERVER", "SCHEDULER", "WORKLOADS"]
  }

  monitoring_config {
    enable_components = ["SYSTEM_COMPONENTS", "APISERVER", "SCHEDULER", "CONTROLLER_MANAGER"]
  }

  # --- ADDONS CONFIG ---
  addons_config {
    # Disables the default GKE Ingress controller. This prevents GKE from automatically provisioning a Google Cloud HTTP(S) Load Balancer when you create a Kubernetes Ingress resource. This is often done when you plan to install a custom Ingress controller (like Nginx, Traefik, etc.) or when migrating to the newer Gateway API standard for traffic management.
    http_load_balancing {
      disabled = true
    }
    # Enables Network Policy enforcement. This allows you to use Kubernetes NetworkPolicy resources to define firewall-like rules for Pod-to-Pod traffic within the cluster. It is a critical feature for establishing a robust security posture based on the principle of least privilege.
    network_policy_config {
      disabled = false
    }
    # Enables the modern Container Storage Interface (CSI) driver for Google Compute Engine Persistent Disks. This is the recommended way to provision and manage PersistentVolumeClaim (PVC) resources in GKE, offering superior stability, performance, and features compared to the older in-tree volume plugin.
    gce_persistent_disk_csi_driver_config {
      enabled = true
    }
    # Enables NodeLocal DNSCache. This runs a small DNS caching agent on every node in your cluster. Its primary goal is to improve DNS lookup latency for Pods and reduce congestion on the central kube-dns or CoreDNS cluster service, leading to more reliable networking for applications.
    dns_cache_config {
      enabled = true
    }
  }

  # --- CLUSTER FEATURES ---
  default_max_pods_per_node = 120
  datapath_provider         = "ADVANCED_DATAPATH" # Alias for GKE Dataplane V2 / Cilium


  # --- NODE POOL DEFAULT CONFIG (FOR THE REMOVED POOL) ---
  initial_node_count       = 1
  remove_default_node_pool = true


  # --- MAINTENANCE & UPGRADES ---
  release_channel {
    channel = "STABLE"
  }

  maintenance_policy {
    # Perform daily maintenance between 3 AM and 7 AM UTC
    recurring_window {
      start_time = "2025-01-01T03:00:00Z"
      end_time   = "2025-01-01T07:00:00Z"
      recurrence = "FREQ=DAILY"
    }
    # Exclusion to prevent upgrades during a critical period
    maintenance_exclusion {
      exclusion_name = "Q4-freeze"
      start_time     = "2025-11-01T00:00:00Z"
      end_time       = "2026-01-31T23:59:59Z"
      exclusion_options {
        scope = "NO_MINOR_UPGRADES" # Only blocks minor version upgrades
      }
    }
  }

  resource_labels = {
    env          = "production"
    team_mlops   = true
    team_devops  = true
    team_backend = true
    team_ocr     = true
    team_llm     = true
    team_rag     = true
    team_asr     = true
    cost_center  = "cc-1234"
  }

  # Force the cluster to wait until the KMS permission is fully granted
  depends_on = [
    google_kms_crypto_key_iam_member.gke_kms_access
  ]

  timeouts {
    create = "30m"
    update = "30m"
    delete = "30m"
  }
}

































# ## 🔑 Dedicated Service Account for GKE Nodes
# resource "google_service_account" "gke_node_sa" {
#   account_id   = "gke-node-sa"
#   display_name = "GKE Node Service Account"
# }

# resource "google_service_account_key" "gke_node_sa_key" {
#   service_account_id = google_service_account.gke_node_sa.name
# }

# output "gke_node_sa_key_file" {
#   value     = google_service_account_key.gke_node_sa_key.private_key
#   sensitive = true
# }

# resource "google_container_cluster" "primary" {
#   name     = "full-featured-cluster"
#   location = "${var.region}-a" # Zonal Cluster

#   # --- FOUNDATION & SCALING ---
#   remove_default_node_pool = true
#   initial_node_count       = 1 # Placeholder for removal

#   # --- NETWORKING (VPC-NATIVE) ---
#   networking_mode = "VPC_NATIVE"
#   network         = google_compute_network.vpc_network.name
#   subnetwork      = google_compute_subnetwork.public_subnet.name # Cluster master uses this

#   ip_allocation_policy {
#     cluster_secondary_range_name  = google_compute_subnetwork.public_subnet.secondary_ip_range[0].range_name # Pods
#     services_secondary_range_name = google_compute_subnetwork.public_subnet.secondary_ip_range[1].range_name # Services
#   }

#   # --- LOGGING & MONITORING ---
# #   logging_service    = "logging.googleapis.com/kubernetes"
# #   monitoring_service = "monitoring.googleapis.com/kubernetes"

#   logging_config {
#     enable_components = ["SYSTEM_COMPONENTS", "APISERVER", "SCHEDULER", "WORKLOADS"]
#   }
#   monitoring_config {
#     enable_components = ["SYSTEM_COMPONENTS", "APISERVER", "SCHEDULER", "CONTROLLER_MANAGER"]
#   }

#   # --- ADDONS CONFIG ---
#   addons_config {
#     # Disable default Ingress in favor of a custom one or Gateway API
#     http_load_balancing {
#       disabled = true
#     }
#     # Enable Network Policy enforcement
#     network_policy_config {
#       disabled = false
#     }
#     # Enable the modern CSI driver for Persistent Disks
#     gce_persistent_disk_csi_driver_config {
#       enabled = true
#     }
#     # Enable NodeLocal DNSCache for lower latency DNS lookups
#     dns_cache_config {
#       enabled = true
#     }
#   }

#   # --- MAINTENANCE & UPGRADES ---
#   release_channel {
#     channel = "STABLE" # Recommended channel for predictable updates
#   }

# maintenance_policy {
#   # Perform daily maintenance between 3 AM and 7 AM UTC
#   recurring_window {
#     start_time = "2025-01-01T03:00:00Z"
#     end_time   = "2025-01-01T07:00:00Z"
#     recurrence = "FREQ=DAILY"
#   }
#   # Exclusion to prevent upgrades during a critical period
#   maintenance_exclusion {
#     exclusion_name = "Q4-freeze"
#     start_time     = "2025-11-01T00:00:00Z"
#     end_time       = "2025-12-31T23:59:59Z"
#     exclusion_options {
#       scope = "NO_MINOR_UPGRADES" # Only blocks minor version upgrades
#     }
#   }
# }

#   # --- SECURITY & HARDENING ---
#   deletion_protection = false # PREVENT ACCIDENTAL DESTRUCTION

# # Node Shielding and ABAC (ABAC should be false)
# enable_shielded_nodes = true # Ensure nodes use shielded features
# enable_legacy_abac    = false

#   # Master Authorization
#   master_authorized_networks_config {
#     # Disable external access to the API master, forcing access through internal network/VPC peering/Bastion
#     gcp_public_cidrs_access_enabled = true # false
#     # cidr_blocks {
#     #   cidr_block   = "YOUR_BASTION_IP/32" # Example: Only allow your admin/bastion IP
#     #   display_name = "Admin Bastion"
#     # }
#   }

# # Binary Authorization (Recommended for production)
# binary_authorization {
#   evaluation_mode = "PROJECT_SINGLETON_POLICY_ENFORCE"
# }

#   # --- NODE POOL DEFAULT CONFIG (FOR THE REMOVED POOL) ---
#   node_config {
#     # NODE CONFIG DISK: Defining the node's boot disk
#     boot_disk {
#       disk_type = "pd-balanced" # Better performance than pd-standard
#       size_gb   = 20
#     }
#     # Default Service Account for Nodes
#     service_account = google_service_account.gke_node_sa.email
#     oauth_scopes    = ["https://www.googleapis.com/auth/cloud-platform"]
#   }
# }


# # NODES
# resource "google_container_node_pool" "public_nodes" {
#   name     = "public-pool"
#   location = google_container_cluster.primary.location
#   cluster  = google_container_cluster.primary.name

#   # --- SCALING ---
#   node_count = 1
#   autoscaling {
#     min_node_count = 1
#     max_node_count = 5 
#   }

#   # --- NETWORKING ---
#   node_locations = [google_container_cluster.primary.location]
#   # subnetwork     = google_compute_subnetwork.public_subnet.name

#   # --- NODE CONFIGURATION ---
#   node_config {
#     machine_type    = "e2-medium"
#     service_account = google_service_account.gke_node_sa.email
#     tags            = ["gke-public-node"]
#     labels          = {
#       role = "public"
#     }

#     # Disk Configuration (Balanced performance for general-purpose workloads)
#     boot_disk {
#       disk_type = "pd-balanced" 
#       size_gb   = 20 # Larger disk for web servers or image caching
#     }

#     # Shielded Nodes (Security)
#     shielded_instance_config {
#       enable_secure_boot = true
#     }

#     # Performance (Recommended for GKE)
#     gvnic {
#       enabled = true # Google Virtual NIC for better networking performance
#     }
#   }
# }
