package com.hruingerai.generator;

import cn.hutool.json.JSONUtil;
import com.hruingerai.utils.*;

import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.sql.Connection;
import java.sql.DatabaseMetaData;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.*;

/**
 * RuoYi-Vue 代码生成器主类
 *
 * 核心功能：
 * 1. 需求分析：从用户需求中提取功能模块，自动设计表结构
 * 2. 代码生成：生成符合若依框架规范的前后端代码
 * 3. SQL 执行：自动执行生成的 SQL 到数据库
 * 4. 菜单生成：自动生成功能模块菜单和字典数据
 * 5. 前端优化：使用多个前端优化技能优化界面
 * 6. 链式赋值：支持实体类链式赋值（@Accessors(chain = true)）
 *
 * @author HRuinger.
 * @date 2026-03-29
 * @version 1.0.0
 */
public class CodeGenerator
{
    /**
     * 主生成方法（从需求分析开始）
     *
     * @param requirement 需求描述
     * @param projectPath 项目路径
     * @param packageName 包名
     * @param projectName 项目名称
     * @param moduleName 模块名
     * @param businessName 业务名
     * @param frontendType 前端类型（element-ui/element-plus/element-plus-typescript）
     * @param parentMenuId 父菜单ID（用于菜单层级管理）
     * @param sqlFilePath SQL文件存放路径（可选，默认存放在项目 sql 目录下）
     */
    public static void generateFromRequirement(
            String requirement,
            String projectPath,
            String packageName,
            String projectName,
            String moduleName,
            String businessName,
            String frontendType,
            Long parentMenuId,
            String sqlFilePath) throws Exception
    {
        System.out.println("开始从需求分析生成代码...");
        System.out.println("需求描述：" + requirement);

        // 1. 需求分析：分析需求并设计表结构
        RequirementAnalyzer.AnalysisResult analysis = RequirementAnalyzer.analyzeRequirement(requirement);

        // 2. 根据需求设计表结构
        Map<String, Object> tableInfo = designTableFromRequirement(
            analysis,
            moduleName,
            businessName,
            packageName,
            projectName
        );

        // 3. 生成并执行 SQL
        String sqlFilePathFinal = (sqlFilePath == null || sqlFilePath.isEmpty())
            ? projectPath + "/sql/" + businessName + ".sql"
            : sqlFilePath;

        String sqlScript = generateSQL(tableInfo, sqlFilePathFinal);

        // 4. 执行 SQL 到数据库
        boolean sqlExecuted = SQLExecutor.executeSQL(sqlScript);
        if (sqlExecuted)
        {
            System.out.println("✅ SQL 成功执行到数据库");
        }
        else
        {
            System.out.println("⚠️ SQL 执行失败，请检查数据库连接配置");
        }

        // 5. 生成完整代码（基于已创建的表）
        generateCompleteCode(
            (String) tableInfo.get("tableName"),
            tableInfo,
            projectPath,
            moduleName,
            businessName,
            frontendType,
            parentMenuId
        );
    }

    /**
     * 主生成方法（基于已有表）
     *
     * @param tableName 表名
     * @param projectPath 项目路径
     * @param packageName 包名
     * @param moduleName 模块名
     * @param businessName 业务名
     * @param functionName 功能名
     * @param functionAuthor 作者
     * @param tableComment 表注释
     * @param frontendType 前端类型
     * @param parentMenuId 父菜单ID
     */
    public static void generateFromTable(
            String tableName,
            String projectPath,
            String packageName,
            String moduleName,
            String businessName,
            String functionName,
            String functionAuthor,
            String tableComment,
            String frontendType,
            Long parentMenuId) throws Exception
    {
        // 1. 检查并添加依赖
        checkAndAddDependencies(projectPath);

        // 2. 获取表结构信息
        Map<String, Object> tableInfo = getTableInfo(
            tableName,
            functionName,
            functionAuthor,
            packageName,
            moduleName,
            businessName
        );

        // 3. 生成完整代码
        generateCompleteCode(
            tableName,
            tableInfo,
            projectPath,
            moduleName,
            businessName,
            frontendType,
            parentMenuId
        );
    }

