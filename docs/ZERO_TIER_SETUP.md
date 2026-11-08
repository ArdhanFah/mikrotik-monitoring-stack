# ZeroTier Setup

## Phase 1: Host foundation

Install Docker Engine and the Compose plugin on a supported Ubuntu/Debian VM. Create a dedicated deployment directory and restrict `.env` and TLS private keys to the deployment account.

## Phase 2: Overlay

1. Install ZeroTier on the VM and put the 16-character Network ID in `.env` as `ZEROTIER_NETWORK_ID`.
2. Join the ZeroTier network on the VM with `sudo zerotier-cli join "$ZEROTIER_NETWORK_ID"`.
3. Authorize the VM and each MikroTik member in ZeroTier Central.
4. Assign stable addresses from the overlay, for example `10.147.20.0/24`.
5. Confirm the VM can reach each router's ZeroTier address, while the router cannot be reached through its public interface for monitoring.

## Phase 3: Router security

Edit `mikrotik/setup-firewall-snmp.rsc`, replacing the community placeholder. Import it on each router after reviewing existing firewall ordering. SNMP is restricted to the monitoring subnet and is read-only.

## Phase 4: Monitoring

Copy `.env.example` to `.env`, set the ZeroTier Network ID, router target, and secrets. Apply the target and community to the static config files as documented in `README.md`, then deploy with `docker compose up -d`.

## Phase 5: HTTPS operations

Place a valid certificate and key at `nginx/certs/fullchain.pem` and `nginx/certs/privkey.pem`, or adapt the Nginx volume to your certificate automation. Set DNS for `GRAFANA_DOMAIN` to the VM. Verify the HTTP-to-HTTPS redirect, then complete the Grafana admin login.

Useful checks:

```bash
docker compose ps
docker compose logs --tail=100 prometheus snmp-exporter grafana nginx
curl -fsS http://127.0.0.1:9090/-/ready
curl -kI https://monitoring.example.com/
```
