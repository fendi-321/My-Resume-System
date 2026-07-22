variable "namespace_name" {
  description = "Kubernetes namespace"
  type        = string
}

variable "db_name" {
  description = "Database name"
  type        = string
  default     = "online_resume_system"
}

variable "db_user" {
  description = "Database user"
  type        = string
  default     = "resume_user"
}

variable "db_secret_name" {
  description = "Kubernetes secret name containing DB passwords"
  type        = string
  default     = "db-secret"
}

variable "storage_size" {
  description = "PVC storage size for MySQL"
  type        = string
  default     = "1Gi"
}

variable "image" {
  description = "MySQL image"
  type        = string
  default     = "mysql:8.0"
}
