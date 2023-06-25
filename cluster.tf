locals {
  node_pool_oauth_scopes = [
    "https://www.googleapis.com/auth/compute",
    "https://www.googleapis.com/auth/devstorage.read_only",
    "https://www.googleapis.com/auth/logging.write",
    "https://www.googleapis.com/auth/monitoring",
    "https://www.googleapis.com/auth/service.management.readonly",
    "https://www.googleapis.com/auth/servicecontrol",
    "https://www.googleapis.com/auth/trace.append",
    "https://www.googleapis.com/auth/cloud-platform"
  ]
}

#########################################
# Create a GKE cluster with no node pool #
#########################################

resource "google_container_cluster" "primary" {
  provider   = google-beta
  project    = var.project_id
  depends_on = [google_project_service.enabled_apis]
  name       = local.cluster_name
  location   = var.zone
  network    = google_compute_network.vpc_network.name

  initial_node_count = 1

  node_config {
    oauth_scopes = local.node_pool_oauth_scopes
    machine_type = "e2-standard-4"
    disk_size_gb = var.system_node_disk_size_gb
    tags         = local.tags

  }

  private_cluster_config {
    enable_private_nodes   = true
    master_ipv4_cidr_block = "10.1.0.0/28"
  }
  ip_allocation_policy {

  }



  master_auth {
    client_certificate_config {
      issue_client_certificate = false

    }
  }
  cluster_autoscaling {
    enabled             = true
    autoscaling_profile = "OPTIMIZE_UTILIZATION"
    resource_limits {
      resource_type = "cpu"
      minimum       = var.cluster_min_cpu
      maximum       = var.cluster_max_cpu
    }
    resource_limits {
      resource_type = "memory"
      minimum       = var.cluster_min_memory
      maximum       = var.cluster_max_memory
    }


    auto_provisioning_defaults {
      management {
        auto_repair  = true
        auto_upgrade = true
      }

      upgrade_settings {
        max_surge       = 2
        max_unavailable = 0
      }
    }
  }
  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }

  release_channel {
    channel = "STABLE"
  }
  maintenance_policy {
    recurring_window {
      start_time = "2023-01-01T09:00:00Z"
      end_time   = "2030-01-01T17:00:00Z"
      recurrence = "FREQ=MONTHLY;BYMONTHDAY=1"
    }
  }

}

#########################################
# iomete nodepool #
#########################################


resource "google_container_node_pool" "driver_node_1" {
  name           = "e2-medium"
  node_locations = [var.zone]
  cluster        = google_container_cluster.primary.id
  node_count     = 0

  autoscaling {
    min_node_count = var.driver_min_node_count
    max_node_count = var.driver_max_node_count
  }

  node_config {
    machine_type = "e2-medium"
    disk_size_gb = var.drive_disk_size_gb
    labels = {
      "k8s.iomete.com/node-purpose" = "e2-medium"
    }
    taint = [{
      key      = "k8s.iomete.com/dedicated"
      operator = "Equal"
      value    = "e2-medium"
      effect   = "NO_SCHEDULE"
      },
      {
        key    = "kubernetes.io/arch"
        value  = "arm64"
        effect = "NO_SCHEDULE"
      }

    ]

    tags = local.tags


    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    service_account = google_service_account.cluster_service_account.email
    oauth_scopes    = local.node_pool_oauth_scopes
  }

  management {
    auto_repair  = true
    auto_upgrade = true
  }

  timeouts {
    create = "30m"
    update = "20m"
  }

  lifecycle {
    ignore_changes = [
      node_config.0.taint
    ]
  }
}


