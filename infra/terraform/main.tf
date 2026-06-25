terraform {
  required_version = ">= 1.5.0"

  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.34"
    }
  }
}

provider "digitalocean" {
  token = var.do_token
}

module "network" {
  source       = "./modules/network"
  project_name = var.project_name
  region       = var.region
  vpc_cidr     = var.vpc_cidr
}

module "compute" {
  source              = "./modules/compute"
  project_name        = var.project_name
  region              = var.region
  droplet_size        = var.droplet_size
  image               = var.image
  vpc_id              = module.network.vpc_id
  ssh_key_fingerprint = var.ssh_key_fingerprint
  worker_count        = var.worker_count
}

module "firewall" {
  source        = "./modules/firewall"
  project_name  = var.project_name
  admin_ip_cidr = var.admin_ip_cidr
  vpc_cidr      = module.network.vpc_cidr
  droplet_ids = concat(
    [module.compute.control_plane_id],
    module.compute.worker_ids
  )
}
