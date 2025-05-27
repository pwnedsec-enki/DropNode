#!/bin/bash
set -e
set -o pipefail

# Load environment variables
source .env

NAME="tailscale-exit-$(date +%s)"
TAGS='["tailscale-exit"]'

# Prepare cloud-init user_data with proper JSON escaping
USER_DATA=$(cat <<EOF | jq -Rs .
#cloud-config
runcmd:
  - curl -fsSL https://tailscale.com/install.sh | sh
  - sysctl -w net.ipv4.ip_forward=1
  - iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
  - tailscale up --authkey ${TAILSCALE_AUTHKEY} --advertise-exit-node --ssh
EOF
)

echo "[+] Creating droplet: $NAME"

HTTP_RESPONSE=$(curl -w "HTTPSTATUS:%{http_code}" -s -X POST "https://api.digitalocean.com/v2/droplets" \
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
  "user_data": $USER_DATA,
  "tags": $TAGS
}
EOF
)

# Extract HTTP status code and body
HTTP_BODY=$(echo "$HTTP_RESPONSE" | sed -e 's/HTTPSTATUS\:.*//g')
HTTP_STATUS=$(echo "$HTTP_RESPONSE" | tr -d '\n' | sed -e 's/.*HTTPSTATUS://')

if [ "$HTTP_STATUS" -ne 202 ]; then
  echo "[-] Droplet creation failed with status code $HTTP_STATUS"
  echo "Response body:"
  echo "$HTTP_BODY"
  exit 1
fi

echo "[+] Droplet created successfully:"
echo "$HTTP_BODY" | jq .
