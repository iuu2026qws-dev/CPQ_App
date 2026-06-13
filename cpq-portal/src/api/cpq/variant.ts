import request from '@/utils/request'

// ---- 类型定义 ----

export interface CpqProductVariantVo {
  variantId: number
  modelId: number
  variantCode: string
  variantName: string
  attributes: string  // JSON string
  defaultBomId?: number
  basePrice: number
  thumbnailUrl?: string
  isDefault: string
  status: string
  tenantId?: string
  createTime?: string
  updateTime?: string
  remark?: string
}

export interface CpqProductVariantBo {
  modelId: number
  variantCode: string
  variantName: string
  attributes: string  // JSON string: {"attr_name":"attr_value",...}
  defaultBomId?: number
  basePrice?: number
  thumbnailUrl?: string
  isDefault?: string
  status?: string
  variantId?: number  // 编辑时需要
}

// ---- API ----

/** 获取某个型号的所有变体 */
export function getVariantList(modelId: number) {
  return request.get<CpqProductVariantVo[]>('/cpq/product/variant/list', {
    params: { modelId }
  })
}

/** 获取变体详情 */
export function getVariantById(variantId: number) {
  return request.get<CpqProductVariantVo>(`/cpq/product/variant/${variantId}`)
}

/** 新增变体 */
export function addVariant(data: CpqProductVariantBo) {
  return request.post('/cpq/product/variant', data)
}

/** 更新变体 */
export function updateVariant(data: CpqProductVariantBo) {
  return request.put('/cpq/product/variant', data)
}

/** 批量查询变体（按ID列表） */
export function getVariantByIds(ids: number[]) {
  return request.get<CpqProductVariantVo[]>('/cpq/product/variant/batch', { params: { ids: ids.join(',') } })
}

/** 删除变体 */
export function deleteVariant(variantId: number) {
  return request.delete(`/cpq/product/variant/${variantId}`)
}
