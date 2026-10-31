# cn-deploy-openmausbot

> **Series index:** [cn-deploy](https://github.com/fisheeplife-beep/cn-deploy) — Chinese follow-along deployment companions.

Chinese, follow-along **deployment companion** for [milind-soni/OpenMausBot](https://github.com/milind-soni/OpenMausBot) (Apache-2.0) — not an official fork, and not a verbatim copy of upstream docs.

**Start here (ZH):** [README.zh-CN.md](./README.zh-CN.md)

### What you get

- npm CLI first-run scripts (`npx openmausbot serve`) tuned for CN npm/mirrors
- Compose / `.env.example` shaped like upstream local + VPS stacks
- Preflight / verify helpers, China network notes, troubleshooting

### Verification snapshot (author box, 2026-10-31 Asia/Shanghai)

| Path | Status |
|------|--------|
| `npx openmausbot@0.1.135 serve` + `/api/health` + UI `200` | **Verified** on Node **24.11.0** |
| `status` / `doctor` (no engine → not ready) | **Verified** |
| Desktop `.deb` / `.dmg` / `.exe` install | **Not run** (no GUI); release URLs HTTP 200 |
| Docker compose pull/up | **Not run** (no Docker); GHCR workflow active; anonymous manifest 401 |
| Engine login + real bot chat | **Not verified** (no Claude/Codex/Grok keys) |

### Quick links

```bash
./scripts/preflight.sh
./scripts/start-cli.sh          # needs Node >= 24
./scripts/verify.sh             # against a running serve
./scripts/start-docker-upstream.sh   # needs Docker; clones upstream
```

Upstream: https://github.com/milind-soni/OpenMausBot · https://www.openmausbot.com/  
License for this companion: [MIT](./LICENSE)
