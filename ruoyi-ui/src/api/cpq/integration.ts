import request from '@/utils/request'

// CRM 连接器
export function syncOpportunity(data: any) { return request({ url: '/integration/crm/sync', method: 'post', data }) }
export function pushQuoteStatus(data: any) { return request({ url: '/integration/crm/push-status', method: 'post', data }) }
// ERP 连接器
export function erpCreateOrder(data: any) { return request({ url: '/integration/erp/order', method: 'post', data }) }
export function erpGetOrderStatus(orderId: string) { return request({ url: `/integration/erp/order/${orderId}/status`, method: 'get' }) }
// PLM 连接器
export function plmSyncProduct(data: any) { return request({ url: '/integration/plm/sync', method: 'post', data }) }
