#!/usr/bin/env bash
set -euo pipefail

# install_nvidia_docker.sh
# Adds/updates NVIDIA Container Toolkit APT repo and installs the toolkit.
# For Ubuntu 24.04 (noble), it auto-falls back to the 22.04 (jammy) repo
# because NVIDIA hasn't published noble packages yet.

log() { printf "\033[1;34m[*]\033[0m %s\n" "$*"; }
warn() { printf "\033[1;33m[!]\033[0m %s\n" "$*"; }
err() { printf "\033[1;31m[x]\033[0m %s\n" "$*" >&2; }
die() { err "$@"; exit 1; }

require_root() {
  if [[ "${EUID:-$(id -u)}" -ne 0 ]]; then
    die "Please run as root (try: sudo $0)"
  fi
}

ensure_bin() {
  command -v "$1" >/dev/null 2>&1 || die "Missing required tool: $1"
}

write_repo_file() {
  local list_content="$1"
  local list_path="/etc/apt/sources.list.d/nvidia-container-toolkit.list"

  log "Writing repo list to: ${list_path}"
  printf "%s\n" "${list_content}" > "${list_path}"
}

main() {
  require_root
  ensure_bin curl
  ensure_bin gpg
  ensure_bin tee
  ensure_bin awk

  # Detect OS
  source /etc/os-release || die "Unable to read /etc/os-release"
  UBUNTU_CODENAME="${UBUNTU_CODENAME:-}"
  VERSION_ID="${VERSION_ID:-}"
  ID="${ID:-}"
  [[ "${ID}" == "ubuntu" ]] || die "This script only supports Ubuntu."

  # Decide which NVIDIA repo we should use
  # Noble (24.04) is not yet supported -> fall back to Jammy (22.04).
  distribution="ubuntu${VERSION_ID}"
  if [[ "${UBUNTU_CODENAME}" == "noble" || "${VERSION_ID}" == "24.04" ]]; then
    warn "Ubuntu ${VERSION_ID} (${UBUNTU_CODENAME}) detected; NVIDIA repo not published for noble."
    warn "Falling back to Jammy (22.04) repo for libnvidia-container."
    distribution="ubuntu22.04"
  fi

  log "Using NVIDIA distribution path: ${distribution}"

  # Prepare keyring path
  keyring="/usr/share/keyrings/nvidia-container-toolkit.gpg"

  log "Fetching NVIDIA GPG key -> ${keyring}"
  curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey \
    | gpg --dearmor -o "${keyring}"

  # Fetch the repo list for the chosen distribution and inject signed-by
  base_url="https://nvidia.github.io/libnvidia-container"
  list_url="${base_url}/${distribution}/libnvidia-container.list"

  log "Probing repo list URL: ${list_url}"
  if ! curl -fsIL "${list_url}" >/dev/null; then
    die "Repo list URL not available: ${list_url}"
  fi

  log "Downloading repo list and adding signed-by..."
  list_content="$(curl -fsSL "${list_url}" \
    | sed "s#^deb https://#deb [signed-by=${keyring}] https://#")"

  # Defensive: ensure the list has at least one 'deb ' line
  if ! printf "%s" "${list_content}" | awk '/^deb /{found=1} END{exit !found}'; then
    die "Failed to generate a valid APT list from ${list_url}"
  fi

  write_repo_file "${list_content}"

  log "Updating APT cache..."
  apt-get update -y

  log "Installing/Updating nvidia-container-toolkit..."
  apt-get install -y nvidia-container-toolkit

  # Configure Docker runtime (safe to re-run)
  if command -v nvidia-ctk >/dev/null 2>&1; then
    log "Configuring NVIDIA runtime for Docker..."
    nvidia-ctk runtime configure --runtime=docker
    systemctl restart docker || warn "Docker not restarted (is Docker installed & running?)"
  else
    warn "nvidia-ctk not found; skipping Docker runtime auto-config."
  fi

  log "Done. You can verify with: docker run --rm --gpus all nvidia/cuda:12.4.1-base-ubuntu22.04 nvidia-smi"
}

main "$@"
