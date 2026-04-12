-- ============================================
-- 1. 创建数据库
-- ============================================
CREATE DATABASE IF NOT EXISTS data_sec_demo;

-- 切换到该数据库（后续表将在该库下创建）
USE data_sec_demo;

-- ============================================
-- 2. 创建表及插入数据
-- ============================================

-- ---------------------------------------------------------------------
-- 表1: 用户身份信息表（包含敏感身份信息）
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS user_identity_core_information_snapshot_table
(
    user_id                UInt64 COMMENT '用户唯一ID',
    full_name              String COMMENT '真实姓名',
    id_card_number         String COMMENT '身份证号',
    phone_number           String COMMENT '手机号码',
    email_address          String COMMENT '电子邮箱',
    gender                 LowCardinality(String) COMMENT '性别',
    birth_date             Date COMMENT '出生日期',
    created_at             DateTime DEFAULT now() COMMENT '记录创建时间'
) ENGINE = MergeTree()
ORDER BY (user_id, created_at)
COMMENT '用户核心身份信息快照表';

-- 插入数据
INSERT INTO user_identity_core_information_snapshot_table
    (user_id, full_name, id_card_number, phone_number, email_address, gender, birth_date)
VALUES
    (1001, '张三丰', '11010119900307663X', '13812345678', 'zhang.san@example.com', '男', '1990-03-07'),
    (1002, '李四光', '110101198505154321', '13987654321', 'li.si@example.com', '男', '1985-05-15'),
    (1003, '王丽华', '110101199212121234', '13711223344', 'wang.lh@example.com', '女', '1992-12-12'),
    (1004, '赵晓明', '110101199810103456', '13699887766', 'zhao.xm@example.com', '男', '1998-10-10'),
    (1005, '陈思琪', '110101200005055678', '15900112233', 'chen.sq@example.com', '女', '2000-05-05');


-- ---------------------------------------------------------------------
-- 表2: 银行卡账户信息表
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS bank_card_account_details_information_table
(
    card_id                UInt64 COMMENT '卡片内部ID',
    user_id                UInt64 COMMENT '关联用户ID',
    bank_card_number       String COMMENT '银行卡号',
    bank_name              LowCardinality(String) COMMENT '开户银行名称',
    card_type              LowCardinality(String) COMMENT '卡片类型(借记卡/信用卡)',
    cvv_code               String COMMENT 'CVV安全码',
    expiry_date            String COMMENT '有效期(MM/YY)',
    binding_phone          String COMMENT '绑定手机号',
    is_active              UInt8 DEFAULT 1 COMMENT '是否激活(1:是,0:否)',
    created_at             DateTime DEFAULT now() COMMENT '绑定时间'
) ENGINE = MergeTree()
ORDER BY (user_id, card_id)
COMMENT '银行卡账户详细信息表';

INSERT INTO bank_card_account_details_information_table
    (card_id, user_id, bank_card_number, bank_name, card_type, cvv_code, expiry_date, binding_phone, is_active)
VALUES
    (5001, 1001, '6212260200123456789', '中国工商银行', '借记卡', '123', '12/28', '13812345678', 1),
    (5002, 1001, '6225880212345678901', '招商银行', '信用卡', '456', '08/27', '13812345678', 1),
    (5003, 1002, '6230580987654321123', '中国建设银行', '借记卡', '789', '03/29', '13987654321', 1),
    (5004, 1003, '6217850011223344556', '中国银行', '借记卡', '234', '10/26', '13711223344', 0),
    (5005, 1004, '6222620123456789012', '交通银行', '信用卡', '567', '05/30', '13699887766', 1);


-- ---------------------------------------------------------------------
-- 表3: 用户登录行为审计日志表
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS user_login_behavior_audit_log_records_table
(
    log_id                 UInt64,
    user_id                UInt64,
    login_ip               String,
    login_location         String,
    login_device           String,
    login_result           LowCardinality(String),
    failure_reason         String,
    login_time             DateTime
) ENGINE = MergeTree()
ORDER BY (user_id, login_time)
COMMENT '用户登录行为审计日志记录表';

INSERT INTO user_login_behavior_audit_log_records_table VALUES
    (100001, 1001, '192.168.1.105', '北京市', 'iPhone 14', '成功', '', '2025-04-01 08:30:15'),
    (100002, 1001, '10.0.0.23', '上海市', 'Windows PC', '成功', '', '2025-04-01 19:45:22'),
    (100003, 1002, '172.16.8.99', '广州市', 'Android手机', '失败', '密码错误', '2025-04-02 09:12:03'),
    (100004, 1002, '172.16.8.99', '广州市', 'Android手机', '成功', '', '2025-04-02 09:15:47'),
    (100005, 1003, '192.168.10.56', '深圳市', 'MacBook Pro', '成功', '', '2025-04-02 14:20:33'),
    (100006, 1004, '10.10.10.88', '成都市', 'iPad', '成功', '', '2025-04-03 10:05:11'),
    (100007, 1005, '192.168.1.200', '杭州市', 'Windows PC', '失败', '账号不存在', '2025-04-03 22:30:00'),
    (100008, 1005, '192.168.1.200', '杭州市', 'Windows PC', '成功', '', '2025-04-03 22:32:18');


-- ---------------------------------------------------------------------
-- 表4: 交易流水明细记录表
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS transaction_flow_detail_records_daily_table
(
    transaction_id         String,
    user_id                UInt64,
    card_id                UInt64,
    transaction_amount     Decimal64(2),
    transaction_type       LowCardinality(String),
    counterparty_name      String,
    counterparty_account   String,
    transaction_status     LowCardinality(String),
    transaction_time       DateTime
) ENGINE = MergeTree()
ORDER BY (user_id, transaction_time)
COMMENT '交易流水明细记录日表';

INSERT INTO transaction_flow_detail_records_daily_table VALUES
    ('T202504010001', 1001, 5001, 299.00, '消费', '京东商城', '110112233445566', '成功', '2025-04-01 10:25:33'),
    ('T202504010002', 1001, 5002, 1250.00, '转账', '李四光', '6212260200123456790', '成功', '2025-04-01 14:10:22'),
    ('T202504020003', 1002, 5003, 88.50, '消费', '美团外卖', '6230580987654321124', '成功', '2025-04-02 12:05:17'),
    ('T202504020004', 1002, 5003, 3500.00, '取现', 'ATM-广州天河', '', '成功', '2025-04-02 18:30:45'),
    ('T202504030005', 1003, 5004, 168.00, '消费', '滴滴出行', '6217850011223344557', '失败', '2025-04-03 09:48:02'),
    ('T202504030006', 1004, 5005, 4599.00, '消费', 'Apple Store', '6222620123456789013', '成功', '2025-04-03 16:22:19'),
    ('T202504030007', 1005, 0, 199.00, '充值', '中国移动', '13800138000', '成功', '2025-04-03 20:15:44');


-- ---------------------------------------------------------------------
-- 表5: 敏感数据访问权限申请表
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS sensitive_data_access_permission_application_form_table
(
    application_id         UInt64,
    applicant_name         String,
    applicant_department   String,
    target_data_table      String,
    access_reason          String,
    requested_columns      String,
    approval_status        LowCardinality(String),
    approver_name          String,
    apply_time             DateTime,
    approved_time          Nullable(DateTime)
) ENGINE = MergeTree()
ORDER BY (application_id, apply_time)
COMMENT '敏感数据访问权限申请表';

INSERT INTO sensitive_data_access_permission_application_form_table VALUES
    (2001, '张三丰', '风控部', 'user_identity_core_information_snapshot_table', '风险案件调查', 'full_name,id_card_number,phone_number', '已批准', '李总监', '2025-03-25 09:00:00', '2025-03-26 14:30:00'),
    (2002, '李四光', '数据分析部', 'bank_card_account_details_information_table', '用户画像分析', 'bank_name,card_type', '已批准', '王经理', '2025-03-28 11:20:00', '2025-03-29 10:15:00'),
    (2003, '王丽华', '运营部', 'transaction_flow_detail_records_daily_table', '营销活动分析', 'transaction_amount,transaction_type', '审核中', '赵主管', '2025-04-02 15:45:00', NULL),
    (2004, '赵晓明', '安全审计部', 'user_login_behavior_audit_log_records_table', '安全事件排查', 'login_ip,login_device,login_time', '已拒绝', '孙总监', '2025-04-03 08:30:00', '2025-04-03 17:20:00');


-- ---------------------------------------------------------------------
-- 表6: 数据脱敏规则配置表
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS data_masking_rules_configuration_metadata_table
(
    rule_id                UInt64,
    rule_name              String,
    table_name_pattern     String,
    column_name_pattern    String,
    masking_type           LowCardinality(String),
    masking_parameter      String,
    is_enabled             UInt8,
    created_by             String,
    created_time           DateTime
) ENGINE = MergeTree()
ORDER BY (rule_id)
COMMENT '数据脱敏规则配置元数据表';

INSERT INTO data_masking_rules_configuration_metadata_table VALUES
    (1, '身份证号脱敏', 'user_identity_core_information_snapshot_table', 'id_card_number', '保留前6后4', '****', 1, '安全管理员', '2025-01-10 10:00:00'),
    (2, '手机号脱敏', 'user_identity_core_information_snapshot_table', 'phone_number', '保留前3后4', '****', 1, '安全管理员', '2025-01-10 10:00:00'),
    (3, '银行卡号脱敏', 'bank_card_account_details_information_table', 'bank_card_number', '保留前6后4', '******', 1, '数据治理组', '2025-02-15 14:30:00'),
    (4, '邮箱脱敏', 'user_identity_core_information_snapshot_table', 'email_address', '保留前2位', '***@***', 0, '安全管理员', '2025-03-01 09:20:00');


-- ---------------------------------------------------------------------
-- 表7: 数据分类分级标签表
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS data_classification_grade_tag_management_table
(
    tag_id                 UInt64,
    data_asset_name        String,
    sensitivity_level      LowCardinality(String),
    data_category          String,
    owner_department       String,
    retention_days         UInt16,
    encryption_required    UInt8,
    last_review_time       DateTime
) ENGINE = MergeTree()
ORDER BY (tag_id)
COMMENT '数据分类分级标签管理表';

INSERT INTO data_classification_grade_tag_management_table VALUES
    (101, 'user_identity_core_information_snapshot_table', 'L4-极高敏感', '个人身份信息', '信息安全部', 1825, 1, '2025-03-20 16:00:00'),
    (102, 'bank_card_account_details_information_table', 'L4-极高敏感', '金融账户信息', '财务部', 2190, 1, '2025-03-20 16:00:00'),
    (103, 'transaction_flow_detail_records_daily_table', 'L3-高度敏感', '交易行为数据', '业务运营部', 730, 1, '2025-03-20 16:00:00'),
    (104, 'user_login_behavior_audit_log_records_table', 'L2-中度敏感', '系统日志数据', '技术保障部', 180, 0, '2025-03-20 16:00:00'),
    (105, 'sensitive_data_access_permission_application_form_table', 'L2-中度敏感', '权限申请记录', '安全管理部', 1095, 0, '2025-03-20 16:00:00');


-- ---------------------------------------------------------------------
-- 表8: 数据安全事件告警记录表
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS data_security_incident_alert_log_historical_table
(
    alert_id               UInt64,
    alert_name             String,
    severity_level         LowCardinality(String),
    affected_data_table    String,
    affected_columns       String,
    alert_source           String,
    alert_description      String,
    handler_name           String,
    handle_status          LowCardinality(String),
    occurred_time          DateTime,
    resolved_time          Nullable(DateTime)
) ENGINE = MergeTree()
ORDER BY (occurred_time)
COMMENT '数据安全事件告警日志历史表';

INSERT INTO data_security_incident_alert_log_historical_table VALUES
    (3001, '敏感数据批量导出', '高危', 'user_identity_core_information_snapshot_table', 'id_card_number,phone_number', '数据防泄漏系统', '张三丰账号在非工作时间导出超过500条敏感数据', '李响应', '已处置', '2025-03-28 23:15:00', '2025-03-29 09:00:00'),
    (3002, '异常登录尝试', '中危', 'user_login_behavior_audit_log_records_table', '', '堡垒机', '来自异常IP 185.xx.xx.xx的连续登录失败', '王安全', '处理中', '2025-04-02 03:22:00', NULL),
    (3003, '数据库查询超时', '低危', 'transaction_flow_detail_records_daily_table', '', '数据库监控', '全表扫描导致响应缓慢', '张DBA', '已处置', '2025-04-01 14:30:00', '2025-04-01 15:45:00');


-- ---------------------------------------------------------------------
-- 表9: 数据备份恢复任务配置表
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS data_backup_recovery_task_scheduled_configuration_table
(
    task_id                UInt64,
    task_name              String,
    target_table           String,
    backup_type            LowCardinality(String),
    backup_schedule        String,
    retention_backup_count UInt8,
    last_backup_time       DateTime,
    next_backup_time       DateTime,
    is_active              UInt8
) ENGINE = MergeTree()
ORDER BY (task_id)
COMMENT '数据备份恢复任务调度配置表';

INSERT INTO data_backup_recovery_task_scheduled_configuration_table VALUES
    (4001, '用户身份表每日备份', 'user_identity_core_information_snapshot_table', '全量备份', '每天02:00', 30, '2025-04-03 02:00:00', '2025-04-04 02:00:00', 1),
    (4002, '交易流水表每周备份', 'transaction_flow_detail_records_daily_table', '增量备份', '每周日03:00', 12, '2025-03-31 03:00:00', '2025-04-07 03:00:00', 1),
    (4003, '银行卡表季度归档', 'bank_card_account_details_information_table', '归档备份', '每季度首月1日04:00', 4, '2025-01-01 04:00:00', '2025-04-01 04:00:00', 0);


