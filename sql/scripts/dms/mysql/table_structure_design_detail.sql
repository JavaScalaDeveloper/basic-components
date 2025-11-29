use dms;
-- 表结构设计表
drop table if exists table_structure_design_detail;
CREATE TABLE table_structure_design_detail
(
    id                   BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键ID',
    create_time          DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    modify_time          DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
    creator              VARCHAR(64)  NOT NULL DEFAULT '' COMMENT '创建人',
    modifier             VARCHAR(64)  NOT NULL DEFAULT '' COMMENT '修改人',
    work_order_id        BIGINT       NOT NULL DEFAULT 0 COMMENT '工单ID',
    table_name           VARCHAR(255) NOT NULL DEFAULT '' COMMENT '表名',
    table_comment        VARCHAR(255) NOT NULL DEFAULT '' COMMENT '表描述',
    charset              VARCHAR(64)  NOT NULL DEFAULT '' COMMENT '字符集',
    auto_increment_start INT          NOT NULL DEFAULT 1 COMMENT '起始自增值',
    columns_info         TEXT         NOT NULL COMMENT '列信息（JSON数组）',
    indexes_info         TEXT         NOT NULL COMMENT '索引信息（JSON数组）',
    current_version      INT Unsigned NOT NULL DEFAULT 0 COMMENT '当前版本',
    operate_type         VARCHAR(16)  NOT NULL DEFAULT '' COMMENT '操作类型',
    INDEX idx_create_time (create_time),
    INDEX idx_modify_time (modify_time),
    UNIQUE uk_work_order_id_table_name (work_order_id, table_name)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4 COMMENT ='表结构设计表';