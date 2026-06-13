package com.hruingerai.utils;

import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * 智能文档解析器
 *
 * 功能：
 * 1. 自动提取配置：从需求文档或开发文档中自动提取表结构、字段信息
 * 2. 智能推断配置项：自动推断类名、业务名、模块名、权限前缀等配置
 * 3. 字段自动映射：根据数据库字段自动推断 Java 类型、显示类型、查询类型
 * 4. 减少手动配置：无需手动编写复杂的 JSON 配置文件
 *
 * @author HRuinger.
 * @date 2026-03-29
 * @version 4.0.0
 */
public class DocumentParser {

    /**
     * 支持的文档类型
     */
    public enum DocumentType {
        /**
         * Markdown 文档
         */
        MARKDOWN,

        /**
         * Word 文档
         */
        WORD,

        /**
         * Excel 文档
         */
        EXCEL,

        /**
         * PDF 文档
         */
        PDF,

        /**
         * 文本文档
         */
        TEXT,

        /**
         * 自动检测
         */
        AUTO
    }

    /**
     * 解析结果
     */
    public static class ParseResult {
        /**
         * 表名
         */
        private String tableName;

        /**
         * 功能名称
         */
        private String functionName;

        /**
         * 类名
         */
        private String className;

        /**
         * 业务名
         */
        private String businessName;

        /**
         * 模块名
         */
        private String moduleName;

        /**
         * 权限前缀
         */
        private String permissionPrefix;

        /**
         * 包名
         */
        private String packageName;

        /**
         * 项目名称
         */
        private String projectName;

        /**
         * 字段列表
         */
        private List<FieldInfo> fields;

        /**
         * 功能类型（crud/tree/sub）
         */
        private String functionType;

        /**
         * 操作类型（create/read/update/delete）
         */
        private List<String> operations;

        // Getters and Setters
        public String getTableName() { return tableName; }
        public void setTableName(String tableName) { this.tableName = tableName; }

        public String getFunctionName() { return functionName; }
        public void setFunctionName(String functionName) { this.functionName = functionName; }

        public String getClassName() { return className; }
        public void setClassName(String className) { this.className = className; }

        public String getBusinessName() { return businessName; }
        public void setBusinessName(String businessName) { this.businessName = businessName; }

        public String getModuleName() { return moduleName; }
        public void setModuleName(String moduleName) { this.moduleName = moduleName; }

        public String getPermissionPrefix() { return permissionPrefix; }
        public void setPermissionPrefix(String permissionPrefix) { this.permissionPrefix = permissionPrefix; }

        public String getPackageName() { return packageName; }
        public void setPackageName(String packageName) { this.packageName = packageName; }

        public String getProjectName() { return projectName; }
        public void setProjectName(String projectName) { this.projectName = projectName; }

        public List<FieldInfo> getFields() { return fields; }
        public void setFields(List<FieldInfo> fields) { this.fields = fields; }

        public String getFunctionType() { return functionType; }
        public void setFunctionType(String functionType) { this.functionType = functionType; }

        public List<String> getOperations() { return operations; }
        public void setOperations(List<String> operations) { this.operations = operations; }
    }

    /**
     * 字段信息
     */
    public static class FieldInfo {
        /**
         * 数据库字段名
         */
        private String columnName;

        /**
         * Java 字段名
         */
        private String javaField;

        /**
         * Java 类型
         */
        private String javaType;

        /**
         * 字段注释
         */
        private String comment;

        /**
         * 是否必填
         */
        private boolean required;

        /**
         * 字段长度
         */
        private int length;

        /**
         * 显示类型（input/select/radio/checkbox/date等）
         */
        private String displayType;

        /**
         * 查询类型（eq/like/between/in等）
         */
        private String queryType;

        /**
         * 字典类型（如果有）
         */
        private String dictType;

        // Getters and Setters
        public String getColumnName() { return columnName; }
        public void setColumnName(String columnName) { this.columnName = columnName; }

        public String getJavaField() { return javaField; }
        public void setJavaField(String javaField) { this.javaField = javaField; }

        public String getJavaType() { return javaType; }
        public void setJavaType(String javaType) { this.javaType = javaType; }

        public String getComment() { return comment; }
        public void setComment(String comment) { this.comment = comment; }

        public boolean isRequired() { return required; }
        public void setRequired(boolean required) { this.required = required; }

        public int getLength() { return length; }
        public void setLength(int length) { this.length = length; }

        public String getDisplayType() { return displayType; }
        public void setDisplayType(String displayType) { this.displayType = displayType; }

        public String getQueryType() { return queryType; }
        public void setQueryType(String queryType) { this.queryType = queryType; }

        public String getDictType() { return dictType; }
        public void setDictType(String dictType) { this.dictType = dictType; }
    }

