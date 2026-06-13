# RuoYi-Vue-Plus 深度研究文档

> 基于 plus-doc.top 官方文档（5.X 版本）全量阅读 + Gitee 仓库 + 口腔平台实践
> 阅读日期：2026-06-03

---

## 一、框架定位

**Dromara RuoYi-Vue-Plus** 是对 RuoYi-Vue 的**全方位重写升级版**（不兼容原框架），专注于**分布式集群与多租户（SaaS）场景**。

- 官网文档：https://plus-doc.top
- 仓库地址：https://gitee.com/dromara/RuoYi-Vue-Plus
- 开源协议：MIT，免费可商用

---

## 二、技术栈

### 2.1 后端核心技术栈

| 分类 | 技术 | 说明 |
|------|------|------|
| 框架 | Spring Boot | 主流 Java 后端框架 |
| Web容器 | **Undertow** | 基于 XNIO 的高性能容器（替代 Tomcat） |
| 认证鉴权 | **Sa-Token + JWT** | 强解耦、功能齐全，支持注解式权限校验 |
| ORM | **MyBatis-Plus** | 对象化操作，插件众多（分页/多租户/乐观锁） |
| SQL监控 | **p6spy** | 输出完整SQL与执行时间 |
| 缓存 | **Redis + Redisson** | Redisson提供分布式锁/队列/限流/幂等 |
| 缓存注解 | **Spring Cache 扩展** | 支持TTL、最大空闲时间、组长度等 |
| 多数据源 | **dynamic-datasource** | 支持异构数据库切换、SpEL表达式动态切换 |
| 连接池 | **HikariCP** | Spring官方内置，高性能 |
| 序列化 | **Jackson** | Spring官方内置 |
| 校验 | **Validation** | 支持注解与工具类，注解支持国际化 |
| Excel | **Apache Fesod（原EasyExcel）** | 扩展了自动合并、字典翻译等功能 |
| 接口文档 | **SpringDoc + javadoc** | 零注解零侵入，基于Java注释 |
| 定时任务 | **SnailJob** | 分布式调度中心，支持分片/重试/DAG工作流 |
| 文件存储 | **MinIO（默认）** | 分布式存储，支持多机/多硬盘/多副本 |
| 云存储 | AWS S3协议 | 支持七牛/阿里/腾讯等S3兼容厂商 |
| 短信 | **sms4j** | 支持数十种短信厂商，多厂家共用 |
| 邮件 | **mail-api** | 通用协议支持大部分邮件厂商 |
| 工具类 | **Hutool + Lombok** | Hutool优先于框架工具类 |
| 链路追踪 | Apache SkyWalking | 实时查看请求经过的每个节点 |
| 监控 | SpringBoot-Admin | 集群监控（CPU/内存/磁盘/堆栈/日志） |
| 部署 | Docker | 一键编排所有环境 |
| 分布式锁 | Lock4j（底层Redisson） | 注解式+工具式 |
| 工作流 | 内置工作流引擎 | 支持转办/委派/加签/会签/或签/票签 |

### 2.2 前端技术栈

| 分类 | 技术 |
|------|------|
| 框架 | Vue 3 + TypeScript |
| UI库 | Element Plus |
| 构建 | Vite |

### 2.3 数据库支持

原生支持：MySQL 5.7+ / 8.0、Oracle ≥12c、PostgreSQL 13/14/15、SQL Server 2017/2019
可扩展：支持 MyBatis-Plus 兼容的所有数据库（达梦、金仓等均有成功案例）
**支持异构数据库同时使用**。

---

## 三、项目结构（v5.2.2）

