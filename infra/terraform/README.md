# Terraform — Week 1 notes

## What this provisions
- 1 VPC
- 1 control-plane droplet + N worker droplets (default 2), all in the VPC
- 1 firewall: 22 from your IP only, 80/443 open, 6443/8472/10250 restricted to the VPC

## One-time setup
1. Install `doctl` and `terraform` (>= 1.5.0).
2. `doctl auth init` and log in to your DO account.
3. Upload an SSH key if you don't have one in DO yet:
   `doctl compute ssh-key import phoenix-key --public-key-file ~/.ssh/id_ed25519.pub`
   Then `doctl compute ssh-key list` to get its fingerprint.
4. Find your public IP for the firewall: `curl ifconfig.me`
5. Set up remote state per the comments in `backend.tf` (Terraform Cloud recommended).

## Running it
```bash
cd infra/terraform
cp terraform.tfvars.example terraform.tfvars   # then edit with real values
export TF_VAR_do_token="dop_v1_xxxxxxxx"        # never put this in a file

terraform login      # one-time, for Terraform Cloud
terraform init
terraform plan
terraform apply
```

## After apply
```bash
terraform output -json > ../ansible/tf_outputs.json
```
This file feeds directly into the Ansible inventory in Week 2 — don't commit it if it contains IPs you'd rather keep out of git history (it's fine either way since IPs aren't secrets, but keep `terraform.tfvars` and any `.tfstate` out of git regardless).

## Requirements this satisfies (from the README)
- 3 nodes minimum, real scheduling across real machines
- Modular Terraform (network / firewall / compute)
- Remote state, no local `terraform.tfstate` in git
- Least-privilege firewall (22 your IP, 80/443 open, 6443 never public)
- All config from variables — no hardcoded IPs/AMIs/secrets
- Outputs ready for Ansible to consume
