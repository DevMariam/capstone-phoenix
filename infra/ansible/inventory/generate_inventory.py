#!/usr/bin/env python3
"""
Reads ../tf_outputs.json (produced by:
  terraform output -json > infra/ansible/tf_outputs.json
from infra/terraform) and writes inventory/hosts.ini.

Run this from infra/ansible/inventory/ whenever your droplet IPs change
(e.g. after terraform apply creates or recreates a node).
"""
import json
import sys
from pathlib import Path

HERE = Path(__file__).parent
TF_OUTPUTS = HERE.parent / "tf_outputs.json"
OUT_FILE = HERE / "hosts.ini"


def main():
    if not TF_OUTPUTS.exists():
        print(f"Could not find {TF_OUTPUTS}.")
        print("Run this first, from infra/terraform:")
        print("  terraform output -json > ../ansible/tf_outputs.json")
        sys.exit(1)

    data = json.loads(TF_OUTPUTS.read_text())

    control_public = data["control_plane_public_ip"]["value"]
    control_private = data["control_plane_private_ip"]["value"]
    worker_names = data["worker_names"]["value"]
    worker_public = data["worker_public_ips"]["value"]
    worker_private = data["worker_private_ips"]["value"]

    lines = [
        "[control_plane]",
        f"phoenix-control ansible_host={control_public} private_ip={control_private}",
        "",
        "[workers]",
    ]
    for name, pub, priv in zip(worker_names, worker_public, worker_private):
        lines.append(f"{name} ansible_host={pub} private_ip={priv}")

    lines += [
        "",
        "[k3s_cluster:children]",
        "control_plane",
        "workers",
        "",
        "[all:vars]",
        "ansible_user=mariam",
        "ansible_ssh_private_key_file=~/.ssh/phoenix_key",
        "ansible_python_interpreter=/usr/bin/python3",
        "ansible_ssh_common_args='-o StrictHostKeyChecking=accept-new'",
        "",
    ]

    OUT_FILE.write_text("\n".join(lines))
    print(f"Wrote {OUT_FILE}")


if __name__ == "__main__":
    main()
