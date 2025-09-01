#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

: "${OLLAMA_PORT:=11434}"
: "${MODELS:=mistral:7b-instruct-q4_K_M phi3:mini-instruct llama3.1:8b-instruct-q4_K_M}"

echo "[*] Ensuring Ollama is up at port ${OLLAMA_PORT}..."
if ! curl -fsSL "http://localhost:${OLLAMA_PORT}/api/tags" >/dev/null 2>&1; then
  echo "[!] Ollama not responding. Start the stack first: bash scripts/start_stack.sh"
  exit 1
fi

for m in $MODELS; do
  echo "[*] Pulling $m ..."
  curl -fsS -X POST "http://localhost:${OLLAMA_PORT}/api/pull" -d "{\"name\":\"$m\"}"
  echo ""
done

echo "[*] Done. List models:"
curl -s "http://localhost:${OLLAMA_PORT}/api/tags" | jq -r '.models[].name' || true
