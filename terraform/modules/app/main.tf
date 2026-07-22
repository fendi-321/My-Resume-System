resource "kubernetes_persistent_volume_claim_v1" "app_uploads" {
  metadata {
    name      = "app-uploads"
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

resource "kubernetes_config_map_v1" "app_config" {
  metadata {
    name      = "app-config"
    namespace = var.namespace_name
  }
  data = {
    DB_HOST  = "mysql"
    DB_NAME  = "online_resume_system"
    DB_USER  = "resume_user"
    APP_URL  = ""
  }
}

resource "kubernetes_deployment_v1" "resume_app" {
  metadata {
    name      = "resume-app"
    namespace = var.namespace_name
    labels = {
      app = "resume-app"
    }
  }
  spec {
    replicas = var.replicas
    selector {
      match_labels = {
        app = "resume-app"
      }
    }
    template {
      metadata {
        labels = {
          app = "resume-app"
        }
      }
      spec {
        container {
          name  = "resume-app"
          image = var.image
          image_pull_policy = "IfNotPresent"
          port {
            container_port = 80
            name           = "http"
          }
          env_from {
            config_map_ref {
              name = kubernetes_config_map_v1.app_config.metadata[0].name
            }
          }
          env {
            name  = "DB_PASS"
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
              drop = ["ALL"]
            }
            run_as_non_root = false
            seccomp_profile {
              type = "RuntimeDefault"
            }
          }
          resources {
            requests = {
              memory = "128Mi"
              cpu    = "100m"
            }
            limits = {
              memory = "256Mi"
              cpu    = "250m"
            }
          }
          volume_mount {
            name       = "uploads"
            mount_path = "/var/www/html/assets/images"
          }
        }
        volume {
          name = "uploads"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim_v1.app_uploads.metadata[0].name
          }
        }
      }
    }
  }
}

resource "kubernetes_service_v1" "resume_app" {
  metadata {
    name      = "resume-app"
    namespace = var.namespace_name
  }
  spec {
    type = var.service_type
    selector = {
      app = "resume-app"
    }
    port {
      port        = 80
      target_port = 80
      name        = "http"
      node_port   = var.service_type == "NodePort" ? var.node_port : null
    }
  }
}

resource "kubernetes_horizontal_pod_autoscaler_v1" "resume_app_hpa" {
  metadata {
    name      = "resume-app-hpa"
    namespace = var.namespace_name
  }
  spec {
    scale_target_ref {
      api_version = "apps/v1"
      kind        = "Deployment"
      name        = kubernetes_deployment_v1.resume_app.metadata[0].name
    }
    min_replicas = var.replicas
    max_replicas = 3
    target_cpu_utilization_percentage = 70
  }
}

output "service_name" {
  value = kubernetes_service_v1.resume_app.metadata[0].name
}
