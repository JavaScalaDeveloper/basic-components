docker run -d --name ddns-go --restart=always --net=host \
  -v /opt/software/ddns/ddns-go:/root \
  jeessy/ddns-go

#放行9876端口
sudo firewall-cmd --permanent --add-port=9876/tcp
sudo firewall-cmd --reload


sudo /usr/local/bin/ddns-go-6.14.1 -l :9876 -f 7200 -c /opt/software/ddns/ddns-go