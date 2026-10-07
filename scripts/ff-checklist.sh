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
if [[ -z "$SSH_PUBLIC_KEY" ]]; then
  echo "ERROR: <SSH_PUBLIC_KEY> is missing"
  exit 1
fi
if [[ -z "$SSH_PRIVATE_KEY" ]]; then
  echo "ERROR: <PERSONAL_VAR_TOKEN> PAT is missing"
  exit 1
fi
if [[ -z "$GH_TOKEN" ]]; then
  echo "ERROR: <PERSONAL_VAR_TOKEN> PAT is missing"
  exit 1
fi
if [[ -z "$DB_PASSWORD" || -z "$DB_ROOT_PASSWORD" || -z "$FLYWAY_PASSWORD" ]]; then
  echo "ERROR:  Critical variables are missing"
  exit 1
fi