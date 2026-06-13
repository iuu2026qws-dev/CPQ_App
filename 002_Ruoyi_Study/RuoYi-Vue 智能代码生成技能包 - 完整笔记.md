# RuoYi-Vue 智能代码生成技能包 - 完整笔记

好的，根据您提供的文档内容，我已将其整理为一篇结构清晰、内容完整的笔记。笔记中保留了所有核心信息，并在必要位置补充了代码块标记（如`代码块`字样），确保您后续可以方便地填充实际代码。

***

# RuoYi-Vue 智能代码生成技能包 - 完整笔记

## 一、概述

* **技能名称**：RuoYi-Vue 智能代码生成技能包
* **核心能力**：一句话描述需求，AI自动完成从需求建模到自检报告的全流程代码生成
* **生成路径**：需求建模 → SQL三件套 → 后端五层代码 → 前端Vue3页面 → 自检报告
* **支持模板**：CRUD / Tree / Sub 三种模板
* **适配版本**：ruoyi-vue3 (Vue3 + Element Plus) 主线版本
* **版本信息**：v5.0.0，作者 HRuinger，发布于 2026/4/14

***

## 二、安装与配置

### 2.1 安装方式

1. 下载技能包文件

包括如下的技能：

aesthetic:专注于提升界⾯或内容的视觉美学，提供设计感和审美层⾯的优化建议。

analyzing-projects:⽤于从宏观⻆度对现有开源项⽬或商业项⽬进⾏架构和业务逻辑的全⾯剖

析。

beautiful-prose:致⼒于润⾊⽂字，撰写优美、流畅且富有感染⼒的散⽂或⾼质量⽂案。

blog-post-writer:专⻔⽤于构思、组织并撰写结构清晰、吸引读者的博客⽂章。

canvas-design:聚焦于前端Canvas技术，辅助进⾏图形绘制、动画设计及复杂交互实现。

detailed-function-analyzer:深⼊代码底层，对特定函数或⽅法进⾏极其详细的逻辑拆解与性

能分析。

docs-write:辅助开发者快速编写清晰、易读且符合规范的⽇常代码注释或轻量级⽂档。

documentation:⽤于⽣成和维护系统化、标准化的项⽬官⽅⽂档或详细操作⼿册。

frontend-design:专注于前端⻚⾯的整体布局、视觉元素搭配及交互体验设计。

product-analyzer:从产品经理视⻆出发，深度分析产品需求、⽤⼾痛点、核⼼功能及市场定

位。

project-analyzer:综合性项⽬分析助⼿，⽤于评估项⽬的整体技术栈、可⾏性及⼯程结构。

project-planner:辅助进⾏项⽬管理，包括阶段划分、任务排期、⽢特图规划及进度控制。

ruoyi-developer-gen:针对若依（RuoYi）⽣态的开发者辅助⼯具，⽤于⽣成符合若依规范的定

制化业务代码。

ruoyi-fast-gen:专⻔⽤于若依单体版（RuoYi-fast）的代码⽣成器模块，⼀键告别基础CRUD。

ruoyi-vue-gen:专⻔⽤于若依前后端分离版（RuoYi-Vue）的代码⽣成器模块。

skill-creator:属于“元技能”，⽤于帮助⽤⼾结构化地创建、编写和调试新的AI提⽰词技能。

statistical-analysis:专注于业务数据的处理、逻辑推导、统计学分析及可视化报表建议。

theme-factory:辅助进⾏前端主题的批量⽣产、配⾊⽅案管理及多套⽪肤的定制化⽣成。

ui-ux-pro-max:提供专家级别的⽤⼾界⾯（UI）与⽤⼾体验（UX）深度诊断与⾼阶设计指导。

2. 按说明修改顶部项目配置
3. 将文件放入 `/skills/ruoyi-vue-codegen/` 目录
4. 提交Git，全团队生效

### 2.2 首次使用：修改项目配置（必须）

