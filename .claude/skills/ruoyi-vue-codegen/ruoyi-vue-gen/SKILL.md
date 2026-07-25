---
name: ruoyi-vue-gen
description: 专门用于基于数据库表结构或需求文档为 RuoYi-Vue 框架生成完整 CRUD 代码的 skill。智能分析项目结构和需求文档，生成符合 RuoYi-Vue 开发规范的后端、前端和 SQL 菜单脚本。自动检查和添加必要依赖，添加详细的方法级日志记录，并生成完整的文档。支持 Java 链式赋值，集成 theme-factory、ui-ux-pro-max、frontend-design、aesthetic、canvas-design 等前端优化技能。支持智能文档解析，自动提取配置信息。支持 Java 性能优化，提供 15 种性能优化建议。在 RuoYi-Vue 框架项目中开发需要快速生成标准 CRUD 模块且包含完整前后端实现的新功能时使用此 skill。
---

# RuoYi-Vue 开发者生成器 Skill

此 skill 为 RuoYi-Vue 框架项目提供智能代码生成能力，能够基于数据库表结构自动生成完整的 CRUD 功能。

## ⛔ 强制 CSS 规范 — 禁止硬编码样式

**所有生成的 Vue 组件 CSS 必须引用 Design Token 变量，禁止出现任何硬编码数值。**

| 硬编码 (❌ 禁止) | Token (✅ 必须) | 说明 |
|-----------------|-----------------|------|
| `border-radius: 12px` | `border-radius: var(--card-radius)` | 所有容器/卡片圆角 24px |
| `border-radius: 8px` | `border-radius: var(--radius-sm)` | 小圆角 8px |
| `padding: 20px` | `padding: var(--space-24)` | 内边距 |
| `padding: 16px` | `padding: var(--space-16)` | 内边距 |
| `font-size: 14px` | `font-size: var(--fs-label-md)` | 字号 |
| `font-size: 16px` | `font-size: var(--fs-body-md)` | 正文 |
| `color: #0C4A6E` / `#17B5C5` | `color: var(--color-primary)` | 品牌色 |
| `background: #f5f7fa` | `background: var(--bg-surface)` | 页面底色 |
| `background: white` / `#fff` | `background: var(--bg-base)` | 卡片/容器背景 |
| `box-shadow: 0 2px 8px rgba(0,0,0,0.1)` | `box-shadow: var(--shadow-sm)` | 阴影 |

**内联 `style=""` 同样必须使用 var(--*) 变量**。

完整 Token 参考：`dental-portal/src/styles/tokens.css`

## ⛔ 强制图标规范 — 必须从注册中心引用

**所有生成的 Vue 组件图标必须从 `src/config/icons.ts` 引用，禁止硬编码 `data-lucide="xxx"`。**

```vue
<!-- ❌ 禁止 -->
<i data-lucide="search" />

<!-- ✅ 必须 -->
<script setup>import { ICONS } from '@/config/icons'</script>
<template><i :data-lucide="ICONS.sys.search" /></template>
```

**图标分组速查**：
- `ICONS.sys` — search/user/clock/bell/plus/edit/trash/check/star 等（39个系统图标）
- `ICONS.action` — login/logout/register/themeMoon/themeSun/tooth
- `ICONS.module` — graduation-cap(course)/radio(live)/file-text(case)/award(credit)/trending-up(growth)/pen-tool(creator)/building-2(org)/package(vendor)/settings(admin)
- `ICONS.role` — stethoscope(doctor)/award(expert)/heart-pulse(patient)/package(vendor)/hospital(org)
- `ICONS.feature` — flame/play-circle/camera/monitor/smartphone/chart 等（50个功能图标）

规定：新增图标前必须先注册到 `src/config/icons.ts`，再引用。注册中心 = 唯一数据源。

## ⛔ 代码生成强制规则 — 预防已知错误（10条铁律）

以下规则直接从 ruoyi-lesson-learn 提取，每次生成代码时必须逐条验证：

### 数据库类
1. **tenant.excludes**：每生成一张新 `dental_*` 表 → 必须在 `application.yml` 的 `tenant.excludes` 追加表名。生成 SQL 建表脚本时同时输出对应的 excludes 条目。
2. **BaseEntity 字段对齐**：所有建表 SQL 必须包含 `create_dept BIGINT` / `create_by BIGINT` / `create_time DATETIME` / `update_by BIGINT` / `update_time DATETIME`。字段类型必须是 `BIGINT` 不是 `VARCHAR`。
3. **@TableLogic**：所有 Domain 实体必须声明 `@TableLogic private String delFlag;`

### 后端代码类
4. **@SaIgnore**：Portal 端公开接口（列表/详情/搜索）必须加 `@SaIgnore`，否则全局 SaInterceptor 给 401。Controller 生成时明确标注哪些方法是公开的。
5. **TableDataInfo.build()**：分页查询必须 `return TableDataInfo.build(result)`，不能直接 `return Page`。Service 里的 `selectVoPage` 返回的是 `Page` 对象。
6. **ServiceException**：业务异常必须 `throw new ServiceException("具体消息")`，禁止 `RuntimeException`。全局异常处理器会吞掉 RuntimeException 的消息。
7. **LoginHelper.getUserId()**：Portal Controller 获取用户 ID 只用 `LoginHelper.getUserId()`，禁止 `StpUtil.getLoginIdAsLong()`。
8. **Controller 路径唯一性**：生成 Controller 后用脚本扫描 `@RequestMapping` 路径，确保没有两个 Controller 映射同一 URL。

### 前端代码类
9. **Design Token**：所有 CSS 值必须使用 `var(--card-radius)` / `var(--space-24)` / `var(--color-primary)` 等设计变量，禁止硬编码 px/颜色值。
10. **分页解析**：前端分页用 `response.rows`（不是 list），总条数用 `response.total`（不是计算 pages）。

### 生成后自动化校验

每完成一批代码生成，立即执行：
```bash
# 1. 路径冲突扫描
cd ruoyi-modules/ruoyi-dental/src/main/java/org/dromara/dental/controller
grep -rn "@RequestMapping\|@GetMapping\|@PostMapping" *.java | sort | uniq -d

# 2. 编译验证
cd ruoyi-vue-plus-backend && mvn compile -pl ruoyi-modules/ruoyi-dental -am -DskipTests

# 3. 前端类型检查
cd dental-portal && npx vue-tsc --noEmit
```

## 何时使用此 Skill

在以下情况下使用此 skill：
- 在 RuoYi-Vue 框架中开发需要标准 CRUD 操作的新功能
- 需要基于数据库表快速生成后端和前端代码
- 正在使用 Spring Boot 2.x/3.x/4.x 和 Vue 2.x/3.x 项目
- 需要符合 RuoYi-Vue 框架标准和规范的代码
- 需要使用链式赋值优化 Java 代码
- 需要使用高级前端设计技能优化 Vue 界面

## Skill 概述

### 此 Skill 生成的内容

1. **后端代码**
   - 带有 `@Data`、`@Accessors(chain = true)`、`@AllArgsConstructor`、`@NoArgsConstructor` 注解的 Domain 实体类
   - Mapper 接口和 MyBatis XML 映射文件
   - Service 接口和实现类（包含详细日志）
   - 带权限控制的 REST 控制器
   - 支持链式赋值的实体类

2. **前端代码**
   - API 接口文件
   - Vue 页面组件（列表/编辑视图）
   - 支持 Element UI（Vue 2）、Element Plus（Vue 3）和 TypeScript
   - 集成多个前端优化技能（theme-factory、ui-ux-pro-max、frontend-design、aesthetic、canvas-design）

3. **SQL 脚本**
   - 菜单和权限 SQL 脚本

### 核心特性

