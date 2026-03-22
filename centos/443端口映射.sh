# 1. 开启系统 IP 转发
sudo sysctl -w net.ipv4.ip_forward=1

# 2. 添加端口映射规则（443 -> 3000）
sudo iptables -t nat -A PREROUTING -p tcp --dport 443 -j REDIRECT --to-port 3000

# 3. 保存规则（CentOS 7+）
sudo yum install iptables-services -y
sudo service iptables save

# 或者使用 firewalld（CentOS 7 默认）
#sudo firewall-cmd --permanent --add-port=443/tcp
#sudo firewall-cmd --reload