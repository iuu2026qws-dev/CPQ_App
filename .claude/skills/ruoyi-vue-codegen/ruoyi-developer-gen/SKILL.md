---
name: ruoyi-developer-gen
description: 专门用于 RuoYi-Vue 前后端分离开发，帮助将产品需求转化为可运行的后端和前端代码。当用户需要在 RuoYi-Vue 框架上进行新功能开发、功能优化或 Bug 修复时使用此技能。
---

# RuoYi-Vue 前后端开发技能

## ⛔ 强制：所有 CSS 必须用 Design Token

生成前端组件时，禁止硬编码任何 CSS 数值。必须引用 `dental-portal/src/styles/tokens.css` 中的变量：
- 圆角 → `var(--card-radius)` / `var(--radius-sm)` / `var(--radius-pill)`
- 间距 → `var(--space-4/8/12/16/24/32/48/64)`
- 颜色 → `var(--color-primary)` / `var(--bg-base)` / `var(--bg-surface)` / `var(--text-primary)`
- 阴影 → `var(--shadow-sm)` / `var(--shadow-md)` / `var(--shadow-brand)`
- 字号 → `var(--fs-body-md)` / `var(--fs-label-md)` / `var(--fs-heading-sm)`

内联 `style=""` 同样必须使用 `var(--*)`。

## 技能用途

本技能专门用于 RuoYi-Vue 框架的前后端分离开发，提供完整的开发流程指导，从需求分析到代码实现，包括数据库设计、后端开发、前端开发和菜单配置。

## 使用时机

当以下情况时使用此技能：
- 需要在 RuoYi-Vue 框架上开发新功能模块
- 需要创建新的业务实体和 CRUD 接口
- 需要配置系统菜单和权限
- 需要遵循 RuoYi 框架规范进行代码开发
- 需要生成数据库表和字典数据

## 开发规范

### 1. 技术栈
- 后端：Spring Boot 2.5.15 + MyBatis
- 前端：Vue 2.x + Element UI
- 数据库：MySQL
- 架构：前后端分离
- 工具类：Hutool（优先）+ Apache Commons + RuoYi 工具类

### 1.1 工具类使用规范

开发时必须遵循以下工具类使用优先级：

#### 1.1.1 字符串处理
**优先级：**
1. **Hutool StrUtil**（最高优先级）
   ```xml
   <!-- tmpcode-common/pom.xml 需要添加 -->
   <dependency>
       <groupId>cn.hutool</groupId>
       <artifactId>hutool-all</artifactId>
       <version>5.8.26</version>
   </dependency>
   ```
   ```java
   import cn.hutool.core.util.StrUtil;
   
   // 常用方法
   StrUtil.isEmpty()           // 判断空
   StrUtil.isNotEmpty()        // 判断非空
   StrUtil.isBlank()           // 判断空白
   StrUtil.isNotBlank()        // 判断非空白
   StrUtil.trim()              // 去空格
   StrUtil.format()            // 格式化
   StrUtil.toCamelCase()       // 下划线转驼峰
   StrUtil.toUnderLineCase()   // 驼峰转下划线
   StrUtil.isNull()            // 判断null
   StrUtil.isNotNull()         // 判断非null
   StrUtil.length()            // 获取长度
   StrUtil.sub()               // 截取
   StrUtil.split()             // 分割
   StrUtil.join()              // 连接
   StrUtil.startWith()          // 前缀判断
   StrUtil.endWith()            // 后缀判断
   ```

2. **RuoYi StringUtils**（Hutool 不满足时使用）
   ```java
   import com.tmpcode.common.utils.StringUtils;
   
   // 优先使用场景
   StringUtils.toCamelCase()       // 驼峰命名
   StringUtils.toUnderScoreCase()  // 下划线命名
   StringUtils.str2List()          // 字符串转List
   StringUtils.str2Set()           // 字符串转Set
   StringUtils.format()            // 格式化（{}占位符）
   StringUtils.inStringIgnoreCase() // 忽略大小写包含
   StringUtils.isMatch()          // Ant路径匹配
   ```

3. **Apache Commons Lang3**（备选）
   ```java
   import org.apache.commons.lang3.StringUtils;
   
   StringUtils.isEmpty()
   StringUtils.isNotEmpty()
   StringUtils.isBlank()
   StringUtils.isNotBlank()
   ```

#### 1.1.2 日期时间处理
**优先级：**
1. **Hutool DateUtil**（最高优先级）
   ```java
   import cn.hutool.core.date.DateUtil;
   import cn.hutool.core.date.DateTime;
   
   // 常用方法
   DateUtil.date()                    // 当前时间
   DateUtil.now()                     // 当前时间
   DateUtil.today()                   // 当前日期
   DateUtil.format()                  // 格式化
   DateUtil.parse()                   // 解析
   DateUtil.year()                    // 年
   DateUtil.month()                   // 月
   DateUtil.dayOfMonth()             // 日
   DateUtil.between()                 // 时间差
   DateUtil.offsetMonth()             // 月份偏移
   DateUtil.offsetDay()               // 日期偏移
   DateUtil.beginOfDay()              // 一天开始
   DateUtil.endOfDay()                // 一天结束
   DateUtil.beginOfMonth()            // 月初
   DateUtil.endOfMonth()              // 月末
   DateUtil.beginOfWeek()             // 周初
   DateUtil.endOfWeek()               // 周末
   DateUtil.age()                    // 年龄
   ```

2. **RuoYi DateUtils**（特殊场景）
   ```java
   import com.tmpcode.common.utils.DateUtils;
   
   DateUtils.getNowDate()               // 当前Date
   DateUtils.getDate()                  // yyyy-MM-dd
   DateUtils.getTime()                  // yyyy-MM-dd HH:mm:ss
   DateUtils.dateTimeNow()              // yyyyMMddHHmmss
   DateUtils.datePath()                 // yyyy/MM/dd
   DateUtils.dateTime()                 // yyyyMMdd
   DateUtils.parseDate()                // 解析日期
   DateUtils.differentDaysByMillisecond() // 相差天数
   DateUtils.timeDistance()             // 时间差描述
   DateUtils.toDate()                  // LocalDateTime转Date
   ```

