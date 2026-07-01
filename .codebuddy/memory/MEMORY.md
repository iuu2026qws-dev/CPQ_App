# 项目记忆 - Project_0005_Ruoyi_CPQ

## 用户偏好（2026-06-08）
- **命令自动执行**：所有终端命令（包括危险命令、工作区外操作）均自动执行，不询问确认。`requires_approval` 始终设为 `false`。
- **FK字段前端规则**：所有 Long 型外键（FK）字段在前端必须用 ModelLookup 或其他下拉搜索组件，禁止裸 `el-input-number` 让用户手动输入 ID。这是强制原则。

## 项目概述
- 纷享销客 CPQ（配置-定价-报价）系统
- 基于 RuoYi-Vue-Plus 前后端分离框架（2026-06-06 迁移自 RuoYi-Vue v3.9.2）
- 仓库：https://gitee.com/dromara/RuoYi-Vue-Plus

## 技术栈
- 后端：Spring Boot 3.x + Sa-Token + JWT + MyBatis-Plus + MySQL/PostgreSQL + Redis + Redisson + HikariCP + Undertow
- 前端：Vue 3 + TypeScript + Element Plus + Vite + Pinia
- 构建：Maven（后端）/ Vite（前端）
- 高级特性：多租户、工作流引擎、数据脱敏/加解密、MinIO OSS、SpringDoc、分布式锁(Lock4j)、防重幂等、国际化、SkyWalking

## 环境要求
- JDK 17+
- MySQL 8.0+ / PostgreSQL 14+
- Redis 6.0+
- Node.js 18+
- Maven 3.8+

## 当前配置
- 后端端口：8080
- 前端端口：80
- 数据库：已配置（Ruoyi_CPQ，localhost:3306，root/Storm123@）
- Redis：localhost:6379（密码：ruoyi123）
- 管理员：admin / admin123
- 配置文件位置：
  - `ruoyi-admin 2/src/main/resources/application-dev.yml`
  - `ruoyi-admin 2/src/main/resources/application-prod.yml`
  - `ruoyi-extend/ruoyi-snailjob-server/src/main/resources/application-dev.yml`
  - `ruoyi-extend/ruoyi-snailjob-server/src/main/resources/application-prod.yml`

## RuoYi-Vue-Plus 核心模块结构
- `ruoyi-admin/`：管理后台启动模块
- `ruoyi-common/`：通用模块（含 20+ 子模块：core、excel、encrypt、sensitive、oss、mail、sms、translation 等）
- `ruoyi-extend/`：扩展模块（xxl-job 等）
- `ruoyi-modules/`：业务模块（system、gen、job、workflow 等）
- `script/`：部署脚本与 SQL

## 数据库设计规范（RuoYi-Vue-Plus）
- 实体继承 BaseEntity，包含字段：create_id, create_by, create_time, update_id, update_by, update_time, remark
- 可选字段：tenant_id（多租户）、del_flag（逻辑删除 '0'/'2'）、version（乐观锁）
- del_flag：'0'=正常，'2'=删除（逻辑删除，禁止物理删除）
- 金额字段：DECIMAL(10,2)，禁用 FLOAT/DOUBLE
- 状态枚举：CHAR(1) 或 VARCHAR，禁用 TINYINT
- 字符集：utf8mb4，禁用 utf8
- 主键：BIGINT（雪花ID，非自增）

## 后端开发规范
- Domain：继承 BaseEntity，@Accessors(chain=true) 链式赋值，日期字段加 @JsonFormat + @Excel
- Mapper XML：禁止 SELECT *，查询首行 del_flag='0'，删除用 UPDATE del_flag='2'，参数用 #{}，列表需 ${params.dataScope}
- ServiceImpl：所有 public 方法首行打印入参日志(@Slf4j)，增删改用 @Transactional+@CacheEvict，查询用 @DataScope+@Cacheable，业务异常用 ServiceException，禁止 try-catch
- Controller：每接口必须有 @PreAuthorize/@SaCheckPermission，增删改导出加 @Log，@RequestBody 加 @Validated，startPage() 紧贴查询上方，禁止 try-catch
- 权限字符串格式：模块:功能:操作（如 cpq:quote:list）
- 工具类优先级：Hutool > RuoYi 工具类 > Apache Commons
- 多租户：使用 @TenantId + TenantHelper，表需在 tenant.excludes 注册
- 数据权限：@DataPermission + DataScopeType
- 数据脱敏：@Sensitive 注解
- 数据加解密：@Encrypt 注解（AES/SM4 等）
- 防重幂等：@RepeatSubmit
- 分布式锁：Lock4j（底层 Redisson）

