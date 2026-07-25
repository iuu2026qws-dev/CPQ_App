---
name: ruoyi-fast-gen
description: 智能生成 RuoYi-fast 单体应用代码的高级技能。能够根据产品需求自动生成完整的后端和前端代码，包括数据库表、字典数据、菜单配置、Domain（使用 Lombok）、Mapper、Service（使用 @Slf4j 和 Hutool）、Controller 以及前端页面（列表、新增、编辑、详情）。相比基础版本，本技能更加智能，能够自动分析项目依赖、智能补全导入语句，并提供更高效的开发流程。Service 层日志功能已全面增强，包含时间记录、耗时统计、Hutool JSON 序列化支持。
---

# RuoYi-fast 智能代码生成技能

## ⛔ 强制：所有 CSS 必须用 Design Token

生成前端组件时，禁止硬编码任何 CSS 数值。必须引用 `dental-portal/src/styles/tokens.css` 中的变量：
- 圆角 → `var(--card-radius)`（24px）/ `var(--radius-sm)`（8px）/ `var(--radius-pill)`（999px）
- 间距 → `var(--space-4/8/12/16/24/32/48/64)`
- 颜色 → `var(--color-primary)` / `var(--bg-base)` / `var(--bg-surface)` / `var(--text-primary)`
- 阴影 → `var(--shadow-sm)` / `var(--shadow-md)` / `var(--shadow-brand)`
- 字号 → `var(--fs-body-md)` / `var(--fs-label-md)` / `var(--fs-heading-sm)`

内联 `style=""` 同样必须使用 `var(--*)`。

## 技能概述

本技能是 ruoyi-fast 的智能升级版，专门用于 RuoYi-fast 单体应用框架的快速开发。它能够智能地分析业务需求，自动生成符合项目规范的完整代码，包括数据库设计、后端代码、前端页面和权限配置。

## 核心优势

相比基础版本，本技能具有以下优势：

1. **智能依赖分析**：自动分析项目依赖，智能补全所需的导入语句
2. **完整功能支持**：自动生成详情页面及相关后端代码
3. **智能代码补全**：根据字段类型自动选择合适的数据类型和验证注解
4. **高效开发流程**：优化的开发流程，减少重复工作
5. **完整权限配置**：自动生成包括详情页面在内的所有权限配置
6. **Lombok 注解支持**：实体类使用 Lombok 注解（@Data、@Builder、@AllArgsConstructor、@NoArgsConstructor），自动生成 getter/setter，大幅减少样板代码
7. **Slf4j 日志支持**：Service 实现类使用 @Slf4j 注解，自动添加日志打印，便于调试和问题追踪

## 使用时机

当以下情况时使用此技能：

- 需要快速开发 RuoYi-fast 框架上的新功能模块
- 需要生成完整的 CRUD 功能（包括详情页面）
- 需要自动生成符合项目规范的代码
- 需要智能处理导入依赖和包配置
- 需要一次性生成数据库、后端、前端的完整代码

## 智能代码生成流程

### 阶段一：需求分析与智能识别

理解用户需求后，智能识别以下内容：

#### 1. 业务实体识别
- 自动识别实体名称（中文名、类名、表名）
- 自动识别业务字段（名称、类型、约束）
- 自动识别状态字段（需要字典数据）

#### 2. 模块信息识别
- 自动识别模块名称（用于包路径和路由）
- 自动识别菜单名称和权限标识

### 阶段二：数据库智能生成

#### 1. 数据库表生成（智能分析）

**表结构 SQL：**
```sql
-- ----------------------------
-- {实体中文名}
-- ----------------------------
DROP TABLE IF EXISTS {模块名}_{表名};
CREATE TABLE {模块名}_{表名} (
    {主键名}           bigint(20)      NOT NULL AUTO_INCREMENT    COMMENT '{主键注释}',
    {业务字段1}        {智能判断类型} DEFAULT {智能判断默认值}     COMMENT '{字段1注释}',
    {业务字段2}        {智能判断类型} DEFAULT {智能判断默认值}     COMMENT '{字段2注释}',
    {状态字段}         char(1)         DEFAULT '0'                COMMENT '状态（0正常 1停用）',
    del_flag          char(1)         DEFAULT '0'                COMMENT '删除标志（0代表存在 2代表删除）',
    create_by         varchar(64)     DEFAULT ''                 COMMENT '创建者',
    create_time       datetime                                    COMMENT '创建时间',
    update_by         varchar(64)     DEFAULT ''                 COMMENT '更新者',
    update_time       datetime                                    COMMENT '更新时间',
    remark            varchar(500)    DEFAULT NULL               COMMENT '备注',
    PRIMARY KEY ({主键名})
) ENGINE=InnoDB AUTO_INCREMENT=100 COMMENT = '{实体中文名}';
```

**智能字段类型映射：**
| 字段类型 | MySQL 类型 | Java 类型 | 验证注解 |
|---------|-----------|----------|---------|
| 字符串(短) | varchar(64) | String | @NotBlank, @Size(max=64) |
| 字符串(长) | varchar(500) | String | @Size(max=500) |
| 整数 | int(11) | Integer | @NotNull |
| 长整数 | bigint(20) | Long | @NotNull |
| 小数 | decimal(10,2) | BigDecimal | @NotNull |
| 日期时间 | datetime | Date | - |
| 文本 | text | String | - |

#### 2. 字典数据自动生成

如果包含状态字段，自动生成字典 SQL：

```sql
-- 字典类型
INSERT INTO sys_dict_type VALUES (
    (SELECT max(dict_id) + 1 FROM sys_dict_type),
    '{模块}_{状态字段}',
    '{实体中文名}状态',
    'biz',
    'Y',
    'admin',
    NOW(),
    '',
    NULL,
    '{实体中文名}状态字典'
);

-- 字典数据 - 正常状态
INSERT INTO sys_dict_data VALUES (
    (SELECT max(dict_code) + 1 FROM sys_dict_data),
    (SELECT dict_id FROM sys_dict_type WHERE dict_type = '{模块}_{状态字段}'),
    1,
    '正常',
    '0',
    'bg-success',
    'N',
    'admin',
    NOW(),
    '',
    NULL,
    '正常状态'
);

-- 字典数据 - 停用状态
INSERT INTO sys_dict_data VALUES (
    (SELECT max(dict_code) + 1 FROM sys_dict_data),
    (SELECT dict_id FROM sys_dict_type WHERE dict_type = '{模块}_{状态字段}'),
    2,
    '停用',
    '1',
    'bg-danger',
    'N',
    'admin',
    NOW(),
    '',
    NULL,
    '停用状态'
);
```

#### 3. 菜单权限智能生成（完整版）

