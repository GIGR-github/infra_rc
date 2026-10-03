#!/bin/bash
set -e
echo "::group::Get Swarm manager IP-address"
MANAGER_IP=$(terraform output -raw swarm_manager_ip)
if [ -z "$MANAGER_IP" ]; then
  echo "ERROR: TERRAFORM output of the <swarm_manager_ip> is empty"
  echo "::endgroup::"
  exit 1
fi
echo "SUCCESS: Manager IP-address: $MANAGER_IP"
echo "::endgroup::"
echo "::group::Assign manager IP-address to the repo scope variable"
gh variable set SWARM_MANAGER_IP --body "$MANAGER_IP"
echo "SUCCESS: Manager IP-address is saved to the <SWARM_MANAGER_IP> repo scope variable"
echo "SWARM_MANAGER_IP=$MANAGER_IP" >> "$GITHUB_ENV"
echo "::endgroup::"