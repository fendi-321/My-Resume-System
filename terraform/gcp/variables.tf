variable "gcp_project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "gcp_region" {
  description = "GCP Region"
  type        = string
  default     = "asia-southeast1"
}

variable "cluster_name" {
  description = "GKE Cluster name"
  type        = string
  default     = "resume-app-cluster"
}

variable "node_machine_type" {
  description = "GKE node machine type"
  type        = string
  default     = "e2-micro"
}

variable "node_disk_size" {
  description = "GKE node disk size in GB"
  type        = number
  default     = 20
}

variable "min_nodes" {
  description = "Minimum number of nodes"
  type        = number
  default     = 1
}

variable "max_nodes" {
  description = "Maximum number of nodes"
  type        = number
  default     = 3
}

variable "use_preemptible_nodes" {
  description = "Use preemptible (spot) nodes to reduce cost"
  type        = bool
  default     = true
}
