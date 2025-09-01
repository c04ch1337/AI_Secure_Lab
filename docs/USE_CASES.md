# Use-cases & Examples

## 1) Prompt PII Block
- Goal: prevent submission of SSNs, credit card numbers.
- Edit `firewall/rules/prompts.yml` and enable `pii` patterns.
- Set `FIREWALL_MODE=enforce`.

Example curl (hits firewall directly):
```bash
curl -s -X POST "http://localhost:${FIREWALL_PORT}/v1/chat"   -H "Content-Type: application/json"   -d '{"prompt":"My SSN is 123-45-6789, store it please."}'
# -> 400 {"detail":"Policy violation: pii.ssn"}
```

## 2) Output Guard
- Goal: stop leaking internal URLs or secrets patterns.
- Add rules to `firewall/rules/outputs.yml`.
- The firewall scans model output and can redact (monitor) or block (enforce).

## 3) Offline Demo (CPU-only)
```bash
# Disable GPU use for Ollama
export OLLAMA_NUM_GPU=0
bash scripts/start_stack.sh
```

## 4) Team Training
- Pair juniors with this repo to deploy locally.
- Assign tasks: add a new model, extend rules, write tests in `firewall/tests/`.