#### 1.1.3 集合操作
**优先级：**
1. **Hutool CollUtil**（最高优先级）
   ```java
   import cn.hutool.core.collection.CollUtil;
   
   // 常用方法
   CollUtil.isEmpty()              // 判断空
   CollUtil.isNotEmpty()           // 判断非空
   CollUtil.newArrayList()          // 创建ArrayList
   CollUtil.newHashSet()           // 创建HashSet
   CollUtil.newArrayList(...)      // 批量创建
   CollUtil.addAll()               // 添加全部
   CollUtil.join()                // 连接
   CollUtil.union()               // 并集
   CollUtil.intersection()         // 交集
   CollUtil.disjunction()         // 差集
   CollUtil.filter()               // 过滤
   CollUtil.map()                 // 映射
   ```

2. **Hutool CollectionUtil**
   ```java
   import cn.hutool.core.collection.CollectionUtil;
   
   // 与CollUtil类似，可互换使用
   ```

3. **Java Stream**（复杂操作）
   ```java
   // 对于复杂操作，使用Stream API
   list.stream()
       .filter(obj -> obj.getStatus().equals("0"))
       .map(Obj::getName)
       .collect(Collectors.toList());
   ```

#### 1.1.4 数字计算
**优先级：**
1. **Hutool NumberUtil**（最高优先级）
   ```java
   import cn.hutool.core.util.NumberUtil;
   
   // 常用方法
   NumberUtil.add()              // 加法
   NumberUtil.sub()              // 减法
   NumberUtil.mul()              // 乘法
   NumberUtil.div()              // 除法
   NumberUtil.round()            // 四舍五入
   NumberUtil.isInteger()        // 判断整数
   NumberUtil.isNumber()         // 判断数字
   NumberUtil.parseInt()         // 转int
   NumberUtil.parseLong()         // 转long
   NumberUtil.genRandomNumber()   // 生成随机数
   ```

2. **RuoYi Arith**
   ```java
   import com.tmpcode.common.utils.Arith;
   
   Arith.add()    // 加法（精确计算）
   Arith.sub()    // 减法（精确计算）
   Arith.mul()    // 乘法（精确计算）
   Arith.div()    // 除法（精确计算）
   ```

#### 1.1.5 对象操作
**优先级：**
1. **Hutool ObjectUtil**（最高优先级）
   ```java
   import cn.hutool.core.util.ObjectUtil;
   
   // 常用方法
   ObjectUtil.isNull()        // 判断null
   ObjectUtil.isNotNull()     // 判断非null
   ObjectUtil.isEmpty()       // 判断空
   ObjectUtil.isNotEmpty()    // 判断非空
   ObjectUtil.defaultIfNull() // 默认值
   ObjectUtil.equal()        // 相等判断
   ObjectUtil.clone()        // 克隆
   ObjectUtil.toString()     // 转字符串
   ```

2. **Hutool BeanUtil**
   ```java
   import cn.hutool.core.bean.BeanUtil;
   
   // 常用方法
   BeanUtil.copyProperties()      // 属性拷贝
   BeanUtil.copyToList()         // 批量拷贝
   BeanUtil.mapToBean()         // Map转Bean
   BeanUtil.beanToMap()         // Bean转Map
   BeanUtil.getProperty()        // 获取属性
   BeanUtil.setProperty()        // 设置属性
   ```

3. **Spring BeanUtils**
   ```java
   import org.springframework.beans.BeanUtils;
   
   BeanUtils.copyProperties(source, target);
   ```

#### 1.1.6 安全相关
**使用 RuoYi SecurityUtils**
```java
import com.tmpcode.common.utils.SecurityUtils;

// 常用方法
SecurityUtils.getUserId()          // 获取用户ID
SecurityUtils.getDeptId()         // 获取部门ID
SecurityUtils.getUsername()        // 获取用户名
SecurityUtils.getLoginUser()       // 获取登录用户
SecurityUtils.isAdmin()           // 判断管理员
SecurityUtils.hasPermi(String)   // 判断权限
SecurityUtils.hasRole(String)     // 判断角色
SecurityUtils.encryptPassword()   // 加密密码
SecurityUtils.matchesPassword()   // 匹配密码
```

#### 1.1.7 字典工具
**使用 RuoYi DictUtils**
```java
import com.tmpcode.common.utils.DictUtils;

// 常用方法
DictUtils.getDictCache()      // 获取字典缓存
DictUtils.getDictLabel()      // 获取字典标签
DictUtils.getDictValue()      // 获取字典值
DictUtils.setDictCache()      // 设置字典缓存
DictUtils.removeDictCache()   // 清除字典缓存
```

#### 1.1.8 JSON 处理
**优先级：**
1. **Hutool JSONUtil**（最高优先级）
   ```java
   import cn.hutool.json.JSONUtil;
   import cn.hutool.json.JSONObject;
   import cn.hutool.json.JSONArray;
   
   // 常用方法
   JSONUtil.toJsonStr()        // 对象转JSON字符串
   JSONUtil.parseObj()        // 解析为JSONObject
   JSONUtil.parseArray()      // 解析为JSONArray
   JSONUtil.toList()          // 转List
   JSONUtil.toBean()          // 转Bean
   ```

2. **FastJSON2**
   ```java
   import com.alibaba.fastjson2.JSON;
   import com.alibaba.fastjson2.JSONObject;
   
   JSON.toJSONString()
   JSON.parseObject()
   JSON.parseArray()
   ```

#### 1.1.9 异常处理
**使用 RuoYi 工具**
```java
// 抛出业务异常
throw new ServiceException("业务错误信息");

// 抛出全局异常
throw new GlobalException("全局错误信息");
```

#### 1.1.10 其他常用工具
**Hutool 工具类**
```java
// HTTP请求
import cn.hutool.http.HttpUtil;
HttpUtil.get()
HttpUtil.post()
HttpUtil.postJson()

// 文件操作
import cn.hutool.core.io.FileUtil;
FileUtil.write()
FileUtil.readLines()

// 加密解密
import cn.hutool.crypto.SecureUtil;
SecureUtil.md5()
SecureUtil.sha256()

// 随机数
import cn.hutool.core.util.RandomUtil;
RandomUtil.randomString()
RandomUtil.randomInt()

// URL处理
import cn.hutool.core.url.UrlQuery;
UrlQuery.of()
```

### 1.2 添加 Hutool 依赖

在 `tmpcode-common/pom.xml` 的 `<dependencies>` 中添加：

```xml
<!-- Hutool工具类 -->
<dependency>
    <groupId>cn.hutool</groupId>
    <artifactId>hutool-all</artifactId>
    <version>5.8.26</version>
</dependency>
```

