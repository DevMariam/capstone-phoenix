variable "project_name" {
  type = string
}

variable "droplet_ids" {
  type        = list(string)
  description = "Droplet IDs to attach this firewall to"
}

variable "admin_ip_cidr" {
  type        = string
  description = "Your public IP in CIDR form, e.g. 203.0.113.5/32"
}

variable "vpc_cidr" {
  type        = string
  description = "Internal VPC CIDR allowed for cluster-internal traffic"
}
