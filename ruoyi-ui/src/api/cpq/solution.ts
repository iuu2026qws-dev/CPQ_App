import request from '@/utils/request'
import type { AxiosPromise } from 'axios'

export function listSolution(params: any) { return request({ url: '/cpq/quote/solution/list', method: 'get', params }) as AxiosPromise<{ rows: any[]; total: number }> }
export function getSolution(id: number) { return request({ url: `/cpq/quote/solution/${id}`, method: 'get' }) }
export function addSolution(data: any) { return request({ url: '/cpq/quote/solution', method: 'post', data }) }
export function updateSolution(data: any) { return request({ url: '/cpq/quote/solution', method: 'put', data }) }
export function delSolution(id: number) { return request({ url: `/cpq/quote/solution/${id}`, method: 'delete' }) }
