variable "sops_secrets_file_path" {
  description = "Path to the SOPS encrypted secrets file"
  type        = string
  default     = "../secrets/management/gitea-admin.yaml"
}

variable "gitea_domain" {
  description = "The custom domain for Gitea (e.g., git.your-domain.com)"
  type        = string
  default     = "git.rhodate.com"
}
