# 🖥️💰 My Free Infrastructure

A fully automated 3-node cluster on Oracle Cloud Infrastructure (OCI) Free Tier, managed with Terraform, Ansible, and Docker Compose.

## Architecture

```
┌────────────────────────────────────────────────────────────────┐
│                  cluster-network VCN (10.0.0.0/16)             │
│                                                                │
│  ┌───────────────────┐  ┌──────────────────┐  ┌─────────────┐  │
│  │  node_0 (HEAD)    │  │  node_1 (WORKER) │  │ node_heavy_0│  │
│  │  VM.Standard.     │  │  VM.Standard.    │  │ VM.Standard.│  │
│  │  E2.1.Micro       │  │  E2.1.Micro      │  │ E2.4        │  │
│  │                   │  │                  │  │             │  │
│  │  - Portainer CE   │  │  - Portainer     │  │ - Portainer │  │
│  │  - Caddy (HTTPS)  │  │    Agent         │  │   Agent     │  │
│  └───────────────────┘  └──────────────────┘  └─────────────┘  │
└────────────────────────────────────────────────────────────────┘
```

**Stack:**
- **Cloud:** Oracle Cloud Infrastructure (São Paulo region)
- **IaC:** Terraform with custom OCI modules
- **Config Management:** Ansible
- **Container Runtime:** Docker + Docker Compose
- **Cluster UI:** Portainer CE + Agents
- **Reverse Proxy:** Caddy (automatic HTTPS)

---

## Terraform

### Production Stack (`terraform/production/`)

Provisions the full cluster infrastructure on OCI using two custom modules.

**Nodes:**

| Node | Role | Shape |
|------|------|-------|
| `node_0` | Head / Swarm Manager | VM.Standard.E2.1.Micro |
| `node_1` | Worker | VM.Standard.E2.1.Micro |
| `node_heavy_0` | Heavy Worker | VM.Standard.E2.4 |

- SSH access is restricted to your current public IP (fetched from ipify.org at apply time).
- Inter-node communication (Portainer Agent on port 9001) is restricted to node_0's private IP.

**IAM:** An OCI dynamic group and policy grant node_0 permissions to manage instances in the compartment (start/stop/reboot workers).

**Provider:** OCI (`sa-saopaulo-1`) with SecurityToken authentication.

---

### Modules

#### `terraform/modules/virtual-network`

Creates all networking resources for the cluster.

| Resource | Details |
|----------|---------|
| VCN | `10.0.0.0/16` (configurable) |
| Subnet | `10.0.0.0/24` (configurable) |
| Internet Gateway | Routes `0.0.0.0/0` for public access |

**Variables:**

| Name | Default | Description |
|------|---------|-------------|
| `compartment_id` | — | OCI compartment OCID |
| `display_name` | — | Name for VCN and subnet resources |
| `cidr_block` | `10.0.0.0/16` | VCN CIDR block |
| `subnet_cidr_block` | `10.0.0.0/24` | Subnet CIDR block |
| `allow_public_ip` | `false` | Allow public IPs on the subnet |

**Outputs:** `vcn_id`, `subnet_id`

---

#### `terraform/modules/linux-machine`

Creates an Ubuntu 24.04 VM instance with an auto-generated ED25519 SSH key and a Network Security Group (NSG).

**Variables:**

| Name | Default | Description |
|------|---------|-------------|
| `compartment_id` | — | OCI compartment OCID |
| `display_name` | — | Instance display name |
| `shape` | `VM.Standard.E2.1.Micro` | OCI compute shape |
| `os` | — | Object with `name` and `version` fields |
| `subnet_id` | — | Subnet to launch the instance in |
| `vcn_id` | — | VCN for the NSG |
| `assign_public_ip` | `false` | Assign a public IPv4 address |
| `boot_volume_size_in_gbs` | `50` | Boot volume size in GiB |
| `ingress_tcp_rules` | `[]` | List of `{port, cidr}` objects for TCP ingress |
| `ingress_udp_rules` | `[]` | List of `{port, cidr}` objects for UDP ingress |
| `allow_icmp` | `false` | Allow ICMP (ping) |