resource "google_container_node_pool" "driver_node_2" {
  name           = "e2-highmem-2"
  node_locations = [var.zone]
  cluster        = google_container_cluster.primary.id
  node_count     = 0

  autoscaling {
    min_node_count = var.driver_min_node_count
    max_node_count = var.driver_max_node_count

  }
  node_config {
    machine_type = "e2-highmem-2"
    disk_size_gb = var.drive_disk_size_gb
    labels = {
      "k8s.iomete.com/node-purpose" = "e2-highmem-2"
    }
    taint = [{
      key      = "k8s.iomete.com/dedicated"
      operator = "Equal"
      value    = "e2-highmem-2"
      effect   = "NO_SCHEDULE"
      },
      {
        key    = "kubernetes.io/arch"
        value  = "arm64"
        effect = "NO_SCHEDULE"
    }]

    tags = local.tags

    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    service_account = google_service_account.cluster_service_account.email
    oauth_scopes    = local.node_pool_oauth_scopes
  }
  timeouts {
    create = "30m"
    update = "20m"
  }

  management {
    auto_repair  = true
    auto_upgrade = true
  }
  lifecycle {
    ignore_changes = [
      node_config.0.taint
    ]
  }
}


resource "google_container_node_pool" "driver_node_3" {
  name           = "e2-highmem-4"
  node_locations = [var.zone]
  cluster        = google_container_cluster.primary.id
  node_count     = 0

  autoscaling {
    min_node_count = var.driver_min_node_count
    max_node_count = var.driver_max_node_count

  }
  node_config {
    machine_type = "e2-highmem-4"
    disk_size_gb = var.drive_disk_size_gb
    labels = {
      "k8s.iomete.com/node-purpose" = "e2-highmem-4"
    }
    taint = [{
      key      = "k8s.iomete.com/dedicated"
      operator = "Equal"
      value    = "e2-highmem-4"
      effect   = "NO_SCHEDULE"
      },
      {
        key    = "kubernetes.io/arch"
        value  = "arm64"
        effect = "NO_SCHEDULE"
    }]

    tags = local.tags

    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    service_account = google_service_account.cluster_service_account.email
    oauth_scopes    = local.node_pool_oauth_scopes
  }
  timeouts {
    create = "30m"
    update = "20m"
  }

  management {
    auto_repair  = true
    auto_upgrade = true
  }
  lifecycle {
    ignore_changes = [
      node_config.0.taint
    ]
  }
}



resource "google_container_node_pool" "exec_node_1" {
  name           = "e2-standard-2"
  node_locations = [var.zone]
  cluster        = google_container_cluster.primary.id
  node_count     = 0
  autoscaling {
    min_node_count = var.exec_min_node_count
    max_node_count = var.exec_max_node_count

  }
  node_config {
    machine_type = "e2-standard-2"
    disk_size_gb = var.exec_disk_size_gb
    disk_type    = var.exec_disk_type
    labels = {
      "k8s.iomete.com/node-purpose" = "e2-standard-2"
    }
    taint = [{
      key      = "k8s.iomete.com/dedicated"
      operator = "Equal"
      value    = "e2-standard-2"
      effect   = "NO_SCHEDULE"
      },
      {
        key    = "kubernetes.io/arch"
        value  = "arm64"
        effect = "NO_SCHEDULE"
    }]

    tags = local.tags

    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    service_account = google_service_account.cluster_service_account.email
    oauth_scopes    = local.node_pool_oauth_scopes
  }

  management {
    auto_repair  = true
    auto_upgrade = true
  }
  timeouts {
    create = "30m"
    update = "20m"
  }
}


resource "google_container_node_pool" "exec_node_2" {
  name           = "e2-standard-4"
  node_locations = [var.zone]
  cluster        = google_container_cluster.primary.id
  node_count     = 0
  autoscaling {
    min_node_count = var.exec_min_node_count
    max_node_count = var.exec_max_node_count

  }
  node_config {
    machine_type = "e2-standard-4"
    disk_size_gb = var.exec_disk_size_gb
    disk_type    = var.exec_disk_type
    labels = {
      "k8s.iomete.com/node-purpose" = "e2-standard-4"
    }
    taint = [{
      key      = "k8s.iomete.com/dedicated"
      operator = "Equal"
      value    = "e2-standard-4"
      effect   = "NO_SCHEDULE"
      },
      {
        key    = "kubernetes.io/arch"
        value  = "arm64"
        effect = "NO_SCHEDULE"
    }]

    tags = local.tags


    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    service_account = google_service_account.cluster_service_account.email
    oauth_scopes    = local.node_pool_oauth_scopes
  }

  management {
    auto_repair  = true
    auto_upgrade = true
  }
  timeouts {
    create = "30m"
    update = "20m"
  }
}


