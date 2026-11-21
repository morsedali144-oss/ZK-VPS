# ZK-VPS-PANEL · Next-Generation Dark Blue SaaS VPS Orchestration Panel

**ZK-VPS-PANEL** is an enterprise-grade, multi-node LXD Virtual Private Server (VPS) management and cloud orchestration panel featuring a custom-crafted dark-blue SaaS interface, real-time telemetry, interactive Xterm.js web console, SFTP file manager, NAT port forwarding, snapshots, backups, and REST API v1.

## Highlights

- **Modern Dark-Blue SaaS UI**: Crafted from scratch with deep obsidian-navy surfaces (`#040812` / `#070d19`), cobalt-to-cyan blue gradients (`#2563eb` -> `#0ea5e9`), responsive grids, and real-time Chart.js resource visualizations.
- **Complete LXD Virtualization Backend**:
  - Instant container provisioning (Ubuntu & Debian LTS images)
  - Live CPU, RAM, NVMe storage, and network bandwidth controls
  - Interactive Web Terminal (`Xterm.js` + Socket.IO) & one-click SSH provisioning
  - Integrated browser SFTP File Manager (browse, upload, download, rename, mkdir, delete)
  - Point-in-time Snapshots, Full Container Backups, and Firewall Rules
  - Dynamic NAT TCP/UDP Port Forwarding with per-user port quotas
  - Server Expiration & Auto-Suspension lifecycle management
  - Multi-Node Cluster support (`node.py` remote agent) and REST API v1 (`api.py`)

## Quick Start

```bash
export MAIN_ADMIN_USERNAME="admin"
export MAIN_ADMIN_PASSWORD="StrongPassword123!"
export MAIN_ADMIN_EMAIL="admin@zk-vps.local"
export PANEL_NAME="ZK-VPS-PANEL"

python3 -m venv .venv
.venv/bin/pip install -r requirements.txt
.venv/bin/python nrb.py
```

## Running Tests

```bash
.venv/bin/pytest -q
```
