#!/bin/bash
# ==============================================================================
# OPERATIONAL RUNBOOK: S3 Object Lifecycle & Retention Policy Enforcement
# PROCESS TYPE:       Cost Optimization & Automated Data Compliance (FinOps)
# METADATA:           Ticket:   [JIRA-4025] Database Infrastructure Hardening
#                     Date:     2026-07-03
#                     Author:   Pavel P. <ppanbeing@redcoast.com>
# ==============================================================================
# DESCRIPTION:
#   Audits and dynamically enforces cloud storage object lifecycle management policies.
#   Ensures that old automated database backups inside DigitalOcean Spaces (S3)
#   are automatically purged after a strict sliding window of 30 days.
#
# ARCHITECTURE, FINOPS & COMPLIANCE DESIGN NOTES:
#   - Idempotency & Cost Prevention: At every execution, the script verifies if a
#     valid lifecycle expiration status already exists via 'getlifecycle'. It avoids
#     redundant API mutation requests, preventing excessive multi-region API charges.
#   - Automated Provisioning: If no expiration rule is discovered, the script
#     dynamically injects a bucket-wide lifecycle expiration configuration
#     ('s3cmd expire') mapping strict retention policies directly into the S3 fabric.
#   - Offloaded Purging Logic: By relying on native cloud S3 lifecycle rules,
#     the physical deletion load is completely offloaded to the DigitalOcean infrastructure.
#     The local backup runner does not waste CPU, memory, or network I/O to delete
#     legacy backup items individually.
#   - Secure Variable Ingestion: Inherits target infrastructure endpoints and secure
#     object storage authorization tokens directly from the shared Makefile runtime environment.
# ==============================================================================

RETENTION_DAYS=30
S3_OPTS="--access_key=${ACCESS_KEY} --secret_key=${SECRET_KEY} \
 --host=sgp1.digitaloceanspaces.com \
 --host-bucket=%(bucket)s.sgp1.digitaloceanspaces.com"
if s3cmd $S3_OPTS getlifecycle s3://asagiri-backup/ | grep -q "Status"; then
   echo "Retention policy is activated to: $RETENTION_DAYS days."
 else
   echo "Retention policy is activating..."
   if s3cmd expire s3://asagiri-backup --expiry-days="$RETENTION_DAYS" $S3_OPTS; then
      echo "Retention policy is successfully activated: $RETENTION_DAYS"
   else
      echo "[ERROR] Failed to set retention policy." >&2
   fi
 fi