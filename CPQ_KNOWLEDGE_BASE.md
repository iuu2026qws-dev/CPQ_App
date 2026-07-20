# CPQ App 知识文档 — 源码、数据、依赖全解析

> **目的**: 供新加入的开发者快速深入理解项目全貌，涵盖源码架构、数据库设计、业务逻辑映射、依赖分析、离线部署注意事项。
> **生成时间**: 2026-07-13
> **项目阶段**: 制造业智能 CPQ 系统（RuoYi-Vue-Plus 5.6.1）

---

## 零、项目全貌速览

| 维度 | 数据 |
|------|------|
| Java 源文件 | **2,002 个** |
| Vue 组件 | **416 个** |
| SQL 脚本 | **170 个** |
| 设计文档 | **206 个** .md |
| JAR 大小 | **166 MB**（含 320 个依赖） |
| 数据库表 | 61 张 CPQ 业务表 + 21 张系统表 + 13 张其他 |
| 构建 JDK | **26**（本地开发） |
| 目标 JRE | **17+** |

---

## 一、项目源码结构（模块地图）

```
004_CPQ_App/
├── ruoyi-admin 2/           → 启动模块（Spring Boot 入口）
│   └── target/ruoyi-admin.jar  (166MB，预构建)
├── ruoyi-common 2/          → 通用模块（20+ 子模块）
│   ├── ruoyi-common-core/      核心工具
│   ├── ruoyi-common-security/  安全框架（Sa-Token + OAuth2）
│   ├── ruoyi-common-redis/     Redis 封装
│   ├── ruoyi-common-mybatis/   MyBatis-Plus 封装
│   ├── ruoyi-common-tenant/    多租户
│   ├── ruoyi-common-satoken/   Sa-Token 集成
│   ├── ruoyi-common-oss/       MinIO 对象存储
│   ├── ruoyi-common-excel/     EasyExcel 封装
│   ├── ruoyi-common-job/       Quartz 定时任务
│   ├── ruoyi-common-log/       操作日志
│   ├── ruoyi-common-encrypt/   数据加密
│   ├── ruoyi-common-sensitive/ 敏感词过滤
│   ├── ruoyi-common-translation/ 翻译服务
│   ├── ruoyi-common-sms/       SMS 发送
│   ├── ruoyi-common-mail/      邮件
│   ├── ruoyi-common-social/    社交登录
│   └── ...（其余）
├── ruoyi-modules/            → 业务模块
│   ├── ruoyi-system/           系统管理（用户/角色/菜单/部门）
│   ├── ruoyi-generator/        代码生成器
│   ├── ruoyi-job/              定时任务管理
│   ├── ruoyi-workflow/         工作流（warm-flow）
│   ├── ruoyi-demo/             测试 Demo
│   │
│   ├── ruoyi-cpq/              CPQ 核心（配置引擎入口）
│   ├── ruoyi-cpq-config/       产品配置引擎 ★
│   ├── ruoyi-cpq-pricing/      定价引擎 ★
│   ├── ruoyi-cpq-quote/        报价管理 ★
│   ├── ruoyi-cpq-customer/     客户管理
│   ├── ruoyi-cpq-crm/          CRM（商机/合同/订单）
│   ├── ruoyi-cpq-approval/     审批中心
│   ├── ruoyi-cpq-ecn/          工程变更 ★
│   ├── ruoyi-cpq-competitive/  竞品分析
│   ├── ruoyi-cpq-integration/  系统集成
│   ├── ruoyi-cpq-knowledge/    知识库
│   └── ruoyi-cpq-migration/    数据迁移
├── ruoyi-extend/             → 扩展模块
├── cpq-portal/               → 前端门户（Vite + Vue 3 + Element Plus）
└── ruoyi-ui/                 → 管理后台（若依标准 UI）
```

### 核心业务模块速查（★ 标记为重点）

| 模块 | 对应前端路由 | 核心功能 |
|------|------------|----------|
| `ruoyi-cpq-config` | `/configure` | 属性选项加载、约束规则验证、配置选择传播、BOM 展开 |
| `ruoyi-cpq-pricing` | `/pricing` | 价格手册、定价规则、阶梯定价、渠道价格、汇率换算 |
| `ruoyi-cpq-quote` | `/quote` | 报价单 CRUD、报价模板、版本管理、审批提交 |
| `ruoyi-cpq-ecn` | `/ecn` | 变更单创建、变更项管理、影响分析、审批流程 |
| `ruoyi-cpq-crm` | `/crm` | 客户账户、商机、合同、订单 |

