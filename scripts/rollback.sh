#!/bin/bash
set -e
if [ ! -f "terraform.tfstate" ]; then
  cho "ERROR: Terraform state is not found"
else
  TF_VAR_ssh_public_key="$SSH_PUBLIC_KEY" terraform destroy -var-file="$TARGET_ENV_TF" -auto-approve
  echo "SUCCESS: Infra was cleaned"
fi