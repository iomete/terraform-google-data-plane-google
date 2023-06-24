provider "google" {
  project = var.project_id
}
locals {

  tags = {
    "iomete.com/terraform" : true
    "iomete.com/managed" : true
  }
}
  
#########################################
# Create service account #
#########################################
resource "google_service_account" "lakehouse" {
  account_id  = "lakehouse-strg-acc-${random_id.random.hex}"
  display_name =  "lakehouse-strg-acc-${random_id.random.hex}"
}

resource "google_service_account_key" "lakehouse" {
  service_account_id = google_service_account.lakehouse.name
  # private_key_type   = "TYPE_JSON"
}
 ############################################

resource "random_id" "random" {
  byte_length = 3
}
  
resource "google_storage_bucket" "lakehouse" {
 
  name          = "iom-lakehouse-${random_id.random.hex}"
  location      = var.location
  uniform_bucket_level_access = true
}
 

resource "google_storage_bucket_iam_member" "lakehouse" {
 
  bucket = google_storage_bucket.lakehouse.name
  role   = "roles/storage.objectAdmin"

  member = "serviceAccount:${google_service_account.lakehouse.email}"
}


resource "google_storage_bucket_iam_member" "assets" {
 depends_on = [ google_service_account.lakehouse ]
  bucket = var.cluster_assets_bucket_name
  role   = "roles/storage.objectAdmin"

  member = "serviceAccount:${google_service_account.lakehouse.email}"
}
############################################

resource "null_resource" "save_outputs" {
  depends_on = [
    google_storage_bucket_iam_member.assets
  ]
  triggers = {
    run_every_time = uuid()
  }
  provisioner "local-exec" {
    command = <<-EOT
    
    echo "Lakehouse Bucket Name: $( terraform output lakehouse_bucket_name )" >> Lakehouse_data &&
    echo "Lakehouse Service Account Key: $( terraform output  lakehouse_service_account_key )" >> Lakehouse_data
    
    EOT
  }
}
