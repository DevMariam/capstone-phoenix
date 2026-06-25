# Least-privilege firewall:
#   - 22   open only to your IP (admin_ip_cidr)
#   - 80/443 open to the world (ingress for the app)
#   - 6443 (Kubernetes API) restricted to the VPC only — never public
#   - 8472 (Flannel VXLAN) and 10250 (kubelet) restricted to the VPC only
resource "digitalocean_firewall" "this" {
  name        = "${var.project_name}-fw"
  droplet_ids = var.droplet_ids

  inbound_rule {
    protocol         = "tcp"
    port_range       = "22"
    source_addresses = [var.admin_ip_cidr]
  }

  inbound_rule {
    protocol         = "tcp"
    port_range       = "80"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  inbound_rule {
    protocol         = "tcp"
    port_range       = "443"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  inbound_rule {
    protocol         = "tcp"
    port_range       = "6443"
    source_addresses = [var.vpc_cidr]
  }

  inbound_rule {
    protocol         = "udp"
    port_range       = "8472"
    source_addresses = [var.vpc_cidr]
  }

  inbound_rule {
    protocol         = "tcp"
    port_range       = "10250"
    source_addresses = [var.vpc_cidr]
  }

  outbound_rule {
    protocol              = "tcp"
    port_range            = "1-65535"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "udp"
    port_range            = "1-65535"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "icmp"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }
}
