use dms;
drop table if exists mysql_table_info;
-- MySQL表信息表
CREATE TABLE mysql_table_info
(
    id            BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键ID',
    create_time   DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    modify_time   DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
    creator       VARCHAR(64)  NOT NULL DEFAULT '' COMMENT '创建人',
    modifier      VARCHAR(64)  NOT NULL DEFAULT '' COMMENT '修改人',
    name          VARCHAR(255) NOT NULL DEFAULT '' COMMENT '表名称',
    db_name       VARCHAR(255) NOT NULL DEFAULT '' COMMENT '所属数据库名',
    instance_host VARCHAR(255) NOT NULL DEFAULT '' COMMENT '所属实例地址',
    row_count     BIGINT       NOT NULL DEFAULT 0 COMMENT '行数',
    size          VARCHAR(50) COMMENT '表大小',
    INDEX idx_create_time (create_time),
    INDEX idx_modify_time (modify_time),
    INDEX idx_name (name),
    unique uk_instance_host_db_name_name (instance_host, db_name, name)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4 COMMENT ='MySQL表信息表';