打开文件，将以下配置替换为实际项目信息：

```yaml
代码块# ====== 项⽬基础配置（修改这⾥）======PROJECT_CONFIG:
# 项⽬根路径（后端 Java 项⽬的根⽬录）
projectPath: "/path/to/your/ruoyi-project"
# 前端项⽬路径
frontendPath: "/path/to/your/ruoyi-ui"
# Java 基础包路径
basePackage: "com.ruoyi"
# 若依版本（⽤于版本差异处理）
# 选项：ruoyi-vue3 / ruoyi-vue2 / ruoyi-fast / ruoyi-cloud / ruoyi-plus 
ruoyiVersion: "ruoyi-vue3"123456789101112131415
# 数据库配置（⽤于 AI 辅助⽣成连接⽰例，不会⾃动执⾏）
database:
  url: "jdbc:mysql://localhost:3306/ry-vue"
  username: "root"
# 代码作者author: "HRuinger."
# ====== 配置结束 ======
```

> 未修改会导致代码包路径、模块名全部错误。

### 2.3 集成到IDE

**CodeBuddy（IDEA插件）：** 在 `.cursor/settings.json` 或 `.windsurferules` 中添加技能引用。

**Trae CN（IDEA插件）：** 将文件复制到 `.trae/rules/ruoyi-vue-codegen.md`，重启IDE。

***

## 三、触发方式

以下任意一种描述均可触发：

* 帮我生成\[业务名称]的代码
* 创建一个\[业务名称]的CRUD
* 我需要一个\[业务名称]管理模块
* 生成\[业务名称]的表和代码
* 用若依的代码生成器创建一个\[业务名称]

***

## 四、执行流程

AI必须按以下步骤顺序执行，每个阶段结束等待用户确认后再继续：

```
Step 1 需求分析 → 输出分析报告和字段清单
Step 2 SQL生成 → 输出建表DDL + 字典SQL + 菜单SQL
Step 3 后端代码生成 → 输出Domain + Mapper + Service + Controller
Step 4 前端代码生成 → 输出API文件 + Vue3页面(index.vue)
Step 5 自检报告 → 输出检查结果
```

> 如果用户提供了已有的DDL，跳过Step 1，从Step 2开始。

***

## 五、Step 1：需求分析

### 5.1 分析报告格式

输出包含：业务描述、模板选择（CRUD/Tree/Sub）、字段清单、关联关系。

### 5.2 字段类型推断规则

AI从文字描述自动推断数据类型，无需用户指定：

| **字段名关键词**                     | **推断类型**      | **示例**                  |
| ------------------------------ | ------------- | ----------------------- |
| 含"时间/日期/date/time"             | DATETIME      | create\_time, pay\_date |
| 含"金额/价格/price/amount/fee"      | DECIMAL(10,2) | order\_amount           |
| 含"数量/count/num/qty"            | INT(11)       | quantity                |
| 含"状态/类型/type/status"           | CHAR(1)       | order\_status           |
| 以"\_id"结尾(外键)                  | BIGINT(20)    | dept\_id                |
| 含"内容/描述/备注/remark"             | VARCHAR(500)  | remark                  |
| 含"图片/图像/image/url/path/avatar" | VARCHAR(255)  | avatar\_url             |
| 含"是否/开关/is/has"                | CHAR(1)       | is\_enable              |
| 其他文本类                          | VARCHAR(适当长度) | name, code              |

***

## 六、Step 2：SQL 三件套

### 6.1 标准建表DDL

