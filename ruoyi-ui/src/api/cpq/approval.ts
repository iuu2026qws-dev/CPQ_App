import request from '@/utils/request'
import type { AxiosPromise } from 'axios'

export function listApproval(params: any) { return request({ url: '/cpq/approval/record/list', method: 'get', params }) as AxiosPromise<{ rows: any[]; total: number }> }
export function getApproval(id: number) { return request({ url: `/cpq/approval/record/${id}`, method: 'get' }) }
export function processApproval(data: any) { return request({ url: '/cpq/approval/action/process', method: 'post', data }) }
export function listChain(params: any) { return request({ url: '/cpq/approval/chain/list', method: 'get', params }) as AxiosPromise<{ rows: any[]; total: number }> }
