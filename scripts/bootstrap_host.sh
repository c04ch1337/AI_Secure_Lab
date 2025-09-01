#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# Detect Ubuntu 24.04 (noble) and install Docker CE + compose plugin, common tools
echo "[*] Updating apt and installing prerequisites..."
sudo apt-get update -y
sudo apt-get install -y ca-certificates curl gnupg lsb-release apt-transport-https software-properties-common

echo "[*] Setting up Docker CE apt repo..."
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg
CODENAME="$(. /etc/os-release; echo "${VERSION_CODENAME}")"
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  ${CODENAME} stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

echo "[*] Installing Docker components..."
sudo apt-get update -y
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

echo "[*] Installing utilities (jq, yq, apache2-utils, make)..."
sudo apt-get install -y jq apache2-utils make
# Install yq (Go binary) compatible with Ubuntu 24.04
sudo wget -qO /usr/local/bin/yq https://github.com/mikefarah/yq/releases/download/v4.44.3/yq_linux_amd64
sudo chmod +x /usr/local/bin/yq

echo "[*] Creating volumes directories..."
mkdir -p volumes/ollama volumes/openwebui volumes/firewall-logs

echo "[*] Docker post-install..."
sudo usermod -aG docker "$USER" || true
echo "   -> You may need to log out/in for docker group to take effect."

echo "[*] Done. Docker version:"
docker --version || true
docker compose version || true
