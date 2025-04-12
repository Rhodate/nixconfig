output "gitea_instance_url" {
  description = "URL to access the deployed Gitea instance"
  value       = module.gitea.gitea_url
}

output "gitea_instance_namespace" {
  description = "Namespace of the deployed Gitea instance"
  value       = module.gitea.namespace
}
