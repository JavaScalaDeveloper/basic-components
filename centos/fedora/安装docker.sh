#!/bin/bash

# ==========================================
# Docker 安装脚本（Fedora）
# 功能: 一键安装 Docker CE 并配置国内镜像加速
# 使用方法: sudo ./安装docker.sh
# 说明: 需 Fedora（见 /etc/os-release 中 ID=fedora）；需 root 或 sudo
# ==========================================

set -euo pipefail

# 检查是否以 root 权限运行
if [ "${EUID:-}" -ne 0 ]; then
    echo "错误: 请使用 root 或 sudo 运行此脚本"
    echo "用法: sudo ./安装docker.sh"
    exit 1
fi

# 发行版检测：本脚本仅针对 Fedora
if [ -r /etc/os-release ]; then
    # shellcheck source=/dev/null
    . /etc/os-release
else
    echo "错误: 无法读取 /etc/os-release，无法判断发行版"
    exit 1
fi

if [ "${ID:-}" != "fedora" ]; then
    echo "错误: 当前系统为「${PRETTY_NAME:-未知}」，本脚本仅支持 Fedora"
    exit 1
fi

echo "=========================================="
echo "   Docker 自动化安装脚本（Fedora）"
echo "   系统: ${PRETTY_NAME:-Fedora}"
echo "=========================================="
echo ""

# 1. 卸载旧版本及可能冲突的 podman-docker（避免与 docker-ce 命令冲突）
echo "[步骤 1/7] 卸载旧版本 Docker / 冲突包..."
dnf remove -y \
    docker docker-client docker-client-latest docker-common \
    docker-latest docker-latest-logrotate docker-logrotate docker-engine \
    podman-docker \
    2>/dev/null || true
echo "✓ 旧版本与冲突包已清理（如有）"
echo ""

# 2. 安装依赖（curl：下载 .repo 与可选 compose；Fedora 41+ 为 DNF5，不再依赖 config-manager --add-repo）
echo "[步骤 2/7] 安装依赖包..."
dnf install -y curl
echo "✓ 依赖包安装完成"
echo ""

# 3. 添加 Docker CE 仓库：直接写入 /etc/yum.repos.d/，兼容 DNF4 与 DNF5（DNF5 无 --add-repo）
echo "[步骤 3/7] 添加 Docker CE 仓库..."
DOCKER_REPO_FILE="/etc/yum.repos.d/docker-ce.repo"
REPO_ADDED=0
for repo_url in \
    "https://mirrors.aliyun.com/docker-ce/linux/fedora/docker-ce.repo" \
    "https://download.docker.com/linux/fedora/docker-ce.repo"
do
    echo "尝试: ${repo_url}"
    if curl -fsSL -o "${DOCKER_REPO_FILE}" "${repo_url}" && [ -s "${DOCKER_REPO_FILE}" ]; then
        REPO_ADDED=1
        break
    fi
done

if [ "${REPO_ADDED}" -ne 1 ]; then
    echo "错误: 下载 Docker CE 仓库描述文件失败，请检查网络或镜像是否可用"
    exit 1
fi
echo "✓ 已写入 ${DOCKER_REPO_FILE}"
echo ""

# 4. 安装 Docker CE 与 Compose 插件
echo "[步骤 4/7] 安装 Docker CE..."
if ! dnf install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin; then
    echo "尝试仅安装核心包（不含 compose 插件）..."
    if ! dnf install -y docker-ce docker-ce-cli containerd.io; then
        echo "错误: Docker CE 安装失败"
        exit 1
    fi
fi
echo "✓ Docker CE 安装完成"
echo ""

# 5. 配置镜像加速与日志
echo "[步骤 5/7] 配置 daemon.json（镜像加速 / 日志）..."
mkdir -p /etc/docker
cat > /etc/docker/daemon.json <<'EOF'
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
echo "✓ daemon.json 已写入"
echo ""

# 6. 启动并启用 Docker
echo "[步骤 6/7] 启动 Docker 服务..."
systemctl daemon-reload
systemctl enable --now docker
echo "✓ Docker 已启动并设为开机自启"
echo ""

# 7. 验证
echo "[步骤 7/7] 验证安装..."
docker --version
echo ""

if docker run --rm hello-world; then
    echo "✓ 测试容器运行成功"
else
    echo "警告: hello-world 运行失败，请检查网络与镜像加速是否可用"
fi
echo ""

echo "=========================================="
echo "         Docker 安装完成"
echo "=========================================="
echo ""
echo "常用命令:"
echo "  systemctl status docker"
echo "  docker compose version   # 若已安装 compose 插件"
echo "  docker info | grep -A 10 \"Registry Mirrors\""
echo ""

# 若 dnf 未装上 compose 插件，则按架构下载官方 CLI 插件（可选兜底）
if ! docker compose version >/dev/null 2>&1; then
    echo "[可选] 未检测到 docker compose 插件，尝试安装独立 compose 二进制..."
    ARCH=$(uname -m)
    case "${ARCH}" in
        x86_64)  COMPOSE_ARCH="x86_64" ;;
        aarch64) COMPOSE_ARCH="aarch64" ;;
        *)
            echo "跳过: 不支持的架构 ${ARCH}，请手动安装 Docker Compose"
            COMPOSE_ARCH=""
            ;;
    esac
    if [ -n "${COMPOSE_ARCH}" ]; then
        mkdir -p /usr/local/lib/docker/cli-plugins
        if curl -fsSL "https://github.com/docker/compose/releases/latest/download/docker-compose-linux-${COMPOSE_ARCH}" \
            -o /usr/local/lib/docker/cli-plugins/docker-compose; then
            chmod +x /usr/local/lib/docker/cli-plugins/docker-compose
            docker compose version || true
        else
            echo "警告: 从 GitHub 下载 compose 失败，可稍后手动安装或重试"
        fi
    fi
fi

echo "当前 Registry Mirrors:"
docker info 2>/dev/null | grep -A 5 "Registry Mirrors" || true
echo ""
