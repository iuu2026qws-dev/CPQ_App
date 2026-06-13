import request from '@/utils/request'

export interface CpqAbacPolicy {
  policyId?: number
  policyName: string
  policyType: string
  subjectType: string
  subjectValue: string
  attributeKey: string
  attributeValue: string
  status?: string
  createTime?: string
  updateTime?: string
  remark?: string
}

/** ABAC策略列表（支持按名称/类型/主体类型筛选） */
export function getAbacPolicyList(params?: Partial<CpqAbacPolicy>) {
  return request<CpqAbacPolicy[]>({ url: '/cpq/abac/policy/list', method: 'get', params })
}

/** 获取单条ABAC策略 */
export function getAbacPolicy(policyId: number) {
  return request<CpqAbacPolicy>({ url: `/cpq/abac/policy/${policyId}`, method: 'get' })
}

/** 新增ABAC策略 */
export function addAbacPolicy(data: CpqAbacPolicy) {
  return request({ url: '/cpq/abac/policy', method: 'post', data })
}

/** 修改ABAC策略 */
export function updateAbacPolicy(data: CpqAbacPolicy) {
  return request({ url: '/cpq/abac/policy', method: 'put', data })
}

/** 删除ABAC策略 */
export function deleteAbacPolicy(policyIds: number[]) {
  return request({ url: `/cpq/abac/policy/${policyIds.join(',')}`, method: 'delete' })
}
