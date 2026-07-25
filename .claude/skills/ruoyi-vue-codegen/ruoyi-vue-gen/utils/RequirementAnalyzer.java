package com.hruingerai.utils;

import java.util.*;

/**
 * 需求分析器
 *
 * 用于分析用户需求并设计对应的数据库表结构
 *
 * @author HRuinger.
 * @date 2026-03-29
 */
public class RequirementAnalyzer
{
    /**
     * 分析需求并生成表设计
     *
     * @param requirement 需求描述
     * @param projectName 项目名称
     * @return 表设计信息
     */
    public static TableDesign analyze(String requirement, String projectName)
    {
        System.out.println("开始分析需求...");
        System.out.println("需求描述：" + requirement);

        TableDesign design = new TableDesign();

        // 解析需求中的关键信息
        design.setTableName(extractTableName(requirement));
        design.setTableComment(extractTableComment(requirement));
        design.setModuleName(extractModuleName(requirement));
        design.setBusinessName(extractBusinessName(requirement));
        design.setFunctionName(extractFunctionName(requirement));

        // 生成字段设计
        List<FieldDesign> fields = generateFields(requirement);
        design.setFields(fields);

        // 生成菜单设计
        MenuDesign menu = generateMenu(requirement, design);
        design.setMenu(menu);

        // 生成字典设计
        List<DictDesign> dicts = generateDicts(requirement, fields);
        design.setDicts(dicts);

        System.out.println("需求分析完成！");
        System.out.println("表名：" + design.getTableName());
        System.out.println("表注释：" + design.getTableComment());
        System.out.println("字段数量：" + fields.size());
        System.out.println("菜单：" + menu.getMenuName());
        System.out.println("字典数量：" + dicts.size());

        return design;
    }

    /**
     * 提取表名
     *
     * @param requirement 需求描述
     * @return 表名
     */
    private static String extractTableName(String requirement)
    {
        // 从需求中提取关键词作为表名
        String[] keywords = requirement.split("[，,、；;\\s]+");
        for (String keyword : keywords)
        {
            if (keyword.length() >= 2 && keyword.matches(".*[管理信息用户订单商品].*"))
            {
                return "sys_" + toUnderScore(keyword);
            }
        }
        return "sys_demo";
    }

    /**
     * 提取表注释
     *
     * @param requirement 需求描述
     * @return 表注释
     */
    private static String extractTableComment(String requirement)
    {
        return requirement.substring(0, Math.min(50, requirement.length()));
    }

    /**
     * 提取模块名
     *
     * @param requirement 需求描述
     * @return 模块名
     */
    private static String extractModuleName(String requirement)
    {
        return "system";
    }

    /**
     * 提取业务名
     *
     * @param requirement 需求描述
     * @return 业务名
     */
    private static String extractBusinessName(String requirement)
    {
        String[] keywords = requirement.split("[，,、；;\\s]+");
        for (String keyword : keywords)
        {
            if (keyword.length() >= 2 && !keyword.matches(".*[的的是一个].*"))
            {
                return toCamelCase(keyword);
            }
        }
        return "demo";
    }

    /**
     * 提取功能名
     *
     * @param requirement 需求描述
     * @return 功能名
     */
    private static String extractFunctionName(String requirement)
    {
        String[] keywords = requirement.split("[，,、；;\\s]+");
        for (String keyword : keywords)
        {
            if (keyword.length() >= 2 && keyword.matches(".*[管理].*"))
            {
                return keyword;
            }
        }
        return "演示管理";
    }

