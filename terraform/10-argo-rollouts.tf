# Argo Rollouts controller, installed as infrastructure in the same way
# as the monitoring stack in 09-monitoring.tf. Rebuilding the cluster
# with terraform apply brings progressive delivery back with it.

resource "kubernetes_namespace" "argo_rollouts" {
  metadata {
    name = "argo-rollouts"
  }
}

resource "helm_release" "argo_rollouts" {
  name       = "argo-rollouts"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-rollouts"
  namespace  = kubernetes_namespace.argo_rollouts.metadata[0].name

  # One controller replica is enough for a single cluster.
  set {
    name  = "controller.replicas"
    value = "1"
  }

  # Small requests so the controller fits on the two node cluster.
  set {
    name  = "controller.resources.requests.cpu"
    value = "50m"
  }

  set {
    name  = "controller.resources.requests.memory"
    value = "64Mi"
  }

  # The dashboard is run locally through the kubectl plugin instead.
  set {
    name  = "dashboard.enabled"
    value = "false"
  }

  wait    = true
  timeout = 600

  depends_on = [azurerm_kubernetes_cluster.aks]
}
