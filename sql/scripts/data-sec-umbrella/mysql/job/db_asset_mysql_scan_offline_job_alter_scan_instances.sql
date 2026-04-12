-- 离线任务：扫描范围为「实例」时，指定 instance（与 db_asset_mysql_database_info.instance 一致）列表，JSON 数组
use data_sec_umbrella;


ALTER TABLE db_asset_mysql_scan_offline_job
    ADD COLUMN database_type VARCHAR(32) not null default '' COMMENT '数据库产品类型：MySQL / Clickhouse' AFTER enabled_status;

ALTER TABLE db_asset_mysql_scan_offline_job_instance
    ADD COLUMN database_type VARCHAR(32) not null default ''  COMMENT '数据库产品类型：MySQL / Clickhouse（与任务一致）' AFTER extend_info;

-- 历史数据默认视为 MySQL
UPDATE db_asset_mysql_scan_offline_job SET database_type = 'MySQL' WHERE database_type ='';
UPDATE db_asset_mysql_scan_offline_job_instance SET database_type = 'MySQL' WHERE database_type ='';
