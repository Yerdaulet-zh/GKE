# Workload Identity Service Account
resource "google_service_account" "gke_sa" {
  disabled                     = false
  project                      = var.project_id
  account_id                   = "gke-sa-id"
  display_name                 = "Service account of GKE"
  description                  = "This account designed for GKE KSA from specific namespace to assume role of GSA to get permissions of GCP services for pods"
  create_ignore_already_exists = true
}

# Grant the Service Account the 'Storage Object Admin' role on the bucket
# This role grants permissions for storage.objects.* operations, 
# including create, delete, and view (get/list).
resource "google_storage_bucket_iam_member" "sa_s3_bucket_admin_permission" {
  bucket   = data.google_storage_bucket.s3_bucket.name
  for_each = toset(local.pod_roles)
  role     = each.key
  member   = "serviceAccount:${google_service_account.gke_sa.email}"
}

# The KMS Crypto Key used for GKE etcd encryption
resource "google_kms_crypto_key_iam_member" "gke_kms_access" {
  crypto_key_id = data.google_kms_crypto_key.gke_db_encryption_key.id

  # The required role for GKE to use the key for etcd encryption
  role = "roles/cloudkms.cryptoKeyEncrypterDecrypter"

  # Grant the role to the Google-managed GKE Service Agent (the 'container-engine-robot' SA).
  # This agent runs the GKE Control Plane and needs permission to encrypt/decrypt the etcd database.
  member = "serviceAccount:${local.gke_service_agent_email}"
}

# # 1. Define the Kubernetes Service Account (KSA)
# resource "kubernetes_service_account" "my_ksa" {
#   metadata {
#     name      = var.kubernetes_service_account_name 
#     namespace = var.kubernetes_namespace            

#     # CRITICAL: This annotation links the KSA to your GSA's email
#     annotations = {
#       "iam.gke.io/gcp-service-account" = google_service_account.gke_sa.email
#     }
#   }
# }

# 2. Grant the Workload Identity binding (Your existing resource)
resource "google_service_account_iam_member" "wi_binding_gsa_ksa" {
  service_account_id = google_service_account.gke_sa.name

  role = "roles/iam.workloadIdentityUser"

  # The implicit dependency on kubernetes_service_account.my_ksa 
  # via the variables ensures the KSA is created first.
  member = "serviceAccount:${var.project_id}.svc.id.goog[${var.kubernetes_namespace}/${var.kubernetes_service_account_name}]"
}

# NODE POOL Service Account 
resource "google_service_account" "gke_node_sa" {
  disabled                     = false
  project                      = var.project_id
  account_id                   = "gke-sa-node-pool-id"
  display_name                 = "Service account of GKE Nodes"
  description                  = "This account designed for GKE Node pools to get permissions of GCP services usually for logging and monitoring"
  create_ignore_already_exists = true

  timeouts {
    create = "5m"
  }
}

# Grant the minimal roles needed for GKE operation (Logging/Monitoring)
resource "google_project_iam_member" "gke_node_sa" {
  project  = var.project_id
  for_each = toset(local.node_pool_roles)
  role     = each.key
  member   = "serviceAccount:${google_service_account.gke_node_sa.email}"
}
