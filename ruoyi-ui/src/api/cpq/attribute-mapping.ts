import request from '@/utils/request'

export interface CpqAttributeMapping {
  mappingId: number
  modelId: number
  attrName: string
  attrValue: string
  materialCode: string
  sbomLineId: number
  conditionExpr: string
  sortOrder: number
  tenantId: string
  createTime: string
  updateTime: string
  remark: string
}

export interface CpqAttributeMappingForm {
  mappingId?: number
  modelId: number
  attrName: string
  attrValue: string
  materialCode: string
  sbomLineId?: number
  conditionExpr: string
  sortOrder: number
  remark?: string
}

// 查询属性映射列表
export function listAttributeMapping(query?: Record<string, any>) {
  return request.get<{ rows: CpqAttributeMapping[]; total: number }>(
    '/cpq/config/attributemapping/list',
    { params: query }
  )
}

// 查询属性映射详情
export function getAttributeMapping(mappingId: number) {
  return request.get<CpqAttributeMapping>('/cpq/config/attributemapping/' + mappingId)
}

// 新增属性映射
export function addAttributeMapping(data: CpqAttributeMappingForm) {
  return request.post('/cpq/config/attributemapping', data)
}

// 修改属性映射
export function updateAttributeMapping(data: CpqAttributeMappingForm) {
  return request.put('/cpq/config/attributemapping', data)
}

// 删除属性映射
export function delAttributeMapping(mappingId: number) {
  return request.delete('/cpq/config/attributemapping/' + mappingId)
}
