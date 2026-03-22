# 安装 Nginx
#sudo dnf install -y nginx

# 创建配置文件
sudo tee /etc/nginx/conf.d/arelore.conf << 'EOF'
server {
    listen 443 ssl;
    server_name www.arelore.com;  # 如果没有域名，用公网IP

    # 如果没有证书，先用 HTTP 测试（把上面 listen 443 ssl 改成 listen 80）
    location / {
        proxy_pass http://127.0.0.1:3000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
}
EOF

# 启动 Nginx
sudo systemctl start nginx
sudo systemctl enable nginx


