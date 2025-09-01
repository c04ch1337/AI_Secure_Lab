#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

STAMP="$(date +%Y%m%d-%H%M%S)"
OUT="backup-${STAMP}.tar.gz"
tar -czf "$OUT" volumes/
echo "[*] Created $OUT"
