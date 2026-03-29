#在服务器上生成 SSH 密钥（如果还没有）：


ssh-keygen -t ed25519 -C "544789628@qq.com" -f ~/.ssh/github_arelore
# 一路回车，不设密码
#将公钥添加到 GitHub：


cat ~/.ssh/github_arelore.pub
#复制输出的内容，登录 GitHub → 进入 JavaScalaDeveloper/arelore 仓库 → Settings → Deploy keys → Add deploy key。勾选 Allow write access。
#配置 Git 使用 SSH：


# 配置仓库使用 SSH 地址
git remote set-url origin git@github.com:JavaScalaDeveloper/arelore.git

# 为这个仓库单独配置 SSH 密钥（可选，如果你有多个密钥）
# 在仓库目录下执行：
git config core.sshCommand "ssh -i ~/.ssh/github_arelore -o IdentitiesOnly=yes"
#测试连接并拉取：


ssh -T git@github.com
git pull

#如果报错：git@github.com: Permission denied (publickey).

# 1. 把专用密钥复制为默认密钥（先备份原来的，如果有的话）
cp ~/.ssh/github_arelore ~/.ssh/id_ed25519
cp ~/.ssh/github_arelore.pub ~/.ssh/id_ed25519.pub

# 2. 测试连接
ssh -T git@github.com