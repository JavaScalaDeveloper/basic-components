-- 创建中间件平台所需的数据库

CREATE DATABASE IF NOT EXISTS data_sec_umbrella CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
-- 查看 MySQL 版本
SELECT VERSION();
ALTER DATABASE data_sec_umbrella   COMMENT '数据安全umbrella库';