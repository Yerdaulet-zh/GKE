resource "google_storage_bucket" "s3_bucket" {
  name          = var.s3_bucket_name
  location      = var.region
  force_destroy = false
  project       = var.project_id
}
