# STATUS.md — CPQ App 项目交接文档

> **目的**：读完本文档即可理解项目全貌、恢复开发环境、继续干活。
> 最后更新: 2026-07-22 11:30（quoteId 修复 + feat 分支 + 交接）

---

## 一、项目概述

| 项目 | 内容 |
|------|------|
| **名称** | 制造业智能 CPQ 系统（配置-定价-报价） |
| **代号** | 004_CPQ_App |
| **技术栈** | Spring Boot 3.5.14 + Vue 3 + TypeScript + Element Plus |
| **基础框架** | RuoYi-Vue-Plus 5.6.1（多租户版） |
| **数据库** | MySQL 8.0+ |
| **缓存** | Redis 6.0+ (密码 `ruoyi123`) |
| **存储** | MinIO |
| **Java** | JDK 17+（本机 JDK 26） |
| **Node** | v22.19.0 |
| **Maven** | 3.x |
| **项目路径** | `iCloud Drive/创新万维/0004. platform_dev/004_CPQ_App/` |
| **Git 分支** | `manong_20260702_ver`（主）/ `feat/fix-quote-api`（今日修复） |
| **最新 Commit** | `188ad07b1`（2026-07-22） |

---

## 二、环境信息

### 2.1 本地开发机

| 配置项 | 值 |
|--------|-----|
| 本机 IP | 172.16.1.115 |
| 本机 hostname | localhost (macOS arm64) |
| JDK 路径 | `/Library/Java/JavaVirtualMachines/jdk-26.jdk/Contents/Home` |
| node/npm | `/usr/local/bin/` |
| MySQL | root / Storm123@ |
| Redis | 密码 `ruoyi123` |

### 2.2 远程测试机

| 配置项 | 值 |
|--------|-----|
| IP | 100.119.232.95 |
| SSH | `ssh mac@100.119.232.95`（密码: 1234） |
| 部署路径 | `/Users/mac/Downloads/cpq_app/` |
| Git Tag | `deploy-test-20260703` |

---

## 三、架构概览

```
┌─────────────────────────────────────────────────────┐
│  cpq-portal (Vite, :3000)   前端门户（CPQ业务）       │
│  ruoyi-ui (Vite, :2999)     管理后台（系统管理）       │
└─────────────┬───────────────────────────────────────┘
              │ REST API
┌─────────────▼───────────────────────────────────────┐
│  ruoyi-admin (Spring Boot, :30000)                  │
│  ├── 认证: Sa-Token + OAuth2                        │
│  ├── ORM: MyBatis-Plus                              │
│  ├── 核心模块:                                       │
│  │   ├── cpq-product     产品模型管理                │
│  │   ├── cpq-configure    配置引擎                    │
│  │   ├── cpq-price        定价引擎                    │
│  │   ├── cpq-quote        报价管理                    │
│  │   ├── cpq-customer     CRM客户                    │
│  │   └── cpq-ecn          工程变更管理                │
│  └── 接口文档: http://localhost:30000/swagger-ui.html │
├─────────────────────────────────────────────────────┤
│  MySQL 8.0+ (:3306)  │  Redis (:6379)  │  MinIO      │
└──────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────┐
│  CPQ Agent Skill (EasyClaw)                          │
│  ├── 位置: workspace-manong/skills/cpq-agent/        │
│  ├── 用途: 自然语言 → 配置 → BOM → 报价（AI编排层） │
│  └── 后端: http://localhost:30000 (同上后端)         │
└─────────────────────────────────────────────────────┘
```

---

## 四、服务启动 / 停止

### 4.1 本地开发

```bash
# 1. 启动 MySQL（系统级开机自启，通常已运行）
# 2. 启动 Redis（系统级开机自启）
redis-server --requirepass ruoyi123 &

# 3. 启动后端（IDE 运行或 JAR）
cd "iCloud Drive/创新万维/0004. platform_dev/004_CPQ_App"
mvn clean package -pl ruoyi-admin -am -DskipTests  # 构建
java -jar ruoyi-admin/target/ruoyi-admin.jar         # 运行

# 4. 启动前端门户
cd cpq-portal && npm run dev       # Vite :3000

# 5. 启动管理后台（可选）
cd ruoyi-ui && npm run dev         # Vite :2999
```