```
RuoYi-Vue-Plus/
├── ruoyi-admin/                    # 管理模块 [8080, 28080]
│   ├── RuoYiApplication           # 启动类
│   ├── RuoYiServletInitializer    # 容器部署初始化类
│   └── resources/
│       ├── i18n/messages.properties  # 国际化
│       ├── application.yml           # 框架总配置
│       ├── application-dev.yml       # 开发环境
│       ├── application-prod.yml      # 生产环境
│       └── logback-plus.xml          # 日志配置
├── ruoyi-extend/                   # 扩展模块
│   ├── ruoyi-monitor-admin/       # Admin监控 [9090]
│   └── ruoyi-snailjob-server/     # 任务调度中心 [8800, 17888]
├── ruoyi-common/                   # 通用模块
│   ├── ruoyi-common-bom/          # 依赖包管理
│   ├── ruoyi-common-core/         # 核心模块
│   ├── ruoyi-common-doc/          # 接口文档模块
│   ├── ruoyi-common-encrypt/      # 数据加解密
│   ├── ruoyi-common-excel/        # Excel模块
│   ├── ruoyi-common-idempotent/   # 幂等功能
│   ├── ruoyi-common-job/          # 定时任务
│   ├── ruoyi-common-json/         # 序列化模块
│   ├── ruoyi-common-log/          # 日志模块
│   ├── ruoyi-common-mail/         # 邮件模块
│   ├── ruoyi-common-mybatis/      # MyBatis扩展
│   ├── ruoyi-common-oss/          # OSS模块
│   ├── ruoyi-common-redis/        # Redis模块
│   ├── ruoyi-common-satoken/      # Sa-Token模块
│   ├── ruoyi-common-security/     # 安全模块
│   ├── ruoyi-common-sensitive/    # 数据脱敏
│   ├── ruoyi-common-sms/          # 短信模块
│   ├── ruoyi-common-sse/          # SSE推送
│   ├── ruoyi-common-tenant/       # 多租户
│   ├── ruoyi-common-translation/  # 翻译功能
│   ├── ruoyi-common-web/          # Web模块
│   └── ruoyi-common-websocket/    # WebSocket模块
├── ruoyi-modules/                  # 业务模块
└── ruoyi-plugin/                   # 第三方集成
```

**关键特点**：插件化 + 扩展包形式，结构解耦，易于扩展（原RuoYi模块相互注入耦合严重）。

---

## 四、与 RuoYi 的核心差异

### 4.1 功能差异

| 功能 | RuoYi-Vue-Plus | 原 RuoYi |
|------|:---:|:---:|
| 前端 | Vue3 + TS + ElementPlus | Vue2/Vue3 + JS |
| 后端结构 | 插件化，解耦 | 模块耦合严重 |
| Web容器 | Undertow（XNIO高性能） | Tomcat |
| 权限认证 | Sa-Token + JWT（低耦合高扩展） | Spring Security（繁琐） |
| 权限注解 | 支持 AND/OR 复杂表达式 | 仅存在性匹配 |
| 三方登录 | JustAuth（微信/钉钉等） | 无 |
| 数据库支持 | MySQL/Oracle/PG/SQLServer，可异构切换 | 仅MySQL/Oracle |
| Redis | Redisson（90%命令，自动优化如keys→scan） | Lettuce（common-pool有bug） |
| ORM | MyBatis-Plus（对象化操作） | MyBatis（XML手写） |
| SQL监控 | p6spy（完整SQL+耗时） | log手动拼接 |
| 数据分页 | MP分页插件（多排序/多传参方式） | PageHelper（仅单排序） |
| 数据权限 | MP插件无感式过滤（支持自定义字段） | AOP注解（SQL兼容性差） |
| **数据脱敏** | ✅ 注解+Jackson | ❌ 无 |
| **数据加解密** | ✅ 注解+MyBatis拦截器 | ❌ 无 |
| **接口传输加密** | ✅ 动态AES+RSA | ❌ 无 |
| **数据翻译** | ✅ 注解+Jackson | ❌ 无 |
| 多数据源 | dynamic-datasource（异构+动态） | druid手动配置 |
| **多数据源事务** | ✅ DSTransactional | ❌ 不支持 |
| 连接池 | HikariCP | Druid（bug多） |
| 主键 | **雪花ID**（有序增长） | 数据库自增 |
| WebSocket | Token鉴权+分布式会话 | 单机 |
| SSE | ✅ 支持 | ❌ 无 |
| 序列化 | Jackson | fastjson（bug多） |
| 分布式幂等 | Redisson（美团GTIS简化） | 手动AOP |
| 分布式锁 | Lock4j | ❌ 无 |
| 定时任务 | **SnailJob**（分布式/分片/DAG） | Quartz（数据库锁差） |
| 文件存储 | **MinIO**（分布式，加密存储） | 本机（裸露不安全） |
| 云存储 | AWS S3协议（七牛/阿里/腾讯） | ❌ 无 |
| 短信 | sms4j（多厂家） | ❌ 无 |
| 邮件 | mail-api | ❌ 无 |
| 接口文档 | SpringDoc（零注解） | Springfox（已停更） |
| Excel | Apache Fesod（扩展功能多） | POI手写 |
| **工作流** | ✅ 内置 | ❌ 无 |
| 国际化 | 请求头动态切换，注解支持 | 基础功能 |
| 监控 | SpringBoot-Admin（集群+在线日志） | 仅单机 |
| 链路追踪 | SkyWalking | ❌ 无 |
| 部署 | Docker编排 | jar部署 |

