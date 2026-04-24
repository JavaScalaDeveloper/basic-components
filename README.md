# basic-components
基础组件环境搭建、运维

## Openclaw + Ollama（Docker Compose，从 0 到 1）

本文档基于本仓库的 `docker/docker/docker-compose.yml` 与 `docker/docker/openclaw/openclaw.json`。

### 目录结构（你需要准备/确认）

进入 compose 目录（建议把整个 `docker/docker/` 同步到你的服务器，比如 `/opt/docker`）：

- `docker-compose.yml`
- `openclaw/`
  - `openclaw.json`（Openclaw 配置文件）
  - `workspace/`（Openclaw 工作区，必须可写）

### 1）前置条件

- 服务器已安装 Docker 与 Docker Compose 插件（`docker compose version` 能运行）
- 若服务器开启 SELinux（常见于 CentOS/RHEL/Fedora），本仓库已在挂载处使用 `:Z` 处理标签

### 2）从零启动（推荐流程）

在服务器上进入 compose 目录（示例 `/opt/docker`）：

```bash
cd /opt/docker
```

创建目录并赋权（Openclaw 镜像默认使用 `node` 用户，uid=1000）：

```bash
mkdir -p ./openclaw/workspace
chown -R 1000:1000 ./openclaw
chmod -R u+rwX ./openclaw
```

启动（只启动 Openclaw）：

```bash
docker compose up -d openclaw
docker logs openclaw --tail 100
```

如果你也要用 Docker 跑 Ollama：

```bash
docker compose up -d ollama openclaw
```

### 3）访问与鉴权（Control UI）

Openclaw 在容器里默认会对外监听（`bind=auto/lan`），因此**非 loopback 绑定必须配置鉴权**，否则会拒绝启动：
`Refusing to bind gateway ... without auth`

- **访问地址**：`http://<服务器IP或主机名>:18789`
- **Token（推荐）**：使用环境变量 `OPENCLAW_GATEWAY_TOKEN`（本仓库默认配置即为 token 模式）

示例（在 `/opt/docker/.env` 中设置）：

```bash
OPENCLAW_GATEWAY_TOKEN=change-me-to-a-long-random-token
```

如果你在局域网通过 HTTP 访问遇到：
`control ui requires device identity (use HTTPS or localhost secure context)`

可以在 `openclaw/openclaw.json` 里开启（仅建议内网自用）：

- `gateway.controlUi.allowInsecureAuth: true`
- `gateway.controlUi.dangerouslyDisableDeviceAuth: true`

更推荐的长期方案：给 Control UI 上 HTTPS（反代/Caddy/Nginx/或 Tailscale Serve），而不是一直开“dangerous”开关。

### 3.1）两种“免登录”模式（你要的两种都给）

#### 模式 A：完全免登录（推荐）——仅本机监听 + SSH 隧道

特点：**Openclaw 不需要 token/密码**，但只在服务器本机可访问；从其他电脑通过 SSH 隧道访问。

1）把 `openclaw/openclaw.json` 改为 loopback（并移除/注释 `gateway.auth` 块）：

```json
{
  "gateway": { "bind": "loopback" }
}
```

2）重启：

```bash
docker compose restart openclaw
```

3）在你的电脑建立隧道：

```bash
ssh -N -L 18789:127.0.0.1:18789 root@book-n5095
```

4）浏览器打开：
`http://127.0.0.1:18789`

#### 模式 B：局域网直连（必须有鉴权）——但可以做到“无需手动输入”

结论：**Openclaw 会强制要求 non-loopback 绑定必须有鉴权**，所以“局域网直连且完全无 token/密码”在默认安全机制下不可行。

但你可以把 token 放进 URL（相当于“免手动登录”）：

- 配置 `.env` 的 `OPENCLAW_GATEWAY_TOKEN`
- 访问时带 token（不同版本 UI 参数略有差异，常见写法之一）：
  - `http://book-n5095:18789/#token=YOUR_TOKEN`

