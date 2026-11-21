#!/usr/bin/env bash
# ============================================================================
# ZK-VPS-PANEL · Interactive Frontend Demo Runner (GitHub Codespaces Ready)
# ============================================================================
# Launches ZK-VPS-PANEL in Frontend Demo / Sandbox Mode (DEMO_MODE=true).
# - All UI pages, forms, charts, web console, SFTP file manager, and actions
#   work interactively in the browser.
# - No real LXD daemon, root privileges, or container backend is required.
# - For real production LXD deployment, use: sudo bash install.sh
# ============================================================================
set -euo pipefail

cd "$(dirname "$0")"

export PANEL_NAME="${PANEL_NAME:-ZK-VPS-PANEL}"
export PANEL_VERSION="${PANEL_VERSION:-2.0}"
export PANEL_DEVELOPER="${PANEL_DEVELOPER:-ZK-VPS-PANEL}"
export DEMO_MODE="true"
export HOST="${HOST:-0.0.0.0}"
export PORT="${PORT:-5000}"
export DATABASE_PATH="${DATABASE_PATH:-zk_demo.db}"
export MAIN_ADMIN_USERNAME="${MAIN_ADMIN_USERNAME:-admin}"
export MAIN_ADMIN_PASSWORD="${MAIN_ADMIN_PASSWORD:-admin123}"
export MAIN_ADMIN_EMAIL="${MAIN_ADMIN_EMAIL:-admin@zk-vps.local}"

echo "=================================================================="
echo "  🚀 Starting ${PANEL_NAME} (Interactive Frontend Demo Mode)"
echo "=================================================================="

# 1. Prepare Python virtual environment
VENV_DIR=".venv"
if [[ ! -x "$VENV_DIR/bin/python" ]]; then
    echo "[1/3] Creating Python virtual environment in ${VENV_DIR}..."
    python3 -m venv "$VENV_DIR"
fi

echo "[2/3] Ensuring Python dependencies are installed..."
"$VENV_DIR/bin/pip" install --quiet --upgrade pip
"$VENV_DIR/bin/pip" install --quiet -r requirements.txt

# 2. Seed rich demo data so the frontend UI is immediately populated
echo "[3/3] Initializing demo database (${DATABASE_PATH}) with sample nodes & servers..."
"$VENV_DIR/bin/python" - <<'PYEOF'
import json
import os
import secrets
from datetime import datetime, timedelta
from werkzeug.security import generate_password_hash
import nrb

nrb.init_db()

now = datetime.now().isoformat()
exp_30d = (datetime.now() + timedelta(days=30)).isoformat()
exp_5d = (datetime.now() + timedelta(days=5)).isoformat()

