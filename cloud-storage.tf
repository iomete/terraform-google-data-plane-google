locals {
  cluster_assets_bucket_name = "${local.cluster_name}-assets"
}



resource "google_storage_bucket" "assets" {
  depends_on = [google_project_service.enabled_apis]

  name                        = local.cluster_assets_bucket_name
  location                    = var.location
  force_destroy               = true
  uniform_bucket_level_access = true


  lifecycle_rule {
    condition {
      age = 180
    }
    action {
      type = "Delete"
    }
  }

}


resource "google_storage_bucket_iam_member" "this" {
  depends_on = [google_project_service.enabled_apis]

  bucket = google_storage_bucket.assets.name
  role   = "roles/storage.objectAdmin"

  member = "serviceAccount:${google_service_account.default.email}"
}

############################################

# resource "google_storage_bucket_iam_binding" "lakehouse" {
#   depends_on = [google_project_service.enabled_apis]

#   bucket = google_storage_bucket.lakehouse.name
#   role   = "roles/storage.objectAdmin"

#   members = [
#     "serviceAccount:${google_service_account.default.email}"
#   ]
# }




# resource "google_storage_bucket" "lakehouse" {
#   depends_on = [google_project_service.enabled_apis]

#   name          = "lakehose-bucket-test"
#   location      = "US"
#   force_destroy = true

#   lifecycle_rule {
#     condition {
#       age = 180
#     }
#     action {
#       type = "Delete"
#     }
#   }

# }