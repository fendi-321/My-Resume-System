resource "kubernetes_persistent_volume_claim_v1" "mysql_data" {
  metadata {
    name      = "mysql-data"
    namespace = var.namespace_name
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = var.storage_size
      }
    }
  }
}

resource "kubernetes_deployment_v1" "mysql" {
  metadata {
    name      = "mysql"
    namespace = var.namespace_name
    labels = {
      app = "mysql"
    }
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "mysql"
      }
    }
    strategy {
      type = "Recreate"
    }
    template {
      metadata {
        labels = {
          app = "mysql"
        }
      }
      spec {
        container {
          name  = "mysql"
          image = var.image
          port {
            container_port = 3306
            name           = "mysql"
          }
          env {
            name  = "MYSQL_ROOT_PASSWORD"
            value_from {
              secret_key_ref {
                name = var.db_secret_name
                key  = "ROOT_PASS"
              }
            }
          }
          env {
            name  = "MYSQL_DATABASE"
            value = var.db_name
          }
          env {
            name  = "MYSQL_USER"
            value = var.db_user
          }
          env {
            name  = "MYSQL_PASSWORD"
            value_from {
              secret_key_ref {
                name = var.db_secret_name
                key  = "DB_PASS"
              }
            }
          }
          security_context {
            allow_privilege_escalation = false
            capabilities {
              drop = []
            }
            run_as_non_root = false
            seccomp_profile {
              type = "RuntimeDefault"
            }
          }
          resources {
            requests = {
              memory = "256Mi"
              cpu    = "250m"
            }
            limits = {
              memory = "512Mi"
              cpu    = "500m"
            }
          }
          volume_mount {
            name       = "mysql-data"
            mount_path = "/var/lib/mysql"
          }
        }
        volume {
          name = "mysql-data"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim_v1.mysql_data.metadata[0].name
          }
        }
      }
    }
  }
}

resource "kubernetes_service_v1" "mysql" {
  metadata {
    name      = "mysql"
    namespace = var.namespace_name
  }
  spec {
    selector = {
      app = "mysql"
    }
    port {
      port        = 3306
      target_port = 3306
    }
  }
}

resource "kubernetes_job_v1" "db_init" {
  depends_on = [kubernetes_deployment_v1.mysql]
  metadata {
    name      = "db-init"
    namespace = var.namespace_name
  }
  spec {
    template {
      metadata {
        name = "db-init"
      }
      spec {
        container {
          name    = "mysql-init"
          image   = var.image
          security_context {
            allow_privilege_escalation = false
            capabilities {
              drop = []
            }
            run_as_non_root = false
            seccomp_profile {
              type = "RuntimeDefault"
            }
          }
          command = ["sh", "-c"]
          args = [
            "until mysql -h mysql -u root -p$MYSQL_ROOT_PASSWORD -e 'SELECT 1' > /dev/null 2>&1; do echo waiting for mysql...; sleep 3; done && mysql -h mysql -u root -p$MYSQL_ROOT_PASSWORD ${var.db_name} < /sql/init.sql"
          ]
          env {
            name  = "MYSQL_ROOT_PASSWORD"
            value_from {
              secret_key_ref {
                name = var.db_secret_name
                key  = "ROOT_PASS"
              }
            }
          }
          volume_mount {
            name       = "sql"
            mount_path = "/sql"
          }
        }
        restart_policy = "Never"
        volume {
          name = "sql"
          config_map {
            name = kubernetes_config_map_v1.db_init_sql.metadata[0].name
          }
        }
      }
    }
    backoff_limit = 4
  }
}

resource "kubernetes_config_map_v1" "db_init_sql" {
  metadata {
    name      = "db-init-sql"
    namespace = var.namespace_name
  }
  data = {
    "init.sql" = file("${path.module}/../../init.sql")
  }
}

output "mysql_service_host" {
  value = kubernetes_service_v1.mysql.metadata[0].name
}