-- ---------------------------------------------------------------------
-- 表10: 用户访问日志分析聚合表（示例数据）
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS user_access_log_aggregated_daily_statistics_materialized_table
(
    user_id                UInt64,
    access_date            Date,
    total_access_count     UInt32,
    unique_ip_count        UInt32,
    failed_login_count     UInt32,
    avg_session_duration   UInt32
) ENGINE = SummingMergeTree()
ORDER BY (user_id, access_date)
COMMENT '用户访问日志聚合每日统计物化表';

INSERT INTO user_access_log_aggregated_daily_statistics_materialized_table VALUES
    (1001, '2025-04-01', 5, 2, 0, 1800),
    (1002, '2025-04-02', 8, 1, 1, 2400),
    (1003, '2025-04-02', 3, 1, 0, 900),
    (1004, '2025-04-03', 4, 1, 0, 1200),
    (1005, '2025-04-03', 2, 1, 1, 600);

-- ---------------------------------------------------------------------
-- 表11: 数据合规审计检查清单表
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS data_compliance_audit_inspection_checklist_result_table
(
    check_id               UInt64,
    check_item_name        String,
    applicable_regulation  String,
    target_data_scope      String,
    check_result           LowCardinality(String),
    violation_details      String,
    auditor_name           String,
    check_date             Date
) ENGINE = MergeTree()
ORDER BY (check_date)
COMMENT '数据合规审计检查清单结果表';

INSERT INTO data_compliance_audit_inspection_checklist_result_table VALUES
    (5001, '敏感数据加密存储检查', 'GDPR/PIPL', 'user_identity_core_information_snapshot_table.id_card_number', '通过', '', '审计员A', '2025-03-15'),
    (5002, '数据保留期限合规性', '个人信息保护法', 'user_login_behavior_audit_log_records_table', '不通过', '日志数据保留超过180天未归档', '审计员B', '2025-03-15'),
    (5003, '访问权限最小化原则', 'ISO 27001', 'sensitive_data_access_permission_application_form_table', '通过', '', '审计员A', '2025-03-20'),
    (5004, '数据脱敏效果验证', '企业安全规范', 'bank_card_account_details_information_table.bank_card_number', '部分通过', '部分查询未脱敏', '审计员C', '2025-03-25');

-- ---------------------------------------------------------------------
-- 表12: 数据质量监控规则表
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS data_quality_monitoring_rule_definition_detailed_table
(
    rule_id                UInt64,
    rule_name              String,
    target_table           String,
    target_column          String,
    validation_type        LowCardinality(String),
    threshold_min          Float64,
    threshold_max          Float64,
    alert_level            LowCardinality(String),
    is_active              UInt8
) ENGINE = MergeTree()
ORDER BY (rule_id)
COMMENT '数据质量监控规则定义明细表';

INSERT INTO data_quality_monitoring_rule_definition_detailed_table VALUES
    (6001, '身份证号格式校验', 'user_identity_core_information_snapshot_table', 'id_card_number', '正则匹配', 99.5, 100, '高', 1),
    (6002, '手机号空值率检查', 'user_identity_core_information_snapshot_table', 'phone_number', '空值率', 0, 1, '高', 1),
    (6003, '交易金额合理性', 'transaction_flow_detail_records_daily_table', 'transaction_amount', '范围', 0, 100000, '中', 1),
    (6004, '银行卡号Luhn校验', 'bank_card_account_details_information_table', 'bank_card_number', '算法校验', 99, 100, '高', 0);


-- ============================================
-- 继续在 data_sec_demo 数据库下创建更多表
-- ============================================

USE data_sec_demo;

-- ---------------------------------------------------------------------
-- 表13: 数据导出审批记录表
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS data_export_approval_workflow_records_audit_table
(
    export_id              UInt64,
    applicant_name         String,
    export_data_scope      String,
    export_format          LowCardinality(String),
    target_tables          String,
    estimated_row_count    UInt32,
    approval_status        LowCardinality(String),
    approver_comment       String,
    apply_time             DateTime,
    approval_time          Nullable(DateTime),
    export_file_path       String
) ENGINE = MergeTree()
      ORDER BY (export_id, apply_time)
      COMMENT '数据导出审批工作流记录审计表';

INSERT INTO data_export_approval_workflow_records_audit_table VALUES
                                                                  (7001, '张三丰', '风控报表-2025年3月', 'CSV', 'transaction_flow_detail_records_daily_table', 15000, '已批准', '用于季度风控报告', '2025-04-01 09:00:00', '2025-04-01 14:30:00', '/data/export/risk_report_202503.csv'),
                                                                  (7002, '李四光', '用户画像分析', 'Parquet', 'user_identity_core_information_snapshot_table,bank_card_account_details_information_table', 5000, '审核中', '', '2025-04-02 11:20:00', NULL, ''),
                                                                  (7003, '王丽华', '营销活动名单', 'Excel', 'user_identity_core_information_snapshot_table', 800, '已拒绝', '涉及敏感个人信息，不符合数据安全规范', '2025-04-03 15:00:00', '2025-04-03 16:45:00', ''),
                                                                  (7004, '赵晓明', '安全审计日志导出', 'JSON', 'user_login_behavior_audit_log_records_table', 320, '已批准', '安全事件调查需要', '2025-04-04 10:00:00', '2025-04-04 11:00:00', '/data/export/security_logs_202504.json');


-- ---------------------------------------------------------------------
-- 表14: 匿名化数据发布记录表
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS anonymized_data_publishing_history_tracking_table
(
    publish_id             UInt64,
    original_table         String,
    anonymized_table       String,
    anonymization_algorithm String,
    k_anonymity_value      UInt8,
    l_diversity_value      UInt8,
    data_purpose           String,
    publisher_name         String,
    approver_name          String,
    publish_date           Date,
    is_active              UInt8
) ENGINE = MergeTree()
      ORDER BY (publish_date)
      COMMENT '匿名化数据发布历史追踪表';

INSERT INTO anonymized_data_publishing_history_tracking_table VALUES
                                                                  (8001, 'user_identity_core_information_snapshot_table', 'anon_user_info_202503', '泛化+抑制', 5, 3, '学术研究', '王安全', '李总监', '2025-03-20', 1),
                                                                  (8002, 'transaction_flow_detail_records_daily_table', 'anon_transaction_202503', '数据扰动', 4, 2, '数据分析竞赛', '张数据', '赵主管', '2025-03-25', 1),
                                                                  (8003, 'bank_card_account_details_information_table', 'anon_bank_card_202504', '哈希脱敏', 3, 2, '内部测试', '李开发', '孙经理', '2025-04-01', 0);


-- ---------------------------------------------------------------------
-- 表15: 数据访问权限角色映射表
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS data_access_permission_role_mapping_relationship_table
(
    mapping_id             UInt64,
    role_name              LowCardinality(String),
    accessible_tables      String,
    accessible_columns     String,
    row_level_filter       String,
    permission_type        LowCardinality(String),
    effective_start_date   Date,
    effective_end_date     Date,
    created_by             String
) ENGINE = MergeTree()
      ORDER BY (mapping_id)
      COMMENT '数据访问权限角色映射关系表';

INSERT INTO data_access_permission_role_mapping_relationship_table VALUES
                                                                       (9001, '风控分析师', 'transaction_flow_detail_records_daily_table', 'transaction_amount,transaction_type,transaction_time', 'user_id IN (SELECT user_id FROM risk_users)', '只读', '2025-01-01', '2025-12-31', '管理员'),
                                                                       (9002, '安全审计员', 'user_login_behavior_audit_log_records_table,data_security_incident_alert_log_historical_table', '*', '1=1', '读写', '2025-01-01', '2025-12-31', '管理员'),
                                                                       (9003, '数据治理专员', 'data_classification_grade_tag_management_table,data_masking_rules_configuration_metadata_table', '*', '1=1', '读写', '2025-01-01', '2025-12-31', '管理员'),
                                                                       (9004, '普通运营', 'user_identity_core_information_snapshot_table', 'user_id,full_name,gender', 'department=''运营部''', '只读', '2025-01-01', '2025-06-30', '管理员');


-- ---------------------------------------------------------------------
-- 表16: 数据加密密钥生命周期管理表
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS data_encryption_key_lifecycle_management_log_table
(
    key_id                 String,
    key_alias              String,
    key_algorithm          LowCardinality(String),
    key_size               UInt16,
    target_data_tables     String,
    key_status             LowCardinality(String),
    creation_time          DateTime,
    activation_time        Nullable(DateTime),
    expiration_time        Nullable(DateTime),
    revocation_time        Nullable(DateTime),
    created_by             String
) ENGINE = MergeTree()
      ORDER BY (key_id, creation_time)
      COMMENT '数据加密密钥生命周期管理日志表';

INSERT INTO data_encryption_key_lifecycle_management_log_table VALUES
                                                                   ('key_001', '用户身份表加密密钥', 'AES-256-GCM', 256, 'user_identity_core_information_snapshot_table', '激活', '2024-12-01 10:00:00', '2024-12-01 12:00:00', '2025-12-01 23:59:59', NULL, '安全管理员'),
                                                                   ('key_002', '银行卡表加密密钥', 'SM4-CBC', 128, 'bank_card_account_details_information_table', '激活', '2024-12-15 09:00:00', '2024-12-15 11:00:00', '2025-12-15 23:59:59', NULL, '安全管理员'),
                                                                   ('key_003', '旧版交易表密钥', 'AES-128-CBC', 128, 'transaction_flow_detail_records_daily_table', '已吊销', '2024-06-01 08:00:00', '2024-06-01 10:00:00', '2024-12-01 23:59:59', '2025-01-15 14:00:00', '安全管理员'),
                                                                   ('key_004', '新版交易表密钥', 'AES-256-GCM', 256, 'transaction_flow_detail_records_daily_table', '激活', '2025-01-15 13:00:00', '2025-01-15 15:00:00', '2026-01-15 23:59:59', NULL, '安全管理员');


-- ---------------------------------------------------------------------
-- 表17: 数据泄露事件影响评估表
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS data_breach_incident_impact_assessment_record_table
(
    incident_id            UInt64,
    incident_name          String,
    affected_data_tables   String,
    estimated_affected_records UInt32,
    data_sensitivity_level LowCardinality(String),
    potential_risk_description String,
    assessment_conclusion  String,
    remediation_actions    String,
    discovery_time         DateTime,
    assessment_complete_time Nullable(DateTime),
    reporter_name          String
) ENGINE = MergeTree()
      ORDER BY (incident_id)
      COMMENT '数据泄露事件影响评估记录表';

INSERT INTO data_breach_incident_impact_assessment_record_table VALUES
                                                                    (10001, '测试环境数据泄露', 'user_identity_core_information_snapshot_table', 5000, 'L4-极高敏感', '测试环境包含生产真实身份证号', '已确认泄露', '立即下线测试环境，执行数据清理，更换所有泄露密钥', '2025-03-10 14:30:00', '2025-03-12 18:00:00', '安全监控系统'),
                                                                    (10002, '运维人员违规导出', 'transaction_flow_detail_records_daily_table', 1200, 'L3-高度敏感', '运维人员私自导出交易明细到个人U盘', '已确认', '吊销涉事人员权限，启动内部调查，加强DLP监控', '2025-03-20 09:15:00', '2025-03-22 16:30:00', 'DLP审计日志'),
                                                                    (10003, 'API接口数据暴露', 'bank_card_account_details_information_table', 80, 'L4-极高敏感', 'API接口响应中包含银行卡完整卡号', '已确认', '紧急修复API接口，实施响应数据脱敏，排查调用记录', '2025-03-28 11:00:00', '2025-03-29 10:00:00', '渗透测试团队');


-- ---------------------------------------------------------------------
-- 表18: 数据主体权利请求处理表
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS data_subject_rights_request_handling_process_table
(
    request_id             UInt64,
    requester_name         String,
    requester_id_card      String,
    request_type           LowCardinality(String),
    target_data_tables     String,
    request_status         LowCardinality(String),
    processing_deadline    Date,
    actual_completion_time Nullable(DateTime),
    response_summary       String,
    request_time           DateTime
) ENGINE = MergeTree()
      ORDER BY (request_id, request_time)
      COMMENT '数据主体权利请求处理流程表';

INSERT INTO data_subject_rights_request_handling_process_table VALUES
                                                                   (11001, '王明', '11010119900307663X', '数据查询', 'user_identity_core_information_snapshot_table', '已完成', '2025-03-20', '2025-03-18 15:30:00', '已提供该用户所有个人信息副本', '2025-03-10 09:00:00'),
                                                                   (11002, '李芳', '110101198505154322', '数据删除', 'user_identity_core_information_snapshot_table,transaction_flow_detail_records_daily_table', '处理中', '2025-04-05', NULL, '', '2025-03-22 14:20:00'),
                                                                   (11003, '张伟', '110101199212121235', '数据更正', 'user_identity_core_information_snapshot_table', '已完成', '2025-03-28', '2025-03-25 11:00:00', '已更正手机号码', '2025-03-21 10:15:00'),
                                                                   (11004, '陈华', '110101199810103457', '数据限制处理', 'transaction_flow_detail_records_daily_table', '已拒绝', '2025-04-10', '2025-04-05 16:00:00', '不符合数据限制处理条件', '2025-03-25 09:30:00');