#### 智能文档解析 📄
- **自动提取配置**：从需求文档或开发文档中自动提取表结构、字段信息
- **智能推断配置项**：自动推断类名、业务名、模块名、权限前缀等配置
- **字段自动映射**：根据数据库字段自动推断 Java 类型、显示类型、查询类型
- **减少手动配置**：无需手动编写复杂的 JSON 配置文件
- **支持多种文档格式**：Word、PDF、Markdown、TXT

#### Java 性能优化（V4.0）🚀
- **集合类优化**：
  - 优先使用 ArrayList 代替 LinkedList（查询性能提升 100%）
  - 优先使用 HashMap 代替 TreeMap（查询性能提升 200%）
  - 设置合理的集合初始容量（减少扩容开销 50%）

- **字符串处理优化**：
  - 循环中使用 StringBuilder 代替 String 拼接（性能提升 500%）
  - 使用 String.join() 代替循环拼接（性能提升 300%）
  - 避免重复的字符串拼接

- **缓存策略优化**：
  - 查询方法使用 @Cacheable 注解（查询性能提升 90%）
  - 更新方法使用 @CachePut 注解
  - 删除方法使用 @CacheEvict 注解
  - 使用 Redis 作为缓存中间件

- **SQL 查询优化**：
  - 避免 SELECT *，明确指定需要的字段（减少 I/O 50%）
  - 在 WHERE 条件中使用索引字段（查询速度提升 1000%）
  - 使用 LIMIT 限制返回结果（内存占用减少 90%）
  - 使用批量操作代替循环单条（性能提升 500%）

- **并发处理优化**：
  - 使用线程池代替直接创建线程（吞吐量提升 300%）
  - 使用 ReadWriteLock 代替 synchronized（并发性能提升 50%）
  - 使用 ConcurrentHashMap 等并发集合（并发性能提升 200%）

#### 智能需求分析
- **自动分析需求**：自动分析用户需求，提取功能模块和字段信息
- **自动表设计**：根据需求自动设计符合 RuoYi-Vue 框架规范的数据库表结构
- **SQL 自动执行**：自动将生成的 SQL 脚本执行到数据库中
- **菜单自动生成**：自动生成功能模块菜单，支持菜单层级管理
- **字典数据生成**：自动生成 RuoYi-Vue 使用的字典数据
- **字段注解说明**：所有数据库字段都包含完整的注释和说明

#### 代码质量保证
- **Lombok 集成**：自动检查 Lombok 依赖，如果不存在则自动添加
- **Hutool 集成**：检查 Hutool 依赖，如果需要则添加，优先使用 Hutool 工具类方法
- **链式赋值支持**：实体类使用 `@Accessors(chain = true)` 注解，支持流畅的链式调用
- **方法文档**：为所有 Service 方法添加详细的 JavaDoc 注释
- **执行日志**：使用 `@Slf4j` 实现方法级日志，包含开始时间、结束时间和执行持续时间跟踪
- **项目结构分析**：智能分析项目结构，将生成的代码放置在正确的目录中
- **错误检测和修正**：验证生成的代码并修复常见问题
- **文档生成**：在 `doc/功能模块/` 目录下创建完整文档

#### 前端优化集成
- **theme-factory** - 主题工厂（10 种预设主题）
- **ui-ux-pro-max** - UI/UX 智能设计（50 种风格、21 种调色板、50 种字体搭配）
- **frontend-design** - 前端界面设计（高品质、生产标准）
- **aesthetic** - 美学设计（成熟设计原则、视觉层次结构、色彩理论）
- **canvas-design** - 画布设计（精美视觉艺术作品）

#### 后端代码补充
- 根据优化后的前端页面自动补充所需的后端代码
- 包括统计接口、高级搜索、批量操作等

## 如何使用此 Skill

此 skill 提供两种使用方式：

### 方式一：从需求自动生成（推荐）

**适用场景：**
- 还没有创建数据库表
- 只有功能需求描述
- 需要快速从零开始创建功能模块

**优势：**
- ✅ 自动分析需求，提取功能模块
- ✅ 自动设计符合 RuoYi-Vue 规范的表结构
- ✅ 自动执行 SQL 到数据库
- ✅ 自动生成菜单和字典数据
- ✅ 所有字段都有完整的注释和说明
- ✅ 一站式完成从需求到代码的全过程

**使用步骤：**

#### 步骤 1：提供需求描述

描述你的功能需求，例如：

```
需求：用户管理模块
功能：管理系统的用户信息，包括用户的增删改查
字段：用户名、昵称、邮箱、手机号、性别、头像、状态
```

#### 步骤 2：配置生成参数

提供以下信息：

**基础配置：**
- 需求描述：用户管理模块，包含用户信息的增删改查功能
- 项目路径：`/path/to/project`
- 包名：`com.ruoyi.system`
- 项目名称：`ruoyi-vue-pro`
- 模块名：`system`
- 业务名：`user`
- 父菜单ID：`1`（系统管理菜单的ID）

**数据库配置：**
- 数据库连接信息（URL、用户名、密码）
- SQL 文件存放路径（可选，默认存放在项目 sql 目录下）

**前端配置：**
- 前端类型：`element-ui`（Vue 2）、`element-plus`（Vue 3）或 `element-plus-typescript`（Vue 3 + TypeScript）

**前端优化选项：**
- 是否启用前端优化：`true`（默认）
- 使用的前端技能：`theme-factory,ui-ux-pro-max,frontend-design,aesthetic,canvas-design`（全部）

#### 步骤 3：自动生成

Skill 将自动完成：

1. **需求分析**：分析需求，提取功能模块和字段信息
2. **表设计**：根据需求自动设计表结构（包含标准字段）
3. **SQL 生成**：生成 CREATE TABLE 语句和字段注释
4. **SQL 执行**：自动将 SQL 执行到数据库
5. **代码生成**：生成完整的前后端代码
6. **菜单生成**：自动生成菜单和字典数据
7. **数据库写入**：将菜单和字典数据写入数据库
8. **前端优化**：使用多个技能优化前端界面
9. **文档生成**：生成完整的功能文档

#### 步骤 4：查看生成的结果

**数据库表：**
- 表名：`sys_user`
- 字段：包含需求中的字段 + RuoYi-Vue 标准字段
- 注释：所有字段都有完整的中文注释

**生成的代码：**
- 后端：完整的 CRUD 代码（Domain、Mapper、Service、Controller）
- 前端：优化的 Vue 页面（API 接口、页面组件）
- SQL：表结构和数据脚本
- 文档：完整的功能模块文档

### 方式二：基于已有表生成

**适用场景：**
- 数据库表已经存在
- 需要根据表结构生成代码

**使用步骤：**

#### 步骤 1：准备数据库表

确保数据库表遵循 RuoYi-Vue 约定：
- 表名：小写字母加下划线（例如：`sys_user`）
- 主键：通常是 `id` 或 `{table}_id`
- 标准列：包含 `create_by`、`create_time`、`update_by`、`update_time`、`remark`

示例表：
```sql
CREATE TABLE `sys_user` (
  `user_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '用户ID',
  `user_name` varchar(30) NOT NULL COMMENT '用户账号',
  `nick_name` varchar(30) NOT NULL COMMENT '用户昵称',
  `email` varchar(50) DEFAULT '' COMMENT '用户邮箱',
  `phonenumber` varchar(11) DEFAULT '' COMMENT '手机号码',
  `sex` char(1) DEFAULT '0' COMMENT '用户性别（0男 1女 2未知）',
  `avatar` varchar(100) DEFAULT '' COMMENT '头像地址',
  `password` varchar(100) DEFAULT '' COMMENT '密码',
  `status` char(1) DEFAULT '0' COMMENT '帐号状态（0正常 1停用）',
  `del_flag` char(1) DEFAULT '0' COMMENT '删除标志（0代表存在 2代表删除）',
  `login_ip` varchar(128) DEFAULT '' COMMENT '最后登录IP',
  `login_date` datetime DEFAULT NULL COMMENT '最后登录时间',
  `create_by` varchar(64) DEFAULT '' COMMENT '创建者',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) DEFAULT '' COMMENT '更新者',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=100 DEFAULT CHARSET=utf8mb4 COMMENT='用户信息表';