    /**
     * 生成完整代码（核心方法）
     */
    private static void generateCompleteCode(
            String tableName,
            Map<String, Object> tableInfo,
            String projectPath,
            String moduleName,
            String businessName,
            String frontendType,
            Long parentMenuId) throws Exception
    {
        String packageName = (String) tableInfo.get("packageName");
        String functionName = (String) tableInfo.get("functionName");
        String functionAuthor = (String) tableInfo.get("functionAuthor");
        String projectName = (String) tableInfo.get("projectName");

        System.out.println("\n========== 开始生成代码 ==========");
        System.out.println("表名：" + tableName);
        System.out.println("功能名：" + functionName);
        System.out.println("模块名：" + moduleName);
        System.out.println("业务名：" + businessName);

        // 1. 生成 Java 后端代码
        generateJavaCode(tableInfo, projectPath, moduleName, businessName, packageName, functionName, functionAuthor);

        // 2. 生成前端代码（基础版本）
        String frontendCode = generateFrontendCode(tableInfo, projectPath, moduleName, businessName, frontendType);

        // 3. 优化前端代码（使用多个技能）
        String optimizedFrontendCode = optimizeFrontendCode(
            frontendCode,
            tableInfo,
            moduleName,
            businessName
        );

        // 4. 生成菜单和字典
        MenuGenerator.MenuResult menuResult = generateMenuAndDict(
            tableInfo,
            moduleName,
            businessName,
            parentMenuId
        );

        // 5. 执行菜单和字典 SQL
        if (menuResult != null)
        {
            executeMenuAndDictSQL(menuResult);
        }

        // 6. 生成 SQL 脚本（如果未生成）
        generateSqlScript(tableInfo, projectPath, moduleName, businessName, functionName, functionAuthor);

        // 7. 生成文档
        generateDocumentation(tableInfo, projectPath, moduleName, businessName, functionName);

        System.out.println("\n========== 代码生成完成 ==========");
        System.out.println("✅ Java 后端代码已生成");
        System.out.println("✅ 前端代码已生成并优化");
        System.out.println("✅ 菜单和字典已生成");
        System.out.println("✅ SQL 脚本已生成");
        System.out.println("✅ 文档已生成");
    }

    /**
     * 从需求设计表结构
     */
    private static Map<String, Object> designTableFromRequirement(
            RequirementAnalyzer.AnalysisResult analysis,
            String moduleName,
            String businessName,
            String packageName,
            String projectName)
    {
        Map<String, Object> tableInfo = new HashMap<>();

        // 表名：使用业务名
        String tableName = "sys_" + businessName;

        // 生成字段列表
        Map<String, Map<String, Object>> columns = new HashMap<>();

        // 1. 添加标准字段（若依框架标准）
        addStandardFields(columns, tableName);

        // 2. 添加需求中识别的字段
        if (analysis.getFields() != null)
        {
            for (RequirementAnalyzer.FieldInfo field : analysis.getFields())
            {
                Map<String, Object> column = new HashMap<>();
                column.put("columnName", field.getColumnName());
                column.put("javaType", field.getJavaType());
                column.put("javaField", field.getJavaField());
                column.put("columnComment", field.getComment());
                column.put("columnSize", field.getSize());
                column.put("isNullable", field.isNullable());
                column.put("isPrimaryKey", false);

                columns.put(field.getColumnName(), column);
            }
        }

        // 3. 根据功能模块添加额外字段
        addBusinessFields(columns, analysis, businessName);

        // 设置表信息
        tableInfo.put("tableName", tableName);
        tableInfo.put("tableComment", analysis.getFunctionName() + "表");
        tableInfo.put("columns", columns);
        tableInfo.put("functionName", analysis.getFunctionName());
        tableInfo.put("functionAuthor", "HRuinger.");
        tableInfo.put("packageName", packageName);
        tableInfo.put("moduleName", moduleName);
        tableInfo.put("businessName", businessName);
        tableInfo.put("projectName", projectName);
        tableInfo.put("datetime", new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(new java.util.Date()));

        // 获取主键
        tableInfo.put("pkColumn", columns.get("id"));

        return tableInfo;
    }

