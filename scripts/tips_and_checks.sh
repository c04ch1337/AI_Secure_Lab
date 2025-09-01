#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

echo "== Docker =="
docker --version || true
docker compose version || true

echo "== NVIDIA =="
nvidia-smi || echo "nvidia-smi not available; likely CPU-only."
which nvidia-ctk || echo "nvidia-ctk not installed."

echo "== Ports =="
ss -tulpn | awk 'NR==1 || /:8080|:8081|:8082|:11434/ {print}'
