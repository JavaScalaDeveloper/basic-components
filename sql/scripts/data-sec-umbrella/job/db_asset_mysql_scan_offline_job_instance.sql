-- MySQL 离线扫描任务执行实例（一次「执行」一条记录）
use data_sec_umbrella;
drop table if exists db_asset_mysql_scan_offline_job_instance;

CREATE TABLE IF NOT EXISTS db_asset_mysql_scan_offline_job_instance
(
    id                 BIGINT AUTO_INCREMENT COMMENT '主键ID' PRIMARY KEY,
    create_time        DATETIME              DEFAULT CURRENT_TIMESTAMP NOT NULL COMMENT '创建时间',
    modify_time        DATETIME              DEFAULT CURRENT_TIMESTAMP NOT NULL ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
    creator            VARCHAR(64)           DEFAULT '' NOT NULL COMMENT '创建人',
    modifier           VARCHAR(64)           DEFAULT '' NOT NULL COMMENT '修改人',
    task_name          VARCHAR(255) NOT NULL COMMENT '任务名',
    run_status         VARCHAR(32)  NOT NULL DEFAULT 'waiting' COMMENT 'waiting等待 running运行中 stopped已停止 completed已完成 failed已失败',
    success_count      INT          NOT NULL DEFAULT 0 COMMENT '运行成功个数',
    fail_count         INT          NOT NULL DEFAULT 0 COMMENT '运行失败个数',
    sensitive_count    INT          NOT NULL DEFAULT 0 COMMENT '敏感个数',
    expected_total     INT          NOT NULL DEFAULT 0 COMMENT '应扫描总数（表资产总数）',
    submitted_total    INT          NOT NULL DEFAULT 0 COMMENT '已提交总数（已发 MQ 数）',
    ai_success_count   INT          NOT NULL DEFAULT 0 COMMENT 'AI检测成功个数',
    ai_fail_count      INT          NOT NULL DEFAULT 0 COMMENT 'AI检测失败个数',
    ai_sensitive_count INT          NOT NULL DEFAULT 0 COMMENT 'AI检测敏感个数',
    ai_expected_total  INT          NOT NULL DEFAULT 0 COMMENT 'AI应扫描总数',
    ai_submitted_total INT          NOT NULL DEFAULT 0 COMMENT 'AI已提交总数（已发 MQ 数）',
    extend_info        TEXT         NULL COMMENT '拓展信息（JSON或错误原因等）',
    KEY idx_task_name (task_name),
    KEY idx_run_status (run_status)
) COMMENT 'MySQL离线扫描任务执行实例';


create index idx_create_time on db_asset_mysql_scan_offline_job_instance (create_time);
create index idx_modify_time on db_asset_mysql_scan_offline_job_instance (modify_time);

truncate db_asset_mysql_scan_offline_job_instance;
# 100