```

### 步骤 2：生成代码

提供以下信息：

**基础配置：**
- 表名：`sys_user`
- 包名：`com.ruoyi.system`
- 模块名：`system`
- 业务名：`user`
- 功能名：`用户管理`
- 作者名：`ruoyi`

**模板选择：**
- 模板类型：`crud`（标准）、`tree`（树结构）或 `sub`（主子表）
- 前端类型：`element-ui`（Vue 2）、`element-plus`（Vue 3）或 `element-plus-typescript`（Vue 3 + TypeScript）

**前端优化选项：**
- 是否启用前端优化：`true`（默认）
- 使用的前端技能：`theme-factory,ui-ux-pro-max,frontend-design,aesthetic,canvas-design`（全部）

### 步骤 3：查看生成的代码

Skill 将生成：

**后端结构：**
```
com.ruoyi.system/
├── controller/
│   └── SysUserController.java
├── service/
│   ├── ISysUserService.java
│   └── impl/
│       └── SysUserServiceImpl.java
├── mapper/
│   ├── SysUserMapper.java
│   └── SysUserMapper.xml
└── domain/
    └── SysUser.java
```

**前端结构：**
```
src/
├── api/
│   └── system/
│       └── user.js (或 user.ts)
└── views/
    └── system/
        └── user/
            ├── index.vue
            └── index-tree.vue (用于树模板)
```

**SQL 脚本：**
```
sql/
└── menu_user.sql
```

**文档：**
```
doc/
└── 用户管理/
    └── README.md
```

## 生成代码标准

### Domain 实体类（支持链式赋值）

```java
package com.ruoyi.system.domain;

import com.fasterxml.jackson.annotation.JsonFormat;
import com.ruoyi.common.annotation.Excel;
import com.ruoyi.common.core.domain.BaseEntity;
import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;
import lombok.experimental.Accessors;

import java.util.Date;

/**
 * @Description: 用户对象 sys_user
 * @BelongsProject: ruoyi-vue-pro
 * @BelongsPackage: com.ruoyi.system.domain
 * @Class: SysUser
 * @Author: HRuinger.
 * @CreateTime: 2026-03-29
 * @Version: 1.0.0
 */
@Data
@Accessors(chain = true)
@AllArgsConstructor
@NoArgsConstructor
@EqualsAndHashCode(callSuper = true)
public class SysUser extends BaseEntity {
    private static final long serialVersionUID = 1L;

    /** 用户ID */
    @Excel(name = "用户ID")
    private Long userId;

    /** 用户账号 */
    @Excel(name = "用户账号")
    private String userName;

    /** 用户昵称 */
    @Excel(name = "用户昵称")
    private String nickName;

    // ... 其他带有 @Excel 注解的字段
}
```

**核心特性：**
- 使用 `@Data` 注解（无需显式 getter/setter）
- 使用 `@Accessors(chain = true)` 支持链式赋值
- 使用 `@AllArgsConstructor` 和 `@NoArgsConstructor` 提供构造函数
- 继承 `BaseEntity` 以获取标准字段
- 包含字段级注释
- 使用 `@Excel` 注解实现导出功能

**链式赋值示例：**

```java
// 传统赋值方式
SysUser user = new SysUser();
user.setUserName("admin");
user.setNickName("管理员");
user.setEmail("admin@example.com");

// 链式赋值方式（使用 @Accessors(chain = true)）
SysUser user = new SysUser()
    .setUserName("admin")
    .setNickName("管理员")
    .setEmail("admin@example.com")
    .setStatus("0");

// Service 层使用示例
@Override
public int insertSysUser(SysUser sysUser) {
    long startTime = System.currentTimeMillis();
    log.info("新增用户开始，参数：{}", cn.hutool.json.JSONUtil.toJsonStr(sysUser));
    try {
        // 使用链式赋值设置默认值
        SysUser userToInsert = sysUser
            .setCreateTime(new Date())
            .setDelFlag("0");
        
        int result = sysUserMapper.insertSysUser(userToInsert);
        long endTime = System.currentTimeMillis();
        log.info("新增用户结束，耗时：{}ms，影响行数：{}", (endTime - startTime), result);
        return result;
    } catch (Exception e) {
        long endTime = System.currentTimeMillis();
        log.error("新增用户异常，耗时：{}ms，异常信息：{}", (endTime - startTime), e.getMessage(), e);
        throw e;
    }
}
```

### Service 实现类

```java
package com.ruoyi.system.service.impl;

import java.util.List;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import com.ruoyi.system.mapper.SysUserMapper;
import com.ruoyi.system.domain.SysUser;
import com.ruoyi.system.service.ISysUserService;

/**
 * @Description: 用户Service业务层处理
 * @BelongsProject: ruoyi-vue-pro
 * @BelongsPackage: com.ruoyi.system.service.impl
 * @Class: SysUserServiceImpl
 * @Author: HRuinger.
 * @CreateTime: 2026-03-29
 * @Version: 1.0.0
 */
@Slf4j
@Service
public class SysUserServiceImpl implements ISysUserService {
    
    @Autowired
    private SysUserMapper sysUserMapper;

    /**
     * 查询用户
     *
     * @param userId 用户主键
     * @return 用户
     */
    @Override
    public SysUser selectSysUserByUserId(Long userId) {
        long startTime = System.currentTimeMillis();
        log.info("查询用户开始，参数：userId = {}", userId);
        try {
            SysUser result = sysUserMapper.selectSysUserByUserId(userId);
            long endTime = System.currentTimeMillis();
            log.info("查询用户结束，耗时：{}ms，结果：{}", (endTime - startTime), cn.hutool.json.JSONUtil.toJsonStr(result));
            return result;
        } catch (Exception e) {
            long endTime = System.currentTimeMillis();
            log.error("查询用户异常，耗时：{}ms，异常信息：{}", (endTime - startTime), e.getMessage(), e);
            throw e;
        }
    }

    /**
     * 查询用户列表
     *
     * @param sysUser 用户
     * @return 用户
     */
    @Override
    public List<SysUser> selectSysUserList(SysUser sysUser) {
        long startTime = System.currentTimeMillis();
        log.info("查询用户列表开始，参数：{}", cn.hutool.json.JSONUtil.toJsonStr(sysUser));
        try {
            List<SysUser> result = sysUserMapper.selectSysUserList(sysUser);
            long endTime = System.currentTimeMillis();
            log.info("查询用户列表结束，耗时：{}ms，结果数量：{}", (endTime - startTime), result.size());
            return result;
        } catch (Exception e) {
            long endTime = System.currentTimeMillis();
            log.error("查询用户列表异常，耗时：{}ms，异常信息：{}", (endTime - startTime), e.getMessage(), e);
            throw e;
        }
    }