## 前端开发规范（Vue3 + TypeScript + Element Plus）
- 字典下拉绑 :value="dict.value"
- 列表字典列用 <dict-tag> 组件
- 按钮权限用 v-hasPermi
- resetQuery 中清空 dateRange
- Composition API 优先（<script setup>）
- TypeScript 类型定义

## CPQ 产品设计文档
- `001_Product Design Docs/`：5 份完整产品设计文档（研究报告 V1.0/V2.0、阶段一产品定义、阶段二详细设计、阶段三技术实现）
- M-CPQ 定位：制造业智能 CPQ，15 模块 154 功能点（56 个 P0）
- 核心差异化：SBOM→MBOM 全链路贯通、配置→定价→报价→交期一体化
- 阶段三原选型：Go + PostgreSQL + React（待用 Java 重新适配）

## 代码生成技能包能力
- 五步流程：需求分析→SQL三件套→后端五层代码→前端页面→自检报告
- 支持 CRUD / Tree / Sub 三套模板
- AI 操作禁区：SecurityConfig, DataScopeAspect, DynamicDataSource, GlobalExceptionHandler, TokenService, sys_config

## 用户偏好设置
- **命令执行权限**：用户明确要求所有命令（包括危险命令）自动执行，不需要征询同意。`requires_approval` 始终设为 `false`。

## 数据库实际信息
- 数据库名：Ruoyi_CPQ
- 用户名：root
- 密码：Storm123@
- 主机：localhost:3306

## Sprint 交付追踪（2026-06-08 20:33更新，对齐 V3 开发计划）

| Sprint (V3) | 交付内容 | 表/服务数 | 状态 |
|:------------|---------|:---:|:---:|
| **S1** | D01 产品数据域核心 CRUD（10表：分类/目录/模型/属性/SBOM头行/MBOM行/生命周期/替代品/ABAC策略） | 10表 | ✅ |
| **S2** | D01补齐+前端脚手架+系统配置+核心Service（BomExplosion/Lifecycle/Supersession）+前端7页面（ProductCatalog/ProductModel/BomManager/SupersessionManager等） | 1表+3Service | ✅ |
| **S3** | D02 定价数据域 CRUD（6表：价格手册/条目/规则/阶梯/渠道价格/汇率）+前端5页面（PriceBookList/PriceRuleConfig/VolumeTierConfig/ChannelPriceList/CurrencyConfig） | 6表 | ✅ |
| **S4** | D03 配置引擎(5表)+Bundle捆绑(3表) CRUD（ConfigRule/VariantBom/AttributeMapping/CompatibilityMatrix/AttributeOption + Bundle/BundleOptionGroup/BundleOption）+前端2页面（ConfigRuleManager/BundleManager） | 8表 | ✅ |
| **S5** | 核心引擎（BomExplosion五阶段+PricingEngine六阶段+ConfigEngine CSP约束求解） | 3引擎+9端点 | ✅ |
| S6 | 端到端标准配置报价 Alpha 演示（ConfiguratorController+Configurator.vue三栏布局+ProductSearch+API模块/Store/路由/菜单） | 12任务 | ✅ |
| **S7** | D04 报价数据域 CRUD（6表：Quote/LineItem/ConfigSnapshot/QuoteVersion/QuoteTemplate/SolutionDocument）+报价前端（QuoteList/QuoteDetail/QuoteVersion/QuotePreview/TemplateSelector/Store/API/路由） | 17/17任务 | ✅ |
| **S8** | D05 审批数据域 CRUD（4表：ApprovalRule/Chain/Record/Matrix + ApprovalRouteService引擎 + ApprovalActionController + PendingApproval/ApprovalDetail/ApprovalHistory/ApprovalNode/ApprovalAction前端） | 16/16任务 | ✅ |
| S9 | QuoteGenerateService + 方案管理（SolutionList/SolutionEditor/SolutionCompare/SolutionReview前端+Solution管理API） | 12/12任务 | ✅ |
| S10 | ATP/CTP 交期引擎（AtpCtpService+AtpController+AtpCheck/AtpBatch/SlaDashboard前端+AtpIndicator/DeliveryTimeline组件） | 11/11任务 | ✅ |
| S11 | D06 客户渠道域（4表CRUD: Account/Channel/AgreementPrice/Territory）+QuoteWorkflowController+QuoteToErpService+新模块ruoyi-cpq-customer | 9/9任务 | ✅ |
| S12 | ECN/ECO 工程变更模块（4表DDL+CRUD+EcnService+EcnImpactAnalysisService五级传播+ChangeManagement/ImpactAnalysis/ChangeApproval前端）+新模块ruoyi-cpq-ecn | 14/14任务 | ✅ |
| S13 | D08 集成数据域 + 集成连接器 | 14任务 | ✅ 完成（2026-06-09） |
| S14 | 竞品对标 + 数据迁移模块 | 18任务 | ✅ 完成（2026-06-09） |
| S15 | 知识库 + 售前协同 + Dashboard | 19任务 | ✅ 完成（2026-06-09） |
| S16 | AI P2 + 多工厂产能分配 | 9任务 | ✅ 完成（2026-06-09） |
| S17 | 系统设置 + QuickQuote + GA | 18任务 | ✅ 完成（2026-06-09） |
| S18 | 权限体系深化 + 安全加固 | 9任务 | ✅ 完成（2026-06-09） |
| S19 | 移动端专用视图 | 7任务 | ✅ 完成（2026-06-09） |
| S20 | 性能优化 + 索引调优 | 8任务 | ✅ 完成（2026-06-09） |
| S21 | 部署方案 + 运维手册 | 7任务 | ✅ 完成（2026-06-09） |

