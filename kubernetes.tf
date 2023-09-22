resource "kubernetes_secret" "data-plane-secret" {
  metadata {
    name = "iomete-data-plane-secret"
  }

  data = {
    "settings" = jsonencode({
      cloud   = "gcp",
      project = var.project_id,
      region  = var.location,
      zone    = var.zone,

      cluster_name          = var.cluster_name,
      storage_configuration = {
        lakehouse_bucket_name     = local.lakehouse_storage_name,
        assets_bucket_name        = local.assets_storage_name,
        lakehouse_service_account = google_service_account.lakehouse_service_account.email,
      },

      #info only
      gke = {
        name               = google_container_cluster.primary.name,
        endpoint           = google_container_cluster.primary.endpoint,
        self_link          = google_container_cluster.primary.self_link,
        caCert             = base64decode(google_container_cluster.primary.master_auth.0.cluster_ca_certificate),
        "credentials.json" = base64decode(google_service_account_key.lakehouse_service_account_key.private_key)
      },
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