-- ---------------------------------------------------------------------
-- 表19: 第三方数据共享协议表
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS third_party_data_sharing_agreement_management_table
(
    agreement_id           UInt64,
    partner_name           String,
    shared_data_tables     String,
    sharing_purpose        String,
    data_transfer_method   LowCardinality(String),
    sharing_frequency      LowCardinality(String),
    data_retention_period  UInt16,
    agreement_start_date   Date,
    agreement_end_date     Date,
    signatory_company      String,
    signatory_partner      String
) ENGINE = MergeTree()
      ORDER BY (agreement_id)
      COMMENT '第三方数据共享协议管理表';

INSERT INTO third_party_data_sharing_agreement_management_table VALUES
                                                                    (12001, 'XX征信有限公司', 'transaction_flow_detail_records_daily_table', '信用评估', 'API实时接口', '实时', 90, '2024-01-01', '2025-12-31', '张三丰', '李征信'),
                                                                    (12002, 'YY营销云平台', 'user_identity_core_information_snapshot_table', '精准营销', '文件加密传输', '每月', 180, '2024-06-01', '2025-05-31', '王丽华', '赵营销'),
                                                                    (12003, 'ZZ风控实验室', 'anonymized_data_publishing_history_tracking_table', '风控模型训练', 'API批量拉取', '每周', 365, '2025-01-01', '2025-12-31', '李四光', '孙风控');


-- ---------------------------------------------------------------------
-- 表20: 数据安全培训考核记录表
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS data_security_training_examination_records_statistics_table
(
    training_id            UInt64,
    employee_name          String,
    employee_department    String,
    training_course_name   String,
    exam_score             UInt8,
    exam_result            LowCardinality(String),
    training_date          Date,
    certificate_expiry_date Date,
    trainer_name           String
) ENGINE = MergeTree()
      ORDER BY (training_id, training_date)
      COMMENT '数据安全培训考核记录统计表';

INSERT INTO data_security_training_examination_records_statistics_table VALUES
                                                                            (13001, '张三丰', '风控部', '数据安全法律法规培训', 92, '通过', '2025-01-15', '2026-01-15', '安全讲师'),
                                                                            (13002, '李四光', '数据分析部', '数据脱敏技术实践', 88, '通过', '2025-01-20', '2026-01-20', '技术讲师'),
                                                                            (13003, '王丽华', '运营部', '个人信息保护法解读', 76, '通过', '2025-02-10', '2026-02-10', '法务讲师'),
                                                                            (13004, '赵晓明', '安全审计部', '数据安全事件应急响应', 65, '不通过', '2025-02-25', NULL, '安全讲师'),
                                                                            (13005, '陈思琪', '产品部', '数据安全合规开发', 85, '通过', '2025-03-05', '2026-03-05', '技术讲师'),
                                                                            (13006, '刘德华', '技术保障部', '数据库安全配置最佳实践', 94, '通过', '2025-03-18', '2026-03-18', 'DBA团队');


-- ---------------------------------------------------------------------
-- 表21: 数据资产盘点登记表
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS data_asset_inventory_registration_classification_table
(
    asset_id               UInt64,
    asset_name             String,
    asset_owner_department String,
    asset_location         String,
    storage_engine         LowCardinality(String),
    total_records          UInt64,
    total_size_gb          Float32,
    backup_frequency       LowCardinality(String),
    last_backup_time       DateTime,
    disaster_recovery_level LowCardinality(String),
    created_date           Date
) ENGINE = MergeTree()
      ORDER BY (asset_id)
      COMMENT '数据资产盘点登记分类表';

INSERT INTO data_asset_inventory_registration_classification_table VALUES
                                                                       (14001, '用户核心身份信息表', '信息安全部', 'ClickHouse集群-01', 'ClickHouse', 5250, 2.5, '每日', '2025-04-03 02:00:00', 'RTO=4h,RPO=1h', '2024-01-01'),
                                                                       (14002, '银行卡账户信息表', '财务部', 'ClickHouse集群-01', 'ClickHouse', 3150, 1.8, '每日', '2025-04-03 02:30:00', 'RTO=4h,RPO=1h', '2024-01-01'),
                                                                       (14003, '交易流水明细表', '业务运营部', 'ClickHouse集群-02', 'ClickHouse', 1250000, 120.5, '每小时', '2025-04-03 03:00:00', 'RTO=2h,RPO=15min', '2024-01-01'),
                                                                       (14004, '登录行为审计日志表', '技术保障部', 'ClickHouse集群-03', 'ClickHouse', 890000, 45.3, '每日', '2025-04-03 01:00:00', 'RTO=8h,RPO=24h', '2024-06-01');


-- ---------------------------------------------------------------------
-- 表22: 数据安全漏洞扫描结果明细表
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS data_security_vulnerability_scanning_results_detail_table
(
    scan_id                UInt64,
    scan_task_name         String,
    vulnerable_table       String,
    vulnerable_column      String,
    vulnerability_type     LowCardinality(String),
    severity_score         UInt8,
    description            String,
    fix_suggestion         String,
    scanner_name           String,
    scan_time              DateTime,
    is_fixed               UInt8,
    fixed_time             Nullable(DateTime)
) ENGINE = MergeTree()
      ORDER BY (scan_time)
      COMMENT '数据安全漏洞扫描结果明细表';

INSERT INTO data_security_vulnerability_scanninilg_results_detail_table VALUES
                                                                            (15001, '季度数据安全扫描', 'user_identity_core_information_snapshot_table', 'id_card_number', '明文存储敏感信息', 9, '身份证号以明文形式存储在数据库中', '实施列级加密或应用层加密', '安全扫描系统', '2025-03-15 02:00:00', 0, NULL),
                                                                            (15002, '季度数据安全扫描', 'bank_card_account_details_information_table', 'cvv_code', '违反PCI DSS标准', 10, 'CVV码不应被存储', '立即删除已存储的CVV码，修改应用逻辑', '安全扫描系统', '2025-03-15 02:05:00', 1, '2025-03-20 10:00:00'),
                                                                            (15003, '月度配置检查', 'data_export_approval_workflow_records_audit_table', 'export_file_path', '路径信息泄露', 6, '导出文件路径包含敏感目录信息', '使用相对路径或路径脱敏', '配置扫描工具', '2025-03-28 03:00:00', 0, NULL),
                                                                            (15004, '权限配置审计', 'data_access_permission_role_mapping_relationship_table', 'accessible_tables', '权限过度分配', 7, '普通运营角色可以访问敏感表', '重新评估并收紧角色权限', 'IAM审计系统', '2025-03-30 04:00:00', 0, NULL);


-- ---------------------------------------------------------------------
-- 表23: 数据生命周期策略配置表
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS data_lifecycle_policy_configuration_management_table
(
    policy_id              UInt64,
    policy_name            String,
    target_table           String,
    creation_retention_days UInt16,
    staging_retention_days UInt16,
    active_retention_days  UInt16,
    archive_retention_days UInt16,
    deletion_trigger_condition String,
    compliance_standard    String,
    last_updated_time      DateTime
) ENGINE = MergeTree()
      ORDER BY (policy_id)
      COMMENT '数据生命周期策略配置管理表';

INSERT INTO data_lifecycle_policy_configuration_management_table VALUES
                                                                     (16001, '交易数据生命周期', 'transaction_flow_detail_records_daily_table', 0, 7, 365, 730, 'archived_date < CURRENT_DATE - 730', '支付卡行业数据安全标准(PCI DSS)', '2025-01-10 14:00:00'),
                                                                     (16002, '日志数据生命周期', 'user_login_behavior_audit_log_records_table', 0, 1, 180, 365, 'archived_date < CURRENT_DATE - 365', 'ISO 27001', '2025-01-15 10:30:00'),
                                                                     (16003, '用户身份信息生命周期', 'user_identity_core_information_snapshot_table', 0, 30, 1825, 3650, 'user_status=''已注销'' AND status_change_date < CURRENT_DATE - 1825', '个人信息保护法', '2025-02-01 09:00:00');


-- ---------------------------------------------------------------------
-- 表24: 数据血缘关系追踪表
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS data_lineage_tracking_relationship_analysis_table
(
    lineage_id             UInt64,
    source_table           String,
    source_column          String,
    target_table           String,
    target_column          String,
    transformation_logic   String,
    etl_job_name           String,
    last_execution_time    DateTime,
    data_flow_frequency    LowCardinality(String),
    owner_team             String
) ENGINE = MergeTree()
      ORDER BY (lineage_id)
      COMMENT '数据血缘关系追踪分析表';

INSERT INTO data_lineage_tracking_relationship_analysis_table VALUES
                                                                  (17001, 'user_identity_core_information_snapshot_table', 'user_id', 'transaction_flow_detail_records_daily_table', 'user_id', '直接映射', 'ETL_User_Transaction_Join', '2025-04-03 01:00:00', '每日', '数据集成团队'),
                                                                  (17002, 'user_identity_core_information_snapshot_table', 'phone_number', 'data_subject_rights_request_handling_process_table', 'requester_id_card', '无直接映射，用于身份验证', 'Data_Rights_Validation', '2025-04-03 08:00:00', '实时', '法务合规团队'),
                                                                  (17003, 'bank_card_account_details_information_table', 'bank_card_number', 'transaction_flow_detail_records_daily_table', 'counterparty_account', '作为交易对手方账号', 'ETL_Transaction_Enrichment', '2025-04-03 02:30:00', '每日', '数据集成团队'),
                                                                  (17004, 'user_login_behavior_audit_log_records_table', 'login_ip', 'data_security_incident_alert_log_historical_table', 'alert_source', 'IP关联用于溯源', 'Security_Correlation_Engine', '2025-04-03 00:15:00', '每小时', '安全分析团队');


-- ---------------------------------------------------------------------
-- 表25: 差分隐私保护参数配置表
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS differential_privacy_parameters_configuration_table
(
    config_id              UInt64,
    target_table           String,
    epsilon                Float32,
    delta                  Float32,
    sensitivity            Float32,
    mechanism              LowCardinality(String),
    budget_consumed        Float32,
    remaining_budget       Float32,
    last_reset_time        DateTime,
    is_active              UInt8
) ENGINE = MergeTree()
      ORDER BY (config_id)
      COMMENT '差分隐私保护参数配置表';

INSERT INTO differential_privacy_parameters_configuration_table VALUES
                                                                    (18001, 'user_access_log_aggregated_daily_statistics_materialized_table', 0.5, 1e-5, 1.0, '拉普拉斯机制', 0.12, 0.38, '2025-04-01 00:00:00', 1),
                                                                    (18002, 'anonymized_data_publishing_history_tracking_table', 1.0, 1e-5, 2.0, '高斯机制', 0.25, 0.75, '2025-04-01 00:00:00', 1),
                                                                    (18003, 'transaction_flow_detail_records_daily_table', 0.1, 1e-6, 0.5, '指数机制', 0.05, 0.05, '2025-04-01 00:00:00', 0);


-- ============================================
-- 使用 data_sec_demo 数据库
-- ============================================
USE data_sec_demo;

-- ---------------------------------------------------------------------
-- 表13: 数据加密密钥生命周期管理表
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS data_encryption_key_lifecycle_management_records_table
(
    key_id                 String,
    key_alias              String,
    encryption_algorithm   LowCardinality(String),
    key_size               UInt16,
    key_status             LowCardinality(String),
    created_by             String,
    created_time           DateTime,
    activated_time         Nullable(DateTime),
    expired_time           Nullable(DateTime),
    destroyed_time         Nullable(DateTime)
) ENGINE = MergeTree()
      ORDER BY (key_id, created_time)
      COMMENT '数据加密密钥生命周期管理记录表';

INSERT INTO data_encryption_key_lifecycle_management_records_table VALUES
                                                                       ('KEY-AES-001', '用户身份加密主密钥', 'AES-256-GCM', 256, '已激活', '安全管理员', '2024-01-01 10:00:00', '2024-01-01 10:00:00', '2026-12-31 23:59:59', NULL),
                                                                       ('KEY-AES-002', '银行卡数据加密密钥', 'AES-256-CBC', 256, '已激活', '密钥管理员', '2024-03-15 14:30:00', '2024-03-15 14:30:00', '2025-12-31 23:59:59', NULL),
                                                                       ('KEY-SM4-001', '国密算法测试密钥', 'SM4', 128, '已废弃', '研发部', '2024-06-01 09:00:00', '2024-06-01 09:00:00', '2024-12-31 23:59:59', '2025-01-15 11:00:00'),
                                                                       ('KEY-RSA-001', '非对称传输加密密钥', 'RSA', 2048, '待激活', '安全架构师', '2025-03-20 16:20:00', NULL, '2030-03-20 16:20:00', NULL);

-- ---------------------------------------------------------------------
-- 表14: 数据跨境传输审批记录表
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS cross_border_data_transfer_approval_records_audit_table
(
    transfer_id            UInt64,
    data_asset_name        String,
    data_volume_gb         Decimal64(2),
    source_country         LowCardinality(String),
    destination_country    LowCardinality(String),
    transfer_purpose       String,
    legal_basis            String,
    applicant_name         String,
    approval_status        LowCardinality(String),
    data_protection_impact_assessment_file   String,
    apply_time             DateTime,
    approval_time          Nullable(DateTime)
) ENGINE = MergeTree()
      ORDER BY (transfer_id, apply_time)
      COMMENT '数据跨境传输审批记录审计表';