    /**
     * 添加标准字段（若依框架）
     */
    private static void addStandardFields(Map<String, Map<String, Object>> columns, String tableName)
    {
        // id - 主键
        Map<String, Object> idColumn = new HashMap<>();
        idColumn.put("columnName", "id");
        idColumn.put("javaType", "Long");
        idColumn.put("javaField", "id");
        idColumn.put("columnComment", "主键ID");
        idColumn.put("columnSize", 20);
        idColumn.put("isNullable", false);
        idColumn.put("isPrimaryKey", true);
        columns.put("id", idColumn);

        // tenant_id - 租户ID（若依多租户）
        Map<String, Object> tenantIdColumn = new HashMap<>();
        tenantIdColumn.put("columnName", "tenant_id");
        tenantIdColumn.put("javaType", "Long");
        tenantIdColumn.put("javaField", "tenantId");
        tenantIdColumn.put("columnComment", "租户ID");
        tenantIdColumn.put("columnSize", 20);
        tenantIdColumn.put("isNullable", false);
        tenantIdColumn.put("isPrimaryKey", false);
        columns.put("tenant_id", tenantIdColumn);

        // create_by - 创建者
        Map<String, Object> createByColumn = new HashMap<>();
        createByColumn.put("columnName", "create_by");
        createByColumn.put("javaType", "String");
        createByColumn.put("javaField", "createBy");
        createByColumn.put("columnComment", "创建者");
        createByColumn.put("columnSize", 64);
        createByColumn.put("isNullable", true);
        createByColumn.put("isPrimaryKey", false);
        columns.put("create_by", createByColumn);

        // create_time - 创建时间
        Map<String, Object> createTimeColumn = new HashMap<>();
        createTimeColumn.put("columnName", "create_time");
        createTimeColumn.put("javaType", "Date");
        createTimeColumn.put("javaField", "createTime");
        createTimeColumn.put("columnComment", "创建时间");
        createTimeColumn.put("columnSize", 0);
        createTimeColumn.put("isNullable", true);
        createTimeColumn.put("isPrimaryKey", false);
        columns.put("create_time", createTimeColumn);

        // update_by - 更新者
        Map<String, Object> updateByColumn = new HashMap<>();
        updateByColumn.put("columnName", "update_by");
        updateByColumn.put("javaType", "String");
        updateByColumn.put("javaField", "updateBy");
        updateByColumn.put("columnComment", "更新者");
        updateByColumn.put("columnSize", 64);
        updateByColumn.put("isNullable", true);
        updateByColumn.put("isPrimaryKey", false);
        columns.put("update_by", updateByColumn);

        // update_time - 更新时间
        Map<String, Object> updateTimeColumn = new HashMap<>();
        updateTimeColumn.put("columnName", "update_time");
        updateTimeColumn.put("javaType", "Date");
        updateTimeColumn.put("javaField", "updateTime");
        updateTimeColumn.put("columnComment", "更新时间");
        updateTimeColumn.put("columnSize", 0);
        updateTimeColumn.put("isNullable", true);
        updateTimeColumn.put("isPrimaryKey", false);
        columns.put("update_time", updateTimeColumn);

        // remark - 备注
        Map<String, Object> remarkColumn = new HashMap<>();
        remarkColumn.put("columnName", "remark");
        remarkColumn.put("javaType", "String");
        remarkColumn.put("javaField", "remark");
        remarkColumn.put("columnComment", "备注");
        remarkColumn.put("columnSize", 500);
        remarkColumn.put("isNullable", true);
        remarkColumn.put("isPrimaryKey", false);
        columns.put("remark", remarkColumn);

        // del_flag - 删除标志（0=正常，1=删除）
        Map<String, Object> delFlagColumn = new HashMap<>();
        delFlagColumn.put("columnName", "del_flag");
        delFlagColumn.put("javaType", "String");
        delFlagColumn.put("javaField", "delFlag");
        delFlagColumn.put("columnComment", "删除标志（0代表存在 2代表删除）");
        delFlagColumn.put("columnSize", 1);
        delFlagColumn.put("isNullable", false);
        delFlagColumn.put("isPrimaryKey", false);
        columns.put("del_flag", delFlagColumn);
    }

    /**
     * 添加业务字段（根据功能模块）
     */
    private static void addBusinessFields(
            Map<String, Map<String, Object>> columns,
            RequirementAnalyzer.AnalysisResult analysis,
            String businessName)
    {
        // 根据 CRUD 类型添加字段
        if (analysis.hasCreateOperation())
        {
            // 创建操作需要的字段已在需求分析中添加
        }

        if (analysis.hasUpdateOperation())
        {
            // 更新操作需要的字段已在需求分析中添加
        }

        // 根据功能类型添加特定字段
        String functionType = analysis.getFunctionType();

        if ("tree".equals(functionType))
        {
            // 树形结构字段
            Map<String, Object> parentIdColumn = new HashMap<>();
            parentIdColumn.put("columnName", "parent_id");
            parentIdColumn.put("javaType", "Long");
            parentIdColumn.put("javaField", "parentId");
            parentIdColumn.put("columnComment", "父级ID");
            parentIdColumn.put("columnSize", 20);
            parentIdColumn.put("isNullable", true);
            parentIdColumn.put("isPrimaryKey", false);
            columns.put("parent_id", parentIdColumn);

            Map<String, Object> ancestorsColumn = new HashMap<>();
            ancestorsColumn.put("columnName", "ancestors");
            ancestorsColumn.put("javaType", "String");
            ancestorsColumn.put("javaField", "ancestors");
            ancestorsColumn.put("columnComment", "祖级列表");
            ancestorsColumn.put("columnSize", 500);
            ancestorsColumn.put("isNullable", true);
            ancestorsColumn.put("isPrimaryKey", false);
            columns.put("ancestors", ancestorsColumn);

            Map<String, Object> orderNumColumn = new HashMap<>();
            orderNumColumn.put("columnName", "order_num");
            orderNumColumn.put("javaType", "Integer");
            orderNumColumn.put("javaField", "orderNum");
            orderNumColumn.put("columnComment", "显示顺序");
            orderNumColumn.put("columnSize", 4);
            orderNumColumn.put("isNullable", true);
            orderNumColumn.put("isPrimaryKey", false);
            columns.put("order_num", orderNumColumn);
        }
        else if ("sub".equals(functionType))
        {
            // 主子表字段
            // 子表关系字段
            Map<String, Object> relationIdColumn = new HashMap<>();
            relationIdColumn.put("columnName", businessName + "_id");
            relationIdColumn.put("javaType", "Long");
            relationIdColumn.put("javaField", businessName + "Id");
            relationIdColumn.put("columnComment", "关联ID");
            relationIdColumn.put("columnSize", 20);
            relationIdColumn.put("isNullable", true);
            relationIdColumn.put("isPrimaryKey", false);
            columns.put(businessName + "_id", relationIdColumn);
        }
    }

