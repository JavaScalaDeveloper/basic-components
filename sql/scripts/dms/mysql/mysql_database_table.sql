use dms;
-- MySQL数据库表
drop table if exists mysql_database_info;
CREATE TABLE mysql_database_info
(
    id            BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键ID',
    create_time   DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    modify_time   DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
    creator       VARCHAR(64)  NOT NULL DEFAULT '' COMMENT '创建人',
    modifier      VARCHAR(64)  NOT NULL DEFAULT '' COMMENT '修改人',
    name          VARCHAR(255) NOT NULL DEFAULT '' COMMENT '数据库名称',
    instance_host VARCHAR(255) NOT NULL DEFAULT '' COMMENT '所属实例地址',
    size          VARCHAR(64)           DEFAULT '' COMMENT '数据库大小',
    table_count   INT          NOT NULL DEFAULT 0 COMMENT '表数量',
    INDEX idx_create_time (create_time),
    INDEX idx_modify_time (modify_time),
    INDEX idx_name (name),
    UNIQUE uk_instance_host_name (instance_host,name)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4 COMMENT ='MySQL数据库表';

