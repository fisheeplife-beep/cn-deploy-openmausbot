#!/usr/bin/env bash
# Preflight checks before installing / starting OpenMausBot on a CN-friendly host.
set -euo pipefail

ok=0; warn=0; bad=0
say() { printf '%s\n' "$*"; }
pass() { say "✅ $*"; ok=$((ok+1)); }
warn_() { say "⚠️  $*"; warn=$((warn+1)); }
fail() { say "❌ $*"; bad=$((bad+1)); }

say "=== OpenMausBot CN preflight ==="
say ""

# Node
if command -v node >/dev/null 2>&1; then
  nv=$(node -v | sed 's/^v//')
  major=${nv%%.*}
  if [[ "$major" -ge 24 ]]; then
    pass "Node.js $nv (>= 24 required for npm CLI path)"
  else
    fail "Node.js $nv — openmausbot npm package requires >= 24 (desktop .deb/.dmg/.exe do not need Node)"
  fi
else
  warn_ "Node.js not found — OK if you only use desktop releases or Docker; required for npx openmausbot"
fi

# npm registry
if command -v npm >/dev/null 2>&1; then
  reg=$(npm config get registry 2>/dev/null || true)
  say "   npm registry: ${reg:-unknown}"
  if [[ "$reg" == *"npmmirror.com"* ]]; then
    pass "npm registry points at npmmirror"
  elif [[ "$reg" == *"registry.npmjs.org"* ]]; then
    warn_ "npm registry is official npmjs.org — fine if reachable; timeout → npm config set registry https://registry.npmmirror.com"
  else
    warn_ "Custom npm registry ($reg). If openmausbot E404, force: npx --registry https://registry.npmjs.org openmausbot@latest ..."
  fi
fi

# Docker
if command -v docker >/dev/null 2>&1; then
  if docker info >/dev/null 2>&1; then
    pass "Docker daemon reachable"
    if docker compose version >/dev/null 2>&1; then
      pass "Docker Compose V2 available"
    else
      warn_ "docker compose plugin missing"
    fi
  else
    fail "docker binary present but daemon not reachable"
  fi
else
  warn_ "Docker not installed — CLI / desktop paths still work"
fi

# Ports commonly used
if command -v ss >/dev/null 2>&1; then
  for p in 8799 8800 8080 5199; do
    if ss -ltn 2>/dev/null | grep -qE ":${p}\\s"; then
      warn_ "Port $p already listening — stop the other process or change --port / OMB_HTTP_PORT"
    else
      pass "Port $p looks free"
    fi
  done
else
  warn_ "Cannot probe ports (no ss)"
fi

# Agent CLIs (optional but needed for real bots)
say ""
say "--- agent engines (optional until you chat) ---"
for cli in claude codex grok; do
  if command -v "$cli" >/dev/null 2>&1; then
    pass "Found agent CLI: $cli ($(command -v "$cli"))"
  else
    warn_ "No $cli on PATH — install & login before expecting doctor 'ready'"
  fi
done

probe() {
  local name="$1" url="$2"
  code=$(curl -sS -o /dev/null -w '%{http_code}' --max-time 8 -L "$url" 2>/dev/null || echo "000")
  if [[ "$code" =~ ^(200|301|302|401|403|404|405)$ ]]; then
    pass "Reachable: $name (HTTP $code)"
  else
    warn_ "Unreachable or slow: $name ($url → HTTP $code)"
  fi
}
say ""
say "--- network (best-effort) ---"
probe "npmjs.org/openmausbot" "https://registry.npmjs.org/openmausbot"
probe "npmmirror/openmausbot" "https://registry.npmmirror.com/openmausbot"
probe "ghcr.io" "https://ghcr.io/v2/"
probe "GitHub releases" "https://github.com/milind-soni/OpenMausBot/releases/latest"
probe "openmausbot.com" "https://www.openmausbot.com/"

say ""
say "=== summary: ${ok} ok / ${warn} warn / ${bad} bad ==="
if [[ "$bad" -gt 0 ]]; then
  exit 1
fi
exit 0