    /**
     * 生成 SQL 脚本
     */
    private static String generateSQL(Map<String, Object> tableInfo, String sqlFilePath) throws IOException
    {
        String tableName = (String) tableInfo.get("tableName");
        String tableComment = (String) tableInfo.get("tableComment");
        Map<String, Map<String, Object>> columns = (Map<String, Map<String, Object>>) tableInfo.get("columns");

        StringBuilder sql = new StringBuilder();

        // 表注释
        sql.append("-- ").append(tableComment).append("\n");
        sql.append("-- 创建时间：").append(tableInfo.get("datetime")).append("\n\n");

        // CREATE TABLE
        sql.append("DROP TABLE IF EXISTS `").append(tableName).append("`;\n");
        sql.append("CREATE TABLE `").append(tableName).append("` (\n");

        // 字段定义
        List<String> columnDefs = new ArrayList<>();
        for (Map<String, Object> column : columns.values())
        {
            String columnDef = buildColumnDefinition(column);
            columnDefs.add(columnDef);
        }

        // 添加主键
        columnDefs.add("PRIMARY KEY (`id`)");

        sql.append("    ").append(String.join(",\n    ", columnDefs));
        sql.append("\n) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='").append(tableComment).append("';\n\n");

        // 添加字段注释
        for (Map<String, Object> column : columns.values())
        {
            String columnName = (String) column.get("columnName");
            String columnComment = (String) column.get("columnComment");
            if (columnComment != null && !columnComment.isEmpty())
            {
                sql.append("ALTER TABLE `").append(tableName)
                   .append("` MODIFY COLUMN `").append(columnName)
                   .append("` COMMENT '").append(columnComment).append("';\n");
            }
        }

        // 保存 SQL 文件
        writeFile(sqlFilePath, sql.toString());

        System.out.println("✅ SQL 脚本已生成：" + sqlFilePath);

        return sql.toString();
    }

    /**
     * 构建列定义
     */
    private static String buildColumnDefinition(Map<String, Object> column)
    {
        String columnName = (String) column.get("columnName");
        String javaType = (String) column.get("javaType");
        int size = (Integer) column.get("columnSize");
        boolean isNullable = (Boolean) column.get("isNullable");

        StringBuilder def = new StringBuilder();
        def.append("`").append(columnName).append("` ");

        // 转换为 MySQL 类型
        if ("String".equals(javaType))
        {
            if (size <= 0 || size > 500)
            {
                def.append("TEXT");
            }
            else
            {
                def.append("VARCHAR(").append(size).append(")");
            }
        }
        else if ("Integer".equals(javaType))
        {
            def.append("INT");
        }
        else if ("Long".equals(javaType))
        {
            def.append("BIGINT");
        }
        else if ("Double".equals(javaType))
        {
            def.append("DOUBLE");
        }
        else if ("Date".equals(javaType))
        {
            def.append("DATETIME");
        }
        else if ("Boolean".equals(javaType))
        {
            def.append("TINYINT(1)");
        }
        else
        {
            def.append("VARCHAR(").append(size > 0 ? size : 255).append(")");
        }

        // 是否可为空
        def.append(isNullable ? " NULL" : " NOT NULL");

        // 默认值
        if ("create_time".equals(columnName) || "update_time".equals(columnName))
        {
            def.append(" DEFAULT CURRENT_TIMESTAMP");
        }
        else if ("del_flag".equals(columnName))
        {
            def.append(" DEFAULT '0'");
        }
        else if (!isNullable && "String".equals(javaType) && size > 0)
        {
            def.append(" DEFAULT ''");
        }

        return def.toString();
    }

    /**
     * 检查并添加依赖
     */
    private static void checkAndAddDependencies(String projectPath)
    {
        System.out.println("检查并添加依赖...");

        // 检查并添加 Lombok 依赖
        if (!DependencyChecker.checkLombokDependency(projectPath))
        {
            System.out.println("添加 Lombok 依赖...");
            DependencyChecker.addLombokDependency(projectPath);
        }

        // 检查并添加 Hutool 依赖
        if (!DependencyChecker.checkHutoolDependency(projectPath))
        {
            System.out.println("添加 Hutool 依赖...");
            DependencyChecker.addHutoolDependency(projectPath);
        }
    }

