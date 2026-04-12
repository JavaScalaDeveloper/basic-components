use data_sec_umbrella;
drop table if exists db_asset_mysql_scan_offline_job;
-- MySQL 数据资产离线扫描任务表
-- 执行前请在目标库中手工执行本脚本

CREATE TABLE IF NOT EXISTS db_asset_mysql_scan_offline_job
(
    id               BIGINT AUTO_INCREMENT COMMENT '主键ID' PRIMARY KEY,
    create_time      DATETIME              DEFAULT CURRENT_TIMESTAMP NOT NULL COMMENT '创建时间',
    modify_time      DATETIME              DEFAULT CURRENT_TIMESTAMP NOT NULL ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
    creator          VARCHAR(64)           DEFAULT '' NOT NULL COMMENT '创建人',
    modifier         VARCHAR(64)           DEFAULT '' NOT NULL COMMENT '修改人',
    task_name        VARCHAR(255) NOT NULL COMMENT '任务名',
    task_description VARCHAR(1024)         DEFAULT '' NOT NULL COMMENT '任务描述',
    sample_count     INT          NOT NULL DEFAULT 10 COMMENT '样例数（1~200）',
    sample_mode      VARCHAR(32)  NOT NULL DEFAULT 'sequence' COMMENT '取样方式：sequence顺序 reverse倒序 random随机',
    enable_sampling  TINYINT      NOT NULL DEFAULT 1 COMMENT '是否取样：0否 1是',
    enable_ai_scan   TINYINT      NOT NULL DEFAULT 0 COMMENT '是否启用AI扫描：0否 1是',
    scan_period      VARCHAR(32)  NOT NULL DEFAULT 'manual' COMMENT '扫描周期：manual手动 weekly每周一次 monthly每月一次',
    supported_tags   TEXT                  default NULL COMMENT '支持的标签（policy_code 列表，建议存 JSON 数组字符串）',
    scan_scope       VARCHAR(32)  NOT NULL DEFAULT 'all' COMMENT '扫描范围：all全部 instance实例',
    time_range_type  VARCHAR(32)  NOT NULL DEFAULT 'full' COMMENT '时间范围：full全量 incremental增量',
    enabled_status   TINYINT      NOT NULL DEFAULT 1 COMMENT '启用状态：0停用 1启用',
    UNIQUE KEY uk_task_name (task_name)
) COMMENT 'MySQL 数据资产离线扫描任务';

create index idx_create_time on db_asset_mysql_scan_offline_job (create_time);
create index idx_modify_time on db_asset_mysql_scan_offline_job (modify_time);

ALTER TABLE db_asset_mysql_scan_offline_job
    ADD COLUMN scan_instance_ids TEXT NULL COMMENT '实例范围' AFTER scan_scope;
