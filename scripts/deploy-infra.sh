#!/bin/bash
set -e
echo "::group::Initializing Terraform"
terraform init -input=false
echo "SUCCESS: Terraform is initialized"
echo "::endgroup::"
echo "::group::Deploying infra for ${TARGET_ENV} env"
terraform apply \
      -var-file="$TARGET_ENV_TF" \
      -lock-timeout=20m \
      -input=false \
      -auto-approve \
echo "SUCCESS: Infrastructure is deployed"
echo "::endgroup::"
