
resource "kubernetes_secret" "iom-manage-secrets" {
  metadata {
    name = "iomete-manage-secrets"
  }

  data = {
    "gcloud.settings" = jsonencode({
      region  = var.location,
      zone    = var.zone,
      project = var.project_id,
      cluster = {
        id   = var.cluster_id,
        name = local.cluster_name,
      },

      gke = {
        name      = google_container_cluster.primary.name,
        endpoint  = google_container_cluster.primary.endpoint,
        self_link = google_container_cluster.primary.self_link,

      },

      default_storage_configuration = {
        google_lakehouse_bucket = module.storage-configuration.lakehouse_bucket_name,
        service_account_name    = module.storage-configuration.lakehouse_service_account_email,
        service_key             = module.storage-configuration.lakehouse_service_account_key,

      }

      assets_storage_configuration = {
        google_asset_bucket  = google_storage_bucket.assets.name,
        service_account_name = google_service_account.cluster_service_account.email,
      }


      service_key = {
        "credentials.json" = base64decode(google_service_account_key.cluster_service_account_key.private_key),
        caCert             = base64decode(google_container_cluster.primary.master_auth.0.cluster_ca_certificate),
      }

      terraform = {
        module_version = local.module_version
      },

    })
  }

  type = "opaque"

  depends_on = [
    google_container_cluster.primary
  ]
}



resource "kubernetes_namespace" "fluxcd" {
  metadata {
    name = "fluxcd"
  }
}


resource "helm_release" "fluxcd" {

  name       = "helm-operator"
  namespace  = "fluxcd"
  repository = "https://fluxcd-community.github.io/helm-charts"
  version    = "2.7.0"
  chart      = "flux2"
  depends_on = [
    kubernetes_namespace.fluxcd,
    google_container_cluster.primary
  ]
  set {
    name  = "imageReflectionController.create"
    value = "false"
  }

  set {
    name  = "imageAutomationController.create"
    value = "false"
  }

  set {
    name  = "kustomizeController.create"
    value = "false"
  }

  set {
    name  = "notificationController.create"
    value = "false"
  }


}