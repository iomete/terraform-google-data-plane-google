
#########################################
# Create service account #
#########################################
resource "google_service_account" "default" {
  depends_on   = [google_project_service.enabled_apis]
  account_id   = var.service_account_id
  display_name = var.service_account_display_name
}

resource "google_service_account_key" "default" {
  service_account_id = google_service_account.default.account_id
  # private_key_type   = "TYPE_JSON"
}

resource "google_project_iam_member" "add_admin" {
  depends_on = [google_project_service.enabled_apis]
  project    = var.project_id
  role       = "roles/storage.admin"
  member     = "serviceAccount:${google_service_account.default.email}"
}

resource "google_project_iam_member" "container_admin" {
  project = var.project_id
  role    = "roles/container.admin"
  member  = "serviceAccount:${google_service_account.default.email}"
}
resource "google_project_iam_member" "servacc_admin" {
  project = var.project_id
  role    = "roles/iam.serviceAccountAdmin"
  member  = "serviceAccount:${google_service_account.default.email}"
}
resource "google_service_account_iam_binding" "workload_identity" {
  depends_on         = [google_container_cluster.primary]
  service_account_id = google_service_account.default.name
  role               = "roles/iam.workloadIdentityUser"
  members = [
    "serviceAccount:${var.project_id}.svc.id.goog[monitoring/loki-s3access-sa]",
  ]

}
 