```sql
-- 标准建表模板（代码块）
CREATE TABLE `{table_name}` (
  `id` BIGINT(20) NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `create_by` VARCHAR(64) DEFAULT '' COMMENT '创建者',
  `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_by` VARCHAR(64) DEFAULT '' COMMENT '更新者',
  `update_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `remark` VARCHAR(500) DEFAULT NULL COMMENT '备注',
  `del_flag` CHAR(1) DEFAULT '0' COMMENT '删除标志（0代表存在 2代表删除）',
  -- 业务字段在此插入
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COMMENT='{表注释}';
```

**字段约束规范：**

* `del_flag`：'0' = 正常，'2' = 删除
* 金额字段：`DECIMAL(10,2)`，禁用 FLOAT/DOUBLE
* 状态枚举：`CHAR(1)`或`VARCHAR`，禁用 TINYINT
* 字符集：`utf8mb4`，禁用 `utf8`

### 6.2 字典数据SQL

```sql
-- 字典类型插入
INSERT INTO `sys_dict_type` (...) VALUES (...);
-- 字典数据插入
INSERT INTO `sys_dict_data` (...) VALUES (...);
```

### 6.3 菜单权限SQL

```sql
-- 父菜单插入
-- 子菜单：列表、查询、新增、修改、删除、导出（共6个权限点）
INSERT INTO `sys_menu` (...) VALUES (...);
```

> **执行说明**：AI生成的SQL必须由人工Review后手动执行，建议保存为 `sql/{YYYYMMDD}_{业务名}_init.sql` 纳入Git管理。

***

## 七、Step 3：后端代码生成

### 7.1 文件结构

```
src/main/java/com/ruoyi/{moduleName}/
├── domain/{BusinessName}.java
├── mapper/{BusinessName}Mapper.java
├── service/I{BusinessName}Service.java
├── service/impl/{BusinessName}ServiceImpl.java
└── controller/{BusinessName}Controller.java

src/main/resources/mapper/{moduleName}/
└── {BusinessName}Mapper.xml
```

### 7.2 Domain 实体类

* 继承 `BaseEntity`（Tree模板继承 `TreeEntity`）
* 使用 `@Accessors(chain=true)` 支持链式赋值
* 日期字段同时加 `@JsonFormat + @Excel(dateFormat)`
* 字典字段用 `@Excel(readConverterExp=...)`
* 金额字段用 `BigDecimal`
* 敏感字段用 `@JsonIgnore`

### 7.3 Mapper XML

* 禁止 `SELECT *`，使用 `<sql>` 抽取复用
* 查询条件首行必须为 `t.del_flag = '0'`
* 列表查询末尾必须有 `${params.dataScope}`
* 删除操作用 `UPDATE del_flag = '2'`
* 参数绑定全用 `#{}`

### 7.4 ServiceImpl

* 所有public方法首行打印入参日志（`@Slf4j + JSONUtil`）
* 增删改用 `@Transactional + @CacheEvict`
* 查询用 `@DataScope + @Cacheable`
* 业务异常用 `ServiceException`
* `@Cacheable` 需要Redis，未配置时去掉所有`@Cache*`注解

### 7.5 Controller

* 每个接口必须有 `@PreAuthorize`
* 增删改导出加 `@Log`
* `@RequestBody` 参数必须加 `@Validated`
* `startPage()` 紧贴查询调用上方
* 禁止 try-catch（由全局异常处理器统一处理）

***

## 八、Step 4：前端代码生成

### 8.1 文件路径

```
src/api/{moduleName}/{businessName}.js
src/views/{moduleName}/{businessName}/index.vue
```

### 8.2 API 文件

包含：list、get、add、update、del、export 六个接口。

### 8.3 页面文件（Vue3 + Element Plus）

遵循若依官方前端规范，包含：搜索表单、操作按钮栏、表格展示、分页组件、新增/修改对话框。

**前端生成关键规则：**

* `useDict` 必须在script setup顶层调用
* 字典下拉绑 `:value="dict.value"`
* 列表字典列用 `<dict-tag>` 组件
* 搜索传字典code值
* 按钮权限用 `v-hasPermi`
* `resetQuery` 中清空 `dateRange`

***

## 九、Step 5：自检报告

生成完毕后，AI必须自动执行检查并输出报告，覆盖以下方面：

