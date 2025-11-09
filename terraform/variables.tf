variable "project_id" {
  description = "The ID of the project in which to provision resources."
  type        = string
  sensitive   = true
}

variable "region" {
  description = "Cluster Region"
  type        = string
  sensitive   = true
}

variable "json_credential_path" {
  description = "json credential"
  type        = string
  sensitive   = true
}

variable "s3_bucket_name" {
  description = "s3 bucket name for GKE pods"
  type        = string
  sensitive   = true
}

# GKE Related Variables

variable "cluster_name" {
  description = "GKE Cluster Name"
  type        = string
  sensitive   = true
}

variable "cluster_location" {
  description = "Cluster location (zone)"
  type        = string
  sensitive   = true
}

variable "kubernetes_namespace" {
  description = "kubernetes_namespace"
  type        = string
  sensitive   = true
}

variable "kubernetes_service_account_name" {
  description = "kubernetes_service_account_name"
  type        = string
  sensitive   = true
}

variable "master_ipv4_cidr_block" {
  description = "The dedicated /28 internal IP range for the Google-managed Control Plane."
  type        = string
  sensitive   = true
}

variable "enable_private_nodes" {
  description = "If true, all worker nodes will be provisioned with only private (RFC 1918) IP addresses."
  type        = bool
  default     = true
  sensitive   = true
}

variable "enable_private_endpoint" {
  description = "If true, the Control Plane (API server) is only accessible via its private IP; the public endpoint is disabled."
  type        = bool
  default     = true
  sensitive   = true
}

variable "kms_key_name" {
  description = "The name of the KMS key for database encryption."
  type        = string
  sensitive   = true
}

variable "kms_key_ring" {
  description = "The key ring of the KMS key for database encryption."
  type        = string
  sensitive   = true
}

# Artifact Registry Related Variables
variable "repository_id" {
  description = "The name of the Artifact Registry repository."
  type        = string
  sensitive   = true
}
