
variable "project_id" {
  type        = string
  description = "The ID of your Google Cloud project. This is a unique identifier for your project and can be found in the Google Cloud Console."
}

variable "api_services" {
  description = "A list of API services to enable for your Google Cloud project. These services are required for the proper functioning of your infrastructure. Please make sure you have enabled billing account, otherwise the resource creation will fail."
  type        = list(string)
  default = [
    "compute.googleapis.com",
    "iam.googleapis.com",
    "container.googleapis.com"
  ]
}

variable "location" {
  type        = string
  description = "The region where the cluster and Cloud storage will be hosted"
}

variable "zone" {
  type        = string
  description = "The zone where the cluster will be hosted"
}

variable "cluster_id" {
  type        = string
  description = "Cluster id from IOMETE. This should match the cluster id in IOMETE"
}


variable "cluster_min_cpu" {
  type        = number
  description = "Minimum number of CPU cores in the cluster node. This is the minimum number of CPU cores that will be available in the cluster and node pools."
  default     = 1
}

variable "cluster_max_cpu" {
  type        = number
  description = "Maximum number of CPU cores in the cluster node. This is the maximum number of CPU cores that will be available in the cluster and node pools."
  default     = 500
}


variable "cluster_min_memory" {
  type        = number
  description = "Minimum amount of memory in the cluster node. This is the minimum amount of memory that will be available in the cluster and node pools."
  default     = 4
}

variable "cluster_max_memory" {
  type        = number
  description = "Maximum amount of memory in the cluster node. This is the maximum amount of memory that will be available in the cluster and node pools."
  default     = 5000
}
########################
# nodepools variables #
########################

variable "driver_min_node_count" {
  type        = number
  description = "Minimum number of nodes in the driver node pool"
  default     = 0
}

variable "driver_max_node_count" {
  type        = number
  description = "Maximum number of nodes in the driver node pool"
  default     = "100"
}


variable "exec_min_node_count" {
  type        = number
  description = "Minimum number of nodes in the exec node pool"
  default     = 0
}

variable "exec_max_node_count" {
  type        = number
  description = "Maximum number of nodes in the exec node pool"
  default     = "1000"
}

variable "exec_disk_size_gb" {
  type        = number
  description = "Disk size in GB for the executer nodes"
  default     = 30
}

variable "exec_disk_type" {
  type        = string
  description = "Disk type for the executor nodes"
  default     = "pd-ssd"
}

variable "drive_disk_size_gb" {
  type        = number
  description = "Disk size in GB for the driver nodes"
  default     = 30
}

variable "system_node_disk_size_gb" {
  type        = number
  description = "Disk size in GB for the system nodes. This is the disk size for the nodes that run the Kubernetes system pods. Please dont change if you have not specified configuration needed for the system pods"
  default     = 100
}