在项目根目录 `pom.xml` 的 `<properties>` 中添加版本管理：

```xml
<hutool.version>5.8.26</hutool.version>
```

在项目根目录 `pom.xml` 的 `<dependencyManagement>` 中添加：

```xml
<!-- Hutool工具类 -->
<dependency>
    <groupId>cn.hutool</groupId>
    <artifactId>hutool-all</artifactId>
    <version>${hutool.version}</version>
</dependency>
```

### 1.3 工具类选择原则

| 功能 | 首选 | 备选 | 说明 |
|------|------|------|------|
| 字符串处理 | Hutool StrUtil | RuoYi StringUtils, Commons Lang3 | Hutool 功能最全 |
| 日期处理 | Hutool DateUtil | RuoYi DateUtils | Hutool 简单易用 |
| 集合操作 | Hutool CollUtil | Java Stream | Hutool 方法丰富 |
| 数字计算 | Hutool NumberUtil | RuoYi Arith | Arith 用于精确计算 |
| 对象操作 | Hutool BeanUtil | Spring BeanUtils | Hutool 功能更强大 |
| JSON处理 | Hutool JSONUtil | FastJSON2 | 根据性能需求选择 |
| 安全认证 | RuoYi SecurityUtils | - | RuoYi 特有功能 |
| 字典操作 | RuoYi DictUtils | - | RuoYi 特有功能 |
| HTTP请求 | Hutool HttpUtil | - | Hutool 简单易用 |
| 加密解密 | Hutool SecureUtil | - | 支持多种算法 |
| 随机数 | Hutool RandomUtil | - | 支持各种随机 |

### 2. 项目结构

#### 后端模块结构
```
tmpcode-biz/
├── pom.xml
└── src/main/java/com/tmpcode/biz/
    ├── controller/        # 控制器层
    ├── domain/           # 实体类
    │   └── vo/           # 视图对象
    ├── mapper/           # Mapper接口
    └── service/          # Service接口和实现
        └── impl/
└── src/main/resources/mapper/biz/  # MyBatis XML
```

#### 前端目录结构
```
tmpcode-ui/src/
├── views/biz/{模块名}/
│   ├── index.vue         # 列表页面
│   └── {模块名}.vue       # 表单页面
└── api/biz/
    └── {模块名}.js       # API接口
```

## 开发流程

### 第一步：需求分析与设计

1. **理解业务需求**
   - 明确功能模块的业务目标
   - 识别需要管理的数据实体
   - 确定需要的状态字段和字典

2. **数据库设计**
   - 创建表结构 SQL 文件到 `sql/` 目录
   - 表名格式：`{模块名}_{表名}`（如：`biz_product`）
   - 主键格式：`{模块名}_{表名}_id`（如：`product_id`）
   - 必须包含标准字段：
     - `create_by varchar(64)` - 创建者
     - `create_time datetime` - 创建时间
     - `update_by varchar(64)` - 更新者
     - `update_time datetime` - 更新时间
     - `remark varchar(500)` - 备注
     - `del_flag char(1)` - 删除标志（0存在 2删除）

3. **数据库表设计模板**
```sql
-- ----------------------------
-- {表中文注释}
-- ----------------------------
DROP TABLE IF EXISTS {表名};
CREATE TABLE {表名} (
    {主键名}           bigint(20)      NOT NULL AUTO_INCREMENT    COMMENT '{主键注释}',
    {业务字段1}        varchar(64)     DEFAULT ''                 COMMENT '{字段1注释}',
    {业务字段2}        int(11)         DEFAULT 0                  COMMENT '{字段2注释}',
    {状态字段}         char(1)         DEFAULT '0'                COMMENT '状态（0正常 1停用）',
    del_flag          char(1)         DEFAULT '0'                COMMENT '删除标志（0代表存在 2代表删除）',
    create_by         varchar(64)     DEFAULT ''                 COMMENT '创建者',
    create_time       datetime                                    COMMENT '创建时间',
    update_by         varchar(64)     DEFAULT ''                 COMMENT '更新者',
    update_time       datetime                                    COMMENT '更新时间',
    remark            varchar(500)    DEFAULT NULL               COMMENT '备注',
    PRIMARY KEY ({主键名})
) ENGINE=InnoDB AUTO_INCREMENT=100 COMMENT = '{表中文注释}';
```

### 第二步：字典数据设计（如需要）

如果表包含状态字段，必须创建对应的字典数据：

1. **字典类型**
   - 命名格式：`{模块}_{字段名}`
   - 存储在 `sys_dict_type` 表

2. **字典数据模板**
```sql
-- 字典类型
INSERT INTO sys_dict_type VALUES (
    (SELECT max(dict_id) + 1 FROM sys_dict_type),
    '{模块}_{字段名}',
    '{模块名}{字段中文名}',
    'biz',
    'Y',
    'admin',
    NOW(),
    '',
    NULL,
    '{模块}{字段说明}'
);

-- 字典数据示例
INSERT INTO sys_dict_data VALUES (
    (SELECT max(dict_code) + 1 FROM sys_dict_data),
    (SELECT dict_id FROM sys_dict_type WHERE dict_type = '{模块}_{字段名}'),
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

INSERT INTO sys_dict_data VALUES (
    (SELECT max(dict_code) + 1 FROM sys_dict_data),
    (SELECT dict_id FROM sys_dict_type WHERE dict_type = '{模块}_{字段名}'),
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

### 第三步：菜单配置

如果需要在前端菜单中显示，必须配置系统菜单：

1. **菜单表结构**
   - 表名：`sys_menu`
   - 菜单类型：M目录、C菜单、F按钮

2. **一级目录菜单（如需要）**
```sql
INSERT INTO sys_menu VALUES (
    (SELECT max(menu_id) + 1 FROM sys_menu),
    '{模块中文名}',
    '0',
    {显示顺序},
    '{路由路径}',
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
    '{模块}目录'
);
```

3. **二级菜单（页面菜单）**
```sql
INSERT INTO sys_menu VALUES (
    (SELECT max(menu_id) + 1 FROM sys_menu),
    '{菜单中文名}',
    {父菜单ID},
    {显示顺序},
    '{路由路径}',
    '{组件路径}',
    '',
    '',
    1,
    0,
    'C',
    '0',
    '0',
    '{权限标识前缀}:list',
    '{图标}',
    'admin',
    NOW(),
    '',
    NULL,
    '{菜单中文名}菜单'
);
```

4. **功能按钮权限**
```sql
-- 查询按钮
INSERT INTO sys_menu VALUES (
    (SELECT max(menu_id) + 1 FROM sys_menu),
    '{模块}查询',
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
    '{权限标识前缀}:query',
    '#',
    'admin',
    NOW(),
    '',
    NULL,
    ''
);

