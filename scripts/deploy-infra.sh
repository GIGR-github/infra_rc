#!/bin/bash
set -e
echo "::group::Initializing Terraform"
terraform init
echo "SUCCESS: Terraform is initialized"
echo "::endgroup::"
echo "::group::Deploying infra for staging env"
TF_VAR_ssh_public_key="$SSH_PUBLIC_KEY" terraform apply -var-file="$TARGET_ENV_TF" -auto-approve
echo "SUCCESS: Infrastructure is deployed"
echo "::endgroup::"
