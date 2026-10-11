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