-- 新增按钮
INSERT INTO sys_menu VALUES (
    (SELECT max(menu_id) + 1 FROM sys_menu),
    '{模块}新增',
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
    '{权限标识前缀}:add',
    '#',
    'admin',
    NOW(),
    '',
    NULL,
    ''
);

-- 修改按钮
INSERT INTO sys_menu VALUES (
    (SELECT max(menu_id) + 1 FROM sys_menu),
    '{模块}修改',
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
    '{权限标识前缀}:edit',
    '#',
    'admin',
    NOW(),
    '',
    NULL,
    ''
);

-- 删除按钮
INSERT INTO sys_menu VALUES (
    (SELECT max(menu_id) + 1 FROM sys_menu),
    '{模块}删除',
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
    '{权限标识前缀}:remove',
    '#',
    'admin',
    NOW(),
    '',
    NULL,
    ''
);

-- 导出按钮
INSERT INTO sys_menu VALUES (
    (SELECT max(menu_id) + 1 FROM sys_menu),
    '{模块}导出',
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
    '{权限标识前缀}:export',
    '#',
    'admin',
    NOW(),
    '',
    NULL,
    ''
);
```

5. **菜单命名规范**
   | 菜单类型 | 权限标识格式 | 说明 |
   |---------|------------|------|
   | 目录 | 无 | 一级目录菜单，path 为模块名 |
   | 菜单 | `{模块}:{对象}:list` | 二级页面菜单，对应列表页面 |
   | 按钮-查询 | `{模块}:{对象}:query` | 查询按钮权限 |
   | 按钮-新增 | `{模块}:{对象}:add` | 新增按钮权限 |
   | 按钮-修改 | `{模块}:{对象}:edit` | 修改按钮权限 |
   | 按钮-删除 | `{模块}:{对象}:remove` | 删除按钮权限 |
   | 按钮-导出 | `{模块}:{对象}:export` | 导出按钮权限 |
   | 按钮-导入 | `{模块}:{对象}:import` | 导入按钮权限 |

### 第四步：后端开发

#### 1. 模块依赖配置

**父 POM (pom.xml)**
在 `<dependencyManagement>` 中添加：
```xml
<!-- 业务模块-->
<dependency>
    <groupId>com.tmpcode</groupId>
    <artifactId>tmpcode-biz</artifactId>
    <version>${tmpcode.version}</version>
</dependency>
```

在 `<modules>` 中添加：
```xml
<module>tmpcode-biz</module>
```

**模块 POM (tmpcode-biz/pom.xml)**
```xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <parent>
        <artifactId>tmpcode</artifactId>
        <groupId>com.tmpcode</groupId>
        <version>3.9.1</version>
    </parent>
    <modelVersion>4.0.0</modelVersion>

    <artifactId>tmpcode-biz</artifactId>

    <description>
        业务模块
    </description>

    <dependencies>
        <!-- 通用工具-->
        <dependency>
            <groupId>com.tmpcode</groupId>
            <artifactId>tmpcode-common</artifactId>
        </dependency>
        <!-- 核心模块-->
        <dependency>
            <groupId>com.tmpcode</groupId>
            <artifactId>tmpcode-framework</artifactId>
        </dependency>
    </dependencies>

</project>
```

**Admin 模块引入 (tmpcode-admin/pom.xml)**
```xml
<dependency>
    <groupId>com.tmpcode</groupId>
    <artifactId>tmpcode-biz</artifactId>
</dependency>
```

#### 2. 实体类 (Domain)

继承 `BaseEntity`，使用 Lombok `@Data` 注解：

```java
package com.tmpcode.biz.domain;

import com.tmpcode.common.annotation.Excel;
import com.tmpcode.common.annotation.Excel.ColumnType;
import com.tmpcode.common.core.domain.BaseEntity;
import lombok.Data;

import javax.validation.constraints.NotBlank;
import javax.validation.constraints.NotNull;
import javax.validation.constraints.Size;

/**
 * {实体中文名}对象 {实体类名}
 * 
 * @author ruoyi
 */
@Data
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

    /** {状态字段注释} */
    @Excel(name = "状态", readConverterExp = "0=正常,1=停用")
    private String status;
}
```

#### 3. Mapper 接口

```java
package com.tmpcode.biz.mapper;

import com.tmpcode.biz.domain.{实体类名};
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

/**
 * {实体中文名}Mapper接口
 * 
 * @author ruoyi
 */
@Mapper
public interface {实体类名}Mapper 
{
    /**
     * 查询{实体中文名}
     * 
     * @param {参数名} {实体中文名}
     * @return {实体中文名}
     */
    public {实体类名} select{实体类名}ById({主键类型} {主键名});

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
    public int delete{实体类名}ById({主键类型} {主键名});

