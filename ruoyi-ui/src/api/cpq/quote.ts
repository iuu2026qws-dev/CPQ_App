import request from '@/utils/request'
import type { AxiosPromise } from 'axios'

// 报价单列表
export function listQuote(params: any) { return request({ url: '/cpq/quote/header/list', method: 'get', params }) as AxiosPromise<{ rows: any[]; total: number }> }
// 获取报价单详情
export function getQuote(id: number) { return request({ url: `/cpq/quote/header/${id}`, method: 'get' }) }
// 新增报价单
export function addQuote(data: any) { return request({ url: '/cpq/quote/header', method: 'post', data }) }
// 修改报价单
export function updateQuote(data: any) { return request({ url: '/cpq/quote/header', method: 'put', data }) }
// 删除报价单
export function delQuote(id: number) { return request({ url: `/cpq/quote/header/${id}`, method: 'delete' }) }
