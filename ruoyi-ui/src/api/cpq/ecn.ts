import request from '@/utils/request'
import type { AxiosPromise } from 'axios'

export function listEcnOrders(params: any) { return request({ url: '/cpq/ecn/order/list', method: 'get', params }) as AxiosPromise<{ rows: any[]; total: number }> }
export function getEcnOrder(id: number) { return request({ url: `/cpq/ecn/order/${id}`, method: 'get' }) }
export function addEcnOrder(data: any) { return request({ url: '/cpq/ecn/order', method: 'post', data }) }
export function updateEcnOrder(data: any) { return request({ url: '/cpq/ecn/order', method: 'put', data }) }
export function delEcnOrder(id: number) { return request({ url: `/cpq/ecn/order/${id}`, method: 'delete' }) }
export function submitEcn(id: number) { return request({ url: `/cpq/ecn/order/${id}/submit`, method: 'post' }) }
export function analyzeImpact(changeOrderId: number) { return request({ url: `/cpq/ecn/impact/analyze/${changeOrderId}`, method: 'post' }) }
export function propagateChange(changeOrderId: number) { return request({ url: `/cpq/ecn/impact/propagate/${changeOrderId}`, method: 'post' }) }
export function whereUsed(params: any) { return request({ url: '/cpq/ecn/impact/where-used', method: 'get', params }) }
export function listImpact(changeOrderId: number) { return request({ url: '/cpq/ecn/impact/list', method: 'get', params: { changeOrderId } }) as AxiosPromise<{ rows: any[]; total: number }> }
