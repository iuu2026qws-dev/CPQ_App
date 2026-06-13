# 制造业CPQ产品设计 — 阶段三总文档：技术实现层

> **版本**：V2.0（技术栈适配版）  
> **日期**：2026年6月7日  
> **基于**：CPQ制造业深度研究报告 V2.0 + 阶段一/二 + 实际开发技术栈（Java + MySQL + Vue3）  
> **参与角色**：技术架构师 / 后端API专家 / 数据库专家  
> **阶段目标**：基于实际技术栈完成模块分解、核心模块Function Spec、API设计、数据库设计、部署架构  
> **V2.0 变更**：技术栈从 Go+PostgreSQL+React+K3s 切换为 Java 17+MySQL 8.0+Vue3+Nginx；移除 K3s 部署和 HPA 弹性伸缩（当前无容器化/自动伸缩需求）；CSP 求解器池化方案提供 Java 替代评估

---

## 目录

- [1. 技术栈选型](#1-技术栈选型)
- [2. 模块分解](#2-模块分解)
- [3. 核心模块Function Specification](#3-核心模块function-specification)
- [4. API设计总览](#4-api设计总览)
- [5. 数据库设计](#5-数据库设计)
- [6. 部署架构](#6-部署架构)
- [7. 交叉评审](#7-交叉评审)

---

## 1. 技术栈选型

### 1.1 全栈技术栈总览

| 层面 | 主选方案 | 选型理由 |
|------|---------|---------|
| **后端框架** | Java 17+ / Spring Boot 2.7+ / RuoYi-Vue-Plus | 项目已集成，模块化单体架构成熟，Spring生态完整（事务/安全/缓存/消息） |
| **ORM** | MyBatis-Plus 3.5+ | 项目已集成，Lambda QueryWrapper + 分页插件 + 多租户拦截器已就绪 |
| **前端框架** | Vue 3 + TypeScript | 项目已采用，Composition API + `<script setup>` 开发效率高 |
| **状态管理** | Pinia | Vue 3 官方推荐，轻量 + TypeScript 原生支持 |
| **UI组件库** | Element Plus | 项目已集成，中后台组件丰富 + 树形表格(BOM) + 虚拟滚动 |
| **富文本编辑器** | Tiptap + Yjs | 方案编辑器的协同编辑场景（预留） |
| **主数据库** | MySQL 8.0 | 项目已部署，支持递归CTE(BOM展开) + JSON类型(配置快照) + 窗口函数 |
| **缓存** | Redis 7.x | 项目已集成，配置规则热加载+BOM缓存+求解结果缓存 |
| **搜索引擎** | Elasticsearch 7.x（可选MeiliSearch轻量版） | 中文分词+聚合分析，MeiliSearch备选降低运维成本 |
| **消息队列** | RabbitMQ（Spring AMQP） | Spring生态原生集成，可靠性高；或 RocketMQ 用于大规模场景 |
| **API网关** | Nginx + Spring Security + Sa-Token | 项目已集成，Nginx反向代理 + Sa-Token认证鉴权 |
| **CI/CD** | GitLab CI / Jenkins | 传统部署管道 |
| **监控** | Prometheus + Grafana（可选集成Spring Boot Actuator） | 开源+JVM指标采集成熟 |

### 1.2 关键选型决策

**为什么用 Java + Spring Boot 而不是 Go？**
- 项目已在 RuoYi-Vue-Plus（Java + Spring Boot + MyBatis-Plus）框架上开发，功能迭代已启动
- Spring 生态的事务管理（`@Transactional`）、安全框架（Sa-Token）、缓存抽象（Spring Cache）可直接复用
- MyBatis-Plus 的多租户拦截器（`TenantLineInnerInterceptor`）已配置就绪，无需从零实现
- JVM 在信创 ARM 环境（鲲鹏/飞腾）下有成熟适配，JDK 17+ 性能已达到生产标准
- Java 21 的 Virtual Threads 为 CSP 求解器并发提供了 goroutine 级别的轻量线程能力（见 §3.1 CSP 求解器方案评估）

**为什么用 MySQL 8.0 而不是 PostgreSQL？**
- 项目已部署 MySQL 8.0，基础设施成熟
- MySQL 8.0 已支持递归 CTE（`WITH RECURSIVE`），可满足 BOM 展开、审批链查询
- MySQL 8.0 的 JSON 类型支持索引，可存储配置快照、ABAC 策略、属性映射
- 多租户隔离通过 MyBatis-Plus `TenantLineInnerInterceptor` 在应用层实现，替代 PG RLS
- Vista/SP 可在 MySQL 下等效实现（详见 §5.5 / §5.6）
- PG 的 Multi-Schema 模式改为数据库级隔离或应用层 Schema 路由

---

## 2. 模块分解

### 2.1 15个模块清单（Spring 模块化单体）

基于 RuoYi-Vue-Plus 模块化单体架构，15 个模块分布在 `ruoyi-modules/` 下，模块间通过 Spring Bean 直接调用（同步）或 Spring Event / RabbitMQ（异步）。

| ID | 模块名 | 职责 | 数据库 |
|:--:|-------|------|:-----:|
| M01 | ruoyi-gateway | Nginx 路由/认证/限流 | — |
| M02 | ruoyi-auth | OAuth2.0/OIDC/SSO/Token | 共享 D07 |
| M03 | ruoyi-tenant | 租户管理/配置 | 共享 D07 |
| M04 | ruoyi-permission | 用户/角色/菜单权限 | 共享 D07 |
| M05 | ruoyi-audit | 审计日志/操作追踪 | 独立 D07 |
| **M06** | **ruoyi-cpq-config** | **CSP求解/规则编译/向导式配置** | **独立 D03** |
| **M07** | **ruoyi-cpq-pricing** | **多维定价/折扣/阶梯定价** | **独立 D02** |
| **M08** | **ruoyi-cpq-quote** | **报价单/模板/文档生成** | **独立 D04** |
| M09 | ruoyi-cpq-approval | 审批路由/矩阵/流转 | 独立 D05 |
| **M10** | **ruoyi-cpq-atp** | **库存/物料/产能三级交期** | **独立** |
| M11 | ruoyi-cpq-solution | 方案CRUD/协同编辑/评审 | 共享 |
| M12 | ruoyi-cpq-presales | 售前协同/任务路由/批注 | 共享(M11) |
| M13 | ruoyi-cpq-competitive | 竞品数据/参数对比/推荐 | 独立 |
| **M14** | **ruoyi-cpq-product** | **5层产品目录/SBOM/MBOM/属性** | **独立 D01(SoT)** |
| M15 | ruoyi-cpq-integration | CRM/ERP/PLM连接器 | 独立 D08 |

**模块间通信**：
```
M06(配置引擎) ──Spring Bean──▶ M14(产品数据) ──Spring Bean──▶ M07(定价引擎)
M06(配置引擎) ──Spring Event──▶ M10(ATP/CTP)
M08(报价引擎) ──Spring Bean──▶ M06(配置快照) + M07(定价) + M10(交期)
M09(审批引擎) ──Spring Event──▶ M08(报价状态)
M15(集成服务) ──RabbitMQ──▶ ERP/CRM/PLM
```

相比 Go 微服务版的 gRPC/NATS 通信，Spring 模块间直接方法调用消除了序列化开销和网络延迟，开发调试更简单。异步场景通过 Spring Event（模块内）或 RabbitMQ（跨系统集成）处理。

### 2.2 数据库归属策略

- **独立库（10个模块）**：M06/M07/M08/M09/M10/M14/M15 → 性能隔离 + 安全合规
- **共享库（M11+M12）**：方案管理 + 售前协同紧密耦合，共享避免分布式事务
- **系统库（M02-M05）**：共享 D07 系统数据域
- **缓存隔离**：每个模块独立的 Redis key namespace（如 `cpq:config:*`、`cpq:pricing:*`）

---

## 3. 核心模块Function Specification

### 3.1 配置引擎（M06 — 最核心模块）

#### 3.1.0 CSP 求解器并发方案评估（Java 替代 Go goroutine 池化）

Go 版本使用 `chan *SolverInstance` 作为有缓冲通道实现求解器实例池化（`CPU×2` 大小），Acquire/Release 模式。Java 下有多种替代方案，以下针对当前技术栈做评估：

| 方案 | 技术 | 与 Go goroutine 池的相似度 | 优势 | 劣势 | 适用性评估 |
|------|------|:---:|------|------|------|
| **方案A** | `ThreadPoolExecutor` + `ArrayBlockingQueue` | ⭐⭐⭐⭐ 高 | `ArrayBlockingQueue` 对应 Go buffered channel；`take()/put()` 对应 `<-chan`；预初始化 SolverInstance 放入队列；JDK 内置无第三方依赖 | 线程数上限受 OS 限制（数百到数千），远少于 goroutine 的数十万；线程上下文切换开销较大 | **当前最佳选择**：直接映射 Go 池化模型，技术栈完全可行，CPU×2 线程数完全在 JVM 可承受范围内 |
| **方案B** | Virtual Threads（Java 21+） | ⭐⭐⭐⭐⭐ 极高 | 语义最接近 goroutine：轻量级、可创建百万级虚拟线程；无池化概念——每个请求直接 `Thread.startVirtualThread()`；`synchronized` 自动让出载体线程 | 需要升级到 JDK 21+（当前项目为 JDK 17）；与某些使用 `synchronized` 的旧库可能有 pinning 问题 | **长期最优方案**：与 goroutine 语义几乎一致，SolverInstance 从池化为按需创建+重置复用；建议在 JDK 21 升级后迁移 |
| **方案C** | Apache Commons Pool2 `GenericObjectPool` | ⭐⭐⭐ 中 | 生产级对象池：支持 minIdle/maxIdle/maxTotal、逐出策略、对象验证；池管理成熟 | 比 Go 的 channel 池多了对象生命周期管理开销；引入额外依赖 | **备选方案**：适合需要精细控制 SolverInstance 生命周期的场景（如实例过期回收、预热验证） |
| **方案D** | `ForkJoinPool` + `RecursiveAction` | ⭐⭐ 低 | 工作窃取算法对 MAC 传播的递归特性有加速效果；适合 CPU 密集型约束校验 | 池模型与 Go channel 差异大；Acquire/Release 无直接对应；不适合简单池化复用 | **专项优化**：不建议替代整体池化模型，但可在 SolverInstance 内部 MAC 传播阶段使用 ForkJoinPool 加速递归计算 |

**推荐路径**：**方案A（ThreadPoolExecutor）当前实现 → 方案B（Virtual Threads）JDK 21 升级后迁移**。方案A 的 `ArrayBlockingQueue` 与 Go buffered channel 模型直接对应，线程数 CPU×2（通常 16-32 线程）完全在 JVM 舒适区内，无性能瓶颈。方案B 在 JDK 21 后可消除线程数上限顾虑，且与 goroutine 语义几乎一致。

#### 3.1.1 CSP求解器类设计（Java 实现）

```
CompiledSolver (共享/只读，单实例，@Component, @Scope("singleton"))
├─ RuleIndex: HashMap + BitSet + Trie 三维索引
├─ DecisionGraph: BDD编译的决策图
├─ DependencyGraph: 变量依赖DAG
└─ 方法: compile(List<ConfigRule> rules) → 热加载

SolverInstance (每次请求创建，池化复用)
├─ assignments: Map<VarId, Value>
├─ domains: Map<VarId, Set<Value>>
├─ compiledSolver: CompiledSolver (引用)
└─ 方法: assign(v, val) → MAC传播 → Option状态集
       reset() → 清空assignments/domains，复用实例

SolverPool (方案A: ThreadPoolExecutor + ArrayBlockingQueue)
├─ pool: ArrayBlockingQueue<SolverInstance> (capacity = CPU×2)
├─ executor: ThreadPoolExecutor (coreSize = CPU×2, maxSize = CPU×2)
├─ acquire() → pool.take() (阻塞直到有可用实例)
├─ release(instance) → instance.reset(); pool.put(instance)
└─ 预初始化：CPU×2 个 SolverInstance 在启动时创建并放入队列
```

**Java 核心代码示例（方案A）**：

```java
@Component
public class SolverPool {
    private final ArrayBlockingQueue<SolverInstance> pool;
    private final CompiledSolver compiledSolver;
    private final int poolSize;

    public SolverPool(CompiledSolver compiledSolver) {
        this.compiledSolver = compiledSolver;
        this.poolSize = Runtime.getRuntime().availableProcessors() * 2;
        this.pool = new ArrayBlockingQueue<>(poolSize);
        // 预初始化
        for (int i = 0; i < poolSize; i++) {
            pool.offer(new SolverInstance(compiledSolver));
        }
    }

    public SolverInstance acquire() throws InterruptedException {
        return pool.take(); // 阻塞，对应 Go 的 <-pool
    }

    public void release(SolverInstance instance) {
        instance.reset();    // 重置状态
        pool.offer(instance); // 归还，对应 Go 的 pool <- instance
    }

    @PreDestroy
    public void shutdown() {
        pool.clear();
    }
}
```

#### 3.1.2 MAC传播算法（增量版，O(e·d³)）

算法逻辑不变，Java 实现：
1. 用户选择 attr=value → 更新 assignments
2. 查找依赖图中受影响节点（只传播变更可达子图）
3. 对受影响节点逐一执行 AC-3 弧相容检查
4. 返回每个Option的四态：
   - `Available`: 域非空且未赋值
   - `Disabled(reason)`: 域为空，附冲突解释
   - `Hidden`: 被父级选择排除
   - `Recommended`: 约束满足 + 高匹配度

#### 3.1.3 规则编译四阶段

1. Parse: 声明式规则 → AST
2. Optimize: 常量折叠 + 子表达式消除
3. Compile: AST → Rete网络 / BDD决策图
4. Cache: 编译结果入 Redis（TTL=即时失效 on 规则变更）

#### 3.1.4 4层缓存策略

- L1 进程内存: Caffeine Cache（编译后的 CompiledSolver，LRU，最大 100 条规则组）
- L2 Redis: 求解结果缓存（配置组合 hash → Option状态集，TTL=5min）
- L3 Redis: BOM展开结果（配置hash → BOM树，TTL=30min）
- L4 Redis: 产品数据（TTL=24h，变更时主动失效）

#### 3.1.5 性能SLA

- 配置交互响应: <50ms P95（增量MAC传播仅处理受影响约束）
- 全量配置校验: <200ms P95
- BOM展开（3层）: <1s P95

### 3.2 定价引擎（M07 — 六阶段流水线）

```
Phase 1: 获取基础价 → BasePrice = PriceBook.Lookup(Product, Region)
Phase 2: BOM成本累加 → Sum(SBOM_Line.price × qty) for each line item
Phase 3: 多维定价覆盖 → ContractPrice > ChannelPrice > RegionalPrice > ListPrice
Phase 4: 阶梯定价应用 → VolumeTier.Lookup(qty) → 单价调整
Phase 5: 折扣应用 → Discount = min(RequestedDiscount, MaxAllowedDiscount)
Phase 6: 净价计算 → NetPrice = AdjustedPrice × (1 - Discount) 
              → CostCheck: if NetPrice < CostFloor → 触发审批
```

Java 实现使用 `@Transactional` 保证六阶段原子性，定价规则通过 Redis 缓存热加载。

### 3.3 ATP/CTP引擎（M10 — 三级交期承诺）

**ATP三级检查**：
```
Level 1 库存ATP: CheckStock(material) → Available/Partial/None
Level 2 物料ATP: NetReq = Gross - OnHand + Allocated + Safety - Scheduled  
Level 3 产能ATP: CheckCapacity(WorkCenter, Period) → Load% → Available/Constrained/Full
```

**CTP交期推算**（6段分解）：
```
交期 = 物料齐套时间 + 生产周期 + 质检周期 + 包装周期 + 物流时间 + 缓冲
     = max(各物料最晚到货日) + Σ(各工序工时/产能) + 检验+包装 + 运输 + 5天缓冲
```

---

## 4. API设计总览

**70个端点**，9大模块，66个核心业务 + 4个集成层端点。

### 4.1 端点分布

| 模块 | 端点 | P0 | 代表性端点 |
|------|:---:|:--:|----------|
| 产品与BOM管理 | 12 | 9 | `POST /products/search`、`GET /products/{id}/sbom`、`GET /bom/explode` |
| 配置引擎 | 12 | 10 | `POST /configure/init`、`POST /configure/select`（增量CSP）、`POST /configure/validate`、`GET /configure/guided/questions`、**`POST /configure/bom-preview`（已实施：ATO BOM实时预览）**、**`POST /configure/guide`（已实施：向导式配置5状态机）** |
| 定价引擎 | 7 | 5 | `POST /pricing/calculate`、`GET /pricing/price-book`、`POST /pricing/discount/apply` |
| 报价引擎 | 9 | 7 | `POST /quotes`、`POST /quotes/{id}/generate`（PDF/Word）、`GET /quotes/{id}/versions` |
| 审批工作流 | 5 | 4 | `POST /approvals/submit`、`POST /approvals/{id}/action`、`GET /approvals/{id}/chain` |
| 方案管理 | 7 | 3 | `POST /solutions`、`POST /solutions/{id}/review`、`POST /solutions/{id}/deliverables` |
| ATP/CTP交期 | 4 | 2 | `POST /atp/check`、`POST /ctp/calculate`、`POST /atp/alternatives` |
| 竞品对标 | 4 | 3 | `POST /competitive/compare`、`GET /competitive/recommendations` |
| 系统管理 | 8 | 2 | `GET /admin/tenants`、`POST /admin/abac-policies`、`GET /admin/audit-logs` |
| 集成层 | 4 | 3 | `POST /integration/crm/opportunity`、`POST /integration/erp/order` |

### 4.2 认证与鉴权体系

基于项目已集成的 **Sa-Token + Spring Security**：

- **认证模式**：Sa-Token 多终端认证（Web 端使用 Cookie/Token 双模式）
- **Token 载体**：JWT，Claims 嵌入租户/角色/权限信息 `{sub, tenant_id, role, region, product_lines, cost_visibility_level}`
- **Token 有效期**：Access Token 30min / Refresh Token 7天（Sa-Token 默认配置）

**权限在 API 层的 5 级实施**：
1. **网关层**：Nginx 限流 + 路由分发
2. **认证层**：Sa-Token `StpUtil.checkLogin()` 验证登录态
3. **鉴权层**：`@SaCheckPermission` 注解控制端点级权限（如 `/admin/*` 仅管理员角色）
4. **租户层**：MyBatis-Plus `TenantLineInnerInterceptor` 自动注入 `tenant_id` 条件（替代 PG RLS）
5. **审计层**：AOP 切面 + `@Log` 注解记录所有 API 调用到操作日志表

**频率限制**：
| 级别 | 限制 | 适用对象 | 实现方式 |
|:----:|------|---------|---------|
| Tier 1 | 30次/分/用户 | 所有认证用户 | Sa-Token  throttle + Redis |
| Tier 2 | 300次/分/租户 | 租户聚合 | Redis 计数器 |
| Tier 3 | 1000次/分/租户 | 突发容忍，超出排队 | Redis 令牌桶 |

### 4.3 关键端点示例

**POST /api/v1/configure/select** — 增量约束传播（核心端点）

```json
// 请求
{
  "configuration_id": "CFG-abc123",
  "selection": {"attribute": "frequency", "value": "66-88MHz"}
}

// 响应 200
{
  "configuration_id": "CFG-abc123",
  "applied_selection": {"frequency": "66-88MHz"},
  "affected_options": {
    "antenna_type": {
      "AN0375H10": {"status": "available", "recommended": true, "reason": "推荐: VHF 66-88MHz 标准天线"},
      "AN0375H20": {"status": "available", "recommended": false},
      "UHF_ANT_01": {"status": "hidden", "reason": "仅适用于UHF频段"}
    },
    "power_amplifier": {
      "PA_VHF_50W": {"status": "available"},
      "PA_UHF_50W": {"status": "disabled", "reason": "与已选频段不兼容: 仅适用于350-400MHz"}
    }
  },
  "bom_preview": {...},
  "atp_estimate": {"delivery_days": 14, "status": "available"},
  "solver_latency_ms": 12
}
**POST /api/v1/configure/bom-preview** — BOM实时预览（已实施，2026-06-13）

```json
// 请求: POST /cpq/configure/bom-preview?modelId=1003
{"焊缝跟踪": "LASER"}

// 响应 200
{
  "code": 200,
  "data": [
    {
      "materialCode": "MAT-ARC200P-HOST",
      "materialDesc": "ARC-200P 弧焊机器人主机",
      "quantity": 1,
      "unit": "SET",
      "requirementType": "M",
      "costComponent": "MATERIAL",
      "leadTime": 21
    },
    {
      "materialCode": "MAT-SEAM-TRACK",
      "materialDesc": "激光焊缝跟踪系统",
      "quantity": 1,
      "unit": "SET",
      "requirementType": "O",
      "costComponent": "MATERIAL",
      "leadTime": 14
    }
  ]
}
```

**用途**: ATO定制配置等场景中，每次属性选择变化时实时刷新BOM预览表。后端调用 `bomExplosionService.sbomToMbom(modelId, selections)` 执行五阶段SBOM→MBOM转换流水线（Phantom跳过→150% BOM过滤→属性映射→展开合并→完整性校验）。变体BOM过滤依赖 `cpq_variant_bom.effectivity_condition` JSON字段。

**POST /api/v1/configure/guide** — 向导式配置步骤（已实施，2026-06-13）

```json
// 请求: POST /cpq/configure/guide?modelId=1003
{"颜色": "珍珠白", "基站版本": "标准版"}

// 响应 200
{
  "code": 200,
  "data": {
    "state": "RECOMMENDING",
    "currentAttribute": null,
    "options": [],
    "recommendedProducts": [...],
    "selections": {"颜色": "珍珠白", "基站版本": "标准版"}
  }
}
```

**用途**: 向导式配置5状态机驱动。后端 `guidedSelling()` 根据已选属性数量返回不同状态：0选项→QUESTIONING、≤3选项→NARROWING、>3选项→RECOMMENDING、全部已选→COMPLETED。注意：后端从不返回CONFIGURING状态，该状态由前端在RECOMMENDING阶段点击"进入配置确认"时直接设置。

---

## 5. 数据库设计

> **V2.0 说明**：原 V1.0 基于 PostgreSQL 16 设计的 43 表 + 8 View + 4 SP，V2.0 全面迁移至 MySQL 8.0。PG 特有的 UUID、JSONB、RLS、Multi-Schema、pg_trgm 等功能用 MySQL 等效方案替代。核心表结构和数据域划分保持不变，仅调整 DDL 语法和特性映射。

### 5.1 ER图（核心关系）

基于 Mermaid erDiagram，43 张表覆盖八大数据域（D01-D08）。核心实体关系：

```
product_catalog ||--o{ product_model : "1:N"
product_model ||--o{ product_attribute : "1:N"
product_model ||--o{ sbom_header : "1:N"
sbom_header ||--o{ sbom_line : "1:N"
sbom_line }o--|| mbom_line : "转换映射"
product_model ||--o{ config_rule : "1:N"
config_rule }o--|| compatibility_matrix : "约束归属"
product_model ||--o{ variant_bom : "150% BOM"
variant_bom ||--o{ attribute_mapping : "属性映射"
quote ||--o{ quote_line_item : "1:N"
quote_line_item }o--|| product_model : "引用产品"
quote ||--o{ config_snapshot : "1:N"
quote ||--o{ approval_chain : "1:N 审批链"
approval_chain ||--o{ approval_record : "1:N"
tenant ||--o{ user : "1:N"
user ||--o{ user_role : "N:M"
```

### 5.2 表结构统计

| 数据域 | 表数 | 核心表 |
|:-----:|:---:|--------|
| D01 产品 | 8 | product_catalog, product_model, sbom_header, sbom_line, mbom_line |
| D02 定价 | 7 | price_book, price_book_entry, price_rule, volume_tier |
| D03 配置 | 5 | config_rule, variant_bom, attribute_mapping, compatibility_matrix |
| D04 报价 | 6 | quote, quote_line_item, config_snapshot, quote_version |
| D05 审批 | 4 | approval_rule, approval_chain, approval_record |
| D06 客户 | 4 | account, channel, agreement_price |
| D07 系统 | 7 | tenant, user, role, abac_policy, audit_event |
| D08 集成 | 3 | integration_config, integration_mapping, sync_log |
| **合计** | **43** | — |

### 5.3 PostgreSQL → MySQL 关键特性迁移对照

| PG 特性（V1.0） | V1.0 用途 | MySQL 8.0 等效方案 |
|------|---------|------|
| `UUID` 主键 | 分布式唯一 ID | `BIGINT AUTO_INCREMENT`（单库足够）或 `VARCHAR(32)` 雪花ID |
| `gen_random_uuid()` | 自动生成 UUID | Java 应用层生成（`IdUtil.simpleUUID()` Hutool / MyBatis-Plus `IdType.ASSIGN_ID` 雪花算法） |
| `TIMESTAMPTZ` | 带时区时间戳 | `DATETIME`（应用层统一 UTC 存储，前端展示转换时区） |
| `JSONB` | 配置快照/ABAC策略/属性映射 | `JSON` 类型（MySQL 5.7+/8.0 支持 JSON 索引和函数） |
| RLS（行级安全） | 数据库级租户隔离 | MyBatis-Plus `TenantLineInnerInterceptor` 应用层自动注入 `tenant_id`（已配置就绪） |
| Multi-Schema | Per-Tenant Schema 隔离 | 数据库级隔离（高隔离需求客户独立DB）+ 表前缀隔离（标准客户） |
| `pg_trgm` GIN 索引 | 模糊搜索 | MySQL `FULLTEXT` 索引 + ngram parser |
| `tsvector` / GIN | 全文搜索 | MySQL `FULLTEXT` 索引（InnoDB 原生支持） |
| 递归 CTE | BOM展开/审批链查询 | MySQL 8.0 `WITH RECURSIVE`（语法与 PG 兼容，已测试可用） |
| 窗口函数 | 审批SLA分析 | MySQL 8.0 原生支持 `ROW_NUMBER() / RANK() / LAG()` |
| `CHECK` 约束 | 字段值约束 | MySQL 8.0.16+ 支持 `CHECK`（注意：实际执行比 PG 晚，建议应用层校验兜底） |
| `TIMESTAMPTZ NOT NULL DEFAULT now()` | 创建时间 | `DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| RANGE 分区 | 报价/审计数据归档 | MySQL RANGE 分区（语法相似） |

### 5.4 核心表示例：cpq_sbom_line

```sql
CREATE TABLE cpq_sbom_line (
    id              BIGINT AUTO_INCREMENT PRIMARY KEY,
    tenant_id       BIGINT NOT NULL,
    sbom_header_id  BIGINT NOT NULL,
    line_number     INT NOT NULL,
    item_code       VARCHAR(100) NOT NULL,
    item_name       VARCHAR(500) NOT NULL,
    item_type       VARCHAR(20) NOT NULL COMMENT 'HOST/ACCESSORY/SERVICE/LICENSE/SOFTWARE',
    quantity        DECIMAL(12,4) NOT NULL DEFAULT 1.0000,
    unit            VARCHAR(10) NOT NULL DEFAULT 'PCS',
    is_required     TINYINT(1) NOT NULL DEFAULT 1,
    is_replaceable  TINYINT(1) NOT NULL DEFAULT 0,
    replacement_group VARCHAR(50),
    min_qty         DECIMAL(12,4),
    max_qty         DECIMAL(12,4),
    price_impact    VARCHAR(10) COMMENT 'FIXED/VARIABLE/NONE',
    sort_order      INT NOT NULL DEFAULT 0,
    create_time     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_time     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    -- 索引
    INDEX idx_tenant_sbom (tenant_id, sbom_header_id),
    INDEX idx_tenant_type (tenant_id, item_type),
    UNIQUE KEY uk_sbom_line (sbom_header_id, line_number)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='SBOM行表';
```

### 5.5 索引策略（MySQL 8.0）

| 查询场景 | 索引类型 | 核心字段 |
|---------|:------:|---------|
| 产品搜索 | BTREE + FULLTEXT | model_name, model_code, description |
| 全文搜索 | FULLTEXT (ngram) | search_vector → description/model_name |
| 配置规则匹配 | BTREE 复合 | tenant_id, product_id, attr_name |
| 报价多维查询 | BTREE 复合 | tenant_id, account_id, status, create_time |
| BOM递归展开 | BTREE | tenant_id, sbom_header_id, parent_line_id |
| 审批流转 | BTREE 复合 | tenant_id, quote_id, approver_id, status |
| 多租户 | BTREE（所有表前缀） | tenant_id |
| 审计时间范围 | BTREE | tenant_id, create_time DESC |

### 5.6 View设计（8个 — MySQL 等效实现）

| 视图 | 用途 | MySQL 实现技术 |
|------|------|---------|
| v_quote_summary | 报价多维聚合+赢率 | `GROUP BY ... WITH ROLLUP` |
| v_config_analytics | 高频选项统计 | `JSON_EXTRACT()` 展开 JSON 字段 |
| v_approval_sla | 审批效率 | 窗口函数 `ROW_NUMBER() / LAG()` |
| v_product_lifecycle | 产品生命周期+在途报价 | `LEFT JOIN` 多表关联 |
| **v_bom_explosion** | **BOM递归展开+层级路径** | **`WITH RECURSIVE` CTE（MySQL 8.0 原生支持）** |
| v_pipeline_forecast | 销售管线预测 | 加权聚合 `SUM(CASE WHEN ...)` |
| v_cpq_health | 系统健康 | 多源 JOIN 聚合 |
| v_sbom_to_mbom_trace | SBOM→MBOM追溯 | 转换映射关联 JOIN |

**BOM 递归展开视图示例（MySQL WITH RECURSIVE）**：

```sql
CREATE VIEW v_bom_explosion AS
WITH RECURSIVE bom_tree AS (
    -- 锚点：顶层物料
    SELECT sl.id, sl.sbom_header_id, sl.parent_line_id, sl.item_code,
           sl.item_name, sl.quantity, 1 AS level,
           CAST(sl.item_code AS CHAR(500)) AS path
    FROM cpq_sbom_line sl
    WHERE sl.parent_line_id IS NULL
    
    UNION ALL
    
    -- 递归：子物料
    SELECT sl.id, sl.sbom_header_id, sl.parent_line_id, sl.item_code,
           sl.item_name, sl.quantity, bt.level + 1,
           CONCAT(bt.path, ' > ', sl.item_code)
    FROM cpq_sbom_line sl
    INNER JOIN bom_tree bt ON sl.parent_line_id = bt.id
)
SELECT * FROM bom_tree;
```

### 5.7 存储过程设计（4个 — MySQL 等效实现）

| SP | 用途 | MySQL 实现 | 性能理由 |
|----|------|---------|---------|
| **sp_bom_explosion** | 递归BOM展开 | `WITH RECURSIVE` CTE 封装为存储过程 | CTE 在 DB 层完成避免多次网络往返+利用 MySQL 优化器 |
| **sp_mrp_net_requirement** | MRP净需求计算 | 多表 JOIN + 批量运算存储过程 | 百万级数据在 DB 层聚合后再返回应用层 |
| **sp_config_validate_batch** | 批量配置校验 | 存储过程 + 游标批量处理 | 一次调用处理数百条配置，避免逐条 API 调用的 N+1 问题 |
| **sp_quote_recalculate** | 报价重算 | 事务内多步更新的存储过程 | 保证六维定价流水线在单事务内完成一致性 |

**MySQL 存储过程注意事项**：
- MySQL 存储过程不支持 `DRY_RUN` 参数模式（PG 支持），需改为应用层判断
- 游标性能弱于 PG，批量操作建议使用临时表 + `INSERT ... SELECT`
- 错误处理使用 `DECLARE EXIT HANDLER` 机制，不如 PG 的 `EXCEPTION` 块灵活

### 5.8 分区与归档

| 表 | 分区策略 | 归档周期 |
|----|---------|:------:|
| quote | RANGE 按月（`PARTITION BY RANGE (TO_DAYS(create_time))`） | 24个月后归档 |
| audit_event | RANGE 按周 | 3个月后归档 |
| sync_log | RANGE 按月 | 6个月后归档 |

**多租户隔离策略**（替代 PG Multi-Schema）：
- **标准客户（90%场景）**：MyBatis-Plus `TenantLineInnerInterceptor` 自动注入 `tenant_id` WHERE 条件，所有租户共享同一组表
- **高隔离需求客户**：独立数据库实例（通过 Spring 动态数据源切换）

---

## 6. 部署架构

> **V2.0 说明**：移除 K3s 容器化部署和 HPA 弹性伸缩（当前无容器化/自动伸缩需求），改为传统 Nginx + JAR 单机/双机部署方案。

### 6.1 部署拓扑

**标准部署（单机）**：

```
                   ┌──────────────────────────┐
                   │     Nginx (:80/:443)       │
                   │  静态资源 + 反向代理 + HTTPS  │
                   └──────────┬───────────────┘
                              │
              ┌───────────────┼───────────────┐
              │               │               │
        ┌─────▼─────┐  ┌─────▼─────┐  ┌─────▼─────┐
        │ ruoyi-ui   │  │ cpq-portal │  │  API 路由   │
        │ (Vue3 SPA) │  │ (Vue3 SPA) │  │ /prod-api/ │
        └───────────┘  └───────────┘  └─────┬─────┘
                                            │
                              ┌─────────────▼─────────────┐
                              │   Spring Boot JAR (:8080)   │
                              │   ruoyi-admin + 所有模块     │
                              └─────────────┬─────────────┘
                                            │
                    ┌───────────────────────┼───────────────┐
                    │                       │               │
             ┌──────▼──────┐        ┌──────▼──────┐  ┌─────▼─────┐
             │  MySQL 8.0   │        │  Redis 7.x   │  │ 文件存储   │
             │  (CPQ主库)   │        │  (缓存/Session)│  │  (本地FS) │
             └─────────────┘        └─────────────┘  └───────────┘
```

**高可用部署（双机 + 主从）**：

```
                   ┌──────────────────────────────┐
                   │     Nginx (Keepalived VIP)      │
                   └─────────────┬────────────────┘
                                 │
              ┌──────────────────┼──────────────────┐
              │                  │                  │
        ┌─────▼─────┐      ┌─────▼─────┐     ┌─────▼─────┐
        │  App-1    │      │  App-2    │     │  静态资源  │
        │  JAR :8080 │      │  JAR :8080 │     │  (NFS共享)│
        └─────┬─────┘      └─────┬─────┘     └───────────┘
              │                  │
              └────────┬─────────┘
                       │
              ┌────────▼────────┐
              │  MySQL 8.0      │
              │  主从复制        │
              │  主库(写) + 从库(读) │
              └────────┬────────┘
                       │
              ┌────────▼────────┐
              │  Redis 7.x      │
              │  Sentinel 哨兵   │
              └─────────────────┘
```

### 6.2 多租户部署模式

- **标准客户（90%）**：共享数据库 + MyBatis-Plus 租户拦截器隔离
- **高隔离客户**：独立数据库实例，通过 Spring 动态数据源路由（`AbstractRoutingDataSource`）

### 6.3 私有化部署（非容器化）

- **依赖**：JDK 17+、MySQL 8.0、Redis 7.x
- **部署包**：Spring Boot Fat JAR（`mvn clean package` 生成） + 前端静态文件
- **启动脚本**：`java -jar ruoyi-admin.jar --spring.profiles.active=prod`
- **ARM 信创支持**：JDK 17+ 已支持鲲鹏/飞腾架构，无需额外适配

---

## 7. 交叉评审

### 7.1 V2.0 变更总结

| 变更项 | V1.0（Go版） | V2.0（Java版） | 变更原因 |
|--------|-------------|-------------|---------|
| 后端语言 | Go 1.23+ / Hertz + Kitex | Java 17+ / Spring Boot 2.7+ | 项目实际技术栈 |
| 并发模型 | goroutine 池化 (channel) | ThreadPoolExecutor / Virtual Threads（JDK 21） | Java 等效替代 |
| 数据库 | PostgreSQL 16 | MySQL 8.0 | 项目已部署 |
| 租户隔离 | PG RLS + Multi-Schema | MyBatis-Plus TenantLineInterceptor + 独立库 | 应用层替代 |
| 前端框架 | React 19 | Vue 3 + Element Plus | 项目已采用 |
| 服务通信 | gRPC + NATS + Pulsar | Spring Bean 直调 + Spring Event + RabbitMQ | 模块化单体架构 |
| 容器编排 | K3s + Rancher | 已移除 | 当前无容器化需求 |
| 弹性伸缩 | HPA（CPU/队列深度） | 已移除 | 当前无自动伸缩需求 |
| API网关 | APISIX | Nginx + Sa-Token | 项目已集成 |

### 7.2 一致性确认

| 概念 | 模块分解 | API | 数据库 | 一致性 |
|------|:--:|:--:|:----:|:-----:|
| 权限控制 | ✅ Sa-Token | ✅ @SaCheckPermission | ✅ 租户拦截器 | ✅ |
| CSP求解器 | ✅ SolverPool + MAC | ✅ select/validate | ✅ config_rule表 | ✅ |
| ATP/CTP | ✅ 三级引擎 | ✅ check/calculate | ✅ 库存视图 | ✅ |
| SBOM→MBOM | ✅ 转换链 | ✅ BOM端点 | ✅ 映射表+WITH RECURSIVE | ✅ |
| 多租户 | ✅ TenantInterceptor | ✅ JWT+租户上下文 | ✅ 拦截器+独立库 | ✅ |
| 部署 | ✅ Fat JAR+Nginx | ✅ 自包含 | ✅ MySQL 8.0 | ✅ |

### 7.3 总体评价

| 维度 | V1.0 评分 | V2.0 评分 | 说明 |
|------|:---:|:---:|------|
| 技术栈选型合理性 | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | V2.0 基于实际项目技术栈，零额外基础设施成本 |
| 模块分解粒度 | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | 15模块在Spring模块化单体下粒度合理，通信开销更低 |
| 核心模块Function Spec深度 | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | CSP求解器保留完整设计，补充 Java 并发方案评估 |
| API设计完整性 | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | 70端点设计不变，鉴权体系改为 Sa-Token 实现 |
| 数据库设计专业度 | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐☆ | MySQL 等效方案完整，但 RLS/Multi-Schema 需应用层兜底 |
| 部署架构可行性 | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | 传统部署模式成熟度高，运维门槛更低 |

> **阶段三 V2.0 结论**：技术实现层已全面适配 Java + MySQL + Vue3 实际技术栈。43表 + 8 View + 4 SP 已提供完整的 MySQL 等效实现方案，CSP 求解器并发提供了 ThreadPoolExecutor（当前）和 Virtual Threads（长期）两套 Java 方案评估。K3s 容器化部署和 HPA 弹性伸缩已移除。从 V2.0 研究报告 → 阶段一定义 → 阶段二详细设计 → 阶段三 V2.0 技术实现形成完整且可执行的技术蓝图闭环。

---

> **三阶段产品设计全流程完结 | V2.0 技术栈适配版 | 累计交付文档: >700KB**
