# MikroTik Monitoring Stack

Docker Compose stack for monitoring remote MikroTik routers through a ZeroTier overlay with Prometheus, SNMP exporter, Grafana, and an Nginx HTTPS reverse proxy.

## Phase 1-5 initialization

1. **Foundation:** install Docker and prepare the VM.
2. **Overlay:** join ZeroTier and authorize stable router/VM addresses.
3. **Router security:** apply the read-only SNMP and firewall script.
4. **Observability:** configure Prometheus, alerts, Grafana provisioning, and dashboards.
5. **Ingress and operations:** install TLS certificates, publish Nginx only, and verify health.

## Quick start

```bash
cp .env.example .env
chmod 600 .env
# Edit .env, then replace the matching placeholders in the configuration files.
docker compose config
docker compose up -d
docker compose ps
```

## Mengisi nilai `CHANGE_ME`

Edit `.env` dan isi:

- `GRAFANA_ADMIN_PASSWORD`: password admin Grafana yang panjang dan acak.
- `GRAFANA_DOMAIN`: domain yang mengarah ke IP publik VM.
- `ZEROTIER_NETWORK_ID`: Network ID 16 karakter hexadecimal dari ZeroTier Central, bukan subnet.
- `MIKROTIK_SNMP_TARGET`: alamat IP ZeroTier router, misalnya `10.147.20.1`.
- `SNMP_COMMUNITY`: community SNMP yang sama dengan konfigurasi router.

Nilai SNMP dan target juga perlu diterapkan ke file konfigurasi karena Prometheus dan SNMP exporter membaca file konfigurasi statis:

```bash
sed -i "s/10\.147\.20\.1/${MIKROTIK_SNMP_TARGET}/g" prometheus/prometheus.yml exporters/mktxp/mktxp.conf
sed -i "s/CHANGE_ME_snmp_community/${SNMP_COMMUNITY}/g" exporters/snmp/snmp.yml mikrotik/setup-firewall-snmp.rsc
```

Jalankan perintah tersebut setelah `.env` diload dengan `set -a; . ./.env; set +a`.

## ZeroTier Network ID

ZeroTier diinstal dan dijalankan di host VM. Tidak perlu menambahkan container ZeroTier ke Compose. Setelah mengisi `.env`:

```bash
set -a; . ./.env; set +a
sudo zerotier-cli join "$ZEROTIER_NETWORK_ID"
```

Authorize member VM di ZeroTier Central, lalu pastikan router dan VM mendapat alamat pada `ZEROTIER_NETWORK`. Compose menggunakan koneksi jaringan host ke overlay tersebut untuk mengakses alamat router.

The stack requires TLS files at `nginx/certs/fullchain.pem` and `nginx/certs/privkey.pem` before Nginx can start. Keep those files out of version control. The mktxp service is disabled by default; enable it with `docker compose --profile mktxp up -d` only when RouterOS API monitoring is required.

See `docs/ARCHITECTURE.md` and `docs/ZERO_TIER_SETUP.md` for deployment and security details.

## Visual assets

- `docs/mikrotik-monitoring-architecture.drawio`: import directly into [diagrams.net](https://app.diagrams.net/) with **File > Import From > Device**.
- `assets/mikrotik-monitoring-banner.svg`: website-ready banner. Use it as an `<img>` or as a CSS background; it scales without pixelation.
