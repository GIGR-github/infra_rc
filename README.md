# Red Coast Production Infra

Production-grade Infrastructure as Code (IaC) repository designed for secure, immutable, and fully automated lifecycle management of a **Docker Swarm** cluster and a monolithic application stack. Built with **Terraform**, **Ansible**, and **GitHub Actions**, enforcing strict GitOps principles and zero-downtime deployment strategies.

---

## Enterprise Architecture and Tech Stack

* **Orchestration:** Docker Swarm (Single-node or multi-node production cluster, overlay networks, secrets management)
* **Application Architecture:** Monolithic application deployed as a containerized service stack
* **Infrastructure Provisioning:** Terraform (Modular structure, remote state backend with state locking)
* **Configuration Management:** Ansible (Idempotent playbooks, server hardening, Ansible Vault for secrets)
* **CI/CD & GitOps:** GitHub Actions (Self-hosted runners, least-privilege access)
* **Observability & Health Checks:** Automated Post-Deploy HTTP/TCP probing, container health policies
* **Project Governance:** GitHub Issues, Custom Templates, Automated Kanban Projects Board

---

## GitOps and Change Management Workflow

To maintain compliance, high availability, and auditability, all modifications must adhere to a strict change management lifecycle:

1. **Change Request / Incident Logging:**
    * Infrastructure and deployment updates begin with an **RFC Issue** (`change-request.yml`).
    * Production incidents automatically trigger an **Incident Issue** (`infra-incident.yml`).

2. **Branching Strategy (Trunk-Based):**
   ```bash
   git checkout -b feature/RFC-42-update-app-env
3. **Automated Validation (CI Gate):**
    * Pushing code changes triggers automated linters and security scanners (`tflint`, `tfsec`, `ansible-lint`) via GitHub Actions.
    * A dry-run `terraform plan` and dependency audit are automatically executed and posted as a comment on the Pull Request to review infrastructure delta prior to review.

4. **Commit & Issue Linking:**
    * Commit messages must follow [Conventional Commits](https://www.conventionalcommits.org/) and explicitly reference the tracking ID to tie code changes directly to the governance task:
      ```bash
      git commit -m "refactor(docker): update application resource limits, resolves #42"
      ```

5. **Deployment & State Synchronization:**
    * Merging approved code into the `main` branch triggers the production pipeline (`.github/workflows/production-deploy.yml`).
    * Ansible and Docker Swarm execute a zero-downtime rolling update of the monolithic service stack, utilizing strict health probes (`--update-failure-action rollback` on failure).
    * Successfully merging the Pull Request automatically closes the linked governance Issue and updates the Kanban board.