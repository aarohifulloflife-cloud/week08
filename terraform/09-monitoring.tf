# Monitoring stack deployed as infrastructure rather than by hand.
# Task 9.1P used a manual helm install, so rebuilding the cluster would
# silently produce one with no monitoring. Declaring it here makes it
# part of the same apply that creates the cluster.

resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = "monitoring"
  }
}

resource "helm_release" "kube_prometheus_stack" {
  name       = "prometheus"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  namespace  = kubernetes_namespace.monitoring.metadata[0].name

  # Without this, Prometheus only discovers ServiceMonitors carrying the
  # chart's own release label and silently ignores the application's.
  set {
    name  = "prometheus.prometheusSpec.serviceMonitorSelectorNilUsesHelmValues"
    value = "false"
  }

  set {
    name  = "prometheus.prometheusSpec.scrapeInterval"
    value = "15s"
  }

  # Short retention: two node cluster limited by vCPU quota.
  set {
    name  = "prometheus.prometheusSpec.retention"
    value = "6h"
  }

  # Not used, and the cluster has no spare capacity for it.
  set {
    name  = "alertmanager.enabled"
    value = "false"
  }

  set_sensitive {
    name  = "grafana.adminPassword"
    value = var.grafana_admin_password
  }

  wait    = true
  timeout = 900

  depends_on = [azurerm_kubernetes_cluster.aks]
}

variable "grafana_admin_password" {
  description = "Grafana admin password, supplied by the pipeline"
  type        = string
  sensitive   = true
}

output "grafana_port_forward_command" {
  description = "Reach Grafana without exposing it publicly"
  value       = "kubectl port-forward -n monitoring svc/prometheus-grafana 3000:80"
}
