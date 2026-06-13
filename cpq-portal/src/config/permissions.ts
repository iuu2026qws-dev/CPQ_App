/**
 * CPQ 权限字符串注册表（S18.1）
 *
 * 所有 CPQ 模块的操作权限字符串在此集中定义。
 * 前端 v-hasPermi 指令 + 后端 @PreAuthorize / @SaCheckPermission 共用此表。
 *
 * 命名规范：cpq:{模块}:{操作}
 * 模块：product / pricing / config / quote / approval / solution / atp / customer / ecn / integration / competitive / migration / knowledge / abac
 * 操作：list / query / add / edit / remove / export / import / process / approve / reject
 */

// === 产品主数据 ===
export const PRODUCT_CATALOG_LIST   = 'cpq:product:catalog:list'
export const PRODUCT_CATALOG_QUERY  = 'cpq:product:catalog:query'
export const PRODUCT_CATALOG_ADD    = 'cpq:product:catalog:add'
export const PRODUCT_CATALOG_EDIT   = 'cpq:product:catalog:edit'
export const PRODUCT_CATALOG_REMOVE = 'cpq:product:catalog:remove'

export const PRODUCT_MODEL_LIST     = 'cpq:product:model:list'
export const PRODUCT_MODEL_QUERY    = 'cpq:product:model:query'
export const PRODUCT_MODEL_ADD      = 'cpq:product:model:add'
export const PRODUCT_MODEL_EDIT     = 'cpq:product:model:edit'
export const PRODUCT_MODEL_REMOVE   = 'cpq:product:model:remove'

export const PRODUCT_BOM_LIST       = 'cpq:product:bom:list'
export const PRODUCT_BOM_QUERY      = 'cpq:product:bom:query'
export const PRODUCT_BOM_ADD        = 'cpq:product:bom:add'
export const PRODUCT_BOM_EDIT       = 'cpq:product:bom:edit'
export const PRODUCT_BOM_REMOVE     = 'cpq:product:bom:remove'
export const PRODUCT_BOM_EXPLODE    = 'cpq:product:bom:explode'

export const PRODUCT_SUPERSESSION_LIST   = 'cpq:product:supersession:list'
export const PRODUCT_SUPERSESSION_EDIT   = 'cpq:product:supersession:edit'

// === 定价 ===
export const PRICING_BOOK_LIST     = 'cpq:pricing:book:list'
export const PRICING_BOOK_ADD      = 'cpq:pricing:book:add'
export const PRICING_BOOK_EDIT     = 'cpq:pricing:book:edit'
export const PRICING_BOOK_REMOVE   = 'cpq:pricing:book:remove'
export const PRICING_ENTRY_LIST    = 'cpq:pricing:entry:list'
export const PRICING_ENTRY_ADD     = 'cpq:pricing:entry:add'
export const PRICING_ENTRY_EDIT    = 'cpq:pricing:entry:edit'
export const PRICING_ENTRY_REMOVE  = 'cpq:pricing:entry:remove'
export const PRICING_RULE_LIST     = 'cpq:pricing:rule:list'
export const PRICING_RULE_ADD      = 'cpq:pricing:rule:add'
export const PRICING_RULE_EDIT     = 'cpq:pricing:rule:edit'
export const PRICING_RULE_REMOVE   = 'cpq:pricing:rule:remove'
export const PRICING_TIER_LIST     = 'cpq:pricing:tier:list'
export const PRICING_CHANNEL_LIST  = 'cpq:pricing:channel:list'
export const PRICING_CALCULATE     = 'cpq:pricing:calculate'

