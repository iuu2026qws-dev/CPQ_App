import request from '@/utils/request'

// ===== Config Rule =====
export interface CpqConfigRuleVo {
  ruleId: number
  ruleName: string
  ruleType: string
  modelId?: number
  conditionExpr: string
  actionExpr: string
  errorMessage?: string
  severity: string
  priority: number
  effectiveDate: string
  expiryDate?: string
  status: string
  tenantId?: string
  createTime?: string
  updateTime?: string
  remark?: string
}

export interface CpqConfigRuleBo {
  ruleId?: number
  ruleName: string
  ruleType: string
  modelId?: number
  conditionExpr: string
  actionExpr: string
  errorMessage?: string
  severity: string
  priority: number
  effectiveDate: string
  expiryDate?: string
  status: string
}

export function getConfigRuleList(params?: any) {
  return request.get<CpqConfigRuleVo[]>('/cpq/config/rule/list', { params })
}
export function getConfigRuleById(ruleId: number) {
  return request.get<CpqConfigRuleVo>(`/cpq/config/rule/${ruleId}`)
}
export function addConfigRule(data: CpqConfigRuleBo) {
  return request.post('/cpq/config/rule', data)
}
export function updateConfigRule(data: CpqConfigRuleBo) {
  return request.put('/cpq/config/rule', data)
}
export function deleteConfigRule(ruleId: number) {
  return request.delete(`/cpq/config/rule/${ruleId}`)
}

// ===== Variant BOM =====
export interface CpqVariantBomVo {
  variantId: number
  modelId: number
  sbomLineId?: number
  materialCode: string
  quantity: number
  effectivityCondition: string
  isDefault: string
  sortOrder: number
  tenantId?: string
  createTime?: string
}

export interface CpqVariantBomBo {
  variantId?: number
  modelId: number
  sbomLineId?: number
  materialCode: string
  quantity: number
  effectivityCondition: string
  isDefault: string
  sortOrder: number
}

export function getVariantBomList(params?: any) {
  return request.get<CpqVariantBomVo[]>('/cpq/config/variantbom/list', { params })
}
export function getVariantBomById(variantId: number) {
  return request.get<CpqVariantBomVo>(`/cpq/config/variantbom/${variantId}`)
}
export function addVariantBom(data: CpqVariantBomBo) {
  return request.post('/cpq/config/variantbom', data)
}
export function updateVariantBom(data: CpqVariantBomBo) {
  return request.put('/cpq/config/variantbom', data)
}
export function deleteVariantBom(variantId: number) {
  return request.delete(`/cpq/config/variantbom/${variantId}`)
}

// ===== Attribute Mapping =====
export interface CpqAttributeMappingVo {
  mappingId: number
  modelId: number
  attrName: string
  attrValue: string
  materialCode: string
  sbomLineId?: number
  conditionExpr?: string
  sortOrder: number
}

export interface CpqAttributeMappingBo {
  mappingId?: number
  modelId: number
  attrName: string
  attrValue: string
  materialCode: string
  sbomLineId?: number
  conditionExpr?: string
  sortOrder: number
}

export function getAttributeMappingList(params?: any) {
  return request.get<CpqAttributeMappingVo[]>('/cpq/config/attributemapping/list', { params })
}
export function getAttributeMappingById(mappingId: number) {
  return request.get<CpqAttributeMappingVo>(`/cpq/config/attributemapping/${mappingId}`)
}
export function addAttributeMapping(data: CpqAttributeMappingBo) {
  return request.post('/cpq/config/attributemapping', data)
}
export function updateAttributeMapping(data: CpqAttributeMappingBo) {
  return request.put('/cpq/config/attributemapping', data)
}
export function deleteAttributeMapping(mappingId: number) {
  return request.delete(`/cpq/config/attributemapping/${mappingId}`)
}

// ===== Compatibility Matrix =====
export interface CpqCompatibilityMatrixVo {
  matrixId: number
  sourceProductId: number
  targetProductId: number
  compatibilityType: string
  conditionDesc?: string
}

export interface CpqCompatibilityMatrixBo {
  matrixId?: number
  sourceProductId: number
  targetProductId: number
  compatibilityType: string
  conditionDesc?: string
}

export function getCompatibilityMatrixList(params?: any) {
  return request.get<CpqCompatibilityMatrixVo[]>('/cpq/config/compatibility/list', { params })
}
export function getCompatibilityMatrixById(matrixId: number) {
  return request.get<CpqCompatibilityMatrixVo>(`/cpq/config/compatibility/${matrixId}`)
}
export function addCompatibilityMatrix(data: CpqCompatibilityMatrixBo) {
  return request.post('/cpq/config/compatibility', data)
}
export function updateCompatibilityMatrix(data: CpqCompatibilityMatrixBo) {
  return request.put('/cpq/config/compatibility', data)
}
export function deleteCompatibilityMatrix(matrixId: number) {
  return request.delete(`/cpq/config/compatibility/${matrixId}`)
}

// ===== Attribute Option =====
export interface CpqAttributeOptionVo {
  optionId: number
  modelId: number
  attrName: string
  optionCode: string
  optionLabel: string
  optionValue?: string
  isDefault: string
  sortOrder: number
}

export interface CpqAttributeOptionBo {
  optionId?: number
  modelId: number
  attrName: string
  optionCode: string
  optionLabel: string
  optionValue?: string
  isDefault: string
  sortOrder: number
}

export function getAttributeOptionList(params?: any) {
  return request.get<CpqAttributeOptionVo[]>('/cpq/config/attributeoption/list', { params })
}
export function getAttributeOptionById(optionId: number) {
  return request.get<CpqAttributeOptionVo>(`/cpq/config/attributeoption/${optionId}`)
}
export function addAttributeOption(data: CpqAttributeOptionBo) {
  return request.post('/cpq/config/attributeoption', data)
}
export function updateAttributeOption(data: CpqAttributeOptionBo) {
  return request.put('/cpq/config/attributeoption', data)
}
export function deleteAttributeOption(optionId: number) {
  return request.delete(`/cpq/config/attributeoption/${optionId}`)
}
