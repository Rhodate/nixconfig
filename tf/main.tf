data "sops_file" "secrets" {
  source_file = var.sops_secrets_file_path
}

resource "kubernetes_storage_class" "openebs-1replica" {
  metadata {
    name        = "mayastor-1"
  }
  storage_provisioner = "io.openebs.csi-mayastor"
  reclaim_policy = "Delete"
  volume_binding_mode = "WaitForFirstConsumer"
  allow_volume_expansion = true

  parameters = {
    repl       = "1"       # Sets replication factor to 1
    protocol   = "nvmf"    # Uses NVMe over Fabrics protocol
  }
}

resource "kubernetes_storage_class" "openebs-2replica" {
  metadata {
    name        = "mayastor-2"
    annotations = {
      "storageclass.kubernetes.io/is-default-class" = "true" # Marks this as the default StorageClass
    }
  }
  storage_provisioner = "io.openebs.csi-mayastor"
  reclaim_policy = "Delete"
  volume_binding_mode = "WaitForFirstConsumer"
  allow_volume_expansion = true

  parameters = {
    repl       = "2"       # Sets replication factor to 2
    protocol   = "nvmf"    # Uses NVMe over Fabrics protocol
  }
}

module "gitea" {
  source = "./modules/gitea"
  namespace            = "gitea"
  chart_version        = "8.3.0"
  domain               = "git.rhodate.com"
  admin_email          = data.sops_file.secrets.data["gitea_admin_email"]
  admin_password       = data.sops_file.secrets.data["gitea_admin_password"]
  admin_user           = "rhodate"
  tls_secret_name      = "tls-certificate"
  storage_class        = kubernetes_storage_class.openebs-2replica.metadata[0].name
  data_volume_size     = "10Gi"
  postgres_volume_size = "5Gi"

  depends_on = [ kubernetes_storage_class.openebs-2replica ]
}

