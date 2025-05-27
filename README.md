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

- **DigitalOcean API Token** with the following exact required permissions:
    - **account**: read  
    - **droplet**: create, read, delete

    **Why these permissions are needed:**
    - `account:read`: Allows the script to fetch your account details, such as your list of SSH keys (so it can attach your key to the droplet for secure access).
    - `droplet:create`: Allows the script to create new droplets for use as exit nodes.
    - `droplet:read`: Allows the script to list and monitor droplets, check droplet status, and find droplets tagged as exit nodes for management.
    - `droplet:delete`: Allows the script to destroy exit node droplets when you run the cleanup script.

- **Tailscale Auth Key** that is *reusable* (generate from the [Tailscale admin console](https://login.tailscale.com/admin/settings/keys); check the box for "Reusable" when creating the key).

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

### Authorize the Exit Node

- **Important:**  
  After the droplet is created, you must authorize the new exit-node in the [Tailscale Admin Console](https://login.tailscale.com/admin/machines) before it can be used as an exit node.  
  Approve the machine and enable exit node functionality in the admin interface.

- **Note:**  
  It may take a few moments for the new droplet to appear in the Tailscale admin console after creation. If you don't see it immediately, wait and refresh the page.

---

## Enabling the Exit Node on Client Devices

After you have authorized the exit node in the Tailscale admin console, you can route your device’s internet traffic through it:

### Windows & macOS

1. Click the Tailscale icon in your system tray (Windows) or menu bar (macOS).
2. Click on your DigitalOcean exit node (e.g., `tailscale-exit-xxxx`).
3. Select **Use Exit Node** (it may be under a submenu or as a checkbox).
4. Your internet traffic will now be routed through the exit node.

### Linux

1. **List available exit nodes:**

        tailscale exit-node list

   This will display all available exit nodes in your network.

2. **Enable the exit node:**

        tailscale up --exit-node <exit-node-IP>

   Replace `<exit-node-hostname>` with the name shown from the list command (e.g., `tailscale-exit-172-16-0-1`).

3. **To stop using the exit node, run:**

        tailscale up --exit-node=

### iOS & Android

1. Open the Tailscale app.
2. Tap the menu or network settings.
3. Choose your DigitalOcean exit node and enable "Use exit node" or "Route all traffic".

---

## Verify

- After enabling the exit node, visit [https://www.whatismyip.com/](https://www.whatismyip.com/) or similar to confirm your public IP matches your DigitalOcean droplet.
- You can also check the node status in the [Tailscale Admin Console](https://login.tailscale.com/admin/machines).

---

## Destroy All Exit Node Droplets

Run:

    ./destroy-tailscale-exit-nodes.sh

- This script deletes all droplets tagged with `tailscale-exit`.

---

## Troubleshooting

- **Droplet creation fails:**  
  Ensure your API token and environment variables are valid. Check script output for HTTP errors.
- **Tailscale node doesn’t appear:**  
  Confirm your Tailscale auth key is set to reusable.
- **No network connectivity through exit node:**  
  Ensure IP forwarding and NAT are enabled (the script handles this automatically).
- **Cannot select as exit node:**  
  Make sure you have authorized the new machine and enabled it as an exit node in the Tailscale admin console.
- **Exit node not visible immediately:**  
  New nodes may take a minute to show up in the admin console after creation.

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