INSERT INTO cross_border_data_transfer_approval_records_audit_table VALUES
                                                                        (1001, 'user_identity_core_information_snapshot_table', 2.50, '中国', '新加坡', '海外业务系统数据同步', '标准合同条款(SCC)', '张三丰', '已批准', '/dpias/CB-2025-001.pdf', '2025-02-10 09:30:00', '2025-02-25 14:00:00'),
                                                                        (1002, 'transaction_flow_detail_records_daily_table', 15.80, '中国', '美国', '全球化数据分析', '有约束力的公司规则(BCR)', '李四光', '审核中', '/dpias/CB-2025-002.pdf', '2025-03-15 11:20:00', NULL),
                                                                        (1003, 'user_login_behavior_audit_log_records_table', 0.50, '中国', '日本', '安全日志集中管理', '数据主体同意', '王丽华', '已拒绝', '/dpias/CB-2025-003.pdf', '2025-03-20 15:45:00', '2025-04-01 10:30:00');

-- ---------------------------------------------------------------------
-- 表15: 第三方数据共享协议管理表
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS third_party_data_sharing_agreement_management_table
(
    agreement_id           UInt64,
    partner_name           String,
    data_scope             String,
    sharing_purpose        String,
    sharing_frequency      LowCardinality(String),
    data_minimization_rule String,
    retention_period_days  UInt16,
    contract_start_date    Date,
    contract_end_date      Date,
    compliance_status      LowCardinality(String),
    sign_date              Date
) ENGINE = MergeTree()
      ORDER BY (agreement_id)
      COMMENT '第三方数据共享协议管理表';

INSERT INTO third_party_data_sharing_agreement_management_table VALUES
                                                                    (2001, '支付宝(中国)网络技术有限公司', '用户手机号、姓名', '实名认证核验', '实时接口调用', '仅传递必要字段', 0, '2024-01-01', '2026-12-31', '合规', '2023-12-15'),
                                                                    (2002, '腾讯云计算(北京)有限责任公司', '脱敏后用户行为数据', '用户画像分析', '每日批量同步', '已脱敏聚合数据', 90, '2024-06-01', '2025-05-31', '审计中', '2024-05-20'),
                                                                    (2003, '中国银联股份有限公司', '银行卡号脱敏、交易金额', '反欺诈联防联控', '实时查询', '哈希处理+脱敏', 0, '2024-09-01', '2025-08-31', '合规', '2024-08-10');

-- ---------------------------------------------------------------------
-- 表16: 数据主体权利请求处理表 (GDPR/个保法)
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS data_subject_rights_request_processing_tracking_table
(
    request_id             UInt64,
    user_id                UInt64,
    request_type           LowCardinality(String),
    request_details        String,
    related_data_tables    String,
    request_submit_time    DateTime,
    expected_response_date Date,
    actual_response_time   Nullable(DateTime),
    processing_status      LowCardinality(String),
    response_summary       String,
    handler_name           String
) ENGINE = MergeTree()
      ORDER BY (request_id, request_submit_time)
      COMMENT '数据主体权利请求处理跟踪表';

INSERT INTO data_subject_rights_request_processing_tracking_table VALUES
                                                                      (5001, 1001, '访问请求', '要求获取所有存储的个人数据副本', 'user_identity_core_information_snapshot_table,bank_card_account_details_information_table', '2025-03-01 10:00:00', '2025-03-31', '2025-03-28 16:30:00', '已完成', '已提供加密数据包下载链接', '合规专员A'),
                                                                      (5002, 1003, '删除请求', '要求注销账户并删除所有相关数据', 'user_identity_core_information_snapshot_table,transaction_flow_detail_records_daily_table', '2025-03-15 14:20:00', '2025-04-14', NULL, '处理中', '正在验证身份真实性', '数据保护官'),
                                                                      (5003, 1005, '更正请求', '手机号已变更，要求更新', 'user_identity_core_information_snapshot_table', '2025-03-20 09:45:00', '2025-04-19', '2025-03-21 11:00:00', '已完成', '已更新手机号', '客服专员'),
                                                                      (5004, 1002, '限制处理请求', '对交易数据的分析处理提出异议', 'transaction_flow_detail_records_daily_table', '2025-03-25 16:00:00', '2025-04-24', NULL, '待审核', '等待法务部门意见', '法务专员');

-- ---------------------------------------------------------------------
-- 表17: 数据安全培训考核记录表
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS data_security_training_examination_records_summary_table
(
    training_id            UInt64,
    training_name          String,
    training_date          Date,
    employee_id            String,
    employee_name          String,
    department             String,
    test_score             UInt8,
    pass_status            LowCardinality(String),
    certificate_url        String
) ENGINE = MergeTree()
      ORDER BY (training_id, training_date)
      COMMENT '数据安全培训考核记录汇总表';

INSERT INTO data_security_training_examination_records_summary_table VALUES
                                                                         (3001, '数据安全法解读与合规实践', '2025-01-15', 'EMP001', '张三丰', '风控部', 95, '通过', '/cert/2025/EMP001-01.pdf'),
                                                                         (3002, '数据安全法解读与合规实践', '2025-01-15', 'EMP002', '李四光', '数据分析部', 88, '通过', '/cert/2025/EMP002-01.pdf'),
                                                                         (3003, '数据安全法解读与合规实践', '2025-01-15', 'EMP003', '王丽华', '运营部', 76, '通过', '/cert/2025/EMP003-01.pdf'),
                                                                         (3004, '个人信息保护法专题培训', '2025-02-20', 'EMP004', '赵晓明', '安全审计部', 92, '通过', '/cert/2025/EMP004-02.pdf'),
                                                                         (3005, '个人信息保护法专题培训', '2025-02-20', 'EMP001', '张三丰', '风控部', 98, '通过', '/cert/2025/EMP001-02.pdf'),
                                                                         (3006, 'GDPR国际合规培训', '2025-03-10', 'EMP006', '陈思琪', '海外业务部', 85, '通过', '/cert/2025/EMP006-03.pdf'),
                                                                         (3007, '数据泄露应急响应演练', '2025-03-25', 'EMP007', '周明远', '安全运维部', 70, '待补考', '/cert/2025/EMP007-04.pdf');

-- ---------------------------------------------------------------------
-- 表18: 数据库账号权限矩阵表
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS database_account_privilege_matrix_permission_assignment_table
(
    privilege_id           UInt64,
    account_name           String,
    account_type           LowCardinality(String),
    accessible_database    String,
    accessible_table       String,
    accessible_columns     String,
    permission_type        LowCardinality(String),
    granted_by             String,
    granted_time           DateTime,
    expiration_time        Nullable(DateTime),
    is_revoked             UInt8 DEFAULT 0
) ENGINE = MergeTree()
      ORDER BY (account_name, privilege_id)
      COMMENT '数据库账号权限矩阵分配表';

INSERT INTO database_account_privilege_matrix_permission_assignment_table VALUES
                                                                              (1, 'data_analyst_ro', '只读账号', 'data_sec_demo', 'transaction_flow_detail_records_daily_table', 'transaction_id,user_id,transaction_amount,transaction_time', 'SELECT', 'DBA管理员', '2025-01-01 00:00:00', '2025-12-31 23:59:59', 0),
                                                                              (2, 'data_analyst_ro', '只读账号', 'data_sec_demo', 'user_access_log_aggregated_daily_statistics_materialized_table', '*', 'SELECT', 'DBA管理员', '2025-01-01 00:00:00', '2025-12-31 23:59:59', 0),
                                                                              (3, 'security_auditor', '审计账号', 'data_sec_demo', 'user_login_behavior_audit_log_records_table', '*', 'SELECT', '安全主管', '2025-01-15 10:00:00', NULL, 0),
                                                                              (4, 'security_auditor', '审计账号', 'data_sec_demo', 'data_security_incident_alert_log_historical_table', '*', 'SELECT,INSERT', '安全主管', '2025-01-15 10:00:00', NULL, 0),
                                                                              (5, 'app_backend_service', '应用账号', 'data_sec_demo', 'user_identity_core_information_snapshot_table', 'user_id,full_name,phone_number', 'SELECT,INSERT,UPDATE', '技术经理', '2025-02-01 14:00:00', '2026-01-31 23:59:59', 0),
                                                                              (6, 'app_backend_service', '应用账号', 'data_sec_demo', 'bank_card_account_details_information_table', 'user_id,bank_card_number,bank_name', 'SELECT,INSERT', '技术经理', '2025-02-01 14:00:00', '2026-01-31 23:59:59', 0),
                                                                              (7, 'data_engineer', '管理员账号', 'data_sec_demo', '*', '*', 'ALL', '系统管理员', '2024-01-01 00:00:00', NULL, 0);

-- ---------------------------------------------------------------------
-- 表19: 敏感数据发现扫描任务表
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS sensitive_data_discovery_scan_task_schedule_table
(
    task_id                UInt64,
    task_name              String,
    scan_scope_databases   String,
    scan_scope_tables      String,
    detection_ruleset      String,
    scan_frequency         LowCardinality(String),
    last_scan_start_time   Nullable(DateTime),
    last_scan_end_time     Nullable(DateTime),
    sensitive_tables_found UInt16,
    sensitive_columns_found UInt16,
    task_status            LowCardinality(String),
    created_by             String
) ENGINE = MergeTree()
      ORDER BY (task_id)
      COMMENT '敏感数据发现扫描任务调度表';

INSERT INTO sensitive_data_discovery_scan_task_schedule_table VALUES
                                                                  (1, '核心数据库全量敏感数据扫描', 'data_sec_demo,data_sec_umbrella', '*', 'PII规则集+金融规则集', '每周一次', '2025-03-28 02:00:00', '2025-03-28 05:30:00', 15, 42, '已完成', '安全数据治理组'),
                                                                  (2, '增量数据实时监控扫描', 'data_sec_demo', 'transaction_flow_detail_records_daily_table', '交易敏感信息规则', '实时', '2025-04-03 08:00:00', NULL, 0, 0, '运行中', '自动调度'),
                                                                  (3, '季度合规全面扫描', 'data_sec_demo', '*', 'GDPR+个保法完整规则集', '每季度', '2025-01-01 01:00:00', '2025-01-01 08:00:00', 18, 56, '已完成', '合规审计部');

-- ---------------------------------------------------------------------
-- 表20: 数据泄露事件影响评估表
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS data_breach_incident_impact_assessment_form_table
(
    incident_id            UInt64,
    incident_name          String,
    occurrence_time        DateTime,
    detection_time         DateTime,
    affected_data_categories String,
    affected_records_count UInt32,
    affected_users_count   UInt32,
    root_cause             String,
    impact_level           LowCardinality(String),
    regulatory_notification_required UInt8,
    affected_subjects_notified UInt8,
    remediation_actions    String,
    closure_time           Nullable(DateTime)
) ENGINE = MergeTree()
      ORDER BY (incident_id, occurrence_time)
      COMMENT '数据泄露事件影响评估表';

INSERT INTO data_breach_incident_impact_assessment_form_table VALUES
                                                                  (8001, '测试环境数据泄露', '2024-11-20 14:30:00', '2024-11-21 09:15:00', '姓名、手机号、地址', 5000, 5000, '测试环境未脱敏直接使用生产数据', '中等', 1, 1, '立即下线测试环境，启动脱敏流程，通知受影响用户', '2024-12-15 17:00:00'),
                                                                  (8002, '内部员工越权查询', '2025-02-10 10:20:00', '2025-02-10 16:00:00', '银行卡号、交易记录', 1200, 350, '权限分配不当，员工超出职责查询', '低等', 0, 0, '回收多余权限，加强行为审计', '2025-02-28 11:30:00'),
                                                                  (8003, '第三方API接口数据暴露', '2025-03-05 03:00:00', '2025-03-05 08:30:00', '用户ID、设备信息', 85000, 85000, 'API接口未做访问频率限制导致批量爬取', '高等', 1, 0, '紧急修复API漏洞，更换API密钥，通知监管机构', NULL);

-- ---------------------------------------------------------------------
-- 表21: 数据保留与归档策略执行表
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS data_retention_archival_policy_execution_log_table
(
    policy_id              UInt64,
    policy_name            String,
    target_table           String,
    retention_days         UInt16,
    archive_destination    String,
    last_execution_time    DateTime,
    archived_records_count UInt32,
    deleted_records_count  UInt32,
    execution_status       LowCardinality(String),
    error_message          String
) ENGINE = MergeTree()
      ORDER BY (policy_id, last_execution_time)
      COMMENT '数据保留与归档策略执行日志表';

INSERT INTO data_retention_archival_policy_execution_log_table VALUES
                                                                   (1, '登录日志180天保留策略', 'user_login_behavior_audit_log_records_table', 180, 'cold_storage_hdfs', '2025-04-01 01:00:00', 150000, 50000, '成功', ''),
                                                                   (2, '交易流水2年归档策略', 'transaction_flow_detail_records_daily_table', 730, 'data_lake_s3', '2025-04-01 02:00:00', 2000000, 0, '成功', ''),
                                                                   (3, '安全事件日志永久保留', 'data_security_incident_alert_log_historical_table', 3650, '长期归档磁带库', '2025-04-01 03:00:00', 0, 0, '部分成功', '归档目标存储空间不足，已跳过312条记录');

-- ---------------------------------------------------------------------
-- 表22: 数据安全产品与工具清单表
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS data_security_products_tools_inventory_catalog_table
(
    tool_id                UInt64,
    tool_name              String,
    tool_category          LowCardinality(String),
    vendor_name            String,
    deployment_type        LowCardinality(String),
    license_expiry_date    Date,
    managed_data_scope     String,
    coverage_rate          UInt8,
    annual_cost_usd        UInt32,
    is_active              UInt8
) ENGINE = MergeTree()
      ORDER BY (tool_id)
      COMMENT '数据安全产品与工具清单目录表';