    /**
     * 解析文档
     *
     * @param filePath 文件路径
     * @param documentType 文档类型
     * @return 解析结果
     * @throws IOException IO异常
     */
    public static ParseResult parseDocument(String filePath, DocumentType documentType) throws IOException {
        String content = readFileContent(filePath);

        if (documentType == DocumentType.AUTO) {
            documentType = detectDocumentType(filePath);
        }

        switch (documentType) {
            case MARKDOWN:
                return parseMarkdown(content);
            case TEXT:
                return parseText(content);
            default:
                throw new UnsupportedOperationException("暂不支持此文档类型：" + documentType);
        }
    }

    /**
     * 解析 Markdown 文档
     *
     * @param content Markdown 内容
     * @return 解析结果
     */
    private static ParseResult parseMarkdown(String content) {
        ParseResult result = new ParseResult();

        // 提取功能名称
        result.setFunctionName(extractFunctionName(content));

        // 提取表名
        result.setTableName(inferTableName(result.getFunctionName()));

        // 推断类名
        result.setClassName(inferClassName(result.getTableName()));

        // 推断业务名
        result.setBusinessName(inferBusinessName(result.getTableName()));

        // 推断模块名
        result.setModuleName(inferModuleName(result.getBusinessName()));

        // 推断权限前缀
        result.setPermissionPrefix(inferPermissionPrefix(result.getModuleName(), result.getBusinessName()));

        // 提取字段信息
        List<FieldInfo> fields = extractFieldsFromMarkdown(content);
        result.setFields(fields);

        // 推断功能类型
        result.setFunctionType(inferFunctionType(content));

        // 提取操作类型
        result.setOperations(extractOperations(content));

        return result;
    }

    /**
     * 解析文本文档
     *
     * @param content 文本内容
     * @return 解析结果
     */
    private static ParseResult parseText(String content) {
        // 文本文档的解析逻辑与 Markdown 类似
        return parseMarkdown(content);
    }

    /**
     * 提取功能名称
     *
     * @param content 内容
     * @return 功能名称
     */
    private static String extractFunctionName(String content) {
        Pattern pattern = Pattern.compile("(?i)(功能名称|功能|模块)[:：\\s]*([^\n]+)");
        Matcher matcher = pattern.matcher(content);
        if (matcher.find()) {
            return matcher.group(2).trim();
        }

        // 如果没有找到功能名称，尝试从标题中提取
        pattern = Pattern.compile("^#+\\s*(.+)$", Pattern.MULTILINE);
        matcher = pattern.matcher(content);
        if (matcher.find()) {
            return matcher.group(1).trim();
        }

        return "未命名功能";
    }

    /**
     * 推断表名
     *
     * @param functionName 功能名称
     * @return 表名
     */
    private static String inferTableName(String functionName) {
        // 简单的推断逻辑：功能名称 -> 驼峰转下划线 -> 加 sys_ 前缀
        String tableName = camelToSnake(functionName);
        if (!tableName.startsWith("sys_")) {
            tableName = "sys_" + tableName;
        }
        return tableName;
    }

    /**
     * 推断类名
     *
     * @param tableName 表名
     * @return 类名
     */
    private static String inferClassName(String tableName) {
        // 移除 sys_ 前缀
        String className = tableName.replaceFirst("^sys_", "");
        // 下划线转驼峰，首字母大写
        return snakeToPascal(className);
    }

    /**
     * 推断业务名
     *
     * @param tableName 表名
     * @return 业务名
     */
    private static String inferBusinessName(String tableName) {
        // 移除 sys_ 前缀，保留原始格式
        return tableName.replaceFirst("^sys_", "");
    }

    /**
     * 推断模块名
     *
     * @param businessName 业务名
     * @return 模块名
     */
    private static String inferModuleName(String businessName) {
        // 简单的推断逻辑：使用业务名作为模块名
        // 可以根据实际项目结构进行更复杂的推断
        return "system";
    }

    /**
     * 推断权限前缀
     *
     * @param moduleName 模块名
     * @param businessName 业务名
     * @return 权限前缀
     */
    private static String inferPermissionPrefix(String moduleName, String businessName) {
        return moduleName + ":" + businessName;
    }