with nrb.get_db() as conn:
    cur = conn.cursor()

    # Ensure demo client user exists
    cur.execute("SELECT id FROM users WHERE username = ?", ("demo",))
    if not cur.fetchone():
        cur.execute(
            """INSERT INTO users (username, email, password_hash, is_admin, is_main_admin, created_at, api_key)
               VALUES (?, ?, ?, 0, 0, ?, ?)""",
            ("demo", "demo@zk-vps.local", generate_password_hash("demo123"), now, f"zk_demo_{secrets.token_hex(16)}")
        )

    # Seed cluster nodes if empty
    cur.execute("SELECT COUNT(*) FROM nodes")
    if cur.fetchone()[0] == 0:
        nodes_seed = [
            ("ZK-Core-EU-Frankfurt", "Frankfurt, DE", 100, 2, 1, "active", "http://127.0.0.1:5001"),
            ("ZK-Core-US-East", "Ashburn, US", 80, 1, 0, "active", "http://198.51.100.12:5001"),
            ("ZK-Core-AP-Singapore", "Singapore, SG", 60, 1, 0, "active", "http://203.0.113.45:5001"),
        ]
        for name, loc, total_v, used_v, is_local, status, url in nodes_seed:
            cur.execute(
                """INSERT INTO nodes (name, location, total_vps, used_vps, is_local, status, url, api_key, created_at, updated_at)
                   VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)""",
                (name, loc, total_v, used_v, is_local, status, url, secrets.token_urlsafe(24), now, now)
            )

    # Seed demo VPS instances if empty
    cur.execute("SELECT COUNT(*) FROM vps")
    if cur.fetchone()[0] == 0:
        cur.execute("SELECT id FROM nodes ORDER BY id ASC")
        node_ids = [r[0] for r in cur.fetchall()] or [1]
        n1 = node_ids[0]
        n2 = node_ids[1] if len(node_ids) > 1 else n1
        n3 = node_ids[2] if len(node_ids) > 2 else n1

        vps_seed = [
            (1, n1, "zk-vps-101", "prod-api-gateway.zkcloud.io", "ubuntu:24.04", "4", "4096", "80", "10.108.14.21", "running", 0, None, exp_30d, 30, 1),
            (1, n1, "zk-vps-102", "db-cluster-primary.zkcloud.io", "images:debian/12", "8", "8192", "160", "10.108.14.22", "running", 0, None, exp_30d, 30, 1),
            (1, n2, "zk-vps-103", "edge-cache-worker.zkcloud.io", "ubuntu:22.04", "2", "2048", "40", "10.108.14.23", "stopped", 0, None, exp_5d, 7, 1),
            (1, n3, "zk-vps-104", "staging-sandbox.zkcloud.io", "ubuntu:22.04", "2", "2048", "30", "10.108.14.24", "stopped", 1, "Demo scheduled maintenance hold", exp_30d, 30, 0),
        ]
        for uid, nid, cname, hname, osv, cpu, ram, disk, ip, st, susp, reason, exp, exp_days, auto_s in vps_seed:
            meta = json.dumps({"ssh_password_encrypted": nrb.encrypt_vps_ssh_password("ZkCloudDemo#2026")})
            cur.execute(
                """INSERT INTO vps (
                    user_id, node_id, container_name, hostname, os_version,
                    cpu, ram, storage, config, ip_address, status,
                    suspended, suspended_reason, expires_at, expiration_days,
                    auto_suspend_enabled, metadata, created_at, updated_at
                ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, '{}', ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)""",
                (uid, nid, cname, hname, osv, cpu, ram, disk, ip, st, susp, reason, exp, exp_days, auto_s, meta, now, now)
            )

        # Seed sample port allocations & forwards
        cur.execute(
            """INSERT OR REPLACE INTO port_allocations (user_id, allocated_ports, used_ports, updated_at)
               VALUES (1, 20, 2, ?)""",
            (now,)
        )
        cur.execute(
            """INSERT INTO port_forwards (user_id, vps_container, vps_port, host_port, protocol, description, created_at)
               VALUES (?, ?, ?, ?, ?, ?, ?)""",
            (1, "zk-vps-101", 22, 22101, "tcp", "SSH Management Access", now)
        )
        cur.execute(
            """INSERT INTO port_forwards (user_id, vps_container, vps_port, host_port, protocol, description, created_at)
               VALUES (?, ?, ?, ?, ?, ?, ?)""",
            (1, "zk-vps-101", 443, 30443, "tcp", "HTTPS Public Gateway", now)
        )

        # Seed welcome notification
        cur.execute(
            """INSERT INTO notifications (user_id, type, title, message, read, created_at)
               VALUES (?, 'info', 'Welcome to ZK-VPS-PANEL Demo Mode',
                       'Interactive frontend sandbox is active. All UI controls, SFTP explorer, and web terminal are simulated.', 0, ?)""",
            (1, now)
        )
PYEOF

# If running in GitHub Codespaces, auto-configure port visibility hint
if [[ -n "${CODESPACE_NAME:-}" ]]; then
    DOMAIN="${GITHUB_CODESPACES_PORT_FORWARDING_DOMAIN:-app.github.dev}"
    echo ""
    echo "🌐 GitHub Codespaces Detected!"
    echo "   Preview URL: https://${CODESPACE_NAME}-${PORT}.${DOMAIN}"
fi

echo ""
echo "=================================================================="
echo "  ✅ ${PANEL_NAME} Demo Ready on http://localhost:${PORT}"
echo "  🔑 Admin Login : ${MAIN_ADMIN_USERNAME} / ${MAIN_ADMIN_PASSWORD}"
echo "  👤 Client Login: demo / demo123"
echo "  ℹ️  Mode        : DEMO_MODE=true (Frontend works, no LXD required)"
echo "=================================================================="
echo ""

exec "$VENV_DIR/bin/python" nrb.py