如果看到 `token_mismatch`，说明你浏览器里缓存的是旧 token，把 UI 设置里的 token 更新为当前配置即可。

### 4）让 Openclaw 使用宿主机上的 Ollama（本地 LLM）

本仓库默认在 `openclaw/openclaw.json` 中配置：

- `models.providers.ollama.baseUrl: "http://host.docker.internal:11434"`

同时在 `docker-compose.yml` 的 `openclaw` 服务中配置了：

- `extra_hosts: ["host.docker.internal:host-gateway"]`（Linux 需要）

### 5）支持多个 Ollama 模型（并修复 context window 过小）

你遇到的报错：
`Model context window too small (8192 tokens; ...). Minimum is 16000.`

原因是 Openclaw 会使用 `openclaw.json` 里为该模型配置的 `contextWindow` 作为上限。

本仓库已在 `docker/docker/openclaw/openclaw.json` 中：

- 将 `qwen3.5:0.8b` 的 `contextWindow` 提高到 **16384**
- 新增第二个模型：**`qwen3.5:4b`**（示例 `contextWindow: 32768`）

你只需要在 Ollama 侧拉取模型即可：

```bash
docker exec -it ollama ollama pull qwen3.5:4b
```

切换默认模型（修改 `openclaw/openclaw.json`）：

```json
{
  "agents": {
    "defaults": {
      "model": {
        "primary": "ollama/qwen3.5:4b"
      }
    }
  }
}
```

修改完重启：

```bash
docker compose restart openclaw
docker logs openclaw --tail 100
```

### 5.1）接入阿里云百炼（DashScope / Qwen）

如果你的 `apiKey` 已经在环境变量里（推荐 `DASHSCOPE_API_KEY`），可以在 `openclaw/openclaw.json` 增加一个 OpenAI 兼容 provider（DashScope 的 compatible-mode）。

本仓库已预置模型：`qwen3-vl-flash-2026-01-22`（图文模型）。

你只需要在运行 Openclaw 的宿主机上设置环境变量，并重启即可：

```bash
export DASHSCOPE_API_KEY="sk-xxxxxx"
docker compose restart openclaw
```

切换默认模型（可选）：

```json
{
  "agents": {
    "defaults": {
      "model": {
        "primary": "dashscope/qwen3-vl-flash-2026-01-22"
      }
    }
  }
}
```

### 5.2）让对话默认使用中文（兼容旧版本）

部分 Openclaw 版本不支持在 `openclaw.json` 里配置 `agents.defaults.systemPrompt`。更通用的做法是把规则写进工作区引导文件（会注入到系统提示中）：

- `openclaw/workspace/AGENTS.md`（推荐）
- 或 `openclaw/workspace/SOUL.md`

本仓库已提供 `docker/docker/openclaw/workspace/AGENTS.md`，默认强制中文输出。你只需要确保服务器上对应路径存在并挂载到容器（本仓库 compose 已挂载 `./openclaw/workspace:/home/node/.openclaw/workspace`）。

### 6）常见报错速查

- **`origin not allowed`**：
  - 配置 `gateway.controlUi.allowedOrigins`（新版本支持 `["*"]`）
  - 确保 Openclaw 真实读取的配置文件就是你挂载的那份（本仓库采用“挂载整个 `./openclaw/` 目录”）

- **`EISDIR ... openclaw.json`**：
  - 说明 `openclaw/openclaw.json` 被错误创建成了目录：`rm -rf ./openclaw/openclaw.json` 后重新创建为文件

- **`EACCES ... openclaw.json.*.tmp` / `EBUSY rename tmp -> openclaw.json`**：
  - 不要只 bind mount 单文件 `openclaw.json`（原子 rename 会失败）
  - 本仓库已改为 bind mount 整个 `./openclaw/` 目录

- **`EACCES mkdir ... /home/node/.openclaw/workspace/state`**：
  - 确保宿主机 `./openclaw/workspace` 可写且 `chown -R 1000:1000 ./openclaw/workspace`

