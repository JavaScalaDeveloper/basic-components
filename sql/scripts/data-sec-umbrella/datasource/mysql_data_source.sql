use data_sec_umbrella;
drop table if exists mysql_data_source;
CREATE TABLE IF NOT EXISTS mysql_data_source
(
    id               bigint auto_increment comment '主键ID' primary key,
    create_time      datetime      default CURRENT_TIMESTAMP not null comment '创建时间',
    modify_time      datetime      default CURRENT_TIMESTAMP not null on update CURRENT_TIMESTAMP comment '修改时间',
    creator          varchar(64)   default ''                not null comment '创建人',
    modifier         varchar(64)   default ''                not null comment '修改人',
    data_source_type varchar(16)   default ''                not null comment '数据源类型（MySQL、Oracle、SQL Server等）',
    instance         varchar(255)  default ''                not null comment '实例（域名:端口）',
    username         varchar(64)   default ''                not null comment '用户名',
    password         varchar(1024) default ''                not null comment '密码（加密存储）',
    connectivity     varchar(16)   default ''                not null comment '连通性（可连接、无法连接）',
    extend_info      text          default null comment '拓展信息（JSON字符串）',
    UNIQUE KEY `uk_instance` (`instance`)
) comment 'MySQL数据源';
create index idx_create_time on mysql_data_source (create_time);
create index idx_modify_time on mysql_data_source (modify_time);