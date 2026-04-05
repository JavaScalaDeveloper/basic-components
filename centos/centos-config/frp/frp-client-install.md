# FRP 客户端安装指南

本文档介绍手动安装 FRP 客户端 (frp_0.61.2_linux_amd64) 的完整流程。

## 前置要求

- Linux 系统（CentOS/Ubuntu 等）
- root 或 sudo 权限
- 能够访问 FRP 服务端的网络连接
- 确保客户端防火墙不阻止相关端口

## 安装目录

本文档使用 `/opt/software/frp/` 作为安装目录。

---

## 安装步骤

### 1. 创建安装目录

```bash
sudo mkdir -p /opt/software/frp
```

### 2. 下载 FRP

下载 frp_0.61.2_linux_amd64.tar.gz 包：

```bash
cd /tmp
wget https://github.com/fatedier/frp/releases/download/v0.61.2/frp_0.61.2_linux_amd64.tar.gz
```

如果无法访问 GitHub，可以使用国内镜像源：

```bash
wget https://ghproxy.com/https://github.com/fatedier/frp/releases/download/v0.61.2/frp_0.61.2_linux_amd64.tar.gz
```

### 3. 解压安装包

```bash
tar -xzf frp_0.61.2_linux_amd64.tar.gz
```

### 4. 复制文件到安装目录

```bash
sudo cp -r frp_0.61.2_linux_amd64/* /opt/software/frp/
```

**注意**：同一个压缩包同时包含服务端和客户端程序，客户端使用的是 `frpc`。

### 5. 验证安装

检查文件是否复制成功：

```bash
ls -lh /opt/software/frp/
```

应该看到以下文件：
- `frps` - 服务端程序（客户端不需要）
- `frpc` - 客户端程序
- `frps.toml` - 服务端配置文件（客户端不需要）
- `frpc.toml` - 客户端配置文件
- `systemd/` - systemd 服务文件目录

---

## 配置客户端

### 1. 编辑配置文件

编辑 `/opt/software/frp/frpc.toml`：

```bash
sudo vi /opt/software/frp/frpc.toml
```

### 2. 基础配置示例

```toml
# 连接到服务端的地址和端口
serverAddr = "your_server_ip"
serverPort = 7000

# 认证token（必须与服务端一致）
auth.token = "your_secure_token_here"

# 日志配置
log.to = "./logs"
log.level = "info"
log.maxDays = 3

# 代理配置示例

# 示例1：SSH 端口映射
[[proxies]]
name = "ssh"
type = "tcp"
localIP = "127.0.0.1"
localPort = 22
remotePort = 6000

# 示例2：HTTP 网站映射
[[proxies]]
name = "web"
type = "http"
localIP = "127.0.0.1"
localPort = 80
customDomains = ["www.yourdomain.com"]

# 示例3：HTTPS 网站映射
[[proxies]]
name = "web-secure"
type = "https"
localIP = "127.0.0.1"
localPort = 443
customDomains = ["www.yourdomain.com"]

# 示例4：内网桌面远程（如 Windows RDP）
[[proxies]]
name = "rdp"
type = "tcp"
localIP = "192.168.1.100"
localPort = 3389
remotePort = 3389
```

### 3. 配置说明

#### 基本参数

| 参数 | 说明 |
|------|------|
| `serverAddr` | FRP 服务端的 IP 地址或域名 |
| `serverPort` | FRP 服务端监听的端口（默认 7000） |
| `auth.token` | 认证令牌，必须与服务端一致 |

#### 代理类型说明

**TCP 类型**：适用于 SSH、RDP、数据库等
- `localIP`：本地服务的 IP 地址
- `localPort`：本地服务的端口
- `remotePort`：服务端开放的端口

**HTTP/HTTPS 类型**：适用于 Web 服务
- `localIP`：本地 Web 服务的 IP 地址
- `localPort`：本地 Web 服务的端口
- `customDomains`：绑定的域名（需要在服务端配置域名）

### 4. 创建日志目录

```bash
sudo mkdir -p /opt/software/frp/logs
sudo chown -R $USER:$USER /opt/software/frp/logs
```

---

## 启动客户端

### 方式一：直接启动（测试）

```bash
cd /opt/software/frp
./frpc -c frpc.toml
```

按 `Ctrl+C` 停止服务。

### 方式二：使用 systemd（推荐）

#### 1. 创建 systemd 服务文件

```bash
sudo vi /etc/systemd/system/frpc.service
```

添加以下内容：

```ini
[Unit]
Description=Frp Client Service
After=network.target

[Service]
Type=simple
User=root
Restart=on-failure
RestartSec=5s
ExecStart=/opt/software/frp/frpc -c /opt/software/frp/frpc.toml
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
```

#### 2. 重新加载 systemd 并启动服务

