# 排错速查

## `engines: { node: '>=24' }` / 启动即退出

升级到 Node 24+。本仓作者环境用官方 `node-v24.11.0-linux-x64` 跑通 `serve`。

## `doctor`：`not ready` / `Engines available: none`

正常：只起了 harness，还没配引擎。任选其一：

```bash
# 本机已有 Claude / Codex / Grok CLI 且已登录 → 重启 serve 后应出现在 models
# 或无屏写入（示例，按官方 help）：
npx openmausbot engine set claude --key-env ANTHROPIC_API_KEY
```

桌面安装包路径：在 App 内按引导登录引擎。

## `browser engine: installed agent-browser X is not the pinned Y`

警告为主：全局 PATH 上的 `agent-browser` 版本与 OpenMausBot 钉死的版本不一致，可能导致浏览器工具卡顿。按提示安装钉死版本，或在干净环境用 `openmausbot browser install` 装到数据目录。

## 端口占用 `8799` / `8800` / `8080`

- CLI：`serve --port 8799`  
- Webhook 默认 `8800`（或 `OMB_PORT+1`）  
- 本地 Docker HTTP：`OMB_HTTP_PORT`（默认 8080）  
用 `./scripts/preflight.sh` 先扫端口。

## Docker：`pull` 401 / timeout

见 [china-network.md](./china-network.md)。优先试上游 monorepo 根目录官方 `compose.yaml`（含 `deploy/local` 构建上下文）；本仓 `docker-compose.yml` 是「只拉预构建镜像」的精简版。

## Windows SmartScreen「未知发布者」

上游尚未代码签名 Windows 安装包。确认下载来自官方 releases 后：**更多信息 → 仍要运行**。

## Ubuntu Wayland：本机电脑控制不可用

上游明确：Wayland 下 host control 仍关闭（跟踪 issue #345）。聊天 / Cloud / Local VM 仍可用；完整本机操控用 Xorg 或等上游解除安全门。

## 数据目录在哪

- CLI / serve 默认：`~/.openmausbot`（本仓脚本默认改到 `./data/cli-openmausbot`）  
- Docker：命名卷（见 compose `data`）  
备份前先停服；引擎登录态（`~/.claude`、`~/.codex` 等）不在 OpenMausBot 数据目录里时需一并备份。
