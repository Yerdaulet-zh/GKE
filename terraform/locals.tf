locals {
  gke_service_agent_email = "service-${data.google_project.project.number}@container-engine-robot.iam.gserviceaccount.com"
  apis = [
    "compute.googleapis.com",
    "container.googleapis.com",
    "logging.googleapis.com",
    "secretmanager.googleapis.com",
    "containersecurity.googleapis.com"
  ]
  node_pool_roles = [
    "roles/container.nodeServiceAccount",
    "roles/logging.logWriter",
    "roles/monitoring.metricWriter",
    "roles/stackdriver.resourceMetadata.writer"
  ]
  pod_roles = [
    "roles/storage.objectAdmin"
  ]
  node_oauth_scopes = [
    "https://www.googleapis.com/auth/devstorage.read_only", # Required for pulling images from Artifact Registry (AR) & Google Container Registry (GCR)
    "https://www.googleapis.com/auth/logging.write",
    "https://www.googleapis.com/auth/monitoring",
    "https://www.googleapis.com/auth/monitoring.write",
    "https://www.googleapis.com/auth/service.management.readonly", # Both required by GKE for service management
    "https://www.googleapis.com/auth/servicecontrol"
  ]
  subnets = {
    subnet_1 = {
      name           = "subnet-1"
      cidr           = "10.0.0.0/16"
      pods_range     = "172.16.0.0/14"
      services_range = "192.168.0.0/20"
    },
    subnet_2 = {
      name           = "subnet-2"
      cidr           = "10.1.0.0/16"
      pods_range     = "172.20.0.0/14"
      services_range = "192.168.16.0/20"
    }
  }
}
