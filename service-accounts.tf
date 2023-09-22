resource "google_service_account" "lakehouse_service_account" {
  depends_on   = [google_project_service.enabled_apis]
  account_id   = var.cluster_name
  display_name = "Lakehouse Service Account for ${var.cluster_name}"
}

resource "google_service_account_key" "lakehouse_service_account_key" {
  service_account_id = google_service_account.lakehouse_service_account.account_id
}

resource "google_project_iam_member" "container_admin" {
  project = var.project_id
  role    = "roles/container.admin"
  member  = "serviceAccount:${google_service_account.lakehouse_service_account.email}"
}

resource "google_service_account_iam_binding" "workload_identity" {
  depends_on         = [google_container_cluster.primary]
  service_account_id = google_service_account.lakehouse_service_account.name
  role               = "roles/iam.workloadIdentityUser"
  members            = [
    "serviceAccount:${var.project_id}.svc.id.goog[iomete-system/lakehouse-service-account]",
  ]
}
 