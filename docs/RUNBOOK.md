# Runbook — Phoenix: TaskApp on Real Kubernetes

## Prerequisites

```bash
export KUBECONFIG=/path/to/infra/ansible/kubeconfig-phoenix.yaml
kubectl get nodes
```

## Check Application Health

```bash
kubectl get pods -n taskapp
kubectl get ingress -n taskapp
kubectl get certificate -n taskapp
kubectl get application -n argocd
```

## Deploy a New Image Version

1. Update image tag in manifests/taskapp/backend-deployment.yaml
2. Commit and push to main
3. Argo CD auto-syncs within ~3 minutes
4. Verify: kubectl rollout status deployment/backend -n taskapp

Never run kubectl apply manually — GitOps owns the cluster.

## Run Database Migrations

```bash
kubectl delete job db-migrate -n taskapp
kubectl apply -f manifests/taskapp/migrations-job.yaml
kubectl wait --for=condition=complete job/db-migrate -n taskapp --timeout=120s
```

## Prove Data Survives Pod Delete

```bash
# Create a task in the UI, then:
kubectl delete pod postgres-0 -n taskapp
kubectl get pods -n taskapp -w
# Log in again — task should still be there
```

## Rotate Secrets

```bash
kubectl apply -f manifests/taskapp/secret.yaml
kubectl rollout restart deployment/backend -n taskapp
```

## Renew TLS Certificate

```bash
kubectl delete secret taskapp-tls -n taskapp
kubectl get certificate -n taskapp -w
```

## Disaster Recovery — Full Cluster Rebuild

```bash
cd infra/terraform && terraform apply
terraform output -json > ../ansible/tf_outputs.json
cd ../ansible && python3 inventory/generate_inventory.py
ansible-playbook bootstrap.yml
ansible-playbook site.yml
kubectl apply -f manifests/platform/clusterissuer.yaml
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl create secret docker-registry ghcr-secret --namespace taskapp \
  --docker-server=ghcr.io --docker-username=YOUR_GITHUB_USERNAME \
  --docker-password=YOUR_GITHUB_PAT
kubectl apply -f manifests/taskapp/secret.yaml
kubectl apply -f manifests/gitops/argocd-app.yaml
```

## Useful Commands

```bash
kubectl top nodes
kubectl top pods -n taskapp
kubectl logs -n taskapp -l app=backend --tail=50
kubectl port-forward svc/argocd-server -n argocd 8080:443
```
