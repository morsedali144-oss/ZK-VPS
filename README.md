# ZK-VPS-PANEL · Next-Generation Dark Blue SaaS VPS Orchestration Panel

**ZK-VPS-PANEL** is an enterprise-grade, multi-node LXD Virtual Private Server (VPS) management and cloud orchestration panel featuring a custom-crafted dark-blue SaaS interface, real-time telemetry, interactive Xterm.js web console, SFTP file manager, NAT port forwarding, snapshots, backups, and REST API v1.

## Highlights

- **Modern Dark-Blue SaaS UI**: Crafted from scratch with deep obsidian-navy surfaces (`#040812` / `#070d19`), cobalt-to-cyan blue gradients (`#2563eb` -> `#0ea5e9`), responsive grids, and real-time Chart.js resource visualizations.
- **GitHub Codespaces & Frontend Demo Mode (`demo.sh`)**:
  - Run `bash demo.sh` in GitHub Codespaces or any local terminal without LXD or root privileges.
  - Pre-seeds sample cluster nodes, virtual servers, port forwards, and an in-memory SFTP filesystem & interactive web shell so the entire frontend works out-of-the-box.
- **Full Production LXD Backend (`install.sh` / `start.sh`)**:
  - Real container provisioning (Ubuntu & Debian LTS images) via LXD
  - Live CPU, RAM, NVMe storage, and network bandwidth controls
  - Interactive Web Terminal (`Xterm.js` + Socket.IO) & one-click SSH provisioning
  - Integrated browser SFTP File Manager (browse, upload, download, rename, mkdir, delete)
  - Dynamic NAT TCP/UDP Port Forwarding with per-user port quotas
  - Server Expiration & Auto-Suspension lifecycle management
  - Multi-Node Cluster support (`node.py` remote agent) and REST API v1 (`api.py`)

## 1. Run Interactive Frontend Demo (GitHub Codespaces)

```bash
bash demo.sh
```

- **Admin Login**: `admin` / `admin123`
- **Client Login**: `demo` / `demo123`

## 2. Real Production Installation (Ubuntu / Debian Host with LXD)

```bash
sudo bash install.sh --install
```

## Running Tests

```bash
PYTHONPATH=. .venv/bin/pytest -q
```
