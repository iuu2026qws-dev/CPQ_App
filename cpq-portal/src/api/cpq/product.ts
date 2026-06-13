import request from '@/utils/request'

export interface CpqProductModelVo {
  modelId: number
  catalogId: number
  categoryId: number
  modelCode: string
  modelName: string
  description?: string
  configType: string    // STANDARD / ATO / CTO / ETO / BUNDLE
  lifecycleStatus: string
  basePrice: number
  currency: string
  minOrderQty?: number
  leadTimeDays?: number
  defaultBomId?: number
  successorModelId?: number
  categoryPath?: string
  catalogName?: string
  thumbnailUrl?: string
  status: string
  tenantId?: string
  createTime?: string
  updateTime?: string
  remark?: string
}

export interface CpqProductModelBo {
  modelId?: number
  catalogId: number
  categoryId: number
  modelCode: string
  modelName: string
  description?: string
  configType: string
  lifecycleStatus?: string
  basePrice?: number
  currency?: string
  minOrderQty?: number
  leadTimeDays?: number
  defaultBomId?: number
  successorModelId?: number
  thumbnailUrl?: string
  status?: string
}

export interface PageResult<T> {
  rows: T[]
  total: number
}

/** 分页列表 */
export function getModelList(params?: any) {
  return request.get<PageResult<CpqProductModelVo>>('/cpq/product/model/list', { params })
}

/** 详情 */
export function getModelById(modelId: number) {
  return request.get<CpqProductModelVo>(`/cpq/product/model/${modelId}`)
}

/** 新增 */
export function addModel(data: CpqProductModelBo) {
  return request.post('/cpq/product/model', data)
}

/** 编辑 */
export function updateModel(data: CpqProductModelBo) {
  return request.put('/cpq/product/model', data)
}

/** 删除 */
export function deleteModel(modelId: number) {
  return request.delete(`/cpq/product/model/${modelId}`)
}

/** 远程搜索产品型号 */
export function searchModel(keyword: string, configType?: string) {
  return request.get<CpqProductModelVo[]>('/cpq/product/model/search', {
    params: { keyword, configType }
  })
}

/** 批量查找产品型号 */
export function listModelByIds(ids: number[]) {
  return request.get<CpqProductModelVo[]>('/cpq/product/model/listByIds', {
    params: { ids: ids.join(',') }
  })
}
