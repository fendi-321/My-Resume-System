resource "kubernetes_namespace_v1" "this" {
  metadata {
    name = var.namespace_name
    labels = {
      name                                          = var.namespace_name
      "pod-security.kubernetes.io/enforce"          = "baseline"
      "pod-security.kubernetes.io/audit"            = "baseline"
      "pod-security.kubernetes.io/warn"             = "baseline"
    }
  }
}

output "namespace" {
  value = kubernetes_namespace_v1.this
}

output "namespace_name" {
  value = kubernetes_namespace_v1.this.metadata[0].name
}
