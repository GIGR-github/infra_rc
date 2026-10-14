# Contributing Guidelines for Krasny Bereg Infrastructure

Welcome to the **Krasny Bereg** infrastructure and GitOps repository!

To maintain system stability, security, and traceability across environments, all engineers, contractors, and developers must follow the standards outlined in this document.

---

## Table of Contents
1. [General Principles](#general-principles)
2. [Issue Management (RFC & Incidents)](#issue-management-rfc--incidents)
3. [Branching Strategy](#branching-strategy)
4. [Git & Commit Guidelines](#git--commit-guidelines)
5. [Pull Request (PR) & Code Review Process](#pull-request-pr--code-review-process)
6. [Security & Secrets Management](#security--secrets-management)

---

## General Principles

* **Infrastructure as Code (IaC):** Never apply manual changes directly on servers or cluster nodes. All configurations must be declared in this repository and deployed via CI/CD pipelines.
* **No Direct Commits to `main`:** The `main` branch is protected and represents the actual or intended state of production. All changes must be reviewed via Pull Requests.
* **No Secret Leaks:** Plaintext passwords, private keys, or API tokens must **never** be committed to Git.

### Emergency "Break-Glass" Access
- In the event of a catastrophic failure where CI/CD or the GitOps controller (e.g., ArgoCD/Flux) is unavailable, team members may request temporary elevated access keys (Break-Glass) to modify infrastructure manually.
- **Mandatory Drift Reconciliation:** Any change made during a break-glass session must be backported to this repository via an RFC/Hotfix PR within 24 hours of incident resolution to eliminate configuration drift.

---

## Issue Management (RFC & Incidents)

We use structured GitHub Issue Forms to track all planned changes and unscheduled outages.

### 1. Production Incidents (`01-infra-incident.yml`)
* Use this form for unscheduled system outages, service degradations, or critical component failures.
* **Requirement:** After the system is stabilized, a **Root Cause Analysis (RCA)** must be completed and documented in the issue before it can be closed.

### 2. Request for Change / RFC (`02-change-request.yml`)
* Use this form for any planned update to environment variables, server resources, stack configurations, or architecture.
* **Requirement:** Every RFC must include a validated **Rollback Plan** and business/technical justification prior to review.

---

## Branching Strategy

We follow a simplified **Feature-Branch Workflow**:

* `main` — Production-ready code and infrastructure state.
* `feature/<issue-id>-<short-description>` — For planned changes (e.g., `feature/12-upgrade-db-limits`).
* `fix/<issue-id>-<short-description>` — For bug fixes and non-critical corrections (e.g., `fix/34-nginx-timeout`).
* `hotfix/<issue-id>-<short-description>` — For emergency production incident resolutions (e.g., `hotfix/104-restore-proxy`).

---

## Git & Commit Guidelines

We enforce the [Conventional Commits](https://www.conventionalcommits.org/) specification to maintain a clear, searchable git history and automate issue linking.

### Policy Enforcement
- **Commit Linting:** We run a CI linter (`commitlint`) on all incoming Pull Requests. PRs with non-compliant commit messages will block the CI/CD pipeline.
- **Automated Secret Scanning:** Every push to a remote branch is automatically scanned by GitHub Advanced Security / Secret Scanning (or Trufflehog CI). Commits containing leaked keys will block merges immediately.

### Commit Message Format

```text
<type>(<scope>): <short description>

[optional body]

[optional footer(s) - e.g., Closes #12]
```

### Allowed Types (`<type>`)
- feat: A new infrastructure resource, service, or configuration feature.
- fix: A bug fix or incident resolution in code or configuration.
- refactor: Restructuring manifests or playbooks without changing functionality.
- chore: Maintenance tasks, dependency updates, or base image bumps.
- ci: Changes to CI/CD workflows (.github/workflows/).
- docs: Documentation updates (README.md, templates, procedures).
- revert: Reverting a previous infrastructure commit due to an incident or change failure.

### Standard Scopes (`<scope>`)
- app / monolith: Application container, runtime configurations, environment variables.
- db: Database configuration, backups, persistent volumes.
- proxy: Nginx, SSL certificates, routing rules, rate limits, timeouts.
- tf: Terraform manifests, modules, and state management.
- ansible: Ansible playbooks, roles, host provisioning.
- docker / swarm: Compose stacks, Swarm services, networks, resource limits.
- ci: GitHub Actions pipelines and deployment runners.
- templates: GitHub Issue Forms (.github/ISSUE_TEMPLATE/).
- docs: Infrastructure and project documentation.

### Linking Commits to Issues
Every pull request or commit merged into main must be linked to an open RFC or Incident Issue using GitHub closing keywords:
#### Closing an RFC / Feature:
```text 
feat(docker): increase memory limits for monolith app
Adjusted container resources to handle upcoming traffic spikes.
Closes #12
```
#### Resolving an Incident:
```text
fix(proxy): increase upstream timeout to 60s
Fixes intermittent 504 Gateway Timeout errors during large file uploads.
Fixes #104
```
---

## Pull Request (PR) & Code Review Process
- Self-Review: Before requesting a review, verify that your changes pass all local linting checks (e.g., terraform validate, ansible-lint, Dockerfile linters).
- PR Description: Describe what was changed, link the relevant Issue ID (Closes #ID), and attach test/validation output.
- Approvals: At least one review approval from an infrastructure lead/peer is required before merging into main.
- Merge Method: Use Squash and Merge or Rebase and Merge to keep the main branch history clean and linear.
- **Staging Verification:** Any change to core infrastructure, networking, or orchestration MUST be deployed and verified in the `staging` or `dev` environment prior to merging into `main`.
- **Dry-Run Validation:** PR descriptions must include logs of a successful dry-run execution (e.g., `terraform plan` output showing exactly what resources will be created/destroyed, or `ansible-playbook --check`).
- **Breaking Changes Flag:** If a change causes resource destruction/recreation (e.g., database instances, volumes), the author must explicitly tag the PR with a `breaking-change` label and coordinate maintenance windows.

---

## Security & Secrets Management

- Pre-commit Hooks: It is strongly recommended to use tools like git-secrets or trufflehog locally to prevent accidental secret commits.
- Secrets Handling: Use environment variables, GitHub Secrets, or an external vault (e.g., HashiCorp Vault / Ansible Vault) for confidential data.
- Immediate Remediation: If a secret is accidentally committed to Git, notify the team immediately and consider the secret compromised (revoke and rotate it instantly).