INSERT INTO data_security_products_tools_inventory_catalog_table VALUES
                                                                     (101, 'Imperva数据安全平台', '数据防泄漏(DLP)', 'Imperva', '私有化部署', '2025-12-31', '数据库、文件服务器', 95, 85000, 1),
                                                                     (102, 'Venafi加密密钥管理', '密钥管理(KMS)', 'Venafi', 'SaaS', '2025-10-15', '数据库加密、TLS证书', 88, 42000, 1),
                                                                     (103, 'Splunk数据审计平台', '安全审计与SIEM', 'Splunk', '混合云', '2026-03-20', '日志、审计数据', 92, 120000, 1),
                                                                     (104, 'OpenVPN数据加密传输', '加密传输', 'OpenVPN社区版', '自建', '2026-06-01', '数据传输通道', 100, 0, 1),
                                                                     (105, 'Apache Ranger', '权限管理', 'Apache基金会', '自建', '2025-09-01', 'Hadoop生态、ClickHouse', 78, 0, 1);

-- ---------------------------------------------------------------------
-- 表23: 数据安全事件应急演练计划表
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS data_security_incident_response_drill_plan_schedule_table
(
    drill_id               UInt64,
    drill_name             String,
    drill_scenario         String,
    drill_date             Date,
    participating_teams    String,
    drill_duration_hours   UInt8,
    objectives_achieved    String,
    improvement_actions    String,
    drill_report_url       String
) ENGINE = MergeTree()
      ORDER BY (drill_id, drill_date)
      COMMENT '数据安全事件应急演练计划调度表';

INSERT INTO data_security_incident_response_drill_plan_schedule_table VALUES
                                                                          (1, '勒索软件攻击应急演练', '模拟勒索软件加密核心数据库', '2025-01-20', '安全运维、DBA、法务、公关', 8, '备份恢复RTO达成，业务中断控制在2小时内', '需加强离线备份频率', '/drill/2025/drill-001.pdf'),
                                                                          (2, '数据泄露应急响应', '模拟敏感数据被批量导出', '2025-03-18', '安全响应、合规审计、IT支持', 6, '2小时内完成封堵和溯源', '建立与监管机构更顺畅的通报流程', '/drill/2025/drill-002.pdf'),
                                                                          (3, 'GDPR合规检查演练', '模拟欧盟监管机构突击检查', '2025-04-15', '法务、合规、数据治理、业务', 4, '数据映射文档完整，响应及时', '需定期更新数据处理记录(ROPA)', NULL);

-- ---------------------------------------------------------------------
-- 表24: 数据处理活动记录表 (ROPA)
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS record_of_processing_activities_ropa_compliance_table
(
    ropa_id                UInt64,
    processing_activity    String,
    data_controller        String,
    data_categories        String,
    sensitive_data_flag    UInt8,
    purpose                String,
    third_party_sharing    String,
    retention_period       String,
    security_measures      String,
    last_review_date       Date,
    next_review_date       Date
) ENGINE = MergeTree()
      ORDER BY (ropa_id)
      COMMENT '数据处理活动记录表(ROPA合规)';

INSERT INTO record_of_processing_activities_ropa_compliance_table VALUES
                                                                      (1, '用户身份认证与授权', '本公司(数据控制者)', '姓名、身份证号、手机号', 1, '用户登录、身份验证、权限分配', '无', '账户注销后5年', '加密存储+访问审计+数据脱敏', '2025-01-10', '2026-01-10'),
                                                                      (2, '支付交易处理', '本公司(数据控制者)', '银行卡号、CVV、交易金额', 1, '完成用户在线支付交易', '支付宝、微信支付、银联', '交易完成后7年', 'PCI DSS标准+TLS加密传输', '2025-02-15', '2026-02-15'),
                                                                      (3, '营销分析与用户画像', '本公司(数据控制者)', '浏览记录、购买历史、设备信息', 0, '个性化推荐、营销活动', '第三方营销平台(已脱敏)', '1年', '数据匿名化+用户同意机制', '2025-03-20', '2026-03-20'),
                                                                      (4, '安全监控与审计', '本公司(数据控制者)', '登录日志、操作记录、网络流量', 0, '安全事件检测、合规审计', '无', '日志保留2年', '加密存储+定期备份+访问控制', '2025-03-01', '2026-03-01');

-- ---------------------------------------------------------------------
-- 表25: 数据安全风险评估矩阵表
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS data_security_risk_assessment_matrix_scoring_table
(
    risk_id                UInt64,
    risk_category          LowCardinality(String),
    risk_description       String,
    affected_assets        String,
    likelihood_score       UInt8,
    impact_score           UInt8,
    risk_level             LowCardinality(String),
    mitigation_control     String,
    residual_risk_level    LowCardinality(String),
    assessment_date        Date,
    next_assessment_date   Date
) ENGINE = MergeTree()
      ORDER BY (risk_id, assessment_date)
      COMMENT '数据安全风险评估矩阵打分表';

INSERT INTO data_security_risk_assessment_matrix_scoring_table VALUES
                                                                   (1, '数据泄露', '内部员工越权访问敏感数据', '用户身份表、银行卡表', 3, 5, '高', '实施细粒度权限控制+UEBA行为分析', '中', '2025-01-15', '2025-07-15'),
                                                                   (2, '数据完整性', '未经授权的数据篡改风险', '交易流水表', 2, 4, '中', '数据库审计+防篡改机制+定期校验', '低', '2025-01-15', '2025-07-15'),
                                                                   (3, '数据可用性', '勒索软件导致数据不可用', '全部核心业务表', 2, 5, '高', '3-2-1备份策略+离线备份+灾备演练', '中', '2025-01-15', '2025-07-15'),
                                                                   (4, '合规风险', '违反数据保护法规(PIPL/GDPR)', '用户数据处理全流程', 2, 4, '中', '数据保护官+合规审查+DPIA', '低', '2025-02-01', '2025-08-01'),
                                                                   (5, '第三方风险', '数据共享合作伙伴数据泄露', '共享给第三方的用户数据', 2, 4, '中', '合同约束+安全评估+定期审计', '低', '2025-02-01', '2025-08-01');

-- ---------------------------------------------------------------------
-- 表26: 数据匿名化/假名化处理记录表
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS data_anonymization_pseudonymization_processing_log_table
(
    processing_id          UInt64,
    source_table           String,
    target_table           String,
    anonymization_method   LowCardinality(String),
    affected_columns       String,
    original_data_volume   UInt32,
    processed_data_volume  UInt32,
    re_identification_risk LowCardinality(String),
    processed_by           String,
    processing_time        DateTime
) ENGINE = MergeTree()
      ORDER BY (processing_id, processing_time)
      COMMENT '数据匿名化/假名化处理日志表';

INSERT INTO data_anonymization_pseudonymization_processing_log_table VALUES
                                                                         (1, 'user_identity_core_information_snapshot_table', 'user_identity_anonymized_research_table', '泛化+扰动', 'birth_date->birth_year,location->city_only', 10000, 10000, '低', '数据脱敏工程师', '2025-03-10 23:00:00'),
                                                                         (2, 'transaction_flow_detail_records_daily_table', 'transaction_anonymized_analytics_table', '假名化+聚合', 'user_id->pseudonym,amount->amount_range', 500000, 500000, '中等', '数据分析师', '2025-03-15 22:30:00'),
                                                                         (3, 'user_login_behavior_audit_log_records_table', 'login_behavior_anonymized_table', '哈希+截断', 'login_ip->hashed_ip,device_info->device_type', 25000, 25000, '低', '安全工程师', '2025-03-20 21:00:00');

-- ---------------------------------------------------------------------
-- 表27: 数据安全承诺书签署记录表
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS data_security_commitment_agreement_signing_records_table
(
    signing_id             UInt64,
    employee_id            String,
    employee_name          String,
    department             String,
    agreement_version      String,
    signing_date           Date,
    expiry_date            Date,
    training_completed     UInt8,
    revoke_flag            UInt8,
    revoke_date            Nullable(Date)
) ENGINE = MergeTree()
      ORDER BY (signing_id, signing_date)
      COMMENT '数据安全承诺书签署记录表';

INSERT INTO data_security_commitment_agreement_signing_records_table VALUES
                                                                         (1, 'EMP001', '张三丰', '风控部', 'v2.0', '2025-01-05', '2026-01-04', 1, 0, NULL),
                                                                         (2, 'EMP002', '李四光', '数据分析部', 'v2.0', '2025-01-06', '2026-01-05', 1, 0, NULL),
                                                                         (3, 'EMP003', '王丽华', '运营部', 'v2.0', '2025-01-07', '2026-01-06', 1, 0, NULL),
                                                                         (4, 'EMP004', '赵晓明', '安全审计部', 'v2.0', '2025-01-08', '2026-01-07', 1, 0, NULL),
                                                                         (5, 'EMP005', '周明远', '技术研发部', 'v2.0', '2025-01-09', '2026-01-08', 1, 0, NULL),
                                                                         (6, 'EMP006', '陈思琪', '海外业务部', 'v2.0', '2025-01-10', '2026-01-09', 1, 0, NULL),
                                                                         (7, 'EMP007', '刘志强', '销售部', 'v2.0', '2025-01-11', '2026-01-10', 1, 0, NULL),
                                                                         (8, 'EMP008', '吴晓敏', '市场部', 'v2.0', '2025-01-12', '2026-01-11', 1, 0, NULL),
                                                                         (9, 'EMP009', '郑浩然', '产品部', 'v2.0', '2025-01-13', '2026-01-12', 0, 1, '2025-02-01');


-- ============================================
-- 在 data_sec_demo 数据库中继续创建更多表
-- 所有表名均以 data_sec_demo. 为前缀
-- ============================================

-- ---------------------------------------------------------------------
-- 表26: 数据资产盘点登记表
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS data_sec_demo.data_asset_inventory_register_master_table
(
    asset_id               UInt64,
    asset_name             String,
    asset_type             LowCardinality(String),
    asset_owner_department String,
    data_source_system     String,
    storage_location       String,
    data_volume_gb         Float64,
    creation_date          Date,
    last_updated_date      Date,
    is_critical_asset      UInt8
) ENGINE = MergeTree()
      ORDER BY (asset_id)
      COMMENT '数据资产盘点登记主表';

INSERT INTO data_sec_demo.data_asset_inventory_register_master_table VALUES
                                                                         (1, '用户身份信息数据集', '结构化数据', '用户中心', 'CRM系统', 'clickhouse_prod_01', 125.5, '2023-01-01', '2025-04-01', 1),
                                                                         (2, '交易流水数据集', '结构化数据', '交易平台', '支付网关', 'clickhouse_prod_01', 890.3, '2023-01-01', '2025-04-01', 1),
                                                                         (3, '用户行为日志', '半结构化数据', '数据分析部', '埋点系统', 'hdfs_cluster', 1520.8, '2023-06-01', '2025-04-01', 0),
                                                                         (4, '风控规则配置', '结构化数据', '风控部', '规则引擎', 'mysql_master', 0.5, '2024-01-01', '2025-03-15', 1);

-- ---------------------------------------------------------------------
-- 表27: 数据质量评分历史记录表
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS data_sec_demo.data_quality_score_history_tracking_analysis_table
(
    record_id              UInt64,
    target_table_name      String,
    quality_dimension      LowCardinality(String),
    score_value            Decimal32(2),
    threshold_value        Decimal32(2),
    is_pass                UInt8,
    deviation_reason       String,
    check_time             DateTime,
    checker_name           String
) ENGINE = MergeTree()
      ORDER BY (check_time)
      COMMENT '数据质量评分历史追踪分析表';

INSERT INTO data_sec_demo.data_quality_score_history_tracking_analysis_table VALUES
                                                                                 (1, 'user_identity_core_information_snapshot_table', '完整性', 99.85, 99.00, 1, '', '2025-04-01 02:00:00', '质量监控系统'),
                                                                                 (2, 'user_identity_core_information_snapshot_table', '准确性', 98.50, 99.00, 0, '身份证号格式异常5条', '2025-04-01 02:00:00', '质量监控系统'),
                                                                                 (3, 'bank_card_account_details_information_table', '一致性', 99.20, 99.00, 1, '', '2025-04-01 03:00:00', '质量监控系统'),
                                                                                 (4, 'transaction_flow_detail_records_daily_table', '及时性', 99.95, 99.90, 1, '', '2025-04-01 04:00:00', '质量监控系统'),
                                                                                 (5, 'user_login_behavior_audit_log_records_table', '唯一性', 100.00, 99.50, 1, '', '2025-04-01 05:00:00', '质量监控系统');

-- ---------------------------------------------------------------------
-- 表28: 敏感数据发现扫描结果表
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS data_sec_demo.sensitive_data_discovery_scan_result_details_table
(
    scan_batch_id          String,
    database_name          String,
    table_name             String,
    column_name            String,
    sensitive_type         LowCardinality(String),
    sample_data            String,
    confidence_level       Decimal32(2),
    detection_rule_id      UInt64,
    scan_time              DateTime
) ENGINE = MergeTree()
      ORDER BY (scan_batch_id, scan_time)
      COMMENT '敏感数据发现扫描结果明细表';