### 4.2 服务端口与状态

| 服务 | 端口 | 本地 | 测试机 |
|------|------|------|--------|
| cpq-portal（前端门户） | 3000 | ✅ | ✅ |
| ruoyi-admin（Java后端） | 30000 | ✅ | ✅ |
| ruoyi-ui（管理后台） | 2999 | ❌ 未启动 | ✅ |
| MySQL | 3306 | ✅ | ✅ |
| Redis | 6379 | ✅ | ✅ |

### 4.3 测试机部署

测试机使用 LaunchAgent 开机自启，plist 位于：
- `~/Library/LaunchAgents/com.cpq.ruoyi-admin.plist`
- `~/Library/LaunchAgents/com.cpq.portal.plist`
- `~/Library/LaunchAgents/com.cpq.admin-ui.plist`

部署流程参考 `DEPLOY_LOG.md`。

---

## 五、数据库

### 5.1 连接信息

| 配置 | 值 |
|------|-----|
| Host | localhost:3306 |
| 用户 | root |
| 密码 | Storm123@ |
| 数据库 | ruoyi-vue-plus（多租户，tenantId=000000） |

### 5.2 核心表

| 模块 | 表名前缀 | 说明 |
|------|----------|------|
| 产品模型 | `cpq_product_model` | 产品型号、描述、价格 |
| 属性定义 | `cpq_product_attribute` | 产品可配置项 |
| 属性选项 | `cpq_attribute_option` | 每个属性的可选值 |
| 配置规则 | `cpq_config_rule` | 30 条约束规则 |
| 属性映射 | `cpq_attribute_mapping` | 属性值→物料映射 |
| SBOM | `cpq_sbom_header` / `cpq_sbom_line` | 标准物料清单 |
| MBOM | `cpq_mbom_line` | 生产物料清单（配置展开后） |
| 价格手册 | `cpq_price_book` / `cpq_price_entry` | 价格条目 |
| 定价规则 | `cpq_pricing_rule` | 3 条 Mock |
| 阶梯定价 | `cpq_tier_price` | 5 条 Mock (LF280K) |
| 渠道价格 | `cpq_channel_price` | 2 条 Mock |
| 报价单 | `cpq_quote_header` / `cpq_quote_line` | 报价管理 |
| 报价模板 | `cpq_quote_template` | 3 条 Mock |
| CRM 客户 | `cpq_customer_account` | 6 条 Mock |
| CRM 商机 | `cpq_crm_opportunity` | 6 条 Mock |
| ECN变更 | `cpq_ecn_header` / `cpq_ecn_item` | 3 条 Mock |

### 5.3 关键产品 ID

| 产品编码 | modelId | 容量 | 类型 |
|----------|---------|------|------|
| EVE-HVI-40.0 | 2091 | 40.96 kWh | 高压壁挂（德国市场主力） |
| EVE-LVI-5.0 | 2063 | 5.12 kWh | 低压壁挂 |
| EVE-LVI-10.0-P | 2067 | 10.24 kWh | 低压加强版 |
| EVE-LVI-20.0 | 2069 | 20.48 kWh | 低压大容量 |

---

## 六、API 认证

### 6.1 获取 Token

```bash
TOKEN=$(curl -s -X POST 'http://localhost:30000/auth/login' \
  -H 'Content-Type: application/json' \
  -d '{
    "username":"admin",
    "password":"admin123",
    "clientId":"e5cd7e4891bf95d1d19206ce24a7b32e",
    "grantType":"password",
    "tenantId":"000000"
  }' | python3 -c "import sys,json; print(json.load(sys.stdin)['data']['access_token'])")
```

### 6.2 请求格式

所有 API 请求需带 Header：
- `clientid: e5cd7e4891bf95d1d19206ce24a7b32e`
- `Authorization: Bearer {token}`

前端登录通过 `cpq_token` (localStorage) + `clientid` header 自动管理。

