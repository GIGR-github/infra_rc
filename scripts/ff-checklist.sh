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
if [[ "$HAS_SSH_PUBLIC_KEY" != "True" ]]; then
  echo "ERROR: <SSH_PUBLIC_KEY> is missing"
  exit 1
fi
if [[ "$HAS_SSH_PRIVATE_KEY" != "True" ]]; then
  echo "ERROR: <PERSONAL_VAR_TOKEN> PAT is missing"
  exit 1
fi
if [[ "$HAS_GH_TOKEN" != "True" ]]; then
  echo "ERROR: <PERSONAL_VAR_TOKEN> PAT is missing"
  exit 1
fi
if [[ "$HAS_DB_PASSWORD" != "True" || "$HAS_DB_ROOT_PASSWORD" != "True" || "$HAS_FLYWAY_PASSWORD" != "True" ]]; then
  echo "ERROR:  Critical database variables are missing"
  exit 1
fi