#!/usr/bin/env bash
# Verify a running OpenMausBot harness (default http://127.0.0.1:8799).
set -euo pipefail

PORT="${OMB_PORT:-8799}"
BASE="http://127.0.0.1:${PORT}"

echo "GET ${BASE}/api/health"
body=$(curl -sS --max-time 5 "${BASE}/api/health")
echo "$body"
echo "$body" | grep -q openmausbot

code=$(curl -sS -o /dev/null -w '%{http_code}' --max-time 5 "${BASE}/")
echo "GET ${BASE}/ → HTTP $code"
[[ "$code" == "200" ]]

if command -v npx >/dev/null 2>&1; then
  echo "--- openmausbot status ---"
  npx --yes openmausbot@latest status --port "$PORT" || true
  echo "--- openmausbot doctor ---"
  npx --yes openmausbot@latest doctor --port "$PORT" || true
fi

echo "OK: harness answers. doctor may say 'not ready' until an engine CLI is configured."
