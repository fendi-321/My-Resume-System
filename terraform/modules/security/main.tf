resource "kubernetes_secret_v1" "db_secret" {
  metadata {
    name      = "db-secret"
    namespace = var.namespace_name
  }
  data = {
    DB_PASS     = random_password.db_password.result
    ROOT_PASS   = random_password.root_password.result
  }
}

resource "random_password" "db_password" {
  length  = 24
  special = false
}

resource "random_password" "root_password" {
  length  = 32
  special = false
}

resource "kubernetes_network_policy_v1" "deny_all_ingress" {
  metadata {
    name      = "deny-all-ingress"
    namespace = var.namespace_name
  }
  spec {
    pod_selector {}
    policy_types = ["Ingress"]
  }
}

resource "kubernetes_network_policy_v1" "allow_mysql_from_app" {
  metadata {
    name      = "allow-mysql-from-app"
    namespace = var.namespace_name
  }
  spec {
    pod_selector {
      match_labels = var.mysql_selector
    }
    policy_types = ["Ingress"]
    ingress {
      from {
        pod_selector {
          match_labels = var.app_selector
        }
      }
      ports {
        port     = "3306"
        protocol = "TCP"
      }
    }
  }
}

output "db_secret_name" {
  value = kubernetes_secret_v1.db_secret.metadata[0].name
}

output "db_password" {
  value     = random_password.db_password.result
  sensitive = true
}

output "root_password" {
  value     = random_password.root_password.result
  sensitive = true
}
