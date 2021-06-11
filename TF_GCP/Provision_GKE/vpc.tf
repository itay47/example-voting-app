variable "project_id" {
  description = "project id"
}

variable "region" {
  description = "region"
}
variable "vpc_name" {
  description = "vpc_name"
}
variable "vpc_subnets" {
  description = "vpc_subnets"
}

provider "google" {
  project = var.project_id
  region  = var.region
}
