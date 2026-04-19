use data_sec_umbrella;
drop table if exists db_asset_mysql_scan_offline_job;
-- MySQL 数据资产离线扫描任务表
-- 执行前请在目标库中手工执行本脚本
create table db_asset_scan_offline_job
(
    id                bigint auto_increment comment '主键ID'
        primary key,
    create_time       datetime      default CURRENT_TIMESTAMP not null comment '创建时间',
    modify_time       datetime      default CURRENT_TIMESTAMP not null on update CURRENT_TIMESTAMP comment '修改时间',
    creator           varchar(64)   default ''                not null comment '创建人',
    modifier          varchar(64)   default ''                not null comment '修改人',
    task_name         varchar(255)                            not null comment '任务名',
    task_description  varchar(1024) default ''                not null comment '任务描述',
    sample_count      int           default 10                not null comment '样例数（1~200）',
    sample_mode       varchar(32)   default 'sequence'        not null comment '取样方式：sequence顺序 reverse倒序 random随机',
    enable_sampling   tinyint       default 1                 not null comment '是否取样：0否 1是',
    enable_ai_scan    tinyint       default 0                 not null comment '是否启用AI扫描：0否 1是',
    scan_period       varchar(32)   default 'manual'          not null comment '扫描周期：manual手动 weekly每周一次 monthly每月一次',
    supported_tags    text                                    null comment '支持的标签（policy_code 列表，建议存 JSON 数组字符串）',
    scan_scope        varchar(32)   default 'all'             not null comment '扫描范围：all全部 instance实例',
    scan_instance_ids text                                    null comment '实例范围',
    time_range_type   varchar(32)   default 'full'            not null comment '时间范围：full全量 incremental增量',
    enabled_status    tinyint       default 1                 not null comment '启用状态：0停用 1启用',
    database_type     varchar(32)   default ''                not null comment '数据库产品类型：MySQL / Clickhouse',
    constraint uk_task_name
        unique (task_name)
)
    comment 'MySQL 数据资产离线扫描任务';

create index idx_create_time
    on db_asset_scan_offline_job (create_time);

create index idx_modify_time
    on db_asset_scan_offline_job (modify_time);


create index idx_database_type
    on db_asset_scan_offline_job (database_type);
