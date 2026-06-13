import request from '@/utils/request'

export interface CpqConfigRule {
  ruleId: number
  ruleName: string
  ruleType: string
  modelId: number
  conditionExpr: string
  actionExpr: string
  errorMessage: string
  severity: string
  priority: number
  effectiveDate: string
  expiryDate: string
  status: string
  tenantId: string
  createTime: string
  updateTime: string
  remark: string
}

export interface CpqConfigRuleForm {
  ruleId?: number
  ruleName: string
  ruleType: string
  modelId: number
  conditionExpr: string
  actionExpr: string
  errorMessage: string
  severity: string
  priority: number
  effectiveDate?: string
  expiryDate?: string
  status: string
  remark?: string
}

// 查询配置规则列表
export function listConfigRule(query?: Record<string, any>) {
  return request.get<{ rows: CpqConfigRule[]; total: number }>(
    '/cpq/config/rule/list',
    { params: query }
  )
}

// 查询配置规则详情
export function getConfigRule(ruleId: number) {
  return request.get<CpqConfigRule>('/cpq/config/rule/' + ruleId)
}

// 新增配置规则
export function addConfigRule(data: CpqConfigRuleForm) {
  return request.post('/cpq/config/rule', data)
}

// 修改配置规则
export function updateConfigRule(data: CpqConfigRuleForm) {
  return request.put('/cpq/config/rule', data)
}

// 删除配置规则
export function delConfigRule(ruleId: number) {
  return request.delete('/cpq/config/rule/' + ruleId)
}