### 4.2 业务差异

| 业务功能 | RuoYi-Vue-Plus | 原 RuoYi |
|----------|:---:|:---:|
| **租户管理** | ✅ 支持 | ❌ 无 |
| **租户套餐管理** | ✅ 支持 | ❌ 无 |
| **客户端管理** | ✅ PC/小程序/动态授权 | ❌ 无 |
| **文件管理** | ✅ 上传/下载/删除 | ❌ 无 |
| **文件配置管理** | ✅ 动态配置 | ❌ 无 |
| 在线构建器 | ✅ 支持 | ✅ 支持 |
| **使用案例模块** | ✅ Demo模块 | ❌ 无 |
| 定时任务管理 | 任务+日志+执行器 | 仅任务+日志 |
| 服务监控 | 集群（CPU/内存/磁盘/堆栈/日志） | 单机CPU/内存/磁盘 |

---

## 五、初始化与搭建

### 5.1 运行环境

| 组件 | 版本要求 | 注意事项 |
|------|----------|----------|
| JDK | **17 / 21** | 推荐 OpenJDK，**禁止 OracleJDK**（会导致 Spring 打包/运行异常） |
| MySQL | 5.7 / 8.0 | 其他版本未测试 |
| Oracle | ≥ 12c | |
| PostgreSQL | 13 / 14 / 15 | |
| SQL Server | 2017 / 2019 | |
| Redis | **≥ 6.x** | 框架大量使用新特性 |
| MinIO | 按需 | 可用 RustFS 替代 |
| Maven | ≥ 3.8.x | |
| Node.js | ≥ 20.15 | |
| npm | ≥ 8.x | **7.x 已确认存在问题** |

### 5.2 IDEA 版本避坑

- ❌ **2023 全系列不推荐**（问题较多）
- ❌ 2024.1/2024.2：Maven 插件无法刷新依赖
- ❌ 2025.1/2025.2：存在已知问题
- ✅ **推荐：2024.3（JDK17）或 2025.3（JDK21-25）**

### 5.3 初始化步骤

1. Maven 勾选对应环境
2. 确认 JDK 版本（默认 JDK17）
3. 按顺序导入数据库 SQL（默认 MySQL）
4. 配置数据库与 Redis 连接
5. **启动顺序**：
   - 必启：MySQL、Redis、Admin
   - 可选：MinIO、Monitor、SnailJob
   - 建议先启 MonitorAdminApplication → SnailJobServerApplication → DromaraApplication

---

## 六、数据库设计规范

### 6.1 BaseEntity 必备字段

继承 `BaseEntity` 的实体自动包含以下字段并按约定自动填充：