> **S9-S12 E2E测试（2026-06-09）**: 25/25 (100%) 全部通过。测试报告: `.codebuddy/test-reports/sprint_9_12_e2e_report.md`

> **注意**：旧版 Sprint 编号（S2a/S2b/S3/S4/S5/S6/S7）与 V3 计划（S1-S25）不对齐，以上表格已统一为 V3 计划编号。旧版 MEMORY.md 中标记为「待开始」的 S2b（SBOM/MBOM/属性/生命周期）和 S3（定价/配置/捆绑）实际已在 V3 S1、S3、S4 中全部完成。

## CPQ Maven 模块结构（2026-06-09）
- `ruoyi-modules/ruoyi-cpq` — 产品主数据
- `ruoyi-modules/ruoyi-cpq-pricing` — 定价域
- `ruoyi-modules/ruoyi-cpq-config` — 配置引擎+Bundle捆绑
- `ruoyi-modules/ruoyi-cpq-quote` — 报价数据域+QuoteGenerateService+AtpCtpService
- `ruoyi-modules/ruoyi-cpq-approval` — 审批数据域+ApprovalRouteService+ApprovalActionController
- `ruoyi-modules/ruoyi-cpq-customer` — 客户渠道域（S11新增，4表CRUD+QuoteWorkflowController+QuoteToErpService）
- `ruoyi-modules/ruoyi-cpq-ecn` — 工程变更模块（S12新增，4表CRUD+EcnService+EcnImpactAnalysisService）
- `ruoyi-modules/ruoyi-cpq-integration` — 集成数据域（S13新增，3表CRUD+CRM/ERP/PLM连接器）
- `ruoyi-modules/ruoyi-cpq-competitive` — 竞品对标模块（S14新增，4表CRUD+CompetitorService）
- `ruoyi-modules/ruoyi-cpq-migration` — 数据迁移模块（S14新增，3表CRUD+DataMigrationService）
- `ruoyi-modules/ruoyi-cpq-knowledge` — 知识库模块（S15新增，文章CRUD+全文搜索）

