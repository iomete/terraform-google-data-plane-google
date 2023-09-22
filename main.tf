data "google_client_config" "default" {}

provider "google" {
  project = var.project_id
  region  = var.location
}

locals {
  lakehouse_storage_name = "${var.cluster_name}-lakehouse"
  assets_storage_name = "${var.cluster_name}-assets"
  module_version   = "1.0.1"
  api_services_map = { for service in var.api_services : service => true }

  tags = [
    "iomete-cluster-name-${var.cluster_name}",
    "iomete-terraform",
    "iomete-managed"
  ]
}

#########################################
# enable apis #
#########################################
resource "google_project_service" "enabled_apis" {
  for_each                   = local.api_services_map
  project                    = var.project_id
  service                    = each.key
  disable_on_destroy         = true
  disable_dependent_services = true
}

#########################################
provider "kubernetes" {
  host                   = "https://${google_container_cluster.primary.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(google_container_cluster.primary.master_auth[0].cluster_ca_certificate)
}

provider "helm" {
  kubernetes {
    host                   = "https://${google_container_cluster.primary.endpoint}"
    token                  = data.google_client_config.default.access_token
    cluster_ca_certificate = base64decode(google_container_cluster.primary.master_auth[0].cluster_ca_certificate)
  }
}