```sql
-- 一级目录菜单（如需要）
INSERT INTO sys_menu VALUES (
    (SELECT max(menu_id) + 1 FROM sys_menu),
    '{模块中文名}',
    '0',
    {显示顺序},
    '{模块名}',
    NULL,
    '',
    '',
    1,
    0,
    'M',
    '0',
    '0',
    '',
    '{图标}',
    'admin',
    NOW(),
    '',
    NULL,
    '{模块中文名}目录'
);

-- 二级菜单（页面菜单）
INSERT INTO sys_menu VALUES (
    (SELECT max(menu_id) + 1 FROM sys_menu),
    '{实体中文名}',
    {父菜单ID},
    {显示顺序},
    '{对象名}',
    '{模块名}/{对象名}/{对象名}',
    '',
    '',
    1,
    0,
    'C',
    '0',
    '0',
    '{模块名}:{对象名}:list',
    '{图标}',
    'admin',
    NOW(),
    '',
    NULL,
    '{实体中文名}菜单'
);

-- 功能按钮权限（查询）
INSERT INTO sys_menu VALUES (
    (SELECT max(menu_id) + 1 FROM sys_menu),
    '{实体中文名}查询',
    {父菜单ID},
    1,
    '',
    '',
    '',
    '',
    1,
    0,
    'F',
    '0',
    '0',
    '{模块名}:{对象名}:query',
    '#',
    'admin',
    NOW(),
    '',
    NULL,
    ''
);

-- 功能按钮权限（新增）
INSERT INTO sys_menu VALUES (
    (SELECT max(menu_id) + 1 FROM sys_menu),
    '{实体中文名}新增',
    {父菜单ID},
    2,
    '',
    '',
    '',
    '',
    1,
    0,
    'F',
    '0',
    '0',
    '{模块名}:{对象名}:add',
    '#',
    'admin',
    NOW(),
    '',
    NULL,
    ''
);

-- 功能按钮权限（修改）
INSERT INTO sys_menu VALUES (
    (SELECT max(menu_id) + 1 FROM sys_menu),
    '{实体中文名}修改',
    {父菜单ID},
    3,
    '',
    '',
    '',
    '',
    1,
    0,
    'F',
    '0',
    '0',
    '{模块名}:{对象名}:edit',
    '#',
    'admin',
    NOW(),
    '',
    NULL,
    ''
);

-- 功能按钮权限（删除）
INSERT INTO sys_menu VALUES (
    (SELECT max(menu_id) + 1 FROM sys_menu),
    '{实体中文名}删除',
    {父菜单ID},
    4,
    '',
    '',
    '',
    '',
    1,
    0,
    'F',
    '0',
    '0',
    '{模块名}:{对象名}:remove',
    '#',
    'admin',
    NOW(),
    '',
    NULL,
    ''
);

-- 功能按钮权限（导出）
INSERT INTO sys_menu VALUES (
    (SELECT max(menu_id) + 1 FROM sys_menu),
    '{实体中文名}导出',
    {父菜单ID},
    5,
    '',
    '',
    '',
    '',
    1,
    0,
    'F',
    '0',
    '0',
    '{模块名}:{对象名}:export',
    '#',
    'admin',
    NOW(),
    '',
    NULL,
    ''
);

-- 功能按钮权限（查看详情）- 新增
INSERT INTO sys_menu VALUES (
    (SELECT max(menu_id) + 1 FROM sys_menu),
    '{实体中文名}查看详情',
    {父菜单ID},
    6,
    '',
    '',
    '',
    '',
    1,
    0,
    'F',
    '0',
    '0',
    '{模块名}:{对象名}:detail',
    '#',
    'admin',
    NOW(),
    '',
    NULL,
    ''
);
```

### 阶段三：后端代码智能生成

#### 1. 实体类（Domain）- 使用 Lombok 注解

**文件位置：** `src/main/java/com/ruoyi/project/{模块名}/domain/{实体类名}.java`

```java
package com.ruoyi.project.{模块名}.domain;

import com.ruoyi.common.constant.UserConstants;
import com.ruoyi.framework.aspectj.lang.annotation.Excel;
import com.ruoyi.framework.aspectj.lang.annotation.Excel.ColumnType;
import com.ruoyi.framework.web.domain.BaseEntity;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.experimental.Accessors;

import javax.validation.constraints.NotBlank;
import javax.validation.constraints.NotNull;
import javax.validation.constraints.Size;

/**
 * {实体中文名}对象 {实体类名}
 *
 * @author HRuinger
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Accessors(chain = true)
@EqualsAndHashCode(callSuper = true)
@ToString(callSuper = true)
public class {实体类名} extends BaseEntity
{
    private static final long serialVersionUID = 1L;

    /** {主键注释} */
    @Excel(name = "{主键中文名}", cellType = ColumnType.NUMERIC)
    private Long {主键名};

    /** {字段1注释} */
    @Excel(name = "{字段1中文名}")
    @NotBlank(message = "{字段1中文名}不能为空")
    @Size(min = 0, max = 64, message = "{字段1中文名}长度不能超过64个字符")
    private String {字段1名};

    /** {字段2注释} */
    @Excel(name = "{字段2中文名}")
    private String {字段2名};

    /** 状态 */
    @Excel(name = "状态", readConverterExp = "0=正常,1=停用")
    private String status;
}
```

**Lombok 注解说明：**

| 注解 | 说明 | 功能 |
|-----|------|------|
| `@Data` | 生成 getter、setter、toString、equals、hashCode | 自动生成常用方法 |
| `@Builder` | 支持链式构建 | 便于对象构建 |
| `@NoArgsConstructor` | 生成无参构造函数 | 用于序列化和框架要求 |
| `@AllArgsConstructor` | 生成全参构造函数 | 便于对象初始化 |
| `@Accessors(chain = true)` | Setter 方法返回 this，支持链式调用 | 便于对象属性设置链式调用 |
| `@EqualsAndHashCode(callSuper = true)` | 生成 equals 和 hashCode，包含父类 | 正确的继承关系处理 |
| `@ToString(callSuper = true)` | 生成 toString，包含父类 | 正确的继承关系处理 |

**智能导入说明：**
- Lombok 注解：`lombok.*`（包括 `lombok.experimental.*`）
- 验证注解：`javax.validation.constraints.*`
- 框架注解：`com.ruoyi.*`
- 继承类：`com.ruoyi.framework.web.domain.BaseEntity`

**Lombok 依赖要求：**
```xml
<dependency>
    <groupId>org.projectlombok</groupId>
    <artifactId>lombok</artifactId>
    <version>1.18.30</version>
    <scope>provided</scope>
</dependency>
```

**使用示例：**
```java
// 链式构建
{实体类名} {实体类名小写} = {实体类名}.builder()
    .{字段1名}("{字段1值}")
    .{字段2名}("{字段2值}")
    .status("0")
    .build();

// Setter 调用（支持链式调用）
{实体类名小写}
    .set{字段1名}("{新值}")
    .set{字段2名}("{新值}")
    .setStatus("1");

// Getter 调用
String {字段1值} = {实体类名小写}.get{字段1名}();
```

#### 2. Mapper 接口 - 完整 CRUD

**文件位置：** `src/main/java/com/ruoyi/project/{模块名}/mapper/{实体类名}Mapper.java`

