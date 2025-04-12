terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.11"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.23"
    }
  }
}

resource "kubernetes_namespace" "gitea" {
  metadata {
    name = var.namespace
  }
}

data "kubernetes_secret" "gitea_tls" {
  metadata {
    name      = var.tls_secret_name
    namespace = kubernetes_namespace.gitea.metadata[0].name
  }
  depends_on = [kubernetes_namespace.gitea]
}

data "kubernetes_storage_class" "sc" {
  metadata {
    name = var.storage_class
  }
}

# --- Helm Deployment ---

resource "helm_release" "gitea" {
  name       = "gitea"                     # Helm release name within the namespace
  repository = "https://dl.gitea.io/charts/"
  chart      = "gitea"
  version    = var.chart_version
  namespace  = kubernetes_namespace.gitea.metadata[0].name

  values = [
    yamlencode({
      gitea = {
        admin = {
          username = var.admin_user
          password = var.admin_password
          email    = var.admin_email
          passwordMode = "initialOnlyRequireReset"
        }
        config = {
          server = {
            DOMAIN     = var.domain
            ROOT_URL   = "https://${var.domain}/"
            SSH_DOMAIN = var.ssh_domain == "" ? var.domain : var.ssh_domain
            PROTOCOL   = "http"
          }
          database = {
            DB_TYPE = "postgres"
            HOST    = "gitea-postgresql:5432"
            NAME    = "gitea"
            USER    = "gitea"
          }
        }
      }
      persistence = {
        enabled      = true
        storageClass = var.storage_class
        size         = var.data_volume_size
      }
      postgresql-ha = {
        enabled = true
        persistence = {
          enabled      = true
          storageClass = var.storage_class
          size         = var.postgres_volume_size
        }
      }
      ingress = {
        enabled   = true
        className = var.ingress_class_name # Use the variable (defaults to traefik)
        # Pass through any user-defined annotations. Removed default Nginx ones.
        annotations = var.ingress_annotations
        hosts = [{
          host  = var.domain
          paths = [{ path = "/", pathType = "Prefix" }]
        }]
        tls = [{
          secretName = data.kubernetes_secret.gitea_tls.metadata[0].name
          hosts      = [var.domain]
        }]
      }
    })
  ]

  depends_on = [
    kubernetes_namespace.gitea,
    data.kubernetes_secret.gitea_tls,
  ]
}