// === 配置引擎 ===
export const CONFIG_RULE_LIST      = 'cpq:config:rule:list'
export const CONFIG_RULE_ADD       = 'cpq:config:rule:add'
export const CONFIG_RULE_EDIT      = 'cpq:config:rule:edit'
export const CONFIG_RULE_REMOVE    = 'cpq:config:rule:remove'
export const CONFIG_BUNDLE_LIST    = 'cpq:config:bundle:list'
export const CONFIG_BUNDLE_ADD     = 'cpq:config:bundle:add'
export const CONFIG_BUNDLE_EDIT    = 'cpq:config:bundle:edit'
export const CONFIG_BUNDLE_REMOVE  = 'cpq:config:bundle:remove'
export const CONFIG_VALIDATE       = 'cpq:config:validate'
export const CONFIG_COMPLETE       = 'cpq:config:complete'

// === 报价 ===
export const QUOTE_LIST            = 'cpq:quote:list'
export const QUOTE_QUERY           = 'cpq:quote:query'
export const QUOTE_ADD             = 'cpq:quote:add'
export const QUOTE_EDIT            = 'cpq:quote:edit'
export const QUOTE_REMOVE          = 'cpq:quote:remove'
export const QUOTE_SUBMIT           = 'cpq:quote:submit'
export const QUOTE_GENERATE        = 'cpq:quote:generate'
export const QUOTE_EXPORT          = 'cpq:quote:export'
export const QUOTE_VERSION_LIST    = 'cpq:quote:version:list'
export const QUOTE_VERSION_ROLLBACK = 'cpq:quote:version:rollback'

// === 审批 ===
export const APPROVAL_PENDING      = 'cpq:approval:pending'
export const APPROVAL_HISTORY      = 'cpq:approval:history'
export const APPROVAL_PROCESS      = 'cpq:approval:process'
export const APPROVAL_ESCALATE     = 'cpq:approval:escalate'
export const APPROVAL_RULE_LIST    = 'cpq:approval:rule:list'
export const APPROVAL_RULE_ADD     = 'cpq:approval:rule:add'
export const APPROVAL_RULE_EDIT    = 'cpq:approval:rule:edit'
export const APPROVAL_RULE_REMOVE  = 'cpq:approval:rule:remove'

// === 方案 ===
export const SOLUTION_LIST         = 'cpq:solution:list'
export const SOLUTION_ADD          = 'cpq:solution:add'
export const SOLUTION_EDIT         = 'cpq:solution:edit'
export const SOLUTION_REMOVE       = 'cpq:solution:remove'
export const SOLUTION_COMPARE      = 'cpq:solution:compare'

// === ATP/CTP ===
export const ATP_CHECK             = 'cpq:atp:check'
export const ATP_BATCH             = 'cpq:atp:batch'
export const ATP_DASHBOARD         = 'cpq:atp:dashboard'

// === 客户 ===
export const CUSTOMER_ACCOUNT_LIST   = 'cpq:customer:account:list'
export const CUSTOMER_ACCOUNT_ADD    = 'cpq:customer:account:add'
export const CUSTOMER_ACCOUNT_EDIT   = 'cpq:customer:account:edit'
export const CUSTOMER_ACCOUNT_REMOVE = 'cpq:customer:account:remove'
export const CUSTOMER_CHANNEL_LIST   = 'cpq:customer:channel:list'
export const CUSTOMER_TERRITORY_LIST = 'cpq:customer:territory:list'

// === ECN ===
export const ECN_ORDER_LIST        = 'cpq:ecn:order:list'
export const ECN_ORDER_ADD         = 'cpq:ecn:order:add'
export const ECN_ORDER_EDIT        = 'cpq:ecn:order:edit'
export const ECN_ORDER_REMOVE      = 'cpq:ecn:order:remove'
export const ECN_ANALYZE_IMPACT    = 'cpq:ecn:analyze'
export const ECN_APPROVE           = 'cpq:ecn:approve'

// === 集成 ===
export const INTEGRATION_CONNECTOR_LIST   = 'cpq:integration:connector:list'
export const INTEGRATION_CONNECTOR_EDIT   = 'cpq:integration:connector:edit'
export const INTEGRATION_SYNC             = 'cpq:integration:sync'