| 字段 | 类型 | 作用 |
|------|------|------|
| `create_dept` | BIGINT | 创建部门，用于数据归属与审计 |
| `create_by` | BIGINT | 创建人 |
| `create_time` | DATETIME | 创建时间 |
| `update_by` | BIGINT | 修改人 |
| `update_time` | DATETIME | 修改时间 |
| `remark` | VARCHAR(500) | 备注 |

### 6.2 可选字段

| 字段 | 说明 |
|------|------|
| `tenant_id` | 租户ID（多租户场景必须），继承 `TenantEntity` 即可 |
| `del_flag` | 逻辑删除标记，默认 `'0'`=正常，`'2'`=删除 |
| `version` | 乐观锁，默认从 `0` 开始 |

### 6.3 命名建议

- 业务表字段**尽量沿用框架标准字段名**：`create_by`、`create_time`、`update_by`、`update_time`、`tenant_id`、`del_flag`、`version`
- 代码生成器会**自动识别**这些字段，在列表、表单、查询条件中自动排除或处理
- 字符集：`utf8mb4`（禁用 `utf8`）
- 金额：`DECIMAL(10,2)`（禁用 FLOAT/DOUBLE）
- 状态：`CHAR(1)` 或 `VARCHAR`

---

## 七、代码生成器深度指南

### 7.1 核心能力

- 支持**多数据源切换**
- 支持 **100+ 数据库**（添加驱动即可）
- 生成：后端 CRUD（Controller/Service/Mapper/Domain/XML）+ 前端 Vue3 页面
- 支持**树表**与多种字段类型
- 支持**预览与同步**

### 7.2 使用步骤

1. **导入数据表**：点击"导入"加载当前数据库所有表
2. **编辑生成配置**：确认"基本信息、字段信息、生成信息"
3. **配置字段生成规则**：

| 配置项 | 影响 |
|--------|------|
| 插入/编辑 | BO类 + 前端新增/编辑表单字段 |
| 列表 | VO类 + 前端列表展示列 |
| 查询 | 查询条件 + 前端搜索框 |
| 查询方式 | =/LIKE/范围 等 |
| 必填 | BO校验 + 页面必填 |
| 显示类型 | 前端组件（输入框/下拉/日期等） |
| 字典类型 | 字典映射与展示 |

### 7.3 树表配置

选择"树表"模板后需配置三个关键字段：
- `treeCode`：当前节点主键字段
- `treeParentCode`：父节点字段
- `treeName`：树节点展示名称字段

> ⚠️ 这三个字段**选错会导致前端树表层级异常或回显错误**

### 7.4 主子表

> ⚠️ **不支持也不推荐主子表生成**

原因：多表关联场景复杂，易出现笛卡尔积。建议以单表生成为基础，复杂 SQL 自行优化。

### 7.5 预览与同步

- **预览**：生成前检查结构与字段是否正确
- **同步**：表结构变化后，与数据库结构保持一致
  > ⚠️ "同步"仅重新读取表结构，**不等于保留手改代码**；二次开发过的模块建议先预览差异再覆盖

---

## 八、数据权限

### 8.1 核心组件

| 组件 | 功能 |
|------|------|
| `DataScopeType` | 数据权限模板定义（含SQL模板与兜底SQL） |
| `@DataPermission` | Mapper方法上标注，开启数据过滤 |
| `@DataColumn` | 替换模板中的 `#deptName` 等 key 变量 |
| `PlusDataPermissionInterceptor` | SQL拦截器，自动注入过滤条件 |
| `PlusDataPermissionHandler` | 角色→模板匹配处理器 |
| `DataPermissionHelper` | 上下文变量操作工具类 |
| `SysDataScopeService` | 自定义Bean扩展逻辑 |

### 8.2 使用流程（参考 demo 模块）

数据权限体系：**用户 → 多角色 ⇒ 角色 → 单数据权限**

