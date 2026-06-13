/**
 * CPQ 定价管理 API 模块
 * 覆盖：价格手册/条目/规则/阶梯定价/渠道价格/汇率 CRUD
 * 参考：[前端§21.2 pricing-management] [前端§C API映射]
 */
import request from '@/utils/request'

// ==================== 类型定义 ====================

export interface CpqPriceBook {
  priceBookId?: number
  bookName: string
  bookType: string  // STANDARD/CHANNEL/PROMOTION/REGION
  currency: string
  effectiveDate: string
  expiryDate?: string
  priority: number
  status: string
  tenantId?: string
  createTime?: string
  updateTime?: string
  remark?: string
}

export interface CpqPriceBookEntry {
  entryId?: number
  priceBookId: number
  modelId: number
  variantId?: number
  variantCode?: string
  variantName?: string
  itemCode?: string
  regionCode?: string
  channelCode?: string
  listPrice: number
  costPrice?: number
  minPrice?: number
  effectiveDate: string
  expiryDate?: string
  status: string
  bookName?: string
  tenantId?: string
  createTime?: string
  updateTime?: string
  remark?: string
}

export interface CpqPriceRule {
  priceRuleId?: number
  ruleName: string
  ruleType: string  // DISCOUNT/MARKUP/PROMOTION/CONTRACT
  priority: number
  conditionJson?: string
  actionJson: string
  approvalThreshold?: number
  effectiveDate: string
  expiryDate?: string
  status: string
  tenantId?: string
  createTime?: string
  updateTime?: string
  remark?: string
}

export interface CpqVolumeTier {
  tierId?: number
  priceBookEntryId: number
  minQuantity: number
  maxQuantity?: number
  unitPrice: number
  sortOrder: number
  tenantId?: string
  createTime?: string
  updateTime?: string
  remark?: string
}

export interface CpqChannelPrice {
  channelPriceId?: number
  channelCode: string
  modelId: number
  variantId?: number
  variantCode?: string
  variantName?: string
  channelListPrice: number
  channelDiscountPct?: number
  effectiveDate: string
  expiryDate?: string
  status: string
  tenantId?: string
  createTime?: string
  updateTime?: string
  remark?: string
}

export interface CpqCurrencyRate {
  rateId?: number
  fromCurrency: string
  toCurrency: string
  exchangeRate: number
  effectiveDate: string
  status: string
  tenantId?: string
  createTime?: string
  updateTime?: string
  remark?: string
}

// ==================== 价格手册 API ====================

export function getPriceBookList(params?: Partial<CpqPriceBook>) {
  return request.get<CpqPriceBook[]>('/cpq/pricing/pricebook/list', { params })
}

export function getPriceBookById(priceBookId: number) {
  return request.get<CpqPriceBook>(`/cpq/pricing/pricebook/${priceBookId}`)
}

export function addPriceBook(data: CpqPriceBook) {
  return request.post('/cpq/pricing/pricebook', data)
}

export function updatePriceBook(data: CpqPriceBook) {
  return request.put('/cpq/pricing/pricebook', data)
}

export function deletePriceBook(priceBookId: number) {
  return request.delete(`/cpq/pricing/pricebook/${priceBookId}`)
}

// ==================== 价格手册条目 API ====================

export function getEntryList(params?: Partial<CpqPriceBookEntry>) {
  return request.get<CpqPriceBookEntry[]>('/cpq/pricing/entry/list', { params })
}

export function getEntryById(entryId: number) {
  return request.get<CpqPriceBookEntry>(`/cpq/pricing/entry/${entryId}`)
}

export function addEntry(data: CpqPriceBookEntry) {
  return request.post('/cpq/pricing/entry', data)
}

export function updateEntry(data: CpqPriceBookEntry) {
  return request.put('/cpq/pricing/entry', data)
}

export function deleteEntry(entryId: number) {
  return request.delete(`/cpq/pricing/entry/${entryId}`)
}

// ==================== 定价规则 API ====================

export function getPriceRuleList(params?: Partial<CpqPriceRule>) {
  return request.get<CpqPriceRule[]>('/cpq/pricing/rule/list', { params })
}

export function getPriceRuleById(priceRuleId: number) {
  return request.get<CpqPriceRule>(`/cpq/pricing/rule/${priceRuleId}`)
}

export function addPriceRule(data: CpqPriceRule) {
  return request.post('/cpq/pricing/rule', data)
}

export function updatePriceRule(data: CpqPriceRule) {
  return request.put('/cpq/pricing/rule', data)
}

export function deletePriceRule(priceRuleId: number) {
  return request.delete(`/cpq/pricing/rule/${priceRuleId}`)
}

// ==================== 阶梯定价 API ====================

export function getVolumeTierList(params?: Partial<CpqVolumeTier>) {
  return request.get<CpqVolumeTier[]>('/cpq/pricing/volumetier/list', { params })
}

export function getVolumeTierById(tierId: number) {
  return request.get<CpqVolumeTier>(`/cpq/pricing/volumetier/${tierId}`)
}

export function addVolumeTier(data: CpqVolumeTier) {
  return request.post('/cpq/pricing/volumetier', data)
}

export function updateVolumeTier(data: CpqVolumeTier) {
  return request.put('/cpq/pricing/volumetier', data)
}

export function deleteVolumeTier(tierId: number) {
  return request.delete(`/cpq/pricing/volumetier/${tierId}`)
}

// ==================== 渠道价格 API ====================

export function getChannelPriceList(params?: Partial<CpqChannelPrice>) {
  return request.get<CpqChannelPrice[]>('/cpq/pricing/channelprice/list', { params })
}

export function getChannelPriceById(channelPriceId: number) {
  return request.get<CpqChannelPrice>(`/cpq/pricing/channelprice/${channelPriceId}`)
}

export function addChannelPrice(data: CpqChannelPrice) {
  return request.post('/cpq/pricing/channelprice', data)
}

export function updateChannelPrice(data: CpqChannelPrice) {
  return request.put('/cpq/pricing/channelprice', data)
}

export function deleteChannelPrice(channelPriceId: number) {
  return request.delete(`/cpq/pricing/channelprice/${channelPriceId}`)
}

// ==================== 汇率 API ====================

export function getCurrencyRateList(params?: Partial<CpqCurrencyRate>) {
  return request.get<CpqCurrencyRate[]>('/cpq/pricing/currencyrate/list', { params })
}

export function getCurrencyRateById(rateId: number) {
  return request.get<CpqCurrencyRate>(`/cpq/pricing/currencyrate/${rateId}`)
}

export function addCurrencyRate(data: CpqCurrencyRate) {
  return request.post('/cpq/pricing/currencyrate', data)
}

export function updateCurrencyRate(data: CpqCurrencyRate) {
  return request.put('/cpq/pricing/currencyrate', data)
}

export function deleteCurrencyRate(rateId: number) {
  return request.delete(`/cpq/pricing/currencyrate/${rateId}`)
}
