import request from '@/utils/request'

export interface CpqAttributeOption {
  optionId: number
  modelId: number
  attrName: string
  optionCode: string
  optionLabel: string
  optionValue: string
  isDefault: string
  sortOrder: number
  tenantId: string
  createTime: string
  updateTime: string
  remark: string
}

export interface CpqAttributeOptionForm {
  optionId?: number
  modelId: number
  attrName: string
  optionCode: string
  optionLabel: string
  optionValue: string
  isDefault: string
  sortOrder: number
  remark?: string
}

// 查询属性选项列表
export function listAttributeOption(query?: Record<string, any>) {
  return request.get<{ rows: CpqAttributeOption[]; total: number }>(
    '/cpq/config/attributeoption/list',
    { params: query }
  )
}

// 查询属性选项详情
export function getAttributeOption(optionId: number) {
  return request.get<CpqAttributeOption>('/cpq/config/attributeoption/' + optionId)
}

// 新增属性选项
export function addAttributeOption(data: CpqAttributeOptionForm) {
  return request.post('/cpq/config/attributeoption', data)
}

// 修改属性选项
export function updateAttributeOption(data: CpqAttributeOptionForm) {
  return request.put('/cpq/config/attributeoption', data)
}

// 删除属性选项
export function delAttributeOption(optionId: number) {
  return request.delete('/cpq/config/attributeoption/' + optionId)
}
