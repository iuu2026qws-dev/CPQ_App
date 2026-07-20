-- =====================================================
-- Ruoyi_CPQ 完整迁移：修正 sys_ 表列类型与 RuoYi-Vue-Plus 对齐
-- 原因：数据库用旧版 ry_20260417.sql 初始化（create_by/update_by 为 VARCHAR），
--       但 RuoYi-Vue-Plus 实体类定义 createBy/updateBy 为 Long（BIGINT）。
-- 日期：2026-07-01
-- 安全可重复执行
-- =====================================================

SET NAMES utf8mb4;

-- =====================================================
-- 步骤1：将VARCHAR类型的create_by/update_by数据清为NULL（无法转为BIGINT）
-- =====================================================

-- sys_config
UPDATE sys_config SET create_by = NULL WHERE create_by IS NOT NULL AND create_by REGEXP '[^0-9]';
UPDATE sys_config SET update_by = NULL WHERE update_by IS NOT NULL AND update_by REGEXP '[^0-9]';

-- sys_dept
UPDATE sys_dept SET create_by = NULL WHERE create_by IS NOT NULL AND create_by REGEXP '[^0-9]';
UPDATE sys_dept SET update_by = NULL WHERE update_by IS NOT NULL AND update_by REGEXP '[^0-9]';

-- sys_dict_data
UPDATE sys_dict_data SET create_by = NULL WHERE create_by IS NOT NULL AND create_by REGEXP '[^0-9]';
UPDATE sys_dict_data SET update_by = NULL WHERE update_by IS NOT NULL AND update_by REGEXP '[^0-9]';

-- sys_dict_type
UPDATE sys_dict_type SET create_by = NULL WHERE create_by IS NOT NULL AND create_by REGEXP '[^0-9]';
UPDATE sys_dict_type SET update_by = NULL WHERE update_by IS NOT NULL AND update_by REGEXP '[^0-9]';

-- sys_job
UPDATE sys_job SET create_by = NULL WHERE create_by IS NOT NULL AND create_by REGEXP '[^0-9]';
UPDATE sys_job SET update_by = NULL WHERE update_by IS NOT NULL AND update_by REGEXP '[^0-9]';

-- sys_menu
UPDATE sys_menu SET create_by = NULL WHERE create_by IS NOT NULL AND create_by REGEXP '[^0-9]';
UPDATE sys_menu SET update_by = NULL WHERE update_by IS NOT NULL AND update_by REGEXP '[^0-9]';

-- sys_notice
UPDATE sys_notice SET create_by = NULL WHERE create_by IS NOT NULL AND create_by REGEXP '[^0-9]';
UPDATE sys_notice SET update_by = NULL WHERE update_by IS NOT NULL AND update_by REGEXP '[^0-9]';

-- sys_post
UPDATE sys_post SET create_by = NULL WHERE create_by IS NOT NULL AND create_by REGEXP '[^0-9]';
UPDATE sys_post SET update_by = NULL WHERE update_by IS NOT NULL AND update_by REGEXP '[^0-9]';

-- sys_role
UPDATE sys_role SET create_by = NULL WHERE create_by IS NOT NULL AND create_by REGEXP '[^0-9]';
UPDATE sys_role SET update_by = NULL WHERE update_by IS NOT NULL AND update_by REGEXP '[^0-9]';

-- sys_user
UPDATE sys_user SET create_by = NULL WHERE create_by IS NOT NULL AND create_by REGEXP '[^0-9]';
UPDATE sys_user SET update_by = NULL WHERE update_by IS NOT NULL AND update_by REGEXP '[^0-9]';

-- =====================================================
-- 步骤2：修改列类型为 BIGINT（与 BaseEntity Long 类型对齐）
-- =====================================================

ALTER TABLE sys_config MODIFY COLUMN create_by BIGINT(20) DEFAULT NULL COMMENT '创建者';
ALTER TABLE sys_config MODIFY COLUMN update_by BIGINT(20) DEFAULT NULL COMMENT '更新者';

ALTER TABLE sys_dept MODIFY COLUMN create_by BIGINT(20) DEFAULT NULL COMMENT '创建者';
ALTER TABLE sys_dept MODIFY COLUMN update_by BIGINT(20) DEFAULT NULL COMMENT '更新者';

ALTER TABLE sys_dict_data MODIFY COLUMN create_by BIGINT(20) DEFAULT NULL COMMENT '创建者';
ALTER TABLE sys_dict_data MODIFY COLUMN update_by BIGINT(20) DEFAULT NULL COMMENT '更新者';

ALTER TABLE sys_dict_type MODIFY COLUMN create_by BIGINT(20) DEFAULT NULL COMMENT '创建者';
ALTER TABLE sys_dict_type MODIFY COLUMN update_by BIGINT(20) DEFAULT NULL COMMENT '更新者';

ALTER TABLE sys_job MODIFY COLUMN create_by BIGINT(20) DEFAULT NULL COMMENT '创建者';
ALTER TABLE sys_job MODIFY COLUMN update_by BIGINT(20) DEFAULT NULL COMMENT '更新者';

ALTER TABLE sys_menu MODIFY COLUMN create_by BIGINT(20) DEFAULT NULL COMMENT '创建者';
ALTER TABLE sys_menu MODIFY COLUMN update_by BIGINT(20) DEFAULT NULL COMMENT '更新者';

ALTER TABLE sys_notice MODIFY COLUMN create_by BIGINT(20) DEFAULT NULL COMMENT '创建者';
ALTER TABLE sys_notice MODIFY COLUMN update_by BIGINT(20) DEFAULT NULL COMMENT '更新者';

ALTER TABLE sys_post MODIFY COLUMN create_by BIGINT(20) DEFAULT NULL COMMENT '创建者';
ALTER TABLE sys_post MODIFY COLUMN update_by BIGINT(20) DEFAULT NULL COMMENT '更新者';

ALTER TABLE sys_role MODIFY COLUMN create_by BIGINT(20) DEFAULT NULL COMMENT '创建者';
ALTER TABLE sys_role MODIFY COLUMN update_by BIGINT(20) DEFAULT NULL COMMENT '更新者';

ALTER TABLE sys_user MODIFY COLUMN create_by BIGINT(20) DEFAULT NULL COMMENT '创建者';
ALTER TABLE sys_user MODIFY COLUMN update_by BIGINT(20) DEFAULT NULL COMMENT '更新者';

-- =====================================================
-- 步骤3：修正 sys_user 特有字段类型
-- =====================================================

-- avatar: VARCHAR(100) → BIGINT(20)（匹配标准 ry_vue_5.X.sql，头像存OSS文件ID）
ALTER TABLE sys_user MODIFY COLUMN avatar BIGINT(20) DEFAULT NULL COMMENT '头像地址';

-- user_type: VARCHAR(2) → VARCHAR(10)（匹配标准定义，默认值'sys_user'）
ALTER TABLE sys_user MODIFY COLUMN user_type VARCHAR(10) DEFAULT 'sys_user' COMMENT '用户类型（sys_user系统用户）';

-- =====================================================
-- 验证结果
-- =====================================================
SELECT TABLE_NAME, COLUMN_NAME, DATA_TYPE, COLUMN_TYPE
FROM information_schema.COLUMNS
WHERE TABLE_SCHEMA = 'Ruoyi_CPQ'
  AND TABLE_NAME LIKE 'sys_%'
  AND COLUMN_NAME IN ('create_by', 'update_by', 'avatar', 'user_type')
ORDER BY TABLE_NAME, ORDINAL_POSITION;
