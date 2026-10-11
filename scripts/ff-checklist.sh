#!/bin/bash
set -e
if [[ -z "$TARGET_ENV" ]]; then
  echo "ERROR: <TARGET_ENV> is missing"
  exit 1
fi
if [[ -z "$TARGET_ENV_TF" ]]; then
  echo "ERROR: <TARGET_ENV_TF> is missing"
  exit 1
fi
if [[ "$HAS_SSH_PUBLIC_KEY" != "true" ]]; then
  echo "ERROR: <SSH_PUBLIC_KEY> is missing"
  exit 1
fi
if [[ "$HAS_SSH_PRIVATE_KEY" != "true" ]]; then
  echo "ERROR: <PERSONAL_VAR_TOKEN> PAT is missing"
  exit 1
fi
if [[ "$HAS_GH_TOKEN" != "true" ]]; then
  echo "ERROR: <PERSONAL_VAR_TOKEN> PAT is missing"
  exit 1
fi
if [[ "$HAS_DB_PASSWORD" != "true" || "$DB_ROOT_PASSWORD" != "true" || "$FLYWAY_PASSWORD" != "true" ]]; then
  echo "ERROR:  Critical database variables are missing"
  exit 1
fi