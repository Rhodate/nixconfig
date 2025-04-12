output "namespace" {
  description = "The Kubernetes namespace where Gitea was deployed"
  value       = kubernetes_namespace.gitea.metadata[0].name
}

output "helm_release_status" {
  description = "Status of the Gitea Helm release"
  value       = helm_release.gitea.status
}

output "gitea_url" {
  description = "URL to access the Gitea web interface"
  value       = "https://${var.domain}"
}