## Lesson Learn 关键铁律
1. 生成后端 Domain 前必须先读 DDL，确保字段名100%匹配
2. 目录名不要含空格（如 `ruoyi-admin 2`），会导致 Maven/Spring Boot 插件行为异常
3. @RequestMapping 路径生成后必须 check 大小写一致性（Controller 全小写，前端 API 必须对齐）
4. `toAjax()` 不返回实体ID，测试时需从 list 接口获取创建后的ID
5. 前端 `import request` 使用 default import（`import request from '@/utils/request'`）
6. 新增 Maven 模块需同时注册：modules/pom.xml + admin/pom.xml 两个地方
7. 登录 API：`POST /auth/login` + body `{"clientId":"e5cd7e4891bf95d1d19206ce24a7b32e","grantType":"password","username":"admin","password":"admin123","tenantId":"000000"}`
8. 所有请求需带 `Authorization: Bearer <token>` + `clientid: e5cd7e4891bf95d1d19206ce24a7b32e` 头
9. zsh 中 URL 含 `?` 需用单引号包围，否则作为 glob 解析
10. cpq_product_model 需要 catalog_id + category_id（NOT NULL无默认值），测试时优先复用已有数据（如 modelId=1001）
11. PriceBookEntry API路径：`/cpq/pricing/entry`（非 `/cpq/pricing/pricebookentry`）
12. SBOM API路径：`/cpq/product/sbom/header` 和 `/cpq/product/sbom/line`（非 `/cpq/product/sbom`）
13. cpq_config_rule 的 effective_date 为 NOT NULL 无默认值，POST 必须带 `effectiveDate`
14. Token 有效期有限（约30分钟），长时间测试需刷新
15. `toAjax()` 返回 code 200 但 data 为 null（不含实体ID），测试时需从 list 接口获取
16. 新增模块间依赖时需在 Maven pom.xml 中显式添加 `<dependency>`（如 config 模块需依赖 pricing 模块才能注入 PricingEngineService）
17. 前端配置器通过 URL 参数传递 ID（`/configure/:modelId`），组件在 onMounted 中读取 route.params 初始化 store
18. 每个 Sprint 完成后必须闭环测试：后端 mvn install → 重启服务 → curl 验证所有新建端点 → vue-tsc 零新错误
19. 新建 Maven 模块三部曲：创建 pom.xml → 注册到 modules/pom.xml 的 &lt;modules&gt; → 注册到 admin/pom.xml 的 &lt;dependencies&gt;（必须带 &lt;version&gt;）
20. 模块间依赖需正确设置：approval 依赖 quote（审批链关联报价单），quote 依赖 cpq 和 config
21. RuoYi-Vue-Plus Controller 模式：@Validated @RequiredArgsConstructor @RestController extends BaseController，使用 R&lt;T&gt;、TableDataInfo&lt;T&gt;、PageQuery
22. 审批操作通过 ApprovalRouteService 驱动，前端通过 REST API `/cpq/approval/action/process` 调用
23. QuoteVersion 版本对比组件通过 version_json 解析快照数据比较报价单头部和行项目差异
24. ApprovalNode 链式流程节点通过 flexbox + 绝对定位连接线实现，支持4色状态
25. 前端组件大型弹窗的打印功能通过 window.open + innerHTML 注入实现，适合简单布局
26. RuoYi-Vue-Plus 的 Controller 不直接使用 startPage()/getDataTable()，而是通过 Service 层 selectPageList(bo, pageQuery) 实现分页
27. 新 Maven 模块必须添加 ruoyi-common-web 依赖才能使用 R<T> 等通用类
28. 模块间跨域依赖（如 customer 引用 quote 和 approval 的 domain/mapper）需在 pom.xml 中显式声明
29. Domain 字段名必须与 DDL 100% 匹配，MyBatis-Plus 默认驼峰→下划线映射不适用时须加 @TableField 注解
30. DDL 表必须包含 BaseEntity 的所有系统字段（create_by, create_time, update_by, update_time, create_dept, remark），缺失会导致 INSERT/SELECT 异常
31. QuoteToErpService 跨模块创建报价时必须设置所有 NOT NULL 字段（account_id, quote_number），否则数据库约束违反
32. E2E 测试 Token 从登录获取后必须同时带 `Authorization: Bearer <token>` 和 `clientid: e5cd7e4891bf95d1d19206ce24a7b32e` 两个请求头
33. Python 脚本执行 curl 测试比 Shell 脚本更稳定（避免变量转义、here-string 编码等问题）
34. 项目有两套前端：ruoyi-ui（Admin Portal, 端口3000）和 cpq-portal（业务应用, 端口3000）。sys_menu 表管理 Admin Portal 菜单，但大部分 CPQ 业务页面的 Vue 文件在 cpq-portal 中，需通过 iframe 嵌入或迁移文件才能使菜单正常工作
35. cpq-portal 菜单加载策略：**当前临时方案**是从 `config/menu.ts` 静态加载菜单，不通过 `sys_menu` API 动态加载。后续计划逐步改为从配置文件加载（非 sys_menu 数据库动态加载）
36. Admin Portal 菜单加载策略：ruoyi-ui 继续加载 sys_menu 表中所有菜单（包括 CPQ 菜单 menu_id ≥ 50000），不做 CPQ 菜单过滤。设计文档虽规定 CPQ 业务菜单归属 cpq-portal，但当前实际做法是 Admin Portal 可见全部功能菜单
37. 新表如果 Entity 继承 TenantEntity，DDL 必须包含全部审计列（create_dept, create_by, create_time, update_by, update_time, remark, del_flag），缺失任何一列都会导致 INSERT/SELECT 500 错误（2026-06-09）
38. 所有 CPQ 实体 @TableLogic 必须显式指定 `value = "0", delval = "2"`，不能依赖 MyBatis-Plus 默认 delval="1"（已统一修复 26 个实体）
39. 新模块的 DDL VARCHAR 长度必须能容纳所有枚举值（如 `sync_direction VARCHAR(10)` 对于 'BIDIRECTIONAL'(13字符) 太小）
40. cpq-portal 前端 dev server 在 package.json 中配置 port 3000 但实际运行可能被 Vite 随机分配到其他端口（如 5173），HMR 修改路由/菜单后需要重启 dev server 才能生效
41. cpq-portal CPQ 登录页无验证码字段（与 ruoyi-ui admin 不同），Playwright 自动化可直接 fill 用户名密码登录
42. Playwright 自动化测试前需先确认前端 dev server 端口（`lsof -i :<port>`），避免端口冲突导致 404
43. 端到端验证标准流程：后端 mvn clean package → 重启 jar → curl 全端点 API 测试 → 前端 Vite 重启 → Playwright 页面导航 → 截图
44. 系统设置页面（租户/用户/角色/菜单/参数配置/审计日志/登录日志等）ruoyi-ui 已有完整实现，cpq-portal 无需重建，直接复用 ruoyi-ui Admin Portal。v3 计划 S17.1-S17.6 已标记为 ♻️ 复用，减少 7.5 人天冗余工作量。
45. ABAC 策略（cpq_abac_policy）是唯一一个 ruoyi-ui 没有但 CPQ 需要的系统管理页面，已在 cpq-portal 独立构建完整 CRUD。入口放在侧边栏底部（/settings/abac），菜单图标 Lock。
46. S18-S21 Phase 4 V1.5 全部完成（2026-06-09）：31/31 任务。v-hasPermi/v-hasRole/v-cost-visibility 三个指令 + AbacCostEnforcementService 四级成本脱敏 + 移动端7页面（MobileLayout/Home/Approval/Quote/Configurator/Solution/Profile）+ PWA Service Worker + 响应式断点 + BomCacheService Redis缓存 + 43张表索引SQL + Vite bundle 优化 + GitHub Actions CI/CD + Dockerfile + Nginx生产配置 + 运维手册 + 部署指南。性能基准：7/7 PASS（配置校验6.9ms, BOM展开21ms, API<103ms）。
47. S12/S13 收尾完成（2026-06-09）：S12.7/8/9 EcnImpactAnalysisService 从Mock→真实（注入ICpqSbomService/ICpqQuoteService/ICpqApprovalChainService + ProductModelMapper/QuoteLineItemMapper，五级传播链全真实化）。S13.7 ErpConnector OAuth2 Client Credentials 真实实现（含内存token缓存+降级兜底）。S13.6 CrmConnector Webhook HMAC-SHA256签名+3次重试机制。CpqQuoteLineItemMapper新增selectQuoteIdsByItemCode/SbomLineId + ICpqQuoteService新增selectActiveByItemCode/batchUpdateStatus。S12 14/14 ✅，S13 14/14 ✅。E2E测试15/16 PASS。

