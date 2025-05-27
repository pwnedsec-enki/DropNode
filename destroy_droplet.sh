#!/bin/bash
set -e

# Load environment variables
source .env

echo "[+] Fetching Tailscale-exit droplets to delete..."
DROPLET_IDS=$(curl -s -H "Authorization: Bearer $DO_API_TOKEN" \
  "https://api.digitalocean.com/v2/droplets?tag_name=tailscale-exit" | \
  jq -r '.droplets[].id')

for ID in $DROPLET_IDS; do
  echo "[+] Deleting droplet ID: $ID"
  curl -s -X DELETE -H "Authorization: Bearer $DO_API_TOKEN" \
    "https://api.digitalocean.com/v2/droplets/$ID"
done

echo "[+] Cleanup complete."
