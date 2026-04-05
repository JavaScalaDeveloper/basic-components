use data_sec_umbrella;
drop table if exists db_asset_mysql_database_info;
drop table if exists db_asset_mysql_table_info;
-- 创建数据库信息表
CREATE TABLE IF NOT EXISTS db_asset_mysql_database_info
(
    id                   bigint auto_increment comment '主键ID' primary key,
    create_time          datetime      default CURRENT_TIMESTAMP not null comment '创建时间',
    modify_time          datetime      default CURRENT_TIMESTAMP not null on update CURRENT_TIMESTAMP comment '修改时间',
    modifier             varchar(64)   default ''                not null comment '修改人',
    instance             varchar(128)  default ''                not null comment '实例（域名:端口）',
    database_name        varchar(128)  default ''                not null comment '数据库名',
    description          varchar(512)  default ''                not null comment '数据库描述',
    sensitivity_level    TINYINT       default 0                 NOT NULL DEFAULT 0 not null comment '敏感等级',
    sensitivity_tags     varchar(1024) default ''                not null comment '敏感标签（逗号分隔）',
    ai_sensitivity_level TINYINT       default 0                 NOT NULL DEFAULT 0 not null comment 'AI敏感等级',
    ai_sensitivity_tags  varchar(1024) default ''                not null comment 'AI敏感标签（逗号分隔）',
    manual_sensitive     tinyint(1)    default 0                 not null comment '人审是否敏感',
    UNIQUE KEY `uk_instance_database_name` (`instance`, database_name)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_unicode_ci COMMENT ='MySQL数据库信息表';

-- 创建表信息表
CREATE TABLE IF NOT EXISTS db_asset_mysql_table_info
(
    id                   bigint auto_increment comment '主键ID' primary key,
    create_time          datetime      default CURRENT_TIMESTAMP not null comment '创建时间',
    modify_time          datetime      default CURRENT_TIMESTAMP not null on update CURRENT_TIMESTAMP comment '修改时间',
    modifier             varchar(64)   default ''                not null comment '修改人',
    instance             varchar(128)  default ''                not null comment '实例（域名:端口）',
    database_name        varchar(128)  default ''                not null comment '数据库名',
    table_name           varchar(128)  default ''                not null comment '表名',
    description          varchar(512)  default ''                not null comment '表描述',
    sensitivity_level    TINYINT       default 0                 not null comment '敏感等级',
    sensitivity_tags     varchar(1024) default ''                not null comment '敏感标签（逗号分隔）',
    ai_sensitivity_level TINYINT       default 0                 not null comment 'AI敏感等级',
    ai_sensitivity_tags  varchar(1024) default ''                not null comment 'AI敏感标签（逗号分隔）',
    manual_sensitive     tinyint(1)    default 0                 not null comment '人审是否敏感',
    column_info          text          default null comment '列信息（JSON格式）',
    column_scan_info     text          default null               comment '列扫描信息（JSON格式）',
    column_ai_scan_info  text          default null              comment '列AI扫描信息（JSON格式）',
    UNIQUE KEY `uk_instance_database_table_name` (`instance`, database_name, table_name)

) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_unicode_ci COMMENT ='MySQL表信息表';

-- 创建索引
create index idx_create_time on db_asset_mysql_database_info (create_time);
create index idx_modify_time on db_asset_mysql_database_info (modify_time);
create index idx_create_time on db_asset_mysql_table_info (create_time);
create index idx_modify_time on db_asset_mysql_table_info (modify_time);


# truncate db_asset_mysql_database_info;
# truncate db_asset_mysql_table_info;