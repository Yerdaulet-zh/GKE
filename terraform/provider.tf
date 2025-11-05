terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "7.8.0"
    }
  }
  required_version = ">1.1.0"
}

provider "google" {
  project     = var.project_id
  region      = var.region
  credentials = var.json_credential_path
}