```java
package com.ruoyi.project.{模块名}.mapper;

import com.ruoyi.project.{模块名}.domain.{实体类名};
import org.apache.ibatis.annotations.Mapper;

import java.util.List;

/**
 * {实体中文名}Mapper接口
 *
 * @author HRuinger
 */
@Mapper
public interface {实体类名}Mapper
{
    /**
     * 查询{实体中文名}
     *
     * @param {主键名} {实体中文名}主键
     * @return {实体中文名}
     */
    public {实体类名} select{实体类名}ById(Long {主键名});

    /**
     * 查询{实体中文名}列表
     *
     * @param {实体类名小写} {实体中文名}
     * @return {实体中文名}集合
     */
    public List<{实体类名}> select{实体类名}List({实体类名} {实体类名小写});

    /**
     * 新增{实体中文名}
     *
     * @param {实体类名小写} {实体中文名}
     * @return 结果
     */
    public int insert{实体类名}({实体类名} {实体类名小写});

    /**
     * 修改{实体中文名}
     *
     * @param {实体类名小写} {实体中文名}
     * @return 结果
     */
    public int update{实体类名}({实体类名} {实体类名小写});

    /**
     * 删除{实体中文名}
     *
     * @param {主键名} {实体中文名}主键
     * @return 结果
     */
    public int delete{实体类名}ById(Long {主键名});

    /**
     * 批量删除{实体中文名}
     *
     * @param {主键名}s 需要删除的数据主键集合
     * @return 结果
     */
    public int delete{实体类名}ByIds(Long[] {主键名}s);
}
```

**智能导入说明：**
- `@Mapper` 注解来自 `org.apache.ibatis.annotations.Mapper`
- `List` 来自 `java.util.List`

#### 3. Mapper XML - 自动生成

**文件位置：** `src/main/resources/mapper/{模块名}/{实体类名}Mapper.xml`

```xml
<?xml version="1.0" encoding="UTF-8" ?>
<!DOCTYPE mapper
PUBLIC "-//mybatis.org//DTD Mapper 3.0//EN"
"http://mybatis.org/dtd/mybatis-3-mapper.dtd">
<mapper namespace="com.ruoyi.project.{模块名}.mapper.{实体类名}Mapper">

    <resultMap type="{实体类名}" id="{实体类名小写}Result">
        <result property="{主键名}"    column="{主键名}"    />
        <result property="{字段1名}"    column="{字段1名}"    />
        <result property="{字段2名}"    column="{字段2名}"    />
        <result property="status"       column="status"       />
        <result property="delFlag"     column="del_flag"     />
        <result property="createBy"    column="create_by"    />
        <result property="createTime"  column="create_time"  />
        <result property="updateBy"    column="update_by"    />
        <result property="updateTime"  column="update_time"  />
        <result property="remark"      column="remark"       />
    </resultMap>

    <sql id="select{实体类名}Vo">
        select {主键名}, {字段1名}, {字段2名}, status, del_flag, create_by, create_time, update_by, update_time, remark
        from {模块名}_{表名}
    </sql>

    <select id="select{实体类名}List" parameterType="{实体类名}" resultMap="{实体类名小写}Result">
        <include refid="select{实体类名}Vo"/>
        <where>
            del_flag = '0'
            <if test="{字段1名} != null and {字段1名} != ''">
                AND {字段1名} like concat('%', #{字段1名}, '%')
            </if>
            <if test="{字段2名} != null and {字段2名} != ''">
                AND {字段2名} like concat('%', #{字段2名}, '%')
            </if>
            <if test="status != null and status != ''">
                AND status = #{status}
            </if>
        </where>
    </select>

    <select id="select{实体类名}ById" parameterType="Long" resultMap="{实体类名小写}Result">
        <include refid="select{实体类名}Vo"/>
        where {主键名} = #{主键名}
    </select>

    <insert id="insert{实体类名}" parameterType="{实体类名}" useGeneratedKeys="true" keyProperty="{主键名}">
        insert into {模块名}_{表名}
        <trim prefix="(" suffix=")" suffixOverrides=",">
            <if test="{字段1名} != null and {字段1名} != ''">{字段1名},</if>
            <if test="{字段2名} != null and {字段2名} != ''">{字段2名},</if>
            <if test="status != null and status != ''">status,</if>
            <if test="remark != null and remark != ''">remark,</if>
            <if test="createBy != null and createBy != ''">create_by,</if>
            create_time
        </trim>
        <trim prefix="values (" suffix=")" suffixOverrides=",">
            <if test="{字段1名} != null and {字段1名} != ''">#{字段1名},</if>
            <if test="{字段2名} != null and {字段2名} != ''">#{字段2名},</if>
            <if test="status != null and status != ''">#{status},</if>
            <if test="remark != null and remark != ''">#{remark},</if>
            <if test="createBy != null and createBy != ''">#{createBy},</if>
            sysdate()
        </trim>
    </insert>

    <update id="update{实体类名}" parameterType="{实体类名}">
        update {模块名}_{表名}
        <trim prefix="SET" suffixOverrides=",">
            <if test="{字段1名} != null and {字段1名} != ''">{字段1名} = #{字段1名},</if>
            <if test="{字段2名} != null and {字段2名} != ''">{字段2名} = #{字段2名},</if>
            <if test="status != null and status != ''">status = #{status},</if>
            <if test="remark != null and remark != ''">remark = #{remark},</if>
            <if test="updateBy != null and updateBy != ''">update_by = #{updateBy},</if>
            update_time = sysdate()
        </trim>
        where {主键名} = #{主键名}
    </update>

    <delete id="delete{实体类名}ById" parameterType="Long">
        update {模块名}_{表名} set del_flag = '2' where {主键名} = #{主键名}
    </delete>

    <delete id="delete{实体类名}ByIds" parameterType="String">
        update {模块名}_{表名} set del_flag = '2' where {主键名} in
        <foreach item="{主键名}" collection="array" open="(" separator="," close=")">
            #{主键名}
        </foreach>
    </delete>

</mapper>
```

#### 4. Service 接口

**文件位置：** `src/main/java/com/ruoyi/project/{模块名}/service/I{实体类名}Service.java`

```java
package com.ruoyi.project.{模块名}.service;

import com.ruoyi.project.{模块名}.domain.{实体类名};

import java.util.List;

/**
 * {实体中文名}Service接口
 *
 * @author HRuinger
 */
public interface I{实体类名}Service
{
    /**
     * 查询{实体中文名}
     *
     * @param {主键名} {实体中文名}主键
     * @return {实体中文名}
     */
    public {实体类名} select{实体类名}ById(Long {主键名});

    /**
     * 查询{实体中文名}列表
     *
     * @param {实体类名小写} {实体中文名}
     * @return {实体中文名}集合
     */
    public List<{实体类名}> select{实体类名}List({实体类名} {实体类名小写});

    /**
     * 新增{实体中文名}
     *
     * @param {实体类名小写} {实体中文名}
     * @return 结果
     */
    public int insert{实体类名}({实体类名} {实体类名小写});

    /**
     * 修改{实体中文名}
     *
     * @param {实体类名小写} {实体中文名}
     * @return 结果
     */
    public int update{实体类名}({实体类名} {实体类名小写});

    /**
     * 批量删除{实体中文名}
     *
     * @param {主键名}s 需要删除的{实体中文名}主键
     * @return 结果
     */
    public int delete{实体类名}ByIds(Long[] {主键名}s);

    /**
     * 删除{实体中文名}信息
     *
     * @param {主键名} {实体中文名}主键
     * @return 结果
     */
    public int delete{实体类名}ById(Long {主键名});
}
```