resource "google_container_node_pool" "exec_node_3" {
  name           = "e2-standard-8"
  node_locations = [var.zone]
  cluster        = google_container_cluster.primary.id
  node_count     = 0
  autoscaling {
    min_node_count = var.exec_min_node_count
    max_node_count = var.exec_max_node_count

  }
  node_config {
    machine_type = "e2-standard-8"
    disk_size_gb = var.exec_disk_size_gb
    disk_type    = var.exec_disk_type
    labels = {
      "k8s.iomete.com/node-purpose" = "e2-standard-8"
    }
    taint = [{
      key      = "k8s.iomete.com/dedicated"
      operator = "Equal"
      value    = "e2-standard-8"
      effect   = "NO_SCHEDULE"
      },
      {
        key    = "kubernetes.io/arch"
        value  = "arm64"
        effect = "NO_SCHEDULE"
    }]

    tags = local.tags

    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    service_account = google_service_account.cluster_service_account.email
    oauth_scopes    = local.node_pool_oauth_scopes
  }

  management {
    auto_repair  = true
    auto_upgrade = true
  }
  timeouts {
    create = "30m"
    update = "20m"
  }
}


resource "google_container_node_pool" "exec_node_4" {
  name           = "e2-standard-16"
  node_locations = [var.zone]
  cluster        = google_container_cluster.primary.id
  node_count     = 0
  autoscaling {
    min_node_count = var.exec_min_node_count
    max_node_count = var.exec_max_node_count

  }
  node_config {
    machine_type = "e2-standard-16"
    disk_size_gb = var.exec_disk_size_gb
    disk_type    = var.exec_disk_type
    labels = {
      "k8s.iomete.com/node-purpose" = "e2-standard-16"
    }
    taint = [{
      key      = "k8s.iomete.com/dedicated"
      operator = "Equal"
      value    = "e2-standard-16"
      effect   = "NO_SCHEDULE"
      },
      {
        key    = "kubernetes.io/arch"
        value  = "arm64"
        effect = "NO_SCHEDULE"
    }]

    tags = local.tags

    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    service_account = google_service_account.cluster_service_account.email
    oauth_scopes    = local.node_pool_oauth_scopes
  }

  management {
    auto_repair  = true
    auto_upgrade = true
  }
  timeouts {
    create = "30m"
    update = "20m"
  }
}
#########################################
# Network 
#########################################
resource "google_compute_network" "vpc_network" {
  depends_on = [google_project_service.enabled_apis]
  name       = "${local.cluster_name}-network"

}
resource "google_compute_subnetwork" "subnet" {
  name          = "${local.cluster_name}-sn"
  network       = google_compute_network.vpc_network.id
  ip_cidr_range = "10.0.0.0/16"
  region        = var.location
}

resource "google_compute_router" "router" {
  name    = "${local.cluster_name}-router"
  region  = google_compute_subnetwork.subnet.region
  network = google_compute_network.vpc_network.id
}


resource "google_compute_router_nat" "advanced-nat" {
  name                               = "${local.cluster_name}-router-nat"
  router                             = google_compute_router.router.name
  region                             = google_compute_router.router.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}

resource "google_compute_firewall" "ingress_self_all" {
  name      = "ingress-self-all-${local.cluster_name}"
  network   = google_compute_network.vpc_network.id
  priority  = 1000
  direction = "INGRESS"



  source_ranges = ["0.0.0.0/0"]

  allow {
    protocol = "all"
  }
}

resource "google_compute_firewall" "ingress_cluster_all" {
  name      = "ingress-cluster-all-${local.cluster_name}"
  network   = google_compute_network.vpc_network.id
  priority  = 1001
  direction = "INGRESS"


  source_ranges = ["0.0.0.0/0"]

  allow {
    protocol = "all"
  }
}

resource "google_compute_firewall" "egress_all" {
  name      = "egress-all-${local.cluster_name}"
  network   = google_compute_network.vpc_network.id
  priority  = 1000
  direction = "EGRESS"


  destination_ranges = ["0.0.0.0/0"]

  allow {
    protocol = "all"
  }
}