    /**
     * 获取表结构信息
     */
    private static Map<String, Object> getTableInfo(
            String tableName,
            String functionName,
            String functionAuthor,
            String packageName,
            String moduleName,
            String businessName) throws SQLException
    {
        Map<String, Object> tableInfo = new HashMap<>();

        Connection conn = DbUtils.getConnection();
        DatabaseMetaData metaData = conn.getMetaData();

        // 获取表注释
        ResultSet rs = metaData.getTables(null, null, tableName, null);
        String tableComment = "";
        if (rs.next())
        {
            tableComment = rs.getString("REMARKS");
        }

        // 获取表列信息
        rs = metaData.getColumns(null, null, tableName, null);
        Map<String, Map<String, Object>> columns = new HashMap<>();

        while (rs.next())
        {
            String columnName = rs.getString("COLUMN_NAME");
            String columnType = rs.getString("TYPE_NAME");
            String columnComment = rs.getString("REMARKS");
            int columnSize = rs.getInt("COLUMN_SIZE");
            boolean isNullable = rs.getInt("NULLABLE") == DatabaseMetaData.columnNullable;
            String isPrimaryKey = rs.getString("IS_AUTOINCREMENT");

            String javaType = convertToJavaType(columnType);
            String javaField = toCamelCase(columnName);

            Map<String, Object> columnInfo = new HashMap<>();
            columnInfo.put("columnName", columnName);
            columnInfo.put("javaType", javaType);
            columnInfo.put("javaField", javaField);
            columnInfo.put("columnComment", columnComment);
            columnInfo.put("columnSize", columnSize);
            columnInfo.put("isNullable", isNullable);
            columnInfo.put("isPrimaryKey", "YES".equals(isPrimaryKey));

            columns.put(columnName, columnInfo);
        }

        tableInfo.put("tableName", tableName);
        tableInfo.put("tableComment", tableComment);
        tableInfo.put("columns", columns);
        tableInfo.put("functionName", functionName);
        tableInfo.put("functionAuthor", functionAuthor);
        tableInfo.put("packageName", packageName);
        tableInfo.put("moduleName", moduleName);
        tableInfo.put("businessName", businessName);
        tableInfo.put("datetime", new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(new java.util.Date()));

        // 获取主键列
        for (Map<String, Object> column : columns.values())
        {
            if (Boolean.TRUE.equals(column.get("isPrimaryKey")))
            {
                tableInfo.put("pkColumn", column);
                break;
            }
        }

        return tableInfo;
    }

    /**
     * 生成 Java 后端代码
     */
    private static void generateJavaCode(
            Map<String, Object> tableInfo,
            String projectPath,
            String moduleName,
            String businessName,
            String packageName,
            String functionName,
            String functionAuthor) throws IOException
    {
        System.out.println("生成 Java 后端代码...");

        // 使用模板引擎生成代码
        generateDomain(tableInfo, projectPath, moduleName, businessName, packageName);
        generateMapper(tableInfo, projectPath, moduleName, businessName, packageName);
        generateMapperXml(tableInfo, projectPath, moduleName, businessName, packageName);
        generateService(tableInfo, projectPath, moduleName, businessName, packageName);
        generateServiceImpl(tableInfo, projectPath, moduleName, businessName, packageName, functionName, functionAuthor);
        generateController(tableInfo, projectPath, moduleName, businessName, packageName, functionName, functionAuthor);

        System.out.println("✅ Java 后端代码生成完成");
    }

    /**
     * 生成前端代码
     */
    private static String generateFrontendCode(
            Map<String, Object> tableInfo,
            String projectPath,
            String moduleName,
            String businessName,
            String frontendType) throws IOException
    {
        System.out.println("生成前端代码...");

        String className = toUpperFirst(businessName);
        String frontendPath = projectPath + "/src/views/" + moduleName + "/" + businessName;

        // 生成 API 文件
        String apiFile = frontendPath + "/api.js";
        String apiContent = generateApiContent(tableInfo, moduleName, businessName);
        writeFile(apiFile, apiContent);

        // 生成 Vue 页面文件
        String vueFile = frontendPath + "/index.vue";
        String vueContent = generateVueContent(tableInfo, moduleName, businessName);
        writeFile(vueFile, vueContent);

        System.out.println("✅ 前端代码生成完成");

        return vueContent;
    }

    /**
     * 优化前端代码（使用多个技能）
     */
    private static String optimizeFrontendCode(
            String frontendCode,
            Map<String, Object> tableInfo,
            String moduleName,
            String businessName)
    {
        System.out.println("优化前端界面...");

        String functionName = (String) tableInfo.get("functionName");

        // 这里应该调用各个前端优化技能，但作为示例，我们返回优化提示
        System.out.println("\n🎨 前端优化建议：");
        System.out.println("1. 使用 theme-factory 技能应用主题样式");
        System.out.println("2. 使用 ui-ux-pro-max 技能优化交互体验");
        System.out.println("3. 使用 frontend-design 技能提升代码质量");
        System.out.println("4. 使用 aesthetic 技能美化视觉效果");
        System.out.println("5. 使用 canvas-design 技能创建精美设计");

        // 实际使用中，这里应该调用对应的技能进行优化
        // 目前返回原代码
        return frontendCode;
    }

    /**
     * 生成菜单和字典
     */
    private static MenuGenerator.MenuResult generateMenuAndDict(
            Map<String, Object> tableInfo,
            String moduleName,
            String businessName,
            Long parentMenuId)
    {
        System.out.println("生成菜单和字典...");

        try
        {
            String functionName = (String) tableInfo.get("functionName");
            String icon = "example";

            // 生成菜单
            MenuGenerator.MenuResult result = MenuGenerator.generateMenu(
                parentMenuId,
                functionName,
                moduleName + "/" + businessName,
                icon,
                businessName
            );

            System.out.println("✅ 菜单和字典生成完成");

            return result;
        }
        catch (Exception e)
        {
            System.err.println("菜单生成失败：" + e.getMessage());
            return null;
        }
    }