**智能导入说明：**
- `List` 来自 `java.util.List`
- 业务实体来自当前模块包

#### 5. Service 实现类 - 完整实现（带日志和时间统计）

**文件位置：** `src/main/java/com/ruoyi/project/{模块名}/service/impl/{实体类名}ServiceImpl.java`

```java
package com.ruoyi.project.{模块名}.service.impl;

import cn.hutool.json.JSONUtil;
import com.ruoyi.project.{模块名}.domain.{实体类名};
import com.ruoyi.project.{模块名}.mapper.{实体类名}Mapper;
import com.ruoyi.project.{模块名}.service.I{实体类名}Service;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

/**
 * {实体中文名}Service业务层处理
 *
 * @author HRuinger
 */
@Slf4j
@Service
public class {实体类名}ServiceImpl implements I{实体类名}Service
{
    @Autowired
    private {实体类名}Mapper {实体类名小写}Mapper;

    /**
     * 查询{实体中文名}
     *
     * @param {主键名} {实体中文名}主键
     * @return {实体中文名}
     */
    @Override
    public {实体类名} select{实体类名}ById(Long {主键名})
    {
        long startTime = System.currentTimeMillis();
        log.info("请求开始 - select{实体类名}ById，时间：{}，主键：{}", new java.util.Date(), {主键名});
        {实体类名} result = {实体类名小写}Mapper.select{实体类名}ById({主键名});
        long endTime = System.currentTimeMillis();
        long costTime = endTime - startTime;
        log.info("请求结束 - select{实体类名}ById，时间：{}，结果：{}，耗时：{}ms", new java.util.Date(), result, costTime);
        return result;
    }

    /**
     * 查询{实体中文名}列表
     *
     * @param {实体类名小写} {实体中文名}
     * @return {实体中文名}
     */
    @Override
    public List<{实体类名}> select{实体类名}List({实体类名} {实体类名小写})
    {
        long startTime = System.currentTimeMillis();
        log.info("请求开始 - select{实体类名}List，时间：{}，查询条件：{}", new java.util.Date(), JSONUtil.toJsonStr({实体类名小写}));
        List<{实体类名}> list = {实体类名小写}Mapper.select{实体类名}List({实体类名小写});
        long endTime = System.currentTimeMillis();
        long costTime = endTime - startTime;
        log.info("请求结束 - select{实体类名}List，时间：{}，结果数量：{}，耗时：{}ms", new java.util.Date(), list != null ? list.size() : 0, costTime);
        return list;
    }

    /**
     * 新增{实体中文名}
     *
     * @param {实体类名小写} {实体中文名}
     * @return 结果
     */
    @Override
    public int insert{实体类名}({实体类名} {实体类名小写})
    {
        long startTime = System.currentTimeMillis();
        log.info("请求开始 - insert{实体类名}，时间：{}，数据：{}", new java.util.Date(), JSONUtil.toJsonStr({实体类名小写}));
        int result = {实体类名小写}Mapper.insert{实体类名}({实体类名小写});
        long endTime = System.currentTimeMillis();
        long costTime = endTime - startTime;
        log.info("请求结束 - insert{实体类名}，时间：{}，影响行数：{}，耗时：{}ms", new java.util.Date(), result, costTime);
        return result;
    }

    /**
     * 修改{实体中文名}
     *
     * @param {实体类名小写} {实体中文名}
     * @return 结果
     */
    @Override
    public int update{实体类名}({实体类名} {实体类名小写})
    {
        long startTime = System.currentTimeMillis();
        log.info("请求开始 - update{实体类名}，时间：{}，数据：{}", new java.util.Date(), JSONUtil.toJsonStr({实体类名小写}));
        int result = {实体类名小写}Mapper.update{实体类名}({实体类名小写});
        long endTime = System.currentTimeMillis();
        long costTime = endTime - startTime;
        log.info("请求结束 - update{实体类名}，时间：{}，影响行数：{}，耗时：{}ms", new java.util.Date(), result, costTime);
        return result;
    }

    /**
     * 批量删除{实体中文名}
     *
     * @param {主键名}s 需要删除的{实体中文名}主键
     * @return 结果
     */
    @Override
    public int delete{实体类名}ByIds(Long[] {主键名}s)
    {
        long startTime = System.currentTimeMillis();
        log.info("请求开始 - delete{实体类名}ByIds，时间：{}，主键数组：{}", new java.util.Date(), {主键名}s);
        int result = {实体类名小写}Mapper.delete{实体类名}ByIds({主键名}s);
        long endTime = System.currentTimeMillis();
        long costTime = endTime - startTime;
        log.info("请求结束 - delete{实体类名}ByIds，时间：{}，影响行数：{}，耗时：{}ms", new java.util.Date(), result, costTime);
        return result;
    }

    /**
     * 删除{实体中文名}信息
     *
     * @param {主键名} {实体中文名}主键
     * @return 结果
     */
    @Override
    public int delete{实体类名}ById(Long {主键名})
    {
        long startTime = System.currentTimeMillis();
        log.info("请求开始 - delete{实体类名}ById，时间：{}，主键：{}", new java.util.Date(), {主键名});
        int result = {实体类名小写}Mapper.delete{实体类名}ById({主键名});
        long endTime = System.currentTimeMillis();
        long costTime = endTime - startTime;
        log.info("请求结束 - delete{实体类名}ById，时间：{}，影响行数：{}，耗时：{}ms", new java.util.Date(), result, costTime);
        return result;
    }
}
```

**智能导入说明：**
- `@Slf4j` 来自 `lombok.extern.slf4j.Slf4j`（用于日志打印）
- `@Service` 来自 `org.springframework.stereotype.Service`
- `@Autowired` 来自 `org.springframework.beans.factory.annotation.Autowired`
- `@Override` 来自 `java.lang.Override`（默认导入）
- `JSONUtil` 来自 `cn.hutool.json.JSONUtil`（用于对象转JSON）

**Hutool 依赖检查：**

生成的代码中会使用 Hutool 的 JSONUtil 工具类，需要确保项目中已引入 Hutool 依赖：

```xml
<!-- pom.xml 中添加 Hutool 依赖 -->
<dependency>
    <groupId>cn.hutool</groupId>
    <artifactId>hutool-all</artifactId>
    <version>5.8.23</version>
</dependency>
```

**检查方法：**
在生成代码前，自动检查项目的 `pom.xml` 文件中是否包含 hutool 依赖：
- 如果已包含，直接使用
- 如果未包含，自动添加上述依赖到 `pom.xml`

**@Slf4j 注解说明：**

`@Slf4j` 是 Lombok 提供的日志注解，它会自动生成以下代码：

```java
private static final Logger log = LoggerFactory.getLogger({实体类名}ServiceImpl.class);
```

**日志级别说明：**

| 级别 | 说明 | 使用场景 |
|-----|------|---------|
| `log.trace()` | 跟踪信息 | 最详细的调试信息 |
| `log.debug()` | 调试信息 | 开发调试阶段使用 |
| `log.info()` | 信息 | 重要业务流程（推荐用于请求开始和结束） |
| `log.warn()` | 警告 | 潜在问题 |
| `log.error()` | 错误 | 异常和错误 |

