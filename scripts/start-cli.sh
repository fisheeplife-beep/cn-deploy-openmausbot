#!/usr/bin/env bash
# Start OpenMausBot harness via npm package (non-interactive serve).
# Verified shape: openmausbot serve --no-open --no-pair --local
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DATA_DIR="${OMB_DATA_DIR:-$ROOT/data/cli-openmausbot}"
PORT="${OMB_PORT:-8799}"
LABEL="${OMB_LABEL:-cn-deploy}"
REGISTRY="${NPM_CONFIG_REGISTRY:-https://registry.npmjs.org}"
PKG="${OPENMAUSBOT_PKG:-openmausbot@latest}"

if ! command -v node >/dev/null 2>&1; then
  echo "Node.js >= 24 required. Install from https://nodejs.org/ or npmmirror Node mirrors." >&2
  exit 1
fi
major=$(node -v | sed 's/^v//' | cut -d. -f1)
if [[ "$major" -lt 24 ]]; then
  echo "Node $(node -v) is too old; need >= 24." >&2
  exit 1
fi

mkdir -p "$DATA_DIR"
echo "data-dir: $DATA_DIR"
echo "port:     $PORT"
echo "package:  $PKG"
echo "Starting serve (Ctrl-C stops the server; data persists)..."
exec npx --yes --registry "$REGISTRY" "$PKG" serve \
  --port "$PORT" \
  --data-dir "$DATA_DIR" \
  --label "$LABEL" \
  --no-open \
  --no-pair \
  --local
