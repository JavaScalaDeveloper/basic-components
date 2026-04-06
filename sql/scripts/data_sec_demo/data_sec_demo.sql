-- =====================================================
-- 1. 创建数据库
-- =====================================================
CREATE DATABASE IF NOT EXISTS data_sec_demo
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE data_sec_demo;

-- =====================================================
-- 2. 用户信息表（含敏感信息）
-- =====================================================

-- 2.1 用户基本信息表（有索引）
CREATE TABLE IF NOT EXISTS user_basic
(
    id         BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '用户ID',
    username   VARCHAR(50) NOT NULL COMMENT '用户名',
    real_name  VARCHAR(50) COMMENT '真实姓名',
    id_card    VARCHAR(18) COMMENT '身份证号',
    phone      VARCHAR(11) COMMENT '手机号',
    email      VARCHAR(100) COMMENT '邮箱',
    gender     TINYINT COMMENT '性别: 1男 2女 0未知',
    birthday   DATE COMMENT '出生日期',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_username (username),
    INDEX idx_phone (phone),
    INDEX idx_id_card (id_card)
) COMMENT '用户基本信息表';

-- 2.2 用户健康信息表（有索引）
CREATE TABLE IF NOT EXISTS user_health
(
    id              BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id         BIGINT NOT NULL COMMENT '关联user_basic.id',
    blood_type      VARCHAR(5) COMMENT '血型',
    height          INT COMMENT '身高(cm)',
    weight          INT COMMENT '体重(kg)',
    medical_history TEXT COMMENT '病史',
    allergies       TEXT COMMENT '过敏史',
    created_at      DATETIME DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_user_id (user_id)
) COMMENT '用户健康信息表';

-- 2.3 公司敏感信息表（有索引）
CREATE TABLE IF NOT EXISTS company_sensitive
(
    id               BIGINT PRIMARY KEY AUTO_INCREMENT,
    company_name     VARCHAR(200) NOT NULL COMMENT '公司名称',
    tax_number       VARCHAR(50) COMMENT '税号',
    bank_account     VARCHAR(50) COMMENT '银行账号',
    bank_name        VARCHAR(100) COMMENT '开户行',
    business_license VARCHAR(100) COMMENT '营业执照号',
    legal_person     VARCHAR(50) COMMENT '法人代表',
    legal_phone      VARCHAR(11) COMMENT '法人手机号',
    legal_id_card    VARCHAR(18) COMMENT '法人身份证',
    created_at       DATETIME DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_company_name (company_name),
    INDEX idx_tax_number (tax_number)
) COMMENT '公司敏感信息表';

-- 2.4 云服务凭证表（含AK/SK，有索引）
CREATE TABLE IF NOT EXISTS cloud_credentials
(
    id             BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id        BIGINT       NOT NULL COMMENT '关联user_basic.id',
    cloud_provider ENUM ('aliyun', 'tencent', 'aws', 'huawei', 'other') DEFAULT 'aliyun' COMMENT '云厂商',
    access_key     VARCHAR(100) NOT NULL COMMENT 'AccessKey',
    secret_key     VARCHAR(200) NOT NULL COMMENT 'SecretKey',
    permission     VARCHAR(500) COMMENT '权限描述',
    expire_time    DATETIME COMMENT '过期时间',
    created_at     DATETIME                                             DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_user_id (user_id),
    INDEX idx_access_key (access_key)
) COMMENT '云服务凭证表(AK/SK)';

-- 2.5 用户登录凭证表（无索引）
CREATE TABLE IF NOT EXISTS user_login_credentials
(
    id              BIGINT PRIMARY KEY AUTO_INCREMENT,
    username        VARCHAR(50)  NOT NULL,
    password_hash   VARCHAR(255) NOT NULL COMMENT '加密密码',
    salt            VARCHAR(64) COMMENT '盐值',
    last_login_ip   VARCHAR(45),
    last_login_time DATETIME,
    created_at      DATETIME DEFAULT CURRENT_TIMESTAMP
    -- 故意不建索引
) COMMENT '用户登录凭证表';

-- =====================================================
-- 3. 业务表
-- =====================================================

-- 3.1 订单表（有索引）
CREATE TABLE IF NOT EXISTS orders
(
    id         BIGINT PRIMARY KEY AUTO_INCREMENT,
    order_no   VARCHAR(32) NOT NULL COMMENT '订单号',
    user_id    BIGINT      NOT NULL,
    amount     DECIMAL(12, 2) COMMENT '订单金额',
    status     TINYINT  DEFAULT 0 COMMENT '0待支付 1已支付 2已取消 3已完成',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    paid_at    DATETIME COMMENT '支付时间',
    INDEX idx_order_no (order_no),
    INDEX idx_user_id (user_id),
    INDEX idx_status (status)
) COMMENT '订单表';

-- 3.2 商品表（无索引）
CREATE TABLE IF NOT EXISTS products
(
    id           BIGINT PRIMARY KEY AUTO_INCREMENT,
    product_code VARCHAR(50)  NOT NULL,
    product_name VARCHAR(200) NOT NULL,
    category     VARCHAR(50),
    price        DECIMAL(10, 2),
    stock        INT      DEFAULT 0,
    description  TEXT,
    created_at   DATETIME DEFAULT CURRENT_TIMESTAMP
    -- 故意不建索引
) COMMENT '商品表';

-- 3.3 操作日志表（无索引）
CREATE TABLE IF NOT EXISTS operation_logs
(
    id             BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id        BIGINT,
    operation_type VARCHAR(50),
    request_url    VARCHAR(500),
    request_params TEXT,
    response_code  INT,
    ip_address     VARCHAR(45),
    duration_ms    INT,
    created_at     DATETIME DEFAULT CURRENT_TIMESTAMP
    -- 故意不建索引
) COMMENT '操作日志表';

-- =====================================================
-- 4. 插入模拟数据
-- =====================================================

-- 4.1 用户基本信息表（15条）
INSERT INTO user_basic (username, real_name, id_card, phone, email, gender, birthday)
VALUES ('zhang_san', '张三', '31010119900307663X', '13812345678', 'zhangsan@example.com', 1, '1990-03-07'),
       ('li_si', '李四', '440301199105124567', '13987654321', 'lisi@example.com', 1, '1991-05-12'),
       ('wang_fang', '王芳', '510107199210235678', '15812345678', 'wangfang@example.com', 2, '1992-10-23'),
       ('zhao_lei', '赵磊', '32010519880514789X', '17712345678', 'zhaolei@example.com', 1, '1988-05-14'),
       ('chen_na', '陈娜', '350203199303156789', '15987654321', 'chenna@example.com', 2, '1993-03-15'),
       ('liu_qiang', '刘强', '120101198612019876', '18612345678', 'liuqiang@example.com', 1, '1986-12-01'),
       ('huang_jing', '黄静', '430103199112348765', '13512345678', 'huangjing@example.com', 2, '1991-12-23'),
       ('xu_wei', '徐伟', '210203199405230987', '15212345678', 'xuwei@example.com', 1, '1994-05-23'),
       ('sun_li', '孙丽', '370202198902191234', '18712345678', 'sunli@example.com', 2, '1989-02-19'),
       ('zhou_jie', '周杰', '500101199607154321', '18812345678', 'zhoujie@example.com', 1, '1996-07-15'),
       ('wu_di', '吴迪', '330105198303284567', '18912345678', 'wudi@example.com', 1, '1983-03-28'),
       ('zheng_shuang', '郑爽', '440304199407163210', '16612345678', 'zhengshuang@example.com', 2, '1994-07-16'),
       ('lin_feng', '林枫', '350582199811119876', '15512345678', 'linfeng@example.com', 1, '1998-11-11'),
       ('guo_jing', '郭静', '410105200001014321', '13312345678', 'guojing@example.com', 2, '2000-01-01'),
       ('tang_wei', '唐伟', '510105198707121234', '18112345678', 'tangwei@example.com', 1, '1987-07-12');

-- 4.2 用户健康信息表（12条）
INSERT INTO user_health (user_id, blood_type, height, weight, medical_history, allergies)
VALUES (1, 'A', 175, 70, '无', '花粉过敏'),
       (2, 'B', 180, 75, '高血压', '无'),
       (3, 'O', 165, 55, '无', '青霉素过敏'),
       (4, 'AB', 172, 68, '糖尿病', '无'),
       (5, 'A', 160, 50, '甲状腺结节', '海鲜过敏'),
       (6, 'B', 185, 80, '高血脂', '无'),
       (7, 'O', 168, 58, '无', '尘螨过敏'),
       (8, 'AB', 178, 72, '脂肪肝', '无'),
       (9, 'A', 162, 52, '无', '无'),
       (10, 'B', 170, 65, '胃病', '无'),
       (11, 'O', 175, 70, '无', '无'),
       (12, 'AB', 165, 60, '哮喘', '花粉过敏');

-- 4.3 公司敏感信息表（10条）
INSERT INTO company_sensitive (company_name, tax_number, bank_account, bank_name, business_license, legal_person,
                               legal_phone, legal_id_card)
VALUES ('云创科技有限责任公司', '91310115MA1H23K45X', '6217000012345678901', '中国建设银行上海分行',
        '91310115MA1H23K45X', '张伟', '13811112222', '310101198001011234'),
       ('智联数据服务有限公司', '91440101MA5CKM78Y', '6217850000000012345', '招商银行广州分行', '91440101MA5CKM78Y',
        '李强', '13922223333', '440301198212155678'),
       ('海纳信息安全公司', '91110108MA01L9B8C', '6230580000123456789', '中国银行北京分行', '91110108MA01L9B8C', '王磊',
        '15833334444', '110101198512203456'),
       ('星辰云计算有限公司', '91370212MA3P9A7K', '6225880012345678', '浦发银行青岛分行', '91370212MA3P9A7K', '赵明',
        '17744445555', '370202199010304567'),
       ('致远信息技术有限公司', '91440300MA5F8B4C', '6228480012345678901', '农业银行深圳分行', '91440300MA5F8B4C',
        '陈华', '18655556666', '440304199212218901'),
       ('鸿图软件科技有限公司', '91310112MA1GD8E', '6212261000001234567', '工商银行上海分行', '91310112MA1GD8E', '刘东',
        '15266667777', '310112198808081234'),
       ('安恒数据安全有限公司', '91110112MA01F5A', '6217000011111111111', '建设银行北京分行', '91110112MA01F5A', '徐凯',
        '18777778888', '110112198509154321'),
       ('磐石信息安全技术有限公司', '91420106MA4K2Q', '6222620210001234567', '交通银行武汉分行', '91420106MA4K2Q',
        '周平', '18888889999', '420106198207161234'),
       ('天璇区块链科技有限公司', '91330205MA2AG', '6214830012345678901', '宁波银行', '91330205MA2AG', '吴刚',
        '16699990000', '330205199303275678'),
       ('昆仑云安全实验室', '91440300MA5GM', '6229081234567890', '平安银行深圳分行', '91440300MA5GM', '郑强',
        '15500001111', '440305199711158765');

-- 4.4 云服务凭证表（8条）
INSERT INTO cloud_credentials (user_id, cloud_provider, access_key, secret_key, permission, expire_time)
VALUES (1, 'aliyun', 'LTAI5tDfV9yZxQ2mN3kP7wB', 'aBcDeFgHiJkLmNoPqRsTuVwXyZ123456', 'ECS只读权限',
        '2025-12-31 23:59:59'),
       (2, 'tencent', 'AKIDz8qXkLmNpRtYwB4cE7gH', 'sKcQaZxSwEdCfRvTgByHnMjUkLpO', 'COS读写权限', '2025-06-30 23:59:59'),
       (3, 'aws', 'AKIAIOSFODNN7EXAMPLE', 'wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY', 'S3只读', '2025-03-15 23:59:59'),
       (4, 'huawei', 'UYH7G8V9B0N1M2K3L4P5Q6R', 'xYzAbC123dEfGhI456jKlMn789OpQ', 'OBS读写', '2025-09-01 23:59:59'),
       (5, 'aliyun', 'LTAI5tRfTgYhUjIkLpQwErT', 'bCdEfGhIjKlMnOpQrStUvWxYz098765', '全权限', '2026-01-01 23:59:59'),
       (7, 'tencent', 'AKIDmNpRtYwB4cE7gHjK3L', 'tYbGvFcDxSzAwEqDrFtGyHuJkL', 'CDN只读', '2025-08-20 23:59:59'),
       (10, 'aws', 'AKIAJ7N9P2K5R8E6XAMPLE', 'mNoPqRsTuVwXyZ1234567890AbCdEfG', 'EC2完全访问', '2025-04-10 23:59:59'),
       (12, 'aliyun', 'LTAI5tA1b2C3d4E5f6G7h8I9', 'jKlMnOpQrStUvWxYz0987654321AbCd', 'RDS只读', '2025-11-30 23:59:59');

-- 4.5 用户登录凭证表（15条，无索引）
INSERT INTO user_login_credentials (username, password_hash, salt, last_login_ip, last_login_time)
VALUES ('zhang_san', '5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8', 'salt_001', '192.168.1.101',
        '2025-03-15 10:30:00'),
       ('li_si', '6b3a55e0261b03014489e4fe4d5f8e2c2e2b4b9e1c3d6e7f8a9b0c1d2e3f4a5b', 'salt_002', '192.168.1.102',
        '2025-03-14 14:20:00'),
       ('wang_fang', '7c4b66f1272c14134b95d8c2f5e6f3d3f3c5c0f2d4e7f8a9b0c1d2e3f4a5b6c', 'salt_003', '192.168.1.103',
        '2025-03-13 09:45:00'),
       ('zhao_lei', '8d5c77g2383d25245ca6e9e3g6f7g4e4g4d6d1g3e5f8a9b0c1d2e3f4a5b6c7d', 'salt_004', '192.168.1.104',
        '2025-03-12 16:10:00'),
       ('chen_na', '9e6d88h3494e36356db7f0f4h7g8h5f5h5e7e2h4f6g9b0c1d2e3f4a5b6c7d8e9f', 'salt_005', '192.168.1.105',
        '2025-03-11 11:30:00'),
       ('liu_qiang', '0f7e99i4505f47467ec8g1g5i8h9i6g6i6f8f3i5g7h0c1d2e3f4a5b6c7d8e9f0a', 'salt_006', '10.0.0.1',
        '2025-03-10 08:00:00'),
       ('huang_jing', '1g8f00j5616g58578fd9h2h6j9i0j7h7j7g9g4j6h8i1d2e3f4a5b6c7d8e9f0a1b', 'salt_007', '10.0.0.2',
        '2025-03-09 17:30:00'),
       ('xu_wei', '2h9g11k6727h69689ge0i3i7k0j1k8i8k8h0h5k7i9j2e3f4a5b6c7d8e9f0a1b2c', 'salt_008', '172.16.0.1',
        '2025-03-08 13:15:00'),
       ('sun_li', '3i0h22l7838i7079ahf1j4j8l1k2l9j9l9i1i6l8j0k3f4a5b6c7d8e9f0a1b2c3d', 'salt_009', '172.16.0.2',
        '2025-03-07 10:45:00'),
       ('zhou_jie', '4j1i33m8949j8180big2k5k9m2l3m0k0m0j2j7m9k1l4g5a6b7c8d9e0f1a2b3c4d', 'salt_010', '192.168.1.110',
        '2025-03-06 15:20:00'),
       ('wu_di', '5k2j44n9050k9291cjh3l6l0n3m4n1l1n1k3k8n0l2m5h6b7c8d9e0f1a2b3c4d5e', 'salt_011', '192.168.1.111',
        '2025-03-05 09:00:00'),
       ('zheng_shuang', '6l3k55o0161l0302dki4m7m1o4n5o2m2o2l4l9o1m3n6i7c8d9e0f1a2b3c4d5e6f', 'salt_012',
        '192.168.1.112', '2025-03-04 14:30:00'),
       ('lin_feng', '7m4l66p1272m1413elj5n8n2p5o6p3n3p3m5m0p2n4o7j8d9e0f1a2b3c4d5e6f7g', 'salt_013', '192.168.1.113',
        '2025-03-03 11:15:00'),
       ('guo_jing', '8n5m77q2383n2524fmk6o9o3q6p7q4o4q4n6n1q3o5p8k9e0f1a2b3c4d5e6f7g8h', 'salt_014', '192.168.1.114',
        '2025-03-02 16:45:00'),
       ('tang_wei', '9o6n88r3494o3635gnl7p0p4r7q8r5p5r5o7o2r4p6q9l0f1a2b3c4d5e6f7g8h9i', 'salt_015', '192.168.1.115',
        '2025-03-01 12:00:00');

-- 4.6 订单表（20条）
INSERT INTO orders (order_no, user_id, amount, status, paid_at)
VALUES ('ORD202503150001', 1, 299.00, 1, '2025-03-15 10:35:00'),
       ('ORD202503150002', 2, 5999.00, 1, '2025-03-15 14:20:00'),
       ('ORD202503140003', 3, 89.50, 1, '2025-03-14 09:15:00'),
       ('ORD202503140004', 4, 1299.00, 0, NULL),
       ('ORD202503130005', 5, 45.00, 2, NULL),
       ('ORD202503130006', 6, 329.00, 1, '2025-03-13 16:30:00'),
       ('ORD202503120007', 7, 7999.00, 3, '2025-03-12 11:00:00'),
       ('ORD202503120008', 8, 159.00, 0, NULL),
       ('ORD202503110009', 9, 2399.00, 1, '2025-03-11 13:45:00'),
       ('ORD202503110010', 10, 67.80, 1, '2025-03-11 10:20:00'),
       ('ORD202503100011', 11, 4599.00, 3, '2025-03-10 09:30:00'),
       ('ORD202503100012', 12, 129.00, 0, NULL),
       ('ORD202503090013', 13, 899.00, 1, '2025-03-09 15:10:00'),
       ('ORD202503090014', 14, 49.90, 2, NULL),
       ('ORD202503080015', 15, 3599.00, 1, '2025-03-08 12:25:00'),
       ('ORD202503080016', 1, 199.00, 3, '2025-03-08 10:00:00'),
       ('ORD202503070017', 2, 6999.00, 0, NULL),
       ('ORD202503070018', 3, 259.00, 1, '2025-03-07 14:50:00'),
       ('ORD202503060019', 4, 1599.00, 1, '2025-03-06 11:30:00'),
       ('ORD202503060020', 5, 79.90, 0, NULL);

-- 4.7 商品表（18条，无索引）
INSERT INTO products (product_code, product_name, category, price, stock, description)
VALUES ('P10001', 'iPhone 15 Pro', '手机数码', 7999.00, 50, '苹果最新旗舰手机'),
       ('P10002', '华为Mate 60 Pro', '手机数码', 6999.00, 30, '华为旗舰手机'),
       ('P10003', 'MacBook Pro 14', '电脑办公', 14999.00, 20, '苹果笔记本电脑'),
       ('P10004', '罗技MX Master 3S', '电脑外设', 599.00, 100, '无线鼠标'),
       ('P10005', '飞利浦Hue智能灯泡', '智能家居', 399.00, 80, '智能照明设备'),
       ('P10006', '小米空气净化器4', '家用电器', 899.00, 45, '智能空气净化器'),
       ('P10007', '索尼WH-1000XM5', '音频设备', 2299.00, 35, '降噪耳机'),
       ('P10008', '任天堂Switch OLED', '游戏娱乐', 2099.00, 25, '游戏主机'),
       ('P10009', '大疆Mini 3 Pro', '摄影摄像', 4789.00, 15, '无人机'),
       ('P10010', '小米手环8', '智能穿戴', 249.00, 200, '智能手环'),
       ('P10011', '戴森V15吸尘器', '家用电器', 4999.00, 10, '无线吸尘器'),
       ('P10012', '极米H6投影仪', '影音娱乐', 5999.00, 8, '4K投影仪'),
       ('P10013', '漫步者MR4音箱', '音频设备', 499.00, 60, '监听音箱'),
       ('P10014', '京东京造人体工学椅', '家居生活', 1299.00, 40, '办公椅'),
       ('P10015', '小米路由器AX9000', '网络设备', 1299.00, 55, '三频路由器'),
       ('P10016', '绿联NAS私有云', '存储设备', 2399.00, 20, '网络存储'),
       ('P10017', '雷蛇毒蝰V2 Pro', '电脑外设', 1099.00, 35, '游戏鼠标'),
       ('P10018', '三星T7移动硬盘', '存储设备', 799.00, 70, '2TB移动硬盘');

-- 4.8 操作日志表（20条，无索引）
INSERT INTO operation_logs (user_id, operation_type, request_url, request_params, response_code, ip_address,
                            duration_ms)
VALUES (1, 'LOGIN', '/api/user/login', '{"username":"zhang_san"}', 200, '192.168.1.101', 45),
       (2, 'QUERY', '/api/order/list', '{"page":1,"size":10}', 200, '192.168.1.102', 32),
       (3, 'CREATE', '/api/order/create', '{"product_id":10001,"quantity":1}', 200, '192.168.1.103', 78),
       (4, 'UPDATE', '/api/user/profile', '{"real_name":"赵磊"}', 200, '192.168.1.104', 56),
       (5, 'DELETE', '/api/cart/clear', '{}', 200, '192.168.1.105', 23),
       (6, 'LOGIN', '/api/user/login', '{"username":"liu_qiang"}', 200, '10.0.0.1', 67),
       (7, 'QUERY', '/api/product/search', '{"keyword":"手机"}', 200, '10.0.0.2', 89),
       (8, 'CREATE', '/api/order/create', '{"product_id":10003,"quantity":1}', 401, '172.16.0.1', 12),
       (9, 'UPDATE', '/api/user/password', '{}', 200, '172.16.0.2', 134),
       (10, 'LOGIN', '/api/admin/login', '{"username":"admin"}', 403, '192.168.1.110', 23),
       (11, 'EXPORT', '/api/order/export', '{"start_date":"2025-03-01"}', 200, '192.168.1.111', 567),
       (12, 'QUERY', '/api/user/list', '{"page":1,"size":20}', 200, '192.168.1.112', 45),
       (13, 'CREATE', '/api/product/create', '{"name":"新商品"}', 500, '192.168.1.113', 89),
       (14, 'DELETE', '/api/user/delete', '{"user_id":99}', 404, '192.168.1.114', 8),
       (15, 'LOGIN', '/api/user/login', '{"username":"tang_wei"}', 200, '192.168.1.115', 56),
       (16, 'QUERY', '/api/order/statistics', '{"type":"daily"}', 200, '10.0.0.3', 234),
       (17, 'UPDATE', '/api/product/price', '{"product_id":10005,"price":299}', 200, '10.0.0.4', 67),
       (18, 'CREATE', '/api/order/create', '{"product_id":10008,"quantity":2}', 200, '172.16.0.5', 123),
       (19, 'LOGIN', '/api/user/login', '{"username":"test"}', 401, '192.168.1.120', 15),
       (20, 'QUERY', '/api/user/info', '{"user_id":1}', 200, '192.168.1.121', 34);

-- =====================================================
-- 5. 验证数据
-- =====================================================
SELECT 'user_basic' AS table_name, COUNT(*) AS row_count
FROM user_basic
UNION ALL
SELECT 'user_health', COUNT(*)
FROM user_health
UNION ALL
SELECT 'company_sensitive', COUNT(*)
FROM company_sensitive
UNION ALL
SELECT 'cloud_credentials', COUNT(*)
FROM cloud_credentials
UNION ALL
SELECT 'user_login_credentials', COUNT(*)
FROM user_login_credentials
UNION ALL
SELECT 'orders', COUNT(*)
FROM orders
UNION ALL
SELECT 'products', COUNT(*)
FROM products
UNION ALL
SELECT 'operation_logs', COUNT(*)
FROM operation_logs;

-- =====================================================
-- 使用数据库
-- =====================================================
USE data_sec_demo;

-- =====================================================
-- 一、敏感信息表（10张）
-- =====================================================

-- 1.1 个人身份信息表（有索引）
CREATE TABLE IF NOT EXISTS personal_identity (
                                                 id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键ID',
                                                 full_name VARCHAR(50) NOT NULL COMMENT '姓名',
                                                 id_card VARCHAR(18) COMMENT '身份证号',
                                                 passport_no VARCHAR(20) COMMENT '护照号',
                                                 driver_license VARCHAR(20) COMMENT '驾驶证号',
                                                 birth_date DATE COMMENT '出生日期',
                                                 nationality VARCHAR(50) COMMENT '国籍',
                                                 ethnicity VARCHAR(20) COMMENT '民族',
                                                 marital_status VARCHAR(10) COMMENT '婚姻状况',
                                                 created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
                                                 INDEX idx_id_card (id_card),
                                                 INDEX idx_full_name (full_name)
) COMMENT '个人身份信息表';

-- 1.2 个人联系方式表（有索引）
CREATE TABLE IF NOT EXISTS personal_contact (
                                                id BIGINT PRIMARY KEY AUTO_INCREMENT,
                                                person_id BIGINT NOT NULL COMMENT '关联personal_identity.id',
                                                phone VARCHAR(11) COMMENT '手机号',
                                                email VARCHAR(100) COMMENT '邮箱',
                                                wechat VARCHAR(50) COMMENT '微信号',
                                                qq VARCHAR(20) COMMENT 'QQ号',
                                                address VARCHAR(500) COMMENT '家庭地址',
                                                postal_code VARCHAR(10) COMMENT '邮编',
                                                created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
                                                INDEX idx_person_id (person_id),
                                                INDEX idx_phone (phone)
) COMMENT '个人联系方式表';

-- 1.3 公司核心信息表（有索引）
CREATE TABLE IF NOT EXISTS company_core (
                                            id BIGINT PRIMARY KEY AUTO_INCREMENT,
                                            company_name VARCHAR(200) NOT NULL COMMENT '公司全称',
                                            credit_code VARCHAR(18) COMMENT '统一社会信用代码',
                                            tax_id VARCHAR(20) COMMENT '税务登记号',
                                            org_code VARCHAR(10) COMMENT '组织机构代码',
                                            legal_person VARCHAR(50) COMMENT '法定代表人',
                                            registered_capital DECIMAL(15,2) COMMENT '注册资本',
                                            founded_date DATE COMMENT '成立日期',
                                            business_scope TEXT COMMENT '经营范围',
                                            created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
                                            INDEX idx_credit_code (credit_code),
                                            INDEX idx_company_name (company_name)
) COMMENT '公司核心信息表';

-- 1.4 公司财务信息表（有索引）
CREATE TABLE IF NOT EXISTS company_finance (
                                               id BIGINT PRIMARY KEY AUTO_INCREMENT,
                                               company_id BIGINT NOT NULL COMMENT '关联company_core.id',
                                               bank_name VARCHAR(100) COMMENT '开户银行',
                                               bank_account VARCHAR(30) COMMENT '银行账号',
                                               swift_code VARCHAR(11) COMMENT 'SWIFT代码',
                                               revenue DECIMAL(15,2) COMMENT '年营收',
                                               profit DECIMAL(15,2) COMMENT '年利润',
                                               tax_paid DECIMAL(15,2) COMMENT '纳税额',
                                               debt_ratio DECIMAL(5,2) COMMENT '负债率(%)',
                                               created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
                                               INDEX idx_company_id (company_id),
                                               INDEX idx_bank_account (bank_account)
) COMMENT '公司财务信息表';

-- 1.5 项目机密信息表（有索引）
CREATE TABLE IF NOT EXISTS project_secret (
                                              id BIGINT PRIMARY KEY AUTO_INCREMENT,
                                              project_code VARCHAR(50) NOT NULL COMMENT '项目编码',
                                              project_name VARCHAR(200) COMMENT '项目名称',
                                              project_key VARCHAR(100) COMMENT '项目密钥',
                                              api_key VARCHAR(100) COMMENT 'API密钥',
                                              secret_key VARCHAR(200) COMMENT 'Secret密钥',
                                              database_url VARCHAR(500) COMMENT '数据库连接串',
                                              database_password VARCHAR(200) COMMENT '数据库密码',
                                              cloud_access_key VARCHAR(100) COMMENT '云服务AK',
                                              cloud_secret_key VARCHAR(200) COMMENT '云服务SK',
                                              expire_date DATE COMMENT '过期日期',
                                              created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
                                              INDEX idx_project_code (project_code),
                                              INDEX idx_api_key (api_key)
) COMMENT '项目机密信息表';

-- 1.6 员工薪资信息表（有索引）
CREATE TABLE IF NOT EXISTS employee_salary (
                                               id BIGINT PRIMARY KEY AUTO_INCREMENT,
                                               employee_no VARCHAR(20) NOT NULL COMMENT '工号',
                                               full_name VARCHAR(50) COMMENT '姓名',
                                               department VARCHAR(100) COMMENT '部门',
                                               position VARCHAR(50) COMMENT '职位',
                                               base_salary DECIMAL(10,2) COMMENT '基本工资',
                                               bonus DECIMAL(10,2) COMMENT '奖金',
                                               allowance DECIMAL(10,2) COMMENT '津贴',
                                               social_security_no VARCHAR(20) COMMENT '社保号',
                                               bank_card_no VARCHAR(25) COMMENT '工资卡号',
                                               created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
                                               INDEX idx_employee_no (employee_no),
                                               INDEX idx_department (department)
) COMMENT '员工薪资信息表';

-- 1.7 客户敏感信息表（有索引）
CREATE TABLE IF NOT EXISTS customer_sensitive (
                                                  id BIGINT PRIMARY KEY AUTO_INCREMENT,
                                                  customer_name VARCHAR(100) NOT NULL COMMENT '客户名称',
                                                  contact_person VARCHAR(50) COMMENT '联系人',
                                                  contact_phone VARCHAR(11) COMMENT '联系电话',
                                                  contract_no VARCHAR(50) COMMENT '合同编号',
                                                  contract_amount DECIMAL(15,2) COMMENT '合同金额',
                                                  payment_terms VARCHAR(200) COMMENT '付款条款',
                                                  discount_rate DECIMAL(5,2) COMMENT '折扣率',
                                                  credit_limit DECIMAL(15,2) COMMENT '信用额度',
                                                  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
                                                  INDEX idx_customer_name (customer_name),
                                                  INDEX idx_contract_no (contract_no)
) COMMENT '客户敏感信息表';

-- 1.8 知识产权信息表（有索引）
CREATE TABLE IF NOT EXISTS intellectual_property (
                                                     id BIGINT PRIMARY KEY AUTO_INCREMENT,
                                                     ip_type VARCHAR(20) NOT NULL COMMENT '类型:专利/商标/软著',
                                                     ip_name VARCHAR(200) COMMENT '名称',
                                                     registration_no VARCHAR(50) COMMENT '注册号',
                                                     applicant VARCHAR(100) COMMENT '申请人',
                                                     inventor VARCHAR(100) COMMENT '发明人',
                                                     application_date DATE COMMENT '申请日期',
                                                     authorization_date DATE COMMENT '授权日期',
                                                     ip_value DECIMAL(15,2) COMMENT '评估价值',
                                                     created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
                                                     INDEX idx_registration_no (registration_no),
                                                     INDEX idx_ip_type (ip_type)
) COMMENT '知识产权信息表';

-- 1.9 系统账号权限表（无索引）
CREATE TABLE IF NOT EXISTS system_accounts (
                                               id BIGINT PRIMARY KEY AUTO_INCREMENT,
                                               username VARCHAR(50) NOT NULL,
                                               password_hash VARCHAR(255) NOT NULL,
                                               role VARCHAR(50),
                                               permission VARCHAR(500),
                                               last_login_ip VARCHAR(45),
                                               last_login_time DATETIME,
                                               is_active TINYINT DEFAULT 1,
                                               created_at DATETIME DEFAULT CURRENT_TIMESTAMP
    -- 故意不建索引
) COMMENT '系统账号权限表';

-- 1.10 日志审计信息表（无索引）
CREATE TABLE IF NOT EXISTS audit_logs (
                                          id BIGINT PRIMARY KEY AUTO_INCREMENT,
                                          operator VARCHAR(50),
                                          operation_type VARCHAR(50),
                                          target_table VARCHAR(100),
                                          target_id BIGINT,
                                          old_value TEXT,
                                          new_value TEXT,
                                          client_ip VARCHAR(45),
                                          created_at DATETIME DEFAULT CURRENT_TIMESTAMP
    -- 故意不建索引
) COMMENT '日志审计信息表';

-- =====================================================
-- 二、业务表（5张）
-- =====================================================

-- 2.1 产品信息表（有索引）
CREATE TABLE IF NOT EXISTS products (
                                        id BIGINT PRIMARY KEY AUTO_INCREMENT,
                                        product_code VARCHAR(50) NOT NULL COMMENT '产品编码',
                                        product_name VARCHAR(200) COMMENT '产品名称',
                                        category VARCHAR(50) COMMENT '分类',
                                        price DECIMAL(10,2) COMMENT '单价',
                                        cost DECIMAL(10,2) COMMENT '成本',
                                        stock INT DEFAULT 0 COMMENT '库存',
                                        status TINYINT DEFAULT 1 COMMENT '状态:1上架 0下架',
                                        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
                                        INDEX idx_product_code (product_code),
                                        INDEX idx_category (category)
) COMMENT '产品信息表';

-- 2.2 订单信息表（有索引）
CREATE TABLE IF NOT EXISTS orders (
                                      id BIGINT PRIMARY KEY AUTO_INCREMENT,
                                      order_no VARCHAR(32) NOT NULL COMMENT '订单号',
                                      user_id BIGINT COMMENT '用户ID',
                                      product_id BIGINT COMMENT '产品ID',
                                      quantity INT COMMENT '数量',
                                      unit_price DECIMAL(10,2) COMMENT '单价',
                                      total_amount DECIMAL(12,2) COMMENT '总金额',
                                      order_status TINYINT DEFAULT 0 COMMENT '0待支付 1已支付 2已发货 3已完成 4已取消',
                                      pay_time DATETIME COMMENT '支付时间',
                                      created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
                                      INDEX idx_order_no (order_no),
                                      INDEX idx_user_id (user_id),
                                      INDEX idx_order_status (order_status)
) COMMENT '订单信息表';

-- 2.3 用户行为日志表（无索引）
CREATE TABLE IF NOT EXISTS user_behavior_log (
                                                 id BIGINT PRIMARY KEY AUTO_INCREMENT,
                                                 user_id BIGINT,
                                                 session_id VARCHAR(64),
                                                 page_url VARCHAR(500),
                                                 action_type VARCHAR(50),
                                                 action_time DATETIME,
                                                 duration_sec INT,
                                                 device_type VARCHAR(20),
                                                 created_at DATETIME DEFAULT CURRENT_TIMESTAMP
    -- 故意不建索引
) COMMENT '用户行为日志表';

-- 2.4 促销活动表（无索引）
CREATE TABLE IF NOT EXISTS promotions (
                                          id BIGINT PRIMARY KEY AUTO_INCREMENT,
                                          promo_code VARCHAR(50),
                                          promo_name VARCHAR(200),
                                          discount_type VARCHAR(20) COMMENT '固定金额/百分比',
                                          discount_value DECIMAL(10,2),
                                          start_time DATETIME,
                                          end_time DATETIME,
                                          usage_limit INT COMMENT '使用次数限制',
                                          used_count INT DEFAULT 0,
                                          created_at DATETIME DEFAULT CURRENT_TIMESTAMP
    -- 故意不建索引
) COMMENT '促销活动表';

-- 2.5 库存流水表（有索引）
CREATE TABLE IF NOT EXISTS inventory_log (
                                             id BIGINT PRIMARY KEY AUTO_INCREMENT,
                                             product_id BIGINT NOT NULL,
                                             change_type VARCHAR(20) COMMENT '入库/出库/盘点',
                                             change_quantity INT COMMENT '变更数量',
                                             before_quantity INT COMMENT '变更前数量',
                                             after_quantity INT COMMENT '变更后数量',
                                             operator VARCHAR(50) COMMENT '操作人',
                                             remark VARCHAR(500) COMMENT '备注',
                                             created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
                                             INDEX idx_product_id (product_id),
                                             INDEX idx_created_at (created_at)
) COMMENT '库存流水表';

-- =====================================================
-- 三、插入模拟数据
-- =====================================================

-- 3.1 个人身份信息表（15条）
INSERT INTO personal_identity (full_name, id_card, passport_no, driver_license, birth_date, nationality, ethnicity, marital_status) VALUES
                                                                                                                                        ('张明', '11010119900307663X', 'E12345678', '11010119900307663X', '1990-03-07', '中国', '汉族', '已婚'),
                                                                                                                                        ('李芳', '310101198805124567', 'E87654321', '310101198805124567', '1988-05-12', '中国', '汉族', '已婚'),
                                                                                                                                        ('王磊', '440301199210235678', 'E23456789', '440301199210235678', '1992-10-23', '中国', '回族', '未婚'),
                                                                                                                                        ('赵静', '51010719870714789X', 'E98765432', '51010719870714789X', '1987-07-14', '中国', '汉族', '离异'),
                                                                                                                                        ('陈强', '320105199103156789', 'E34567890', '320105199103156789', '1991-03-15', '中国', '满族', '已婚'),
                                                                                                                                        ('刘娜', '350203199512019876', 'E09876543', '350203199512019876', '1995-12-01', '中国', '汉族', '未婚'),
                                                                                                                                        ('周涛', '120101198608128765', 'E45678901', '120101198608128765', '1986-08-12', '中国', '蒙古族', '已婚'),
                                                                                                                                        ('吴迪', '430103199311234321', 'E10987654', '430103199311234321', '1993-11-23', '中国', '汉族', '未婚'),
                                                                                                                                        ('郑爽', '210203199403211234', 'E56789012', '210203199403211234', '1994-03-21', '中国', '朝鲜族', '已婚'),
                                                                                                                                        ('林晨', '370202199707153456', 'E21098765', '370202199707153456', '1997-07-15', '中国', '汉族', '未婚'),
                                                                                                                                        ('郭峰', '500101198809194567', 'E67890123', '500101198809194567', '1988-09-19', '中国', '土家族', '已婚'),
                                                                                                                                        ('唐雅', '330105199410285678', 'E32109876', '330105199410285678', '1994-10-28', '中国', '汉族', '离异'),
                                                                                                                                        ('孙浩', '440304199612316789', 'E78901234', '440304199612316789', '1996-12-31', '中国', '汉族', '未婚'),
                                                                                                                                        ('许晴', '350582199811118901', 'E43210987', '350582199811118901', '1998-11-11', '中国', '汉族', '未婚'),
                                                                                                                                        ('韩雪', '410105200001012345', 'E89012345', '410105200001012345', '2000-01-01', '中国', '汉族', '未婚');

-- 3.2 个人联系方式表（12条）
INSERT INTO personal_contact (person_id, phone, email, wechat, qq, address, postal_code) VALUES
                                                                                             (1, '13812345678', 'zhangming@example.com', 'zhangming_wx', '12345678', '北京市朝阳区xxx路1号', '100020'),
                                                                                             (2, '13987654321', 'lifang@example.com', 'lifang_wx', '87654321', '上海市浦东新区xxx路2号', '200120'),
                                                                                             (3, '15812345678', 'wanglei@example.com', 'wanglei_wx', '23456789', '深圳市南山区xxx路3号', '518000'),
                                                                                             (4, '17712345678', 'zhaojing@example.com', 'zhaojing_wx', '98765432', '成都市高新区xxx路4号', '610000'),
                                                                                             (5, '18612345678', 'chenqiang@example.com', 'chenqiang_wx', '34567890', '杭州市西湖区xxx路5号', '310000'),
                                                                                             (6, '15987654321', 'liuna@example.com', 'liuna_wx', '10987654', '厦门市思明区xxx路6号', '361000'),
                                                                                             (7, '13512345678', 'zhoutao@example.com', 'zhoutao_wx', '45678901', '天津市和平区xxx路7号', '300000'),
                                                                                             (8, '15212345678', 'wudi@example.com', 'wudi_wx', '21098765', '长沙市岳麓区xxx路8号', '410000'),
                                                                                             (9, '18712345678', 'zhengshuang@example.com', 'zhengshuang_wx', '56789012', '大连市中山区xxx路9号', '116000'),
                                                                                             (10, '18812345678', 'linchen@example.com', 'linchen_wx', '32109876', '青岛市市南区xxx路10号', '266000'),
                                                                                             (11, '18912345678', 'guofeng@example.com', 'guofeng_wx', '67890123', '重庆市渝中区xxx路11号', '400000'),
                                                                                             (12, '16612345678', 'tangya@example.com', 'tangya_wx', '43210987', '宁波市鄞州区xxx路12号', '315000');

-- 3.3 公司核心信息表（10条）
INSERT INTO company_core (company_name, credit_code, tax_id, org_code, legal_person, registered_capital, founded_date, business_scope) VALUES
                                                                                                                                           ('云创科技股份有限公司', '91110000MA01A2B3C4', '91110000MA01A2B3C4', '12345678-9', '张伟', 50000000.00, '2015-03-15', '软件开发、技术咨询、数据处理'),
                                                                                                                                           ('海纳数据安全有限公司', '91440000MA05D6E7F8', '91440000MA05D6E7F8', '23456789-0', '李强', 30000000.00, '2016-06-20', '数据安全、网络安全、信息安全'),
                                                                                                                                           ('智联信息技术集团', '91370000MA09G8H9I0', '91370000MA09G8H9I0', '34567890-1', '王芳', 100000000.00, '2010-11-01', '信息技术、系统集成、云计算服务'),
                                                                                                                                           ('星辰云计算有限公司', '91420000MA11J2K3L4', '91420000MA11J2K3L4', '45678901-2', '赵磊', 20000000.00, '2018-08-18', '云计算服务、大数据处理'),
                                                                                                                                           ('安恒信息安全技术', '91350000MA13M4N5O6', '91350000MA13M4N5O6', '56789012-3', '陈华', 15000000.00, '2017-04-12', '信息安全、风险评估、安全运维'),
                                                                                                                                           ('致远软件科技', '91330000MA15P6Q7R8', '91330000MA15P6Q7R8', '67890123-4', '刘东', 25000000.00, '2014-09-25', '软件开发、软件销售、技术服务'),
                                                                                                                                           ('磐石区块链科技', '91220000MA17S8T9U0', '91220000MA17S8T9U0', '78901234-5', '徐凯', 40000000.00, '2019-01-10', '区块链技术、数字货币、智能合约'),
                                                                                                                                           ('天璇人工智能实验室', '91110000MA19V0W1X2', '91110000MA19V0W1X2', '89012345-6', '周平', 60000000.00, '2016-12-05', '人工智能、机器学习、计算机视觉'),
                                                                                                                                           ('昆仑金融科技集团', '91440000MA21W2Y3Z4', '91440000MA21W2Y3Z4', '90123456-7', '吴刚', 80000000.00, '2012-07-30', '金融科技、支付系统、风控管理'),
                                                                                                                                           ('华盾网络安全公司', '91370000MA23X4A5B6', '91370000MA23X4A5B6', '01234567-8', '郑强', 18000000.00, '2018-03-22', '网络安全、安全防护、安全咨询');

-- 3.4 公司财务信息表（10条）
INSERT INTO company_finance (company_id, bank_name, bank_account, swift_code, revenue, profit, tax_paid, debt_ratio) VALUES
                                                                                                                         (1, '中国工商银行北京分行', '6222020200123456789', 'ICBKCNBJBJM', 85000000.00, 12000000.00, 8000000.00, 45.50),
                                                                                                                         (2, '中国建设银行广州分行', '6217000100123456789', 'PCBCCNBJGZX', 45000000.00, 5500000.00, 3500000.00, 38.20),
                                                                                                                         (3, '招商银行深圳分行', '6214850200123456789', 'CMBCCNBS', 120000000.00, 25000000.00, 15000000.00, 52.30),
                                                                                                                         (4, '中国银行成都分行', '6013823100123456789', 'BKCHCNBJ570', 28000000.00, 3200000.00, 2200000.00, 32.50),
                                                                                                                         (5, '浦发银行上海分行', '6217920100123456789', 'SPDBCNSH', 35000000.00, 4800000.00, 3100000.00, 41.80),
                                                                                                                         (6, '交通银行杭州分行', '6222600110123456789', 'COMMCNSHHAN', 42000000.00, 6100000.00, 4200000.00, 44.00),
                                                                                                                         (7, '兴业银行北京分行', '6229090100123456789', 'FJIBCNBA', 68000000.00, 9800000.00, 7200000.00, 48.70),
                                                                                                                         (8, '中信银行深圳分行', '6217680100123456789', 'CIBKCNBJ', 95000000.00, 15200000.00, 10800000.00, 50.10),
                                                                                                                         (9, '民生银行上海分行', '6226220100123456789', 'MSBCCNBJ', 110000000.00, 18800000.00, 13500000.00, 55.60),
                                                                                                                         (10, '广发银行广州分行', '6214620100123456789', 'GDBKCN22', 32000000.00, 4100000.00, 2800000.00, 36.90);

-- 3.5 项目机密信息表（8条）
INSERT INTO project_secret (project_code, project_name, project_key, api_key, secret_key, database_url, database_password, cloud_access_key, cloud_secret_key, expire_date) VALUES
                                                                                                                                                                                ('PRJ-2024-001', '数据安全态势感知平台', 'proj_key_001_a3f5g7h9', 'ak_aliyun_001_x7k9m2', 'sk_aliyun_001_f8g3h6j1k4l7', 'jdbc:mysql://10.0.0.1:3306/db_security', 'db_pass_001_!QAZ2wsx', 'LTAI5tA1b2C3d4E5f6G7h8I9', 'aBcDeFgHiJkLmNoPqRsTuVwXyZ123456', '2025-12-31'),
                                                                                                                                                                                ('PRJ-2024-002', '企业数据资产发现系统', 'proj_key_002_b4g6h8i0', 'ak_tencent_002_y8n0p3', 'sk_tencent_002_g9h4i7j2k5l8', 'jdbc:mysql://10.0.0.2:3306/db_asset', 'db_pass_002_@WSX3edc', 'AKIDz8qXkLmNpRtYwB4cE7gH', 'sKcQaZxSwEdCfRvTgByHnMjUkLpO', '2025-10-31'),
                                                                                                                                                                                ('PRJ-2024-003', '数据分类分级管理系统', 'proj_key_003_c5h7i9j1', 'ak_huawei_003_z9p1q4', 'sk_huawei_003_h5i8j2k6l9m2', 'jdbc:mysql://10.0.0.3:3306/db_classify', 'db_pass_003_#EDC4rfv', 'UYH7G8V9B0N1M2K3L4P5Q6R', 'xYzAbC123dEfGhI456jKlMn789OpQ', '2025-09-30'),
                                                                                                                                                                                ('PRJ-2024-004', '数据库审计监控平台', 'proj_key_004_d6i8j0k2', 'ak_aws_004_a0q2r5', 'sk_aws_004_i6j9k3l7m0n3', 'jdbc:mysql://10.0.0.4:3306/db_audit', 'db_pass_004_5tgb^YHN', 'AKIAIOSFODNN7EXAMPLE', 'wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY', '2025-08-31'),
                                                                                                                                                                                ('PRJ-2024-005', '数据脱敏服务平台', 'proj_key_005_e7j9k1l3', 'ak_aliyun_005_b1r3s6', 'sk_aliyun_005_j7k0l4m8n1o4', 'jdbc:mysql://10.0.0.5:3306/db_mask', 'db_pass_005_6yhn&UJM', 'LTAI5tRfTgYhUjIkLpQwErT', 'bCdEfGhIjKlMnOpQrStUvWxYz098765', '2025-07-31'),
                                                                                                                                                                                ('PRJ-2024-006', '数据安全评估系统', 'proj_key_006_f8k0l2m4', 'ak_tencent_006_c2s4t7', 'sk_tencent_006_k8l1m5n9o2p5', 'jdbc:mysql://10.0.0.6:3306/db_assess', 'db_pass_006_7ujm*IK<', 'AKIDmNpRtYwB4cE7gHjK3L', 'tYbGvFcDxSzAwEqDrFtGyHuJkL', '2025-06-30'),
                                                                                                                                                                                ('PRJ-2024-007', '数据安全培训平台', 'proj_key_007_g9l1m3n5', 'ak_huawei_007_d3u5v8', 'sk_huawei_007_l9m2n6o0p3q6', 'jdbc:mysql://10.0.0.7:3306/db_train', 'db_pass_007_8ik,<LO', 'UYH7G8V9B0N1M2K3L4P5Q6R', 'xYzAbC123dEfGhI456jKlMn789OpQ', '2025-05-31'),
                                                                                                                                                                                ('PRJ-2024-008', '数据安全合规平台', 'proj_key_008_h0m2n4o6', 'ak_aws_008_e4v6w9', 'sk_aws_008_m0n3o7p1q4r7', 'jdbc:mysql://10.0.0.8:3306/db_comply', 'db_pass_008_9ol.;PN', 'AKIAJ7N9P2K5R8E6XAMPLE', 'mNoPqRsTuVwXyZ1234567890AbCdEfG', '2025-04-30');

-- 3.6 员工薪资信息表（15条）
INSERT INTO employee_salary (employee_no, full_name, department, position, base_salary, bonus, allowance, social_security_no, bank_card_no) VALUES
                                                                                                                                                ('EMP001', '张明', '技术研发部', '技术总监', 35000.00, 50000.00, 2000.00, 'SSN00123456', '6212260200123456789'),
                                                                                                                                                ('EMP002', '李芳', '产品部', '产品总监', 32000.00, 40000.00, 2000.00, 'SSN00234567', '6212260200234567890'),
                                                                                                                                                ('EMP003', '王磊', '销售部', '销售总监', 30000.00, 80000.00, 3000.00, 'SSN00345678', '6212260200345678901'),
                                                                                                                                                ('EMP004', '赵静', '技术研发部', '架构师', 28000.00, 30000.00, 1500.00, 'SSN00456789', '6212260200456789012'),
                                                                                                                                                ('EMP005', '陈强', '技术研发部', '高级工程师', 22000.00, 20000.00, 1000.00, 'SSN00567890', '6212260200567890123'),
                                                                                                                                                ('EMP006', '刘娜', '市场部', '市场经理', 18000.00, 15000.00, 1000.00, 'SSN00678901', '6212260200678901234'),
                                                                                                                                                ('EMP007', '周涛', '技术研发部', '工程师', 15000.00, 10000.00, 800.00, 'SSN00789012', '6212260200789012345'),
                                                                                                                                                ('EMP008', '吴迪', '运维部', '运维经理', 20000.00, 18000.00, 1000.00, 'SSN00890123', '6212260200890123456'),
                                                                                                                                                ('EMP009', '郑爽', '财务部', '财务经理', 25000.00, 20000.00, 1500.00, 'SSN00901234', '6212260200901234567'),
                                                                                                                                                ('EMP010', '林晨', '人事部', 'HR经理', 18000.00, 12000.00, 1000.00, 'SSN01012345', '6212260201012345678'),
                                                                                                                                                ('EMP011', '郭峰', '技术研发部', '工程师', 14000.00, 8000.00, 800.00, 'SSN01123456', '6212260201123456789'),
                                                                                                                                                ('EMP012', '唐雅', '销售部', '销售经理', 16000.00, 40000.00, 1000.00, 'SSN01234567', '6212260201234567890'),
                                                                                                                                                ('EMP013', '孙浩', '技术研发部', '工程师', 13000.00, 7000.00, 800.00, 'SSN01345678', '6212260201345678901'),
                                                                                                                                                ('EMP014', '许晴', '产品部', '产品经理', 17000.00, 15000.00, 1000.00, 'SSN01456789', '6212260201456789012'),
                                                                                                                                                ('EMP015', '韩雪', '市场部', '市场专员', 12000.00, 8000.00, 500.00, 'SSN01567890', '6212260201567890123');

-- 3.7 客户敏感信息表（12条）
INSERT INTO customer_sensitive (customer_name, contact_person, contact_phone, contract_no, contract_amount, payment_terms, discount_rate, credit_limit) VALUES
                                                                                                                                                            ('中国银行总行', '王建国', '13812345001', 'CT-2024-001', 2500000.00, '30%预付款+70%验收后', 5.00, 5000000.00),
                                                                                                                                                            ('华为技术有限公司', '李振华', '13987654002', 'CT-2024-002', 3800000.00, '40%预付款+60%验收后', 8.00, 8000000.00),
                                                                                                                                                            ('腾讯科技深圳公司', '马晓东', '15812345003', 'CT-2024-003', 4200000.00, '20%预付款+80%验收后', 10.00, 10000000.00),
                                                                                                                                                            ('阿里巴巴集团', '张建军', '17712345004', 'CT-2024-004', 5600000.00, '30%预付款+70%验收后', 12.00, 12000000.00),
                                                                                                                                                            ('百度在线网络技术', '刘志强', '18612345005', 'CT-2024-005', 3100000.00, '50%预付款+50%验收后', 6.00, 6000000.00),
                                                                                                                                                            ('京东世纪贸易公司', '陈国栋', '15912345006', 'CT-2024-006', 2800000.00, '40%预付款+60%验收后', 7.00, 5500000.00),
                                                                                                                                                            ('中国移动通信集团', '赵卫国', '13512345007', 'CT-2024-007', 4500000.00, '30%预付款+70%验收后', 9.00, 9000000.00),
                                                                                                                                                            ('国家电网有限公司', '孙建华', '15212345008', 'CT-2024-008', 6200000.00, '20%预付款+80%验收后', 11.00, 15000000.00),
                                                                                                                                                            ('中国平安保险集团', '周明远', '18712345009', 'CT-2024-009', 3500000.00, '50%预付款+50%验收后', 8.00, 7000000.00),
                                                                                                                                                            ('招商银行股份公司', '吴志勇', '18812345010', 'CT-2024-010', 2900000.00, '40%预付款+60%验收后', 6.00, 5800000.00),
                                                                                                                                                            ('字节跳动有限公司', '郑晓东', '18912345011', 'CT-2024-011', 4800000.00, '30%预付款+70%验收后', 10.00, 10000000.00),
                                                                                                                                                            ('美团科技公司', '林志文', '16612345012', 'CT-2024-012', 3300000.00, '35%预付款+65%验收后', 7.00, 6600000.00);

-- 3.8 知识产权信息表（10条）
INSERT INTO intellectual_property (ip_type, ip_name, registration_no, applicant, inventor, application_date, authorization_date, ip_value) VALUES
                                                                                                                                               ('专利', '一种数据安全检测方法及系统', 'ZL202410000001', '云创科技股份有限公司', '张明,李芳,王磊', '2024-01-10', '2024-06-15', 500000.00),
                                                                                                                                               ('专利', '基于大数据的敏感信息识别算法', 'ZL202410000002', '海纳数据安全有限公司', '陈强,赵静', '2024-02-05', '2024-07-20', 450000.00),
                                                                                                                                               ('软件著作权', '数据分类分级管理系统V1.0', '2024SR000001', '智联信息技术集团', '刘娜,周涛', '2024-01-15', '2024-04-10', 200000.00),
                                                                                                                                               ('软件著作权', '数据库审计监控平台V2.0', '2024SR000002', '星辰云计算有限公司', '吴迪,郑爽', '2024-02-20', '2024-05-18', 250000.00),
                                                                                                                                               ('商标', '数据盾牌图形商标', '70500001', '安恒信息安全技术', '林晨', '2023-11-01', '2024-03-25', 100000.00),
                                                                                                                                               ('专利', '基于区块链的数据存证方法', 'ZL202310000003', '磐石区块链科技', '郭峰,唐雅', '2023-09-10', '2024-02-28', 600000.00),
                                                                                                                                               ('软件著作权', '数据脱敏服务平台V3.0', '2023SR000015', '致远软件科技', '孙浩,许晴', '2023-10-15', '2024-01-20', 280000.00),
                                                                                                                                               ('专利', 'AI驱动的数据安全评估系统', 'ZL202310000008', '天璇人工智能实验室', '韩雪,张明', '2023-08-20', '2024-01-15', 550000.00),
                                                                                                                                               ('商标', '智安盾文字商标', '70450008', '昆仑金融科技集团', '李芳', '2023-12-01', '2024-04-20', 150000.00),
                                                                                                                                               ('软件著作权', '数据安全合规平台V1.0', '2024SR000025', '华盾网络安全公司', '王磊,陈强', '2024-03-01', '2024-06-10', 220000.00);

-- 3.9 系统账号权限表（12条）
INSERT INTO system_accounts (username, password_hash, role, permission, last_login_ip, last_login_time, is_active) VALUES
                                                                                                                       ('admin', '8c6976e5b5410415bde908bd4dee15dfb167a9c873fc4bb8a81f6f2ab448a918', '超级管理员', '*:*:*', '192.168.1.100', '2025-03-20 09:00:00', 1),
                                                                                                                       ('audit_admin', '5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8', '审计管理员', 'audit:*:*', '192.168.1.101', '2025-03-20 10:30:00', 1),
                                                                                                                       ('security_admin', '6b3a55e0261b03014489e4fe4d5f8e2c2e2b4b9e1c3d6e7f8a9b0c1d2e3f4a5b', '安全管理员', 'security:data:*', '192.168.1.102', '2025-03-20 11:15:00', 1),
                                                                                                                       ('operator01', '7c4b66f1272c14134b95d8c2f5e6f3d3f3c5c0f2d4e7f8a9b0c1d2e3f4a5b6c', '操作员', 'data:classify:read,data:mask:write', '10.0.0.1', '2025-03-19 14:20:00', 1),
                                                                                                                       ('operator02', '8d5c77g2383d25245ca6e9e3g6f7g4e4g4d6d1g3e5f8a9b0c1d2e3f4a5b6c7d', '操作员', 'data:audit:read,data:report:write', '10.0.0.2', '2025-03-19 15:30:00', 1),
                                                                                                                       ('monitor01', '9e6d88h3494e36356db7f0f4h7g8h5f5h5e7e2h4f6g9b0c1d2e3f4a5b6c7d8e9f', '监控员', 'monitor:*:read', '172.16.0.1', '2025-03-18 08:45:00', 1),
                                                                                                                       ('developer01', '0f7e99i4505f47467ec8g1g5i8h9i6g6i6f8f3i5g7h0c1d2e3f4a5b6c7d8e9f0a', '开发工程师', 'data:*:read,data:mask:write', '192.168.1.150', '2025-03-18 09:30:00', 1),
                                                                                                                       ('tester01', '1g8f00j5616g58578fd9h2h6j9i0j7h7j7g9g4j6h8i1d2e3f4a5b6c7d8e9f0a1b', '测试工程师', 'data:test:*', '192.168.1.151', '2025-03-17 13:20:00', 1),
                                                                                                                       ('report_user', '2h9g11k6727h69689ge0i3i7k0j1k8i8k8h0h5k7i9j2e3f4a5b6c7d8e9f0a1b2c', '报表用户', 'report:*:read', '10.0.0.5', '2025-03-17 10:15:00', 1),
                                                                                                                       ('backup_user', '3i0h22l7838i7079ahf1j4j8l1k2l9j9l9i1i6l8j0k3f4a5b6c7d8e9f0a1b2c3d', '备份管理员', 'backup:*:*', '172.16.0.5', '2025-03-16 16:00:00', 1),
                                                                                                                       ('disabled_user', '4j1i33m8949j8180big2k5k9m2l3m0k0m0j2j7m9k1l4g5a6b7c8d9e0f1a2b3c4d', '操作员', 'data:read', '192.168.1.200', '2024-12-01 08:00:00', 0),
                                                                                                                       ('temp_user', '5k2j44n9050k9291cjh3l6l0n3m4n1l1n1k3k8n0l2m5h6b7c8d9e0f1a2b3c4d5e', '临时用户', 'temp:access', NULL, NULL, 0);

-- 3.10 日志审计信息表（15条）
INSERT INTO audit_logs (operator, operation_type, target_table, target_id, old_value, new_value, client_ip, created_at) VALUES
                                                                                                                            ('admin', 'CREATE', 'system_accounts', 1, NULL, '创建用户admin', '192.168.1.100', '2025-03-20 09:00:00'),
                                                                                                                            ('admin', 'GRANT', 'system_accounts', 2, '角色:无', '角色:审计管理员', '192.168.1.100', '2025-03-20 09:05:00'),
                                                                                                                            ('security_admin', 'UPDATE', 'project_secret', 1, '密钥:旧值', '密钥:已轮换', '192.168.1.102', '2025-03-20 11:00:00'),
                                                                                                                            ('audit_admin', 'SELECT', 'company_finance', 5, NULL, '查询公司财务数据', '192.168.1.101', '2025-03-20 10:35:00'),
                                                                                                                            ('operator01', 'UPDATE', 'personal_identity', 3, '电话:旧号码', '电话:新号码', '10.0.0.1', '2025-03-19 14:25:00'),
                                                                                                                            ('admin', 'DELETE', 'system_accounts', 11, '用户:disabled_user', '已删除', '192.168.1.100', '2025-03-19 15:00:00'),
                                                                                                                            ('security_admin', 'CREATE', 'project_secret', 8, NULL, '创建新项目密钥', '192.168.1.102', '2025-03-19 16:20:00'),
                                                                                                                            ('operator02', 'EXPORT', 'customer_sensitive', NULL, NULL, '导出客户数据(1000条)', '10.0.0.2', '2025-03-19 15:35:00'),
                                                                                                                            ('admin', 'UPDATE', 'employee_salary', 2, '基本工资:30000', '基本工资:32000', '192.168.1.100', '2025-03-18 10:00:00'),
                                                                                                                            ('audit_admin', 'SELECT', 'project_secret', 4, NULL, '审计项目密钥配置', '192.168.1.101', '2025-03-18 14:20:00'),
                                                                                                                            ('developer01', 'UPDATE', 'system_accounts', 7, '密码:旧哈希', '密码:新哈希', '192.168.1.150', '2025-03-18 09:35:00'),
                                                                                                                            ('admin', 'REVOKE', 'system_accounts', 12, '角色:临时用户', '已禁用', '192.168.1.100', '2025-03-17 11:00:00'),
                                                                                                                            ('security_admin', 'SELECT', 'cloud_credentials', 2, NULL, '检查AK/SK安全性', '192.168.1.102', '2025-03-17 15:30:00'),
                                                                                                                            ('operator01', 'UPDATE', 'intellectual_property', 5, '评估值:80,000', '评估值:100,000', '10.0.0.1', '2025-03-16 09:15:00'),
                                                                                                                            ('audit_admin', 'SELECT', 'audit_logs', NULL, NULL, '审计日志查询', '192.168.1.101', '2025-03-16 16:45:00');

-- =====================================================
-- 四、业务表数据
-- =====================================================

-- 4.1 产品信息表（20条）
INSERT INTO products (product_code, product_name, category, price, cost, stock, status) VALUES
                                                                                            ('P10001', '数据安全态势感知平台', '安全软件', 350000.00, 150000.00, 999, 1),
                                                                                            ('P10002', '数据分类分级系统', '安全软件', 280000.00, 120000.00, 999, 1),
                                                                                            ('P10003', '数据库审计系统', '安全软件', 180000.00, 80000.00, 999, 1),
                                                                                            ('P10004', '数据脱敏系统', '安全软件', 220000.00, 100000.00, 999, 1),
                                                                                            ('P10005', '数据安全评估服务', '安全服务', 150000.00, 60000.00, 999, 1),
                                                                                            ('P10006', '数据安全培训课程', '培训服务', 50000.00, 20000.00, 999, 1),
                                                                                            ('P10007', '数据安全咨询服务', '咨询服务', 200000.00, 80000.00, 999, 1),
                                                                                            ('P10008', '数据安全运维服务', '运维服务', 300000.00, 150000.00, 999, 1),
                                                                                            ('P10009', '数据安全备份系统', '备份软件', 120000.00, 50000.00, 999, 1),
                                                                                            ('P10010', '数据安全加密系统', '加密软件', 250000.00, 110000.00, 999, 1),
                                                                                            ('P10011', '数据安全审计服务', '审计服务', 180000.00, 70000.00, 999, 1),
                                                                                            ('P10012', '数据安全合规平台', '合规软件', 320000.00, 140000.00, 999, 1),
                                                                                            ('P10013', '数据安全应急响应', '应急服务', 250000.00, 100000.00, 999, 1),
                                                                                            ('P10014', '数据安全演练服务', '演练服务', 80000.00, 35000.00, 999, 1),
                                                                                            ('P10015', '数据安全保险产品', '保险服务', 50000.00, 20000.00, 999, 1),
                                                                                            ('P10016', '数据安全监测平台', '监测软件', 280000.00, 120000.00, 999, 1),
                                                                                            ('P10017', '数据安全响应平台', '响应软件', 260000.00, 110000.00, 999, 1),
                                                                                            ('P10018', '数据安全治理平台', '治理软件', 380000.00, 160000.00, 999, 1),
                                                                                            ('P10019', '数据安全风险评估', '评估服务', 120000.00, 50000.00, 999, 1),
                                                                                            ('P10020', '数据安全加固服务', '加固服务', 150000.00, 65000.00, 999, 1);

-- 4.2 订单信息表（20条）
INSERT INTO orders (order_no, user_id, product_id, quantity, unit_price, total_amount, order_status, pay_time) VALUES
                                                                                                                   ('ORD202503200001', 1, 1, 1, 350000.00, 350000.00, 1, '2025-03-20 10:00:00'),
                                                                                                                   ('ORD202503200002', 2, 2, 1, 280000.00, 280000.00, 1, '2025-03-20 11:30:00'),
                                                                                                                   ('ORD202503200003', 3, 3, 2, 180000.00, 360000.00, 1, '2025-03-20 14:20:00'),
                                                                                                                   ('ORD202503190004', 4, 4, 1, 220000.00, 220000.00, 0, NULL),
                                                                                                                   ('ORD202503190005', 5, 5, 1, 150000.00, 150000.00, 2, '2025-03-19 09:15:00'),
                                                                                                                   ('ORD202503180006', 6, 6, 3, 50000.00, 150000.00, 3, '2025-03-18 16:30:00'),
                                                                                                                   ('ORD202503180007', 7, 7, 1, 200000.00, 200000.00, 1, '2025-03-18 10:45:00'),
                                                                                                                   ('ORD202503170008', 8, 8, 1, 300000.00, 300000.00, 4, NULL),
                                                                                                                   ('ORD202503170009', 9, 9, 2, 120000.00, 240000.00, 1, '2025-03-17 13:20:00'),
                                                                                                                   ('ORD202503160010', 10, 10, 1, 250000.00, 250000.00, 2, '2025-03-16 11:00:00'),
                                                                                                                   ('ORD202503160011', 11, 11, 1, 180000.00, 180000.00, 3, '2025-03-16 09:30:00'),
                                                                                                                   ('ORD202503150012', 12, 12, 1, 320000.00, 320000.00, 1, '2025-03-15 14:50:00'),
                                                                                                                   ('ORD202503150013', 13, 13, 1, 250000.00, 250000.00, 0, NULL),
                                                                                                                   ('ORD202503140014', 14, 14, 2, 80000.00, 160000.00, 1, '2025-03-14 10:10:00'),
                                                                                                                   ('ORD202503140015', 15, 15, 1, 50000.00, 50000.00, 1, '2025-03-14 15:40:00'),
                                                                                                                   ('ORD202503130016', 1, 16, 1, 280000.00, 280000.00, 3, '2025-03-13 11:25:00'),
                                                                                                                   ('ORD202503130017', 2, 17, 1, 260000.00, 260000.00, 2, '2025-03-13 09:00:00'),
                                                                                                                   ('ORD202503120018', 3, 18, 1, 380000.00, 380000.00, 1, '2025-03-12 16:15:00'),
                                                                                                                   ('ORD202503120019', 4, 19, 2, 120000.00, 240000.00, 0, NULL),
                                                                                                                   ('ORD202503110020', 5, 20, 1, 150000.00, 150000.00, 1, '2025-03-11 13:35:00');

-- 4.3 用户行为日志表（20条）
INSERT INTO user_behavior_log (user_id, session_id, page_url, action_type, action_time, duration_sec, device_type) VALUES
                                                                                                                       (1, 'sess_001_abc123', '/dashboard', 'page_view', '2025-03-20 09:00:00', 120, 'PC'),
                                                                                                                       (1, 'sess_001_abc123', '/data/classify', 'click', '2025-03-20 09:05:00', 5, 'PC'),
                                                                                                                       (2, 'sess_002_def456', '/security/audit', 'page_view', '2025-03-20 10:30:00', 300, 'PC'),
                                                                                                                       (2, 'sess_002_def456', '/report/export', 'download', '2025-03-20 10:35:00', 10, 'PC'),
                                                                                                                       (3, 'sess_003_ghi789', '/data/mask', 'page_view', '2025-03-20 14:00:00', 180, 'Mobile'),
                                                                                                                       (4, 'sess_004_jkl012', '/dashboard', 'login', '2025-03-19 09:00:00', 45, 'PC'),
                                                                                                                       (5, 'sess_005_mno345', '/project/config', 'update', '2025-03-19 11:20:00', 60, 'PC'),
                                                                                                                       (6, 'sess_006_pqr678', '/data/backup', 'page_view', '2025-03-18 15:00:00', 90, 'PC'),
                                                                                                                       (7, 'sess_007_stu901', '/security/report', 'export', '2025-03-18 10:15:00', 8, 'Mobile'),
                                                                                                                       (8, 'sess_008_vwx234', '/admin/users', 'search', '2025-03-17 14:30:00', 15, 'PC'),
                                                                                                                       (9, 'sess_009_yz567', '/dashboard', 'page_view', '2025-03-17 09:45:00', 200, 'PC'),
                                                                                                                       (10, 'sess_010_abc890', '/data/classify', 'create', '2025-03-16 16:00:00', 25, 'PC'),
                                                                                                                       (11, 'sess_011_def123', '/security/audit', 'page_view', '2025-03-16 11:30:00', 150, 'Mobile'),
                                                                                                                       (12, 'sess_012_ghi456', '/report/view', 'click', '2025-03-15 10:00:00', 3, 'PC'),
                                                                                                                       (13, 'sess_013_jkl789', '/project/secret', 'update', '2025-03-15 13:20:00', 40, 'PC'),
                                                                                                                       (14, 'sess_014_mno012', '/dashboard', 'logout', '2025-03-14 17:00:00', 10, 'PC'),
                                                                                                                       (15, 'sess_015_pqr345', '/data/mask', 'preview', '2025-03-14 09:30:00', 12, 'Mobile'),
                                                                                                                       (1, 'sess_016_stu678', '/admin/settings', 'update', '2025-03-13 11:00:00', 35, 'PC'),
                                                                                                                       (2, 'sess_017_vwx901', '/security/report', 'download', '2025-03-13 09:15:00', 6, 'PC'),
                                                                                                                       (3, 'sess_018_yz234', '/dashboard', 'page_view', '2025-03-12 15:30:00', 180, 'PC');

-- 4.4 促销活动表（10条）
INSERT INTO promotions (promo_code, promo_name, discount_type, discount_value, start_time, end_time, usage_limit, used_count) VALUES
                                                                                                                                  ('SPRING2025', '春季大促', '百分比', 10.00, '2025-03-01 00:00:00', '2025-03-31 23:59:59', 100, 45),
                                                                                                                                  ('NEWUSER50', '新用户专享', '固定金额', 5000.00, '2025-01-01 00:00:00', '2025-12-31 23:59:59', 50, 23),
                                                                                                                                  ('SECURITY25', '安全产品特惠', '百分比', 15.00, '2025-03-15 00:00:00', '2025-04-15 23:59:59', 200, 67),
                                                                                                                                  ('BULK20', '批量采购优惠', '百分比', 20.00, '2025-01-01 00:00:00', '2025-12-31 23:59:59', 30, 8),
                                                                                                                                  ('VIP10', 'VIP专享折扣', '百分比', 8.00, '2025-01-01 00:00:00', '2025-12-31 23:59:59', 999, 156),
                                                                                                                                  ('EARLYBIRD', '早鸟优惠', '固定金额', 3000.00, '2025-03-01 00:00:00', '2025-03-10 23:59:59', 20, 20),
                                                                                                                                  ('TEAM5', '团队采购5套以上', '百分比', 12.00, '2025-01-01 00:00:00', '2025-12-31 23:59:59', 100, 12),
                                                                                                                                  ('EDUCATION', '教育行业优惠', '百分比', 25.00, '2025-01-01 00:00:00', '2025-12-31 23:59:59', 50, 5),
                                                                                                                                  ('REFERRAL', '推荐有礼', '固定金额', 2000.00, '2025-01-01 00:00:00', '2025-12-31 23:59:59', 200, 34),
                                                                                                                                  ('ANNIVERSARY', '周年庆特惠', '百分比', 18.00, '2025-04-01 00:00:00', '2025-04-30 23:59:59', 300, 0);

-- 4.5 库存流水表（20条）
INSERT INTO inventory_log (product_id, change_type, change_quantity, before_quantity, after_quantity, operator, remark) VALUES
                                                                                                                            (1, '入库', 100, 900, 1000, '采购员', '初始库存'),
                                                                                                                            (2, '入库', 100, 900, 1000, '采购员', '初始库存'),
                                                                                                                            (3, '入库', 100, 900, 1000, '采购员', '初始库存'),
                                                                                                                            (4, '出库', 1, 1000, 999, '销售员', '订单ORD202503190004'),
                                                                                                                            (5, '出库', 1, 1000, 999, '销售员', '订单ORD202503190005'),
                                                                                                                            (6, '出库', 3, 1000, 997, '销售员', '订单ORD202503180006'),
                                                                                                                            (7, '出库', 1, 1000, 999, '销售员', '订单ORD202503180007'),
                                                                                                                            (8, '入库', 50, 950, 1000, '采购员', '补货'),
                                                                                                                            (9, '出库', 2, 1000, 998, '销售员', '订单ORD202503170009'),
                                                                                                                            (10, '出库', 1, 1000, 999, '销售员', '订单ORD202503160010'),
                                                                                                                            (11, '出库', 1, 1000, 999, '销售员', '订单ORD202503160011'),
                                                                                                                            (12, '入库', 30, 970, 1000, '采购员', '补货'),
                                                                                                                            (13, '出库', 1, 1000, 999, '销售员', '订单ORD202503150013'),
                                                                                                                            (14, '出库', 2, 1000, 998, '销售员', '订单ORD202503140014'),
                                                                                                                            (15, '出库', 1, 1000, 999, '销售员', '订单ORD202503140015'),
                                                                                                                            (16, '出库', 1, 1000, 999, '销售员', '订单ORD202503130016'),
                                                                                                                            (17, '出库', 1, 1000, 999, '销售员', '订单ORD202503130017'),
                                                                                                                            (18, '出库', 1, 1000, 999, '销售员', '订单ORD202503120018'),
                                                                                                                            (19, '出库', 2, 1000, 998, '销售员', '订单ORD202503120019'),
                                                                                                                            (20, '出库', 1, 1000, 999, '销售员', '订单ORD202503110020');

-- =====================================================
-- 五、数据统计验证
-- =====================================================
SELECT '=== 数据统计 ===' AS '';
SELECT 'personal_identity' AS table_name, COUNT(*) AS row_count FROM personal_identity
UNION ALL SELECT 'personal_contact', COUNT(*) FROM personal_contact
UNION ALL SELECT 'company_core', COUNT(*) FROM company_core
UNION ALL SELECT 'company_finance', COUNT(*) FROM company_finance
UNION ALL SELECT 'project_secret', COUNT(*) FROM project_secret
UNION ALL SELECT 'employee_salary', COUNT(*) FROM employee_salary
UNION ALL SELECT 'customer_sensitive', COUNT(*) FROM customer_sensitive
UNION ALL SELECT 'intellectual_property', COUNT(*) FROM intellectual_property
UNION ALL SELECT 'system_accounts', COUNT(*) FROM system_accounts
UNION ALL SELECT 'audit_logs', COUNT(*) FROM audit_logs
UNION ALL SELECT 'products', COUNT(*) FROM products
UNION ALL SELECT 'orders', COUNT(*) FROM orders
UNION ALL SELECT 'user_behavior_log', COUNT(*) FROM user_behavior_log
UNION ALL SELECT 'promotions', COUNT(*) FROM promotions
UNION ALL SELECT 'inventory_log', COUNT(*) FROM inventory_log;


-- =====================================================
-- 使用数据库
-- =====================================================
USE data_sec_demo;

-- =====================================================
-- 一、新增敏感信息表（10张）
-- =====================================================

-- 1.1 银行卡信息表（有索引）
CREATE TABLE IF NOT EXISTS bank_card_info (
                                              id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键ID',
                                              card_holder_name VARCHAR(50) NOT NULL COMMENT '持卡人姓名',
                                              bank_name VARCHAR(100) COMMENT '开户银行',
                                              bank_card_no VARCHAR(25) NOT NULL COMMENT '银行卡号',
                                              card_type VARCHAR(20) COMMENT '卡类型:借记卡/信用卡',
                                              cvv_code VARCHAR(4) COMMENT 'CVV码',
                                              expire_date VARCHAR(10) COMMENT '有效期(MM/YY)',
                                              id_card_no VARCHAR(18) COMMENT '关联身份证号',
                                              phone VARCHAR(11) COMMENT '预留手机号',
                                              created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
                                              INDEX idx_card_no (bank_card_no),
                                              INDEX idx_card_holder (card_holder_name)
) COMMENT '银行卡信息表';

-- 1.2 医疗病历表（有索引）
CREATE TABLE IF NOT EXISTS medical_records (
                                               id BIGINT PRIMARY KEY AUTO_INCREMENT,
                                               patient_name VARCHAR(50) NOT NULL COMMENT '患者姓名',
                                               patient_id_card VARCHAR(18) COMMENT '患者身份证',
                                               medical_record_no VARCHAR(30) COMMENT '病历号',
                                               diagnosis TEXT COMMENT '诊断结果',
                                               prescription TEXT COMMENT '处方信息',
                                               surgery_history TEXT COMMENT '手术史',
                                               medication_allergy VARCHAR(200) COMMENT '药物过敏',
                                               hospital_name VARCHAR(100) COMMENT '医院名称',
                                               doctor_name VARCHAR(50) COMMENT '主治医生',
                                               visit_date DATE COMMENT '就诊日期',
                                               created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
                                               INDEX idx_patient_id_card (patient_id_card),
                                               INDEX idx_medical_no (medical_record_no)
) COMMENT '医疗病历表';

-- 1.3 保险保单表（有索引）
CREATE TABLE IF NOT EXISTS insurance_policies (
                                                  id BIGINT PRIMARY KEY AUTO_INCREMENT,
                                                  policy_no VARCHAR(50) NOT NULL COMMENT '保单号',
                                                  insured_name VARCHAR(50) COMMENT '投保人姓名',
                                                  insured_id_card VARCHAR(18) COMMENT '投保人身份证',
                                                  beneficiary VARCHAR(50) COMMENT '受益人',
                                                  insurance_type VARCHAR(50) COMMENT '险种类型',
                                                  coverage_amount DECIMAL(15,2) COMMENT '保额',
                                                  premium DECIMAL(10,2) COMMENT '保费',
                                                  start_date DATE COMMENT '生效日期',
                                                  end_date DATE COMMENT '到期日期',
                                                  policy_status VARCHAR(20) COMMENT '保单状态',
                                                  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
                                                  INDEX idx_policy_no (policy_no),
                                                  INDEX idx_insured_id_card (insured_id_card)
) COMMENT '保险保单表';

-- 1.4 房产信息表（有索引）
CREATE TABLE IF NOT EXISTS property_info (
                                             id BIGINT PRIMARY KEY AUTO_INCREMENT,
                                             owner_name VARCHAR(50) NOT NULL COMMENT '业主姓名',
                                             owner_id_card VARCHAR(18) COMMENT '业主身份证',
                                             property_address VARCHAR(500) COMMENT '房产地址',
                                             property_cert_no VARCHAR(50) COMMENT '房产证号',
                                             land_cert_no VARCHAR(50) COMMENT '土地证号',
                                             building_area DECIMAL(10,2) COMMENT '建筑面积',
                                             purchase_price DECIMAL(12,2) COMMENT '购买价格',
                                             mortgage_amount DECIMAL(12,2) COMMENT '抵押金额',
                                             mortgage_bank VARCHAR(100) COMMENT '抵押银行',
                                             created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
                                             INDEX idx_owner_id_card (owner_id_card),
                                             INDEX idx_cert_no (property_cert_no)
) COMMENT '房产信息表';

-- 1.5 车辆信息表（有索引）
CREATE TABLE IF NOT EXISTS vehicle_info (
                                            id BIGINT PRIMARY KEY AUTO_INCREMENT,
                                            owner_name VARCHAR(50) NOT NULL COMMENT '车主姓名',
                                            owner_id_card VARCHAR(18) COMMENT '车主身份证',
                                            license_plate VARCHAR(15) COMMENT '车牌号',
                                            vin VARCHAR(17) COMMENT '车架号',
                                            engine_no VARCHAR(20) COMMENT '发动机号',
                                            brand_model VARCHAR(100) COMMENT '品牌型号',
                                            registration_date DATE COMMENT '注册日期',
                                            vehicle_color VARCHAR(20) COMMENT '颜色',
                                            loan_status VARCHAR(20) COMMENT '贷款状态',
                                            created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
                                            INDEX idx_license_plate (license_plate),
                                            INDEX idx_vin (vin)
) COMMENT '车辆信息表';

-- 1.6 教育学历信息表（有索引）
CREATE TABLE IF NOT EXISTS education_info (
                                              id BIGINT PRIMARY KEY AUTO_INCREMENT,
                                              person_name VARCHAR(50) NOT NULL COMMENT '姓名',
                                              person_id_card VARCHAR(18) COMMENT '身份证号',
                                              education_level VARCHAR(50) COMMENT '学历层次',
                                              institution_name VARCHAR(200) COMMENT '毕业院校',
                                              major VARCHAR(100) COMMENT '专业',
                                              student_no VARCHAR(30) COMMENT '学号',
                                              degree_cert_no VARCHAR(50) COMMENT '学位证书编号',
                                              graduation_date DATE COMMENT '毕业日期',
                                              degree_type VARCHAR(30) COMMENT '学位类型',
                                              created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
                                              INDEX idx_person_id_card (person_id_card),
                                              INDEX idx_degree_no (degree_cert_no)
) COMMENT '教育学历信息表';

-- 1.7 税务信息表（有索引）
CREATE TABLE IF NOT EXISTS tax_info (
                                        id BIGINT PRIMARY KEY AUTO_INCREMENT,
                                        taxpayer_name VARCHAR(100) NOT NULL COMMENT '纳税人姓名',
                                        taxpayer_id VARCHAR(20) COMMENT '纳税人识别号',
                                        id_card VARCHAR(18) COMMENT '身份证号',
                                        income_amount DECIMAL(12,2) COMMENT '收入金额',
                                        tax_amount DECIMAL(10,2) COMMENT '应纳税额',
                                        tax_paid DECIMAL(10,2) COMMENT '已缴税额',
                                        tax_year INT COMMENT '纳税年度',
                                        employer VARCHAR(200) COMMENT '任职单位',
                                        tax_bureau VARCHAR(100) COMMENT '主管税务机关',
                                        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
                                        INDEX idx_taxpayer_id (taxpayer_id),
                                        INDEX idx_id_card (id_card)
) COMMENT '税务信息表';

-- 1.8 社交账号信息表（无索引）
CREATE TABLE IF NOT EXISTS social_accounts (
                                               id BIGINT PRIMARY KEY AUTO_INCREMENT,
                                               platform_name VARCHAR(50) NOT NULL COMMENT '平台名称',
                                               user_id VARCHAR(100) NOT NULL COMMENT '用户ID',
                                               nickname VARCHAR(100) COMMENT '昵称',
                                               real_name VARCHAR(50) COMMENT '真实姓名',
                                               phone VARCHAR(11) COMMENT '绑定手机',
                                               email VARCHAR(100) COMMENT '绑定邮箱',
                                               follower_count INT COMMENT '粉丝数',
                                               is_verified TINYINT DEFAULT 0 COMMENT '是否认证',
                                               created_at DATETIME DEFAULT CURRENT_TIMESTAMP
    -- 故意不建索引
) COMMENT '社交账号信息表';

-- 1.9 生物特征信息表（无索引）
CREATE TABLE IF NOT EXISTS biometric_info (
                                              id BIGINT PRIMARY KEY AUTO_INCREMENT,
                                              person_name VARCHAR(50) NOT NULL,
                                              person_id_card VARCHAR(18),
                                              fingerprint_hash VARCHAR(255) COMMENT '指纹哈希',
                                              face_feature VARCHAR(1000) COMMENT '人脸特征向量',
                                              iris_code VARCHAR(500) COMMENT '虹膜编码',
                                              voice_print VARCHAR(500) COMMENT '声纹特征',
                                              signature_hash VARCHAR(255) COMMENT '签名哈希',
                                              created_at DATETIME DEFAULT CURRENT_TIMESTAMP
    -- 故意不建索引
) COMMENT '生物特征信息表';

-- 1.10 支付交易记录表（有索引）
CREATE TABLE IF NOT EXISTS payment_transactions (
                                                    id BIGINT PRIMARY KEY AUTO_INCREMENT,
                                                    transaction_no VARCHAR(50) NOT NULL COMMENT '交易流水号',
                                                    payer_name VARCHAR(50) COMMENT '付款人',
                                                    payer_card_no VARCHAR(25) COMMENT '付款卡号',
                                                    payee_name VARCHAR(50) COMMENT '收款人',
                                                    payee_card_no VARCHAR(25) COMMENT '收款卡号',
                                                    amount DECIMAL(12,2) COMMENT '交易金额',
                                                    currency VARCHAR(10) DEFAULT 'CNY' COMMENT '币种',
                                                    transaction_time DATETIME COMMENT '交易时间',
                                                    transaction_type VARCHAR(30) COMMENT '交易类型',
                                                    status VARCHAR(20) COMMENT '交易状态',
                                                    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
                                                    INDEX idx_transaction_no (transaction_no),
                                                    INDEX idx_payer_card (payer_card_no),
                                                    INDEX idx_payee_card (payee_card_no)
) COMMENT '支付交易记录表';

-- =====================================================
-- 二、新增业务表（5张）
-- =====================================================

-- 2.1 商品评价表（有索引）
CREATE TABLE IF NOT EXISTS product_reviews (
                                               id BIGINT PRIMARY KEY AUTO_INCREMENT,
                                               product_id BIGINT NOT NULL COMMENT '产品ID',
                                               user_id BIGINT COMMENT '用户ID',
                                               rating TINYINT COMMENT '评分1-5',
                                               review_title VARCHAR(200) COMMENT '评价标题',
                                               review_content TEXT COMMENT '评价内容',
                                               images_url VARCHAR(1000) COMMENT '图片URL',
                                               like_count INT DEFAULT 0 COMMENT '点赞数',
                                               is_deleted TINYINT DEFAULT 0 COMMENT '是否删除',
                                               created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
                                               INDEX idx_product_id (product_id),
                                               INDEX idx_user_id (user_id)
) COMMENT '商品评价表';

-- 2.2 购物车表（有索引）
CREATE TABLE IF NOT EXISTS shopping_cart (
                                             id BIGINT PRIMARY KEY AUTO_INCREMENT,
                                             user_id BIGINT NOT NULL COMMENT '用户ID',
                                             product_id BIGINT NOT NULL COMMENT '产品ID',
                                             quantity INT DEFAULT 1 COMMENT '数量',
                                             selected TINYINT DEFAULT 1 COMMENT '是否选中',
                                             created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
                                             updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                                             INDEX idx_user_id (user_id),
                                             INDEX idx_product_id (product_id)
) COMMENT '购物车表';

-- 2.3 优惠券表（无索引）
CREATE TABLE IF NOT EXISTS coupons (
                                       id BIGINT PRIMARY KEY AUTO_INCREMENT,
                                       coupon_code VARCHAR(50) NOT NULL,
                                       coupon_name VARCHAR(200),
                                       discount_type VARCHAR(20),
                                       discount_value DECIMAL(10,2),
                                       min_amount DECIMAL(10,2) COMMENT '最低使用金额',
                                       user_id BIGINT COMMENT '领券用户ID',
                                       status TINYINT DEFAULT 0 COMMENT '0未使用 1已使用 2已过期',
                                       start_time DATETIME,
                                       end_time DATETIME,
                                       use_time DATETIME,
                                       created_at DATETIME DEFAULT CURRENT_TIMESTAMP
    -- 故意不建索引
) COMMENT '优惠券表';

-- 2.4 用户收藏表（有索引）
CREATE TABLE IF NOT EXISTS user_favorites (
                                              id BIGINT PRIMARY KEY AUTO_INCREMENT,
                                              user_id BIGINT NOT NULL,
                                              favorite_type VARCHAR(30) COMMENT '收藏类型:product/article',
                                              target_id BIGINT NOT NULL COMMENT '目标ID',
                                              favorite_time DATETIME DEFAULT CURRENT_TIMESTAMP,
                                              created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
                                              INDEX idx_user_id (user_id),
                                              INDEX idx_target (favorite_type, target_id)
) COMMENT '用户收藏表';

-- 2.5 系统通知表（无索引）
CREATE TABLE IF NOT EXISTS system_notifications (
                                                    id BIGINT PRIMARY KEY AUTO_INCREMENT,
                                                    title VARCHAR(200) NOT NULL,
                                                    content TEXT,
                                                    notification_type VARCHAR(30) COMMENT '系统/活动/公告',
                                                    target_user_id BIGINT COMMENT '目标用户ID(0表示全体)',
                                                    is_read TINYINT DEFAULT 0,
                                                    read_time DATETIME,
                                                    send_time DATETIME,
                                                    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
    -- 故意不建索引
) COMMENT '系统通知表';

-- =====================================================
-- 三、插入模拟数据
-- =====================================================

-- 3.1 银行卡信息表（12条）
INSERT INTO bank_card_info (card_holder_name, bank_name, bank_card_no, card_type, cvv_code, expire_date, id_card_no, phone) VALUES
                                                                                                                                ('张明', '中国工商银行', '6212260200123456789', '借记卡', '123', '12/28', '11010119900307663X', '13812345678'),
                                                                                                                                ('李芳', '中国建设银行', '6217000100123456789', '信用卡', '456', '08/27', '310101198805124567', '13987654321'),
                                                                                                                                ('王磊', '招商银行', '6214850200123456789', '借记卡', '789', '10/26', '440301199210235678', '15812345678'),
                                                                                                                                ('赵静', '中国银行', '6013823100123456789', '信用卡', '234', '03/29', '51010719870714789X', '17712345678'),
                                                                                                                                ('陈强', '交通银行', '6222600110123456789', '借记卡', '567', '05/30', '320105199103156789', '18612345678'),
                                                                                                                                ('刘娜', '浦发银行', '6217920100123456789', '信用卡', '890', '01/28', '350203199512019876', '15987654321'),
                                                                                                                                ('周涛', '兴业银行', '6229090100123456789', '借记卡', '345', '09/27', '120101198608128765', '13512345678'),
                                                                                                                                ('吴迪', '中信银行', '6217680100123456789', '信用卡', '678', '07/26', '430103199311234321', '15212345678'),
                                                                                                                                ('郑爽', '民生银行', '6226220100123456789', '借记卡', '901', '11/25', '210203199403211234', '18712345678'),
                                                                                                                                ('林晨', '广发银行', '6214620100123456789', '信用卡', '234', '02/29', '370202199707153456', '18812345678'),
                                                                                                                                ('郭峰', '平安银行', '6229081234567890', '借记卡', '567', '04/28', '500101198809194567', '18912345678'),
                                                                                                                                ('唐雅', '光大银行', '6214920100123456789', '信用卡', '890', '06/27', '330105199410285678', '16612345678');

-- 3.2 医疗病历表（10条）
INSERT INTO medical_records (patient_name, patient_id_card, medical_record_no, diagnosis, prescription, surgery_history, medication_allergy, hospital_name, doctor_name, visit_date) VALUES
                                                                                                                                                                                         ('张明', '11010119900307663X', 'MR202400001', '高血压2级', '硝苯地平片 30mg qd', '无', '无', '北京协和医院', '李医生', '2024-01-15'),
                                                                                                                                                                                         ('李芳', '310101198805124567', 'MR202400002', '糖尿病2型', '二甲双胍 0.5g bid', '阑尾切除术', '青霉素', '上海瑞金医院', '王医生', '2024-02-20'),
                                                                                                                                                                                         ('王磊', '440301199210235678', 'MR202400003', '急性上呼吸道感染', '阿莫西林 0.5g tid', '无', '头孢类', '深圳人民医院', '张医生', '2024-03-10'),
                                                                                                                                                                                         ('赵静', '51010719870714789X', 'MR202400004', '颈椎病', '布洛芬缓释胶囊 0.3g bid', '无', '无', '华西医院', '刘医生', '2024-01-05'),
                                                                                                                                                                                         ('陈强', '320105199103156789', 'MR202400005', '胃溃疡', '奥美拉唑 20mg qd', '无', '阿司匹林', '南京鼓楼医院', '陈医生', '2024-02-28'),
                                                                                                                                                                                         ('刘娜', '350203199512019876', 'MR202400006', '过敏性鼻炎', '氯雷他定 10mg qd', '无', '花粉', '厦门大学附属医院', '林医生', '2024-03-15'),
                                                                                                                                                                                         ('周涛', '120101198608128765', 'MR202400007', '冠心病', '阿托伐他汀 20mg qd', '心脏搭桥', '无', '天津泰达医院', '赵医生', '2024-01-20'),
                                                                                                                                                                                         ('吴迪', '430103199311234321', 'MR202400008', '腰椎间盘突出', '塞来昔布 200mg qd', '无', '无', '湘雅医院', '周医生', '2024-02-10'),
                                                                                                                                                                                         ('郑爽', '210203199403211234', 'MR202400009', '甲状腺结节', '无', '甲状腺切除术', '无', '大连医科大学附属医院', '孙医生', '2024-03-05'),
                                                                                                                                                                                         ('林晨', '370202199707153456', 'MR202400010', '抑郁症', '舍曲林 50mg qd', '无', '无', '青岛精神卫生中心', '李医生', '2024-01-25');

-- 3.3 保险保单表（10条）
INSERT INTO insurance_policies (policy_no, insured_name, insured_id_card, beneficiary, insurance_type, coverage_amount, premium, start_date, end_date, policy_status) VALUES
                                                                                                                                                                          ('POL202400001', '张明', '11010119900307663X', '配偶', '重疾险', 500000.00, 5200.00, '2024-01-01', '2044-01-01', '有效'),
                                                                                                                                                                          ('POL202400002', '李芳', '310101198805124567', '子女', '医疗险', 2000000.00, 1800.00, '2024-02-01', '2025-02-01', '有效'),
                                                                                                                                                                          ('POL202400003', '王磊', '440301199210235678', '父母', '意外险', 1000000.00, 1200.00, '2024-03-01', '2025-03-01', '有效'),
                                                                                                                                                                          ('POL202400004', '赵静', '51010719870714789X', '配偶', '寿险', 1000000.00, 6800.00, '2024-01-15', '2044-01-15', '有效'),
                                                                                                                                                                          ('POL202400005', '陈强', '320105199103156789', '子女', '年金险', 300000.00, 10000.00, '2024-02-10', '2044-02-10', '有效'),
                                                                                                                                                                          ('POL202400006', '刘娜', '350203199512019876', '父母', '重疾险', 300000.00, 3200.00, '2024-03-05', '2044-03-05', '有效'),
                                                                                                                                                                          ('POL202400007', '周涛', '120101198608128765', '配偶', '医疗险', 1500000.00, 1500.00, '2024-01-20', '2025-01-20', '有效'),
                                                                                                                                                                          ('POL202400008', '吴迪', '430103199311234321', '子女', '意外险', 500000.00, 800.00, '2024-02-15', '2025-02-15', '有效'),
                                                                                                                                                                          ('POL202400009', '郑爽', '210203199403211234', '父母', '车险', 2000000.00, 4500.00, '2024-03-10', '2025-03-10', '有效'),
                                                                                                                                                                          ('POL202400010', '林晨', '370202199707153456', '配偶', '家财险', 1000000.00, 600.00, '2024-01-25', '2025-01-25', '已到期');

-- 3.4 房产信息表（8条）
INSERT INTO property_info (owner_name, owner_id_card, property_address, property_cert_no, land_cert_no, building_area, purchase_price, mortgage_amount, mortgage_bank) VALUES
                                                                                                                                                                           ('张明', '11010119900307663X', '北京市朝阳区望京xxx小区1号楼101', '京房权证朝字第123456号', '京朝国用(2020)字第001号', 120.50, 8000000.00, 3000000.00, '中国工商银行'),
                                                                                                                                                                           ('李芳', '310101198805124567', '上海市浦东新区陆家嘴xxx大厦2001', '沪房地浦字(2021)第234567号', '沪浦国用(2021)第002号', 150.00, 15000000.00, 6000000.00, '中国建设银行'),
                                                                                                                                                                           ('王磊', '440301199210235678', '深圳市南山区科技园xxx栋B座', '粤(2020)深圳市不动产权第0123456号', NULL, 98.00, 9000000.00, 4000000.00, '招商银行'),
                                                                                                                                                                           ('赵静', '51010719870714789X', '成都市高新区天府xxx街8号', '川(2019)成都市不动产权第3456789号', NULL, 110.00, 3500000.00, 1500000.00, '中国银行'),
                                                                                                                                                                           ('陈强', '320105199103156789', '南京市建邺区河西xxx花园15栋302', '苏(2020)宁建不动产权第4567890号', NULL, 125.00, 4200000.00, 1800000.00, '交通银行'),
                                                                                                                                                                           ('刘娜', '350203199512019876', '厦门市思明区环岛路xxx小区8号', '闽(2021)厦门市不动产权第5678901号', NULL, 105.00, 4800000.00, 2000000.00, '兴业银行'),
                                                                                                                                                                           ('周涛', '120101198608128765', '天津市和平区南京路xxx大厦2505', '津(2020)和平区不动产权第6789012号', NULL, 135.00, 5500000.00, 2500000.00, '浦发银行'),
                                                                                                                                                                           ('吴迪', '430103199311234321', '长沙市岳麓区梅溪湖xxx小区7栋201', '湘(2021)长沙市不动产权第7890123号', NULL, 115.00, 2800000.00, 1000000.00, '中信银行');

-- 3.5 车辆信息表（10条）
INSERT INTO vehicle_info (owner_name, owner_id_card, license_plate, vin, engine_no, brand_model, registration_date, vehicle_color, loan_status) VALUES
                                                                                                                                                    ('张明', '11010119900307663X', '京A12345', 'LSVCD6B23BN123456', 'ENG123456789', '大众帕萨特', '2022-03-15', '黑色', '已还清'),
                                                                                                                                                    ('李芳', '310101198805124567', '沪B67890', 'LBV8E7406LM456789', 'ENG987654321', '宝马X3', '2023-05-20', '白色', '贷款中'),
                                                                                                                                                    ('王磊', '440301199210235678', '粤C23456', 'LVGDC56A0BG789012', 'ENG456789123', '奥迪A6L', '2021-08-10', '灰色', '已还清'),
                                                                                                                                                    ('赵静', '51010719870714789X', '川A34567', 'LDCB31640B345678', 'ENG789123456', '奔驰C级', '2023-01-18', '红色', '贷款中'),
                                                                                                                                                    ('陈强', '320105199103156789', '苏A45678', 'LSGAR5AL5MH901234', 'ENG234567891', '别克GL8', '2022-06-25', '金色', '已还清'),
                                                                                                                                                    ('刘娜', '350203199512019876', '闽D56789', 'LFV3A23C0K3123456', 'ENG345678912', '大众迈腾', '2021-11-11', '白色', '已还清'),
                                                                                                                                                    ('周涛', '120101198608128765', '津C67890', 'WBA8E7200KAT12345', 'ENG456789123', '宝马5系', '2023-07-07', '黑色', '贷款中'),
                                                                                                                                                    ('吴迪', '430103199311234321', '湘A78901', 'LVSHCAAE2FH678901', 'ENG567891234', '福特蒙迪欧', '2022-09-30', '蓝色', '已还清'),
                                                                                                                                                    ('郑爽', '210203199403211234', '辽B89012', 'LHGCV3610K8123456', 'ENG678912345', '本田雅阁', '2023-02-14', '白色', '贷款中'),
                                                                                                                                                    ('林晨', '370202199707153456', '鲁B90123', 'LVGBV80E9MG345678', 'ENG789123456', '丰田凯美瑞', '2022-12-20', '银色', '已还清');

-- 3.6 教育学历信息表（12条）
INSERT INTO education_info (person_name, person_id_card, education_level, institution_name, major, student_no, degree_cert_no, graduation_date, degree_type) VALUES
                                                                                                                                                                 ('张明', '11010119900307663X', '硕士研究生', '清华大学', '计算机科学与技术', '20181123001', '1040012023001234', '2023-06-30', '工学硕士'),
                                                                                                                                                                 ('李芳', '310101198805124567', '本科', '复旦大学', '软件工程', '20160912001', '1024612022005678', '2022-06-25', '工学学士'),
                                                                                                                                                                 ('王磊', '440301199210235678', '博士研究生', '北京大学', '人工智能', '20190901001', '1000112024009012', '2024-01-15', '理学博士'),
                                                                                                                                                                 ('赵静', '51010719870714789X', '本科', '四川大学', '信息安全', '20151020001', '1061012021034567', '2021-07-01', '工学学士'),
                                                                                                                                                                 ('陈强', '320105199103156789', '硕士研究生', '南京大学', '数据科学', '20180905001', '1028412022023456', '2022-06-28', '理学硕士'),
                                                                                                                                                                 ('刘娜', '350203199512019876', '本科', '厦门大学', '会计学', '20160901001', '1038412023045678', '2023-07-01', '管理学学士'),
                                                                                                                                                                 ('周涛', '120101198608128765', '博士研究生', '天津大学', '管理科学与工程', '20180915001', '1005612023067890', '2023-12-20', '管理学博士'),
                                                                                                                                                                 ('吴迪', '430103199311234321', '本科', '中南大学', '计算机科学', '20170908001', '1053312021038901', '2021-06-30', '工学学士'),
                                                                                                                                                                 ('郑爽', '210203199403211234', '硕士研究生', '大连理工大学', '信息管理', '20190912001', '1014112023012345', '2023-06-25', '管理学硕士'),
                                                                                                                                                                 ('林晨', '370202199707153456', '本科', '山东大学', '网络工程', '20160903001', '1042212022045678', '2022-07-01', '工学学士'),
                                                                                                                                                                 ('郭峰', '500101198809194567', '硕士研究生', '重庆大学', '软件工程', '20180910001', '1061112023056789', '2023-06-28', '工学硕士'),
                                                                                                                                                                 ('唐雅', '330105199410285678', '本科', '浙江大学', '数学与应用数学', '20160905001', '1033512021067890', '2021-06-30', '理学学士');

-- 3.7 税务信息表（10条）
INSERT INTO tax_info (taxpayer_name, taxpayer_id, id_card, income_amount, tax_amount, tax_paid, tax_year, employer, tax_bureau) VALUES
                                                                                                                                    ('张明', '11010119900307663X01', '11010119900307663X', 580000.00, 87000.00, 87000.00, 2023, '云创科技股份有限公司', '北京市朝阳区税务局'),
                                                                                                                                    ('李芳', '31010119880512456701', '310101198805124567', 520000.00, 75000.00, 75000.00, 2023, '海纳数据安全有限公司', '上海市浦东新区税务局'),
                                                                                                                                    ('王磊', '44030119921023567801', '440301199210235678', 650000.00, 105000.00, 105000.00, 2023, '智联信息技术集团', '深圳市南山区税务局'),
                                                                                                                                    ('赵静', '51010719870714789X01', '51010719870714789X', 480000.00, 68000.00, 68000.00, 2023, '星辰云计算有限公司', '成都市高新区税务局'),
                                                                                                                                    ('陈强', '32010519910315678901', '320105199103156789', 420000.00, 55000.00, 55000.00, 2023, '安恒信息安全技术', '南京市建邺区税务局'),
                                                                                                                                    ('刘娜', '35020319951201987601', '350203199512019876', 350000.00, 42000.00, 42000.00, 2023, '致远软件科技', '厦门市思明区税务局'),
                                                                                                                                    ('周涛', '12010119860812876501', '120101198608128765', 550000.00, 82000.00, 82000.00, 2023, '磐石区块链科技', '天津市和平区税务局'),
                                                                                                                                    ('吴迪', '43010319931123432101', '430103199311234321', 380000.00, 48000.00, 48000.00, 2023, '天璇人工智能实验室', '长沙市岳麓区税务局'),
                                                                                                                                    ('郑爽', '21020319940321123401', '210203199403211234', 450000.00, 62000.00, 62000.00, 2023, '昆仑金融科技集团', '大连市中山区税务局'),
                                                                                                                                    ('林晨', '37020219970715345601', '370202199707153456', 320000.00, 36000.00, 36000.00, 2023, '华盾网络安全公司', '青岛市市南区税务局');

-- 3.8 社交账号信息表（12条）
INSERT INTO social_accounts (platform_name, user_id, nickname, real_name, phone, email, follower_count, is_verified) VALUES
                                                                                                                         ('微信', 'wxid_zhangming001', '明哥', '张明', '13812345678', 'zhangming@example.com', 520, 1),
                                                                                                                         ('微博', 'weibo_lifang', '芳芳', '李芳', '13987654321', 'lifang@example.com', 12300, 1),
                                                                                                                         ('抖音', 'douyin_wanglei', '雷哥', '王磊', '15812345678', 'wanglei@example.com', 45600, 0),
                                                                                                                         ('小红书', 'xiaohongshu_zhaojing', '静静', '赵静', '17712345678', 'zhaojing@example.com', 8900, 1),
                                                                                                                         ('知乎', 'zhihu_chenqiang', '强哥说技术', '陈强', '18612345678', 'chenqiang@example.com', 23400, 1),
                                                                                                                         ('B站', 'bilibili_liuna', '娜娜', '刘娜', '15987654321', 'liuna@example.com', 34500, 0),
                                                                                                                         ('QQ', '123456789', '涛哥', '周涛', '13512345678', 'zhoutao@example.com', 800, 0),
                                                                                                                         ('领英', 'linkedin_wudi', '吴迪', '吴迪', '15212345678', 'wudi@example.com', 1200, 1),
                                                                                                                         ('Twitter', 'twitter_zhengshuang', 'Shuang', '郑爽', NULL, 'zhengshuang@example.com', 56700, 1),
                                                                                                                         ('Instagram', 'insta_lin', 'Lin Chen', '林晨', NULL, 'linchen@example.com', 34500, 0),
                                                                                                                         ('GitHub', 'github_guofeng', 'guofeng', '郭峰', NULL, 'guofeng@example.com', 890, 0),
                                                                                                                         ('抖音', 'douyin_tangya', '雅雅', '唐雅', '16612345678', 'tangya@example.com', 67800, 1);

-- 3.9 生物特征信息表（8条）
INSERT INTO biometric_info (person_name, person_id_card, fingerprint_hash, face_feature, iris_code, voice_print, signature_hash) VALUES
                                                                                                                                     ('张明', '11010119900307663X', 'fp_hash_3f8d2e1a9b4c7d5e6f2a3b4c5d6e7f8g', 'face_vec_128d_7f8e9d0c1b2a3f4e5d6c7b8a9f0e1d2c', 'iris_7d8e9f0a1b2c3d4e5f6a7b8c9d0e1f2a', 'voice_3c4d5e6f7a8b9c0d1e2f3a4b5c6d7e8', 'sign_hash_a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5'),
                                                                                                                                     ('李芳', '310101198805124567', 'fp_hash_4e9d3f2b0a5c8e7f6g3a4b5c6d7e8f9g', 'face_vec_128d_8e9f0a1b2c3d4e5f6a7b8c9d0e1f2a', 'iris_8e9f0a1b2c3d4e5f6a7b8c9d0e1f2b', 'voice_4d5e6f7a8b9c0d1e2f3a4b5c6d7e8f9', 'sign_hash_b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6'),
                                                                                                                                     ('王磊', '440301199210235678', 'fp_hash_5f0e4g3c1b6d9f8g7h4a5b6c7d8e9f0g', 'face_vec_128d_9f0a1b2c3d4e5f6a7b8c9d0e1f2a3', 'iris_9f0a1b2c3d4e5f6a7b8c9d0e1f2c3', 'voice_5e6f7a8b9c0d1e2f3a4b5c6d7e8f9g0', 'sign_hash_c3d4e5f6g7h8i9j0k1l2m3n4o5p6q7'),
                                                                                                                                     ('赵静', '51010719870714789X', 'fp_hash_6a1f5h4d2c7e0g9h8i5a6b7c8d9e0f1g', 'face_vec_128d_0a1b2c3d4e5f6a7b8c9d0e1f2a3b4', 'iris_0a1b2c3d4e5f6a7b8c9d0e1f2d4e5', 'voice_6f7a8b9c0d1e2f3a4b5c6d7e8f9g0h1', 'sign_hash_d4e5f6g7h8i9j0k1l2m3n4o5p6q7r8'),
                                                                                                                                     ('陈强', '320105199103156789', 'fp_hash_7b2g6i5e3d8f1h0i9j6a7b8c9d0e1f2g', 'face_vec_128d_1b2c3d4e5f6a7b8c9d0e1f2a3b4c5', 'iris_1b2c3d4e5f6a7b8c9d0e1f2e5f6g7', 'voice_7g8a9b0c1d2e3f4a5b6c7d8e9f0g1h2', 'sign_hash_e5f6g7h8i9j0k1l2m3n4o5p6q7r8s9'),
                                                                                                                                     ('刘娜', '350203199512019876', 'fp_hash_8c3h7j6f4e9g2i1j0k7a8b9c0d1e2f3g', 'face_vec_128d_2c3d4e5f6a7b8c9d0e1f2a3b4c5d6', 'iris_2c3d4e5f6a7b8c9d0e1f2f6g7h8i9', 'voice_8h9b0c1d2e3f4a5b6c7d8e9f0g1h2i3', 'sign_hash_f6g7h8i9j0k1l2m3n4o5p6q7r8s9t0'),
                                                                                                                                     ('周涛', '120101198608128765', 'fp_hash_9d4i8k7g5f0h3j2k1l8a9b0c1d2e3f4g', 'face_vec_128d_3d4e5f6a7b8c9d0e1f2a3b4c5d6e7', 'iris_3d4e5f6a7b8c9d0e1f2g7h8i9j0k1', 'voice_9i0c1d2e3f4a5b6c7d8e9f0g1h2i3j4', 'sign_hash_g7h8i9j0k1l2m3n4o5p6q7r8s9t0u1'),
                                                                                                                                     ('吴迪', '430103199311234321', 'fp_hash_0e5j9l8h6g1i4k3l2m9b0c1d2e3f4g5h', 'face_vec_128d_4e5f6a7b8c9d0e1f2a3b4c5d6e7f8', 'iris_4e5f6a7b8c9d0e1f2h8i9j0k1l2m3', 'voice_0j1d2e3f4a5b6c7d8e9f0g1h2i3j4k5', 'sign_hash_h8i9j0k1l2m3n4o5p6q7r8s9t0u1v2');

-- 3.10 支付交易记录表（15条）
INSERT INTO payment_transactions (transaction_no, payer_name, payer_card_no, payee_name, payee_card_no, amount, currency, transaction_time, transaction_type, status) VALUES
                                                                                                                                                                          ('TXN202403150001', '张明', '6212260200123456789', '云创科技', '6217000100123456789', 350000.00, 'CNY', '2024-03-15 10:30:00', '企业支付', '成功'),
                                                                                                                                                                          ('TXN202403150002', '李芳', '6217000100123456789', '海纳数据', '6013823100123456789', 280000.00, 'CNY', '2024-03-15 14:20:00', '企业支付', '成功'),
                                                                                                                                                                          ('TXN202403140003', '王磊', '6214850200123456789', '智联信息', '6222600110123456789', 360000.00, 'CNY', '2024-03-14 09:15:00', '企业支付', '成功'),
                                                                                                                                                                          ('TXN202403140004', '赵静', '6013823100123456789', '星辰云', '6217920100123456789', 220000.00, 'CNY', '2024-03-14 16:45:00', '企业支付', '失败'),
                                                                                                                                                                          ('TXN202403130005', '陈强', '6222600110123456789', '安恒安全', '6229090100123456789', 150000.00, 'CNY', '2024-03-13 11:00:00', '企业支付', '成功'),
                                                                                                                                                                          ('TXN202403120006', '刘娜', '6217920100123456789', '致远软件', '6217680100123456789', 150000.00, 'CNY', '2024-03-12 10:30:00', '企业支付', '成功'),
                                                                                                                                                                          ('TXN202403110007', '周涛', '6229090100123456789', '磐石区块链', '6226220100123456789', 200000.00, 'CNY', '2024-03-11 14:00:00', '企业支付', '成功'),
                                                                                                                                                                          ('TXN202403100008', '吴迪', '6217680100123456789', '天璇AI', '6214620100123456789', 240000.00, 'CNY', '2024-03-10 09:30:00', '企业支付', '处理中'),
                                                                                                                                                                          ('TXN202403090009', '郑爽', '6226220100123456789', '昆仑金融', '6229081234567890', 250000.00, 'CNY', '2024-03-09 16:00:00', '企业支付', '成功'),
                                                                                                                                                                          ('TXN202403080010', '林晨', '6214620100123456789', '华盾安全', '6214920100123456789', 180000.00, 'CNY', '2024-03-08 11:20:00', '企业支付', '成功'),
                                                                                                                                                                          ('TXN202403070011', '郭峰', '6229081234567890', '云创科技', '6212260200123456789', 320000.00, 'CNY', '2024-03-07 13:45:00', '企业支付', '成功'),
                                                                                                                                                                          ('TXN202403060012', '唐雅', '6214920100123456789', '海纳数据', '6217000100123456789', 250000.00, 'CNY', '2024-03-06 10:00:00', '企业支付', '失败'),
                                                                                                                                                                          ('TXN202403050013', '张明', '6212260200123456789', '个人转账', '6214850200123456789', 5000.00, 'CNY', '2024-03-05 19:30:00', '个人转账', '成功'),
                                                                                                                                                                          ('TXN202403040014', '李芳', '6217000100123456789', '个人转账', '6222600110123456789', 3000.00, 'CNY', '2024-03-04 12:15:00', '个人转账', '成功'),
                                                                                                                                                                          ('TXN202403030015', '王磊', '6214850200123456789', '个人转账', '6217920100123456789', 8000.00, 'CNY', '2024-03-03 18:00:00', '个人转账', '成功');

-- =====================================================
-- 四、业务表数据
-- =====================================================

-- 4.1 商品评价表（15条）
INSERT INTO product_reviews (product_id, user_id, rating, review_title, review_content, like_count, is_deleted) VALUES
                                                                                                                    (1, 1, 5, '非常好用的安全平台', '功能强大，界面友好，数据分类分级很准确', 23, 0),
                                                                                                                    (2, 2, 4, '性价比不错', '价格合理，但部分功能还有提升空间', 12, 0),
                                                                                                                    (3, 3, 5, '数据库审计神器', '审计日志非常详细，合规必备', 45, 0),
                                                                                                                    (4, 4, 3, '功能还可以', '基本满足需求，但文档不够详细', 5, 0),
                                                                                                                    (5, 5, 5, '脱敏效果很棒', '数据脱敏很彻底，支持多种格式', 18, 0),
                                                                                                                    (1, 6, 4, '售后支持很好', '遇到问题技术响应很快', 8, 0),
                                                                                                                    (2, 7, 5, '强烈推荐', '用了半年，稳定可靠', 67, 0),
                                                                                                                    (3, 8, 2, '价格偏高', '产品不错但价格偏高', 3, 0),
                                                                                                                    (4, 9, 5, '值得购买', '满足所有合规要求', 14, 0),
                                                                                                                    (5, 10, 4, '整体满意', '操作简单，易上手', 9, 0),
                                                                                                                    (1, 11, 5, '行业标杆', '不愧是行业领先产品', 56, 0),
                                                                                                                    (2, 12, 3, '中规中矩', '没什么亮点，但也没什么缺点', 2, 1),
                                                                                                                    (3, 13, 5, '性价比之王', '功能强大价格实惠', 34, 0),
                                                                                                                    (4, 14, 4, '推荐购买', '值得信赖的品牌', 11, 0),
                                                                                                                    (5, 15, 5, '完美', '完全超出预期', 29, 0);

-- 4.2 购物车表（12条）
INSERT INTO shopping_cart (user_id, product_id, quantity, selected) VALUES
                                                                        (1, 2, 1, 1),
                                                                        (1, 5, 2, 0),
                                                                        (2, 3, 1, 1),
                                                                        (3, 1, 1, 1),
                                                                        (3, 4, 1, 1),
                                                                        (4, 2, 2, 0),
                                                                        (5, 6, 1, 1),
                                                                        (6, 7, 1, 1),
                                                                        (7, 8, 1, 1),
                                                                        (8, 9, 1, 0),
                                                                        (9, 10, 2, 1),
                                                                        (10, 1, 1, 1);

-- 4.3 优惠券表（10条）
INSERT INTO coupons (coupon_code, coupon_name, discount_type, discount_value, min_amount, user_id, status, start_time, end_time, use_time) VALUES
                                                                                                                                               ('CP2024001', '新用户专享券', '百分比', 10.00, 1000.00, 1, 1, '2024-01-01 00:00:00', '2024-12-31 23:59:59', '2024-03-15 10:30:00'),
                                                                                                                                               ('CP2024002', '满减券', '固定金额', 5000.00, 50000.00, 2, 1, '2024-01-01 00:00:00', '2024-12-31 23:59:59', '2024-03-15 14:20:00'),
                                                                                                                                               ('CP2024003', '折扣券', '百分比', 15.00, 20000.00, 3, 0, '2024-01-01 00:00:00', '2024-12-31 23:59:59', NULL),
                                                                                                                                               ('CP2024004', '免单券', '固定金额', 100000.00, 100000.00, 4, 0, '2024-01-01 00:00:00', '2024-06-30 23:59:59', NULL),
                                                                                                                                               ('CP2024005', '9折券', '百分比', 10.00, 5000.00, 5, 1, '2024-01-01 00:00:00', '2024-12-31 23:59:59', '2024-03-10 09:30:00'),
                                                                                                                                               ('CP2024006', '新人专享', '固定金额', 2000.00, 10000.00, 6, 0, '2024-01-01 00:00:00', '2024-06-30 23:59:59', NULL),
                                                                                                                                               ('CP2024007', '周年庆券', '百分比', 20.00, 50000.00, 7, 2, '2023-10-01 00:00:00', '2023-12-31 23:59:59', NULL),
                                                                                                                                               ('CP2024008', 'VIP专享', '固定金额', 10000.00, 100000.00, 8, 0, '2024-01-01 00:00:00', '2024-12-31 23:59:59', NULL),
                                                                                                                                               ('CP2024009', '推荐有礼', '百分比', 5.00, 20000.00, 9, 1, '2024-01-01 00:00:00', '2024-12-31 23:59:59', '2024-03-08 11:20:00'),
                                                                                                                                               ('CP2024010', '员工福利', '固定金额', 50000.00, 200000.00, 10, 0, '2024-01-01 00:00:00', '2024-12-31 23:59:59', NULL);

-- 4.4 用户收藏表（15条）
INSERT INTO user_favorites (user_id, favorite_type, target_id) VALUES
                                                                   (1, 'product', 1),
                                                                   (1, 'product', 3),
                                                                   (2, 'product', 2),
                                                                   (2, 'product', 5),
                                                                   (3, 'product', 1),
                                                                   (3, 'product', 4),
                                                                   (4, 'product', 6),
                                                                   (5, 'product', 7),
                                                                   (6, 'product', 8),
                                                                   (7, 'product', 9),
                                                                   (8, 'product', 10),
                                                                   (9, 'product', 1),
                                                                   (10, 'product', 2),
                                                                   (11, 'product', 3),
                                                                   (12, 'product', 5);

-- 4.5 系统通知表（15条）
INSERT INTO system_notifications (title, content, notification_type, target_user_id, is_read, read_time, send_time) VALUES
                                                                                                                        ('系统升级通知', '平台将于3月20日凌晨2:00-4:00进行升级维护', '系统', 0, 0, NULL, '2024-03-18 10:00:00'),
                                                                                                                        ('新功能上线', '数据分类分级功能已全面升级', '公告', 0, 1, '2024-03-01 09:00:00', '2024-02-28 18:00:00'),
                                                                                                                        ('安全提醒', '请及时更新您的登录密码，确保账号安全', '安全', 0, 0, NULL, '2024-03-15 09:00:00'),
                                                                                                                        ('订单提醒', '您的订单ORD202403200001已支付成功', '活动', 1, 1, '2024-03-20 10:35:00', '2024-03-20 10:30:00'),
                                                                                                                        ('优惠券提醒', '您有一张新用户专享券即将到期', '活动', 2, 1, '2024-03-19 14:00:00', '2024-03-18 09:00:00'),
                                                                                                                        ('系统维护', '数据库将于3月25日凌晨进行维护', '系统', 0, 0, NULL, '2024-03-22 10:00:00'),
                                                                                                                        ('产品更新', '数据脱敏系统V3.0正式发布', '公告', 0, 0, NULL, '2024-03-10 14:00:00'),
                                                                                                                        ('安全培训通知', '本季度数据安全培训将于3月28日举行', '活动', 0, 0, NULL, '2024-03-20 11:00:00'),
                                                                                                                        ('订单状态', '您的订单已发货，请注意查收', '活动', 3, 1, '2024-03-19 16:00:00', '2024-03-19 15:30:00'),
                                                                                                                        ('积分提醒', '您的积分将于本月底过期，请及时使用', '活动', 4, 0, NULL, '2024-03-25 09:00:00'),
                                                                                                                        ('合规通知', '请完成本季度的数据安全合规认证', '系统', 0, 0, NULL, '2024-03-01 10:00:00'),
                                                                                                                        ('节日祝福', '祝您元宵节快乐！', '公告', 0, 1, '2024-02-24 12:00:00', '2024-02-24 08:00:00'),
                                                                                                                        ('密码修改提醒', '您的密码已于3月15日修改', '安全', 5, 1, '2024-03-15 10:00:00', '2024-03-15 09:55:00'),
                                                                                                                        ('试用到期提醒', '您的产品试用版将于3月31日到期', '活动', 6, 0, NULL, '2024-03-25 14:00:00'),
                                                                                                                        ('版本更新', '客户端V2.5.0版本已发布', '公告', 0, 0, NULL, '2024-03-20 16:00:00');

-- =====================================================
-- 五、数据统计验证
-- =====================================================
SELECT '=== 新增表数据统计 ===' AS '';
SELECT 'bank_card_info' AS table_name, COUNT(*) AS row_count FROM bank_card_info
UNION ALL SELECT 'medical_records', COUNT(*) FROM medical_records
UNION ALL SELECT 'insurance_policies', COUNT(*) FROM insurance_policies
UNION ALL SELECT 'property_info', COUNT(*) FROM property_info
UNION ALL SELECT 'vehicle_info', COUNT(*) FROM vehicle_info
UNION ALL SELECT 'education_info', COUNT(*) FROM education_info
UNION ALL SELECT 'tax_info', COUNT(*) FROM tax_info
UNION ALL SELECT 'social_accounts', COUNT(*) FROM social_accounts
UNION ALL SELECT 'biometric_info', COUNT(*) FROM biometric_info
UNION ALL SELECT 'payment_transactions', COUNT(*) FROM payment_transactions
UNION ALL SELECT 'product_reviews', COUNT(*) FROM product_reviews
UNION ALL SELECT 'shopping_cart', COUNT(*) FROM shopping_cart
UNION ALL SELECT 'coupons', COUNT(*) FROM coupons
UNION ALL SELECT 'user_favorites', COUNT(*) FROM user_favorites
UNION ALL SELECT 'system_notifications', COUNT(*) FROM system_notifications;

-- =====================================================
-- 使用数据库
-- =====================================================
USE data_sec_demo;

-- =====================================================
-- 一、新增敏感信息表（11张）
-- =====================================================

-- 1.1 银行卡信息表（有索引）
CREATE TABLE IF NOT EXISTS bank_card_info (
                                              id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键ID',
                                              card_holder_name VARCHAR(50) NOT NULL COMMENT '持卡人姓名',
                                              bank_name VARCHAR(100) COMMENT '开户银行',
                                              bank_branch VARCHAR(200) COMMENT '开户支行',
                                              card_number VARCHAR(30) NOT NULL COMMENT '银行卡号',
                                              card_type VARCHAR(20) COMMENT '卡类型:借记卡/信用卡',
                                              cvv_code VARCHAR(10) COMMENT 'CVV码',
                                              expire_date VARCHAR(10) COMMENT '有效期(MM/YY)',
                                              id_card_no VARCHAR(18) COMMENT '关联身份证号',
                                              phone VARCHAR(11) COMMENT '预留手机号',
                                              created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
                                              INDEX idx_card_number (card_number),
                                              INDEX idx_card_holder (card_holder_name),
                                              INDEX idx_id_card (id_card_no)
) COMMENT '银行卡信息表';

-- 1.2 医疗病历表（有索引）
CREATE TABLE IF NOT EXISTS medical_records (
                                               id BIGINT PRIMARY KEY AUTO_INCREMENT,
                                               patient_name VARCHAR(50) NOT NULL COMMENT '患者姓名',
                                               id_card VARCHAR(18) COMMENT '身份证号',
                                               medical_record_no VARCHAR(50) COMMENT '病历号',
                                               hospital_name VARCHAR(200) COMMENT '医院名称',
                                               diagnosis TEXT COMMENT '诊断结果',
                                               treatment_plan TEXT COMMENT '治疗方案',
                                               prescription TEXT COMMENT '处方信息',
                                               admission_date DATE COMMENT '入院日期',
                                               discharge_date DATE COMMENT '出院日期',
                                               doctor_name VARCHAR(50) COMMENT '主治医生',
                                               created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
                                               INDEX idx_medical_no (medical_record_no),
                                               INDEX idx_patient_name (patient_name),
                                               INDEX idx_id_card (id_card)
) COMMENT '医疗病历表';

-- 1.3 保险保单表（有索引）
CREATE TABLE IF NOT EXISTS insurance_policies (
                                                  id BIGINT PRIMARY KEY AUTO_INCREMENT,
                                                  policy_no VARCHAR(50) NOT NULL COMMENT '保单号',
                                                  insured_name VARCHAR(50) COMMENT '被保险人',
                                                  id_card VARCHAR(18) COMMENT '身份证号',
                                                  insurance_type VARCHAR(50) COMMENT '险种:重疾险/医疗险/寿险',
                                                  premium DECIMAL(12,2) COMMENT '保费',
                                                  insured_amount DECIMAL(15,2) COMMENT '保额',
                                                  policy_date DATE COMMENT '投保日期',
                                                  effective_date DATE COMMENT '生效日期',
                                                  expiry_date DATE COMMENT '到期日期',
                                                  beneficiary VARCHAR(50) COMMENT '受益人',
                                                  agent_name VARCHAR(50) COMMENT '代理人',
                                                  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
                                                  INDEX idx_policy_no (policy_no),
                                                  INDEX idx_id_card (id_card),
                                                  INDEX idx_insured_name (insured_name)
) COMMENT '保险保单表';

-- 1.4 车辆登记信息表（有索引）
CREATE TABLE IF NOT EXISTS vehicle_registration (
                                                    id BIGINT PRIMARY KEY AUTO_INCREMENT,
                                                    plate_number VARCHAR(20) NOT NULL COMMENT '车牌号',
                                                    vin VARCHAR(50) COMMENT '车架号',
                                                    engine_no VARCHAR(50) COMMENT '发动机号',
                                                    owner_name VARCHAR(50) COMMENT '车主姓名',
                                                    owner_id_card VARCHAR(18) COMMENT '车主身份证',
                                                    brand VARCHAR(50) COMMENT '品牌',
                                                    model VARCHAR(100) COMMENT '车型',
                                                    register_date DATE COMMENT '注册日期',
                                                    vehicle_color VARCHAR(20) COMMENT '车身颜色',
                                                    fuel_type VARCHAR(20) COMMENT '燃料类型',
                                                    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
                                                    INDEX idx_plate_number (plate_number),
                                                    INDEX idx_vin (vin),
                                                    INDEX idx_owner_id_card (owner_id_card)
) COMMENT '车辆登记信息表';

-- 1.5 房产登记信息表（有索引）
CREATE TABLE IF NOT EXISTS property_registration (
                                                     id BIGINT PRIMARY KEY AUTO_INCREMENT,
                                                     property_cert_no VARCHAR(50) NOT NULL COMMENT '房产证号',
                                                     owner_name VARCHAR(50) COMMENT '产权人',
                                                     owner_id_card VARCHAR(18) COMMENT '产权人身份证',
                                                     property_address VARCHAR(500) COMMENT '房产地址',
                                                     building_area DECIMAL(12,2) COMMENT '建筑面积',
                                                     land_area DECIMAL(12,2) COMMENT '土地面积',
                                                     property_type VARCHAR(30) COMMENT '房产类型:住宅/商业/工业',
                                                     purchase_price DECIMAL(15,2) COMMENT '购买价格',
                                                     purchase_date DATE COMMENT '购买日期',
                                                     mortgage_status VARCHAR(20) COMMENT '抵押状态',
                                                     bank_name VARCHAR(100) COMMENT '贷款银行',
                                                     created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
                                                     INDEX idx_cert_no (property_cert_no),
                                                     INDEX idx_owner_id_card (owner_id_card),
                                                     INDEX idx_owner_name (owner_name)
) COMMENT '房产登记信息表';

-- 1.6 学历教育信息表（有索引）
CREATE TABLE IF NOT EXISTS education_info (
                                              id BIGINT PRIMARY KEY AUTO_INCREMENT,
                                              full_name VARCHAR(50) NOT NULL COMMENT '姓名',
                                              id_card VARCHAR(18) COMMENT '身份证号',
                                              degree VARCHAR(50) COMMENT '学位:学士/硕士/博士',
                                              major VARCHAR(100) COMMENT '专业',
                                              school_name VARCHAR(200) COMMENT '毕业院校',
                                              graduation_date DATE COMMENT '毕业日期',
                                              degree_cert_no VARCHAR(50) COMMENT '学位证书编号',
                                              diploma_cert_no VARCHAR(50) COMMENT '毕业证书编号',
                                              transcript_hash VARCHAR(255) COMMENT '成绩单哈希值',
                                              created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
                                              INDEX idx_id_card (id_card),
                                              INDEX idx_full_name (full_name),
                                              INDEX idx_cert_no (degree_cert_no)
) COMMENT '学历教育信息表';

-- 1.7 社保公积金信息表（有索引）
CREATE TABLE IF NOT EXISTS social_security_info (
                                                    id BIGINT PRIMARY KEY AUTO_INCREMENT,
                                                    full_name VARCHAR(50) NOT NULL COMMENT '姓名',
                                                    id_card VARCHAR(18) COMMENT '身份证号',
                                                    social_security_no VARCHAR(30) COMMENT '社保号',
                                                    provident_fund_no VARCHAR(30) COMMENT '公积金账号',
                                                    company_name VARCHAR(200) COMMENT '缴纳单位',
                                                    monthly_base DECIMAL(10,2) COMMENT '月缴存基数',
                                                    personal_ratio DECIMAL(5,2) COMMENT '个人比例',
                                                    company_ratio DECIMAL(5,2) COMMENT '单位比例',
                                                    accumulated_amount DECIMAL(15,2) COMMENT '累计金额',
                                                    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
                                                    INDEX idx_id_card (id_card),
                                                    INDEX idx_ss_no (social_security_no),
                                                    INDEX idx_pf_no (provident_fund_no)
) COMMENT '社保公积金信息表';

-- 1.8 网络账号密码表（有索引）
CREATE TABLE IF NOT EXISTS online_accounts (
                                               id BIGINT PRIMARY KEY AUTO_INCREMENT,
                                               platform_name VARCHAR(100) NOT NULL COMMENT '平台名称',
                                               platform_url VARCHAR(500) COMMENT '平台网址',
                                               username VARCHAR(100) NOT NULL COMMENT '用户名',
                                               email VARCHAR(100) COMMENT '绑定邮箱',
                                               phone VARCHAR(11) COMMENT '绑定手机',
                                               password_encrypted VARCHAR(255) COMMENT '加密密码',
                                               password_md5 VARCHAR(32) COMMENT '密码MD5',
                                               security_question VARCHAR(200) COMMENT '安全问题',
                                               security_answer VARCHAR(200) COMMENT '安全答案',
                                               created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
                                               INDEX idx_platform (platform_name),
                                               INDEX idx_username (username),
                                               INDEX idx_email (email)
) COMMENT '网络账号密码表';

-- 1.9 API密钥令牌表（有索引）
CREATE TABLE IF NOT EXISTS api_tokens (
                                          id BIGINT PRIMARY KEY AUTO_INCREMENT,
                                          app_name VARCHAR(100) NOT NULL COMMENT '应用名称',
                                          app_key VARCHAR(100) NOT NULL COMMENT 'AppKey',
                                          app_secret VARCHAR(255) NOT NULL COMMENT 'AppSecret',
                                          access_token VARCHAR(500) COMMENT '访问令牌',
                                          refresh_token VARCHAR(500) COMMENT '刷新令牌',
                                          token_type VARCHAR(20) COMMENT '令牌类型',
                                          expire_time DATETIME COMMENT '过期时间',
                                          scope VARCHAR(200) COMMENT '权限范围',
                                          created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
                                          INDEX idx_app_key (app_key),
                                          INDEX idx_app_name (app_name)
) COMMENT 'API密钥令牌表';

-- 1.10 用户支付记录表（无索引）
CREATE TABLE IF NOT EXISTS payment_records (
                                               id BIGINT PRIMARY KEY AUTO_INCREMENT,
                                               transaction_id VARCHAR(64) NOT NULL COMMENT '交易流水号',
                                               payer_name VARCHAR(50) COMMENT '付款人',
                                               payer_card VARCHAR(30) COMMENT '付款卡号',
                                               payee_name VARCHAR(50) COMMENT '收款人',
                                               payee_account VARCHAR(30) COMMENT '收款账号',
                                               amount DECIMAL(12,2) COMMENT '金额',
                                               currency VARCHAR(10) COMMENT '币种',
                                               payment_time DATETIME COMMENT '支付时间',
                                               payment_channel VARCHAR(30) COMMENT '支付渠道',
                                               status VARCHAR(20) COMMENT '状态',
                                               remark VARCHAR(500) COMMENT '备注'
    -- 故意不建索引
) COMMENT '用户支付记录表';

-- 1.11 生物特征信息表（无索引）
CREATE TABLE IF NOT EXISTS biometric_data (
                                              id BIGINT PRIMARY KEY AUTO_INCREMENT,
                                              person_name VARCHAR(50) NOT NULL COMMENT '姓名',
                                              id_card VARCHAR(18) COMMENT '身份证号',
                                              fingerprint_hash VARCHAR(255) COMMENT '指纹哈希',
                                              face_feature_hash VARCHAR(255) COMMENT '人脸特征哈希',
                                              iris_code_hash VARCHAR(255) COMMENT '虹膜编码哈希',
                                              voiceprint_hash VARCHAR(255) COMMENT '声纹哈希',
                                              signature_hash VARCHAR(255) COMMENT '签名哈希',
                                              created_at DATETIME DEFAULT CURRENT_TIMESTAMP
    -- 故意不建索引
) COMMENT '生物特征信息表';

-- =====================================================
-- 二、新增业务表（4张）
-- =====================================================

-- 2.1 物流信息表（有索引）
CREATE TABLE IF NOT EXISTS logistics_info (
                                              id BIGINT PRIMARY KEY AUTO_INCREMENT,
                                              tracking_no VARCHAR(50) NOT NULL COMMENT '物流单号',
                                              order_no VARCHAR(32) COMMENT '关联订单号',
                                              courier_company VARCHAR(50) COMMENT '快递公司',
                                              sender_name VARCHAR(50) COMMENT '寄件人',
                                              sender_phone VARCHAR(11) COMMENT '寄件人电话',
                                              sender_address VARCHAR(500) COMMENT '寄件地址',
                                              receiver_name VARCHAR(50) COMMENT '收件人',
                                              receiver_phone VARCHAR(11) COMMENT '收件人电话',
                                              receiver_address VARCHAR(500) COMMENT '收件地址',
                                              status VARCHAR(20) COMMENT '物流状态',
                                              created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
                                              INDEX idx_tracking_no (tracking_no),
                                              INDEX idx_order_no (order_no)
) COMMENT '物流信息表';

-- 2.2 商品评价表（有索引）
CREATE TABLE IF NOT EXISTS product_reviews (
                                               id BIGINT PRIMARY KEY AUTO_INCREMENT,
                                               product_id BIGINT NOT NULL COMMENT '商品ID',
                                               user_id BIGINT COMMENT '用户ID',
                                               order_no VARCHAR(32) COMMENT '订单号',
                                               rating TINYINT COMMENT '评分1-5',
                                               review_content TEXT COMMENT '评价内容',
                                               review_images VARCHAR(1000) COMMENT '评价图片',
                                               reply_content TEXT COMMENT '商家回复',
                                               review_time DATETIME COMMENT '评价时间',
                                               reply_time DATETIME COMMENT '回复时间',
                                               created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
                                               INDEX idx_product_id (product_id),
                                               INDEX idx_user_id (user_id),
                                               INDEX idx_order_no (order_no)
) COMMENT '商品评价表';

-- 2.3 购物车记录表（无索引）
CREATE TABLE IF NOT EXISTS shopping_cart (
                                             id BIGINT PRIMARY KEY AUTO_INCREMENT,
                                             user_id BIGINT NOT NULL COMMENT '用户ID',
                                             product_id BIGINT NOT NULL COMMENT '商品ID',
                                             product_name VARCHAR(200) COMMENT '商品名称',
                                             quantity INT COMMENT '数量',
                                             unit_price DECIMAL(10,2) COMMENT '单价',
                                             selected TINYINT DEFAULT 1 COMMENT '是否选中',
                                             added_time DATETIME COMMENT '添加时间'
    -- 故意不建索引
) COMMENT '购物车记录表';

-- 2.4 优惠券领取记录表（无索引）
CREATE TABLE IF NOT EXISTS coupon_records (
                                              id BIGINT PRIMARY KEY AUTO_INCREMENT,
                                              coupon_code VARCHAR(50) NOT NULL COMMENT '优惠券码',
                                              user_id BIGINT COMMENT '用户ID',
                                              coupon_name VARCHAR(200) COMMENT '优惠券名称',
                                              discount_amount DECIMAL(10,2) COMMENT '优惠金额',
                                              min_amount DECIMAL(10,2) COMMENT '满减门槛',
                                              start_time DATETIME COMMENT '生效时间',
                                              end_time DATETIME COMMENT '失效时间',
                                              used_time DATETIME COMMENT '使用时间',
                                              order_no VARCHAR(32) COMMENT '使用订单号',
                                              status VARCHAR(20) COMMENT '状态'
    -- 故意不建索引
) COMMENT '优惠券领取记录表';

-- =====================================================
-- 三、插入模拟数据
-- =====================================================

-- 3.1 银行卡信息表（15条）
INSERT INTO bank_card_info (card_holder_name, bank_name, bank_branch, card_number, card_type, cvv_code, expire_date, id_card_no, phone) VALUES
                                                                                                                                            ('张明', '中国工商银行', '北京朝阳支行', '6212260200123456789', '借记卡', '123', '12/28', '11010119900307663X', '13812345678'),
                                                                                                                                            ('李芳', '中国建设银行', '上海浦东支行', '6217000100123456789', '借记卡', '456', '10/27', '310101198805124567', '13987654321'),
                                                                                                                                            ('王磊', '招商银行', '深圳南山支行', '6214850200123456789', '信用卡', '789', '08/29', '440301199210235678', '15812345678'),
                                                                                                                                            ('赵静', '中国银行', '成都高新支行', '6013823100123456789', '借记卡', '234', '06/26', '51010719870714789X', '17712345678'),
                                                                                                                                            ('陈强', '交通银行', '杭州西湖支行', '6222600110123456789', '信用卡', '567', '04/30', '320105199103156789', '18612345678'),
                                                                                                                                            ('刘娜', '浦发银行', '厦门思明支行', '6217920100123456789', '借记卡', '890', '02/28', '350203199512019876', '15987654321'),
                                                                                                                                            ('周涛', '兴业银行', '天津和平支行', '6229090100123456789', '借记卡', '123', '11/27', '120101198608128765', '13512345678'),
                                                                                                                                            ('吴迪', '中信银行', '长沙岳麓支行', '6217680100123456789', '信用卡', '456', '09/28', '430103199311234321', '15212345678'),
                                                                                                                                            ('郑爽', '民生银行', '大连中山支行', '6226220100123456789', '借记卡', '789', '07/29', '210203199403211234', '18712345678'),
                                                                                                                                            ('林晨', '广发银行', '青岛市南支行', '6214620100123456789', '借记卡', '234', '05/30', '370202199707153456', '18812345678'),
                                                                                                                                            ('郭峰', '平安银行', '重庆渝中支行', '6222980100123456789', '信用卡', '567', '03/31', '500101198809194567', '18912345678'),
                                                                                                                                            ('唐雅', '光大银行', '宁波鄞州支行', '6226620100123456789', '借记卡', '890', '01/28', '330105199410285678', '16612345678'),
                                                                                                                                            ('孙浩', '华夏银行', '郑州金水支行', '6226360100123456789', '借记卡', '111', '10/28', '440304199612316789', '17723456789'),
                                                                                                                                            ('许晴', '北京银行', '南京鼓楼支行', '6210300100123456789', '信用卡', '222', '12/29', '350582199811118901', '18834567890'),
                                                                                                                                            ('韩雪', '上海银行', '武汉武昌支行', '6212830100123456789', '借记卡', '333', '08/30', '410105200001012345', '19945678901');

-- 3.2 医疗病历表（12条）
INSERT INTO medical_records (patient_name, id_card, medical_record_no, hospital_name, diagnosis, treatment_plan, prescription, admission_date, discharge_date, doctor_name) VALUES
                                                                                                                                                                                ('张明', '11010119900307663X', 'MR202400001', '北京协和医院', '高血压2级，高血脂', '降压药+降脂药联合治疗，定期监测血压血脂', '硝苯地平控释片30mg qd，阿托伐他汀20mg qd', '2024-03-10', '2024-03-18', '王建国'),
                                                                                                                                                                                ('李芳', '310101198805124567', 'MR202400002', '上海瑞金医院', '2型糖尿病', '胰岛素治疗，饮食控制，运动疗法', '门冬胰岛素30R早12U晚8U，二甲双胍0.5g tid', '2024-02-15', '2024-02-22', '张丽华'),
                                                                                                                                                                                ('王磊', '440301199210235678', 'MR202400003', '深圳市人民医院', '急性阑尾炎', '腹腔镜阑尾切除术', '头孢曲松钠2g qd，甲硝唑0.5g bid', '2024-03-05', '2024-03-12', '刘志强'),
                                                                                                                                                                                ('赵静', '51010719870714789X', 'MR202400004', '华西医院', '甲状腺结节', '甲状腺细针穿刺活检，定期随访', '左甲状腺素钠片50ug qd', '2024-01-20', '2024-01-25', '陈敏'),
                                                                                                                                                                                ('陈强', '320105199103156789', 'MR202400005', '江苏省人民医院', '腰椎间盘突出', '物理治疗，康复训练，必要时手术', '布洛芬缓释胶囊0.3g bid，甲钴胺0.5mg tid', '2024-02-01', '2024-02-10', '李明'),
                                                                                                                                                                                ('刘娜', '350203199512019876', 'MR202400006', '厦门大学附属第一医院', '支气管哮喘', '吸入激素治疗，避免过敏原', '布地奈德福莫特罗粉吸入剂160/4.5ug bid', '2024-03-15', '2024-03-20', '黄伟'),
                                                                                                                                                                                ('周涛', '120101198608128765', 'MR202400007', '天津医科大学总医院', '冠心病', '药物治疗，支架植入术计划', '阿司匹林100mg qd，氯吡格雷75mg qd，美托洛尔25mg bid', '2024-02-20', '2024-03-01', '孙华'),
                                                                                                                                                                                ('吴迪', '430103199311234321', 'MR202400008', '中南大学湘雅医院', '胃溃疡', '抑酸治疗，根除HP', '奥美拉唑20mg bid，阿莫西林1g bid，克拉霉素0.5g bid', '2024-01-10', '2024-01-18', '周敏'),
                                                                                                                                                                                ('郑爽', '210203199403211234', 'MR202400009', '大连医科大学附属第一医院', '胆囊结石', '腹腔镜胆囊切除术', '头孢呋辛1.5g bid，布洛芬0.3g prn', '2024-03-08', '2024-03-15', '赵强'),
                                                                                                                                                                                ('林晨', '370202199707153456', 'MR202400010', '青岛大学附属医院', '骨质疏松', '补充钙剂和维生素D，药物治疗', '碳酸钙D3片600mg bid，阿仑膦酸钠70mg qw', '2024-02-25', '2024-02-28', '王芳'),
                                                                                                                                                                                ('郭峰', '500101198809194567', 'MR202400011', '重庆医科大学附属第一医院', '慢性肾炎', '控制血压，保护肾功能', '厄贝沙坦150mg qd，金水宝胶囊3粒 tid', '2024-03-12', '2024-03-22', '刘军'),
                                                                                                                                                                                ('唐雅', '330105199410285678', 'MR202400012', '浙江大学医学院附属第一医院', '偏头痛', '预防性治疗，急性期止痛', '普萘洛尔10mg tid，佐米曲普坦2.5mg prn', '2024-02-10', '2024-02-14', '陈红');

-- 3.3 保险保单表（10条）
INSERT INTO insurance_policies (policy_no, insured_name, id_card, insurance_type, premium, insured_amount, policy_date, effective_date, expiry_date, beneficiary, agent_name) VALUES
                                                                                                                                                                                  ('POL202400001', '张明', '11010119900307663X', '重疾险', 5800.00, 500000.00, '2024-01-15', '2024-01-20', '2054-01-19', '李芳', '王销售'),
                                                                                                                                                                                  ('POL202400002', '李芳', '310101198805124567', '医疗险', 3200.00, 2000000.00, '2024-02-10', '2024-02-15', '2025-02-14', '张明', '赵经理'),
                                                                                                                                                                                  ('POL202400003', '王磊', '440301199210235678', '寿险', 4500.00, 1000000.00, '2024-01-20', '2024-01-25', '2064-01-24', '王磊父母', '孙顾问'),
                                                                                                                                                                                  ('POL202400004', '赵静', '51010719870714789X', '意外险', 980.00, 300000.00, '2024-03-01', '2024-03-05', '2025-03-04', '赵静配偶', '李代理'),
                                                                                                                                                                                  ('POL202400005', '陈强', '320105199103156789', '重疾险', 6200.00, 600000.00, '2024-02-05', '2024-02-10', '2054-02-09', '陈强子女', '周销售'),
                                                                                                                                                                                  ('POL202400006', '刘娜', '350203199512019876', '医疗险', 2800.00, 1500000.00, '2024-01-25', '2024-01-30', '2025-01-29', '刘娜父母', '吴经理'),
                                                                                                                                                                                  ('POL202400007', '周涛', '120101198608128765', '年金险', 12000.00, 300000.00, '2024-03-10', '2024-03-15', '2044-03-14', '周涛配偶', '郑顾问'),
                                                                                                                                                                                  ('POL202400008', '吴迪', '430103199311234321', '重疾险', 5400.00, 450000.00, '2024-02-20', '2024-02-25', '2054-02-24', '吴迪父母', '林代理'),
                                                                                                                                                                                  ('POL202400009', '郑爽', '210203199403211234', '医疗险', 3500.00, 1800000.00, '2024-01-18', '2024-01-23', '2025-01-22', '郑爽配偶', '郭销售'),
                                                                                                                                                                                  ('POL202400010', '林晨', '370202199707153456', '寿险', 3800.00, 800000.00, '2024-03-05', '2024-03-10', '2064-03-09', '林晨子女', '唐经理');

-- 3.4 车辆登记信息表（12条）
INSERT INTO vehicle_registration (plate_number, vin, engine_no, owner_name, owner_id_card, brand, model, register_date, vehicle_color, fuel_type) VALUES
                                                                                                                                                      ('京A12345', 'LVSHFFAL8LF123456', 'ENG123456789', '张明', '11010119900307663X', '福特', '福克斯', '2023-05-20', '白色', '汽油'),
                                                                                                                                                      ('沪B67890', 'LSVCD6B46LN123456', 'ENG234567890', '李芳', '310101198805124567', '大众', '帕萨特', '2023-08-15', '黑色', '汽油'),
                                                                                                                                                      ('粤C12345', 'LGBF5DE07LR123456', 'ENG345678901', '王磊', '440301199210235678', '日产', '天籁', '2023-11-10', '银色', '汽油'),
                                                                                                                                                      ('川A67890', 'LDC6714DXM1234567', 'ENG456789012', '赵静', '51010719870714789X', '标致', '408', '2024-01-05', '红色', '汽油'),
                                                                                                                                                      ('苏E12345', 'LFV3A23K9L3123456', 'ENG567890123', '陈强', '320105199103156789', '奥迪', 'A4L', '2023-09-25', '黑色', '汽油'),
                                                                                                                                                      ('闽D67890', 'LSGAR5AL0LH123456', 'ENG678901234', '刘娜', '350203199512019876', '别克', '君威', '2023-12-18', '白色', '汽油'),
                                                                                                                                                      ('津C12345', 'LBV8W3103LM123456', 'ENG789012345', '周涛', '120101198608128765', '宝马', '3系', '2024-02-14', '蓝色', '汽油'),
                                                                                                                                                      ('湘A67890', 'LE4ZG4JB8LL123456', 'ENG890123456', '吴迪', '430103199311234321', '奔驰', 'C级', '2023-10-30', '黑色', '汽油'),
                                                                                                                                                      ('辽B12345', 'LVGDC46A3LG123456', 'ENG901234567', '郑爽', '210203199403211234', '丰田', '凯美瑞', '2023-07-12', '银色', '汽油'),
                                                                                                                                                      ('鲁B67890', 'LHGCP1687L8123456', 'ENG012345678', '林晨', '370202199707153456', '本田', '雅阁', '2024-03-08', '白色', '汽油'),
                                                                                                                                                      ('渝A12345', 'LVCB3NWB8LJ123456', 'ENG123456780', '郭峰', '500101198809194567', '比亚迪', '汉', '2023-11-20', '灰色', '电动'),
                                                                                                                                                      ('浙B67890', 'L6T7854Z9LD123456', 'ENG234567891', '唐雅', '330105199410285678', '特斯拉', 'Model 3', '2024-01-28', '红色', '电动');

-- 3.5 房产登记信息表（10条）
INSERT INTO property_registration (property_cert_no, owner_name, owner_id_card, property_address, building_area, land_area, property_type, purchase_price, purchase_date, mortgage_status, bank_name) VALUES
                                                                                                                                                                                                          ('京房权证朝字第123456号', '张明', '11010119900307663X', '北京市朝阳区望京街道xxx小区1号楼101室', 128.50, 15.20, '住宅', 8500000.00, '2020-05-15', '已抵押', '中国工商银行'),
                                                                                                                                                                                                          ('沪房地浦字第654321号', '李芳', '310101198805124567', '上海市浦东新区陆家嘴街道xxx小区2号楼202室', 142.30, 18.50, '住宅', 12000000.00, '2021-03-20', '无抵押', NULL),
                                                                                                                                                                                                          ('粤房地证字第789012号', '王磊', '440301199210235678', '深圳市南山区科技园xxx大厦1801室', 110.80, 12.00, '住宅', 6800000.00, '2022-08-10', '已抵押', '招商银行'),
                                                                                                                                                                                                          ('成房权证字第345678号', '赵静', '51010719870714789X', '成都市高新区天府大道xxx小区3单元301室', 95.60, 10.50, '住宅', 3200000.00, '2021-11-05', '无抵押', NULL),
                                                                                                                                                                                                          ('杭房权证字第901234号', '陈强', '320105199103156789', '杭州市西湖区文一路xxx小区4幢402室', 118.20, 13.80, '住宅', 4500000.00, '2022-03-18', '已抵押', '交通银行'),
                                                                                                                                                                                                          ('厦房证字第567890号', '刘娜', '350203199512019876', '厦门市思明区环岛路xxx小区5号楼503室', 135.00, 16.50, '住宅', 5800000.00, '2023-01-22', '无抵押', NULL),
                                                                                                                                                                                                          ('津房权字第123890号', '周涛', '120101198608128765', '天津市和平区南京路xxx小区6门601室', 98.40, 11.20, '住宅', 2800000.00, '2022-06-30', '已抵押', '建设银行'),
                                                                                                                                                                                                          ('长房证字第456712号', '吴迪', '430103199311234321', '长沙市岳麓区麓谷大道xxx小区7栋702室', 105.70, 12.60, '住宅', 2200000.00, '2023-04-15', '无抵押', NULL),
                                                                                                                                                                                                          ('大房权字第789034号', '郑爽', '210203199403211234', '大连市中山区人民路xxx小区8号801室', 125.30, 14.80, '住宅', 3500000.00, '2021-09-28', '已抵押', '民生银行'),
                                                                                                                                                                                                          ('青房证字第567123号', '林晨', '370202199707153456', '青岛市市南区香港中路xxx小区9号楼902室', 132.60, 15.50, '住宅', 4200000.00, '2022-12-12', '无抵押', NULL);

-- 3.6 学历教育信息表（15条）
INSERT INTO education_info (full_name, id_card, degree, major, school_name, graduation_date, degree_cert_no, diploma_cert_no) VALUES
                                                                                                                                  ('张明', '11010119900307663X', '硕士', '计算机科学与技术', '清华大学', '2015-07-01', 'DC2015001234', 'DP2015001234'),
                                                                                                                                  ('李芳', '310101198805124567', '博士', '软件工程', '北京大学', '2016-07-01', 'DC2016005678', 'DP2016005678'),
                                                                                                                                  ('王磊', '440301199210235678', '本科', '信息安全', '复旦大学', '2014-07-01', 'DC2014009012', 'DP2014009012'),
                                                                                                                                  ('赵静', '51010719870714789X', '硕士', '数据科学', '上海交通大学', '2012-07-01', 'DC2012003456', 'DP2012003456'),
                                                                                                                                  ('陈强', '320105199103156789', '本科', '网络工程', '浙江大学', '2013-07-01', 'DC2013007890', 'DP2013007890'),
                                                                                                                                  ('刘娜', '350203199512019876', '本科', '计算机应用', '南京大学', '2017-07-01', 'DC2017002345', 'DP2017002345'),
                                                                                                                                  ('周涛', '120101198608128765', '硕士', '人工智能', '中国科学技术大学', '2011-07-01', 'DC2011006789', 'DP2011006789'),
                                                                                                                                  ('吴迪', '430103199311234321', '本科', '软件工程', '华中科技大学', '2015-07-01', 'DC2015000123', 'DP2015000123'),
                                                                                                                                  ('郑爽', '210203199403211234', '博士', '密码学', '武汉大学', '2019-07-01', 'DC2019004567', 'DP2019004567'),
                                                                                                                                  ('林晨', '370202199707153456', '本科', '数据科学与大数据技术', '西安交通大学', '2019-07-01', 'DC2019008901', 'DP2019008901'),
                                                                                                                                  ('郭峰', '500101198809194567', '硕士', '网络空间安全', '哈尔滨工业大学', '2014-07-01', 'DC2014002345', 'DP2014002345'),
                                                                                                                                  ('唐雅', '330105199410285678', '本科', '信息管理与信息系统', '南开大学', '2016-07-01', 'DC2016006789', 'DP2016006789'),
                                                                                                                                  ('孙浩', '440304199612316789', '本科', '计算机科学与技术', '中山大学', '2018-07-01', 'DC2018000123', 'DP2018000123'),
                                                                                                                                  ('许晴', '350582199811118901', '硕士', '软件工程', '厦门大学', '2021-07-01', 'DC2021004567', 'DP2021004567'),
                                                                                                                                  ('韩雪', '410105200001012345', '本科', '信息安全', '四川大学', '2022-07-01', 'DC2022008901', 'DP2022008901');

-- 3.7 社保公积金信息表（12条）
INSERT INTO social_security_info (full_name, id_card, social_security_no, provident_fund_no, company_name, monthly_base, personal_ratio, company_ratio, accumulated_amount) VALUES
                                                                                                                                                                                ('张明', '11010119900307663X', 'SSN110101001', 'PF110101001', '云创科技股份有限公司', 25000.00, 8.00, 12.00, 120000.00),
                                                                                                                                                                                ('李芳', '310101198805124567', 'SSN310101002', 'PF310101002', '海纳数据安全有限公司', 22000.00, 8.00, 12.00, 98000.00),
                                                                                                                                                                                ('王磊', '440301199210235678', 'SSN440301003', 'PF440301003', '智联信息技术集团', 20000.00, 8.00, 12.00, 85000.00),
                                                                                                                                                                                ('赵静', '51010719870714789X', 'SSN510107004', 'PF510107004', '星辰云计算有限公司', 18000.00, 8.00, 12.00, 72000.00),
                                                                                                                                                                                ('陈强', '320105199103156789', 'SSN320105005', 'PF320105005', '安恒信息安全技术', 16000.00, 8.00, 12.00, 65000.00),
                                                                                                                                                                                ('刘娜', '350203199512019876', 'SSN350203006', 'PF350203006', '致远软件科技', 15000.00, 8.00, 12.00, 55000.00),
                                                                                                                                                                                ('周涛', '120101198608128765', 'SSN120101007', 'PF120101007', '磐石区块链科技', 28000.00, 8.00, 12.00, 150000.00),
                                                                                                                                                                                ('吴迪', '430103199311234321', 'SSN430103008', 'PF430103008', '天璇人工智能实验室', 19000.00, 8.00, 12.00, 78000.00),
                                                                                                                                                                                ('郑爽', '210203199403211234', 'SSN210203009', 'PF210203009', '昆仑金融科技集团', 26000.00, 8.00, 12.00, 135000.00),
                                                                                                                                                                                ('林晨', '370202199707153456', 'SSN370202010', 'PF370202010', '华盾网络安全公司', 17000.00, 8.00, 12.00, 68000.00),
                                                                                                                                                                                ('郭峰', '500101198809194567', 'SSN500101011', 'PF500101011', '云创科技股份有限公司', 23000.00, 8.00, 12.00, 110000.00),
                                                                                                                                                                                ('唐雅', '330105199410285678', 'SSN330105012', 'PF330105012', '海纳数据安全有限公司', 14000.00, 8.00, 12.00, 48000.00);

-- 3.8 网络账号密码表（20条）
INSERT INTO online_accounts (platform_name, platform_url, username, email, phone, password_encrypted, password_md5, security_question, security_answer) VALUES
                                                                                                                                                            ('淘宝', 'https://taobao.com', 'zhangming2024', 'zhangming@163.com', '13812345678', 'encrypt_pwd_001_abc', 'e10adc3949ba59abbe56e057f20f883e', '你的小学名称', '朝阳一小'),
                                                                                                                                                            ('京东', 'https://jd.com', 'liming_888', 'liming@qq.com', '13987654321', 'encrypt_pwd_002_def', 'e10adc3949ba59abbe56e057f20f883e', '你的宠物名字', '旺财'),
                                                                                                                                                            ('微信', 'https://weixin.qq.com', 'wanglai_001', 'wanglei@gmail.com', '15812345678', 'encrypt_pwd_003_ghi', 'e10adc3949ba59abbe56e057f20f883e', '你的生日', '19921023'),
                                                                                                                                                            ('微博', 'https://weibo.com', 'zhaojing_2024', 'zhaojing@126.com', '17712345678', 'encrypt_pwd_004_jkl', 'e10adc3949ba59abbe56e057f20f883e', '你的父亲名字', '赵国强'),
                                                                                                                                                            ('支付宝', 'https://alipay.com', 'chenqiang_88', 'chenqiang@163.com', '18612345678', 'encrypt_pwd_005_mno', 'e10adc3949ba59abbe56e057f20f883e', '你的毕业学校', '南京大学'),
                                                                                                                                                            ('QQ', 'https://qq.com', '1234567890', 'liuna@qq.com', '15987654321', 'encrypt_pwd_006_pqr', 'e10adc3949ba59abbe56e057f20f883e', '你的母亲名字', '王秀英'),
                                                                                                                                                            ('抖音', 'https://douyin.com', 'zhoutao_001', 'zhoutao@163.com', '13512345678', 'encrypt_pwd_007_stu', 'e10adc3949ba59abbe56e057f20f883e', '你的第一辆车', '大众'),
                                                                                                                                                            ('GitHub', 'https://github.com', 'wudi_dev', 'wudi@gmail.com', '15212345678', 'encrypt_pwd_008_vwx', 'e10adc3949ba59abbe56e057f20f883e', '你的家乡', '长沙'),
                                                                                                                                                            ('腾讯云', 'https://cloud.tencent.com', 'zhengshuang', 'zhengshuang@qq.com', '18712345678', 'encrypt_pwd_009_yz', 'e10adc3949ba59abbe56e057f20f883e', '你的偶像', '周杰伦'),
                                                                                                                                                            ('阿里云', 'https://aliyun.com', 'linchen_2024', 'linchen@163.com', '18812345678', 'encrypt_pwd_010_ab', 'e10adc3949ba59abbe56e057f20f883e', '你的大学', '青岛大学'),
                                                                                                                                                            ('百度网盘', 'https://pan.baidu.com', 'guofeng_001', 'guofeng@126.com', '18912345678', 'encrypt_pwd_011_cd', 'e10adc3949ba59abbe56e057f20f883e', '你的宠物', '猫咪'),
                                                                                                                                                            ('网易邮箱', 'https://mail.163.com', 'tangya_88', 'tangya@163.com', '16612345678', 'encrypt_pwd_012_ef', 'e10adc3949ba59abbe56e057f20f883e', '你的小学班主任', '刘老师'),
                                                                                                                                                            ('B站', 'https://bilibili.com', 'sunhao_2024', 'sunhao@gmail.com', '17723456789', 'encrypt_pwd_013_gh', 'e10adc3949ba59abbe56e057f20f883e', '你的初恋', '王丽'),
                                                                                                                                                            ('拼多多', 'https://pinduoduo.com', 'xuqing_001', 'xuqing@qq.com', '18834567890', 'encrypt_pwd_014_ij', 'e10adc3949ba59abbe56e057f20f883e', '你的手机品牌', '华为'),
                                                                                                                                                            ('美团', 'https://meituan.com', 'hanxue_88', 'hanxue@163.com', '19945678901', 'encrypt_pwd_015_kl', 'e10adc3949ba59abbe56e057f20f883e', '你的星座', '摩羯座'),
                                                                                                                                                            ('携程', 'https://ctrip.com', 'zhangming_2025', 'zhangming@aliyun.com', '13812345678', 'encrypt_pwd_016_mn', 'e10adc3949ba59abbe56e057f20f883e', '你的第一次旅行', '北京'),
                                                                                                                                                            ('滴滴', 'https://didiglobal.com', 'lifang_2024', 'lifang@didiglobal.com', '13987654321', 'encrypt_pwd_017_op', 'e10adc3949ba59abbe56e057f20f883e', '你的车牌号', '京A12345'),
                                                                                                                                                            ('顺丰速运', 'https://sf-express.com', 'wanglei_sf', 'wanglei@sf.com', '15812345678', 'encrypt_pwd_018_qr', 'e10adc3949ba59abbe56e057f20f883e', '你的常用地址', '深圳南山'),
                                                                                                                                                            ('中国移动', 'https://10086.cn', 'zhaojing_mobile', 'zhaojing@139.com', '17712345678', 'encrypt_pwd_019_st', 'e10adc3949ba59abbe56e057f20f883e', '你的服务密码', '123456'),
                                                                                                                                                            ('招商银行', 'https://cmbchina.com', 'chenqiang_cmb', 'chenqiang@cmb.com', '18612345678', 'encrypt_pwd_020_uv', 'e10adc3949ba59abbe56e057f20f883e', '你的查询密码', '888888');

-- 3.9 API密钥令牌表（10条）
INSERT INTO api_tokens (app_name, app_key, app_secret, access_token, refresh_token, token_type, expire_time, scope) VALUES
                                                                                                                        ('数据安全平台', 'AK_DS_PLATFORM_001', 'SK_DS_PLATFORM_001_a3f5g7h9', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c', 'refresh_token_001_xyz123', 'Bearer', '2025-12-31 23:59:59', 'read:data write:data'),
                                                                                                                        ('风险评估系统', 'AK_RISK_002', 'SK_RISK_002_b4g6h8i0', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c', 'refresh_token_002_abc456', 'Bearer', '2025-10-31 23:59:59', 'read:reports write:reports'),
                                                                                                                        ('分类分级引擎', 'AK_CLASSIFY_003', 'SK_CLASSIFY_003_c5h7i9j1', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c', 'refresh_token_003_def789', 'Bearer', '2025-09-30 23:59:59', 'read:classify write:classify'),
                                                                                                                        ('审计监控平台', 'AK_AUDIT_004', 'SK_AUDIT_004_d6i8j0k2', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c', 'refresh_token_004_ghi012', 'Bearer', '2025-08-31 23:59:59', 'read:audit write:audit'),
                                                                                                                        ('脱敏服务平台', 'AK_MASK_005', 'SK_MASK_005_e7j9k1l3', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c', 'refresh_token_005_jkl345', 'Bearer', '2025-07-31 23:59:59', 'read:mask write:mask'),
                                                                                                                        ('安全评估系统', 'AK_ASSESS_006', 'SK_ASSESS_006_f8k0l2m4', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c', 'refresh_token_006_mno678', 'Bearer', '2025-06-30 23:59:59', 'read:assess write:assess'),
                                                                                                                        ('数据备份系统', 'AK_BACKUP_007', 'SK_BACKUP_007_g9l1m3n5', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c', 'refresh_token_007_pqr901', 'Bearer', '2025-05-31 23:59:59', 'read:backup write:backup'),
                                                                                                                        ('合规检查平台', 'AK_COMPLY_008', 'SK_COMPLY_008_h0m2n4o6', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c', 'refresh_token_008_stu234', 'Bearer', '2025-04-30 23:59:59', 'read:comply write:comply'),
                                                                                                                        ('应急响应系统', 'AK_RESPONSE_009', 'SK_RESPONSE_009_i1n3o5p7', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c', 'refresh_token_009_vwx567', 'Bearer', '2025-03-31 23:59:59', 'read:response write:response'),
                                                                                                                        ('数据治理平台', 'AK_GOVERN_010', 'SK_GOVERN_010_j2o4p6q8', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c', 'refresh_token_010_yz890', 'Bearer', '2025-02-28 23:59:59', 'read:govern write:govern');

-- 3.10 用户支付记录表（15条）
INSERT INTO payment_records (transaction_id, payer_name, payer_card, payee_name, payee_account, amount, currency, payment_time, payment_channel, status, remark) VALUES
                                                                                                                                                                     ('TXN202503200001', '张明', '6212260200123456789', '京东商城', '110010011001', 2999.00, 'CNY', '2025-03-20 10:30:00', '支付宝', '成功', '购买手机'),
                                                                                                                                                                     ('TXN202503200002', '李芳', '6217000100123456789', '天猫超市', '110010011002', 568.00, 'CNY', '2025-03-20 14:15:00', '微信支付', '成功', '生活用品'),
                                                                                                                                                                     ('TXN202503190003', '王磊', '6214850200123456789', '美团外卖', '110010011003', 89.50, 'CNY', '2025-03-19 12:00:00', '微信支付', '成功', '午餐'),
                                                                                                                                                                     ('TXN202503190004', '赵静', '6013823100123456789', '滴滴出行', '110010011004', 45.00, 'CNY', '2025-03-19 08:30:00', '支付宝', '成功', '打车费'),
                                                                                                                                                                     ('TXN202503180005', '陈强', '6222600110123456789', '携程旅行', '110010011005', 2380.00, 'CNY', '2025-03-18 20:00:00', '信用卡', '成功', '机票预订'),
                                                                                                                                                                     ('TXN202503180006', '刘娜', '6217920100123456789', '饿了么', '110010011006', 67.80, 'CNY', '2025-03-18 18:30:00', '微信支付', '成功', '晚餐'),
                                                                                                                                                                     ('TXN202503170007', '周涛', '6229090100123456789', '腾讯视频', '110010011007', 30.00, 'CNY', '2025-03-17 15:00:00', '支付宝', '成功', '会员续费'),
                                                                                                                                                                     ('TXN202503170008', '吴迪', '6217680100123456789', '百度网盘', '110010011008', 298.00, 'CNY', '2025-03-17 10:30:00', '微信支付', '成功', '会员购买'),
                                                                                                                                                                     ('TXN202503160009', '郑爽', '6226220100123456789', '网易云音乐', '110010011009', 158.00, 'CNY', '2025-03-16 19:00:00', '支付宝', '失败', '余额不足'),
                                                                                                                                                                     ('TXN202503160010', '林晨', '6214620100123456789', 'B站大会员', '110010011010', 168.00, 'CNY', '2025-03-16 14:30:00', '微信支付', '成功', '年度会员'),
                                                                                                                                                                     ('TXN202503150011', '郭峰', '6222980100123456789', '拼多多', '110010011011', 199.00, 'CNY', '2025-03-15 11:20:00', '支付宝', '成功', '日用品'),
                                                                                                                                                                     ('TXN202503150012', '唐雅', '6226620100123456789', '顺丰速运', '110010011012', 35.00, 'CNY', '2025-03-15 09:00:00', '微信支付', '成功', '快递费'),
                                                                                                                                                                     ('TXN202503140013', '孙浩', '6226360100123456789', '麦当劳', '110010011013', 127.50, 'CNY', '2025-03-14 12:30:00', '支付宝', '成功', '午餐'),
                                                                                                                                                                     ('TXN202503140014', '许晴', '6210300100123456789', '星巴克', '110010011014', 78.00, 'CNY', '2025-03-14 10:00:00', '微信支付', '成功', '咖啡'),
                                                                                                                                                                     ('TXN202503130015', '韩雪', '6212830100123456789', '盒马鲜生', '110010011015', 456.00, 'CNY', '2025-03-13 17:30:00', '支付宝', '处理中', '生鲜采购');

-- 3.11 生物特征信息表（10条）
INSERT INTO biometric_data (person_name, id_card, fingerprint_hash, face_feature_hash, iris_code_hash, voiceprint_hash, signature_hash) VALUES
                                                                                                                                            ('张明', '11010119900307663X', 'fp_hash_001_a3f5g7h9j1k3l5', 'face_hash_001_b4g6h8i0k2m4', 'iris_hash_001_c5h7i9j1k3m5n7', 'voice_hash_001_d6i8j0k2m4n6o8', 'sign_hash_001_e7j9k1l3m5o7p9'),
                                                                                                                                            ('李芳', '310101198805124567', 'fp_hash_002_f8k0l2m4n6o8p0', 'face_hash_002_g9l1m3n5o7p9q1', 'iris_hash_002_h0m2n4o6p8q0r2', 'voice_hash_002_i1n3o5p7q9r1s3', 'sign_hash_002_j2o4p6q8r0s2t4'),
                                                                                                                                            ('王磊', '440301199210235678', 'fp_hash_003_k3p5r7t9v1x3z5', 'face_hash_003_l4q6s8u0w2y4a6', 'iris_hash_003_m5r7t9v1x3z5b7', 'voice_hash_003_n6s8u0w2y4a6c8', 'sign_hash_003_o7t9v1x3z5b7d9'),
                                                                                                                                            ('赵静', '51010719870714789X', 'fp_hash_004_p8r0t2v4x6z8', 'face_hash_004_q9s1u3w5y7a9', 'iris_hash_004_r0t2v4x6z8b0', 'voice_hash_004_s1u3w5y7a9c1', 'sign_hash_004_t2v4x6z8b0d2'),
                                                                                                                                            ('陈强', '320105199103156789', 'fp_hash_005_u5w7y9a1c3e5', 'face_hash_005_v6x8z0b2d4f6', 'iris_hash_005_w7y9a1c3e5g7', 'voice_hash_005_x8z0b2d4f6h8', 'sign_hash_005_y9a1c3e5g7i9'),
                                                                                                                                            ('刘娜', '350203199512019876', 'fp_hash_006_z0b2d4f6h8j0', 'face_hash_006_a1c3e5g7i9k1', 'iris_hash_006_b2d4f6h8j0l2', 'voice_hash_006_c3e5g7i9k1m3', 'sign_hash_006_d4f6h8j0l2n4'),
                                                                                                                                            ('周涛', '120101198608128765', 'fp_hash_007_e6g8i0k2m4o6', 'face_hash_007_f7h9j1l3n5p7', 'iris_hash_007_g8i0k2m4o6q8', 'voice_hash_007_h9j1l3n5p7r9', 'sign_hash_007_i0k2m4o6q8s0'),
                                                                                                                                            ('吴迪', '430103199311234321', 'fp_hash_008_j1l3n5p7r9t1', 'face_hash_008_k2m4o6q8s0u2', 'iris_hash_008_l3n5p7r9t1v3', 'voice_hash_008_m4o6q8s0u2w4', 'sign_hash_008_n5p7r9t1v3x5'),
                                                                                                                                            ('郑爽', '210203199403211234', 'fp_hash_009_o6q8s0u2w4y6', 'face_hash_009_p7r9t1v3x5z7', 'iris_hash_009_q8s0u2w4y6a8', 'voice_hash_009_r9t1v3x5z7b9', 'sign_hash_009_s0u2w4y6a8c0'),
                                                                                                                                            ('林晨', '370202199707153456', 'fp_hash_010_t1v3x5z7b9d1', 'face_hash_010_u2w4y6a8c0e2', 'iris_hash_010_v3x5z7b9d1f3', 'voice_hash_010_w4y6a8c0e2g4', 'sign_hash_010_x5z7b9d1f3h5');

-- =====================================================
-- 四、业务表数据
-- =====================================================

-- 4.1 物流信息表（15条）
INSERT INTO logistics_info (tracking_no, order_no, courier_company, sender_name, sender_phone, sender_address, receiver_name, receiver_phone, receiver_address, status) VALUES
                                                                                                                                                                            ('SF1234567890', 'ORD202503200001', '顺丰速运', '云创科技', '010-12345678', '北京市朝阳区xxx科技园', '张明', '13812345678', '北京市朝阳区望京街道xxx小区', '已签收'),
                                                                                                                                                                            ('YT1234567891', 'ORD202503200002', '圆通速递', '海纳数据', '021-87654321', '上海市浦东新区xxx软件园', '李芳', '13987654321', '上海市浦东新区xxx路2号', '运输中'),
                                                                                                                                                                            ('ZTO1234567892', 'ORD202503190003', '中通快递', '智联信息', '0755-23456789', '深圳市南山区xxx科技大厦', '王磊', '15812345678', '深圳市南山区xxx路3号', '已揽收'),
                                                                                                                                                                            ('EMS1234567893', 'ORD202503190004', '中国邮政', '星辰云', '028-34567890', '成都市高新区xxx产业园', '赵静', '17712345678', '成都市高新区xxx路4号', '派送中'),
                                                                                                                                                                            ('JD1234567894', 'ORD202503180005', '京东物流', '安恒安全', '0571-45678901', '杭州市西湖区xxx大厦', '陈强', '18612345678', '杭州市西湖区xxx路5号', '已签收'),
                                                                                                                                                                            ('SF1234567895', 'ORD202503180006', '顺丰速运', '致远软件', '0592-56789012', '厦门市思明区xxx软件园', '刘娜', '15987654321', '厦门市思明区xxx路6号', '已发货'),
                                                                                                                                                                            ('YTO1234567896', 'ORD202503170007', '韵达快递', '磐石区块链', '022-67890123', '天津市和平区xxx大厦', '周涛', '13512345678', '天津市和平区xxx路7号', '运输中'),
                                                                                                                                                                            ('STO1234567897', 'ORD202503170008', '申通快递', '天璇AI', '0731-78901234', '长沙市岳麓区xxx科技园', '吴迪', '15212345678', '长沙市岳麓区xxx路8号', '已揽收'),
                                                                                                                                                                            ('SF1234567898', 'ORD202503160009', '顺丰速运', '昆仑金融', '0411-89012345', '大连市中山区xxx金融中心', '郑爽', '18712345678', '大连市中山区xxx路9号', '已签收'),
                                                                                                                                                                            ('ZTO1234567899', 'ORD202503160010', '中通快递', '华盾安全', '0532-90123456', '青岛市市南区xxx大厦', '林晨', '18812345678', '青岛市市南区xxx路10号', '派送中'),
                                                                                                                                                                            ('EMS1234567900', 'ORD202503150011', '中国邮政', '云创科技', '010-12345678', '北京市朝阳区xxx科技园', '郭峰', '18912345678', '重庆市渝中区xxx路11号', '运输中'),
                                                                                                                                                                            ('YTO1234567901', 'ORD202503150012', '韵达快递', '海纳数据', '021-87654321', '上海市浦东新区xxx软件园', '唐雅', '16612345678', '宁波市鄞州区xxx路12号', '已发货'),
                                                                                                                                                                            ('STO1234567902', 'ORD202503140013', '申通快递', '智联信息', '0755-23456789', '深圳市南山区xxx科技大厦', '孙浩', '17723456789', '南京市鼓楼区xxx路13号', '已揽收'),
                                                                                                                                                                            ('JD1234567903', 'ORD202503140014', '京东物流', '星辰云', '028-34567890', '成都市高新区xxx产业园', '许晴', '18834567890', '武汉市武昌区xxx路14号', '已签收'),
                                                                                                                                                                            ('SF1234567904', 'ORD202503130015', '顺丰速运', '安恒安全', '0571-45678901', '杭州市西湖区xxx大厦', '韩雪', '19945678901', '郑州市金水区xxx路15号', '运输中');

-- 4.2 商品评价表（15条）
INSERT INTO product_reviews (product_id, user_id, order_no, rating, review_content, review_images, reply_content, review_time, reply_time) VALUES
                                                                                                                                               (1, 1, 'ORD202503200001', 5, '非常好用的产品，功能强大，操作简单，推荐购买！', '/images/review1.jpg', '感谢您的支持，我们会继续努力！', '2025-03-21 10:00:00', '2025-03-21 14:00:00'),
                                                                                                                                               (2, 2, 'ORD202503200002', 4, '产品不错，就是价格有点高，希望能有优惠活动。', NULL, '感谢反馈，我们会考虑推出优惠活动。', '2025-03-21 11:30:00', '2025-03-21 15:30:00'),
                                                                                                                                               (3, 3, 'ORD202503190003', 5, '性能稳定，安全可靠，已推荐给同事。', '/images/review3.jpg', '非常感谢您的推荐！', '2025-03-20 09:00:00', '2025-03-20 13:00:00'),
                                                                                                                                               (4, 4, 'ORD202503190004', 3, '功能还可以，但文档不够详细，入门有一定难度。', NULL, '我们会完善文档，感谢反馈。', '2025-03-20 14:00:00', '2025-03-20 16:00:00'),
                                                                                                                                               (5, 5, 'ORD202503180005', 5, '技术支持很到位，问题响应快，解决效率高。', '/images/review5.jpg', '您的满意是我们的追求！', '2025-03-19 10:30:00', '2025-03-19 15:00:00'),
                                                                                                                                               (6, 6, 'ORD202503180006', 4, '培训课程内容实用，讲师专业，收获很大。', NULL, '感谢您的认可，期待再次学习！', '2025-03-19 16:00:00', '2025-03-19 17:30:00'),
                                                                                                                                               (7, 7, 'ORD202503170007', 5, '咨询服务专业，解决方案符合我们的需求。', '/images/review7.jpg', '感谢您的信任，合作愉快！', '2025-03-18 11:00:00', '2025-03-18 14:00:00'),
                                                                                                                                               (8, 8, 'ORD202503170008', 2, '运维服务响应速度较慢，希望改进。', NULL, '很抱歉给您带来不便，我们会提升响应速度。', '2025-03-18 15:00:00', '2025-03-18 17:00:00'),
                                                                                                                                               (9, 9, 'ORD202503160009', 5, '备份系统稳定，数据恢复快，非常满意。', '/images/review9.jpg', '感谢您的支持！', '2025-03-17 09:30:00', '2025-03-17 12:00:00'),
                                                                                                                                               (10, 10, 'ORD202503160010', 4, '加密系统安全性高，但配置稍微复杂。', NULL, '我们会优化配置流程，感谢反馈。', '2025-03-17 14:00:00', '2025-03-17 16:30:00'),
                                                                                                                                               (11, 11, 'ORD202503150011', 5, '审计服务专业，报告详细，帮助发现多处隐患。', '/images/review11.jpg', '感谢您的详细评价！', '2025-03-16 10:00:00', '2025-03-16 13:00:00'),
                                                                                                                                               (12, 12, 'ORD202503150012', 4, '合规平台功能齐全，界面友好，值得推荐。', NULL, '感谢推荐！', '2025-03-16 15:00:00', '2025-03-16 17:00:00'),
                                                                                                                                               (13, 13, 'ORD202503140013', 5, '应急响应团队专业，处置及时，避免了损失。', '/images/review13.jpg', '保障您的安全是我们的职责。', '2025-03-15 11:30:00', '2025-03-15 14:30:00'),
                                                                                                                                               (14, 14, 'ORD202503140014', 3, '演练服务内容还可以，但场地安排不够理想。', NULL, '抱歉场地问题，下次会改进。', '2025-03-15 09:00:00', '2025-03-15 12:00:00'),
                                                                                                                                               (15, 15, 'ORD202503130015', 5, '保险产品性价比高，理赔流程简单。', '/images/review15.jpg', '感谢您的信任！', '2025-03-14 16:00:00', '2025-03-14 18:00:00');

-- 4.3 购物车记录表（15条）
INSERT INTO shopping_cart (user_id, product_id, product_name, quantity, unit_price, selected, added_time) VALUES
                                                                                                              (1, 1, '数据安全态势感知平台', 1, 350000.00, 1, '2025-03-20 08:00:00'),
                                                                                                              (1, 2, '数据分类分级系统', 1, 280000.00, 0, '2025-03-20 08:05:00'),
                                                                                                              (2, 3, '数据库审计系统', 2, 180000.00, 1, '2025-03-19 09:30:00'),
                                                                                                              (2, 4, '数据脱敏系统', 1, 220000.00, 0, '2025-03-19 09:35:00'),
                                                                                                              (3, 5, '数据安全评估服务', 1, 150000.00, 1, '2025-03-18 14:00:00'),
                                                                                                              (3, 6, '数据安全培训课程', 3, 50000.00, 1, '2025-03-18 14:10:00'),
                                                                                                              (4, 7, '数据安全咨询服务', 1, 200000.00, 1, '2025-03-17 10:00:00'),
                                                                                                              (5, 8, '数据安全运维服务', 1, 300000.00, 0, '2025-03-16 11:20:00'),
                                                                                                              (5, 9, '数据安全备份系统', 2, 120000.00, 1, '2025-03-16 11:25:00'),
                                                                                                              (6, 10, '数据安全加密系统', 1, 250000.00, 1, '2025-03-15 15:30:00'),
                                                                                                              (7, 11, '数据安全审计服务', 1, 180000.00, 1, '2025-03-14 09:00:00'),
                                                                                                              (8, 12, '数据安全合规平台', 1, 320000.00, 0, '2025-03-13 16:00:00'),
                                                                                                              (9, 13, '数据安全应急响应', 1, 250000.00, 1, '2025-03-12 13:30:00'),
                                                                                                              (10, 14, '数据安全演练服务', 2, 80000.00, 1, '2025-03-11 10:15:00'),
                                                                                                              (11, 15, '数据安全保险产品', 1, 50000.00, 1, '2025-03-10 11:45:00');

-- 4.4 优惠券领取记录表（12条）
INSERT INTO coupon_records (coupon_code, user_id, coupon_name, discount_amount, min_amount, start_time, end_time, used_time, order_no, status) VALUES
                                                                                                                                                   ('SP2025001', 1, '春季大促优惠券', 500.00, 5000.00, '2025-03-01 00:00:00', '2025-03-31 23:59:59', '2025-03-20 10:00:00', 'ORD202503200001', '已使用'),
                                                                                                                                                   ('SP2025002', 2, '春季大促优惠券', 500.00, 5000.00, '2025-03-01 00:00:00', '2025-03-31 23:59:59', NULL, NULL, '未使用'),
                                                                                                                                                   ('NEW2025001', 3, '新用户专享券', 5000.00, 10000.00, '2025-01-01 00:00:00', '2025-12-31 23:59:59', '2025-03-19 14:20:00', 'ORD202503190003', '已使用'),
                                                                                                                                                   ('SEC2025001', 4, '安全产品特惠券', 3000.00, 20000.00, '2025-03-15 00:00:00', '2025-04-15 23:59:59', NULL, NULL, '未使用'),
                                                                                                                                                   ('BULK2025001', 5, '批量采购优惠券', 5000.00, 30000.00, '2025-01-01 00:00:00', '2025-12-31 23:59:59', '2025-03-18 10:45:00', 'ORD202503180005', '已使用'),
                                                                                                                                                   ('VIP2025001', 6, 'VIP专享券', 1000.00, 10000.00, '2025-01-01 00:00:00', '2025-12-31 23:59:59', NULL, NULL, '未使用'),
                                                                                                                                                   ('EARLY2025001', 7, '早鸟优惠券', 3000.00, 15000.00, '2025-03-01 00:00:00', '2025-03-10 23:59:59', '2025-03-17 13:20:00', 'ORD202503170007', '已使用'),
                                                                                                                                                   ('TEAM2025001', 8, '团队采购优惠券', 8000.00, 50000.00, '2025-01-01 00:00:00', '2025-12-31 23:59:59', NULL, NULL, '未使用'),
                                                                                                                                                   ('EDU2025001', 9, '教育行业优惠券', 5000.00, 20000.00, '2025-01-01 00:00:00', '2025-12-31 23:59:59', '2025-03-16 09:30:00', 'ORD202503160009', '已使用'),
                                                                                                                                                   ('REF2025001', 10, '推荐有礼券', 2000.00, 8000.00, '2025-01-01 00:00:00', '2025-12-31 23:59:59', '2025-03-16 14:50:00', 'ORD202503160010', '已使用'),
                                                                                                                                                   ('ANN2025001', 11, '周年庆特惠券', 8000.00, 40000.00, '2025-04-01 00:00:00', '2025-04-30 23:59:59', NULL, NULL, '未使用'),
                                                                                                                                                   ('SP2025003', 12, '春季大促优惠券', 500.00, 5000.00, '2025-03-01 00:00:00', '2025-03-31 23:59:59', NULL, NULL, '未使用');

-- =====================================================
-- 五、数据统计验证
-- =====================================================
SELECT '=== 新增表数据统计 ===' AS '';
SELECT 'bank_card_info' AS table_name, COUNT(*) AS row_count FROM bank_card_info
UNION ALL SELECT 'medical_records', COUNT(*) FROM medical_records
UNION ALL SELECT 'insurance_policies', COUNT(*) FROM insurance_policies
UNION ALL SELECT 'vehicle_registration', COUNT(*) FROM vehicle_registration
UNION ALL SELECT 'property_registration', COUNT(*) FROM property_registration
UNION ALL SELECT 'education_info', COUNT(*) FROM education_info
UNION ALL SELECT 'social_security_info', COUNT(*) FROM social_security_info
UNION ALL SELECT 'online_accounts', COUNT(*) FROM online_accounts
UNION ALL SELECT 'api_tokens', COUNT(*) FROM api_tokens
UNION ALL SELECT 'payment_records', COUNT(*) FROM payment_records
UNION ALL SELECT 'biometric_data', COUNT(*) FROM biometric_data
UNION ALL SELECT 'logistics_info', COUNT(*) FROM logistics_info
UNION ALL SELECT 'product_reviews', COUNT(*) FROM product_reviews
UNION ALL SELECT 'shopping_cart', COUNT(*) FROM shopping_cart
UNION ALL SELECT 'coupon_records', COUNT(*) FROM coupon_records;

-- =====================================================
-- 使用数据库
-- =====================================================
USE data_sec_demo;

-- =====================================================
-- 一、新增敏感信息表（12张）
-- =====================================================

-- 1.1 护照签证信息表（有索引）
CREATE TABLE IF NOT EXISTS passport_visa_info (
                                                  id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键ID',
                                                  full_name VARCHAR(50) NOT NULL COMMENT '姓名',
                                                  passport_no VARCHAR(20) NOT NULL COMMENT '护照号',
                                                  country_code VARCHAR(10) COMMENT '国家代码',
                                                  issue_date DATE COMMENT '签发日期',
                                                  expiry_date DATE COMMENT '有效期至',
                                                  visa_type VARCHAR(30) COMMENT '签证类型',
                                                  visa_no VARCHAR(30) COMMENT '签证编号',
                                                  entry_count INT COMMENT '入境次数',
                                                  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
                                                  INDEX idx_passport_no (passport_no),
                                                  INDEX idx_full_name (full_name)
) COMMENT '护照签证信息表';

-- 1.2 信用报告信息表（有索引）
CREATE TABLE IF NOT EXISTS credit_report_info (
                                                  id BIGINT PRIMARY KEY AUTO_INCREMENT,
                                                  full_name VARCHAR(50) NOT NULL COMMENT '姓名',
                                                  id_card VARCHAR(18) COMMENT '身份证号',
                                                  credit_score INT COMMENT '信用评分',
                                                  credit_limit DECIMAL(15,2) COMMENT '总授信额度',
                                                  used_amount DECIMAL(15,2) COMMENT '已用额度',
                                                  overdue_count INT COMMENT '逾期次数',
                                                  overdue_amount DECIMAL(15,2) COMMENT '逾期金额',
                                                  query_count INT COMMENT '查询次数',
                                                  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
                                                  INDEX idx_id_card (id_card),
                                                  INDEX idx_full_name (full_name)
) COMMENT '信用报告信息表';

-- 1.3 家庭成员信息表（有索引）
CREATE TABLE IF NOT EXISTS family_member_info (
                                                  id BIGINT PRIMARY KEY AUTO_INCREMENT,
                                                  main_person_name VARCHAR(50) NOT NULL COMMENT '主姓名',
                                                  main_person_id VARCHAR(18) COMMENT '主身份证号',
                                                  member_name VARCHAR(50) COMMENT '成员姓名',
                                                  member_id_card VARCHAR(18) COMMENT '成员身份证',
                                                  relationship VARCHAR(20) COMMENT '关系:配偶/子女/父母',
                                                  member_phone VARCHAR(11) COMMENT '成员电话',
                                                  member_birthday DATE COMMENT '成员生日',
                                                  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
                                                  INDEX idx_main_id (main_person_id),
                                                  INDEX idx_member_id (member_id_card)
) COMMENT '家庭成员信息表';

-- 1.4 资产信息表（有索引）
CREATE TABLE IF NOT EXISTS asset_info (
                                          id BIGINT PRIMARY KEY AUTO_INCREMENT,
                                          owner_name VARCHAR(50) NOT NULL COMMENT '资产持有人',
                                          owner_id_card VARCHAR(18) COMMENT '身份证号',
                                          asset_type VARCHAR(30) COMMENT '资产类型:股票/基金/理财/存款',
                                          asset_code VARCHAR(50) COMMENT '资产代码',
                                          asset_name VARCHAR(200) COMMENT '资产名称',
                                          quantity DECIMAL(15,4) COMMENT '持有数量',
                                          cost_price DECIMAL(12,2) COMMENT '成本价',
                                          current_price DECIMAL(12,2) COMMENT '当前价',
                                          total_value DECIMAL(15,2) COMMENT '总市值',
                                          created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
                                          INDEX idx_owner_id (owner_id_card),
                                          INDEX idx_owner_name (owner_name)
) COMMENT '资产信息表';

-- 1.5 税务信息表（有索引）
CREATE TABLE IF NOT EXISTS tax_info (
                                        id BIGINT PRIMARY KEY AUTO_INCREMENT,
                                        taxpayer_name VARCHAR(50) NOT NULL COMMENT '纳税人姓名',
                                        taxpayer_id VARCHAR(20) COMMENT '纳税人识别号',
                                        id_card VARCHAR(18) COMMENT '身份证号',
                                        income_year INT COMMENT '纳税年度',
                                        total_income DECIMAL(15,2) COMMENT '总收入',
                                        taxable_income DECIMAL(15,2) COMMENT '应纳税所得额',
                                        tax_paid DECIMAL(15,2) COMMENT '已纳税额',
                                        tax_refund DECIMAL(15,2) COMMENT '应退税额',
                                        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
                                        INDEX idx_taxpayer_id (taxpayer_id),
                                        INDEX idx_id_card (id_card)
) COMMENT '税务信息表';

-- 1.6 通讯录联系人表（有索引）
CREATE TABLE IF NOT EXISTS contacts_list (
                                             id BIGINT PRIMARY KEY AUTO_INCREMENT,
                                             owner_name VARCHAR(50) NOT NULL COMMENT '所属人',
                                             owner_phone VARCHAR(11) COMMENT '所属人手机',
                                             contact_name VARCHAR(50) COMMENT '联系人姓名',
                                             contact_phone VARCHAR(11) COMMENT '联系人电话',
                                             contact_relation VARCHAR(30) COMMENT '关系',
                                             contact_email VARCHAR(100) COMMENT '联系人邮箱',
                                             contact_address VARCHAR(500) COMMENT '联系人地址',
                                             created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
                                             INDEX idx_owner_phone (owner_phone),
                                             INDEX idx_contact_phone (contact_phone)
) COMMENT '通讯录联系人表';

-- 1.7 位置轨迹信息表（有索引）
CREATE TABLE IF NOT EXISTS location_track (
                                              id BIGINT PRIMARY KEY AUTO_INCREMENT,
                                              person_name VARCHAR(50) NOT NULL COMMENT '人员姓名',
                                              person_phone VARCHAR(11) COMMENT '手机号',
                                              latitude DECIMAL(10,8) COMMENT '纬度',
                                              longitude DECIMAL(11,8) COMMENT '经度',
                                              location_address VARCHAR(500) COMMENT '位置地址',
                                              track_time DATETIME COMMENT '时间点',
                                              device_id VARCHAR(100) COMMENT '设备ID',
                                              created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
                                              INDEX idx_person_phone (person_phone),
                                              INDEX idx_track_time (track_time)
) COMMENT '位置轨迹信息表';

-- 1.8 通话记录表（有索引）
CREATE TABLE IF NOT EXISTS call_records (
                                            id BIGINT PRIMARY KEY AUTO_INCREMENT,
                                            caller_name VARCHAR(50) COMMENT '主叫人姓名',
                                            caller_phone VARCHAR(11) NOT NULL COMMENT '主叫号码',
                                            callee_name VARCHAR(50) COMMENT '被叫人姓名',
                                            callee_phone VARCHAR(11) COMMENT '被叫号码',
                                            call_duration INT COMMENT '通话时长(秒)',
                                            call_time DATETIME COMMENT '通话时间',
                                            call_type VARCHAR(10) COMMENT '呼出/呼入',
                                            imei VARCHAR(50) COMMENT '设备IMEI',
                                            created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
                                            INDEX idx_caller_phone (caller_phone),
                                            INDEX idx_callee_phone (callee_phone),
                                            INDEX idx_call_time (call_time)
) COMMENT '通话记录表';

-- 1.9 短信记录表（有索引）
CREATE TABLE IF NOT EXISTS sms_records (
                                           id BIGINT PRIMARY KEY AUTO_INCREMENT,
                                           sender_name VARCHAR(50) COMMENT '发送人姓名',
                                           sender_phone VARCHAR(11) NOT NULL COMMENT '发送号码',
                                           receiver_name VARCHAR(50) COMMENT '接收人姓名',
                                           receiver_phone VARCHAR(11) COMMENT '接收号码',
                                           sms_content TEXT COMMENT '短信内容',
                                           sms_time DATETIME COMMENT '发送时间',
                                           sms_type VARCHAR(10) COMMENT '发送/接收',
                                           created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
                                           INDEX idx_sender_phone (sender_phone),
                                           INDEX idx_receiver_phone (receiver_phone),
                                           INDEX idx_sms_time (sms_time)
) COMMENT '短信记录表';

-- 1.10 浏览器历史记录表（无索引）
CREATE TABLE IF NOT EXISTS browser_history (
                                               id BIGINT PRIMARY KEY AUTO_INCREMENT,
                                               user_name VARCHAR(50) NOT NULL COMMENT '用户名',
                                               visit_url VARCHAR(2000) COMMENT '访问URL',
                                               page_title VARCHAR(500) COMMENT '页面标题',
                                               visit_time DATETIME COMMENT '访问时间',
                                               visit_duration INT COMMENT '停留时长(秒)',
                                               browser_type VARCHAR(50) COMMENT '浏览器类型',
                                               device_type VARCHAR(30) COMMENT '设备类型'
    -- 故意不建索引
) COMMENT '浏览器历史记录表';

-- 1.11 设备指纹信息表（无索引）
CREATE TABLE IF NOT EXISTS device_fingerprint (
                                                  id BIGINT PRIMARY KEY AUTO_INCREMENT,
                                                  person_name VARCHAR(50) COMMENT '人员姓名',
                                                  device_id VARCHAR(200) COMMENT '设备唯一标识',
                                                  device_model VARCHAR(100) COMMENT '设备型号',
                                                  os_version VARCHAR(50) COMMENT '操作系统版本',
                                                  screen_resolution VARCHAR(20) COMMENT '屏幕分辨率',
                                                  mac_address VARCHAR(50) COMMENT 'MAC地址',
                                                  ip_address VARCHAR(45) COMMENT 'IP地址',
                                                  user_agent TEXT COMMENT 'User Agent',
                                                  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
    -- 故意不建索引
) COMMENT '设备指纹信息表';

-- 1.12 工作履历信息表（有索引）
CREATE TABLE IF NOT EXISTS work_history (
                                            id BIGINT PRIMARY KEY AUTO_INCREMENT,
                                            full_name VARCHAR(50) NOT NULL COMMENT '姓名',
                                            id_card VARCHAR(18) COMMENT '身份证号',
                                            company_name VARCHAR(200) COMMENT '公司名称',
                                            job_title VARCHAR(100) COMMENT '职位',
                                            start_date DATE COMMENT '入职日期',
                                            end_date DATE COMMENT '离职日期',
                                            monthly_salary DECIMAL(10,2) COMMENT '月薪',
                                            supervisor_name VARCHAR(50) COMMENT '上级姓名',
                                            supervisor_phone VARCHAR(11) COMMENT '上级电话',
                                            created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
                                            INDEX idx_id_card (id_card),
                                            INDEX idx_full_name (full_name),
                                            INDEX idx_company_name (company_name)
) COMMENT '工作履历信息表';

-- =====================================================
-- 二、新增业务表（3张）
-- =====================================================

-- 2.1 活动报名表（有索引）
CREATE TABLE IF NOT EXISTS event_registration (
                                                  id BIGINT PRIMARY KEY AUTO_INCREMENT,
                                                  event_name VARCHAR(200) NOT NULL COMMENT '活动名称',
                                                  registrant_name VARCHAR(50) COMMENT '报名人姓名',
                                                  registrant_phone VARCHAR(11) COMMENT '联系电话',
                                                  registrant_email VARCHAR(100) COMMENT '邮箱',
                                                  company_name VARCHAR(200) COMMENT '公司名称',
                                                  job_title VARCHAR(100) COMMENT '职位',
                                                  registration_time DATETIME COMMENT '报名时间',
                                                  check_in_time DATETIME COMMENT '签到时间',
                                                  status VARCHAR(20) COMMENT '状态',
                                                  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
                                                  INDEX idx_event_name (event_name),
                                                  INDEX idx_registrant_phone (registrant_phone)
) COMMENT '活动报名表';

-- 2.2 售后服务工单表（有索引）
CREATE TABLE IF NOT EXISTS service_tickets (
                                               id BIGINT PRIMARY KEY AUTO_INCREMENT,
                                               ticket_no VARCHAR(32) NOT NULL COMMENT '工单号',
                                               customer_name VARCHAR(50) COMMENT '客户姓名',
                                               customer_phone VARCHAR(11) COMMENT '联系电话',
                                               product_name VARCHAR(200) COMMENT '产品名称',
                                               issue_type VARCHAR(50) COMMENT '问题类型',
                                               issue_description TEXT COMMENT '问题描述',
                                               urgency VARCHAR(20) COMMENT '紧急程度',
                                               status VARCHAR(20) COMMENT '处理状态',
                                               handler VARCHAR(50) COMMENT '处理人',
                                               handle_time DATETIME COMMENT '处理时间',
                                               created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
                                               INDEX idx_ticket_no (ticket_no),
                                               INDEX idx_customer_phone (customer_phone),
                                               INDEX idx_status (status)
) COMMENT '售后服务工单表';

-- 2.3 用户反馈表（无索引）
CREATE TABLE IF NOT EXISTS user_feedback (
                                             id BIGINT PRIMARY KEY AUTO_INCREMENT,
                                             user_name VARCHAR(50) COMMENT '用户名',
                                             user_phone VARCHAR(11) COMMENT '联系电话',
                                             feedback_type VARCHAR(30) COMMENT '反馈类型',
                                             feedback_content TEXT COMMENT '反馈内容',
                                             rating TINYINT COMMENT '评分1-5',
                                             feedback_time DATETIME COMMENT '反馈时间',
                                             reply_content TEXT COMMENT '回复内容',
                                             reply_time DATETIME COMMENT '回复时间'
    -- 故意不建索引
) COMMENT '用户反馈表';

-- =====================================================
-- 三、插入模拟数据
-- =====================================================

-- 3.1 护照签证信息表（12条）
INSERT INTO passport_visa_info (full_name, passport_no, country_code, issue_date, expiry_date, visa_type, visa_no, entry_count) VALUES
                                                                                                                                    ('张明', 'E12345678', 'USA', '2018-05-20', '2028-05-19', 'B1/B2', 'USVISA001234', 10),
                                                                                                                                    ('李芳', 'E87654321', 'CAN', '2019-03-15', '2029-03-14', 'TRV', 'CANVISA005678', 5),
                                                                                                                                    ('王磊', 'E23456789', 'GBR', '2020-01-10', '2030-01-09', 'Standard Visitor', 'GBVISA009876', 3),
                                                                                                                                    ('赵静', 'E98765432', 'AUS', '2017-11-20', '2027-11-19', 'Subclass 600', 'AUSVISA004321', 4),
                                                                                                                                    ('陈强', 'E34567890', 'JPN', '2019-06-25', '2029-06-24', '短期滞在', 'JPNVISA007890', 8),
                                                                                                                                    ('刘娜', 'E09876543', 'KOR', '2021-02-14', '2031-02-13', 'C-3-9', 'KORVISA001234', 6),
                                                                                                                                    ('周涛', 'E45678901', 'FRA', '2018-09-05', '2028-09-04', '申根', 'SCHVISA003456', 7),
                                                                                                                                    ('吴迪', 'E10987654', 'DEU', '2020-07-19', '2030-07-18', '申根', 'SCHVISA005678', 4),
                                                                                                                                    ('郑爽', 'E56789012', 'SGP', '2019-12-01', '2029-11-30', '旅游签证', 'SGPVISA007890', 9),
                                                                                                                                    ('林晨', 'E21098765', 'NZL', '2021-04-08', '2031-04-07', 'Visitor Visa', 'NZLVISA009012', 2),
                                                                                                                                    ('郭峰', 'E67890123', 'THA', '2022-01-15', '2032-01-14', '旅游签证', 'THAVISA001234', 5),
                                                                                                                                    ('唐雅', 'E32109876', 'MYS', '2020-10-20', '2030-10-19', 'eNTRI', 'MYSVISA003456', 6);

-- 3.2 信用报告信息表（10条）
INSERT INTO credit_report_info (full_name, id_card, credit_score, credit_limit, used_amount, overdue_count, overdue_amount, query_count) VALUES
                                                                                                                                             ('张明', '11010119900307663X', 725, 500000.00, 125000.00, 1, 3200.00, 12),
                                                                                                                                             ('李芳', '310101198805124567', 780, 800000.00, 200000.00, 0, 0.00, 8),
                                                                                                                                             ('王磊', '440301199210235678', 690, 300000.00, 180000.00, 2, 5600.00, 15),
                                                                                                                                             ('赵静', '51010719870714789X', 745, 450000.00, 95000.00, 0, 0.00, 6),
                                                                                                                                             ('陈强', '320105199103156789', 710, 400000.00, 220000.00, 1, 1800.00, 10),
                                                                                                                                             ('刘娜', '350203199512019876', 798, 1000000.00, 350000.00, 0, 0.00, 5),
                                                                                                                                             ('周涛', '120101198608128765', 685, 280000.00, 195000.00, 3, 8900.00, 18),
                                                                                                                                             ('吴迪', '430103199311234321', 735, 350000.00, 120000.00, 0, 0.00, 9),
                                                                                                                                             ('郑爽', '210203199403211234', 760, 600000.00, 250000.00, 0, 0.00, 7),
                                                                                                                                             ('林晨', '370202199707153456', 705, 320000.00, 150000.00, 1, 2500.00, 11);

-- 3.3 家庭成员信息表（15条）
INSERT INTO family_member_info (main_person_name, main_person_id, member_name, member_id_card, relationship, member_phone, member_birthday) VALUES
                                                                                                                                                ('张明', '11010119900307663X', '王丽', '11010119920307668X', '配偶', '13812345679', '1992-03-07'),
                                                                                                                                                ('张明', '11010119900307663X', '张小宝', '11010120200307661X', '子女', NULL, '2020-03-07'),
                                                                                                                                                ('李芳', '310101198805124567', '刘强', '31010119860312456X', '配偶', '13987654322', '1986-03-12'),
                                                                                                                                                ('王磊', '440301199210235678', '王建国', '44030119651023567X', '父亲', '15812345679', '1965-10-23'),
                                                                                                                                                ('王磊', '440301199210235678', '李秀英', '44030119700823568X', '母亲', '15812345680', '1970-08-23'),
                                                                                                                                                ('赵静', '51010719870714789X', '陈浩', '51010719850514789X', '配偶', '17712345679', '1985-05-14'),
                                                                                                                                                ('陈强', '320105199103156789', '陈国栋', '32010519680315678X', '父亲', '18612345679', '1968-03-15'),
                                                                                                                                                ('陈强', '320105199103156789', '王秀芳', '32010519710515679X', '母亲', '18612345680', '1971-05-15'),
                                                                                                                                                ('刘娜', '350203199512019876', '刘大海', '35020319691201987X', '父亲', '15987654322', '1969-12-01'),
                                                                                                                                                ('刘娜', '350203199512019876', '陈玉梅', '35020319731201988X', '母亲', '15987654323', '1973-12-01'),
                                                                                                                                                ('周涛', '120101198608128765', '周华', '12010119820812876X', '配偶', '13512345679', '1982-08-12'),
                                                                                                                                                ('吴迪', '430103199311234321', '吴建军', '43010319681123432X', '父亲', '15212345679', '1968-11-23'),
                                                                                                                                                ('郑爽', '210203199403211234', '郑晓东', '21020319960321123X', '配偶', '18712345679', '1996-03-21'),
                                                                                                                                                ('林晨', '370202199707153456', '林峰', '37020219680715345X', '父亲', '18812345679', '1968-07-15'),
                                                                                                                                                ('林晨', '370202199707153456', '孙丽', '37020219720715346X', '母亲', '18812345680', '1972-07-15');

-- 3.4 资产信息表（12条）
INSERT INTO asset_info (owner_name, owner_id_card, asset_type, asset_code, asset_name, quantity, cost_price, current_price, total_value) VALUES
                                                                                                                                             ('张明', '11010119900307663X', '股票', '600519', '贵州茅台', 500.00, 1680.00, 1750.00, 875000.00),
                                                                                                                                             ('张明', '11010119900307663X', '基金', '000001', '华夏成长混合', 10000.00, 1.85, 2.10, 21000.00),
                                                                                                                                             ('李芳', '310101198805124567', '股票', '000858', '五粮液', 800.00, 145.00, 155.00, 124000.00),
                                                                                                                                             ('王磊', '440301199210235678', '理财', 'C001', '招行日日盈', 50000.00, 1.00, 1.00, 50000.00),
                                                                                                                                             ('赵静', '51010719870714789X', '存款', '定期', '3年定期存款', 200000.00, 1.00, 1.00, 200000.00),
                                                                                                                                             ('陈强', '320105199103156789', '基金', '110011', '易方达中小盘', 8000.00, 4.50, 5.20, 41600.00),
                                                                                                                                             ('刘娜', '350203199512019876', '股票', '300750', '宁德时代', 300.00, 180.00, 200.00, 60000.00),
                                                                                                                                             ('周涛', '120101198608128765', '理财', 'P002', '平安稳赢', 100000.00, 1.00, 1.02, 102000.00),
                                                                                                                                             ('吴迪', '430103199311234321', '存款', '活期', '活期存款', 50000.00, 1.00, 1.00, 50000.00),
                                                                                                                                             ('郑爽', '210203199403211234', '股票', '601318', '中国平安', 1000.00, 45.00, 48.00, 48000.00),
                                                                                                                                             ('林晨', '370202199707153456', '基金', '519069', '汇添富价值精选', 5000.00, 3.20, 3.80, 19000.00),
                                                                                                                                             ('郭峰', '500101198809194567', '理财', 'B003', '建信理财', 80000.00, 1.00, 1.01, 80800.00);

-- 3.5 税务信息表（10条）
INSERT INTO tax_info (taxpayer_name, taxpayer_id, id_card, income_year, total_income, taxable_income, tax_paid, tax_refund) VALUES
                                                                                                                                ('张明', 'TAX110101001', '11010119900307663X', 2024, 350000.00, 250000.00, 35000.00, 1200.00),
                                                                                                                                ('李芳', 'TAX310101002', '310101198805124567', 2024, 420000.00, 320000.00, 48000.00, 2000.00),
                                                                                                                                ('王磊', 'TAX440301003', '440301199210235678', 2024, 280000.00, 180000.00, 22000.00, 800.00),
                                                                                                                                ('赵静', 'TAX510107004', '51010719870714789X', 2024, 380000.00, 280000.00, 40000.00, 1500.00),
                                                                                                                                ('陈强', 'TAX320105005', '320105199103156789', 2024, 320000.00, 220000.00, 30000.00, 1000.00),
                                                                                                                                ('刘娜', 'TAX350203006', '350203199512019876', 2024, 260000.00, 160000.00, 18000.00, 600.00),
                                                                                                                                ('周涛', 'TAX120101007', '120101198608128765', 2024, 450000.00, 350000.00, 55000.00, 2500.00),
                                                                                                                                ('吴迪', 'TAX430103008', '430103199311234321', 2024, 300000.00, 200000.00, 26000.00, 900.00),
                                                                                                                                ('郑爽', 'TAX210203009', '210203199403211234', 2024, 400000.00, 300000.00, 45000.00, 1800.00),
                                                                                                                                ('林晨', 'TAX370202010', '370202199707153456', 2024, 270000.00, 170000.00, 20000.00, 700.00);

-- 3.6 通讯录联系人表（15条）
INSERT INTO contacts_list (owner_name, owner_phone, contact_name, contact_phone, contact_relation, contact_email, contact_address) VALUES
                                                                                                                                       ('张明', '13812345678', '王建国', '13912345678', '同事', 'wangjg@example.com', '北京市朝阳区xxx大厦'),
                                                                                                                                       ('张明', '13812345678', '李小明', '15812345679', '朋友', 'lixm@example.com', '北京市海淀区xxx小区'),
                                                                                                                                       ('李芳', '13987654321', '赵丽华', '15987654322', '闺蜜', 'zhaolh@example.com', '上海市浦东新区xxx路'),
                                                                                                                                       ('李芳', '13987654321', '刘伟', '17712345678', '同学', 'liuw@example.com', '上海市徐汇区xxx弄'),
                                                                                                                                       ('王磊', '15812345678', '陈强', '18612345678', '同事', 'chenq@example.com', '深圳市南山区科技园'),
                                                                                                                                       ('王磊', '15812345678', '周敏', '13512345679', '客户', 'zhoum@example.com', '深圳市福田区xxx大厦'),
                                                                                                                                       ('赵静', '17712345678', '吴迪', '15212345678', '同学', 'wud@example.com', '成都市高新区天府大道'),
                                                                                                                                       ('赵静', '17712345678', '郑爽', '18712345678', '朋友', 'zhengs@example.com', '成都市武侯区xxx路'),
                                                                                                                                       ('陈强', '18612345678', '林晨', '18812345678', '同事', 'linc@example.com', '杭州市西湖区xxx科技园'),
                                                                                                                                       ('陈强', '18612345678', '郭峰', '18912345678', '客户', 'guof@example.com', '杭州市滨江区xxx大厦'),
                                                                                                                                       ('刘娜', '15987654321', '唐雅', '16612345678', '闺蜜', 'tangy@example.com', '厦门市思明区环岛路'),
                                                                                                                                       ('刘娜', '15987654321', '孙浩', '17723456789', '同学', 'sunh@example.com', '厦门市湖里区xxx路'),
                                                                                                                                       ('周涛', '13512345678', '许晴', '18834567890', '同事', 'xuq@example.com', '天津市和平区南京路'),
                                                                                                                                       ('周涛', '13512345678', '韩雪', '19945678901', '客户', 'hanx@example.com', '天津市河西区xxx路'),
                                                                                                                                       ('吴迪', '15212345678', '张明', '13812345678', '朋友', 'zhangm@example.com', '长沙市岳麓区麓谷大道');

-- 3.7 位置轨迹信息表（15条）
INSERT INTO location_track (person_name, person_phone, latitude, longitude, location_address, track_time, device_id) VALUES
                                                                                                                         ('张明', '13812345678', 39.904200, 116.407396, '北京市朝阳区望京SOHO', '2025-03-20 09:00:00', 'device_001_iphone'),
                                                                                                                         ('张明', '13812345678', 39.904500, 116.408000, '北京市朝阳区望京地铁站', '2025-03-20 12:30:00', 'device_001_iphone'),
                                                                                                                         ('张明', '13812345678', 39.905000, 116.409500, '北京市朝阳区凯德MALL', '2025-03-20 18:00:00', 'device_001_iphone'),
                                                                                                                         ('李芳', '13987654321', 31.230416, 121.473701, '上海市浦东新区陆家嘴', '2025-03-20 09:30:00', 'device_002_huawei'),
                                                                                                                         ('李芳', '13987654321', 31.235000, 121.480000, '上海市浦东新区世纪大道', '2025-03-20 13:00:00', 'device_002_huawei'),
                                                                                                                         ('王磊', '15812345678', 22.543099, 114.057868, '深圳市南山区科技园', '2025-03-19 10:00:00', 'device_003_xiaomi'),
                                                                                                                         ('王磊', '15812345678', 22.545000, 114.060000, '深圳市南山区海岸城', '2025-03-19 19:30:00', 'device_003_xiaomi'),
                                                                                                                         ('赵静', '17712345678', 30.572815, 104.066801, '成都市高新区天府三街', '2025-03-18 09:00:00', 'device_004_samsung'),
                                                                                                                         ('赵静', '17712345678', 30.575000, 104.070000, '成都市高新区银泰城', '2025-03-18 12:00:00', 'device_004_samsung'),
                                                                                                                         ('陈强', '18612345678', 30.274084, 120.155074, '杭州市西湖区西溪湿地', '2025-03-17 14:00:00', 'device_005_oppo'),
                                                                                                                         ('陈强', '18612345678', 30.280000, 120.160000, '杭州市西湖区黄龙时代广场', '2025-03-17 17:00:00', 'device_005_oppo'),
                                                                                                                         ('刘娜', '15987654321', 24.479000, 118.089000, '厦门市思明区中山路', '2025-03-16 11:00:00', 'device_006_vivo'),
                                                                                                                         ('刘娜', '15987654321', 24.482000, 118.092000, '厦门市思明区曾厝垵', '2025-03-16 15:30:00', 'device_006_vivo'),
                                                                                                                         ('周涛', '13512345678', 39.123456, 117.234567, '天津市和平区滨江道', '2025-03-15 10:00:00', 'device_007_oneplus'),
                                                                                                                         ('周涛', '13512345678', 39.125000, 117.238000, '天津市南开区鼓楼', '2025-03-15 14:00:00', 'device_007_oneplus');

-- 3.8 通话记录表（20条）
INSERT INTO call_records (caller_name, caller_phone, callee_name, callee_phone, call_duration, call_time, call_type, imei) VALUES
                                                                                                                               ('张明', '13812345678', '李芳', '13987654321', 180, '2025-03-20 10:30:00', '呼出', '123456789012345'),
                                                                                                                               ('李芳', '13987654321', '张明', '13812345678', 245, '2025-03-20 11:00:00', '呼入', '234567890123456'),
                                                                                                                               ('王磊', '15812345678', '陈强', '18612345678', 120, '2025-03-19 14:30:00', '呼出', '345678901234567'),
                                                                                                                               ('赵静', '17712345678', '吴迪', '15212345678', 85, '2025-03-19 09:15:00', '呼出', '456789012345678'),
                                                                                                                               ('陈强', '18612345678', '刘娜', '15987654321', 300, '2025-03-18 16:20:00', '呼入', '567890123456789'),
                                                                                                                               ('刘娜', '15987654321', '周涛', '13512345678', 65, '2025-03-18 11:00:00', '呼出', '678901234567890'),
                                                                                                                               ('周涛', '13512345678', '郑爽', '18712345678', 420, '2025-03-17 19:30:00', '呼出', '789012345678901'),
                                                                                                                               ('吴迪', '15212345678', '林晨', '18812345678', 90, '2025-03-17 13:45:00', '呼入', '890123456789012'),
                                                                                                                               ('郑爽', '18712345678', '郭峰', '18912345678', 150, '2025-03-16 10:00:00', '呼出', '901234567890123'),
                                                                                                                               ('林晨', '18812345678', '唐雅', '16612345678', 210, '2025-03-16 15:30:00', '呼入', '012345678901234'),
                                                                                                                               ('郭峰', '18912345678', '孙浩', '17723456789', 45, '2025-03-15 09:00:00', '呼出', '123456789012346'),
                                                                                                                               ('唐雅', '16612345678', '许晴', '18834567890', 180, '2025-03-15 14:00:00', '呼出', '234567890123457'),
                                                                                                                               ('孙浩', '17723456789', '韩雪', '19945678901', 75, '2025-03-14 11:30:00', '呼入', '345678901234568'),
                                                                                                                               ('许晴', '18834567890', '张明', '13812345678', 135, '2025-03-14 16:00:00', '呼出', '456789012345679'),
                                                                                                                               ('韩雪', '19945678901', '李芳', '13987654321', 95, '2025-03-13 10:15:00', '呼入', '567890123456780'),
                                                                                                                               ('张明', '13812345678', '王磊', '15812345678', 260, '2025-03-13 20:00:00', '呼出', '678901234567891'),
                                                                                                                               ('李芳', '13987654321', '赵静', '17712345678', 110, '2025-03-12 09:30:00', '呼出', '789012345678902'),
                                                                                                                               ('王磊', '15812345678', '陈强', '18612345678', 200, '2025-03-12 14:00:00', '呼入', '890123456789013'),
                                                                                                                               ('赵静', '17712345678', '刘娜', '15987654321', 55, '2025-03-11 11:00:00', '呼出', '901234567890124'),
                                                                                                                               ('陈强', '18612345678', '周涛', '13512345678', 340, '2025-03-11 17:30:00', '呼入', '012345678901235');

-- 3.9 短信记录表（18条）
INSERT INTO sms_records (sender_name, sender_phone, receiver_name, receiver_phone, sms_content, sms_time, sms_type) VALUES
                                                                                                                        ('张明', '13812345678', '李芳', '13987654321', '晚上一起吃饭吗？', '2025-03-20 17:00:00', '发送'),
                                                                                                                        ('李芳', '13987654321', '张明', '13812345678', '好的，几点？', '2025-03-20 17:05:00', '接收'),
                                                                                                                        ('银行', '95588', '张明', '13812345678', '【工商银行】您尾号1234的储蓄卡转账收入5000.00元', '2025-03-20 09:30:00', '接收'),
                                                                                                                        ('支付宝', '95188', '李芳', '13987654321', '【支付宝】您有一笔消费299.00元', '2025-03-19 14:20:00', '接收'),
                                                                                                                        ('王磊', '15812345678', '陈强', '18612345678', '项目进度怎么样了？', '2025-03-19 10:00:00', '发送'),
                                                                                                                        ('陈强', '18612345678', '王磊', '15812345678', '进度正常，预计周五完成', '2025-03-19 10:05:00', '接收'),
                                                                                                                        ('京东', '4006065500', '赵静', '17712345678', '【京东】您的订单已发货，快递单号SF1234567890', '2025-03-18 15:30:00', '接收'),
                                                                                                                        ('赵静', '17712345678', '吴迪', '15212345678', '周末有空出来聚聚吗？', '2025-03-18 12:00:00', '发送'),
                                                                                                                        ('吴迪', '15212345678', '赵静', '17712345678', '好的，周六中午见', '2025-03-18 12:15:00', '接收'),
                                                                                                                        ('中国移动', '10086', '刘娜', '15987654321', '【中国移动】您本月套餐剩余流量2.5GB', '2025-03-17 08:00:00', '接收'),
                                                                                                                        ('刘娜', '15987654321', '周涛', '13512345678', '资料发你邮箱了，请查收', '2025-03-17 11:20:00', '发送'),
                                                                                                                        ('周涛', '13512345678', '刘娜', '15987654321', '收到了，谢谢', '2025-03-17 11:25:00', '接收'),
                                                                                                                        ('顺丰', '95338', '郑爽', '18712345678', '【顺丰速运】您的快件已签收，感谢使用', '2025-03-16 10:00:00', '接收'),
                                                                                                                        ('郑爽', '18712345678', '林晨', '18812345678', '生日快乐！', '2025-03-16 09:00:00', '发送'),
                                                                                                                        ('林晨', '18812345678', '郑爽', '18712345678', '谢谢祝福！', '2025-03-16 09:05:00', '接收'),
                                                                                                                        ('美团', '10107888', '郭峰', '18912345678', '【美团】您有一个红包即将过期，点击领取', '2025-03-15 12:00:00', '接收'),
                                                                                                                        ('郭峰', '18912345678', '唐雅', '16612345678', '明天开会记得带上材料', '2025-03-15 16:30:00', '发送'),
                                                                                                                        ('唐雅', '16612345678', '郭峰', '18912345678', '收到，已准备好', '2025-03-15 16:35:00', '接收');

-- 3.10 浏览器历史记录表（15条）
INSERT INTO browser_history (user_name, visit_url, page_title, visit_time, visit_duration, browser_type, device_type) VALUES
                                                                                                                          ('张明', 'https://www.google.com/search?q=mysql', 'mysql - Google搜索', '2025-03-20 09:00:00', 120, 'Chrome', 'PC'),
                                                                                                                          ('张明', 'https://github.com/', 'GitHub', '2025-03-20 09:30:00', 300, 'Chrome', 'PC'),
                                                                                                                          ('张明', 'https://stackoverflow.com/questions/tagged/mysql', 'MySQL Questions', '2025-03-20 10:00:00', 450, 'Chrome', 'PC'),
                                                                                                                          ('李芳', 'https://www.baidu.com/', '百度一下', '2025-03-20 10:00:00', 60, 'Edge', 'PC'),
                                                                                                                          ('李芳', 'https://www.taobao.com/', '淘宝网', '2025-03-20 11:00:00', 600, 'Edge', 'PC'),
                                                                                                                          ('王磊', 'https://www.bilibili.com/', 'B站', '2025-03-19 14:00:00', 1800, 'Chrome', 'PC'),
                                                                                                                          ('王磊', 'https://www.youtube.com/watch?v=abc123', 'Python Tutorial', '2025-03-19 20:00:00', 900, 'Chrome', 'PC'),
                                                                                                                          ('赵静', 'https://www.jd.com/', '京东', '2025-03-18 15:00:00', 300, 'Safari', 'Mobile'),
                                                                                                                          ('陈强', 'https://www.zhihu.com/', '知乎', '2025-03-17 20:00:00', 1200, 'Chrome', 'PC'),
                                                                                                                          ('陈强', 'https://www.csdn.net/', 'CSDN', '2025-03-17 21:00:00', 600, 'Chrome', 'PC'),
                                                                                                                          ('刘娜', 'https://www.douyin.com/', '抖音', '2025-03-16 19:00:00', 3600, 'Chrome', 'Mobile'),
                                                                                                                          ('周涛', 'https://mail.163.com/', '163邮箱', '2025-03-15 09:00:00', 180, 'Edge', 'PC'),
                                                                                                                          ('吴迪', 'https://cloud.tencent.com/', '腾讯云', '2025-03-14 10:00:00', 900, 'Chrome', 'PC'),
                                                                                                                          ('郑爽', 'https://www.alipay.com/', '支付宝', '2025-03-13 12:00:00', 120, 'Safari', 'Mobile'),
                                                                                                                          ('林晨', 'https://music.163.com/', '网易云音乐', '2025-03-12 22:00:00', 1800, 'Chrome', 'PC');

-- 3.11 设备指纹信息表（10条）
INSERT INTO device_fingerprint (person_name, device_id, device_model, os_version, screen_resolution, mac_address, ip_address, user_agent) VALUES
                                                                                                                                              ('张明', 'fp_001_iphone12_abc123', 'iPhone 12', 'iOS 15.4', '2532x1170', 'AA:BB:CC:DD:EE:01', '192.168.1.101', 'Mozilla/5.0 (iPhone; CPU iPhone OS 15_4 like Mac OS X)'),
                                                                                                                                              ('张明', 'fp_002_macbook_xyz789', 'MacBook Pro 14', 'macOS 12.3', '3024x1964', 'AA:BB:CC:DD:EE:02', '192.168.1.102', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7)'),
                                                                                                                                              ('李芳', 'fp_003_huawei_p40_def456', 'Huawei P40', 'Android 11', '2340x1080', 'BB:CC:DD:EE:FF:03', '192.168.1.103', 'Mozilla/5.0 (Linux; Android 11; Huawei P40)'),
                                                                                                                                              ('王磊', 'fp_004_xiaomi11_ghi789', 'Xiaomi 11', 'Android 12', '2400x1080', 'CC:DD:EE:FF:00:04', '10.0.0.1', 'Mozilla/5.0 (Linux; Android 12; Xiaomi 11)'),
                                                                                                                                              ('赵静', 'fp_005_samsung_s21_jkl012', 'Samsung S21', 'Android 12', '2400x1080', 'DD:EE:FF:00:11:05', '10.0.0.2', 'Mozilla/5.0 (Linux; Android 12; Samsung S21)'),
                                                                                                                                              ('陈强', 'fp_006_oppo_find_mno345', 'OPPO Find X5', 'Android 12', '2412x1080', 'EE:FF:00:11:22:06', '172.16.0.1', 'Mozilla/5.0 (Linux; Android 12; OPPO Find X5)'),
                                                                                                                                              ('刘娜', 'fp_007_vivo_x70_pqr678', 'vivo X70', 'Android 11', '2376x1080', 'FF:00:11:22:33:07', '172.16.0.2', 'Mozilla/5.0 (Linux; Android 11; vivo X70)'),
                                                                                                                                              ('周涛', 'fp_008_oneplus9_stu901', 'OnePlus 9', 'Android 12', '2400x1080', '00:11:22:33:44:08', '192.168.1.110', 'Mozilla/5.0 (Linux; Android 12; OnePlus 9)'),
                                                                                                                                              ('吴迪', 'fp_009_pixel6_vwx234', 'Google Pixel 6', 'Android 12', '2400x1080', '11:22:33:44:55:09', '192.168.1.111', 'Mozilla/5.0 (Linux; Android 12; Pixel 6)'),
                                                                                                                                              ('郑爽', 'fp_010_ipad_pro_yz567', 'iPad Pro', 'iOS 15.4', '2388x1668', '22:33:44:55:66:10', '192.168.1.112', 'Mozilla/5.0 (iPad; CPU OS 15_4 like Mac OS X)');

-- 3.12 工作履历信息表（12条）
INSERT INTO work_history (full_name, id_card, company_name, job_title, start_date, end_date, monthly_salary, supervisor_name, supervisor_phone) VALUES
                                                                                                                                                    ('张明', '11010119900307663X', '云创科技股份有限公司', '技术总监', '2020-03-01', NULL, 35000.00, '王总', '13811111111'),
                                                                                                                                                    ('张明', '11010119900307663X', '海纳数据安全有限公司', '高级工程师', '2015-07-01', '2020-02-28', 20000.00, '李经理', '13922222222'),
                                                                                                                                                    ('李芳', '310101198805124567', '智联信息技术集团', '产品总监', '2019-06-01', NULL, 32000.00, '张总', '13833333333'),
                                                                                                                                                    ('李芳', '310101198805124567', '致远软件科技', '产品经理', '2014-08-01', '2019-05-31', 18000.00, '刘经理', '13944444444'),
                                                                                                                                                    ('王磊', '440301199210235678', '星辰云计算有限公司', '销售总监', '2021-02-01', NULL, 30000.00, '李总', '13855555555'),
                                                                                                                                                    ('王磊', '440301199210235678', '安恒信息安全技术', '销售经理', '2016-03-01', '2021-01-31', 15000.00, '陈经理', '13966666666'),
                                                                                                                                                    ('赵静', '51010719870714789X', '磐石区块链科技', '架构师', '2022-01-01', NULL, 28000.00, '周总', '13877777777'),
                                                                                                                                                    ('赵静', '51010719870714789X', '天璇人工智能实验室', '技术经理', '2017-06-01', '2021-12-31', 22000.00, '吴经理', '13988888888'),
                                                                                                                                                    ('陈强', '320105199103156789', '昆仑金融科技集团', '高级工程师', '2021-08-01', NULL, 22000.00, '郑总', '13899999999'),
                                                                                                                                                    ('陈强', '320105199103156789', '华盾网络安全公司', '工程师', '2016-09-01', '2021-07-31', 12000.00, '林经理', '13900000000'),
                                                                                                                                                    ('刘娜', '350203199512019876', '云创科技股份有限公司', '市场经理', '2022-03-01', NULL, 18000.00, '王总', '13811111111'),
                                                                                                                                                    ('刘娜', '350203199512019876', '海纳数据安全有限公司', '市场专员', '2019-07-01', '2022-02-28', 10000.00, '李经理', '13922222222');

-- =====================================================
-- 四、业务表数据
-- =====================================================

-- 4.1 活动报名表（12条）
INSERT INTO event_registration (event_name, registrant_name, registrant_phone, registrant_email, company_name, job_title, registration_time, check_in_time, status) VALUES
                                                                                                                                                                        ('2024数据安全峰会', '张明', '13812345678', 'zhangming@example.com', '云创科技', '技术总监', '2025-03-01 09:00:00', '2025-03-20 09:00:00', '已签到'),
                                                                                                                                                                        ('2024数据安全峰会', '李芳', '13987654321', 'lifang@example.com', '海纳数据', '产品总监', '2025-03-02 10:00:00', '2025-03-20 09:15:00', '已签到'),
                                                                                                                                                                        ('2024数据安全峰会', '王磊', '15812345678', 'wanglei@example.com', '智联信息', '销售总监', '2025-03-01 14:00:00', NULL, '已报名'),
                                                                                                                                                                        ('AI技术大会', '赵静', '17712345678', 'zhaojing@example.com', '星辰云', '架构师', '2025-03-05 09:30:00', '2025-03-15 09:00:00', '已签到'),
                                                                                                                                                                        ('AI技术大会', '陈强', '18612345678', 'chenqiang@example.com', '安恒安全', '高级工程师', '2025-03-06 11:00:00', NULL, '已报名'),
                                                                                                                                                                        ('AI技术大会', '刘娜', '15987654321', 'liuna@example.com', '致远软件', '市场经理', '2025-03-04 15:00:00', '2025-03-15 09:30:00', '已签到'),
                                                                                                                                                                        ('网络安全论坛', '周涛', '13512345678', 'zhoutao@example.com', '磐石区块链', '架构师', '2025-03-10 10:00:00', '2025-03-18 09:00:00', '已签到'),
                                                                                                                                                                        ('网络安全论坛', '吴迪', '15212345678', 'wudi@example.com', '天璇AI', '技术经理', '2025-03-11 14:30:00', '2025-03-18 09:15:00', '已签到'),
                                                                                                                                                                        ('云计算峰会', '郑爽', '18712345678', 'zhengshuang@example.com', '昆仑金融', '高级工程师', '2025-03-08 09:00:00', '2025-03-22 10:00:00', '已签到'),
                                                                                                                                                                        ('云计算峰会', '林晨', '18812345678', 'linchen@example.com', '华盾安全', '工程师', '2025-03-09 16:00:00', NULL, '已报名'),
                                                                                                                                                                        ('大数据论坛', '郭峰', '18912345678', 'guofeng@example.com', '云创科技', '技术经理', '2025-03-12 11:00:00', NULL, '已报名'),
                                                                                                                                                                        ('大数据论坛', '唐雅', '16612345678', 'tangya@example.com', '海纳数据', '产品经理', '2025-03-13 09:30:00', NULL, '已报名');

-- 4.2 售后服务工单表（12条）
INSERT INTO service_tickets (ticket_no, customer_name, customer_phone, product_name, issue_type, issue_description, urgency, status, handler, handle_time) VALUES
                                                                                                                                                               ('TK20240320001', '张明', '13812345678', '数据安全态势感知平台', '功能问题', '登录后页面加载缓慢，超过10秒', '中', '已完成', '技术支持', '2025-03-20 14:00:00'),
                                                                                                                                                               ('TK20240320002', '李芳', '13987654321', '数据分类分级系统', '配置问题', '数据库连接配置不生效', '高', '处理中', '技术支持', NULL),
                                                                                                                                                               ('TK20240319003', '王磊', '15812345678', '数据库审计系统', '告警问题', '误报率较高，需要调整规则', '中', '已完成', '技术专家', '2025-03-19 16:30:00'),
                                                                                                                                                               ('TK20240319004', '赵静', '17712345678', '数据脱敏系统', '性能问题', '大批量数据脱敏速度慢', '高', '处理中', '技术专家', NULL),
                                                                                                                                                               ('TK20240318005', '陈强', '18612345678', '数据安全评估服务', '咨询问题', '需要了解评估报告的详细解读', '低', '已完成', '客户成功', '2025-03-18 11:00:00'),
                                                                                                                                                               ('TK20240318006', '刘娜', '15987654321', '数据安全培训课程', '课程问题', '课程视频无法播放', '中', '已完成', '技术支持', '2025-03-18 15:00:00'),
                                                                                                                                                               ('TK20240317007', '周涛', '13512345678', '数据安全咨询服务', '需求变更', '需要增加新的安全评估项', '中', '处理中', '咨询顾问', NULL),
                                                                                                                                                               ('TK20240317008', '吴迪', '15212345678', '数据安全运维服务', '紧急故障', '系统出现异常重启', '紧急', '处理中', '运维工程师', NULL),
                                                                                                                                                               ('TK20240316009', '郑爽', '18712345678', '数据安全备份系统', '备份失败', '定时备份任务执行失败', '高', '已完成', '技术支持', '2025-03-16 14:00:00'),
                                                                                                                                                               ('TK20240316010', '林晨', '18812345678', '数据安全加密系统', '兼容性问题', '与现有系统不兼容', '中', '处理中', '技术专家', NULL),
                                                                                                                                                               ('TK20240315011', '郭峰', '18912345678', '数据安全审计服务', '报告问题', '审计报告数据不准确', '高', '处理中', '审计专家', NULL),
                                                                                                                                                               ('TK20240315012', '唐雅', '16612345678', '数据安全合规平台', '功能咨询', '如何导出合规报告', '低', '已完成', '客户成功', '2025-03-15 10:30:00');

-- 4.3 用户反馈表（10条）
INSERT INTO user_feedback (user_name, user_phone, feedback_type, feedback_content, rating, feedback_time, reply_content, reply_time) VALUES
                                                                                                                                         ('张明', '13812345678', '产品建议', '希望增加更多的数据源连接方式，比如MongoDB', 4, '2025-03-18 10:00:00', '感谢建议，已纳入产品规划', '2025-03-19 14:00:00'),
                                                                                                                                         ('李芳', '13987654321', 'Bug反馈', '报表导出功能在数据量大时会卡死', 3, '2025-03-17 14:30:00', '已定位问题，下个版本修复', '2025-03-18 09:00:00'),
                                                                                                                                         ('王磊', '15812345678', '表扬', '产品功能强大，技术支持响应及时', 5, '2025-03-16 09:00:00', '感谢您的认可，我们会继续努力', '2025-03-16 16:00:00'),
                                                                                                                                         ('赵静', '17712345678', '产品建议', '希望增加API接口，方便集成', 4, '2025-03-15 11:00:00', 'API文档已发布，欢迎使用', '2025-03-15 17:00:00'),
                                                                                                                                         ('陈强', '18612345678', '投诉', '售后服务响应太慢，工单两天没人处理', 2, '2025-03-14 16:00:00', '非常抱歉，已安排专人跟进', '2025-03-14 18:00:00'),
                                                                                                                                         ('刘娜', '15987654321', '咨询', '请问产品是否支持信创环境部署', 4, '2025-03-13 10:00:00', '支持，已适配麒麟、统信等国产系统', '2025-03-13 15:00:00'),
                                                                                                                                         ('周涛', '13512345678', '产品建议', '希望增加移动端APP', 3, '2025-03-12 14:00:00', '移动端已在开发中，预计Q3上线', '2025-03-12 16:00:00'),
                                                                                                                                         ('吴迪', '15212345678', '表扬', '培训课程很实用，讲师专业', 5, '2025-03-11 09:30:00', '感谢您的认可', '2025-03-11 14:00:00'),
                                                                                                                                         ('郑爽', '18712345678', 'Bug反馈', '权限配置保存后有时会丢失', 3, '2025-03-10 11:00:00', '已记录，正在排查', '2025-03-10 17:00:00'),
                                                                                                                                         ('林晨', '18812345678', '咨询', '是否提供定制化开发服务', 5, '2025-03-09 15:00:00', '提供，请联系销售团队获取报价', '2025-03-10 10:00:00');

-- =====================================================
-- 五、数据统计验证
-- =====================================================
SELECT '=== 新增表数据统计 ===' AS '';
SELECT 'passport_visa_info' AS table_name, COUNT(*) AS row_count FROM passport_visa_info
UNION ALL SELECT 'credit_report_info', COUNT(*) FROM credit_report_info
UNION ALL SELECT 'family_member_info', COUNT(*) FROM family_member_info
UNION ALL SELECT 'asset_info', COUNT(*) FROM asset_info
UNION ALL SELECT 'tax_info', COUNT(*) FROM tax_info
UNION ALL SELECT 'contacts_list', COUNT(*) FROM contacts_list
UNION ALL SELECT 'location_track', COUNT(*) FROM location_track
UNION ALL SELECT 'call_records', COUNT(*) FROM call_records
UNION ALL SELECT 'sms_records', COUNT(*) FROM sms_records
UNION ALL SELECT 'browser_history', COUNT(*) FROM browser_history
UNION ALL SELECT 'device_fingerprint', COUNT(*) FROM device_fingerprint
UNION ALL SELECT 'work_history', COUNT(*) FROM work_history
UNION ALL SELECT 'event_registration', COUNT(*) FROM event_registration
UNION ALL SELECT 'service_tickets', COUNT(*) FROM service_tickets
UNION ALL SELECT 'user_feedback', COUNT(*) FROM user_feedback;


-- =====================================================
-- 使用数据库
-- =====================================================
USE data_sec_demo;

-- =====================================================
-- 一、新增敏感信息表（10张）
-- =====================================================

-- 1.1 信用卡交易记录表（有索引）
CREATE TABLE IF NOT EXISTS credit_card_transactions (
                                                        id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键ID',
                                                        card_number VARCHAR(30) NOT NULL COMMENT '信用卡号',
                                                        card_holder VARCHAR(50) COMMENT '持卡人',
                                                        transaction_amount DECIMAL(12,2) COMMENT '交易金额',
                                                        transaction_time DATETIME COMMENT '交易时间',
                                                        merchant_name VARCHAR(200) COMMENT '商户名称',
                                                        merchant_category VARCHAR(50) COMMENT '商户类别',
                                                        transaction_type VARCHAR(20) COMMENT '交易类型:消费/预授权/退款',
                                                        currency VARCHAR(10) COMMENT '币种',
                                                        auth_code VARCHAR(20) COMMENT '授权码',
                                                        terminal_id VARCHAR(50) COMMENT '终端ID',
                                                        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
                                                        INDEX idx_card_number (card_number),
                                                        INDEX idx_transaction_time (transaction_time),
                                                        INDEX idx_auth_code (auth_code)
) COMMENT '信用卡交易记录表';

-- 1.2 会员积分明细表（有索引）
CREATE TABLE IF NOT EXISTS member_points_detail (
                                                    id BIGINT PRIMARY KEY AUTO_INCREMENT,
                                                    member_id VARCHAR(50) NOT NULL COMMENT '会员ID',
                                                    member_name VARCHAR(50) COMMENT '会员姓名',
                                                    phone VARCHAR(11) COMMENT '手机号',
                                                    points_change INT COMMENT '积分变动',
                                                    change_type VARCHAR(30) COMMENT '变动类型:消费获得/兑换/过期/调整',
                                                    before_points INT COMMENT '变动前积分',
                                                    after_points INT COMMENT '变动后积分',
                                                    source_order_no VARCHAR(32) COMMENT '来源订单号',
                                                    expire_date DATE COMMENT '过期日期',
                                                    operator VARCHAR(50) COMMENT '操作人',
                                                    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
                                                    INDEX idx_member_id (member_id),
                                                    INDEX idx_phone (phone),
                                                    INDEX idx_source_order (source_order_no)
) COMMENT '会员积分明细表';

-- 1.3 设备指纹信息表（有索引）
CREATE TABLE IF NOT EXISTS device_fingerprint (
                                                  id BIGINT PRIMARY KEY AUTO_INCREMENT,
                                                  device_id VARCHAR(100) NOT NULL COMMENT '设备ID',
                                                  user_id BIGINT COMMENT '用户ID',
                                                  device_type VARCHAR(30) COMMENT '设备类型:手机/电脑/平板',
                                                  os_type VARCHAR(50) COMMENT '操作系统',
                                                  os_version VARCHAR(50) COMMENT '系统版本',
                                                  browser_type VARCHAR(50) COMMENT '浏览器类型',
                                                  browser_version VARCHAR(50) COMMENT '浏览器版本',
                                                  screen_resolution VARCHAR(20) COMMENT '屏幕分辨率',
                                                  mac_address VARCHAR(50) COMMENT 'MAC地址',
                                                  imei VARCHAR(50) COMMENT 'IMEI号',
                                                  idfa VARCHAR(50) COMMENT 'IDFA(iOS)',
                                                  android_id VARCHAR(100) COMMENT 'Android ID',
                                                  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
                                                  INDEX idx_device_id (device_id),
                                                  INDEX idx_user_id (user_id),
                                                  INDEX idx_mac_address (mac_address)
) COMMENT '设备指纹信息表';

-- 1.4 通话记录明细表（有索引）
CREATE TABLE IF NOT EXISTS call_records (
                                            id BIGINT PRIMARY KEY AUTO_INCREMENT,
                                            caller_number VARCHAR(20) NOT NULL COMMENT '主叫号码',
                                            callee_number VARCHAR(20) NOT NULL COMMENT '被叫号码',
                                            call_duration INT COMMENT '通话时长(秒)',
                                            call_time DATETIME COMMENT '通话时间',
                                            call_type VARCHAR(20) COMMENT '通话类型:主叫/被叫/未接',
                                            imsi VARCHAR(30) COMMENT 'IMSI号',
                                            imei VARCHAR(30) COMMENT 'IMEI号',
                                            cell_tower_id VARCHAR(50) COMMENT '基站ID',
                                            location_area VARCHAR(100) COMMENT '位置区',
                                            roaming_status VARCHAR(20) COMMENT '漫游状态',
                                            created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
                                            INDEX idx_caller_number (caller_number),
                                            INDEX idx_callee_number (callee_number),
                                            INDEX idx_call_time (call_time)
) COMMENT '通话记录明细表';

-- 1.5 位置轨迹信息表（有索引）
CREATE TABLE IF NOT EXISTS location_trajectory (
                                                   id BIGINT PRIMARY KEY AUTO_INCREMENT,
                                                   user_id BIGINT NOT NULL COMMENT '用户ID',
                                                   user_name VARCHAR(50) COMMENT '用户姓名',
                                                   phone VARCHAR(11) COMMENT '手机号',
                                                   latitude DECIMAL(10,8) COMMENT '纬度',
                                                   longitude DECIMAL(11,8) COMMENT '经度',
                                                   location_time DATETIME COMMENT '定位时间',
                                                   location_type VARCHAR(30) COMMENT '定位类型:GPS/基站/WiFi',
                                                   accuracy INT COMMENT '精度(米)',
                                                   speed DECIMAL(8,2) COMMENT '速度(km/h)',
                                                   address VARCHAR(500) COMMENT '详细地址',
                                                   poi_name VARCHAR(200) COMMENT '兴趣点名称',
                                                   created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
                                                   INDEX idx_user_id (user_id),
                                                   INDEX idx_phone (phone),
                                                   INDEX idx_location_time (location_time)
) COMMENT '位置轨迹信息表';

-- 1.6 短信记录表（有索引）
CREATE TABLE IF NOT EXISTS sms_records (
                                           id BIGINT PRIMARY KEY AUTO_INCREMENT,
                                           sender_number VARCHAR(20) NOT NULL COMMENT '发送方号码',
                                           receiver_number VARCHAR(20) NOT NULL COMMENT '接收方号码',
                                           sms_content TEXT COMMENT '短信内容',
                                           sms_time DATETIME COMMENT '短信时间',
                                           sms_type VARCHAR(20) COMMENT '短信类型:发送/接收',
                                           sms_length INT COMMENT '短信长度',
                                           is_encrypted TINYINT DEFAULT 0 COMMENT '是否加密',
                                           imsi VARCHAR(30) COMMENT 'IMSI号',
                                           created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
                                           INDEX idx_sender (sender_number),
                                           INDEX idx_receiver (receiver_number),
                                           INDEX idx_sms_time (sms_time)
) COMMENT '短信记录表';

-- 1.7 亲属关系信息表（有索引）
CREATE TABLE IF NOT EXISTS family_relationship (
                                                   id BIGINT PRIMARY KEY AUTO_INCREMENT,
                                                   person_name VARCHAR(50) NOT NULL COMMENT '本人姓名',
                                                   person_id_card VARCHAR(18) COMMENT '本人身份证',
                                                   relative_name VARCHAR(50) COMMENT '亲属姓名',
                                                   relative_id_card VARCHAR(18) COMMENT '亲属身份证',
                                                   relationship VARCHAR(20) COMMENT '关系:配偶/子女/父母/兄弟姐妹',
                                                   relative_phone VARCHAR(11) COMMENT '亲属电话',
                                                   is_dependent TINYINT DEFAULT 0 COMMENT '是否被赡养/抚养',
                                                   created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
                                                   INDEX idx_person_id_card (person_id_card),
                                                   INDEX idx_relative_id_card (relative_id_card),
                                                   INDEX idx_person_name (person_name)
) COMMENT '亲属关系信息表';

-- 1.8 招聘简历信息表（有索引）
CREATE TABLE IF NOT EXISTS resume_info (
                                           id BIGINT PRIMARY KEY AUTO_INCREMENT,
                                           candidate_name VARCHAR(50) NOT NULL COMMENT '候选人姓名',
                                           id_card VARCHAR(18) COMMENT '身份证号',
                                           phone VARCHAR(11) COMMENT '手机号',
                                           email VARCHAR(100) COMMENT '邮箱',
                                           birth_date DATE COMMENT '出生日期',
                                           gender VARCHAR(10) COMMENT '性别',
                                           education VARCHAR(50) COMMENT '学历',
                                           work_experience TEXT COMMENT '工作经历',
                                           skills TEXT COMMENT '技能特长',
                                           expected_salary DECIMAL(10,2) COMMENT '期望薪资',
                                           current_company VARCHAR(200) COMMENT '当前公司',
                                           current_position VARCHAR(100) COMMENT '当前职位',
                                           resume_file_path VARCHAR(500) COMMENT '简历文件路径',
                                           created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
                                           INDEX idx_candidate_name (candidate_name),
                                           INDEX idx_id_card (id_card),
                                           INDEX idx_phone (phone)
) COMMENT '招聘简历信息表';

-- 1.9 考试分数表（有索引）
CREATE TABLE IF NOT EXISTS exam_scores (
                                           id BIGINT PRIMARY KEY AUTO_INCREMENT,
                                           examinee_name VARCHAR(50) NOT NULL COMMENT '考生姓名',
                                           id_card VARCHAR(18) COMMENT '身份证号',
                                           exam_name VARCHAR(200) COMMENT '考试名称',
                                           exam_time DATETIME COMMENT '考试时间',
                                           subject VARCHAR(100) COMMENT '科目',
                                           score DECIMAL(5,2) COMMENT '分数',
                                           total_score DECIMAL(5,2) COMMENT '总分',
                                           rank_position INT COMMENT '排名',
                                           exam_center VARCHAR(200) COMMENT '考点',
                                           admission_no VARCHAR(50) COMMENT '准考证号',
                                           created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
                                           INDEX idx_id_card (id_card),
                                           INDEX idx_admission_no (admission_no),
                                           INDEX idx_examinee_name (examinee_name)
) COMMENT '考试分数表';

-- 1.10 医疗费用明细表（无索引）
CREATE TABLE IF NOT EXISTS medical_expenses (
                                                id BIGINT PRIMARY KEY AUTO_INCREMENT,
                                                patient_name VARCHAR(50) NOT NULL COMMENT '患者姓名',
                                                id_card VARCHAR(18) COMMENT '身份证号',
                                                medical_no VARCHAR(50) COMMENT '病历号',
                                                expense_date DATE COMMENT '费用日期',
                                                expense_type VARCHAR(50) COMMENT '费用类型:挂号费/检查费/药费/手术费',
                                                expense_amount DECIMAL(10,2) COMMENT '费用金额',
                                                insurance_amount DECIMAL(10,2) COMMENT '医保报销金额',
                                                self_pay_amount DECIMAL(10,2) COMMENT '自付金额',
                                                hospital_name VARCHAR(200) COMMENT '医院名称',
                                                department VARCHAR(100) COMMENT '科室',
                                                doctor_name VARCHAR(50) COMMENT '医生姓名'
    -- 故意不建索引
) COMMENT '医疗费用明细表';

-- =====================================================
-- 二、新增业务表（5张）
-- =====================================================

-- 2.1 文章资讯表（有索引）
CREATE TABLE IF NOT EXISTS articles (
                                        id BIGINT PRIMARY KEY AUTO_INCREMENT,
                                        article_title VARCHAR(500) NOT NULL COMMENT '文章标题',
                                        article_author VARCHAR(100) COMMENT '作者',
                                        category VARCHAR(50) COMMENT '分类',
                                        tags VARCHAR(500) COMMENT '标签',
                                        view_count INT DEFAULT 0 COMMENT '浏览量',
                                        like_count INT DEFAULT 0 COMMENT '点赞数',
                                        comment_count INT DEFAULT 0 COMMENT '评论数',
                                        publish_time DATETIME COMMENT '发布时间',
                                        content LONGTEXT COMMENT '文章内容',
                                        status TINYINT DEFAULT 1 COMMENT '状态:0草稿1已发布',
                                        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
                                        INDEX idx_category (category),
                                        INDEX idx_publish_time (publish_time),
                                        INDEX idx_view_count (view_count)
) COMMENT '文章资讯表';

-- 2.2 活动报名表（有索引）
CREATE TABLE IF NOT EXISTS event_registration (
                                                  id BIGINT PRIMARY KEY AUTO_INCREMENT,
                                                  event_name VARCHAR(200) NOT NULL COMMENT '活动名称',
                                                  registrant_name VARCHAR(50) COMMENT '报名人姓名',
                                                  registrant_phone VARCHAR(11) COMMENT '报名人电话',
                                                  registrant_email VARCHAR(100) COMMENT '报名人邮箱',
                                                  company_name VARCHAR(200) COMMENT '公司名称',
                                                  job_title VARCHAR(100) COMMENT '职位',
                                                  registration_time DATETIME COMMENT '报名时间',
                                                  attend_status VARCHAR(20) COMMENT '出席状态:已报名/已签到/未出席',
                                                  source_channel VARCHAR(50) COMMENT '来源渠道',
                                                  remark VARCHAR(500) COMMENT '备注',
                                                  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
                                                  INDEX idx_event_name (event_name),
                                                  INDEX idx_registrant_phone (registrant_phone),
                                                  INDEX idx_registration_time (registration_time)
) COMMENT '活动报名表';

-- 2.3 设备维护记录表（有索引）
CREATE TABLE IF NOT EXISTS device_maintenance (
                                                  id BIGINT PRIMARY KEY AUTO_INCREMENT,
                                                  device_code VARCHAR(50) NOT NULL COMMENT '设备编码',
                                                  device_name VARCHAR(200) COMMENT '设备名称',
                                                  maintenance_date DATE COMMENT '维护日期',
                                                  maintenance_type VARCHAR(50) COMMENT '维护类型:日常/定期/故障',
                                                  maintenance_content TEXT COMMENT '维护内容',
                                                  maintenance_cost DECIMAL(10,2) COMMENT '维护费用',
                                                  technician VARCHAR(50) COMMENT '维修人员',
                                                  next_maintenance_date DATE COMMENT '下次维护日期',
                                                  status VARCHAR(20) COMMENT '状态:待维护/已完成/已延期',
                                                  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
                                                  INDEX idx_device_code (device_code),
                                                  INDEX idx_maintenance_date (maintenance_date),
                                                  INDEX idx_status (status)
) COMMENT '设备维护记录表';

-- 2.4 会议室预订表（无索引）
CREATE TABLE IF NOT EXISTS meeting_room_booking (
                                                    id BIGINT PRIMARY KEY AUTO_INCREMENT,
                                                    room_name VARCHAR(100) NOT NULL COMMENT '会议室名称',
                                                    booker_name VARCHAR(50) COMMENT '预订人',
                                                    booker_dept VARCHAR(100) COMMENT '预订部门',
                                                    meeting_topic VARCHAR(500) COMMENT '会议主题',
                                                    start_time DATETIME COMMENT '开始时间',
                                                    end_time DATETIME COMMENT '结束时间',
                                                    attendee_count INT COMMENT '参会人数',
                                                    is_approved TINYINT DEFAULT 0 COMMENT '是否审批通过'
    -- 故意不建索引
) COMMENT '会议室预订表';

-- 2.5 反馈建议表（无索引）
CREATE TABLE IF NOT EXISTS feedback_suggestions (
                                                    id BIGINT PRIMARY KEY AUTO_INCREMENT,
                                                    user_id BIGINT COMMENT '用户ID',
                                                    user_name VARCHAR(50) COMMENT '用户名',
                                                    feedback_type VARCHAR(30) COMMENT '反馈类型:建议/投诉/咨询',
                                                    feedback_content TEXT COMMENT '反馈内容',
                                                    contact_way VARCHAR(100) COMMENT '联系方式',
                                                    feedback_time DATETIME COMMENT '反馈时间',
                                                    reply_content TEXT COMMENT '回复内容',
                                                    reply_time DATETIME COMMENT '回复时间',
                                                    status VARCHAR(20) COMMENT '状态:待处理/处理中/已处理'
    -- 故意不建索引
) COMMENT '反馈建议表';

-- =====================================================
-- 三、插入模拟数据
-- =====================================================

-- 3.1 信用卡交易记录表（15条）
INSERT INTO credit_card_transactions (card_number, card_holder, transaction_amount, transaction_time, merchant_name, merchant_category, transaction_type, currency, auth_code, terminal_id) VALUES
                                                                                                                                                                                                ('4532123456789012', '张明', 12999.00, '2025-03-20 10:30:00', '京东商城', '电子产品', '消费', 'CNY', 'AUTH001234', 'T001'),
                                                                                                                                                                                                ('4532123456789012', '张明', 899.00, '2025-03-19 15:20:00', '星巴克', '餐饮', '消费', 'CNY', 'AUTH005678', 'T002'),
                                                                                                                                                                                                ('4532987654321098', '李芳', 3500.00, '2025-03-20 09:15:00', '携程旅行', '旅游', '消费', 'CNY', 'AUTH009012', 'T003'),
                                                                                                                                                                                                ('4532987654321098', '李芳', 128.00, '2025-03-18 18:30:00', '海底捞', '餐饮', '消费', 'CNY', 'AUTH013456', 'T004'),
                                                                                                                                                                                                ('4532567890123456', '王磊', 24999.00, '2025-03-19 11:00:00', '天猫', '电子产品', '预授权', 'CNY', 'AUTH017890', 'T005'),
                                                                                                                                                                                                ('4532567890123456', '王磊', 568.00, '2025-03-17 12:30:00', '盒马鲜生', '超市', '消费', 'CNY', 'AUTH021234', 'T006'),
                                                                                                                                                                                                ('4532789012345678', '赵静', 6800.00, '2025-03-18 14:00:00', '国航', '航空', '消费', 'CNY', 'AUTH025678', 'T007'),
                                                                                                                                                                                                ('4532789012345678', '赵静', 200.00, '2025-03-16 20:00:00', '美团外卖', '餐饮', '消费', 'CNY', 'AUTH029012', 'T008'),
                                                                                                                                                                                                ('4532901234567890', '陈强', 15800.00, '2025-03-17 09:30:00', '顺电', '家电', '分期', 'CNY', 'AUTH033456', 'T009'),
                                                                                                                                                                                                ('4532901234567890', '陈强', 450.00, '2025-03-15 16:45:00', '沃尔玛', '超市', '消费', 'CNY', 'AUTH037890', 'T010'),
                                                                                                                                                                                                ('4532123409876543', '刘娜', 3200.00, '2025-03-16 13:00:00', '滴滴出行', '交通', '消费', 'CNY', 'AUTH041234', 'T011'),
                                                                                                                                                                                                ('4532123409876543', '刘娜', 89.00, '2025-03-14 08:30:00', '肯德基', '餐饮', '消费', 'CNY', 'AUTH045678', 'T012'),
                                                                                                                                                                                                ('4532567812345670', '周涛', 22000.00, '2025-03-15 10:00:00', '苹果官网', '电子产品', '消费', 'CNY', 'AUTH049012', 'T013'),
                                                                                                                                                                                                ('4532567812345670', '周涛', 1500.00, '2025-03-13 19:30:00', '西贝莜面村', '餐饮', '消费', 'CNY', 'AUTH053456', 'T014'),
                                                                                                                                                                                                ('4532789098765432', '吴迪', 750.00, '2025-03-14 11:15:00', '屈臣氏', '日化', '消费', 'CNY', 'AUTH057890', 'T015');

-- 3.2 会员积分明细表（15条）
INSERT INTO member_points_detail (member_id, member_name, phone, points_change, change_type, before_points, after_points, source_order_no, expire_date, operator) VALUES
                                                                                                                                                                      ('VIP100001', '张明', '13812345678', 5000, '消费获得', 12000, 17000, 'ORD202503200001', '2025-12-31', '系统'),
                                                                                                                                                                      ('VIP100001', '张明', '13812345678', -2000, '兑换', 17000, 15000, 'EX20250320001', '2025-12-31', '用户'),
                                                                                                                                                                      ('VIP100002', '李芳', '13987654321', 3500, '消费获得', 8000, 11500, 'ORD202503200002', '2025-12-31', '系统'),
                                                                                                                                                                      ('VIP100003', '王磊', '15812345678', 8000, '消费获得', 15000, 23000, 'ORD202503190003', '2025-11-30', '系统'),
                                                                                                                                                                      ('VIP100003', '王磊', '15812345678', -3000, '兑换', 23000, 20000, 'EX20250319001', '2025-11-30', '用户'),
                                                                                                                                                                      ('VIP100004', '赵静', '17712345678', 2200, '消费获得', 5000, 7200, 'ORD202503190004', '2025-10-31', '系统'),
                                                                                                                                                                      ('VIP100005', '陈强', '18612345678', 6800, '消费获得', 10000, 16800, 'ORD202503180005', '2025-12-31', '系统'),
                                                                                                                                                                      ('VIP100006', '刘娜', '15987654321', -500, '过期', 3000, 2500, NULL, '2025-03-31', '系统'),
                                                                                                                                                                      ('VIP100007', '周涛', '13512345678', 12000, '消费获得', 20000, 32000, 'ORD202503170007', '2025-09-30', '系统'),
                                                                                                                                                                      ('VIP100007', '周涛', '13512345678', -5000, '兑换', 32000, 27000, 'EX20250317001', '2025-09-30', '用户'),
                                                                                                                                                                      ('VIP100008', '吴迪', '15212345678', 4500, '消费获得', 6000, 10500, 'ORD202503170008', '2025-08-31', '系统'),
                                                                                                                                                                      ('VIP100009', '郑爽', '18712345678', 2800, '消费获得', 7000, 9800, 'ORD202503160009', '2025-12-31', '系统'),
                                                                                                                                                                      ('VIP100010', '林晨', '18812345678', -800, '调整', 5000, 4200, 'ADJ20250316', '2025-12-31', '管理员'),
                                                                                                                                                                      ('VIP100011', '郭峰', '18912345678', 9000, '消费获得', 12000, 21000, 'ORD202503150011', '2025-11-30', '系统'),
                                                                                                                                                                      ('VIP100012', '唐雅', '16612345678', -1000, '过期', 4000, 3000, NULL, '2025-03-15', '系统');

-- 3.3 设备指纹信息表（12条）
INSERT INTO device_fingerprint (device_id, user_id, device_type, os_type, os_version, browser_type, browser_version, screen_resolution, mac_address, imei, idfa, android_id) VALUES
                                                                                                                                                                                 ('DEV_001_ABC123', 1, '手机', 'iOS', '17.2.1', 'Safari', '17.0', '1170x2532', 'AA:BB:CC:DD:EE:01', '123456789012345', 'FFFF-1111-AAAA-2222', NULL),
                                                                                                                                                                                 ('DEV_002_DEF456', 2, '电脑', 'Windows', '11 Pro', 'Chrome', '122.0', '1920x1080', 'AA:BB:CC:DD:EE:02', NULL, NULL, NULL),
                                                                                                                                                                                 ('DEV_003_GHI789', 3, '手机', 'Android', '14', 'Chrome', '121.0', '1080x2400', 'AA:BB:CC:DD:EE:03', '987654321098765', NULL, 'android_id_003_abc123'),
                                                                                                                                                                                 ('DEV_004_JKL012', 4, '平板', 'iPadOS', '17.2', 'Safari', '17.0', '1366x1024', 'AA:BB:CC:DD:EE:04', '555555555555555', 'GGGG-2222-BBBB-3333', NULL),
                                                                                                                                                                                 ('DEV_005_MNO345', 5, '电脑', 'macOS', '14.2', 'Safari', '17.0', '2560x1440', 'AA:BB:CC:DD:EE:05', NULL, NULL, NULL),
                                                                                                                                                                                 ('DEV_006_PQR678', 6, '手机', 'Android', '13', 'Firefox', '122.0', '1080x2340', 'AA:BB:CC:DD:EE:06', '111222333444555', NULL, 'android_id_006_def456'),
                                                                                                                                                                                 ('DEV_007_STU901', 7, '电脑', 'Windows', '10 Pro', 'Edge', '121.0', '1920x1080', 'AA:BB:CC:DD:EE:07', NULL, NULL, NULL),
                                                                                                                                                                                 ('DEV_008_VWX234', 8, '手机', 'iOS', '16.5', 'Safari', '16.0', '1125x2436', 'AA:BB:CC:DD:EE:08', '999888777666555', 'HHHH-3333-CCCC-4444', NULL),
                                                                                                                                                                                 ('DEV_009_YZ567', 9, '电脑', 'Linux', 'Ubuntu 22.04', 'Firefox', '121.0', '1920x1080', 'AA:BB:CC:DD:EE:09', NULL, NULL, NULL),
                                                                                                                                                                                 ('DEV_010_ABC890', 10, '手机', 'Android', '14', 'Chrome', '122.0', '1440x3040', 'AA:BB:CC:DD:EE:10', '444555666777888', NULL, 'android_id_010_ghi789'),
                                                                                                                                                                                 ('DEV_011_DEF123', 11, '平板', 'Android', '13', 'Edge', '121.0', '1600x2560', 'AA:BB:CC:DD:EE:11', '777888999000111', NULL, 'android_id_011_jkl012'),
                                                                                                                                                                                 ('DEV_012_GHI456', 12, '手机', 'iOS', '17.1', 'Chrome', '121.0', '1170x2532', 'AA:BB:CC:DD:EE:12', '333222111000999', 'IIII-4444-DDDD-5555', NULL);

-- 3.4 通话记录明细表（15条）
INSERT INTO call_records (caller_number, callee_number, call_duration, call_time, call_type, imsi, imei, cell_tower_id, location_area, roaming_status) VALUES
                                                                                                                                                           ('13812345678', '13987654321', 325, '2025-03-20 09:30:00', '主叫', '46001123456789', '123456789012345', 'CID_001_A', '朝阳区望京', '非漫游'),
                                                                                                                                                           ('13987654321', '13812345678', 180, '2025-03-19 14:20:00', '被叫', '46002987654321', '987654321098765', 'CID_002_B', '浦东新区', '非漫游'),
                                                                                                                                                           ('15812345678', '17712345678', 560, '2025-03-18 11:00:00', '主叫', '46003123456789', '555555555555555', 'CID_003_C', '南山区科技园', '非漫游'),
                                                                                                                                                           ('17712345678', '15812345678', 0, '2025-03-17 20:30:00', '未接', '46004321098765', '111222333444555', 'CID_004_D', '高新区', '非漫游'),
                                                                                                                                                           ('18612345678', '15987654321', 210, '2025-03-16 08:45:00', '主叫', '46005123456789', '999888777666555', 'CID_005_E', '西湖区', '非漫游'),
                                                                                                                                                           ('15987654321', '18612345678', 95, '2025-03-15 17:30:00', '被叫', '46006321098765', '444555666777888', 'CID_006_F', '思明区', '非漫游'),
                                                                                                                                                           ('13512345678', '15212345678', 780, '2025-03-14 10:15:00', '主叫', '46007123456789', '777888999000111', 'CID_007_G', '和平区', '非漫游'),
                                                                                                                                                           ('15212345678', '13512345678', 320, '2025-03-13 15:40:00', '被叫', '46008321098765', '333222111000999', 'CID_008_H', '岳麓区', '非漫游'),
                                                                                                                                                           ('18712345678', '18812345678', 125, '2025-03-12 09:00:00', '主叫', '46009123456789', '666555444333222', 'CID_009_I', '中山区', '非漫游'),
                                                                                                                                                           ('18812345678', '18712345678', 90, '2025-03-11 13:25:00', '被叫', '46010321098765', '222333444555666', 'CID_010_J', '市南区', '非漫游'),
                                                                                                                                                           ('18912345678', '16612345678', 450, '2025-03-10 11:50:00', '主叫', '46011123456789', '888999000111222', 'CID_011_K', '渝中区', '漫游'),
                                                                                                                                                           ('16612345678', '18912345678', 200, '2025-03-09 16:10:00', '被叫', '46012321098765', '111222333444555', 'CID_012_L', '鄞州区', '非漫游'),
                                                                                                                                                           ('17723456789', '18834567890', 35, '2025-03-08 19:45:00', '未接', '46013123456789', '444555666777888', 'CID_013_M', '鼓楼区', '非漫游'),
                                                                                                                                                           ('18834567890', '17723456789', 150, '2025-03-07 12:20:00', '被叫', '46014321098765', '777888999000111', 'CID_014_N', '武昌区', '非漫游'),
                                                                                                                                                           ('19945678901', '13812345678', 280, '2025-03-06 08:00:00', '主叫', '46015123456789', '999000111222333', 'CID_015_O', '金水区', '非漫游');

-- 3.5 位置轨迹信息表（15条）
INSERT INTO location_trajectory (user_id, user_name, phone, latitude, longitude, location_time, location_type, accuracy, speed, address, poi_name) VALUES
                                                                                                                                                       (1, '张明', '13812345678', 39.995120, 116.480820, '2025-03-20 09:00:00', 'GPS', 10, 0.00, '北京市朝阳区望京SOHO', '望京SOHO T3'),
                                                                                                                                                       (1, '张明', '13812345678', 39.995500, 116.481200, '2025-03-20 12:30:00', 'GPS', 15, 0.00, '北京市朝阳区望京街10号', '凯德MALL'),
                                                                                                                                                       (2, '李芳', '13987654321', 31.235120, 121.543820, '2025-03-20 10:00:00', 'GPS', 8, 0.00, '上海市浦东新区世纪大道100号', '上海环球金融中心'),
                                                                                                                                                       (2, '李芳', '13987654321', 31.238500, 121.550200, '2025-03-20 18:30:00', '基站', 100, 0.00, '上海市浦东新区陆家嘴环路', '国金中心商场'),
                                                                                                                                                       (3, '王磊', '15812345678', 22.543210, 114.065430, '2025-03-19 14:00:00', 'GPS', 12, 5.20, '深圳市南山区科技中一路', '腾讯大厦'),
                                                                                                                                                       (3, '王磊', '15812345678', 22.548900, 114.062500, '2025-03-19 17:00:00', 'GPS', 10, 0.00, '深圳市南山区深南大道10000号', '深圳湾万象城'),
                                                                                                                                                       (4, '赵静', '17712345678', 30.572500, 104.066800, '2025-03-18 11:30:00', 'GPS', 20, 0.00, '成都市高新区天府大道北段', '金融城'),
                                                                                                                                                       (5, '陈强', '18612345678', 30.287200, 120.152800, '2025-03-17 09:30:00', 'GPS', 15, 0.00, '杭州市西湖区学院路77号', '黄龙万科中心'),
                                                                                                                                                       (6, '刘娜', '15987654321', 24.482500, 118.089800, '2025-03-16 15:00:00', '基站', 80, 0.00, '厦门市思明区环岛东路', '会展中心'),
                                                                                                                                                       (7, '周涛', '13512345678', 39.135800, 117.205600, '2025-03-15 10:30:00', 'GPS', 10, 0.00, '天津市和平区南京路', '天津国际金融中心'),
                                                                                                                                                       (8, '吴迪', '15212345678', 28.228200, 112.938800, '2025-03-14 13:00:00', 'GPS', 18, 0.00, '长沙市岳麓区麓谷大道', '麓谷信息港'),
                                                                                                                                                       (9, '郑爽', '18712345678', 38.914500, 121.617800, '2025-03-13 09:00:00', '基站', 120, 0.00, '大连市中山区人民路', '时代广场'),
                                                                                                                                                       (10, '林晨', '18812345678', 36.066500, 120.382600, '2025-03-12 14:30:00', 'GPS', 12, 0.00, '青岛市市南区香港中路', '五四广场'),
                                                                                                                                                       (11, '郭峰', '18912345678', 29.564200, 106.558900, '2025-03-11 11:00:00', 'GPS', 15, 0.00, '重庆市渝中区解放碑', '解放碑步行街'),
                                                                                                                                                       (12, '唐雅', '16612345678', 29.876500, 121.548900, '2025-03-10 16:00:00', '基站', 90, 0.00, '宁波市鄞州区宁穿路', '宁波文化广场');

-- 3.6 短信记录表（15条）
INSERT INTO sms_records (sender_number, receiver_number, sms_content, sms_time, sms_type, sms_length, is_encrypted, imsi) VALUES
                                                                                                                              ('10086', '13812345678', '尊敬的客户，您本月话费共计128.50元，请及时缴费。', '2025-03-20 08:00:00', '接收', 45, 0, '46001123456789'),
                                                                                                                              ('13812345678', '13987654321', '晚上一起吃饭吗？7点老地方见。', '2025-03-19 17:30:00', '发送', 28, 0, '46001123456789'),
                                                                                                                              ('95588', '13987654321', '您尾号1234的信用卡消费12999元，余额85000元。', '2025-03-20 10:35:00', '接收', 42, 0, '46002987654321'),
                                                                                                                              ('15812345678', '17712345678', '订单已发货，物流单号SF1234567890，请注意查收。', '2025-03-18 14:20:00', '发送', 48, 0, '46003123456789'),
                                                                                                                              ('95188', '15812345678', '您的支付宝账户于03月19日支付89.50元，如非本人操作请点击...', '2025-03-19 12:05:00', '接收', 65, 0, '46003123456789'),
                                                                                                                              ('18612345678', '15987654321', '项目方案已发邮箱，请查收并审核。', '2025-03-17 10:15:00', '发送', 32, 0, '46005123456789'),
                                                                                                                              ('95555', '18612345678', '您账户于03月18日收到转账3500.00元，余额12500.00元。', '2025-03-18 15:30:00', '接收', 52, 0, '46005123456789'),
                                                                                                                              ('13512345678', '15212345678', '密码已重置，新密码为Abc123456，请登录后修改。', '2025-03-16 09:00:00', '发送', 44, 1, '46007123456789'),
                                                                                                                              ('10690999', '13512345678', '验证码：382947，您正在登录账号，5分钟内有效。', '2025-03-15 11:25:00', '接收', 38, 0, '46007123456789'),
                                                                                                                              ('15212345678', '13512345678', '好的，收到，明天见。', '2025-03-14 18:45:00', '发送', 15, 0, '46008321098765'),
                                                                                                                              ('10010', '18712345678', '尊敬的用户，您本月流量已使用80%，剩余2GB。', '2025-03-13 08:30:00', '接收', 42, 0, '46009123456789'),
                                                                                                                              ('18712345678', '18812345678', '会议时间改为下午3点，会议室302。', '2025-03-12 09:15:00', '发送', 24, 0, '46009123456789'),
                                                                                                                              ('18812345678', '18712345678', '收到，准时参加。', '2025-03-12 09:20:00', '发送', 12, 0, '46010321098765'),
                                                                                                                              ('95566', '18912345678', '您尾号6789的信用卡账单已出，应还款15800元，最后还款日04月10日。', '2025-03-11 07:00:00', '接收', 58, 0, '46011123456789'),
                                                                                                                              ('10655000', '16612345678', '【京东】您购买的商品已送达，请凭取件码123456取件。', '2025-03-10 14:30:00', '接收', 48, 0, '46012321098765');

-- 3.7 亲属关系信息表（12条）
INSERT INTO family_relationship (person_name, person_id_card, relative_name, relative_id_card, relationship, relative_phone, is_dependent) VALUES
                                                                                                                                               ('张明', '11010119900307663X', '李芳', '310101198805124567', '配偶', '13987654321', 0),
                                                                                                                                               ('张明', '11010119900307663X', '张建国', '110101196503151234', '父亲', '13512345678', 1),
                                                                                                                                               ('张明', '11010119900307663X', '王秀英', '110101196808202345', '母亲', '13612345678', 1),
                                                                                                                                               ('王磊', '440301199210235678', '王强', '440301197005103456', '父亲', '13712345678', 0),
                                                                                                                                               ('王磊', '440301199210235678', '刘敏', '440301197212154567', '母亲', '13812345678', 0),
                                                                                                                                               ('赵静', '51010719870714789X', '赵志远', '510107196003205678', '父亲', '13912345678', 1),
                                                                                                                                               ('陈强', '320105199103156789', '陈晓', '320105201505016789', '子女', '18012345678', 1),
                                                                                                                                               ('周涛', '120101198608128765', '周华健', '120101196212128901', '父亲', '15012345678', 1),
                                                                                                                                               ('周涛', '120101198608128765', '林凤娇', '120101196503239012', '母亲', '15112345678', 1),
                                                                                                                                               ('郑爽', '210203199403211234', '郑成功', '210203196805151234', '父亲', '15212345678', 0),
                                                                                                                                               ('林晨', '370202199707153456', '林青霞', '370202196808203456', '母亲', '15312345678', 0),
                                                                                                                                               ('郭峰', '500101198809194567', '郭靖', '500101196312204567', '父亲', '15512345678', 1);

-- 3.8 招聘简历信息表（12条）
INSERT INTO resume_info (candidate_name, id_card, phone, email, birth_date, gender, education, work_experience, skills, expected_salary, current_company, current_position, resume_file_path) VALUES
                                                                                                                                                                                                  ('王建国', '110101199203156789', '13812345601', 'wangjg@example.com', '1992-03-15', '男', '硕士', '5年数据安全经验，负责过3个大型安全项目', '数据安全、风险评估、合规审计', 35000.00, '华为技术有限公司', '安全工程师', '/resumes/wangjg_202503.pdf'),
                                                                                                                                                                                                  ('刘丽', '310101199512201234', '13987654002', 'liuli@example.com', '1995-12-20', '女', '本科', '3年大数据开发经验，熟悉Hadoop/Spark', 'Python、Java、大数据处理', 25000.00, '阿里巴巴', '数据开发工程师', '/resumes/liuli_202503.pdf'),
                                                                                                                                                                                                  ('陈晨', '440301199408017890', '15812345603', 'chenchen@example.com', '1994-08-01', '男', '博士', '2年AI算法研究，发表3篇顶会论文', '机器学习、深度学习、计算机视觉', 45000.00, '商汤科技', '算法工程师', '/resumes/chenchen_202503.pdf'),
                                                                                                                                                                                                  ('赵敏', '510107199610104567', '17712345604', 'zhaomin@example.com', '1996-10-10', '女', '硕士', '4年网络安全经验，持有CISP证书', '渗透测试、安全运维、应急响应', 30000.00, '奇安信', '安全分析师', '/resumes/zhaomin_202503.pdf'),
                                                                                                                                                                                                  ('孙阳', '320105199311155678', '18612345605', 'sunyang@example.com', '1993-11-15', '男', '本科', '6年Java开发经验，架构设计能力强', 'Spring Cloud、微服务、分布式', 40000.00, '美团', '技术专家', '/resumes/sunyang_202503.pdf'),
                                                                                                                                                                                                  ('李华', '350203199812202345', '15912345606', 'lihua@example.com', '1998-12-20', '女', '本科', '2年产品经验，独立负责过2个产品线', '需求分析、产品设计、项目管理', 20000.00, '字节跳动', '产品经理', '/resumes/lihua_202503.pdf'),
                                                                                                                                                                                                  ('周杰', '120101199407075678', '13512345607', 'zhoujie@example.com', '1994-07-07', '男', '硕士', '5年数据库管理经验，熟悉MySQL/Oracle', '数据库优化、数据备份、高可用架构', 32000.00, '京东', 'DBA工程师', '/resumes/zhoujie_202503.pdf'),
                                                                                                                                                                                                  ('吴越', '430103199509098901', '15212345608', 'wuyue@example.com', '1995-09-09', '男', '本科', '4年云计算经验，持有AWS认证', 'AWS、K8s、Docker、自动化运维', 28000.00, '腾讯云', '运维工程师', '/resumes/wuyue_202503.pdf'),
                                                                                                                                                                                                  ('郑爽', '210203199601011234', '18712345609', 'zhengshuang@example.com', '1996-01-01', '女', '硕士', '3年数据分析经验，熟练使用SQL/Python', '数据分析、数据可视化、报表开发', 22000.00, '百度', '数据分析师', '/resumes/zhengshuang_202503.pdf'),
                                                                                                                                                                                                  ('林峰', '370202199703034567', '18812345610', 'linfeng@example.com', '1997-03-03', '男', '本科', '2年前端开发经验，React技术栈', 'React、Vue、小程序开发', 18000.00, '滴滴', '前端工程师', '/resumes/linfeng_202503.pdf'),
                                                                                                                                                                                                  ('郭靖', '500101199804046789', '18912345611', 'guojing@example.com', '1998-04-04', '男', '硕士', '1年区块链开发经验', 'Solidity、智能合约、Web3', 30000.00, '蚂蚁集团', '区块链工程师', '/resumes/guojing_202503.pdf'),
                                                                                                                                                                                                  ('杨康', '330105199905058901', '16612345612', 'yangkang@example.com', '1999-05-05', '男', '本科', '1年测试经验，自动化测试方向', '自动化测试、性能测试、测试开发', 15000.00, '网易', '测试工程师', '/resumes/yangkang_202503.pdf');

-- 3.9 考试分数表（15条）
INSERT INTO exam_scores (examinee_name, id_card, exam_name, exam_time, subject, score, total_score, rank_position, exam_center, admission_no) VALUES
                                                                                                                                                  ('张明', '11010119900307663X', '全国计算机等级考试', '2024-09-15 09:00:00', '三级数据库技术', 85.00, 100.00, 12, '北京朝阳考点', '202409150001'),
                                                                                                                                                  ('李芳', '310101198805124567', '大学英语六级', '2024-12-14 15:00:00', '英语', 568.00, 710.00, 45, '上海浦东考点', '202412140002'),
                                                                                                                                                  ('王磊', '440301199210235678', '全国计算机等级考试', '2024-09-15 09:00:00', '四级信息安全', 72.00, 100.00, 35, '深圳南山考点', '202409150003'),
                                                                                                                                                  ('赵静', '51010719870714789X', '教师资格证考试', '2024-10-30 09:00:00', '高中信息技术', 88.00, 100.00, 8, '成都高新考点', '202410300004'),
                                                                                                                                                  ('陈强', '320105199103156789', 'PMP认证考试', '2024-11-20 09:00:00', '项目管理', 175.00, 200.00, 20, '杭州西湖考点', '202411200005'),
                                                                                                                                                  ('刘娜', '350203199512019876', '注册会计师考试', '2024-08-25 08:30:00', '会计', 72.50, 100.00, 150, '厦门思明考点', '202408250006'),
                                                                                                                                                  ('周涛', '120101198608128765', '雅思考试', '2024-10-10 09:00:00', '听力', 7.50, 9.00, NULL, '天津和平考点', '202410100007'),
                                                                                                                                                  ('吴迪', '430103199311234321', '雅思考试', '2024-10-10 09:00:00', '阅读', 6.50, 9.00, NULL, '长沙岳麓考点', '202410100008'),
                                                                                                                                                  ('郑爽', '210203199403211234', '研究生入学考试', '2024-12-21 08:30:00', '英语一', 78.00, 100.00, 50, '大连中山考点', '202412210009'),
                                                                                                                                                  ('林晨', '370202199707153456', '研究生入学考试', '2024-12-21 08:30:00', '数学一', 125.00, 150.00, 30, '青岛市南考点', '202412210010'),
                                                                                                                                                  ('郭峰', '500101198809194567', '软考高级', '2024-11-09 09:00:00', '信息系统项目管理师', 52.00, 75.00, 25, '重庆渝中考点', '202411090011'),
                                                                                                                                                  ('唐雅', '330105199410285678', '全国计算机等级考试', '2025-03-22 09:00:00', '二级Python', 92.00, 100.00, 5, '宁波鄞州考点', '202503220012'),
                                                                                                                                                  ('孙浩', '440304199612316789', '大学英语四级', '2024-12-14 09:00:00', '英语', 512.00, 710.00, 280, '广州天河考点', '202412140013'),
                                                                                                                                                  ('许晴', '350582199811118901', '教师资格证考试', '2025-03-08 09:00:00', '小学语文', 82.00, 100.00, 60, '泉州晋江考点', '202503080014'),
                                                                                                                                                  ('韩雪', '410105200001012345', 'PMP认证考试', '2025-03-15 09:00:00', '项目管理', 168.00, 200.00, 35, '郑州金水考点', '202503150015');

-- 3.10 医疗费用明细表（15条）
INSERT INTO medical_expenses (patient_name, id_card, medical_no, expense_date, expense_type, expense_amount, insurance_amount, self_pay_amount, hospital_name, department, doctor_name) VALUES
                                                                                                                                                                                            ('张明', '11010119900307663X', 'MR202400001', '2024-03-10', '挂号费', 50.00, 0.00, 50.00, '北京协和医院', '心内科', '王建国'),
                                                                                                                                                                                            ('张明', '11010119900307663X', 'MR202400001', '2024-03-10', '检查费', 850.00, 680.00, 170.00, '北京协和医院', '心内科', '王建国'),
                                                                                                                                                                                            ('张明', '11010119900307663X', 'MR202400001', '2024-03-10', '药费', 320.00, 256.00, 64.00, '北京协和医院', '心内科', '王建国'),
                                                                                                                                                                                            ('李芳', '310101198805124567', 'MR202400002', '2024-02-15', '挂号费', 50.00, 0.00, 50.00, '上海瑞金医院', '内分泌科', '张丽华'),
                                                                                                                                                                                            ('李芳', '310101198805124567', 'MR202400002', '2024-02-15', '检查费', 450.00, 360.00, 90.00, '上海瑞金医院', '内分泌科', '张丽华'),
                                                                                                                                                                                            ('李芳', '310101198805124567', 'MR202400002', '2024-02-15', '药费', 280.00, 224.00, 56.00, '上海瑞金医院', '内分泌科', '张丽华'),
                                                                                                                                                                                            ('王磊', '440301199210235678', 'MR202400003', '2024-03-05', '手术费', 8500.00, 5950.00, 2550.00, '深圳市人民医院', '普外科', '刘志强'),
                                                                                                                                                                                            ('王磊', '440301199210235678', 'MR202400003', '2024-03-05', '住院费', 3200.00, 2240.00, 960.00, '深圳市人民医院', '普外科', '刘志强'),
                                                                                                                                                                                            ('赵静', '51010719870714789X', 'MR202400004', '2024-01-20', '检查费', 680.00, 544.00, 136.00, '华西医院', '内分泌科', '陈敏'),
                                                                                                                                                                                            ('陈强', '320105199103156789', 'MR202400005', '2024-02-01', '治疗费', 1200.00, 960.00, 240.00, '江苏省人民医院', '康复科', '李明'),
                                                                                                                                                                                            ('陈强', '320105199103156789', 'MR202400005', '2024-02-01', '药费', 450.00, 360.00, 90.00, '江苏省人民医院', '康复科', '李明'),
                                                                                                                                                                                            ('刘娜', '350203199512019876', 'MR202400006', '2024-03-15', '药费', 380.00, 304.00, 76.00, '厦门大学附属第一医院', '呼吸科', '黄伟'),
                                                                                                                                                                                            ('周涛', '120101198608128765', 'MR202400007', '2024-02-20', '检查费', 1200.00, 960.00, 240.00, '天津医科大学总医院', '心内科', '孙华'),
                                                                                                                                                                                            ('周涛', '120101198608128765', 'MR202400007', '2024-02-20', '药费', 680.00, 544.00, 136.00, '天津医科大学总医院', '心内科', '孙华'),
                                                                                                                                                                                            ('吴迪', '430103199311234321', 'MR202400008', '2024-01-10', '手术费', 6800.00, 4760.00, 2040.00, '中南大学湘雅医院', '普外科', '周敏');

-- =====================================================
-- 四、业务表数据
-- =====================================================

-- 4.1 文章资讯表（15条）
INSERT INTO articles (article_title, article_author, category, tags, view_count, like_count, comment_count, publish_time, content, status) VALUES
                                                                                                                                               ('数据安全法实施一周年回顾', '张安全', '行业资讯', '数据安全,法律法规', 12580, 568, 89, '2025-03-15 09:00:00', '数据安全法实施一年来，各行业数据安全建设取得显著进展...', 1),
                                                                                                                                               ('AI在数据分类分级中的应用实践', '李智能', '技术前沿', '人工智能,数据分类', 8560, 432, 56, '2025-03-14 10:30:00', '本文介绍了利用AI技术自动识别和分类敏感数据的方法...', 1),
                                                                                                                                               ('企业数据安全建设指南', '王顾问', '最佳实践', '数据安全,企业建设', 23450, 1289, 234, '2025-03-12 08:00:00', '从组织、制度、技术三个维度全面解析数据安全建设...', 1),
                                                                                                                                               ('2025年数据安全趋势预测', '赵分析师', '行业报告', '趋势预测,数据安全', 6780, 345, 67, '2025-03-10 14:00:00', '预测未来一年数据安全领域的重要发展趋势和技术方向...', 1),
                                                                                                                                               ('零信任架构在数据安全中的应用', '陈架构师', '技术架构', '零信任,数据安全', 9870, 567, 123, '2025-03-08 11:00:00', '零信任架构如何保护企业数据资产，案例分析...', 1),
                                                                                                                                               ('数据脱敏技术详解', '刘工程师', '技术专题', '数据脱敏,隐私保护', 5430, 289, 45, '2025-03-05 16:30:00', '静态脱敏和动态脱敏的技术原理和实现方案...', 1),
                                                                                                                                               ('GDPR与中国数据安全法对比', '周律师', '法律解读', 'GDPR,数据安全法', 4560, 234, 78, '2025-03-01 09:30:00', '欧盟GDPR与中国数据安全法的主要差异和合规要点...', 1),
                                                                                                                                               ('如何选择数据安全产品', '吴产品', '产品选型', '数据安全产品,选型指南', 12340, 789, 156, '2025-02-25 10:00:00', '从功能、性能、易用性、成本等角度分析选型要点...', 1),
                                                                                                                                               ('数据安全人才培养之道', '郑HR', '人才培养', '人才培养,数据安全', 3450, 178, 34, '2025-02-20 14:30:00', '数据安全人才的市场需求和培养路径建议...', 1),
                                                                                                                                               ('云环境下的数据安全挑战', '林云', '云计算', '云安全,数据保护', 7890, 456, 89, '2025-02-15 09:00:00', '企业上云后数据安全面临的新挑战和应对策略...', 1),
                                                                                                                                               ('数据安全应急响应体系建设', '郭应急', '应急响应', '应急响应,安全管理', 5670, 312, 67, '2025-02-10 11:00:00', '如何建立高效的数据安全应急响应机制...', 1),
                                                                                                                                               ('数据安全审计要点解析', '唐审计', '审计合规', '安全审计,合规检查', 4320, 234, 45, '2025-02-05 15:00:00', '数据安全审计的重点内容和方法论...', 1),
                                                                                                                                               ('区块链在数据安全中的应用', '孙链', '区块链', '区块链,数据安全', 6540, 389, 78, '2025-01-28 10:30:00', '利用区块链技术实现数据防篡改和可追溯...', 1),
                                                                                                                                               ('数据安全与隐私计算', '许隐私', '技术前沿', '隐私计算,联邦学习', 5430, 298, 56, '2025-01-20 14:00:00', '隐私计算技术在数据安全领域的应用前景...', 1),
                                                                                                                                               ('中小企业数据安全实践', '韩中小', '实践案例', '中小企业,实践案例', 8760, 567, 123, '2025-01-15 09:30:00', '中小企业如何在有限预算下做好数据安全...', 1);

-- 4.2 活动报名表（15条）
INSERT INTO event_registration (event_name, registrant_name, registrant_phone, registrant_email, company_name, job_title, registration_time, attend_status, source_channel, remark) VALUES
                                                                                                                                                                                        ('数据安全峰会2025', '张明', '13812345678', 'zhangming@example.com', '云创科技', '技术总监', '2025-03-01 10:00:00', '已签到', '官网', 'VIP嘉宾'),
                                                                                                                                                                                        ('数据安全峰会2025', '李芳', '13987654321', 'lifang@example.com', '海纳数据', '安全总监', '2025-03-02 14:30:00', '已签到', '邮件邀请', NULL),
                                                                                                                                                                                        ('数据安全峰会2025', '王磊', '15812345678', 'wanglei@example.com', '智联信息', '架构师', '2025-03-05 09:15:00', '已报名', '合作伙伴', NULL),
                                                                                                                                                                                        ('AI安全技术沙龙', '赵静', '17712345678', 'zhaojing@example.com', '星辰云', '算法工程师', '2025-03-10 11:00:00', '已签到', '公众号', '现场提问'),
                                                                                                                                                                                        ('AI安全技术沙龙', '陈强', '18612345678', 'chenqiang@example.com', '安恒安全', '安全专家', '2025-03-10 14:00:00', '已签到', '邀请制', NULL),
                                                                                                                                                                                        ('数据治理培训营', '刘娜', '15987654321', 'liuna@example.com', '致远软件', '数据治理专员', '2025-02-20 09:30:00', '已签到', '官网', '团报3人'),
                                                                                                                                                                                        ('数据治理培训营', '周涛', '13512345678', 'zhoutao@example.com', '磐石区块链', '数据工程师', '2025-02-20 09:30:00', '已签到', '官网', '团报3人'),
                                                                                                                                                                                        ('数据治理培训营', '吴迪', '15212345678', 'wudi@example.com', '天璇AI', '数据工程师', '2025-02-20 09:30:00', '已签到', '官网', '团报3人'),
                                                                                                                                                                                        ('信息安全认证培训班', '郑爽', '18712345678', 'zhengshuang@example.com', '昆仑金融', '安全运维', '2025-02-15 10:00:00', '已签到', '邮件', '已缴费'),
                                                                                                                                                                                        ('信息安全认证培训班', '林晨', '18812345678', 'linchen@example.com', '华盾安全', '安全分析师', '2025-02-16 11:30:00', '未出席', '官网', '未到场'),
                                                                                                                                                                                        ('云安全技术大会', '郭峰', '18912345678', 'guofeng@example.com', '云创科技', '云架构师', '2025-01-20 09:00:00', '已签到', '邀请制', '演讲嘉宾'),
                                                                                                                                                                                        ('云安全技术大会', '唐雅', '16612345678', 'tangya@example.com', '海纳数据', '安全顾问', '2025-01-21 14:00:00', '已签到', '官网', NULL),
                                                                                                                                                                                        ('数据隐私保护研讨会', '孙浩', '17723456789', 'sunhao@example.com', '智联信息', '合规专员', '2025-01-10 10:30:00', '已签到', '公众号', NULL),
                                                                                                                                                                                        ('数据隐私保护研讨会', '许晴', '18834567890', 'xuqing@example.com', '星辰云', '隐私保护工程师', '2025-01-10 10:30:00', '已签到', '官网', NULL),
                                                                                                                                                                                        ('网络安全攻防演练', '韩雪', '19945678901', 'hanxue@example.com', '安恒安全', '安全研究员', '2024-12-15 09:00:00', '已签到', '邀请制', '红队成员');

-- 4.3 设备维护记录表（12条）
INSERT INTO device_maintenance (device_code, device_name, maintenance_date, maintenance_type, maintenance_content, maintenance_cost, technician, next_maintenance_date, status) VALUES
                                                                                                                                                                                    ('SRV-DB-001', '数据库服务器-主', '2025-03-15', '定期', '系统检查、日志清理、磁盘扩容', 1500.00, '张工', '2025-06-15', '已完成'),
                                                                                                                                                                                    ('SRV-DB-002', '数据库服务器-备', '2025-03-15', '定期', '系统检查、数据同步验证', 1200.00, '张工', '2025-06-15', '已完成'),
                                                                                                                                                                                    ('SW-001', '核心交换机', '2025-03-10', '日常', '固件升级、配置备份', 800.00, '李工', '2025-04-10', '已完成'),
                                                                                                                                                                                    ('FW-001', '防火墙设备', '2025-03-05', '故障', '策略优化、修复安全漏洞', 2000.00, '王工', '2025-06-05', '已完成'),
                                                                                                                                                                                    ('STO-001', '存储阵列', '2025-02-28', '定期', '硬盘健康检查、坏道修复', 1800.00, '赵工', '2025-05-28', '已完成'),
                                                                                                                                                                                    ('SRV-WEB-001', 'Web服务器', '2025-02-20', '日常', '软件更新、性能优化', 1000.00, '陈工', '2025-03-20', '已完成'),
                                                                                                                                                                                    ('SRV-WEB-002', '应用服务器', '2025-02-15', '故障', '内存更换、系统重装', 2500.00, '刘工', '2025-05-15', '已完成'),
                                                                                                                                                                                    ('UPS-001', 'UPS电源', '2025-02-10', '定期', '电池检测、负载测试', 600.00, '周工', '2025-08-10', '已完成'),
                                                                                                                                                                                    ('AC-001', '精密空调', '2025-02-05', '定期', '滤网清洗、制冷剂补充', 900.00, '吴工', '2025-05-05', '已完成'),
                                                                                                                                                                                    ('SRV-BACKUP-001', '备份服务器', '2025-01-25', '日常', '备份策略调整、空间清理', 800.00, '郑工', '2025-04-25', '已完成'),
                                                                                                                                                                                    ('FW-002', '入侵检测设备', '2025-01-20', '故障', '规则库更新、系统修复', 1500.00, '林工', '2025-04-20', '待维护'),
                                                                                                                                                                                    ('SRV-MON-001', '监控服务器', '2025-01-15', '定期', '系统升级、存储扩容', 1200.00, '郭工', '2025-04-15', '已完成');

-- 4.4 会议室预订表（12条）
INSERT INTO meeting_room_booking (room_name, booker_name, booker_dept, meeting_topic, start_time, end_time, attendee_count, is_approved) VALUES
                                                                                                                                             ('会议室A-101', '张明', '技术部', '数据安全项目周会', '2025-03-20 09:00:00', '2025-03-20 10:30:00', 15, 1),
                                                                                                                                             ('会议室A-102', '李芳', '产品部', '产品需求评审会', '2025-03-20 14:00:00', '2025-03-20 16:00:00', 12, 1),
                                                                                                                                             ('会议室B-201', '王磊', '架构组', '系统架构设计评审', '2025-03-19 10:00:00', '2025-03-19 12:00:00', 8, 1),
                                                                                                                                             ('会议室B-202', '赵静', '研发部', '代码审查会', '2025-03-19 15:00:00', '2025-03-19 17:00:00', 10, 1),
                                                                                                                                             ('会议室A-101', '陈强', '安全部', '安全应急演练复盘', '2025-03-18 09:30:00', '2025-03-18 11:30:00', 6, 1),
                                                                                                                                             ('会议室A-102', '刘娜', '市场部', '市场推广方案讨论', '2025-03-18 14:00:00', '2025-03-18 16:30:00', 20, 1),
                                                                                                                                             ('会议室C-301', '周涛', '运维部', '服务器维护计划会', '2025-03-17 10:00:00', '2025-03-17 11:00:00', 5, 1),
                                                                                                                                             ('会议室C-302', '吴迪', '质量部', '质量改进会议', '2025-03-17 14:30:00', '2025-03-17 15:30:00', 7, 1),
                                                                                                                                             ('会议室A-101', '郑爽', '财务部', '预算审批会议', '2025-03-16 09:00:00', '2025-03-16 10:00:00', 8, 1),
                                                                                                                                             ('会议室B-201', '林晨', '人事部', '招聘面试', '2025-03-16 13:00:00', '2025-03-16 17:00:00', 3, 1),
                                                                                                                                             ('会议室A-102', '郭峰', '技术部', '技术方案评审', '2025-03-15 15:00:00', '2025-03-15 17:00:00', 12, 0),
                                                                                                                                             ('会议室C-301', '唐雅', '产品部', '用户调研讨论', '2025-03-15 10:30:00', '2025-03-15 12:00:00', 6, 0);

-- 4.5 反馈建议表（12条）
INSERT INTO feedback_suggestions (user_id, user_name, feedback_type, feedback_content, contact_way, feedback_time, reply_content, reply_time, status) VALUES
                                                                                                                                                          (1, '张明', '建议', '希望数据脱敏功能支持更多数据类型，如JSON格式', 'zhangming@example.com', '2025-03-15 10:30:00', '感谢建议，已纳入下个版本规划', '2025-03-16 09:00:00', '已处理'),
                                                                                                                                                          (2, '李芳', '投诉', '报表导出功能偶尔出现乱码问题', 'lifang@example.com', '2025-03-14 14:20:00', '已定位问题，下个版本修复', '2025-03-15 11:00:00', '已处理'),
                                                                                                                                                          (3, '王磊', '咨询', '产品是否支持国产化数据库适配？', 'wanglei@example.com', '2025-03-13 09:15:00', '已支持达梦、人大金仓等主流国产数据库', '2025-03-13 16:30:00', '已处理'),
                                                                                                                                                          (4, '赵静', '建议', '建议增加数据安全评分功能，便于量化风险', 'zhaojing@example.com', '2025-03-12 11:00:00', '好建议，已在开发中', '2025-03-12 17:00:00', '已处理'),
                                                                                                                                                          (5, '陈强', '投诉', 'API接口响应速度有时较慢，影响体验', 'chenqiang@example.com', '2025-03-11 15:30:00', '已优化接口性能，请重试', '2025-03-12 10:00:00', '已处理'),
                                                                                                                                                          (6, '刘娜', '咨询', '购买企业版后是否提供定制化开发？', 'liuna@example.com', '2025-03-10 10:00:00', '企业版支持定制开发，请与销售团队联系', '2025-03-10 14:30:00', '已处理'),
                                                                                                                                                          (7, '周涛', '建议', '希望增加移动端App，方便随时随地查看', 'zhoutao@example.com', '2025-03-09 08:30:00', '移动端正在开发中，预计Q3上线', '2025-03-09 16:00:00', '已处理'),
                                                                                                                                                          (8, '吴迪', '投诉', '文档更新不及时，缺少API详细说明', 'wudi@example.com', '2025-03-08 13:00:00', '已更新文档，请查看最新版', '2025-03-09 10:00:00', '已处理'),
                                                                                                                                                          (9, '郑爽', '咨询', '是否有免费试用版本？', 'zhengshuang@example.com', '2025-03-07 09:00:00', '提供30天免费试用，请联系客服开通', '2025-03-07 15:00:00', '已处理'),
                                                                                                                                                          (10, '林晨', '建议', '建议增加数据水印功能，防止泄密', 'linchen@example.com', '2025-03-06 11:30:00', '数据水印功能已在规划中', '2025-03-06 16:30:00', '已处理'),
                                                                                                                                                          (11, '郭峰', '建议', '希望支持与钉钉、飞书等系统集成', 'guofeng@example.com', '2025-03-05 14:00:00', '已支持企业微信，其他平台将陆续支持', '2025-03-05 17:00:00', '处理中'),
                                                                                                                                                          (12, '唐雅', '咨询', '产品是否支持多云环境部署？', 'tangya@example.com', '2025-03-04 10:00:00', '支持主流公有云和私有云部署', '2025-03-04 15:00:00', '已处理');

-- =====================================================
-- 五、数据统计验证
-- =====================================================
SELECT '=== 新增表数据统计 ===' AS '';
SELECT 'credit_card_transactions' AS table_name, COUNT(*) AS row_count FROM credit_card_transactions
UNION ALL SELECT 'member_points_detail', COUNT(*) FROM member_points_detail
UNION ALL SELECT 'device_fingerprint', COUNT(*) FROM device_fingerprint
UNION ALL SELECT 'call_records', COUNT(*) FROM call_records
UNION ALL SELECT 'location_trajectory', COUNT(*) FROM location_trajectory
UNION ALL SELECT 'sms_records', COUNT(*) FROM sms_records
UNION ALL SELECT 'family_relationship', COUNT(*) FROM family_relationship
UNION ALL SELECT 'resume_info', COUNT(*) FROM resume_info
UNION ALL SELECT 'exam_scores', COUNT(*) FROM exam_scores
UNION ALL SELECT 'medical_expenses', COUNT(*) FROM medical_expenses
UNION ALL SELECT 'articles', COUNT(*) FROM articles
UNION ALL SELECT 'event_registration', COUNT(*) FROM event_registration
UNION ALL SELECT 'device_maintenance', COUNT(*) FROM device_maintenance
UNION ALL SELECT 'meeting_room_booking', COUNT(*) FROM meeting_room_booking
UNION ALL SELECT 'feedback_suggestions', COUNT(*) FROM feedback_suggestions;

-- =====================================================
-- 使用数据库
-- =====================================================
USE data_sec_demo;

-- =====================================================
-- 一、新增敏感信息表（10张）
-- =====================================================

-- 1.1 信用卡交易明细表（有索引）
CREATE TABLE IF NOT EXISTS credit_card_transaction_details (
                                                               id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键ID',
                                                               card_holder_name VARCHAR(50) NOT NULL COMMENT '持卡人姓名',
                                                               credit_card_number VARCHAR(30) NOT NULL COMMENT '信用卡卡号',
                                                               transaction_amount DECIMAL(12,2) COMMENT '交易金额',
                                                               transaction_currency VARCHAR(10) COMMENT '交易币种',
                                                               transaction_time DATETIME COMMENT '交易时间',
                                                               merchant_name VARCHAR(200) COMMENT '商户名称',
                                                               merchant_category VARCHAR(50) COMMENT '商户类别',
                                                               transaction_type VARCHAR(30) COMMENT '交易类型:消费/取现/退款',
                                                               installment_months INT COMMENT '分期期数',
                                                               billing_cycle VARCHAR(20) COMMENT '账单周期',
                                                               created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
                                                               INDEX idx_card_number (credit_card_number),
                                                               INDEX idx_card_holder (card_holder_name),
                                                               INDEX idx_transaction_time (transaction_time)
) COMMENT '信用卡交易明细表';

-- 1.2 个人征信报告信息表（有索引）
CREATE TABLE IF NOT EXISTS personal_credit_report_info (
                                                           id BIGINT PRIMARY KEY AUTO_INCREMENT,
                                                           full_name VARCHAR(50) NOT NULL COMMENT '姓名',
                                                           id_card_number VARCHAR(18) NOT NULL COMMENT '身份证号',
                                                           credit_score INT COMMENT '信用评分',
                                                           credit_level VARCHAR(10) COMMENT '信用等级',
                                                           total_credit_limit DECIMAL(15,2) COMMENT '总授信额度',
                                                           used_credit_limit DECIMAL(15,2) COMMENT '已用额度',
                                                           overdue_count INT COMMENT '逾期次数',
                                                           overdue_amount DECIMAL(15,2) COMMENT '逾期金额',
                                                           inquiry_count_90d INT COMMENT '近90天查询次数',
                                                           loan_count INT COMMENT '贷款笔数',
                                                           credit_card_count INT COMMENT '信用卡张数',
                                                           report_generate_date DATE COMMENT '报告生成日期',
                                                           created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
                                                           INDEX idx_id_card (id_card_number),
                                                           INDEX idx_full_name (full_name),
                                                           INDEX idx_credit_score (credit_score)
) COMMENT '个人征信报告信息表';

-- 1.3 企业税务申报记录表（有索引）
CREATE TABLE IF NOT EXISTS enterprise_tax_filing_records (
                                                             id BIGINT PRIMARY KEY AUTO_INCREMENT,
                                                             company_name VARCHAR(200) NOT NULL COMMENT '企业名称',
                                                             unified_social_credit_code VARCHAR(18) COMMENT '统一社会信用代码',
                                                             tax_year INT COMMENT '纳税年度',
                                                             tax_period VARCHAR(20) COMMENT '纳税期间',
                                                             tax_type VARCHAR(50) COMMENT '税种:增值税/企业所得税/个税',
                                                             taxable_income DECIMAL(18,2) COMMENT '应纳税所得额',
                                                             tax_amount DECIMAL(18,2) COMMENT '应纳税额',
                                                             paid_amount DECIMAL(18,2) COMMENT '已纳税额',
                                                             late_fee_amount DECIMAL(18,2) COMMENT '滞纳金',
                                                             filing_date DATE COMMENT '申报日期',
                                                             filing_status VARCHAR(20) COMMENT '申报状态',
                                                             tax_official_name VARCHAR(50) COMMENT '税务专管员',
                                                             created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
                                                             INDEX idx_credit_code (unified_social_credit_code),
                                                             INDEX idx_company_name (company_name),
                                                             INDEX idx_tax_year (tax_year)
) COMMENT '企业税务申报记录表';

-- 1.4 员工入职背景调查表（有索引）
CREATE TABLE IF NOT EXISTS employee_background_check_info (
                                                              id BIGINT PRIMARY KEY AUTO_INCREMENT,
                                                              employee_name VARCHAR(50) NOT NULL COMMENT '员工姓名',
                                                              id_card_number VARCHAR(18) COMMENT '身份证号',
                                                              previous_company VARCHAR(200) COMMENT '前雇主公司',
                                                              previous_position VARCHAR(100) COMMENT '前职位',
                                                              employment_start_date DATE COMMENT '前工作开始日期',
                                                              employment_end_date DATE COMMENT '前工作结束日期',
                                                              criminal_record_check VARCHAR(20) COMMENT '犯罪记录核查:通过/未通过',
                                                              education_verify_status VARCHAR(20) COMMENT '学历核查状态',
                                                              reference_check_result TEXT COMMENT '背景调查结果',
                                                              credit_check_result VARCHAR(20) COMMENT '信用核查结果',
                                                              check_company VARCHAR(100) COMMENT '背调机构',
                                                              check_date DATE COMMENT '背调日期',
                                                              created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
                                                              INDEX idx_employee_name (employee_name),
                                                              INDEX idx_id_card (id_card_number),
                                                              INDEX idx_check_date (check_date)
) COMMENT '员工入职背景调查表';

-- 1.5 医疗检查检验报告表（有索引）
CREATE TABLE IF NOT EXISTS medical_lab_test_reports (
                                                        id BIGINT PRIMARY KEY AUTO_INCREMENT,
                                                        patient_name VARCHAR(50) NOT NULL COMMENT '患者姓名',
                                                        id_card_number VARCHAR(18) COMMENT '身份证号',
                                                        medical_record_no VARCHAR(50) COMMENT '病历号',
                                                        test_report_no VARCHAR(50) COMMENT '检验报告编号',
                                                        test_type VARCHAR(100) COMMENT '检验类型:血常规/尿常规/CT等',
                                                        test_items TEXT COMMENT '检验项目详情',
                                                        test_result TEXT COMMENT '检验结果',
                                                        reference_range VARCHAR(200) COMMENT '参考范围',
                                                        abnormal_flag VARCHAR(10) COMMENT '异常标识:正常/偏高/偏低',
                                                        doctor_name VARCHAR(50) COMMENT '检验医生',
                                                        hospital_name VARCHAR(200) COMMENT '医院名称',
                                                        test_date DATE COMMENT '检验日期',
                                                        report_date DATE COMMENT '报告日期',
                                                        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
                                                        INDEX idx_patient_name (patient_name),
                                                        INDEX idx_id_card (id_card_number),
                                                        INDEX idx_report_no (test_report_no)
) COMMENT '医疗检查检验报告表';

-- 1.6 证券账户持仓信息表（有索引）
CREATE TABLE IF NOT EXISTS securities_account_holdings_info (
                                                                id BIGINT PRIMARY KEY AUTO_INCREMENT,
                                                                account_holder_name VARCHAR(50) NOT NULL COMMENT '账户持有人',
                                                                id_card_number VARCHAR(18) COMMENT '身份证号',
                                                                securities_account_no VARCHAR(30) COMMENT '证券账户号',
                                                                stock_code VARCHAR(10) COMMENT '股票代码',
                                                                stock_name VARCHAR(50) COMMENT '股票名称',
                                                                holding_quantity INT COMMENT '持股数量',
                                                                average_cost DECIMAL(12,4) COMMENT '平均成本',
                                                                current_price DECIMAL(12,4) COMMENT '当前价格',
                                                                market_value DECIMAL(15,2) COMMENT '市值',
                                                                profit_loss DECIMAL(15,2) COMMENT '盈亏金额',
                                                                profit_loss_rate DECIMAL(8,4) COMMENT '盈亏比例',
                                                                broker_name VARCHAR(100) COMMENT '券商名称',
                                                                created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
                                                                INDEX idx_account_no (securities_account_no),
                                                                INDEX idx_holder_name (account_holder_name),
                                                                INDEX idx_stock_code (stock_code)
) COMMENT '证券账户持仓信息表';

-- 1.7 保险理赔申请记录表（有索引）
CREATE TABLE IF NOT EXISTS insurance_claim_application_records (
                                                                   id BIGINT PRIMARY KEY AUTO_INCREMENT,
                                                                   policy_holder_name VARCHAR(50) NOT NULL COMMENT '投保人姓名',
                                                                   id_card_number VARCHAR(18) COMMENT '身份证号',
                                                                   policy_no VARCHAR(50) COMMENT '保单号',
                                                                   claim_no VARCHAR(50) COMMENT '理赔申请号',
                                                                   claim_amount DECIMAL(15,2) COMMENT '理赔金额',
                                                                   accident_date DATE COMMENT '出险日期',
                                                                   claim_date DATE COMMENT '申请日期',
                                                                   claim_reason VARCHAR(500) COMMENT '理赔原因',
                                                                   claim_status VARCHAR(30) COMMENT '理赔状态:审核中/已通过/已拒赔',
                                                                   approved_amount DECIMAL(15,2) COMMENT '核定金额',
                                                                   reject_reason VARCHAR(500) COMMENT '拒赔原因',
                                                                   claim_settlement_date DATE COMMENT '结案日期',
                                                                   adjuster_name VARCHAR(50) COMMENT '理赔员',
                                                                   created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
                                                                   INDEX idx_policy_no (policy_no),
                                                                   INDEX idx_id_card (id_card_number),
                                                                   INDEX idx_claim_no (claim_no)
) COMMENT '保险理赔申请记录表';

-- 1.8 不动产抵押登记信息表（有索引）
CREATE TABLE IF NOT EXISTS real_estate_mortgage_registration (
                                                                 id BIGINT PRIMARY KEY AUTO_INCREMENT,
                                                                 property_owner_name VARCHAR(50) NOT NULL COMMENT '产权人姓名',
                                                                 owner_id_card VARCHAR(18) COMMENT '产权人身份证',
                                                                 property_cert_no VARCHAR(50) COMMENT '房产证号',
                                                                 property_address VARCHAR(500) COMMENT '房产地址',
                                                                 mortgage_amount DECIMAL(15,2) COMMENT '抵押金额',
                                                                 mortgagee_name VARCHAR(100) COMMENT '抵押权人(银行)',
                                                                 mortgage_contract_no VARCHAR(50) COMMENT '抵押合同号',
                                                                 registration_no VARCHAR(50) COMMENT '抵押登记编号',
                                                                 registration_date DATE COMMENT '登记日期',
                                                                 mortgage_start_date DATE COMMENT '抵押起始日期',
                                                                 mortgage_end_date DATE COMMENT '抵押结束日期',
                                                                 release_status VARCHAR(20) COMMENT '解押状态:已抵押/已解押',
                                                                 release_date DATE COMMENT '解押日期',
                                                                 created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
                                                                 INDEX idx_cert_no (property_cert_no),
                                                                 INDEX idx_owner_id_card (owner_id_card),
                                                                 INDEX idx_registration_no (registration_no)
) COMMENT '不动产抵押登记信息表';

-- 1.9 儿童疫苗接种记录表（有索引）
CREATE TABLE IF NOT EXISTS child_vaccination_record_details (
                                                                id BIGINT PRIMARY KEY AUTO_INCREMENT,
                                                                child_name VARCHAR(50) NOT NULL COMMENT '儿童姓名',
                                                                parent_name VARCHAR(50) COMMENT '家长姓名',
                                                                parent_id_card VARCHAR(18) COMMENT '家长身份证',
                                                                vaccine_name VARCHAR(100) COMMENT '疫苗名称',
                                                                vaccine_batch_no VARCHAR(50) COMMENT '疫苗批号',
                                                                vaccination_date DATE COMMENT '接种日期',
                                                                vaccination_location VARCHAR(200) COMMENT '接种地点',
                                                                dose_number INT COMMENT '剂次:1/2/3',
                                                                next_vaccination_date DATE COMMENT '下次接种日期',
                                                                manufacturer VARCHAR(100) COMMENT '生产厂家',
                                                                administering_nurse VARCHAR(50) COMMENT '接种护士',
                                                                adverse_reaction VARCHAR(500) COMMENT '不良反应',
                                                                created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
                                                                INDEX idx_child_name (child_name),
                                                                INDEX idx_parent_id_card (parent_id_card),
                                                                INDEX idx_vaccination_date (vaccination_date)
) COMMENT '儿童疫苗接种记录表';

-- 1.10 企业商业秘密登记表（无索引）
CREATE TABLE IF NOT EXISTS enterprise_trade_secret_registration (
                                                                    id BIGINT PRIMARY KEY AUTO_INCREMENT,
                                                                    enterprise_name VARCHAR(200) NOT NULL COMMENT '企业名称',
                                                                    secret_name VARCHAR(200) COMMENT '商业秘密名称',
                                                                    secret_type VARCHAR(50) COMMENT '秘密类型:技术秘密/经营秘密',
                                                                    secret_level VARCHAR(20) COMMENT '密级:核心/重要/一般',
                                                                    secret_content TEXT COMMENT '秘密内容描述',
                                                                    creation_date DATE COMMENT '创建日期',
                                                                    creator_name VARCHAR(50) COMMENT '创建人',
                                                                    access_scope VARCHAR(500) COMMENT '知悉范围',
                                                                    protection_measures VARCHAR(500) COMMENT '保护措施',
                                                                    confidentiality_agreement VARCHAR(10) COMMENT '是否签署保密协议',
                                                                    registration_authority VARCHAR(100) COMMENT '登记机关',
                                                                    registration_no VARCHAR(50) COMMENT '登记编号',
                                                                    registration_date DATE COMMENT '登记日期',
                                                                    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
    -- 故意不建索引
) COMMENT '企业商业秘密登记表';

-- =====================================================
-- 二、新增业务表（5张）
-- =====================================================

-- 2.1 客户服务工单处理记录表（有索引）
CREATE TABLE IF NOT EXISTS customer_service_ticket_processing_records (
                                                                          id BIGINT PRIMARY KEY AUTO_INCREMENT,
                                                                          ticket_no VARCHAR(50) NOT NULL COMMENT '工单编号',
                                                                          customer_name VARCHAR(100) COMMENT '客户名称',
                                                                          customer_phone VARCHAR(11) COMMENT '客户电话',
                                                                          service_type VARCHAR(50) COMMENT '服务类型:咨询/投诉/售后',
                                                                          priority_level VARCHAR(20) COMMENT '优先级:高/中/低',
                                                                          issue_description TEXT COMMENT '问题描述',
                                                                          processing_status VARCHAR(30) COMMENT '处理状态:待处理/处理中/已完成',
                                                                          handler_name VARCHAR(50) COMMENT '处理人',
                                                                          processing_remark TEXT COMMENT '处理备注',
                                                                          resolve_time DATETIME COMMENT '解决时间',
                                                                          customer_satisfaction INT COMMENT '客户满意度1-5',
                                                                          created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
                                                                          INDEX idx_ticket_no (ticket_no),
                                                                          INDEX idx_customer_name (customer_name),
                                                                          INDEX idx_status (processing_status)
) COMMENT '客户服务工单处理记录表';

-- 2.2 商品库存盘点明细表（有索引）
CREATE TABLE IF NOT EXISTS product_inventory_stocktaking_details (
                                                                     id BIGINT PRIMARY KEY AUTO_INCREMENT,
                                                                     product_code VARCHAR(50) NOT NULL COMMENT '商品编码',
                                                                     product_name VARCHAR(200) COMMENT '商品名称',
                                                                     theoretical_quantity INT COMMENT '理论库存量',
                                                                     actual_quantity INT COMMENT '实际盘点量',
                                                                     difference_quantity INT COMMENT '差异数量',
                                                                     difference_reason VARCHAR(200) COMMENT '差异原因',
                                                                     stocktaking_date DATE COMMENT '盘点日期',
                                                                     stocktaking_person VARCHAR(50) COMMENT '盘点人',
                                                                     auditor_name VARCHAR(50) COMMENT '复核人',
                                                                     adjustment_status VARCHAR(20) COMMENT '调整状态:已调整/待调整',
                                                                     adjustment_amount DECIMAL(15,2) COMMENT '调整金额',
                                                                     remark VARCHAR(500) COMMENT '备注',
                                                                     created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
                                                                     INDEX idx_product_code (product_code),
                                                                     INDEX idx_stocktaking_date (stocktaking_date),
                                                                     INDEX idx_status (adjustment_status)
) COMMENT '商品库存盘点明细表';

-- 2.3 用户登录访问日志明细表（无索引）
CREATE TABLE IF NOT EXISTS user_login_access_log_details (
                                                             id BIGINT PRIMARY KEY AUTO_INCREMENT,
                                                             username VARCHAR(50) NOT NULL COMMENT '用户名',
                                                             login_ip VARCHAR(45) COMMENT '登录IP',
                                                             login_time DATETIME COMMENT '登录时间',
                                                             logout_time DATETIME COMMENT '登出时间',
                                                             session_duration_seconds INT COMMENT '会话时长(秒)',
                                                             login_device VARCHAR(100) COMMENT '登录设备',
                                                             browser_info VARCHAR(200) COMMENT '浏览器信息',
                                                             login_status VARCHAR(20) COMMENT '登录状态:成功/失败',
                                                             fail_reason VARCHAR(200) COMMENT '失败原因',
                                                             request_uri VARCHAR(500) COMMENT '请求地址',
                                                             http_method VARCHAR(10) COMMENT '请求方法'
    -- 故意不建索引
) COMMENT '用户登录访问日志明细表';

-- 2.4 促销活动参与记录表（无索引）
CREATE TABLE IF NOT EXISTS promotion_activity_participation_records (
                                                                        id BIGINT PRIMARY KEY AUTO_INCREMENT,
                                                                        user_id BIGINT NOT NULL COMMENT '用户ID',
                                                                        username VARCHAR(50) COMMENT '用户名',
                                                                        activity_code VARCHAR(50) COMMENT '活动编码',
                                                                        activity_name VARCHAR(200) COMMENT '活动名称',
                                                                        activity_type VARCHAR(50) COMMENT '活动类型:满减/折扣/秒杀',
                                                                        participation_time DATETIME COMMENT '参与时间',
                                                                        order_no VARCHAR(32) COMMENT '关联订单号',
                                                                        discount_amount DECIMAL(10,2) COMMENT '优惠金额',
                                                                        coupon_code VARCHAR(50) COMMENT '使用的优惠券码',
                                                                        sharing_status VARCHAR(20) COMMENT '是否分享:是/否',
                                                                        invitation_code VARCHAR(50) COMMENT '邀请码'
    -- 故意不建索引
) COMMENT '促销活动参与记录表';

-- 2.5 系统性能监控指标数据表（有索引）
CREATE TABLE IF NOT EXISTS system_performance_monitoring_metrics_data (
                                                                          id BIGINT PRIMARY KEY AUTO_INCREMENT,
                                                                          server_name VARCHAR(100) NOT NULL COMMENT '服务器名称',
                                                                          metric_type VARCHAR(50) COMMENT '指标类型:CPU/内存/磁盘/网络',
                                                                          metric_value DECIMAL(15,4) COMMENT '指标值',
                                                                          metric_unit VARCHAR(20) COMMENT '单位:百分比/MB/GB',
                                                                          collect_time DATETIME COMMENT '采集时间',
                                                                          threshold_value DECIMAL(15,4) COMMENT '阈值',
                                                                          alert_status VARCHAR(20) COMMENT '告警状态:正常/告警/严重',
                                                                          alert_message VARCHAR(500) COMMENT '告警信息',
                                                                          created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
                                                                          INDEX idx_server_name (server_name),
                                                                          INDEX idx_metric_type (metric_type),
                                                                          INDEX idx_collect_time (collect_time)
) COMMENT '系统性能监控指标数据表';

-- =====================================================
-- 三、插入模拟数据
-- =====================================================

-- 3.1 信用卡交易明细表（15条）
INSERT INTO credit_card_transaction_details (card_holder_name, credit_card_number, transaction_amount, transaction_currency, transaction_time, merchant_name, merchant_category, transaction_type, installment_months, billing_cycle) VALUES
                                                                                                                                                                                                                                          ('张明', '6222021234567890123', 299.00, 'CNY', '2025-03-20 10:30:00', '京东商城', '电商', '消费', 0, '2025-04'),
                                                                                                                                                                                                                                          ('李芳', '6222032345678901234', 1299.00, 'CNY', '2025-03-19 14:20:00', '天猫超市', '电商', '消费', 3, '2025-04'),
                                                                                                                                                                                                                                          ('王磊', '6222043456789012345', 45.50, 'CNY', '2025-03-18 12:00:00', '麦当劳', '餐饮', '消费', 0, '2025-04'),
                                                                                                                                                                                                                                          ('赵静', '6222054567890123456', 3280.00, 'CNY', '2025-03-17 19:30:00', '携程旅行', '旅游', '消费', 6, '2025-04'),
                                                                                                                                                                                                                                          ('陈强', '6222065678901234567', 98.00, 'CNY', '2025-03-16 08:15:00', '星巴克', '餐饮', '消费', 0, '2025-04'),
                                                                                                                                                                                                                                          ('刘娜', '6222076789012345678', 569.00, 'CNY', '2025-03-15 15:45:00', '优衣库', '服饰', '消费', 0, '2025-04'),
                                                                                                                                                                                                                                          ('周涛', '6222087890123456789', 15000.00, 'CNY', '2025-03-14 11:00:00', '苹果官网', '数码', '消费', 12, '2025-04'),
                                                                                                                                                                                                                                          ('吴迪', '6222098901234567890', 238.00, 'CNY', '2025-03-13 18:30:00', '美团外卖', '餐饮', '消费', 0, '2025-04'),
                                                                                                                                                                                                                                          ('郑爽', '6222109012345678901', 5000.00, 'CNY', '2025-03-12 09:00:00', '支付宝', '金融', '取现', 0, '2025-04'),
                                                                                                                                                                                                                                          ('林晨', '6222110123456789012', 189.00, 'CNY', '2025-03-11 16:20:00', '滴滴出行', '出行', '消费', 0, '2025-04'),
                                                                                                                                                                                                                                          ('郭峰', '6222121234567890123', 899.00, 'CNY', '2025-03-10 13:40:00', '小米商城', '数码', '消费', 0, '2025-04'),
                                                                                                                                                                                                                                          ('唐雅', '6222132345678901234', 3499.00, 'CNY', '2025-03-09 20:15:00', '京东自营', '电商', '消费', 3, '2025-04'),
                                                                                                                                                                                                                                          ('孙浩', '6222143456789012345', 67.80, 'CNY', '2025-03-08 12:30:00', '饿了么', '餐饮', '消费', 0, '2025-04'),
                                                                                                                                                                                                                                          ('许晴', '6222154567890123456', 12500.00, 'CNY', '2025-03-07 10:00:00', '国美电器', '家电', '消费', 12, '2025-04'),
                                                                                                                                                                                                                                          ('韩雪', '6222165678901234567', 456.00, 'CNY', '2025-03-06 14:50:00', '沃尔玛', '商超', '消费', 0, '2025-04');

-- 3.2 个人征信报告信息表（10条）
INSERT INTO personal_credit_report_info (full_name, id_card_number, credit_score, credit_level, total_credit_limit, used_credit_limit, overdue_count, overdue_amount, inquiry_count_90d, loan_count, credit_card_count, report_generate_date) VALUES
                                                                                                                                                                                                                                                  ('张明', '11010119900307663X', 785, '优秀', 500000.00, 125000.00, 0, 0.00, 3, 1, 3, '2025-03-01'),
                                                                                                                                                                                                                                                  ('李芳', '310101198805124567', 762, '良好', 450000.00, 189000.00, 1, 2500.00, 5, 2, 4, '2025-03-01'),
                                                                                                                                                                                                                                                  ('王磊', '440301199210235678', 738, '良好', 380000.00, 156000.00, 2, 3800.00, 6, 2, 2, '2025-03-01'),
                                                                                                                                                                                                                                                  ('赵静', '51010719870714789X', 801, '优秀', 600000.00, 98000.00, 0, 0.00, 2, 1, 5, '2025-03-01'),
                                                                                                                                                                                                                                                  ('陈强', '320105199103156789', 695, '中等', 280000.00, 168000.00, 3, 5600.00, 8, 3, 2, '2025-03-01'),
                                                                                                                                                                                                                                                  ('刘娜', '350203199512019876', 745, '良好', 350000.00, 142000.00, 1, 1200.00, 4, 1, 3, '2025-03-01'),
                                                                                                                                                                                                                                                  ('周涛', '120101198608128765', 820, '极好', 800000.00, 250000.00, 0, 0.00, 2, 1, 4, '2025-03-01'),
                                                                                                                                                                                                                                                  ('吴迪', '430103199311234321', 712, '中等', 300000.00, 195000.00, 2, 4200.00, 7, 2, 3, '2025-03-01'),
                                                                                                                                                                                                                                                  ('郑爽', '210203199403211234', 768, '良好', 420000.00, 165000.00, 1, 1800.00, 4, 1, 4, '2025-03-01'),
                                                                                                                                                                                                                                                  ('林晨', '370202199707153456', 755, '良好', 390000.00, 148000.00, 1, 900.00, 5, 2, 3, '2025-03-01');

-- 3.3 企业税务申报记录表（10条）
INSERT INTO enterprise_tax_filing_records (company_name, unified_social_credit_code, tax_year, tax_period, tax_type, taxable_income, tax_amount, paid_amount, late_fee_amount, filing_date, filing_status, tax_official_name) VALUES
                                                                                                                                                                                                                                  ('云创科技股份有限公司', '91110000MA01A2B3C4', 2024, 'Q1', '增值税', 8500000.00, 1105000.00, 1105000.00, 0.00, '2024-04-15', '已申报', '王税务师'),
                                                                                                                                                                                                                                  ('云创科技股份有限公司', '91110000MA01A2B3C4', 2024, 'Q1', '企业所得税', 8500000.00, 2125000.00, 2125000.00, 0.00, '2024-04-15', '已申报', '王税务师'),
                                                                                                                                                                                                                                  ('海纳数据安全有限公司', '91440000MA05D6E7F8', 2024, 'Q1', '增值税', 4500000.00, 585000.00, 585000.00, 0.00, '2024-04-18', '已申报', '李税务员'),
                                                                                                                                                                                                                                  ('智联信息技术集团', '91370000MA09G8H9I0', 2024, 'Q1', '增值税', 12000000.00, 1560000.00, 1560000.00, 0.00, '2024-04-20', '已申报', '张税务师'),
                                                                                                                                                                                                                                  ('星辰云计算有限公司', '91420000MA11J2K3L4', 2024, 'Q1', '增值税', 2800000.00, 364000.00, 364000.00, 0.00, '2024-04-16', '已申报', '刘科员'),
                                                                                                                                                                                                                                  ('安恒信息安全技术', '91350000MA13M4N5O6', 2024, 'Q1', '增值税', 3500000.00, 455000.00, 455000.00, 0.00, '2024-04-19', '已申报', '陈税务员'),
                                                                                                                                                                                                                                  ('致远软件科技', '91330000MA15P6Q7R8', 2024, 'Q1', '增值税', 4200000.00, 546000.00, 546000.00, 0.00, '2024-04-17', '已申报', '赵税务师'),
                                                                                                                                                                                                                                  ('磐石区块链科技', '91220000MA17S8T9U0', 2024, 'Q1', '增值税', 6800000.00, 884000.00, 884000.00, 0.00, '2024-04-22', '已申报', '周科员'),
                                                                                                                                                                                                                                  ('天璇人工智能实验室', '91110000MA19V0W1X2', 2024, 'Q1', '增值税', 9500000.00, 1235000.00, 1235000.00, 0.00, '2024-04-21', '已申报', '吴税务师'),
                                                                                                                                                                                                                                  ('昆仑金融科技集团', '91440000MA21W2Y3Z4', 2024, 'Q1', '增值税', 11000000.00, 1430000.00, 1430000.00, 0.00, '2024-04-23', '已申报', '郑税务员');

-- 3.4 员工入职背景调查表（12条）
INSERT INTO employee_background_check_info (employee_name, id_card_number, previous_company, previous_position, employment_start_date, employment_end_date, criminal_record_check, education_verify_status, reference_check_result, credit_check_result, check_company, check_date) VALUES
                                                                                                                                                                                                                                                                                        ('张明', '11010119900307663X', '百度在线网络技术', '高级工程师', '2018-03-01', '2023-12-31', '通过', '已核实', '推荐，工作表现优秀', '无不良记录', '猎聘背调', '2024-01-10'),
                                                                                                                                                                                                                                                                                        ('李芳', '310101198805124567', '阿里巴巴集团', '产品经理', '2019-06-01', '2024-02-28', '通过', '已核实', '强烈推荐，业绩突出', '无不良记录', '凯莱德背调', '2024-03-05'),
                                                                                                                                                                                                                                                                                        ('王磊', '440301199210235678', '腾讯科技', '销售总监', '2017-08-01', '2024-01-31', '通过', '已核实', '推荐，销售能力突出', '无不良记录', '全景求是', '2024-02-15'),
                                                                                                                                                                                                                                                                                        ('赵静', '51010719870714789X', '华为技术有限公司', '架构师', '2016-05-01', '2023-11-30', '通过', '已核实', '强烈推荐，技术能力强', '无不良记录', '猎聘背调', '2024-01-20'),
                                                                                                                                                                                                                                                                                        ('陈强', '320105199103156789', '字节跳动', '技术专家', '2020-02-01', '2024-02-29', '通过', '已核实', '推荐，责任心强', '无不良记录', '凯莱德背调', '2024-03-10'),
                                                                                                                                                                                                                                                                                        ('刘娜', '350203199512019876', '美团点评', '市场经理', '2019-09-01', '2024-02-28', '通过', '已核实', '推荐，执行力强', '无不良记录', '全景求是', '2024-03-12'),
                                                                                                                                                                                                                                                                                        ('周涛', '120101198608128765', '京东集团', '运维总监', '2015-07-01', '2023-10-31', '通过', '已核实', '强烈推荐，管理能力强', '无不良记录', '猎聘背调', '2024-01-05'),
                                                                                                                                                                                                                                                                                        ('吴迪', '430103199311234321', '小米科技', '研发工程师', '2021-03-01', '2024-01-31', '通过', '已核实', '推荐，学习能力强', '无不良记录', '凯莱德背调', '2024-02-20'),
                                                                                                                                                                                                                                                                                        ('郑爽', '210203199403211234', '网易公司', '财务经理', '2018-11-01', '2023-12-31', '通过', '已核实', '推荐，专业能力扎实', '无不良记录', '全景求是', '2024-01-25'),
                                                                                                                                                                                                                                                                                        ('林晨', '370202199707153456', '携程旅行网', 'HRBP', '2020-08-01', '2024-02-29', '通过', '已核实', '推荐，沟通能力强', '无不良记录', '猎聘背调', '2024-03-08'),
                                                                                                                                                                                                                                                                                        ('郭峰', '500101198809194567', '滴滴出行', '产品运营', '2019-04-01', '2023-11-30', '通过', '已核实', '推荐，数据敏感度高', '无不良记录', '凯莱德背调', '2024-01-15'),
                                                                                                                                                                                                                                                                                        ('唐雅', '330105199410285678', '拼多多', '运营专员', '2021-06-01', '2024-02-28', '通过', '已核实', '推荐，工作积极主动', '无不良记录', '全景求是', '2024-03-18');

-- 3.5 医疗检查检验报告表（12条）
INSERT INTO medical_lab_test_reports (patient_name, id_card_number, medical_record_no, test_report_no, test_type, test_items, test_result, reference_range, abnormal_flag, doctor_name, hospital_name, test_date, report_date) VALUES
                                                                                                                                                                                                                                   ('张明', '11010119900307663X', 'MR202400001', 'LAB202400001', '血常规', '白细胞计数', '6.5', '3.5-9.5', '正常', '王医生', '北京协和医院', '2024-03-10', '2024-03-11'),
                                                                                                                                                                                                                                   ('张明', '11010119900307663X', 'MR202400001', 'LAB202400002', '血脂', '总胆固醇', '5.8', '<5.2', '偏高', '王医生', '北京协和医院', '2024-03-10', '2024-03-11'),
                                                                                                                                                                                                                                   ('李芳', '310101198805124567', 'MR202400002', 'LAB202400003', '血糖', '空腹血糖', '7.2', '3.9-6.1', '偏高', '张医生', '上海瑞金医院', '2024-02-15', '2024-02-16'),
                                                                                                                                                                                                                                   ('王磊', '440301199210235678', 'MR202400003', 'LAB202400004', '尿常规', '尿蛋白', '阴性', '阴性', '正常', '刘医生', '深圳市人民医院', '2024-03-05', '2024-03-06'),
                                                                                                                                                                                                                                   ('赵静', '51010719870714789X', 'MR202400004', 'LAB202400005', '甲状腺功能', 'TSH', '3.2', '0.35-4.94', '正常', '陈医生', '华西医院', '2024-01-20', '2024-01-21'),
                                                                                                                                                                                                                                   ('陈强', '320105199103156789', 'MR202400005', 'LAB202400006', '肝功能', 'ALT', '45', '10-40', '偏高', '李医生', '江苏省人民医院', '2024-02-01', '2024-02-02'),
                                                                                                                                                                                                                                   ('刘娜', '350203199512019876', 'MR202400006', 'LAB202400007', '肺功能', 'FEV1/FVC', '82', '>80', '正常', '黄医生', '厦门大学附属第一医院', '2024-03-15', '2024-03-16'),
                                                                                                                                                                                                                                   ('周涛', '120101198608128765', 'MR202400007', 'LAB202400008', '心电图', '心电图', '窦性心律', '正常', '孙医生', '天津医科大学总医院', '2024-02-20', '2024-02-21'),
                                                                                                                                                                                                                                   ('吴迪', '430103199311234321', 'MR202400008', 'LAB202400009', '胃镜', '胃镜检查', '胃溃疡', '正常', '周医生', '中南大学湘雅医院', '2024-01-10', '2024-01-11'),
                                                                                                                                                                                                                                   ('郑爽', '210203199403211234', 'MR202400009', 'LAB202400010', 'B超', '胆囊B超', '胆囊结石', '正常', '赵医生', '大连医科大学附属第一医院', '2024-03-08', '2024-03-09'),
                                                                                                                                                                                                                                   ('林晨', '370202199707153456', 'MR202400010', 'LAB202400011', '骨密度', '骨密度T值', '-2.1', '>-1', '偏低', '王医生', '青岛大学附属医院', '2024-02-25', '2024-02-26'),
                                                                                                                                                                                                                                   ('郭峰', '500101198809194567', 'MR202400011', 'LAB202400012', '肾功能', '肌酐', '95', '44-104', '正常', '刘医生', '重庆医科大学附属第一医院', '2024-03-12', '2024-03-13');

-- 3.6 证券账户持仓信息表（10条）
INSERT INTO securities_account_holdings_info (account_holder_name, id_card_number, securities_account_no, stock_code, stock_name, holding_quantity, average_cost, current_price, market_value, profit_loss, profit_loss_rate, broker_name) VALUES
                                                                                                                                                                                                                                               ('张明', '11010119900307663X', 'A123456789', '600519', '贵州茅台', 100, 1680.00, 1720.00, 172000.00, 4000.00, 2.38, '中信证券'),
                                                                                                                                                                                                                                               ('张明', '11010119900307663X', 'A123456789', '000858', '五粮液', 500, 145.00, 152.00, 76000.00, 3500.00, 4.83, '中信证券'),
                                                                                                                                                                                                                                               ('李芳', '310101198805124567', 'B234567890', '300750', '宁德时代', 200, 180.00, 195.00, 39000.00, 3000.00, 8.33, '华泰证券'),
                                                                                                                                                                                                                                               ('王磊', '440301199210235678', 'C345678901', '601318', '中国平安', 1000, 42.00, 45.00, 45000.00, 3000.00, 7.14, '国泰君安'),
                                                                                                                                                                                                                                               ('赵静', '51010719870714789X', 'D456789012', '000333', '美的集团', 800, 58.00, 62.00, 49600.00, 3200.00, 6.90, '招商证券'),
                                                                                                                                                                                                                                               ('陈强', '320105199103156789', 'E567890123', '002415', '海康威视', 600, 35.00, 33.50, 20100.00, -900.00, -4.29, '广发证券'),
                                                                                                                                                                                                                                               ('刘娜', '350203199512019876', 'F678901234', '600036', '招商银行', 500, 38.00, 42.00, 21000.00, 2000.00, 10.53, '中信建投'),
                                                                                                                                                                                                                                               ('周涛', '120101198608128765', 'G789012345', '601012', '隆基绿能', 400, 25.00, 22.00, 8800.00, -1200.00, -12.00, '海通证券'),
                                                                                                                                                                                                                                               ('吴迪', '430103199311234321', 'H890123456', '002594', '比亚迪', 150, 260.00, 280.00, 42000.00, 3000.00, 7.69, '银河证券'),
                                                                                                                                                                                                                                               ('郑爽', '210203199403211234', 'I901234567', '000001', '平安银行', 1000, 12.00, 11.50, 11500.00, -500.00, -4.17, '国信证券');

-- 3.7 保险理赔申请记录表（10条）
INSERT INTO insurance_claim_application_records (policy_holder_name, id_card_number, policy_no, claim_no, claim_amount, accident_date, claim_date, claim_reason, claim_status, approved_amount, reject_reason, claim_settlement_date, adjuster_name) VALUES
                                                                                                                                                                                                                                                         ('张明', '11010119900307663X', 'POL202400001', 'CLM202400001', 150000.00, '2024-02-10', '2024-02-20', '确诊胃癌', '已通过', 150000.00, NULL, '2024-03-10', '李理赔员'),
                                                                                                                                                                                                                                                         ('李芳', '310101198805124567', 'POL202400002', 'CLM202400002', 85000.00, '2024-01-15', '2024-01-25', '住院医疗费用', '已通过', 82000.00, NULL, '2024-02-15', '王理赔员'),
                                                                                                                                                                                                                                                         ('王磊', '440301199210235678', 'POL202400003', 'CLM202400003', 500000.00, '2023-12-05', '2023-12-20', '意外身故', '审核中', NULL, NULL, NULL, '张理赔员'),
                                                                                                                                                                                                                                                         ('赵静', '51010719870714789X', 'POL202400004', 'CLM202400004', 3500.00, '2024-02-20', '2024-03-01', '意外摔伤门诊', '已通过', 3200.00, NULL, '2024-03-20', '刘理赔员'),
                                                                                                                                                                                                                                                         ('陈强', '320105199103156789', 'POL202400005', 'CLM202400005', 280000.00, '2024-01-10', '2024-01-30', '急性心肌梗死', '已拒赔', 0.00, '等待期内出险', '2024-02-25', '陈理赔员'),
                                                                                                                                                                                                                                                         ('刘娜', '350203199512019876', 'POL202400006', 'CLM202400006', 12000.00, '2024-02-05', '2024-02-18', '阑尾炎手术', '已通过', 11500.00, NULL, '2024-03-05', '赵理赔员'),
                                                                                                                                                                                                                                                         ('周涛', '120101198608128765', 'POL202400007', 'CLM202400007', 50000.00, '2023-11-20', '2023-12-05', '甲状腺癌', '已通过', 50000.00, NULL, '2024-01-05', '孙理赔员'),
                                                                                                                                                                                                                                                         ('吴迪', '430103199311234321', 'POL202400008', 'CLM202400008', 68000.00, '2024-01-25', '2024-02-10', '骨折住院', '审核中', NULL, NULL, NULL, '周理赔员'),
                                                                                                                                                                                                                                                         ('郑爽', '210203199403211234', 'POL202400009', 'CLM202400009', 25000.00, '2024-02-28', '2024-03-10', '肺炎住院', '已通过', 23000.00, NULL, '2024-03-25', '吴理赔员'),
                                                                                                                                                                                                                                                         ('林晨', '370202199707153456', 'POL202400010', 'CLM202400010', 180000.00, '2024-01-08', '2024-01-22', '脑中风后遗症', '已拒赔', 0.00, '不属于保障范围', '2024-02-18', '郑理赔员');

-- 3.8 不动产抵押登记信息表（10条）
INSERT INTO real_estate_mortgage_registration (property_owner_name, owner_id_card, property_cert_no, property_address, mortgage_amount, mortgagee_name, mortgage_contract_no, registration_no, registration_date, mortgage_start_date, mortgage_end_date, release_status, release_date) VALUES
                                                                                                                                                                                                                                                                                            ('张明', '11010119900307663X', '京房权证朝字第123456号', '北京市朝阳区望京街道xxx小区1号楼101室', 5000000.00, '中国工商银行北京分行', 'MORT202400001', 'REG202400001', '2024-01-15', '2024-01-20', '2044-01-19', '已抵押', NULL),
                                                                                                                                                                                                                                                                                            ('李芳', '310101198805124567', '沪房地浦字第654321号', '上海市浦东新区陆家嘴街道xxx小区2号楼202室', 7000000.00, '中国建设银行上海分行', 'MORT202400002', 'REG202400002', '2024-02-10', '2024-02-15', '2044-02-14', '已抵押', NULL),
                                                                                                                                                                                                                                                                                            ('王磊', '440301199210235678', '粤房地证字第789012号', '深圳市南山区科技园xxx大厦1801室', 4000000.00, '招商银行深圳分行', 'MORT202400003', 'REG202400003', '2024-03-01', '2024-03-05', '2044-03-04', '已抵押', NULL),
                                                                                                                                                                                                                                                                                            ('赵静', '51010719870714789X', '成房权证字第345678号', '成都市高新区天府大道xxx小区3单元301室', 1800000.00, '中国银行成都分行', 'MORT202400004', 'REG202400004', '2023-11-20', '2023-11-25', '2043-11-24', '已解押', '2024-02-20'),
                                                                                                                                                                                                                                                                                            ('陈强', '320105199103156789', '杭房权证字第901234号', '杭州市西湖区文一路xxx小区4幢402室', 2500000.00, '交通银行杭州分行', 'MORT202400005', 'REG202400005', '2024-01-05', '2024-01-10', '2044-01-09', '已抵押', NULL),
                                                                                                                                                                                                                                                                                            ('刘娜', '350203199512019876', '厦房证字第567890号', '厦门市思明区环岛路xxx小区5号楼503室', 3000000.00, '兴业银行厦门分行', 'MORT202400006', 'REG202400006', '2023-12-15', '2023-12-20', '2043-12-19', '已抵押', NULL),
                                                                                                                                                                                                                                                                                            ('周涛', '120101198608128765', '津房权字第123890号', '天津市和平区南京路xxx小区6门601室', 1500000.00, '中信银行天津分行', 'MORT202400007', 'REG202400007', '2024-02-20', '2024-02-25', '2044-02-24', '已抵押', NULL),
                                                                                                                                                                                                                                                                                            ('吴迪', '430103199311234321', '长房证字第456712号', '长沙市岳麓区麓谷大道xxx小区7栋702室', 1200000.00, '长沙银行', 'MORT202400008', 'REG202400008', '2024-03-10', '2024-03-15', '2044-03-14', '已抵押', NULL),
                                                                                                                                                                                                                                                                                            ('郑爽', '210203199403211234', '大房权字第789034号', '大连市中山区人民路xxx小区8号801室', 2000000.00, '民生银行大连分行', 'MORT202400009', 'REG202400009', '2024-01-25', '2024-01-30', '2044-01-29', '已解押', '2024-03-15'),
                                                                                                                                                                                                                                                                                            ('林晨', '370202199707153456', '青房证字第567123号', '青岛市市南区香港中路xxx小区9号楼902室', 2500000.00, '青岛银行', 'MORT202400010', 'REG202400010', '2023-10-10', '2023-10-15', '2043-10-14', '已抵押', NULL);

-- 3.9 儿童疫苗接种记录表（12条）
INSERT INTO child_vaccination_record_details (child_name, parent_name, parent_id_card, vaccine_name, vaccine_batch_no, vaccination_date, vaccination_location, dose_number, next_vaccination_date, manufacturer, administering_nurse, adverse_reaction) VALUES
                                                                                                                                                                                                                                                            ('张小宝', '张明', '11010119900307663X', '乙肝疫苗', 'HBV2024001', '2024-01-10', '朝阳区妇幼保健院', 1, '2024-02-10', '北京天坛生物', '王护士', '无'),
                                                                                                                                                                                                                                                            ('张小宝', '张明', '11010119900307663X', '卡介苗', 'BCG2024001', '2024-01-11', '朝阳区妇幼保健院', 1, NULL, '成都生物制品所', '王护士', '无'),
                                                                                                                                                                                                                                                            ('李小朵', '李芳', '310101198805124567', '脊灰灭活疫苗', 'IPV2024001', '2024-02-05', '浦东新区妇幼保健院', 1, '2024-03-05', '北京科兴', '张护士', '无'),
                                                                                                                                                                                                                                                            ('王小小', '王磊', '440301199210235678', '百白破疫苗', 'DTaP2024001', '2024-02-15', '南山区妇幼保健院', 1, '2024-04-15', '武汉生物制品所', '刘护士', '轻微发热'),
                                                                                                                                                                                                                                                            ('赵小静', '赵静', '51010719870714789X', '麻腮风疫苗', 'MMR2024001', '2024-01-20', '高新区妇幼保健院', 1, '2024-06-20', '上海生物制品所', '陈护士', '无'),
                                                                                                                                                                                                                                                            ('陈小强', '陈强', '320105199103156789', '流脑疫苗', 'MenA2024001', '2024-02-25', '西湖区妇幼保健院', 1, '2024-03-25', '兰州生物制品所', '李护士', '无'),
                                                                                                                                                                                                                                                            ('刘小娜', '刘娜', '350203199512019876', '乙脑疫苗', 'JE2024001', '2024-03-01', '思明区妇幼保健院', 1, '2024-04-01', '成都生物制品所', '黄护士', '无'),
                                                                                                                                                                                                                                                            ('周小涛', '周涛', '120101198608128765', '甲肝疫苗', 'HepA2024001', '2024-02-10', '和平区妇幼保健院', 1, '2024-08-10', '北京科兴', '孙护士', '无'),
                                                                                                                                                                                                                                                            ('吴小迪', '吴迪', '430103199311234321', '水痘疫苗', 'Var2024001', '2024-01-15', '岳麓区妇幼保健院', 1, '2024-07-15', '长春百克', '周护士', '无'),
                                                                                                                                                                                                                                                            ('郑小爽', '郑爽', '210203199403211234', '肺炎疫苗', 'PCV2024001', '2024-02-20', '中山区妇幼保健院', 1, '2024-04-20', '辉瑞', '赵护士', '无'),
                                                                                                                                                                                                                                                            ('林小晨', '林晨', '370202199707153456', '轮状病毒疫苗', 'RV2024001', '2024-03-05', '市南区妇幼保健院', 1, '2024-05-05', '默沙东', '王护士', '无'),
                                                                                                                                                                                                                                                            ('郭小峰', '郭峰', '500101198809194567', '手足口病疫苗', 'EV712024001', '2024-01-25', '渝中区妇幼保健院', 1, '2024-04-25', '北京科兴', '刘护士', '无');

-- 3.10 企业商业秘密登记表（8条）
INSERT INTO enterprise_trade_secret_registration (enterprise_name, secret_name, secret_type, secret_level, secret_content, creation_date, creator_name, access_scope, protection_measures, confidentiality_agreement, registration_authority, registration_no, registration_date) VALUES
                                                                                                                                                                                                                                                                                      ('云创科技股份有限公司', '数据安全态势感知核心算法', '技术秘密', '核心', '基于深度学习的异常检测算法，准确率达99.5%', '2023-05-10', '张明', '核心研发团队5人', '加密存储+权限管控+定期审计', '是', '北京市知识产权局', 'TS202400001', '2024-01-15'),
                                                                                                                                                                                                                                                                                      ('海纳数据安全有限公司', '敏感信息智能识别模型', '技术秘密', '核心', '基于NLP的敏感信息识别模型，支持20+种敏感数据类型', '2023-08-20', '李芳', '算法团队8人', '代码加密+访问日志审计', '是', '广东省知识产权局', 'TS202400002', '2024-02-10'),
                                                                                                                                                                                                                                                                                      ('智联信息技术集团', '客户关系管理系统架构', '经营秘密', '重要', '客户关系管理系统整体架构设计及数据模型', '2022-11-15', '王磊', '架构组+产品组12人', '内网隔离+权限分级', '是', '山东省知识产权局', 'TS202400003', '2024-01-20'),
                                                                                                                                                                                                                                                                                      ('星辰云计算有限公司', '弹性伸缩调度算法', '技术秘密', '核心', '基于预测的弹性伸缩调度算法，节省成本30%', '2023-03-25', '赵静', '云计算团队6人', '代码混淆+访问控制', '是', '湖北省知识产权局', 'TS202400004', '2024-02-05'),
                                                                                                                                                                                                                                                                                      ('安恒信息安全技术', '漏洞扫描特征库', '技术秘密', '重要', '包含5000+漏洞特征的扫描规则库', '2022-09-10', '陈强', '安全研究团队10人', '加密存储+定期备份', '是', '福建省知识产权局', 'TS202400005', '2024-01-25'),
                                                                                                                                                                                                                                                                                      ('致远软件科技', '项目管理方法论', '经营秘密', '一般', '敏捷项目管理流程与最佳实践', '2023-06-18', '刘娜', '项目管理部15人', '文档水印+权限管理', '是', '浙江省知识产权局', 'TS202400006', '2024-02-18'),
                                                                                                                                                                                                                                                                                      ('磐石区块链科技', '智能合约安全审计流程', '经营秘密', '重要', '智能合约安全审计SOP及检查清单', '2023-10-05', '周涛', '审计团队7人', '物理隔离+双重认证', '是', '吉林省知识产权局', 'TS202400007', '2024-01-30'),
                                                                                                                                                                                                                                                                                      ('天璇人工智能实验室', '大模型微调技术方案', '技术秘密', '核心', '大规模语言模型高效微调技术方案', '2024-01-08', '吴迪', 'AI研究团队5人', '加密传输+访问审计', '是', '北京市知识产权局', 'TS202400008', '2024-03-01');

-- =====================================================
-- 四、业务表数据
-- =====================================================

-- 4.1 客户服务工单处理记录表（12条）
INSERT INTO customer_service_ticket_processing_records (ticket_no, customer_name, customer_phone, service_type, priority_level, issue_description, processing_status, handler_name, processing_remark, resolve_time, customer_satisfaction) VALUES
                                                                                                                                                                                                                                                ('TK202403200001', '云创科技', '010-12345678', '技术咨询', '高', '系统部署遇到数据库连接问题', '已完成', '张三', '已协助配置数据库连接参数', '2025-03-20 16:30:00', 5),
                                                                                                                                                                                                                                                ('TK202403200002', '海纳数据', '021-87654321', '投诉', '高', '系统响应速度慢，影响业务使用', '处理中', '李四', '正在排查性能瓶颈', NULL, NULL),
                                                                                                                                                                                                                                                ('TK202403190003', '智联信息', '0755-23456789', '售后', '中', '需要升级到最新版本', '已完成', '王五', '已协助完成版本升级', '2025-03-19 17:00:00', 4),
                                                                                                                                                                                                                                                ('TK202403190004', '星辰云', '028-34567890', '咨询', '低', '产品功能介绍咨询', '已完成', '赵六', '已发送产品介绍文档', '2025-03-19 11:30:00', 5),
                                                                                                                                                                                                                                                ('TK202403180005', '安恒安全', '0571-45678901', '技术咨询', '中', 'API接口调用报错', '已完成', '钱七', '已修复接口参数问题', '2025-03-18 15:20:00', 4),
                                                                                                                                                                                                                                                ('TK202403180006', '致远软件', '0592-56789012', '投诉', '高', '数据统计结果不准确', '处理中', '孙八', '正在核对数据源', NULL, NULL),
                                                                                                                                                                                                                                                ('TK202403170007', '磐石区块链', '022-67890123', '售后', '中', '需要定制开发报表功能', '待处理', NULL, NULL, NULL, NULL),
                                                                                                                                                                                                                                                ('TK202403170008', '天璇AI', '0731-78901234', '咨询', '低', '询价和购买流程', '已完成', '周九', '已报价并发起采购流程', '2025-03-17 14:00:00', 5),
                                                                                                                                                                                                                                                ('TK202403160009', '昆仑金融', '0411-89012345', '技术咨询', '高', '系统与现有系统集成问题', '处理中', '吴十', '正在设计集成方案', NULL, NULL),
                                                                                                                                                                                                                                                ('TK202403160010', '华盾安全', '0532-90123456', '投诉', '中', '技术支持响应慢', '已完成', '郑十一', '已加强技术支持团队配置', '2025-03-16 18:00:00', 3),
                                                                                                                                                                                                                                                ('TK202403150011', '中国银行', '010-12345001', '咨询', '中', '产品安全认证咨询', '已完成', '王十二', '已提供安全认证材料', '2025-03-15 16:30:00', 5),
                                                                                                                                                                                                                                                ('TK202403150012', '华为技术', '0755-12345002', '售后', '高', '紧急故障需要处理', '处理中', '李十三', '正在紧急排查', NULL, NULL);

-- 4.2 商品库存盘点明细表（12条）
INSERT INTO product_inventory_stocktaking_details (product_code, product_name, theoretical_quantity, actual_quantity, difference_quantity, difference_reason, stocktaking_date, stocktaking_person, auditor_name, adjustment_status, adjustment_amount, remark) VALUES
                                                                                                                                                                                                                                                                    ('P10001', '数据安全态势感知平台', 1000, 999, -1, '已出库未记录', '2025-03-20', '张三', '李四', '已调整', -350000.00, '订单ORD202503200001'),
                                                                                                                                                                                                                                                                    ('P10002', '数据分类分级系统', 1000, 1000, 0, '无差异', '2025-03-20', '张三', '李四', '已调整', 0.00, '盘点准确'),
                                                                                                                                                                                                                                                                    ('P10003', '数据库审计系统', 1000, 997, -3, '已出库未记录', '2025-03-19', '王五', '赵六', '已调整', -540000.00, '订单ORD202503190003'),
                                                                                                                                                                                                                                                                    ('P10004', '数据脱敏系统', 1000, 999, -1, '已出库未记录', '2025-03-19', '王五', '赵六', '已调整', -220000.00, '订单ORD202503190004'),
                                                                                                                                                                                                                                                                    ('P10005', '数据安全评估服务', 1000, 998, -2, '已出库未记录', '2025-03-18', '钱七', '孙八', '已调整', -300000.00, '订单ORD202503180005'),
                                                                                                                                                                                                                                                                    ('P10006', '数据安全培训课程', 1000, 997, -3, '已出库未记录', '2025-03-18', '钱七', '孙八', '已调整', -150000.00, '订单ORD202503180006'),
                                                                                                                                                                                                                                                                    ('P10007', '数据安全咨询服务', 1000, 999, -1, '已出库未记录', '2025-03-17', '周九', '吴十', '已调整', -200000.00, '订单ORD202503170007'),
                                                                                                                                                                                                                                                                    ('P10008', '数据安全运维服务', 1000, 999, -1, '已出库未记录', '2025-03-17', '周九', '吴十', '已调整', -300000.00, '订单ORD202503170008'),
                                                                                                                                                                                                                                                                    ('P10009', '数据安全备份系统', 1000, 998, -2, '已出库未记录', '2025-03-16', '郑十一', '王十二', '已调整', -240000.00, '订单ORD202503160009'),
                                                                                                                                                                                                                                                                    ('P10010', '数据安全加密系统', 1000, 999, -1, '已出库未记录', '2025-03-16', '郑十一', '王十二', '已调整', -250000.00, '订单ORD202503160010'),
                                                                                                                                                                                                                                                                    ('P10011', '数据安全审计服务', 1000, 999, -1, '已出库未记录', '2025-03-15', '李十三', '张十四', '已调整', -180000.00, '订单ORD202503150011'),
                                                                                                                                                                                                                                                                    ('P10012', '数据安全合规平台', 1000, 998, -2, '已出库未记录', '2025-03-15', '李十三', '张十四', '已调整', -640000.00, '订单ORD202503150012');

-- 4.3 用户登录访问日志明细表（20条）
INSERT INTO user_login_access_log_details (username, login_ip, login_time, logout_time, session_duration_seconds, login_device, browser_info, login_status, fail_reason, request_uri, http_method) VALUES
                                                                                                                                                                                                       ('zhang_san', '192.168.1.101', '2025-03-20 09:00:00', '2025-03-20 11:30:00', 9000, 'Windows PC', 'Chrome 120.0', '成功', NULL, '/api/dashboard', 'GET'),
                                                                                                                                                                                                       ('li_si', '192.168.1.102', '2025-03-20 10:30:00', '2025-03-20 12:15:00', 6300, 'MacBook Pro', 'Safari 17.0', '成功', NULL, '/api/security/audit', 'GET'),
                                                                                                                                                                                                       ('wang_fang', '192.168.1.103', '2025-03-20 14:00:00', NULL, NULL, 'iPhone 15', 'Safari Mobile', '成功', NULL, '/api/data/classify', 'POST'),
                                                                                                                                                                                                       ('zhao_lei', '192.168.1.104', '2025-03-19 09:30:00', '2025-03-19 18:00:00', 30600, 'Windows PC', 'Edge 122.0', '成功', NULL, '/api/report/export', 'GET'),
                                                                                                                                                                                                       ('chen_na', '10.0.0.1', '2025-03-19 08:00:00', '2025-03-19 17:30:00', 34200, 'Ubuntu PC', 'Firefox 124.0', '成功', NULL, '/api/project/config', 'PUT'),
                                                                                                                                                                                                       ('liu_qiang', '10.0.0.2', '2025-03-18 09:15:00', '2025-03-18 18:00:00', 31500, 'Windows PC', 'Chrome 119.0', '成功', NULL, '/api/data/backup', 'GET'),
                                                                                                                                                                                                       ('huang_jing', '172.16.0.1', '2025-03-18 14:30:00', '2025-03-18 16:45:00', 8100, 'iPad', 'Safari', '失败', '密码错误', '/api/user/login', 'POST'),
                                                                                                                                                                                                       ('xu_wei', '172.16.0.2', '2025-03-17 10:00:00', '2025-03-17 19:00:00', 32400, 'Windows PC', 'Chrome 120.0', '成功', NULL, '/api/admin/users', 'GET'),
                                                                                                                                                                                                       ('sun_li', '192.168.1.110', '2025-03-17 11:20:00', '2025-03-17 17:30:00', 22200, 'MacBook Air', 'Safari 16.5', '成功', NULL, '/api/dashboard', 'GET'),
                                                                                                                                                                                                       ('zhou_jie', '192.168.1.111', '2025-03-16 08:30:00', '2025-03-16 12:00:00', 12600, 'Windows PC', 'Edge 121.0', '成功', NULL, '/api/data/mask', 'POST'),
                                                                                                                                                                                                       ('wu_di', '192.168.1.112', '2025-03-16 13:00:00', '2025-03-16 18:30:00', 19800, 'iPhone 14', 'Chrome Mobile', '失败', '账号锁定', '/api/user/login', 'POST'),
                                                                                                                                                                                                       ('zheng_shuang', '192.168.1.113', '2025-03-15 09:00:00', '2025-03-15 18:00:00', 32400, 'Windows PC', 'Chrome 118.0', '成功', NULL, '/api/security/report', 'GET'),
                                                                                                                                                                                                       ('lin_feng', '192.168.1.114', '2025-03-15 14:30:00', '2025-03-15 17:00:00', 9000, 'Android Phone', 'Chrome Mobile', '成功', NULL, '/api/data/classify', 'GET'),
                                                                                                                                                                                                       ('guo_jing', '192.168.1.115', '2025-03-14 10:00:00', '2025-03-14 19:30:00', 34200, 'MacBook Pro', 'Safari 17.0', '成功', NULL, '/api/order/list', 'GET'),
                                                                                                                                                                                                       ('tang_wei', '10.0.0.3', '2025-03-14 08:45:00', '2025-03-14 12:00:00', 11700, 'Windows PC', 'Firefox 123.0', '失败', '账户不存在', '/api/user/login', 'POST'),
                                                                                                                                                                                                       ('admin', '192.168.1.100', '2025-03-13 09:00:00', '2025-03-13 20:00:00', 39600, 'Windows PC', 'Chrome 120.0', '成功', NULL, '/api/admin/settings', 'PUT'),
                                                                                                                                                                                                       ('audit_admin', '192.168.1.101', '2025-03-13 10:30:00', '2025-03-13 16:30:00', 21600, 'Mac Mini', 'Safari 16.5', '成功', NULL, '/api/audit/logs', 'GET'),
                                                                                                                                                                                                       ('security_admin', '192.168.1.102', '2025-03-12 14:00:00', '2025-03-12 18:00:00', 14400, 'Windows PC', 'Edge 120.0', '成功', NULL, '/api/security/policy', 'PUT'),
                                                                                                                                                                                                       ('operator01', '10.0.0.1', '2025-03-12 08:30:00', '2025-03-12 17:30:00', 32400, 'Ubuntu PC', 'Chrome 119.0', '成功', NULL, '/api/data/mask', 'GET'),
                                                                                                                                                                                                       ('test_user', '192.168.1.200', '2025-03-11 15:00:00', NULL, NULL, 'Android Phone', 'Chrome Mobile', '失败', '用户已禁用', '/api/user/login', 'POST');

-- 4.4 促销活动参与记录表（12条）
INSERT INTO promotion_activity_participation_records (user_id, username, activity_code, activity_name, activity_type, participation_time, order_no, discount_amount, coupon_code, sharing_status, invitation_code) VALUES
                                                                                                                                                                                                                       (1, 'zhang_san', 'SPRING2025', '春季大促', '满减', '2025-03-20 10:00:00', 'ORD202503200001', 500.00, 'SP2025001', '是', 'INV001'),
                                                                                                                                                                                                                       (2, 'li_si', 'SPRING2025', '春季大促', '满减', '2025-03-20 11:30:00', 'ORD202503200002', 500.00, 'SP2025002', '否', NULL),
                                                                                                                                                                                                                       (3, 'wang_fang', 'NEWUSER2025', '新用户专享', '折扣', '2025-03-19 14:20:00', 'ORD202503190003', 5000.00, 'NEW2025001', '是', 'INV002'),
                                                                                                                                                                                                                       (4, 'zhao_lei', 'SECURITY2025', '安全产品特惠', '折扣', '2025-03-19 09:15:00', 'ORD202503190004', 3000.00, 'SEC2025001', '否', NULL),
                                                                                                                                                                                                                       (5, 'chen_na', 'BULK2025', '批量采购优惠', '满减', '2025-03-18 16:30:00', 'ORD202503180005', 5000.00, 'BULK2025001', '是', 'INV003'),
                                                                                                                                                                                                                       (6, 'liu_qiang', 'VIP2025', 'VIP专享折扣', '折扣', '2025-03-18 10:45:00', 'ORD202503180006', 1000.00, 'VIP2025001', '否', NULL),
                                                                                                                                                                                                                       (7, 'huang_jing', 'EARLY2025', '早鸟优惠', '固定金额', '2025-03-17 13:20:00', 'ORD202503170007', 3000.00, 'EARLY2025001', '是', 'INV004'),
                                                                                                                                                                                                                       (8, 'xu_wei', 'TEAM2025', '团队采购优惠', '满减', '2025-03-17 11:00:00', 'ORD202503170008', 8000.00, 'TEAM2025001', '否', NULL),
                                                                                                                                                                                                                       (9, 'sun_li', 'EDU2025', '教育行业优惠', '折扣', '2025-03-16 09:30:00', 'ORD202503160009', 5000.00, 'EDU2025001', '是', 'INV005'),
                                                                                                                                                                                                                       (10, 'zhou_jie', 'REF2025', '推荐有礼', '固定金额', '2025-03-16 14:50:00', 'ORD202503160010', 2000.00, 'REF2025001', '是', 'INV006'),
                                                                                                                                                                                                                       (11, 'wu_di', 'SPRING2025', '春季大促', '满减', '2025-03-15 11:25:00', 'ORD202503130016', 500.00, 'SP2025003', '否', NULL),
                                                                                                                                                                                                                       (12, 'zheng_shuang', 'ANN2025', '周年庆特惠', '折扣', '2025-03-15 09:00:00', 'ORD202503130017', 8000.00, 'ANN2025001', '是', 'INV007');

-- 4.5 系统性能监控指标数据表（15条）
INSERT INTO system_performance_monitoring_metrics_data (server_name, metric_type, metric_value, metric_unit, collect_time, threshold_value, alert_status, alert_message) VALUES
                                                                                                                                                                             ('web-server-01', 'CPU使用率', 45.5, '百分比', '2025-03-20 10:00:00', 80.0, '正常', NULL),
                                                                                                                                                                             ('web-server-01', '内存使用率', 62.3, '百分比', '2025-03-20 10:00:00', 85.0, '正常', NULL),
                                                                                                                                                                             ('web-server-01', '磁盘使用率', 58.7, '百分比', '2025-03-20 10:00:00', 90.0, '正常', NULL),
                                                                                                                                                                             ('db-server-01', 'CPU使用率', 78.2, '百分比', '2025-03-20 10:00:00', 80.0, '告警', 'CPU使用率接近阈值'),
                                                                                                                                                                             ('db-server-01', '内存使用率', 72.5, '百分比', '2025-03-20 10:00:00', 85.0, '正常', NULL),
                                                                                                                                                                             ('db-server-01', '磁盘使用率', 82.3, '百分比', '2025-03-20 10:00:00', 90.0, '正常', NULL),
                                                                                                                                                                             ('mq-server-01', 'CPU使用率', 35.8, '百分比', '2025-03-20 10:00:00', 80.0, '正常', NULL),
                                                                                                                                                                             ('mq-server-01', '内存使用率', 48.9, '百分比', '2025-03-20 10:00:00', 85.0, '正常', NULL),
                                                                                                                                                                             ('cache-server-01', 'CPU使用率', 28.4, '百分比', '2025-03-20 10:00:00', 80.0, '正常', NULL),
                                                                                                                                                                             ('cache-server-01', '内存使用率', 55.6, '百分比', '2025-03-20 10:00:00', 85.0, '正常', NULL),
                                                                                                                                                                             ('web-server-01', '网络流入', 125.8, 'MB/s', '2025-03-20 10:00:00', 200.0, '正常', NULL)
    ;



-- 1. 用户基本信息表
CREATE TABLE IF NOT EXISTS user_basic_information (
                                                      user_id INT AUTO_INCREMENT PRIMARY KEY,
                                                      username VARCHAR(50) NOT NULL UNIQUE,
                                                      full_name VARCHAR(100) NOT NULL,
                                                      email VARCHAR(100) NOT NULL UNIQUE,
                                                      phone_number VARCHAR(20),
                                                      date_of_birth DATE,
                                                      gender ENUM('Male', 'Female', 'Other', 'Prefer not to say'),
                                                      registration_date DATETIME DEFAULT CURRENT_TIMESTAMP,
                                                      last_login_time DATETIME,
                                                      account_status ENUM('Active', 'Inactive', 'Suspended', 'Deleted') DEFAULT 'Active'
);

INSERT INTO user_basic_information (username, full_name, email, phone_number, date_of_birth, gender, last_login_time) VALUES
                                                                                                                          ('john_doe', 'John Michael Doe', 'john.doe@example.com', '1234567890', '1985-05-15', 'Male', '2023-05-10 09:30:00'),
                                                                                                                          ('jane_smith', 'Jane Elizabeth Smith', 'jane.smith@example.com', '2345678901', '1990-11-22', 'Female', '2023-05-11 14:45:00'),
                                                                                                                          ('robert_jones', 'Robert Andrew Jones', 'robert.jones@example.com', '3456789012', '1978-03-08', 'Male', '2023-05-09 11:20:00'),
                                                                                                                          ('emily_wilson', 'Emily Grace Wilson', 'emily.wilson@example.com', '4567890123', '1995-07-30', 'Female', '2023-05-12 16:10:00'),
                                                                                                                          ('michael_brown', 'Michael James Brown', 'michael.brown@example.com', '5678901234', '1982-09-14', 'Male', '2023-05-08 13:50:00'),
                                                                                                                          ('sarah_johnson', 'Sarah Anne Johnson', 'sarah.johnson@example.com', '6789012345', '1988-02-18', 'Female', '2023-05-13 10:25:00'),
                                                                                                                          ('david_taylor', 'David William Taylor', 'david.taylor@example.com', '7890123456', '1975-12-05', 'Male', '2023-05-07 15:30:00'),
                                                                                                                          ('jessica_anderson', 'Jessica Marie Anderson', 'jessica.anderson@example.com', '8901234567', '1992-04-27', 'Female', '2023-05-14 11:40:00'),
                                                                                                                          ('thomas_martinez', 'Thomas Edward Martinez', 'thomas.martinez@example.com', '9012345678', '1980-08-11', 'Male', '2023-05-06 14:15:00'),
                                                                                                                          ('lisa_robinson', 'Lisa Catherine Robinson', 'lisa.robinson@example.com', '0123456789', '1986-01-19', 'Female', '2023-05-15 09:55:00');

-- 2. 用户地址信息表
CREATE TABLE IF NOT EXISTS user_address_details (
                                                    address_id INT AUTO_INCREMENT PRIMARY KEY,
                                                    user_id INT NOT NULL,
                                                    address_type ENUM('Home', 'Work', 'Billing', 'Shipping', 'Other'),
                                                    street_address VARCHAR(200) NOT NULL,
                                                    city VARCHAR(100) NOT NULL,
                                                    state_province VARCHAR(100),
                                                    postal_code VARCHAR(20),
                                                    country VARCHAR(100) NOT NULL,
                                                    is_primary BOOLEAN DEFAULT FALSE,
                                                    FOREIGN KEY (user_id) REFERENCES user_basic_information(user_id) ON DELETE CASCADE
);

INSERT INTO user_address_details (user_id, address_type, street_address, city, state_province, postal_code, country, is_primary) VALUES
                                                                                                                                     (1, 'Home', '123 Main St, Apt 4B', 'New York', 'NY', '10001', 'United States', TRUE),
                                                                                                                                     (1, 'Work', '456 Business Ave, Suite 200', 'New York', 'NY', '10002', 'United States', FALSE),
                                                                                                                                     (2, 'Home', '789 Oak Lane', 'Los Angeles', 'CA', '90001', 'United States', TRUE),
                                                                                                                                     (3, 'Home', '321 Pine Road', 'Chicago', 'IL', '60601', 'United States', TRUE),
                                                                                                                                     (4, 'Home', '654 Elm Street', 'Houston', 'TX', '77001', 'United States', TRUE),
                                                                                                                                     (5, 'Home', '987 Maple Drive', 'Phoenix', 'AZ', '85001', 'United States', TRUE),
                                                                                                                                     (6, 'Home', '741 Cedar Avenue', 'Philadelphia', 'PA', '19101', 'United States', TRUE),
                                                                                                                                     (7, 'Home', '852 Walnut Blvd', 'San Antonio', 'TX', '78201', 'United States', TRUE),
                                                                                                                                     (8, 'Home', '369 Birch Lane', 'San Diego', 'CA', '92101', 'United States', TRUE),
                                                                                                                                     (9, 'Home', '741 Spruce Road', 'Dallas', 'TX', '75201', 'United States', TRUE),
                                                                                                                                     (10, 'Home', '852 Oakwood Drive', 'San Jose', 'CA', '95101', 'United States', TRUE);

-- 3. 公司基本信息表
CREATE TABLE IF NOT EXISTS company_profile_details (
                                                       company_id INT AUTO_INCREMENT PRIMARY KEY,
                                                       company_name VARCHAR(200) NOT NULL UNIQUE,
                                                       legal_name VARCHAR(200),
                                                       business_type ENUM('Corporation', 'LLC', 'Partnership', 'Sole Proprietorship', 'Nonprofit', 'Government'),
                                                       industry VARCHAR(100),
                                                       tax_identification_number VARCHAR(50) UNIQUE,
                                                       registration_date DATE,
                                                       website_url VARCHAR(200),
                                                       is_active BOOLEAN DEFAULT TRUE
);

INSERT INTO company_profile_details (company_name, legal_name, business_type, industry, tax_identification_number, registration_date, website_url) VALUES
                                                                                                                                                       ('TechSolutions Inc.', 'TechSolutions Corporation', 'Corporation', 'Information Technology', '12-3456789', '2005-03-15', 'https://techsolutions.com'),
                                                                                                                                                       ('GreenEnergy LLC', 'GreenEnergy Solutions LLC', 'LLC', 'Renewable Energy', '23-4567890', '2010-07-22', 'https://greenenergy.com'),
                                                                                                                                                       ('GlobalRetail Partners', 'GlobalRetail Holdings Corporation', 'Corporation', 'Retail', '34-5678901', '1998-11-05', 'https://globalretail.com'),
                                                                                                                                                       ('HealthFirst Medical Group', 'HealthFirst Healthcare Services LLC', 'LLC', 'Healthcare', '45-6789012', '2015-02-18', 'https://healthfirst.com'),
                                                                                                                                                       ('FinancialAdvisors Inc.', 'FinancialAdvisors Corporation', 'Corporation', 'Financial Services', '56-7890123', '2008-09-30', 'https://financialadvisors.com'),
                                                                                                                                                       ('EducationExcel', 'Education Excellence Foundation', 'Nonprofit', 'Education', '67-8901234', '2012-05-14', 'https://educationexcel.org'),
                                                                                                                                                       ('ConstructionPros', 'Construction Professionals LLC', 'LLC', 'Construction', '78-9012345', '2003-12-10', 'https://constructionpros.com'),
                                                                                                                                                       ('TransportLogistics Inc.', 'Transport Logistics Solutions Corporation', 'Corporation', 'Transportation', '89-0123456', '2017-04-25', 'https://transportlogistics.com'),
                                                                                                                                                       ('ManufacturingMasters', 'Manufacturing Masters LLC', 'LLC', 'Manufacturing', '90-1234567', '2011-08-19', 'https://manufacturingmasters.com'),
                                                                                                                                                       ('HospitalityPlus', 'Hospitality Plus Corporation', 'Corporation', 'Hospitality', '01-2345678', '2019-01-07', 'https://hospitalityplus.com');

-- 4. 公司联系信息表
CREATE TABLE IF NOT EXISTS company_contact_information (
                                                           contact_id INT AUTO_INCREMENT PRIMARY KEY,
                                                           company_id INT NOT NULL,
                                                           contact_type ENUM('Main', 'Billing', 'Shipping', 'Customer Service', 'Technical Support', 'Sales'),
                                                           phone_number VARCHAR(20),
                                                           email VARCHAR(100),
                                                           address_line1 VARCHAR(200),
                                                           address_line2 VARCHAR(200),
                                                           city VARCHAR(100),
                                                           state_province VARCHAR(100),
                                                           postal_code VARCHAR(20),
                                                           country VARCHAR(100),
                                                           FOREIGN KEY (company_id) REFERENCES company_profile_details(company_id) ON DELETE CASCADE
);

INSERT INTO company_contact_information (company_id, contact_type, phone_number, email, address_line1, city, state_province, postal_code, country) VALUES
                                                                                                                                                       (1, 'Main', '555-123-4567', 'info@techsolutions.com', '100 Tech Park Blvd', 'San Francisco', 'CA', '94107', 'United States'),
                                                                                                                                                       (1, 'Customer Service', '555-123-4568', 'support@techsolutions.com', '100 Tech Park Blvd', 'San Francisco', 'CA', '94107', 'United States'),
                                                                                                                                                       (2, 'Main', '555-234-5678', 'info@greenenergy.com', '200 Renewable Way', 'Austin', 'TX', '78701', 'United States'),
                                                                                                                                                       (3, 'Main', '555-345-6789', 'info@globalretail.com', '300 Retail Plaza', 'Chicago', 'IL', '60601', 'United States'),
                                                                                                                                                       (4, 'Main', '555-456-7890', 'info@healthfirst.com', '400 Medical Center Dr', 'Boston', 'MA', '02108', 'United States'),
                                                                                                                                                       (5, 'Main', '555-567-8901', 'info@financialadvisors.com', '500 Finance Tower', 'New York', 'NY', '10001', 'United States'),
                                                                                                                                                       (6, 'Main', '555-678-9012', 'info@educationexcel.org', '600 Education Blvd', 'Washington', 'DC', '20001', 'United States'),
                                                                                                                                                       (7, 'Main', '555-789-0123', 'info@constructionpros.com', '700 Building Site Rd', 'Denver', 'CO', '80201', 'United States'),
                                                                                                                                                       (8, 'Main', '555-890-1234', 'info@transportlogistics.com', '800 Logistics Center', 'Seattle', 'WA', '98101', 'United States'),
                                                                                                                                                       (9, 'Main', '555-901-2345', 'info@manufacturingmasters.com', '900 Factory Ave', 'Detroit', 'MI', '48201', 'United States'),
                                                                                                                                                       (10, 'Main', '555-012-3456', 'info@hospitalityplus.com', '1000 Hospitality Ln', 'Orlando', 'FL', '32801', 'United States');

-- 5. 项目基本信息表
CREATE TABLE IF NOT EXISTS project_management_details (
                                                          project_id INT AUTO_INCREMENT PRIMARY KEY,
                                                          project_name VARCHAR(200) NOT NULL,
                                                          project_code VARCHAR(50) NOT NULL UNIQUE,
                                                          description TEXT,
                                                          start_date DATE,
                                                          estimated_end_date DATE,
                                                          actual_end_date DATE,
                                                          budget DECIMAL(15,2),
                                                          status ENUM('Planning', 'In Progress', 'On Hold', 'Completed', 'Cancelled'),
                                                          company_id INT NOT NULL,
                                                          project_manager_id INT,
                                                          FOREIGN KEY (company_id) REFERENCES company_profile_details(company_id) ON DELETE CASCADE,
                                                          FOREIGN KEY (project_manager_id) REFERENCES user_basic_information(user_id) ON DELETE SET NULL
);

INSERT INTO project_management_details (project_name, project_code, description, start_date, estimated_end_date, budget, status, company_id, project_manager_id) VALUES
                                                                                                                                                                     ('Website Redesign', 'PRJ-2023-001', 'Complete redesign of company website with new CMS', '2023-01-15', '2023-06-30', 50000.00, 'In Progress', 1, 1),
                                                                                                                                                                     ('Solar Farm Construction', 'PRJ-2023-002', 'Construction of 10MW solar farm in Texas', '2023-03-01', '2023-12-31', 15000000.00, 'In Progress', 2, 3),
                                                                                                                                                                     ('Store Expansion', 'PRJ-2023-003', 'Open 5 new retail stores across the Midwest', '2023-02-15', '2023-11-30', 2000000.00, 'In Progress', 3, 5),
                                                                                                                                                                     ('Electronic Health Records', 'PRJ-2023-004', 'Implementation of new EHR system', '2023-04-01', '2023-10-31', 750000.00, 'In Progress', 4, 7),
                                                                                                                                                                     ('Investment Platform Upgrade', 'PRJ-2023-005', 'Upgrade of online investment platform', '2023-01-10', '2023-07-15', 300000.00, 'Completed', 5, 9),
                                                                                                                                                                     ('Scholarship Program', 'PRJ-2023-006', 'Launch new scholarship program for underprivileged students', '2023-03-15', '2023-09-30', 100000.00, 'In Progress', 6, 2),
                                                                                                                                                                     ('Office Building Construction', 'PRJ-2023-007', 'Construct new 10-story office building', '2023-02-01', '2024-01-31', 5000000.00, 'In Progress', 7, 4),
                                                                                                                                                                     ('Fleet Management System', 'PRJ-2023-008', 'Implement new fleet tracking and management system', '2023-01-20', '2023-08-31', 250000.00, 'Completed', 8, 6),
                                                                                                                                                                     ('Production Line Automation', 'PRJ-2023-009', 'Automate key production lines to increase efficiency', '2023-03-10', '2023-12-15', 1200000.00, 'In Progress', 9, 8),
                                                                                                                                                                     ('Hotel Renovation', 'PRJ-2023-010', 'Complete renovation of 200-room hotel', '2023-04-15', '2023-11-30', 3000000.00, 'In Progress', 10, 10);

-- 6. 项目团队成员表
CREATE TABLE IF NOT EXISTS project_team_members (
                                                    team_member_id INT AUTO_INCREMENT PRIMARY KEY,
                                                    project_id INT NOT NULL,
                                                    user_id INT NOT NULL,
                                                    role VARCHAR(100) NOT NULL,
                                                    join_date DATE,
                                                    end_date DATE,
                                                    is_active BOOLEAN DEFAULT TRUE,
                                                    FOREIGN KEY (project_id) REFERENCES project_management_details(project_id) ON DELETE CASCADE,
                                                    FOREIGN KEY (user_id) REFERENCES user_basic_information(user_id) ON DELETE CASCADE,
                                                    UNIQUE KEY (project_id, user_id)
);

INSERT INTO project_team_members (project_id, user_id, role, join_date, end_date) VALUES
                                                                                      (1, 1, 'Project Manager', '2023-01-15', NULL),
                                                                                      (1, 2, 'Lead Developer', '2023-01-15', NULL),
                                                                                      (1, 3, 'UI/UX Designer', '2023-02-01', NULL),
                                                                                      (1, 4, 'QA Engineer', '2023-03-01', NULL),
                                                                                      (2, 3, 'Project Manager', '2023-03-01', NULL),
                                                                                      (2, 5, 'Civil Engineer', '2023-03-01', NULL),
                                                                                      (2, 6, 'Electrical Engineer', '2023-03-15', NULL),
                                                                                      (2, 7, 'Site Supervisor', '2023-04-01', NULL),
                                                                                      (3, 5, 'Project Manager', '2023-02-15', NULL),
                                                                                      (3, 8, 'Real Estate Specialist', '2023-02-15', NULL),
                                                                                      (3, 9, 'Construction Manager', '2023-03-01', NULL),
                                                                                      (3, 10, 'Interior Designer', '2023-04-01', NULL),
                                                                                      (4, 7, 'Project Manager', '2023-04-01', NULL),
                                                                                      (4, 1, 'IT Specialist', '2023-04-15', NULL),
                                                                                      (4, 2, 'Training Specialist', '2023-05-01', NULL),
                                                                                      (5, 9, 'Project Manager', '2023-01-10', '2023-07-15'),
                                                                                      (5, 3, 'Lead Developer', '2023-01-15', '2023-07-10'),
                                                                                      (5, 4, 'Security Specialist', '2023-02-01', '2023-07-05'),
                                                                                      (6, 2, 'Program Coordinator', '2023-03-15', NULL),
                                                                                      (6, 6, 'Financial Analyst', '2023-04-01', NULL),
                                                                                      (6, 8, 'Marketing Specialist', '2023-05-01', NULL);

-- 7. 薪酬结构表
CREATE TABLE IF NOT EXISTS compensation_structure (
                                                      compensation_id INT AUTO_INCREMENT PRIMARY KEY,
                                                      compensation_name VARCHAR(100) NOT NULL UNIQUE,
                                                      description TEXT,
                                                      base_salary_range_min DECIMAL(12,2),
                                                      base_salary_range_max DECIMAL(12,2),
                                                      bonus_percentage DECIMAL(5,2),
                                                      stock_options BOOLEAN DEFAULT FALSE,
                                                      health_benefits BOOLEAN DEFAULT TRUE,
                                                      retirement_benefits BOOLEAN DEFAULT TRUE,
                                                      other_benefits TEXT
);

INSERT INTO compensation_structure (compensation_name, description, base_salary_range_min, base_salary_range_max, bonus_percentage, stock_options, health_benefits, retirement_benefits, other_benefits) VALUES
                                                                                                                                                                                                             ('Entry Level Developer', 'Compensation package for entry-level software developers', 60000.00, 75000.00, 5.00, FALSE, TRUE, TRUE, 'Paid time off, professional development'),
                                                                                                                                                                                                             ('Senior Developer', 'Compensation package for senior software developers', 100000.00, 140000.00, 10.00, TRUE, TRUE, TRUE, 'Paid time off, professional development, flexible schedule'),
                                                                                                                                                                                                             ('Project Manager', 'Compensation package for IT project managers', 90000.00, 130000.00, 12.00, TRUE, TRUE, TRUE, 'Paid time off, professional development, bonus opportunities'),
                                                                                                                                                                                                             ('Executive', 'Compensation package for C-level executives', 200000.00, 500000.00, 25.00, TRUE, TRUE, TRUE, 'Executive benefits, company car, paid time off'),
                                                                                                                                                                                                             ('Sales Representative', 'Compensation package for sales professionals', 40000.00, 60000.00, 15.00, FALSE, TRUE, FALSE, 'Commission structure, performance bonuses'),
                                                                                                                                                                                                             ('Administrative Assistant', 'Compensation package for administrative staff', 35000.00, 50000.00, 2.00, FALSE, TRUE, TRUE, 'Paid time off, standard benefits'),
                                                                                                                                                                                                             ('Marketing Specialist', 'Compensation package for marketing professionals', 55000.00, 80000.00, 8.00, FALSE, TRUE, TRUE, 'Paid time off, professional development'),
                                                                                                                                                                                                             ('Financial Analyst', 'Compensation package for financial analysts', 70000.00, 100000.00, 10.00, TRUE, TRUE, TRUE, 'Paid time off, professional development');




-- 1. 企业基本信息表
CREATE TABLE enterprise_basic_information (
                                              enterprise_id INT AUTO_INCREMENT PRIMARY KEY,
                                              enterprise_name VARCHAR(100) NOT NULL,
                                              registration_number VARCHAR(50) UNIQUE NOT NULL,
                                              legal_representative VARCHAR(50) NOT NULL,
                                              registered_capital DECIMAL(15,2) NOT NULL,
                                              establishment_date DATE NOT NULL,
                                              business_scope TEXT,
                                              registered_address VARCHAR(200) NOT NULL,
                                              contact_phone VARCHAR(20) NOT NULL,
                                              enterprise_status ENUM('正常', '停业', '注销', '吊销') DEFAULT '正常',
                                              created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO enterprise_basic_information VALUES
                                             (1, '华夏科技有限公司', '91310101MA1FPX1234', '张伟', 5000000.00, '2010-05-15', '软件开发、系统集成、技术服务', '上海市浦东新区张江高科技园区', '021-12345678', '正常', NOW()),
                                             (2, '东方机械制造有限公司', '91310105MA1GQY5678', '李娜', 10000000.00, '2005-08-20', '机械设备制造、销售', '上海市闵行区经济技术开发区', '021-87654321', '正常', NOW()),
                                             (3, '环球贸易有限公司', '91310115MA1HRZ9012', '王强', 2000000.00, '2015-03-10', '进出口贸易、国内贸易', '上海市外高桥保税区', '021-55556666', '正常', NOW()),
                                             (4, '南方新能源科技有限公司', '91440300MA5FUT3456', '陈静', 8000000.00, '2018-11-05', '新能源技术研发、生产、销售', '深圳市南山区科技园', '0755-11223344', '正常', NOW()),
                                             (5, '北方建筑工程有限公司', '91110108MA01KLM789', '刘洋', 15000000.00, '2000-07-12', '建筑工程施工、装饰装修', '北京市朝阳区建国路', '010-66667777', '正常', NOW()),
                                             (6, '西部物流运输有限公司', '91610131MA6U123456', '赵敏', 3000000.00, '2012-09-18', '货物运输、仓储服务', '西安市高新区锦业路', '029-33334444', '正常', NOW()),
                                             (7, '中部农业发展有限公司', '91420106MA4K567890', '周杰', 5000000.00, '2016-04-22', '农产品种植、加工、销售', '武汉市东湖新技术开发区', '027-77778888', '正常', NOW()),
                                             (8, '海洋生物科技有限公司', '91370200MA3M901234', '吴磊', 6000000.00, '2019-02-14', '海洋生物制品研发、生产', '青岛市崂山区松岭路', '0532-88889999', '正常', NOW()),
                                             (9, '云端信息技术服务有限公司', '91500105MA5U345678', '郑浩', 4000000.00, '2017-07-30', '云计算服务、大数据分析', '重庆市渝北区黄山大道', '023-99990000', '正常', NOW()),
                                             (10, '智能机器人制造有限公司', '91330108MA2H567890', '王芳', 7000000.00, '2014-12-05', '工业机器人研发、生产', '杭州市滨江区江陵路', '0571-66667777', '正常', NOW());

-- 2. 企业股东信息表
CREATE TABLE enterprise_shareholder_information (
                                                    shareholder_id INT AUTO_INCREMENT PRIMARY KEY,
                                                    enterprise_id INT NOT NULL,
                                                    shareholder_name VARCHAR(100) NOT NULL,
                                                    shareholder_type ENUM('自然人', '法人') NOT NULL,
                                                    identification_number VARCHAR(50) NOT NULL,
                                                    share_ratio DECIMAL(5,2) NOT NULL,
                                                    contribution_amount DECIMAL(15,2) NOT NULL,
                                                    contribution_date DATE NOT NULL,
                                                    FOREIGN KEY (enterprise_id) REFERENCES enterprise_basic_information(enterprise_id)
);

INSERT INTO enterprise_shareholder_information VALUES
                                                   (1, 1, '张伟', '自然人', '310101198001011234', 60.00, 3000000.00, '2010-05-10'),
                                                   (2, 1, '上海投资集团有限公司', '法人', '91310101MA1FPX9876', 40.00, 2000000.00, '2010-05-10'),
                                                   (3, 2, '李娜', '自然人', '310105197505055678', 70.00, 7000000.00, '2005-08-15'),
                                                   (4, 2, '北京机械制造厂', '法人', '91110105MA01ABC123', 30.00, 3000000.00, '2005-08-15'),
                                                   (5, 3, '王强', '自然人', '310115198503039012', 51.00, 1020000.00, '2015-03-05'),
                                                   (6, 3, '深圳贸易有限公司', '法人', '91440300MA5FUVW321', 29.00, 580000.00, '2015-03-05'),
                                                   (7, 3, '广州进出口公司', '法人', '91440101MA5FUTSR45', 20.00, 400000.00, '2015-03-05'),
                                                   (8, 4, '陈静', '自然人', '440300198811053456', 40.00, 3200000.00, '2018-11-01'),
                                                   (9, 4, '南方科技投资基金', '法人', '91440300MA5FUTXYZ1', 30.00, 2400000.00, '2018-11-01'),
                                                   (10, 4, '深圳创新投资集团', '法人', '91440300MA5FUTABC2', 30.00, 2400000.00, '2018-11-01'),
                                                   (11, 5, '刘洋', '自然人', '110108197807077890', 55.00, 8250000.00, '2000-07-05'),
                                                   (12, 5, '北京建设集团', '法人', '91110108MA01KLM987', 45.00, 6750000.00, '2000-07-05'),
                                                   (13, 6, '赵敏', '自然人', '610131198209091234', 65.00, 1950000.00, '2012-09-10'),
                                                   (14, 6, '西安物流有限公司', '法人', '91610131MA6U123678', 35.00, 1050000.00, '2012-09-10'),
                                                   (15, 7, '周杰', '自然人', '420106198604045678', 70.00, 3500000.00, '2016-04-15'),
                                                   (16, 7, '武汉农业发展银行', '法人', '91420106MA4K567901', 30.00, 1500000.00, '2016-04-15'),
                                                   (17, 8, '吴磊', '自然人', '370200198902023456', 50.00, 3000000.00, '2019-02-05'),
                                                   (18, 8, '青岛海洋科技园', '法人', '91370200MA3M901456', 30.00, 1800000.00, '2019-02-05'),
                                                   (19, 8, '山东生物研究所', '法人', '91370100MA3M901678', 20.00, 1200000.00, '2019-02-05'),
                                                   (20, 9, '郑浩', '自然人', '500105198707077890', 60.00, 2400000.00, '2017-07-20'),
                                                   (21, 9, '重庆云计算中心', '法人', '91500105MA5U345890', 40.00, 1600000.00, '2017-07-20'),
                                                   (22, 10, '王芳', '自然人', '330108198412055678', 55.00, 3850000.00, '2014-11-25'),
                                                   (23, 10, '杭州智能科技园', '法人', '91330108MA2H567901', 45.00, 3150000.00, '2014-11-25');

-- 3. 企业财务年度报表
CREATE TABLE enterprise_annual_financial_reports (
                                                     report_id INT AUTO_INCREMENT PRIMARY KEY,
                                                     enterprise_id INT NOT NULL,
                                                     report_year YEAR NOT NULL,
                                                     total_assets DECIMAL(15,2) NOT NULL,
                                                     total_liabilities DECIMAL(15,2) NOT NULL,
                                                     owner_equity DECIMAL(15,2) NOT NULL,
                                                     operating_revenue DECIMAL(15,2) NOT NULL,
                                                     net_profit DECIMAL(15,2) NOT NULL,
                                                     tax_paid DECIMAL(15,2) NOT NULL,
                                                     report_date DATE NOT NULL,
                                                     UNIQUE (enterprise_id, report_year),
                                                     FOREIGN KEY (enterprise_id) REFERENCES enterprise_basic_information(enterprise_id)
);

INSERT INTO enterprise_annual_financial_reports VALUES
                                                    (1, 1, 2020, 15000000.00, 8000000.00, 7000000.00, 12000000.00, 2500000.00, 1800000.00, '2021-03-31'),
                                                    (2, 1, 2021, 18000000.00, 9000000.00, 9000000.00, 15000000.00, 3200000.00, 2200000.00, '2022-03-31'),
                                                    (3, 2, 2020, 25000000.00, 12000000.00, 13000000.00, 20000000.00, 4000000.00, 2800000.00, '2021-04-15'),
                                                    (4, 2, 2021, 28000000.00, 13000000.00, 15000000.00, 23000000.00, 4800000.00, 3200000.00, '2022-04-15'),
                                                    (5, 3, 2020, 5000000.00, 2000000.00, 3000000.00, 4500000.00, 800000.00, 500000.00, '2021-05-10'),
                                                    (6, 3, 2021, 6000000.00, 2500000.00, 3500000.00, 5200000.00, 1000000.00, 650000.00, '2022-05-10'),
                                                    (7, 4, 2020, 12000000.00, 6000000.00, 6000000.00, 9500000.00, 1800000.00, 1200000.00, '2021-06-20'),
                                                    (8, 4, 2021, 15000000.00, 7000000.00, 8000000.00, 12000000.00, 2500000.00, 1600000.00, '2022-06-20'),
                                                    (9, 5, 2020, 30000000.00, 18000000.00, 12000000.00, 25000000.00, 5000000.00, 3500000.00, '2021-07-05'),
                                                    (10, 5, 2021, 35000000.00, 20000000.00, 15000000.00, 28000000.00, 6000000.00, 4000000.00, '2022-07-05'),
                                                    (11, 6, 2020, 8000000.00, 4000000.00, 4000000.00, 6500000.00, 1200000.00, 800000.00, '2021-08-15'),
                                                    (12, 6, 2021, 9500000.00, 4500000.00, 5000000.00, 7500000.00, 1500000.00, 1000000.00, '2022-08-15'),
                                                    (13, 7, 2020, 10000000.00, 5000000.00, 5000000.00, 8000000.00, 1500000.00, 1000000.00, '2021-09-25'),
                                                    (14, 7, 2021, 12000000.00, 6000000.00, 6000000.00, 9500000.00, 1800000.00, 1200000.00, '2022-09-25'),
                                                    (15, 8, 2020, 15000000.00, 8000000.00, 7000000.00, 12000000.00, 2200000.00, 1500000.00, '2021-10-10'),
                                                    (16, 8, 2021, 18000000.00, 9000000.00, 9000000.00, 15000000.00, 2800000.00, 1800000.00, '2022-10-10'),
                                                    (17, 9, 2020, 9000000.00, 4500000.00, 4500000.00, 7200000.00, 1300000.00, 900000.00, '2021-11-20'),
                                                    (18, 9, 2021, 11000000.00, 5500000.00, 5500000.00, 9000000.00, 1700000.00, 1100000.00, '2022-11-20'),
                                                    (19, 10, 2020, 16000000.00, 8500000.00, 7500000.00, 13000000.00, 2400000.00, 1600000.00, '2021-12-05'),
                                                    (20, 10, 2021, 19000000.00, 9500000.00, 9500000.00, 16000000.00, 3000000.00, 2000000.00, '2022-12-05');

-- 4. 企业员工基本信息表
CREATE TABLE enterprise_employee_basic_info (
                                                employee_id INT AUTO_INCREMENT PRIMARY KEY,
                                                enterprise_id INT NOT NULL,
                                                employee_name VARCHAR(50) NOT NULL,
                                                gender ENUM('男', '女') NOT NULL,
                                                birth_date DATE NOT NULL,
                                                id_card_number VARCHAR(18) UNIQUE NOT NULL,
                                                mobile_phone VARCHAR(20) NOT NULL,
                                                email VARCHAR(100) NOT NULL,
                                                department VARCHAR(50) NOT NULL,
                                                position_title VARCHAR(50) NOT NULL,
                                                hire_date DATE NOT NULL,
                                                employment_status ENUM('在职', '离职', '休假', '停职') DEFAULT '在职',
                                                FOREIGN KEY (enterprise_id) REFERENCES enterprise_basic_information(enterprise_id)
);

INSERT INTO enterprise_employee_basic_info VALUES
                                               (1, 1, '张三', '男', '1990-05-15', '310101199005151234', '13800138001', 'zhangsan@example.com', '研发部', '高级软件工程师', '2015-07-10', '在职'),
                                               (2, 1, '李四', '女', '1992-08-20', '310101199208205678', '13800138002', 'lisi@example.com', '市场部', '市场经理', '2016-03-15', '在职'),
                                               (3, 1, '王五', '男', '1988-11-05', '310101198811059012', '13800138003', 'wangwu@example.com', '财务部', '财务主管', '2014-09-22', '在职'),
                                               (4, 1, '赵六', '女', '1995-02-14', '310101199502143456', '13800138004', 'zhaoliu@example.com', '人力资源部', 'HR专员', '2018-06-30', '在职'),
                                               (5, 1, '钱七', '男', '1985-07-30', '310101198507307890', '13800138005', 'qianqi@example.com', '技术部', '技术总监', '2012-04-05', '在职'),
                                               (6, 2, '孙八', '女', '1991-04-22', '310105199104221234', '13900139001', 'sunba@example.com', '生产部', '生产主管', '2017-08-18', '在职'),
                                               (7, 2, '周九', '男', '1989-09-10', '310105198909105678', '13900139002', 'zhoujiu@example.com', '质检部', '质检经理', '2015-11-25', '在职'),
                                               (8, 2, '吴十', '女', '1993-12-05', '310105199312059012', '13900139003', 'wushi@example.com', '采购部', '采购专员', '2019-02-14', '在职'),
                                               (9, 2, '郑十一', '男', '1987-03-30', '310105198703303456', '13900139004', 'zhengshiyi@example.com', '研发部', '研发工程师', '2014-07-15', '在职'),
                                               (10, 2, '王十二', '女', '1994-06-15', '310105199406157890', '13900139005', 'wangshier@example.com', '行政部', '行政助理', '2018-09-20', '在职'),
                                               (11, 3, '刘十三', '男', '1990-10-10', '310115199010101234', '13700137001', 'liushisan@example.com', '销售部', '销售经理', '2016-05-12', '在职'),
                                               (12, 3, '陈十四', '女', '1992-01-25', '310115199201255678', '13700137002', 'chenshisi@example.com', '客服部', '客服主管', '2017-09-08', '在职'),
                                               (13, 3, '杨十五', '男', '1988-07-18', '310115198807189012', '13700137003', 'yangshiwu@example.com', '物流部', '物流经理', '2015-03-22', '在职'),
                                               (14, 3, '黄十六', '女', '1993-11-30', '310115199311303456', '13700137004', 'huangshiliu@example.com', '财务部', '会计', '2019-04-15', '在职'),
                                               (15, 3, '徐十七', '男', '1986-04-05', '310115198604057890', '13700137005', 'xushiqi@example.com', '市场部', '市场专员', '214-08-10', '在职'),
                                               (16, 4, '马十八', '女', '1991-08-22', '440300199108221234', '13600136001', 'mashiba@example.com', '研发部', '研发主管', '2017-11-05', '在职'),
                                               (17, 4, '朱十九', '男', '1989-03-15', '440300198903155678', '13600136002', 'zhushijiu@example.com', '生产部', '生产经理', '2015-06-20', '在职');



-- 1. 用户基本信息表
CREATE TABLE IF NOT EXISTS user_personal_information (
                                                         user_id INT AUTO_INCREMENT PRIMARY KEY,
                                                         username VARCHAR(50) NOT NULL UNIQUE,
                                                         full_name VARCHAR(100) NOT NULL,
                                                         date_of_birth DATE,
                                                         gender ENUM('Male', 'Female', 'Other'),
                                                         email VARCHAR(100) NOT NULL UNIQUE,
                                                         phone_number VARCHAR(20),
                                                         address VARCHAR(200),
                                                         registration_date DATETIME DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO user_personal_information (username, full_name, date_of_birth, gender, email, phone_number, address) VALUES
                                                                                                                     ('john_doe123', 'John Michael Doe', '1985-05-15', 'Male', 'john.doe@example.com', '1234567890', '123 Main St, Anytown'),
                                                                                                                     ('jane_smith456', 'Jane Elizabeth Smith', '1990-11-22', 'Female', 'jane.smith@example.com', '2345678901', '456 Oak Ave, Somewhere'),
                                                                                                                     ('bob_johnson789', 'Robert William Johnson', '1978-03-08', 'Male', 'bob.johnson@example.com', '3456789012', '789 Pine Rd, Nowhere'),
                                                                                                                     ('alice_brown321', 'Alice Mary Brown', '1992-07-30', 'Female', 'alice.brown@example.com', '4567890123', '321 Elm Blvd, Anywhere'),
                                                                                                                     ('mike_wilson654', 'Michael Andrew Wilson', '1988-02-14', 'Male', 'mike.wilson@example.com', '5678901234', '654 Cedar Ln, Somewhere'),
                                                                                                                     ('sarah_jones987', 'Sarah Louise Jones', '1995-09-18', 'Female', 'sarah.jones@example.com', '6789012345', '987 Maple Dr, Nowhere'),
                                                                                                                     ('david_miller246', 'David James Miller', '1982-04-25', 'Male', 'david.miller@example.com', '7890123456', '246 Birch Ct, Anywhere'),
                                                                                                                     ('emily_davis579', 'Emily Grace Davis', '1991-12-03', 'Female', 'emily.davis@example.com', '8901234567', '579 Oakwood Ave, Somewhere'),
                                                                                                                     ('tom_garcia813', 'Thomas Edward Garcia', '1979-06-11', 'Male', 'tom.garcia@example.com', '9012345678', '813 Pinecrest Rd, Nowhere'),
                                                                                                                     ('lisa_martinez468', 'Lisa Ann Martinez', '1987-08-19', 'Female', 'lisa.martinez@example.com', '0123456789', '468 Elmwood Blvd, Anywhere');

-- 2. 公司基本信息表
CREATE TABLE IF NOT EXISTS company_basic_details (
                                                     company_id INT AUTO_INCREMENT PRIMARY KEY,
                                                     company_name VARCHAR(100) NOT NULL UNIQUE,
                                                     industry_type VARCHAR(50),
                                                     founded_year YEAR,
                                                     headquarters_location VARCHAR(100),
                                                     number_of_employees INT,
                                                     annual_revenue DECIMAL(15,2),
                                                     website_url VARCHAR(100),
                                                     is_active BOOLEAN DEFAULT TRUE
);

INSERT INTO company_basic_details (company_name, industry_type, founded_year, headquarters_location, number_of_employees, annual_revenue, website_url) VALUES
                                                                                                                                                           ('TechSolutions Inc.', 'Information Technology', 1995, 'San Francisco, CA', 1200, 250000000.00, 'www.techsolutions.com'),
                                                                                                                                                           ('GlobalManufacturing Co.', 'Manufacturing', 1980, 'Detroit, MI', 5000, 750000000.00, 'www.globalmfg.com'),
                                                                                                                                                           ('HealthCare Services Ltd.', 'Healthcare', 2005, 'Boston, MA', 800, 150000000.00, 'www.healthcareservices.com'),
                                                                                                                                                           ('FinancialAdvisors Group', 'Finance', 1990, 'New York, NY', 600, 180000000.00, 'www.financialadvisors.com'),
                                                                                                                                                           ('RetailGiant Stores', 'Retail', 1975, 'Chicago, IL', 10000, 1200000000.00, 'www.retailgiant.com'),
                                                                                                                                                           ('EducationOnline Platform', 'Education', 2010, 'Austin, TX', 300, 50000000.00, 'www.educationonline.com'),
                                                                                                                                                           ('TransportLogistics Corp.', 'Transportation', 1985, 'Seattle, WA', 1500, 200000000.00, 'www.transportlogistics.com'),
                                                                                                                                                           ('EnergySolutions Power', 'Energy', 2000, 'Houston, TX', 900, 300000000.00, 'www.energysolutions.com'),
                                                                                                                                                           ('FoodDelight Restaurants', 'Food Services', 1998, 'Miami, FL', 2000, 120000000.00, 'www.fooddelight.com'),
                                                                                                                                                           ('ConstructionExperts Inc.', 'Construction', 1982, 'Denver, CO', 750, 90000000.00, 'www.constructionexperts.com');

-- 3. 项目基本信息表
CREATE TABLE IF NOT EXISTS project_management_details (
                                                          project_id INT AUTO_INCREMENT PRIMARY KEY,
                                                          project_name VARCHAR(100) NOT NULL,
                                                          company_id INT,
                                                          project_manager_id INT,
                                                          start_date DATE,
                                                          estimated_end_date DATE,
                                                          actual_end_date DATE NULL,
                                                          budget DECIMAL(15,2),
                                                          current_status ENUM('Planning', 'In Progress', 'On Hold', 'Completed', 'Cancelled'),
                                                          description TEXT,
                                                          FOREIGN KEY (company_id) REFERENCES company_basic_details(company_id),
                                                          FOREIGN KEY (project_manager_id) REFERENCES user_personal_information(user_id)
);

INSERT INTO project_management_details (project_name, company_id, project_manager_id, start_date, estimated_end_date, actual_end_date, budget, current_status, description) VALUES
                                                                                                                                                                                ('Website Redesign Project', 1, 1, '2023-01-15', '2023-06-30', NULL, 75000.00, 'In Progress', 'Complete redesign of company website with new CMS'),
                                                                                                                                                                                ('New Product Launch', 2, 3, '2023-03-01', '2023-11-30', NULL, 500000.00, 'In Progress', 'Launch of new line of industrial equipment'),
                                                                                                                                                                                ('Electronic Health Records System', 3, 5, '2022-11-01', '2023-10-31', NULL, 250000.00, 'In Progress', 'Implementation of new EHR system across all clinics'),
                                                                                                                                                                                ('Financial Planning Software', 4, 7, '2023-02-15', '2023-08-31', NULL, 120000.00, 'In Progress', 'Development of client financial planning application'),
                                                                                                                                                                                ('Store Expansion Project', 5, 9, '2023-04-01', '2024-03-31', NULL, 1000000.00, 'In Progress', 'Open 10 new retail locations across the country'),
                                                                                                                                                                                ('Online Course Platform Upgrade', 6, 2, '2023-01-10', '2023-05-15', '2023-05-10', 60000.00, 'Completed', 'Upgrade to support more concurrent users and new features'),
                                                                                                                                                                                ('Fleet Management System', 7, 4, '2022-10-15', '2023-04-30', '2023-04-28', 180000.00, 'Completed', 'Implementation of GPS tracking for all vehicles'),
                                                                                                                                                                                ('Renewable Energy Project', 8, 6, '2023-03-20', '2024-02-28', NULL, 350000.00, 'In Progress', 'Construction of new solar farm in Texas'),
                                                                                                                                                                                ('Menu Revamp Initiative', 9, 8, '2023-02-01', '2023-07-31', NULL, 90000.00, 'In Progress', 'Update menu items and introduce healthier options'),
                                                                                                                                                                                ('Office Building Construction', 10, 10, '2022-12-01', '2024-05-31', NULL, 2500000.00, 'In Progress', 'Construction of new 10-story office building');

-- 4. 员工职位表
CREATE TABLE IF NOT EXISTS employee_job_positions (
                                                      position_id INT AUTO_INCREMENT PRIMARY KEY,
                                                      position_title VARCHAR(100) NOT NULL,
                                                      department VARCHAR(50),
                                                      reports_to_position_id INT NULL,
                                                      min_salary DECIMAL(12,2),
                                                      max_salary DECIMAL(12,2),
                                                      job_description TEXT,
                                                      is_management_role BOOLEAN DEFAULT FALSE
);

INSERT INTO employee_job_positions (position_title, department, reports_to_position_id, min_salary, max_salary, job_description, is_management_role) VALUES
                                                                                                                                                         ('Software Engineer', 'Engineering', NULL, 80000.00, 120000.00, 'Develop and maintain software applications', FALSE),
                                                                                                                                                         ('Senior Software Engineer', 'Engineering', 1, 110000.00, 150000.00, 'Lead software development projects and mentor junior engineers', FALSE),
                                                                                                                                                         ('Engineering Manager', 'Engineering', NULL, 130000.00, 180000.00, 'Manage engineering team and project delivery', TRUE),
                                                                                                                                                         ('Product Manager', 'Product Management', NULL, 100000.00, 140000.00, 'Define product vision and roadmap', TRUE),
                                                                                                                                                         ('UX Designer', 'Design', NULL, 75000.00, 110000.00, 'Create user-centered designs for digital products', FALSE),
                                                                                                                                                         ('Marketing Specialist', 'Marketing', NULL, 65000.00, 95000.00, 'Execute marketing campaigns and strategies', FALSE),
                                                                                                                                                         ('Marketing Director', 'Marketing', NULL, 120000.00, 170000.00, 'Lead marketing team and strategy', TRUE),
                                                                                                                                                         ('Financial Analyst', 'Finance', NULL, 70000.00, 100000.00, 'Analyze financial data and prepare reports', FALSE),
                                                                                                                                                         ('HR Generalist', 'Human Resources', NULL, 60000.00, 90000.00, 'Handle various HR functions including recruitment and benefits', FALSE),
                                                                                                                                                         ('HR Manager', 'Human Resources', NULL, 90000.00, 130000.00, 'Manage HR department and policies', TRUE);

-- 5. 员工雇佣信息表
CREATE TABLE IF NOT EXISTS employee_employment_records (
                                                           employment_id INT AUTO_INCREMENT PRIMARY KEY,
                                                           user_id INT NOT NULL,
                                                           company_id INT NOT NULL,
                                                           position_id INT NOT NULL,
                                                           hire_date DATE NOT NULL,
                                                           termination_date DATE NULL,
                                                           employment_status ENUM('Full-time', 'Part-time', 'Contract', 'Intern', 'Terminated'),
                                                           work_location VARCHAR(100),
                                                           reports_to_user_id INT NULL,
                                                           FOREIGN KEY (user_id) REFERENCES user_personal_information(user_id),
                                                           FOREIGN KEY (company_id) REFERENCES company_basic_details(company_id),
                                                           FOREIGN KEY (position_id) REFERENCES employee_job_positions(position_id),
                                                           FOREIGN KEY (reports_to_user_id) REFERENCES user_personal_information(user_id)
);

INSERT INTO employee_employment_records (user_id, company_id, position_id, hire_date, termination_date, employment_status, work_location, reports_to_user_id) VALUES
                                                                                                                                                                  (1, 1, 3, '2018-06-15', NULL, 'Full-time', 'San Francisco, CA', NULL),
                                                                                                                                                                  (2, 1, 4, '2019-03-10', NULL, 'Full-time', 'San Francisco, CA', 1),
                                                                                                                                                                  (3, 2, 1, '2020-01-20', NULL, 'Full-time', 'Detroit, MI', NULL),
                                                                                                                                                                  (4, 2, 2, '2021-05-05', NULL, 'Full-time', 'Detroit, MI', 3),
                                                                                                                                                                  (5, 3, 7, '2017-11-15', NULL, 'Full-time', 'Boston, MA', NULL),
                                                                                                                                                                  (6, 3, 6, '2022-02-28', NULL, 'Full-time', 'Boston, MA', 5),
                                                                                                                                                                  (7, 4, 8, '2019-09-10', NULL, 'Full-time', 'New York, NY', NULL),
                                                                                                                                                                  (8, 4, 9, '2020-07-22', NULL, 'Full-time', 'New York, NY', 7),
                                                                                                                                                                  (9, 5, 1, '2021-04-01', NULL, 'Full-time', 'Chicago, IL', NULL),
                                                                                                                                                                  (10, 5, 5, '2022-03-15', NULL, 'Full-time', 'Chicago, IL', 9);

-- 6. 薪酬结构表
CREATE TABLE IF NOT EXISTS compensation_structure (
                                                      compensation_id INT AUTO_INCREMENT PRIMARY KEY,
                                                      position_id INT NOT NULL,
                                                      base_salary DECIMAL(12,2) NOT NULL,
                                                      bonus_percentage DECIMAL(5,2) DEFAULT 0.00,
                                                      stock_options INT DEFAULT 0,
                                                      health_benefits BOOLEAN DEFAULT TRUE,
                                                      retirement_plan BOOLEAN DEFAULT TRUE,
                                                      other_benefits TEXT,
                                                      FOREIGN KEY (position_id) REFERENCES employee_job_positions(position_id)
);

INSERT INTO compensation_structure (position_id, base_salary, bonus_percentage, stock_options, health_benefits, retirement_plan, other_benefits) VALUES
                                                                                                                                                     (1, 95000.00, 10.00, 500, TRUE, TRUE, 'Gym membership, paid time off'),
                                                                                                                                                     (2, 125000.00, 15.00, 1000, TRUE, TRUE, 'Gym membership, paid time off, conference budget'),
                                                                                                                                                     (3, 150000.00, 20.00, 2000, TRUE, TRUE, 'Car allowance, paid time off, conference budget'),
                                                                                                                                                     (4, 120000.00, 15.00, 1500, TRUE, TRUE, 'Paid time off, conference budget'),
                                                                                                                                                     (5, 90000.00, 10.00, 0, TRUE, TRUE, 'Paid time off'),
                                                                                                                                                     (6, 80000.00, 10.00, 0, TRUE, TRUE, 'Paid time off'),
                                                                                                                                                     (7, 140000.00, 20.00, 2500, TRUE, TRUE, 'Car allowance, paid time off, conference budget'),
                                                                                                                                                     (8, 85000.00, 10.00, 0, TRUE, TRUE, 'Paid time off'),
                                                                                                                                                     (9, 75000.00, 5.00, 0, TRUE, TRUE, 'Paid time off'),
                                                                                                                                                     (10, 110000.00, 15.00, 1000, TRUE, TRUE, 'Paid time off, conference budget');

-- 7. 财务交易记录表
CREATE TABLE IF NOT EXISTS financial_transaction_records (
                                                             transaction_id INT AUTO_INCREMENT PRIMARY KEY,
                                                             company_id INT NOT NULL,
                                                             transaction_date DATETIME DEFAULT CURRENT_TIMESTAMP,
                                                             transaction_type ENUM('Revenue', 'Expense', 'Investment', 'Loan', 'Payment'),
                                                             amount DECIMAL(15,2) NOT NULL,
                                                             description TEXT,
                                                             related_project_id INT NULL,
                                                             processed_by_user_id INT NULL,
                                                             FOREIGN KEY (company_id) REFERENCES company_basic_details(company_id),
                                                             FOREIGN KEY (related_project_id) REFERENCES project_management_details(project_id),
                                                             FOREIGN KEY (processed_by_user_id) REFERENCES user_personal_information(user_id)
);

INSERT INTO financial_transaction_records (company_id, transaction_type, amount, description, related_project_id, processed_by_user_id) VALUES
                                                                                                                                            (1, 'Revenue', 250000.00, 'Software license sales', NULL, 1),
                                                                                                                                            (1, 'Expense', 75000.00, 'Website redesign project payment', 1, 1),
                                                                                                                                            (2, 'Revenue', 5000000.00, 'Industrial equipment sales', NULL, 3),
                                                                                                                                            (2, 'Expense', 500000.00, 'New product launch expenses', 2, 3),
                                                                                                                                            (3, 'Revenue', 1200000.00, 'Patient services revenue', NULL, 5),
                                                                                                                                            (3, 'Expense', 250000.00, 'EHR system implementation payment', 3, 5),
                                                                                                                                            (4, 'Revenue', 850000.00, 'Financial planning fees', NULL, 7),
                                                                                                                                            (4, 'Expense', 120000.00, 'Software development costs', 4, 7),
                                                                                                                                            (5, 'Revenue', 12000000.00, 'Retail sales revenue', NULL, 9),
                                                                                                                                            (5, 'Expense', 1000000.00, 'Store expansion project costs', 5, 9);

-- 8. 员工绩效评估表
CREATE TABLE IF NOT EXISTS employee_performance_reviews (
                                                            review_id INT AUTO_INCREMENT PRIMARY KEY,
                                                            employment_id INT NOT NULL,
                                                            review_date DATE NOT NULL,
                                                            performance_rating ENUM('Exceeds Expectations', 'Meets Expectations', 'Needs Improvement', 'Unsatisfactory'),
                                                            strengths TEXT,
                                                            areas_for_improvement TEXT,
                                                            development_plan TEXT,
                                                            next_review_date DATE,
                                                            reviewed_by_user_id INT NOT NULL,
                                                            FOREIGN KEY (employment_id) REFERENCES employee_employment_records(employment_id),
                                                            FOREIGN KEY (reviewed_by_user_id) REFERENCES user_personal_information(user_id)
);

INSERT INTO employee_performance_reviews (employment_id, review_date, performance_rating, strengths, areas_for_improvement, development_plan, next_review_date, reviewed_by_user_id) VALUES
                                                                                                                                                                                         (1, '2023-01-15', 'Exceeds Expectations', 'Consistently delivers high-quality work ahead of schedule', 'Could work on delegating tasks more effectively', 'Attend leadership training program', '2023-07-15', 1),
                                                                                                                                                                                         (2, '2023-01-20', 'Meets Expectations', 'Strong product vision and execution', 'Needs to improve stakeholder communication', 'Work with communication coach', '2023-07-20', 1),
                                                                                                                                                                                         (3, '2023-02-05', 'Meets Expectations', 'Reliable and produces quality code', 'Could be more proactive in suggesting improvements', 'Encouraged to attend more industry conferences', '2023-08-05', 3),
                                                                                                                                                                                         (4, '2023-02-10', 'Exceeds Expectations', 'Exceptional technical skills and mentorship', 'None identified', 'Continue current professional development', '2023-08-10', 3),
                                                                                                                                                                                         (5, '2023-03-15', 'Meets Expectations', 'Strong clinical knowledge and patient care', 'Could improve documentation practices', 'Additional EHR system training', '2023-09-15', 5),
                                                                                                                                                                                         (6, '2023-03-20', 'Exceeds Expectations', 'Excellent patient interaction skills', 'None identified', 'Continue current professional development', '2023-09-20', 5),
                                                                                                                                                                                         (7, '2023-04-10', 'Meets Expectations', 'Good financial analysis skills', 'Could work on presenting findings more clearly', 'Presentation skills training', '2023-10-10', 7),
                                                                                                                                                                                         (8, '2023-04-15', 'Exceeds Expectations', 'Exceptional organizational skills', 'None identified', 'Continue current professional development', '2023-10-15', 7),
                                                                                                                                                                                         (9, '2023-05-05', 'Meets Expectations', 'Strong retail operations knowledge', 'Could improve staff management skills', 'Management training program', '2023-11-05', 9),
                                                                                                                                                                                         (10, '2023-05-10', 'Exceeds Expectations', 'Excellent visual design skills', 'None identified', 'Continue current professional development', '2023-11-10', 9);

-- 9. 项目里程碑表
CREATE TABLE IF NOT EXISTS project_milestones_tracking (
                                                           milestone_id INT AUTO_INCREMENT PRIMARY KEY,
                                                           project_id INT NOT NULL,
                                                           milestone_name VARCHAR(100) NOT NULL,
                                                           planned_completion_date DATE NOT NULL,
                                                           actual_completion_date DATE NULL,
                                                           status ENUM('Not Started', 'In Progress', 'Completed', 'Delayed'),
                                                           description TEXT,
                                                           responsible_user_id INT NOT NULL,
                                                           FOREIGN KEY (project_id) REFERENCES project_management_details(project_id),
                                                           FOREIGN KEY (responsible_user_id) REFERENCES user_personal_information(user_id)
);

INSERT INTO project_milestones_tracking (project_id, milestone_name, planned_completion_date, actual_completion_date, status, description, responsible_user_id) VALUES
                                                                                                                                                                    (1, 'Design Phase Completion', '2023-02-28', '2023-02-25', 'Completed', 'Finalize all design mockups and specifications', 2),
                                                                                                                                                                    (1, 'Development Sprint 1', '2023-03-31', '2023-03-28', 'Completed', 'Complete core functionality development', 1),
                                                                                                                                                                    (1, 'Development Sprint 2', '2023-04-30', '2023-04-28', 'Completed', 'Complete remaining features and integrations', 1),
                                                                                                                                                                    (1, 'User Acceptance Testing', '2023-05-31', '2023-05-25', 'Completed', 'Conduct UAT with stakeholders', 2),
                                                                                                                                                                    (2, 'Product Design Finalization', '2023-05-31', NULL, 'In Progress', 'Finalize product design and specifications', 4),
                                                                                                                                                                    (2, 'Prototype Development', '2023-08-31', NULL, 'In Progress', 'Build and test functional prototype', 3),
                                                                                                                                                                    (2, 'Pilot Production Run', '2023-10-31', NULL, 'In Progress', 'Run pilot production and quality testing', 3),
                                                                                                                                                                    (3, 'Vendor Selection', '2023-02-28', '2023-02-28', 'Completed', 'Select EHR system vendor', 6),
                                                                                                                                                                    (3, 'System Configuration', '2023-05-31', '2023-05-25', 'Completed', 'Configure system to meet clinic needs', 5),
                                                                                                                                                                    (3, 'Data Migration', '2023-07-31', NULL, 'In Progress', 'Migrate existing patient data to new system', 6);

-- 10. 培训与发展记录表
CREATE TABLE IF NOT EXISTS training_and_development_records (
                                                                training_id INT AUTO_INCREMENT PRIMARY KEY,
                                                                user_id INT NOT NULL,
                                                                training_program_name VARCHAR(100) NOT NULL,
                                                                start_date DATE NOT NULL,
                                                                end_date DATE NOT NULL,
                                                                training_type ENUM('Technical', 'Soft Skills', 'Compliance', 'Leadership', 'Product'),
                                                                status ENUM('Scheduled', 'In Progress', 'Completed', 'Cancelled'),
                                                                cost DECIMAL(10,2) DEFAULT 0.00,
                                                                description TEXT,
                                                                FOREIGN KEY (user_id) REFERENCES user_personal_information(user_id)
);

INSERT INTO training_and_development_records (user_id, training_program_name, start_date, end_date, training_type, status, cost, description) VALUES
                                                                                                                                                  (1, 'Advanced Leadership Program', '2023-06-01', '2023-08-31', 'Leadership', 'In Progress', 5000.00, 'Comprehensive leadership development program'),
                                                                                                                                                  (2, 'Effective Presentation Skills', '2023-05-15', '2023-05-16', 'Soft Skills', 'Completed', 800.00, 'Two-day workshop on presentation techniques'),
                                                                                                                                                  (3, 'New Programming Language', '2023-07-01', '2023-07-31', 'Technical', 'Scheduled', 1200.00, 'Online course on latest programming language'),
                                                                                                                                                  (4, 'Mentoring Skills Workshop', '2023-06-10', '2023-06-11', 'Soft Skills', 'Scheduled', 600.00, 'Workshop on effective mentoring techniques'),
                                                                                                                                                  (5, 'Healthcare Compliance Update', '2023-04-20', '2023-04-20', 'Compliance', 'Completed', 300.00, 'Annual compliance training update'),
                                                                                                                                                  (6, 'Patient Communication Skills', '2023-05-01', '2023-05-02', 'Soft Skills', 'Completed', 700.00, 'Workshop on effective patient communication'),
                                                                                                                                                  (7, 'Financial Analysis Masterclass', '2023-08-01', '2023-08-05', 'Technical', 'Scheduled', 2000.00, 'Intensive financial analysis training'),
                                                                                                                                                  (8, 'HR Policies and Procedures', '2023-03-15', '2023-03-15', 'Compliance', 'Completed', 400.00, 'Update on current HR policies'),
                                                                                                                                                  (9, 'Retail Management Essentials', '2023-07-15', '2023-07-16', 'Management', 'Scheduled', 900.00, 'Two-day retail management workshop'),
                                                                                                                                                  (10, 'Advanced Design Principles', '2023-06-20', '2023-06-24', 'Technical', 'Scheduled', 1500.00, 'Week-long advanced design course');

-- 11. 客户反馈记录表
CREATE TABLE IF NOT EXISTS customer_feedback_records (
                                                         feedback_id INT AUTO_INCREMENT PRIMARY KEY,
                                                         company_id INT NOT NULL,
                                                         feedback_date DATETIME DEFAULT CURRENT_TIMESTAMP,
                                                         customer_name VARCHAR(100) NOT NULL,
                                                         contact_email VARCHAR(100),
                                                         contact_phone VARCHAR(20),
                                                         feedback_type ENUM('Complaint', 'Compliment', 'Suggestion', 'Question'),
                                                         feedback_text TEXT NOT NULL,
                                                         resolution_status ENUM('Open', 'In Progress', 'Resolved', 'Closed'),
                                                         resolved_by_user_id INT NULL,
                                                         resolution_notes TEXT NULL,
                                                         FOREIGN KEY (company_id) REFERENCES company_basic_details(company_id),
                                                         FOREIGN KEY (resolved_by_user_id) REFERENCES user_personal_information(user_id)
);

INSERT INTO customer_feedback_records (company_id, customer_name, contact_email, contact_phone, feedback_type, feedback_text, resolution_status) VALUES
                                                                                                                                                     (1, 'Sarah Johnson', 'sarah.j@example.com', '5551234567', 'Complaint', 'The new website is difficult to navigate and I can''t find the information I need.', 'Open'),
                                                                                                                                                     (2, 'Michael Chen', 'michael.c@example.com', '5552345678', 'Suggestion', 'Your industrial equipment is great but could use more safety features.', 'In Progress'),
                                                                                                                                                     (3, 'Emily Wilson', 'emily.w@example.com', '5553456789', 'Compliment', 'The new EHR system has made our clinic operations much more efficient!', 'Resolved'),
                                                                                                                                                     (4, 'David Brown', 'david.b@example.com', '5554567890', 'Question', 'Can you explain how your financial planning fees are calculated?', 'Open'),
                                                                                                                                                     (5, 'Lisa Garcia', 'lisa.g@example.com', '5555678901', 'Complaint', 'The new store layout is confusing and products are hard to find.', 'In Progress'),
                                                                                                                                                     (1, 'Robert Miller', 'robert.m@example.com', '5556789012', 'Suggestion', 'Consider adding more video tutorials to your website.', 'Open'),
                                                                                                                                                     (2, 'Jennifer Davis', 'jennifer.d@example.com', '5557890123', 'Compliment', 'Your customer service team was very helpful with my recent order.', 'Resolved'),
                                                                                                                                                     (3, 'Thomas Martinez', 'thomas.m@example.com', '5558901234', 'Question', 'What are the system requirements for the new EHR software?', 'In Progress'),
                                                                                                                                                     (4, 'Jessica Anderson', 'jessica.a@example.com', '5559012345', 'Complaint', 'I received incorrect financial reports last month.', 'Open'),
                                                                                                                                                     (5, 'Daniel Taylor', 'daniel.t@example.com', '5550123456', 'Suggestion', 'Offer more eco-friendly product options in your stores.', 'In Progress');

-- 12. 供应商信息表
CREATE TABLE IF NOT EXISTS supplier_management_records (
                                                           supplier_id INT AUTO_INCREMENT PRIMARY KEY,
                                                           company_id INT NOT NULL,
                                                           supplier_name VARCHAR(100) NOT NULL,
                                                           contact_name VARCHAR(100),
                                                           contact_email VARCHAR(100),
                                                           contact_phone VARCHAR(20),
                                                           supplier_type VARCHAR(50),
                                                           products_services_provided TEXT,
                                                           contract_start_date DATE,
                                                           contract_end_date DATE,
                                                           contract_value DECIMAL(15,2),
                                                           status ENUM('Active', 'Inactive', 'Terminated'),
                                                           FOREIGN KEY (company_id) REFERENCES company_basic_details(company_id)
);

INSERT INTO supplier_management_records (company_id, supplier_name, contact_name, contact_email, contact_phone, supplier_type, products_services_provided, contract_start_date, contract_end_date, contract_value, status) VALUES
                                                                                                                                                                                                                               (1, 'CloudHosting Solutions', 'John Smith', 'john.s@cloudhost.com', '5551112222', 'Hosting Provider', 'Cloud hosting services for company website', '2023-01-01', '2024-12-31', 12000.00, 'Active'),
                                                                                                                                                                                                                               (2, 'IndustrialParts Inc.', 'Michael Johnson', 'michael.j@parts.com', '5552223333', 'Parts Supplier', 'Replacement parts for manufacturing equipment', '2023-02-15', '2024-02-14', 75000.00, 'Active'),
                                                                                                                                                                                                                               (3, 'MedicalSupplies Ltd.', 'Sarah Williams', 'sarah.w@medsupplies.com', '5553334444', 'Medical Supplier', 'Medical equipment and supplies for clinics', '2023-03-01', '2024-02-28', 150000.00, 'Active'),
                                                                                                                                                                                                                               (4, 'FinancialData Services', 'David Brown', 'david.b@financialdata.com', '5554445555', 'Data Provider', 'Financial market data and analytics', '2023-01-15', '2023-12-31', 90000.00, 'Active'),
                                                                                                                                                                                                                               (5, 'RetailEquipment Co.', 'Emily Davis', 'emily.d@retailequip.com', '5555556666', 'Equipment Supplier', 'Store fixtures and equipment', '2023-04-01', '2024-03-31', 120000.00, 'Active'),
                                                                                                                                                                                                                               (1, 'DesignAgency Creative', 'Robert Wilson', 'robert.w@designagency.com', '5556667777', 'Design Agency', 'Graphic design and branding services', '2023-02-01', '2023-11-30', 45000.00, 'Active'),
                                                                                                                                                                                                                               (2, 'LogisticsPro Transport', 'Jennifer Martinez', 'jennifer.m@logisticspro.com', '5557778888', 'Logistics Provider', 'Shipping and transportation services', '2023-03-15', '2024-03-14', 60000.00, 'Active'),
                                                                                                                                                                                                                               (3, 'CleaningServices Plus', 'Thomas Anderson', 'thomas.a@cleaningservices.com', '5558889999', 'Cleaning Service', 'Facility cleaning and maintenance', '2023-01-10', '2023-12-31', 36000.00, 'Active'),
                                                                                                                                                                                                                               (4, 'OfficeSupplies Direct', 'Jessica Taylor', 'jessica.t@officesupplies.com', '5559990000', 'Office Supplier', 'Office supplies and equipment', '2023-02-20', '2024-02-19', 24000.00, 'Active'),
                                                                                                                                                                                                                               (5, 'FoodService Solutions', 'Daniel Garcia', 'daniel.g@foodservices.com', '5550001111', 'Food Supplier', 'Food and beverage supplies for restaurants', '2023-05-01', '2024-04-30', 80000.00, 'Active');

-- 13. 会议记录表
CREATE TABLE IF NOT EXISTS meeting_management_records (
                                                          meeting_id INT AUTO_INCREMENT PRIMARY KEY,
                                                          meeting_title VARCHAR(100) NOT NULL,
                                                          meeting_date DATETIME NOT NULL,
                                                          organizer_user_id INT NOT NULL,
                                                          location VARCHAR(100),
                                                          is_virtual BOOLEAN DEFAULT FALSE,
                                                          virtual_meeting_url VARCHAR(200) NULL,
                                                          duration_minutes INT NOT NULL,
                                                          attendees TEXT,
                                                          agenda TEXT,
                                                          minutes TEXT,
                                                          action_items TEXT,
                                                          FOREIGN KEY (organizer_user_id) REFERENCES user_personal_information(user_id)
);

INSERT INTO meeting_management_records (meeting_title, meeting_date, organizer_user_id, location, is_virtual, virtual_meeting_url, duration_minutes, attendees, agenda, minutes, action_items) VALUES
                                                                                                                                                                                                   ('Project Status Update Meeting', '2023-05-15 10:00:00', 1, 'Conference Room A', FALSE, NULL, 60, '1,2,3,4,5', 'Review project progress, discuss challenges, plan next steps', 'All projects are on track with minor issues discussed', 'John to follow up on design approval, Sarah to check on vendor status'),
                                                                                                                                                                                                   ('Quarterly Financial Review', '2023-05-20 14:00:00', 7, 'Board Room', FALSE, NULL, 90, '7,8,9,10', 'Review Q2 financial performance, discuss budget variances', 'Revenue slightly below projections, expenses well controlled', 'David to prepare revised forecast, Emily to analyze cost savings opportunities'),
                                                                                                                                                                                                   ('Product Development Planning', '2023-05-25 11:00:00', 2, 'Virtual', TRUE, 'https://zoom.us/j/123456789', 75, '2,4,6,8', 'Discuss new product features, prioritize roadmap', 'Agreed on top 5 features for next release', 'Michael to finalize requirements, Jennifer to start design work'),
                                                                                                                                                                                                   ('HR Policy Update Meeting', '2023-06-01 09:30:00', 10, 'HR Conference Room', FALSE, NULL, 60, '10,8,6', 'Review and update company policies', 'Updated several policies including remote work and expense reimbursement', 'Lisa to communicate changes to all employees, Thomas to update employee handbook'),
                                                                                                                                                                                                   ('Marketing Strategy Session', '2023-06-05 13:00:00', 5, 'Marketing Office', FALSE, NULL, 90, '5,2,9', 'Develop Q3 marketing plan and campaigns', 'Agreed on key campaigns and channels for Q3', 'Alice to prepare campaign briefs, Bob to coordinate with sales team'),
                                                                                                                                                                                                   ('Engineering Team Retrospective', '2023-06-10 15:00:00', 1, 'Engineering Lounge', FALSE, NULL, 60, '1,3,4,6', 'Review sprint outcomes, identify process improvements', 'Identified several areas for process improvement', 'John to implement new code review process, Mike to update development guidelines'),
                                                                                                                                                                                                   ('Customer Feedback Analysis', '2023-06-15 10:30:00', 8, 'Virtual', TRUE, 'https://zoom.us/j/987654321', 75, '8,5,7,10', 'Review recent customer feedback, identify trends', 'Identified several common issues to address', 'Emily to create action plan for top 3 issues, David to review product documentation'),
                                                                                                                                                                                                   ('Sales Forecast Meeting', '2023-06-20 14:00:00', 9, 'Sales Office', FALSE, NULL, 60, '9,7,2', 'Review sales pipeline, update forecasts', 'Pipeline looks healthy but need to close several large deals', 'Robert to follow up on top 5 opportunities, Sarah to prepare client presentations'),
                                                                                                                                                                                                   ('Executive Leadership Retreat', '2023-06-25 09:00:00', 1, 'Offsite Location', FALSE, NULL, 240, '1,3,5,7,9,10', 'Strategic planning for next 12-18 months', 'Developed high-level strategic plan for company growth', 'John to finalize strategic plan, all leaders to develop department plans'),
                                                                                                                                                                                                   ('New Hire Onboarding Planning', '2023-06-30 11:00:00', 10, 'HR Office', FALSE, NULL, 60, '10,8,6,4', 'Review and improve onboarding process', 'Identified several areas for improvement in onboarding', 'Lisa to update onboarding checklist, Thomas to train hiring managers on new process');