---

## 二、依赖全景分析

### 2.1 技术栈分层

```
┌─────────────────────────────────────────┐
│  前端层                                    │
│  Vue 3.5 + Element Plus 2.14 + Vite 8    │
│  Store: Pinia | HTTP: Axios | CSS: UnoCSS │
├─────────────────────────────────────────┤
│  Web 层                                    │
│  Spring MVC 6.2 + Tomcat 10.1             │
│  API 文档: SpringDoc OpenAPI 2.8          │
├─────────────────────────────────────────┤
│  安全层                                    │
│  Sa-Token 1.44 + OAuth2 + JWT            │
│  多租户: ruoyi-common-tenant              │
├─────────────────────────────────────────┤
│  业务层                                    │
│  MyBatis-Plus 3.5 + Dynamic Datasource   │
│  MapStruct 1.6 (DTO 映射)                │
│  Redisson 3.x (分布式锁)                  │
│  Lock4j (方法级分布式锁)                   │
│  Warm-Flow (工作流引擎)                    │
│  AnyLine (低代码数据操作)                   │
├─────────────────────────────────────────┤
│  数据层                                    │
│  MySQL 8.0 (MySQL Connector 9.7)         │
│  Redis 6.0+ (Redisson + Spring Cache)    │
│  MinIO (对象存储)                          │
├─────────────────────────────────────────┤
│  工具层                                    │
│  Hutool 5.8.43 (全能工具集)               │
│  Lombok 1.18.44                           │
│  Jackson 2.21                             │
│  EasyExcel (Excel 导入导出)               │
│  SMS4j (短信)                              │
│  ip2region 3.3 (IP 归属地)                │
│  Velocity 2.x (模板引擎)                   │
│  OSHI (系统监控)                            │
└─────────────────────────────────────────┘
```

### 2.2 关键依赖版本（从 JAR 提取）

| 依赖 | 版本 | 说明 |
|------|------|------|
| Spring Boot | **3.5.14** | 若依封装在 ruoyi-common-spring-boot-starter |
| Spring Framework | **6.2.18** | |
| Sa-Token | **1.44.x** | 替代 Spring Security / Shiro |
| MyBatis-Plus | **3.5.x** | 含 jsqlparser 5.0 |
| MySQL Connector | **9.7.0** | 9.x 系（已知与旧版 JDBC URL 参数兼容性问题） |
| Redisson | **3.x** | 分布式锁 + Redis 高级数据结构 |
| SpringDoc OpenAPI | **2.8.17** | 替代 Knife4j，可使用 Swagger UI |
| MapStruct | **1.6.3** | 编译期生成 Bean 映射代码 |
| Dynamic Datasource | **4.x** | 多数据源动态切换 |
| Warm-Flow | **1.x** | 国产工作流引擎 |
| AnyLine | **8.x** | JDBC 增强（免写 SQL） |
| EasyExcel | **4.x** | 阿里 Excel 工具 |
| Sms4j | **3.x** | 多通道短信 |
| ip2region | **3.3.7** | IP 归属地离线查询 |

### 2.3 Maven 依赖树获取方法

当前 JAR 是预构建的，没有 Maven 本地仓库缓存。要获取完整依赖树：

```bash
# 方法1: 从 POM 生成（如果有完整源码）
cd ruoyi-admin
mvn dependency:tree -DoutputFile=/tmp/deps.txt

# 方法2: 从 JAR 提取 classpath.idx（快速，但只有文件名）
unzip -p ruoyi-admin.jar BOOT-INF/classpath.idx

# 方法3: 深度分析（列出所有依赖版本）
jar tf ruoyi-admin.jar | grep "BOOT-INF/lib/" | \
  sed 's|BOOT-INF/lib/||' | sort > /tmp/deps-list.txt
```

---

## 三、数据库设计（反向工程）

### 3.1 数据库信息

| 配置项 | 值 |
|--------|-----|
| 数据库名 | `Ruoyi_CPQ` |
| 字符集 | utf8mb4 |
| 表总数 | 95（61 CPQ + 21 系统 + 13 其他/工作流/测试） |
| DDL 导出 | `/tmp/cpq_tables_ddl.sql`（1,050 行） |

