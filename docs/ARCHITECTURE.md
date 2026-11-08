# Architecture

The stack runs on an Ubuntu/Debian cloud VM and observes MikroTik routers across a ZeroTier overlay. Only Nginx is published externally.

## Data flow

1. A MikroTik router exposes read-only SNMP on its ZeroTier address.
2. Prometheus asks `snmp-exporter` for metrics; the exporter performs the SNMP walk over the overlay.
3. Grafana reads Prometheus through the private Docker network.
4. Nginx publishes Grafana over HTTPS and terminates TLS.

Prometheus, SNMP exporter, and Grafana do not publish host ports. The only host bindings are loopback diagnostics for Prometheus and SNMP exporter, plus Nginx ports 80/443.

## Components

| Component | Role | Exposure |
| --- | --- | --- |
| Prometheus | Time-series storage and alert rules | `127.0.0.1:9090` only |
| SNMP exporter | SNMP-to-Prometheus translation | `127.0.0.1:9116` only |
| Grafana | Dashboards and visualization | Docker network only |
| Nginx | TLS reverse proxy | TCP 80/443 |
| mktxp | Optional RouterOS API exporter | `127.0.0.1:49090` only |

## Trust boundaries

ZeroTier is the router management/data plane. Do not configure public/WAN router addresses as Prometheus targets. The host firewall should allow inbound 80/443 only, and Docker's published loopback ports must not be re-published externally.
