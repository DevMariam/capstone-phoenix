variable "project_name" {
  type = string
}

variable "region" {
  type = string
}

variable "droplet_size" {
  type        = string
  description = "DO droplet size slug, e.g. s-2vcpu-4gb"
}

variable "image" {
  type        = string
  description = "DO image slug, e.g. ubuntu-22-04-x64"
}

variable "vpc_id" {
  type        = string
  description = "VPC UUID from the network module"
}

variable "ssh_key_fingerprint" {
  type        = string
  description = "Fingerprint of an SSH key already uploaded to your DO account"
}

variable "worker_count" {
  type    = number
  default = 2
}
