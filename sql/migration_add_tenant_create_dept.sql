-- =====================================================
-- Ruoyi_CPQ 迁移：给 sys_ 表添加 tenant_id 和 create_dept 列
-- 原因：数据库用旧版 ry_20260417.sql 初始化（无多租户列），
--       但 RuoYi-Vue-Plus 实体类包含这些字段，MyBatis-Plus 
--       SELECT 会生成包含这些列的 SQL 导致报错。
-- 日期：2026-07-01
-- 安全可重复执行
-- =====================================================

SET NAMES utf8mb4;

-- 用存储过程安全添加列（存在则跳过）
DROP PROCEDURE IF EXISTS add_column_if_missing;
DELIMITER $$
CREATE PROCEDURE add_column_if_missing(
    IN tbl_name VARCHAR(64),
    IN col_name VARCHAR(64),
    IN col_def VARCHAR(256)
)
BEGIN
    DECLARE col_count INT DEFAULT 0;
    SELECT COUNT(*) INTO col_count
    FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME = tbl_name
      AND COLUMN_NAME = col_name;
    IF col_count = 0 THEN
        SET @sql = CONCAT('ALTER TABLE ', tbl_name, ' ADD COLUMN ', col_name, ' ', col_def);
        PREPARE stmt FROM @sql;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
        SELECT CONCAT('ADDED: ', tbl_name, '.', col_name) AS result;
    ELSE
        SELECT CONCAT('SKIP: ', tbl_name, '.', col_name, ' already exists') AS result;
    END IF;
END$$
DELIMITER ;

-- sys_client
CALL add_column_if_missing('sys_client', 'tenant_id', "VARCHAR(20) DEFAULT '000000' COMMENT '租户编号'");

-- sys_config
CALL add_column_if_missing('sys_config', 'tenant_id', "VARCHAR(20) DEFAULT '000000' COMMENT '租户编号'");
CALL add_column_if_missing('sys_config', 'create_dept', "BIGINT(20) DEFAULT NULL COMMENT '创建部门'");

-- sys_dept
CALL add_column_if_missing('sys_dept', 'tenant_id', "VARCHAR(20) DEFAULT '000000' COMMENT '租户编号'");
CALL add_column_if_missing('sys_dept', 'create_dept', "BIGINT(20) DEFAULT NULL COMMENT '创建部门'");

-- sys_dict_data
CALL add_column_if_missing('sys_dict_data', 'tenant_id', "VARCHAR(20) DEFAULT '000000' COMMENT '租户编号'");
CALL add_column_if_missing('sys_dict_data', 'create_dept', "BIGINT(20) DEFAULT NULL COMMENT '创建部门'");

-- sys_dict_type
CALL add_column_if_missing('sys_dict_type', 'tenant_id', "VARCHAR(20) DEFAULT '000000' COMMENT '租户编号'");
CALL add_column_if_missing('sys_dict_type', 'create_dept', "BIGINT(20) DEFAULT NULL COMMENT '创建部门'");

-- sys_job
CALL add_column_if_missing('sys_job', 'tenant_id', "VARCHAR(20) DEFAULT '000000' COMMENT '租户编号'");
CALL add_column_if_missing('sys_job', 'create_dept', "BIGINT(20) DEFAULT NULL COMMENT '创建部门'");

-- sys_job_log
CALL add_column_if_missing('sys_job_log', 'tenant_id', "VARCHAR(20) DEFAULT '000000' COMMENT '租户编号'");
CALL add_column_if_missing('sys_job_log', 'create_dept', "BIGINT(20) DEFAULT NULL COMMENT '创建部门'");

-- sys_logininfor
CALL add_column_if_missing('sys_logininfor', 'tenant_id', "VARCHAR(20) DEFAULT '000000' COMMENT '租户编号'");
CALL add_column_if_missing('sys_logininfor', 'create_dept', "BIGINT(20) DEFAULT NULL COMMENT '创建部门'");

-- sys_menu
CALL add_column_if_missing('sys_menu', 'tenant_id', "VARCHAR(20) DEFAULT '000000' COMMENT '租户编号'");
CALL add_column_if_missing('sys_menu', 'create_dept', "BIGINT(20) DEFAULT NULL COMMENT '创建部门'");

