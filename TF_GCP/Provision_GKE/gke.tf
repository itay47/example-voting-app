variable "gke_username" {
  default     = ""
  description = "gke username"
}

variable "gke_password" {
  default     = ""
  description = "gke password"
}

variable "gke_num_nodes" {
  default     = 2
  description = "number of gke nodes"
}

variable "nexus_user" {
  description = "nexus3 artifactory user"
}

variable "nexus_pass" {
  description = "nexus3 artifactory password"
}


# GKE cluster
resource "google_container_cluster" "primary" {
  name     = "${var.project_id}-gke"
  location = var.region
  
  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = true
  initial_node_count       = 1

  network    = var.vpc_name #google_compute_network.vpc.name
  subnetwork = var.vpc_subnets #google_compute_subnetwork.subnet.name
}

# Separately Managed Node Pool
resource "google_container_node_pool" "primary_nodes" {
  name       = "${google_container_cluster.primary.name}-node-pool"
  location   = var.region
  cluster    = google_container_cluster.primary.name
  node_count = var.gke_num_nodes

  node_config {
    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]

    labels = {
      env = var.project_id
    }

    # preemptible  = true
    machine_type = "n1-standard-1"
    tags         = ["gke-node", "${var.project_id}-gke"]
    metadata = {
      disable-legacy-endpoints = "true"
    }
  }
}

terraform {
  backend "artifactory" {
    username = "${data.terraform_remote_state.state.nexus_user}"
    password = "${data.terraform_remote_state.state.nexus_pass}"
    url      = "${data.terraform_remote_state.state.url}"
    repo     = "${data.terraform_remote_state.state.repo}"
    subpath  = "${data.terraform_remote_state.state.subpath}"
  }
}

data "terraform_remote_state" "state" {
 backend = "artifactory"
 config {
   # URL of the nexus repository
   url      = "http://shechter47.mooo.com:8181/repository" 
   # the repository name you just created
   repo     = "TF-repo" 
   # an unique path to for identification
   subpath  = "GKE-TF-STATE"
   # an username that has permissions to the repository
   username = "${var.nexus_user}" 
   # the password of the username you provided
   password = "${var.nexus_pass}" 
 }
}

# # Kubernetes provider
# # The Terraform Kubernetes Provider configuration below is used as a learning reference only. 
# # It references the variables and resources provisioned in this file. 
# # We recommend you put this in another file -- so you can have a more modular configuration.
# # https://learn.hashicorp.com/terraform/kubernetes/provision-gke-cluster#optional-configure-terraform-kubernetes-provider
# # To learn how to schedule deployments and services using the provider, go here: https://learn.hashicorp.com/tutorials/terraform/kubernetes-provider.

# provider "kubernetes" {
#   load_config_file = "false"

#   host     = google_container_cluster.primary.endpoint
#   username = var.gke_username
#   password = var.gke_password

#   client_certificate     = google_container_cluster.primary.master_auth.0.client_certificate
#   client_key             = google_container_cluster.primary.master_auth.0.client_key
#   cluster_ca_certificate = google_container_cluster.primary.master_auth.0.cluster_ca_certificate
# }

