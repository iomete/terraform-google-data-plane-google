data "google_client_config" "default" {}

provider "google" {
  project = var.project_id
  region  = var.location
}

locals {
  cluster_name     = "iomete-${var.cluster_id}"
  module_version   = "1.0.0"
  api_services_map = { for service in var.api_services : service => true }



  tags = [
    "iomete-clusterid-${var.cluster_id}",
    "iomete-clustername-${local.cluster_name}",
    "iomete-terraform",
    "iomete-managed",
    "iomete-google",
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


resource "random_id" "random" {
  byte_length = 5

}

module "storage-configuration" {
  source             = "./modules/storage-configuration"
  project_id         = var.project_id
  location           = var.location
  cluster_assets_bucket_name = google_storage_bucket.assets.name

}

resource "null_resource" "save_outputs" {
  depends_on = [
    google_container_node_pool.driver_node_1
  ]
  triggers = {
    run_every_time = uuid()
  }
  provisioner "local-exec" {
    command = <<-EOT
    
    if [ ! -s "IOMETE_DATA" ]; then
    echo "gkeName: $(terraform output gke_name)" >> IOMETE_DATA &&
    echo "Endpoint: $(terraform output cluster_endpoint)" >> IOMETE_DATA &&
    echo "Cluster CA Certificate: $(terraform output cluster_ca_certificate)" >> IOMETE_DATA &&
    echo "Google Service Account Key: $(terraform output google_service_account_key)" >> IOMETE_DATA
    fi


    EOT
  }
}
