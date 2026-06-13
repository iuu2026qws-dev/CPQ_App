package com.hruingerai.utils;

import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.sql.*;
import java.util.List;

/**
 * SQL 执行器
 *
 * 用于生成 SQL 脚本并执行到数据库
 *
 * @author HRuinger.
 * @date 2026-03-29
 */
public class SQLExecutor
{
    private Connection connection;

    /**
     * 构造函数
     *
     * @param url 数据库URL
     * @param username 用户名
     * @param password 密码
     * @throws SQLException SQL异常
     */
    public SQLExecutor(String url, String username, String password) throws SQLException
    {
        this.connection = DriverManager.getConnection(url, username, password);
    }

    /**
     * 生成并执行表创建 SQL
     *
     * @param design 表设计
     * @param projectPath 项目路径
     * @return 是否成功
     * @throws SQLException SQL异常
     * @throws IOException IO异常
     */
    public boolean generateAndExecuteTableSQL(RequirementAnalyzer.TableDesign design, String projectPath) 
            throws SQLException, IOException
    {
        // 1. 生成 SQL
        String sql = generateCreateTableSQL(design);

        // 2. 保存 SQL 文件到项目目录
        saveSQLToFile(sql, projectPath, design.getTableName(), "table");

        // 3. 执行 SQL
        return executeSQL(sql);
    }

    /**
     * 生成并执行菜单 SQL
     *
     * @param menu 菜单设计
     * @param tableDesign 表设计
     * @param projectPath 项目路径
     * @return 是否成功
     * @throws SQLException SQL异常
     * @throws IOException IO异常
     */
    public boolean generateAndExecuteMenuSQL(RequirementAnalyzer.MenuDesign menu, 
                                            RequirementAnalyzer.TableDesign tableDesign,
                                            String projectPath) 
            throws SQLException, IOException
    {
        // 1. 生成 SQL
        String sql = generateMenuSQL(menu, tableDesign);

        // 2. 保存 SQL 文件到项目目录
        saveSQLToFile(sql, projectPath, tableDesign.getTableName(), "menu");

        // 3. 执行 SQL
        return executeSQL(sql);
    }

    /**
     * 生成并执行字典 SQL
     *
     * @param dicts 字典设计列表
     * @param projectPath 项目路径
     * @return 是否成功
     * @throws SQLException SQL异常
     * @throws IOException IO异常
     */
    public boolean generateAndExecuteDictSQL(List<RequirementAnalyzer.DictDesign> dicts, String projectPath) 
            throws SQLException, IOException
    {
        if (dicts == null || dicts.isEmpty())
        {
            return true;
        }

        // 1. 生成 SQL
        String sql = generateDictSQL(dicts);

        // 2. 保存 SQL 文件到项目目录
        saveSQLToFile(sql, projectPath, "dict", "dict");

        // 3. 执行 SQL
        return executeSQL(sql);
    }

    /**
     * 生成表创建 SQL
     *
     * @param design 表设计
     * @return SQL 语句
     */
    private String generateCreateTableSQL(RequirementAnalyzer.TableDesign design)
    {
        StringBuilder sql = new StringBuilder();
        
        sql.append("-- 创建表：").append(design.getTableComment()).append("\n");
        sql.append("DROP TABLE IF EXISTS `").append(design.getTableName()).append("`;\n");
        sql.append("CREATE TABLE `").append(design.getTableName()).append("` (\n");

        List<RequirementAnalyzer.FieldDesign> fields = design.getFields();
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
        sql.append(design.getTableComment()).append("';\n\n");

        return sql.toString();
    }

    /**
     * 生成菜单 SQL
     *
     * @param menu 菜单设计
     * @param tableDesign 表设计
     * @return SQL 语句
     */
    private String generateMenuSQL(RequirementAnalyzer.MenuDesign menu, RequirementAnalyzer.TableDesign tableDesign)
    {
        StringBuilder sql = new StringBuilder();
        
        sql.append("-- 菜单 SQL：").append(menu.getMenuName()).append("\n\n");

        // 插入主菜单
        sql.append("-- 插入主菜单\n");
        sql.append("INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)\n");
        sql.append("VALUES ('").append(menu.getMenuName()).append("', ");
        sql.append(menu.getParentMenuId()).append(", ");
        sql.append(menu.getOrderNum()).append(", ");
        sql.append("'").append(menu.getMenuPath()).append("', ");
        sql.append("'").append(menu.getComponent()).append("', ");
        sql.append("NULL, ");
        sql.append("'1', ");
        sql.append("'0', ");
        sql.append("'").append(menu.getMenuType()).append("', ");
        sql.append("'").append(menu.getVisible()).append("', ");
        sql.append("'").append(menu.getStatus()).append("', ");
        sql.append("NULL, ");
        sql.append("'").append(menu.getMenuIcon()).append("', ");
        sql.append("'admin', ");
        sql.append("NOW(), ");
        sql.append("'', ");
        sql.append("NULL, ");
        sql.append("'").append(menu.getMenuName()).append("');\n\n");

        // 插入按钮权限
        if (menu.getButtons() != null && !menu.getButtons().isEmpty())
        {
            sql.append("-- 插入按钮权限\n");
            
            // 获取主菜单ID（假设刚刚插入的菜单ID）
            String menuId = "(SELECT menu_id FROM sys_menu WHERE menu_name = '" + menu.getMenuName() + "' AND menu_type = 'C' LIMIT 1)";
            
            for (RequirementAnalyzer.MenuButton button : menu.getButtons())
            {
                sql.append("INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, query, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)\n");
                sql.append("VALUES ('").append(button.getButtonName()).append("', ");
                sql.append(menuId).append(", ");
                sql.append(button.getOrderNum()).append(", ");
                sql.append("'#', ");
                sql.append("'', ");
                sql.append("NULL, ");
                sql.append("'1', ");
                sql.append("'0', ");
                sql.append("'F', ");
                sql.append("'").append(button.getVisible()).append("', ");
                sql.append("'0', ");
                sql.append("'").append(button.getPerms()).append("', ");
                sql.append("'#', ");
                sql.append("'admin', ");
                sql.append("NOW(), ");
                sql.append("'', ");
                sql.append("NULL, ");
                sql.append("'');\n");
            }
            sql.append("\n");
        }

        return sql.toString();
    }

