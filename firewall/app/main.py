import os
import re
import yaml
import json
from fastapi import FastAPI, Request, Response, HTTPException
import httpx

MODE = os.getenv("FIREWALL_MODE", "enforce").lower()
UPSTREAM = os.getenv("FIREWALL_UPSTREAM", "http://openwebui:8080")
BLOCKLIST_PATH = os.getenv("FIREWALL_BLOCKLIST_PATH", "/rules/prompts.yml")
OUTPUT_RULES_PATH = os.getenv("FIREWALL_OUTPUT_RULES_PATH", "/rules/outputs.yml")

app = FastAPI(title="AI Firewall", version="0.1.0")

def load_rules(path):
    try:
        with open(path, "r") as f:
            data = yaml.safe_load(f) or {}
        compiled = []
        for name, pattern in (data.get("patterns") or {}).items():
            try:
                compiled.append((name, re.compile(pattern, re.IGNORECASE)))
            except re.error:
                pass
        return compiled
    except FileNotFoundError:
        return []

PROMPT_RULES = load_rules(BLOCKLIST_PATH)
OUTPUT_RULES = load_rules(OUTPUT_RULES_PATH)

def scan(text: str, rules):
    hits = []
    for name, rx in rules:
        if rx.search(text or ""):
            hits.append(name)
    return hits

@app.get("/health")
def health():
    return {"mode": MODE, "upstream": UPSTREAM, "prompt_rules": len(PROMPT_RULES), "output_rules": len(OUTPUT_RULES)}

@app.post("/v1/chat")
async def chat_proxy(req: Request):
    body = await req.body()
    try:
        payload = json.loads(body.decode("utf-8") or "{}")
    except json.JSONDecodeError:
        raise HTTPException(status_code=400, detail="Invalid JSON")

    prompt = payload.get("prompt") or json.dumps(payload)
    prompt_hits = scan(prompt, PROMPT_RULES)
    if prompt_hits and MODE == "enforce":
        raise HTTPException(status_code=400, detail=f"Policy violation: {', '.join(prompt_hits)}")

    async with httpx.AsyncClient(timeout=60) as client:
        upstream_resp = await client.post(f"{UPSTREAM}/api/chat", content=body, headers={"Content-Type": "application/json"})
        text = upstream_resp.text

    output_hits = scan(text, OUTPUT_RULES)
    if output_hits and MODE == "enforce":
        raise HTTPException(status_code=400, detail=f"Output policy violation: {', '.join(output_hits)}")

    headers = {}
    if prompt_hits or output_hits:
        headers["X-AI-FW-Hits"] = ",".join(prompt_hits + output_hits)

    return Response(content=text, media_type="application/json", headers=headers)
