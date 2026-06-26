# Cost Breakdown — Phoenix: TaskApp on Real Kubernetes

## DigitalOcean Infrastructure

| Resource | Spec | Monthly Cost |
|----------|------|-------------|
| phoenix-control | s-2vcpu-4gb, nyc3 | $24.00 |
| phoenix-worker-1 | s-2vcpu-4gb, nyc3 | $24.00 |
| phoenix-worker-2 | s-2vcpu-4gb, nyc3 | $24.00 |
| VPC + Firewall | — | $0.00 |
| Bandwidth (first 1TB) | — | $0.00 |
| **Total** | | **$72.00/mo** |

Hourly: ~$0.32/hr total for 3 nodes.
3-week capstone estimate: **~$50.40**

## Supporting Services (Free Tier)

| Service | Cost |
|---------|------|
| Terraform Cloud (remote state + locking) | $0.00 |
| GitHub + GHCR (source + images) | $0.00 |
| Let's Encrypt (TLS certificates) | $0.00 |
| ClouDNS (DNS hosting) | $0.00 |
| Argo CD (self-hosted on cluster) | $0.00 |

## Cost Decisions

### Why DigitalOcean?
AWS equivalent (3x t3.medium + ALB + Route53) = ~$120-150/mo.
DigitalOcean is ~50% cheaper for equivalent compute.

### Why s-2vcpu-4gb?
s-1vcpu-2gb ($12/mo) ran out of memory running cert-manager +
Argo CD + Traefik + app pods simultaneously.

### Why local-path storage?
DO Managed Postgres costs $15-50/mo extra. local-path is sufficient
for a capstone. Trade-off: data is tied to a specific node.
Production deployment would use a managed DB.

## Production Cost Projection

| Addition | Cost |
|----------|------|
| Managed Postgres | +$15/mo |
| DO Spaces (backups) | +$5/mo |
| Larger droplets (s-4vcpu-8gb) | +$72/mo |
| Additional worker | +$24/mo |
| **Production total** | **~$188/mo** |