INSERT INTO data_sec_demo.sensitive_data_discovery_scan_result_details_table VALUES
                                                                                 ('SCAN_20250401_001', 'data_sec_demo', 'user_identity_core_information_snapshot_table', 'id_card_number', '身份证号', '11010119900307663X', 99.99, 101, '2025-04-01 01:00:00'),
                                                                                 ('SCAN_20250401_001', 'data_sec_demo', 'user_identity_core_information_snapshot_table', 'phone_number', '手机号', '138****5678', 99.99, 102, '2025-04-01 01:00:00'),
                                                                                 ('SCAN_20250401_001', 'data_sec_demo', 'bank_card_account_details_information_table', 'bank_card_number', '银行卡号', '6212***********6789', 99.95, 103, '2025-04-01 01:00:00'),
                                                                                 ('SCAN_20250401_001', 'data_sec_demo', 'bank_card_account_details_information_table', 'cvv_code', 'CVV码', '***', 98.50, 104, '2025-04-01 01:00:00'),
                                                                                 ('SCAN_20250401_002', 'data_sec_demo', 'transaction_flow_detail_records_daily_table', 'counterparty_account', '银行账号', '6212*******6789', 85.00, 105, '2025-04-02 01:00:00');

-- ---------------------------------------------------------------------
-- 表29: 数据安全策略配置表
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS data_sec_demo.data_security_policy_configuration_rules_table
(
    policy_id              UInt64,
    policy_name            String,
    policy_category        LowCardinality(String),
    target_resource_type   String,
    target_resource_pattern String,
    allowed_actions        String,
    denied_actions         String,
    effective_time_start   DateTime,
    effective_time_end     DateTime,
    priority               UInt8,
    is_enabled             UInt8
) ENGINE = MergeTree()
      ORDER BY (policy_id)
      COMMENT '数据安全策略配置规则表';

INSERT INTO data_sec_demo.data_security_policy_configuration_rules_table VALUES
                                                                             (1, '敏感表仅允许数据分析组访问', '访问控制', 'TABLE', 'data_sec_demo.user_identity_core_information_snapshot_table', 'SELECT', 'INSERT,UPDATE,DELETE,DROP', '2025-01-01 00:00:00', '2025-12-31 23:59:59', 100, 1),
                                                                             (2, '禁止非工作时间大批量导出', '数据防泄漏', 'QUERY', 'SELECT * FROM data_sec_demo.*', '', 'EXPORT', '2025-01-01 00:00:00', '2025-12-31 23:59:59', 90, 1),
                                                                             (3, '金融数据强制脱敏', '数据脱敏', 'COLUMN', 'data_sec_demo.bank_card_account_details_information_table.bank_card_number', 'SELECT', '', '2025-01-01 00:00:00', '2025-12-31 23:59:59', 80, 1);

-- ---------------------------------------------------------------------
-- 表30: 数据安全告警实时监控表
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS data_sec_demo.data_security_alert_realtime_monitoring_stream_table
(
    alert_uuid             String,
    alert_source           String,
    alert_type             LowCardinality(String),
    risk_level             UInt8,
    source_ip              String,
    user_name              String,
    operation_type         String,
    target_resource        String,
    alert_message          String,
    occurred_time          DateTime,
    is_handled             UInt8,
    handled_by             String
) ENGINE = MergeTree()
      ORDER BY (occurred_time)
      COMMENT '数据安全告警实时监控流表';

INSERT INTO data_sec_demo.data_security_alert_realtime_monitoring_stream_table VALUES
                                                                                   (uuid(), 'UEBA系统', '异常数据访问', 8, '10.20.30.45', 'zhang.san', 'SELECT', 'data_sec_demo.user_identity_core_information_snapshot_table', '非工作时间访问敏感表', '2025-04-05 22:30:00', 1, 'security_bot'),
                                                                                   (uuid(), '数据库审计', '权限滥用', 7, '192.168.1.100', 'li.si', 'DROP', 'data_sec_demo.test_table', '尝试删除生产表', '2025-04-05 14:15:00', 1, 'DBA_team'),
                                                                                   (uuid(), 'DLP系统', '数据外发', 9, '172.16.8.50', 'wang.lh', 'EXPORT', 'data_sec_demo.transaction_flow_detail_records_daily_table', '单次导出超过10万条记录', '2025-04-05 10:00:00', 0, NULL);

-- ---------------------------------------------------------------------
-- 表31: 数据水印嵌入记录表
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS data_sec_demo.data_watermark_embedding_tracking_log_table
(
    watermark_id           UInt64,
    data_asset_name        String,
    watermark_content      String,
    embedding_algorithm    LowCardinality(String),
    embedded_by            String,
    embedded_time          DateTime,
    expiration_time        DateTime,
    purpose                String
) ENGINE = MergeTree()
      ORDER BY (watermark_id)
      COMMENT '数据水印嵌入追踪日志表';

INSERT INTO data_sec_demo.data_watermark_embedding_tracking_log_table VALUES
                                                                          (1, 'user_identity_core_information_snapshot_table_2025Q1_export', '版权归属XX公司-禁止外传-工号1001', 'LSB隐写算法', 'data_processor_01', '2025-03-31 18:00:00', '2025-12-31 23:59:59', '数据共享给第三方合作伙伴'),
                                                                          (2, 'transaction_flow_detail_records_daily_table_20250401_analysis', '内部使用-工号2003', '文本水印', 'data_analyst_02', '2025-04-01 09:30:00', '2025-04-30 23:59:59', '临时数据分析任务'),
                                                                          (3, 'bank_card_account_details_information_table_audit', '审计追踪码:AUDIT-2025-001', '数字水印', 'audit_system', '2025-04-02 14:00:00', '2026-04-02 23:59:59', '合规审计导出');

-- ---------------------------------------------------------------------
-- 表32: 数据库用户行为画像表
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS data_sec_demo.database_user_behavior_profile_modeling_table
(
    user_name              String,
    profile_date           Date,
    avg_query_count_daily  Decimal32(2),
    avg_data_accessed_gb   Decimal32(2),
    frequently_accessed_tables String,
    preferred_operation    LowCardinality(String),
    anomaly_score          Decimal32(2),
    risk_level             LowCardinality(String)
) ENGINE = SummingMergeTree()
      ORDER BY (user_name, profile_date)
      COMMENT '数据库用户行为画像建模表';

INSERT INTO data_sec_demo.database_user_behavior_profile_modeling_table VALUES
                                                                            ('data_analyst_01', '2025-04-01', 45.5, 2.3, 'transaction_flow_detail_records_daily_table,user_login_behavior_audit_log_records_table', 'SELECT', 0.05, '低风险'),
                                                                            ('etl_processor', '2025-04-01', 120.0, 15.8, 'user_identity_core_information_snapshot_table,bank_card_account_details_information_table', 'INSERT,SELECT', 0.12, '中风险'),
                                                                            ('security_auditor', '2025-04-01', 18.2, 0.9, 'data_security_incident_alert_log_historical_table', 'SELECT', 0.02, '低风险');

-- ---------------------------------------------------------------------
-- 表33: 数据共享协议管理表
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS data_sec_demo.data_sharing_agreement_management_signing_record_table
(
    agreement_id           String,
    provider_party         String,
    recipient_party        String,
    data_scope_description String,
    sharing_frequency      LowCardinality(String),
    data_format            LowCardinality(String),
    security_requirements  String,
    signing_date           Date,
    effective_date         Date,
    expiry_date            Date,
    agreement_file_path    String,
    signer_name            String
) ENGINE = MergeTree()
      ORDER BY (agreement_id)
      COMMENT '数据共享协议管理签署记录表';

INSERT INTO data_sec_demo.data_sharing_agreement_management_signing_record_table VALUES
                                                                                     ('DSA-2024-001', 'XX科技有限公司', 'XX征信有限公司', '用户信贷记录、还款行为数据(脱敏)', '每日增量推送', 'JSON加密', 'TLS1.3传输、AES-256存储、数据保留不超过90天', '2024-01-10', '2024-02-01', '2025-01-31', '/agreements/DSA-2024-001.pdf', '张三丰'),
                                                                                     ('DSA-2024-045', 'XX科技有限公司', 'XX云计算服务商', '业务日志数据(不含个人信息)', '实时流式传输', 'Protobuf', 'VPC内网传输、日志数据存储加密', '2024-06-15', '2024-07-01', '2025-06-30', '/agreements/DSA-2024-045.pdf', '李四光');

-- ---------------------------------------------------------------------
-- 表34: 数据安全成熟度评估结果表
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS data_sec_demo.data_security_maturity_assessment_result_dimension_table
(
    assessment_id          UInt64,
    assessment_date        Date,
    dimension_name         LowCardinality(String),
    current_score          UInt8,
    target_score           UInt8,
    gap_description        String,
    improvement_actions    String,
    owner_department       String
) ENGINE = MergeTree()
      ORDER BY (assessment_id, dimension_name)
      COMMENT '数据安全成熟度评估结果维度表';

INSERT INTO data_sec_demo.data_security_maturity_assessment_result_dimension_table VALUES
                                                                                       (1, '2025-03-15', '数据分类分级', 75, 85, '自动化分类分级覆盖率不足', '采购自动化扫描工具，覆盖所有数据源', '信息安全部'),
                                                                                       (1, '2025-03-15', '访问控制', 80, 90, '特权账号管理不够精细', '实施PAM方案，定期审计特权账号', '技术保障部'),
                                                                                       (1, '2025-03-15', '数据加密', 70, 85, '部分备份数据未加密', '2025年Q4完成全量备份加密改造', '运维部'),
                                                                                       (1, '2025-03-15', '审计追溯', 85, 90, '数据库审计日志存储周期不足', '扩展日志存储周期至180天', '安全运维组');

-- ---------------------------------------------------------------------
-- 表35: 数据安全预算与成本核算表
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS data_sec_demo.data_security_budget_cost_accounting_allocation_table
(
    budget_id              UInt64,
    fiscal_year            UInt16,
    cost_center            String,
    expenditure_category   LowCardinality(String),
    vendor_name            String,
    amount_rmb             Decimal64(2),
    contract_number        String,
    procurement_status     LowCardinality(String),
    payment_date           Date,
    remarks                String
) ENGINE = MergeTree()
      ORDER BY (fiscal_year, budget_id)
      COMMENT '数据安全预算与成本核算分配表';

INSERT INTO data_sec_demo.data_security_budget_cost_accounting_allocation_table VALUES
                                                                                    (1, 2025, '信息安全部', '软件采购', '奇安信', 350000.00, 'CON-2025-001', '已付款', '2025-02-15', '数据防泄漏DLP系统'),
                                                                                    (2, 2025, '信息安全部', '硬件采购', '深信服', 280000.00, 'CON-2025-008', '已付款', '2025-03-10', '数据库审计一体机'),
                                                                                    (3, 2025, '技术保障部', '云服务', '阿里云', 120000.00, 'CON-2025-015', '分期付款', '2025-01-20', '密钥管理服务KMS'),
                                                                                    (4, 2025, '合规部', '咨询费', '德勤', 500000.00, 'CON-2025-022', '已付款', '2025-03-25', 'GDPR合规咨询项目');

-- ---------------------------------------------------------------------
-- 表36: 数据安全岗位人员配置表
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS data_sec_demo.data_security_staff_personnel_configuration_table
(
    employee_id            String,
    full_name              String,
    job_role               LowCardinality(String),
    job_level              String,
    certifications         String,
    join_date              Date,
    reporting_to           String,
    contact_email          String,
    is_active              UInt8
) ENGINE = MergeTree()
      ORDER BY (employee_id)
      COMMENT '数据安全岗位人员配置表';

INSERT INTO data_sec_demo.data_security_staff_personnel_configuration_table VALUES
                                                                                ('SEC001', '王安全', '数据安全总监', 'P9', 'CISSP,CIPP/E', '2020-01-15', 'CTO', 'wang.anquan@company.com', 1),
                                                                                ('SEC002', '李审计', '安全审计专员', 'P7', 'CISA,ISO27001 LA', '2021-06-01', '王安全', 'li.shenji@company.com', 1),
                                                                                ('SEC003', '张合规', '数据合规官', 'P8', 'CIPP/CN', '2022-03-10', '王安全', 'zhang.hegui@company.com', 1),
                                                                                ('SEC004', '赵运维', '安全运维工程师', 'P6', 'CISP', '2023-08-20', '李审计', 'zhao.yunwei@company.com', 1);

-- ---------------------------------------------------------------------
-- 表37: 数据安全事件演练记录表
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS data_sec_demo.data_security_incident_drill_exercise_record_table
(
    drill_id               UInt64,
    drill_name             String,
    drill_scenario         String,
    drill_date             Date,
    participating_teams    String,
    drill_duration_minutes UInt16,
    success_rate           Decimal32(2),
    lessons_learned        String,
    improvement_items      String
) ENGINE = MergeTree()
      ORDER BY (drill_id)
      COMMENT '数据安全事件演练记录表';

INSERT INTO data_sec_demo.data_security_incident_drill_exercise_record_table VALUES
                                                                                 (1, '红蓝对抗-数据泄露应急响应', '模拟黑客窃取数据库敏感信息', '2025-02-20', '安全团队,运维团队,法务团队', 180, 85.5, '发现备份恢复流程不够自动化', '2025年Q3上线自动化备份恢复平台'),
                                                                                 (2, '钓鱼邮件社工演练', '员工点击恶意链接导致凭证泄露', '2025-03-15', '全员参与', 0, 92.0, '仍有8%员工未通过测试', '加强季度安全培训，对未通过者强制复训'),
                                                                                 (3, '勒索病毒攻击演练', '模拟勒索软件加密核心数据', '2025-03-28', '安全团队,业务连续性团队', 240, 78.0, '异地备份恢复时间过长', '优化异地备份策略，实施定期恢复测试');

-- ---------------------------------------------------------------------
-- 表38: 数据安全技术产品清单表
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS data_sec_demo.data_security_technology_product_inventory_table
(
    product_id             UInt64,
    product_name           String,
    vendor_name            String,
    product_category       LowCardinality(String),
    deployment_mode        LowCardinality(String),
    covered_asset_scope    String,
    license_expiry_date    Date,
    maintenance_contact    String,
    technical_spec         String
) ENGINE = MergeTree()
      ORDER BY (product_id)
      COMMENT '数据安全技术产品清单表';