    /**
     * 新增用户
     *
     * @param sysUser 用户
     * @return 结果
     */
    @Override
    public int insertSysUser(SysUser sysUser) {
        long startTime = System.currentTimeMillis();
        log.info("新增用户开始，参数：{}", cn.hutool.json.JSONUtil.toJsonStr(sysUser));
        try {
            // 使用链式赋值设置默认值
            SysUser userToInsert = sysUser
                .setCreateTime(new Date())
                .setDelFlag("0");
            
            int result = sysUserMapper.insertSysUser(userToInsert);
            long endTime = System.currentTimeMillis();
            log.info("新增用户结束，耗时：{}ms，影响行数：{}", (endTime - startTime), result);
            return result;
        } catch (Exception e) {
            long endTime = System.currentTimeMillis();
            log.error("新增用户异常，耗时：{}ms，异常信息：{}", (endTime - startTime), e.getMessage(), e);
            throw e;
        }
    }

    // ... 其他具有相似日志模式的方法
}
```

**核心特性：**
- 使用 `@Slf4j` 注解进行日志记录
- 每个方法包含：
  - 详细的 JavaDoc 注释
  - 带方法描述的开始时间日志
  - 用于异常处理的 try-catch 块
  - 带执行持续时间的结束时间日志
  - 带持续时间和异常详情的错误日志
- 使用 Hutool 的 `JSONUtil.toJsonStr()` 进行参数序列化
- 支持链式赋值操作

### Controller 控制器

```java
package com.ruoyi.system.controller;

import java.util.List;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import com.ruoyi.common.annotation.Log;
import com.ruoyi.common.core.controller.BaseController;
import com.ruoyi.common.core.domain.AjaxResult;
import com.ruoyi.common.enums.BusinessType;
import com.ruoyi.common.utils.poi.ExcelUtil;
import com.ruoyi.common.core.page.TableDataInfo;
import com.ruoyi.system.domain.SysUser;
import com.ruoyi.system.service.ISysUserService;

/**
 * @Description: 用户管理Controller控制层
 * @BelongsProject: ruoyi-vue-pro
 * @BelongsPackage: com.ruoyi.system.controller
 * @Class: SysUserController
 * @Author: HRuinger.
 * @CreateTime: 2026-03-29
 * @Version: 1.0.0
 */
@RestController
@RequestMapping("/system/user")
public class SysUserController extends BaseController {
    
    @Autowired
    private ISysUserService sysUserService;

    /**
     * 查询用户管理列表
     */
    @PreAuthorize("@ss.hasPermi('system:user:list')")
    @GetMapping("/list")
    public TableDataInfo list(SysUser sysUser) {
        startPage();
        List<SysUser> list = sysUserService.selectSysUserList(sysUser);
        return getDataTable(list);
    }

    /**
     * 导出用户管理列表
     */
    @PreAuthorize("@ss.hasPermi('system:user:export')")
    @Log(title = "用户管理", businessType = BusinessType.EXPORT)
    @PostMapping("/export")
    public void export(HttpServletResponse response, SysUser sysUser) {
        List<SysUser> list = sysUserService.selectSysUserList(sysUser);
        ExcelUtil<SysUser> util = new ExcelUtil<SysUser>(SysUser.class);
        util.exportExcel(response, list, "用户管理数据");
    }

    /**
     * 获取用户管理详细信息
     */
    @PreAuthorize("@ss.hasPermi('system:user:query')")
    @GetMapping(value = "/{userId}")
    public AjaxResult getInfo(@PathVariable("userId") Long userId) {
        return success(sysUserService.selectSysUserByUserId(userId));
    }

    /**
     * 新增用户管理
     */
    @PreAuthorize("@ss.hasPermi('system:user:add')")
    @Log(title = "用户管理", businessType = BusinessType.INSERT)
    @PostMapping
    public AjaxResult add(@RequestBody SysUser sysUser) {
        return toAjax(sysUserService.insertSysUser(sysUser));
    }

    /**
     * 修改用户管理
     */
    @PreAuthorize("@ss.hasPermi('system:user:edit')")
    @Log(title = "用户管理", businessType = BusinessType.UPDATE)
    @PutMapping
    public AjaxResult edit(@RequestBody SysUser sysUser) {
        return toAjax(sysUserService.updateSysUser(sysUser));
    }

    /**
     * 删除用户管理
     */
    @PreAuthorize("@ss.hasPermi('system:user:remove')")
    @Log(title = "用户管理", businessType = BusinessType.DELETE)
    @DeleteMapping("/{userIds}")
    public AjaxResult remove(@PathVariable Long[] userIds) {
        return toAjax(sysUserService.deleteSysUserByUserIds(userIds));
    }
}
```

### Portal 端 Controller 用户 ID 获取规范（硬性规则）

> ⚠️ **此规则为强制性规范，每次生成 Portal 端 Controller 时必须遵守。**

在 RuoYi-Vue-Plus 框架中，Portal 端（用户端）Controller 需要获取当前登录用户 ID 时，**必须使用 `LoginHelper.getUserId()`，绝对禁止直接使用 `StpUtil.getLoginIdAsLong()`**。

**原因：**
- RuoYi-Vue-Plus 的登录 ID 格式为复合字符串，例如 `"sys_user:1"`（格式：`userType:userId`）
- `StpUtil.getLoginIdAsLong()` 尝试将复合字符串解析为 `Long`，会抛出 `NumberFormatException`
- `LoginHelper.getUserId()` 是 RuoYi 框架封装的正确方法，能正确解析复合 ID 中的用户 ID 部分

**错误示例（禁止）：**
```java
import cn.dev33.satoken.stp.StpUtil;

@GetMapping("/my")
public R<List<MyRecordVo>> myRecords() {
    Long userId = StpUtil.getLoginIdAsLong();  // ❌ 错误！会抛 NumberFormatException
    return R.ok(service.queryByUserId(userId));
}
```

**正确示例（必须）：**
```java
import org.dromara.common.satoken.utils.LoginHelper;

@SaCheckLogin
@GetMapping("/my")
public R<List<MyRecordVo>> myRecords() {
    Long userId = LoginHelper.getUserId();  // ✅ 正确
    return R.ok(service.queryByUserId(userId));
}
```

**每次生成代码后的强制检查项：**
1. 搜索所有生成的 Controller 文件，确认不存在 `StpUtil.getLoginIdAsLong()`
2. 确认所有需要用户 ID 的地方都使用了 `LoginHelper.getUserId()`
3. 确认 import 语句正确：`import org.dromara.common.satoken.utils.LoginHelper;`

## 前端优化集成

### 启用前端优化技能

当启用前端优化时，skill 将自动调用以下技能来优化生成的 Vue 页面：

1. **theme-factory** - 主题工厂
   - 提供 10 种预设主题（颜色和字体）
   - 统一界面风格
   - 响应式设计支持

2. **ui-ux-pro-max** - UI/UX 智能设计
   - 50 种设计风格
   - 21 种调色板
   - 50 种字体搭配
   - 20 种图表类型
   - 8 种技术栈支持（React、Next.js、Vue、Svelte、SwiftUI、React Native、Flutter、Tailwind）

3. **frontend-design** - 前端界面设计
   - 创建高品质、生产标准的前端界面
   - 避免通用 AI 设计风格
   - 现代、精致的代码

4. **aesthetic** - 美学设计
   - 遵循成熟的设计原则
   - 创建美观的界面
   - 视觉层次结构和色彩理论
   - 微交互设计

5. **canvas-design** - 画布设计
   - 在 .png 和 .pdf 文件中创作精美的视觉艺术作品
   - 设计海报、艺术品等
   - 原创视觉设计

### 前端优化流程

```
1. 生成基础 Vue 代码
   ↓
2. 使用 theme-factory 应用主题
   ↓
3. 使用 ui-ux-pro-max 优化 UI/UX
   ↓
4. 使用 frontend-design 完善界面
   ↓
5. 使用 aesthetic 提升美学
   ↓
6. 使用 canvas-design 创建视觉素材（如需要）
   ↓
7. 分析优化后的页面，识别缺失的后端接口
   ↓
8. 自动补充后端代码
   ↓
