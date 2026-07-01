import request from '@/utils/request'

// ===================== Account (客户) =====================
export interface AccountVo {
  accountId: number
  accountName: string
  accountCode: string
  accountType: string
  industry?: string
  region?: string
  legalRepresentative?: string
  unifiedSocialCreditCode?: string
  contactName?: string
  contactPhone?: string
  contactEmail?: string
  address?: string
  taxId?: string
  createTime?: string
  updateTime?: string
}

export interface AccountBo {
  accountId?: number
  accountName: string
  accountCode: string
  accountType?: string
  industry?: string
  region?: string
  legalRepresentative?: string
  unifiedSocialCreditCode?: string
  contactName?: string
  contactPhone?: string
  contactEmail?: string
  address?: string
  taxId?: string
}

export function listAccounts(params?: Record<string, unknown>) {
  return request.get<{ rows: AccountVo[]; total: number }>('/cpq/customer/account/list', { params })
}

export function getAccount(id: number) {
  return request.get<AccountVo>('/cpq/customer/account/' + id)
}

export function addAccount(data: AccountBo) {
  return request.post('/cpq/customer/account', data)
}

export function updateAccount(data: AccountBo) {
  return request.put('/cpq/customer/account', data)
}

export function delAccount(id: number) {
  return request.delete('/cpq/customer/account/' + id)
}

// ===================== Opportunity (商机) =====================
export interface OpportunityVo {
  opportunityId: number
  opportunityName: string
  opportunityCode: string
  accountId: number
  accountName: string
  stage: string
  amount?: number
  probability?: number
  closeDate?: string
  opportunityType?: string
  source?: string
  ownerId?: number
  ownerName?: string
  contactName?: string
  contactPhone?: string
  description?: string
  nextStep?: string
  createTime?: string
  updateTime?: string
}

export interface OpportunityBo {
  opportunityId?: number
  opportunityName: string
  accountId: number
  stage: string
  amount?: number
  probability?: number
  closeDate?: string
  opportunityType?: string
  source?: string
  ownerId?: number
  ownerName?: string
  contactName?: string
  contactPhone?: string
  description?: string
  nextStep?: string
}

export function listOpportunities(params?: Record<string, unknown>) {
  return request.get<{ rows: OpportunityVo[]; total: number }>('/cpq/crm/opportunity/list', { params })
}

export function getOpportunity(id: number) {
  return request.get<OpportunityVo>('/cpq/crm/opportunity/' + id)
}

export function addOpportunity(data: OpportunityBo) {
  return request.post('/cpq/crm/opportunity', data)
}

export function updateOpportunity(data: OpportunityBo) {
  return request.put('/cpq/crm/opportunity', data)
}

export function delOpportunity(id: number) {
  return request.delete('/cpq/crm/opportunity/' + id)
}

export function promoteOpportunity(id: number, data: { nextStage: string; nextStep?: string }) {
  return request.post('/cpq/crm/opportunity/' + id + '/promote', data)
}

// ===================== Contract (合同) =====================
export interface ContractVo {
  contractId: number
  contractNumber: string
  contractName: string
  accountId: number
  accountName: string
  opportunityId?: number
  opportunityName?: string
  contractType: string
  status: string
  amount?: number
  startDate?: string
  endDate?: string
  signingEntity?: string
  paymentTerms?: string
  ownerId?: number
  ownerName?: string
  createTime?: string
  updateTime?: string
}

export interface ContractBo {
  contractId?: number
  contractName: string
  accountId: number
  opportunityId?: number
  contractType: string
  status?: string
  amount?: number
  startDate?: string
  endDate?: string
  signingEntity?: string
  paymentTerms?: string
  ownerId?: number
  ownerName?: string
  lines?: ContractLineBo[]
}

export interface ContractLineBo {
  lineId?: number
  contractId?: number
  productCode: string
  productName: string
  quantity: number
  unitPrice: number
}

export function listContracts(params?: Record<string, unknown>) {
  return request.get<{ rows: ContractVo[]; total: number }>('/cpq/crm/contract/list', { params })
}

export function getContract(id: number) {
  return request.get<ContractVo>('/cpq/crm/contract/' + id)
}

export function addContract(data: ContractBo) {
  return request.post('/cpq/crm/contract', data)
}

export function updateContract(data: ContractBo) {
  return request.put('/cpq/crm/contract', data)
}

export function delContract(id: number) {
  return request.delete('/cpq/crm/contract/' + id)
}

export function generateContractNumber() {
  return request.get<string>('/cpq/crm/contract/nextNumber')
}

// ===================== Order (订单) =====================
export interface OrderVo {
  orderId: number
  orderNumber: string
  orderName: string
  accountId: number
  accountName: string
  contractId?: number
  contractNumber?: string
  status: string
  amount?: number
  orderDate?: string
  createTime?: string
  updateTime?: string
}

export interface OrderBo {
  orderId?: number
  orderName: string
  accountId: number
  contractId?: number
  status?: string
  amount?: number
  orderDate?: string
  lines?: OrderLineBo[]
}

export interface OrderLineVo {
  lineId: number
  orderId: number
  productCode: string
  productName: string
  quantity: number
  unitPrice: number
  discountPct: number
  taxRate: number
  lineAmount: number
}

export interface OrderLineBo {
  lineId?: number
  orderId?: number
  productCode?: string
  productName?: string
  quantity: number
  unitPrice: number
  discountPct?: number
  taxRate?: number
  lineAmount?: number
}

export function listOrders(params?: Record<string, unknown>) {
  return request.get<{ rows: OrderVo[]; total: number }>('/cpq/crm/order/list', { params })
}

export function getOrder(id: number) {
  return request.get<OrderVo>('/cpq/crm/order/' + id)
}

export function addOrder(data: OrderBo) {
  return request.post('/cpq/crm/order', data)
}

export function updateOrder(data: OrderBo) {
  return request.put('/cpq/crm/order', data)
}

export function delOrder(id: number) {
  return request.delete('/cpq/crm/order/' + id)
}

export function listOrderLines(orderId: number) {
  return request.get<OrderLineVo[]>('/cpq/crm/order/' + orderId + '/lines')
}

export function addOrderLine(data: OrderLineBo) {
  return request.post('/cpq/crm/order/line', data)
}

export function updateOrderLine(data: OrderLineBo) {
  return request.put('/cpq/crm/order/line', data)
}

export function delOrderLine(lineId: number) {
  return request.delete('/cpq/crm/order/line/' + lineId)
}

// ===================== Activity (活动) =====================
export interface ActivityVo {
  activityId: number
  opportunityId?: number
  accountId?: number
  activityType: string
  subject: string
  activityDate: string
  activityTime?: string
  duration?: number
  participants?: string
  result?: string
  nextPlan?: string
  createTime?: string
}

export interface ActivityBo {
  activityId?: number
  opportunityId?: number
  accountId?: number
  activityType: string
  subject: string
  activityDate: string
  activityTime?: string
  duration?: number
  participants?: string
  result?: string
  nextPlan?: string
}

export function listActivities(params?: Record<string, unknown>) {
  return request.get<{ rows: ActivityVo[]; total: number }>('/cpq/crm/activity/list', { params })
}

export function addActivity(data: ActivityBo) {
  return request.post('/cpq/crm/activity', data)
}

export function updateActivity(data: ActivityBo) {
  return request.put('/cpq/crm/activity', data)
}

export function delActivity(id: number) {
  return request.delete('/cpq/crm/activity/' + id)
}
