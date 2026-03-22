# 创建一个 2GB 的 swap 文件（大小建议为物理内存的 1-2 倍）
sudo fallocate -l 2G /swapfile

# 如果 fallocate 不支持，用 dd 命令
# sudo dd if=/dev/zero of=/swapfile bs=1M count=2048

# 只允许 root 读写，安全考虑
sudo chmod 600 /swapfile

sudo mkswap /swapfile
sudo swapon /swapfile
# 查看 swap 状态
sudo swapon --show

# 查看内存总体情况（会多出一行 Swap）
free -h

# 将配置写入 /etc/fstab
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab

# 查看当前 swappiness 值（默认 60）
cat /proc/sys/vm/swappiness

# 临时调整（建议设为 10-30，让系统优先使用物理内存）
sudo sysctl vm.swappiness=10

# 永久生效
echo 'vm.swappiness=10' | sudo tee -a /etc/sysctl.conf