### 3.2 CPQ 核心表（按业务流程分组）

#### 产品主数据

| 表 | 说明 | 关键字段 |
|----|------|----------|
| `cpq_product_model` | 产品型号 | model_id, model_code, model_name, category_id, unit_price |
| `cpq_product_attribute` | 产品可配置属性 | attribute_id, model_id, attr_name, attr_type, required |
| `cpq_attribute_option` | 属性可选值 | option_id, attribute_id, option_value, option_label, price_adjust |
| `cpq_product_category` | 产品分类 | category_id, category_name, parent_id |
| `cpq_product_catalog` | 产品目录 | catalog_id, catalog_name |
| `cpq_product_variant` | 产品变体（配置组合固化） | variant_id, model_id, config_snapshot |
| `cpq_product_supersession` | 产品替代关系 | from_model_id, to_model_id, effective_date |
| `cpq_product_lifecycle_log` | 产品生命周期日志 | model_id, from_status, to_status, change_reason |

#### 配置引擎

| 表 | 说明 | 关键字段 |
|----|------|----------|
| `cpq_config_rule` | 配置约束规则（30 条） | rule_id, model_id, rule_type, rule_expr, severity |
| `cpq_attribute_mapping` | 属性→物料映射 | mapping_id, attribute_id, option_value, material_code |
| `cpq_config_snapshot` | 配置快照（用户保存的配置） | snapshot_id, model_id, config_json, user_id |
| `cpq_compatibility_matrix` | 兼容性矩阵 | matrix_id, component_a, component_b, compatible |

#### 物料清单（BOM）

| 表 | 说明 | 关键字段 |
|----|------|----------|
| `cpq_sbom_header` | 标准 BOM 头 | sbom_id, model_id, bom_version, effective_date |
| `cpq_sbom_line` | 标准 BOM 行 | sbom_line_id, sbom_id, material_code, quantity, unit |
| `cpq_mbom_line` | 制造 BOM（配置展开后） | mbom_line_id, quote_line_id, material_code, quantity |
| `cpq_variant_bom` | 变体 BOM | variant_id, material_code, quantity |

#### 定价引擎

| 表 | 说明 | Mock 数据 |
|----|------|-----------|
| `cpq_price_book` | 价格手册 | 1 本 |
| `cpq_price_book_entry` | 价格条目 | 99+ 条 |
| `cpq_price_rule` | 定价规则 | 3 条 |
| `cpq_volume_tier` | 阶梯定价 | 5 条（LF280K） |
| `cpq_channel_price` | 渠道价格 | 2 条 |
| `cpq_agreement_price` | 协议价格 | — |
| `cpq_currency_rate` | 汇率配置 | — |

#### 报价管理

| 表 | 说明 | Mock 数据 |
|----|------|-----------|
| `cpq_quote` | 报价单头 | 7 条 |
| `cpq_quote_line_item` | 报价单行 | — |
| `cpq_quote_template` | 报价模板 | 3 条 |
| `cpq_quote_version` | 报价版本 | — |

#### CRM

| 表 | 说明 | Mock 数据 |
|----|------|-----------|
| `cpq_account` | 客户账户 | 6 条 |
| `cpq_crm_opportunity` | 商机 | 6 条 |
| `cpq_crm_contract` | 合同 | — |
| `cpq_crm_order` | 订单头 | — |
| `cpq_crm_order_line` | 订单行 | — |
| `cpq_crm_activity` | 活动记录 | — |
| `cpq_channel` | 销售渠道 | — |
| `cpq_territory` | 销售区域 | — |

#### 工程变更（ECN）

| 表 | 说明 | Mock 数据 |
|----|------|-----------|
| `cpq_ecn_change_order` | 变更单 | 3 条 |
| `cpq_ecn_change_item` | 变更项 | — |
| `cpq_ecn_approval` | 变更审批 | — |
| `cpq_ecn_impact_analysis` | 影响分析 | — |

#### 审批与系统

