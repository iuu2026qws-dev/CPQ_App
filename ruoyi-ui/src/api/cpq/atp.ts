import request from '@/utils/request'
import type { AxiosPromise } from 'axios'

export function checkAtp(params: any) { return request({ url: '/cpq/atp/check', method: 'get', params }) }
export function batchAtp(data: any) { return request({ url: '/cpq/atp/batch', method: 'post', data }) }
export function getAlternative(params: any) { return request({ url: '/cpq/atp/alternative', method: 'get', params }) }