```bash
sudo systemctl daemon-reload
sudo systemctl enable frpc
sudo systemctl start frpc
```

#### 3. 查看服务状态

```bash
sudo systemctl status frpc
```

#### 4. 查看日志

```bash
sudo journalctl -u frpc -f
```

---

## 验证连接

### 1. 检查客户端状态

```bash
sudo systemctl status frpc
```

确保服务处于 `active (running)` 状态。

### 2. 测试端口映射

根据你配置的代理类型进行测试：

#### SSH 示例
从外网访问：`ssh -p 6000 user@服务器IP`

#### HTTP 示例
浏览器访问：`http://www.yourdomain.com`

#### HTTPS 示例
浏览器访问：`https://www.yourdomain.com`

### 3. 查看服务端连接

登录 FRP 服务端管理面板（默认 http://服务器IP:7500），查看代理状态。

---

## 常用命令

```bash
# 启动服务
sudo systemctl start frpc

# 停止服务
sudo systemctl stop frpc

# 重启服务
sudo systemctl restart frpc

# 查看状态
sudo systemctl status frpc

# 查看日志
sudo journalctl -u frpc -f

# 测试配置文件是否正确
cd /opt/software/frp
./frpc verify -c frpc.toml
```

---

## 常见应用场景配置

### 1. 端口映射（SSH）

```toml
[[proxies]]
name = "ssh"
type = "tcp"
localIP = "127.0.0.1"
localPort = 22
remotePort = 6000
```

使用：`ssh -p 6000 user@服务器IP`

### 2. Web 服务（HTTP）

```toml
[[proxies]]
name = "web"
type = "http"
localIP = "127.0.0.1"
localPort = 8080
customDomains = ["blog.example.com"]
```

使用：浏览器访问 `http://blog.example.com`

### 3. MySQL 数据库

```toml
[[proxies]]
name = "mysql"
type = "tcp"
localIP = "127.0.0.1"
localPort = 3306
remotePort = 3306
```

使用：从外网连接 `服务器IP:3306`

### 4. 桌面远程（RDP）

```toml
[[proxies]]
name = "rdp"
type = "tcp"
localIP = "192.168.1.100"
localPort = 3389
remotePort = 3389
```

使用：从外网远程桌面连接 `服务器IP:3389`

### 5. 文件共享（NFS）

```toml
[[proxies]]
name = "nfs"
type = "tcp"
localIP = "127.0.0.1"
localPort = 2049
remotePort = 2049
```

### 6. STCP（安全 TCP 模式）

STCP 模式提供更高的安全性，只有知晓 secret 的客户端才能访问。

```toml
# 客户端 A（被访问端）配置
[[proxies]]
name = "secret_ssh"
type = "stcp"
secret = "your_secret_key"
localIP = "127.0.0.1"
localPort = 22
```

```toml
# 客户端 B（访问端）配置
[[visitors]]
name = "secret_ssh_visitor"
type = "stcp"
serverName = "secret_ssh"
secret = "your_secret_key"
bindAddr = "127.0.0.1"
bindPort = 6000
```

使用：`ssh -p 6000 user@127.0.0.1`

---

## 卸载

如需卸载 FRP 客户端：

```bash
# 停止并禁用服务
sudo systemctl stop frpc
sudo systemctl disable frpc

# 删除服务文件
sudo rm /etc/systemd/system/frpc.service

# 删除安装目录
sudo rm -rf /opt/software/frp

# 重新加载 systemd
sudo systemctl daemon-reload
```

---

## 故障排查

### 1. 连接失败

检查以下几点：
- 确认服务端 IP 和端口正确
- 确认 token 与服务端一致
- 检查防火墙是否阻止连接

### 2. 代理无法访问

- 确认本地服务正常运行
- 检查 localIP 和 localPort 配置正确
- 查看客户端日志：`sudo journalctl -u frpc -f`

### 3. 服务端显示未连接

- 检查网络连接
- 确认服务端正常运行
- 验证配置文件语法：`./frpc verify -c frpc.toml`

---

## 注意事项

1. **安全性**：
   - 不要在配置文件中使用明文密码
   - STCP 模式比普通 TCP 模式更安全
   - 定期更新 FRP 版本

2. **性能优化**：
   - 根据实际使用情况调整连接池大小
   - 生产环境建议开启 TLS 加密

3. **日志管理**：
   - 定期清理日志文件
   - 设置合理的日志级别

4. **域名配置**：
   - HTTP/HTTPS 代理需要域名解析到服务端 IP
   - 建议配置反向代理和 HTTPS 证书

---

## 参考资源

- FRP 官方文档：https://github.com/fatedier/frp
- FRP 配置说明：https://github.com/fatedier/frp/blob/dev/README.md
- FRP 示例配置：https://github.com/fatedier/frp/tree/dev/conf