| 表 | 说明 |
|----|------|
| `cpq_approval_rule` | 审批规则 |
| `cpq_approval_chain` | 审批链 |
| `cpq_approval_record` | 审批记录 |
| `cpq_approval_matrix` | 审批矩阵 |
| `cpq_system_config` | 系统配置 |
| `cpq_sync_log` | 数据同步日志 |
| `cpq_migration_task` / `cpq_migration_log` / `cpq_migration_mapping` | 数据迁移 |
| `cpq_integration_config` / `cpq_integration_mapping` | 系统集成 |
| `cpq_knowledge_article` | 知识库 |
| `cpq_solution_document` | 方案文档 |
| `cpq_recommendation` | 推荐配置 |
| `cpq_competitor` / `cpq_competitor_product` | 竞品分析 |
| `cpq_plant` | 工厂/产线 |
| `cpq_abac_policy` | ABAC 权限策略 |
| `cpq_comparison` | 配置对比 |
| `cpq_bundle` / `cpq_bundle_option` / `cpq_bundle_option_group` | 捆绑包 |

#### 系统表（若依框架）

`sys_user`, `sys_role`, `sys_menu`, `sys_dept`, `sys_dict_data`, `sys_dict_type`, `sys_config`, `sys_notice`, `sys_oss`, `sys_tenant`, `sys_tenant_package`, `sys_client`, `sys_post`, `sys_logininfor`, `sys_oper_log` 等 21 张表。

#### 工作流表（warm-flow）

`flow_definition`, `flow_instance`, `flow_task`, `flow_his_task`, `flow_node`, `flow_skip`, `flow_spel`, `flow_user`, `flow_category`, `flow_instance_biz_ext` 等 10 张表。

### 3.3 如何获取完整 DDL

已从运行库导出核心表 DDL 到 `/tmp/cpq_tables_ddl.sql`（1,050 行）。如需完整建库脚本：

```bash
# 完整导出（含索引、约束、自增设置）
export PATH="/usr/local/mysql/bin:$PATH"
mysqldump -u root -pStorm123@ --no-data --routines --triggers \
  Ruoyi_CPQ > /tmp/cpq_full_schema.sql

# 仅 CPQ 业务表
mysqldump -u root -pStorm123@ --no-data Ruoyi_CPQ \
  $(mysql -u root -pStorm123@ Ruoyi_CPQ -N -e "SHOW TABLES LIKE 'cpq%'") \
  > /tmp/cpq_business_schema.sql
```

---

## 四、业务逻辑映射（前端 → 后端 → 数据库）

### 4.1 产品配置流程

```
前端(cpq-portal)                    后端(ruoyi-cpq-config)           数据库
─────────────                      ──────────────────────           ──────
选择产品                           /cpq/configure/model/{id}       cpq_product_model
  │                                    │                              │
  ▼                                    ▼                              ▼
加载可配置属性                     查询 product_attribute           cpq_product_attribute
  │                                    │                              │
  ▼                                    ▼                              ▼
展示选项列表                       查询 attribute_option           cpq_attribute_option
  │                                    │                              │
  ▼                                    ▼                              ▼
用户勾选选项 ──POST──→            /cpq/configure/validate          cpq_config_rule
  │                               ├─ 约束规则校验                   (rule_expr 列)
  │                               └─ 兼容性检查                     cpq_compatibility_matrix
  │                                    │
  ▼                                    ▼
查看实时价格                       /cpq/configure/complete         cpq_price_book_entry
  │                               ├─ 基础价格 + 选项增价             cpq_volume_tier
  │                               └─ 阶梯折扣计算                   cpq_channel_price
  │                                    │
  ▼                                    ▼
BOM 展开预览 ──POST──→            /cpq/configure/bom-preview       cpq_sbom_line
  │                               ├─ 属性→物料映射                  cpq_attribute_mapping
  │                               └─ 数量 × BOM 行展开             cpq_mbom_line
```

### 4.2 报价创建流程

```
前端                              后端(ruoyi-cpq-quote)            数据库
───                               ────────────────────             ──────
选择客户                          客户搜索接口                      cpq_account
  │                                                                
  ▼                                                                
选择配置(带入)                     POST /cpq/quote/header           cpq_quote
  │                               ├─ 生成报价单号                  (quote_number)
  │                               └─ 关联客户+配置快照              cpq_config_snapshot
  │                                                                
  ▼                                                                
添加行项目                        POST /cpq/quote/line             cpq_quote_line_item
  │                               ├─ 关联 BOM 行                   cpq_mbom_line
  │                               └─ 计算行金额                    (quantity × unit_price)
  │                                                                
  ▼                                                                
报价预览/生成 PDF                 GET quote/{id}/preview           cpq_quote_template
  │                               └─ Velocity 模板渲染
  │                                                                
  ▼                                                                
提交审批                          POST quote/{id}/submit           cpq_approval_rule
                                  └─ 触发 warm-flow 工作流         flow_instance
```

