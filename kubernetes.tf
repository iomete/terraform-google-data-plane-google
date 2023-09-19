
resource "kubernetes_secret" "iom-manage-secrets" {
  metadata {
    name = "iomete-manage-secrets"
  }

  data = {
    "settings" = jsonencode({
      region  = var.location,
      cloud   = "gcp",
      zone    = var.zone,
      project = var.project_id,
      cluster = {
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
        clusterCa          = base64decode(google_container_cluster.primary.master_auth[0].cluster_ca_certificate),
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
  version    = "2.9.2"
  chart      = "flux2"
  depends_on = [
    kubernetes_namespace.fluxcd
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


resource "helm_release" "iomete-agent" {
  name       = "iomete-agent"
  namespace  = "default"
  repository = "https://chartmuseum.iomete.com"
  chart      = "iom-agent"
  version    = "0.2.0"
  depends_on = [
    helm_release.fluxcd,
    kubernetes_secret.iom-manage-secrets,
  ]

  set {
    name  = "iometeAccountId"
    value = var.account_id
  }

  set {
    name  = "cloud"
    value = "gcp"
  }

  set {
    name  = "region"
    value = var.location
  }

}