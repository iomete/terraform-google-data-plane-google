output "cluster_id" {
  value       = google_container_cluster.primary.id
  description = "An identifier for the resource with format projects/{{project}}/locations/{{zone}}/clusters/{{name}}"
}

output "gke_name" {
  # This may seem redundant with the `name` input, but it serves an important
  # purpose. Terraform won't establish a dependency graph without this to interpolate on.
  description = "The name of the cluster master. This output is used for interpolation with node pools, other modules."
  value       = google_container_cluster.primary.name
}


output "cluster_self_link" {
  value       = google_container_cluster.primary.self_link
  description = "The server-defined URL for the resource."
}

output "cluster_endpoint" {
  value       = google_container_cluster.primary.endpoint
  description = "The IP address of this cluster's Kubernetes master."
}

output "cluster_label_fingerprint" {
  value       = google_container_cluster.primary.label_fingerprint
  description = "The fingerprint of the set of labels for this cluster."
}

output "cluster_ca_certificate" {
  description = "The public certificate that is the root of trust for the cluster."
  value       = base64decode(google_container_cluster.primary.master_auth[0].cluster_ca_certificate)
}

output "token" {
  description = "The OAuth2 access token used by clients to authenticate to the Kubernetes cluster."
  value       = data.google_client_config.default.access_token
  sensitive   = true
}


output "google_service_account_key" {
  description = "The private key of the service account."
  value       = base64decode(google_service_account_key.default.private_key)
  sensitive   = true
}

 
output "lakehouse_bucket_name" {
  description = "The name of the cluster master. This output is used for interpolation with node pools, other modules."
  value       = module.storage-configuration.lakehouse_bucket_name
}

output "lakehouse_service_account_key" {
  description = "The private key of the service account."
  value       = module.storage-configuration.lakehouse_service_account_key
  sensitive   = true
}

 output "lakehouse_service_account_email" {
   value = module.storage-configuration.lakehouse_service_account_email
 }