1. 在角色管理中创建数据权限角色
2. 将角色分配给用户
3. 在 **Mapper 层**标注 `@DataPermission` 注解

> ⚠️ 数据权限注解**只能在 Mapper 层生效**

### 8.3 忽略数据权限

```java
// 单条SQL忽略
@InterceptorIgnore(dataPermission = "true")

// 代码块忽略（无返回值）
DataPermissionHelper.ignore(() -> { 业务代码 });

// 代码块忽略（有返回值）
Result result = DataPermissionHelper.ignore(() -> { return 业务代码 });
```

### 8.4 自定义 SQL 模板

在 `DataScopeType` 中新增模板，SQL模板支持：
- `#{#deptName}`：模板变量
- `#{@sdss}`：调用 Bean 处理逻辑
- `elseSql`：兜底SQL（无匹配模板时长用 `1 = 0` 限制）

---

## 九、多租户

### 9.1 核心机制

- `@TenantId` 注解标记租户字段
- 全局开关：`tenant.enable` 配置
- 租户过滤基于 MyBatis-Plus 多租户插件自动注入

### 9.2 忽略多租户

```java
// 单条SQL
@InterceptorIgnore(tenantLine = "true")

// 代码块
TenantHelper.ignore(() -> { 业务代码 });
```

### 9.3 与数据权限的关系

- **彼此独立**，可组合使用
- 同一段逻辑如果同时涉及，需分别评估是否需要忽略

---

## 十、多数据源

### 10.1 配置方式

- YAML 配置：多数据源定义在配置文件中
- 动态添加：通过前端页面添加数据源
- SpEL 表达式：从请求头/参数等条件动态切换

### 10.2 注解用法

```java
@DS("slave")  // 切换到从库
public List<User> selectAll() { ... }

@DS("master") // 或省略（默认数据源）
public void insert(User user) { ... }
```

### 10.3 多数据源事务

```java
// AService调用BService（数据源b）和CService（数据源c）
public class AService {
    @DS("a")  // 默认数据源可省略
    @DSTransactional
    public void doSomething() {
        BService.doB();  // @DS("b")
        CService.doC();  // @DS("c")
    }
}
```

> ⚠️ `@DSTransactional` 是**本地事务**，**不等于 XA 分布式事务**

---

## 十一、缓存使用

基于 **Spring Cache 扩展** + **Redis/Redisson**：

```java
@Cacheable(cacheNames = "user", key = "#id", ttl = 3600)      // 读取缓存
@CacheEvict(cacheNames = "user", key = "#id")                   // 删除缓存
@CachePut(cacheNames = "user", key = "#user.id")                // 更新缓存
```

扩展功能：
- `ttl`：过期时间（秒）
- `maxIdleTime`：最大空闲时间
- `maxSize`：组最大长度

---

## 十二、防重幂等

基于 Redisson + 美团GTIS防重系统简化实现：

```java
@RepeatSubmit(interval = 5000)  // 5秒内不允许重复提交
public R<Void> submit(@RequestBody Form form) { ... }
```

---

## 十三、数据脱敏

注解 + Jackson 序列化期间脱敏：

```java
@Sensitive(strategy = SensitiveStrategy.PHONE)
private String phone;

@Sensitive(strategy = SensitiveStrategy.ID_CARD)
private String idCard;
```

内置策略：身份证、手机号、地址、邮箱、银行卡等，**可自行扩展**。

---

## 十四、数据加解密

注解 + MyBatis 拦截器，存取期间自动加解密：

```java
@Encrypt(algorithm = AlgorithmType.AES)
private String secretData;

@Encrypt(algorithm = AlgorithmType.SM4)
private String nationalSecret;
```

支持算法：BASE64、AES、RSA、SM2、SM4

---

## 十五、翻译功能

注解 + Jackson 序列化期间动态翻译：

