# 上传配置文件到服务器
scp config.txt root@192.168.1.100:/etc/

# 下载远程目录到本地
scp -r root@192.168.1.100:/var/log/ ./logs/

# 使用自定义端口和压缩
scp -C -P 2222 project.tar.gz user@server.com:/home/user/
