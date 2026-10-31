#!/usr/bin/env bash
# Clone upstream (shallow) and run the official root compose.yaml.
# Needs Docker + Compose V2. Not verified on the author box (no Docker).
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
WORK="${OMB_UPSTREAM_DIR:-$ROOT/data/upstream-OpenMausBot}"
REPO_URL="${OMB_UPSTREAM_URL:-https://github.com/milind-soni/OpenMausBot.git}"

if ! command -v docker >/dev/null 2>&1; then
  echo "Docker not found." >&2
  exit 1
fi
if ! docker compose version >/dev/null 2>&1; then
  echo "docker compose V2 required." >&2
  exit 1
fi

mkdir -p "$(dirname "$WORK")"
if [[ ! -d "$WORK/.git" ]]; then
  git clone --depth 1 "$REPO_URL" "$WORK"
else
  git -C "$WORK" pull --ff-only || true
fi

# Optional companion .env
if [[ -f "$ROOT/.env" ]]; then
  cp "$ROOT/.env" "$WORK/.env"
elif [[ -f "$ROOT/.env.example" && ! -f "$WORK/.env" ]]; then
  cp "$ROOT/.env.example" "$WORK/.env"
  echo "Wrote $WORK/.env from companion .env.example — edit ENGINES / ports if needed."
fi

cd "$WORK"
echo "Using upstream compose at $WORK"
docker compose up -d --build
docker compose ps
echo "Open http://localhost:${OMB_HTTP_PORT:-8080} when healthy."
echo "Engine login example: docker compose exec omb codex login --device-auth"
echo "Pair: docker compose exec omb node dist-server/openmausbot.js pair"