```java
// 映射翻译（字典）
@Translate(type = TranslateType.DICT, dictType = "sys_user_sex")
private String sex;

// 直接翻译（指定映射关系）
@Translate(type = TranslateType.MAPPING, source = "0", target = "正常")
private String status;

// 自定义翻译（接口化扩展）
@Translate(type = TranslateType.CUSTOM, handler = MyTranslator.class)
private String customField;
```

---

## 十六、事务相关

### 16.1 单数据源事务

```java
@Transactional(rollbackFor = Exception.class)
public void doSomething() { ... }
```

### 16.2 多数据源事务

```java
@DSTransactional  // ≠ XA分布式事务
```

### 16.3 事务与多数据源调用关系

```java
// AService调用BService、CService（不同数据源）
public class AService {
    @DS("a")  // 默认数据源可省略
    @DSTransactional
    public void process() {
        BService.doB();  // @DS("b")
        CService.doC();  // @DS("c")
    }
}
```

---

## 十七、主键使用说明

- **默认：雪花ID**（分布式、时间戳有序增长）
- 全局修改：`MybatisPlusConfig` 的 Bean
- 单表自定义：实体类单独注解
- **前端兼容**：Long 在 JS 中可能失真 → 框架已配置序列化方案，超出 JS 最大值自动转字符串（`BigNumberSerializer`，3.0.0 以上）

---

## 十八、分页功能

基于 MyBatis-Plus 分页插件，已开启**分页合理化**（页码溢出返回首页）。

### 使用步骤

```java
// 1. Controller 接收分页参数
public TableDataInfo<UserVo> list(UserBo bo, PageQuery pageQuery) {
    // 2. 构建 MP 分页对象
    Page<UserVo> page = pageQuery.build();
    // 3. 执行查询
    Page<UserVo> result = userService.page(page, wrapper);
    // 4. 封装返回
    return TableDataInfo.build(result);
}
```

支持参数：`pageNum`（默认1）、`pageSize`、`orderByColumn`、`isAsc`

---

## 十九、OSS 功能

### 19.1 支持的厂商

MinIO（默认）、阿里云 OSS、腾讯云 COS、七牛云、**所有 AWS S3 协议兼容厂商**

### 19.2 关键注意

- 访问站点**不要携带路径**（如 `/`、`/ruoyi`）
- 阿里云/腾讯云：访问站点中不要包含桶名
- MinIO：不建议使用 `localhost`，请用 `127.0.0.1`
- HTTPS 使用配置项控制，不要加 `http/https` 前缀

### 19.3 代码使用

```java
// 获取默认 OSS 客户端
OssClient client = OssFactory.instance();
// 指定配置
OssClient imageClient = OssFactory.instance("image");

// 上传
OssClient storage = OssFactory.instance();
storage.upload(...);
```

### 19.4 多业务场景

建议创建**多个 OSS 配置**进行切换存储（图片、附件、私有文件等），不建议一套配置混放所有场景。

---

## 二十、导入导出

### 20.1 导出示例

```java
// 定义导出VO
@ExcelProperty(value = "用户序号")
private Long userId;

@ExcelProperty(value = "用户性别", converter = ExcelDictConvert.class)
@ExcelDictFormat(dictType = "sys_user_sex")
private String sex;
```

### 20.2 导入校验

```java
// BO类加校验注解
@ExcelProperty(value = "用户名称")
@NotBlank(message = "用户名称不能为空")
private String userName;
```

---

## 二十一、接口文档（SpringDoc）

基于 SpringDoc + javadoc，**零注解零侵入**，只需写好 Java 注释即可自动生成 API 文档。

- 访问地址：`http://localhost:8080/swagger-ui/index.html`
- 无需额外写文档注解

---

## 二十二、国际化

基于请求头 `Accept-Language` 动态返回不同语种文本：

```java
// 工具类
MessageUtils.message("user.not.exists");
```

支持大部分注解内容的国际化，配置在 `i18n/messages.properties`。

---

## 二十三、WebSocket / SSE

### 23.1 WebSocket

