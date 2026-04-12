use data_sec_umbrella;
drop table if exists admin_user;

CREATE TABLE IF NOT EXISTS admin_user
(
    id            BIGINT AUTO_INCREMENT COMMENT '主键ID' PRIMARY KEY,
    create_time   DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL COMMENT '创建时间',
    modify_time   DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
    creator       VARCHAR(64)                        NOT NULL COMMENT '创建人',
    modifier      VARCHAR(64)                        NOT NULL COMMENT '修改人',
    username      VARCHAR(64)                        NOT NULL COMMENT '用户名',
    password_hash VARCHAR(128)                       NOT NULL COMMENT '密码摘要（SHA-256）',
    role_code     VARCHAR(64)                        NOT NULL COMMENT '角色编码',
    product_permissions TEXT                          NOT NULL COMMENT '产品权限（逗号分隔：DATABASE,API,MQ）',
    status        TINYINT  DEFAULT 1                 NOT NULL COMMENT '状态：1启用，0禁用',
    UNIQUE KEY uk_admin_user_username (username)
) COMMENT ='管理中心账号表';
-- 创建索引
create index idx_create_time on admin_user (create_time);
create index idx_modify_time on admin_user (modify_time);