## Sprint 5 引擎服务速查
| 引擎 | 模块 | 行数 | 端点 | 关键功能 |
|------|------|:---:|------|---------|
| BomExplosionService | ruoyi-cpq-config | 532 | `/cpq/engine/bom/*` | explode/explodeFlat/sbomToMbom(5阶段)/implodeBom |
| PricingEngineService | ruoyi-cpq-pricing | 355 | `/cpq/engine/pricing/calculate` | 六阶段定价(基础→BOM→多维→阶梯→折扣→净价) |
| ConfigEngineService | ruoyi-cpq-config | 380 | `/cpq/engine/config/*` | validate/propagate(MAC-3)/guide(MRV启发式)/compatibility |

## Sprint 6 配置器速查
| 组件 | 路径 | 用途 |
|------|------|------|
| ConfiguratorController | ruoyi-cpq-config | 编排器：聚合 ConfigEngine + BomExplosion + PricingEngine |
| /cpq/configure/model/{id} | GET | 加载配置模型（属性+选项+BOM） |
| /cpq/configure/validate | POST | CSP实时校验 |
| /cpq/configure/complete | POST | 完成配置（验证→BOM→定价） |
| ProductSearch.vue | views/configure/ | 产品搜索+场景筛选 |
| Configurator.vue | views/configure/ | 三栏布局配置器 |
| configure.ts | api/ | 12个API函数+9个类型 |
| configurator.ts | store/ | 配置会话状态机 |

## 报价模板管理模块（2026-06-13 完整实施）