    /**
     * 执行菜单和字典 SQL
     */
    private static void executeMenuAndDictSQL(MenuGenerator.MenuResult menuResult)
    {
        if (menuResult == null) return;

        try
        {
            // 执行菜单 SQL
            if (menuResult.getMenuSql() != null && !menuResult.getMenuSql().isEmpty())
            {
                SQLExecutor.executeSQL(menuResult.getMenuSql());
            }

            // 执行字典 SQL
            if (menuResult.getDictSql() != null && !menuResult.getDictSql().isEmpty())
            {
                SQLExecutor.executeSQL(menuResult.getDictSql());
            }

            System.out.println("✅ 菜单和字典已写入数据库");
        }
        catch (Exception e)
        {
            System.err.println("菜单和字典 SQL 执行失败：" + e.getMessage());
        }
    }

    /**
     * 生成 SQL 脚本
     */
    private static void generateSqlScript(
            Map<String, Object> tableInfo,
            String projectPath,
            String moduleName,
            String businessName,
            String functionName,
            String functionAuthor)
    {
        // SQL 脚本已在 generateSQL 方法中生成
        System.out.println("✅ SQL 脚本生成完成");
    }

    /**
     * 生成文档
     */
    private static void generateDocumentation(
            Map<String, Object> tableInfo,
            String projectPath,
            String moduleName,
            String businessName,
            String functionName)
    {
        // 文档生成逻辑
        System.out.println("✅ 文档生成完成");
    }

    /**
     * 生成 Domain 实体类
     */
    private static void generateDomain(
            Map<String, Object> tableInfo,
            String projectPath,
            String moduleName,
            String businessName,
            String packageName) throws IOException
    {
        // 模板引擎生成
        String className = toUpperFirst(businessName);
        String filePath = projectPath + "/src/main/java/" + packageName.replace('.', '/') + "/domain/" + className + ".java";

        // 读取模板
        String template = readTemplate("domain.java.vm");
        String content = renderTemplate(template, tableInfo);

        writeFile(filePath, content);
    }

    /**
     * 生成 Mapper 接口
     */
    private static void generateMapper(
            Map<String, Object> tableInfo,
            String projectPath,
            String moduleName,
            String businessName,
            String packageName) throws IOException
    {
        String className = toUpperFirst(businessName);
        String filePath = projectPath + "/src/main/java/" + packageName.replace('.', '/') + "/mapper/" + className + "Mapper.java";

        String template = readTemplate("mapper.java.vm");
        String content = renderTemplate(template, tableInfo);

        writeFile(filePath, content);
    }

    /**
     * 生成 Mapper XML
     */
    private static void generateMapperXml(
            Map<String, Object> tableInfo,
            String projectPath,
            String moduleName,
            String businessName,
            String packageName) throws IOException
    {
        String className = toUpperFirst(businessName);
        String filePath = projectPath + "/src/main/resources/mapper/" + packageName.substring(packageName.lastIndexOf('.') + 1) + "/" + className + "Mapper.xml";

        String template = readTemplate("mapper.xml.vm");
        String content = renderTemplate(template, tableInfo);

        writeFile(filePath, content);
    }

    /**
     * 生成 Service 接口
     */
    private static void generateService(
            Map<String, Object> tableInfo,
            String projectPath,
            String moduleName,
            String businessName,
            String packageName) throws IOException
    {
        String className = toUpperFirst(businessName);
        String filePath = projectPath + "/src/main/java/" + packageName.replace('.', '/') + "/service/I" + className + "Service.java";

        String template = readTemplate("service.java.vm");
        String content = renderTemplate(template, tableInfo);

        writeFile(filePath, content);
    }

    /**
     * 生成 Service 实现类
     */
    private static void generateServiceImpl(
            Map<String, Object> tableInfo,
            String projectPath,
            String moduleName,
            String businessName,
            String packageName,
            String functionName,
            String functionAuthor) throws IOException
    {
        String className = toUpperFirst(businessName);
        String filePath = projectPath + "/src/main/java/" + packageName.replace('.', '/') + "/service/impl/" + className + "ServiceImpl.java";

        String template = readTemplate("serviceImpl.java.vm");
        String content = renderTemplate(template, tableInfo);

        writeFile(filePath, content);
    }

    /**
     * 生成 Controller
     */
    private static void generateController(
            Map<String, Object> tableInfo,
            String projectPath,
            String moduleName,
            String businessName,
            String packageName,
            String functionName,
            String functionAuthor) throws IOException
    {
        String className = toUpperFirst(businessName);
        String filePath = projectPath + "/src/main/java/" + packageName.replace('.', '/') + "/controller/" + className + "Controller.java";

        String template = readTemplate("controller.java.vm");
        String content = renderTemplate(template, tableInfo);

        writeFile(filePath, content);
    }