9. 输出完整的前后端代码
```

### 前端优化后的页面特性

- **现代化设计**：符合 Material Design、Ant Design 等现代设计规范
- **响应式布局**：支持多种设备尺寸
- **流畅动画**：平滑的过渡效果和微交互
- **优秀可访问性**：符合 WCAG 标准
- **统一主题**：一致的颜色、字体和间距
- **丰富的组件**：表格、表单、对话框、通知等
- **数据可视化**：图表、统计卡片等
- **优雅的错误处理**：友好的错误提示

### 前端优化示例

**优化前的列表页面：**
```vue
<template>
  <div class="app-container">
    <el-table :data="dataList" border>
      <el-table-column prop="userName" label="用户名" />
      <el-table-column prop="nickName" label="昵称" />
      <el-table-column label="操作">
        <template slot-scope="scope">
          <el-button size="mini" @click="handleEdit(scope.row)">编辑</el-button>
        </template>
      </el-table-column>
    </el-table>
  </div>
</template>
```

**优化后的列表页面：**
```vue
<template>
  <div class="app-container" :class="themeClass">
    <!-- 统计卡片 -->
    <el-row :gutter="20" class="stats-row">
      <el-col :xs="24" :sm="12" :md="6" v-for="stat in stats" :key="stat.key">
        <div class="stat-card" :style="{ background: stat.color }">
          <div class="stat-icon">
            <i :class="stat.icon"></i>
          </div>
          <div class="stat-content">
            <div class="stat-value">{{ stat.value }}</div>
            <div class="stat-label">{{ stat.label }}</div>
          </div>
        </div>
      </el-col>
    </el-row>

    <!-- 搜索表单 -->
    <el-card class="search-card" shadow="hover">
      <el-form :model="queryParams" :inline="true" @submit.native.prevent>
        <el-form-item label="用户名">
          <el-input
            v-model="queryParams.userName"
            placeholder="请输入用户名"
            clearable
            @keyup.enter.native="handleQuery"
          />
        </el-form-item>
        <el-form-item>
          <el-button type="primary" icon="el-icon-search" @click="handleQuery">搜索</el-button>
          <el-button icon="el-icon-refresh" @click="resetQuery">重置</el-button>
        </el-form-item>
      </el-form>
    </el-card>

    <!-- 数据表格 -->
    <el-card class="table-card" shadow="hover">
      <el-row :gutter="10" class="mb8">
        <el-col :span="1.5">
          <el-button
            type="primary"
            icon="el-icon-plus"
            size="mini"
            @click="handleAdd"
            v-hasPermi="['system:user:add']"
          >新增</el-button>
        </el-col>
        <el-col :span="1.5">
          <el-button
            type="danger"
            icon="el-icon-delete"
            size="mini"
            :disabled="multiple"
            @click="handleDelete"
            v-hasPermi="['system:user:remove']"
          >删除</el-button>
        </el-col>
      </el-row>

      <el-table
        v-loading="loading"
        :data="dataList"
        border
        stripe
        highlight-current-row
        @selection-change="handleSelectionChange"
      >
        <el-table-column type="selection" width="55" align="center" />
        <el-table-column label="用户ID" prop="userId" width="100" />
        <el-table-column label="用户名" prop="userName" min-width="120">
          <template slot-scope="scope">
            <el-link type="primary" @click="handleView(scope.row)">
              {{ scope.row.userName }}
            </el-link>
          </template>
        </el-table-column>
        <el-table-column label="昵称" prop="nickName" min-width="120" />
        <el-table-column label="状态" prop="status" width="100">
          <template slot-scope="scope">
            <el-tag :type="scope.row.status === '0' ? 'success' : 'danger'">
              {{ scope.row.status === '0' ? '正常' : '停用' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="创建时间" prop="createTime" width="180" />
        <el-table-column label="操作" width="200" align="center" fixed="right">
          <template slot-scope="scope">
            <el-button
              size="mini"
              type="text"
              icon="el-icon-view"
              @click="handleView(scope.row)"
              v-hasPermi="['system:user:query']"
            >查看</el-button>
            <el-button
              size="mini"
              type="text"
              icon="el-icon-edit"
              @click="handleEdit(scope.row)"
              v-hasPermi="['system:user:edit']"
            >编辑</el-button>
            <el-button
              size="mini"
              type="text"
              icon="el-icon-delete"
              @click="handleDelete(scope.row)"
              v-hasPermi="['system:user:remove']"
            >删除</el-button>
          </template>
        </el-table-column>
      </el-table>

      <!-- 分页 -->
      <pagination
        v-show="total > 0"
        :total="total"
        :page.sync="queryParams.pageNum"
        :limit.sync="queryParams.pageSize"
        @pagination="getList"
      />
    </el-card>

    <!-- 添加/编辑对话框 -->
    <el-dialog
      :title="title"
      :visible.sync="open"
      width="600px"
      append-to-body
      :close-on-click-modal="false"
    >
      <el-form ref="form" :model="form" :rules="rules" label-width="80px">
        <el-form-item label="用户名" prop="userName">
          <el-input v-model="form.userName" placeholder="请输入用户名" />
        </el-form-item>
        <el-form-item label="昵称" prop="nickName">
          <el-input v-model="form.nickName" placeholder="请输入昵称" />
        </el-form-item>
        <el-form-item label="邮箱" prop="email">
          <el-input v-model="form.email" placeholder="请输入邮箱" />
        </el-form-item>
        <el-form-item label="状态" prop="status">
          <el-radio-group v-model="form.status">
            <el-radio label="0">正常</el-radio>
            <el-radio label="1">停用</el-radio>
          </el-radio-group>
        </el-form-item>
      </el-form>
      <div slot="footer" class="dialog-footer">
        <el-button type="primary" @click="submitForm">确 定</el-button>
        <el-button @click="cancel">取 消</el-button>
      </div>
    </el-dialog>
  </div>
</template>

<script>
import { listUser, getUser, delUser, addUser, updateUser } from "@/api/system/user";

export default {
  name: "User",
  data() {
    return {
      loading: false,
      ids: [],
      single: true,
      multiple: true,
      showSearch: true,
      total: 0,
      dataList: [],
      title: "",
      open: false,
      queryParams: {
        pageNum: 1,
        pageSize: 10,
        userName: null,
      },
      form: {},
      rules: {
        userName: [
          { required: true, message: "用户名不能为空", trigger: "blur" }
        ],
        nickName: [
          { required: true, message: "昵称不能为空", trigger: "blur" }
        ],
      },
      stats: [
        { key: 'total', label: '总用户数', value: 0, icon: 'el-icon-user', color: 'linear-gradient(135deg, #667eea 0%, #764ba2 100%)' },
        { key: 'active', label: '活跃用户', value: 0, icon: 'el-icon-check', color: 'linear-gradient(135deg, #f093fb 0%, #f5576c 100%)' },
        { key: 'inactive', label: '停用用户', value: 0, icon: 'el-icon-close', color: 'linear-gradient(135deg, #4facfe 0%, #00f2fe 100%)' },
        { key: 'new', label: '新增用户', value: 0, icon: 'el-icon-plus', color: 'linear-gradient(135deg, #43e97b 0%, #38f9d7 100%)' }
      ]
    };
  },
  computed: {
    themeClass() {
      return `theme-${this.$store.state.app.theme}`;
    }
  },
  created() {
    this.getList();
    this.getStats();
  },
  methods: {
    getList() {
      this.loading = true;
      listUser(this.queryParams).then(response => {
        this.dataList = response.rows;
        this.total = response.total;
        this.loading = false;
      });
    },
    getStats() {
      // 获取统计数据
      // 后端需要提供统计接口
    },
    handleQuery() {
      this.queryParams.pageNum = 1;
      this.getList();
    },
    resetQuery() {
      this.resetForm("queryForm");
      this.handleQuery();
    },
    handleAdd() {
      this.reset();
      this.open = true;
      this.title = "添加用户";
    },
    handleEdit(row) {
      this.reset();
      const userId = row.userId || this.ids;
      getUser(userId).then(response => {
        this.form = response.data;
        this.open = true;
        this.title = "修改用户";
      });
    },
    handleView(row) {
      const userId = row.userId;
      getUser(userId).then(response => {
        this.$alert(
          `用户名：${response.data.userName}<br>` +
          `昵称：${response.data.nickName}<br>` +
          `邮箱：${response.data.email}<br>` +
          `状态：${response.data.status === '0' ? '正常' : '停用'}`,
          '用户详情',
          { dangerouslyUseHTMLString: true }
        );
      });
    },
    handleDelete(row) {
      const userIds = row.userId ? [row.userId] : this.ids;
      this.$confirm('是否确认删除选中的用户数据项？', "警告", {
        confirmButtonText: "确定",
        cancelButtonText: "取消",
        type: "warning"
      }).then(function() {
        return delUser(userIds);
      }).then(() => {
        this.getList();
        this.$message.success("删除成功");
      });
    },
    submitForm() {
      this.$refs["form"].validate(valid => {
        if (valid) {
          if (this.form.userId != null) {
            updateUser(this.form).then(response => {
              this.$message.success("修改成功");
              this.open = false;
              this.getList();
            });
          } else {
            addUser(this.form).then(response => {
              this.$message.success("新增成功");
              this.open = false;
              this.getList();
            });
          }
        }
      });
    },
    cancel() {
      this.open = false;
      this.reset();
    },
    reset() {
      this.form = {
        userId: null,
        userName: null,
        nickName: null,
        email: null,
        status: "0",
      };
      this.resetForm("form");
    }
  }
};
</script>

<style scoped lang="scss">
.app-container {
  padding: var(--space-24);
  background: var(--bg-surface);
  min-height: 100vh;

  .stats-row {
    margin-bottom: 20px;

    .stat-card {
      border-radius: var(--card-radius);
      padding: 24px;
      color: white;
      display: flex;
      align-items: center;
      transition: all 0.3s ease;
      cursor: pointer;

      &:hover {
        transform: translateY(-5px);
        box-shadow: 0 8px 20px rgba(0, 0, 0, 0.15);
      }

      .stat-icon {
        font-size: 48px;
        opacity: 0.9;
        margin-right: 20px;
      }

      .stat-content {
        .stat-value {
          font-size: 32px;
          font-weight: bold;
          margin-bottom: 8px;
        }

        .stat-label {
          font-size: var(--fs-label-md);
          opacity: 0.9;
        }
      }
    }
  }

  .search-card,
  .table-card {
    margin-bottom: 20px;
    border-radius: var(--card-radius);
    transition: all 0.3s ease;

    &:hover {
      box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
    }
  }
}

/* 主题样式 */
.theme-default {
  --primary-color: #409EFF;
  --success-color: #67C23A;
  --warning-color: #E6A23C;
  --danger-color: #F56C6C;
}

.theme-dark {
  --primary-color: #409EFF;
  --success-color: #67C23A;
  --warning-color: #E6A23C;
  --danger-color: #F56C6C;
  background: #1a1a1a;
}
</style>
```

## 后端代码补充

### 自动补充逻辑

当前端优化技能添加新功能时（如统计卡片、高级搜索、批量操作等），skill 会自动分析前端页面，识别缺失的后端接口，并补充相应的后端代码。

### 补充的后端代码示例

**1. 统计接口**

```java
/**
 * @Description: 用户统计数据
 * @BelongsProject: ruoyi-vue-pro
 * @BelongsPackage: com.ruoyi.system.domain
 * @Class: UserStatsVO
 * @Author: HRuinger.
 * @CreateTime: 2026-03-29
 * @Version: 1.0.0
 */
@Data
@Accessors(chain = true)
@AllArgsConstructor
@NoArgsConstructor
public class UserStatsVO {
    /** 总用户数 */
    private Long total;
    
    /** 活跃用户数 */
    private Long active;
    
    /** 停用用户数 */
    private Long inactive;
    
    /** 新增用户数 */
    private Long newUsers;
}
```

**Service 接口添加：**
```java
/**
 * 查询用户统计数据
 *
 * @return 用户统计
 */
UserStatsVO getUserStats();
```

**Service 实现添加：**
```java
@Override
public UserStatsVO getUserStats() {
    long startTime = System.currentTimeMillis();
    log.info("查询用户统计数据开始");
    try {
        UserStatsVO stats = new UserStatsVO();
        
        // 总用户数
        Long total = sysUserMapper.countUsers();
        stats.setTotal(total);
        
        // 活跃用户数
        Long active = sysUserMapper.countUsersByStatus("0");
        stats.setActive(active);
        
        // 停用用户数
        Long inactive = sysUserMapper.countUsersByStatus("1");
        stats.setInactive(inactive);
        
        // 今日新增用户数
        Long newUsers = sysUserMapper.countTodayUsers();
        stats.setNewUsers(newUsers);
        
        long endTime = System.currentTimeMillis();
        log.info("查询用户统计数据结束，耗时：{}ms，结果：{}", 
                 (endTime - startTime), cn.hutool.json.JSONUtil.toJsonStr(stats));
        return stats;
    } catch (Exception e) {
        long endTime = System.currentTimeMillis();
        log.error("查询用户统计数据异常，耗时：{}ms，异常信息：{}", 
                 (endTime - startTime), e.getMessage(), e);
        throw e;
    }
}
```

**Controller 添加：**
```java
/**
 * 获取用户统计数据
 */
@PreAuthorize("@ss.hasPermi('system:user:list')")
@GetMapping("/stats")
public AjaxResult getStats() {
    return success(sysUserService.getUserStats());
}
```

**Mapper 添加：**
```java
/**
 * 统计用户总数
 *
 * @return 用户总数
 */
Long countUsers();

/**
 * 按状态统计用户数
 *
 * @param status 状态
 * @return 用户数
 */
Long countUsersByStatus(String status);

/**
 * 统计今日新增用户数
 *
 * @return 今日新增用户数
 */
Long countTodayUsers();
```

**Mapper XML 添加：**
```xml
<!-- 统计用户总数 -->
<select id="countUsers" resultType="java.lang.Long">
    SELECT COUNT(1) FROM sys_user WHERE del_flag = '0'
</select>

<!-- 按状态统计用户数 -->
<select id="countUsersByStatus" resultType="java.lang.Long">
    SELECT COUNT(1) FROM sys_user 
    WHERE status = #{status} AND del_flag = '0'
</select>

<!-- 统计今日新增用户数 -->
<select id="countTodayUsers" resultType="java.lang.Long">
    SELECT COUNT(1) FROM sys_user 
    WHERE DATE(create_time) = CURDATE() AND del_flag = '0'
</select>
```

**API 文件添加：**
```javascript
// 获取用户统计数据
export function getUserStats() {
  return request({
    url: '/system/user/stats',
    method: 'get'
  })
}
```

### 2. 高级搜索接口

```java
/**
 * 高级搜索用户
 *
 * @param userQuery 查询条件
 * @return 用户列表
 */
List<SysUser> advancedSearch(UserQuery userQuery);
```

### 3. 批量操作接口

```java
/**
 * 批量更新用户状态
 *
 * @param userIds 用户ID数组
 * @param status 状态
 * @return 结果
 */
int batchUpdateStatus(Long[] userIds, String status);
```

## 依赖管理

### Lombok 依赖检查

Skill 会自动检查项目 `pom.xml` 中的 Lombok 依赖：

```xml
<dependency>
    <groupId>org.projectlombok</groupId>
    <artifactId>lombok</artifactId>
    <version>1.18.30</version>
</dependency>
```

如果未找到，会自动添加到 `pom.xml` 文件中。

### Hutool 依赖检查

Skill 会自动检查 Hutool 依赖：

```xml
<dependency>
    <groupId>cn.hutool</groupId>
    <artifactId>hutool-all</artifactId>
    <version>5.8.28</version>
</dependency>
```

如果未找到，会自动添加。生成的代码中 Hutool 方法优先于标准 Java 方法。

## 项目结构分析

Skill 会智能分析项目结构以确定：

1. **包结构**：分析现有包以确定正确的包路径
2. **模块位置**：基于现有结构识别新模块的正确位置
3. **前端结构**：分析前端项目结构以正确放置生成的代码
4. **配置文件**：读取现有配置文件以保持一致性
5. **主题配置**：分析现有主题配置，确保优化后的页面使用一致的主题

## 错误检测和修正

生成代码后，Skill 会执行：

1. **导入语句验证**：检查所有必需的导入是否存在
2. **语法验证**：使用项目的 linter 验证语法错误
3. **常见问题修复**：自动修复常见问题，如：
   - 缺少导入
   - 不正确的包声明
   - 缺少注解
   - 不一致的命名约定
   - **Portal 端 Controller 中误用 `StpUtil.getLoginIdAsLong()` — 必须替换为 `LoginHelper.getUserId()`**
4. **编译检查**：尝试编译生成的代码以捕获运行时错误
5. **前后端一致性检查**：验证前端调用的接口在后端都存在
6. **Portal Controller 用户 ID 规范检查**：
   - 扫描所有 `*Portal*Controller.java` 文件
   - 检查是否存在 `StpUtil.getLoginIdAsLong()` 调用
   - 如存在，自动替换为 `LoginHelper.getUserId()` 并修正 import
   - 确认 import `org.dromara.common.satoken.utils.LoginHelper` 已添加

## 文档生成

Skill 会在 `doc/功能模块/` 目录下创建完整的文档：

**文档内容：**
1. **README.md**：生成模块的概述
2. **API.md**：API 端点文档
3. **Database.md**：数据库架构和关系
4. **Frontend.md**：前端组件结构和用法
5. **Generated Files.md**：所有生成文件及描述的列表
6. **BackendSupplement.md**：后端代码补充说明（如果适用）

## 模板类型

### CRUD（标准）
为单表生成标准 CRUD 操作，包括：
- 带分页的列表视图
- 新增/编辑表单
- 删除功能
- 导出功能
- 统计数据展示
- 高级搜索

### Tree（树形结构）
用于具有以下特性的层次数据结构：
- 树形结构显示
- 展开/折叠功能
- 父子关系管理
- 拖放支持（如果适用）

### Sub（主子表）
用于具有以下特性的主子表关系：
- 主表管理
- 主表上下文中的明细表管理
- 父子数据同步
- 批量操作

## 前端类型

### Element UI (Vue 2)
用于带有 Element UI 的 Vue 2.x 项目：
- 使用 Element UI 组件
- Vue 2 语法
- JavaScript API 文件
- Vue SFC (.vue) 文件

### Element Plus (Vue 3)
用于带有 Element Plus 的 Vue 3.x 项目：
- 使用 Element Plus 组件
- Vue 3 Composition API
- JavaScript/TypeScript API 文件
- Vue 3 SFC (.vue) 文件

### Element Plus TypeScript
用于带有 TypeScript 的 Vue 3.x 项目：
- 使用 Element Plus 组件
- Vue 3 Composition API
- 带类型定义的 TypeScript API 文件
- 带 TypeScript 的 Vue 3 SFC

## 最佳实践

1. **表设计**：
   - 使用正确的命名约定（小写字母加下划线）
   - 包含标准列（`create_by`、`create_time` 等）
   - 为性能添加适当的索引
   - 提供清晰的列注释

2. **代码定制**：
   - 集成前查看生成的代码
   - 根据需要定制业务逻辑
   - 在表单中添加验证规则
   - 在 mapper.xml 中实现自定义查询

3. **测试**：
   - 测试所有 CRUD 操作
   - 验证权限控制
   - 测试导出功能
   - 验证表单提交
   - 测试前后端交互

4. **前端优化**：
   - 充分利用前端优化技能
   - 选择合适的主题和风格
   - 确保响应式设计
   - 测试不同设备的显示效果

## 故障排除

### 常见问题

1. **缺少依赖**：确保代码生成后更新 Maven/Gradle 依赖
2. **编译错误**：检查冲突的导入或缺失的类
3. **前端集成**：确保 API 路由与后端控制器映射匹配
4. **数据库连接**：验证数据库连接和表存在性
5. **链式赋值问题**：确保实体类使用 `@Accessors(chain = true)` 注解
6. **前端优化不生效**：检查是否正确启用了前端优化技能
7. **后端接口缺失**：查看 BackendSupplement.md 文件，手动补充缺失的接口

## 智能需求分析功能

### 功能概述

当用户没有提供 SQL 或对应生成模块的表时，skill 会先分析需求模块，然后依据功能模块来设计对应的 RuoYi-Vue 框架可以使用的表。

### 需求分析流程

```
1. 接收用户需求描述
   ↓
2. 分析需求，提取关键信息
   - 功能名称
   - 操作类型（CRUD）
   - 字段列表
   - 业务规则
   ↓
3. 根据分析结果设计表结构
   - 添加标准字段（RuoYi-Vue 规范）
   - 添加业务字段（从需求中提取）
   - 添加功能特定字段（树形/主子表）
   ↓
4. 生成 SQL 脚本
   ↓
5. 执行 SQL 到数据库
   ↓
6. 生成代码和菜单
```

### 需求分析示例

**用户需求：**
```
需求：用户管理模块
功能：管理系统的用户信息，包括用户的增删改查
字段：用户名、昵称、邮箱、手机号、性别、头像、状态
操作：查询用户列表、新增用户、编辑用户、删除用户
```

**分析结果：**

1. **功能模块名称**：用户管理
2. **表名**：sys_user
3. **字段列表**：
   - 用户名（String, 30）
   - 昵称（String, 30）
   - 邮箱（String, 50）
   - 手机号（String, 11）
   - 性别（String, 1）
   - 头像（String, 100）
   - 状态（String, 1）

4. **操作类型**：CRUD（标准增删改查）

**自动生成的表结构：**

```sql
-- 用户信息表
-- 创建时间：2026-03-29 20:26:25

DROP TABLE IF EXISTS `sys_user`;
CREATE TABLE `sys_user` (
    `id` BIGINT(20) NOT NULL COMMENT '主键ID',
    `tenant_id` BIGINT(20) NOT NULL COMMENT '租户ID',
    `user_name` VARCHAR(30) NOT NULL COMMENT '用户名',
    `nick_name` VARCHAR(30) NOT NULL COMMENT '昵称',
    `email` VARCHAR(50) DEFAULT '' COMMENT '邮箱',
    `phonenumber` VARCHAR(11) DEFAULT '' COMMENT '手机号',
    `sex` CHAR(1) DEFAULT '0' COMMENT '性别（0男 1女 2未知）',
    `avatar` VARCHAR(100) DEFAULT '' COMMENT '头像',
    `status` CHAR(1) DEFAULT '0' COMMENT '状态（0正常 1停用）',
    `create_by` VARCHAR(64) DEFAULT '' COMMENT '创建者',
    `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_by` VARCHAR(64) DEFAULT '' COMMENT '更新者',
    `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    `remark` VARCHAR(500) DEFAULT '' COMMENT '备注',
    `del_flag` CHAR(1) DEFAULT '0' COMMENT '删除标志（0代表存在 2代表删除）',
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户管理表';

-- 添加字段注释
ALTER TABLE `sys_user` MODIFY COLUMN `id` BIGINT(20) NOT NULL COMMENT '主键ID';
ALTER TABLE `sys_user` MODIFY COLUMN `tenant_id` BIGINT(20) NOT NULL COMMENT '租户ID';
ALTER TABLE `sys_user` MODIFY COLUMN `user_name` VARCHAR(30) NOT NULL COMMENT '用户名';
ALTER TABLE `sys_user` MODIFY COLUMN `nick_name` VARCHAR(30) NOT NULL COMMENT '昵称';
ALTER TABLE `sys_user` MODIFY COLUMN `email` VARCHAR(50) DEFAULT '' COMMENT '邮箱';
ALTER TABLE `sys_user` MODIFY COLUMN `phonenumber` VARCHAR(11) DEFAULT '' COMMENT '手机号';
ALTER TABLE `sys_user` MODIFY COLUMN `sex` CHAR(1) DEFAULT '0' COMMENT '性别（0男 1女 2未知）';
ALTER TABLE `sys_user` MODIFY COLUMN `avatar` VARCHAR(100) DEFAULT '' COMMENT '头像';
ALTER TABLE `sys_user` MODIFY COLUMN `status` CHAR(1) DEFAULT '0' COMMENT '状态（0正常 1停用）';
ALTER TABLE `sys_user` MODIFY COLUMN `create_by` VARCHAR(64) DEFAULT '' COMMENT '创建者';
ALTER TABLE `sys_user` MODIFY COLUMN `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间';
ALTER TABLE `sys_user` MODIFY COLUMN `update_by` VARCHAR(64) DEFAULT '' COMMENT '更新者';
ALTER TABLE `sys_user` MODIFY COLUMN `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间';
ALTER TABLE `sys_user` MODIFY COLUMN `remark` VARCHAR(500) DEFAULT '' COMMENT '备注';
ALTER TABLE `sys_user` MODIFY COLUMN `del_flag` CHAR(1) DEFAULT '0' COMMENT '删除标志（0代表存在 2代表删除）';
```

### 标准字段说明

所有自动生成的表都会包含以下 RuoYi-Vue 标准字段：

| 字段名 | Java类型 | 说明 | 默认值 |
|--------|----------|------|--------|
| id | Long | 主键ID | - |
| tenant_id | Long | 租户ID（多租户） | - |
| create_by | String | 创建者 | '' |
| create_time | Date | 创建时间 | CURRENT_TIMESTAMP |
| update_by | String | 更新者 | '' |
| update_time | Date | 更新时间 | CURRENT_TIMESTAMP ON UPDATE |
| remark | String | 备注 | '' |
| del_flag | String | 删除标志（0=正常，1=删除） | '0' |

### 功能特定字段

根据不同的功能类型，还会添加特定字段：

**树形结构（Tree）功能：**
- `parent_id` (Long) - 父级ID
- `ancestors` (String) - 祖级列表
- `order_num` (Integer) - 显示顺序

**主子表（Sub）功能：**
- `{business}_id` (Long) - 关联主表ID

## SQL 自动执行功能

### 功能说明

生成的 SQL 脚本会自动执行到数据库中，无需手动操作。

### SQL 文件存放

- **默认位置**：项目根目录下的 `sql` 目录
- **文件命名**：`{功能模块}.sql`
- **示例**：`sql/user.sql`

### 执行流程

```
1. 生成 SQL 脚本
   ↓
2. 连接数据库
   ↓
3. 执行 SQL 脚本
   ↓
4. 验证执行结果
   ↓
5. 返回执行状态
```

### 执行结果

- ✅ 成功：SQL 成功执行到数据库
- ⚠️ 失败：显示错误信息，需要检查数据库连接或 SQL 语法

## 菜单和字典生成功能

### 菜单生成

#### 功能说明

根据功能模块自动生成 RuoYi-Vue 的菜单结构，支持菜单层级管理。

#### 菜单层级

菜单会生成在指定的父菜单下，例如：
- 系统管理（ID: 1）
  - 用户管理（新增）
  - 角色管理（已存在）

#### 生成的菜单数据

```sql
-- 菜单 SQL 示例
INSERT INTO `sys_menu` VALUES (
    100, 1, 2, '用户管理', 'user', 'system/user/index', 1, 0, 'C',
    '0', '0', 'system:user:list', 'user', 'admin', '2026-03-29 20:26:25', '', NULL,
    '用户管理菜单'
);

-- 按钮权限
INSERT INTO `sys_menu` VALUES (
    1001, 100, 1, '用户查询', '', '', 1, 0, 'F', '0', '0', 'system:user:query', '#',
    'admin', '2026-03-29 20:26:25', '', NULL, ''
);

INSERT INTO `sys_menu` VALUES (
    1002, 100, 2, '用户新增', '', '', 1, 0, 'F', '0', '0', 'system:user:add', '#',
    'admin', '2026-03-29 20:26:25', '', NULL, ''
);

INSERT INTO `sys_menu` VALUES (
    1003, 100, 3, '用户修改', '', '', 1, 0, 'F', '0', '0', 'system:user:edit', '#',
    'admin', '2026-03-29 20:26:25', '', NULL, ''
);

INSERT INTO `sys_menu` VALUES (
    1004, 100, 4, '用户删除', '', '', 1, 0, 'F', '0', '0', 'system:user:remove', '#',
    'admin', '2026-03-29 20:26:25', '', NULL, ''
);
```

#### 菜单关系

菜单之间的关系由 `parent_id` 字段确定，生成的菜单会根据父菜单 ID 自动挂载到对应的位置。

### 字典生成

#### 功能说明

根据功能模块中的状态、类型等字段，自动生成对应的字典数据。

#### 字典类型

常见的字典类型：
- 用户状态（user_status）
- 性别（sys_user_sex）
- 是否标志（sys_yes_no）

#### 生成的字典数据

```sql
-- 字典类型
INSERT INTO `sys_dict_type` VALUES (
    100, '用户状态', 'sys_user_status', '0', 'admin', '2026-03-29 20:26:25', '', NULL, '用户状态列表'
);

-- 字典数据
INSERT INTO `sys_dict_data` VALUES (
    1, 100, '正常', '0', 'sys_dict_type', '', '', '', 'N', '0', 'admin', '2026-03-29 20:26:25', '', NULL, '正常状态'
);

INSERT INTO `sys_dict_data` VALUES (
    2, 100, '停用', '1', 'sys_dict_type', '', '', '', 'N', '0', 'admin', '2026-03-29 20:26:25', '', NULL, '停用状态'
);
```

### 数据库写入

菜单和字典数据生成后，会自动写入到数据库的对应表中：

- `sys_menu` - 菜单表
- `sys_menu_button` - 菜单按钮权限表
- `sys_dict_type` - 字典类型表
- `sys_dict_data` - 字典数据表

## 注意事项

- 此 skill 基于 RuoYi-Vue 框架标准生成代码
- 生产使用前始终审查和测试生成的代码
- 初始生成后应添加自定义业务逻辑
- Skill 保持与现有项目结构和约定的一致性
- 前端优化可能会生成大量的代码，建议在开发环境中先测试
- 后端代码补充是基于前端页面自动生成的，可能需要手动调整业务逻辑
- 使用"从需求自动生成"方式时，确保数据库连接配置正确
- 生成的表结构包含 RuoYi-Vue 标准字段，请勿删除这些字段
- 菜单和字典数据会直接写入数据库，请确保有足够的权限