**日志打印最佳实践：**

1. **请求开始日志**：记录方法调用参数和开始时间
   ```java
   long startTime = System.currentTimeMillis();
   log.info("请求开始 - select{实体类名}ById，时间：{}，主键：{}", new java.util.Date(), {主键名});
   ```

2. **实体参数日志**：使用 JSONUtil.toJsonStr() 打印实体对象
   ```java
   long startTime = System.currentTimeMillis();
   log.info("请求开始 - insert{实体类名}，时间：{}，数据：{}", new java.util.Date(), JSONUtil.toJsonStr({实体类名小写}));
   ```

3. **请求结束日志**：记录方法执行结果、结束时间和耗时
   ```java
   long endTime = System.currentTimeMillis();
   long costTime = endTime - startTime;
   log.info("请求结束 - insert{实体类名}，时间：{}，影响行数：{}，耗时：{}ms", new java.util.Date(), result, costTime);
   ```

4. **异常处理日志**：记录异常信息
   ```java
   try {
       long startTime = System.currentTimeMillis();
       log.info("请求开始 - {方法名}，时间：{}，参数：{}", new java.util.Date(), JSONUtil.toJsonStr(params));
       // 业务逻辑
       long endTime = System.currentTimeMillis();
       log.info("请求结束 - {方法名}，时间：{}，耗时：{}ms", new java.util.Date(), endTime - startTime);
   } catch (Exception e) {
       log.error("操作{实体中文名}失败", e);
       throw new RuntimeException("操作失败", e);
   }
   ```

5. **使用占位符**：避免字符串拼接
   ```java
   // 推荐
   log.info("查询{实体中文名}，主键：{}", {主键名});

   // 不推荐（性能差）
   log.info("查询{实体中文名}，主键：" + {主键名});
   ```

6. **时间记录规范**：
   - 使用 `System.currentTimeMillis()` 记录时间戳
   - 使用 `new java.util.Date()` 打印可读时间
   - 计算耗时：`long costTime = endTime - startTime;`
   - 耗时单位：毫秒（ms）

**日志格式规范：**

所有业务方法统一使用以下日志格式：

**请求开始格式：**
```
请求开始 - {方法名}，时间：{Date}，{参数名}：{参数值}
```

**请求结束格式：**
```
请求结束 - {方法名}，时间：{Date}，结果描述：{结果}，耗时：{耗时}ms
```

**Lombok 日志依赖要求：**

`@Slf4j` 注解需要 Lombok 依赖（已在实体类部分说明），同时需要日志框架依赖（通常 Spring Boot 自带）。

常用的日志框架包括：
- Slf4j + Logback（Spring Boot 默认）
- Slf4j + Log4j2
- Slf4j + Log4j

#### 6. Controller - 包含详情页面

**文件位置：** `src/main/java/com/ruoyi/project/{模块名}/controller/{实体类名}Controller.java`

```java
package com.ruoyi.project.{模块名}.controller;

import com.ruoyi.common.annotation.Log;
import com.ruoyi.common.core.controller.BaseController;
import com.ruoyi.common.core.domain.AjaxResult;
import com.ruoyi.common.core.page.TableDataInfo;
import com.ruoyi.common.enums.BusinessType;
import com.ruoyi.common.utils.poi.ExcelUtil;
import com.ruoyi.project.{模块名}.domain.{实体类名};
import com.ruoyi.project.{模块名}.service.I{实体类名}Service;
import org.apache.shiro.authz.annotation.RequiresPermissions;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.ModelMap;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import javax.servlet.http.HttpServletResponse;
import java.util.List;

/**
 * {实体中文名}Controller
 *
 * @author HRuinger
 */
@Controller
@RequestMapping("/{模块名}/{对象名}")
public class {实体类名}Controller extends BaseController
{
    private String prefix = "{模块名}/{对象名}";

    @Autowired
    private I{实体类名}Service {实体类名小写}Service;

    /**
     * 跳转{实体中文名}列表页面
     */
    @RequiresPermissions("{模块名}:{对象名}:list")
    @GetMapping()
    public String {对象名}()
    {
        return prefix + "/{对象名}";
    }

    /**
     * 查询{实体中文名}列表
     */
    @RequiresPermissions("{模块名}:{对象名}:list")
    @PostMapping("/list")
    @ResponseBody
    public TableDataInfo list({实体类名} {实体类名小写})
    {
        startPage();
        List<{实体类名}> list = {实体类名小写}Service.select{实体类名}List({实体类名小写});
        return getDataTable(list);
    }

    /**
     * 导出{实体中文名}列表
     */
    @RequiresPermissions("{模块名}:{对象名}:export")
    @Log(title = "{实体中文名}", businessType = BusinessType.EXPORT)
    @PostMapping("/export")
    @ResponseBody
    public AjaxResult export({实体类名} {实体类名小写})
    {
        List<{实体类名}> list = {实体类名小写}Service.select{实体类名}List({实体类名小写});
        ExcelUtil<{实体类名}> util = new ExcelUtil<{实体类名}>({实体类名}.class);
        return util.exportExcel(list, "{实体中文名}数据");
    }

    /**
     * 新增{实体中文名}
     */
    @GetMapping("/add")
    public String add()
    {
        return prefix + "/add";
    }

    /**
     * 新增保存{实体中文名}
     */
    @RequiresPermissions("{模块名}:{对象名}:add")
    @Log(title = "{实体中文名}", businessType = BusinessType.INSERT)
    @PostMapping("/add")
    @ResponseBody
    public AjaxResult addSave(@Validated {实体类名} {实体类名小写})
    {
        return toAjax({实体类名小写}Service.insert{实体类名}({实体类名小写}));
    }

    /**
     * 修改{实体中文名}
     */
    @RequiresPermissions("{模块名}:{对象名}:edit")
    @GetMapping("/edit/{{主键名}}")
    public String edit(@PathVariable("{主键名}") Long {主键名}, ModelMap mmap)
    {
        mmap.put("{对象名}", {实体类名小写}Service.select{实体类名}ById({主键名}));
        return prefix + "/edit";
    }

    /**
     * 修改保存{实体中文名}
     */
    @RequiresPermissions("{模块名}:{对象名}:edit")
    @Log(title = "{实体中文名}", businessType = BusinessType.UPDATE)
    @PostMapping("/edit")
    @ResponseBody
    public AjaxResult editSave(@Validated {实体类名} {实体类名小写})
    {
        return toAjax({实体类名小写}Service.update{实体类名}({实体类名小写}));
    }

    /**
     * 查看{实体中文名}详情
     */
    @RequiresPermissions("{模块名}:{对象名}:detail")
    @GetMapping("/view/{{主键名}}")
    public String view(@PathVariable("{主键名}") Long {主键名}, ModelMap mmap)
    {
        mmap.put("{对象名}", {实体类名小写}Service.select{实体类名}ById({主键名}));
        return prefix + "/view";
    }

    /**
     * 删除{实体中文名}
     */
    @RequiresPermissions("{模块名}:{对象名}:remove")
    @Log(title = "{实体中文名}", businessType = BusinessType.DELETE)
    @PostMapping("/remove")
    @ResponseBody
    public AjaxResult remove(String ids)
    {
        return toAjax({实体类名小写}Service.delete{实体类名}ByIds(ids.split(",")));
    }
}
```