    /**
     * 生成字典 SQL
     *
     * @param dicts 字典设计列表
     * @return SQL 语句
     */
    private String generateDictSQL(List<RequirementAnalyzer.DictDesign> dicts)
    {
        StringBuilder sql = new StringBuilder();
        
        sql.append("-- 字典数据 SQL\n\n");

        for (RequirementAnalyzer.DictDesign dict : dicts)
        {
            // 插入字典类型
            sql.append("-- 插入字典类型：").append(dict.getDictName()).append("\n");
            sql.append("INSERT INTO sys_dict_type (dict_name, dict_type, status, create_by, create_time, update_by, update_time, remark)\n");
            sql.append("VALUES ('").append(dict.getDictName()).append("', ");
            sql.append("'").append(dict.getDictType()).append("', ");
            sql.append("'0', ");
            sql.append("'admin', ");
            sql.append("NOW(), ");
            sql.append("'', ");
            sql.append("NULL, ");
            sql.append("'").append(dict.getDictName()).append("');\n\n");

            // 插入字典数据
            if (dict.getItems() != null && !dict.getItems().isEmpty())
            {
                sql.append("-- 插入字典数据\n");
                for (RequirementAnalyzer.DictItem item : dict.getItems())
                {
                    sql.append("INSERT INTO sys_dict_data (dict_sort, dict_label, dict_value, dict_type, is_default, status, create_by, create_time, update_by, update_time, remark)\n");
                    sql.append("VALUES (").append(item.getDictSort()).append(", ");
                    sql.append("'").append(item.getDictLabel()).append("', ");
                    sql.append("'").append(item.getDictValue()).append("', ");
                    sql.append("'").append(dict.getDictType()).append("', ");
                    sql.append("'").append(item.getIsDefault()).append("', ");
                    sql.append("'0', ");
                    sql.append("'admin', ");
                    sql.append("NOW(), ");
                    sql.append("'', ");
                    sql.append("NULL, ");
                    sql.append("'').append("\n");
                }
                sql.append("\n");
            }
        }

        return sql.toString();
    }

    /**
     * 保存 SQL 到文件
     *
     * @param sql SQL 内容
     * @param projectPath 项目路径
     * @param tableName 表名
     * @param type 类型（table/menu/dict）
     * @throws IOException IO异常
     */
    private void saveSQLToFile(String sql, String projectPath, String tableName, String type) throws IOException
    {
        // 如果没有指定项目路径，使用当前目录
        String sqlDirPath = projectPath != null ? projectPath + "/sql" : "sql";
        File sqlDir = new File(sqlDirPath);
        if (!sqlDir.exists())
        {
            sqlDir.mkdirs();
        }

        String fileName = tableName + "_" + type + ".sql";
        String filePath = sqlDirPath + "/" + fileName;

        try (FileWriter writer = new FileWriter(filePath))
        {
            writer.write(sql);
        }

        System.out.println("SQL 文件已保存：" + filePath);
    }

    /**
     * 执行 SQL
     *
     * @param sql SQL 语句
     * @return 是否成功
     * @throws SQLException SQL异常
     */
    private boolean executeSQL(String sql) throws SQLException
    {
        try (Statement stmt = connection.createStatement())
        {
            // 分割 SQL 语句
            String[] sqlStatements = sql.split(";");
            
            for (String statement : sqlStatements)
            {
                if (statement.trim().isEmpty() || statement.trim().startsWith("--"))
                {
                    continue;
                }

                try
                {
                    stmt.execute(statement);
                    System.out.println("SQL 执行成功：" + statement.substring(0, Math.min(50, statement.length())) + "...");
                }
                catch (SQLException e)
                {
                    // 忽略表已存在的错误
                    if (!e.getMessage().contains("already exists"))
                    {
                        System.err.println("SQL 执行失败：" + e.getMessage());
                        throw e;
                    }
                }
            }

            return true;
        }
    }

    /**
     * 关闭连接
     *
     * @throws SQLException SQL异常
     */
    public void close() throws SQLException
    {
        if (connection != null && !connection.isClosed())
        {
            connection.close();
        }
    }

    /**
     * 测试连接
     *
     * @return 是否连接成功
     */
    public boolean testConnection()
    {
        try
        {
            return connection != null && !connection.isClosed();
        }
        catch (SQLException e)
        {
            return false;
        }
    }
}
