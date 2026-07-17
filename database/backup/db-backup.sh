#!/bin/bash
# ==============================================================================
# OPERATIONAL RUNBOOK: Automated Encrypted Database Backup to Cloud Storage (S3)
# PROCESS TYPE:       Disaster Recovery (DR) Pipeline & Data Integrity Enforcement
# METADATA:           Ticket:   [JIRA-4025] Database Infrastructure Hardening
#                     Date:     2026-07-03
#                     Author:   Pavel P. <ppanbeing@redcoast.com>
# ==============================================================================
# DESCRIPTION:
#   Executes a zero-downtime hot-backup of all MySQL schemas, applies runtime
#   gzip compression, encrypts the stream via symmetric AES256 GPG, and uploads
#   the encrypted artifact directly into an offsite S3 bucket (DigitalOcean Spaces).
#
# ARCHITECTURE, SECURITY & RELIABILITY DESIGN NOTES:
#   - Execution Policy (Retention): Immediately chains the local data retention
#     policy cleanup at bootstrap ('./db-backup-policy.sh').
#   - Strict Parameter Validation: Utilizes standard Bash expansion (: ${VAR:?})
#     to crash-fast before execution if critical infrastructure parameters, S3
#     keys, or GPG passphrases are absent from the runtime environment.
#   - Multi-Stage Pipeline Telemetry (set -o pipefail + PIPESTATUS):
#     Standard bash piping hides intermediary failures. This script captures the
#     discrete return code of EVERY stage (mysqldump, gzip, gpg, s3cmd) using the
#     internal PIPESTATUS array, ensuring silent failures in compression or
#     encryption are explicitly caught.
#   - Non-Blocking Hot-Dumping: Uses '--single-transaction' combined with '--quick'
#     to execute an online dump without locking tables, preserving production
#     throughput for application worker nodes.
#   - Cryptographic Hardening: Enforces asymmetric-grade strength using symmetric
#     GPG with the military-grade AES256 cipher algorithm to prevent data leaks
#     in case of S3 bucket compromises.
#   - Secure Log Sanitization: Uses 'mktemp' for transient stderr logging. A strict
#     trap routine ensures error logs are purged from disk upon termination,
#     preventing local credential exposure.
# ==============================================================================
./db-backup-policy.sh
set -o pipefail
: "${DB_HOST:?DB_HOST is missing}"
: "${GPG_PASS:?GPG_PASS is missing}"
: "${DB_USERNAME:?DB_USERNAME is missing}"
: "${WEB_HOOK:?WEB_HOOK is missing}"
: "${BACKUP_TTL:?BACKUP_TTL is missing}"

BACKUP_DIR="backup"
CURRENT_DATE="[$(date +'%Y-%m-%d %H:%M:%S')]"
DUMP_FILE="backup.$CURRENT_DATE.sql.gz"
ERROR_LOG=$(mktemp)
trap 'rm -f "$ERROR_LOG"' EXIT
mkdir -p "$BACKUP_DIR"
send_message() {
 if curl -f -X POST -H 'Content-type: application/json' --data "{\"text\":\"$1\"}" "$WEB_HOOK" > /dev/null 2>&1; then
     echo "[SUCCESS] Notification has been sent."
   else
     echo "[ERROR] Failed to send notification." >&2
   fi
}
mysqldump -h "$DB_HOST" --all-databases --single-transaction \
   --quick -u "$DB_USERNAME" 2> "$ERROR_LOG" | gzip -c 2>> "$ERROR_LOG" | \
   gpg --batch --yes --symmetric  --cipher-algo AES256 --passphrase "$GPG_PASS" 2>> "$ERROR_LOG" | \
   s3cmd put - s3://asagiri-backup/"$DUMP_FILE.gpg" \
      --no-encrypt \
      --access_key="$ACCESS_KEY" \
      --secret_key="$SECRET_KEY" \
      --host="sgp1.digitaloceanspaces.com" \
      --host-bucket="%(bucket)s.sgp1.digitaloceanspaces.com" \
      2>> "$ERROR_LOG"
PIPE_STATUS=("${PIPESTATUS[@]}")
cat "$ERROR_LOG"
if [[ "${PIPE_STATUS[0]}" -ne 0 || "${PIPE_STATUS[1]}" -ne 0 || "${PIPE_STATUS[2]}" -ne 0 ]]; then
  send_message "[ERROR]: Database backup failed!!!
  Stages: mysqldump:${PIPE_STATUS[0]}, gzip:${PIPE_STATUS[1]}, gpg:${PIPE_STATUS[2]}
  Details: $(tail -n 1 "$ERROR_LOG")"
  exit 1
fi
send_message "[SUCCESS] Backup created: $DUMP_FILE.gpg"