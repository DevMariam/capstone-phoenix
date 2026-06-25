output "control_plane_id" {
  value = digitalocean_droplet.control_plane.id
}

output "control_plane_public_ip" {
  value = digitalocean_droplet.control_plane.ipv4_address
}

output "control_plane_private_ip" {
  value = digitalocean_droplet.control_plane.ipv4_address_private
}

output "worker_ids" {
  value = digitalocean_droplet.workers[*].id
}

output "worker_public_ips" {
  value = digitalocean_droplet.workers[*].ipv4_address
}

output "worker_private_ips" {
  value = digitalocean_droplet.workers[*].ipv4_address_private
}

output "worker_names" {
  value = digitalocean_droplet.workers[*].name
}