INSERT INTO data_sec_demo.data_security_technology_product_inventory_table VALUES
                                                                               (1, '数据库审计系统DAS', '深信服', '数据库安全', '旁路部署', 'ClickHouse,MySQL,PostgreSQL集群', '2025-12-31', 'support@sangfor.com', '吞吐量2000条/秒，存储180天'),
                                                                               (2, '数据防泄漏DLP', '奇安信', '数据防泄漏', '串联部署', '邮件、网络、终端', '2026-01-15', 'dlp_support@qianxin.com', '支持HTTP/SMTP/FTP协议解析'),
                                                                               (3, '密钥管理服务KMS', '阿里云', '加密与密钥管理', '云服务', 'RDS,OSS,ECS', '2025-12-01', 'kms_service@aliyun.com', '支持AES-256/SM4，密钥轮换周期90天'),
                                                                               (4, '数据脱敏平台', '观安信息', '数据脱敏', '旁路部署', '开发测试环境、数据分析平台', '2025-10-20', 'dm_support@guanan.com', '支持静态脱敏和动态脱敏');

-- ---------------------------------------------------------------------
-- 表39: 数据安全外部审计发现项表
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS data_sec_demo.data_security_external_audit_finding_tracking_table
(
    finding_id             UInt64,
    audit_firm_name        String,
    audit_date             Date,
    finding_severity       LowCardinality(String),
    finding_description    String,
    affected_asset         String,
    recommendation         String,
    remediation_status     LowCardinality(String),
    planned_completion_date Date,
    actual_completion_date Nullable(Date),
    auditor_name           String
) ENGINE = MergeTree()
      ORDER BY (finding_id)
      COMMENT '数据安全外部审计发现项追踪表';

INSERT INTO data_sec_demo.data_security_external_audit_finding_tracking_table VALUES
                                                                                  (1, '普华永道', '2025-01-10', '中危', '数据库访问日志未开启审计功能', 'clickhouse_prod_01', '启用数据库审计日志，配置日志存储位置', '已修复', '2025-02-15', '2025-02-10', '张审计师'),
                                                                                  (2, '普华永道', '2025-01-10', '高危', '未对所有敏感数据列进行加密存储', 'user_identity_core_information_snapshot_table.email_address', '实施列级加密，评估性能影响后分批改造', '修复中', '2025-06-30', NULL, '张审计师'),
                                                                                  (3, '德勤', '2025-03-20', '低危', '数据保留策略未文档化', '全公司数据资产', '制定并发布数据保留与销毁政策文档', '已修复', '2025-04-10', '2025-04-05', '李评估师');

-- ---------------------------------------------------------------------
-- 表40: 数据安全内部举报记录表
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS data_sec_demo.data_security_whistleblower_report_confidential_table
(
    report_id              UInt64,
    reporter_anonymous_id  String,
    report_channel         LowCardinality(String),
    report_category        LowCardinality(String),
    report_description     String,
    reported_person        String,
    evidence_file_path     String,
    report_time            DateTime,
    investigation_status   LowCardinality(String),
    investigation_result   String,
    closure_date           Nullable(Date)
) ENGINE = MergeTree()
      ORDER BY (report_time)
      COMMENT '数据安全内部举报保密表';

INSERT INTO data_sec_demo.data_security_whistleblower_report_confidential_table VALUES
                                                                                    (1, 'ANON_7F3D8A', '内部举报平台', '数据违规导出', '数据分析组员工在未经审批情况下将用户数据导出到个人U盘', 'EMP_00456', '/evidence/case_001/usb_logs.txt', '2025-02-18 15:30:00', '已查实', '涉事员工记过处分，撤销数据权限', '2025-03-10'),
                                                                                    (2, 'ANON_9B2E1C', '合规热线', '权限滥用', '运维人员使用root账户查看敏感表数据，疑似出于好奇', 'EMP_00812', '/evidence/case_002/audit_logs.csv', '2025-03-22 10:15:00', '调查中', NULL, NULL);

-- ---------------------------------------------------------------------
-- 表41: 数据安全知识库文档表
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS data_sec_demo.data_security_knowledge_base_document_catalog_table
(
    doc_id                 UInt64,
    doc_title              String,
    doc_category           LowCardinality(String),
    applicable_roles       String,
    content_summary        String,
    file_path              String,
    version                String,
    publish_date           Date,
    last_updated_date      Date,
    view_count             UInt64
) ENGINE = MergeTree()
      ORDER BY (doc_id)
      COMMENT '数据安全知识库文档目录表';

INSERT INTO data_sec_demo.data_security_knowledge_base_document_catalog_table VALUES
                                                                                  (1, '数据分类分级操作指南', '制度规范', '全体员工', '详细说明数据分类分级的标准和操作流程', '/knowledge/classification_guide_v2.3.pdf', '2.3', '2024-12-01', '2025-03-15', 342),
                                                                                  (2, 'ClickHouse安全配置最佳实践', '技术手册', 'DBA,运维工程师', '包含访问控制、加密、审计等安全配置示例', '/knowledge/clickhouse_security_best_practice_v1.1.pdf', '1.1', '2025-01-10', '2025-02-20', 189),
                                                                                  (3, '数据泄露应急响应SOP', '应急预案', '安全团队,IT支持', '数据泄露事件的分级响应流程和操作步骤', '/knowledge/incident_response_sop_v3.0.pdf', '3.0', '2025-02-01', '2025-03-01', 456),
                                                                                  (4, '个人信息保护法合规自查清单', '合规工具', '合规部,法务部', 'PIPL重点条款解读及自查项', '/knowledge/pipl_checklist_v1.5.xlsx', '1.5', '2025-01-15', '2025-03-20', 234);

-- ---------------------------------------------------------------------
-- 表42: 数据安全风险自评估报告表
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS data_sec_demo.data_security_risk_self_assessment_report_table
(
    assessment_id          UInt64,
    assessment_period      String,
    risk_scenario          String,
    inherent_risk_score    UInt8,
    control_effectiveness  UInt8,
    residual_risk_score    UInt8,
    risk_level             LowCardinality(String),
    treatment_plan         String,
    owner_name             String,
    review_date            Date
) ENGINE = MergeTree()
      ORDER BY (assessment_id)
      COMMENT '数据安全风险自评估报告表';

INSERT INTO data_sec_demo.data_security_risk_self_assessment_report_table VALUES
                                                                              (1, '2025年Q1', '内部人员违规访问敏感数据', 4, 3, 3, '中风险', '实施UEBA监控，加强离职员工权限回收流程', '安全架构组', '2025-04-05'),
                                                                              (2, '2025年Q1', '第三方数据共享泄露', 5, 2, 4, '高风险', '建立第三方数据安全评估机制，签订新版数据保护协议', '合规部', '2025-04-05'),
                                                                              (3, '2025年Q1', '备份数据未加密存储', 3, 4, 2, '低风险', '2025年Q3完成备份加密改造', '运维部', '2025-04-05');

-- ---------------------------------------------------------------------
-- 表43: 数据安全考核指标(KPI)表
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS data_sec_demo.data_security_kpi_dashboard_monthly_table
(
    kpi_id                 UInt64,
    report_month           Date,
    kpi_name               LowCardinality(String),
    target_value           Decimal32(2),
    actual_value           Decimal32(2),
    achievement_rate       Decimal32(2),
    trend_direction        LowCardinality(String),
    responsible_dept       String,
    remarks                String
) ENGINE = MergeTree()
      ORDER BY (report_month, kpi_id)
      COMMENT '数据安全考核指标月度仪表表';

INSERT INTO data_sec_demo.data_security_kpi_dashboard_monthly_table VALUES
                                                                        (1, '2025-03-01', '敏感数据发现覆盖率', 95.00, 92.50, 97.37, '上升', '信息安全部', '较上月提升2.5%'),
                                                                        (2, '2025-03-01', '数据安全事件平均响应时长(分钟)', 30.00, 25.00, 120.00, '下降', '应急响应组', '响应效率提升'),
                                                                        (3, '2025-03-01', '安全培训员工覆盖率', 100.00, 98.00, 98.00, '持平', '人力资源部', '新员工入职培训待完成'),
                                                                        (4, '2025-03-01', '数据泄露事件数量', 0.00, 0.00, 100.00, '持平', '全员', '本月无数据泄露事件'),
                                                                        (5, '2025-03-01', '合规整改完成率', 90.00, 85.00, 94.44, '上升', '合规部', '剩余3项整改中');

-- ---------------------------------------------------------------------
-- 表44: 数据安全工具选型评估表
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS data_sec_demo.data_security_tool_evaluation_selection_matrix_table
(
    evaluation_id          UInt64,
    requirement_name       String,
    candidate_product      String,
    vendor_name            String,
    score_functional       UInt8,
    score_performance      UInt8,
    score_compatibility    UInt8,
    score_cost             UInt8,
    total_score            UInt16,
    evaluation_conclusion  LowCardinality(String),
    evaluator_name         String,
    evaluation_date        Date
) ENGINE = MergeTree()
      ORDER BY (evaluation_id)
      COMMENT '数据安全工具选型评估矩阵表';

INSERT INTO data_sec_demo.data_security_tool_evaluation_selection_matrix_table VALUES
                                                                                   (1, '数据脱敏', '数据脱敏平台A', '观安信息', 9, 8, 9, 7, 33, '推荐', '王安全', '2025-02-10'),
                                                                                   (1, '数据脱敏', '数据脱敏平台B', '美创科技', 8, 9, 8, 8, 33, '推荐', '王安全', '2025-02-10'),
                                                                                   (1, '数据脱敏', '数据脱敏平台C', '安华金和', 7, 7, 9, 9, 32, '备选', '王安全', '2025-02-10'),
                                                                                   (2, '数据库审计', '数据库审计系统X', '深信服', 9, 9, 8, 7, 33, '推荐', '李审计', '2025-01-15'),
                                                                                   (2, '数据库审计', '数据库审计系统Y', '启明星辰', 8, 8, 9, 8, 33, '推荐', '李审计', '2025-01-15');

-- ---------------------------------------------------------------------
-- 表45: 数据安全违规处罚记录表
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS data_sec_demo.data_security_violation_disciplinary_record_table
(
    violation_id           UInt64,
    violator_name          String,
    violator_department    String,
    violation_type         LowCardinality(String),
    violation_description  String,
    evidence_summary       String,
    disciplinary_action    LowCardinality(String),
    action_details         String,
    effective_date         Date,
    issuer_name            String
) ENGINE = MergeTree()
      ORDER BY (violation_id)
      COMMENT '数据安全违规处罚记录表';

INSERT INTO data_sec_demo.data_security_violation_disciplinary_record_table VALUES
                                                                                (1, '陈某某', '研发中心', '违规查询', '未经审批在生产环境执行批量查询，涉及用户表', '审计日志记录显示查询操作超1000次', '警告处分', '书面警告，取消季度评优资格', '2025-02-20', '安全委员会'),
                                                                                (2, '李某某', '市场部', '数据外发', '将含用户手机号的营销名单通过个人邮箱外发', 'DLP系统告警记录', '记过处分', '记过处分，降薪一级，调离数据接触岗位', '2025-03-05', '安全委员会'),
                                                                                (3, '张某某', '外包团队', '权限滥用', '使用测试账号访问生产环境敏感表', '堡垒机操作记录', '解除合同', '立即终止合作，清除所有系统权限', '2025-03-18', '采购部');

-- ---------------------------------------------------------------------
-- 表46: 数据安全通告与预警信息表
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS data_sec_demo.data_security_advisory_warning_information_table
(
    advisory_id            UInt64,
    advisory_title         String,
    severity_level         LowCardinality(String),
    affected_system        String,
    vulnerability_cve      String,
    description            String,
    mitigation_actions     String,
    publish_date           Date,
    expiry_date            Date,
    status                 LowCardinality(String)
) ENGINE = MergeTree()
      ORDER BY (advisory_id)
      COMMENT '数据安全通告与预警信息表';

INSERT INTO data_sec_demo.data_security_advisory_warning_information_table VALUES
                                                                               (1, 'ClickHouse 历史版本权限绕过漏洞', '高危', 'ClickHouse < 24.3', 'CVE-2024-12345', '低权限用户可通过特定函数绕过行级安全策略', '升级到24.3+版本，或配置网络访问控制', '2025-02-01', '2025-08-01', '处理中'),
                                                                               (2, 'Apache Log4j2 远程代码执行', '严重', '使用Log4j2的Java应用', 'CVE-2021-44228', 'JNDI注入导致RCE', '升级Log4j2到2.17.0+，配置JVM参数', '2024-12-10', '2025-06-10', '已解决'),
                                                                               (3, '敏感数据泄露预警', '中危', '数据分析平台', '内部发现', '部分分析师权限过大，存在数据滥用风险', '实施最小权限原则，建立审批流程', '2025-03-15', '2025-04-15', '监控中');

-- ---------------------------------------------------------------------
-- 表47: 数据安全管理评审会议纪要表
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS data_sec_demo.data_security_management_review_meeting_minutes_table
(
    meeting_id             UInt64,
    meeting_date           Date,
    meeting_title          String,
    attendees              String,
    key_discussion_points  String,
    decisions_made         String,
    action_items           String,
    responsible_persons    String,
    deadline_date          Date,
    next_review_date       Date
) ENGINE = MergeTree()
      ORDER BY (meeting_id)
      COMMENT '数据安全管理评审会议纪要表';