**智能导入说明：**
- 所有注解的完整导入路径
- 根据使用的类自动导入相应的包
- 确保所有导入语句完整且正确

### 阶段四：前端代码智能生成

#### 1. 列表页面（{对象名}.html）- 包含详情功能

**文件位置：** `src/main/resources/templates/{模块名}/{对象名}.html`

```html
<!DOCTYPE html>
<html lang="zh" xmlns:th="http://www.thymeleaf.org">
<head>
    <th:block th:include="include :: header('{实体中文名}')" />
</head>
<body class="gray-bg">
    <div class="container-div">
        <div class="row">
            <div class="col-sm-12 search-collapse">
                <form id="searchForm" class="form-inline">
                    <div class="select-list">
                        <ul>
                            <li>
                                <label class="control-label">{字段1中文名}：</label>
                                <input type="text" name="{字段1名}" class="form-control" placeholder="请输入{字段1中文名}" />
                            </li>
                            <li>
                                <label class="control-label">状态：</label>
                                <select name="status" th:with="type=${@dict.getType('{模块}_{状态字段}')}" class="form-control m-b">
                                    <option value="">所有</option>
                                    <option th:each="dict : ${type}" th:text="${dict.dictLabel}" th:value="${dict.dictValue}"></option>
                                </select>
                            </li>
                            <li>
                                <a class="btn btn-primary btn-rounded btn-sm" onclick="$.table.search()"><i class="fa fa-search"></i>&nbsp;搜索</a>
                                <a class="btn btn-warning btn-rounded btn-sm" onclick="$.table.reset()"><i class="fa fa-refresh"></i>&nbsp;重置</a>
                            </li>
                        </ul>
                    </div>
                </form>
            </div>

            <div class="btn-group-sm" id="toolbar" role="group">
                <a class="btn btn-success" onclick="$.operate.add()" shiro:hasPermission="{模块名}:{对象名}:add">
                    <i class="fa fa-plus"></i> 新增
                </a>
                <a class="btn btn-primary" onclick="$.operate.edit()" shiro:hasPermission="{模块名}:{对象名}:edit">
                    <i class="fa fa-edit"></i> 修改
                </a>
                <a class="btn btn-success" onclick="$.operate.view()" shiro:hasPermission="{模块名}:{对象名}:detail">
                    <i class="fa fa-search"></i> 详情
                </a>
                <a class="btn btn-danger" onclick="$.operate.removeAll()" shiro:hasPermission="{模块名}:{对象名}:remove">
                    <i class="fa fa-remove"></i> 删除
                </a>
                <a class="btn btn-warning" onclick="$.table.exportExcel()" shiro:hasPermission="{模块名}:{对象名}:export">
                    <i class="fa fa-download"></i> 导出
                </a>
            </div>

            <div class="col-sm-12 select-table table-striped">
                <table id="bootstrap-table" data-mobile-responsive="true"></table>
            </div>
        </div>
    </div>
    <th:block th:include="include :: footer" />
    <script th:inline="javascript">
        var prefix = ctx + "/{模块名}/{对象名}";
        var datas = [[${@dict.getType('{模块}_{状态字段}')}]];
        var detailFlag = [[${@permission.hasPermi('{模块名}:{对象名}:detail')}]];
        var editFlag = [[${@permission.hasPermi('{模块名}:{对象名}:edit')}]];
        var removeFlag = [[${@permission.hasPermi('{模块名}:{对象名}:remove')}]];

        $(function() {
            var options = {
                url: prefix + "/list",
                createUrl: prefix + "/add",
                updateUrl: prefix + "/edit/{id}",
                viewUrl: prefix + "/view/{id}",
                removeUrl: prefix + "/remove",
                exportUrl: prefix + "/export",
                modalName: "{实体中文名}",
                columns: [
                    [
                        {checkbox: true},
                        {field: '{主键名}', title: '{主键中文名}', visible: false, align: 'center', valign: 'middle', sortable: true},
                        {field: '{字段1名}', title: '{字段1中文名}', align: 'center', valign: 'middle', sortable: true},
                        {field: '{字段2名}', title: '{字段2中文名}', align: 'center', valign: 'middle', sortable: true},
                        {field: 'status', title: '状态', align: 'center', valign: 'middle', sortable: true, formatter: function(value, row, index) {
                            return $.table.selectDictLabel(datas, value);
                        }},
                        {field: 'createTime', title: '创建时间', align: 'center', valign: 'middle', sortable: true},
                        {field: 'remark', title: '备注', align: 'center', valign: 'middle', sortable: true, visible: false},
                        {title: '操作', align: 'center', valign: 'middle', formatter: function(value, row, index) {
                            var actions = [];
                            actions.push('<a class="btn btn-info btn-xs ' + detailFlag + '" href="javascript:void(0)" onclick="$.operate.view(\'' + row.{主键名} + '\')"><i class="fa fa-search"></i>详情</a> ');
                            actions.push('<a class="btn btn-success btn-xs ' + editFlag + '" href="javascript:void(0)" onclick="$.operate.edit(\'' + row.{主键名} + '\')"><i class="fa fa-edit"></i>编辑</a> ');
                            actions.push('<a class="btn btn-danger btn-xs ' + removeFlag + '" href="javascript:void(0)" onclick="$.operate.remove(\'' + row.{主键名} + '\')"><i class="fa fa-remove"></i>删除</a>');
                            return actions.join('');
                        }}
                    ]
                ]
            };
            $.table.init(options);
        });
    </script>
</body>
</html>
```

#### 2. 新增页面（add.html）

**文件位置：** `src/main/resources/templates/{模块名}/add.html`

```html
<!DOCTYPE html>
<html lang="zh" xmlns:th="http://www.thymeleaf.org">
<head>
    <th:block th:include="include :: header('新增{实体中文名}')" />
</head>
<body class="white-bg">
    <div class="wrapper wrapper-content animated fadeInRight ibox-content">
        <form class="form-horizontal m" id="form-{对象名}-add" th:object="${{对象名}}">
            <div class="form-group">
                <label class="col-sm-3 control-label">{字段1中文名}：</label>
                <div class="col-sm-8">
                    <input name="{字段1名}" th:field="*{{字段1名}}" class="form-control" type="text" required>
                </div>
            </div>
            <div class="form-group">
                <label class="col-sm-3 control-label">{字段2中文名}：</label>
                <div class="col-sm-8">
                    <input name="{字段2名}" th:field="*{{字段2名}}" class="form-control" type="text">
                </div>
            </div>
            <div class="form-group">
                <label class="col-sm-3 control-label">状态：</label>
                <div class="col-sm-8">
                    <div class="radio-box">
                        <input type="radio" name="status" th:field="*{{status}}" value="0" checked="checked">
                        <label>正常</label>
                    </div>
                    <div class="radio-box">
                        <input type="radio" name="status" th:field="*{{status}}" value="1">
                        <label>停用</label>
                    </div>
                </div>
            </div>
            <div class="form-group">
                <label class="col-sm-3 control-label">备注：</label>
                <div class="col-sm-8">
                    <textarea name="remark" th:field="*{{remark}}" class="form-control" type="text"></textarea>
                </div>
            </div>
        </form>
    </div>
    <th:block th:include="include :: footer" />
    <script th:inline="javascript">
        var prefix = ctx + "/{模块名}/{对象名}";

        $(function() {
            $.validator.setDefaults({
                submitHandler: function(form) {
                    $.operate.save(prefix + "/add", $(form).serialize());
                }
            });
            $("#form-{对象名}-add").validate();
        });
    </script>
</body>
</html>
```

