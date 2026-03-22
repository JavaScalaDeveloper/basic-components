# 1. 安装 Java 21 (OpenJDK)
sudo dnf install -y java-21-openjdk java-21-openjdk-devel

# 2. 安装 Maven (系统源中版本是 3.8.5/3.8.8)
sudo dnf install -y maven

# 3. 安装 Node.js 20 LTS (为了稳定兼容，使用官方 NodeSource 源安装较新版本)
# 3.1 添加 NodeSource 仓库 (这里安装 20.x LTS，比 24.x 更稳定)
curl -fsSL https://rpm.nodesource.com/setup_20.x | sudo bash -
# 3.2 安装 Node.js 和 npm
sudo dnf install -y nodejs