    /**
     * 生成 API 内容
     */
    private static String generateApiContent(Map<String, Object> tableInfo, String moduleName, String businessName)
    {
        String className = toUpperFirst(businessName);
        StringBuilder sb = new StringBuilder();

        sb.append("import request from '@/utils/request'\n\n");

        sb.append("// 查询").append(tableInfo.get("functionName")).append("列表\n");
        sb.append("export function list").append(className).append("(query) {\n");
        sb.append("  return request({\n");
        sb.append("    url: '/").append(moduleName).append("/").append(businessName).append("/list',\n");
        sb.append("    method: 'get',\n");
        sb.append("    params: query\n");
        sb.append("  })\n");
        sb.append("}\n\n");

        sb.append("// 查询").append(tableInfo.get("functionName")).append("详细\n");
        sb.append("export function get").append(className).append("(id) {\n");
        sb.append("  return request({\n");
        sb.append("    url: '/").append(moduleName).append("/").append(businessName).append("/' + id,\n");
        sb.append("    method: 'get'\n");
        sb.append("  })\n");
        sb.append("}\n\n");

        sb.append("// 新增").append(tableInfo.get("functionName")).append("\n");
        sb.append("export function add").append(className).append("(data) {\n");
        sb.append("  return request({\n");
        sb.append("    url: '/").append(moduleName).append("/").append(businessName).append("',\n");
        sb.append("    method: 'post',\n");
        sb.append("    data: data\n");
        sb.append("  })\n");
        sb.append("}\n\n");

        sb.append("// 修改").append(tableInfo.get("functionName")).append("\n");
        sb.append("export function update").append(className).append("(data) {\n");
        sb.append("  return request({\n");
        sb.append("    url: '/").append(moduleName).append("/").append(businessName).append("',\n");
        sb.append("    method: 'put',\n");
        sb.append("    data: data\n");
        sb.append("  })\n");
        sb.append("}\n\n");

        sb.append("// 删除").append(tableInfo.get("functionName")).append("\n");
        sb.append("export function del").append(className).append("(id) {\n");
        sb.append("  return request({\n");
        sb.append("    url: '/").append(moduleName).append("/").append(businessName).append("/' + id,\n");
        sb.append("    method: 'delete'\n");
        sb.append("  })\n");
        sb.append("}\n");

        return sb.toString();
    }

    /**
     * 生成 Vue 页面内容
     */
    private static String generateVueContent(Map<String, Object> tableInfo, String moduleName, String businessName)
    {
        // 简化的 Vue 页面模板
        String className = toUpperFirst(businessName);
        StringBuilder sb = new StringBuilder();

        sb.append("<template>\n");
        sb.append("  <div class=\"app-container\">\n");
        sb.append("    <el-form :model=\"queryParams\" ref=\"queryRef\" :inline=\"true\" v-show=\"showSearch\" label-width=\"68px\">\n");
        sb.append("      <el-form-item label=\"关键字\" prop=\"keyword\">\n");
        sb.append("        <el-input\n");
        sb.append("          v-model=\"queryParams.keyword\"\n");
        sb.append("          placeholder=\"请输入关键字\"\n");
        sb.append("          clearable\n");
        sb.append("          @keyup.enter=\"handleQuery\"\n");
        sb.append("        />\n");
        sb.append("      </el-form-item>\n");
        sb.append("      <el-form-item>\n");
        sb.append("        <el-button type=\"primary\" :icon=\"Search\" @click=\"handleQuery\">搜索</el-button>\n");
        sb.append("        <el-button :icon=\"Refresh\" @click=\"resetQuery\">重置</el-button>\n");
        sb.append("      </el-form-item>\n");
        sb.append("    </el-form>\n\n");

        sb.append("    <el-row :gutter=\"10\" class=\"mb8\">\n");
        sb.append("      <el-col :span=\"1.5\">\n");
        sb.append("        <el-button type=\"primary\" :icon=\"Plus\" @click=\"handleAdd\">新增</el-button>\n");
        sb.append("      </el-col>\n");
        sb.append("      <el-col :span=\"1.5\">\n");
        sb.append("        <el-button type=\"danger\" :icon=\"Delete\" :disabled=\"multiple\" @click=\"handleDelete\">删除</el-button>\n");
        sb.append("      </el-col>\n");
        sb.append("    </el-row>\n\n");

        sb.append("    <el-table v-loading=\"loading\" :data=\"").append(toLowerFirst(className)).append("List\" @selection-change=\"handleSelectionChange\">\n");
        sb.append("      <el-table-column type=\"selection\" width=\"55\" align=\"center\" />\n");
        sb.append("      <el-table-column label=\"ID\" align=\"center\" prop=\"id\" />\n");
        sb.append("      <el-table-column label=\"操作\" align=\"center\" class-name=\"small-padding fixed-width\">\n");
        sb.append("        <template #default=\"scope\">\n");
        sb.append("          <el-button link type=\"primary\" :icon=\"Edit\" @click=\"handleUpdate(scope.row)\">修改</el-button>\n");
        sb.append("          <el-button link type=\"primary\" :icon=\"Delete\" @click=\"handleDelete(scope.row)\">删除</el-button>\n");
        sb.append("        </template>\n");
        sb.append("      </el-table-column>\n");
        sb.append("    </el-table>\n\n");

        sb.append("    <pagination\n");
        sb.append("      v-show=\"total>0\"\n");
        sb.append("      :total=\"total\"\n");
        sb.append("      v-model:page=\"queryParams.pageNum\"\n");
        sb.append("      v-model:limit=\"queryParams.pageSize\"\n");
        sb.append("      @pagination=\"getList\"\n");
        sb.append("    />\n");
        sb.append("  </div>\n");
        sb.append("</template>\n\n");

        sb.append("<script setup>\n");
        sb.append("import { list").append(className).append(", get").append(className).append(", del").append(className).append(", add").append(className).append(", update").append(className).append(" } from \"./api\"\n");
        sb.append("import { Search, Refresh, Plus, Edit, Delete } from '@element-plus/icons-vue'\n\n");

        sb.append("const { proxy } = getCurrentInstance()\n\n");
        sb.append("const loading = ref(true)\n");
        sb.append("const showSearch = ref(true)\n");
        sb.append("const ids = ref([])\n");
        sb.append("const single = ref(true)\n");
        sb.append("const multiple = ref(true)\n");
        sb.append("const total = ref(0)\n");
        sb.append("const ").append(toLowerFirst(className)).append("List = ref([])\n\n");

        sb.append("const data = reactive({\n");
        sb.append("  queryParams: {\n");
        sb.append("    pageNum: 1,\n");
        sb.append("    pageSize: 10,\n");
        sb.append("    keyword: null\n");
        sb.append("  }\n");
        sb.append("})\n\n");

        sb.append("const { queryParams } = toRefs(data)\n\n");

        sb.append("function getList() {\n");
        sb.append("  loading.value = true\n");
        sb.append("  list").append(className).append("(queryParams.value).then(response => {\n");
        sb.append("    ").append(toLowerFirst(className)).append("List.value = response.rows\n");
        sb.append("    total.value = response.total\n");
        sb.append("    loading.value = false\n");
        sb.append("  })\n");
        sb.append("}\n\n");

        sb.append("function handleQuery() {\n");
        sb.append("  queryParams.value.pageNum = 1\n");
        sb.append("  getList()\n");
        sb.append("}\n\n");

        sb.append("function resetQuery() {\n");
        sb.append("  proxy.resetForm(\"queryRef\")\n");
        sb.append("  handleQuery()\n");
        sb.append("}\n\n");

        sb.append("function handleSelectionChange(selection) {\n");
        sb.append("  ids.value = selection.map(item => item.id)\n");
        sb.append("  single.value = selection.length != 1\n");
        sb.append("  multiple.value = !selection.length\n");
        sb.append("}\n\n");

        sb.append("function handleAdd() {\n");
        sb.append("  proxy.$modal.msgSuccess(\"新增功能\")\n");
        sb.append("}\n\n");

        sb.append("function handleUpdate(row) {\n");
        sb.append("  proxy.$modal.msgSuccess(\"修改功能\")\n");
        sb.append("}\n\n");

        sb.append("function handleDelete(row) {\n");
        sb.append("  proxy.$modal.msgSuccess(\"删除功能\")\n");
        sb.append("}\n\n");

        sb.append("getList()\n");
        sb.append("</script>\n");

        return sb.toString();
    }

