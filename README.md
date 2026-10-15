# Krasny Bereg — Red Coast Production Infrastructure

[![CI/CD Pipeline](https://github.com/GIGR-github/infra_rc.git/actions/workflows/stage.yml/badge.svg)](https://github.com/GIGR-github/infra_rc.git/actions/workflows/deploy.yml)
[![Security Scan](https://github.com/GIGR-github/infra_rc.git/actions/workflows/security.yml/badge.svg)](https://github.com/GIGR-github/infra_rc.git/actions/workflows/security.yml)
![Infrastructure License](https://img.shields.io/badge/license-Proprietary-red.svg)

This repository hosts the **Production-grade Infrastructure as Code (IaC)** and GitOps configurations for the **Krasny Bereg (Red Coast)** platform. It manages the fully automated lifecycle, security hardening, and zero-downtime deployment of a high-availability Docker Swarm cluster running our containerized monolithic core application stack.

---

## System Architecture Overview

<p align="center">
  <img src=".github/images/sa.png" alt="System Architecture" width="600">
</p>



The infrastructure enforces strict isolation. All ingress traffic is routed through hardened Nginx reverse proxies, while the monolithic application (Java Spring Boot Core) and database tiers communicate exclusively inside isolated, encrypted Docker Overlay Networks.

---

## Enterprise Tech Stack

| Component | Technology | Operational Purpose |
| :--- | :--- | :--- |
| **Cloud Provisioning** | Terraform (v1.8+) | Modular stateful provisioning with remote S3 backend & DynamoDB state locking. |
| **Configuration** | Ansible (v2.15+) | Idempotent OS tuning, SSH hardening, and automated Swarm cluster bootstrap. |
| **Orchestration** | Docker Swarm | Container scheduling, multi-node scaling, rollbacks, and native ingress mesh. |
| **CI/CD & GitOps** | GitHub Actions | Self-hosted runner execution using least-privilege IAM roles and strict logs grouping. |
| **Security Scanning** | `tflint`, `tfsec`, `ansible-lint` | Automated static analysis and structural compliance gates on every PR. |

---

## Repository Directory Structure

```text
.
├── .github/
│   ├── ISSUE_TEMPLATE/        # Structured Change Requests & Incident forms
│   └── workflows/             # CI/CD automation pipelines (lint, plan, deploy)
├── ansible/
│   ├── inventory/             # Environment-specific host files (dev, staging, prod)
│   ├── roles/                 # Reusable configurations (security, docker, swarm)
│   │   ├── common/            # OS hardening, fail2ban, firewall rules
│   │   └── swarm-cluster/     # Manager/Worker token generation & cluster bootstrap
│   └── infra-cluster-setup.yml# Main playbook for infrastructure convergence
├── terraform/
│   ├── environments/          # Environment instantiations (.tfvars definitions)
│   └── modules/               # Reusable infrastructure blocks (compute, network, storage)
└── scripts/
    ├── deploy-infra.sh        # Orchestrated Terraform lifecycle entrypoint
    └── get-ip-manager.sh      # Dynamic inventory resolver and metadata updater
```

---

## GitOps Deployment & Operational Lifecycle

This repository strictly enforces **GitOps principles**. Direct infrastructure state mutations from local engineer machines are blocked. The cluster lifecycle is driven entirely by GitHub Actions running on automated runners.

### 1. Automated CI/CD Pipeline Execution (The Standard Path)
Every core infrastructure event follows a strictly orchestrated sequence triggered by Git events on the `main` branch:

```text
┌──────────────────┐     ┌─────────────────────┐     ┌───────────────────┐     ┌─────────────────────┐
│  git push / merge│     │  Terraform Deploy   │     │  Dynamic IP Scan  │     │  Ansible Provision  │
│    to main       ├────►|  (deploy-infra.sh)  ├─────►(get-ip-manager.sh)├──_─►|(infra-cluster-setup)│
└──────────────────┘     └─────────────────────┘     └───────────────────┘     └─────────────────────┘
```

1. **Infrastructure Provisioning (`deploy-infra.sh`):** Changes trigger the custom deployment wrapper script. It initializes Terraform, maps the workspace, and executes `terraform apply` non-interactively using automated state-locking management.
2. **Dynamic Inventory Resolution (`get-ip-manager.sh`):** The pipeline runs the tracking script to extract the newly provisioned Swarm Manager IP address and update the required application repository metadata via GitHub API tokens (`GH_TOKEN`).
3. **Target Node Hardening & Orchestration (`infra-cluster-setup.yml`):** An ephemeral enterprise SSH key is established (`SSH_PRIVATE_KEY`), `known_hosts` are verified to prevent MITM vector, and the Ansible playbook is executed to converge the final operating system and Docker Swarm cluster state.

### 2. Local Read-Only Inspection & Verification (Dry-Runs)
To safely evaluate the impact of your code changes locally before pushing to remote branches, use the following read-only simulations:

#### Validating Infrastructure Code Changes
To check syntax, look up backend configurations, and preview the state delta without applying any mutations, run the orchestrator script with the `--dry-run` flag:
```bash
# 1. Export the target environment configuration file path
export TARGET_ENV_TF="../terraform/environments/staging.tfvars"

# 2. Run the secure planning wrapper from the terraform execution folder
cd terraform
../scripts/deploy-infra.sh --dry-run
```
*(Note: Local write mutations are blocked by cloud provider IAM policies. Real apply routines run strictly inside GitHub CI).*

#### Simulating Ansible Configuration Convergence
Verify playbook compatibility and linting against targeted server nodes without writing changes to the operating system:
```bash
cd ansible
ansible-playbook -i ./inventory/nodes.ini ../infra-cluster-setup.yml --check --diff \
  --extra-vars "db_password=DUMMY db_root_password=DUMMY flyway_password=DUMMY"
```

---

## 🔒 Security, Compliance & Secret Management

### Secrets Encapsulation
Sensitive parameters within Ansible configurations are managed dynamically.
- **CI Injection:** Database, root account, and migration passwords (`DB_PASSWORD`, `DB_ROOT_PASSWORD`, `FLYWAY_PASSWORD`) are stored inside encrypted **GitHub Secrets** and safely injected directly via Ansible `--extra-vars` flag, preventing plain-text leakage in stdout or log management pipelines.
- **Swarm Runtime:** Application credentials are deployed as immutable **Docker Secrets**. They are mounted directly into volatile container RAM paths (`/run/secrets/`), ensuring zero-exposure on host disks.

---

## Project Governance & Contributing

We enforce a highly disciplined change management strategy to guarantee absolute auditability and continuous operational compliance.

* For instructions on creating branches, setting up local commit hooks, utilizing Conventional Commits, and verifying code through staging environments, please strictly consult our **[Contributing Guidelines (CONTRIBUTING.md)](CONTRIBUTING.md)**.
* To review specific component maintainers or routing rules for automated Pull Request evaluations, check the **[CODEOWNERS](.github/CODEOWNERS)** matrix.

---

## License
This infrastructure source code is proprietary and confidential. Unauthorized copying, distribution, or modifications via any medium is strictly prohibited. For authorized external integrations, refer to the [LICENSE](LICENSE) file.
