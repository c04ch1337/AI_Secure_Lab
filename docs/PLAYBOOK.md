# Playbook — Deploy & Operate

> All commands are idempotent; safe to re-run.

## 1) Prepare Host (Ubuntu 24.04)
```bash
sudo bash scripts/bootstrap_host.sh
```
This installs: Docker CE + compose plugin, `curl`, `jq`, `yq`, `htpasswd`, `make` (optional), and sane kernel/network sysctls.

## 2) (Optional) GPU Offload
```bash
sudo bash scripts/install_nvidia_container_toolkit.sh
```
Script detects distro and configures `libnvidia-container` apt repo with fallbacks for `noble`. Validates via:
```bash
nvidia-smi || true
docker run --rm --gpus all nvidia/cuda:12.5.0-base-ubuntu24.04 nvidia-smi || true
```

## 3) Configure Environment
```bash
cp .env.example .env
# edit secrets, ports, mode (enforce/monitor), admin user/pw
```

## 4) Launch Stack
```bash
bash scripts/start_stack.sh
```
- Traefik available at `http://localhost:$TRAEFIK_HTTP_PORT`
- OpenWebUI at `http://localhost:$OPENWEBUI_PORT`

## 5) Pull Models
```bash
bash scripts/pull_models_ollama.sh
```
Choose small quantized models first for stability on 3–6GB VRAM.

## 6) Operate
```bash
bash scripts/status.sh
bash scripts/logs.sh
bash scripts/stop_stack.sh
bash scripts/backup.sh
```

## 7) Firewall Modes
- `enforce`: reject requests that violate rules (HTTP 400 + reason).
- `monitor`: allow but log policy hits for tuning.

## 8) Upgrades
- Re-run bootstrap scripts anytime.
- Recreate services: `docker compose pull && bash scripts/start_stack.sh`
