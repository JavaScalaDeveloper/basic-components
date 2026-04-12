-- ClickHouse 数据源资产表（与 db_asset_mysql_* 同库、结构对齐，供离线/定时扫描写入；实例为 host:HTTP端口 等与数据源配置一致）
-- 敏感等级列类型与业务库中 MySQL 资产表保持一致时可按需改为 VARCHAR（若应用层按字符串读写）
use data_sec_umbrella;

CREATE TABLE db_asset_clickhouse_database_info
(
    id                   BIGINT AUTO_INCREMENT COMMENT '主键ID'
        PRIMARY KEY,
    create_time          DATETIME      DEFAULT CURRENT_TIMESTAMP NOT NULL COMMENT '创建时间',
    modify_time          DATETIME      DEFAULT CURRENT_TIMESTAMP NOT NULL ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
    modifier             VARCHAR(64)   DEFAULT ''                NOT NULL COMMENT '修改人',
    instance             VARCHAR(128)  DEFAULT ''                NOT NULL COMMENT '实例（域名:端口，与数据源 instance 一致）',
    database_name        VARCHAR(128)  DEFAULT ''                NOT NULL COMMENT 'ClickHouse 库名',
    description          VARCHAR(255)  DEFAULT ''                NOT NULL COMMENT '库描述/注释',
    sensitivity_level    TINYINT       DEFAULT 0                 NOT NULL COMMENT '敏感等级',
    sensitivity_tags     VARCHAR(1024) DEFAULT ''                NOT NULL COMMENT '敏感标签（逗号分隔）',
    ai_sensitivity_level TINYINT       DEFAULT 0                 NOT NULL COMMENT 'AI敏感等级',
    ai_sensitivity_tags  VARCHAR(1024) DEFAULT ''                NOT NULL COMMENT 'AI敏感标签（逗号分隔）',
    manual_sensitive     VARCHAR(32)                             NULL COMMENT '人工打标：IGNORE/FALSE_POSITIVE/SENSITIVE',
    CONSTRAINT uk_ch_instance_database_name
        UNIQUE (instance, database_name)
)
    COMMENT 'ClickHouse 数据库（库级）资产信息表';

CREATE INDEX idx_ch_db_create_time
    ON db_asset_clickhouse_database_info (create_time);

CREATE INDEX idx_ch_db_modify_time
    ON db_asset_clickhouse_database_info (modify_time);


CREATE TABLE db_asset_clickhouse_table_info
(
    id                   BIGINT AUTO_INCREMENT COMMENT '主键ID'
        PRIMARY KEY,
    create_time          DATETIME      DEFAULT CURRENT_TIMESTAMP NOT NULL COMMENT '创建时间',
    modify_time          DATETIME      DEFAULT CURRENT_TIMESTAMP NOT NULL ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
    modifier             VARCHAR(64)   DEFAULT ''                NOT NULL COMMENT '修改人',
    instance             VARCHAR(128)  DEFAULT ''                NOT NULL COMMENT '实例（域名:端口）',
    database_name        VARCHAR(128)  DEFAULT ''                NOT NULL COMMENT 'ClickHouse 库名',
    table_name           VARCHAR(128)  DEFAULT ''                NOT NULL COMMENT '表名',
    description          VARCHAR(255)  DEFAULT ''                NOT NULL COMMENT '表描述/注释',
    sensitivity_level    TINYINT       DEFAULT 0                 NOT NULL COMMENT '敏感等级',
    sensitivity_tags     VARCHAR(1024) DEFAULT ''                NOT NULL COMMENT '敏感标签（逗号分隔）',
    ai_sensitivity_level TINYINT       DEFAULT 0                 NOT NULL COMMENT 'AI敏感等级',
    ai_sensitivity_tags  VARCHAR(1024) DEFAULT ''                NOT NULL COMMENT 'AI敏感标签（逗号分隔）',
    manual_sensitive     VARCHAR(32)                             NULL COMMENT '人工打标：IGNORE/FALSE_POSITIVE/SENSITIVE',
    column_info          TEXT                                    NULL COMMENT '列信息（JSON格式）',
    column_scan_info     TEXT                                    NULL COMMENT '列扫描信息（JSON格式）',
    column_ai_scan_info  TEXT                                    NULL COMMENT '列AI扫描信息（JSON格式）',
    CONSTRAINT uk_ch_instance_database_table_name
        UNIQUE (instance, database_name, table_name)
)
    COMMENT 'ClickHouse 表级资产信息表';

CREATE INDEX idx_ch_tbl_create_time
    ON db_asset_clickhouse_table_info (create_time);

CREATE INDEX idx_ch_tbl_modify_time
    ON db_asset_clickhouse_table_info (modify_time);
