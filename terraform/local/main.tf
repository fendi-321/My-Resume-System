terraform {
  backend "local" {}
  required_version = ">= 1.5"
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.30"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
}

provider "kubernetes" {
  config_path = "~/.kube/config"
  config_context = var.kube_context
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
  service_type   = "NodePort"
  node_port      = 30080
  image          = "resume-app:local"
}

output "namespace" {
  value = module.namespace.namespace_name
}

output "app_service" {
  value = module.app.service_name
}

output "db_password" {
  value     = module.security.db_password
  sensitive = true
}

output "root_password" {
  value     = module.security.root_password
  sensitive = true
}
