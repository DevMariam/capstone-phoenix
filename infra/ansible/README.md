# Ansible — Week 1/2 notes (cluster bring-up)

## What this does
1. `bootstrap.yml` — connects as root (one time only), creates a sudo user
   (`mariam`, set in `group_vars/all.yml`), copies your SSH key over to it,
   and disables root SSH login.
2. `site.yml` — connects as that sudo user, installs k3s on the control
   plane, joins the 2 workers over the **private** network, then fetches
   the kubeconfig and rewrites it to use the control plane's public IP.

## One-time setup
From `infra/terraform`, after `terraform apply` succeeds:
```bash
terraform output -json > ../ansible/tf_outputs.json
```

From `infra/ansible`:
```bash
python3 inventory/generate_inventory.py
```
This writes `inventory/hosts.ini` from the Terraform outputs. Re-run it
any time your droplet IPs change.

## Run order
```bash
cd infra/ansible

# 1. Bootstrap (root, run ONCE)
ansible-playbook bootstrap.yml

# 2. Cluster bring-up (idempotent, safe to re-run anytime)
ansible-playbook site.yml
```

If `bootstrap.yml` is accidentally run a second time, it will fail to
connect — that's expected, since root login is now disabled. That's fine;
it isn't meant to run again.

## Verify
```bash
export KUBECONFIG=$(pwd)/kubeconfig-phoenix.yaml
kubectl get nodes
```
You should see the control plane + both workers listed as `Ready`.

## Idempotency check (matches the README's acceptance bullet)
```bash
ansible-playbook site.yml
```
Run it twice in a row — the second run should show `changed=0` for every
host (k3s/k3s-agent are already installed and already running).

## Things to add to your repo .gitignore
```
infra/ansible/kubeconfig-phoenix.yaml
infra/ansible/inventory/hosts.ini
infra/ansible/tf_outputs.json
```
None of these are secrets exactly, but they're all generated/local
artifacts — the kubeconfig especially should never be committed (it's
explicitly forbidden in the README's hard constraints).

## Requirements this satisfies
- Idempotent playbook (`ansible-playbook` twice = no changes)
- Kubeconfig fetched locally with server address rewritten to public IP
- No root SSH (root login disabled after bootstrap)
- k3s join happens over the private network only (matches the firewall
  rule that keeps 6443 closed to the internet)