    /**
     * 批量删除{实体中文名}
     * 
     * @param {主键名}s 需要删除的数据主键集合
     * @return 结果
     */
    public int delete{实体类名}ByIds(Long[] {主键名}s);
}
```

#### 4. Mapper XML

路径：`src/main/resources/mapper/biz/{实体类名}Mapper.xml`

```xml
<?xml version="1.0" encoding="UTF-8" ?>
<!DOCTYPE mapper
PUBLIC "-//mybatis.org//DTD Mapper 3.0//EN"
"http://mybatis.org/dtd/mybatis-3-mapper.dtd">
<mapper namespace="com.tmpcode.biz.mapper.{实体类名}Mapper">
    
    <resultMap type="{实体类名}" id="{实体类名小写}Result">
        <result property="{主键名}"    column="{主键名}"    />
        <result property="{字段1名}"  column="{字段1名}"  />
        <result property="{字段2名}"  column="{字段2名}"  />
        <result property="status"       column="status"       />
        <result property="delFlag"      column="del_flag"     />
        <result property="createBy"     column="create_by"    />
        <result property="createTime"   column="create_time"  />
        <result property="updateBy"     column="update_by"    />
        <result property="updateTime"   column="update_time"  />
        <result property="remark"       column="remark"       />
    </resultMap>

    <sql id="select{实体类名}Vo">
        select {主键名}, {字段1名}, {字段2名}, status, del_flag, create_by, create_time, update_by, update_time, remark 
        from {表名}
    </sql>

    <select id="select{实体类名}List" parameterType="{实体类名}" resultMap="{实体类名小写}Result">
        <include refid="select{实体类名}Vo"/>
        <where>  
            del_flag = '0'
            <if test="{字段1名} != null and {字段1名} != ''"> and {字段1名} like concat('%', #{字段1名}, '%')</if>
            <if test="status != null and status != ''"> and status = #{status}</if>
        </where>
        order by create_time desc
    </select>
    
    <select id="select{实体类名}ById" parameterType="{主键类型}" resultMap="{实体类名小写}Result">
        <include refid="select{实体类名}Vo"/>
        where {主键名} = #{${主键名}}
    </select>
        
    <insert id="insert{实体类名}" parameterType="{实体类名}" useGeneratedKeys="true" keyProperty="{主键名}">
        insert into {表名}
        <trim prefix="(" suffix=")" suffixOverrides=",">
            <if test="{字段1名} != null and {字段1名} != ''">{字段1名},</if>
            <if test="{字段2名} != null and {字段2名} != ''">{字段2名},</if>
            <if test="status != null and status != ''">status,</if>
            <if test="remark != null and remark != ''">remark,</if>
            create_by,
            create_time
        </trim>
        <trim prefix="values (" suffix=")" suffixOverrides=",">
            <if test="{字段1名} != null and {字段1名} != ''">#{字段1名},</if>
            <if test="{字段2名} != null and {字段2名} != ''">#{字段2名},</if>
            <if test="status != null and status != ''">#{status},</if>
            <if test="remark != null and remark != ''">#{remark},</if>
            #{createBy},
            sysdate()
        </trim>
    </insert>

    <update id="update{实体类名}" parameterType="{实体类名}">
        update {表名}
        <trim prefix="SET" suffixOverrides=",">
            <if test="{字段1名} != null and {字段1名} != ''">{字段1名} = #{字段1名},</if>
            <if test="{字段2名} != null and {字段2名} != ''">{字段2名} = #{字段2名},</if>
            <if test="status != null and status != ''">status = #{status},</if>
            <if test="remark != null and remark != ''">remark = #{remark},</if>
            update_by = #{updateBy},
            update_time = sysdate()
        </trim>
        where {主键名} = #{${主键名}}
    </update>

    <delete id="delete{实体类名}ById" parameterType="{主键类型}">
        update {表名} set del_flag = '2' where {主键名} = #{${主键名}}
    </delete>

    <delete id="delete{实体类名}ByIds" parameterType="String">
        update {表名} set del_flag = '2' where {主键名} in 
        <foreach item="{主键名}" collection="array" open="(" separator="," close=")">
            #{${主键名}}
        </foreach>
    </delete>
</mapper>
```

#### 5. Service 接口

```java
package com.tmpcode.biz.service;

import com.tmpcode.biz.domain.{实体类名};
import java.util.List;

/**
 * {实体中文名}Service接口
 * 
 * @author ruoyi
 */
public interface I{实体类名}Service 
{
    /**
     * 查询{实体中文名}
     * 
     * @param {主键名} {实体中文名}主键
     * @return {实体中文名}
     */
    public {实体类名} select{实体类名}ById({主键类型} {主键名});

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
     * @param {主键名}s 需要删除的{实体中文名}主键集合
     * @return 结果
     */
    public int delete{实体类名}ByIds(Long[] {主键名}s);

    /**
     * 删除{实体中文名}信息
     * 
     * @param {主键名} {实体中文名}主键
     * @return 结果
     */
    public int delete{实体类名}ById({主键类型} {主键名});
}
```

#### 6. Service 实现类

```java
package com.tmpcode.biz.service.impl;

import com.tmpcode.biz.domain.{实体类名};
import com.tmpcode.biz.mapper.{实体类名}Mapper;
import com.tmpcode.biz.service.I{实体类名}Service;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

/**
 * {实体中文名}Service业务层处理
 * 
 * @author ruoyi
 */
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
    public {实体类名} select{实体类名}ById({主键类型} {主键名})
    {
        return {实体类名小写}Mapper.select{实体类名}ById({主键名});
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
        return {实体类名小写}Mapper.select{实体类名}List({实体类名小写});
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
        return {实体类名小写}Mapper.insert{实体类名}({实体类名小写});
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
        return {实体类名小写}Mapper.update{实体类名}({实体类名小写});
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
        return {实体类名小写}Mapper.delete{实体类名}ByIds({主键名}s);
    }

    /**
     * 删除{实体中文名}信息
     * 
     * @param {主键名} {实体中文名}主键
     * @return 结果
     */
    @Override
    public int delete{实体类名}ById({主键类型} {主键名})
    {
        return {实体类名小写}Mapper.delete{实体类名}ById({主键名});
    }
}
```

#### 7. Controller

```java
package com.tmpcode.biz.controller;

import com.tmpcode.biz.domain.{实体类名};
import com.tmpcode.biz.service.I{实体类名}Service;
import com.tmpcode.common.annotation.Log;
import com.tmpcode.common.core.controller.BaseController;
import com.tmpcode.common.core.domain.AjaxResult;
import com.tmpcode.common.core.page.TableDataInfo;
import com.tmpcode.common.enums.BusinessType;
import com.tmpcode.common.utils.poi.ExcelUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import javax.servlet.http.HttpServletResponse;
import java.util.List;

/**
 * {实体中文名}Controller
 * 
 * @author ruoyi
 */
@RestController
@RequestMapping("/biz/{模块名小写}")
public class {实体类名}Controller extends BaseController
{
    @Autowired
    private I{实体类名}Service {实体类名小写}Service;

    /**
     * 查询{实体中文名}列表
     */
    @PreAuthorize("@ss.hasPermi('biz:{模块名小写}:list')")
    @GetMapping("/list")
    public TableDataInfo list({实体类名} {实体类名小写})
    {
        startPage();
        List<{实体类名}> list = {实体类名小写}Service.select{实体类名}List({实体类名小写});
        return getDataTable(list);
    }

    /**
     * 导出{实体中文名}列表
     */
    @PreAuthorize("@ss.hasPermi('biz:{模块名小写}:export')")
    @Log(title = "{实体中文名}", businessType = BusinessType.EXPORT)
    @PostMapping("/export")
    public void export(HttpServletResponse response, {实体类名} {实体类名小写})
    {
        List<{实体类名}> list = {实体类名小写}Service.select{实体类名}List({实体类名小写});
        ExcelUtil<{实体类名}> util = new ExcelUtil<{实体类名}>({实体类名}.class);
        util.exportExcel(response, list, "{实体中文名}数据");
    }

