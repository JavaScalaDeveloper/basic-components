use dms;

drop table if exists schema_design_work_order;

-- 结构设计工单表
CREATE TABLE schema_design_work_order
(
    id                 BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键ID',
    create_time        DATETIME                    NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    modify_time        DATETIME                    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
    creator            VARCHAR(64)                 NOT NULL DEFAULT '' COMMENT '创建人',
    modifier           VARCHAR(64)                 NOT NULL DEFAULT '' COMMENT '修改人',
    project_name       VARCHAR(255)                NOT NULL DEFAULT '' COMMENT '项目名称',
    database_type      VARCHAR(64)                 NOT NULL DEFAULT '' COMMENT '数据库类型',
    change_baseline    VARCHAR(255)                NOT NULL DEFAULT '' COMMENT '变更基准库',
    related_person     VARCHAR(255)                NOT NULL DEFAULT '' COMMENT '变更相关人',
    project_background VARCHAR(255)                NOT NULL DEFAULT '' COMMENT '项目背景',
    status             VARCHAR(32)                 NOT NULL DEFAULT '' COMMENT '工单状态',
    INDEX idx_create_time (create_time),
    INDEX idx_modify_time (modify_time),
    INDEX idx_project_name (project_name),
    INDEX idx_status (status)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4 COMMENT ='结构设计工单表';