output "gke_cluster_id" {
  value       = google_container_cluster.primary.id
  description = "An identifier for the resource with format projects/{{project}}/locations/{{zone}}/clusters/{{name}}"
}

output "gke_name" {
  description = "The name of the cluster master. This output is used for interpolation with node pools, other modules."
  value       = google_container_cluster.primary.name
}

output "cluster_self_link" {
  value       = google_container_cluster.primary.self_link
  description = "The server-defined URL for the resource."
}

output "lakehouse_bucket_name" {
  description = "The lakehouse bucket name."
  value       = local.lakehouse_storage_name
}

 