### 架构
- 后端：`ruoyi-cpq-quote` 模块，Controller `/cpq/quote/template`
- Admin Portal：`ruoyi-ui/src/views/quoting/TemplateManager.vue` + `TemplateDesigner.vue`
- CPQ Portal：`cpq-portal/src/components/quoting/TemplateSelector.vue`（模板选择对话框）

### 核心端点（CpqQuoteTemplateController）
| 端点 | 方法 | 说明 |
|------|------|------|
| `/cpq/quote/template/list` | GET | 分页列表 |
| `/cpq/quote/template/{id}` | GET | 详情（含 template_json） |
| `/cpq/quote/template` | POST | 新增 |
| `/cpq/quote/template` | PUT | 修改 |
| `/cpq/quote/template/{id}` | DELETE | 删除 |
| `/cpq/quote/template/batch` | DELETE | 批量删除 |
| `/cpq/quote/template/fields` | GET | **新增**：字段库（3类23字段） |
| `/cpq/quote/template/{id}/design` | PUT | **新增**：保存设计 JSON |
| `/cpq/quote/template/{id}/preview` | GET | **新增**：生成预览 HTML |
| `/cpq/quote/template/{id}/default` | PUT | **新增**：设为默认模板 |

### 关键设计决策
- 模板设计 JSON 结构：sections[]（含 id/label/type/columns/fields 或 columns 用于 table）+ pageSettings（companyName/footerText/primaryColor）
- 字段库 23 个字段分 3 类：quote 头部(10)、line 行项目(9)、summary 汇总(4)
- 设计器：三栏布局（左字段库 260px / 中画布 flex / 右属性面板 260px），drag-drop 基于 HTML5 DnD API
- 预览：用示例数据（QT-2026-0001/示例客户公司/2 行模拟数据）替换占位符生成 HTML
- 默认模板设置：同类型互斥（设置为默认时自动取消其他同类型模板的 isDefault）

### 数据库表
- `cpq_quote_template`：template_name/template_type/template_content(LONGTEXT)/template_json(JSON)/is_default/status

### API 认证注意事项
- RuoYi-Vue-Plus SaToken 要求请求头携带 `clientid`（与登录 clientId 一致），否则 401

## 配置管理功能实际实施（2026-06-13）
以下为实际实施结果，已同步到4份设计文档（CPQ_后端功能设计.md / CPQ_前端门户设计.md / CPQ_阶段二_详细设计层.md / CPQ_阶段三_技术实现层.md）：

### 后端端点（ConfiguratorController 已实施）
| 端点 | 说明 |
|------|------|
| `GET /cpq/configure/model/{id}` | 加载产品配置模型 |
| `POST /cpq/configure/validate` | CSP全量校验 |
| `POST /cpq/configure/propagate` | MAC-3增量约束传播 |
| `POST /cpq/configure/guide` | 向导式配置5状态机（QUESTIONING/NARROWING/RECOMMENDING/CONFIGURING/COMPLETED） |
| `POST /cpq/configure/bom-preview` | **新增**：ATO BOM实时预览（sbomToMbom五阶段转换） |
| `POST /cpq/configure/complete` | 完成配置（验证→BOM→定价） |

### 前端页面（cpq-portal 已实施）
| 页面 | 路由 | 说明 |
|------|------|------|
| ProductSearch.vue | /configure | 产品搜索 |
| Configurator.vue | /configure/:modelId | 三栏CSP配置器 |
| StandardConfigure.vue | /configure-standard | 新建标准配置（STANDARD产品+4步引导） |
| GuidedSelling.vue | /configure-guided + /configure-guided/:modelId | 向导式配置5阶段 |
| AtoCustomize.vue | /configure-ato | ATO搜索+标准配置+定制面板+BOM实时刷新 |
| ConfigurationReview.vue | /configure-review/:modelId | **新增**：配置回顾（只读store，展示完整配置+MBOM+价格） |

### 关键设计决策
- **向导式 CONFIGURING 状态**：前端直接转换（绕过API），后端 guidedSelling() 不返回此状态
- **BOM预览**：使用 store.previewBomLines（MBOM格式），列 prop 为 materialCode/materialDesc/unit
- **变体BOM**：依赖 cpq_variant_bom.effectivity_condition JSON 过滤 is_required='0' 的非必选 SBOM 行
- **ConfigurationReview**：只读 store 不调用任何 API，区别于 Configurator.vue（会 initModel 清空数据）
- **startOver()**：直接调用 initWizard(modelId) 原地重新初始化，不用 router.push（同路由不触发 navigation）