#### 3. 编辑页面（edit.html）

**文件位置：** `src/main/resources/templates/{模块名}/edit.html`

```html
<!DOCTYPE html>
<html lang="zh" xmlns:th="http://www.thymeleaf.org">
<head>
    <th:block th:include="include :: header('修改{实体中文名}')" />
</head>
<body class="white-bg">
    <div class="wrapper wrapper-content animated fadeInRight ibox-content">
        <form class="form-horizontal m" id="form-{对象名}-edit" th:object="${{对象名}}">
            <input name="{主键名}" th:field="*{{主键名}}" type="hidden">
            <div class="form-group">
                <label class="col-sm-3 control-label">{字段1中文名}：</label>
                <div class="col-sm-8">
                    <input name="{字段1名}" th:field="*{{字段1名}}" class="form-control" type="text" required>
                </div>
            </div>
            <div class="form-group">
                <label class="col-sm-3 control-label">{字段2中文名}：</label>
                <div class="col-sm-8">
                    <input name="{字段2名}" th:field="*{{字段2名}}" class="form-control" type="text">
                </div>
            </div>
            <div class="form-group">
                <label class="col-sm-3 control-label">状态：</label>
                <div class="col-sm-8">
                    <div class="radio-box">
                        <input type="radio" name="status" th:field="*{{status}}" value="0">
                        <label>正常</label>
                    </div>
                    <div class="radio-box">
                        <input type="radio" name="status" th:field="*{{status}}" value="1">
                        <label>停用</label>
                    </div>
                </div>
            </div>
            <div class="form-group">
                <label class="col-sm-3 control-label">备注：</label>
                <div class="col-sm-8">
                    <textarea name="remark" th:field="*{{remark}}" class="form-control" type="text"></textarea>
                </div>
            </div>
        </form>
    </div>
    <th:block th:include="include :: footer" />
    <script th:inline="javascript">
        var prefix = ctx + "/{模块名}/{对象名}";

        $(function() {
            $.validator.setDefaults({
                submitHandler: function(form) {
                    $.operate.save(prefix + "/edit", $(form).serialize());
                }
            });
            $("#form-{对象名}-edit").validate();
        });
    </script>
</body>
</html>
```

#### 4. 详情页面（view.html）- 新增

**文件位置：** `src/main/resources/templates/{模块名}/view.html`

```html
<!DOCTYPE html>
<html lang="zh" xmlns:th="http://www.thymeleaf.org">
<head>
    <th:block th:include="include :: header('{实体中文名}详情')" />
</head>
<body class="white-bg">
    <div class="wrapper wrapper-content animated fadeInRight ibox-content">
        <form class="form-horizontal m">
            <input name="{主键名}" th:value="${{对象名}.{主键名}}" type="hidden">
            <div class="form-group">
                <label class="col-sm-3 control-label is-required">{字段1中文名}：</label>
                <div class="col-sm-8">
                    <input class="form-control" type="text" name="{字段1名}" th:value="${{对象名}.{字段1名}}" readonly>
                </div>
            </div>
            <div class="form-group">
                <label class="col-sm-3 control-label">{字段2中文名}：</label>
                <div class="col-sm-8">
                    <input class="form-control" type="text" name="{字段2名}" th:value="${{对象名}.{字段2名}}" readonly>
                </div>
            </div>
            <div class="form-group">
                <label class="col-sm-3 control-label">状态：</label>
                <div class="col-sm-8">
                    <input class="form-control" type="text" name="status" th:value="${{{对象名}.status == '0'} ? '正常' : '停用'}" readonly>
                </div>
            </div>
            <div class="form-group">
                <label class="col-sm-3 control-label">备注：</label>
                <div class="col-sm-8">
                    <textarea class="form-control" name="remark" th:text="${{对象名}.remark}" readonly></textarea>
                </div>
            </div>
            <div class="form-group">
                <label class="col-sm-3 control-label">创建者：</label>
                <div class="col-sm-8">
                    <input class="form-control" type="text" name="createBy" th:value="${{对象名}.createBy}" readonly>
                </div>
            </div>
            <div class="form-group">
                <label class="col-sm-3 control-label">创建时间：</label>
                <div class="col-sm-8">
                    <input class="form-control" type="text" name="createTime" th:value="${{#dates.format({对象名}.createTime, 'yyyy-MM-dd HH:mm:ss')}}" readonly>
                </div>
            </div>
            <div class="form-group">
                <label class="col-sm-3 control-label">更新者：</label>
                <div class="col-sm-8">
                    <input class="form-control" type="text" name="updateBy" th:value="${{对象名}.updateBy}" readonly>
                </div>
            </div>
            <div class="form-group">
                <label class="col-sm-3 control-label">更新时间：</label>
                <div class="col-sm-8">
                    <input class="form-control" type="text" name="updateTime" th:value="${{#dates.format({对象名}.updateTime, 'yyyy-MM-dd HH:mm:ss')}}" readonly>
                </div>
            </div>
        </form>
        <div class="form-group">
            <div class="col-sm-offset-5 col-sm-10">
                <button type="button" class="btn btn-default" onclick="$.modal.close()">关闭</button>
            </div>
        </div>
    </div>
    <th:block th:include="include :: footer" />
</body>
</html>
```

## 智能依赖管理

### 自动导入规则

根据代码中使用的类型和注解，智能生成对应的导入语句：

#### 1. 注解导入
```java
// 验证注解
import javax.validation.constraints.NotBlank;
import javax.validation.constraints.NotNull;
import javax.validation.constraints.Size;

// 框架注解
import org.springframework.stereotype.Service;
import org.springframework.stereotype.Controller;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

// MyBatis 注解
import org.apache.ibatis.annotations.Mapper;

// Shiro 注解
import org.apache.shiro.authz.annotation.RequiresPermissions;

// RuoYi 注解
import com.ruoyi.common.annotation.Log;
import com.ruoyi.framework.aspectj.lang.annotation.Excel;
import com.ruoyi.framework.aspectj.lang.annotation.Excel.ColumnType;
```

#### 2. 类导入
```java
// 框架基础类
import com.ruoyi.common.core.controller.BaseController;
import com.ruoyi.common.core.domain.AjaxResult;
import com.ruoyi.common.core.page.TableDataInfo;
import com.ruoyi.common.enums.BusinessType;
import com.ruoyi.common.utils.poi.ExcelUtil;
import com.ruoyi.framework.web.domain.BaseEntity;

// Spring 框架类
import org.springframework.ui.ModelMap;

// Servlet API
import javax.servlet.http.HttpServletResponse;

// Java 集合和工具
import java.util.List;
import java.util.ArrayList;
import java.util.Date;
```

