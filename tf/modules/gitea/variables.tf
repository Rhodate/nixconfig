variable "namespace" {
  description = "Kubernetes namespace to deploy Gitea into"
  type        = string
}

variable "chart_version" {
  description = "Version of the Gitea Helm chart to deploy"
  type        = string
}

variable "domain" {
  description = "The custom domain for Gitea (e.g., git.your-domain.com)"
  type        = string
}

variable "ssh_domain" {
  description = "The domain to use for SSH access. Defaults to the main domain if empty."
  type        = string
  default     = ""
}

variable "admin_user" {
  description = "Initial Gitea admin username"
  type        = string
}

variable "admin_password" {
  description = "Initial Gitea admin password (should be sourced securely)"
  type        = string
  sensitive   = true
}

variable "admin_email" {
  description = "Initial Gitea admin email address"
  type        = string
}

variable "tls_secret_name" {
  description = "Name of the pre-existing Kubernetes TLS secret for the custom domain"
  type        = string
}

variable "storage_class" {
  description = "Name of the Kubernetes StorageClass to use for persistence (e.g., longhorn)"
  type        = string
}

variable "data_volume_size" {
  description = "Size of the persistent volume for Gitea data"
  type        = string
}

variable "postgres_volume_size" {
  description = "Size of the persistent volume for the PostgreSQL database"
  type        = string
}

variable "ingress_class_name" {
  description = "Ingress Class name to use. For K3s default Traefik, this is often just 'traefik'."
  type        = string
  default     = "traefik"
}

variable "ingress_annotations" {
  description = "Additional annotations for the Ingress resource (e.g., for Traefik middleware, cert-manager)"
  type        = map(string)
  default     = {}
}