### 4.3 ECN 变更流程

```
变更单创建                        POST /cpq/ecn/order              cpq_ecn_change_order
  │                               ├─ 选择受影响产品                cpq_product_model
  │                               └─ 填写变更原因
  │                                                                
  ▼                                                                
添加变更项                        POST /cpq/ecn/item               cpq_ecn_change_item
  │                               ├─ 替换物料/属性                 cpq_attribute_mapping
  │                               └─ 生效日期                      cpq_sbom_line
  │                                                                
  ▼                                                                
影响分析                          GET /cpq/ecn/impact/{id}         cpq_ecn_impact_analysis
  │                               ├─ 关联报价单查询                cpq_quote
  │                               └─ 关联 BOM 查询                 cpq_mbom_line
  │                                                                
  ▼                                                                
审批                              POST /cpq/ecn/approve            cpq_ecn_approval
                                  └─ warm-flow 审批链              flow_instance
```

---

## 五、认证与权限

### 5.1 认证流程

Sa-Token + OAuth2 模式：

```
登录 POST /auth/login
  ↓
验证: admin / admin123
  ↓
生成 access_token (JWT) + refresh_token
  ↓
前端存储: localStorage('cpq_token')
  ↓
每次请求带 Header:
  - clientid: e5cd7e4891bf95d1d19206ce24a7b32e
  - Authorization: Bearer {token}
```

### 5.2 多租户隔离

本系统使用若依多租户版，tenantId = `000000`。所有 CPQ 业务表包含 `tenant_id` 字段用于数据隔离。

---

## 六、已知缺口（诚实记录）

### 6.1 🔴 无法确认的项

| 项目 | 说明 | 影响 |
|------|------|------|
| **JAR 构建方式** | ruoyi-admin.jar 是甲方提供的成品，本地无 Maven 构建记录。`mvn clean package` 是否成功未验证 | 修改 Java 代码后可能无法重新打包 |
| **MySQL 原始 DDL** | 数据库是之前建好的，无原始 `init.sql` 脚本 | 新环境部署需从运行库反向导出 |
| **甲方 Linux 环境** | 具体的内核版本、glibc 版本、是否已安装 JDK/Node 未知 | 无法预先准备部署策略 |
| **原生模块兼容性** | sass-embedded、rolldown 等原生模块在离线跨架构场景下未验证 | 部署到 Linux 可能编译失败 |

### 6.2 🟡 已验证但需注意的项

- **NODE_ENV 陷阱**：PM2 环境设置了 `NODE_ENV=production`，导致 `npm install` 跳过 devDependencies。`ruoyi-ui` 的 Vite/TypeScript 等构建工具全部在 devDependencies 中，必须显式 `NODE_ENV=development npm install`
- **Snowflake ID 精度**：19 位 Snowflake ID 超过 `Number.MAX_SAFE_INTEGER`，11 个 Vue 文件中仍有 `Number(route.params.*)` 需改成 `String()`
- **MySQL Connector 9.7 vs 8.0**：Connector 9.x 与部分旧版 JDBC URL 参数不兼容（如 `useSSL` 已被移除）

---

## 七、离线 node_modules 跨平台部署指南

### 7.1 问题本质

Node.js 原生模块（.node 文件）是**平台相关的二进制**，不同 OS（macOS/Linux）不同架构（arm64/x64）编译产物不通用。

CPQ App 前端受影响的模块：

| 模块 | 用途 | 是否有原生二进制 |
|------|------|:---:|
| `sass-embedded` | SCSS 编译 | ✅ dart-sass 二进制 |
| `rolldown` | Vite 打包（部分场景） | ✅ Rust 编译产物 |
| `esbuild` | Vite 预构建 | ✅ Go 编译产物 |
| `@parcel/watcher` | 文件监听 | ✅ 原生模块 |

### 7.2 推荐方案：平台独立打包