    /**
     * 生成字段设计
     *
     * @param requirement 需求描述
     * @return 字段设计列表
     */
    private static List<FieldDesign> generateFields(String requirement)
    {
        List<FieldDesign> fields = new ArrayList<>();

        // 添加主键
        fields.add(new FieldDesign(
            extractIdField(requirement),
            "BIGINT",
            "20",
            "NOT NULL AUTO_INCREMENT",
            "主键ID",
            true,
            false
        ));

        // 根据需求生成业务字段
        if (requirement.contains("用户"))
        {
            fields.add(new FieldDesign("user_name", "VARCHAR", "30", "NOT NULL", "用户账号", false, false));
            fields.add(new FieldDesign("nick_name", "VARCHAR", "30", "NOT NULL", "用户昵称", false, false));
            fields.add(new FieldDesign("email", "VARCHAR", "50", "DEFAULT ''", "用户邮箱", false, false));
            fields.add(new FieldDesign("phonenumber", "VARCHAR", "11", "DEFAULT ''", "手机号码", false, false));
            fields.add(new FieldDesign("sex", "CHAR", "1", "DEFAULT '0'", "用户性别（0男 1女 2未知）", false, false));
            fields.add(new FieldDesign("avatar", "VARCHAR", "100", "DEFAULT ''", "头像地址", false, false));
            fields.add(new FieldDesign("password", "VARCHAR", "100", "DEFAULT ''", "密码", false, false));
            fields.add(new FieldDesign("status", "CHAR", "1", "DEFAULT '0'", "帐号状态（0正常 1停用）", false, false));
        }
        else if (requirement.contains("订单"))
        {
            fields.add(new FieldDesign("order_no", "VARCHAR", "50", "NOT NULL", "订单编号", false, true));
            fields.add(new FieldDesign("order_amount", "DECIMAL", "10,2", "DEFAULT 0.00", "订单金额", false, false));
            fields.add(new FieldDesign("order_status", "CHAR", "1", "DEFAULT '0'", "订单状态（0待付款 1已付款 2已发货 3已完成）", false, false));
            fields.add(new FieldDesign("pay_time", "DATETIME", "", "DEFAULT NULL", "支付时间", false, false));
            fields.add(new FieldDesign("ship_time", "DATETIME", "", "DEFAULT NULL", "发货时间", false, false));
        }
        else if (requirement.contains("商品"))
        {
            fields.add(new FieldDesign("product_name", "VARCHAR", "100", "NOT NULL", "商品名称", false, false));
            fields.add(new FieldDesign("product_price", "DECIMAL", "10,2", "DEFAULT 0.00", "商品价格", false, false));
            fields.add(new FieldDesign("product_stock", "INT", "11", "DEFAULT 0", "商品库存", false, false));
            fields.add(new FieldDesign("product_category", "VARCHAR", "50", "DEFAULT ''", "商品分类", false, false));
            fields.add(new FieldDesign("product_image", "VARCHAR", "255", "DEFAULT ''", "商品图片", false, false));
        }
        else
        {
            // 默认字段
            fields.add(new FieldDesign("name", "VARCHAR", "50", "NOT NULL", "名称", false, false));
            fields.add(new FieldDesign("code", "VARCHAR", "30", "DEFAULT ''", "编码", false, true));
            fields.add(new FieldDesign("status", "CHAR", "1", "DEFAULT '0'", "状态（0正常 1停用）", false, false));
        }

        // 添加标准字段
        fields.add(new FieldDesign("del_flag", "CHAR", "1", "DEFAULT '0'", "删除标志（0代表存在 2代表删除）", false, false));
        fields.add(new FieldDesign("create_by", "VARCHAR", "64", "DEFAULT ''", "创建者", false, false));
        fields.add(new FieldDesign("create_time", "DATETIME", "", "DEFAULT NULL", "创建时间", false, false));
        fields.add(new FieldDesign("update_by", "VARCHAR", "64", "DEFAULT ''", "更新者", false, false));
        fields.add(new FieldDesign("update_time", "DATETIME", "", "DEFAULT NULL", "更新时间", false, false));
        fields.add(new FieldDesign("remark", "VARCHAR", "500", "DEFAULT NULL", "备注", false, false));

        return fields;
    }

    /**
     * 提取ID字段名
     *
     * @param requirement 需求描述
     * @return ID字段名
     */
    private static String extractIdField(String requirement)
    {
        if (requirement.contains("用户")) return "user_id";
        if (requirement.contains("订单")) return "order_id";
        if (requirement.contains("商品")) return "product_id";
        return "id";
    }

