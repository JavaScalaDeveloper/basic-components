docker exec -it rocketmq-broker sh mqadmin updateTopic \
  -n rocketmq-namesrv:9876 \
  -c DefaultCluster \
  -t OFFLINE_MYSQL_SCAN \
  -r 4 \
  -w 4


docker exec -it rabbitmq sh -lc '
rabbitmqadmin --username=admin --password=123456 declare exchange name=OFFLINE_MYSQL_SCAN type=topic durable=true &&
rabbitmqadmin --username=admin --password=123456 declare queue name=OFFLINE_MYSQL_SCAN durable=true &&
rabbitmqadmin --username=admin --password=123456 declare binding source=OFFLINE_MYSQL_SCAN destination_type=queue destination=OFFLINE_MYSQL_SCAN routing_key="OFFLINE_MYSQL_SCAN.*"
'


docker exec -it rabbitmq sh -lc '
rabbitmqadmin --username=admin --password=123456 declare exchange name=OFFLINE_MYSQL_AI_SCAN type=topic durable=true &&
rabbitmqadmin --username=admin --password=123456 declare queue name=OFFLINE_MYSQL_AI_SCAN durable=true &&
rabbitmqadmin --username=admin --password=123456 declare binding source=OFFLINE_MYSQL_AI_SCAN destination_type=queue destination=OFFLINE_MYSQL_AI_SCAN routing_key="OFFLINE_MYSQL_AI_SCAN.*"
'


docker exec -it rabbitmq sh -lc '
rabbitmqadmin --username=admin --password=123456 declare exchange name=OFFLINE_SCAN_SNAPSHOT_TABLE type=topic durable=true &&
rabbitmqadmin --username=admin --password=123456 declare queue name=OFFLINE_SCAN_SNAPSHOT_TABLE durable=true &&
rabbitmqadmin --username=admin --password=123456 declare binding source=OFFLINE_SCAN_SNAPSHOT_TABLE destination_type=queue destination=OFFLINE_SCAN_SNAPSHOT_TABLE routing_key="OFFLINE_SCAN_SNAPSHOT_TABLE.*"
'

docker exec -it rabbitmq sh -lc '
rabbitmqadmin --username=admin --password=123456 declare exchange name=OFFLINE_SCAN_SNAPSHOT_COLUMN type=topic durable=true &&
rabbitmqadmin --username=admin --password=123456 declare queue name=OFFLINE_SCAN_SNAPSHOT_COLUMN durable=true &&
rabbitmqadmin --username=admin --password=123456 declare binding source=OFFLINE_SCAN_SNAPSHOT_COLUMN destination_type=queue destination=OFFLINE_SCAN_SNAPSHOT_COLUMN routing_key="OFFLINE_SCAN_SNAPSHOT_COLUMN.*"
'

# 重启
docker compose -f docker-compose.yml down
docker compose -f docker-compose.yml up -d
docker logs -f rocketmq-broker