    /**
     * 从 Markdown 提取字段信息
     *
     * @param content Markdown 内容
     * @return 字段信息列表
     */
    private static List<FieldInfo> extractFieldsFromMarkdown(String content) {
        List<FieldInfo> fields = new ArrayList<>();

        // 匹配表格形式的字段定义
        Pattern tablePattern = Pattern.compile(
            "\\|\\s*([^|]+)\\s*\\|\\s*([^|]+)\\s*\\|\\s*([^|]+)\\s*\\|\\s*([^|]*)\\s*\\|"
        );
        Matcher tableMatcher = tablePattern.matcher(content);

        while (tableMatcher.find()) {
            String fieldName = tableMatcher.group(1).trim();
            String fieldType = tableMatcher.group(2).trim();
            String comment = tableMatcher.group(3).trim();
            String extra = tableMatcher.group(4).trim();

            FieldInfo field = new FieldInfo();
            field.setColumnName(camelToSnake(fieldName));
            field.setJavaField(fieldName);
            field.setJavaType(inferJavaType(fieldType));
            field.setComment(comment);
            field.setRequired(extra.contains("必填") || extra.contains("required"));
            field.setLength(extractLength(extra));

            // 自动推断显示类型
            field.setDisplayType(inferDisplayType(fieldName, fieldType, extra));

            // 自动推断查询类型
            field.setQueryType(inferQueryType(fieldName, extra));

            // 提取字典类型
            field.setDictType(extractDictType(extra));

            fields.add(field);
        }

        // 匹配列表形式的字段定义
        if (fields.isEmpty()) {
            Pattern listPattern = Pattern.compile(
                "-\\s*([^：:]+)[：:]\\s*([^\\n]+)"
            );
            Matcher listMatcher = listPattern.matcher(content);

            while (listMatcher.find()) {
                String fieldName = listMatcher.group(1).trim();
                String comment = listMatcher.group(2).trim();

                FieldInfo field = new FieldInfo();
                field.setColumnName(camelToSnake(fieldName));
                field.setJavaField(fieldName);
                field.setJavaType("String"); // 默认类型
                field.setComment(comment);
                field.setRequired(false);
                field.setDisplayType(inferDisplayType(fieldName, "String", ""));
                field.setQueryType("eq");

                fields.add(field);
            }
        }

        return fields;
    }

    /**
     * 推断 Java 类型
     *
     * @param fieldType 字段类型字符串
     * @return Java 类型
     */
    private static String inferJavaType(String fieldType) {
        if (fieldType == null) {
            return "String";
        }

        fieldType = fieldType.toLowerCase();

        if (fieldType.contains("int") || fieldType.contains("整数")) {
            return "Integer";
        } else if (fieldType.contains("long") || fieldType.contains("长整")) {
            return "Long";
        } else if (fieldType.contains("double") || fieldType.contains("浮点")) {
            return "Double";
        } else if (fieldType.contains("date") || fieldType.contains("时间")) {
            return "Date";
        } else if (fieldType.contains("boolean") || fieldType.contains("布尔")) {
            return "Boolean";
        } else {
            return "String";
        }
    }

    /**
     * 推断显示类型
     *
     * @param fieldName 字段名
     * @param fieldType 字段类型
     * @param extra 额外信息
     * @return 显示类型
     */
    private static String inferDisplayType(String fieldName, String fieldType, String extra) {
        if (extra != null) {
            if (extra.contains("下拉") || extra.contains("select")) {
                return "select";
            } else if (extra.contains("单选") || extra.contains("radio")) {
                return "radio";
            } else if (extra.contains("多选") || extra.contains("checkbox")) {
                return "checkbox";
            } else if (extra.contains("日期") || extra.contains("date")) {
                return "date";
            } else if (extra.contains("时间") || extra.contains("datetime")) {
                return "datetime";
            } else if (extra.contains("文本域") || extra.contains("textarea")) {
                return "textarea";
            } else if (extra.contains("富文本") || extra.contains("editor")) {
                return "editor";
            } else if (extra.contains("文件上传") || extra.contains("file")) {
                return "fileUpload";
            } else if (extra.contains("图片上传") || extra.contains("image")) {
                return "imageUpload";
            }
        }

        // 根据字段名推断
        if (fieldName.toLowerCase().contains("email")) {
            return "email";
        } else if (fieldName.toLowerCase().contains("phone") || fieldName.toLowerCase().contains("mobile")) {
            return "tel";
        } else if (fieldName.toLowerCase().contains("password")) {
            return "password";
        } else if (fieldName.toLowerCase().contains("url")) {
            return "url";
        }

        // 默认返回输入框
        return "input";
    }

    /**
     * 推断查询类型
     *
     * @param fieldName 字段名
     * @param extra 额外信息
     * @return 查询类型
     */
    private static String inferQueryType(String fieldName, String extra) {
        if (extra != null) {
            if (extra.contains("模糊") || extra.contains("like")) {
                return "like";
            } else if (extra.contains("范围") || extra.contains("between")) {
                return "between";
            } else if (extra.contains("包含") || extra.contains("in")) {
                return "in";
            }
        }

        // 根据字段名推断
        if (fieldName.toLowerCase().contains("name") || fieldName.toLowerCase().contains("title")) {
            return "like";
        } else if (fieldName.toLowerCase().contains("id")) {
            return "eq";
        }

        return "eq";
    }

