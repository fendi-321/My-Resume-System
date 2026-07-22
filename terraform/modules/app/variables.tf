variable "namespace_name" {
  description = "Kubernetes namespace"
  type        = string
}

variable "db_secret_name" {
  description = "Kubernetes secret name containing DB passwords"
  type        = string
  default     = "db-secret"
}

variable "image" {
  description = "App container image"
  type        = string
  default     = "resume-app:local"
}

variable "service_type" {
  description = "Kubernetes service type (NodePort for local, LoadBalancer for GKE)"
  type        = string
  default     = "NodePort"
}

variable "node_port" {
  description = "NodePort for local access"
  type        = number
  default     = 30080
}

variable "replicas" {
  description = "Number of app replicas"
  type        = number
  default     = 1
}

variable "storage_size" {
  description = "PVC storage size for uploads"
  type        = string
  default     = "100Mi"
}
