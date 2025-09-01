# Architecture

## Data Flow
```
Client -> Traefik -> (Firewall enforce/monitor) -> OpenWebUI -> Ollama
```
- Traefik centralizes routing, TLS (optional), and auth for dashboard.
- Firewall inspects JSON payloads for inbound (prompts) and outbound (model outputs).
- OpenWebUI is the user front-end; talks to Ollama on `11434`.
- Ollama hosts quantized models for local inference.

## Ports
- Traefik: `${TRAEFIK_HTTP_PORT}`
- Firewall: `${FIREWALL_PORT}`
- OpenWebUI: `${OPENWEBUI_PORT}`
- Ollama: `${OLLAMA_PORT}`

## Storage
- `volumes/` directory (created automatically) stores:
  - `ollama/` models
  - `openwebui/` data
  - `firewall/` logs
