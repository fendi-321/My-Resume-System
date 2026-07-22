terraform {
  backend "gcs" {
    bucket = "resume-app-terraform-state"
    prefix = "prod"
  }
}

provider "google" {
  project = var.gcp_project_id
  region  = var.gcp_region
}

# GKE Cluster
resource "google_container_cluster" "resume_app" {
  name     = var.cluster_name
  location = var.gcp_region
  network  = "default"

  initial_node_count = 1

  node_config {
    machine_type = var.node_machine_type
    disk_size_gb = var.node_disk_size
    preemptible  = var.use_preemptible_nodes
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }

  node_pool {
    name               = "default-pool"
    initial_node_count = 1
    autoscaling {
      min_node_count = var.min_nodes
      max_node_count = var.max_nodes
    }
  }

  deletion_protection = false
}

# Artifact Registry
resource "google_artifact_registry_repository" "resume_app" {
  location      = var.gcp_region
  repository_id = "resume-app"
  description   = "Docker repository for resume app"
  format        = "DOCKER"
}

# GCS Bucket for Terraform state
resource "google_storage_bucket" "terraform_state" {
  name          = "resume-app-terraform-state"
  location      = var.gcp_region
  force_destroy = false
  versioning {
    enabled = true
  }
}

# Get kubeconfig from cluster
data "google_container_cluster" "resume_app" {
  name     = google_container_cluster.resume_app.name
  location = var.gcp_region
  depends_on = [google_container_cluster.resume_app]
}

provider "kubernetes" {
  host  = "https://${data.google_container_cluster.resume_app.endpoint}"
  token = data.google_container_cluster.resume_app.access_token
  cluster_ca_certificate = base64decode(
    data.google_container_cluster.resume_app.master_auth[0].cluster_ca_certificate
  )
}

module "namespace" {
  source = "../modules/namespace"
}

module "security" {
  source         = "../modules/security"
  namespace_name = module.namespace.namespace_name
}

module "mysql" {
  source         = "../modules/mysql"
  namespace_name = module.namespace.namespace_name
  db_secret_name = module.security.db_secret_name
}

module "app" {
  source         = "../modules/app"
  namespace_name = module.namespace.namespace_name
  db_secret_name = module.security.db_secret_name
  service_type   = "LoadBalancer"
  image          = "${var.gcp_region}-docker.pkg.dev/${var.gcp_project_id}/resume-app/resume-app:latest"
}

output "cluster_name" {
  value = google_container_cluster.resume_app.name
}

output "cluster_endpoint" {
  value = google_container_cluster.resume_app.endpoint
}

output "artifact_registry" {
  value = google_artifact_registry_repository.resume_app.id
}

output "namespace" {
  value = module.namespace.namespace_name
}

output "db_password" {
  value     = module.security.db_password
  sensitive = true
}

output "root_password" {
  value     = module.security.root_password
  sensitive = true
}
