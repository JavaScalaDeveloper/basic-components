sudo passwd root

#允许root远程登录
sudo vim /etc/ssh/sshd_config

# 找到 PermitRootLogin 行，将 no 改为 yes
PermitRootLogin yes
#重启ssh
sudo systemctl restart sshd
reboot