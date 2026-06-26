# Architecture — Phoenix: TaskApp on Real Kubernetes

## Overview

TaskApp is a full-stack task management application (React/nginx frontend,
Flask/Postgres backend) deployed on a self-provisioned 3-node k3s Kubernetes
cluster on DigitalOcean, managed entirely via GitOps (Argo CD).

## Infrastructure Layer

### Cloud Provider
DigitalOcean — chosen for simple API, predictable pricing, and native
Terraform provider support.

### Terraform Modules
- modules/network/ — VPC (10.10.0.0/24, nyc3)
- modules/compute/ — 1 control-plane + 2 worker droplets (s-2vcpu-4gb)
- modules/firewall/ — Least-privilege inbound rules

### Firewall Rules
| Port | Source | Purpose |
|------|--------|---------|
| 22 | Admin IP only | SSH |
| 80/443 | 0.0.0.0/0 | App traffic |
| 6443 | VPC + Admin IP | Kubernetes API |
| 8472/10250 | VPC only | Node-to-node |

### Remote State
Terraform Cloud — provides remote state storage and locking.

## Cluster Layer

### k3s (v1.30.4+k3s1)
- 1 control-plane: phoenix-control (104.236.121.208)
- 2 workers: phoenix-worker-1, phoenix-worker-2
- Built-in: Traefik, CoreDNS, metrics-server, Flannel CNI

### Ansible Automation
- bootstrap.yml — creates non-root sudo user, disables root SSH
- site.yml — idempotent k3s install, fetches kubeconfig

## Application Layer

### Configuration Split
- ConfigMap — non-secret: DB host, port, name, user, Flask env
- Secret — sensitive: DB password, JWT secret key

### Postgres (StatefulSet)
Single replica with 2Gi PVC (local-path storage class).
Data survives pod deletion — proven by delete test.

### Migrations (Job)
Runs alembic upgrade head once before backend replicas start,
preventing the race condition at 2+ replicas.

### Backend (Flask/gunicorn)
- 2 replicas, spread across nodes via topologySpreadConstraints
- maxUnavailable: 0 rolling updates
- HPA: scales 2-5 replicas at 70% CPU
- securityContext: runAsNonRoot, drop ALL capabilities

### Frontend (React/nginx)
- 2 replicas spread across nodes
- PodDisruptionBudget: minimum 1 replica always available

### Ingress (Traefik)
Same-origin routing on taskapp-mariam.xyz:
- /api/* → backend (Flask handles /api/ prefix natively)
- /* → frontend (nginx/React)
TLS via Let's Encrypt cert-manager. No self-signed certificates.

## GitOps Layer (Argo CD)

Argo CD watches manifests/taskapp/ in this repo.
Any git push to main auto-syncs to the cluster within ~3 minutes.
No manual kubectl apply in the final state.

## Traffic Flow
User → HTTPS:443 → Firewall → Traefik
/api/* → backend Service → Flask Pod → Postgres
/*     → frontend Service → nginx Pod
## High Availability

| Failure | Recovery |
|---------|----------|
| Backend pod killed | Other replica serves traffic, new pod starts in ~15s |
| Frontend pod killed | Other replica serves traffic, new pod starts in ~10s |
| Worker node lost | Pods rescheduled to remaining nodes in ~60s |
| Postgres pod killed | StatefulSet restarts pod, PVC reattaches, ~5s downtime |
