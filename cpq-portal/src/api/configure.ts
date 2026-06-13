import request from '@/utils/request'
import type { CpqProductModelVo } from '@/api/cpq/product'
import type { SbomLine } from '@/api/bom'

// ========== 配置器 API ==========

/** 加载配置模型（产品信息 + 属性选项 + 默认BOM） */
export function loadConfigModel(modelId: string) {
  return request.get<ConfigModelResponse>('/cpq/configure/model/' + modelId)
}

/** 实时校验属性选择 */
export function validateSelections(modelId: string, selections: Record<string, string>) {
  return request.post<ValidationResult>('/cpq/configure/validate', selections, {
    params: { modelId }
  })
}

/** 完成配置（验证 + BOM转换 + 定价） */
export function completeConfiguration(
  modelId: string,
  selections: Record<string, string>,
  quantity: number = 1
) {
  return request.post<ConfigCompleteResponse>('/cpq/configure/complete', selections, {
    params: { modelId, quantity }
  })
}

// ========== 引擎 API ==========

/** 约束传播：查看当前选择下各属性的可用/禁用选项 */
export function propagateConstraints(modelId: string, selections: Record<string, string>) {
  return request.post<Record<string, OptionInfo[]>>('/cpq/engine/config/propagate', selections, {
    params: { modelId }
  })
}

/** BOM预览：根据当前属性选择返回对应的MBOM明细 */
export function getBomPreview(modelId: string, selections: Record<string, string>) {
  return request.post<MbomLine[]>('/cpq/configure/bom-preview', selections, {
    params: { modelId }
  })
}

/** 向导式销售：获取下一步引导 */
export function getGuideStep(modelId: string, selections: Record<string, string>) {
  return request.post<GuideStep>('/cpq/configure/guide', selections, {
    params: { modelId }
  })
}

/** BOM展开（按SBOM头ID） */
export function explodeBomFlat(sbomHeaderId: string) {
  return request.get<SbomLine[]>('/cpq/engine/bom/explodeFlat/' + sbomHeaderId)
}

/** BOM转换（SBOM→MBOM 带属性选择） */
export function convertBom(sbomHeaderId: string, selections: Record<string, string>) {
  return request.post<MbomLine[]>('/cpq/engine/bom/convert/' + sbomHeaderId, selections)
}

/** 定价计算 */
export function calculatePrice(params: {
  productModelId: string
  variantId?: string
  quantity?: number
  region?: string
  channelId?: string
  requestedDiscount?: number
  bomCost?: number
  currency?: string
}) {
  return request.post<PriceResult>('/cpq/engine/pricing/calculate', null, { params })
}

/** 搜索产品 */
export function searchProducts(keyword: string, configType?: string) {
  return request.get<CpqProductModelVo[]>('/cpq/product/model/search', {
    params: { keyword, configType }
  })
}

// ========== 类型定义 ==========

export interface AttributeOptionVo {
  optionValue: string
  optionLabel: string
  sortOrder: number
}

export interface BomLineVo {
  sbomLineId: number
  lineNumber: number
  itemCode: string
  itemName: string
  itemType: string
  quantity: number
  unit: string
  isRequired: string
  parentLineId?: number
  level: number
}

export interface ConfigModelResponse {
  modelId: number
  modelCode: string
  modelName: string
  configType: string
  defaultBomId: number
  basePrice: number
  currency: string
  description: string
  leadTimeDays: number
  attributes: Record<string, AttributeOptionVo[]>
  bomLines: BomLineVo[]
}

export type ValidationStatus = 'PASS' | 'SOFT_FAIL' | 'HARD_FAIL'

export interface ValidationResult {
  status: ValidationStatus
  errors: string[]
  warnings: string[]
}

export interface OptionInfo {
  code: string
  label: string
  available: boolean
  recommended: boolean
  reason: string
}

export type GuideState = 'QUESTIONING' | 'NARROWING' | 'RECOMMENDING' | 'CONFIGURING' | 'COMPLETED'

export interface GuideStep {
  state: GuideState
  currentAttribute: string
  options: OptionInfo[]
  recommendation: string
  prohibited: Record<string, string>
  attributeOptions: Record<string, string[]>
}

export interface PriceResult {
  basePrice: number
  bomCost: number
  bestMatchPrice: number
  tierAdjustedPrice: number
  discountPct: number
  netPrice: number
  needsApproval: boolean
  approvalReason: string | null
  pricingDetail: string | null
}

export interface MbomLine {
  mbomLineId: number
  sbomLineId: number
  modelId: number
  lineNumber: number
  materialCode: string
  materialDesc: string
  materialType: string
  quantity: number
  unit: string
  requirementType: string
  substituteGroup: string
  substitutePriority: number
  costComponent: string
  leadTimeDays: number
  sortOrder: number
}

export interface ConfigCompleteResponse {
  validation: ValidationResult
  mbomLines: MbomLine[]
  price: PriceResult
}
