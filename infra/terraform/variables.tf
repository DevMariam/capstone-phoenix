variable "do_token" {
  type        = string
  sensitive   = true
  description = "DigitalOcean API token. Set via TF_VAR_do_token env var, never commit this."
}

variable "project_name" {
  type    = string
  default = "phoenix"
}

variable "region" {
  type    = string
  default = "nyc3"
}

variable "droplet_size" {
  type    = string
  default = "s-2vcpu-4gb"
}

variable "image" {
  type    = string
  default = "ubuntu-22-04-x64"
}

variable "vpc_cidr" {
  type    = string
  default = "10.10.0.0/24"
}

variable "admin_ip_cidr" {
  type        = string
  description = "Your public IP in CIDR form, e.g. 203.0.113.5/32 (find yours with: curl ifconfig.me)"
}

variable "ssh_key_fingerprint" {
  type        = string
  description = "Fingerprint of an SSH key already uploaded to your DO account (doctl compute ssh-key list)"
}

variable "worker_count" {
  type    = number
  default = 2
}
