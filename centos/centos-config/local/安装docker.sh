#!/bin/bash

# ==========================================
# Docker 安装脚本 (CentOS 9/8)
# 功能: 一键安装 Docker 并配置国内镜像源
# 使用方法: sudo ./安装docker.创建Topic.sh
# ==========================================

# 检查是否以 root 权限运行
if [ "$EUID" -ne 0 ]; then
    echo "错误: 请使用 sudo 权限运行此脚本"
    echo "用法: sudo ./安装docker.sh"
    exit 1
fi

echo "=========================================="
echo "      Docker 自动化安装脚本"
echo "=========================================="
echo ""

# 1. 卸载旧版本（如果存在）
echo "[步骤 1/7] 卸载旧版本 Docker..."
dnf remove -y docker docker-client docker-client-latest docker-common docker-latest-latest docker-latest-logrotate docker-logrotate docker-engine 2>/dev/null
echo "✓ 旧版本已清理（如果有）"
echo ""

# 2. 安装依赖包
echo "[步骤 2/7] 安装依赖包..."
dnf install -y dnf-plugins-core device-mapper-persistent-data lvm2
if [ $? -ne 0 ]; then
    echo "错误: 依赖包安装失败"
    exit 1
fi
echo "✓ 依赖包安装完成"
echo ""

# 3. 添加 Docker 仓库（使用国内镜像源）
echo "[步骤 3/7] 添加 Docker 仓库..."

# 尝试使用阿里云镜像源
echo "尝试使用阿里云镜像源..."
dnf config-manager --add-repo https://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
if [ $? -ne 0 ]; then
    echo "阿里云镜像源失败，尝试官方源..."
    dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
    if [ $? -ne 0 ]; then
        echo "错误: 添加 Docker 仓库失败"
        exit 1
    fi
fi
echo "✓ Docker 仓库已添加"
echo ""

# 4. 安装 Docker CE
echo "[步骤 4/7] 安装 Docker CE..."

# 先尝试安装（跳过失败的包）
dnf install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin 2>&1
if [ $? -ne 0 ]; then
    echo "部分包安装失败，尝试不安装 buildx 插件..."
    # 如果失败，尝试不安装 buildx 和 scan 插件
    dnf install -y docker-ce docker-ce-cli containerd.io
    if [ $? -ne 0 ]; then
        echo "错误: Docker 安装失败"
        exit 1
    fi
    echo "✓ Docker CE 安装完成（不含 buildx/scan 插件）"
else
    echo "✓ Docker CE 安装完成"
fi
echo ""

# 5. 配置国内镜像源
echo "[步骤 5/7] 配置国内镜像源..."
mkdir -p /etc/docker
cat > /etc/docker/daemon.json <<EOF
{
  "registry-mirrors": [
    "https://docker.mirrors.ustc.edu.cn",
    "https://hub-mirror.c.163.com",
    "https://mirror.baidubce.com",
    "https://dockerhub.azk8s.cn"
  ],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m",
    "max-file": "3"
  },
  "storage-driver": "overlay2"
}
EOF
echo "✓ 镜像源配置完成"
echo ""
echo "已配置的镜像源:"
echo "  - 中科大镜像: https://docker.mirrors.ustc.edu.cn"
echo "  - 网易镜像:   https://hub-mirror.c.163.com"
echo "  - 百度云镜像: https://mirror.baidubce.com"
echo "  - Azure 镜像:  https://dockerhub.azk8s.cn"
echo ""

# 6. 启动 Docker 服务
echo "[步骤 6/7] 启动 Docker 服务..."
systemctl start docker
if [ $? -ne 0 ]; then
    echo "错误: Docker 服务启动失败"
    systemctl status docker
    exit 1
fi
echo "✓ Docker 服务启动成功"
echo ""

# 设置开机自启
systemctl enable docker
echo "✓ 开机自启已设置"
echo ""

# 7. 验证安装
echo "[步骤 7/7] 验证安装..."
docker --version
echo "✓ Docker 版本信息"
echo ""

# 运行测试容器
docker run --rm hello-world
if [ $? -ne 0 ]; then
    echo "错误: 测试容器运行失败"
    exit 1
fi
echo "✓ 测试容器运行成功"
echo ""

# 完成
echo "=========================================="
echo "         Docker 安装完成!"
echo "=========================================="
echo ""
echo "常用管理命令:"
echo "  启动 Docker:   systemctl start docker"
echo "  停止 Docker:   systemctl stop docker"
echo "  重启 Docker:   systemctl restart docker"
echo "  查看状态:     systemctl status docker"
echo "  查看 Docker 版本:   docker --version"
echo "  查看 Docker 信息:   docker info"
echo ""
echo "镜像管理命令:"
echo "  拉取镜像:     docker pull <镜像名>"
echo "  查看镜像:     docker images"
echo "  删除镜像:     docker rmi <镜像ID>"
echo ""
echo "容器管理命令:"
echo "  运行容器:     docker run <镜像名>"
echo "  查看容器:     docker ps"
echo "  停止容器:     docker stop <容器ID>"
echo "  删除容器:     docker rm <容器ID>"
echo ""
echo "查看镜像源配置:"
echo "  docker info | grep -A 10 \"Registry Mirrors\""
echo ""

# 显示当前镜像源配置
echo "=========================================="
echo "       当前镜像源配置:"
echo "=========================================="
docker info | grep -A 5 "Registry Mirrors"
echo ""


#安装docker-compose

# 1. 检查 Docker 是否已安装
docker --version

# 2. Docker Compose V2 通常随 Docker Engine 一起安装，如果没有，可以手动安装
# 设置插件目录
sudo mkdir -p /usr/local/lib/docker/cli-plugins

# 3. 下载 Docker Compose V2
sudo curl -SL https://github.com/docker/compose/releases/latest/download/docker-compose-linux-x86_64 -o /usr/local/lib/docker/cli-plugins/docker-compose

# 4. 赋予执行权限
sudo chmod +x /usr/local/lib/docker/cli-plugins/docker-compose

# 5. 验证安装
docker compose version