---

## 七、核心 API (CPQ 业务)

| 端点 | 方法 | 用途 |
|------|------|------|
| `/cpq/product/model/search?keyword={}` | GET | 搜索产品 |
| `/cpq/configure/model/{modelId}` | GET | 加载配置模型 |
| `/cpq/configure/validate?modelId={}` | POST | 验证配置选择 |
| `/cpq/configure/complete?modelId={}&quantity={}` | POST | 完成配置+定价 |
| `/cpq/configure/guide?modelId={}` | POST | 向导推荐 |
| `/cpq/configure/bom-preview?modelId={}` | POST | BOM 预览 |
| `/cpq/configure/bom-preview?modelId={}` | POST | BOM 预览 |
| `/cpq/engine/config/propagate?modelId={}` | POST | 约束传播 |
| `/cpq/customer/account/list` | GET | CRM 客户列表 |
| `/cpq/crm/opportunity/list` | GET | CRM 商机列表 |
| `/cpq/quote/header` | POST | 创建报价单 |

完整 Swagger 文档: `http://localhost:30000/swagger-ui.html`

---

## 八、测试进度与模块状态

| 模块 | 状态 | 备注 |
|------|------|------|
| 价格手册 | ✅ | 1 本手册，99+ 条目 |
| 定价规则 | ✅ | 3 条 Mock 规则 |
| 阶梯定价 | ✅ | 5 条 Mock 阶梯（LF280K） |
| 渠道价格 | ✅ | 2 条 Mock 渠道价 |
| 汇率配置 | — | 页面存在，未测 |
| 配置规则(门户) | ✅ | 页面正常 |
| BOM 管理 | ✅ | 需选择产品 |
| 标准配置 | ✅ | 四步流程已测 |
| 向导式配置 | ✅ | 五步流程已测 |
| 三栏配置器 | ✅ | 已测 |
| ATO 配置 | ✅ | 页面存在 |
| CRM 客户 | ✅ | 6 条，列表展示正常 |
| CRM 商机 | ✅ | 6 条，同上 |
| 报价单 | ✅ | 7 条 + P01 客户 ID 下拉搜索 |
| 报价模板 | ✅ | 3 条 Mock，前后端验证通过 |
| ECN 变更管理 | ✅ | 3 条 Mock，前后端验证通过 |
| 审批中心 | ❌ | **未开发** |
| **CPQ Agent Skill** | ✅ | 自然语言→配置→BOM→报价 30s 全链路跑通 |

---

## 九、已知问题（Bug / 技术债）

### 9.0 ✅ 已修复：创建报价不返回 quoteId + itemName 缺失（2026-07-22）

- `CpqQuoteController.add()` 返回 `R<Long>`，前端可获取新增报价 ID
- `CpqQuoteLineItemServiceImpl` 行项目创建时自动从产品填充 `itemName`
- `selectMaxLineNumber` 增加 `IFNULL` 空值保护
- 5 文件改动，commit `188ad07b1`，已推 `feat/fix-quote-api` 分支

### 9.1 🔴 P1：Snowflake ID JS 精度丢失

- **现象**：19 位 Snowflake ID 超出 `Number.MAX_SAFE_INTEGER`，`Number(route.params.id)` 丢失精度，导致页面取不到数据
- **根因**：Vue Router params 被 `Number()` 转换后精度丢失
- **影响文件**：**13 个 Vue 文件** 受影响
- **已修复**：ImpactAnalysis.vue、ChangeApproval.vue（ECN 相关 2 个）
- **待修复**：剩余 **11 个文件**，需全局替换 `Number(route.params.*)` → `String(route.params.*)`
- **验证方法**：`grep -rn "Number(route.params" cpq-portal/src/`

### 9.2 🟡 P2：前端列表显示问题（已修复）

- 之前 API 返回正确（6客户/6商机/7报价），但前端搜索传参导致显示"暂无数据"
- Commit `2b83b302b` 已修复

### 9.3 🟡 P3：审批中心未开发

- 页面菜单存在，后端接口未实现

