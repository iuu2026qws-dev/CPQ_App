import { createRouter, createWebHistory, type RouteRecordRaw } from 'vue-router'

const routes: RouteRecordRaw[] = [
  {
    path: '/login',
    name: 'Login',
    component: () => import('@/views/login/Login.vue'),
    meta: { title: '登录' }
  },
  // ===== 移动端路由（S19）=====
  {
    path: '/mobile',
    component: () => import('@/views/mobile/MobileLayout.vue'),
    redirect: '/mobile/home',
    children: [
      {
        path: 'home',
        name: 'MobileHome',
        component: () => import('@/views/mobile/MobileHome.vue'),
        meta: { title: '首页' }
      },
      {
        path: 'approval',
        name: 'MobileApproval',
        component: () => import('@/views/mobile/MobileApproval.vue'),
        meta: { title: '审批' }
      },
      {
        path: 'quote',
        name: 'MobileQuote',
        component: () => import('@/views/mobile/MobileQuote.vue'),
        meta: { title: '快速报价' }
      },
      {
        path: 'quick-quote',
        redirect: '/mobile/quote'
      },
      {
        path: 'solution',
        name: 'MobileSolution',
        component: () => import('@/views/mobile/MobileSolution.vue'),
        meta: { title: '方案' }
      },
      {
        path: 'profile',
        name: 'MobileProfile',
        component: () => import('@/views/mobile/MobileProfile.vue'),
        meta: { title: '我的' }
      },
      {
        path: 'configurator',
        name: 'MobileConfigurator',
        component: () => import('@/views/mobile/MobileConfigurator.vue'),
        meta: { title: '产品配置' }
      },
    ]
  },
  // ===== 桌面端路由 =====
  {
    path: '/',
    component: () => import('@/views/layout/PortalLayout.vue'),
    redirect: '/catalog',
    children: [
      // ===== CRM信息模块 =====
      {
        path: 'crm/account',
        name: 'CrmAccountList',
        component: () => import('@/views/crm/AccountList.vue'),
        meta: { title: '客户管理' }
      },
      {
        path: 'crm/account/:id',
        name: 'CrmAccountDetail',
        component: () => import('@/views/crm/AccountDetail.vue'),
        meta: { title: '客户详情' }
      },
      {
        path: 'crm/opportunity',
        name: 'CrmOpportunityList',
        component: () => import('@/views/crm/OpportunityList.vue'),
        meta: { title: '商机管理' }
      },
      {
        path: 'crm/opportunity/:id',
        name: 'CrmOpportunityDetail',
        component: () => import('@/views/crm/OpportunityDetail.vue'),
        meta: { title: '商机详情' }
      },
      {
        path: 'crm/contract',
        name: 'CrmContractList',
        component: () => import('@/views/crm/ContractList.vue'),
        meta: { title: '合同管理' }
      },
      {
        path: 'crm/contract/create',
        name: 'CrmContractCreate',
        component: () => import('@/views/crm/ContractForm.vue'),
        meta: { title: '新建合同' }
      },
      {
        path: 'crm/contract/:id',
        name: 'CrmContractDetail',
        component: () => import('@/views/crm/ContractDetail.vue'),
        meta: { title: '合同详情' }
      },
      {
        path: 'crm/order',
        name: 'CrmOrderList',
        component: () => import('@/views/crm/OrderList.vue'),
        meta: { title: '订单管理' }
      },
      {
        path: 'crm/order/:id',
        name: 'CrmOrderDetail',
        component: () => import('@/views/crm/OrderDetail.vue'),
        meta: { title: '订单详情' }
      },
      {
        path: 'catalog',
        name: 'ProductCatalog',
        component: () => import('@/views/catalog/ProductCatalog.vue'),
        meta: { title: '产品目录' }
      },
      {
        path: 'bom',
        name: 'BomManager',
        component: () => import('@/views/bom/BomManager.vue'),
        meta: { title: 'BOM管理' }
      },
      {
        path: 'bundle',
        name: 'BundleManager',
        component: () => import('@/views/product/BundleManager.vue'),
        meta: { title: '捆绑包管理' }
      },
      {
        path: 'model',
        name: 'ProductModel',
        component: () => import('@/views/product/ProductModel.vue'),
        meta: { title: '产品模型' }
      },
      {
        path: 'supersession',
        name: 'SupersessionManager',
        component: () => import('@/views/supersession/SupersessionManager.vue'),
        meta: { title: '替代品管理' }
      },
      {
        path: 'config',
        name: 'ConfigRuleManager',
        component: () => import('@/views/config/ConfigRuleManager.vue'),
        meta: { title: '配置规则' }
      },
      {
        path: 'attribute-option',
        name: 'AttributeOptionManager',
        component: () => import('@/views/product/AttributeOptionManager.vue'),
        meta: { title: '属性选项管理' }
      },
      // ===== 定价管理模块 =====
      {
        path: 'pricing/book',
        name: 'PriceBookList',
        component: () => import('@/views/pricing/PriceBookList.vue'),
        meta: { title: '价格手册' }
      },
      {
        path: 'pricing/rule',
        name: 'PriceRuleConfig',
        component: () => import('@/views/pricing/PriceRuleConfig.vue'),
        meta: { title: '定价规则' }
      },
      {
        path: 'pricing/volumetier',
        name: 'VolumeTierConfig',
        component: () => import('@/views/pricing/VolumeTierConfig.vue'),
        meta: { title: '阶梯定价' }
      },
      {
        path: 'pricing/channelprice',
        name: 'ChannelPriceList',
        component: () => import('@/views/pricing/ChannelPriceList.vue'),
        meta: { title: '渠道价格' }
      },
      {
        path: 'pricing/currencyrate',
        name: 'CurrencyConfig',
        component: () => import('@/views/pricing/CurrencyConfig.vue'),
        meta: { title: '汇率配置' }
      },
      // ===== 配置器模块 =====
      {
        path: 'configure',
        name: 'ProductSearch',
        component: () => import('@/views/configure/ProductSearch.vue'),
        meta: { title: '产品配置器' }
      },
      {
        path: 'configure/:modelId',
        name: 'ProductConfigurator',
        component: () => import('@/views/configure/Configurator.vue'),
        meta: { title: '配置产品' }
      },
      // 新建标准配置（专用页面：流程引导+STANDARD产品搜索）
      {
        path: 'configure-standard',
        name: 'StandardConfigure',
        component: () => import('@/views/configure/StandardConfigure.vue'),
        meta: { title: '新建标准配置' }
      },
      // 向导式配置
      {
        path: 'configure-guided',
        name: 'GuidedSelling',
        component: () => import('@/views/configure/GuidedSelling.vue'),
        meta: { title: '向导式配置' }
      },
      {
        path: 'configure-guided/:modelId',
        name: 'GuidedConfigurator',
        component: () => import('@/views/configure/GuidedSelling.vue'),
        meta: { title: '向导配置产品' }
      },
      // 配置回顾（向导完成后查看完整配置与价格）
      {
        path: 'configure-review/:modelId',
        name: 'ConfigurationReview',
        component: () => import('@/views/configure/ConfigurationReview.vue'),
        meta: { title: '配置回顾' }
      },
      // ATO定制配置
      {
        path: 'configure-ato',
        name: 'AtoCustomize',
        component: () => import('@/views/configure/AtoCustomize.vue'),
        meta: { title: 'ATO定制配置' }
      },
      // ===== 报价管理模块 =====
      {
        path: 'quoting',
        name: 'QuoteList',
        component: () => import('@/views/quoting/QuoteList.vue'),
        meta: { title: '报价单管理' }
      },
      {
        path: 'quoting/template',
        name: 'TemplateManager',
        component: () => import('@/views/quoting/TemplateManager.vue'),
        meta: { title: '报价模板管理' }
      },
      {
        path: 'quoting/template-design/:templateId',
        name: 'TemplateDesigner',
        component: () => import('@/views/quoting/TemplateDesigner.vue'),
        meta: { title: '模板设计' }
      },
      {
        path: 'quoting/:id',
        name: 'QuoteDetail',
        component: () => import('@/views/quoting/QuoteDetail.vue'),
        meta: { title: '报价单详情' }
      },
      {
        path: 'quoting/:id/versions',
        name: 'QuoteVersion',
        component: () => import('@/views/quoting/QuoteVersion.vue'),
        meta: { title: '版本对比' }
      },
      // ===== 方案管理模块 =====
      {
        path: 'solution',
        name: 'SolutionList',
        component: () => import('@/views/solution/SolutionList.vue'),
        meta: { title: '方案管理' }
      },
      {
        path: 'solution/:id/editor',
        name: 'SolutionEditor',
        component: () => import('@/views/solution/SolutionEditor.vue'),
        meta: { title: '方案编辑器' }
      },
      {
        path: 'solution/:id/compare',
        name: 'SolutionCompare',
        component: () => import('@/views/solution/SolutionCompare.vue'),
        meta: { title: '方案对比' }
      },
      {
        path: 'solution/:id/review',
        name: 'SolutionReview',
        component: () => import('@/views/solution/SolutionReview.vue'),
        meta: { title: '方案评审' }
      },
      // ===== ATP/CTP 交期管理模块 =====
      {
        path: 'atp',
        name: 'AtpCheck',
        component: () => import('@/views/atp/AtpCheck.vue'),
        meta: { title: '交期检查' }
      },
      {
        path: 'atp/batch',
        name: 'AtpBatch',
        component: () => import('@/views/atp/AtpBatch.vue'),
        meta: { title: '批量交期查询' }
      },
      {
        path: 'atp/sla',
        name: 'SlaDashboard',
        component: () => import('@/views/atp/SlaDashboard.vue'),
        meta: { title: 'SLA看板' }
      },
      // ===== ECN 工程变更模块 =====
      {
        path: 'ecn',
        name: 'ChangeManagement',
        component: () => import('@/views/ecn/ChangeManagement.vue'),
        meta: { title: 'ECN变更管理' }
      },
      {
        path: 'ecn/:id/impact',
        name: 'ImpactAnalysis',
        component: () => import('@/views/ecn/ImpactAnalysis.vue'),
        meta: { title: '影响分析' }
      },
      {
        path: 'ecn/:id/approval',
        name: 'ChangeApproval',
        component: () => import('@/views/ecn/ChangeApproval.vue'),
        meta: { title: 'ECN审批' }
      },
      // ===== 工厂管理模块 =====
      {
        path: 'plant',
        name: 'PlantManager',
        component: () => import('@/views/plant/PlantManager.vue'),
        meta: { title: '工厂管理' }
      },
      // ===== 快速报价模块 =====
      {
        path: 'quick-quote',
        name: 'QuickQuote',
        component: () => import('@/views/quoting/QuickQuote.vue'),
        meta: { title: '快速报价' }
      },
      // ===== 集成管理模块 =====
      {
        path: 'integration',
        name: 'IntegrationManager',
        component: () => import('@/views/integration/IntegrationManager.vue'),
        meta: { title: '集成管理' }
      },
      // ===== 竞品对标模块 =====
      {
        path: 'competitive',
        name: 'CompetitiveManager',
        component: () => import('@/views/competitive/CompetitiveManager.vue'),
        meta: { title: '竞品对标' }
      },
      // ===== 数据迁移模块 =====
      {
        path: 'migration',
        name: 'MigrationManager',
        component: () => import('@/views/migration/MigrationManager.vue'),
        meta: { title: '数据迁移' }
      },
      // ===== 知识库模块 =====
      {
        path: 'knowledge',
        name: 'KnowledgeManager',
        component: () => import('@/views/knowledge/KnowledgeManager.vue'),
        meta: { title: '知识库' }
      },
      // ===== 系统设置 =====
      {
        path: 'settings/abac',
        name: 'AbacPolicyConfig',
        component: () => import('@/views/settings/AbacPolicyConfig.vue'),
        meta: { title: 'ABAC策略' }
      },
      // ===== 任务中心模块 =====
      {
        path: 'task/board',
        name: 'TaskBoard',
        component: () => import('@/views/task/TaskBoard.vue'),
        meta: { title: '任务看板' }
      },
      {
        path: 'task/review',
        name: 'ReviewWorkbench',
        component: () => import('@/views/task/ReviewWorkbench.vue'),
        meta: { title: '评审工作台' }
      },
      // ===== 审批中心模块 =====
      {
        path: 'approval/pending',
        name: 'PendingMyApproval',
        component: () => import('@/views/approval/PendingMyApproval.vue'),
        meta: { title: '待我审批' }
      },
      {
        path: 'approval/processed',
        name: 'MyProcessed',
        component: () => import('@/views/approval/MyProcessed.vue'),
        meta: { title: '我已审批' }
      },
      {
        path: 'approval/initiated',
        name: 'MyInitiated',
        component: () => import('@/views/approval/MyInitiated.vue'),
        meta: { title: '我发起的' }
      },
      {
        path: 'approval/analytics',
        name: 'ApprovalAnalytics',
        component: () => import('@/views/approval/ApprovalAnalytics.vue'),
        meta: { title: '效率看板' }
      },
      {
        path: 'approval/:id',
        name: 'ApprovalDetail',
        component: () => import('@/views/approval/ApprovalDetail.vue'),
        meta: { title: '审批详情' }
      },
      // ===== 审批管理模块（兼容旧版）=====
      {
        path: 'approval',
        name: 'PendingApproval',
        component: () => import('@/views/approval/PendingApproval.vue'),
        meta: { title: '待审批' }
      },
      {
        path: 'approval/history',
        name: 'ApprovalHistory',
        component: () => import('@/views/approval/ApprovalHistory.vue'),
        meta: { title: '审批历史' }
      },
      {
        path: 'approval/history/:id',
        name: 'ApprovalHistoryDetail',
        component: () => import('@/views/approval/ApprovalDetail.vue'),
        meta: { title: '历史审批详情' }
      }
    ]
  }
]

const router = createRouter({
  history: createWebHistory(),
  routes
})

export default router
