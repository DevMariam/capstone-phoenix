resource "digitalocean_droplet" "control_plane" {
  name     = "${var.project_name}-control"
  region   = var.region
  size     = var.droplet_size
  image    = var.image
  vpc_uuid = var.vpc_id
  ssh_keys = [var.ssh_key_fingerprint]
  tags     = ["phoenix", "control-plane"]
}

resource "digitalocean_droplet" "workers" {
  count    = var.worker_count
  name     = "${var.project_name}-worker-${count.index + 1}"
  region   = var.region
  size     = var.droplet_size
  image    = var.image
  vpc_uuid = var.vpc_id
  ssh_keys = [var.ssh_key_fingerprint]
  tags     = ["phoenix", "worker"]
}