---

## 十、开发铁律（踩坑教训）

> 来源：MEMORY.md 中沉淀的 CPQ App 开发经验

1. **axios 响应解包**：拦截器统一返回 `{rows, total}`，Vue 组件必须用 `res.rows || res.data || []`，不要直接取 `res`
2. **Snowflake ID**：19 位 ID 超 JS 精度，一律用 `String(route.params.id)`，**禁止** `Number()`
3. **status 字段**：数据库 CHAR(1)，取值 `'0'` / `'1'`，不要传 `'ACTIVE'` 等字符串
4. **代码提交**：所有改动已提交（`188ad07b1`），已推 `manong_20260702_ver` + `feat/fix-quote-api`
5. **GitHub 推送**：IPv6 不通，必须加 `-4` 参数 `git push -4 github <branch>`
6. **Docker 生产环境**：`root@8.148.208.235`，需通过跳板机 `mac@100.119.232.95` 中转
7. **交接文档**：workspace-manong/CPQ_HANDOVER.md（新 Agent 即看即上手）

---

## 十一、关键文档索引

| 文档 | 路径 |
|------|------|
| **本文档** | `STATUS.md`（项目根目录） |
| 部署日志 | `DEPLOY_LOG.md` |
| 产品设计文档 (8份) | `001_Product Design Docs/` |
| Mock 数据 | `Mock Data/` (M-CPQ + M-CPQ_EVE) |
| 测试报告 | 飞书 `OiekdKbH2oVaJDxgM31cYjzcnVe` |
| 用户场景说明书 | 飞书 `PLKsbQnjeofTNSxo0Kxcl4gTn3d` + 本地 `cpq_app_user_scenario.md` |
| CPQ Agent Skill | `workspace-manong/skills/cpq-agent/SKILL.md` |
| 项目持久记忆 | `workspace-manong/MEMORY.md` |

---

## 十二、已知问题清单（2026-07-20 产品评审新增）

| # | 任务ID | 问题 | 优先级 |
|:--:|------|------|:--:|
| 1 | CPQAPP-006 | 配置审阅页无"生成报价单"按钮，配置结果无法直接生成报价单 | 🔴 P0 |
| 2 | CPQAPP-007 | 配置快照 API 存在但从未调用，配置结果刷新即丢失 | 🟡 P1 |
| 3 | CPQAPP-008 | 报价单行项目不写入 configurationJson/customRequirements | 🟡 P1 |
| 4 | CPQAPP-009 | BOM物料成本写死为 0，成本校验无效 | 🟡 P1 |
| 5 | CPQAPP-010 | 报价单生成时不重算定价（channel/region/quantity 缺失） | 🟢 P2 |
| 6 | CPQAPP-011 | 报价单行项目需手动逐行添加，无批量导入 | 🟡 P1 |
| 7 | CPQAPP-012 | 产品目录搜索对型号编码（ER14505/EVE等）匹配失效 | 🟢 P2 |
| 8 | CPQAPP-013 | MBOM 覆盖写入导致多用户会话数据互相覆盖 | 🟢 P2 |
| 9 | CPQAPP-014 | 新增报价单表单缺少客户搜索和数量输入 | 🟡 P1 |

> 详见 `001_Product Design Docs/CPQ_开发任务清单.md` 任务 5-13

## 十四、快速上手（新开发者 10 分钟启动）

```bash
# 1. 进入项目目录
cd "/Users/mac/Library/Mobile Documents/com~apple~CloudDocs/创新万维/0004. platform_dev/004_CPQ_App"

# 2. 确保 MySQL 和 Redis 运行
# MySQL: root / Storm123@
# Redis: requirepass ruoyi123

# 3. 启动后端
mvn clean package -pl ruoyi-admin -am -DskipTests
java -jar ruoyi-admin/target/ruoyi-admin.jar

# 4. 启动前端（新终端）
cd cpq-portal && npm install && npm run dev

# 5. 访问
# 前端门户: http://localhost:3000
# API 文档: http://localhost:30000/swagger-ui.html
# 登录: admin / admin123
```
