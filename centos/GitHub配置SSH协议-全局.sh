# 1. 生成新的 Ed25519 密钥（使用当前日期避免重复）
ssh-keygen -t ed25519 -C "544789628@qq.com-$(date +%Y%m%d)" -f ~/.ssh/github_544789628

# 2. 启动 SSH agent
eval "$(ssh-agent -s)"

# 3. 添加新生成的私钥
ssh-add ~/.ssh/github_544789628

# 4. 配置 SSH 使用新密钥（覆盖或创建配置）
cat >> ~/.ssh/config << 'EOF'

# GitHub 专用配置
Host github.com
    HostName github.com
    User git
    IdentityFile ~/.ssh/github_544789628
    IdentitiesOnly yes
    Compression yes
    ServerAliveInterval 60
EOF

# 5. 设置权限
chmod 600 ~/.ssh/github_544789628
chmod 644 ~/.ssh/github_544789628.pub
chmod 600 ~/.ssh/config

# 6. 设置自动加载（添加到 ~/.bashrc）
echo 'eval "$(ssh-agent -s)"' >> ~/.bashrc
echo 'ssh-add ~/.ssh/github_544789628 2>/dev/null' >> ~/.bashrc

# 7. 显示公钥
echo "========== 公钥内容（复制到 GitHub） =========="
cat ~/.ssh/github_544789628.pub
echo "=============================================="

# 8. 如果安装了 xclip，复制到剪贴板
if command -v xclip &> /dev/null; then
    xclip -sel clip < ~/.ssh/github_544789628.pub
    echo "✓ 公钥已复制到剪贴板"
else
    echo "提示: 未安装 xclip，请手动复制上面的公钥"
fi

# 9. 测试连接（添加后执行）
echo ""
echo "请在 GitHub 添加公钥后，运行以下命令测试："
echo "ssh -T git@github.com"