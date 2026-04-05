use data_sec_umbrella;
# drop table if exists database_policy;
create table database_policy
(
    id                   bigint auto_increment comment '主键ID'
        primary key,
    create_time          datetime     default CURRENT_TIMESTAMP not null comment '创建时间',
    modify_time          datetime     default CURRENT_TIMESTAMP not null on update CURRENT_TIMESTAMP comment '修改时间',
    creator              varchar(64)  default ''                not null comment '创建人',
    modifier             varchar(64)  default ''                not null comment '修改人',
    policy_code          varchar(128)                           not null comment '策略code',
    policy_name          varchar(128)                           not null comment '策略名',
    description          varchar(255) default ''                not null comment '描述',
    sensitivity_level    tinyint      default 1                 not null comment '敏感等级 1-5，越高代表越敏感',
    hide_example         tinyint      default 0                 not null comment '隐藏样例 0-否 1-是',
    classification_rules json                                   null comment '分类规则',
    rule_expression      text                                   null comment '规则表达式',
    ai_rule              text                                   null comment 'AI规则',
    database_type        varchar(16)  default ''                not null comment '数据库类型',
    constraint uk_policy_code
        unique (policy_code)
)
    comment '数据库策略表' charset = utf8mb4;

create index idx_create_time
    on database_policy (create_time);

create index idx_modify_time
    on database_policy (modify_time);

