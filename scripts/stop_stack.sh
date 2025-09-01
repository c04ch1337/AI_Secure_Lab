#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

echo "[*] Stopping services..."
docker compose down
