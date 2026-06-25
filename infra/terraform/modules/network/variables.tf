variable "project_name" {
  type        = string
  description = "Short name used as a prefix for all resources"
}

variable "region" {
  type        = string
  description = "DigitalOcean region slug, e.g. nyc3"
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR block for the VPC, e.g. 10.10.0.0/24"
}