1. **SQL检查**：字符集、del\_flag默认值、金额字段类型、基础字段完整性
2. **后端代码检查**：Domain继承、日期注解、Mapper规范、Service注解、Controller权限
3. **前端代码检查**：useDict位置、字典绑定、dict-tag使用、v-hasPermi、API路径一致性
4. **菜单权限检查**：权限字符串一致性、六个权限点完整性
5. **最终确认**：SQL已保存、代码已生成、占位符已替换

***

## 十、模板变体

### 10.1 Tree 树表变体

触发关键词：树形、层级、分类

**变更点：**

* Domain继承 `TreeEntity`，追加 `parentId`、`ancestors`、`orderNum` 字段
* Mapper追加递归查询和子节点查询
* Service追加构建树形结构方法
* Controller追加 `/treeList` 接口
* 前端使用 `el-tree`，左侧树+右侧列表布局

### 10.2 Sub 主子表变体

触发关键词：明细、子表、一对多

**变更点：**

* SQL包含主表和子表两张表
* 后端分为主表和子表两套代码
* 主表Domain包含子表List字段
* 前端主表页面内嵌子表 `el-table`，支持动态增删行

***

## 十一、AI操作禁区

以下文件AI禁止主动修改，只能解释原理和指导使用：

| **文件**                      | **原因**            |
| --------------------------- | ----------------- |
| SecurityConfig.java         | 过滤器链改错导致接口安全失效    |
| DataScopeAspect.java        | 全局数据权限静默失效        |
| DynamicDataSource.java      | 事务边界复杂，写错库        |
| GlobalExceptionHandler.java | 前端依赖返回格式，改结构全局崩溃  |
| TokenService.java           | Token生命周期错误导致安全漏洞 |
| sys\_config 系统配置参数          | 框架强依赖，改错初始化失败     |

***

## 十二、常见问题快速排查表

| **问题现象**             | **根因**                                 | **定位方法**                   | **修复措施**       |
| -------------------- | -------------------------------------- | -------------------------- | -------------- |
| 列表接口403              | 权限字符串不一致                               | 查 sys\_menu 表 perms 字段对比注解 | 从菜单SQL复制       |
| 分页失效/全表查询            | startPage 位置不对                         | 检查Controller中 startPage 位置 | 挪到查询调用上一行      |
| 已删数据出现在列表            | Mapper漏了 del\_flag='0'                 | 搜索Mapper XML的 \<where>     | 补上过滤条件         |
| Excel时间列显示数字         | 缺少 @Excel(dateFormat)                  | 检查实体类日期注解                  | 补充注解           |
| 启动报ConnectionRefused | 未配Redis但用了@Cacheable                   | 搜索 @Cache\* 注解             | 去掉注解或启动Redis   |
| 搜索字典条件无结果            | 绑了dict.label而非dict.value               | F12看请求参数                   | 改为绑 dict.value |
| dict-tag显示空白         | 绑错了字典变量名                               | 检查:options绑定               | 对齐变量名          |
| @DataScope不生效        | 三个前提缺失：未继承BaseEntity/XML无占位符/非public方法 | 逐一检查                       | 补全缺失前提         |

***

## 十三、验证加载是否成功

在AI对话框输入：

```
1. 请告诉我当前加载的若依技能包，列出：
2. 若依版本
3. 删除操作的正确写法（给代码示例）
4. 什么情况下 @DataScope 会静默失效
```

如果AI能准确回答 `del_flag = '2'` 和三个前提条件（未继承BaseEntity/XML无占位符/非public方法），说明技能包加载成功。

***

> **总结**：本技能包为RuoYi-Vue开发者提供了一套完整的、规范化的AI代码生成方案，涵盖从需求分析到自检报告的全流程，支持CRUD/Tree/Sub三种模板，并内置了大量避坑指南和最佳实践，适合团队统一代码风格、提升交付效率。

