#!/bin/bash
# 启动MySQL8容器，初始化root密码为123456
# 需要先拉取mysql:8镜像
# 使用方法：bash mysql8-docker-run.创建Topic.sh
sudo chmod 777 /var/lib/mysql

#docker run -d \
#  --name mysql8 \
#  --userns=keep-id \
#  -e MYSQL_ROOT_PASSWORD=123456 \
#  -p 3306:3306 \
#  -v $(pwd)/mysql-data:/var/lib/mysql \
#  mysql:8



# 使用你已有的镜像启动 MySQL
docker run -d \
  --name mysql8 \
  -p 3306:3306 \
  -e MYSQL_ROOT_PASSWORD=123456 \
  -e MYSQL_DATABASE=testdb \
  -e MYSQL_USER=testuser \
  -e MYSQL_PASSWORD=123456 \
  -v $(pwd)/mysql-data:/var/lib/mysql \
  docker.m.daocloud.io/mysql:8.0