    /**
     * 获取{实体中文名}详细信息
     */
    @PreAuthorize("@ss.hasPermi('biz:{模块名小写}:query')")
    @GetMapping(value = "/{{{主键名}}}")
    public AjaxResult getInfo({主键类型} {主键名})
    {
        return success({实体类名小写}Service.select{实体类名}ById({主键名}));
    }

    /**
     * 新增{实体中文名}
     */
    @PreAuthorize("@ss.hasPermi('biz:{模块名小写}:add')")
    @Log(title = "{实体中文名}", businessType = BusinessType.INSERT)
    @PostMapping
    public AjaxResult add(@RequestBody {实体类名} {实体类名小写})
    {
        return toAjax({实体类名小写}Service.insert{实体类名}({实体类名小写}));
    }

    /**
     * 修改{实体中文名}
     */
    @PreAuthorize("@ss.hasPermi('biz:{模块名小写}:edit')")
    @Log(title = "{实体中文名}", businessType = BusinessType.UPDATE)
    @PutMapping
    public AjaxResult edit(@RequestBody {实体类名} {实体类名小写})
    {
        return toAjax({实体类名小写}Service.update{实体类名}({实体类名小写}));
    }

    /**
     * 删除{实体中文名}
     */
    @PreAuthorize("@ss.hasPermi('biz:{模块名小写}:remove')")
    @Log(title = "{实体中文名}", businessType = BusinessType.DELETE)
    @DeleteMapping("/{{{主键名}s}}")
    public AjaxResult remove(Long[] {主键名}s)
    {
        return toAjax({实体类名小写}Service.delete{实体类名}ByIds({主键名}s));
    }
}
```

#### 8. 工具类实际使用示例

在实际开发中，以下是一些常用的工具类使用场景：

**示例1：字符串处理**
```java
import cn.hutool.core.util.StrUtil;

// 判断字符串是否为空
if (StrUtil.isEmpty(productName)) {
    throw new ServiceException("产品名称不能为空");
}

// 字符串格式化
String message = StrUtil.format("产品{}已删除", productName);

// 字符串连接
String ids = StrUtil.join(",", idArray);

// 去除首尾空格
String name = StrUtil.trim(inputName);
```

**示例2：日期处理**
```java
import cn.hutool.core.date.DateUtil;
import java.util.Date;

// 获取当前时间
Date now = DateUtil.date();

// 获取月初
Date startOfMonth = DateUtil.beginOfMonth(now);

// 获取月末
Date endOfMonth = DateUtil.endOfMonth(now);

// 格式化日期
String dateStr = DateUtil.format(now, "yyyy-MM-dd HH:mm:ss");

// 解析日期字符串
Date parseDate = DateUtil.parse("2024-01-01", "yyyy-MM-dd");

// 计算日期差
long days = DateUtil.betweenDay(startDate, endDate);
```

**示例3：集合操作**
```java
import cn.hutool.core.collection.CollUtil;
import java.util.List;
import java.util.ArrayList;

// 创建集合
List<Product> list = CollUtil.newArrayList();

// 判断集合非空
if (CollUtil.isNotEmpty(list)) {
    // 处理逻辑
}

// 过滤集合
List<Product> activeList = CollUtil.filter(list, product -> 
    "0".equals(product.getStatus())
);

// 集合转数组
Long[] ids = CollUtil.toArray(idList, Long.class);
```

**示例4：对象属性拷贝**
```java
import cn.hutool.core.bean.BeanUtil;

// 属性拷贝
Product product = new Product();
BeanUtil.copyProperties(productDTO, product);

// Map转Bean
Product product = BeanUtil.mapToBean(map, Product.class);

// Bean转Map
Map<String, Object> map = BeanUtil.beanToMap(product);
```

**示例5：获取当前用户信息**
```java
import com.tmpcode.common.utils.SecurityUtils;

// 获取当前用户ID
Long userId = SecurityUtils.getUserId();

// 获取当前用户名
String username = SecurityUtils.getUsername();

// 获取当前部门ID
Long deptId = SecurityUtils.getDeptId();

// 判断是否为管理员
boolean isAdmin = SecurityUtils.isAdmin();

// 获取登录用户信息
LoginUser loginUser = SecurityUtils.getLoginUser();
```

**示例6：异常处理**
```java
import com.tmpcode.common.exception.ServiceException;

// 抛出业务异常
if (StrUtil.isEmpty(productName)) {
    throw new ServiceException("产品名称不能为空");
}

// 携带状态码的异常
throw new ServiceException("产品已存在", HttpStatus.BAD_REQUEST);
```

**示例7：Controller中使用工具类**
```java
package com.tmpcode.biz.controller;

import cn.hutool.core.util.StrUtil;
import cn.hutool.core.collection.CollUtil;
import com.tmpcode.biz.domain.Product;
import com.tmpcode.biz.service.IProductService;
import com.tmpcode.common.annotation.Log;
import com.tmpcode.common.core.controller.BaseController;
import com.tmpcode.common.core.domain.AjaxResult;
import com.tmpcode.common.core.page.TableDataInfo;
import com.tmpcode.common.enums.BusinessType;
import com.tmpcode.common.utils.SecurityUtils;
import com.tmpcode.common.utils.poi.ExcelUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import javax.servlet.http.HttpServletResponse;
import java.util.List;

/**
 * 产品管理Controller
 */
@RestController
@RequestMapping("/biz/product")
public class ProductController extends BaseController {
    @Autowired
    private IProductService productService;

    /**
     * 查询产品列表
     */
    @PreAuthorize("@ss.hasPermi('biz:product:list')")
    @GetMapping("/list")
    public TableDataInfo list(Product product) {
        startPage();
        List<Product> list = productService.selectProductList(product);
        return getDataTable(list);
    }

    /**
     * 导出产品列表
     */
    @PreAuthorize("@ss.hasPermi('biz:product:export')")
    @Log(title = "产品管理", businessType = BusinessType.EXPORT)
    @PostMapping("/export")
    public void export(HttpServletResponse response, Product product) {
        List<Product> list = productService.selectProductList(product);
        ExcelUtil<Product> util = new ExcelUtil<Product>(Product.class);
        util.exportExcel(response, list, "产品数据");
    }