// === 竞品 ===
export const COMPETITIVE_LIST       = 'cpq:competitive:list'
export const COMPETITIVE_ADD        = 'cpq:competitive:add'
export const COMPETITIVE_EDIT       = 'cpq:competitive:edit'
export const COMPETITIVE_REMOVE     = 'cpq:competitive:remove'

// === 数据迁移 ===
export const MIGRATION_TASK_LIST    = 'cpq:migration:task:list'
export const MIGRATION_TASK_CREATE  = 'cpq:migration:task:create'
export const MIGRATION_EXECUTE      = 'cpq:migration:execute'

// === 知识库 ===
export const KNOWLEDGE_LIST         = 'cpq:knowledge:list'
export const KNOWLEDGE_ADD          = 'cpq:knowledge:add'
export const KNOWLEDGE_EDIT         = 'cpq:knowledge:edit'
export const KNOWLEDGE_REMOVE       = 'cpq:knowledge:remove'
export const KNOWLEDGE_SEARCH       = 'cpq:knowledge:search'

// === ABAC 策略 ===
export const ABAC_POLICY_LIST       = 'cpq:abac:policy:list'
export const ABAC_POLICY_ADD        = 'cpq:abac:policy:add'
export const ABAC_POLICY_EDIT       = 'cpq:abac:policy:edit'
export const ABAC_POLICY_REMOVE     = 'cpq:abac:policy:remove'

// === 快速报价 ===
export const QUICK_QUOTE            = 'cpq:quickquote:create'

// === 工厂 ===
export const PLANT_LIST             = 'cpq:plant:list'
export const PLANT_ADD              = 'cpq:plant:add'
export const PLANT_EDIT             = 'cpq:plant:edit'
export const PLANT_REMOVE           = 'cpq:plant:remove'

// ======== 12 角色权限矩阵 ========
// 每个角色拥有的权限前缀
export const ROLE_PERMISSIONS: Record<string, string[]> = {
  executive:           ['*:*:*'],
  admin:               ['*:*:*'],
  auditor:             ['cpq:*:list', 'cpq:*:query', 'cpq:abac:*', 'cpq:approval:history'],
  pricing_manager:     ['cpq:pricing:*', 'cpq:product:*:list', 'cpq:product:*:query', 'cpq:config:*:list', 'cpq:config:*:query', 'cpq:quote:*:list', 'cpq:quote:*:query'],
  sales_manager:       ['cpq:quote:*', 'cpq:solution:*', 'cpq:customer:*', 'cpq:atp:*', 'cpq:competitive:*:list', 'cpq:competitive:*:query'],
  sales_rep:           ['cpq:quote:list', 'cpq:quote:query', 'cpq:quote:add', 'cpq:quote:edit', 'cpq:quote:submit', 'cpq:solution:list', 'cpq:solution:add', 'cpq:solution:compare', 'cpq:atp:check', 'cpq:customer:*:list', 'cpq:customer:*:query', 'cpq:config:validate', 'cpq:config:complete', 'cpq:quickquote:create'],
  product_manager:     ['cpq:product:*', 'cpq:config:*', 'cpq:ecn:*', 'cpq:plant:*'],
  presales:            ['cpq:config:validate', 'cpq:config:complete', 'cpq:quote:*:list', 'cpq:quote:*:query', 'cpq:solution:*', 'cpq:knowledge:*'],
  channel_partner:     ['cpq:quote:list', 'cpq:quote:query', 'cpq:quote:add', 'cpq:quote:submit', 'cpq:atp:check', 'cpq:customer:*:list', 'cpq:customer:*:query'],
  operations:          ['cpq:quote:*:list', 'cpq:quote:*:query', 'cpq:atp:*', 'cpq:migration:*'],
  supply_chain:        ['cpq:atp:*', 'cpq:ecn:*:list', 'cpq:ecn:*:query', 'cpq:plant:*:list', 'cpq:plant:*:query'],
}