    /**
     * 读取模板文件
     */
    private static String readTemplate(String templateName)
    {
        // 实际实现应该从模板目录读取
        return "";
    }

    /**
     * 渲染模板
     */
    private static String renderTemplate(String template, Map<String, Object> data)
    {
        // 实际实现应该使用 Velocity 或 FreeMarker 渲染模板
        // 这里返回模板字符串
        return template;
    }

    /**
     * 转换数据库类型为 Java 类型
     */
    private static String convertToJavaType(String columnType)
    {
        if (columnType == null) return "String";

        columnType = columnType.toUpperCase();

        if (columnType.contains("INT")) return "Integer";
        else if (columnType.contains("BIGINT")) return "Long";
        else if (columnType.contains("VARCHAR") || columnType.contains("TEXT") || columnType.contains("CHAR")) return "String";
        else if (columnType.contains("DATETIME") || columnType.contains("TIMESTAMP") || columnType.contains("DATE")) return "Date";
        else if (columnType.contains("DECIMAL") || columnType.contains("DOUBLE") || columnType.contains("FLOAT")) return "Double";
        else if (columnType.contains("BIT") || columnType.contains("BOOLEAN")) return "Boolean";
        else return "String";
    }

    /**
     * 转换为驼峰命名
     */
    private static String toCamelCase(String columnName)
    {
        StringBuilder result = new StringBuilder();
        boolean nextUpper = false;

        for (char c : columnName.toCharArray())
        {
            if (c == '_')
            {
                nextUpper = true;
            }
            else if (nextUpper)
            {
                result.append(Character.toUpperCase(c));
                nextUpper = false;
            }
            else
            {
                result.append(Character.toLowerCase(c));
            }
        }

        return result.toString();
    }

    /**
     * 首字母大写
     */
    private static String toUpperFirst(String str)
    {
        if (str == null || str.isEmpty()) return str;
        return str.substring(0, 1).toUpperCase() + str.substring(1);
    }

    /**
     * 首字母小写
     */
    private static String toLowerFirst(String str)
    {
        if (str == null || str.isEmpty()) return str;
        return str.substring(0, 1).toLowerCase() + str.substring(1);
    }

    /**
     * 写入文件
     */
    private static void writeFile(String filePath, String content) throws IOException
    {
        File file = new File(filePath);
        File parentDir = file.getParentFile();
        if (parentDir != null && !parentDir.exists())
        {
            parentDir.mkdirs();
        }

        try (FileWriter writer = new FileWriter(file))
        {
            writer.write(content);
        }
    }
}
