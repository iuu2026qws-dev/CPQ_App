package com.hruingerai.utils;

import java.util.List;

/**
 * 菜单生成器
 *
 * 用于生成 RuoYi-Vue 框架的菜单和字典配置
 *
 * @author HRuinger.
 * @date 2026-03-29
 */
public class MenuGenerator
{
    /**
     * 生成菜单配置 SQL
     *
     * @param menu 菜单设计
     * @param tableDesign 表设计
     * @return SQL 语句
     */
    public static String generateMenuSQL(RequirementAnalyzer.MenuDesign menu, 
                                         RequirementAnalyzer.TableDesign tableDesign)
    {
        StringBuilder sql = new StringBuilder();
        
        sql.append("-- ======================================================\n");
        sql.append("-- 菜单 SQL：").append(menu.getMenuName()).append("\n");
        sql.append("-- ======================================================\n\n");

        // 插入主菜单
        sql.append("-- 1. 插入主菜单\n");
        sql.append("SET @menu_id = (SELECT menu_id FROM sys_menu WHERE menu_name = '").append(menu.getMenuName()).append("' AND menu_type = 'C' LIMIT 1);\n");
        sql.append("INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)\n");
        sql.append("VALUES ('").append(menu.getMenuName()).append("', ");
        sql.append(menu.getParentMenuId()).append(", ");
        sql.append(menu.getOrderNum()).append(", ");
        sql.append("'").append(menu.getMenuPath()).append("', ");
        sql.append("'").append(menu.getComponent()).append("', ");
        sql.append("'1', ");
        sql.append("'0', ");
        sql.append("'").append(menu.getMenuType()).append("', ");
        sql.append("'").append(menu.getVisible()).append("', ");
        sql.append("'").append(menu.getStatus()).append("', ");
        sql.append("NULL, ");
        sql.append("'").append(menu.getMenuIcon()).append("', ");
        sql.append("'admin', ");
        sql.append("NOW(), ");
        sql.append("'").append(menu.getMenuName()).append("')\n");
        sql.append("ON DUPLICATE KEY UPDATE \n");
        sql.append("  path = VALUES(path),\n");
        sql.append("  component = VALUES(component),\n");
        sql.append("  icon = VALUES(icon),\n");
        sql.append("  update_time = NOW();\n\n");

        sql.append("SET @menu_id = (SELECT menu_id FROM sys_menu WHERE menu_name = '").append(menu.getMenuName()).append("' AND menu_type = 'C' LIMIT 1);\n\n");

        // 插入按钮权限
        if (menu.getButtons() != null && !menu.getButtons().isEmpty())
        {
            sql.append("-- 2. 插入按钮权限\n");
            for (RequirementAnalyzer.MenuButton button : menu.getButtons())
            {
                sql.append("INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)\n");
                sql.append("VALUES ('").append(button.getButtonName()).append("', ");
                sql.append("@menu_id").append(", ");
                sql.append(button.getOrderNum()).append(", ");
                sql.append("'#', ");
                sql.append("'', ");
                sql.append("'1', ");
                sql.append("'0', ");
                sql.append("'F', ");
                sql.append("'").append(button.getVisible()).append("', ");
                sql.append("'0', ");
                sql.append("'").append(button.getPerms()).append("', ");
                sql.append("'#', ");
                sql.append("'admin', ");
                sql.append("NOW(), ");
                sql.append("'').append("')\n");
                sql.append("ON DUPLICATE KEY UPDATE \n");
                sql.append("  perms = VALUES(perms),\n");
                sql.append("  update_time = NOW();\n");
            }
            sql.append("\n");
        }

        return sql.toString();
    }

    /**
     * 生成字典配置 SQL
     *
     * @param dicts 字典设计列表
     * @return SQL 语句
     */
    public static String generateDictSQL(List<RequirementAnalyzer.DictDesign> dicts)
    {
        StringBuilder sql = new StringBuilder();
        
        sql.append("-- ======================================================\n");
        sql.append("-- 字典数据 SQL\n");
        sql.append("-- ======================================================\n\n");

        for (RequirementAnalyzer.DictDesign dict : dicts)
        {
            // 插入字典类型
            sql.append("-- 字典类型：").append(dict.getDictName()).append("\n");
            sql.append("INSERT INTO sys_dict_type (dict_name, dict_type, status, create_by, create_time, remark)\n");
            sql.append("VALUES ('").append(dict.getDictName()).append("', ");
            sql.append("'").append(dict.getDictType()).append("', ");
            sql.append("'0', ");
            sql.append("'admin', ");
            sql.append("NOW(), ");
            sql.append("'").append(dict.getDictName()).append("')\n");
            sql.append("ON DUPLICATE KEY UPDATE \n");
            sql.append("  dict_name = VALUES(dict_name),\n");
            sql.append("  update_time = NOW();\n\n");

            // 插入字典数据
            if (dict.getItems() != null && !dict.getItems().isEmpty())
            {
                sql.append("-- 字典数据：").append(dict.getDictName()).append("\n");
                for (RequirementAnalyzer.DictItem item : dict.getItems())
                {
                    sql.append("INSERT INTO sys_dict_data (dict_sort, dict_label, dict_value, dict_type, is_default, status, create_by, create_time, remark)\n");
                    sql.append("VALUES (").append(item.getDictSort()).append(", ");
                    sql.append("'").append(item.getDictLabel()).append("', ");
                    sql.append("'").append(item.getDictValue()).append("', ");
                    sql.append("'").append(dict.getDictType()).append("', ");
                    sql.append("'").append(item.getIsDefault()).append("', ");
                    sql.append("'0', ");
                    sql.append("'admin', ");
                    sql.append("NOW(), ");
                    sql.append("'').append("')\n");
                    sql.append("ON DUPLICATE KEY UPDATE \n");
                    sql.append("  dict_label = VALUES(dict_label),\n");
                    sql.append("  update_time = NOW();\n");
                }
                sql.append("\n");
            }
        }

        return sql.toString();
    }

    /**
     * 生成完整的菜单和字典 SQL
     *
     * @param tableDesign 表设计
     * @return SQL 语句
     */
    public static String generateCompleteSQL(RequirementAnalyzer.TableDesign tableDesign)
    {
        StringBuilder sql = new StringBuilder();
        
        sql.append("-- ======================================================\n");
        sql.append("-- RuoYi-Vue 功能模块：").append(tableDesign.getFunctionName()).append("\n");
        sql.append("-- 生成时间：").append(new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(new java.util.Date())).append("\n");
        sql.append("-- ======================================================\n\n");

        // 生成表 SQL
        sql.append(generateTableSQL(tableDesign));
        sql.append("\n");

        // 生成菜单 SQL
        sql.append(generateMenuSQL(tableDesign.getMenu(), tableDesign));
        sql.append("\n");

        // 生成字典 SQL
        if (tableDesign.getDicts() != null && !tableDesign.getDicts().isEmpty())
        {
            sql.append(generateDictSQL(tableDesign.getDicts()));
        }

        return sql.toString();
    }

    /**
     * 生成表 SQL
     *
     * @param tableDesign 表设计
     * @return SQL 语句
     */
    private static String generateTableSQL(RequirementAnalyzer.TableDesign tableDesign)
    {
        StringBuilder sql = new StringBuilder();
        
        sql.append("-- ======================================================\n");
        sql.append("-- 表结构 SQL：").append(tableDesign.getTableName()).append("\n");
        sql.append("-- 表注释：").append(tableDesign.getTableComment()).append("\n");
        sql.append("-- ======================================================\n\n");
        
        sql.append("-- 删除表（如果存在）\n");
        sql.append("DROP TABLE IF EXISTS `").append(tableDesign.getTableName()).append("`;\n\n");

        // 创建表
        sql.append("-- 创建表\n");
        sql.append("CREATE TABLE `").append(tableDesign.getTableName()).append("` (\n");

        List<RequirementAnalyzer.FieldDesign> fields = tableDesign.getFields();
        for (int i = 0; i < fields.size(); i++)
        {
            RequirementAnalyzer.FieldDesign field = fields.get(i);
            sql.append("  `").append(field.getColumnName()).append("` ");
            sql.append(field.getDataType());
            
            if (field.getDataLength() != null && !field.getDataLength().isEmpty())
            {
                sql.append("(").append(field.getDataLength()).append(")");
            }
            
            sql.append(" ");
            sql.append(field.getColumnDefault());
            
            if (field.getComment() != null && !field.getComment().isEmpty())
            {
                sql.append(" COMMENT '").append(field.getComment()).append("'");
            }
            
            if (i < fields.size() - 1)
            {
                sql.append(",\n");
            }
            else
            {
                // 主键
                for (RequirementAnalyzer.FieldDesign pkField : fields)
                {
                    if (pkField.isPrimaryKey())
                    {
                        sql.append(",\n");
                        sql.append("  PRIMARY KEY (`").append(pkField.getColumnName()).append("`)");
                        break;
                    }
                }
                sql.append("\n");
            }
        }

        sql.append(") ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COMMENT='");
        sql.append(tableDesign.getTableComment()).append("';\n\n");

        return sql.toString();
    }

    /**
     * 根据需求自动生成菜单层级关系
     *
     * @param requirement 需求描述
     * @param tableDesign 表设计
     * @return 菜单设计
     */
    public static RequirementAnalyzer.MenuDesign generateMenuHierarchy(String requirement, 
                                                                           RequirementAnalyzer.TableDesign tableDesign)
    {
        RequirementAnalyzer.MenuDesign menu = tableDesign.getMenu();

        // 根据需求判断菜单层级
        if (requirement.contains("用户"))
        {
            menu.setParentMenuId("1"); // 假设用户管理菜单ID为1
            menu.setMenuIcon("user");
        }
        else if (requirement.contains("订单"))
        {
            menu.setParentMenuId("2"); // 假设订单管理菜单ID为2
            menu.setMenuIcon("shopping");
        }
        else if (requirement.contains("商品"))
        {
            menu.setParentMenuId("3"); // 假设商品管理菜单ID为3
            menu.setMenuIcon("goods");
        }
        else
        {
            menu.setParentMenuId("0"); // 一级菜单
            menu.setMenuIcon("system");
        }

        return menu;
    }

    /**
     * 自动分配菜单排序号
     *
     * @param parentMenuId 父菜单ID
     * @param existingCount 已有菜单数量
     * @return 排序号
     */
    public static String allocateOrderNum(String parentMenuId, int existingCount)
    {
        return String.valueOf(existingCount + 1);
    }
}