-- sys_notice
CALL add_column_if_missing('sys_notice', 'tenant_id', "VARCHAR(20) DEFAULT '000000' COMMENT '租户编号'");
CALL add_column_if_missing('sys_notice', 'create_dept', "BIGINT(20) DEFAULT NULL COMMENT '创建部门'");

-- sys_notice_read
CALL add_column_if_missing('sys_notice_read', 'tenant_id', "VARCHAR(20) DEFAULT '000000' COMMENT '租户编号'");
CALL add_column_if_missing('sys_notice_read', 'create_dept', "BIGINT(20) DEFAULT NULL COMMENT '创建部门'");

-- sys_oper_log
CALL add_column_if_missing('sys_oper_log', 'tenant_id', "VARCHAR(20) DEFAULT '000000' COMMENT '租户编号'");
CALL add_column_if_missing('sys_oper_log', 'create_dept', "BIGINT(20) DEFAULT NULL COMMENT '创建部门'");

-- sys_post
CALL add_column_if_missing('sys_post', 'tenant_id', "VARCHAR(20) DEFAULT '000000' COMMENT '租户编号'");
CALL add_column_if_missing('sys_post', 'create_dept', "BIGINT(20) DEFAULT NULL COMMENT '创建部门'");

-- sys_role
CALL add_column_if_missing('sys_role', 'tenant_id', "VARCHAR(20) DEFAULT '000000' COMMENT '租户编号'");
CALL add_column_if_missing('sys_role', 'create_dept', "BIGINT(20) DEFAULT NULL COMMENT '创建部门'");

-- sys_role_dept
CALL add_column_if_missing('sys_role_dept', 'tenant_id', "VARCHAR(20) DEFAULT '000000' COMMENT '租户编号'");
CALL add_column_if_missing('sys_role_dept', 'create_dept', "BIGINT(20) DEFAULT NULL COMMENT '创建部门'");

-- sys_role_menu
CALL add_column_if_missing('sys_role_menu', 'tenant_id', "VARCHAR(20) DEFAULT '000000' COMMENT '租户编号'");
CALL add_column_if_missing('sys_role_menu', 'create_dept', "BIGINT(20) DEFAULT NULL COMMENT '创建部门'");

-- sys_tenant_package
CALL add_column_if_missing('sys_tenant_package', 'tenant_id', "VARCHAR(20) DEFAULT '000000' COMMENT '租户编号'");

-- sys_user
CALL add_column_if_missing('sys_user', 'tenant_id', "VARCHAR(20) DEFAULT '000000' COMMENT '租户编号'");
CALL add_column_if_missing('sys_user', 'create_dept', "BIGINT(20) DEFAULT NULL COMMENT '创建部门'");

-- sys_user_post
CALL add_column_if_missing('sys_user_post', 'tenant_id', "VARCHAR(20) DEFAULT '000000' COMMENT '租户编号'");
CALL add_column_if_missing('sys_user_post', 'create_dept', "BIGINT(20) DEFAULT NULL COMMENT '创建部门'");

-- sys_user_role
CALL add_column_if_missing('sys_user_role', 'tenant_id', "VARCHAR(20) DEFAULT '000000' COMMENT '租户编号'");
CALL add_column_if_missing('sys_user_role', 'create_dept', "BIGINT(20) DEFAULT NULL COMMENT '创建部门'");

-- 清理存储过程
DROP PROCEDURE IF EXISTS add_column_if_missing;

-- =====================================================
-- 验证结果
-- =====================================================
SELECT 
    t.TABLE_NAME,
    IF(c_tid.COLUMN_NAME IS NOT NULL, 'YES', 'NO') AS has_tenant_id,
    IF(c_cd.COLUMN_NAME IS NOT NULL, 'YES', 'NO') AS has_create_dept
FROM information_schema.TABLES t
LEFT JOIN information_schema.COLUMNS c_tid ON t.TABLE_SCHEMA = c_tid.TABLE_SCHEMA AND t.TABLE_NAME = c_tid.TABLE_NAME AND c_tid.COLUMN_NAME = 'tenant_id'
LEFT JOIN information_schema.COLUMNS c_cd ON t.TABLE_SCHEMA = c_cd.TABLE_SCHEMA AND t.TABLE_NAME = c_cd.TABLE_NAME AND c_cd.COLUMN_NAME = 'create_dept'
WHERE t.TABLE_SCHEMA = 'Ruoyi_CPQ' AND t.TABLE_NAME LIKE 'sys_%'
ORDER BY t.TABLE_NAME;
