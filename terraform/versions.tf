terraform {
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
