# Tailscale DigitalOcean Exit Node Automation

This repository contains scripts to automate creating and destroying DigitalOcean droplets configured as Tailscale exit nodes. These droplets allow you to route your Tailscale network traffic through a DigitalOcean VPS, effectively creating an exit node in your Tailscale mesh.

---

## Features

- **Automated Droplet Creation:** Create DigitalOcean droplets preconfigured with Tailscale as an exit node.
- **IP Forwarding & NAT:** Automatically enables IP forwarding and NAT for proper routing.
- **Unattended Registration:** Uses reusable Tailscale auth keys for hands-free node registration.
- **Easy Management:** Tags droplets as `tailscale-exit` for simple identification and management.
- **Cleanup Script:** Quickly destroy all droplets tagged `tailscale-exit` with a single command.

---

## Prerequisites

- **DigitalOcean API Token** with droplet creation and deletion rights.
- **Tailscale Auth Key** (reusable, pre-approved; generate from the [Tailscale admin console](https://login.tailscale.com/admin/settings/keys)).
- **SSH Public Key** uploaded to DigitalOcean and its ID (optional but recommended).
- **Installed Tools:**
  - `curl`
  - `jq`
  - `bash`

---

## Setup

1. **Clone the repository:**

    git clone https://github.com/pwnedsec-enki/Tailscale-DO-ExitNode.git
    cd Tailscale-DO-ExitNode

2. **Configure environment variables:**

    Create a `.env` file in the repository root with the following content:

        DO_API_TOKEN="your_digitalocean_api_token"
        TAILSCALE_AUTHKEY="tskey-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
        SSH_KEY_ID="1234567"            # Optional: your DigitalOcean SSH key ID
        REGION="nyc3"                   # Choose your preferred DigitalOcean region
        IMAGE="ubuntu-22-04-x64"        # Droplet image slug
        SIZE="s-1vcpu-1gb"              # Droplet size

    > **Note:** `.env` is included in `.gitignore` to keep your secrets safe.

---

## Usage

### Create a Tailscale Exit Node Droplet

Run:

    ./create-tailscale-exit-node.sh

- This script creates a new DigitalOcean droplet.
- The droplet will install Tailscale, enable IP forwarding & NAT, and join your Tailscale network advertising itself as an exit node.
- Droplets are tagged `tailscale-exit` and named like `tailscale-exit-<timestamp>`.

### Verify

- Check the [Tailscale Admin Console](https://login.tailscale.com/admin/machines) to confirm the node is connected and visible as an exit node.
- You can now route your device traffic through this exit node as needed.

### Destroy All Exit Node Droplets

Run:

    ./destroy-tailscale-exit-nodes.sh

- This script deletes all droplets tagged with `tailscale-exit`.

---

## Troubleshooting

- **Droplet creation fails:**  
  Ensure your API token and environment variables are valid. Check script output for HTTP errors.
- **Tailscale node doesn’t appear:**  
  Confirm your Tailscale auth key is reusable and preapproved.
- **No network connectivity through exit node:**  
  Ensure IP forwarding and NAT are enabled (the script handles this automatically).

---

## Security & Costs

- Keep your `.env` file secret and secure.
- Only use reusable Tailscale auth keys on trusted environments.
- Destroy droplets when not in use to avoid unnecessary billing.
- **Typical cost:** ~$0.17 per droplet per day (for `s-1vcpu-1gb`).

---

## License

[MIT License](LICENSE)

---

## Acknowledgments

- [Tailscale](https://tailscale.com/)
- [DigitalOcean](https://digitalocean.com/)