## Sprint 7/8 报价+审批速查
| 组件 | 路径 | 用途 |
|------|------|------|
| ruoyi-cpq-quote | ruoyi-modules/ | 6表CRUD: Quote/LineItem/Snapshot/Version/Template/Solution |
| ruoyi-cpq-approval | ruoyi-modules/ | 4表CRUD+引擎: Rule/Chain/Record/Matrix + ApprovalRouteService |
| **ApprovalActionController** | approval/controller/ | 审批操作 REST API: processAction / escalateTimeout |
| /cpq/quote/header/* | REST | 报价单 CRUD |
| /cpq/quote/lineitem/* | REST | 行项目 CRUD |
| /cpq/approval/rule/* | REST | 审批规则 CRUD |
| /cpq/approval/chain/* | REST | 审批链 CRUD |
| /cpq/approval/action/process | REST | 审批动作处理 |
| ApprovalRouteService | approval/service/ | buildChain/processAction/escalateTimeout |
| QuoteList.vue | views/quoting/ | 报价单列表+搜索+CRUD弹窗 |
| QuoteDetail.vue | views/quoting/ | 报价单详情+行项目管理+预览入口+版本对比入口 |
| **QuoteVersion.vue** | views/quoting/ | 双版本选择器+并排/统一差异+回滚 |
| **QuotePreview.vue** | components/quoting/ | 报价单预览对话框+打印+PDF/Word导出 |
| **TemplateSelector.vue** | components/quoting/ | 网格卡片模板选择器 |
| PendingApproval.vue | views/approval/ | 待审批列表 |
| ApprovalDetail.vue | views/approval/ | 审批详情+节点可视+操作组件+时间线 |
| **ApprovalHistory.vue** | views/approval/ | 审批历史列表+筛选+详情抽屉+耗时计算 |
| **ApprovalNode.vue** | components/approval/ | 链式流程节点+4色状态+脉冲动画+SLA警告 |
| **ApprovalAction.vue** | components/approval/ | 通过/驳回/转审/加签+弹窗确认 |
| quoting.ts | api/ | 6域API+类型定义 |
| approval.ts | api/ | 4域API+审批动作API+类型定义 |
| quote.ts | store/ | 报价Pinia Store |
| approval.ts | store/ | 审批Pinia Store |

---

## 项目状态总览（2026-06-23 更新）

### 一、整体进度

| 阶段 | 状态 | 完成日期 |
|------|:----:|----------|
| S1-S21 全部 Sprint | ✅ | 2026-06-09 |
| CRM 信息模块 v1.0 | ✅ | 2026-06-15 |
| 报价模板管理模块 | ✅ | 2026-06-13 |
| 配置管理功能（5页面+6端点） | ✅ | 2026-06-13 |

### 二、当前运行状态

| 组件 | 端口 | 状态 |
|------|:----:|------|
| MySQL | 3306 | ✅ 运行中 |
| Redis | 6379 | ✅ 运行中 |
| 后端 Admin JAR | 8080 | ✅ 运行中 |
| cpq-portal 前端 | 3000 | ✅ 运行中 |
| 数据库 Ruoyi_CPQ | — | ✅ 包含所有CPQ表 |

### 三、Maven 模块清单（14个CPQ模块）

1. `ruoyi-cpq` — 产品主数据
2. `ruoyi-cpq-pricing` — 定价域
3. `ruoyi-cpq-config` — 配置引擎+Bundle捆绑
4. `ruoyi-cpq-quote` — 报价数据域+QuoteGenerateService+AtpCtpService+报价模板管理
5. `ruoyi-cpq-approval` — 审批数据域+ApprovalRouteService+ApprovalActionController
6. `ruoyi-cpq-customer` — 客户渠道域（S11）
7. `ruoyi-cpq-ecn` — 工程变更模块（S12）
8. `ruoyi-cpq-integration` — 集成数据域（S13）
9. `ruoyi-cpq-competitive` — 竞品对标模块（S14）
10. `ruoyi-cpq-migration` — 数据迁移模块（S14）
11. `ruoyi-cpq-knowledge` — 知识库模块（S15）
12. **`ruoyi-cpq-crm`** — **CRM信息模块（2026-06-15 新增，31个Java文件）**

### 四、CRM 模块详细状态

**后端**：5 Entity + 5 Mapper + 4 BO + 5 VO + 4 Service + 4 ServiceImpl + 4 Controller，共31个Java文件，29个Swagger端点全部注册
**前端**：10个Vue页面 + 3个组件，1个API文件(crm.ts)，菜单和路由已配置
**数据库**：5张CRM表已在MySQL创建（cpq_crm_opportunity/contract/order/order_line/activity），cpq_account已增加2个字段
**编译**：Maven BUILD SUCCESS，vue-tsc 0新增错误
**测试**：29个Swagger端点已注册，Playwright浏览器测试通过，4个前端页面HTTP 200

### 五、已修复的问题

1. **CRM表不存在**（2026-06-15）：SQL DDL脚本未执行到MySQL → 修 SQL语法（MySQL不支持`ADD COLUMN IF NOT EXISTS`）→ 执行建表 → 5张表全部创建成功
2. **跨模块字段名不匹配**：CpqQuote.getGrandTotal() vs getTotalAmount()、CpqQuoteLineItem.getLineId() vs getLineItemId()
3. **LambdaUpdateWrapper软删除语法**：`.set("del_flag","2")` → `.setSql("del_flag = '2'")`

### 六、已知待处理问题

1. **CRM前端页面功能验证**：虽然后端API端点存在且数据库表已创建，但尚未进行完整的前端增删改查交互验证（如新增商机是否真的能写入数据库）
2. **合同→订单集成链**：fromOpportunity(商机→合同→订单)和fromQuote(报价→订单)两条集成链路仅在Service层实现，前端触发按钮是否正常工作待验证
3. **商机阶段推进逻辑**：6阶段不可回退校验+概率自动计算+活动日志自动记录，后端逻辑完整但缺少业务数据测试
4. **cpq_quote.opportunity_id字段类型**：当前为VARCHAR，设计文档建议改为BIGINT FK → cpq_crm_opportunity，尚未修改
5. **权限配置**：CRM模块定义了16个权限字符串（cpq:crm:xxx:*），但sys_menu表未追加菜单SQL（50150-50179）
6. **BO继承链**：CRM模块4个BO extends Entity（非TenantEntity），无@AutoMapper注解。当前使用Hutool BeanUtil.toBean()可用，但与Ruoyi-Vue-Plus框架的MapStruct Plus模式不一致
7. **全局 @AutoMapper**：整个CPQ项目未引入MapStruct Plus，所有模块均使用BeanUtil做对象转换

### 七、下一步工作建议

1. **P0 - 交互验证**：用Playwright打开CRM各页面，执行新增→编辑→删除完整CRUD流程，确认数据能正确写入和回显
2. **P0 - 集成链路测试**：端到端验证：客户→商机→报价→合同→订单全链路
3. **P1 - 菜单SQL**：补充`sql/cpq_menu.sql`追加CRM菜单50150-50179
4. **P1 - opportunity_id字段类型升级**：ALTER TABLE cpq_quote MODIFY COLUMN opportunity_id BIGINT
5. **P1 - 权限字符串注册**：在cpq-portal/src/config/permissions.ts追加CRM权限
6. **P2 - 发布流程**：mvn clean package全量打包 → 部署新jar → 数据库迁移脚本执行
7. **P2 - 后续功能**：参照设计文档中Planned phase的功能（移动端CRM视图、仪表板、合同审批流程细化等）

### 八、关键配置速查

| 配置项 | 值 |
|--------|-----|
| 数据库 | Ruoyi_CPQ, localhost:3306, root/Storm123@ |
| Redis | localhost:6379, 密码 ruoyi123 |
| 后端端口 | 8080 |
| 前端端口 | 3000 |
| 管理员 | admin / admin123 |
| 后端JAR | `ruoyi-admin 2/target/ruoyi-admin.jar` |
| 前端启动 | `cd cpq-portal && npm run dev` |
| Maven构建 | `mvn clean package -pl ruoyi-admin\ 2 -am -DskipTests` |
| 登录API | POST /auth/login, body包含clientId/grantType/username/password/tenantId |
| 认证头 | Authorization: Bearer \<token\> + clientid: e5cd7e4891bf95d1d19206ce24a7b32e |

### 九、工作约定

- 所有终端命令自动执行，`requires_approval=false`
- 开发完成后必须先编译验证再测试
- 新增Maven模块必须同时注册modules/pom.xml和admin/pom.xml（注意带&lt;version&gt;）
- 新增数据库表后必须实际执行DDL到MySQL
- DDL表必须包含所有TenantEntity/BaseEntity系统字段
- 禁止使用res.data/.data解构（响应拦截器已自动解包）
- 路径拼接前先`.replace(/^\\/+/, '')`去前导斜杠
- FK字段前端用下拉搜索组件，禁止裸el-input-number