```bash
# 方案A: 在目标平台（Linux）上执行 npm install（最可靠）
# 将 package.json + package-lock.json 上传到目标服务器后执行：
NODE_ENV=development npm ci

# 方案B: 跨平台离线包（需要 Docker）
# 在 macOS 上模拟 Linux arm64 环境
docker run --rm -v $(pwd):/app -w /app \
  --platform linux/arm64 node:22-alpine \
  sh -c "npm ci"

# 方案C: 使用 pnpm（更好的跨平台支持）
pnpm install --frozen-lockfile
# pnpm 使用硬链接 + content-addressable store，跨平台问题更少
```

### 7.3 验证清单

在目标环境运行后检查：

```bash
# 1. 检查是否有 .node 文件
find node_modules -name "*.node" -type f | wc -l

# 2. 验证原生模块可加载
node -e "require('sass-embedded'); console.log('sass-embedded OK')"
node -e "require('esbuild'); console.log('esbuild OK')"

# 3. 尝试完整构建
NODE_ENV=development npm run build
```

### 7.4 Vite 8 特别注意事项

Vite 8 默认使用 **Rolldown**（Rust 实现）替代部分 Rollup 功能。在离线环境下，Rolldown 的原生模块需要：
- Linux: glibc ≥ 2.28（CentOS 7 不支持，需 CentOS 8+/Ubuntu 20.04+）
- macOS: macOS ≥ 12
- 如果目标环境不支持 Rolldown，可通过 `vite.config.ts` 降级：

```ts
// vite.config.ts
export default defineConfig({
  experimental: {
    enableNativeDepsPrebundling: false  // 回退到 esbuild
  }
})
```

---

## 八、部署速查

### 8.1 当前本地环境

| 服务 | 方式 | 命令 |
|------|------|------|
| 后端 | JAR 直接运行 | `java -jar ruoyi-admin.jar --server.port=30000` |
| cpq-portal | PM2 + Vite | `pm2 start node --name cpq-portal --cwd cpq-portal -- ./node_modules/.bin/vite --port 3000 --host 0.0.0.0` |
| ruoyi-ui | PM2 + Vite | `pm2 start node --name cpq-admin-ui --cwd ruoyi-ui -- ./node_modules/.bin/vite --port 2999 --host 0.0.0.0` |
| MySQL | 系统服务 | `/usr/local/mysql/bin/mysqld`（开机自启） |
| Redis | Homebrew | `redis-server --requirepass ruoyi123` |

### 8.2 测试机部署

- IP: 100.119.232.95
- SSH: `ssh mac@100.119.232.95` (密码: 1234)
- 部署路径: `/Users/mac/Downloads/cpq_app/`
- Git Tag: `deploy-test-20260703`
- LaunchAgent plist: `~/Library/LaunchAgents/com.cpq.*.plist`
- 详情见: `DEPLOY_LOG.md`

---

## 九、快速上手指南（10分钟）

```bash
# 1. 切换分支
cd "iCloud Drive/创新万维/0004. platform_dev/004_CPQ_App"
git checkout manong_20260702_ver

# 2. 确认环境
java -version                    # JDK 17+
node -v                          # v22+
export PATH="/usr/local/mysql/bin:$PATH"
mysqladmin -u root -pStorm123@ ping   # 应返回 alive
redis-cli -a ruoyi123 ping            # 应返回 PONG

# 3. 启动后端（如未运行）
java -jar "ruoyi-admin 2/target/ruoyi-admin.jar" --server.port=30000 &

# 4. 启动前端
cd cpq-portal && NODE_ENV=development npm install && npm run dev &  # :3000
cd ruoyi-ui && NODE_ENV=development npm install && npm run dev &    # :2999

# 5. 验证
curl http://localhost:30000/api/health
open http://localhost:3000
```

---

## 十、继续深入的方向

| 方向 | 操作 | 产出 |
|------|------|------|
| 源码阅读 | 从 `ruoyi-cpq-config/controller` 开始，追踪配置验证 → BOM 展开链路 | 核心链路时序图 |
| 数据库深入 | `mysqldump --no-data Ruoyi_CPQ > schema.sql` 生成完整建库脚本 | 可部署的 DDL |
| 依赖审计 | 在源码目录运行 `mvn dependency:tree` 或分析 JAR classpath.idx | 版本冲突清单 |
| 部署验证 | SSH 到测试机 100.119.232.95，确认 JDK/Node 版本 | 环境兼容性矩阵 |
| E2E 测试 | 用 Playwright 录制"搜索产品→配置→报价→审批"完整流程 | 回归测试脚本 |