    /**
     * 生成菜单设计
     *
     * @param requirement 需求描述
     * @param design 表设计
     * @return 菜单设计
     */
    private static MenuDesign generateMenu(String requirement, TableDesign design)
    {
        MenuDesign menu = new MenuDesign();
        menu.setMenuName(extractFunctionName(requirement));
        menu.setMenuType("C"); // 目录
        menu.setParentMenuId("0"); // 一级菜单
        menu.setOrderNum("1");
        menu.setMenuIcon("system");
        menu.setMenuPath("/" + design.getModuleName() + "/" + design.getBusinessName());
        menu.setComponent(design.getModuleName() + "/" + design.getBusinessName() + "/index");
        menu.setVisible("0");
        menu.setStatus("0");

        // 生成子菜单（按钮权限）
        List<MenuButton> buttons = new ArrayList<>();
        buttons.add(new MenuButton("查询", design.getModuleName() + ":" + design.getBusinessName() + ":query", "1", "1"));
        buttons.add(new MenuButton("新增", design.getModuleName() + ":" + design.getBusinessName() + ":add", "1", "2"));
        buttons.add(new MenuButton("修改", design.getModuleName() + ":" + design.getBusinessName() + ":edit", "1", "3"));
        buttons.add(new MenuButton("删除", design.getModuleName() + ":" + design.getBusinessName() + ":remove", "1", "4"));
        buttons.add(new MenuButton("导出", design.getModuleName() + ":" + design.getBusinessName() + ":export", "1", "5"));
        menu.setButtons(buttons);

        return menu;
    }

    /**
     * 生成字典设计
     *
     * @param requirement 需求描述
     * @param fields 字段设计
     * @return 字典设计列表
     */
    private static List<DictDesign> generateDicts(String requirement, List<FieldDesign> fields)
    {
        List<DictDesign> dicts = new ArrayList<>();

        // 遍历字段，查找需要字典的字段
        for (FieldDesign field : fields)
        {
            if (field.getComment().contains("（") && field.getComment().contains("）"))
            {
                String dictComment = field.getComment();
                String dictValue = dictComment.substring(dictComment.indexOf("（") + 1, dictComment.indexOf("）"));

                DictDesign dict = new DictDesign();
                dict.setDictType(field.getColumnName() + "_type");
                dict.setDictName(field.getComment().replace("（" + dictValue + "）", ""));
                dict.setIsDefault("N");

                // 解析字典项
                List<DictItem> items = new ArrayList<>();
                String[] pairs = dictValue.split(" ");
                for (int i = 0; i < pairs.length; i++)
                {
                    String[] kv = pairs[i].split("（");
                    if (kv.length == 2)
                    {
                        String key = kv[0];
                        String value = kv[1].replace("）", "");
                        items.add(new DictItem(key, String.valueOf(i), "1", i + 1));
                    }
                }
                dict.setItems(items);

                dicts.add(dict);
            }
        }

        return dicts;
    }

    /**
     * 转换为下划线命名
     *
     * @param str 字符串
     * @return 下划线命名
     */
    private static String toUnderScore(String str)
    {
        StringBuilder result = new StringBuilder();
        for (int i = 0; i < str.length(); i++)
        {
            char c = str.charAt(i);
            if (Character.isUpperCase(c))
            {
                if (i > 0)
                {
                    result.append("_");
                }
                result.append(Character.toLowerCase(c));
            }
            else
            {
                result.append(c);
            }
        }
        return result.toString();
    }

