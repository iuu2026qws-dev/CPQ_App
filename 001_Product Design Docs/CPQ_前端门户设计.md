# 制造业智能CPQ — 前端门户应用设计

> **版本**：V2.1（补全版）  
> **日期**：2026年6月6日  
> **基于**：RuoYi-Vue-Plus 框架(Java/SpringBoot+Vue3+TS+ElementPlus) + CPQ三阶段产品设计  
> **设计范围**：前端用户门户（销售工作台/渠道门户/移动端），不含后台管理系统（后者由RuoYi-Vue-Plus自带admin模块提供）  
> **技术栈裁决**：本项目后端采用RuoYi-Vue-Plus（Java/SpringBoot），前端采用Vue3+ElementPlus（与RuoYi统一技术栈）。阶段三的Go技术方案作为备选参考，当项目需要独立高性能微服务时可采用方案C（Go微服务+RuoYi认证平台混合部署）。

---

## 目录

- [1. 应用架构总览](#1-应用架构总览)
- [2. 技术栈与集成方案](#2-技术栈与集成方案)
- [3. 菜单结构与路由设计](#3-菜单结构与路由设计)
- [4. 门户首页设计](#4-门户首页设计)
- [5. 核心页面布局设计](#5-核心页面布局设计)
- [6. UI设计系统](#6-ui设计系统)
- [7. 角色与视图映射](#7-角色与视图映射)
- [8. 关键页面设计规格](#8-关键页面设计规格)
- [9. 与RuoYi-Vue-Plus后台的集成](#9-与ruoyi-vue-plus后台的集成)
- [10. 移动端适配策略](#10-移动端适配策略)
- [11. 设计决策总结](#11-设计决策总结)
- [附录A：阶段二P0功能→前端组件映射表](#附录a阶段二p0功能前端组件映射表)
- [附录B：阶段二7流程→前端页面流映射](#附录b阶段二7流程前端页面流映射)
- [附录C：阶段三70 API端点→前端API模块映射](#附录c阶段三70-api端点前端api模块映射)
- [附录D：阶段一设计Token→前端SCSS变量对照](#附录d阶段一设计token前端scss变量对照)
- [附录E：V2.0报告→前端设计完整追溯矩阵](#附录e-v20报告前端设计完整追溯矩阵)

---

## 1. 应用架构总览

### 1.1 双端分离架构

```
┌─────────────────────────────────────────────────────────┐
│                    RuoYi-Vue-Plus 后台                    │
│  ┌───────────────────────────────────────────────────┐  │
│  │  ruoyi-admin (Spring Boot + Undertow :30000)        │  │
│  │  ├─ Sa-Token + JWT 认证                            │  │
│  │  ├─ RBAC 权限管理 (sys_user/sys_role/sys_menu)     │  │
│  │  ├─ 多租户 (sys_tenant)                            │  │
│  │  ├─ 工作流引擎                                     │  │
│  │  ├─ OSS文件存储 (MinIO)                            │  │
│  │  ├─ 代码生成器                                     │  │
│  │  ├─ 系统管理（用户/角色/菜单/部门/岗位/字典/参数）      │  │
│  │  └─ 监控（SpringBoot-Admin + SkyWalking）          │  │
│  └───────────────────────────────────────────────────┘  │
│                                                          │
│  ┌──────────────────────┐  ┌──────────────────────────┐  │
│  │  ruoyi-ui (管理后台)   │  │  cpq-portal (CPQ前端)    │  │
│  │  ────────────────    │  │  ─────────────────       │  │
│  │  Vue3 + ElementPlus  │  │  Vue3 + ElementPlus      │  │
│  │  系统管理/监控/租户    │  │  + CPQ业务组件库          │  │
│  │  端口: 80            │  │  端口: 3000              │  │
│  │                      │  │                          │  │
│  │  使用者: 系统管理员    │  │  使用者: 销售/售前/渠道    │  │
│  │                      │  │         /产品经理/审批人   │  │
│  └──────────────────────┘  └──────────────────────────┘  │
└─────────────────────────────────────────────────────────┘
```

### 1.2 项目目录结构

```
cpq-portal/
├── public/
│   └── favicon.ico
├── src/
│   ├── api/                        # API 接口层
│   │   ├── configure/              # 配置引擎接口
│   │   ├── pricing/                # 定价引擎接口
│   │   ├── quoting/                # 报价引擎接口
│   │   ├── approval/               # 审批接口
│   │   ├── solution/               # 方案管理接口
│   │   ├── presales/               # 售前协同接口
│   │   ├── competitive/            # 竞品对标接口
│   │   ├── atpctp/                 # 交期承诺接口
│   │   ├── product/                # 产品与BOM接口
│   │   ├── system/                 # 复用RuoYi系统接口
│   │   └── integration/            # 集成接口
│   ├── assets/                     # 静态资源
│   │   ├── images/
│   │   └── styles/
│   │       ├── variables.scss      # CPQ设计Token
│   │       ├── mixins.scss
│   │       └── cpq-theme.scss      # CPQ主题覆盖ElementPlus
│   ├── components/                 # CPQ业务组件库
│   │   ├── configurator/           # 配置器组件
│   │   │   ├── OptionCard.vue      # 选项卡片(四态)
│   │   │   ├── AttributeSelector.vue  # 属性选择器
│   │   │   ├── ConfigTree.vue      # 5层产品结构树
│   │   │   ├── BomPreview.vue      # BOM预览面板(虚拟滚动)
│   │   │   └── GuidedWizard.vue    # 向导式销售步骤器
│   │   ├── pricing/                # 定价组件
│   │   │   ├── PriceBreakdown.vue  # 价格明细分解
│   │   │   └── DiscountSlider.vue  # 折扣滑动选择器
│   │   ├── quoting/                # 报价组件
│   │   │   ├── QuotePreview.vue    # 报价单预览
│   │   │   ├── TemplateSelector.vue  # 模板选择器
│   │   │   └── DeliveryKit.vue     # 方案交付套装
│   │   ├── comparison/             # 对比组件
│   │   │   ├── RadarChart.vue      # 多方案雷达图
│   │   │   ├── ComparisonMatrix.vue # 并排对比矩阵
│   │   │   └── WaterfallChart.vue  # 成本瀑布图
│   │   ├── search/                 # 搜索组件
│   │   │   ├── MultiModalSearch.vue # 多模态搜索
│   │   │   └── SceneNavigator.vue  # 场景导航面包屑
│   │   ├── approval/               # 审批组件
│   │   │   ├── ApprovalNode.vue    # 审批节点可视化
│   │   │   └── ApprovalAction.vue  # 审批操作(通过/驳回)
│   │   ├── atp/                    # 交期组件
│   │   │   ├── AtpIndicator.vue    # ATP状态指示器
│   │   │   └── DeliveryTimeline.vue # 交期时间线
│   │   ├── collaborative/          # 协同组件
│   │   │   ├── SolutionEditor.vue  # 方案协同编辑器
│   │   │   └── ReviewWorkbench.vue # 评审工作台
│   │   └── common/                 # 通用组件
│   │       ├── CpqCard.vue         # CPQ卡片容器
│   │       ├── StatusBadge.vue     # 状态徽章
│   │       ├── DataTable.vue       # 数据表格(基于ag-Grid)
│   │       └── EmptyState.vue      # 空状态
│   ├── composables/                # 组合式函数
│   │   ├── useConfigurator.ts      # 配置器逻辑
│   │   ├── usePricing.ts           # 定价计算
│   │   ├── useAtpCtp.ts            # 交期检查
│   │   └── useAuth.ts             # 认证与权限
│   ├── directives/                 # 自定义指令
│   │   ├── v-hasPermi.ts           # RBAC权限（复用RuoYi）
│   │   ├── v-hasRole.ts            # 角色控制
│   │   └── v-cost-visibility.ts   # 成本可见性控制(ABAC L0-L3)
│   ├── layout/                     # 布局组件
│   │   ├── PortalLayout.vue        # 主布局(侧边栏+顶栏+内容)
│   │   ├── SalesDeskLayout.vue     # 销售工作台布局(宽屏三栏)
│   │   ├── PartnerLayout.vue       # 渠道伙伴布局(简化版)
│   │   ├── MobileLayout.vue        # 移动端布局(底部Tab)
│   │   ├── Sidebar.vue             # 侧边导航(角色自适应)
│   │   ├── Navbar.vue              # 顶栏(全局搜索+通知+用户)
│   │   └── Breadcrumb.vue          # 面包屑
│   ├── router/                     # 路由
│   │   ├── index.ts                # 路由主文件
│   │   └── modules/                # 按模块拆分路由
│   │       ├── dashboard.ts
│   │       ├── configure.ts
│   │       ├── quoting.ts
│   │       ├── solution.ts
│   │       ├── approval.ts
│   │       ├── atpctp.ts
│   │       ├── presales.ts
│   │       ├── competitive.ts
│   │       ├── product.ts
│   │       ├── pricing.ts
│   │       ├── knowledge.ts
│   │       ├── integration.ts
│   │       └── settings.ts
│   ├── store/                      # 状态管理 (Pinia)
│   │   ├── modules/
│   │   │   ├── user.ts             # 用户信息+角色+权限
│   │   │   ├── app.ts              # 应用配置(主题/语言/布局)
│   │   │   ├── configurator.ts     # 当前配置会话状态
│   │   │   ├── quote.ts            # 当前报价单状态
│   │   │   └── tenant.ts           # 租户上下文
│   │   └── index.ts
│   ├── views/                      # 页面视图
│   │   ├── dashboard/              # 首页工作台
│   │   │   ├── SalesDashboard.vue  # 销售视图首页
│   │   │   ├── PresalesDashboard.vue # 售前视图首页
│   │   │   ├── ManagerDashboard.vue  # 管理视图首页
│   │   │   ├── PartnerDashboard.vue  # 渠道伙伴首页
│   │   │   ├── ProductDashboard.vue  # 产品经理首页
│   │   │   ├── PricingDashboard.vue  # 定价管理员首页
│   │   │   ├── SupplyDashboard.vue   # 供应链首页(产能+物料预警)
│   │   │   ├── ApprovalDashboard.vue # 审批人首页
│   │   │   ├── OperationsDashboard.vue # 销售运营首页
│   │   │   ├── ExecutiveDashboard.vue  # 高管首页
│   │   │   └── AuditDashboard.vue      # 审计首页(只读)
│   │   ├── configure/              # 配置模块页面
│   │   │   ├── ProductSearch.vue   # 产品搜索页
│   │   │   ├── Configurator.vue    # 配置器主页面
│   │   │   ├── GuidedSelling.vue   # 向导式销售页面
│   │   │   └── AtoCustomize.vue    # ATO定制配置页
│   │   ├── quoting/                # 报价模块页面
│   │   │   ├── QuoteList.vue       # 报价单列表
│   │   │   ├── QuoteDetail.vue     # 报价单详情
│   │   │   ├── QuoteCreate.vue     # 创建报价单
│   │   │   ├── QuoteVersion.vue    # 版本对比
│   │   │   └── QuoteLineManager.vue # 行项目管理
│   │   ├── solution/               # 方案模块页面
│   │   │   ├── SolutionList.vue    # 方案列表
│   │   │   ├── SolutionEditor.vue  # 方案编辑器(CRDT)
│   │   │   ├── SolutionCompare.vue # 方案对比页
│   │   │   └── SolutionReview.vue  # 方案评审
│   │   ├── approval/               # 审批模块页面
│   │   │   ├── PendingApproval.vue # 待审批列表
│   │   │   ├── ApprovalDetail.vue  # 审批详情
│   │   │   ├── ApprovalHistory.vue # 审批历史
│   │   │   └── ApprovalAnalytics.vue # 审批效率看板
│   │   ├── presales/               # 售前协同页面
│   │   │   ├── TaskBoard.vue       # 任务看板
│   │   │   ├── CollabEditor.vue    # 协同编辑
│   │   │   └── ReviewWorkbench.vue # 评审工作台
│   │   ├── competitive/            # 竞品对标页面
│   │   │   ├── CompetitorList.vue  # 竞品库管理
│   │   │   ├── ComparisonView.vue  # 参数对比视图
│   │   │   └── RecommendationView.vue # 差异化推荐
│   │   ├── pricing/                # 定价管理页面
│   │   │   ├── PriceBookList.vue   # 价格手册列表
│   │   │   ├── PriceRuleConfig.vue # 定价规则配置
│   │   │   ├── VolumeTierConfig.vue # 阶梯定价
│   │   │   ├── DiscountApproval.vue # 折扣审批
│   │   │   └── CurrencyConfig.vue   # 多币种管理
│   │   ├── product/                # 产品管理页面
│   │   │   ├── ProductCategory.vue # 产品分类(3层树, V1.2新增)
│   │   │   ├── ProductCatalog.vue  # 产品目录
│   │   │   ├── BomManager.vue      # BOM管理(递归展开)
│   │   │   ├── ConfigRuleManager.vue # 配置规则管理
│   │   │   ├── AttributeOptionManager.vue # 属性选项管理（V1.2新增）
│   │   │   ├── SupersessionManager.vue # 替代品管理
│   │   │   └── BundleManager.vue   # 捆绑包管理（V1.1新增）
│   │   ├── atpctp/                 # 交期查询页面
│   │   │   ├── AtpCheck.vue        # 交期检查
│   │   │   ├── AtpBatch.vue        # 批量交期查询
│   │   │   └── SlaDashboard.vue    # 交期SLA看板
│   │   ├── knowledge/              # 知识库页面
│   │   │   ├── ProductKnowledge.vue # 产品知识库
│   │   │   ├── SalesScripts.vue    # 销售话术库
│   │   │   ├── CaseLibrary.vue     # 成功案例库
│   │   │   └── TrainingCenter.vue  # 培训认证中心
│   │   ├── integration/            # 系统集成页面(管理员)
│   │   │   ├── CrmConnector.vue    # CRM连接器配置
│   │   │   ├── ErpConnector.vue    # ERP连接器配置
│   │   │   ├── PlmConnector.vue    # PLM连接器配置
│   │   │   └── SyncLogViewer.vue   # 同步日志查看
│   │   ├── settings/               # 系统设置页面(管理员)
│   │   │   ├── TenantConfig.vue    # 租户配置
│   │   │   ├── UserManagement.vue  # 用户管理
│   │   │   ├── RoleManagement.vue  # 角色管理
│   │   │   ├── AbacPolicyConfig.vue # ABAC策略配置
│   │   │   ├── AuditLogViewer.vue  # 审计日志查看
│   │   │   ├── DataMigration.vue   # 数据迁移工具
│   │   │   ├── ChangeManagement.vue # ECN/ECO变更管理
│   │   │   └── SystemParams.vue    # 系统参数
│   │   └── profile/                # 个人中心
│   │       └── UserProfile.vue
│   ├── utils/                      # 工具函数
│   │   ├── request.ts              # Axios封装(含Sa-Token)
│   │   ├── auth.ts                 # Token管理
│   │   ├── permission.ts           # 权限校验
│   │   └── dict.ts                 # 字典工具(复用RuoYi)
│   ├── App.vue
│   └── main.ts                     # 入口文件
├── vite.config.ts
├── package.json
└── tsconfig.json
```

### 1.3 与RuoYi-Vue-Plus的关系

> **数据库 DDL 文件**：本前端门户所依赖的全部 43 张 CPQ 业务表的 DDL 定义存放在 `sql/` 目录下，按数据域分为 8 个 SQL 文件。开发或部署时按 Sprint 阶段执行对应 DDL。前端 API 接口层（`src/api/`）的 TypeScript 类型定义需与对应 DDL 表结构保持一致。DDL 文件清单详见 `CPQ_后端功能设计.md` §4.2 或 `.codebuddy/development_plan.md` SQL 文件清单。

| 维度 | CPQ前端门户 (cpq-portal) | RuoYi-Vue-Plus (ruoyi-ui) |
|------|------------------------|--------------------------|
| **定位** | CPQ业务操作入口 | 系统管理后台 |
| **使用者** | 销售/售前/渠道/产品/审批人 | 系统管理员/IT运维 |
| **认证** | **复用** Sa-Token + JWT (同一认证中心) | Sa-Token + JWT |
| **权限** | **复用** RBAC (sys_user/role/menu) + **新增** ABAC (v-cost-visibility) | RBAC |
| **菜单** | **复用** sys_menu表，新增CPQ菜单项 | sys_menu管理 |
| **字典** | **复用** sys_dict_type/sys_dict_data | sys_dict管理 |
| **多租户** | **复用** sys_tenant，请求头自动注入tenant_id | sys_tenant管理 |
| **文件** | **复用** OSS(MinIO)上传下载 | OSS管理 |
| **通知** | **复用** SSE推送 + WebSocket | SSE/WS管理 |
| **组件库** | Element Plus + **CPQ业务组件库**（自建） | Element Plus |
| **部署** | 独立Nginx站点 :3000（dev）/ Nginx反向代理统一端口（prod） | 独立Nginx站点 :80（dev）/ Nginx反向代理统一端口（prod） |
| **SSO** | 同域 Cookie Token + localStorage 共享（prod）/ 独立登录（dev） | 同域 Cookie Token + localStorage 共享（prod）/ 独立登录（dev） |

---

## 2. 技术栈与集成方案

### 2.1 前端技术栈

| 层面 | 选型 | 理由 |
|------|------|------|
| 框架 | Vue 3.5+ + TypeScript | 与RuoYi-Vue-Plus统一技术栈 |
| UI库 | Element Plus 2.x | 与RuoYi-Vue-Plus统一UI库，降低学习成本 |
| 高级表格 | ag-Grid Community | 虚拟滚动支撑万级BOM行、方案对比矩阵 |
| 图表 | ECharts 5 | 雷达图/成本瀑布图/交期甘特图 |
| 状态管理 | Pinia | Vue3官方推荐，Treeshaking友好 |
| 路由 | Vue Router 4 | 动态路由 + 菜单权限过滤 |
| HTTP | Axios + 请求/响应拦截器 | 统一Token注入 + 错误处理 |
| 构建 | Vite 6 | 与RuoYi统一构建工具 |
| 富文本 | Tiptap | 方案编辑器协同编辑 |
| 实时协同 | Yjs + y-websocket | 方案协同编辑CRDT |
| 虚拟滚动 | vue-virtual-scroller | 配置树/BOM面板大数据渲染 |

### 2.2 认证集成方案

```typescript
// src/utils/auth.ts — 复用RuoYi的Sa-Token认证
import { getToken, setToken, removeToken } from '@/utils/auth'

// 请求拦截器
axios.interceptors.request.use(config => {
  // 自动注入Token（复用RuoYi的Sa-Token格式）
  const token = getToken()
  if (token) {
    config.headers['Authorization'] = `Bearer ${token}`
  }
  // 注入租户ID（复用RuoYi多租户）
  const tenantId = useTenantStore().tenantId
  if (tenantId) {
    config.headers['tenant-id'] = tenantId
  }
  // 注入语言偏好
  config.headers['Accept-Language'] = useAppStore().locale
  return config
})
```

### 2.2.1 同域 SSO 单点登录方案

**核心原理**：生产环境通过 Nginx 反向代理将 ruoyi-ui（管理后台）和 cpq-portal（业务门户）挂载到同一域名不同路径下，共享浏览器 origin，**localStorage 和 Cookie 天然互通**，无需额外 SSO 协议。

**环境差异**：

| 环境 | ruoyi-ui (admin-portal) | cpq-portal | SSO 实现 |
|------|------------------------|------------|---------|
| 开发 | `localhost:80` | `localhost:3000` | 各自独立登录（不同端口 = 不同 origin，不共享 localStorage） |
| 生产 | `cpq.example.com/admin/` | `cpq.example.com/portal/` | Nginx 反向代理统一端口 80/443，同 origin → localStorage 天然共享 + Cookie Domain 兜底 |

**生产环境 Nginx 配置**：

```nginx
server {
    listen 80;
    listen [::]:80;
    server_name cpq.example.com;

    # ruoyi-ui 管理后台
    location /admin/ {
        root /opt/ruoyi-ui/dist;
        index index.html;
        try_files $uri $uri/ /admin/index.html;
    }

    # cpq-portal 业务门户
    location /portal/ {
        root /opt/cpq-portal/dist;
        index index.html;
        try_files $uri $uri/ /portal/index.html;
    }

    # 后端 API 统一代理
    location /api/ {
        proxy_pass http://127.0.0.1:30000/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

**认证共享链路**：

```
用户登录 ruoyi-ui /admin/login
  → POST /api/auth/login → 后端返回 access_token
  → localStorage['cpq_token'] = token （admin 和 portal 共享同一 origin）
  → 用户访问 cpq-portal /portal/
  → cpq-portal 的 auth.ts 读取 localStorage['cpq_token']
  → Authorization: Bearer <token> 注入请求
  → 后端 Sa-Token 验证通过 → 无需二次登录
```

**Cookie 兜底**：后端 Sa-Token 配置 `token-prefix=cpq` + Cookie 模式作为备选，当 localStorage 不可用时自动回退 Cookie 读取，确保隐私模式等极端场景下 SSO 仍然有效。

**开发环境**：两个应用各跑各的端口，各自登录。开发时不做 SSO（不同端口 → 不同 origin → localStorage 隔离），但这不影响功能开发——cpq-portal 的 `auth.ts` 代码与 ruoyi-ui 完全一致，部署到生产后 SSO 自动生效。

### 2.3 权限集成方案

```typescript
// 复用RuoYi的RBAC + 扩展CPQ的ABAC

// L1: RBAC角色权限 (复用RuoYi v-hasPermi)
// 格式: cpq:module:action  e.g. cpq:configure:edit
<el-button v-hasPermi="['cpq:configure:edit']">保存配置</el-button>

// L2: ABAC成本可见性 (CPQ新增)
// 成本可见性4级控制：
//   L0 = 渠道伙伴：仅协议价，无成本信息
//   L1 = 销售代表：销售价 + 毛利百分比
//   L2 = 售前/销售经理：销售价 + 毛利 + 物料成本合计
//   L3 = 定价/财务/高层：全成本(物料+人工+制造费用+外协)
<cost-field :value="item.cost" v-cost-visibility="2" />
// 仅cost_visibility_level >= 2的用户可见成本数据
```

---

## 3. 菜单结构与路由设计

### 3.1 菜单树结构

基于CPQ 12角色和15模块，设计统一的菜单树。通过RuoYi的RBAC机制，不同角色看到的菜单子集不同。

```
CPQ门户菜单
├── 🏠 首页工作台               /dashboard
│   ├── 我的工作台              /dashboard/home
│   ├── 我的报价单              /dashboard/my-quotes
│   ├── 待处理审批              /dashboard/pending-approvals
│   └── 我的任务                /dashboard/my-tasks
│
├── 🔧 配置报价                /configure
│   ├── 产品搜索               /configure/search
│   ├── 新建标准配置            /configure/standard
│   ├── 向导式配置              /configure/guided
│   ├── ATO定制配置             /configure/ato
│   └── 渠道自助配置(伙伴专属)    /configure/channel
│
├── 📋 报价管理                /quoting
│   ├── 报价单列表              /quoting/list
│   ├── 新建报价                /quoting/create
│   ├── 报价模板                /quoting/templates
│   └── 已发送报价              /quoting/sent
│
├── 📊 方案管理                /solution
│   ├── 方案列表                /solution/list
│   ├── 方案编辑器              /solution/editor
│   ├── 方案对比                /solution/compare
│   └── 方案评审                /solution/review
│
├── ✅ 审批中心                /approval
│   ├── 待我审批                /approval/pending
│   ├── 我已审批                /approval/processed
│   ├── 我发起的                /approval/initiated
│   └── 审批效率看板             /approval/analytics
│
├── 🤝 售前协同                /presales
│   ├── 任务看板                /presales/board
│   ├── 协同编辑                /presales/collab
│   └── 评审工作台              /presales/review
│
├── ⚔️ 竞品对标                /competitive
│   ├── 竞品库                  /competitive/library
│   └── 对比分析                /competitive/compare
│
├── 📦 产品管理                /product
│   ├── 产品分类(3层树)         /product/category
│   ├── 产品目录                /product/catalog
│   ├── BOM管理                 /product/bom
│   ├── 配置规则                /product/rules
│   ├── 替代品管理              /product/supersession
│   └── 捆绑包管理              /product/bundle
│
├── 💰 定价管理                /pricing
│   ├── 价格手册                /pricing/books
│   ├── 定价规则                /pricing/rules
│   └── 折扣审批                /pricing/discounts
│
├── ⏱️ 交期查询                /atpctp
│   ├── 交期检查                /atpctp/check
│   ├── 批量交期查询            /atpctp/batch
│   └── 交期SLA看板             /atpctp/sla
│
├── 📚 知识库                  /knowledge
│   ├── 产品知识                /knowledge/products
│   ├── 销售话术                /knowledge/scripts
│   ├── 成功案例                /knowledge/cases
│   └── 培训认证                /knowledge/training
│
├── 🔄 系统集成                /integration (管理员)
│   ├── CRM连接器              /integration/crm
│   ├── ERP连接器              /integration/erp
│   ├── PLM连接器              /integration/plm
│   └── 同步日志                /integration/logs
│
├── ⚙️ 系统设置                /settings (管理员+审计)
│   ├── 租户配置                /settings/tenant
│   ├── 用户管理                /settings/users
│   ├── 角色管理                /settings/roles
│   ├── ABAC策略               /settings/abac
│   ├── 审计日志                /settings/audit (审计: 只读完整访问)
│   ├── 数据迁移                /settings/migration
│   ├── 变更管理                /settings/ecn
│   └── 系统参数                /settings/params
│
└── 📱 个人中心                /profile
    ├── 个人信息                /profile/info
    ├── 消息通知                /profile/notifications
    └── 帮助文档                /profile/help
```

### 3.2 按角色的菜单可见性

| 菜单项 | 销售 | 售前 | 经理 | 渠道 | 产品 | 定价 | 供应链 | 审批人 | 运营 | 高管 | 审计 | 管理员 |
|--------|:--:|:--:|:--:|:--:|:--:|:--:|:----:|:----:|:--:|:--:|:--:|:----:|
| 首页工作台 | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | — | ✅ |
| 配置报价 | ✅ | ✅ | ✅ | ✅ | — | — | — | — | — | — | — | — |
| 报价管理 | ✅ | ✅ | ✅ | ✅ | — | — | — | — | — | — | — | — |
| 方案管理 | — | ✅ | ✅ | — | — | — | — | — | — | — | — | — |
| 审批中心 | ✅ | ✅ | ✅ | — | ✅ | ✅ | ✅ | ✅ | — | ✅ | — | ✅ |
| 售前协同 | ✅ | ✅ | ✅ | — | — | — | — | — | — | — | — | — |
| 竞品对标 | — | ✅ | ✅ | — | ✅ | — | — | — | ✅ | ✅ | — | — |
| 产品管理 | — | — | — | — | ✅ | — | ✅ | — | — | — | — | — |
| 定价管理 | — | — | — | — | — | ✅ | — | — | — | — | — | — |
| ATP/CTP交期 | ✅ | ✅ | ✅ | ✅ | — | — | ✅ | — | — | ✅ | — | — |
| 知识库 | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | — | — | ✅ | — | — | ✅ |
| 系统集成 | — | — | — | — | — | — | — | — | — | — | — | ✅ |
| 系统设置 | — | — | — | — | — | — | — | — | — | — | ✅(只读) | ✅ |
| 个人中心 | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |

### 3.3 路由权限控制

```typescript
// src/router/modules/configure.ts
export default {
  path: '/configure',
  component: () => import('@/layout/PortalLayout.vue'),
  meta: { 
    title: '配置报价', 
    icon: 'Setting',
    roles: ['sales', 'presales', 'manager', 'partner'] // 角色级过滤
  },
  children: [
    {
      path: 'search',
      name: 'ProductSearch',
      component: () => import('@/views/configure/ProductSearch.vue'),
      meta: { 
        title: '产品搜索', 
        permission: 'cpq:configure:search'  // 权限字符串（RuoYi RBAC）
      }
    },
    {
      path: 'standard',
      name: 'StandardConfig',
      component: () => import('@/views/configure/Configurator.vue'),
      meta: { title: '标准配置', permission: 'cpq:configure:standard' }
    },
    {
      path: 'guided',
      name: 'GuidedSelling',
      component: () => import('@/views/configure/GuidedSelling.vue'),
      meta: { title: '向导式配置', permission: 'cpq:configure:guided' }
    },
    {
      path: 'ato',
      name: 'AtoCustomize',
      component: () => import('@/views/configure/AtoCustomize.vue'),
      meta: { title: 'ATO定制', permission: 'cpq:configure:ato', roles: ['sales','presales'] }
    },
    {
      path: 'channel',
      name: 'ChannelConfig',
      component: () => import('@/views/configure/Configurator.vue'),
      meta: { title: '渠道自助', permission: 'cpq:configure:channel', roles: ['partner'] }
    }
  ]
}
```

---

## 4. 门户首页设计

### 4.1 首页布局

```
┌─────────────────────────────────────────────────────────────┐
│ 顶栏                                                         │
│ [SmartCPQ Logo]  🔍 全局搜索产品/方案..  🔔[3] 👤张三[▼]     │
├────────────┬────────────────────────────────────────────────┤
│ 侧边栏      │                                                │
│            │  ┌──────────────────┐  ┌──────────────────┐    │
│ 🏠 首页     │  │ 今日报价汇总      │  │ 本周配置趋势       │    │
│ 🔧 配置报价  │  │ 📋 12份     ¥2.8M │  │ 📈 配置次数 47↑12%│    │
│ 📋 报价管理  │  │ 转化率 68%       │  │ 热门: PD785/BD300  │    │
│ 📊 方案管理  │  └──────────────────┘  └──────────────────┘    │
│ ✅ 审批中心  │                                                │
│ 🤝 售前协同  │  ┌─────────────────────────────────────────┐  │
│ ⚔️ 竞品对标  │  │ 快捷入口                                    │  │
│ 📚 知识库    │  │ [新建配置] [快速报价] [方案模板] [产品搜索]   │  │
│            │  └─────────────────────────────────────────┘  │
│            │                                                │
│            │  ┌─── 最近报价(5条) ──────────────────────────┐  │
│            │  │ QTE-0500  矿山通信方案   ¥4.85M  已通过 ✅  │  │
│            │  │ QTE-0498  PD785标准配置  ¥48.5K  待审批 ⏳ │  │
│            │  │ QTE-0495  BD300定制方案  ¥12.8K  已发送 📤 │  │
│            │  │ ...                                        │  │
│            │  └──────────────────────────────────────────┘  │
│            │                                                │
│            │  ┌─── 待处理事项 ──┬── 知识推荐 ─────────────┐  │
│            │  │ ⏳ 3条待审批    │ 📖 PD785产品手册          │  │
│            │  │ 📝 2条方案待修改│ 💬 矿山通信话术指引       │  │
│            │  │ 🔔 1个交期预警  │ 🏆 本月Top Sales方案    │  │
│            │  └────────────────┴─────────────────────────┘  │
│            │                                                │
└────────────┴────────────────────────────────────────────────┘
```

### 4.2 按角色的首页视图（全12角色）

| 角色 | 首页核心内容 | 关键KPI卡片 | 快捷入口 |
|------|-----------|-----------|---------|
| **销售** | 今日报价汇总 + 最近报价列表 + 待审批事项 + 产品知识推荐 | 今日报价数/金额/转化率 | 新建配置 / 快速报价 / 产品搜索 |
| **售前** | 方案任务看板 + 待处理方案请求 + 方案响应SLA + 本周方案产出统计 | 进行中方案数/响应时长/方案通过率 | 接单 / 方案编辑器 / 竞品查询 |
| **经理** | 团队Pipeline漏斗 + 报价转化率 + 折扣异常告警 + 团队成员活跃度 | 团队报价额/赢率/异常折扣数 | 团队视图 / 审批 / 方案评审 |
| **渠道** | 授权产品目录入口 + 最近报价 + 协议价查询 + 新品通知 | 本月下单数/金额/未读通知 | 产品配置 / 我的报价 / 协议查询 |
| **产品** | 产品配置趋势 + 规则命中率 + 规则冲突统计 + 产品生命周期看板 | 活跃SKU数/规则冲突数/EOL预警 | 产品目录 / BOM管理 / 配置规则 |
| **定价** | 折扣分布热力图 + 利润率仪表盘 + 异常折扣告警 + 价格调整历史 | 平均折扣率/利润率/异常价格数 | 价格手册 / 定价规则 / 折扣审批 |
| **供应链** | 产能负荷仪表盘 + 物料短缺预警 + 采购需求看板 + 交期SLA统计 | 产能利用率/缺料SKU数/交期达成率 | ATP检查 / 批量交期 / 物料预警 |
| **审批人** | 待审批列表(按紧急度排序) + 审批效率统计 + 历史审批参考 | 待审批数/平均审批时长/驳回率 | 审批中心 / 已审批 / 效率看板 |
| **运营** | 销售能力看板(5维雷达图) + 培训完成率 + 方案质量分析 + 竞品情报摘要 | 销售认证率/方案通过率/竞品更新数 | 知识库 / 培训管理 / 竞品库 |
| **高管** | 全局Pipeline漏斗 + Top/Bottom销售排名 + 利润率趋势 + 交期达成率 | 总收入/赢率/利润率/交期SLA | 团队概览 / 趋势分析 / 异常关注 |
| **审计** | 审计日志概览(只读) + 合规检查摘要 + 数据导出请求 | 日志条数/异常事件数/导出请求 | 审计日志 / 合规报告 / 数据导出 |
| **管理员** | 系统健康看板 + 租户使用统计 + 集成状态 + 审计摘要 | 在线用户数/API成功率/存储用量 | 用户管理 / 租户配置 / 集成管理 |

### 4.3 全局搜索组件

```
┌────────────────────────────────────────────────────────┐
│  🔍 搜索产品/型号/方案/客户...                     [搜索]  │
├────────────────────────────────────────────────────────┤
│  [全部] [产品] [方案] [客户] [帮助]                        │
├────────────────────────────────────────────────────────┤
│  最近搜索: PD785对讲机 | BD300系列 | 矿山通信方案          │
│  热门搜索: 防爆对讲机配置 | ATO定制流程 | 海外报价模板     │
│  快速导航: 新建配置 → | 查看审批 → | 方案模板 →           │
└────────────────────────────────────────────────────────┘
```

---

## 5. 核心页面布局设计

### 5.1 销售工作台布局（宽屏三栏）

```
┌──────────────────────────────────────────────────────────────┐
│ 顶栏: Logo | 面包屑 | 全局搜索 | 通知(SSE实时) | 用户头像    │
├──────────┬───────────────────────────┬───────────────────────┤
│ 侧边栏    │  主内容区                   │  右侧信息面板          │
│ (240px)  │  (flex:1)                 │  (320px, 可折叠)      │
│          │                           │                       │
│ 菜单导航   │  ┌─ 配置器 ─────────────┐ │  配置摘要              │
│          │  │                       │ │  ├ 产品: PD785       │
│ 可折叠    │  │  属性选择区 + 约束反馈  │ │  ├ 频段: 136-174MHz │
│          │  │                       │ │  ├ 天线: AN0375H20  │
│ 🔧 当前:  │  │                       │ │  └ ...              │
│ 配置报价   │  └─────────────────────┘ │                       │
│          │                           │  BOM预览              │
│          │  ┌─ BOM / 价格明细 ──────┐ │  ┌ H001 主机  1 ✓  │
│          │  │                       │ │  ├ A001 天线  1 ✓  │
│          │  │                       │ │  ├ B001 电池  2 ⚠  │
│          │  │                       │ │  └ C001 充电器 1 ✗ │
│          │  └─────────────────────┘ │                       │
│          │                           │  ATP交期              │
│          │                           │  📦 预估: 14-21天     │
│          │                           │  ⚠ 电池库存紧张       │
│          │                           │  建议: BL2500替代     │
│          │                           │                       │
│          │                           │  [保存草稿] [提交方案]  │
└──────────┴───────────────────────────┴───────────────────────┘
```

### 5.2 渠道合作伙伴布局（简化两栏）

```
┌──────────────────────────────────────────────────────────────┐
│ 顶栏: Partner Portal | 公司名 | 消息 | 退出                    │
├──────────┬───────────────────────────────────────────────────┤
│ 简化侧边栏│  主内容区                                          │
│ (200px)  │                                                   │
│          │  ┌──────────┐ ┌──────────┐ ┌──────────┐          │
│ 📋 授权产品│  │ 产品A     │ │ 产品B     │ │ 产品C     │          │
│ 📝 我的报价│  │ ¥X,XXX   │ │ ¥X,XXX   │ │ ¥X,XXX   │          │
│ 💰 协议价格│  │ [配置]    │ │ [配置]    │ │ [配置]    │          │
│ 📊 订单追踪│  └──────────┘ └──────────┘ └──────────┘          │
│ ❓ 帮助    │                                                   │
└──────────┴───────────────────────────────────────────────────┘
```

### 5.3 移动端布局（底部Tab导航）

```
┌──────────────────────┐
│ SmartCPQ             │ ← 简化顶栏
├──────────────────────┤
│                      │
│   页面内容区          │  (单栏卡片流)
│                      │
│                      │
│                      │
├──────────────────────┤
│ 🏠首页 │📋报价│📊方案│👤我 │ ← 4Tab底部导航
└──────────────────────┘
```

---

## 6. UI设计系统

### 6.1 设计Token（基于阶段一CPQ设计系统，适配Element Plus）

```scss
// src/assets/styles/variables.scss
// CPQ设计Token — 基于Element Plus变量覆盖

// ===== 主色（稳重专业蓝 — 与阶段一设计Token一致） =====
$--color-primary: #1A73E8;
$--color-primary-light-3: #4A90E2;
$--color-primary-light-5: #7AADF0;
$--color-primary-light-7: #AACCFF;
$--color-primary-light-9: #D4E5FF;

// ===== 辅色（精准工业绿） =====
$--color-accent: #0F974A;

// ===== 语义色 =====
$--color-success: #0F974A;
$--color-warning: #F9AB00;
$--color-danger: #D93025;
$--color-info: #1A73E8;

// ===== 中性色（暖灰基调 — 降低工业场景视觉疲劳） =====
$--color-text-primary: #202124;
$--color-text-regular: #5F6368;
$--color-text-secondary: #9AA0A6;
$--bg-color-page: #F8F9FA;
$--bg-color-container: #FFFFFF;

// ===== 字体（中英文双语） =====
$--font-family: 'PingFang SC', 'Microsoft YaHei', -apple-system, BlinkMacSystemFont, sans-serif;
$--font-family-mono: 'SF Mono', 'JetBrains Mono', monospace;

// ===== 间距（4px基线 × 8px网格） =====
$--spacing-unit: 4px;
$--spacing-xs: 4px;
$--spacing-sm: 8px;
$--spacing-md: 16px;
$--spacing-lg: 24px;
$--spacing-xl: 32px;

// ===== 圆角 =====
$--border-radius-sm: 4px;
$--border-radius-base: 8px;
$--border-radius-lg: 12px;

// ===== 阴影 =====
$--box-shadow-light: 0 1px 3px rgba(0,0,0,0.08);
$--box-shadow-base: 0 2px 8px rgba(0,0,0,0.12);
$--box-shadow-dark: 0 4px 16px rgba(0,0,0,0.16);

// ===== 侧边栏 =====
$--sidebar-width: 240px;
$--sidebar-collapse-width: 64px;
$--sidebar-bg: #1E293B;  // 深色导航

// ===== 顶栏 =====
$--navbar-height: 56px;
```

### 6.2 Element Plus主题覆盖

```typescript
// vite.config.ts — Element Plus按需导入 + 主题变量覆盖
import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'
import ElementPlus from 'unplugin-element-plus/vite'

export default defineConfig({
  plugins: [
    vue(),
    ElementPlus({
      useSource: true,
    }),
  ],
  css: {
    preprocessorOptions: {
      scss: {
        additionalData: `
          @use "@/assets/styles/variables.scss" as *;
          @use "@/assets/styles/mixins.scss" as *;
        `
      }
    }
  }
})
```

### 6.3 CPQ业务组件样式规范

```scss
// 选项卡片四态样式
.cpq-option-card {
  border: 1px solid $--color-gray-300;
  border-radius: $--border-radius-base;
  padding: $--spacing-md;
  cursor: pointer;
  transition: all 0.2s;
  
  &:hover { border-color: $--color-primary; }
  
  // Available — 可选
  &--available { 
    border-color: $--color-gray-300;
    background: $--bg-color-container;
  }
  // Disabled — 禁用（附原因）
  &--disabled { 
    border-color: $--color-gray-200;
    background: $--color-gray-50;
    opacity: 0.6;
    cursor: not-allowed;
    .cpq-option-card__reason { color: $--color-danger; font-size: 12px; }
  }
  // Hidden — 隐藏
  &--hidden { display: none; }
  // Recommended — 推荐（蓝色高亮边框 + 浅蓝背景）
  &--recommended { 
    border-color: $--color-primary;
    border-width: 2px;
    background: #E8F0FE;
    box-shadow: 0 0 0 2px rgba(26,115,232,0.2);
  }
  // Selected — 已选（蓝色实心 + 勾选标记）
  &--selected {
    border-color: $--color-primary;
    background: $--color-primary;
    color: #FFFFFF;
    &::after { content: "✓"; position: absolute; top: 8px; right: 12px; }
  }
}

// ATP交期指示器
.cpq-atp-indicator {
  display: flex; align-items: center; gap: $--spacing-sm;
  &--available { color: $--color-success; }    // 交期充足
  &--constrained { color: $--color-warning; }  // 交期紧张
  &--unavailable { color: $--color-danger; }   // 不可交付
  &--calculating { color: $--color-info; animation: pulse 1.5s infinite; }
}

// 配置树节点5级缩进
.cpq-config-tree {
  .level-1 { padding-left: 0; }
  .level-2 { padding-left: 16px; }
  .level-3 { padding-left: 32px; }
  .level-4 { padding-left: 48px; }
  .level-5 { padding-left: 64px; font-size: 12px; color: $--color-text-secondary; }
}
```

---

## 7. 角色与视图映射

### 7.1 12角色 → 布局模式

| 角色 | 布局模式 | 侧边栏 | 右侧面板 | 首页视图 |
|------|---------|:-----:|:------:|---------|
| 一线销售 | SalesDeskLayout | 全部菜单 | 配置摘要+BOM+ATP | SalesDashboard |
| 售前工程师 | SalesDeskLayout | 全部菜单 | 方案状态+任务 | PresalesDashboard |
| 销售经理 | SalesDeskLayout | 全部菜单 | Pipeline+异常告警 | ManagerDashboard |
| 渠道伙伴 | PartnerLayout | 简化菜单 | — | PartnerDashboard |
| 产品经理 | PortalLayout | 全部菜单 | — | ProductDashboard |
| 定价管理员 | PortalLayout | 全部菜单 | — | PricingDashboard |
| 供应链计划员 | PortalLayout | ATP/产品 | 产能看板+物料预警 | SupplyDashboard |
| 审批人 | PortalLayout | 审批中心 | — | ApprovalDashboard |
| 销售运营 | PortalLayout | 全部菜单 | — | OperationsDashboard |
| 高层管理者 | PortalLayout | 全部菜单 | — | ExecutiveDashboard |
| 外部审计 | PortalLayout | 仅审计菜单 | — | AuditDashboard |
| 系统管理员 | PortalLayout | 全部菜单 | — | AdminDashboard |

### 7.2 布局自适应逻辑

```typescript
// src/layout/index.ts — 根据角色和屏幕尺寸自动选择布局
export function useLayout() {
  const userStore = useUserStore()
  const { width } = useWindowSize()
  
  const layout = computed(() => {
    // 移动端：强制 MobileLayout
    if (width.value < 768) return 'mobile'
    
    // 角色决定布局类型
    const role = userStore.primaryRole
    if (role === 'partner') return 'partner'
    if (['sales', 'presales', 'manager'].includes(role)) return 'salesDesk'
    return 'portal'
  })
  
  return { layout }
}
```

---

## 8. 关键页面设计规格

### 8.1 配置器主页面 (Configurator.vue)

**页面路径**：`/configure/standard`、`/configure/ato`

**页面组成**：

```
Configurator.vue
├── ConfiguratorHeader        # 产品名称 + 面包屑 + 操作按钮(保存/提交/导出)
├── ConfiguratorBody (三栏)
│   ├── ConfigSidebar         # 配置导航（属性分组树）
│   ├── ConfigMain            # 属性选择区
│   │   ├── OptionCard (v-for) # 选项卡片列表（四态）
│   │   └── ConstraintWarning  # 约束冲突提示（MCS解释）
│   └── ConfigRightPanel      # 右侧面板（可折叠）
│       ├── ConfigSummary      # 配置摘要
│       ├── BomPreview         # BOM预览（虚拟滚动）
│       └── AtpIndicator       # ATP交期指示器
└── ConfiguratorFooter        # 价格摘要 + 操作按钮
```

**关键交互**：
- 选择属性 → 实时CSP约束传播 → 更新Option状态 → BOM面板同步
- 冲突检测 → 高亮冲突项 + QuickXPlain解释 + 替代建议
- BOM面板支持5000+行虚拟滚动
- ATP交期每3秒自动更新（可手动刷新）

### 8.2 向导式销售页面 (GuidedSelling.vue)

**页面路径**：`/configure/guided`

**5阶段流程**：
```
Step 1: Questioning (提问)         ── 雷达图进度指示器
Step 2: Narrowing (收敛)           ── 实时显示过滤后产品数
Step 3: Recommending (推荐)       ── 推荐卡片（匹配度+理由）
Step 4: Configuring (微调)        ── 简化配置器 + 交期显示
Step 5: Completed (完成)          ── 生成方案 / 继续报价
```
**数据持久化**：每步选择自动保存至 `useConfigurator` Pinia store（支持页面刷新恢复），完成Step 5后一次性提交配置快照至后端。

### 8.3 方案编辑器 (SolutionEditor.vue)

**四区布局**：
```
┌─ 顶部工具栏 ────────────────────────────────────┐
│ [保存] [预览] [提交评审] [导出] │ [撤销] [重做]   │
├──────────────┬────────────────┬─────────────────┤
│ 模板章节导航  │  编辑区          │  配置数据面板    │
│              │  (Tiptap富文本)  │                 │
│ ✓ 公司介绍   │                 │  [插入参数表]    │
│ ✓ 需求理解   │  {{config.*}}   │  [插入BOM清单]   │
│ ◐ 技术方案   │  动态占位符      │  [插入架构图]    │
│ ○ 实施计划   │                 │  [插入对比表]    │
│ ○ 验收标准   │  协同光标(8色)   │  [插入案例引用]  │
└──────────────┴────────────────┴─────────────────┘
```

### 8.4 报价单生成页面 (QuoteCreate.vue)

**生成流程**：
1. 选择报价模板（缩略图预览）
2. 自动填充配置数据 → 预览
3. 微调（修改描述/调整折扣/添加备注）
4. 生成PDF/Word → 预览 → 确认
5. 提交审批 或 直接发送客户

### 8.5 全局状态规范

所有页面必须覆盖以下四种状态的UI表现，使用统一的 `EmptyState` / `LoadingSkeleton` / `ErrorBoundary` 组件：

| 状态 | 全局组件 | 触发条件 | UI表现 |
|------|---------|---------|--------|
| **加载中** | `LoadingSkeleton.vue` | API请求pending | 骨架屏（表格行/卡片/图表占位），>3s显示"加载中…" |
| **空数据** | `EmptyState.vue` | 返回空列表/无匹配 | 场景化插图+文案+主要CTA按钮 |
| **错误** | `ErrorBoundary.vue` | API 4xx/5xx/网络超时 | 错误摘要+错误码+重试按钮+联系管理员；5xx全局Banner |
| **就绪** | 正常渲染 | 200 OK + 数据非空 | 正常业务组件渲染 |

**各页面空状态文案**：报价单列表→"暂无报价单，开始创建第一份"[新建报价]；方案列表→"暂无方案，从模板快速开始"[从模板新建]；待审批→"暂无待审批项"[查看已审批]；竞品库→"竞品库为空"[添加竞品]；知识库→"产品知识库建设中"[浏览产品目录]；搜索无结果→"未找到匹配结果"[放宽条件] / [提交需求给售前]。

---

## 9. 与RuoYi-Vue-Plus后台的集成

### 9.1 数据共享

| 数据 | 来源 | 共享方式 |
|------|------|---------|
| 用户信息 | sys_user, sys_user_role | **复用** RuoYi `/system/user/*` 接口 |
| 角色权限 | sys_role, sys_role_menu | **复用** RuoYi `/system/role/*` 接口 |
| 菜单结构 | sys_menu | **复用** + **扩展** CPQ专用菜单项 |
| 字典数据 | sys_dict_type, sys_dict_data | **复用** RuoYi `/system/dict/*` 接口 |
| 部门数据 | sys_dept | **复用** 用于数据权限（区域过滤） |
| 租户信息 | sys_tenant | **复用** 请求头自动注入 |
| 文件上传 | OSS (MinIO) | **复用** 统一文件管理 |
| 通知推送 | SSE / WebSocket | **复用** 统一消息推送 |

### 9.2 权限扩展方案

```sql
-- RuoYi sys_menu表扩展（新增CPQ菜单项）
-- 权限字符串格式: cpq:模块:功能:操作
-- 菜单ID范围: 50000-50140（避免与RuoYi系统菜单1000-2300冲突）
-- 所有CPQ菜单挂在顶级父菜单 50000 'CPQ管理' 之下

INSERT INTO sys_menu (menu_id, menu_name, parent_id, order_num, path, component, 
  perms, menu_type, visible, status) VALUES
(50000, 'CPQ管理', 0, 99, NULL, NULL, NULL, 'M', '0', '0'),
(50020, '配置报价', 50000, 2, '/configure', NULL, NULL, 'M', '0', '0'),
(50021, '产品搜索', 50020, 1, 'search', 'configure/ProductSearch', 'cpq:configure:search', 'C', '0', '0'),
(50022, '标准配置', 50020, 2, 'standard', 'configure/Configurator', 'cpq:configure:standard', 'C', '0', '0'),
(50023, '向导式配置', 50020, 3, 'guided', 'configure/GuidedSelling', 'cpq:configure:guided', 'C', '0', '0'),
-- ... 其余CPQ菜单项（完整清单见 sql/cpq_menu.sql）
```

### 9.3 ABAC成本可见性指令

```typescript
// src/directives/v-cost-visibility.ts
// 扩展RuoYi的RBAC，增加ABAC成本字段控制
export const vCostVisibility: Directive = {
  mounted(el: HTMLElement, binding: DirectiveBinding) {
    const requiredLevel = binding.value as number // L0-L3
    const userLevel = useUserStore().costVisibilityLevel
    
    if (userLevel < requiredLevel) {
      // 低级别用户：脱敏显示
      el.textContent = '***'
      el.classList.add('cost-masked')
    }
  }
}
```

---

## 10. 移动端适配策略

### 10.1 响应式断点（与阶段一UI/UX规范一致）

| 断点 | 宽度 | 布局 | 适配策略 |
|------|------|------|---------|
| Desktop | ≥1280px | 三栏（侧边栏240+主内容+右侧面板320） | 完整功能 |
| Desktop S | 1024-1279px | 两栏（侧边栏200+主内容） | 右侧面板可折叠到底部 |
| Tablet | 768-1023px | 两栏（可折叠侧边栏） | 配置选项单列显示 |
| Mobile | <768px | 底部Tab单栏 | 简化为问答式配置 |

### 10.2 移动端专用视图

| 功能 | 桌面端 | 移动端 |
|------|--------|--------|
| 配置 | 属性选择器+配置树+BOM面板三栏 | 问答式（3个核心问题→推荐→确认） |
| 报价 | 完整报价单编辑+模板选择 | 报价摘要卡片 + 发送/审批 |
| 审批 | 审批工作台+节点可视化 | 推送→卡片摘要→左驳回/右通过手势 |
| 搜索 | 多模态搜索下拉 | 搜索栏+热门标签 |

---

## 11. 设计决策总结

| 决策 | 选择 | 理由 |
|------|------|------|
| **前端框架** | Vue 3 + Element Plus | 与RuoYi-Vue-Plus技术栈统一 |
| **独立部署** | cpq-portal独立站点（dev :3000，prod Nginx反向代理统一域名） | 开发环境端口隔离，生产环境同域 SSO |
| **认证复用** | 复用RuoYi Sa-Token+JWT + 同域 localStorage/Cookie 共享 | 生产环境同一 origin 下 token 天然共享，用户无感知单点登录 |
| **权限双模型** | RBAC(复用) + ABAC(新增) | RBAC管菜单/按钮权限，ABAC管成本可见性 |
| **菜单管理** | 扩展sys_menu表 | 在RuoYi菜单管理后台统一管理 |
| **布局自适应** | 角色+屏幕双维度决策 | 销售三栏 vs 渠道两栏 vs 移动Tab |
| **组件库** | Element Plus + CPQ自建 | 通用UI复用Element Plus，CPQ业务组件自建 |
| **移动端** | 渐进增强（非独立RN/Flutter） | 降低维护成本，一套代码多端 |

---

### 12.2 ConfigurationReview.vue — 配置回顾页（新增，已实施）

**实际文件路径**: `cpq-portal/src/views/configure/ConfigurationReview.vue`  
**路由**: `/configure-review/:modelId`  
**状态**: **已实施完成**，2026-06-13 经 Playwright 测试验证通过

**场景**: 向导式配置完成后，用户点击"查看完整配置"跳转到此页面，展示完整的配置详情、MBOM明细和价格汇总。此页面**只读取 Pinia store 状态**，不调用任何初始化 API，确保向导式销售流程中的配置数据不丢失。

**布局**: 全宽单栏布局。
- 顶部：产品概览卡片（产品编码、名称、类型、已选属性数）
- 已选属性清单：el-descriptions 列出所有属性名-值对
- 配置验证结果：PASS（绿色）/ SOFT_FAIL（黄色）/ HARD_FAIL（红色）标签 + 错误/警告详情列表
- MBOM明细表：el-table 列（物料编码/物料描述/类型/数量/单位/需求类型/成本组件/交期）
- 价格汇总：el-descriptions（基础价/BOM成本/最佳匹配价/阶梯调整价/折扣%/净价）+ 审批状态提示
- 底部操作栏：[重新配置]（→ `/configure-guided/:modelId`）+ [前往产品配置器]（→ `/configure/:modelId`）

**数据来源**（全部来自 Pinia store）：
| 数据 | Store字段 | 填充时机 |
|------|----------|---------|
| 产品信息 | `store.modelData` | `initModel()` 时加载 |
| 已选属性 | `store.selections` | 向导式配置过程中累积 |
| 验证结果 | `store.validationResult` | `complete()` 时返回 |
| MBOM明细 | `store.mbomLines` | `complete()` 时返回 |
| 价格结果 | `store.priceResult` | `complete()` 时返回 |

**无数据兜底**: 直接访问 URL 时（无 store 数据），显示警告提示"暂无配置数据" + "返回向导式配置"/"前往产品配置器"按钮。

### 12.3 AtoCustomize.vue — ATO定制配置 BOM实时刷新（已实施增强）

**实际文件路径**: `cpq-portal/src/views/configure/AtoCustomize.vue`  
**路由**: `/configure-ato`  
**状态**: **已实施完成**，含 BOM 实时刷新功能

**BOM预览刷新流程**（2026-06-13 增强）：
```
selectProduct(modelId)
  → store.initModel(modelId)          // 加载产品+属性选项
  → store.refreshBomPreview()         // 初始BOM预览（空选择=默认BOM）

handleSelect(attrName, optionCode)
  → store.selectOption(attrName, opt) // 更新 selections
  → store.refreshBomPreview()         // 根据新 selections 刷新 BOM
     → POST /cpq/configure/bom-preview?modelId= （携带 selections）
     → backend: bomExplosionService.sbomToMbom(modelId, selections)
     → 返回 List<CpqMbomLine> → store.previewBomLines
```

**表格字段映射**（重要：MBOM字段名）：
| 列 | prop | 来源 |
|----|------|------|
| 物料编码 | `materialCode` | `CpqMbomLine.materialCode` |
| 物料名称 | `materialDesc` | `CpqMbomLine.materialDesc` |
| 数量 | `quantity` | `CpqMbomLine.quantity` |
| 单位 | `unit` | `CpqMbomLine.unit` |

**注意**：BOM预览表使用的是 `store.previewBomLines`（MBOM格式），不是 `store.bomLines`（SBOM格式，来自 initModel 返回）。SBOM 使用 itemCode/itemName/unit 字段，MBOM 使用 materialCode/materialDesc/unit 字段。

**变体BOM数据支撑**：BOM随属性选择变化依赖于 `cpq_variant_bom` 表中的 `effectivity_condition` JSON 条件。以 ARC-200P 为例：
- 6 条 SBOM 行中，MAT-SEAM-TRACK（激光焊缝跟踪系统）的 `is_required='0'`
- 存在 variant_bom 记录：effectivity_condition=`{"焊缝跟踪":"LASER"}` 和 `{"焊缝跟踪":"ARC"}` 时包含该物料
- 选择"无（手动编程）"→ 5行（不含激光跟踪系统），选择"激光焊缝跟踪"→ 6行

---

## 附录A：阶段二P0功能→前端组件映射表

### A.1 配置引擎P0功能（8项）→ 前端实现

| P0功能ID | 功能名称 | Vue组件/视图 | 实现方式 |
|---------|---------|-------------|---------|
| CFG-001 | 约束型配置规则引擎 | `Configurator.vue` + `useConfigurator.ts` | CSP求解器API调用→`OptionCard`四态更新 |
| CFG-002 | 向导式配置(Guided Selling) | `GuidedSelling.vue` | **已实施**：5状态枚举（QUESTIONING/NARROWING/RECOMMENDING/CONFIGURING/COMPLETED），复用 `useConfiguratorStore`，`POST /cpq/configure/guide` |
| CFG-003 | 标准配置模板 | `StandardConfigure.vue` | **已实施**：4步流程引导卡片+自动过滤STANDARD产品+蓝色渐变标题+步骤指示器 |
| CFG-006 | ATO参数化配置 | `AtoCustomize.vue` | **已实施**：产品搜索（atoType树形选择）+标准属性配置+定制需求面板+**BOM实时刷新**（`POST /cpq/configure/bom-preview`） |
| CFG-007 | 配置BOM实时预览 | `AtoCustomize.vue` BOM预览表 + `ConfigurationReview.vue` MBOM明细 | **已实施**：前端 `store.previewBomLines`（MBOM格式）+ 后端 `sbomToMbom` 五阶段转换流水线 |
| — | 配置回顾 | `ConfigurationReview.vue` | **新增**：只读 store 状态，展示完整配置+MBOM明细+价格汇总，含"重新配置"/"前往产品配置器"按钮 |

### A.2 定价引擎P0功能（6项）→ 前端实现

| P0功能ID | 功能名称 | Vue组件/视图 | 实现方式 |
|---------|---------|-------------|---------|
| PRC-001 | 基础价格手册 | `pricing/PriceBookList.vue` | Element Plus表格+导入导出(复用RuoYi Excel) |
| PRC-002 | 多维定价 | `PriceBreakdown.vue` | 区域×渠道×客户三维价格匹配显示 |
| PRC-003 | 折扣阈值管控 | `DiscountSlider.vue` | 滑块组件+阈值线可视化+超标告警 |
| PRC-004 | 阶梯定价 | `pricing/VolumeTierConfig.vue` | 阶梯表格编辑(ag-Grid) |
| PRC-005 | 多币种汇率 | `pricing/CurrencyConfig.vue` | 汇率表格+实时/锁定切换 |
| PRC-006 | 价格有效期 | `pricing/PriceValidity.vue` | 日期范围选择器+到期预警 |

### A.3 ATP/CTP交期P0功能（4项）→ 前端实现

| P0功能ID | 功能名称 | Vue组件/视图 | 实现方式 |
|---------|---------|-------------|---------|
| ATP-001 | ATP库存检查 | `AtpIndicator.vue` | 三级ATP状态(绿/黄/红/灰)实时轮询 |
| ATP-002 | CTP交期推算 | `DeliveryTimeline.vue` | 六段交期分解甘特图(ECharts) |
| ATP-003 | 交期不满足推荐 | `atp/AlternativeRecommend.vue` | 替代配置卡片+分批交付方案 |
| ATP-004 | 交期SLA追踪 | `atpctp/SlaDashboard.vue` | 承诺vs实际偏差折线图+根因标签 |

### A.4 审批工作流P0功能（4项）→ 前端实现

| P0功能ID | 功能名称 | Vue组件/视图 | 实现方式 |
|---------|---------|-------------|---------|
| APV-001 | 多级审批路由 | `ApprovalNode.vue` | 节点可视化(4形状×7颜色+脉冲动画) |
| APV-002 | 条件触发审批 | `approval/ApprovalRuleConfig.vue` | 8种条件规则配置表单 |
| APV-003 | 移动审批 | `MobileLayout.vue` — 审批卡片 | 左滑驳回/右滑通过手势(触觉反馈) |
| APV-004 | 审批历史追溯 | `approval/ApprovalHistory.vue` | 审批链路时间线+每步决策理由 |

### A.5 报价引擎P0功能（5项）→ 前端实现

| P0功能ID | 功能名称 | Vue组件/视图 | 实现方式 |
|---------|---------|-------------|---------|
| QTE-001 | 报价单模板生成 | `TemplateSelector.vue` + `QuotePreview.vue` | 模板缩略图选择→`{{config.*}}`填充→PDF/Word生成 |
| QTE-002 | 报价行项目管理 | `quoting/QuoteLineManager.vue` | ag-Grid行增删改+自动重算 |
| QTE-003 | 报价版本管理 | `quoting/QuoteVersion.vue` | 版本列表→Diff对比→回滚确认 |
| QTE-004 | 配置自动填充 | `QuoteCreate.vue` | 配置快照→模板占位符替换 |
| QTE-005 | 报价状态流转 | `StatusBadge.vue` (全局) | 7状态生命周期视觉指示器 |

---

## 附录B：阶段二7流程→前端页面流映射

| 流程 | 前端入口 | 页面流转路径 | 关键组件 |
|------|---------|-------------|---------|
| 流程1: 标准配置报价 | 首页"新建配置" / 菜单"配置报价" | `ProductSearch`→`Configurator`→`QuoteCreate`→`Approval` 或 `Sent` | OptionCard, BomPreview, AtpIndicator, QuotePreview |
| 流程2: ATO定制配置 | 配置器"ATO定制"TAB | `SceneNavigator`→`AtoCustomize`→`ReviewWorkbench`→`QuoteCreate` | CustomRequestPanel, ConfigValidator, CostCalculator |
| 流程3: 渠道自助报价 | PartnerPortal首页 | `ProductCatalog(授权)`→`Configurator(channel)`→`QuoteCreate(channel)` | ChannelLayout, AgreementPriceTag, LimitedSidebar |
| 流程4: 项目型方案协同 | 售前协同"任务看板" | `TaskBoard`→`SolutionEditor`(CRDT)→`SolutionCompare`→`ReviewWorkbench`→`DeliveryKit` | TiptapEditor, YjsCollaborativeCursor, RadarChart, ComparisonMatrix |
| 流程5: ECN/ECO变更 | 产品管理"配置规则" / 系统设置"变更管理" | `ChangeRequest`→`ImpactAssessment`→`ApprovalNode`→变更传播通知 | BomDiffViewer, WhereUsedTree, NotificationCenter |
| 流程6: 数据迁移 | 系统设置"数据迁移"(管理员) | `DataImport`→`MappingConfig`→`TrialMigration`→`Reconciliation`→`FullMigration` | FileUpload(Excel/CSV), FieldMappingDragDrop, DiffReport |
| 流程7: 审批异常处理 | 审批中心"待审批" | `PendingApproval`→`ApprovalDetail`→驳回/转审/超时升级 | ApprovalAction, RejectionReasonForm, ApprovalNode |

---

## 附录C：阶段三70 API端点→前端API模块映射

| 阶段三API模块 | 端点数 | 前端api目录 | 主要端点 |
|-------------|:-----:|------------|---------|
| 产品与BOM管理 | 12 | `api/product/` | productSearch, getSbom, explodeBom, updateLifecycle |
| 配置引擎 | 10 | `api/configure/` | initConfig, selectOption, validateConfig, saveDraft, getGuidedQuestions |
| 定价引擎 | 7 | `api/pricing/` | calculatePrice, applyDiscount, getPriceBook, getVolumeTier |
| 报价引擎 | 9 | `api/quoting/` | createQuote, generatePdf, getVersions, updateLineItems |
| 审批工作流 | 5 | `api/approval/` | submitApproval, performAction, getChain, getHistory |
| 方案管理 | 7 | `api/solution/` | createSolution, submitReview, generateDeliverables, compareSolutions |
| ATP/CTP交期 | 4 | `api/atpctp/` | checkAtp, calculateCtp, getAlternatives, getSlaStats |
| 竞品对标 | 4 | `api/competitive/` | compareProducts, getRecommendations, manageCompetitorData |
| 系统管理 | 8 | `api/system/` | getTenants, manageUsers, updateAbacPolicy, getAuditLogs |
| 集成层 | 4 | `api/integration/` | syncCrmOpportunity, createErpOrder, getSyncLogs |
| **合计** | **70** | **10个API模块** | 全部端点在前端有对应TypeScript接口定义 |

---

## 附录D：阶段一设计Token→前端SCSS变量对照

| 阶段一Token | 前端SCSS变量 | 值 | 用途 |
|------------|-------------|-----|------|
| `--color-primary-500` | `$--color-primary` | #1A73E8 | 主按钮/链接/选中态 |
| `--color-accent-500` | `$--color-accent` | #0F974A | 成功状态/ATP可用/通过 |
| `--color-gray-900` | `$--color-text-primary` | #202124 | 正文 |
| `--color-gray-700` | `$--color-text-regular` | #5F6368 | 辅助文字 |
| `--color-gray-500` | `$--color-text-secondary` | #9AA0A6 | 禁用/占位文字 |
| `--bg-page` | `$--bg-color-page` | #F8F9FA | 页面背景 |
| `--bg-surface` | `$--bg-color-container` | #FFFFFF | 卡片/面板背景 |
| `--font-family-ui` | `$--font-family` | PingFang SC, ... | 全局字体 |
| `--space-4 (16px)` | `$--spacing-md` | 16px | 组件间距 |
| `--space-6 (24px)` | `$--spacing-lg` | 24px | 容器间距 |
| `--space-8 (32px)` | `$--spacing-xl` | 32px | 区块间距 |

---

## 附录E：V2.0报告→前端设计完整追溯矩阵

| V2.0章节 | 内容 | 前端设计章节 | 覆盖状态 |
|---------|------|------------|:------:|
| §2.4 5层产品结构 | 产品目录管理 | §3.1 📦产品管理 / §8 配置树组件 | ✅ |
| §2.4扩展 生命周期 | EOL/替代品 | §3.1 产品管理→替代品管理 | ✅ |
| §2.5 SBOM/MBOM | BOM关系 | §8.1 BomPreview.vue / §A.1 CFG-007 | ✅ |
| §2.5扩展 多层级BOM | BOM展开引擎 | §附录A BOM展开性能(虚拟滚动) | ✅ |
| §3.1 配置引擎 | CSP约束/向导式 | §8.1 Configurator.vue / §8.2 GuidedSelling.vue | ✅ |
| §3.1深化 交互模型 | Option四态/渐进披露/需求翻译 | §6.3 .cpq-option-card样式 / §8.2 5阶段流程 | ✅ |
| §3.2 定价引擎 | 多维定价/阶梯/折扣 | §3.1 💰定价管理 / §A.2 PRC-001~006 | ✅ |
| §3.3 报价引擎 | 报价单/模板/输出 | §3.1 📋报价管理 / §8.4 QuoteCreate.vue | ✅ |
| §3.4 审批工作流 | 多级审批/异常处理 | §3.1 ✅审批中心 / §6.3 ApprovalNode组件 | ✅ |
| §3.5 系统集成 | CRM/ERP/PLM连接 | §3.1 🔄系统集成 / §9.1 数据共享表 | ✅ |
| §3.6 售前协同 | 方案交付物/协同编辑/评审 | §3.1 🤝售前协同 / §8.3 SolutionEditor.vue | ✅ |
| §3.7 竞品对标 | 竞品库/对比/推荐 | §3.1 ⚔️竞品对标 / §A.1 竞品组件 | ✅ |
| §3.8 销售赋能 | 知识库/话术/培训 | §3.1 📚知识库 / §4.2 运营角色首页 | ✅ |
| §3.9 ATP/CTP | 三级检查/交期推算/替代 | §3.1 ⏱️交期查询 / §A.3 ATP-001~004 | ✅ |
| §3.9补充 生产约束 | 产能/物料/多工厂/包装物流 | §4.2 供应链首页 / §7.1 供应链布局 | ✅ |
| §4.3.X 配置算法 | CSP求解/MAC/QuickXPlain | §8.1 关键交互(CSP约束传播) | ✅ |
| §4.3扩展 版本管理 | 配置Diff/时间胶囊 | §8.1 配置保存恢复(快照) | ✅ |
| §4.4.XA 全链路转换 | SBOM→MBOM→工艺BOM | §附录A BOM展开API调用 | ✅ |
| §4.4.XB MRP仿真 | BOM仿真/成本滚算 | §附录B 流程5(ECN传播) | ✅ |
| §4.5 安全权限ABAC | RBAC+ABAC双模型 | §2.3 权限集成 / §9.3 v-cost-visibility | ✅ |
| §4.6 性能架构 | 虚拟滚动/缓存/并发 | §2.1 ag-Grid+虚拟滚动 / §5.1 BOM面板5000+行 | ✅ |
| §5.X 数据迁移 | 五阶段迁移 | §附录B 流程6 / §3.1 系统设置(管理员) | ✅ |
| §5.Y ECN/ECO | 五级联动传播 | §附录B 流程5 / §3.1 产品管理→配置规则 | ✅ |
| §6 市场选型 | 差异化竞争力 | §1.1 双端架构 / §11 设计决策 | ✅ |
| §7 AI+CPQ | 智能推荐/NLP | §4.3 全局搜索(智能建议) / 预留P2/P3 AI能力 | ✅ |

> **追溯结论：V2.0报告25个主要章节100%映射到前端设计的具体章节/组件/功能。**

---

## 附录F：向导式销售页面详细设计（Guided Selling）

### F.0 概述

向导式销售是CPQ配置引擎的核心P0功能之一（CFG-002），为不具备专业技术背景的销售人员提供问答式引导，通过逐步收敛问题空间最终推荐最优产品配置。该功能与配置器（Configurator.vue）共享底层CSP约束引擎，但交互模型完全不同——从"属性选择"转变为"需求翻译"。

向导式销售包含两个层级的组件：页面级 `GuidedSelling.vue`（独立路由页面）和可嵌入组件级 `GuidedWizard.vue`（可在Configurator.vue和独立页面中复用）。

### F.1 GuidedSelling.vue（向导式销售主页面）

**页面路径**：`cpq-portal/src/views/configurator/GuidedSelling.vue`

**使用场景**：一线销售代表（角色100）、售前工程师（角色101）、渠道合作伙伴（角色103）在面对复杂产品线时，通过回答一系列逐步深入的问题，系统自动收敛可行产品空间并推荐最优匹配。例如：客户需要"矿山场景下的防爆通讯设备"→系统通过3-5个关键问题确定产品系列→推荐具体型号→引导微调参数→完成配置。

**五状态机流程**：

向导式销售遵循严格的五状态机流转，每个状态对应不同的UI布局和交互模式：

| 状态 | 枚举值 | 说明 | UI布局 |
|------|--------|------|--------|
| 欢迎 | `WELCOME` | 初始入口，展示使用场景引导 | 全屏Hero区域：大标题+场景选择器+CTA按钮 |
| 提问中 | `QUESTIONING` | 逐步提问，每步1个问题 | 顶部步骤条+中央问题卡片+右侧推荐面板 |
| 分析中 | `ANALYZING` | CSP求解中，显示进度动画 | 中央加载动画（骨架屏+脉冲）+步骤条锁定 |
| 推荐中 | `RECOMMENDING` | 展示推荐结果列表 | 推荐卡片网格+BOM预览+交期预估 |
| 完成 | `COMPLETED` | 配置确认，可继续报价或保存 | 配置摘要确认页+CTA按钮（保存/报价/分享） |

**页面布局**：

```
┌─────────────────────────────────────────────────────────────┐
│ 顶栏: [< 返回产品搜索] 面包屑: 配置报价 > 向导式配置           │
├────────────────────────────────┬────────────────────────────┤
│ 中央主区域 (flex: 1)           │ 右侧推荐面板 (340px, 可折叠)  │
│                                │                            │
│ ┌─ 步骤条 ───────────────────┐ │ ┌─ 推荐概要 ──────────────┐ │
│ │ ①场景 → ②需求 → ③约束 →   │ │ │ 匹配产品: 3个           │ │
│ │   ④偏好 → ⑤确认           │ │ │ 最佳匹配: PD785         │ │
│ │ [ElSteps 5步，当前步高亮]   │ │ │ 匹配度: 94% ████████░  │ │
│ └────────────────────────────┘ │ └────────────────────────┘ │
│                                │                            │
│ ┌─ QuestionCard ─────────────┐ │ ┌─ 推荐产品列表 ─────────┐ │
│ │                            │ │ │ ┌ PD785 94% ─────────┐ │ │
│ │ Q3: 您的主要应用场景是？    │ │ │ │ 防爆对讲机           │ │ │
│ │                            │ │ │ │ 适用: 矿山/石油/化工  │ │ │
│ │ ○ 矿山井下作业              │ │ │ │ [查看详情] [选择]    │ │ │
│ │ ● 石油化工防爆区            │ │ │ └────────────────────┘ │ │
│ │ ○ 公共安全应急              │ │ │ ┌ BD300 87% ─────────┐ │ │
│ │ ○ 港口码头调度              │ │ │ │ 数字对讲机           │ │ │
│ │                            │ │ │ │ ...                  │ │ │
│ │ [上一步] [下一步 →]        │ │ │ └────────────────────┘ │ │
│ └────────────────────────────┘ │ └────────────────────────┘ │
│                                │                            │
│                                │ ┌─ BOM预览(迷你版) ──────┐ │
│                                │ │ H001 主机 ×1  ✓        │ │
│                                │ │ A001 天线 ×1  ✓        │ │
│                                │ │ B001 电池 ×2  ⚠        │ │
│                                │ └────────────────────────┘ │
│                                │                            │
│                                │ ┌─ ATP交期 ──────────────┐ │
│                                │ │ 🟢 预估: 14-21个工作日  │ │
│                                │ │ 起订量: 50台            │ │
│                                │ └────────────────────────┘ │
└────────────────────────────────┴────────────────────────────┘
```

**组件清单**：

1. **StepsNavigator** (`components/configurator/StepsNavigator.vue`)
   - 基于 Element Plus 的 `ElSteps` 封装，5个步骤节点
   - 支持：点击已完成的步骤回退（配合路由守卫，未完成步骤灰显不可点击）
   - 每步节点显示：步骤序号 + 步骤名称 + 完成状态图标（✓）
   - 当前步骤：蓝色高亮（`$--color-primary`）+ 脉冲动画
   - 已完成步骤：绿色（`$--color-accent`）+ 对勾图标
   - 未完成步骤：灰色（`$--color-text-secondary`）
   - 使用 `$--spacing-md` 间距和 `$--border-radius-base` 圆角

2. **QuestionCard** (`components/configurator/QuestionCard.vue`)
   - 中央问题卡片，每种问题类型对应不同的表单控件渲染
   - 四种问题类型枚举：
     * `SINGLE_CHOICE`：单选 — 渲染 `ElRadioGroup` + `ElRadio` 纵向排列，每项含标题+描述文字
     * `MULTI_CHOICE`：多选 — 渲染 `ElCheckboxGroup` + `ElCheckbox`，底部显示已选数量
     * `NUMERIC_INPUT`：数值输入 — 渲染 `ElInputNumber`（带单位后缀和范围提示）
     * `TEXT_INPUT`：文本输入 — 渲染 `ElInput` type="textarea"（自由文本描述）
   - 卡片入场动画：`transition` name="slide-fade"，从右侧滑入
   - 问题标题：`$--color-text-primary`、字号16px、加粗
   - 选项描述：`$--color-text-regular`、字号14px
   - 选项卡片（rendered per option）：border `$--color-gray-300`、hover时border变为`$--color-primary`、已选项border和背景变为`$--color-primary`和`#E8F0FE`

3. **ProgressIndicator** (`components/configurator/ProgressIndicator.vue`)
   - 顶部步骤条下方的进度指示器，显示：已完成问题数 / 总问题数
   - 渲染 `ElProgress` 组件，颜色 `$--color-primary`
   - 显示文字："已完成 3/8 个问题"

4. **RecommendPanel** (`components/configurator/RecommendPanel.vue`)
   - 右侧推荐面板，显示推荐产品列表
   - 每个推荐项为 `ElCard`，包含：
     * 产品缩略图（若有）或产品图标占位
     * 产品名称（加粗，14px）
     * 匹配度进度条（`ElProgress`，颜色从绿到橙渐变）
     * 适用场景标签（`ElTag`，size="small"）
     * "查看详情"链接按钮（`ElButton` type="text"）— 点击展开产品详情抽屉
     * "选择此产品"主按钮（`ElButton` type="primary"）— 点击跳转到微调步骤
   - 面板sticky定位，跟随滚动

5. **BomPreview（迷你版）** (`components/configurator/BomPreview.vue` 的 mini 模式)
   - 精简BOM表格（仅显示物料编码+名称+数量+ATP状态图标）
   - 使用 `ElTable` small size，stripe
   - 物料行ATP状态：绿色圆点(✓充足) / 黄色圆点(⚠紧张) / 红色圆点(✗缺货)
   - 最大显示5行，超出显示"查看完整BOM →"链接

6. **AtpIndicator** (`components/atp/AtpIndicator.vue`)
   - 交期预估指示器，显示预估交期天数和起订量
   - 三种状态颜色：绿色(#0F974A 充足) / 黄色(#F9AB00 紧张) / 红色(#D93025 不可用) / 灰色(#9AA0A6 计算中)
   - 伴随脉冲动画（计算中状态）
   - Tooltip显示交期分解明细

**数据流**：

```
GET /configure/guided/init?productFamilyId={id}
  → 后端返回初始问题列表和产品空间
  → 前端进入 WELCOME 状态

用户选择场景（WELCOME → QUESTIONING）
  → POST /configure/guided/start
  → 后端返回第一个问题 + 上下文

用户回答当前问题
  → POST /configure/guided/answer
    Body: { configId, questionId, answer: { type, value } }
  → 后端CSP求解器增量过滤产品空间
  → 前端 Option 状态集更新

QUESTIONING → ANALYZING
  → 前端显示分析动画（1-2秒延迟）
  → 轮询 GET /configure/guided/status?configId={id} 直到 status=READY

ANALYZING → RECOMMENDING
  → GET /configure/guided/recommendations?configId={id}
  → 后端返回推荐产品列表（含匹配度、ATP、BOM摘要）
  → 前端渲染 RecommendPanel + BomPreview（迷你版）

用户选择推荐产品
  → 进入微调步骤（可选，跳转到 Configurator.vue 的简化模式）
  → 或直接进入 COMPLETED 状态

RECOMMENDING → COMPLETED
  → POST /configure/guided/confirm
  → 配置快照保存 → 显示确认页

COMPLETED 状态下CTA：
  → [保存草稿] → POST /configure/save
  → [创建报价] → 导航到 /quoting/create?configId={id}
  → [分享方案] → 复制分享链接
```

**草稿持久化**：所有回答和中间状态自动保存到 `useConfiguratorStore` Pinia store。当 `isDirty=true` 时，每30秒自动触发 `saveDraft()` 将当前状态持久化到后端。页面刷新后通过 `loadDraft(configId)` 恢复。

**UI设计系统应用**：

- 步骤条主色：`$--color-primary`(#1A73E8)，已完成步骤：`$--color-accent`(#0F974A)
- 问题卡片：`$--bg-color-container`(#FFFFFF)背景，`$--box-shadow-base`阴影，`$--border-radius-base`(8px)圆角
- 选项卡片hover：`border-color: $--color-primary` + `box-shadow: 0 0 0 2px rgba(26,115,232,0.2)`
- 推荐面板：`$--bg-color-page`(#F8F9FA)背景，sticky top: `$--navbar-height` + 16px
- 匹配度进度条：使用 `$--color-accent` → `$--color-warning` 渐变（100%→60%），低于60%使用 `$--color-danger`
- 所有文本：`$--font-family`
- 间距体系：组件内 `$--spacing-md`(16px)，组件间 `$--spacing-lg`(24px)
- 响应式：<1024px时右侧推荐面板折叠到底部，移动端(<768px)全屏单列+底部导航

**权限要求**：

| 角色 | 角色ID | 权限字符串 | 说明 |
|------|--------|-----------|------|
| 销售代表 | 100 | `cpq:configure:guided` | 完整访问 |
| 售前工程师 | 101 | `cpq:configure:guided` | 完整访问 |
| 渠道伙伴 | 103 | `cpq:configure:guided` | 仅授权产品族 |

**代码生成计划**：

| 文件路径 | 技术要点 |
|---------|---------|
| `cpq-portal/src/views/configurator/GuidedSelling.vue` | 五状态机驱动页面布局，`ref<GuidedState>('WELCOME')`，使用 `v-if` 切换不同状态的UI区块。使用 `useGuidedSelling()` composable |
| `cpq-portal/src/composables/useGuidedSelling.ts` | 核心业务逻辑：`state`(ref), `currentQuestion`(ref), `recommendations`(ref), `answerQuestion()`, `goNext()`, `goBack()`, `selectProduct()`, `confirm()`。封装所有API调用（`api/guided.ts`） |
| `cpq-portal/src/components/configurator/StepsNavigator.vue` | `ElSteps`封装，Props: `steps: Step[]`, `current: number`, `completedSteps: number[]`。支持点击回退 |
| `cpq-portal/src/components/configurator/QuestionCard.vue` | 根据 `question.type` 动态渲染不同表单控件。Props: `question: GuidedQuestion`, `modelValue: any`。Emit: `update:modelValue`。包含四种类型的问题渲染器子组件 |
| `cpq-portal/src/components/configurator/RecommendPanel.vue` | 推荐产品列表。Props: `products: RecommendedProduct[]`, `selectedId: string`。Emit: `select`。使用 `ElCard` + `ElProgress` |
| `cpq-portal/src/components/configurator/ProgressIndicator.vue` | 进度条。Props: `completed: number`, `total: number`。使用 `ElProgress` |
| `cpq-portal/src/types/guided.d.ts` | 类型定义：`GuidedState`, `GuidedQuestion`, `Answer`, `RecommendedProduct`, `GuideSession` |

### F.2 GuidedWizard.vue（可嵌入向导组件）

**页面路径**：`cpq-portal/src/components/configurator/GuidedWizard.vue`

**使用场景**：作为嵌入式组件在 Configurator.vue 的 TAB 面板中或独立页面中复用。当标准配置器过于复杂时，用户可以切换到向导模式。与 GuidedSelling.vue 共享底层 `useGuidedSelling.ts` composable，但UI布局为紧凑型单列。

**布局**：紧凑型顶部步骤条（`StepIndicator`）+ 单个问题卡片（带过渡动画）+ 底部操作按钮行。无右侧推荐面板（推荐结果以内联卡片列表呈现）。

**组件清单**：

1. **StepIndicator** — 可点击回退的微型步骤条，复用标准 `ElSteps`，`simple` 模式。已完成步骤以绿色圆点标记，支持点击回退到已完成步骤。
2. **QuestionRenderer** — 问题渲染器，根据类型渲染不同表单控件（复用 `QuestionCard` 的内部逻辑）。当问题切换时使用 `transition` name="slide-fade" 过渡动画。
3. **SkipButton** — 跳过按钮（可选问题时显示），`ElButton` type="text"。
4. **BackButton** — 返回上一步按钮，`ElButton` type="default"。

**权限要求**：继承父组件的权限上下文，不单独设置。

---

## 附录G：方案管理页面详细设计（Solution Management）

### G.0 概述

方案管理模块面向售前工程师（角色101）和产品经理（角色104），提供从方案创建、协同编辑、评审到版本管理的全生命周期管理。本模块的三个P0页面——SolutionEditor、SolutionCompare、SolutionReview——在阶段二§3.4中明确定义了交互流程。

### G.1 SolutionEditor.vue（方案协同编辑器）

**页面路径**：`cpq-portal/src/views/solution/SolutionEditor.vue`

**使用场景**：售前工程师创建和编辑投标方案文档，支持多人同时在线协同编辑（类似Google Docs）。方案内容基于Tiptap富文本编辑器，结合Yjs CRDT实现无冲突复制数据类型（Conflict-free Replicated Data Type）的实时协同，多个用户同时编辑同一文档时光标和编辑操作实时同步，每个用户有唯一的颜色标识。方案编辑过程中可插入CPQ特有的动态数据块：产品参数表、BOM清单、报价摘要、配置快照等。

**四区布局**：

```
┌─ 顶部工具栏 ──────────────────────────────────────────────────────┐
│ [保存] [预览] [提交评审] [导出PDF] | [撤销] [重做] | 👥 协同用户头像  │
├──────────┬──────────────────────────┬─────────────────────────────┤
│ 大纲导航  │ 富文本编辑区（中央）       │ 右侧面板（上下分区）           │
│ (220px)  │ (flex: 1)               │ (240px)                     │
│          │                         │                             │
│ ElTree   │ Tiptap Editor           │ ┌─ 协同光标列表 ───────────┐ │
│ 章节导航  │                         │ │ 🟢 张三 (蓝色)  正在编辑  │ │
│          │ ┌─────────────────┐     │ │ 🟢 李四 (绿色)  第3行    │ │
│ ├ 公司介绍│ │                 │     │ │ 🟡 王五 (橙色)  空闲     │ │
│ │ ✓      │ │  {{config.      │     │ └─────────────────────────┘ │
│ ├ 需求理解│ │    参数表}}      │     │                             │
│ │ ✓      │ │                 │     │ ┌─ 批注面板 ───────────────┐ │
│ ├ 技术方案│ │                 │     │ │ ┌ Zhang:                │ │
│ │ ◐      │ │  协同光标(8色)   │     │ │ │ 建议补充实施周期估计    │ │
│ ├ 实施计划│ │  ↓ 其他用户正在   │     │ │ │    2026-06-05 14:30  │ │
│ │ ○      │ │    编辑此段落    │     │ │ │    [回复] [解决]      │ │
│ └ 验收标准│ │                 │     │ │ └───────────────────── │ │
│    ○     │ │                 │     │ │ ┌ Li:                  │ │
│          │ └─────────────────┘     │ │ │ 技术参数需要更新到V3    │ │
│          │                         │ │ └───────────────────── │ │
│          │                         │ │ [添加批注 +]            │ │
│          │                         │ └─────────────────────────┘ │
└──────────┴──────────────────────────┴─────────────────────────────┘
```

**技术架构**：

- **Tiptap Editor**：基于 ProseMirror 的富文本编辑器，支持自定义扩展节点
- **Yjs**：CRDT（Conflict-free Replicated Data Type）数据结构，确保多人协同编辑无冲突
- **y-websocket**：WebSocket 传输层，将 Yjs 文档的增量更新同步到服务端
- **8色协同光标**：每个协作用户分配唯一颜色（取自预定义的8色调色板：蓝#1A73E8、绿#0F974A、橙#F9AB00、红#D93025、紫#7B1FA2、青#00838F、粉#C2185B、棕#5D4037），通过 CSS cursor 和选区背景色区分

**CPQ Tiptap扩展（自定义节点）**：

| 扩展名称 | 说明 | 渲染方式 |
|---------|------|---------|
| `cpqProductTable` | 产品参数表 | 渲染 `ElTable` 展示产品规格参数，数据来自 `GET /product/{id}/specs` |
| `cpqBomTable` | BOM清单 | 渲染 `ag-Grid` 层级树表，数据来自 `GET /bom/explode?configId={id}` |
| `cpqQuoteSummary` | 报价摘要 | 渲染报价金额卡片，数据来自 `GET /quoting/{id}/summary` |
| `cpqConfigSnapshot` | 配置快照 | 渲染配置摘要面板，数据来自 `GET /configure/{id}/snapshot` |
| `cpqComparisonTable` | 方案对比表 | 渲染 `ComparisonMatrix` 组件，多列对比 |

**组件清单**：

1. **OutlineTree** (`components/solution/OutlineTree.vue`)
   - 基于 `ElTree` 的章节大纲导航，每个节点为一个方案章节/标题
   - 节点类型：`Section`（一级章节）、`SubSection`（二级标题）
   - 每节点显示：标题文本 + 完成状态图标（✓已完成/◐进行中/○未开始）
   - 点击节点：滚动Tiptap编辑器到对应位置（`editor.commands.scrollIntoView()`）
   - 支持拖拽排序调整章节顺序（`allow-drag`）
   - 右键菜单：重命名、删除、新增子章节
   - 宽度：220px，可折叠（折叠后40px）

2. **TiptapEditor** (`components/solution/TiptapEditor.vue`)
   - 封装 Tiptap 编辑器，集成 Yjs 协同
   - 初始化：连接 WebSocket → 创建 Yjs Document → 绑定 Tiptap
   - 工具栏：使用 Tiptap 默认工具栏扩展，包含：标题选择、粗体/斜体/下划线、列表（有序/无序）、引用、代码块、插入CPQ扩展块、插入图片、表格
   - CPQ扩展块插入按钮：产品参数表、BOM清单、报价摘要、配置快照、方案对比表
   - 自动保存：内容变更防抖（debounce 3秒）→ 保存到 `useSolutionStore`
   - 选区协同：通过 `y-codemirror` 风格的 awareness 协议同步光标和选区

3. **CollaboratorAvatars** (`components/solution/CollaboratorAvatars.vue`)
   - 显示当前在线协同用户列表
   - 每项：用户头像（`ElAvatar`）+ 用户名 + 在线状态（绿色圆点=正在编辑，黄色=空闲）+ 颜色标识（小色块）
   - 使用 `Yjs awareness API` 获取在线状态
   - 鼠标悬浮用户头像时，Tiptap中高亮该用户的选区

4. **CommentThread** (`components/solution/CommentThread.vue`)
   - 右侧批注面板，显示文档中的所有批注讨论线程
   - 每条批注使用 `ElTimeline` + `ElTimelineItem` 渲染
   - 批注创建：选中文本 → 工具栏"添加批注"按钮 → 弹出 `ElInput` + `ElButton`
   - 批注回复：嵌套显示，引用原批注
   - 批注解决：标记为已解决（变灰 + 删除线），可重新打开
   - 批注数据通过 Yjs 同步（批注本身也是CRDT数据结构）

5. **VersionTimeline** (`components/solution/VersionTimeline.vue`)
   - 版本历史时间线，基于 `ElTimeline`
   - 每项：版本号 + 提交时间 + 提交人 + 变更摘要
   - 点击版本项：加载该版本快照到只读预览模式
   - "恢复此版本"按钮（管理员可见）

**数据流**：

```
页面加载
  → GET /solution/{id} (获取方案元数据)
  → WebSocket连接 ws://host/ws/solution/{id}?token={jwt}
  → Yjs Document 初始化 + 同步
  → Tiptap 绑定 Yjs → 渲染协同内容

用户编辑
  → Tiptap onChange → Yjs 本地更新 → y-websocket 推送增量 →
  → 服务端广播给其他协同用户 → 其他用户Tiptap自动更新

保存操作
  → POST /solution/{id}/save (保存完整方案内容+元数据)
  → 保存时自动版本快照

提交评审
  → POST /solution/{id}/submit-review
  → 方案状态变为 "待评审"
  → 触发审批工作流

导出PDF
  → POST /solution/{id}/export?format=pdf
  → 服务端渲染PDF → 下载
```

**UI设计系统应用**：

- 四区边框分隔：左侧tree区域 `border-right: 1px solid $--color-gray-300`，右侧面板 `border-left: 1px solid $--color-gray-300`
- Tiptap编辑区：`$--bg-color-container`(#FFFFFF)背景
- 大纲节点hover：背景 `$--color-primary-light-9`(#D4E5FF)
- 批注引用块：背景 `#FFF3E0`(浅橙)，左边框 3px `$--color-warning`(#F9AB00)
- 协同光标：通过CSS自定义，每个用户的cursor颜色与其分配的颜色一致，选区背景半透明
- 工具栏分隔符：灰色垂直线 `1px solid $--color-gray-300`
- 响应式：<1024px时右侧面板折叠到底部Tab切换，<768px时仅显示编辑区全屏

**权限要求**：

| 角色 | 权限 | 说明 |
|------|------|------|
| 售前工程师（101） | `cpq:solution:edit` | 创建、编辑、提交评审 |
| 产品经理（104） | `cpq:solution:edit` | 查看、评审打分 |

**代码生成计划**：

| 文件路径 | 技术要点 |
|---------|---------|
| `cpq-portal/src/views/solution/SolutionEditor.vue` | 四区布局主页面，使用 flexbox 布局。左侧220px、中央flex-1、右侧240px。集成所有子组件 |
| `cpq-portal/src/components/solution/OutlineTree.vue` | `ElTree` + 节点操作。Props: `chapters: Chapter[]`。Emit: `navigate`, `reorder`, `add`, `delete`, `rename` |
| `cpq-portal/src/components/solution/TiptapEditor.vue` | Tiptap + Yjs 集成。`useEditor()` + `y-websocket` provider。自定义 CPQ 扩展节点。防抖保存 |
| `cpq-portal/src/components/solution/CollaboratorAvatars.vue` | Yjs awareness API 集成。Props: `awareness: Awareness`。渲染用户头像列表 |
| `cpq-portal/src/components/solution/CommentThread.vue` | 批注CRUD。Props: `comments: Comment[]`。使用 `ElTimeline` |
| `cpq-portal/src/components/solution/VersionTimeline.vue` | 版本历史。Props: `versions: Version[]`。使用 `ElTimeline` |
| `cpq-portal/src/composables/useSolutionEditor.ts` | 编辑状态管理：`save()`, `load()`, `collaborators`, `awareness` 等 |
| `cpq-portal/src/types/solution.d.ts` | 类型定义：`Chapter`, `Comment`, `Version`, `Collaborator` |
| `cpq-portal/src/extensions/tiptap/` | CPQ Tiptap 自定义扩展：ProductTable、BomTable、QuoteSummary、ConfigSnapshot、ComparisonTable |

### G.2 SolutionCompare.vue（方案对比）

**页面路径**：`cpq-portal/src/views/solution/SolutionCompare.vue`

**使用场景**：销售经理（角色102）或售前工程师（角色101）需要对比多个备选方案的优劣，辅助客户决策。支持2-4个方案同时对比，从成本、交期、性能、兼容性、服务五个维度进行雷达图可视化对比，同时展示详细的差异对表。

**布局**：

```
┌──────────────────────────────────────────────────────────────┐
│ 顶部: 方案选择器                                               │
│ [方案A: 矿山通信标准方案 ▼] [方案B: 矿山通信增强方案 ▼]          │
│ [方案C: 防爆方案豪华版 ▼] [+ 添加方案]                         │
├────────────────────┬─────────────────────────────────────────┤
│ 左侧 (50%)         │ 右侧 (50%)                               │
│                    │                                         │
│ ┌─ 雷达图 ───────┐ │ ┌─ 成本瀑布图 ─────────────────────────┐ │
│ │  ECharts雷达图  │ │ │ ECharts 瀑布图                       │ │
│ │  5个维度:       │ │ │ 方案A成本 方案B成本 方案C成本          │ │
│ │  成本/交期/     │ │ │ ████████  ████████████  ██████       │ │
│ │  性能/兼容性/   │ │ │ 物料+人工+费用+外协+运费=总成本       │ │
│ │  服务           │ │ │                                      │ │
│ └────────────────┘ │ └──────────────────────────────────────┘ │
├────────────────────┴─────────────────────────────────────────┤
│ 底部: 差异对比表 (ElTable)                                     │
│ ┌───────────────────────────────────────────────────────────┐ │
│ │ 对比维度  │ 方案A              │ 方案B           │ 方案C    │ │
│ ├───────────┼───────────────────┼────────────────┼───────── │ │
│ │ 产品型号  │ PD785-DMR          │ PD785-DMR-PRO  │ PD985   │ │
│ │ 频段     │ 136-174MHz         │ 136-174MHz     │ 350-400 │ │
│ │ 单价     │ ¥4,850             │ ¥5,950         │ ¥12,800 │ │
│ │ 预估交期 │ 14天               │ 21天 ⚠         │ 18天    │ │
│ │ 防护等级 │ IP67               │ IP68 ★         │ IP67    │ │
│ │ 电池容量 │ 2100mAh            │ 2500mAh ▲      │ 3000mAh │ │
│ │ 维保    │ 1年标准             │ 3年标准 ▲      │ 1年标准 │ │
│ │ ...      │ ...                │ ...            │ ...     │ │
│ └───────────────────────────────────────────────────────────┘ │
│ ★ = 最优项  ▲ = 优于基准  ⚠ = 低于基准                         │
│ [导出对比报告] [选择方案A并创建报价] [选择方案B并创建报价] ...     │
└──────────────────────────────────────────────────────────────┘
```

**组件清单**：

1. **SolutionSelector** (`components/solution/SolutionSelector.vue`)
   - 多选方案下拉选择器，基于 `ElSelect` multiple模式
   - 选项渲染：方案名称 + 简短描述（副标题）
   - 最大可选4个方案，超出提示
   - 支持 remote search（远程搜索方案名称）
   - 已选方案以 `ElTag` closable 方式展示在选择器下方

2. **RadarChartWidget** (`components/comparison/RadarChart.vue`)
   - 基于 ECharts 5 radar 图表类型
   - 5个维度：成本（越低越好，归一化反转）、交期（越短越好）、性能、兼容性、服务
   - 每个方案一条闭合曲线，不同颜色（取自8色调色板）
   - 图例交互：点击legend项切换显示/隐藏该方案曲线
   - Tooltip：悬浮显示具体分值
   - Canvas 渲染确保大数据量性能

3. **WaterfallChartWidget** (`components/comparison/WaterfallChart.vue`)
   - 基于 ECharts 5 bar 图表类型（瀑布图变体）
   - 展示各方案的总成本分解：物料成本、人工成本、制造费用、外协费用、运费
   - X轴：方案名称，Y轴：金额（元）
   - 柱子颜色：总成本蓝色(#1A73E8)，分项按渐变阶梯色
   - Tooltip：hover显示详细金额

4. **DiffTable** (`components/comparison/DiffTable.vue`)
   - 基于 `ElTable` 的动态列对比表
   - 第一列：对比维度名称（固定列）
   - 后续列：每个方案的数据列（动态生成）
   - 差异行高亮：当某方案的值与其他方案不同时，该单元格背景高亮（浅黄色 `#FFF8E1`）
   - 最优值标记：五角星图标 ★ 标记该维度下的最优方案，颜色 `$--color-accent`
   - 优于基准标记：▲ 绿色箭头，低于基准标记：⚠ 橙色警告
   - 行分组：产品参数 / 价格信息 / 交期信息 / 维保服务 / 其他

**权限要求**：

| 角色 | 权限 | 说明 |
|------|------|------|
| 销售经理（102） | `cpq:solution:compare` | 完整访问 |
| 售前工程师（101） | `cpq:solution:compare` | 完整访问 |

**数据流**：

```
GET /solution/compare?ids=id1,id2,id3
  → 后端返回结构化对比数据（含雷达图维度分值、成本瀑布数据、差异表数据）
  → 前端渲染三个图表组件

用户选择方案并创建报价
  → 导航到 /quoting/create?solutionId={selectedId}
```

---

### G.3 SolutionReview.vue（方案评审）

**页面路径**：`cpq-portal/src/views/solution/SolutionReview.vue`

**使用场景**：产品经理（角色104）或销售经理（角色102）对售前工程师提交的方案进行专业评审。评审采用多维度评分矩阵，评审人从技术方案、报价合理性、交期可行性、实施风险、文档完整性五个维度打分，最后汇总给出通过/驳回/请求修改的评审意见。

**布局**：

```
┌──────────────────────────────────────────────────────────────┐
│ 顶栏: 方案名称: 矿山通信防爆方案 V2  |  提交人: 张三  |  提交时间│
├──────────────────────────┬───────────────────────────────────┤
│ 方案内容预览 (60%)        │ 评审表单 (40%)                     │
│                          │                                   │
│ ┌─ 方案内容 iframe ─────┐│ ┌─ 评分矩阵 ─────────────────────┐ │
│ │                        ││ │ 评审维度  │ 1★ 2★ 3★ 4★ 5★    │ │
│ │  渲染的方案内容         ││ │ ─────────┼─────────────────    │ │
│ │  (可滚动)              ││ │ 技术方案  │ ○ ○ ● ○ ○  3分     │ │
│ │                        ││ │ 报价合理性│ ○ ○ ○ ● ○  4分     │ │
│ │                        ││ │ 交期可行性│ ○ ● ○ ○ ○  2分     │ │
│ │                        ││ │ 实施风险  │ ○ ○ ○ ● ○  4分     │ │
│ │                        ││ │ 文档完整性│ ○ ○ ○ ○ ●  5分     │ │
│ │                        ││ │          │ 综合: 3.6/5         │ │
│ └────────────────────────┘│ └───────────────────────────────┘ │
│                          │                                   │
│                          │ ┌─ 评审意见 ─────────────────────┐ │
│                          │ │ ElInput type="textarea"        │ │
│                          │ │ 技术方案中频段选择建议增加      │ │
│                          │ │ UHF 400-470MHz选项以覆盖       │ │
│                          │ │ 更多行业场景...                │ │
│                          │ └───────────────────────────────┘ │
│                          │                                   │
│                          │ ┌─ 评审历史 ─────────────────────┐ │
│                          │ │ ElTimeline:                    │ │
│                          │ │ ● 2026-06-05 李四 驳回         │ │
│                          │ │   理由: BOM中电池数量不足        │ │
│                          │ │ ● 2026-06-03 王五 请求修改      │ │
│                          │ │   已修改: 增加备用电池2块        │ │
│                          │ │ ● 2026-06-01 张三 提交评审      │ │
│                          │ └───────────────────────────────┘ │
│                          │                                   │
│                          │ [驳回] [请求修改] [通过评审 ✓]      │
└──────────────────────────┴───────────────────────────────────┘
```

**组件清单**：

1. **SolutionPreview** (`components/solution/SolutionPreview.vue`)
   - 方案内容预览区域，方案HTML渲染为非交互iframe
   - 或使用 `v-html` 渲染方案内容（需XSS过滤）
   - 支持滚动同步：左侧预览滚动时，右侧不跟随；反之亦然
   - 工具栏：缩放按钮（放大/缩小/适合宽度）

2. **ReviewScoreMatrix** (`components/solution/ReviewScoreMatrix.vue`)
   - 多维度评分矩阵，使用 `ElRate` 组件渲染每个维度的星级评分
   - 5个维度 × 每个维度5星（1-5分）
   - 每个维度行：维度名称 + `ElRate` + 分数显示
   - 底部自动计算加权平均分和综合评分
   - 评分变化时 emit `update:scores` 事件

3. **ReviewComments** (`components/solution/ReviewComments.vue`)
   - 评审历史时间线，基于 `ElTimeline` + `ElTimelineItem`
   - 每项：时间戳 + 评审人 + 评审动作（提交/驳回/请求修改/通过）+ 评审意见文本
   - 当前用户的评审意见输入：`ElInput` type="textarea" rows="4"
   - 意见字数统计（如"已输入128字"）

4. **ApprovalActions** (`components/solution/ApprovalActions.vue`)
   - 底部操作按钮组
   - [驳回]：`ElButton` type="danger" → 弹出确认提示 → 必须填写驳回理由
   - [请求修改]：`ElButton` type="warning" → 必须填写修改要求清单
   - [通过评审 ✓]：`ElButton` type="success" → 弹出二次确认 → 更新方案状态为"已通过"

**权限要求**：

| 角色 | 权限 | 说明 |
|------|------|------|
| 产品经理（104） | `cpq:solution:review` | 评审打分、通过/驳回 |
| 销售经理（102） | `cpq:solution:review` | 评审打分、通过/驳回 |
| 审批人（107） | `cpq:solution:review` | 终审通过 |

**数据流**：

```
GET /solution/{id}/review
  → 获取方案预览内容 + 已有评审历史 + 评审维度配置

POST /solution/{id}/review
  Body: { scores: {...}, comment: "...", action: "APPROVE"|"REJECT"|"REQUEST_CHANGES" }
  → 提交评审结果
  → 方案状态更新
  → 触发通知（SSE推送给方案提交人）
```

---

## 附录H：竞品对标页面详细设计（Competitive Analysis）

### H.0 概述

竞品对标模块面向销售代表、售前工程师和销售运营，提供竞品信息管理、产品参数对比和差异化策略推荐。这是CPQ系统的核心差异化功能之一，帮助一线销售人员在面对竞品时快速获得专业对比数据和应对策略。

### H.1 CompetitorList.vue（竞品库管理）

**页面路径**：`cpq-portal/src/views/competitive/CompetitorList.vue`

**使用场景**：销售运营（角色108）和系统管理员（角色111）维护竞品信息库，包括添加新竞品、编辑竞品SWOT分析、更新竞品市场地位。销售人员可以浏览竞品库了解市场格局。

**布局**（标准CRUD布局）：

```
┌──────────────────────────────────────────────────────────────┐
│ 顶: 搜索栏 (ElForm inline)                                    │
│ [竞品名称...] [行业: 全部▼] [市场地位: 全部▼] [搜索] [+ 新增竞品]│
├──────────────────────────────────────────────────────────────┤
│ 表格 (ElTable, stripe, border, highlight-current-row)        │
│ ┌──────────────────────────────────────────────────────────┐ │
│ │ 竞品名称        │ 行业      │ 市场地位   │ 对标产品数  │ 操作│ │
│ ├─────────────────┼──────────┼──────────┼──────────┼───── │ │
│ │ 摩托罗拉MOTOTRBO │ 公共安全  │ 🟡 挑战者  │ 12个      │ 编辑 │ │
│ │ 海能达Hytera     │ 专业通信  │ 🔴 领导者  │ 25个      │ 编辑 │ │
│ │ 建伍KENWOOD     │ 专业通信  │ 🟢 追随者  │ 8个       │ 编辑 │ │
│ │ 科立讯Kirisun   │ 商业通信  │ 🟢 追随者  │ 5个       │ 编辑 │ │
│ │ ...              │ ...      │ ...      │ ...       │ ...  │ │
│ └──────────────────────────────────────────────────────────┘ │
│ 分页: ElPagination                                            │
└──────────────────────────────────────────────────────────────┘
```

**组件清单**：

1. **CompetitorFormDialog** (`components/competitive/CompetitorFormDialog.vue`)
   - `ElDialog` 弹窗表单，用于新增/编辑竞品信息
   - 表单字段：
     * 竞品名称（`ElInput`，必填）
     * 竞品代码（`ElInput`，大写字母+数字，必填）
     * 官方网站（`ElInput`，URL校验）
     * 所属行业（`ElSelect`，多选，从字典 `competitor_industry` 获取）
     * SWOT分析（`ElInput` type="textarea" × 4：优势/劣势/机会/威胁）
     * 市场地位（`ElRadioGroup`：领导者🔴/挑战者🟡/追随者🟢/新进入者🔵）
     * 备注（`ElInput` type="textarea"）
   - 表单校验：名称和代码必填、代码唯一性校验（远程校验）
   - 保存按钮调用 `POST /competitive/competitors` 或 `PUT /competitive/competitors/{id}`

2. **DeleteConfirm** — `ElMessageBox.confirm` 确认删除，提示"删除后将同时删除该竞品的所有对标关系"

**市场地位标签颜色映射**：

| 市场地位 | 标签颜色 | Element Plus type |
|---------|---------|-------------------|
| 领导者 | 红色 | `danger` |
| 挑战者 | 橙色 | `warning` |
| 追随者 | 绿色 | `success` |
| 新进入者 | 蓝色 | `primary` |

**权限要求**：

| 角色 | 权限 | 说明 |
|------|------|------|
| 销售运营（108） | `cpq:competitive:manage` | 完整CRUD |
| 系统管理员（111） | `cpq:competitive:manage` | 完整CRUD |

### H.2 ComparisonView.vue（参数对比视图）

**页面路径**：`cpq-portal/src/views/competitive/ComparisonView.vue`

**使用场景**：销售代表（角色100）或售前工程师（角色101）在面对客户对比竞品时，快速生成我方产品与竞品产品的参数对比表，辅助商务谈判和技术答疑。

**布局**：

```
┌──────────────────────────────────────────────────────────────┐
│ 顶部: 产品选择器                                               │
│ 我方产品: [请选择产品... ▼] remote search                      │
│ 对标竞品产品: [请选择竞品... ▼] multi-select [+ 添加竞品]       │
│ [开始对比]                                                    │
├──────────────────────────────────────────────────────────────┤
│ 参数对比表 (ElTable, dynamic columns)                          │
│ ┌──────────────────────────────────────────────────────────┐ │
│ │ 参数名称     │ 我方 PD785-DMR  │ 竞品 Moto XPR7550 │ 竞品 │ │
│ ├──────────────┼────────────────┼──────────────────┼────── │ │
│ │ 频段         │ 136-174MHz      │ 136-174MHz       │ =     │ │
│ │ 信道容量     │ 1000ch          │ 1000ch           │ =     │ │
│ │ 发射功率     │ 1-5W            │ 1-5W             │ =     │ │
│ │ 防护等级     │ IP67 ★          │ IP65             │ + ○   │ │
│ │ 电池容量     │ 2100mAh         │ 2300mAh ▲        │ - ●   │ │
│ │ 重量         │ 310g            │ 335g ★           │ + ●   │ │
│ │ 工作温度     │ -30°C~+60°C ★   │ -25°C~+55°C     │ + ●   │ │
│ │ 价格(美元)   │ $485            │ $625             │ + ●   │ │
│ │ 质保期       │ 2年标准 ★       │ 1年标准          │ + ●   │ │
│ │ ATEX防爆认证 │ 支持 ★          │ 需额外选配        │ + ●   │ │
│ │ GPS定位      │ 内置 ★          │ 不支持           │ + ○   │ │
│ └──────────────────────────────────────────────────────────┘ │
│ ★ = 优势项  ▲ = 微弱优势  = 持平  - = 劣势                     │
│ ● = 我方显著优势  ○ = 我方微弱优势                             │
│                                                               │
│ ┌─ 赢率估算 ────────────────────────────────────────────────┐ │
│ │ 基于历史数据的大致赢率: 68%                                │ │
│ └──────────────────────────────────────────────────────────┘ │
├───────────────────┬───────────────────────────────────────────┤
│ 雷达图 (ECharts)   │ 推荐策略卡片                               │
│                   │ ┌──────────────────────────────────────┐  │
│  5维对比:          │ │ ⚔️ 攻击策略 (ATTACK)                  │  │
│  价格/性能/        │ │ 强调我方IP67 vs 竞品IP65的防护优势，   │  │
│  防护/温度/续航    │ │ 以及ATEX防爆认证为标准配置无需额外付费   │  │
│                   │ └──────────────────────────────────────┘  │
│                   │ [查看完整策略手册]                          │
└───────────────────┴───────────────────────────────────────────┘
```

**组件清单**：

1. **OurProductSelector** (`components/competitive/OurProductSelector.vue`)
   - 我方产品选择器，基于 `ElSelect` + remote search
   - 搜索时调用 `GET /product/search?keyword={}` 获取产品列表
   - 选项渲染：产品型号 + 产品名称
   - 单选模式

2. **CompetitorProductSelector** (`components/competitive/CompetitorProductSelector.vue`)
   - 竞品产品多选器，基于 `ElSelect` multiple + remote search
   - 选项分组：按竞品公司名称分组（`ElOptionGroup`）
   - 每个竞品产品选项：公司名 + 产品型号 + 产品名

3. **ComparisonTable** (`components/competitive/ComparisonTable.vue`)
   - 动态列对比表格，基于 `ElTable`
   - 第一列：参数名称（固定列，sticky left）
   - 动态列：根据选择的竞品产品数量动态生成列头
   - 差异行高亮：当前行中最大值或最优值的单元格背景浅绿色 `#E8F5E9`
   - 我方优势标记：★ 绿色星标，我方劣势：▼ 红色向下箭头
   - 支持分页和滚动（参数可能很多）

4. **RadarChartWidget** — 复用 `@/components/comparison/RadarChart.vue`

5. **StrategyCard** (`components/competitive/StrategyCard.vue`)
   - 推荐策略卡片，四种策略类型颜色编码：
     * ATTACK（攻击）：红色 `$--color-danger`
     * DEFEND（防御）：蓝色 `$--color-primary`
     * AVOID（规避）：黄色 `$--color-warning`
     * OBSERVE（观望）：绿色 `$--color-accent`
   - 卡片内容：策略类型标签 + 策略名称 + 策略描述摘要
   - 展开查看详细话术和支撑证据

**常驻显示**：赢率估算 `win_rate_pct` 显示为进度环（`ElProgress` type="circle"）

**权限要求**：

| 角色 | 权限 | 说明 |
|------|------|------|
| 销售代表（100） | `cpq:competitive:compare` | 查看对比 |
| 售前工程师（101） | `cpq:competitive:compare` | 查看对比 |
| 销售运营（108） | `cpq:competitive:compare` | 查看对比+管理竞品库 |

### H.3 RecommendationView.vue（推荐策略）

**页面路径**：`cpq-portal/src/views/competitive/RecommendationView.vue`

**使用场景**：销售代表在准备拜访客户前，快速查看针对特定竞品的应对策略和关键话术，提升临场应对能力。

**布局**：

```
┌──────────────────────────────────────────────────────────────┐
│ 顶部: 场景选择器                                               │
│ 竞品: [摩托罗拉 MOTOTRBO ▼] 场景: [矿山井下 ▼] [查询]          │
├──────────────────────────────────────────────────────────────┤
│ 策略卡片 (Grid 2×2)                                           │
│ ┌──────────────────────┐ ┌──────────────────────┐            │
│ │ ⚔️ ATTACK 攻击策略     │ │ 🛡️ DEFEND 防御策略     │            │
│ │ 强调IP67 vs IP65      │ │ 应对竞品品牌优势      │            │
│ │ 防护等级优势           │ │ 强调本地化售后服务     │            │
│ │ [展开话术 →]          │ │ [展开话术 →]          │            │
│ └──────────────────────┘ └──────────────────────┘            │
│ ┌──────────────────────┐ ┌──────────────────────┐            │
│ │ ⚠️ AVOID 规避策略      │ │ 👁️ OBSERVE 观望策略    │            │
│ │ 避免在电池容量上      │ │ 关注竞品V4.0固件      │            │
│ │ 直接对比               │ │ 计划发布时间          │            │
│ │ [展开话术 →]          │ │ [展开话术 →]          │            │
│ └──────────────────────┘ └──────────────────────┘            │
├──────────────────────────────────────────────────────────────┤
│ 关键话术列表 (ElCollapse accordion)                            │
│ ┌ 客户的异议: "摩托罗拉品牌更有保证..."                    [展开] │
│ ├ 建议应对: "PD785已通过ATEX/IECEx双认证，在全球50+国家矿产...│
│ │   支撑证据: 认证证书链接、全球部署案例列表                    │
│ ├ 客户的异议: "你们的价格比海能达高..."                   [展开] │
│ ├ 建议应对: "我们的价格包含了3年现场维保服务，海能达的报价...  │
│ └ 客户的异议: "交期太长了..."                          [展开]   │
└──────────────────────────────────────────────────────────────┘
```

**组件清单**：

1. **ScenarioSelector** (`components/competitive/ScenarioSelector.vue`)
   - 场景选择器：竞品下拉(`ElSelect`) + 场景下拉(`ElSelect`)
   - 场景选项：矿山井下、石油化工、公共安全、港口码头、商业楼宇
   - 联动加载推荐策略

2. **StrategyCard** — 同上 `components/competitive/StrategyCard.vue`，网格布局展示四种策略

3. **TalkingPointsList** (`components/competitive/TalkingPointsList.vue`)
   - 关键话术列表，使用 `ElCollapse` accordion 模式（手风琴，一次只展开一项）
   - 每项：客户异议/问题 + 建议应对话术 + 支撑证据链接列表
   - 支撑证据：可点击的链接列表（认证证书、案例文档、技术白皮书等）

4. **EvidenceLinks** (`components/competitive/EvidenceLinks.vue`)
   - 支撑证据快速链接列表
   - 每项：链接名称 + 链接类型图标（PDF/链接/图片）+ 点击打开

**权限要求**：

| 角色 | 权限 | 说明 |
|------|------|------|
| 销售代表（100） | `cpq:competitive:recommend` | 查看推荐策略 |
| 售前工程师（101） | `cpq:competitive:recommend` | 查看+维护策略 |

---

## 附录I：知识库页面详细设计（Knowledge Base）

### I.0 概述

知识库模块为所有CPQ角色提供产品知识、销售话术、成功案例和培训资料的统一入口。该模块面向所有12个角色开放查看权限（除外部审计110仅可查看），销售运营（108）拥有编辑权限。

### I.1 ProductKnowledge.vue（产品知识库）

**页面路径**：`cpq-portal/src/views/knowledge/ProductKnowledge.vue`

**使用场景**：销售人员快速查阅产品知识文章，了解产品特性、技术参数、适用场景和竞品对比。支持全文搜索和分类浏览。

**布局**：

```
┌──────────┬───────────────────────────────────────────────────┐
│ 分类树    │ 搜索栏 + 热门标签                                    │
│ (240px)  │ [🔍 搜索产品知识...] [搜索]                          │
│          │ 热门标签: [对讲机] [防爆] [DMR] [数字通信] [IP67]    │
│ ElTree   ├───────────────────────────────────────────────────┤
│          │ 文章卡片列表                                         │
│ ├ 对讲设备│ ┌───────────────────────────────────────────────┐ │
│ │├ PD系列 │ │ 📖 PD785产品深度技术解析                        │ │
│ │├ BD系列 │ │ 标签: #DMR #数字通信 #防爆                      │ │
│ │└ 配件   │ │ 阅读: 1,250次 | 发布时间: 2026-05-15           │ │
│ ├ 基站设备│ └───────────────────────────────────────────────┘ │
│ │├ 中继站 │ ┌───────────────────────────────────────────────┐ │
│ │└ 控制器 │ │ 📖 DMR vs analog: 为何全面转向数字通信？        │ │
│ ├ 天线系统│ │ 标签: #DMR #数字化 #通信技术对比                 │ │
│ ├ 解决方案│ │ 阅读: 3,420次 | 发布时间: 2026-04-20           │ │
│ └ 技术白皮│ └───────────────────────────────────────────────┘ │
│          │ ... (更多文章卡片)                                   │
│          │                                                     │
│          │ 分页: ElPagination                                   │
└──────────┴───────────────────────────────────────────────────┘
```

**组件清单**：

1. **KnowledgeCategoryTree** (`components/knowledge/KnowledgeCategoryTree.vue`)
   - 基于 `ElTree` 的知识分类树
   - 数据源：字典表 `knowledge_category`
   - 节点：分类名称 + 文章数量badge（`ElBadge`）
   - 点击节点：触发文章列表按分类筛选
   - 默认展开第一级分类

2. **ArticleSearchBar** (`components/knowledge/ArticleSearchBar.vue`)
   - 搜索输入框 + 搜索按钮
   - 支持全文搜索（MySQL FULLTEXT 或 Elasticsearch）
   - 防抖300ms自动搜索
   - 搜索时显示加载状态（`ElInput` prefix-icon 旋转动画）

3. **ArticleCard** (`components/knowledge/ArticleCard.vue`)
   - 文章摘要卡片，使用 `ElCard`
   - 内容：标题（加粗14px）、摘要（13px灰色最多3行截断）、标签行（`ElTag` size="small" type="info"）、元信息行（阅读量👁 + 发布时间📅）
   - Hover效果：`box-shadow`增强 + border颜色变为 `$--color-primary`
   - 点击卡片：打开 `ArticleDetailDrawer`

4. **ArticleDetailDrawer** (`components/knowledge/ArticleDetailDrawer.vue`)
   - 基于 `ElDrawer` 的全屏阅读模式
   - 方向：从右侧滑入，宽度：`60%`（桌面端）/ `100%`（移动端）
   - 内容：文章标题（H2）、发布时间+作者、标签行、Markdown渲染正文（使用 `marked` 或 `markdown-it`）、相关文章推荐列表（底部）
   - 工具栏：打印、复制链接、收藏、调整字号(±)

5. **TagCloud** (`components/knowledge/TagCloud.vue`)
   - 热门标签云，使用 `ElTag` 列表渲染
   - 标签大小根据热度变化（使用不同字号或 `ElTag` size）
   - 点击标签：触发搜索（按标签筛选文章）

**全文搜索**：支持 MySQL FULLTEXT 索引或 Elasticsearch。搜索关键词高亮显示在结果卡片中（使用 `v-html` 渲染高亮片段）。

**权限要求**：

| 角色 | 权限 | 说明 |
|------|------|------|
| 所有角色（100-111） | `cpq:knowledge:view` | 查看知识文章 |
| 销售运营（108） | `cpq:knowledge:edit` | 创建、编辑、删除文章 |

### I.2 SalesScripts.vue（销售话术库）

**页面路径**：`cpq-portal/src/views/knowledge/SalesScripts.vue`

**使用场景**：销售人员在拜访客户前或应对客户异议时，快速查阅按场景分类的销售话术，获得专业的应对策略和关键要点。

**布局**：

```
┌──────────────────────────────────────────────────────────────┐
│ 场景Tabs (ElTabs)                                             │
│ [全部] [陌拜开场] [深度需求挖掘] [异议处理] [逼单成交] [增购推荐] │
├──────────────────────────────────────┬───────────────────────┤
│ 话术卡片列表                          │ 成功率统计 (240px)      │
│                                      │                       │
│ ┌──────────────────────────────────┐ │ 话术使用排行 (Top 10)   │
│ │ 🎯 矿山场景-初次拜访话术           │ │ ┌──────┬────┬───────┐ │
│ │ 场景: 陌拜 | 关联产品: PD785/BD300│ │ │ 话术  │使用 │成功率  │ │
│ │                                  │ │ ├──────┼────┼───────┤ │
│ │ 要点:                            │ │ │ 异议A │ 238│ 78%  │ │
│ │ 1. 开场从矿山安全法规切入          │ │ │ 逼单B │ 195│ 65%  │ │
│ │ 2. 强调IP67防护+ATEX认证          │ │ │ 陌拜C │ 182│ 72%  │ │
│ │ 3. 以同行案例引发共鸣              │ │ │ 增购D │ 156│ 55%  │ │
│ │                                  │ │ │ ...   │ ...│ ...  │ │
│ │ 异议应对: [展开3条常见异议应对]     │ │ └──────┴────┴───────┘ │
│ │                                  │ │                       │
│ │ 使用: 238次 | 成功率: 78%         │ │ 各场景成功率对比柱状图  │
│ └──────────────────────────────────┘ │ ECharts               │
│                                      │                       │
│ ┌──────────────────────────────────┐ │                       │
│ │ 💡 价格异议-标准应对话术           │ │                       │
│ │ ...                              │ │                       │
│ └──────────────────────────────────┘ │                       │
│                                      │                       │
│ 分页                                 │                       │
└──────────────────────────────────────┴───────────────────────┘
```

**组件清单**：

1. **ScriptScenarioTabs** (`components/knowledge/ScriptScenarioTabs.vue`)
   - 基于 `ElTabs` 的场景筛选标签页
   - 标签页：全部、陌拜开场、深度需求挖掘、异议处理、逼单成交、增购推荐
   - 切换标签时筛选话术列表

2. **ScriptCard** (`components/knowledge/ScriptCard.vue`)
   - 话术卡片，使用 `ElCard`
   - 内容：场景标签(`ElTag`)、关联产品标签、话术要点列表（`<ol>` 编号）、使用统计（次数 + 成功率进度条）
   - 底部：`[展开异议应对]` 按钮（点击展开 `ObjectionResponseAccordion`）

3. **ObjectionResponseAccordion** (`components/knowledge/ObjectionResponseAccordion.vue`)
   - 异议应对折叠面板，使用 `ElCollapse`
   - 每项：客户异议（标题）+ 建议应对话术（内容）+ 支撑数据/证据

4. **SuccessRateChart** (`components/knowledge/SuccessRateChart.vue`)
   - 成功率统计面板，包含：
     * 话术使用排行表（`ElTable` small size）
     * 各场景成功率柱状图（ECharts bar chart）
   - 右侧sticky定位

**权限要求**：

| 角色 | 权限 | 说明 |
|------|------|------|
| 销售代表（100） | `cpq:knowledge:scripts` | 查看话术 |
| 售前工程师（101） | `cpq:knowledge:scripts` | 查看+维护 |
| 渠道伙伴（103） | `cpq:knowledge:scripts` | 查看话术 |

### I.3 CaseLibrary.vue（成功案例库）

**页面路径**：`cpq-portal/src/views/knowledge/CaseLibrary.vue`

**使用场景**：浏览成功案例，了解产品在不同行业和场景下的实际应用效果。销售人员可使用案例作为说服客户的参考材料。

**布局**：响应式网格卡片布局，使用 `ElRow` + `ElCol`，gutter=16px。桌面端4列（xl: 6 span each）、平板2列（md: 12 span each）、移动端1列（xs: 24 span）。

**组件清单**：

1. **CaseCard** (`components/knowledge/CaseCard.vue`)
   - 案例摘要卡片，使用 `ElCard` + `hover-shadow`
   - 内容：客户公司名（加粗）、行业标签(`ElTag`)、挑战摘要（2行截断）、解决方案亮点（1行）、KPI指标（使用 `ElStatistic` 组件展示，如"成本降低35%" "交付周期缩短40%"）
   - 悬浮效果：KPI指标放大动画（`transform: scale(1.05)`）

2. **CaseDetailDialog** (`components/knowledge/CaseDetailDialog.vue`)
   - 案例详情弹窗，使用 `ElDialog` fullscreen模式
   - 内容模块：背景与挑战、解决方案详述、实施过程、关键成果（KPI指标图表）、客户评价引述、相关产品链接

**权限要求**：所有角色（100-111）

### I.4 TrainingCenter.vue（培训中心）

**页面路径**：`cpq-portal/src/views/knowledge/TrainingCenter.vue`

**使用场景**：按技能等级浏览培训资料，跟踪学习进度。系统根据用户角色推荐相关培训内容。

**布局**：

```
┌──────────────────────────────────────────────────────────────┐
│ 技能等级Tabs: [全部] [🟢 初级] [🟡 中级] [🔴 高级]              │
├──────────────────────────────────────┬───────────────────────┤
│ 培训资料网格                          │ 我的学习进度 (280px)     │
│                                      │                       │
│ ┌──────────┐ ┌──────────┐ ┌────────┐│ 学习进度总览            │
│ │🎬 视频    │ │📄 PDF    │ │🖼️ 幻灯片││ CPQ基础 ████████░░ 80% │
│ │PD785配置 │ │防爆标准   │ │DMR技术  ││ 定价引擎 ████░░░░░░ 40%│
│ │⏱ 25分钟  │ │12页      │ │45页    ││ 报价模板 ██░░░░░░░░ 20%│
│ │✓ 128人完成│ │✓ 95人完成 │ │63人完成 ││ 集成基础 ░░░░░░░░░░ 0% │
│ └──────────┘ └──────────┘ └────────┘│                       │
│ ┌──────────┐ ┌──────────┐           │ 已完成列表              │
│ │📝 测验    │ │🌐 在线讲座 │           │ ✓ PD785产品培训       │
│ │DMR理论   │ │矿山通信   │           │ ✓ 报价单模板制作       │
│ │20题     │ │⏱ 60分钟  │           │ ✓ 竞品对比方法论        │
│ │204人完成 │ │下周三直播 │           │                       │
│ └──────────┘ └──────────┘           │ 推荐学习               │
│                                      │ → 配置规则高级应用     │
│ 分页                                 │ → ATP交期管理          │
└──────────────────────────────────────┴───────────────────────┘
```

**组件清单**：

1. **TrainingMaterialCard** (`components/knowledge/TrainingMaterialCard.vue`)
   - 培训资料卡片，使用 `ElCard`，根据资料类型显示不同图标：
     * VIDEO（视频）：🎬 播放图标 + 时长
     * PDF（文档）：📄 文档图标 + 页数
     * SLIDES（幻灯片）：🖼️ 幻灯片图标 + 页数
     * QUIZ（测验）：📝 问卷图标 + 题数
     * WEBINAR（在线讲座）：🌐 直播图标 + 开始时间
   - 底部：完成人数统计

2. **VideoPlayer** (`components/knowledge/VideoPlayer.vue`)
   - 视频播放器，使用 `ElDialog` 内嵌 `<video>` 标签
   - 支持：播放/暂停、进度条、音量控制、全屏
   - 关闭Dialog时自动暂停

3. **MyProgressPanel** (`components/knowledge/MyProgressPanel.vue`)
   - 右侧学习进度面板
   - 进度总览：多个 `ElProgress` 条显示各模块完成度
   - 已完成列表：`ElTimeline` 显示已完成的学习活动
   - 推荐学习：基于角色和未完成课程的推荐列表

**权限要求**：

| 角色 | 权限 | 说明 |
|------|------|------|
| 所有角色（100-111） | `cpq:knowledge:training` | 查看培训内容 |
| `required_role_ids` 过滤 | — | 按角色过滤推荐课程 |

---

## 附录J：ECN/ECO变更管理页面详细设计（Change Management）

### J.0 概述

工程变更管理（ECN/ECO）是制造业CPQ系统的核心功能之一，对应阶段二流程5"ECN/ECO变更五级传播"。从物料变更开始，通过五级传播链影响BOM→配置→报价→审批。本模块面向产品经理（104）、系统管理员（111）、销售经理（102）和审批人（107）。

### J.1 ChangeManagement.vue（变更管理主页）

**页面路径**：`cpq-portal/src/views/ecn/ChangeManagement.vue`

**使用场景**：产品经理查看和管理所有工程变更通知（ECN），创建新的变更请求，追踪变更状态。

**布局**（标准列表页）：

```
┌──────────────────────────────────────────────────────────────┐
│ 搜索条件: [ECN编号...] [状态: 全部▼] [类型: 全部▼] [日期范围]    │
│ [搜索] [重置]                                [+ 新建变更申请]   │
├──────────────────────────────────────────────────────────────┤
│ 表格 (ElTable)                                                │
│ ┌──────────────────────────────────────────────────────────┐ │
│ │ ECN编号    │ 标题          │ 类型  │ 状态 │ 优先级│ 发起人 │ │
│ ├────────────┼──────────────┼──────┼─────┼─────┼─────── │ │
│ │ ECN-00105  │ PD785电池升级  │ 🔴紧急│ 审批中│ 🔴高  │ 张三   │ │
│ │ ECN-00104  │ BD300天线材质 │ 🔵常规│ 已实施│ 🟡中  │ 李四   │ │
│ │ ECN-00103  │ 全线产品固件  │ 🟣策略│ 草稿 │ 🟢低  │ 王五   │ │
│ │ ...        │ ...           │ ...  │ ...  │ ...  │ ...    │ │
│ └──────────────────────────────────────────────────────────┘ │
│ 分页                                                          │
└──────────────────────────────────────────────────────────────┘
```

**类型标签颜色**：

| 类型 | 颜色 | Element Plus type |
|------|------|-------------------|
| 紧急变更 | 红色 `$--color-danger` | `danger` |
| 常规变更 | 蓝色 `$--color-primary` | `primary` |
| 策略变更 | 紫色 `#7B1FA2` | 自定义 |

**优先级标签**：

| 优先级 | 颜色 | type |
|--------|------|------|
| 高 | 红色 | `danger` |
| 中 | 橙色 | `warning` |
| 低 | 绿色 | `success` |

**组件清单**：

1. **EcnCreateDialog** (`components/ecn/EcnCreateDialog.vue`)
   - `ElDialog` 弹窗表单
   - 字段：标题（`ElInput`，必填）、变更类型（`ElRadioGroup`：紧急/常规/策略）、变更原因（`ElInput` type="textarea"）、优先级（`ElRadioGroup`：高/中/低）、有效日期（`ElDatePicker`）、变更说明附件（`ElUpload`）

2. **StatusBadge** — 复用全局 `StatusBadge.vue`，扩展ECN状态类型
3. **PriorityTag** — 同上，渲染优先级标签

**权限要求**：

| 角色 | 权限 | 说明 |
|------|------|------|
| 产品经理（104） | `cpq:ecn:manage` | 完整CRUD |
| 系统管理员（111） | `cpq:ecn:manage` | 完整CRUD |

### J.2 ImpactAnalysis.vue（影响分析）

**页面路径**：`cpq-portal/src/views/ecn/ImpactAnalysis.vue`

**使用场景**：分析某个ECN变更对下游的传播影响，以ECharts树图可视化五级传播链：物料→BOM→配置→报价→审批。

**布局**：

```
┌──────────────────────────────────────────────────────────────┐
│ ECN基本信息卡片                                                │
│ ┌ ECN-00105: PD785电池升级 → 更换电芯供应商 ─────────────────┐ │
│ │ 发起人: 张三  |  状态: 🔴审批中  |  优先级: 高              │ │
│ │ 变更说明: 将PD785电池从松下NCR18650B更换为三星INR18650-35E  │ │
│ │ 理由: 松下电芯停产，三星电芯性能更优且成本降低12%            │ │
│ └──────────────────────────────────────────────────────────┘ │
├──────────────┬───────────────────────────────────────────────┤
│ 传播树图      │ 影响清单 (ElTable)                              │
│ (ECharts)    │ ┌───────────────────────────────────────────┐ │
│              │ │ 等级 │ 实体        │ 描述        │ 在途报价│ │
│ 5级树形图:   │ ├──────┼────────────┼────────────┼────────│ │
│              │ │ 🔴   │ B001 电池   │ 电芯更换    │ 3个     │ │
│ ①变更项:    │ │ 🟠   │ MBOM-PD785  │ 物料清单更新│ 2个     │ │
│  B001电池    │ │ 🟠   │ 矿山标准配置 │ 配置参数需要│ 5个     │ │
│  ├─②BOM:    │ │ 🟡   │ QTE-0488    │ 报价价格重算│ 1个     │ │
│  │ MBOM-PD785│ │ 🟡   │ QTE-0495    │ 报价价格重算│ 1个     │ │
│  │ SBOM-矿山 │ │ 🟡   │ QTE-0500    │ 报价价格重算│ 1个     │ │
│  │ SBOM-石油 │ │ 🟢   │ SLN-120     │ 方案内容更新│ 0个     │ │
│  ├─③配置:   │ │ ...  │ ...         │ ...        │ ...    │ │
│  │ 矿山标准   │ └───────────────────────────────────────────┘ │
│  │ 石油标准   │                                               │
│  │ 公共安全   │                                               │
│  ├─④报价:   │                                               │
│  │ QTE-0488 │                                               │
│  │ QTE-0495 │                                               │
│  │ QTE-0500 │                                               │
│  └─⑤方案:   │                                               │
│     SLN-120 │                                               │
└──────────────┴───────────────────────────────────────────────┘
```

**组件清单**：

1. **EcnSummaryCard** (`components/ecn/EcnSummaryCard.vue`)
   - ECN基本信息摘要卡片，`ElCard`
   - 显示：ECN编号、标题、发起人、状态、优先级、变更说明

2. **PropagationTree** (`components/ecn/PropagationTree.vue`)
   - 基于ECharts tree图表的五级传播链可视化
   - 5级节点：变更项(红色) → BOM(橙色) → 配置(黄色) → 报价(蓝色) → 方案(绿色)
   - 节点大小表示影响范围（受影响实体数越多，节点越大）
   - 节点悬浮tooltip显示：实体名称、影响类型、受影响数量
   - 点击节点：触发影响清单表格滚动到对应行

3. **ImpactList** (`components/ecn/ImpactList.vue`)
   - 影响清单表格，`ElTable`
   - 列：影响等级、影响实体、描述、在途报价数
   - 影响等级颜色编码：
     * CRITICAL 严重 = 红色 `$--color-danger`
     * HIGH 高 = 橙色 `$--color-warning`
     * MEDIUM 中 = 黄色 `#FFC107`
     * LOW 低 = 蓝色 `$--color-info`
     * NONE 无影响 = 灰色 `$--color-text-secondary`
   - 行点击：跳转到受影响实体的详情页

4. **AffectedQuotesPanel** (`components/ecn/AffectedQuotesPanel.vue`)
   - 受影响报价列表面板
   - 显示所有受该ECN影响的在途报价（未完成审批的报价）

**权限要求**：

| 角色 | 权限 | 说明 |
|------|------|------|
| 产品经理（104） | `cpq:ecn:analyze` | 查看影响分析 |
| 销售经理（102） | `cpq:ecn:analyze` | 查看对报价的影响 |
| 审批人（107） | `cpq:ecn:analyze` | 审批决策参考 |

### J.3 ChangeApproval.vue（变更审批）

**页面路径**：`cpq-portal/src/views/ecn/ChangeApproval.vue`

**使用场景**：审批人审批ECN变更申请，查看变更项的前后对比，了解影响范围后做出审批决策。

**布局**：

```
┌──────────────────────────────┬────────────────────────────────┐
│ 左侧: 变更详情 + 变更项列表     │ 右侧: 审批链 + 审批表单          │
│ (60%)                        │ (40%)                          │
│                              │                                │
│ ECN-00105详情                 │ 审批链 (ElSteps vertical)        │
│ [ECN基本信息摘要]              │ ● ① 产品经理初审 ✓             │
│                              │   张三 2026-06-01              │
│ 变更项列表                     │ ● ② 技术评审 ✓                │
│ ┌─ B001 电池 ──────────────┐ │   李四 2026-06-03              │
│ │ 电芯:                     │ │ ● ③ 财务审批 ◐ (当前步骤)      │
│ │ 松下NCR18650B → 三星INR   │ │   王五 — 待审批               │
│ │ 容量: 3400mAh → 3500mAh   │ │ ○ ④ 最终批准                   │
│ │ 价格: ¥48 → ¥42           │ │   赵六                         │
│ │ 供应商: 松下 → 三星SDI     │ │                                │
│ │ [详细对比 ▼]               │ │                                │
│ └───────────────────────────┘ │ 审批表单                        │
│                              │ 意见:                           │
│ ┌─ 电池BOM变更 ─────────────┐ │ [文本输入...]                   │
│ │ 影响子件:                  │ │                                │
│ │ MBOM-PD785 (第3层)        │ │ [驳回] [请求修改] [同意] [转交]  │
│ │ [展开受影响配置...]         │ │                                │
│ └───────────────────────────┘ │                                │
└──────────────────────────────┴────────────────────────────────┘
```

**组件清单**：

1. **ChangeItemList** (`components/ecn/ChangeItemList.vue`)
   - 变更项diff对比列表
   - 每个变更项显示：变更项名称 + 变更前后对比（old→new，使用删除线+高亮）
   - 展开详情：完整的变更字段diff表格
   - 使用 `ElCollapse` accordion模式

2. **ApprovalChainSteps** (`components/ecn/ApprovalChainSteps.vue`)
   - 垂直审批链步骤条，`ElSteps` direction="vertical"
   - 每步：步骤名称 + 审批人姓名 + 审批时间 + 状态图标（✓通过 / ✗驳回 / ◐进行中 / ○待审批）
   - 当前步骤：脉冲动画高亮

3. **ApprovalForm** (`components/ecn/ApprovalForm.vue`)
   - 审批表单
   - `ElRadioGroup`：通过 / 驳回 / 请求修改
   - `ElInput` type="textarea"：审批意见
   - `ElButton`：提交审批 / 转交给其他审批人

**权限要求**：

| 角色 | 权限 | 说明 |
|------|------|------|
| 审批人（107） | `cpq:ecn:approve` | 审批决策 |
| 产品经理（104） | `cpq:ecn:approve` | 技术评审 |

---

## 附录K：定价管理页面详细设计（Pricing Management）

### K.0 概述

定价管理模块面向定价管理员（角色105）和系统管理员（角色111），提供价格手册管理、定价规则配置、阶梯定价、折扣审批和汇率管理功能。该模块在前端目录结构（`cpq-portal/src/views/pricing/`）中已有定义但缺少详细设计规格。

### K.1 PriceBookList.vue（价格手册管理）

**页面路径**：`cpq-portal/src/views/pricing/PriceBookList.vue`

**使用场景**：定价管理员创建和管理价格手册，维护各产品的标准价格（牌价）和成本价。支持多种币种的价格手册（人民币、美元、欧元等）。

**布局**（标准CRUD + 展开行）：

```
┌──────────────────────────────────────────────────────────────┐
│ 搜索: [名称...] [币种: 全部▼] [状态: 全部▼] [搜索] [+ 新增手册]  │
├──────────────────────────────────────────────────────────────┤
│ 表格 (ElTable, expandable rows)                               │
│ ┌──────────────────────────────────────────────────────────┐ │
│ │ > │ 手册名称       │ 币种 │ 有效期            │ 状态 │ 操作│ │
│ ├───┼───────────────┼─────┼──────────────────┼─────┼───── │ │
│ │ ▼ │ 2026年度标准价  │ CNY  │ 2026.01.01-12.31 │ 🟢启用│ 编辑 │ │
│ │   │ ┌ 展开: 价格条目 (嵌套ElTable) ─────────────────────┐ │ │
│ │   │ │ 产品型号   │ 牌价     │ 成本价   │ 协议价   │ 有效期│ │ │
│ │   │ │ PD785-DMR │ ¥4,850  │ ¥3,200  │ ¥4,200  │全年  │ │ │
│ │   │ │ BD300     │ ¥980    │ ¥650    │ ¥850    │全年  │ │ │
│ │   │ │ PD985     │ ¥12,800 │ ¥8,500  │ ¥11,000 │全年  │ │ │
│ │   │ │ ...       │ ...     │ ...     │ ...     │ ...  │ │ │
│ │   │ └──────────────────────────────────────────────────┘ │ │
│ │ > │ 2026年度美元价  │ USD  │ 2026.01.01-12.31 │ 🟢启用│ 编辑 │ │
│ │ > │ 渠道专属手册    │ CNY  │ 2026.03.01-12.31 │ 🟢启用│ 编辑 │ │
│ └──────────────────────────────────────────────────────────┘ │
└──────────────────────────────────────────────────────────────┘
```

**组件清单**：

1. **PriceBookFormDialog** (`components/pricing/PriceBookFormDialog.vue`)
   - 创建/编辑价格手册弹窗
   - 字段：手册名称、币种（`ElSelect`）、有效期（`ElDatePicker` range）、状态（`ElSwitch` 启用/停用）

2. **PriceBookEntryDialog** (`components/pricing/PriceBookEntryDialog.vue`)
   - 价格条目添加/编辑弹窗
   - 字段：产品搜索（`ElSelect` remote search）、牌价（`ElInputNumber`）、成本价（`ElInputNumber`）、协议价（`ElInputNumber`）、有效期（`ElDatePicker`）

3. **EffectiveDateRangePicker** — 日期范围选择器封装，限制结束日期不能早于开始日期

**权限要求**：

| 角色 | 权限 | 说明 |
|------|------|------|
| 定价管理员（105） | `cpq:pricing:manage` | 完整CRUD |
| 系统管理员（111） | `cpq:pricing:manage` | 完整CRUD |

### K.2 PriceRuleConfig.vue（定价规则配置）

**页面路径**：`cpq-portal/src/views/pricing/PriceRuleConfig.vue`

**使用场景**：定价管理员配置动态定价规则，包括折扣规则（DISCOUNT）、价格上浮规则（MARKUP）和价格覆盖规则（OVERRIDE）。规则基于条件表达式自动触发。

**布局**：

```
┌──────────────────────────────────────────────────────────────┐
│ 规则类型Tabs: [全部] [折扣规则] [上浮规则] [覆盖规则]             │
├────────────────────────────────────┬─────────────────────────┤
│ 规则列表                            │ 规则预览面板 (320px)      │
│                                    │                         │
│ ┌────────────────────────────────┐ │ 当前规则预览:             │
│ │ ⇅ 规则                            │ • 条件: 数量≥100         │
│ │ ┌ 优先级1: 大客户折扣 ─────────┐ │   AND 客户等级=VIP       │
│ │ │ 类型: 🟢DISCOUNT             │ │ • 动作: 牌价×0.85       │
│ │ │ 条件: quantity>=100 AND      │ │ • 叠加: 不可叠加其他折扣  │
│ │ │       客户等级=VIP           │ │ • 有效: 2026.01-12.31   │
│ │ │ 动作: 牌价 × 0.85            │ │                         │
│ │ │ 状态: 🟢生效 [编辑] [停用]    │ │                         │
│ │ └─────────────────────────────┘ │ │                         │
│ │ ┌ 优先级2: 海外加价 ───────────┐ │ │                         │
│ │ │ 类型: 🔵MARKUP               │ │                         │
│ │ │ 条件: 区域=海外 AND          │ │                         │
│ │ │       币种≠CNY               │ │                         │
│ │ │ 动作: 牌价 × 1.10            │ │                         │
│ │ │ 状态: 🟢生效 [编辑] [停用]    │ │                         │
│ │ └─────────────────────────────┘ │ │                         │
│ │ ...                             │ │                         │
│ └────────────────────────────────┘ │                         │
│                                    │                         │
│ [+ 新增规则]                        │                         │
└────────────────────────────────────┴─────────────────────────┘
```

**组件清单**：

1. **RuleConditionBuilder** (`components/pricing/RuleConditionBuilder.vue`)
   - 可视化条件编辑器
   - 支持：AND/OR逻辑组合、字段选择（产品/数量/区域/客户等级/币种）、操作符选择（=/≠/≥/≤/包含/不包含）、值输入
   - 使用 `ElSelect` + `ElInput` 的组合行，支持添加多个条件
   - 底部显示JSON预览（用于高级用户直接编辑JSON）

2. **RuleActionSelector** (`components/pricing/RuleActionSelector.vue`)
   - 规则动作选择器
   - 动作类型：折扣百分比、固定减价、固定加价、覆盖价格
   - 可叠加规则开关：是否允许与其他规则叠加

3. **PriorityDragSort** — 使用 `vuedraggable` 或原生 HTML5 Drag API 实现规则优先级拖拽排序

4. **RulePreviewPanel** (`components/pricing/RulePreviewPanel.vue`)
   - 右侧预览面板，选择某个规则时预览其匹配逻辑
   - 自然语言描述：将JSON条件翻译为可读的文本

**权限要求**：定价管理员（105）

### K.3 VolumeTierConfig.vue（阶梯定价配置）

**页面路径**：`cpq-portal/src/views/pricing/VolumeTierConfig.vue`

**使用场景**：定价管理员为特定产品或产品族配置阶梯价格（数量折扣）。例如：1-50台¥4,850/台，51-100台¥4,600/台，101-500台¥4,350/台。

**布局**：

```
┌──────────────────────────────────────────────────────────────┐
│ 产品选择: [请选择产品或价格条目... ▼]                            │
├────────────────────────────────┬─────────────────────────────┤
│ 阶梯表 (可编辑ElTable)          │ 阶梯折线图 (ECharts)          │
│                                │                             │
│ ┌────────────────────────────┐ │ 单价 ¥                      │
│ │ 最低数量│最高数量│单价    │折扣%│ │ 4850 ─●                    │
│ │────────┼───────┼────────┼────┼ │      │ ╲                  │
│ │ 1      │ 50   │ ¥4,850 │ 0% │ │ 4600 ─┼──●                │
│ │ 51     │ 100  │ ¥4,600 │ 5% │ │      │    ╲              │
│ │ 101    │ 500  │ ¥4,350 │ 10%│ │ 4350 ─┼────●              │
│ │ 501    │ 9999 │ ¥4,100 │ 15%│ │ 4100 ─┼──────●            │
│ │        │      │        │    │ │      └───┴───┴───┴── 数量  │
│ │ [+ 添加阶梯]                 │ │   1   50  100 500 9999    │
│ └────────────────────────────┘ │                             │
└────────────────────────────────┴─────────────────────────────┘
```

**组件清单**：

1. **ProductEntrySelector** (`components/pricing/ProductEntrySelector.vue`)
   - 产品或价格条目选择器，`ElSelect` remote search
   - 用于选择要配置阶梯定价的目标产品

2. **TierTableEditor** (`components/pricing/TierTableEditor.vue`)
   - 可内联编辑的阶梯表，基于 `ElTable`
   - 列：最低数量(`ElInputNumber`)、最高数量(`ElInputNumber`)、单价(`ElInputNumber`)、折扣百分比（自动计算）
   - 行操作：添加阶梯按钮在表格底部、删除单行（×按钮）
   - 校验：数量区间不能重叠、最低数量 < 最高数量

3. **TierChart** (`components/pricing/TierChart.vue`)
   - 基于ECharts的阶梯折线图
   - X轴：数量，Y轴：单价
   - 阶梯型线条（`step: 'end'`），展示价格随数量的阶梯变化
   - 支持多个产品系列叠加对比

**权限要求**：定价管理员（105）

### K.4 DiscountApproval.vue（折扣审批管理）

**页面路径**：`cpq-portal/src/views/pricing/DiscountApproval.vue`

**使用场景**：定价管理员和审批人查看超过最大允许折扣的申请，审批或驳回超出阈值的折扣请求。

**布局**：表格主视图，显示超限折扣申请列表。每行包含折扣对比进度条和审批操作按钮。

**组件清单**：

1. **DiscountComparisonBar** (`components/pricing/DiscountComparisonBar.vue`)
   - 折扣对比进度条组件
   - 上半部分（蓝色）：申请折扣比例
   - 下半部分（红色）：超出最大允许的部分
   - 进度条红线标记最大允许折扣位置
   - Tooltip显示详细数字

2. **BulkApproveActions** — 批量审批操作栏，显示在表格上方，`ElCheckbox`全选 + [批量通过] [批量驳回] 按钮

**权限要求**：

| 角色 | 权限 | 说明 |
|------|------|------|
| 定价管理员（105） | `cpq:pricing:approve` | 审批折扣 |
| 审批人（107） | `cpq:pricing:approve` | 审批折扣 |
| 销售经理（102） | `cpq:pricing:approve` | 审批团队折扣 |

### K.5 CurrencyConfig.vue（汇率配置）

**页面路径**：`cpq-portal/src/views/pricing/CurrencyConfig.vue`

**使用场景**：定价管理员维护多币种汇率表，用于报价时自动进行币种转换。

**布局**：表格主视图，列：源币种、目标币种、汇率、生效日期、更新时间、操作（编辑/删除）。

**组件清单**：

1. **CurrencyRateEditor** (`components/pricing/CurrencyRateEditor.vue`)
   - 汇率编辑弹窗
   - 字段：源币种(`ElSelect`)、目标币种(`ElSelect`)、汇率(`ElInputNumber` precision=6)、生效日期(`ElDatePicker`)

2. **RateHistoryChart** (`components/pricing/RateHistoryChart.vue`)
   - 汇率历史走势折线图（ECharts line chart）
   - 可选择显示3个月/6个月/1年的历史汇率趋势
   - 多系列：实际汇率 vs 锁定汇率

**权限要求**：

| 角色 | 权限 | 说明 |
|------|------|------|
| 定价管理员（105） | `cpq:pricing:currency` | 管理汇率 |
| 系统管理员（111） | `cpq:pricing:currency` | 管理汇率 |

---

## 附录L：审批管理页面详细设计（Approval Management）

### L.0 概述

审批管理模块面向审批人（107）、销售经理（102）、高层管理者（109）和外部审计（110），覆盖从待审批列表、审批详情、历史记录到审批效率分析的全流程。

### L.1 PendingApproval.vue（待审批列表）

**页面路径**：`cpq-portal/src/views/approval/PendingApproval.vue`

**使用场景**：审批人查看和管理所有待审批事项，支持批量操作和快速审批。

**布局**：

```
┌──────────────────────────────────────────────────────────────┐
│ Tabs: [待我审批(5)] [我已审批] [我发起的]                        │
│ [批量通过] [批量驳回]                                           │
├──────────────────────────────────────────────────────────────┤
│ 表格 (ElTable, selection)                                     │
│ ┌──────────────────────────────────────────────────────────┐ │
│ │ ☐│ 类型      │ 编号       │ 申请人 │ 提交时间   │ 步骤  │操作│ │
│ ├──┼──────────┼───────────┼───────┼───────────┼──────┼────│ │
│ │ ☐│ 🔵报价审批│ QTE-0500  │ 张三   │ 06-05 14:30│ 2/4  │审批│ │
│ │ ☐│ 🔵报价审批│ QTE-0499  │ 李四   │ 06-05 11:20│ 3/4  │审批│ │
│ │ ☐│ 🟣ECN审批 │ ECN-00105 │ 张三   │ 06-05 09:00│ 1/3  │审批│ │
│ │ ☐│ 🟢方案评审│ SLN-120   │ 王五   │ 06-04 16:45│ 2/2  │审批│ │
│ │ ☐│ 🔴折扣审批│ DSC-032   │ 赵六   │ 06-04 10:00│ 1/2  │审批│ │
│ └──────────────────────────────────────────────────────────┘ │
└──────────────────────────────────────────────────────────────┘
```

**组件清单**：

1. **ApprovalActionButtons** (`components/approval/ApprovalActionButtons.vue`)
   - 四个操作按钮：通过（`type="success"`）、驳回（`type="danger"`）、转交（`type="warning"`）、升级（`type="info"`）
   - 通过/驳回：点击弹出确认对话框 + 意见输入
   - 转交：弹出 `ElSelect` 选择转交目标审批人
   - 升级：将审批自动升级到更高级别审批链

2. **BatchApproveBar** (`components/approval/BatchApproveBar.vue`)
   - 批量操作栏：显示在表格上方
   - 全选checkbox + 已选数量计数
   - [批量通过] [批量驳回] 按钮
   - 不可用于不同类型的审批项混合批量操作

**权限要求**：

| 角色 | 权限 | 说明 |
|------|------|------|
| 审批人（107） | `cpq:approval:process` | 审批操作 |
| 销售经理（102） | `cpq:approval:process` | 审批操作 |
| 高层管理者（109） | `cpq:approval:process` | 审批操作 |

### L.2 ApprovalDetail.vue（审批详情）

**页面路径**：`cpq-portal/src/views/approval/ApprovalDetail.vue`

**使用场景**：审批人查看被审批实体的完整详情（报价单、方案、ECN等），结合审批链时间线做出决策。

**布局**：左侧60%渲染被审批实体（动态组件），右侧40%显示审批链 + 审批表单。

**组件清单**：

1. **EntityDetailRenderer** (`components/approval/EntityDetailRenderer.vue`)
   - 动态组件渲染器，根据 `entity_type` 动态加载对应实体详情组件
   - 映射：`QUOTE` → `QuoteDetail`、`SOLUTION` → `SolutionPreview`、`ECN` → `EcnSummaryCard`
   - 使用 `<component :is="...">` + defineAsyncComponent 动态导入

2. **ApprovalTimeline** (`components/approval/ApprovalTimeline.vue`)
   - 审批链时间线，`ElTimeline` + `ElTimelineItem`
   - 每项：审批人姓名 + 审批人头像(`ElAvatar`) + 审批动作（通过/驳回/请求修改）+ 审批意见 + 审批时间
   - 当前等待审批的节点：显示橙色脉冲动画
   - 已完成节点：显示绿色对勾
   - 驳回节点：显示红色叉号

3. **ApprovalForm** — 复用 `components/approval/ApprovalForm.vue`

**权限要求**：审批相关角色

### L.3 ApprovalHistory.vue（审批历史）

**页面路径**：`cpq-portal/src/views/approval/ApprovalHistory.vue`

**使用场景**：查询历史审批记录，支持高级检索（日期范围、状态、类型、申请人），用于审计和合规检查。

**组件清单**：

1. **AdvancedSearchForm** (`components/approval/AdvancedSearchForm.vue`)
   - 高级搜索表单，`ElForm` inline
   - 字段：日期范围(`ElDatePicker` range)、审批状态(`ElSelect`)、审批类型(`ElSelect`)、申请人(`ElInput`)

2. **ApprovalRecordTable** — 历史记录表格，增加列：审批结果、审批耗时、审批链详情

3. **ExportButton** — 导出审批记录按钮（导出为Excel，复用RuoYi Excel工具）

**权限要求**：

| 角色 | 权限 | 说明 |
|------|------|------|
| 审批人（107） | `cpq:approval:history` | 查看审批历史 |
| 销售经理（102） | `cpq:approval:history` | 查看团队审批 |
| 外部审计（110） | `cpq:approval:history` | 查看审批历史（只读） |

### L.4 ApprovalAnalytics.vue（审批效率Dashboard）

**页面路径**：`cpq-portal/src/views/approval/ApprovalAnalytics.vue`

**使用场景**：销售运营（108）和高层管理者（109）查看审批效率数据，识别审批瓶颈和超时问题。

**布局**：网格Dashboard布局（`ElRow` + `ElCol` 2列），包含5个ECharts图表。

**图表清单**：

1. **ApprovalTrendChart** — 审批量趋势折线图（按日/周/月），X轴时间、Y轴审批数量
2. **AvgDurationChart** — 平均审批时长柱状图（按审批类型分列），颜色编码通过时长
3. **ApprovalRateGauge** — 审批通过率仪表盘（ECharts gauge），显示通过/驳回/超时比例
4. **OverdueList** — 超时审批清单表格，列出所有超过SLA的审批记录
5. **WorkloadPieChart** — 审批人工作量分布饼图，展示各审批人的审批量占比

**权限要求**：

| 角色 | 权限 | 说明 |
|------|------|------|
| 销售运营（108） | `cpq:approval:analytics` | 查看分析 |
| 高层管理者（109） | `cpq:approval:analytics` | 查看分析 |

---

## 附录M：售前协同页面详细设计（Presales Collaboration）

### M.0 概述

售前协同模块面向售前工程师（101）、销售经理（102）和销售代表（100），提供任务看板、协同编辑和评审工作台三大核心功能，支持售前团队高效协作完成任务。

### M.1 TaskBoard.vue（任务看板）

**页面路径**：`cpq-portal/src/views/presales/TaskBoard.vue`

**使用场景**：售前团队管理方案请求任务，以Kanban风格可视化任务流转状态。销售代表提交方案请求后，售前工程师从看板上接单处理。

**布局**（四列Kanban看板）：

```
┌──────────────────────────────────────────────────────────────┐
│ [新建任务] [筛选: 全部▼] [负责人: 全部▼]                         │
├───────────┬────────────┬────────────┬────────────────────────┤
│ 待接单 (3) │ 处理中 (5)  │ 待评审 (2)  │ 已完成 (15)             │
│ (250px)   │ (250px)    │ (250px)    │ (250px)               │
│           │            │            │                       │
│ ┌───────┐ │ ┌────────┐ │ ┌────────┐ │ ┌──────────────────┐  │
│ │ 🔴高   │ │ │ 🟡中    │ │ │ 🟡中    │ │ │ 🟢已完成          │  │
│ │ 矿山方案│ │ │ 石油方案 │ │ │ 公共安全│ │ │ 港口码头方案       │  │
│ │ 客户:  │ │ │ 客户:   │ │ │ 客户:   │ │ │ 客户: XX港口集团  │  │
│ │ XX矿业 │ │ │ XX石化  │ │ │ XX消防局│ │ │ 负责人: 王五      │  │
│ │ 截止:  │ │ │ 负责人: │ │ │ 负责人: │ │ │ 完成: 06-04      │  │
│ │ 06-10  │ │ │ 李四    │ │ │ 李四    │ │ │                  │  │
│ │ [接单]  │ │ │ 截止:   │ │ │ [评审]  │ │ │ 详情             │  │
│ └───────┘ │ │ 06-12  │ │ └────────┘ │ └──────────────────┘  │
│           │ │ [完成]  │ │            │                       │
│ ┌───────┐ │ └────────┘ │ ┌────────┐ │ ┌──────────────────┐  │
│ │ 🟢低   │ │            │ │ 🔴高    │ │ │ 🟢已完成          │  │
│ │ 渠道方案│ │ ┌────────┐ │ │ 海外方案 │ │ │ ...              │  │
│ │ ...    │ │ │ ...    │ │ │ ...    │ │ └──────────────────┘  │
│ └───────┘ │ └────────┘ │ └────────┘ │                       │
└───────────┴────────────┴────────────┴────────────────────────┘
```

**组件清单**：

1. **KanbanColumn** (`components/presales/KanbanColumn.vue`)
   - 可放置区域（droppable），接受拖入的任务卡片
   - 列头：列名称 + 任务数量badge + 列颜色指示条
   - 列内渲染 `TaskCard` 列表
   - 使用 HTML5 Drag & Drop API（dragover/drop事件）或 vuedraggable

2. **TaskCard** (`components/presales/TaskCard.vue`)
   - 可拖拽任务卡片（draggable），`ElCard`
   - 左侧优先级颜色条：红(高)/橙(中)/绿(低)/灰(无)
   - 内容：方案名称、客户名称、负责人头像、截止日期（过期变红）、状态标签
   - 点击卡片：跳转到方案详情或协同编辑页

3. **QuickActionButtons** (`components/presales/QuickActionButtons.vue`)
   - 卡片hover时显示的操作按钮：接单、转派（`ElSelect`选择转交人）、催办

**拖拽行为**：将卡片从"待接单"拖入"处理中" = 自动接单（`PUT /presales/tasks/{id}/assign`）。将卡片从"处理中"拖入"待评审" = 标记完成进入评审（`PUT /presales/tasks/{id}/submit-review`）。

**权限要求**：

| 角色 | 权限 | 说明 |
|------|------|------|
| 售前工程师（101） | `cpq:presales:board` | 查看+接单+处理 |
| 销售经理（102） | `cpq:presales:board` | 查看+分派 |
| 销售代表（100） | `cpq:presales:board` | 查看自己提交的任务 |

### M.2 CollabEditor.vue（售前协同编辑）

**页面路径**：`cpq-portal/src/views/presales/CollabEditor.vue`

**使用场景**：售前团队多人协同编辑方案文档，实时讨论和批注。与SolutionEditor.vue共享底层Tiptap+Yjs技术栈，但增加了聊天面板和更轻量的售前场景专用功能。

**布局**（三栏）：左栏（协同用户列表+聊天面板240px）、中栏（Tiptap编辑器flex-1）、右栏（批注+版本历史240px）。与SolutionEditor.vue共享核心组件但布局差异在于增加了实时聊天面板。

**组件清单**：

1. **CollabUserList** (`components/presales/CollabUserList.vue`) — 在线协同用户列表，显示在线状态（绿点/黄点/灰点）+ 用户颜色标识
2. **ChatPanel** (`components/presales/ChatPanel.vue`) — 实时聊天面板，使用SSE推送消息。消息列表 `ElScrollbar` + 消息输入 `ElInput` + 发送按钮
3. **TiptapEditor** — 复用 `@/components/solution/TiptapEditor.vue`
4. **CommentPanel** — 复用 `@/components/solution/CommentThread.vue`
5. **VersionHistory** — 复用 `@/components/solution/VersionTimeline.vue`

**权限要求**：

| 角色 | 权限 | 说明 |
|------|------|------|
| 售前工程师（101） | `cpq:presales:collab` | 完整协同编辑 |
| 销售代表（100） | `cpq:presales:collab` | 查看+评论 |

### M.3 ReviewWorkbench.vue（评审工作台）

**页面路径**：`cpq-portal/src/views/presales/ReviewWorkbench.vue`

**使用场景**：评审专家（产品经理、销售经理、审批人）集中评审多个方案，使用分屏模式高效完成评审打分。

**布局**：顶部待评审方案列表 → 点击进入分屏模式（左50%方案预览 + 右50%评审表单）。

**组件清单**：

1. **PendingReviewTable** (`components/presales/PendingReviewTable.vue`) — 待评审方案列表，`ElTable`
2. **SplitPaneReview** (`components/presales/SplitPaneReview.vue`) — 分屏评审容器，使用CSS `flex` 实现50/50分屏
3. **ReviewScoreCard** — 复用 `@/components/solution/ReviewScoreMatrix.vue`
4. **SubmitReviewButton** — 提交评审按钮，带二次确认

**权限要求**：

| 角色 | 权限 | 说明 |
|------|------|------|
| 产品经理（104） | `cpq:presales:review` | 评审打分 |
| 销售经理（102） | `cpq:presales:review` | 评审打分 |
| 审批人（107） | `cpq:presales:review` | 评审打分 |

---

## 附录N：角色Dashboard详细设计（Role Dashboards）

### N.0 概述

CPQ系统需为每个角色提供专属的Dashboard首页。每个Dashboard遵循统一的布局模式：顶部KPI指标卡片行 + 中间图表网格区域 + 底部最近动态/活动Feed。

已有7个角色Dashboard在前端目录结构中定义但缺乏详细设计：ExecutiveDashboard、SalesManagerDashboard、PartnerDashboard、ProductManagerDashboard、PricingManagerDashboard、SupplyChainDashboard、OperationsDashboard（另外SalesDashboard、PresalesDashboard、ApprovalDashboard、AuditDashboard已在主文档§4.2中简要描述）。

### N.1 ExecutiveDashboard.vue（高管Dashboard）

**页面路径**：`cpq-portal/src/views/dashboard/ExecutiveDashboard.vue`

**KPI行**：总报价金额(本季度累计)、赢单率(百分比)、平均折扣率、审批通过率。每个KPI卡片使用 `ElStatistic` 组件 + 与上期环比变化箭头(↑绿色/↓红色)。

**图表网格**（2×2布局）：

1. **报价趋势折线图**：按月展示报价金额和数量的双Y轴折线图（ECharts），过去12个月
2. **区域销售地图**：中国地图热力图，各省份报价金额色阶（ECharts map）
3. **产品线收入构成**：饼图，各产品线的收入占比（ECharts pie + roseType）
4. **Top 10客户柱状图**：按报价金额排名的Top 10客户水平柱状图（ECharts bar horizontal）

**权限**：高层管理者（109）

### N.2 SalesManagerDashboard.vue（销售经理Dashboard）

**页面路径**：`cpq-portal/src/views/dashboard/SalesManagerDashboard.vue`

**KPI行**：团队报价总额、人均报价数、赢单率、审批超时数（红色告警）。

**图表**：

1. **个人业绩排名柱状图**：团队成员按报价金额排名的水平柱状图
2. **报价-赢单漏斗图**：报价数→已发送→客户确认→赢单的漏斗转化（ECharts funnel）
3. **折扣分布散点图**：各报价的折扣率 vs 利润率散点图（ECharts scatter），标注异常折扣（红色）

**权限**：销售经理（102）

### N.3 PartnerDashboard.vue（渠道伙伴Dashboard）

**页面路径**：`cpq-portal/src/views/dashboard/PartnerDashboard.vue`

**KPI行**：我的报价数、已通过数、待审批数、本月预估佣金。

**内容区**：
- 最近报价列表（ElTable，最近5条）
- 新产品推荐卡片（ElCard网格，显示新品图片+名称+简介）
- 培训完成进度条（ElProgress，显示CPQ培训完成百分比）

**权限**：渠道合作伙伴（103）

### N.4 ProductManagerDashboard.vue（产品经理Dashboard）

**页面路径**：`cpq-portal/src/views/dashboard/ProductManagerDashboard.vue`

**KPI行**：活跃产品数、EOL预警数（红色告警）、变更待审批数、竞品威胁等级（1-5级）。

**图表**：

1. **产品生命周期分布**：饼图，按生命周期阶段（引入/成长/成熟/衰退/EOL）分布
2. **ECN趋势图**：按月统计ECN变更数量的折线图
3. **竞品市场份额对比**：我方vs竞品市场份额柱状图（多个系列）

**权限**：产品经理（104）

### N.5 PricingManagerDashboard.vue（定价管理员Dashboard）

**页面路径**：`cpq-portal/src/views/dashboard/PricingManagerDashboard.vue`

**KPI行**：定价规则总数、本月更新数、折扣超限告警数、汇率波动率。

**图表**：

1. **价格带分布直方图**：各产品价格区间的分布直方图（ECharts histogram）
2. **折扣审批趋势**：折扣审批通过/驳回的月度趋势折线图
3. **汇率走势**：主要货币对（USD/CNY、EUR/CNY）汇率走势图

**权限**：定价管理员（105）

### N.6 SupplyChainDashboard.vue（供应链Dashboard）

**页面路径**：`cpq-portal/src/views/dashboard/SupplyChainDashboard.vue`

**KPI行**：ATP可用物料数、交期达标率、产能利用率(%)、替代物料命中率。

**图表**：

1. **库存水平趋势**：关键物料库存水平的折线图（多系列）
2. **交期分布直方图**：交期天数分布（ECharts bar），显示不同区间(0-7天/8-14天/15-30天/30天+)的订单数量
3. **产能负载热力图**：各工厂各生产线的产能负载热力图（ECharts heatmap）

**权限**：供应链计划员（106）

### N.7 OperationsDashboard.vue（销售运营Dashboard）

**页面路径**：`cpq-portal/src/views/dashboard/OperationsDashboard.vue`

**KPI行**：系统用户活跃数、数据迁移进度(百分比)、集成同步状态(正常/异常)、知识库更新数。

**图表**：

1. **用户活跃趋势**：日活跃用户(DAU)折线图
2. **同步成功率**：各集成系统(CRM/ERP/PLM)的同步成功率仪表盘（ECharts gauge × 3）
3. **迁移进度甘特图**：数据迁移各阶段的进度甘特图（ECharts custom 或使用 `ElProgress` 列表）

**权限**：销售运营（108）

---

## 附录O：集成管理页面详细设计（Integration Management）

### O.0 概述

集成管理模块面向销售运营（108）和系统管理员（111），提供CRM、ERP、PLM三大系统的连接配置、字段映射和同步监控功能。四个页面CrmConnector、ErpConnector、PlmConnector共享相同的布局模板，仅差异化的配置项和同步选项不同。

### O.1 CrmConnector.vue（CRM集成）

**页面路径**：`cpq-portal/src/views/integration/CrmConnector.vue`

**使用场景**：配置CRM（客户关系管理）系统的连接参数，建立CPQ与CRM的数据同步通道（客户信息、商机、联系人等同步到CPQ，报价数据同步回CRM）。

**布局**：

```
┌──────────────────────────┬────────────────────────────────────┐
│ 连接配置 (50%)            │ 同步状态面板 (50%)                   │
│                          │                                    │
│ ┌─ 连接配置表单 ────────┐ │ ┌─ 同步概览 ─────────────────────┐ │
│ │ CRM系统类型: [CRM...▼]│ │ │ 上次同步: 2026-06-05 08:00      │ │
│ │ API URL: [____]      │ │ │ 同步记录: 1,250条               │ │
│ │ 认证方式: [OAuth2...▼]│ │ │ 成功率: 98.5% ████████░░        │ │
│ │ Client ID: [____]    │ │ │ 下次同步: 2026-06-05 09:00      │ │
│ │ Client Secret: [****]│ │ │ 状态: 🟢 正常                   │ │
│ │ [测试连接] [保存]      │ │ └────────────────────────────────┘ │
│ └───────────────────────┘ │                                    │
│                          │ ┌─ 同步日志 ─────────────────────┐ │
│ ┌─ 字段映射 ────────────┐ │ │ 时间       │方向 │记录│状态    │ │
│ │ 源字段 ↔ 目标字段      │ │ │ 06-05 08:00│→CRM │1250│🟢成功 │ │
│ │ ┌──────────┬─────────┐│ │ │ 06-05 07:00│←CRM │850 │🟢成功 │ │
│ │ │客户名称   │↔ Name  ││ │ └────────────────────────────────┘ │
│ │ │联系电话   │↔ Phone ││ │                                    │
│ │ │行业       │↔ Ind   ││ │ [手动同步] [查看完整日志]           │
│ │ │ ...       │↔ ...   ││ │                                    │
│ │ │[+ 添加映射]         ││ │                                    │
│ │ └──────────┴─────────┘│ │                                    │
│ └───────────────────────┘ │                                    │
└──────────────────────────┴────────────────────────────────────┘
```

**组件清单**：

1. **ConnectionConfigForm** (`components/integration/ConnectionConfigForm.vue`)
   - 连接配置表单
   - 字段：系统类型（`ElSelect`：[纷享销客/Salesforce/Dynamics 365/自定义]）、API URL（`ElInput`）、认证方式（`ElSelect`：[OAuth2/API Key/Basic Auth]）、客户端凭证（`ElInput` + `ElInput` type="password"）

2. **FieldMappingGrid** (`components/integration/FieldMappingGrid.vue`)
   - 字段映射配置表，`ElTable` 可编辑
   - 每行：源字段(`ElSelect` 从CRM字段列表加载)、映射方向(`↔` 双向 / `→` 单向)、目标字段(`ElSelect` 从CPQ字段列表加载)
   - 行操作：添加(`+` 按钮)、删除(`×` 按钮)

3. **SyncStatusPanel** (`components/integration/SyncStatusPanel.vue`)
   - 同步状态面板，显示上次同步时间、同步记录数、成功率进度条、同步状态指示灯

4. **TestConnectionButton** — 测试连接按钮，调用 `POST /integration/crm/test` 返回连接状态和延迟

5. **ManualSyncButton** — 手动触发同步按钮，`ElButton` type="primary"

6. **SyncLogTable** (`components/integration/SyncLogTable.vue`)
   - 同步日志表格，`ElTable`
   - 列：同步时间、方向（`←` INBOUND / `→` OUTBOUND）、记录数、状态标签(`SyncStatusBadge`)、错误详情展开

**权限要求**：

| 角色 | 权限 | 说明 |
|------|------|------|
| 销售运营（108） | `cpq:integration:configure` | 配置连接 |
| 系统管理员（111） | `cpq:integration:configure` | 配置连接 |

### O.2 ErpConnector.vue（ERP集成）

**页面路径**：`cpq-portal/src/views/integration/ErpConnector.vue`

布局与CrmConnector相同，复用 `ConnectionConfigForm`、`FieldMappingGrid`、`SyncStatusPanel` 等组件。额外增加订单同步方向配置：

**OrderSyncStatus** (`components/integration/OrderSyncStatus.vue`)
- 订单同步方向指示器
- CPQ→ERP OUTBOUND：报价审批通过后自动创建ERP销售订单
- ERP→CPQ INBOUND：ERP订单状态回传CPQ（订单确认/发货/开票）
- 显示每个方向的最近同步状态和记录数

**权限要求**：销售运营（108）/ 系统管理员（111）

### O.3 PlmConnector.vue（PLM集成）

**页面路径**：`cpq-portal/src/views/integration/PlmConnector.vue`

布局同上。额外增加产品数据同步配置：

**ProductSyncConfig** (`components/integration/ProductSyncConfig.vue`)
- 产品数据同步选项checkboxes组：物料主数据、BOM结构、产品属性、技术文档、ECN变更、生命周期状态
- `ElCheckboxGroup` 渲染，每个选项带说明

**权限要求**：

| 角色 | 权限 | 说明 |
|------|------|------|
| 产品经理（104） | `cpq:integration:configure` | 配置PLM同步 |
| 系统管理员（111） | `cpq:integration:configure` | 配置PLM连接 |

### O.4 SyncLogViewer.vue（同步日志统一查看）

**页面路径**：`cpq-portal/src/views/integration/SyncLogViewer.vue`

**使用场景**：统一查看所有集成系统（CRM/ERP/PLM）的同步日志，按系统、方向、状态、时间筛选。

**布局**：顶部筛选栏 + 日志表格 + 分页。

**组件清单**：

1. **SyncLogFilter** (`components/integration/SyncLogFilter.vue`)
   - 筛选条件：系统（`ElSelect`：CRM/ERP/PLM/全部）、方向（`ElSelect`：INBOUND/OUTBOUND/全部）、状态（`ElSelect`：成功/失败/部分/全部）、时间范围（`ElDatePicker` range）

2. **SyncStatusBadge** (`components/integration/SyncStatusBadge.vue`)
   - 同步状态标签：SUCCESS=绿色(#0F974A) / FAILED=红色(#D93025) / PARTIAL=黄色(#F9AB00)

3. **ErrorDetailExpand** (`components/integration/ErrorDetailExpand.vue`)
   - 错误详情展开行，表格行点击展开显示完整错误堆栈和上下文信息

---

## 附录P：数据迁移页面详细设计（Data Migration）

### P.1 DataMigration.vue（数据迁移工具）

**页面路径**：`cpq-portal/src/views/migration/DataMigration.vue`

**使用场景**：销售运营（108）和系统管理员（111）使用三步向导将历史数据导入CPQ系统。支撑阶段二流程6"数据迁移"五阶段流程。

**三步向导布局**：

```
┌──────────────────────────────────────────────────────────────┐
│ 步骤条: ① 上传文件 → ② 字段映射 → ③ 执行导入                    │
├──────────────────────────────────────────────────────────────┤
│                                                              │
│ Step 1: 上传文件                                              │
│ ┌─ 选择导入类型 ────────────────────────────────────────────┐ │
│ │ ○ 产品数据  ○ 定价数据  ○ 客户数据  ● BOM数据  ○ 全量导入 │ │
│ └──────────────────────────────────────────────────────────┘ │
│ ┌─ 文件上传 ────────────────────────────────────────────────┐ │
│ │                                                           │ │
│ │         📁 拖拽文件到此处 或 点击上传                        │ │
│ │                                                           │ │
│ │      支持: .xlsx, .csv, .json (最大50MB)                   │ │
│ │      [选择文件]                                             │ │
│ └───────────────────────────────────────────────────────────┘ │
│                                                              │
│ [下一步: 字段映射 →]                                          │
└──────────────────────────────────────────────────────────────┘

Step 2: 字段映射配置 + 数据预览

┌─ 字段映射 ──────────────────────────────────────────────────┐
│ ┌──────────┬───┬────────────────┐                          │
│ │ 源字段     │ → │ 目标CPQ字段     │                          │
│ │ product_code│ → │ product_code  │ [默认值: ___]           │
│ │ pro_name   │ → │ product_name  │                         │
│ │ pro_price  │ → │ list_price    │                         │
│ │ [未映射]   │ → │ [请选择字段 ▼] │  [忽略此行]              │
│ └──────────┴───┴────────────────┘                          │
│                                                             │
└─────────────────────────────────────────────────────────────┘
┌─ 数据预览 (前10行) ─────────────────────────────────────────┐
│ ┌──────────────────────────────────────────────────────────┐│
│ │ # │ product_code│ product_name │ list_price│ status      ││
│ │ 1 │ PD785-DMR  │ 防爆对讲机    │ 4850.00  │  active     ││
│ │ 2 │ BD300      │ 数字对讲机    │ 980.00   │  active     ││
│ │ ...                                                      ││
│ └──────────────────────────────────────────────────────────┘│
└─────────────────────────────────────────────────────────────┘

Step 3: 执行导入 + 进度 + 结果报告

┌─ 校验结果 ──────────────────────────────────────────────────┐
│ ✅ 通过: 1,245行  ⚠ 警告: 23行  ❌ 错误: 5行               │
└─────────────────────────────────────────────────────────────┘
┌─ 导入进度 ──────────────────────────────────────────────────┐
│ ElProgress: ████████████████░░░░░░░░ 68%                    │
│ 已导入: 850/1250行  |  预计剩余: 2分钟                        │
└─────────────────────────────────────────────────────────────┘
┌─ 导入结果报告 ──────────────────────────────────────────────┐
│ ✅ 成功: 1,240行  ⚠ 跳过: 5行(重复)  ❌ 失败: 5行           │
│ [下载错误详情.xlsx] [下载完整报告.csv]                        │
└─────────────────────────────────────────────────────────────┘
```

**组件清单**：

1. **MigrationTypeSelector** (`components/migration/MigrationTypeSelector.vue`)
   - 导入类型选择，`ElRadioGroup`
   - 选项：产品数据、定价数据、客户数据、BOM数据、全量导入

2. **FileUploader** (`components/migration/FileUploader.vue`)
   - 文件上传拖拽区域，使用 `ElUpload` drag模式
   - 文件类型校验：`.xlsx`、`.csv`、`.json`
   - 文件大小限制：50MB
   - 拖拽区域：虚线边框 + 上传图标 + 提示文字
   - 文件选择后显示文件名+大小+删除按钮

3. **FieldMapper** (`components/migration/FieldMapper.vue`)
   - 字段映射配置组件
   - 每行：源字段（来自上传文件的列名，只读显示）+ 映射方向 `→` + 目标字段（`ElSelect` 从CPQ字段列表选择）+ 默认值输入框（选填）+ 忽略按钮
   - 自动匹配：根据字段名称相似度自动推荐映射（高亮绿色边框）

4. **DataPreview** (`components/migration/DataPreview.vue`)
   - 数据预览表格，`ElTable` 显示上传文件的前10行数据
   - 根据映射配置显示转换后的列名
   - 高亮显示有问题的数据行（格式错误、超出范围等）

5. **ValidationResult** (`components/migration/ValidationResult.vue`)
   - 校验结果面板，显示：通过行数（绿色badge）、警告行数（黄色badge）、错误行数（红色badge）
   - 点击badge展开查看具体问题列表

6. **ImportProgress** (`components/migration/ImportProgress.vue`)
   - 导入进度组件，`ElProgress` + 进度文字（已导入X/Y行 + 预计剩余时间）
   - 轮询 `GET /migration/tasks/{taskId}/progress` 更新进度

7. **ResultReport** (`components/migration/ResultReport.vue`)
   - 导入结果报告，显示：成功数、跳过数（含跳过原因）、失败数
   - 下载按钮：错误详情（.xlsx）、完整报告（.csv）

**数据流**：

```
POST /migration/tasks (创建迁移任务)
  → POST /migration/tasks/{id}/upload (上传文件)
  → GET /migration/tasks/{id}/fields (获取上传文件的列名)
  → POST /migration/tasks/{id}/mapping (保存字段映射)
  → POST /migration/tasks/{id}/validate (触发数据校验)
  → GET /migration/tasks/{id}/validation-result (获取校验结果)

Step 3:
  → POST /migration/tasks/{id}/execute (开始执行导入)
  → GET /migration/tasks/{id}/progress (轮询进度，每2秒)
  → GET /migration/tasks/{id}/report (获取最终结果报告)
```

**权限要求**：

| 角色 | 权限 | 说明 |
|------|------|------|
| 销售运营（108） | `cpq:migration:execute` | 执行数据迁移 |
| 系统管理员（111） | `cpq:migration:execute` | 执行数据迁移 |

---

## 附录Q：全局搜索组件详细设计（Multi-Modal Search）

### Q.1 MultiModalSearch.vue（多模态全局搜索）

**页面路径**：`cpq-portal/src/components/search/MultiModalSearch.vue`

**使用场景**：全局搜索弹窗，通过 `Cmd+K` / `Ctrl+K` 快捷键触发。用户输入关键词后，在全部CPQ业务域（产品、方案、报价、知识、竞品）中并发搜索并聚合展示结果。支持四种搜索模式。

**布局**：

```
┌──────────────────────────────────────────────────────────────┐
│ 半透明遮罩层                                                   │
│ ┌──────────────────────────────────────────────────────────┐ │
│ │  🔍 [请输入搜索关键词...                           ] [Esc] │ │
│ ├──────────────────────────────────────────────────────────┤ │
│ │ [全部] [产品(15)] [方案(3)] [报价(8)] [知识(12)] [竞品(2)]   │ │
│ ├──────────────────────────────────────────────────────────┤ │
│ │ ┌─ 产品 ────────────────────────────────────────────────┐│ │
│ │ │ 📦 PD785-DMR                  防爆数字对讲机(IP67)     ││ │
│ │ │    频段: 136-174MHz 功率: 5W  ¥4,850               →  ││ │
│ │ │ 📦 PD785-DMR-PRO              增强型防爆对讲机         ││ │
│ │ │    频段: 136-174MHz 功率: 5W  ¥5,950               →  ││ │
│ │ └───────────────────────────────────────────────────────┘│ │
│ │ ┌─ 方案 ────────────────────────────────────────────────┐│ │
│ │ │ 📊 矿山通信防爆方案 V2          售前: 张三 06-05    →  ││ │
│ │ └───────────────────────────────────────────────────────┘│ │
│ │ ┌─ 报价 ────────────────────────────────────────────────┐│ │
│ │ │ 📋 QTE-0500                    矿山通信方案 ¥4.85M  →  ││ │
│ │ └───────────────────────────────────────────────────────┘│ │
│ │                                                          │ │
│ │ ┌─ 最近搜索 ────────────────────────────────────────────┐│ │
│ │ │ PD785  ·  BD300  ·  矿山通信方案  ·  ATEX认证         ││ │
│ │ └───────────────────────────────────────────────────────┘│ │
│ └──────────────────────────────────────────────────────────┘ │
└──────────────────────────────────────────────────────────────┘
```

**四种搜索模式**：

| 模式 | 触发方式 | 搜索策略 | 示例 |
|------|---------|---------|------|
| 关键词搜索 | 输入普通文本 | 在所有实体名称/描述中模糊匹配 | "防爆对讲机" |
| 编码精确搜索 | 输入大写字母+数字格式 | 精确匹配产品编码/报价编号/ECN编号 | "PD785-DMR" |
| 全文搜索 | 输入长文本(>20字) | MySQL FULLTEXT或ES全文检索知识库文章 | "IP67防护等级产品详细技术参数" |
| 智能建议（预留AI） | 输入问句格式（以?结尾） | 预留P2 AI语义搜索接口 | "哪些产品支持ATEX防爆认证?" |

**组件清单**：

1. **SearchInput** (`components/search/SearchInput.vue`)
   - 搜索输入框，使用 `ElInput` + `prefix-icon` search图标
   - `autofocus` 自动聚焦
   - 防抖300ms后触发搜索请求
   - 支持键盘导航：↓↑选择结果项、Enter打开选中项、Esc关闭弹窗

2. **CategoryTabs** (`components/search/CategoryTabs.vue`)
   - 分类标签页，`ElTabs`
   - 每标签显示分类名称 + 结果计数badge
   - 切换到具体分类时仅显示该分类的结果

3. **SearchResultItem** (`components/search/SearchResultItem.vue`)
   - 搜索结果项，可点击跳转到对应实体详情页
   - 每项含：实体图标（📦/📊/📋/📖/⚔️）、标题（加粗，14px）、描述/副标题（12px灰色）、分类标签（`ElTag` size="small"）、跳转箭头(→)
   - 键盘选中项高亮：背景 `$--color-primary-light-9`(#D4E5FF)

4. **RecentSearches** (`components/search/RecentSearches.vue`)
   - 最近搜索列表，存储在 `localStorage`
   - 排列为行内标签：`ElTag` closable，点击标签填入搜索框

5. **HotKeywords** (`components/search/HotKeywords.vue`)
   - 热门搜索关键词，`ElTag` 列表
   - 数据来自 `GET /search/hot-keywords`

**快捷键**：`Cmd+K`(Mac) / `Ctrl+K`(Windows) 触发打开全局搜索弹窗。`Esc` 关闭弹窗。

**权限**：所有登录用户（基于RBAC），搜索结果按租户隔离（多租户过滤）。成本相关结果对低权限角色脱敏显示。

**数据流**：

```
GET /search/global?q={keyword}&category={category}&page={page}&size={size}
  → 后端并发查询所有业务域 → 聚合 → 返回统一搜索结果格式
  → 前端渲染搜索结果项列表
```

**代码生成计划**：

| 文件路径 | 技术要点 |
|---------|---------|
| `cpq-portal/src/components/search/MultiModalSearch.vue` | 主弹窗组件，`ElDialog` modal centered。`useMagicKeys` 或全局键盘事件监听 `Cmd+K` |
| `cpq-portal/src/components/search/SearchInput.vue` | `ElInput` + debounce + 键盘事件 |
| `cpq-portal/src/components/search/SearchResultItem.vue` | 结果项，`ElCard` hover |
| `cpq-portal/src/composables/useGlobalSearch.ts` | 搜索逻辑：`search()`, `results`, `loading`, `categories` |

---

## 附录R：系统设置页面详细设计（System Settings）

### R.1 SystemSettings.vue（系统设置主页）

**页面路径**：`cpq-portal/src/views/settings/SystemSettings.vue`

**使用场景**：系统管理员集中管理CPQ系统配置，包括ABAC策略、系统参数、租户配置、集成配置等。采用左侧菜单树+右侧设置面板的标准后台布局。

**布局**：

```
┌──────────┬───────────────────────────────────────────────────┐
│ 设置菜单树│ 设置面板                                           │
│ (200px)  │                                                   │
│          │ [设置项名称]                                        │
│ ElTree   │ ┌─ 设置表单/表格 ────────────────────────────────┐ │
│          │ │ (根据选中菜单项动态渲染对应设置组件)               │ │
│ ├ ABAC策略│ │                                                 │ │
│ ├ 系统配置│ │                                                 │ │
│ ├ 租户配置│ │                                                 │ │
│ ├ 集成配置│ │                                                 │ │
│ ├ 变更管理│ │                                                 │ │
│ ├ 数据迁移│ │                                                 │ │
│ ├ 审计日志│ │                                                 │ │
│ └ 系统参数│ │                                                 │ │
│          │ └────────────────────────────────────────────────┘ │
│          │ [保存设置] [重置]                                    │
└──────────┴───────────────────────────────────────────────────┘
```

**设置面板内容**：

- **ABAC策略管理**：`ElTable` CRUD表格操作 `cpq_abac_policy` 表，列：策略名称、资源类型、属性条件、成本可见级别、状态
- **系统配置**：`ElForm` key-value 表单编辑 `cpq_system_config` 表，每个配置项一行：键(只读) + 值(编辑) + 描述
- **租户配置**：`ElTable` 租户列表，每行：租户名称、状态、创建时间、管理员、操作(查看/编辑)
- **集成配置**：聚合展示CRM/ERP/PLM集成配置摘要卡片，点击跳转到对应集成页面

---

## 附录S：状态管理Pinia Stores详细定义

### S.0 概述

本附录定义CPQ前端门户的全部Pinia Store模块的完整结构，包括state、getters、actions签名和关键实现逻辑。Store文件统一放置在 `cpq-portal/src/stores/` 目录下。

### S.1 useConfiguratorStore（配置器状态）

**文件路径**：`cpq-portal/src/stores/configurator.ts`

```
State:
  configId: string | null          // 当前配置会话ID
  productId: string | null         // 当前配置的产品ID
  selections: Record<string, any>  // 已选属性集 {attributeId: optionId}
  optionStates: Map<string, OptionState>  // 各选项的可用状态(AVAILABLE/DISABLED/HIDDEN/RECOMMENDED/SELECTED)
  bomData: BomItem[]               // BOM数据列表
  atpData: AtpResult | null        // ATP交期数据
  isDirty: boolean                 // 是否有未保存的更改
  draftId: string | null           // 自动保存草稿ID
  conflictWarnings: ConstraintWarning[]  // 冲突警告列表

Getters:
  selectedOptions: computed        // 已选选项列表
  totalPrice: computed             // 配置总价（基于BOM汇总）
  isValid: computed                // 配置是否有效（无冲突）
  isComplete: computed             // 所有必选属性是否已选择

Actions:
  initConfig(productId): Promise   // 初始化配置会话 → POST /configure/init
  selectOption(attributeId, optionId): Promise  // 选择选项 → POST /configure/select → CSP求解 → 更新optionStates
  validateConfig(): Promise        // 校验配置 → POST /configure/validate
  saveDraft(): Promise             // 保存草稿 → POST /configure/save
  loadDraft(draftId): Promise      // 恢复草稿 → GET /configure/drafts/{id}
  refreshAtp(): Promise            // 刷新ATP → GET /atpctp/check
  resetConfig(): void              // 重置配置
```

### S.2 useQuotingStore（报价单状态）

**文件路径**：`cpq-portal/src/stores/quoting.ts`

```
State:
  quoteId: string | null           // 当前报价单ID
  items: QuoteLineItem[]           // 报价行项目列表
  pricingResult: PricingResult | null  // 定价计算结果
  discounts: Discount[]            // 已应用折扣列表
  template: QuoteTemplate | null   // 选择的报价模板

Getters:
  subtotal: computed               // 小计
  totalDiscount: computed          // 总折扣金额
  netPrice: computed               // 最终净价
  itemCount: computed              // 行项目数量

Actions:
  createQuote(configId): Promise   // 从配置创建报价 → POST /quoting/create
  addLineItem(item): Promise       // 添加行项目 → POST /quoting/{id}/items
  removeLineItem(itemId): void     // 移除行项目（前端乐观更新）
  applyDiscount(discount): Promise // 应用折扣 → POST /pricing/apply-discount
  removeDiscount(discountId): void
  calculatePrice(): Promise        // 重新计算价格 → POST /pricing/calculate
  generatePdf(): Promise           // 生成PDF → POST /quoting/{id}/generate-pdf
  submitForApproval(): Promise     // 提交审批 → POST /approval/submit
```

### S.3 useApprovalStore（审批状态）

**文件路径**：`cpq-portal/src/stores/approval.ts`

```
State:
  pendingList: ApprovalItem[]      // 待审批列表
  processedList: ApprovalItem[]    // 已审批列表
  initiatedList: ApprovalItem[]    // 我发起的审批列表
  currentApproval: ApprovalDetail | null  // 当前查看的审批详情
  approvalChain: ApprovalNode[]    // 审批链
  history: ApprovalHistoryItem[]   // 审批历史

Actions:
  fetchPending(page, filters): Promise     // GET /approval/pending
  fetchProcessed(page, filters): Promise   // GET /approval/processed
  fetchInitiated(page, filters): Promise   // GET /approval/initiated
  fetchDetail(approvalId): Promise         // GET /approval/{id}/detail
  submitApproval(approvalId, action, comment): Promise  // POST /approval/{id}/action
  processAction(approvalId, action): Promise  // 审批操作（通过/驳回/转交）
  fetchHistory(page, filters): Promise     // GET /approval/history
```

### S.4 useSolutionStore（方案管理状态）

**文件路径**：`cpq-portal/src/stores/solution.ts`

```
State:
  solutionId: string | null
  content: string                   // 方案内容（Markdown/HTML）
  collaborators: Collaborator[]     // 协同用户列表
  comments: Comment[]              // 批注列表
  versions: Version[]              // 版本历史

Actions:
  initSolution(solutionId): Promise  // 初始化方案 + WebSocket连接
  syncContent(content): void         // Yjs同步更新（由Tiptap onChange触发）
  saveSolution(): Promise            // POST /solution/{id}/save
  addComment(comment): Promise       // POST /solution/{id}/comments
  resolveComment(commentId): void
  submitReview(): Promise            // POST /solution/{id}/submit-review
  loadVersion(versionId): Promise    // GET /solution/{id}/versions/{versionId}
```

### S.5 useCompetitiveStore（竞品状态）

**文件路径**：`cpq-portal/src/stores/competitive.ts`

```
State:
  competitors: Competitor[]          // 竞品库列表
  comparisonResults: ComparisonResult[]  // 对比结果

Actions:
  fetchCompetitors(filters): Promise  // GET /competitive/competitors
  addCompetitor(data): Promise        // POST /competitive/competitors
  updateCompetitor(id, data): Promise // PUT /competitive/competitors/{id}
  compare(ourProducts, competitorProducts): Promise  // POST /competitive/compare
  getRecommendation(competitorId, scenario): Promise  // GET /competitive/recommendation
```

### S.6 useKnowledgeStore（知识库状态）

**文件路径**：`cpq-portal/src/stores/knowledge.ts`

```
State:
  articles: Article[]                // 产品知识文章列表
  scripts: SalesScript[]             // 销售话术列表
  caseStudies: CaseStudy[]           // 成功案例列表
  trainingMaterials: TrainingMaterial[]  // 培训资料列表
  categories: Category[]             // 分类树

Actions:
  searchArticles(query, filters): Promise  // GET /knowledge/articles/search
  searchScripts(scenario): Promise         // GET /knowledge/scripts?scenario={}
  getScriptByScenario(scenario): Array     // 本地getter，按场景过滤话术
  getCaseStudies(filters): Promise         // GET /knowledge/case-studies
  getTrainingMaterials(level): Promise     // GET /knowledge/training?level={}
```

### S.7 useMigrationStore（数据迁移状态）

**文件路径**：`cpq-portal/src/stores/migration.ts`

```
State:
  taskId: string | null
  file: File | null
  mappingConfig: FieldMapping[]
  validationResult: ValidationResult | null
  progress: ImportProgress | null
  report: MigrationReport | null

Actions:
  createTask(type): Promise          // POST /migration/tasks
  uploadFile(file): Promise          // POST /migration/tasks/{id}/upload
  configMapping(mappings): Promise   // POST /migration/tasks/{id}/mapping
  validateData(): Promise            // POST /migration/tasks/{id}/validate
  executeImport(): Promise           // POST /migration/tasks/{id}/execute
  getProgress(): Promise             // GET /migration/tasks/{id}/progress (轮询)
  getReport(): Promise               // GET /migration/tasks/{id}/report
```

### S.8 useEcnStore（ECN变更状态）

**文件路径**：`cpq-portal/src/stores/ecn.ts`

```
State:
  ecnId: string | null
  changeItems: ChangeItem[]
  impactAnalysis: ImpactAnalysis | null
  approvalChain: ApprovalNode[]

Actions:
  createEcn(data): Promise           // POST /ecn/create
  addChangeItem(item): Promise       // POST /ecn/{id}/items
  updateChangeItem(itemId, data): Promise  // PUT /ecn/{id}/items/{itemId}
  analyzeImpact(): Promise           // POST /ecn/{id}/analyze
  submitForApproval(): Promise       // POST /ecn/{id}/submit
```

---

## 附录T：API模块TypeScript定义

### T.0 概述

本附录定义所有CPQ前端API模块的TypeScript类型定义和函数签名。每个API模块对应 `cpq-portal/src/api/` 下的一个文件，使用 `request.ts` (Axios实例) 发送HTTP请求。

### T.1 API模块函数签名

**api/guided.ts** (向导式销售API)

```
import request from '@/utils/request'

export function getQuestions(productFamilyId: string): Promise<GuidedQuestion[]>
export function startGuidedSession(params: { productFamilyId: string, scenarioType: string }): Promise<GuideSession>
export function submitAnswer(configId: string, answer: { questionId: string, type: QuestionType, value: any }): Promise<void>
export function getRecommendations(configId: string): Promise<RecommendedProduct[]>
export function confirmConfiguration(configId: string, productId: string): Promise<ConfigSnapshot>
export function getGuidedStatus(configId: string): Promise<{ status: GuidedState, progress: number }>
```

**api/solution.ts** (方案管理API)

```
import request from '@/utils/request'

export function getSolutions(params: PaginationParams & FilterParams): Promise<PaginatedResponse<SolutionSummary>>
export function getSolution(id: string): Promise<SolutionDetail>
export function createSolution(data: CreateSolutionParams): Promise<SolutionDetail>
export function updateSolution(id: string, data: UpdateSolutionParams): Promise<void>
export function submitForReview(id: string): Promise<void>
export function compareSolutions(ids: string[]): Promise<ComparisonData>
export function exportSolution(id: string, format: 'pdf' | 'docx'): Promise<Blob>
export function getCollaborators(id: string): Promise<Collaborator[]>
export function getSolutionVersions(id: string): Promise<Version[]>
export function restoreVersion(solutionId: string, versionId: string): Promise<void>
```

**api/competitive.ts** (竞品对标API)

```
import request from '@/utils/request'

export function getCompetitors(params: PaginationParams & { keyword?: string, industry?: string }): Promise<PaginatedResponse<Competitor>>
export function getCompetitor(id: string): Promise<CompetitorDetail>
export function createCompetitor(data: CreateCompetitorParams): Promise<Competitor>
export function updateCompetitor(id: string, data: UpdateCompetitorParams): Promise<void>
export function deleteCompetitor(id: string): Promise<void>
export function compareProducts(params: { ourProductIds: string[], competitorProductIds: string[] }): Promise<ComparisonResult>
export function getRecommendation(params: { competitorId: string, scenario: string }): Promise<RecommendationData>
```

**api/knowledge.ts** (知识库API)

```
import request from '@/utils/request'

export function searchArticles(params: { query?: string, category?: string, tags?: string[], page: number, size: number }): Promise<PaginatedResponse<Article>>
export function getArticle(id: string): Promise<ArticleDetail>
export function getCategories(): Promise<Category[]>
export function getScripts(params: { scenario?: string, productId?: string }): Promise<SalesScript[]>
export function getScript(scenario: string): Promise<SalesScript>
export function getCaseStudies(params: { industry?: string, page: number, size: number }): Promise<PaginatedResponse<CaseStudy>>
export function getCaseStudy(id: string): Promise<CaseStudyDetail>
export function getTrainingMaterials(params: { level?: TrainingLevel, roleId?: number }): Promise<TrainingMaterial[]>
export function getHotKeywords(): Promise<string[]>
```

**api/ecn.ts** (ECN变更管理API)

```
import request from '@/utils/request'

export function getChangeOrders(params: PaginationParams & { status?: string, type?: string }): Promise<PaginatedResponse<EcnSummary>>
export function getEcnDetail(id: string): Promise<EcnDetail>
export function createChangeOrder(data: CreateEcnParams): Promise<EcnDetail>
export function addChangeItem(ecnId: string, data: ChangeItemParams): Promise<void>
export function submitForAnalysis(ecnId: string): Promise<void>
export function getImpactAnalysis(ecnId: string): Promise<ImpactAnalysis>
export function approveEcn(ecnId: string, data: { action: ApprovalAction, comment: string }): Promise<void>
```

**api/pricing-management.ts** (定价管理API)

```
import request from '@/utils/request'

export function getPriceBooks(params: PaginationParams & { currency?: string }): Promise<PaginatedResponse<PriceBook>>
export function getPriceBook(id: string): Promise<PriceBookDetail>
export function createPriceBook(data: CreatePriceBookParams): Promise<void>
export function updatePriceBook(id: string, data: UpdatePriceBookParams): Promise<void>
export function getPriceEntries(priceBookId: string): Promise<PriceEntry[]>
export function addPriceEntry(priceBookId: string, data: PriceEntryParams): Promise<void>
export function updatePriceEntry(id: string, data: PriceEntryParams): Promise<void>
export function getPriceRules(params: { type?: string }): Promise<PriceRule[]>
export function createPriceRule(data: PriceRuleParams): Promise<void>
export function updatePriceRule(id: string, data: PriceRuleParams): Promise<void>
export function getVolumeTiers(productId: string): Promise<VolumeTier[]>
export function createVolumeTier(productId: string, tiers: VolumeTier[]): Promise<void>
export function getCurrencyRates(): Promise<CurrencyRate[]>
export function updateCurrencyRate(id: string, rate: number): Promise<void>
export function getDiscountApprovals(params: PaginationParams): Promise<PaginatedResponse<DiscountApprovalItem>>
export function approveDiscount(id: string, action: ApprovalAction, comment: string): Promise<void>
```

**api/approval-management.ts** (审批管理API)

```
import request from '@/utils/request'

export function getPendingApprovals(params: PaginationParams): Promise<PaginatedResponse<ApprovalItem>>
export function getProcessedApprovals(params: PaginationParams): Promise<PaginatedResponse<ApprovalItem>>
export function getInitiatedApprovals(params: PaginationParams): Promise<PaginatedResponse<ApprovalItem>>
export function getApprovalDetail(id: string): Promise<ApprovalDetail>
export function processApproval(id: string, data: { action: ApprovalAction, comment?: string, reassignTo?: string }): Promise<void>
export function getApprovalHistory(params: PaginationParams & { dateRange?: [string, string], status?: string, type?: string }): Promise<PaginatedResponse<ApprovalHistoryItem>>
export function getApprovalAnalytics(params: { period?: 'day'|'week'|'month', dateRange?: [string, string] }): Promise<ApprovalAnalytics>
export function getApprovalChain(entityType: string, entityId: string): Promise<ApprovalNode[]>
```

**api/presales.ts** (售前协同API)

```
import request from '@/utils/request'

export function getTasks(params: { status?: TaskStatus, assigneeId?: string }): Promise<Task[]>
export function assignTask(taskId: string, assigneeId: string): Promise<void>
export function updateTaskStatus(taskId: string, status: TaskStatus): Promise<void>
export function getCollaborationSession(solutionId: string): Promise<CollabSession>
```

**api/integration.ts** (集成管理API)

```
import request from '@/utils/request'

export function getConnectionConfigs(): Promise<ConnectionConfig[]>
export function getConnectionConfig(system: string): Promise<ConnectionConfig>
export function saveConnectionConfig(system: string, config: ConnectionConfigParams): Promise<void>
export function testConnection(system: string): Promise<TestConnectionResult>
export function triggerSync(system: string, direction?: SyncDirection): Promise<void>
export function getSyncLogs(params: { system?: string, direction?: SyncDirection, status?: string, page: number, size: number }): Promise<PaginatedResponse<SyncLog>>
export function getFieldMappings(system: string): Promise<FieldMapping[]>
export function saveFieldMappings(system: string, mappings: FieldMapping[]): Promise<void>
```

**api/migration.ts** (数据迁移API)

```
import request from '@/utils/request'

export function createMigrationTask(type: MigrationType): Promise<{ taskId: string }>
export function uploadFile(taskId: string, file: File): Promise<void>
export function getSourceFields(taskId: string): Promise<string[]>
export function saveFieldMapping(taskId: string, mappings: FieldMapping[]): Promise<void>
export function validateData(taskId: string): Promise<void>
export function getValidationResult(taskId: string): Promise<ValidationResult>
export function executeImport(taskId: string): Promise<void>
export function getImportProgress(taskId: string): Promise<ImportProgress>
export function getMigrationReport(taskId: string): Promise<MigrationReport>
```

**api/dashboard.ts** (Dashboard数据API)

```
import request from '@/utils/request'

export function getExecutiveMetrics(): Promise<ExecutiveMetrics>
export function getSalesManagerMetrics(): Promise<SalesManagerMetrics>
export function getPartnerMetrics(): Promise<PartnerMetrics>
export function getProductMetrics(): Promise<ProductMetrics>
export function getPricingMetrics(): Promise<PricingMetrics>
export function getSupplyChainMetrics(): Promise<SupplyChainMetrics>
export function getOperationsMetrics(): Promise<OperationsMetrics>
export function getDashboardCharts(roleType: string, period: string): Promise<DashboardCharts>
```

**api/search.ts** (全局搜索API)

```
import request from '@/utils/request'

export function globalSearch(params: { q: string, category?: string, page?: number, size?: number }): Promise<GlobalSearchResult>
export function getHotKeywords(): Promise<string[]>
export function getRecentSearches(): Promise<string[]>
export function clearRecentSearches(): Promise<void>
```

---

## 附录U：路由配置补充

### U.0 概述

本附录补充现有路由配置中缺失的模块路由定义。所有路由使用 `PortalLayout.vue` 作为外层布局，路由文件放置在 `cpq-portal/src/router/modules/` 目录下。路由按模块独立拆分文件，通过角色(meta.roles)和权限字符串(meta.perm)双重控制访问。

### U.1 竞品对标路由 (`router/modules/competitive.ts`)

```typescript
export default {
  path: '/competitive',
  component: () => import('@/layouts/PortalLayout.vue'),
  redirect: '/competitive/list',
  meta: { title: '竞品对标', icon: 'swords', roles: ['cpq_sales','cpq_presales','cpq_operations','cpq_manager','cpq_executive'] },
  children: [
    {
      path: 'list',
      name: 'CompetitorList',
      component: () => import('@/views/competitive/CompetitorList.vue'),
      meta: { title: '竞品库', perm: 'cpq:competitive:list' }
    },
    {
      path: 'compare',
      name: 'ComparisonView',
      component: () => import('@/views/competitive/ComparisonView.vue'),
      meta: { title: '参数对比', perm: 'cpq:competitive:compare' }
    },
    {
      path: 'recommendation',
      name: 'RecommendationView',
      component: () => import('@/views/competitive/RecommendationView.vue'),
      meta: { title: '推荐策略', perm: 'cpq:competitive:recommend' }
    }
  ]
}
```

### U.2 方案管理路由 (`router/modules/solution.ts`)

```typescript
export default {
  path: '/solution',
  component: () => import('@/layouts/PortalLayout.vue'),
  redirect: '/solution/list',
  meta: { title: '方案管理', icon: 'documentation', roles: ['cpq_presales','cpq_manager'] },
  children: [
    {
      path: 'list',
      name: 'SolutionList',
      component: () => import('@/views/solution/SolutionList.vue'),
      meta: { title: '方案列表', perm: 'cpq:solution:list' }
    },
    {
      path: 'editor/:id?',
      name: 'SolutionEditor',
      component: () => import('@/views/solution/SolutionEditor.vue'),
      meta: { title: '方案编辑器', perm: 'cpq:solution:edit', hidden: true }
    },
    {
      path: 'compare',
      name: 'SolutionCompare',
      component: () => import('@/views/solution/SolutionCompare.vue'),
      meta: { title: '方案对比', perm: 'cpq:solution:compare' }
    },
    {
      path: 'review',
      name: 'SolutionReview',
      component: () => import('@/views/solution/SolutionReview.vue'),
      meta: { title: '方案评审', perm: 'cpq:solution:review' }
    }
  ]
}
```

### U.3 知识库路由 (`router/modules/knowledge.ts`)

```typescript
export default {
  path: '/knowledge',
  component: () => import('@/layouts/PortalLayout.vue'),
  redirect: '/knowledge/products',
  meta: { title: '知识库', icon: 'reading', roles: ['cpq_all'] },
  children: [
    {
      path: 'products',
      name: 'ProductKnowledge',
      component: () => import('@/views/knowledge/ProductKnowledge.vue'),
      meta: { title: '产品知识', perm: 'cpq:knowledge:view' }
    },
    {
      path: 'scripts',
      name: 'SalesScripts',
      component: () => import('@/views/knowledge/SalesScripts.vue'),
      meta: { title: '销售话术', perm: 'cpq:knowledge:scripts' }
    },
    {
      path: 'cases',
      name: 'CaseLibrary',
      component: () => import('@/views/knowledge/CaseLibrary.vue'),
      meta: { title: '成功案例', perm: 'cpq:knowledge:cases' }
    },
    {
      path: 'training',
      name: 'TrainingCenter',
      component: () => import('@/views/knowledge/TrainingCenter.vue'),
      meta: { title: '培训中心', perm: 'cpq:knowledge:training' }
    }
  ]
}
```

### U.4 ECN变更管理路由 (`router/modules/ecn.ts`)

```typescript
export default {
  path: '/ecn',
  component: () => import('@/layouts/PortalLayout.vue'),
  redirect: '/ecn/list',
  meta: { title: '变更管理', icon: 'switch', roles: ['cpq_product','cpq_manager','cpq_approver','cpq_admin'] },
  children: [
    {
      path: 'list',
      name: 'ChangeManagement',
      component: () => import('@/views/ecn/ChangeManagement.vue'),
      meta: { title: '变更列表', perm: 'cpq:ecn:list' }
    },
    {
      path: 'impact/:ecnId',
      name: 'ImpactAnalysis',
      component: () => import('@/views/ecn/ImpactAnalysis.vue'),
      meta: { title: '影响分析', perm: 'cpq:ecn:analyze', hidden: true }
    },
    {
      path: 'approval/:ecnId',
      name: 'ChangeApproval',
      component: () => import('@/views/ecn/ChangeApproval.vue'),
      meta: { title: '变更审批', perm: 'cpq:ecn:approve', hidden: true }
    }
  ]
}
```

### U.5 定价管理路由 (`router/modules/pricing-management.ts`)

```typescript
export default {
  path: '/pricing-management',
  component: () => import('@/layouts/PortalLayout.vue'),
  redirect: '/pricing-management/books',
  meta: { title: '定价管理', icon: 'money', roles: ['cpq_pricing','cpq_admin'] },
  children: [
    {
      path: 'books',
      name: 'PriceBookList',
      component: () => import('@/views/pricing/PriceBookList.vue'),
      meta: { title: '价格手册', perm: 'cpq:pricing:books' }
    },
    {
      path: 'rules',
      name: 'PriceRuleConfig',
      component: () => import('@/views/pricing/PriceRuleConfig.vue'),
      meta: { title: '定价规则', perm: 'cpq:pricing:rules' }
    },
    {
      path: 'volume-tiers',
      name: 'VolumeTierConfig',
      component: () => import('@/views/pricing/VolumeTierConfig.vue'),
      meta: { title: '阶梯定价', perm: 'cpq:pricing:tiers' }
    },
    {
      path: 'discounts',
      name: 'DiscountApproval',
      component: () => import('@/views/pricing/DiscountApproval.vue'),
      meta: { title: '折扣审批', perm: 'cpq:pricing:discounts' }
    },
    {
      path: 'currency',
      name: 'CurrencyConfig',
      component: () => import('@/views/pricing/CurrencyConfig.vue'),
      meta: { title: '汇率管理', perm: 'cpq:pricing:currency' }
    }
  ]
}
```

### U.6 审批管理路由 (`router/modules/approval-management.ts`)

```typescript
export default {
  path: '/approval-management',
  component: () => import('@/layouts/PortalLayout.vue'),
  redirect: '/approval-management/pending',
  meta: { title: '审批中心', icon: 'checked', roles: ['cpq_approver','cpq_manager','cpq_executive','cpq_audit'] },
  children: [
    {
      path: 'pending',
      name: 'PendingApproval',
      component: () => import('@/views/approval/PendingApproval.vue'),
      meta: { title: '待我审批', perm: 'cpq:approval:process' }
    },
    {
      path: 'detail/:id',
      name: 'ApprovalDetail',
      component: () => import('@/views/approval/ApprovalDetail.vue'),
      meta: { title: '审批详情', perm: 'cpq:approval:view', hidden: true }
    },
    {
      path: 'history',
      name: 'ApprovalHistory',
      component: () => import('@/views/approval/ApprovalHistory.vue'),
      meta: { title: '审批历史', perm: 'cpq:approval:history' }
    },
    {
      path: 'analytics',
      name: 'ApprovalAnalytics',
      component: () => import('@/views/approval/ApprovalAnalytics.vue'),
      meta: { title: '效率看板', perm: 'cpq:approval:analytics' }
    }
  ]
}
```

### U.7 售前协同路由 (`router/modules/presales.ts`)

```typescript
export default {
  path: '/presales',
  component: () => import('@/layouts/PortalLayout.vue'),
  redirect: '/presales/board',
  meta: { title: '售前协同', icon: 'connection', roles: ['cpq_presales','cpq_manager','cpq_sales'] },
  children: [
    {
      path: 'board',
      name: 'TaskBoard',
      component: () => import('@/views/presales/TaskBoard.vue'),
      meta: { title: '任务看板', perm: 'cpq:presales:board' }
    },
    {
      path: 'collab/:solutionId',
      name: 'CollabEditor',
      component: () => import('@/views/presales/CollabEditor.vue'),
      meta: { title: '协同编辑', perm: 'cpq:presales:collab', hidden: true }
    },
    {
      path: 'review',
      name: 'ReviewWorkbench',
      component: () => import('@/views/presales/ReviewWorkbench.vue'),
      meta: { title: '评审工作台', perm: 'cpq:presales:review' }
    }
  ]
}
```

### U.8 集成管理路由 (`router/modules/integration.ts`)

```typescript
export default {
  path: '/integration',
  component: () => import('@/layouts/PortalLayout.vue'),
  redirect: '/integration/crm',
  meta: { title: '系统集成', icon: 'link', roles: ['cpq_operations','cpq_admin'] },
  children: [
    {
      path: 'crm',
      name: 'CrmConnector',
      component: () => import('@/views/integration/CrmConnector.vue'),
      meta: { title: 'CRM连接器', perm: 'cpq:integration:configure' }
    },
    {
      path: 'erp',
      name: 'ErpConnector',
      component: () => import('@/views/integration/ErpConnector.vue'),
      meta: { title: 'ERP连接器', perm: 'cpq:integration:configure' }
    },
    {
      path: 'plm',
      name: 'PlmConnector',
      component: () => import('@/views/integration/PlmConnector.vue'),
      meta: { title: 'PLM连接器', perm: 'cpq:integration:configure' }
    },
    {
      path: 'logs',
      name: 'SyncLogViewer',
      component: () => import('@/views/integration/SyncLogViewer.vue'),
      meta: { title: '同步日志', perm: 'cpq:integration:logs' }
    }
  ]
}
```

### U.9 数据迁移路由 (`router/modules/migration.ts`)

```typescript
export default {
  path: '/migration',
  component: () => import('@/layouts/PortalLayout.vue'),
  meta: { title: '数据迁移', icon: 'upload', roles: ['cpq_operations','cpq_admin'] },
  children: [
    {
      path: '',
      name: 'DataMigration',
      component: () => import('@/views/migration/DataMigration.vue'),
      meta: { title: '数据迁移', perm: 'cpq:migration:execute' }
    }
  ]
}
```

### U.10 Dashboard路由补充 (`router/modules/dashboard.ts`)

在现有dashboard路由中补充各角色专属Dashboard：

```typescript
// 补充到 router/modules/dashboard.ts 已有路由中
{
  path: 'executive',
  name: 'ExecutiveDashboard',
  component: () => import('@/views/dashboard/ExecutiveDashboard.vue'),
  meta: { title: '高管看板', perm: 'cpq:dashboard:executive', roles: ['cpq_executive'] }
},
{
  path: 'sales-manager',
  name: 'SalesManagerDashboard',
  component: () => import('@/views/dashboard/SalesManagerDashboard.vue'),
  meta: { title: '销售管理看板', perm: 'cpq:dashboard:manager', roles: ['cpq_manager'] }
},
{
  path: 'product-manager',
  name: 'ProductManagerDashboard',
  component: () => import('@/views/dashboard/ProductManagerDashboard.vue'),
  meta: { title: '产品看板', perm: 'cpq:dashboard:product', roles: ['cpq_product'] }
},
{
  path: 'pricing-manager',
  name: 'PricingManagerDashboard',
  component: () => import('@/views/dashboard/PricingManagerDashboard.vue'),
  meta: { title: '定价看板', perm: 'cpq:dashboard:pricing', roles: ['cpq_pricing'] }
},
{
  path: 'supply-chain',
  name: 'SupplyChainDashboard',
  component: () => import('@/views/dashboard/SupplyChainDashboard.vue'),
  meta: { title: '供应链看板', perm: 'cpq:dashboard:supplychain', roles: ['cpq_supplychain'] }
},
{
  path: 'operations',
  name: 'OperationsDashboard',
  component: () => import('@/views/dashboard/OperationsDashboard.vue'),
  meta: { title: '运营看板', perm: 'cpq:dashboard:operations', roles: ['cpq_operations'] }
}
```

**路由命名约定总结**：
- 模块路径使用kebab-case（如 `/competitive`、`/pricing-management`）
- 路由name使用PascalCase（如 `CompetitorList`、`PriceBookList`）
- `meta.perm` 使用冒号分隔的权限字符串格式（如 `cpq:competitive:list`）
- `meta.roles` 用于菜单级别的粗粒度角色过滤（数组格式）
- 详情/编辑/审批页面设置 `hidden: true` 不显示在侧边栏菜单中
- 所有组件使用动态 `import()` 实现路由级别的Code Splitting

---

## 附录V：UI组件库扩展规范

### V.0 概述

本附录定义CPQ业务组件库中所有通用组件和业务专用组件的完整规范，包括Props、Slots、Events和行为描述。这些组件是对Element Plus的增强和CPQ业务场景的封装，放置在 `cpq-portal/src/components/` 目录下。

### V.1 CpqCard.vue（CPQ卡片容器增强版）

增强版卡片容器，在普通 `ElCard` 基础上增加四种状态变体。

```
Props:
  loading: boolean = false        // 加载中 → 显示骨架屏
  error: Error | null = null      // 错误状态 → 显示错误信息+重试按钮
  empty: boolean = false          // 空数据 → 显示空状态插画
  emptyText: string = ''          // 空状态文字
  emptyActionText: string = ''    // 空状态操作按钮文字
  retryText: string = '重试'      // 错误重试按钮文字

Slots:
  default: 正常内容
  loading: 自定义加载内容（默认骨架屏）
  error: 自定义错误内容
  empty: 自定义空状态内容

Events:
  retry: 点击重试按钮时触发
  empty-action: 点击空状态操作按钮时触发
```

**实现**：使用 `v-if` / `v-else-if` 链：error → empty → loading → default。Loading状态使用 `ElSkeleton` 组件。Empty状态使用 `ElEmpty` + 自定义插画。

### V.2 StatusBadge.vue（状态徽章扩展版）

扩展支持CPQ全部业务状态类型的状态徽章组件。

```
Props:
  status: string                  // 状态值
  type: 'quote'|'ecn'|'approval'|'migration'|'sync'|'default'  // 状态类型域
  size: 'small'|'default'|'large'

支持的状态类型映射：
  quote: DRAFT(灰)/PENDING(橙)/APPROVED(绿)/REJECTED(红)/SENT(蓝)/EXPIRED(灰)/WON(绿)
  ecn: DRAFT(灰)/PENDING_ANALYSIS(蓝)/ANALYZING(蓝)/PENDING_APPROVAL(橙)/APPROVED(绿)/REJECTED(红)/IMPLEMENTED(绿)
  approval: PENDING(橙)/APPROVED(绿)/REJECTED(红)/REASSIGNED(紫)/ESCALATED(红)
  migration: VALIDATING(蓝)/VALIDATED(绿)/VALIDATION_FAILED(红)/IMPORTING(蓝)/COMPLETED(绿)/FAILED(红)
  sync: SUCCESS(绿)/FAILED(红)/PARTIAL(黄)/SYNCING(蓝)
```

### V.3 DataTable.vue（高级数据表格）

基于 `ElTable` 的服务端分页、排序、筛选封装组件。

```
Props:
  columns: ColumnConfig[]         // 列配置（复用ElTable column props）
  data: any[]                     // 表格数据
  loading: boolean
  pagination: PaginationConfig    // 分页配置 { current, pageSize, total }
  rowKey: string = 'id'
  selection: boolean = false      // 是否显示选择列

Slots:
  default: 自定义列插槽（具名插槽，slot名 = 列的slotName）
  empty: 空数据状态
  toolbar: 表格上方工具栏区域

Events:
  page-change: ({ page, pageSize }) → 分页变化
  sort-change: ({ prop, order }) → 排序变化
  filter-change: (filters) → 筛选变化
  selection-change: (selectedRows) → 选择变化
```

### V.4 EmptyState.vue（空状态组件）

可配置的空状态组件，用于所有列表页面的空数据展示。

```
Props:
  illustration: string = 'default'  // 插画类型: default/search/quote/solution/approval
  title: string = '暂无数据'
  description: string = ''
  actionText: string = ''
  actionType: 'primary'|'default'|'success' = 'primary'
  actionIcon: string = ''

Slots:
  default: 自定义内容（覆盖默认布局）
  action: 自定义操作按钮区域

Events:
  action: 点击操作按钮
```

**各页面空状态配置**：报价单列表→"暂无报价单，开始创建第一份报价" actionText="新建报价"；方案列表→"暂无方案，从模板快速开始" actionText="从模板新建"；待审批→"暂无待审批项，干得漂亮!" actionText="查看已审批"；竞品库→"竞品库为空，开始添加竞品信息" actionText="添加竞品"；知识库→"产品知识库建设中" actionText="浏览产品目录"；搜索无结果→"未找到匹配结果" actionText="放宽筛选条件" secondaryAction="提交需求给售前"。

### V.5 LoadingSkeleton.vue（骨架屏加载）

Shimmer效果的骨架屏占位组件。

```
Props:
  variant: 'rect'|'circle'|'text'|'table'|'card'  // 骨架形状
  rows: number = 3                 // 文本/表格行数
  width: string = '100%'
  height: string = '16px'
  animated: boolean = true         // 是否Shimmer动画

Slots:
  default: 自定义骨架形状
```

**实现**：使用CSS `@keyframes shimmer` 实现从左到右的光泽移动动画。背景使用线性渐变 `linear-gradient(90deg, #f0f0f0 25%, #e0e0e0 50%, #f0f0f0 75%)`，`background-size: 200% 100%`，动画 `shimmer 1.5s infinite`。

### V.6 ErrorBoundary.vue（错误边界）

Vue全局错误边界组件，捕获子组件树中的未处理异常并显示友好的错误界面。

```
Props:
  fallbackText: string = '页面加载出错'
  showError: boolean = false       // 是否显示原始错误信息（开发环境）

Slots:
  default: 正常子组件内容
  fallback: 自定义错误回退内容

Events:
  retry: 点击重试时触发（会重新挂载子组件）

State:
  hasError: boolean
  error: Error | null
```

**实现**：使用 Vue 3 `onErrorCaptured` 生命周期钩子捕获子组件错误。

### V.7 AtpIndicator.vue（ATP状态指示器）

```
Props:
  status: 'available'|'constrained'|'unavailable'|'calculating'
  leadTimeDays: number | null      // 交期天数
  moq: number | null               // 起订量
  showDetail: boolean = false      // 是否显示详细交期分解

Slots:
  detail: 自定义详细交期分解内容

样式:
  available: color $--color-accent(#0F974A), dot + "预估: 14-21天"
  constrained: color $--color-warning(#F9AB00), dot + "交期紧张: 28-35天"
  unavailable: color $--color-danger(#D93025), dot + "暂不可交付"
  calculating: color $--color-info(#1A73E8), dot + 脉冲动画
```

### V.8 DeliveryTimeline.vue（CTP交期时间线）

```
Props:
  stages: DeliveryStage[]          // 六阶段时间数据
  // 阶段: 物料齐套 → 生产 → 质检 → 包装 → 物流 → 缓冲

Slots:
  stage: 自定义阶段渲染

样式:
  水平时间线，使用ElSteps或自定义CSS
  每阶段显示: 阶段名称 + 预计天数 + 开始~结束日期
  阶段状态: completed(绿)/current(蓝+脉冲)/pending(灰)
```

### V.9 PriceBreakdown.vue（价格瀑布分解）

```
Props:
  listPrice: number                // 牌价
  discounts: DiscountBreakdown[]   // 折扣列表 [{name,amount,type}]
  netPrice: number                 // 净价
  currency: string = 'CNY'

样式:
  瀑布流式价格卡片
  每行: 描述(左) + 金额(右)
  牌价行: 灰色文字
  折扣行: 绿色(#0F974A)负号金额
  净价行: 加粗黑色文字 + 底部分隔线
  最终报价行: 蓝色(#1A73E8)加粗
```

### V.10 DiscountSlider.vue（折扣交互滑动条）

```
Props:
  modelValue: number               // 当前折扣值 (0-100)
  maxAllowed: number               // 最大允许折扣 (%)
  step: number = 1
  showInput: boolean = true        // 是否显示数字输入框

Events:
  update:modelValue

样式:
  ElSlider 自定义样式
  滑块左侧(≤最大允许): 蓝色(#1A73E8)
  滑块右侧(>最大允许): 红色(#D93025) + 警告图标
  超出最大允许时显示 "超出最大允许折扣" 警告提示
  红线标记最大允许位置
```

### V.11 ApprovalNode.vue（审批节点可视化）

```
Props:
  node: ApprovalNode               // 节点数据: { stepName, assignee, status, comment, timestamp }
  current: boolean                 // 是否是当前等待节点
  last: boolean                    // 是否是最后一个节点

样式:
  4种形状 × 7种颜色:
  形状: 圆(发起/结束) / 矩形(审批) / 菱形(条件) / 六边形(会签)
  颜色: 未开始(灰) / 进行中(蓝+脉冲) / 通过(绿) / 驳回(红) / 转交(紫) / 超时(橙) / 跳过(灰虚线)
  节点间连接线: 实线(已完成) / 虚线(未完成)
```

### V.12 ScenarioNavigator.vue（场景导航面包屑）

```
Props:
  scenarios: Scenario[]            // [{id, name, icon, description}]
  activeId: string

Events:
  select: (scenarioId)

样式:
  水平排列的场景选择卡片
  每个场景: 图标 + 名称 + 简短描述
  激活态: $--color-primary 边框 + 浅蓝背景(#E8F0FE)
```

### V.13 ConfigDiff.vue（配置差异对比）

```
Props:
  before: ConfigData               // 变更前配置
  after: ConfigData                // 变更后配置
  changes: ChangeRecord[]          // 变更记录列表 [{field, before, after, type}]

样式:
  左右并排卡片对比
  左侧: 变更前(标题"旧")，右侧: 变更后(标题"新")
  变更字段行:
    新增字段: 绿色背景 + "+ 新增" 标签
    删除字段: 红色背景 + 删除线
    修改字段: 黄色背景 + 箭头动画(旧→新)
```

### V.14 TemplateSelector.vue（报价模板选择器）

```
Props:
  templates: QuoteTemplate[]       // [{id, name, thumbnail, description}]
  modelValue: string | null

Events:
  update:modelValue

样式:
  网格布局，每模板: 缩略图预览 + 模板名称
  选中态: 蓝色边框 + ✓ 图标覆盖
  hover: 阴影增强 + 缩放(scale 1.02)
```

### V.15 ErrorState组件补充

除了 `EmptyState.vue` 和 `LoadingSkeleton.vue`，以下特殊状态组件需全局可用：

**NetworkError.vue**：网络断开提示横幅
- 全局顶部固定横幅：红色背景 + "网络连接已断开" + 自动重连倒计时
- 监听 `navigator.onLine` 变化

**PermissionDenied.vue**：权限不足页面
- 居中卡片：锁图标 + "您没有访问此页面的权限" + 返回首页按钮
- 用于路由守卫拦截后渲染

**NotFound.vue**：404页面
- 居中布局：404大号数字 + "页面不存在" + 返回首页按钮

**ServerError.vue**：500错误页面
- 居中布局：错误图标 + "服务器内部错误" + 联系管理员 + 刷新重试按钮

---

## §12 缺失页面详细设计 — 配置与方案模块

> 以下补充 cross_trace_v2_final.md 审计发现的全部缺失页面/组件设计，按模块组织。每个页面包含：场景/布局/组件清单/数据流/UI设计系统/权限/代码生成计划。

### 12.1 GuidedSelling.vue — 向导式销售（已实施，实际实现）

**实际文件路径**: `cpq-portal/src/views/configure/GuidedSelling.vue`（非 configurator 目录）  
**路由**: `/configure-guided/:modelId`（带产品ID参数，复用 PortalLayout）  
**状态**: **已实施完成**，2026-06-13 经 Playwright 测试验证通过

**实施版本 vs 设计版本差异**：

| 维度 | 设计版本（§12.1原始） | 实施版本 |
|------|---------------------|---------|
| 路由 | `POST /configure/guided/init` + `/next` + `/complete` | 统一用 `POST /cpq/configure/guide`（单端点，携带累计 selections） |
| 状态机 | WELCOME → QUESTIONING → ANALYZING → RECOMMENDING → COMPLETED（5状态） | QUESTIONING → NARROWING → RECOMMENDING → CONFIGURING → COMPLETED（5状态枚举+1前端直接转换） |
| 步骤条 | 5步 ElSteps | 无 ElSteps，每个状态对应独立卡片布局（v-if 切换） |
| 问题渲染 | QuestionCard 根据 type 动态渲染（SINGLE_CHOICE/MULTI_CHOICE/NUMERIC_INPUT/TEXT_INPUT） | 统一使用 el-radio-group 单选按钮组 |
| 推荐展示 | RecommendPanel 推荐卡片网格 | 内置推荐卡片（产品编码+名称+已选属性列表） |
| CONFIGURING | 无此状态（ANALYZING 跳过直接到 RECOMMENDING） | **新增**：展示所有已选属性确认卡片，用户确认后调用 complete() |

**实际六阶段流程**：

```
① QUESTIONING（选择属性）
  └─ 展示当前属性+选项按钮组，选择一个值后自动调用 POST /cpq/configure/guide
     └─ 单选项→QUESTIONING 继续 ｜ ≤3选项→NARROWING ｜ >3选项或无属性→RECOMMENDING ｜ 全属性已选→COMPLETED

② NARROWING（智能筛选，被前端映射为QUESTIONING）
  └─ 与QUESTIONING共用同一卡片模板

③ RECOMMENDING（查看推荐结果）
  └─ 展示推荐产品卡片（产品编码/名称+所有已选属性摘要）→ [进入配置确认] → ④
     └─ 关键：点击"进入配置确认"时前端直接设置 state=CONFIGURING，**不调用** guide API
        原因：后端 guidedSelling() 从不返回 CONFIGURING 状态

④ CONFIGURING（确认所有已选属性）
  └─ 卡片列出产品编码+名称+所有已选属性及其值 → [上一步回RECOMMENDING] / [完成配置并生成报价]
     └─ CONFIGURING→RECOMMENDING 也是前端直接转换，不调用API

⑤ COMPLETED（配置完成）
  └─ 显示配置摘要、验证结果、价格汇总 → [重新配置] / [查看完整配置]
     └─ [重新配置] → initWizard(modelId) 原地重新初始化（不跳路由）
     └─ [查看完整配置] → /configure-review/:modelId（ConfigurationReview.vue）
```

**数据流**（实际）：
```
产品搜索 → /configure-guided/:modelId
  → initWizard() → store.initModel() → GET /cpq/configure/model/{id}
  → loadGuideStep() → POST /cpq/configure/guide?modelId= （携带空 selections{}）
  → 用户选择选项 → store.selectOption() → loadGuideStep()（携带累计selections）
  → ...循环直到进入 RECOMMENDING...
  → 点击"进入配置确认" → 前端直接 state=CONFIGURING（不调API）
  → 点击"完成配置并生成报价" → completeGuide() → store.complete() → POST /cpq/configure/complete
  → state=COMPLETED
```

**健壮性措施**（已实施）：
- 15秒安全超时机制：防止 API 调用永不 resolve/reject 导致 loading 永久显示
- `v-if="wizardLoading"` + `v-else` 模式：loading 时显示"取消等待"按钮
- `wizardError` 状态：API 失败时显示错误卡片+重试/返回按钮
- `state` 空值兜底：guideStep.state 为 null 时默认设为 'QUESTIONING'
- 未知 state 兜底：任意未知 state 显示警告卡片+返回/重试按钮
- `onUnmounted` 清理定时器：防止组件卸载后泄露

**权限**: 同原设计（销售代表/售前工程师/渠道合作伙伴）

### 12.2 SolutionEditor.vue — 方案协同编辑器（完整版）

**文件路径**: `cpq-portal/src/views/solution/SolutionEditor.vue`  
**场景**: 售前工程师在线编辑方案文档，支持多人实时协同编辑+评审批注。对应阶段二§3.4四区布局。  
**布局**: 四区布局(Flexbox row)。左侧：大纲导航(ElTree章节/标题，宽度220px，sticky定位)。中央：富文本编辑区(Tiptap Editor flex-1，最小宽度600px)。右侧上：协同光标列表(在线用户头像+8色标识，240px)。右侧下：批注面板(CommentThread评论链，240px)。  
**技术栈**: Tiptap(富文本编辑器) + Yjs(CRDT协同数据) + y-websocket(WebSocket同步) + 8色协同光标(y-cursor-plugin)  
**组件清单**: OutlineTree(可拖拽排序的大纲树)、TiptapEditor(含CPQ自定义扩展：产品插入/BOM行内表/报价摘要/AT交期时间线)、CollaboratorAvatars(在线用户头像环，hover显示用户名+颜色)、CommentThread(批注/回复/解决)、VersionTimeline(ElTimeline版本历史)、SaveIndicator(自动保存状态标签)  
**数据流**: WebSocket连接(ws://backend/ws/solution/{solutionId}) → Yjs Awareness同步在线用户 → Yjs Document同步文档内容(OT-free CRDT) → 每2秒自动保存 → Tiptap渲染 → 批注数据独立Yjs类型  
**CPQ Tiptap扩展**: ProductInsert(node — 内嵌产品卡片含图片+参数表)、BomTable(node — 可折叠BOM树形表)、QuoteSummary(node — 报价摘要含金额)、DeliveryTimeline(node — CTP交期时间线)  
**UI设计系统**: 编辑器区域白色背景 `$--bg-color-container`；大纲树选中项左侧 `$--color-primary` 3px边线；协同光标8色(红橙黄绿青蓝紫粉)；批注面板卡片化(每个批注一个Card含头像+时间+内容)  
**权限**: 售前工程师(101)、产品经理(104)  
**代码生成计划**:
- `src/views/solution/SolutionEditor.vue` — 主页面(四区布局)
- `src/components/solution/OutlineTree.vue` — 可拖拽大纲
- `src/components/solution/TiptapEditor.vue` — 编辑器封装
- `src/components/solution/CollaboratorAvatars.vue` — 在线用户
- `src/components/solution/CommentThread.vue` — 批注组件
- `src/components/solution/VersionTimeline.vue` — 版本历史
- `src/composables/useCollaboration.ts` — Yjs+WebSocket逻辑
- `src/extensions/tiptap/` — CPQ自定义Tiptap扩展

### 12.3 SolutionCompare.vue — 方案对比

**文件路径**: `cpq-portal/src/views/solution/SolutionCompare.vue`  
**场景**: 对比2-4个方案的优劣，辅助客户/销售决策。  
**布局**: 顶部：方案选择器(ElSelect multi-select 2-4个方案) + 对比按钮。中央上半：五维雷达图(ECharts Radar: 成本/交期/性能/兼容性/服务)。中央下半：成本瀑布图(ECharts Waterfall: 逐项成本分解)。底部：差异对比表(ElTable，列=参数名/方案A/方案B/...，差异行黄色背景高亮)  
**组件**: SolutionSelector(多选下拉+已选标签)、RadarChartWidget(五维雷达)、WaterfallChartWidget(成本瀑布)、DiffTable(参数差异表)  
**数据流**: 选择方案 → `POST /solution/compare`(solutionIds数组) → 返回对比结果JSON → 渲染三图  
**权限**: 销售经理(102)、售前工程师(101)  
**代码**: `src/views/solution/SolutionCompare.vue` + `src/api/solution.ts:compareSolutions()`

### 12.4 SolutionReview.vue — 方案评审工作台

**文件路径**: `cpq-portal/src/views/solution/SolutionReview.vue`  
**场景**: 专家评审方案，提交多维度评分和意见。  
**布局**: 左右分屏(Grid 6:4)。左：方案内容预览(iframe/html渲染方案文档)。右：评审表单(ElForm — 多维度ElRate评分 [技术可行性/成本合理性/交期可实现性/竞争力/风险] ×5 + ElInput textarea评审意见 + ElRadioGroup通过/驳回/需修改)  
**组件**: SolutionPreview(内容渲染)、ReviewScoreMatrix(ElRate×5)、CommentInput(评审意见)、ApprovalActions(通过/驳回按钮组)  
**权限**: 产品经理(104)、销售经理(102)、审批人(107)

---

## §13 缺失页面详细设计 — 竞品对标模块（3页面）

### 13.1 CompetitorList.vue — 竞品库管理

**文件路径**: `cpq-portal/src/views/competitive/CompetitorList.vue`  
**场景**: 销售运营管理竞品信息库。  
**布局**: 标准CRUD页。顶：搜索栏(ElForm inline: 竞品名称输入+行业Select + 市场地位Select + 搜索/重置/新增按钮)。中：表格(ElTable — 竞品名称/编码/网站(链接)/行业/市场地位标签/产品数/操作[编辑/查看产品/删除])。分页  
**组件**: CompetitorFormDialog(新增/编辑弹窗: 名称/编码/网站/行业/描述ElInput textarea/SWOT优势劣势各ElInput textarea/市场地位Select)  
**UI**: 市场地位列彩色标签(LEADER=红色/CHALLENGER=橙色/NICHE=蓝色/EMERGING=绿色)  
**权限**: 销售运营(108)、系统管理员(111)  
**代码**: `src/views/competitive/CompetitorList.vue` + `src/api/competitive.ts:getCompetitors/createCompetitor/deleteCompetitor`

### 13.2 ComparisonView.vue — 参数对比

**文件路径**: `cpq-portal/src/views/competitive/ComparisonView.vue`  
**场景**: 选择我方产品和竞品产品，逐项参数对比+赢率分析。  
**布局**: 顶部：产品选择区(左侧el-select我方产品[remote search]，右侧el-select竞品产品[multi-select remote])。中央：参数对比表(ElTable — 第一列参数名固定列，后续动态列[我方/竞品A/竞品B/...]，差异行黄色背景)。底部双栏：左雷达图(ECharts) + 右推荐策略卡片。常驻顶部条：赢率估算(大号数字 + 趋势箭头)  
**权限**: 销售代表(100)、售前工程师(101)、销售运营(108)

### 13.3 RecommendationView.vue — 推荐策略

**文件路径**: `cpq-portal/src/views/competitive/RecommendationView.vue`  
**场景**: 查看针对特定竞品的推荐应对方略和关键话术。  
**布局**: 顶部：场景选择器(ElSelect下拉)。中央：策略卡片(带颜色编码的ElCard: ATTACK=红色左边框/DEFEND=蓝色/AVOID=黄色/OBSERVE=绿色)。底部：关键话术列表(ElCollapse手风琴展开每条话术) + 支撑证据链接列表  
**权限**: 销售代表(100)、售前工程师(101)

---

## §14 缺失页面详细设计 — 知识库模块（4页面）

### 14.1 ProductKnowledge.vue — 产品知识库

**文件路径**: `cpq-portal/src/views/knowledge/ProductKnowledge.vue`  
**场景**: 销售/售前浏览产品知识文章。  
**布局**: 左侧：分类树(ElTree，数据源knowledge_category表，宽度240px)。右侧上：搜索栏(ElInput+搜索按钮) + 热门标签(ElTag动态标签云)。右侧下：文章列表(ElTable或卡片列表Grid，每项含标题/摘要/标签/阅读量/发布时间/阅读按钮)。点击打开文章详情抽屉(ElDrawer width=60%全屏阅读模式)  
**全文搜索**: 调用MySQL FULLTEXT或ES接口。**标签筛选**: 点击tag过滤列表  
**权限**: 所有角色(100-111)，销售运营(108)可新增/编辑文章

### 14.2 SalesScripts.vue — 销售话术

**文件路径**: `cpq-portal/src/views/knowledge/SalesScripts.vue`  
**场景**: 按销售场景浏览话术模板。  
**布局**: 顶部：场景Tabs(COLD_CALL/MEETING/OBJECTION_HANDLING/CLOSING/UPSELL 5个tab)。中央：话术卡片列表(ElRow+ElCol响应式Grid，每卡:场景名+关联产品名+话术要点摘要+使用次数)。右侧固定面板: 成功率统计(该场景话术成功率柱状图)  
**组件**: ScriptCard(悬浮展开异议应对)、SuccessRateChart(成功率)  
**权限**: 销售代表(100)、售前工程师(101)、渠道伙伴(103)

### 14.3 CaseLibrary.vue — 案例库

**文件路径**: `cpq-portal/src/views/knowledge/CaseLibrary.vue`  
**场景**: 浏览成功案例。  
**布局**: 响应式卡片网格(ElRow gutter=20，xs=1/sm=2/md=3/lg=4列)。每卡片(ElCard): 客户名+行业标签+挑战描述摘要+方案亮点+关键KPI大号数字  
**组件**: CaseCard(悬浮显示详细指标)、CaseDetailDialog(ElDialog全屏: 背景→挑战→方案→结果→KPI图表)  
**权限**: 所有角色

### 14.4 TrainingCenter.vue — 培训中心

**文件路径**: `cpq-portal/src/views/knowledge/TrainingCenter.vue`  
**场景**: 按角色和技能等级浏览培训资料。  
**布局**: 顶部：技能等级Tabs(初/中/高级)。中央：资料卡片网格(VIDEO带播放图标/PDF带文件图标/SLIDES/QUIZ/WEBINAR，每卡含时长/完成人数)。右侧面板：我的学习进度(ElProgress列表+已完成资料列表)  
**角色过滤**: 根据当前用户角色匹配 `required_role_ids` JSON字段  
**权限**: 所有角色(100-111)

---

## §15 缺失页面详细设计 — 定价管理模块（5页面）

### 15.1 PriceBookList.vue — 价格手册管理

**文件路径**: `cpq-portal/src/views/pricing/PriceBookList.vue`  
**场景**: 定价管理员管理价格手册及条目。  
**布局**: 标准CRUD。顶：搜索(手册名称/币种/状态) + 新增按钮。中：ElTable(名称/编码/币种/有效期/状态标签/操作)。点击展开嵌套条目  
**行展开**: expand-row嵌套第二个ElTable(条目:产品编码/名称/牌价/成本价/有效期)。支持内联新增条目  
**组件**: PriceBookFormDialog(名称/编码/币种/日期)、PriceBookEntryDialog(产品搜索+价格字段)  
**权限**: 定价管理员(105)、系统管理员(111)

### 15.2 PriceRuleConfig.vue — 定价规则配置

**文件路径**: `cpq-portal/src/views/pricing/PriceRuleConfig.vue`  
**场景**: 配置定价规则(DISCOUNT折扣/MARKUP加价/OVERRIDE覆盖)。  
**布局**: 顶：规则类型Tabs。中：规则列表(ElTable:优先级/名称/类型/条件摘要/动作摘要/状态开关/编辑删除)。右侧展开规则预览面板(显示规则效果模拟)  
**组件**: RuleConditionBuilder(可视化JSON编辑: IF字段/操作符/值添加行)、RuleActionSelector(THEN动作选择)、PriorityDragSort(拖拽排序列)  
**权限**: 定价管理员(105)

### 15.3 VolumeTierConfig.vue — 阶梯定价

**文件路径**: `cpq-portal/src/views/pricing/VolumeTierConfig.vue`  
**场景**: 配置特定产品的阶梯定价。  
**布局**: 顶部：产品/价格条目选择器(ElSelect remote)。中央：阶梯表(ElTable可内联编辑: 数量从/数量到/单价/折扣%，带+添加行/-删除行)。底部：阶梯图表(ECharts阶梯折线图，X轴=数量 Y轴=单价)  
**权限**: 定价管理员(105)

### 15.4 DiscountApproval.vue — 折扣审批

**文件路径**: `cpq-portal/src/views/pricing/DiscountApproval.vue`  
**场景**: 查看/处理超限折扣审批申请。  
**布局**: 顶：筛选(日期/状态/申请人)。表格(ElTable: 申请单号/申请人/客户/产品/申请折扣%/最大允许%/差额%/状态/操作)。**折扣对比条**: `ElProgress` 申请折扣(红色) vs 最大允许(绿色)  
**组件**: DiscountBar(折扣百分比可视化对比)、BulkApprove(批量通过按钮)  
**权限**: 定价管理员(105)、审批人(107)、销售经理(102)

### 15.5 CurrencyConfig.vue — 汇率配置

**文件路径**: `cpq-portal/src/views/pricing/CurrencyConfig.vue`  
**场景**: 多币种汇率管理。  
**布局**: 表格(货币对/汇率/生效日期/操作) + 新增弹窗(源币种/目标币种/汇率数字/日期)。底部：汇率走势折线图(ECharts)  
**权限**: 定价管理员(105)、系统管理员(111)

---

## §16 缺失页面详细设计 — 审批管理模块（4页面）

### 16.1 PendingApproval.vue — 待审批列表

**文件路径**: `cpq-portal/src/views/approval/PendingApproval.vue`  
**场景**: 审批人查看待审批项。  
**布局**: 顶：三Tab(待我审批/我已审批/我发起的)。表格(ElTable: 类型[报价/方案/ECN标签]+实体编号+申请人+金额+提交时间+当前步骤+操作)。**操作列**: 审批(通过绿/驳回红按钮)、详情查看链接  
**组件**: ApprovalActionButtons(通过/驳回/转交/升级四按钮)、BatchApprove(批量操作栏)  
**权限**: 审批人(107)、高层(109)、外部审计(110只读)

### 16.2 ApprovalDetail.vue — 审批详情

**文件路径**: `cpq-portal/src/views/approval/ApprovalDetail.vue`  
**场景**: 查看审批详情+被审批实体+审批链+历史。  
**布局**: 左右分屏(6:4)。左：被审批实体详情(动态组件:报价详情/方案预览/ECN详情，根据entity_type切换)。右：审批时间线(ElTimeline vertical，每节点含审批人+头像+动作标签+意见+时间)  
**审批链**: ElSteps(vertical)显示当前步骤  
**权限**: 审批相关角色

### 16.3 ApprovalHistory.vue — 审批历史

**文件路径**: `cpq-portal/src/views/approval/ApprovalHistory.vue`  
**场景**: 查询历史审批记录。  
**布局**: 顶：高级搜索(日期范围/状态/类型/申请人多条件)。底：表格(同待审批+结果+耗时) + 导出按钮  
**权限**: 审批人(107)、销售运营(108)、外部审计(110)

### 16.4 ApprovalAnalytics.vue — 审批分析Dashboard

**文件路径**: `cpq-portal/src/views/approval/ApprovalAnalytics.vue`  
**场景**: 审批效率分析看板。  
**布局**: 网格Dashboard(3×2 Grid)。图表: 审批量趋势(ECharts折线图)、平均审批时长(柱状图)、审批通过率(Gauge仪表盘)、超时审批清单(表格)、审批人工作量分布(饼图)、月对比趋势  
**权限**: 销售运营(108)、高层(109)

---

## §17 缺失页面详细设计 — 售前协同模块（3页面）

### 17.1 TaskBoard.vue — 任务看板

**文件路径**: `cpq-portal/src/views/presales/TaskBoard.vue`  
**场景**: 售前任务Kanban管理。  
**布局**: 四列看板(Grid 4列等宽): 待接单→处理中→待评审→已完成。每列可滚动，包含TaskCard(客户名/方案名/优先级彩色条/截止时间/负责人)。卡片支持拖拽(HTML5 Drag API或vue-draggable)变更状态  
**组件**: KanbanColumn(可drop)、TaskCard(可drag+优先级色条:高红/中橙/低灰)、QuickAction(接单/转派/催办)  
**权限**: 售前工程师(101)、销售经理(102)、销售代表(100只读)

### 17.2 CollabEditor.vue — 协同编辑

**文件路径**: `cpq-portal/src/views/presales/CollabEditor.vue`  
**场景**: 售前实时协同编辑方案文档。  
**布局**: 三栏。左：协同用户列表(在线头像+颜色+聊天消息SSE)。中：Tiptap编辑器。右：批注+版本历史  
**组件**: CollabUserList(含在线状态点)、ChatPanel(SSE实时消息)、TiptapEditor、CommentPanel、VersionHistory  
**权限**: 售前工程师(101)、销售代表(100仅查看)

### 17.3 ReviewWorkbench.vue — 评审工作台

**文件路径**: `cpq-portal/src/views/presales/ReviewWorkbench.vue`  
**场景**: 专家评审待评审方案。  
**布局**: 顶：待评审方案列表(ElTable)。点击进入分屏：左方案预览+右评审表单(多维度评分+意见+通过/驳回)  
**权限**: 产品经理(104)、销售经理(102)、审批人(107)

---

## §18 缺失页面详细设计 — ECN变更管理模块（3页面）

### 18.1 ChangeManagement.vue — 变更管理主页

**文件路径**: `cpq-portal/src/views/ecn/ChangeManagement.vue`  
**场景**: 产品经理管理ECN变更单列表。  
**布局**: 标准CRUD。顶：搜索(ECN编号/状态/类型/日期)+新建变更按钮。表格(ECN编号/标题/类型标签[紧急=红色/常规=蓝色/策略=紫色]/状态标签/优先级/发起人/提交时间/操作)  
**组件**: EcnCreateDialog(表单:标题/类型Select/原因textarea/优先级/有效日期/附件上传ElUpload)、StatusBadge、PriorityTag  
**权限**: 产品经理(104)、系统管理员(111)

### 18.2 ImpactAnalysis.vue — 五级传播影响分析

**文件路径**: `cpq-portal/src/views/ecn/ImpactAnalysis.vue`  
**场景**: 可视化ECN五级传播链影响分析。  
**布局**: 顶部：ECN摘要卡片(编号/标题/类型/状态/发起人)。中央：传播树图(ECharts Tree — 从变更项逐层传播:物料→BOM→配置→报价→审批，5级节点不同颜色)。右侧面板：影响清单(ElTable — 影响等级/实体/描述/在途报价数)  
**颜色**: 影响等级CRITICAL=红色节点、HIGH=橙色、MEDIUM=黄色、LOW=蓝色  
**权限**: 产品经理(104)、销售经理(102)、审批人(107)

### 18.3 ChangeApproval.vue — ECN审批

**文件路径**: `cpq-portal/src/views/ecn/ChangeApproval.vue`  
**场景**: ECN审批流程处理。  
**布局**: 左：ECN详情+变更项diff对比(old→new JSON对比表)。右：审批链ElSteps+审批表单(意见textarea+通过/驳回/请求修改ElRadioGroup)  
**权限**: 审批人(107)、产品经理(104)

---

## §19 缺失页面详细设计 — 集成与迁移模块（5页面）

### 19.1 CrmConnector.vue / ErpConnector.vue / PlmConnector.vue

**文件路径**: `cpq-portal/src/views/integration/CrmConnector.vue`（同模板创建Erp/Plm）  
**场景**: 配置和管理外部系统集成连接。  
**布局**: 左右分屏(5:5)。左：连接配置表单(API URL/认证方式Select/凭证/额外Headers JSON Editor)。右：同步状态面板(上次同步时间/同步记录数/成功率进度条+)  
**组件**: ConnectionConfigForm(通用配置表单)、FieldMappingGrid(源字段↔目标字段配对Select)、SyncStatusPanel(含TestConnection按钮+ManualSync按钮+SyncLogTable)  
**权限**: 销售运营(108)、产品经理(104 PLM)、系统管理员(111)

### 19.2 SyncLogViewer.vue — 同步日志

**文件路径**: `cpq-portal/src/views/integration/SyncLogViewer.vue`  
**场景**: 统一查看所有集成同步日志。  
**布局**: 顶：筛选(集成系统Select/方向/状态/时间范围)。表格(系统/方向标签/状态彩色标签/总数/成功/失败/时间/错误详情展开行)  
**权限**: 销售运营(108)、系统管理员(111)

### 19.3 DataMigration.vue — 数据迁移

**文件路径**: `cpq-portal/src/views/migration/DataMigration.vue`  
**场景**: 三步数据导入迁移向导。  
**布局**: Step1: 选择导入类型(ElRadio:产品/定价/客户/BOM/全量) + 拖拽上传(ElUpload drag)。Step2: 字段映射配置(源字段↔目标字段配对Select)+数据预览(ElTable前10行)。Step3: 校验结果(错误/警告计数badge)+执行导入(ElProgress百分比)+结果报告(成功/失败/跳过统计+错误详情下载ElLink)  
**组件**: MigrationTypeSelector(radio)、FileUploader(drag drop+文件类型/大小校验)、FieldMapper(配对Select动态行)、DataPreview(前10行表格)、ValidationResult(错误/警告计数)、ImportProgress(百分比进度条)、ResultReport(统计卡片)  
**权限**: 销售运营(108)、系统管理员(111)

---

## §20 缺失组件详细设计 — Dashboard与通用组件（9+10组件）

### 20.1 7个角色Dashboard

**ExecutiveDashboard.vue**(高管): KPI行(总报价金额/赢单率/平均折扣/审批通过率) + 图表Grid(报价月趋势折线图/区域销售地图/产品线收入饼图/Top10客户柱状图)

**SalesManagerDashboard.vue**(销售经理): KPI(团队报价总额/人均报价数/赢单率) + 个人业绩排名柱状图 + 报价-赢单漏斗图 + 折扣分布散点图

**PartnerDashboard.vue**(渠道): KPI(我的报价数/已通过/待审批/本月佣金) + 最近报价列表 + 新产品推荐 + 培训进度

**ProductManagerDashboard.vue**(产品经理): KPI(活跃产品数/EOL预警/待审批ECN) + 产品生命周期饼图 + ECN趋势图

**PricingManagerDashboard.vue**(定价): KPI(规则总数/本月更新/折扣超限告警) + 价格带柱状图 + 折扣审批趋势

**SupplyChainDashboard.vue**(供应链): KPI(ATP可用率/交期达标率/产能利用率) + 库存趋势 + 交期分布 + 产能负载热力图

**OperationsDashboard.vue**(运营): KPI(活跃用户/数据迁移进度/同步成功率) + 用户活跃趋势 + 迁移进度甘特图

所有Dashboard通用实现: `composables/useDashboard.ts`(统一的KPI+chart数据加载)、`components/dashboard/KpiCard.vue`(KPI指标卡片: 图标+数字+趋势箭头)、`components/dashboard/ChartContainer.vue`(ECharts容器封装: 标题+loading+error状态)

### 20.2 10个通用UI组件

| 组件 | 文件路径 | 功能 |
|------|---------|------|
| CpqCard | `components/common/CpqCard.vue` | 统一卡片容器(skeleton/error/empty三种状态) |
| StatusBadge | `components/common/StatusBadge.vue` | 状态标签(所有CPQ状态: 报价/ECN/迁移/审批等) |
| DataTable | `components/common/DataTable.vue` | ElTable封装(分页/排序/筛选/列显示控制) |
| EmptyState | `components/common/EmptyState.vue` | 空状态(图标+标题+描述+操作按钮) |
| LoadingSkeleton | `components/common/LoadingSkeleton.vue` | 骨架屏加载(矩形/圆形变体, 行数控制) |
| ErrorBoundary | `components/common/ErrorBoundary.vue` | 全局错误边界(onErrorCaptured+重试按钮) |
| AtpIndicator | `components/common/AtpIndicator.vue` | ATP状态指示器(绿/黄/红三点+tooltip详情) |
| DeliveryTimeline | `components/common/DeliveryTimeline.vue` | CTP交期时间线(物料→生产→质检→包装→物流→缓冲水平步骤) |
| PriceBreakdown | `components/common/PriceBreakdown.vue` | 价格分解瀑布(牌价→折扣→净价) |
| DiscountSlider | `components/common/DiscountSlider.vue` | 交互折扣滑块(ElSlider+最大值标记) |

---

## §21 Store模块与API模块定义

### 21.1 新增Pinia Store（8个）

| Store | 文件 | 核心状态 | 核心Actions |
|-------|------|---------|------------|
| useSolutionStore | `stores/solution.ts` | solutionId, content, collaborators[], comments[], isDirty | initSolution, syncContent(Yjs), addComment, submitReview |
| useCompetitiveStore | `stores/competitive.ts` | competitors[], comparisonResults[], recommendations[] | fetchCompetitors, compare(myId, compId), getRecommendation |
| useKnowledgeStore | `stores/knowledge.ts` | articles[], scripts[], caseStudies[], trainingMaterials[] | searchArticles, getScriptByScenario |
| useEcnStore | `stores/ecn.ts` | ecnId, changeItems[], impactAnalysis[], approvalSteps[] | createEcn, addChangeItem, analyzeImpact, submitApproval |
| useMigrationStore | `stores/migration.ts` | taskId, mappingConfig[], validationResult, progress% | uploadFile, configMapping, validate, execute, getReport |
| usePricingStore | `stores/pricing.ts` | priceBooks[], rules[], volumeTiers[], currencyRates[] | CRUD actions for all pricing entities |
| useApprovalStore | `stores/approval.ts` | pendingList[], chain, history[], analytics[] | fetchPending, processAction, fetchHistory, fetchAnalytics |
| usePresalesStore | `stores/presales.ts` | tasks[], collabSession, reviewItems[] | fetchTasks, assignTask, updateTaskStatus |

### 21.2 新增API模块（12个）

| API模块 | 文件 | 端点 |
|---------|------|------|
| guided | `api/guided.ts` | getInitQuestion, submitAnswer, completeGuided |
| solution | `api/solution.ts` | createSolution, updateContent, submitReview, compareSolutions, getCollaborators |
| competitive | `api/competitive.ts` | getCompetitors, addCompetitor, addProduct, compare, getRecommendation |
| knowledge | `api/knowledge.ts` | searchArticles, getScripts(scenario), getCaseStudies, getTrainingMaterials |
| ecn | `api/ecn.ts` | createChangeOrder, addChangeItem, submit, getImpactAnalysis, approve, close |
| pricing-management | `api/pricing-management.ts` | getPriceBooks, createPriceBook, getRules, createRule, getVolumeTiers, createTier, getCurrencyRates |
| approval-management | `api/approval-management.ts` | getPending, processApproval, getHistory, getAnalytics |
| presales | `api/presales.ts` | getTasks, assignTask, updateTask, getCollabSession |
| integration | `api/integration.ts` | getConfigs, testConnection, triggerSync, getSyncLogs |
| migration | `api/migration.ts` | createTask, uploadFile, configMapping, validate, execute, getReport, getReconciliation |
| dashboard | `api/dashboard.ts` | getExecutiveMetrics, getSalesManagerMetrics, getProductMetrics, getPricingMetrics, getSupplyChainMetrics, getOperationsMetrics, getPartnerMetrics |
| search | `api/search.ts` | globalSearch(query, category) — 统一搜索接口 |

---

## §22 路由补充（Vue Router配置）

```typescript
// router/index.ts 新增路由（懒加载全部页面组件）

// 方案管理
{ path: '/solution', component: PortalLayout, meta: { title: '方案管理', icon: 'document' },
  children: [
    { path: 'list', name: 'SolutionList', component: () => import('@/views/solution/SolutionList.vue'), meta: { perm: 'cpq:solution:list' } },
    { path: 'editor/:id', name: 'SolutionEditor', component: () => import('@/views/solution/SolutionEditor.vue'), meta: { perm: 'cpq:solution:edit' } },
    { path: 'compare', name: 'SolutionCompare', component: () => import('@/views/solution/SolutionCompare.vue'), meta: { perm: 'cpq:solution:compare' } },
    { path: 'review/:id', name: 'SolutionReview', component: () => import('@/views/solution/SolutionReview.vue'), meta: { perm: 'cpq:solution:review' } }
  ]
},
// 竞品对标
{ path: '/competitive', component: PortalLayout, meta: { title: '竞品对标', icon: 'swords' },
  children: [
    { path: 'competitor', name: 'CompetitorList', component: () => import('@/views/competitive/CompetitorList.vue'), meta: { perm: 'cpq:competitive:list' } },
    { path: 'compare', name: 'ComparisonView', component: () => import('@/views/competitive/ComparisonView.vue'), meta: { perm: 'cpq:competitive:compare' } },
    { path: 'recommendation', name: 'RecommendationView', component: () => import('@/views/competitive/RecommendationView.vue'), meta: { perm: 'cpq:competitive:view' } }
  ]
},
// 知识库
{ path: '/knowledge', component: PortalLayout, meta: { title: '知识库', icon: 'book' },
  children: [
    { path: 'article', name: 'ProductKnowledge', component: () => import('@/views/knowledge/ProductKnowledge.vue'), meta: { perm: 'cpq:knowledge:view' } },
    { path: 'script', name: 'SalesScripts', component: () => import('@/views/knowledge/SalesScripts.vue'), meta: { perm: 'cpq:knowledge:view' } },
    { path: 'case', name: 'CaseLibrary', component: () => import('@/views/knowledge/CaseLibrary.vue'), meta: { perm: 'cpq:knowledge:view' } },
    { path: 'training', name: 'TrainingCenter', component: () => import('@/views/knowledge/TrainingCenter.vue'), meta: { perm: 'cpq:knowledge:view' } }
  ]
},
// ECN变更管理
{ path: '/ecn', component: PortalLayout, meta: { title: '变更管理', icon: 'refresh' },
  children: [
    { path: 'list', name: 'ChangeManagement', component: () => import('@/views/ecn/ChangeManagement.vue'), meta: { perm: 'cpq:ecn:list' } },
    { path: 'impact/:id', name: 'ImpactAnalysis', component: () => import('@/views/ecn/ImpactAnalysis.vue'), meta: { perm: 'cpq:ecn:view' } },
    { path: 'approval/:id', name: 'ChangeApproval', component: () => import('@/views/ecn/ChangeApproval.vue'), meta: { perm: 'cpq:ecn:approve' } }
  ]
},
// 定价管理
{ path: '/pricing', component: PortalLayout, meta: { title: '定价管理', icon: 'money' },
  children: [
    { path: 'price-book', name: 'PriceBookList', component: () => import('@/views/pricing/PriceBookList.vue'), meta: { perm: 'cpq:pricing:list' } },
    { path: 'rule', name: 'PriceRuleConfig', component: () => import('@/views/pricing/PriceRuleConfig.vue'), meta: { perm: 'cpq:pricing:rule' } },
    { path: 'volume-tier', name: 'VolumeTierConfig', component: () => import('@/views/pricing/VolumeTierConfig.vue'), meta: { perm: 'cpq:pricing:tier' } },
    { path: 'discount', name: 'DiscountApproval', component: () => import('@/views/pricing/DiscountApproval.vue'), meta: { perm: 'cpq:pricing:discount' } },
    { path: 'currency', name: 'CurrencyConfig', component: () => import('@/views/pricing/CurrencyConfig.vue'), meta: { perm: 'cpq:pricing:currency' } }
  ]
},
// 审批管理
{ path: '/approval', component: PortalLayout, meta: { title: '审批中心', icon: 'checked' },
  children: [
    { path: 'pending', name: 'PendingApproval', component: () => import('@/views/approval/PendingApproval.vue'), meta: { perm: 'cpq:approval:list' } },
    { path: 'detail/:id', name: 'ApprovalDetail', component: () => import('@/views/approval/ApprovalDetail.vue'), meta: { perm: 'cpq:approval:view' } },
    { path: 'history', name: 'ApprovalHistory', component: () => import('@/views/approval/ApprovalHistory.vue'), meta: { perm: 'cpq:approval:history' } },
    { path: 'analytics', name: 'ApprovalAnalytics', component: () => import('@/views/approval/ApprovalAnalytics.vue'), meta: { perm: 'cpq:approval:analytics' } }
  ]
},
// 售前协同
{ path: '/presales', component: PortalLayout, meta: { title: '售前协同', icon: 'user' },
  children: [
    { path: 'task-board', name: 'TaskBoard', component: () => import('@/views/presales/TaskBoard.vue'), meta: { perm: 'cpq:presales:task' } },
    { path: 'editor/:id', name: 'CollabEditor', component: () => import('@/views/presales/CollabEditor.vue'), meta: { perm: 'cpq:presales:edit' } },
    { path: 'review', name: 'ReviewWorkbench', component: () => import('@/views/presales/ReviewWorkbench.vue'), meta: { perm: 'cpq:presales:review' } }
  ]
},
// 集成管理
{ path: '/integration', component: PortalLayout, meta: { title: '系统集成', icon: 'link' },
  children: [
    { path: 'crm', name: 'CrmConnector', component: () => import('@/views/integration/CrmConnector.vue'), meta: { perm: 'cpq:integration:config' } },
    { path: 'erp', name: 'ErpConnector', component: () => import('@/views/integration/ErpConnector.vue'), meta: { perm: 'cpq:integration:config' } },
    { path: 'plm', name: 'PlmConnector', component: () => import('@/views/integration/PlmConnector.vue'), meta: { perm: 'cpq:integration:config' } },
    { path: 'logs', name: 'SyncLogViewer', component: () => import('@/views/integration/SyncLogViewer.vue'), meta: { perm: 'cpq:integration:log' } }
  ]
},
// 数据迁移
{ path: '/migration', component: PortalLayout, meta: { title: '数据迁移', icon: 'upload' },
  children: [
    { path: 'task', name: 'DataMigration', component: () => import('@/views/migration/DataMigration.vue'), meta: { perm: 'cpq:migration:list' } }
  ]
},
// Dashboard (7个角色)
{ path: '/dashboard', component: PortalLayout,
  children: [
    { path: 'executive', name: 'ExecutiveDashboard', component: () => import('@/views/dashboard/ExecutiveDashboard.vue'), meta: { roles: ['cpq_executive'] } },
    { path: 'sales-manager', name: 'SalesManagerDashboard', component: () => import('@/views/dashboard/SalesManagerDashboard.vue'), meta: { roles: ['cpq_sales_manager'] } },
    { path: 'partner', name: 'PartnerDashboard', component: () => import('@/views/dashboard/PartnerDashboard.vue'), meta: { roles: ['cpq_partner'] } },
    { path: 'product', name: 'ProductManagerDashboard', component: () => import('@/views/dashboard/ProductManagerDashboard.vue'), meta: { roles: ['cpq_product_manager'] } },
    { path: 'pricing', name: 'PricingManagerDashboard', component: () => import('@/views/dashboard/PricingManagerDashboard.vue'), meta: { roles: ['cpq_pricing_admin'] } },
    { path: 'supply', name: 'SupplyChainDashboard', component: () => import('@/views/dashboard/SupplyChainDashboard.vue'), meta: { roles: ['cpq_supply_chain'] } },
    { path: 'operations', name: 'OperationsDashboard', component: () => import('@/views/dashboard/OperationsDashboard.vue'), meta: { roles: ['cpq_operations'] } }
  ]
},
// 配置报价下的向导式销售（已有路由，补充子路由）
// 在 /configurator 下追加:
// 实际已实施路由（cpq-portal/src/router/index.ts）：
// 配置管理
{ path: 'configure', name: 'Configurator', component: () => import('@/views/configure/ProductSearch.vue'), meta: { title: '产品配置器' } },
{ path: 'configure/:modelId', name: 'ConfigureProduct', component: () => import('@/views/configure/Configurator.vue'), meta: { title: '产品配置器' } },
// 新建标准配置（复用 StandardConfigure 页面，含4步流程引导、STANDARD产品过滤）
{ path: 'configure-standard', name: 'StandardConfigure', component: () => import('@/views/configure/StandardConfigure.vue'), meta: { title: '新建标准配置' } },
// 向导式配置
{ path: 'configure-guided', name: 'GuidedSelling', component: () => import('@/views/configure/GuidedSelling.vue'), meta: { title: '向导式配置' } },
{ path: 'configure-guided/:modelId', name: 'GuidedConfigurator', component: () => import('@/views/configure/GuidedSelling.vue'), meta: { title: '向导配置产品' } },
// ATO定制配置
{ path: 'configure-ato', name: 'AtoCustomize', component: () => import('@/views/configure/AtoCustomize.vue'), meta: { title: 'ATO定制配置' } },
// 配置回顾（向导完成后查看完整配置与价格）
{ path: 'configure-review/:modelId', name: 'ConfigurationReview', component: () => import('@/views/configure/ConfigurationReview.vue'), meta: { title: '配置回顾' } },
```

---

## §23 累计统计

| 维度 | V1.0 | V2.0（本补充） |
|------|:---:|:---:|
| 页面/组件数 | ~25 | **~60**（新增35个页面+10个通用组件） |
| 路由定义 | ~15 | **~52**（新增37条路由） |
| Pinia Store | 3 | **11**（新增8个） |
| API模块 | 4 | **16**（新增12个） |
| 12角色Dashboard覆盖 | 1/12 | **12/12** |
| P0遗漏功能前端覆盖 | 0% | **100%**（全部35+页面已设计） |
| cross_trace_v2_final 30项遗漏 | 0/30 | **30/30**（全部完成设计补充） |

---

> **文档完结 V2.0 | 前后端设计全面补全，所有 cross_trace_v2_final 审计发现的缺失模块/页面/表/菜单/角色均已补充到可直接执行的颗粒度。**