// 所有 CPQ 权限字符串汇总（用于系统注册/校验）
export const ALL_CPQ_PERMISSIONS: string[] = Object.values({
  PRODUCT_CATALOG_LIST, PRODUCT_CATALOG_QUERY, PRODUCT_CATALOG_ADD, PRODUCT_CATALOG_EDIT, PRODUCT_CATALOG_REMOVE,
  PRODUCT_MODEL_LIST, PRODUCT_MODEL_QUERY, PRODUCT_MODEL_ADD, PRODUCT_MODEL_EDIT, PRODUCT_MODEL_REMOVE,
  PRODUCT_BOM_LIST, PRODUCT_BOM_QUERY, PRODUCT_BOM_ADD, PRODUCT_BOM_EDIT, PRODUCT_BOM_REMOVE, PRODUCT_BOM_EXPLODE,
  PRODUCT_SUPERSESSION_LIST, PRODUCT_SUPERSESSION_EDIT,
  PRICING_BOOK_LIST, PRICING_BOOK_ADD, PRICING_BOOK_EDIT, PRICING_BOOK_REMOVE,
  PRICING_ENTRY_LIST, PRICING_ENTRY_ADD, PRICING_ENTRY_EDIT, PRICING_ENTRY_REMOVE,
  PRICING_RULE_LIST, PRICING_RULE_ADD, PRICING_RULE_EDIT, PRICING_RULE_REMOVE,
  PRICING_TIER_LIST, PRICING_CHANNEL_LIST, PRICING_CALCULATE,
  CONFIG_RULE_LIST, CONFIG_RULE_ADD, CONFIG_RULE_EDIT, CONFIG_RULE_REMOVE,
  CONFIG_BUNDLE_LIST, CONFIG_BUNDLE_ADD, CONFIG_BUNDLE_EDIT, CONFIG_BUNDLE_REMOVE,
  CONFIG_VALIDATE, CONFIG_COMPLETE,
  QUOTE_LIST, QUOTE_QUERY, QUOTE_ADD, QUOTE_EDIT, QUOTE_REMOVE, QUOTE_SUBMIT, QUOTE_GENERATE, QUOTE_EXPORT,
  QUOTE_VERSION_LIST, QUOTE_VERSION_ROLLBACK,
  APPROVAL_PENDING, APPROVAL_HISTORY, APPROVAL_PROCESS, APPROVAL_ESCALATE,
  APPROVAL_RULE_LIST, APPROVAL_RULE_ADD, APPROVAL_RULE_EDIT, APPROVAL_RULE_REMOVE,
  SOLUTION_LIST, SOLUTION_ADD, SOLUTION_EDIT, SOLUTION_REMOVE, SOLUTION_COMPARE,
  ATP_CHECK, ATP_BATCH, ATP_DASHBOARD,
  CUSTOMER_ACCOUNT_LIST, CUSTOMER_ACCOUNT_ADD, CUSTOMER_ACCOUNT_EDIT, CUSTOMER_ACCOUNT_REMOVE,
  CUSTOMER_CHANNEL_LIST, CUSTOMER_TERRITORY_LIST,
  ECN_ORDER_LIST, ECN_ORDER_ADD, ECN_ORDER_EDIT, ECN_ORDER_REMOVE, ECN_ANALYZE_IMPACT, ECN_APPROVE,
  INTEGRATION_CONNECTOR_LIST, INTEGRATION_CONNECTOR_EDIT, INTEGRATION_SYNC,
  COMPETITIVE_LIST, COMPETITIVE_ADD, COMPETITIVE_EDIT, COMPETITIVE_REMOVE,
  MIGRATION_TASK_LIST, MIGRATION_TASK_CREATE, MIGRATION_EXECUTE,
  KNOWLEDGE_LIST, KNOWLEDGE_ADD, KNOWLEDGE_EDIT, KNOWLEDGE_REMOVE, KNOWLEDGE_SEARCH,
  ABAC_POLICY_LIST, ABAC_POLICY_ADD, ABAC_POLICY_EDIT, ABAC_POLICY_REMOVE,
  QUICK_QUOTE,
  PLANT_LIST, PLANT_ADD, PLANT_EDIT, PLANT_REMOVE,
})
