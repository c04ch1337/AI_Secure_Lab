#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

if [ ! -f ".env" ]; then
  echo "[!] Missing .env. Copy .env.example to .env and customize."
  exit 1
fi

echo "[*] Starting services..."
docker compose up -d --build

echo "[*] Health checks..."
sleep 3
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
