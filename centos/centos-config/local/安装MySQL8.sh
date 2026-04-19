#!/bin/bash

# ==========================================
# MySQL 8 手动安装命令集合 (CentOS 9/8)
# 功能: 提供手动安装 MySQL 8 的分步命令
# 使用方法: 参照以下命令逐步执行
# ==========================================

# 检查是否以 root 权限运行
if [ "$EUID" -ne 0 ]; then
    echo "错误: 请使用 sudo 权限运行此脚本"
    echo "用法: sudo ./安装MySQL8.sh"
    exit 1
fi

echo "=========================================="
echo "      MySQL 8 手动安装命令"
echo "=========================================="


#改密码
docker exec -it <你的容器名或ID> bash
mysql -u admin -p
ALTER USER 'admin'@'%' IDENTIFIED BY '59de91a6479c434abc13354e225b8fa6';
FLUSH PRIVILEGES;