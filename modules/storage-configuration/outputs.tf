
output "lakehouse_bucket_name" {
  value = google_storage_bucket.lakehouse.name
  
}

 output "lakehouse_service_account_email" {
   value = google_service_account.lakehouse.email
 }


output "lakehouse_service_account_key" {
  description = "The private key of the service account."
  value       = base64decode(google_service_account_key.lakehouse.private_key)
  sensitive   = true
}