- Token 鉴权 + 分布式会话同步（不再是单机）
- 支持单机/分布式消息发送

### 23.2 SSE（Server-Sent Events）

- 基于 Spring SSE 实现
- 扩展了 Token 鉴权与分布式会话同步
- 前端连接示例：`http://ip:port/resource/sse?clientid=xxx&Authorization=Bearer <token>`

### 消息发送方式

```java
SseMessageUtils.sendMessage(...)     // 单机消息
SseMessageUtils.publishMessage(...)  // 分布式消息（推荐）
SseMessageUtils.publishAll(...)      // 群发消息
```

---

## 二十四、多表查询建议

> ⚠️ **建议单表优先**

多表 Join 容易造成性能下降与结果集膨胀。参考资料：
- 《高性能 MySQL》大连接查询分解
- MP 多表查询性能测试

---

## 二十五、单元测试

基于 JUnit5 + SpringBoot Test，提供单例测试模板与 Maven 多环境单测插件。

参考代码在 demo 模块（4.4.0 新增）。

---

## 二十六、工作流

内置工作流引擎，支持：
- 转办、委派、加减签
- 会签、或签、票签
- 各种复杂审批场景

---

## 二十七、与口腔平台的契合点总结

基于 `口腔平台-RuoYi实现方案.md` 的实际需求，RuoYi-Vue-Plus 框架提供以下关键能力：

| 项目需求 | 框架能力 | 实现方式 |
|----------|----------|----------|
| 7大角色体系 | **RBAC + 部门体系** | 角色=功能权限，部门=数据范围，不改核心表 |
| 课程分类树 | 树形组件 + 代码生成器树表模板 | `dental_course_category` 表用树表模板生成 |
| 专家仅看自己的课程 | **数据权限** | `@DataPermission` + `data_scope=5` + `create_by` 过滤 |
| 机构管理者看团队数据 | 数据权限（本部门及以下） | `data_scope=3` 原生支持 |
| 课程图片存储 | **OSS 模块** | MinIO 多配置（课程封面/病例影像 分离） |
| 视频播放 | 第三方播放器集成 | DPlayer 前端组件 |
| 课后测验评分 | 业务逻辑 | Service 层自定义 + 事务管理 |
| 学习时长累加 | 业务逻辑 | `updateProgress` + `total_study_time` 累加 |
| 病例社区 | 标准 CRUD | 代码生成器生成基础代码 + 业务补充 |
| 病例评分自动计算 | 业务逻辑 | ServiceImpl 中 `recalculateAndUpdateCaseScore()` |
| 多租户隔离 | **多租户功能** | 如 SaaS 化部署，租户隔离天然支持 |
| API文档 | SpringDoc | 零注解自动生成 |

---

## 二十八、开发规范速查

### 后端规范
- 实体继承 `BaseEntity`（树表继承 `TreeEntity`），使用 `@Accessors(chain=true)` 链式赋值
- 工具类优先级：**Hutool > RuoYi工具类 > Apache Commons**
- 所有 public 方法首行打印入参日志（`@Slf4j`）
- 业务异常用 `ServiceException`
- 禁止 try-catch（全局异常处理器统一处理）
- Mapper XML：禁止 `SELECT *`，查询首行 `del_flag = '0'`，删除用 `UPDATE del_flag = '2'`

### 前端规范
- `useDict` 在 `script setup` 顶层调用
- 字典下拉绑 `:value="dict.value"`
- 列表字典列用 `<dict-tag>` 组件
- 按钮权限用 `v-hasPermi`
- `resetQuery` 中清空 `dateRange`

### 权限字符串规范
- 格式：`模块:功能:操作`（如 `dental:course:list`）
- Controller 注解与菜单表 `sys_menu.perms` 必须严格一致

---

> **文档编制日期**：2026-06-03
> **数据来源**：https://plus-doc.top 官方文档全量阅读（52个页面）+ https://gitee.com/dromara/RuoYi-Vue-Plus 仓库
