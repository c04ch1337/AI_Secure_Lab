# Security Policy

## Supported Versions
This repository targets Ubuntu 24.04 hosts. All scripts are idempotent and safe to re-run.

## Reporting a Vulnerability
Open an issue with minimal details; for sensitive reports, please contact the maintainer privately.
Do not include secrets or PII in issues, PRs, or commit messages.

## Secure Development Practices
- Shell scripts use `set -euo pipefail` and `IFS` hardening.
- Dependencies pinned where practical; container images use explicit tags.
- Default deployment is **local only** with auth on management UIs.
- Optional AI Firewall service inspects prompts/responses for policy violations.
