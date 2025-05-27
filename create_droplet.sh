#!/bin/bash
set -e

# Load environment variables
source .env

NAME="tailscale-exit-$(date +%s)"
TAGS='["tailscale-exit"]'

# Create cloud-init script for Tailscale
USER_DATA=$(cat <<EOF
#cloud-config
runcmd:
  - curl -fsSL https://tailscale.com/install.sh | sh
  - tailscale up --authkey ${TAILSCALE_AUTHKEY} --advertise-exit-node --ssh
EOF
)

# Create the droplet
echo "[+] Creating droplet: $NAME"
RESPONSE=$(curl -sX POST "https://api.digitalocean.com/v2/droplets" \
  -H "Authorization: Bearer $DO_API_TOKEN" \
  -H "Content-Type: application/json" \
  -d @- <<EOF
{
  "name": "$NAME",
  "region": "$REGION",
  "size": "$SIZE",
  "image": "$IMAGE",
  "ssh_keys": [$SSH_KEY_ID],
  "backups": false,
  "ipv6": false,
  "user_data": "$USER_DATA",
  "tags": $TAGS
}
EOF
)

echo "[+] Droplet creation request sent. Response:"
echo "$RESPONSE" | jq .