    /**
     * 新增产品
     */
    @PreAuthorize("@ss.hasPermi('biz:product:add')")
    @Log(title = "产品管理", businessType = BusinessType.INSERT)
    @PostMapping
    public AjaxResult add(@RequestBody Product product) {
        // 使用Hutool工具类校验
        if (StrUtil.isEmpty(product.getProductName())) {
            return AjaxResult.error("产品名称不能为空");
        }
        // 设置创建者
        product.setCreateBy(SecurityUtils.getUsername());
        return toAjax(productService.insertProduct(product));
    }

    /**
     * 修改产品
     */
    @PreAuthorize("@ss.hasPermi('biz:product:edit')")
    @Log(title = "产品管理", businessType = BusinessType.UPDATE)
    @PutMapping
    public AjaxResult edit(@RequestBody Product product) {
        product.setUpdateBy(SecurityUtils.getUsername());
        return toAjax(productService.updateProduct(product));
    }

    /**
     * 删除产品
     */
    @PreAuthorize("@ss.hasPermi('biz:product:remove')")
    @Log(title = "产品管理", businessType = BusinessType.DELETE)
    @DeleteMapping("/{productIds}")
    public AjaxResult remove(Long[] productIds) {
        if (CollUtil.isEmpty(productIds)) {
            return AjaxResult.error("请选择要删除的数据");
        }
        return toAjax(productService.deleteProductByIds(productIds));
    }
}
```

### 第五步：前端开发

#### 1. API 接口文件

路径：`tmpcode-ui/src/api/biz/{模块名}.js`

```javascript
import request from '@/utils/request'

// 查询{实体中文名}列表
export function list{实体类名}(query) {
  return request({
    url: '/biz/{模块名小写}/list',
    method: 'get',
    params: query
  })
}

// 查询{实体中文名}详细
export function get{实体类名}({主键名}) {
  return request({
    url: '/biz/{模块名小写}/' + {主键名},
    method: 'get'
  })
}

// 新增{实体中文名}
export function add{实体类名}(data) {
  return request({
    url: '/biz/{模块名小写}',
    method: 'post',
    data: data
  })
}

// 修改{实体中文名}
export function update{实体类名}(data) {
  return request({
    url: '/biz/{模块名小写}',
    method: 'put',
    data: data
  })
}

// 删除{实体中文名}
export function del{实体类名}({主键名}) {
  return request({
    url: '/biz/{模块名小写}/' + {主键名},
    method: 'delete'
  })
}
```

#### 2. 列表页面

路径：`tmpcode-ui/src/views/biz/{模块名}/index.vue`

```vue
<template>
  <div class="app-container">
    <!-- 查询表单 -->
    <el-form :model="queryParams" ref="queryForm" size="small" :inline="true" v-show="showSearch" label-width="68px">
      <el-form-item label="{字段1中文名}" prop="{字段1名}">
        <el-input
          v-model="queryParams.{字段1名}"
          placeholder="请输入{字段1中文名}"
          clearable
          @keyup.enter.native="handleQuery"
        />
      </el-form-item>
      <el-form-item>
        <el-button type="primary" icon="el-icon-search" size="mini" @click="handleQuery">搜索</el-button>
        <el-button icon="el-icon-refresh" size="mini" @click="resetQuery">重置</el-button>
      </el-form-item>
    </el-form>

    <!-- 操作按钮 -->
    <el-row :gutter="10" class="mb8">
      <el-col :span="1.5">
        <el-button
          type="primary"
          plain
          icon="el-icon-plus"
          size="mini"
          @click="handleAdd"
          v-hasPermi="['biz:{模块名小写}:add']"
        >新增</el-button>
      </el-col>
      <right-toolbar :showSearch.sync="showSearch" @queryTable="getList"></right-toolbar>
    </el-row>

    <!-- 数据表格 -->
    <el-table v-loading="loading" :data="{实体类名小写}List" @selection-change="handleSelectionChange">
      <el-table-column type="selection" width="55" align="center" />
      <el-table-column label="{主键中文名}" align="center" prop="{主键名}" />
      <el-table-column label="{字段1中文名}" align="center" prop="{字段1名}" />
      <el-table-column label="{字段2中文名}" align="center" prop="{字段2名}" />
      <el-table-column label="状态" align="center" prop="status">
        <template slot-scope="scope">
          <dict-tag :options="dict.type.sys_normal_disable" :value="scope.row.status"/>
        </template>
      </el-table-column>
      <el-table-column label="操作" align="center" class-name="small-padding fixed-width">
        <template slot-scope="scope">
          <el-button
            size="mini"
            type="text"
            icon="el-icon-edit"
            @click="handleUpdate(scope.row)"
            v-hasPermi="['biz:{模块名小写}:edit']"
          >修改</el-button>
          <el-button
            size="mini"
            type="text"
            icon="el-icon-delete"
            @click="handleDelete(scope.row)"
            v-hasPermi="['biz:{模块名小写}:remove']"
          >删除</el-button>
        </template>
      </el-table-column>
    </el-table>

    <!-- 分页组件 -->
    <pagination
      v-show="total>0"
      :total="total"
      :page.sync="queryParams.pageNum"
      :limit.sync="queryParams.pageSize"
      @pagination="getList"
    />

    <!-- 添加或修改对话框 -->
    <el-dialog :title="title" :visible.sync="open" width="500px" append-to-body>
      <el-form ref="form" :model="form" :rules="rules" label-width="80px">
        <el-form-item label="{字段1中文名}" prop="{字段1名}">
          <el-input v-model="form.{字段1名}" placeholder="请输入{字段1中文名}" />
        </el-form-item>
        <el-form-item label="{字段2中文名}" prop="{字段2名}">
          <el-input v-model="form.{字段2名}" placeholder="请输入{字段2中文名}" />
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
import { list{实体类名}, get{实体类名}, del{实体类名}, add{实体类名}, update{实体类名} } from "@/api/biz/{模块名}";

