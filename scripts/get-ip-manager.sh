#!/bin/bash
set -e
echo "::group::Get Swarm manager IP-address"
MANAGER_IP=$(terraform output -raw swarm_manager_ip)
if [ -z "$MANAGER_IP" ]; then
  echo "ERROR: TERRAFORM output of the <swarm_manager_ip> is empty"
  echo "::endgroup::"
  exit 1
fi
STAGE_ENV="${TARGET_ENV}_MANAGER_IP"
echo "SUCCESS: Manager IP-address: $MANAGER_IP"
echo "::endgroup::"
echo "::group::Assign manager IP-address to the repo scope variable"
gh variable set "$STAGE_ENV" --body "$MANAGER_IP"
echo "SUCCESS: Manager IP-address is saved to the <$STAGE_ENV> repo scope variable"
echo "$STAGE_ENV=$MANAGER_IP" >> "$GITHUB_ENV"
echo "::endgroup::"