**Outputs:** `instance_id`, `public_ip`, `private_ip`, `ssh_private_key` (sensitive), `ssh_public_key`, `nsg_id`

---

## Ansible

### Configuration

`ansible/ansible.cfg` is pre-configured with:
- Remote user: `ubuntu`
- Host key checking disabled
- SSH connection multiplexing (60s persistence)
- Pipelining enabled

SSH keys and the inventory file are generated from Terraform outputs via `make` (see [Makefile](#makefile)).

### Playbooks (`ansible/playbooks/`)

#### `install-docker.yaml`

Installs Docker Engine on Ubuntu hosts.

```bash
ansible-playbook -i inventory/production playbooks/install-docker.yaml
```

Tasks:
- Installs system dependencies and Docker GPG key
- Adds Docker CE apt repository
- Installs `docker-ce`, `docker-ce-cli`, `containerd.io`, `docker-buildx-plugin`, `docker-compose-plugin`
- Adds the `ubuntu` user to the `docker` group

---

#### `update-system.yaml`

Runs a full system upgrade and reboots if required.

```bash
ansible-playbook -i inventory/production playbooks/update-system.yaml
```

Tasks:
- Updates apt cache and runs `dist-upgrade` with autoremove/autoclean
- Detects if a reboot is needed
- Reboots and waits for the host to come back online

---

#### `deploy-stack.yaml`

Copies a Docker Compose stack to the target nodes and deploys it.

```bash
ansible-playbook -i inventory/custom ansible/playbooks/deploy-stack.yaml -e stack=stack-name
```

Tasks:
- Prompts for the stack name at runtime
- Copies `stacks/<stack>/` to `~/stacks/<stack>/` on the remote host
- Deploys with `docker compose up` (`recreate: always`)
- Loads environment variables from the stack's `.env` file
- Prunes unused Docker resources (containers, images, networks, volumes, build cache)

---

## Docker Compose Stacks

### `stacks/cluster-head/` (node_0)

Runs the management services on the head node.

| Service | Image | Purpose |
|---------|-------|---------|
| `portainer` | `portainer/portainer-ce:lts` | Cluster management UI |
| `caddy` | `caddy:2.11-alpine` | Reverse proxy with automatic HTTPS |

Caddy routes traffic based on subdomain:
- `admin.<DOMAIN>` → Portainer UI (`http://portainer:9000`)
- Root domain → admin dashboard

Environment variable: `DOMAIN` (configured in `stacks/cluster-head/.env`).

---

### `stacks/cluster-node/` (node_1, node_heavy_0)

Runs the Portainer Agent on each worker node so they can be managed by the head node.

| Service | Image | Port | Purpose |
|---------|-------|------|---------|
| `portainer_agent` | `portainer/agent:lts` | 9001 | Portainer cluster agent |

---

## Makefile

Bridges Terraform outputs to Ansible by reading from the Terraform state.

```bash
make ansible/ssh        # Extract SSH private keys from Terraform outputs → ansible/ssh/*.key
make ansible/inventory  # Generate ansible/inventory/production from Terraform outputs
```

Both targets must be run from the repo root after `terraform apply`.

---

## Getting Started

### Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/install) >= 1.0
- [Ansible](https://docs.ansible.com/ansible/latest/installation_guide/index.html) >= 2.15
- OCI CLI configured with a valid session token

### 1. Provision Infrastructure

```bash
cd terraform/production
terraform init
terraform apply
```

### 2. Generate Ansible SSH Keys and Inventory

```bash
make ansible/ssh
make ansible/inventory
```

### 3. Install Docker on All Nodes

```bash
cd ansible
ansible-playbook -i inventory/production playbooks/install-docker.yaml
```

### 4. Deploy Stacks

```bash
cd ansible

# Head node
ansible-playbook -i inventory/head playbooks/deploy-stack.yaml -e stack=cluster-head

# Worker nodes
ansible-playbook -i inventory/node ansible/playbooks/deploy-stack.yaml -e stack=cluster-node
```

---

## License

MIT