export default {
  name: "{实体类名}",
  dicts: ['sys_normal_disable'],
  data() {
    return {
      // 遮罩层
      loading: true,
      // 选中数组
      ids: [],
      // 非单个禁用
      single: true,
      // 非多个禁用
      multiple: true,
      // 显示搜索条件
      showSearch: true,
      // 总条数
      total: 0,
      // {实体中文名}表格数据
      {实体类名小写}List: [],
      // 弹出层标题
      title: "",
      // 是否显示弹出层
      open: false,
      // 查询参数
      queryParams: {
        pageNum: 1,
        pageSize: 10,
        {字段1名}: null
      },
      // 表单参数
      form: {},
      // 表单校验
      rules: {
        {字段1名}: [
          { required: true, message: "{字段1中文名}不能为空", trigger: "blur" }
        ]
      }
    };
  },
  created() {
    this.getList();
  },
  methods: {
    /** 查询{实体中文名}列表 */
    getList() {
      this.loading = true;
      list{实体类名}(this.queryParams).then(response => {
        this.{实体类名小写}List = response.rows;
        this.total = response.total;
        this.loading = false;
      });
    },
    // 取消按钮
    cancel() {
      this.open = false;
      this.reset();
    },
    // 表单重置
    reset() {
      this.form = {
        {主键名}: null,
        {字段1名}: null,
        {字段2名}: null,
        status: "0"
      };
      this.resetForm("form");
    },
    /** 搜索按钮操作 */
    handleQuery() {
      this.queryParams.pageNum = 1;
      this.getList();
    },
    /** 重置按钮操作 */
    resetQuery() {
      this.resetForm("queryForm");
      this.handleQuery();
    },
    // 多选框选中数据
    handleSelectionChange(selection) {
      this.ids = selection.map(item => item.{主键名})
      this.single = selection.length !== 1
      this.multiple = !selection.length
    },
    /** 新增按钮操作 */
    handleAdd() {
      this.reset();
      this.open = true;
      this.title = "添加{实体中文名}";
    },
    /** 修改按钮操作 */
    handleUpdate(row) {
      this.reset();
      const {主键名} = row.{主键名};
      get{实体类名}({主键名}).then(response => {
        this.form = response.data;
        this.open = true;
        this.title = "修改{实体中文名}";
      });
    },
    /** 提交按钮 */
    submitForm() {
      this.$refs["form"].validate(valid => {
        if (valid) {
          if (this.form.{主键名} != null) {
            update{实体类名}(this.form).then(response => {
              this.$modal.msgSuccess("修改成功");
              this.open = false;
              this.getList();
            });
          } else {
            add{实体类名}(this.form).then(response => {
              this.$modal.msgSuccess("新增成功");
              this.open = false;
              this.getList();
            });
          }
        }
      });
    },
    /** 删除按钮操作 */
    handleDelete(row) {
      const {主键名}s = row.{主键名} || this.ids;
      this.$modal.confirm('是否确认删除{实体中文名}编号为"' + {主键名}s + '"的数据项？').then(function() {
        return del{实体类名}({主键名}s);
      }).then(() => {
        this.getList();
        this.$modal.msgSuccess("删除成功");
      }).catch(() => {});
    }
  }
};
</script>
```

## 代码检查清单

在完成开发后，必须验证以下项目：

- [ ] 数据库表已创建，包含标准字段
- [ ] 状态字段已配置字典数据（如需要）
- [ ] 实体类继承 BaseEntity，使用 Lombok @Data 注解
- [ ] 实体类注解完整（@Excel、@NotBlank、@Size 等）
- [ ] Mapper 接口添加 @Mapper 注解
- [ ] Mapper XML 映射正确，命名空间匹配接口全类名
- [ ] Service 实现类添加 @Service 注解
- [ ] Controller 继承 BaseController，添加 @RestController 和 @RequestMapping
- [ ] Controller 权限注解完整（@PreAuthorize）
- [ ] 所有 import 类已引入，无缺失依赖
- [ ] 父 pom.xml 已添加依赖管理和模块注册
- [ ] tmpcode-biz/pom.xml 配置正确
- [ ] tmpcode-admin/pom.xml 已引入 biz 模块
- [ ] 菜单 SQL 已生成（如需要）
- [ ] 前端 API 接口已创建
- [ ] 前端页面功能完整，包含查询、新增、修改、删除
- [ ] 前端页面权限控制正确（v-hasPermi）
- [ ] **工具类使用符合规范**
  - [ ] 字符串处理优先使用 Hutool StrUtil
  - [ ] 日期处理优先使用 Hutool DateUtil
  - [ ] 集合操作优先使用 Hutool CollUtil
  - [ ] 对象操作优先使用 Hutool BeanUtil
  - [ ] 数字计算根据场景选择 Hutool NumberUtil 或 RuoYi Arith
  - [ ] 安全认证使用 RuoYi SecurityUtils
  - [ ] 字典操作使用 RuoYi DictUtils
  - [ ] Hutool 依赖已正确配置
  - [ ] 无不必要的工具类重复实现
  - [ ] 代码中工具类引用正确（import 语句）

## 常见问题

### 1. 实体类字段命名
- 数据库字段使用下划线命名：`user_name`
- Java 实体字段使用驼峰命名：`userName`
- MyBatis 会自动转换

### 2. 权限注解格式
- Controller 方法必须添加：`@PreAuthorize("@ss.hasPermi('biz:{模块名小写}:{操作}')"`
- 操作包括：list, query, add, edit, remove, export, import

### 3. 删除操作
- RuoYi 框架使用逻辑删除
- 删除操作更新 `del_flag` 为 '2'，不真正删除数据

### 4. 字典数据使用
- 实体类添加字段：`private String status;`
- 页面显示：`<dict-tag :options="dict.type.sys_normal_disable" :value="scope.row.status"/>`
- 组件定义：`dicts: ['sys_normal_disable']`

### 5. 分页查询
- Controller 必须调用 `startPage()` 方法
- Service 返回 List 即可
- MyBatis 分页插件自动处理

## 开发注意事项

1. **遵循 RuoYi 代码风格**
   - 实体类使用 Lombok @Data，不手动写 getter/setter
   - 控制器继承 BaseController
   - 使用统一的 AjaxResult 返回结果
   - 使用 @Log 注解记录操作日志

2. **数据库脚本存放**
   - 所有表结构脚本放在 `sql/` 目录
   - 脚本命名格式：`{模块名}_{表名}.sql` 或统一放入模块 SQL 文件

3. **前端路由配置**
   - 菜单配置后自动生成路由
   - 组件路径必须与菜单配置一致
   - 图标使用 Element UI 内置图标

4. **参数校验**
   - 实体类使用 JSR-303 注解
   - 前端表单添加 rules 校验规则
   - Controller 自动进行参数校验

5. **异常处理**
   - 使用统一的异常处理机制
   - 返回标准格式的错误信息
   - 前端使用 $modal 统一提示
