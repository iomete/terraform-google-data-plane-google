resource "google_storage_bucket" "lakehouse_storage" {
  depends_on = [google_project_service.enabled_apis]

  name                        = local.lakehouse_storage_name
  location                    = var.location
  uniform_bucket_level_access = true
}


resource "google_storage_bucket_iam_member" "lakehouse_storage_member_add" {
  depends_on = [google_project_service.enabled_apis]

  bucket = google_storage_bucket.lakehouse_storage.name
  role   = "roles/storage.objectAdmin"

  member = "serviceAccount:${google_service_account.lakehouse_service_account.email}"
}

# Assets bucket
resource "google_storage_bucket" "assets_storage" {
  depends_on = [google_project_service.enabled_apis]

  name                        = local.assets_storage_name
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


resource "google_storage_bucket_iam_member" "assets_member_add" {
  depends_on = [google_project_service.enabled_apis]

  bucket = google_storage_bucket.assets_storage.name
  role   = "roles/storage.objectAdmin"

  member = "serviceAccount:${google_service_account.lakehouse_service_account.email}"
}