#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'
docker compose logs -f --tail=200 "${1:-}"
