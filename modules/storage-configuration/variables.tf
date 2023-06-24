 
 
variable "project_id" {
  type        = string
  description = "The project ID to host the cluster install"
}

variable "location" {
  type        = string
  description = "The location to host the cluster install"
}

variable "cluster_assets_bucket_name" {
  type        = string
  description = "The name of the bucket to store cluster assets"
}
 