import request from '@/utils/request'

export interface IntegrationConfig {
  configId?: number
  systemType: string
  systemName: string
  endpointUrl: string
  authType: string
  authConfigJson?: string
  syncDirection: string
  status: string
  tenantId?: string
  createTime?: string
  updateTime?: string
}

export interface IntegrationMapping {
  mappingId?: number
  configId: number
  sourceField: string
  targetField: string
  transformRule?: string
  defaultValue?: string
  status: string
  tenantId?: string
  createTime?: string
  updateTime?: string
}

export interface SyncLog {
  logId?: number
  configId?: number
  syncType: string
  syncStatus: string
  recordsProcessed?: number
  recordsFailed?: number
  errorMessage?: string
  startedAt?: string
  completedAt?: string
  tenantId?: string
  createTime?: string
}

// Integration Config CRUD
export function getConfigList(params?: any) { return request.get('/cpq/integration/config/list', { params }) }
export function getConfigById(id: number) { return request.get(`/cpq/integration/config/${id}`) }
export function addConfig(data: IntegrationConfig) { return request.post('/cpq/integration/config', data) }
export function updateConfig(data: IntegrationConfig) { return request.put('/cpq/integration/config', data) }
export function deleteConfig(ids: string) { return request.delete(`/cpq/integration/config/${ids}`) }

// Integration Mapping CRUD
export function getMappingList(params?: any) { return request.get('/cpq/integration/mapping/list', { params }) }
export function getMappingById(id: number) { return request.get(`/cpq/integration/mapping/${id}`) }
export function addMapping(data: IntegrationMapping) { return request.post('/cpq/integration/mapping', data) }
export function updateMapping(data: IntegrationMapping) { return request.put('/cpq/integration/mapping', data) }
export function deleteMapping(ids: string) { return request.delete(`/cpq/integration/mapping/${ids}`) }

// Sync Log
export function getSyncLogList(params?: any) { return request.get('/cpq/integration/sync-log/list', { params }) }
export function deleteSyncLog(ids: string) { return request.delete(`/cpq/integration/sync-log/${ids}`) }

// Connectors
export function syncCrmOpportunity(data: any) { return request.post('/cpq/integration/crm/opportunity', data) }
export function createErpOrder(data: any) { return request.post('/cpq/integration/erp/order', data) }
export function syncPlmProduct(data: any) { return request.post('/cpq/integration/plm/product', data) }
