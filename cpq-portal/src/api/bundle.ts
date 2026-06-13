import request from '@/utils/request'

// ===== Bundle =====
export interface CpqBundleVo {
  bundleId: number
  modelId: number
  bundleType: string
  pricingStrategy: string
  bundleDiscountPct?: number
  isActive: string
  description?: string
  status: string
  tenantId?: string
  createTime?: string
}

export interface CpqBundleBo {
  bundleId?: number
  modelId: number
  bundleType: string
  pricingStrategy: string
  bundleDiscountPct?: number
  isActive: string
  description?: string
  status: string
}

export function getBundleList(params?: any) {
  return request.get<CpqBundleVo[]>('/cpq/product/bundle/list', { params })
}
export function getBundleById(bundleId: number) {
  return request.get<CpqBundleVo>(`/cpq/product/bundle/${bundleId}`)
}
export function addBundle(data: CpqBundleBo) {
  return request.post('/cpq/product/bundle', data)
}
export function updateBundle(data: CpqBundleBo) {
  return request.put('/cpq/product/bundle', data)
}
export function deleteBundle(bundleId: number) {
  return request.delete(`/cpq/product/bundle/${bundleId}`)
}

// ===== Bundle Option Group =====
export interface CpqBundleOptionGroupVo {
  optionGroupId: number
  bundleId: number
  groupName: string
  groupCode: string
  minSelections: number
  maxSelections: number
  isRequired: string
  sortOrder: number
  status: string
}

export interface CpqBundleOptionGroupBo {
  optionGroupId?: number
  bundleId: number
  groupName: string
  groupCode: string
  minSelections: number
  maxSelections: number
  isRequired: string
  sortOrder: number
  status: string
}

export function getBundleOptionGroupList(params?: any) {
  return request.get<CpqBundleOptionGroupVo[]>('/cpq/product/bundleoptiongroup/list', { params })
}
export function getBundleOptionGroupById(optionGroupId: number) {
  return request.get<CpqBundleOptionGroupVo>(`/cpq/product/bundleoptiongroup/${optionGroupId}`)
}
export function addBundleOptionGroup(data: CpqBundleOptionGroupBo) {
  return request.post('/cpq/product/bundleoptiongroup', data)
}
export function updateBundleOptionGroup(data: CpqBundleOptionGroupBo) {
  return request.put('/cpq/product/bundleoptiongroup', data)
}
export function deleteBundleOptionGroup(optionGroupId: number) {
  return request.delete(`/cpq/product/bundleoptiongroup/${optionGroupId}`)
}

// ===== Bundle Option =====
export interface CpqBundleOptionVo {
  optionId: number
  optionGroupId: number
  componentModelId: number
  quantity: number
  unit?: string
  isDefault: string
  priceModifierType: string
  priceModifierValue?: number
  sortOrder: number
  status: string
}

export interface CpqBundleOptionBo {
  optionId?: number
  optionGroupId: number
  componentModelId: number
  quantity: number
  unit?: string
  isDefault: string
  priceModifierType: string
  priceModifierValue?: number
  sortOrder: number
  status: string
}

export function getBundleOptionList(params?: any) {
  return request.get<CpqBundleOptionVo[]>('/cpq/product/bundleoption/list', { params })
}
export function getBundleOptionById(optionId: number) {
  return request.get<CpqBundleOptionVo>(`/cpq/product/bundleoption/${optionId}`)
}
export function addBundleOption(data: CpqBundleOptionBo) {
  return request.post('/cpq/product/bundleoption', data)
}
export function updateBundleOption(data: CpqBundleOptionBo) {
  return request.put('/cpq/product/bundleoption', data)
}
export function deleteBundleOption(optionId: number) {
  return request.delete(`/cpq/product/bundleoption/${optionId}`)
}
