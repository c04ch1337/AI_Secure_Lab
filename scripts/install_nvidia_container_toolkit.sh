#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

if ! command -v nvidia-smi >/dev/null 2>&1; then
  echo "[!] NVIDIA drivers not detected on host. You can still run CPU-only. Continuing..."
fi

echo "[*] Setting up NVIDIA Container Toolkit apt repo with fallbacks..."
sudo apt-get update -y
sudo apt-get install -y curl gnupg

sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /etc/apt/keyrings/nvidia-container-toolkit.gpg
sudo chmod a+r /etc/apt/keyrings/nvidia-container-toolkit.gpg

DIST_ID="$(. /etc/os-release; echo ${ID})"
DIST_VER="$(. /etc/os-release; echo ${VERSION_ID})"
DIST_CODE="$(. /etc/os-release; echo ${VERSION_CODENAME})"

# Try noble codename first, then IDVERSION
LISTDIR="/etc/apt/sources.list.d"
echo "[*] Attempting noble codename path..."
curl -fsSL "https://nvidia.github.io/libnvidia-container/stable/deb/ubuntu${DIST_VER}/libnvidia-container.list" \
  | sed 's#deb https://#deb [signed-by=/etc/apt/keyrings/nvidia-container-toolkit.gpg] https://#' \
  | sudo tee "${LISTDIR}/nvidia-container-toolkit.list" >/dev/null || true

if ! grep -q "libnvidia-container" "${LISTDIR}/nvidia-container-toolkit.list"; then
  echo "[*] Fallback to ID+VERSION_ID path..."
  curl -fsSL "https://nvidia.github.io/libnvidia-container/stable/deb/${DIST_ID}${DIST_VER}/libnvidia-container.list" \
    | sed 's#deb https://#deb [signed-by=/etc/apt/keyrings/nvidia-container-toolkit.gpg] https://#' \
    | sudo tee "${LISTDIR}/nvidia-container-toolkit.list" >/dev/null || true
fi

echo "[*] Installing nvidia-container-toolkit..."
sudo apt-get update -y || true
sudo apt-get install -y nvidia-container-toolkit || {
  echo "[!] Could not install nvidia-container-toolkit. CPU-only mode is still supported."
}

echo "[*] Configuring Docker default runtime (if toolkit present)..."
if command -v nvidia-ctk >/dev/null 2>&1; then
  sudo nvidia-ctk runtime configure --runtime=docker
  sudo systemctl restart docker
fi

echo "[*] Validation (non-fatal if it fails on CPU-only hosts):"
nvidia-smi || true
docker run --rm --gpus all nvidia/cuda:12.5.0-base-ubuntu24.04 nvidia-smi || true

echo "[*] Done."
