#!/bin/bash
# ==============================================================================
# RUNTIME ENTRYPOINT: Secure Database Bootstrapping & Secret Injection Script
# PROCESS TYPE:       Infrastructure Provisioning & Secret Hydration
# METADATA:           Ticket:   [JIRA-4025] Database Infrastructure Hardening
#                     Date:     2026-07-03
#                     Author:   Pavel P. <ppanbeing@redcoast.com>
# ==============================================================================
# DESCRIPTION:
#   Intercepts the standard container startup lifecycle to securely extract cluster-level
#   Docker Secrets (mounted as files) and interpolate them into the static 'init.sql'
#   template. Hands over execution control to the official MySQL binary after setup.
#
# ARCHITECTURE, SECURITY & RELIABILITY DESIGN NOTES:
#   - Fail-Fast Enforcement (set -e): Activates strict shell execution boundaries.
#     Any non-zero exit status during file reading or template processing instantly
#     terminates the container, preventing partial or insecure DB initialization.
#   - Production Secret Decryption: Avoids exposing root/application credentials
#     via standard plaintext environment variables. Reads passwords directly from
#     the secure, encrypted Docker Swarm in-memory mount path ('/run/secrets/*').
#   - Safe Templating Engine (sed Stream Isolation): Reads the pristine template
#     from a read-only location ('/tmp/init.sql') and streams the parsed values
#     directly into the official automated initialization directory
#     ('/docker-entrypoint-initdb.d/'). This layout guarantees zero modification
#     to the master reference file.
#   - Process Hijacking (exec Paradigm): Uses the standard Linux 'exec' command
#     to replace the wrapper bash shell process with the native MySQL engine process
#     (PID 1). This ensures proper Unix signal propagation (e.g., SIGTERM, SIGKILL)
#     for graceful cluster shutdowns and container lifecycles.
# ==============================================================================
set +e
if [ ! -s /run/secrets/db_password ] || [ ! -s /run/secrets/db_root_password ] || [ ! -s /run/secrets/flyway_password ]; then
    echo "Secret files is not exists or empty, container will be restarted" >&2
    exit 1
fi
DB_PASSWORD=$(cat /run/secrets/db_password)
FLYWAY_PASSWORD=$(cat /run/secrets/flyway_password)
MYSQL_ROOT_PASSWORD=$(cat /run/secrets/db_root_password)
export MYSQL_ROOT_PASSWORD
set -e
sed -e "s/\${MYSQL_DATABASE}/$MYSQL_DATABASE/g" \
    -e "s/\${FLYWAY_USER}/$FLYWAY_USER/g" \
    -e "s/\${FLYWAY_PASSWORD}/$FLYWAY_PASSWORD/g" \
    -e "s/\${DB_USERNAME}/$MYSQL_USER/g" \
    -e "s/\${DB_PASSWORD}/$DB_PASSWORD/g" \
    /tmp/init.sql > /docker-entrypoint-initdb.d/init.sql
exec /usr/local/bin/docker-entrypoint.sh mysqld
