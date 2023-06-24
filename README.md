# IOMETE Data-Plane module

## Terraform module which creates resources on Google cloud.
 

## Module Usage

After running terraform apply to create or update your resources, Terraform will automatically generate the IOMETE_DATA file with the necessary information.
Locate the IOMETE_DATA file in your Terraform project directory.

 
Open this file ordinary text editor and copy the content of the file to the IOMETE control plane.

## Terraform code

```hcl

 
 
module "data-plane" {
  source                       = "iomete/data-plane-google/google"
  version                      = "1.0.0"
  project_id                   = "project_id"
  cluster_id                   = "goog_cust"
  location                     = "us-central1"    # Cluster installed region
  zone                         = "us-central1-c" # Cluster installed exact zone
}

output "gke_name" {
  description = "The name of the cluster master. This output is used for interpolation with node pools, other modules."
  value       = module.data-plane.gke_name
} 
 
output "cluster_endpoint" {
  value       = module.data-plane.cluster_endpoint
  description = "The IP address of this cluster's Kubernetes master."
}

output "cluster_service_account_key" {
  description = "The private key of the cluster service account."
  value = (module.data-plane.google_service_account_key)
  sensitive = true
}

output "cluster_ca_certificate" {
  value       = module.data-plane.cluster_ca_certificate
  description = "The cluster CA certificate for the AKS cluster."
  sensitive   = true
}

 
  
```

## Terraform Deployment

```shell
terraform init
terraform plan
terraform apply
```

## Description of variables

| Name | Description | Required |
| --- | --- | --- |
| cluster_id | The name of the AKS cluster | yes |
| project_id | Googl cloud project name to install resources | yes |
| location | Where all resources will create | yes |
| zone | Exact zone to install google storage bucket | yes |
