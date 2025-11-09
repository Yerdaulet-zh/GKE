data "google_project" "project" {
  project_id = var.project_id
}

data "google_storage_bucket" "s3_bucket" {
  name = var.s3_bucket_name
}

data "google_kms_crypto_key" "gke_db_encryption_key" {
  name     = var.kms_key_name
  key_ring = var.kms_key_ring
}

data "google_artifact_registry_repository" "fastapi_ai_repo" {
  project       = var.project_id
  location      = var.region
  repository_id = var.repository_id
}
