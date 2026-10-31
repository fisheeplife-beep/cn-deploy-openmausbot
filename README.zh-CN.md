# OpenMausBot 国内可跟做部署配套

> 上游仓库：[milind-soni/OpenMausBot](https://github.com/milind-soni/OpenMausBot)（Apache-2.0；另有 `enterprise/` 源码可得树）  
> 官网 / 下载：https://www.openmausbot.com/ · https://www.openmausbot.com/download  
> 文档站（同源 docs）：上游 `apps/docs` · 自托管长文：`docs/deploy-vps.md`  
> 本仓性质：**独立中文部署配套**（脚本 / Compose 形状说明 / 踩坑记录），**不是**官方镜像，也**不会**整页搬运上游 README。

OpenMausBot（亦称 MausBot；曾用名 OpenGrokBot）是开源的「聊天 App 里管一队 AI Bot」方案：本地优先 harness、自带 Claude / Codex / Grok 等引擎 CLI、可选云电脑与连接应用。  
本仓目标：在**国内网络 / 常见 Linux 或 macOS**上，按步骤把实例跑起来，并知道成功长什么样。

---

## 验证边界（请先看）

| 路径 | 本仓作者环境验证状态（2026-10-31，Asia/Shanghai） |
|------|--------------------------------------------------|
| **npm：`openmausbot@0.1.135` + `serve --local --no-open --no-pair`**（Node **24.11.0**） | ✅ **已验证** — `GET /api/health` 含 `"app":"openmausbot"`；UI 根路径 **HTTP 200**；`status` 显示版本与主机名；见 [`examples/`](./examples/) |
| **`doctor`（未配引擎）** | ✅ **已验证** — 明确报 `Engines available: none` / `not ready`（预期） |
| **桌面发行包 `.deb` / `.dmg` / `.exe`** | ⚠️ **未安装 GUI** — 最新 release `v0.1.135` 直链探测 **HTTP 200**（约 250–330MB 级） |
| **Docker：`ghcr.io/milind-soni/openmausbot` + compose up** | ⚠️ **未在本机跑通** — 验证机无 Docker；匿名拉 manifest **401**（GHCR 常见）；上游 `docker.yml` workflow **active** |
| **引擎登录后真实对话 / Cloud 电脑 / Composio** | ⚠️ **未验证** — 需自备 Claude / Codex / Grok 登录或 API Key |

示例输出：[`examples/health.json`](./examples/health.json)、[`examples/status.txt`](./examples/status.txt)、[`examples/doctor.txt`](./examples/doctor.txt)。

---

## 它到底怎么装？（真实安装面）

上游同时提供多条路，**不要混成一条**：

| 方式 | 命令 / 产物 | 说明 |
|------|-------------|------|
| **A. 桌面发行包（最省事）** | GitHub Releases：`.dmg` / `.exe` / `.deb` / AppImage | harness **嵌在 App 里**，一般不用另起服务；需再装至少一个引擎 CLI |
| **B. npm CLI（本仓重点实测）** | `npm i -g openmausbot` 或 `npx openmausbot` | Node **≥ 24**；`serve` 起 harness（默认 `127.0.0.1:8799`） |
| **C. 本地 Docker Compose** | 上游根目录 `compose.yaml`：`docker compose up -d --build` | 基于 `ghcr.io/milind-soni/openmausbot` + 本地 Dockerfile 注入引擎；默认 HTTP **8080** |
| **D. VPS 自托管** | `npx openmausbot serve --tunnel` / `--tailscale`，或 `deploy/docker-compose.yml` + 域名 | 见上游 `docs/deploy-vps.md`；本仓给 `.env` 样例与网络笔记 |
| **E. 源码开发** | `pnpm install` → `pnpm dev:server` + `pnpm dev`（+ 可选 `dev:desktop`） | Node 24+、pnpm 10.33；重，国内慎选 |

**硬依赖（除纯看 UI 外）：** 至少一个已登录的 agent CLI —— [`claude`](https://claude.com/claude-code)、[`codex`](https://github.com/openai/codex) 或 [`grok`](https://x.ai/cli)。`openmausbot` 包**不包含**这些引擎。

可选先体检：

```bash
./scripts/preflight.sh
# 或你已有的 cn-deploy-doctor
```

---

## 环境要求（最小可跑）

### 路径 B（npm CLI，已验证）

- **Node.js ≥ 24**（本仓实测 24.11.0）
- 能访问 npm（官方或 [npmmirror](https://registry.npmmirror.com)）
- 端口：**8799**（harness）、**8800**（webhook 默认）
- 磁盘：数百 MB 起；浏览器引擎另计

### 路径 A（桌面包）

- macOS / Windows x64 / Ubuntu 24.04 x64（Linux 仍标 beta）
- 不强制本机 Node；仍要引擎 CLI

### 路径 C / D（Docker）

- Docker + Compose V2，Linux 容器
- 能拉 GHCR 或愿意 `--build`
- 建议 `--init` 与 `shm_size=512m`（上游已写进 compose）

---

## 路径 B｜npm CLI 五分钟落地（已验证）

### 1. 确认 Node 24+

```bash
node -v    # 需要 v24.x
npm -v
```

不够就去 [Node 发行页](https://nodejs.org/dist/) 或 [npmmirror Node 镜像](https://npmmirror.com/mirrors/node/) 装 24，再开新终端。

### 2. 预检 npm

```bash
npm view openmausbot version
# 本仓当日：0.1.135（与 GitHub release v0.1.135 对齐）
```

超时可临时：

```bash
npm config set registry https://registry.npmmirror.com
# 或单次：
npx --yes --registry https://registry.npmjs.org openmausbot@latest --help
```

### 3. 一键 serve（推荐本仓脚本）

```bash
git clone https://github.com/fisheeplife-beep/cn-deploy-openmausbot.git
cd cn-deploy-openmausbot
./scripts/start-cli.sh
```

等价手写：

```bash
mkdir -p ./data/cli-openmausbot
npx --yes --registry https://registry.npmjs.org openmausbot@latest serve \
  --port 8799 \
  --data-dir "$(pwd)/data/cli-openmausbot" \
  --label cn-deploy \
  --no-open \
  --no-pair \
  --local
```

说明：

- `serve`：非交互起服务，适合脚本 / SSH  
- `--no-open`：不弹浏览器（无头机必备）  
- `--no-pair`：本次不打印手机配对码  
- `--local`：忽略已保存的远程访问设置，本机 loopback  
- 数据进 `--data-dir`；删目录 ≈ 重置（引擎登录目录可能仍在 `~/.claude` 等）

成功时日志类似：

```text
openmausbot server on http://127.0.0.1:8799
OpenMausBot is running on http://127.0.0.1:8799
```

### 4. 成功标准（必须自己勾）

另开终端：

```bash
./scripts/verify.sh
# 或：
curl -sS http://127.0.0.1:8799/api/health
# 期望 JSON 含 "app":"openmausbot"
curl -sS -o /dev/null -w '%{http_code}\n' http://127.0.0.1:8799/
# 期望 200
npx openmausbot status --port 8799
npx openmausbot doctor --port 8799
```

本仓实测 `doctor` 在**未装引擎**时会说 `not ready` —— 这表示 harness 活着、只差引擎，**不算失败**。

### 5. 配引擎（未在本仓完整验证）

本机已安装并登录 `claude` / `codex` / `grok` 后重启 `serve`，或按 `openmausbot help` 使用：

```bash
npx openmausbot engine set claude --key-env ANTHROPIC_API_KEY
# 具体 KIND / 标志以 openmausbot help engine 为准
```

交互式首次引导也可用：

```bash
npx openmausbot setup --data-dir ./data/cli-openmausbot
npx openmausbot          # 或 start：按已保存配置打开工作区
```

---

## 路径 A｜桌面发行包（未在本机装 GUI）

| 平台 | 推荐包 | 安装 |
|------|--------|------|
| macOS Apple silicon | [OpenMausBot.dmg](https://github.com/milind-soni/OpenMausBot/releases/latest/download/OpenMausBot.dmg) | 拖进 Applications；已签名公证 |
| macOS Intel | [OpenMausBot-intel.dmg](https://github.com/milind-soni/OpenMausBot/releases/latest/download/OpenMausBot-intel.dmg) | 同上 |
| Windows x64 | [OpenMausBot-setup.exe](https://github.com/milind-soni/OpenMausBot/releases/latest/download/OpenMausBot-setup.exe) | 每用户安装；SmartScreen → 更多信息 → 仍要运行 |
| Ubuntu 24.04 x64 | [OpenMausBot-amd64.deb](https://github.com/milind-soni/OpenMausBot/releases/latest/download/OpenMausBot-amd64.deb) · [AppImage](https://github.com/milind-soni/OpenMausBot/releases/latest/download/OpenMausBot.AppImage) | 优先 `.deb`；GNOME；beta |

然后：装好 `claude`/`codex`/`grok` → 终端登录一次 → **重启 OpenMausBot** → 模型选择器里应出现可用引擎。

Linux 能力边界（本机操控 / Wayland）见上游 `docs/linux-desktop.md`；本仓 [troubleshooting.md](./docs/troubleshooting.md) 有摘要。

---

## 路径 C｜Docker 本地（未在本机跑通）

**推荐：** 跟上游官方，而不是只靠本仓精简 compose：

```bash
./scripts/start-docker-upstream.sh
# 等价：
# git clone https://github.com/milind-soni/OpenMausBot && cd OpenMausBot
# cp .env.example .env   # 可选
# docker compose up -d --build
# 打开 http://localhost:8080
```

健康：容器内 `GET http://127.0.0.1:8799/api/health` 应含 `openmausbot`；宿主机映射默认 **8080**。

引擎登录 / 配对（上游 local README）：

```bash
docker compose exec omb codex login --device-auth
docker compose exec omb node dist-server/openmausbot.js pair
```

本仓 [`docker-compose.yml`](./docker-compose.yml) 展示端口与 healthcheck 形状，适合「先看一眼」；完整 build 上下文在上游 `deploy/local/`。

VPS 自有域名：见 [`deploy-snippets/vps.env.example`](./deploy-snippets/vps.env.example) + 上游 `OpenMausBot/deploy/docker-compose.yml`（Caddy 要 `DOMAIN=`）。

---

## 国内网络与排错

- [docs/china-network.md](./docs/china-network.md) — npm / Releases / GHCR / 代理  
- [docs/troubleshooting.md](./docs/troubleshooting.md) — Node 版本、doctor、端口、Wayland、备份

---

## 和「只翻译 README」的差别

本仓提供：可执行脚本、验证过的成功标准、标明未跑通的路径、国内可达性探测结果。  
不会：复刻上游营销长文、声称官方、内嵌上游私有企业层。

上游还有：团队模板仓 [milind-soni/openmausbot-teams](https://github.com/milind-soni/openmausbot-teams)、签名 macOS 构建仓 `openmausbot-releases`。

---

## 许可

本配套仓：[MIT](./LICENSE) © 2026 fisheeplife-beep  
上游 OpenMausBot：Apache-2.0（`enterprise/` 另有许可）。安装 / 拉取上游产物时遵守其许可与第三方条款（Composio、Boat、语音服务等均为可选第三方）。
