output "vpc_id" {
  value = digitalocean_vpc.this.id
}

output "vpc_cidr" {
  value = digitalocean_vpc.this.ip_range
}