INSERT INTO data_sec_demo.data_security_management_review_meeting_minutes_table VALUES
                                                                                    (1, '2025-03-25', '数据安全委员会Q1季度会议', '王安全,李审计,张合规,赵运维,技术总监,法务总监', '1.回顾Q1数据安全指标完成情况；2.评审数据脱敏平台采购方案；3.讨论PIPL合规整改事项', '1.批准数据脱敏平台采购预算；2.成立数据分类分级专项工作组', '1.完成数据脱敏平台POC测试(王安全负责，4月15日)；2.发布新版数据分类分级制度(张合规负责，4月10日)', '王安全,张合规', '2025-04-20'),
                                                                                    (2, '2025-02-20', '数据泄露事件复盘会', '应急响应组全员,受影响业务部门负责人', '复盘2月18日敏感数据外发事件，分析根本原因', '1.升级DLP策略；2.加强数据导出审批流程；3.组织全员安全培训', '1.DLP策略优化(赵运维，3月5日)；2.修订数据导出管理办法(李审计，3月1日)', '赵运维,李审计', '2025-03-10');

-- ---------------------------------------------------------------------
-- 表48: 数据安全技术研究试验记录表
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS data_sec_demo.data_security_technology_research_experiment_table
(
    experiment_id          UInt64,
    experiment_name        String,
    technology_area        LowCardinality(String),
    objective              String,
    experiment_environment String,
    experiment_steps       String,
    results_summary        String,
    conclusion             String,
    researcher_name        String,
    experiment_date        Date,
    follow_up_actions      String
) ENGINE = MergeTree()
      ORDER BY (experiment_id)
      COMMENT '数据安全技术研究试验记录表';

INSERT INTO data_sec_demo.data_security_technology_research_experiment_table VALUES
                                                                                 (1, '同态加密在聚合查询中的性能测试', '加密技术', '评估同态加密对ClickHouse聚合查询性能的影响', 'ClickHouse 24.3 + 同态加密插件', '1.部署测试环境；2.导入1000万条测试数据；3.执行标准聚合查询并记录性能基线；4.启用同态加密后重复测试', '常规聚合查询性能下降约35%，复杂查询下降约60%', '同态加密目前不适合生产环境的高频查询场景，可考虑仅对超敏感列使用', '加密研究组', '2025-02-28', '继续关注硬件加速方案'),
                                                                                 (2, '差分隐私在用户画像场景的应用', '隐私计算', '验证差分隐私技术在保护用户隐私的同时保持画像准确性', 'Python + OpenDP库', '1.构建用户画像模型；2.对查询结果添加拉普拉斯噪声；3.评估隐私预算与准确性的权衡', '隐私预算epsilon=1时，准确性下降约8%；epsilon=0.5时下降约15%', '差分隐私适合对外输出的统计类画像数据，epsilon建议设置0.5-1之间', '隐私计算团队', '2025-03-10', '计划在生产环境试点应用');

-- ---------------------------------------------------------------------
-- 表49: 数据安全供应商风险评估表
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS data_sec_demo.data_security_vendor_risk_assessment_scorecard_table
(
    assessment_id          UInt64,
    vendor_name            String,
    service_category       LowCardinality(String),
    assessment_date        Date,
    security_certifications String,
    data_protection_measures String,
    breach_history         String,
    risk_score             UInt8,
    risk_level             LowCardinality(String),
    recommendation         String,
    assessor_name          String
) ENGINE = MergeTree()
      ORDER BY (assessment_id)
      COMMENT '数据安全供应商风险评估计分表';

INSERT INTO data_sec_demo.data_security_vendor_risk_assessment_scorecard_table VALUES
                                                                                   (1, '阿里云', '云服务提供商', '2025-03-01', 'ISO27001,ISO27701,SOC2 Type II', '数据加密存储、访问控制、审计日志', '无已知重大泄露事件', 15, '低风险', '可继续使用，年度复审即可', '第三方风险管理组'),
                                                                                   (2, 'XX营销科技公司', '数据营销服务', '2025-02-10', 'ISO27001', '基础安全措施', '2023年曾发生客户数据误删事件', 45, '中风险', '建议限制共享数据范围，增加合同约束', '第三方风险管理组'),
                                                                                   (3, 'YY数据分析公司', '数据分析外包', '2025-01-15', '无', '安全措施不明确', '信息未披露', 75, '高风险', '不建议合作，或要求其完成安全认证后再评估', '第三方风险管理组');

-- ---------------------------------------------------------------------
-- 表50: 数据安全能力建设里程碑表
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS data_sec_demo.data_security_capability_building_milestone_table
(
    milestone_id           UInt64,
    capability_name        String,
    strategic_initiative   String,
    target_completion_date Date,
    actual_completion_date Nullable(Date),
    status                 LowCardinality(String),
    budget_allocated_rmb   Decimal64(2),
    responsible_executive  String,
    key_deliverables       String
) ENGINE = MergeTree()
      ORDER BY (milestone_id)
      COMMENT '数据安全能力建设里程碑表';

INSERT INTO data_sec_demo.data_security_capability_building_milestone_table VALUES
                                                                                (1, '数据分类分级自动化', '数据治理', '2025-06-30', NULL, '进行中', 500000.00, '王安全', '自动化分类分级平台上线、覆盖率>=90%'),
                                                                                (2, '数据防泄漏能力建设', '数据保护', '2025-09-30', NULL, '进行中', 800000.00, '赵运维', 'DLP覆盖邮件、网络、终端、API四类通道'),
                                                                                (3, '统一密钥管理平台', '加密与密钥管理', '2025-04-30', '2025-04-15', '已完成', 300000.00, '李审计', 'KMS平台上线、支持AES/SM4算法'),
                                                                                (4, '数据安全运营中心建设', '安全运营', '2025-12-31', NULL, '规划中', 2000000.00, '王安全', '安全数据湖、态势大屏、自动化响应编排'),
                                                                                (5, '全员数据安全意识提升', '人员与文化', '2025-12-31', NULL, '进行中', 150000.00, '张合规', '季度培训覆盖率100%、钓鱼演练参与率100%');

-- ---------------------------------------------------------------------
-- 表51: 数据血缘关系追踪表
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS data_sec_demo.data_lineage_relationship_tracking_analysis_table
(
    lineage_id             UInt64,
    source_table           String,
    source_column          String,
    target_table           String,
    target_column          String,
    transformation_logic   String,
    pipeline_name          String,
    update_frequency       LowCardinality(String),
    data_flow_direction    LowCardinality(String),
    created_time           DateTime
) ENGINE = MergeTree()
      ORDER BY (lineage_id)
      COMMENT '数据血缘关系追踪分析表';

INSERT INTO data_sec_demo.data_lineage_relationship_tracking_analysis_table VALUES
                                                                                (1, 'user_identity_core_information_snapshot_table', 'user_id', 'transaction_flow_detail_records_daily_table', 'user_id', '直接映射', 'ETL_User_Transaction_Flow', '每日增量', '上游->下游', '2025-01-01 00:00:00'),
                                                                                (2, 'user_identity_core_information_snapshot_table', 'full_name', 'user_access_log_aggregated_daily_statistics_materialized_table', 'user_name', '字符串拼接', 'ETL_User_Aggregation', '实时流', '上游->下游', '2025-01-01 00:00:00'),
                                                                                (3, 'bank_card_account_details_information_table', 'card_id', 'transaction_flow_detail_records_daily_table', 'card_id', '直接映射', 'ETL_Card_Transaction_Flow', '每日增量', '上游->下游', '2025-01-01 00:00:00'),
                                                                                (4, 'transaction_flow_detail_records_daily_table', 'transaction_amount', 'user_access_log_aggregated_daily_statistics_materialized_table', 'total_amount', 'SUM聚合', 'Agg_Transaction_By_User', '每日全量', '上游->下游', '2025-01-01 00:00:00');

-- ---------------------------------------------------------------------
-- 表52: 数据字典元数据同步记录表
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS data_sec_demo.data_dictionary_metadata_sync_history_table
(
    sync_id                UInt64,
    sync_batch_id          String,
    database_name          String,
    table_name             String,
    column_name            String,
    data_type              String,
    is_nullable            UInt8,
    column_comment         String,
    sync_status            LowCardinality(String),
    sync_time              DateTime,
    error_message          String
) ENGINE = MergeTree()
      ORDER BY (sync_batch_id, sync_time)
      COMMENT '数据字典元数据同步历史表';

INSERT INTO data_sec_demo.data_dictionary_metadata_sync_history_table VALUES
                                                                          (1, 'SYNC_20250401_001', 'data_sec_demo', 'user_identity_core_information_snapshot_table', 'user_id', 'UInt64', 0, '用户唯一ID', '成功', '2025-04-01 01:00:00', ''),
                                                                          (2, 'SYNC_20250401_001', 'data_sec_demo', 'user_identity_core_information_snapshot_table', 'full_name', 'String', 0, '真实姓名', '成功', '2025-04-01 01:00:00', ''),
                                                                          (3, 'SYNC_20250401_001', 'data_sec_demo', 'user_identity_core_information_snapshot_table', 'id_card_number', 'String', 0, '身份证号', '成功', '2025-04-01 01:00:00', ''),
                                                                          (4, 'SYNC_20250401_001', 'data_sec_demo', 'bank_card_account_details_information_table', 'bank_card_number', 'String', 0, '银行卡号', '成功', '2025-04-01 01:00:00', ''),
                                                                          (5, 'SYNC_20250401_002', 'data_sec_demo', 'non_existent_table', 'col1', 'String', 1, '测试列', '失败', '2025-04-01 02:00:00', '表不存在');

-- ---------------------------------------------------------------------
-- 表53: 数据生命周期状态监控表
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS data_sec_demo.data_lifecycle_status_monitoring_current_table
(
    data_asset_id          String,
    data_asset_name        String,
    current_stage          LowCardinality(String),
    stage_start_time       DateTime,
    expected_duration_days UInt16,
    expected_next_stage    LowCardinality(String),
    remaining_days         Int16,
    alert_flag             UInt8,
    last_processed_time    DateTime
) ENGINE = MergeTree()
      ORDER BY (data_asset_id)
      COMMENT '数据生命周期状态监控当前表';

INSERT INTO data_sec_demo.data_lifecycle_status_monitoring_current_table VALUES
                                                                             ('ASSET_USER_001', '用户身份信息数据', '在线使用', '2024-01-01 00:00:00', 730, '归档', 275, 0, '2025-04-01 00:00:00'),
                                                                             ('ASSET_LOG_001', '用户登录日志数据', '在线使用', '2025-01-01 00:00:00', 180, '删除', 45, 1, '2025-04-01 00:00:00'),
                                                                             ('ASSET_BACKUP_001', '季度全量备份数据', '归档', '2025-01-15 00:00:00', 1095, '删除', 915, 0, '2025-04-01 00:00:00');

-- ---------------------------------------------------------------------
-- 表54: 数据安全合规审计点配置表
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS data_sec_demo.data_security_compliance_audit_point_configuration_table
(
    audit_point_id         UInt64,
    regulation_name        LowCardinality(String),
    article_number         String,
    requirement_text       String,
    applicable_data_scope  String,
    audit_frequency        LowCardinality(String),
    audit_method           String,
    evidence_retention_days UInt16,
    is_active              UInt8
) ENGINE = MergeTree()
      ORDER BY (audit_point_id)
      COMMENT '数据安全合规审计点配置表';

INSERT INTO data_sec_demo.data_security_compliance_audit_point_configuration_table VALUES
                                                                                       (1, 'PIPL', '第13条', '个人信息处理前需告知并取得同意', '所有用户个人信息', '季度', '检查用户同意记录表、隐私政策更新记录', 1095, 1),
                                                                                       (2, 'PIPL', '第21条', '个人信息委托处理需签订数据处理协议', '委托第三方处理的个人信息', '半年', '检查数据处理协议签署情况、第三方风险评估记录', 1825, 1),
                                                                                       (3, 'GDPR', '第17条', '被遗忘权-用户可要求删除其个人数据', '所有用户个人信息', '季度', '检查删除请求响应时效、删除操作记录', 1095, 1),
                                                                                       (4, 'ISO27001', 'A.8.2.1', '数据分类分级', '全公司数据资产', '年度', '检查分类分级标签覆盖率、标签准确性', 2190, 1);

-- ---------------------------------------------------------------------
-- 表55: 数据安全产品续费与合同管理表
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS data_sec_demo.data_security_product_renewal_contract_management_table
(
    contract_id            String,
    product_name           String,
    vendor_name            String,
    contract_start_date    Date,
    contract_end_date      Date,
    renewal_notification_date Date,
    renewal_deadline_date  Date,
    annual_fee_rmb         Decimal64(2),
    payment_terms          String,
    renewal_status         LowCardinality(String),
    poc_contact_person     String
) ENGINE = MergeTree()
      ORDER BY (contract_id)
      COMMENT '数据安全产品续费与合同管理表';

INSERT INTO data_sec_demo.data_security_product_renewal_contract_management_table VALUES
                                                                                      ('CT-2023-088', '数据库审计系统DAS', '深信服', '2023-12-01', '2025-11-30', '2025-09-30', '2025-11-15', 280000.00, '年付', '待续约', '王安全'),
                                                                                      ('CT-2024-015', '数据防泄漏DLP', '奇安信', '2024-02-15', '2026-02-14', '2025-12-15', '2026-01-30', 350000.00, '年付', '正常使用', '赵运维'),
                                                                                      ('CT-2024-102', '密钥管理服务KMS', '阿里云', '2024-01-20', '2025-01-19', '2024-12-20', '2025-01-10', 120000.00, '年付', '已续约', '李审计');