    /**
     * 提取字段长度
     *
     * @param extra 额外信息
     * @return 字段长度
     */
    private static int extractLength(String extra) {
        if (extra == null) {
            return 0;
        }

        Pattern pattern = Pattern.compile("(\\d+)[\\s]*[字长度]*");
        Matcher matcher = pattern.matcher(extra);
        if (matcher.find()) {
            try {
                return Integer.parseInt(matcher.group(1));
            } catch (NumberFormatException e) {
                return 0;
            }
        }

        return 0;
    }

    /**
     * 提取字典类型
     *
     * @param extra 额外信息
     * @return 字典类型
     */
    private static String extractDictType(String extra) {
        if (extra == null) {
            return null;
        }

        Pattern pattern = Pattern.compile("字典[:：]\\s*([\\w_]+)");
        Matcher matcher = pattern.matcher(extra);
        if (matcher.find()) {
            return matcher.group(1);
        }

        return null;
    }

    /**
     * 推断功能类型
     *
     * @param content 内容
     * @return 功能类型（crud/tree/sub）
     */
    private static String inferFunctionType(String content) {
        String lowerContent = content.toLowerCase();

        if (lowerContent.contains("树形") || lowerContent.contains("tree") ||
            lowerContent.contains("父子") || lowerContent.contains("层级")) {
            return "tree";
        } else if (lowerContent.contains("主子") || lowerContent.contains("明细") ||
                   lowerContent.contains("sub")) {
            return "sub";
        } else {
            return "crud";
        }
    }

    /**
     * 提取操作类型
     *
     * @param content 内容
     * @return 操作类型列表
     */
    private static List<String> extractOperations(String content) {
        List<String> operations = new ArrayList<>();
        String lowerContent = content.toLowerCase();

        if (lowerContent.contains("新增") || lowerContent.contains("create") || lowerContent.contains("insert")) {
            operations.add("create");
        }
        if (lowerContent.contains("查询") || lowerContent.contains("read") || lowerContent.contains("select")) {
            operations.add("read");
        }
        if (lowerContent.contains("修改") || lowerContent.contains("update") || lowerContent.contains("edit")) {
            operations.add("update");
        }
        if (lowerContent.contains("删除") || lowerContent.contains("delete") || lowerContent.contains("remove")) {
            operations.add("delete");
        }

        // 默认包含 CRUD
        if (operations.isEmpty()) {
            operations.add("create");
            operations.add("read");
            operations.add("update");
            operations.add("delete");
        }

        return operations;
    }

    /**
     * 驼峰转下划线
     *
     * @param camel 驼峰字符串
     * @return 下划线字符串
     */
    private static String camelToSnake(String camel) {
        return camel.replaceAll("([a-z])([A-Z])", "$1_$2").toLowerCase();
    }

    /**
     * 下划线转帕斯卡（首字母大写的驼峰）
     *
     * @param snake 下划线字符串
     * @return 帕斯卡字符串
     */
    private static String snakeToPascal(String snake) {
        StringBuilder result = new StringBuilder();
        boolean nextUpper = true;

        for (char c : snake.toCharArray()) {
            if (c == '_') {
                nextUpper = true;
            } else if (nextUpper) {
                result.append(Character.toUpperCase(c));
                nextUpper = false;
            } else {
                result.append(Character.toLowerCase(c));
            }
        }

        return result.toString();
    }

    /**
     * 检测文档类型
     *
     * @param filePath 文件路径
     * @return 文档类型
     */
    private static DocumentType detectDocumentType(String filePath) {
        String lowerPath = filePath.toLowerCase();

        if (lowerPath.endsWith(".md") || lowerPath.endsWith(".markdown")) {
            return DocumentType.MARKDOWN;
        } else if (lowerPath.endsWith(".txt")) {
            return DocumentType.TEXT;
        } else if (lowerPath.endsWith(".doc") || lowerPath.endsWith(".docx")) {
            return DocumentType.WORD;
        } else if (lowerPath.endsWith(".xls") || lowerPath.endsWith(".xlsx")) {
            return DocumentType.EXCEL;
        } else if (lowerPath.endsWith(".pdf")) {
            return DocumentType.PDF;
        } else {
            return DocumentType.TEXT;
        }
    }

    /**
     * 读取文件内容
     *
     * @param filePath 文件路径
     * @return 文件内容
     * @throws IOException IO异常
     */
    private static String readFileContent(String filePath) throws IOException {
        StringBuilder content = new StringBuilder();
        try (BufferedReader reader = new BufferedReader(new FileReader(filePath))) {
            String line;
            while ((line = reader.readLine()) != null) {
                content.append(line).append("\n");
            }
        }
        return content.toString();
    }
}
