use data_sec_umbrella;
CREATE TABLE IF NOT EXISTS common_metric_history
(
    id            BIGINT AUTO_INCREMENT COMMENT '主键ID' PRIMARY KEY,
    create_time   DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL COMMENT '创建时间',
    modify_time   DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
    metric_code   VARCHAR(128)                       NOT NULL COMMENT '指标Code',
    metric_period VARCHAR(32)                        NOT NULL COMMENT '周期：DAY/WEEK/MONTH',
    metric_time   VARCHAR(16)                        NOT NULL COMMENT '时间：DAY=yyyyMMdd，MONTH=yyyyMM',
    metric_value  VARCHAR(2048)                      NULL COMMENT '指标值（可数字/字符串/JSON）',
    description   VARCHAR(512)                       NULL COMMENT '指标描述',
    extend_info   TEXT                               NULL COMMENT '拓展信息',
    UNIQUE KEY uk_metric_code_period_time (metric_code, metric_period, metric_time)
) COMMENT ='通用指标历史表';

create index idx_create_time on common_metric_history (create_time);
create index idx_modify_time on common_metric_history (modify_time);