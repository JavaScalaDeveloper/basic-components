#!/bin/bash

set -e  # 遇到错误立即退出

echo "=== 开始安装 Ollama ==="

# 1. 解压本地安装包
echo "1. 解压本地安装包..."
cd /opt/software

# 检查安装包是否存在
if [ ! -f "ollama-linux-amd64.tar.zst" ]; then
    echo "错误: 未找到 ollama-linux-amd64.tar.zst"
    echo "请确保安装包位于 /opt/software/ 目录"
    exit 1
fi

# 解压 .zst 文件
#sudo dnf install -y zstd
echo "正在解压 ollama-linux-amd64.tar.zst..."
zstd -d ollama-linux-amd64.tar.zst -o ollama-linux-amd64.tar

# 解压 tar 文件
tar -xf ollama-linux-amd64.tar

# 查看解压后的目录结构
echo "解压后的文件列表:"
ls -la
echo ""
echo "bin 目录内容:"
ls -la bin/ 2>/dev/null || echo "bin 目录不存在"
echo ""
echo "lib 目录内容:"
ls -la lib/ 2>/dev/null || echo "lib 目录不存在"

# 查找 ollama 可执行文件
if [ -f "bin/ollama" ]; then
    cp bin/ollama ./ollama
    echo "从 bin/ 目录复制 ollama 可执行文件"
elif [ -f "ollama" ]; then
    echo "找到 ollama 可执行文件"
else
    echo "错误: 未找到 ollama 可执行文件"
    exit 1
fi

# 验证文件
if ! file ollama | grep -q "ELF"; then
    echo "错误: 文件不是有效的可执行文件"
    echo "文件实际内容:"
    cat ollama
    exit 1
fi

# 2. 停止旧服务
echo "2. 停止旧服务..."
sudo systemctl stop ollama 2>/dev/null || true
sudo systemctl disable ollama 2>/dev/null || true

# 3. 清理旧文件
echo "3. 清理旧文件..."
sudo rm -f /usr/local/bin/ollama /usr/bin/ollama

# 4. 安装新版本
echo "4. 安装新版本..."
sudo cp ollama /usr/bin/
sudo chmod +x /usr/bin/ollama
sudo ln -sf /usr/bin/ollama /usr/local/bin/ollama

# 5. 验证安装
echo "5. 验证安装..."
ollama --version

# 6. 创建用户和目录
echo "6. 创建用户和目录..."
sudo useradd -r -s /bin/false -m -d /usr/share/ollama ollama 2>/dev/null || true
sudo mkdir -p /usr/share/ollama/models
sudo chown -R ollama:ollama /usr/share/ollama

# 7. 创建服务
echo "7. 创建 systemd 服务..."
sudo tee /etc/systemd/system/ollama.service > /dev/null << 'EOF'
[Unit]
Description=Ollama Service
After=network-online.target

[Service]
ExecStart=/usr/bin/ollama serve
User=ollama
Group=ollama
Restart=always
RestartSec=3
Environment="PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
Environment="OLLAMA_HOST=0.0.0.0:11434"
Environment="OLLAMA_MODELS=/usr/share/ollama/models"

[Install]
WantedBy=default.target
EOF

# 8. 启动服务
echo "8. 启动服务..."
sudo systemctl daemon-reload
sudo systemctl start ollama
sudo systemctl enable ollama

# 9. 检查服务状态
echo "9. 检查服务状态..."
sudo systemctl status ollama --no-pager

# 10. 清理
echo "10. 清理临时文件..."
#rm -f /tmp/ollama

echo "=== Ollama 安装完成 ==="
echo "运行 'ollama --version' 验证安装"
echo "运行 'ollama run llama2' 测试模型"

#ollama run qwen3.5:0.8b
#ollama run qwen3:0.6b
#禁用思考
#/set nothink

#关闭防火墙
# 开放 11434 端口（TCP）
sudo firewall-cmd --permanent --add-port=11434/tcp

# 重新加载防火墙
sudo firewall-cmd --reload

# 验证端口已开放
sudo firewall-cmd --list-ports

# 再次查看防火墙规则
sudo firewall-cmd --list-all