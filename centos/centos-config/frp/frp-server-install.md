# FRP 服务端安装指南

本文档介绍手动安装 FRP 服务端 (frp_0.61.2_linux_amd64) 的完整流程。

## 前置要求

- Linux 系统（CentOS/Ubuntu 等）
- root 或 sudo 权限
- 服务器需要有一个公网 IP 地址
- 确保服务器防火墙开放必要的端口（默认 7000、7500 等）

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

### 5. 验证安装

检查文件是否复制成功：

```bash
ls -lh /opt/software/frp/
```

应该看到以下文件：
- `frps` - 服务端程序
- `frps.toml` - 服务端配置文件
- `systemd/` - systemd 服务文件目录

---

## 配置服务端

### 1. 编辑配置文件

编辑 `/opt/software/frp/frps.toml`：

```bash
sudo vi /opt/software/frp/frps.toml
```

### 2. 基础配置示例

```toml
# 绑定端口
bindPort = 7000

# 认证token（请修改为复杂密码）
auth.token = "your_secure_token_here"

# 管理面板配置（可选）
webServer.addr = "0.0.0.0"
webServer.port = 7500
webServer.user = "admin"
webServer.password = "admin_password"

# 日志配置
log.to = "./logs"
log.level = "info"
log.maxDays = 3
```

### 3. 创建日志目录

```bash
sudo mkdir -p /opt/software/frp/logs
sudo chown -R $USER:$USER /opt/software/frp/logs
```

---

## 设置防火墙

如果使用 firewalld（CentOS）：

```bash
sudo firewall-cmd --permanent --add-port=7000/tcp
sudo firewall-cmd --permanent --add-port=7500/tcp
sudo firewall-cmd --reload
```

如果使用 ufw（Ubuntu）：

```bash
sudo ufw allow 7000/tcp
sudo ufw allow 7500/tcp
```

---

## 启动服务端

### 方式一：直接启动（测试）

```bash
cd /opt/software/frp
./frps -c frps.toml
```

按 `Ctrl+C` 停止服务。

### 方式二：使用 systemd（推荐）

#### 1. 创建 systemd 服务文件

```bash
sudo vi /etc/systemd/system/frps.service
```

添加以下内容：

```ini
[Unit]
Description=Frp Server Service
After=network.target

[Service]
Type=simple
User=root
Restart=on-failure
RestartSec=5s
ExecStart=/opt/software/frp/frps -c /opt/software/frp/frps.toml
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
```

#### 2. 重新加载 systemd 并启动服务

```bash
sudo systemctl daemon-reload
sudo systemctl enable frps
sudo systemctl start frps
```

#### 3. 查看服务状态

```bash
sudo systemctl status frps
```

#### 4. 查看日志

```bash
sudo journalctl -u frps -f
```

---

## 验证服务

### 1. 检查服务是否监听

```bash
sudo netstat -tlnp | grep frps
```

应该看到 frps 监听在 7000 和 7500 端口。

### 2. 测试管理面板

浏览器访问：`http://服务器IP:7500`

使用配置文件中设置的用户名和密码登录。

---

## 常用命令

```bash
# 启动服务
sudo systemctl start frps

# 停止服务
sudo systemctl stop frps

# 重启服务
sudo systemctl restart frps

# 查看状态
sudo systemctl status frps

# 查看日志
sudo journalctl -u frps -f
```

---

## 卸载

如需卸载 FRP 服务端：

```bash
# 停止并禁用服务
sudo systemctl stop frps
sudo systemctl disable frps

# 删除服务文件
sudo rm /etc/systemd/system/frps.service

# 删除安装目录
sudo rm -rf /opt/software/frp

# 重新加载 systemd
sudo systemctl daemon-reload
```

---

## 注意事项

1. **安全性**：
   - 务必修改默认的认证 token
   - 建议配置管理面板的用户名和密码
   - 不要暴露不必要的端口

2. **性能优化**：
   - 根据实际情况调整 `maxPoolCount` 参数
   - 生产环境建议开启 TLS 加密

3. **日志管理**：
   - 定期清理日志文件
   - 可以配置日志轮转

---

## 参考资源

- FRP 官方文档：https://github.com/fatedier/frp
- FRP 配置说明：https://github.com/fatedier/frp/blob/dev/README.md