### 依赖检查清单

生成代码时，自动检查以下依赖是否存在：

- [ ] `javax.validation:validation-api`（验证注解）
- [ ] `org.springframework.boot:spring-boot-starter-web`（Spring Web）
- [ ] `org.mybatis.spring.boot:mybatis-spring-boot-starter`（MyBatis）
- [ ] `org.apache.shiro:shiro-spring-boot-web-starter`（Shiro）
- [ ] `cn.hutool:hutool-all`（Hutool 工具类，可选）

## 工具类智能使用

### Hutool 工具类优先级

本技能智能识别场景，优先使用 Hutool 工具类：

| 场景 | 推荐类 | 方法示例 |
|-----|--------|---------|
| 字符串判断 | `cn.hutool.core.util.StrUtil` | `isEmpty()`, `isNotEmpty()`, `isBlank()` |
| 日期处理 | `cn.hutool.core.date.DateUtil` | `date()`, `format()`, `parse()` |
| 集合操作 | `cn.hutool.core.collection.CollUtil` | `isEmpty()`, `isNotEmpty()`, `newArrayList()` |
| 对象操作 | `cn.hutool.core.bean.BeanUtil` | `copyProperties()`, `beanToMap()` |
| JSON 处理 | `cn.hutool.json.JSONUtil` | `toJsonStr()`, `parseObj()`, `toBean()` |

### RuoYi 特有工具类

对于 RuoYi 特定功能，自动使用 RuoYi 工具类：

```java
// 安全认证
import com.ruoyi.common.utils.SecurityUtils;
SecurityUtils.getUserId()
SecurityUtils.getUsername()
SecurityUtils.isAdmin()

// 字典工具
import com.ruoyi.common.utils.DictUtils;
DictUtils.getDictLabel()
DictUtils.getDictValue()
```

## 代码质量智能检查

### 自动检查项

1. **导入完整性**：确保所有使用的类都有对应的导入语句
2. **注解正确性**：确保注解使用正确，参数完整
3. **方法签名**：确保方法签名与接口一致
4. **命名规范**：遵循 RuoYi 命名规范
5. **代码格式**：统一的缩进、空行和注释

### 智能错误提示

生成代码时，自动检查并提示以下问题：

- 缺少的导入语句
- 不匹配的方法签名
- 缺少的必填注解
- 命名不规范的地方
- 潜在的空指针风险

## 使用示例

### 示例 1：生成产品管理模块

**用户输入：**
```
我需要一个产品管理模块，包含产品名称、价格、库存数量和状态字段
```

**AI 自动生成：**
1. 分析需求，识别实体：
   - 实体名：产品
   - 类名：Product
   - 表名：biz_product
   - 字段：name(名称)、price(价格)、stock(库存)、status(状态)

2. 生成数据库表 SQL（包括字典数据和菜单配置）

3. 生成后端代码：
   - Domain/Product.java（完整的 getter/setter、注解）
   - mapper/ProductMapper.java
   - mapper/ProductMapper.xml
   - service/IProductService.java
   - service/impl/ProductServiceImpl.java
   - controller/ProductController.java（包含详情方法）

4. 生成前端页面：
   - product/product.html（列表页，包含详情按钮）
   - product/add.html（新增页）
   - product/edit.html（编辑页）
   - product/view.html（详情页，新增）

### 示例 2：智能补全导入

**用户输入：**
```
生成订单管理的 Controller，需要导出 Excel 功能
```

**AI 自动生成：**
```java
// 自动识别并导入所需的所有类
package com.ruoyi.project.order.controller;

import com.ruoyi.common.annotation.Log;  // 自动导入
import com.ruoyi.common.core.controller.BaseController;  // 自动导入
import com.ruoyi.common.core.domain.AjaxResult;  // 自动导入
import com.ruoyi.common.core.page.TableDataInfo;  // 自动导入
import com.ruoyi.common.enums.BusinessType;  // 自动导入
import com.ruoyi.common.utils.poi.ExcelUtil;  // 自动导入（因为需要导出 Excel）
import com.ruoyi.project.order.domain.Order;  // 自动导入
import com.ruoyi.project.order.service.IOrderService;  // 自动导入
import org.apache.shiro.authz.annotation.RequiresPermissions;  // 自动导入
import org.springframework.beans.factory.annotation.Autowired;  // 自动导入
import org.springframework.stereotype.Controller;  // 自动导入
import org.springframework.ui.ModelMap;  // 自动导入
import org.springframework.validation.annotation.Validated;  // 自动导入
import org.springframework.web.bind.annotation.*;  // 自动导入

import javax.servlet.http.HttpServletResponse;  // 自动导入
import java.util.List;  // 自动导入

// ... 后续代码
```

## 与基础版本的对比

| 功能 | 基础版本 | 智能版本 |
|-----|---------|---------|
| 详情页面 | ❌ 不支持 | ✅ 完整支持 |
| 智能导入 | ❌ 需手动检查 | ✅ 自动补全 |
| 依赖分析 | ❌ 无 | ✅ 智能分析 |
| 字段类型映射 | ❌ 手动选择 | ✅ 自动推断 |
| 错误检查 | ❌ 无 | ✅ 自动检查 |
| 开发效率 | 中等 | 高 |

## 项目参考信息

- **项目地址**：https://gitcode.com/yangzongzhuan/RuoYi-fast.git
- **项目前端位置**：`RuoYi-fast/src/main/resources/templates/`
- **参考技能**：ruoyi-fast（基础版本）

## 技能使用说明

### 如何使用本技能

1. **描述需求**：向技能描述功能需求，包括功能模块、数据实体、字段信息等
2. **智能识别**：技能会自动识别实体名称、字段类型、模块信息等
3. **生成代码**：技能会自动生成完整的 SQL、后端代码、前端代码
4. **智能检查**：技能会自动检查导入语句、注解、方法签名等
5. **一键使用**：生成的代码可以直接使用，无需额外调整

### 使用技巧

1. **明确的字段描述**：在描述需求时，明确字段的类型（如：价格（小数）、数量（整数））
2. **模块命名**：明确模块名称，技能会自动生成对应的包路径和路由
3. **状态字段**：如果需要状态字段，技能会自动生成对应的字典数据
4. **详情需求**：技能会自动生成详情页面，无需特别说明

## 总结

本技能相比基础版本，更加智能和高效，能够：

1. **自动识别需求**：智能解析用户输入，自动识别实体、字段、模块信息
2. **智能类型推断**：根据字段名称和描述，自动推断字段类型和验证规则
3. **完整依赖管理**：自动分析代码依赖，智能补全导入语句
4. **完整功能支持**：包括详情页面在内的完整 CRUD 功能
5. **智能错误检查**：自动检查代码质量，提示潜在问题

使用本技能，开发者可以快速生成高质量的 RuoYi-fast 框架代码，大大提高开发效率。
