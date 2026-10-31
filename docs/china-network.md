# 国内网络说明（OpenMausBot）

## npm 包 `openmausbot`

- 官方源：`https://registry.npmjs.org/openmausbot`（本仓实测 HTTP 200，包版本与 upstream release 对齐，如 `0.1.135`）
- 镜像：`https://registry.npmmirror.com/openmausbot`（本仓实测 HTTP 200）
- 若私有源导致 `E404`：

```bash
npx --yes --registry https://registry.npmjs.org openmausbot@latest --help
```

- Node 必须 **≥ 24**。可用 [npmmirror Node 镜像](https://npmmirror.com/mirrors/node/) 下载 `v24.x` linux/mac 二进制。

## GitHub Releases（桌面安装包）

- 最新：https://github.com/milind-soni/OpenMausBot/releases/latest  
- 国内直连 GitHub 可能慢或断；常见做法：代理、`ghproxy` 类镜像、或先用可访问的机器下载 `.deb` / `.dmg` / `.exe` 再拷贝。  
- 本仓验证机对 `OpenMausBot-amd64.deb` / `openmausbot-*.tgz` 的 release 直链返回 **HTTP 200**（可下载），未在无桌面环境安装 GUI。

## GHCR 镜像 `ghcr.io/milind-soni/openmausbot`

- 上游根目录 `compose.yaml` 与 `deploy/docker-compose.yml` 默认使用该镜像。  
- 匿名拉 tag 列表可能 **401**（GHCR 常见）；有 Docker 时再 `docker pull ghcr.io/milind-soni/openmausbot:latest`。  
- 上游 `.github/workflows/docker.yml` 状态为 **active**，main 推送会出图。  
- 若 GHCR 拉不动：代理 Docker、或在上游仓 `docker compose up -d --build` 本地构建（慢、吃带宽）。

## 代理建议

| 场景 | 变量 / 做法 |
|------|-------------|
| npm | `npm config set proxy` / 系统 `HTTPS_PROXY`；或换 npmmirror |
| git clone 上游 | `HTTPS_PROXY` 或镜像站 |
| Docker pull | Docker daemon 代理 / 镜像加速（注意加速器通常只覆盖 Docker Hub，**不一定**覆盖 GHCR） |
| Electron / Chrome for Testing（bots 浏览器） | 同 agent-browser：Google CDN 可能需代理；CLI 路径可用 `openmausbot browser install` |

## 引擎 CLI（Claude / Codex / Grok）

- `openmausbot` **不自带**这些引擎；需本机或容器内另行安装并登录。  
- 国内装 `@anthropic-ai/claude-code` / `@openai/codex` 同样受 npm 与厂商登录页网络影响；VPS 路径常用容器内 `device-auth` 扫码。
