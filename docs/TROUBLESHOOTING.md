# Troubleshooting (Ubuntu 24.04)

## Docker not found
Re-run:
```bash
sudo bash scripts/bootstrap_host.sh
```

## NVIDIA repo 404
The script tries multiple distro codename patterns (`noble`, `$ID$VERSION_ID`). If both fail, it falls back to CPU-only.
You can also visit https://nvidia.github.io/libnvidia-container/ to confirm repo paths, then re-run the installer.

## OpenWebUI port already in use
Change `OPENWEBUI_PORT` in `.env` and `bash scripts/start_stack.sh` again.

## Models too large / OOM
Use smaller quantized models (`q4_K_M`) or set `OLLAMA_NUM_GPU=0` for CPU.