    /**
     * 转换为驼峰命名
     *
     * @param str 字符串
     * @return 驼峰命名
     */
    private static String toCamelCase(String str)
    {
        StringBuilder result = new StringBuilder();
        boolean nextUpper = false;

        for (char c : str.toCharArray())
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
     * 表设计类
     */
    public static class TableDesign
    {
        private String tableName;
        private String tableComment;
        private String moduleName;
        private String businessName;
        private String functionName;
        private List<FieldDesign> fields;
        private MenuDesign menu;
        private List<DictDesign> dicts;

        // Getters and Setters
        public String getTableName() { return tableName; }
        public void setTableName(String tableName) { this.tableName = tableName; }
        public String getTableComment() { return tableComment; }
        public void setTableComment(String tableComment) { this.tableComment = tableComment; }
        public String getModuleName() { return moduleName; }
        public void setModuleName(String moduleName) { this.moduleName = moduleName; }
        public String getBusinessName() { return businessName; }
        public void setBusinessName(String businessName) { this.businessName = businessName; }
        public String getFunctionName() { return functionName; }
        public void setFunctionName(String functionName) { this.functionName = functionName; }
        public List<FieldDesign> getFields() { return fields; }
        public void setFields(List<FieldDesign> fields) { this.fields = fields; }
        public MenuDesign getMenu() { return menu; }
        public void setMenu(MenuDesign menu) { this.menu = menu; }
        public List<DictDesign> getDicts() { return dicts; }
        public void setDicts(List<DictDesign> dicts) { this.dicts = dicts; }
    }

    /**
     * 字段设计类
     */
    public static class FieldDesign
    {
        private String columnName;
        private String dataType;
        private String dataLength;
        private String columnDefault;
        private String comment;
        private boolean isPrimaryKey;
        private boolean isUnique;

        public FieldDesign(String columnName, String dataType, String dataLength, 
                          String columnDefault, String comment, boolean isPrimaryKey, boolean isUnique)
        {
            this.columnName = columnName;
            this.dataType = dataType;
            this.dataLength = dataLength;
            this.columnDefault = columnDefault;
            this.comment = comment;
            this.isPrimaryKey = isPrimaryKey;
            this.isUnique = isUnique;
        }

        // Getters
        public String getColumnName() { return columnName; }
        public String getDataType() { return dataType; }
        public String getDataLength() { return dataLength; }
        public String getColumnDefault() { return columnDefault; }
        public String getComment() { return comment; }
        public boolean isPrimaryKey() { return isPrimaryKey; }
        public boolean isUnique() { return isUnique; }
    }

    /**
     * 菜单设计类
     */
    public static class MenuDesign
    {
        private String menuName;
        private String menuType;
        private String parentMenuId;
        private String orderNum;
        private String menuIcon;
        private String menuPath;
        private String component;
        private String visible;
        private String status;
        private List<MenuButton> buttons;

        // Getters and Setters
        public String getMenuName() { return menuName; }
        public void setMenuName(String menuName) { this.menuName = menuName; }
        public String getMenuType() { return menuType; }
        public void setMenuType(String menuType) { this.menuType = menuType; }
        public String getParentMenuId() { return parentMenuId; }
        public void setParentMenuId(String parentMenuId) { this.parentMenuId = parentMenuId; }
        public String getOrderNum() { return orderNum; }
        public void setOrderNum(String orderNum) { this.orderNum = orderNum; }
        public String getMenuIcon() { return menuIcon; }
        public void setMenuIcon(String menuIcon) { this.menuIcon = menuIcon; }
        public String getMenuPath() { return menuPath; }
        public void setMenuPath(String menuPath) { this.menuPath = menuPath; }
        public String getComponent() { return component; }
        public void setComponent(String component) { this.component = component; }
        public String getVisible() { return visible; }
        public void setVisible(String visible) { this.visible = visible; }
        public String getStatus() { return status; }
        public void setStatus(String status) { this.status = status; }
        public List<MenuButton> getButtons() { return buttons; }
        public void setButtons(List<MenuButton> buttons) { this.buttons = buttons; }
    }

    /**
     * 菜单按钮类
     */
    public static class MenuButton
    {
        private String buttonName;
        private String perms;
        private String visible;
        private String orderNum;

        public MenuButton(String buttonName, String perms, String visible, String orderNum)
        {
            this.buttonName = buttonName;
            this.perms = perms;
            this.visible = visible;
            this.orderNum = orderNum;
        }

        // Getters
        public String getButtonName() { return buttonName; }
        public String getPerms() { return perms; }
        public String getVisible() { return visible; }
        public String getOrderNum() { return orderNum; }
    }

    /**
     * 字典设计类
     */
    public static class DictDesign
    {
        private String dictType;
        private String dictName;
        private String isDefault;
        private List<DictItem> items;

        // Getters and Setters
        public String getDictType() { return dictType; }
        public void setDictType(String dictType) { this.dictType = dictType; }
        public String getDictName() { return dictName; }
        public void setDictName(String dictName) { this.dictName = dictName; }
        public String getIsDefault() { return isDefault; }
        public void setIsDefault(String isDefault) { this.isDefault = isDefault; }
        public List<DictItem> getItems() { return items; }
        public void setItems(List<DictItem> items) { this.items = items; }
    }

    /**
     * 字典项类
     */
    public static class DictItem
    {
        private String dictLabel;
        private String dictValue;
        private String isDefault;
        private int dictSort;

        public DictItem(String dictLabel, String dictValue, String isDefault, int dictSort)
        {
            this.dictLabel = dictLabel;
            this.dictValue = dictValue;
            this.isDefault = isDefault;
            this.dictSort = dictSort;
        }

        // Getters
        public String getDictLabel() { return dictLabel; }
        public String getDictValue() { return dictValue; }
        public String getIsDefault() { return isDefault; }
        public int getDictSort() { return dictSort; }
    }
}
