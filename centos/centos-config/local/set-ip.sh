#!/bin/bash

# ==============================================
# CentOS/Linux IP地址修改脚本
# 功能：快速修改系统网络接口的静态IP地址
# ==============================================
#!/bin/bash

if [ -z "$1" ]; then
    echo "用法: $0 <新IP地址>"
    exit 1
fi

NEW_IP="$1"
GATEWAY="192.168.1.1"
NETMASK="24"

# 获取第一个非 lo 的连接名称（兼容 ethernet/wifi）
CONN_NAME=$(nmcli -t -f NAME,TYPE con show | grep -v "loopback" | head -1 | cut -d: -f1)

if [ -z "$CONN_NAME" ]; then
    echo "错误：未找到活动的网络连接"
    exit 1
fi

echo "找到连接: $CONN_NAME"

nmcli con mod "$CONN_NAME" ipv4.addresses "$NEW_IP/$NETMASK"
nmcli con mod "$CONN_NAME" ipv4.gateway "$GATEWAY"
nmcli con mod "$CONN_NAME" ipv4.method manual
nmcli con mod "$CONN_NAME" ipv4.dns "8.8.8.8 114.114.114.114"

nmcli con down "$CONN_NAME"
nmcli con up "$CONN_NAME"

echo "IP已修改为: $NEW_IP"
ip addr show | grep -E "inet " | grep -v 127.0.0.1