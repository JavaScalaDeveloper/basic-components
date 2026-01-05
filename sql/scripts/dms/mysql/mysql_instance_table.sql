use dms;

drop table if exists mysql_instance_info;

-- MySQL实例表
CREATE TABLE mysql_instance_info
(
    id          BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键ID',
    create_time DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    modify_time DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
    creator     VARCHAR(64)  NOT NULL DEFAULT '' COMMENT '创建人',
    modifier    VARCHAR(64)  NOT NULL DEFAULT '' COMMENT '修改人',
    name        VARCHAR(255) NOT NULL DEFAULT '' COMMENT '实例名称',
    host        VARCHAR(255) NOT NULL DEFAULT '' COMMENT '主机地址',
    port        INT          NOT NULL DEFAULT '' DEFAULT 3306 COMMENT '端口号',
    status      VARCHAR(16)  NOT NULL DEFAULT '' DEFAULT 'stopped' COMMENT '状态(running:运行中, stopped:已停止)',
    env         VARCHAR(16)  NOT NULL DEFAULT '' DEFAULT '' COMMENT '环境',
    INDEX idx_create_time (create_time),
    INDEX idx_modify_time (modify_time),
    UNIQUE uk_host (host),
    INDEX idx_name (name)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4 COMMENT ='MySQL实例表';


ALTER TABLE mysql_instance_info
    ADD COLUMN related_test_instance_host VARCHAR(255) COMMENT '关联测试实例host' AFTER env,
    ADD COLUMN related_pre_instance_host VARCHAR(255) COMMENT '关联预发实例host' AFTER related_test_instance_host,
    ADD COLUMN related_prd_instance_host VARCHAR(255) COMMENT '关联生产实例host' AFTER related_pre_instance_host;
