-- MySQL 离线扫描任务执行实例（一次「执行」一条记录）
use data_sec_umbrella;
drop table if exists db_asset_mysql_scan_offline_job_instance;
create table db_asset_scan_offline_job_instance
(
    id                 bigint auto_increment comment '主键ID'
        primary key,
    create_time        datetime    default CURRENT_TIMESTAMP not null comment '创建时间',
    modify_time        datetime    default CURRENT_TIMESTAMP not null on update CURRENT_TIMESTAMP comment '修改时间',
    creator            varchar(64) default ''                not null comment '创建人',
    modifier           varchar(64) default ''                not null comment '修改人',
    task_name          varchar(255)                          not null comment '任务名',
    run_status         varchar(32) default 'waiting'         not null comment 'waiting等待 running运行中 stopped已停止 completed已完成 failed已失败',
    success_count      int         default 0                 not null comment '运行成功个数',
    fail_count         int         default 0                 not null comment '运行失败个数',
    sensitive_count    int         default 0                 not null comment '敏感个数',
    expected_total     int         default 0                 not null comment '应扫描总数（表资产总数）',
    submitted_total    int         default 0                 not null comment '已提交总数（已发 MQ 数）',
    ai_success_count   int         default 0                 not null comment 'AI检测成功个数',
    ai_fail_count      int         default 0                 not null comment 'AI检测失败个数',
    ai_sensitive_count int         default 0                 not null comment 'AI检测敏感个数',
    ai_expected_total  int         default 0                 not null comment 'AI应扫描总数',
    ai_submitted_total int         default 0                 not null comment 'AI已提交总数（已发 MQ 数）',
    extend_info        text                                  null comment '拓展信息（JSON或错误原因等）',
    database_type      varchar(32) default ''                not null comment '数据库产品类型：MySQL / Clickhouse（与任务一致）'
)
    comment 'MySQL离线扫描任务执行实例';

create index idx_create_time
    on db_asset_scan_offline_job_instance (create_time);

create index idx_modify_time
    on db_asset_scan_offline_job_instance (modify_time);

create index idx_database_type
    on db_asset_scan_offline_job_instance (database_type);

create index idx_run_status
    on db_asset_scan_offline_job_instance (run_status);

create index idx_task_name
    on db_asset_scan_offline_job_instance (task_name);


# 100