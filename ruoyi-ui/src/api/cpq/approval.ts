import request from '@/utils/request'
import type { AxiosPromise } from 'axios'

export function listApproval(params: any) { return request({ url: '/cpq/approval/record/list', method: 'get', params }) as AxiosPromise<{ rows: any[]; total: number }> }
export function getApproval(id: number) { return request({ url: `/cpq/approval/record/${id}`, method: 'get' }) }
export function processApproval(data: any) { return request({ url: '/cpq/approval/action/process', method: 'post', data }) }
export function listChain(params: any) { return request({ url: '/cpq/approval/chain/list', method: 'get', params }) as AxiosPromise<{ rows: any[]; total: number }> }

// 审批规则 CRUD
export function listApprovalRule(params: any) { return request({ url: '/cpq/approval/rule/list', method: 'get', params }) as AxiosPromise<{ rows: any[]; total: number }> }
export function getApprovalRule(ruleId: number) { return request({ url: `/cpq/approval/rule/${ruleId}`, method: 'get' }) }
export function addApprovalRule(data: any) { return request({ url: '/cpq/approval/rule', method: 'post', data }) }
export function updateApprovalRule(data: any) { return request({ url: '/cpq/approval/rule', method: 'put', data }) }
export function delApprovalRule(ruleId: number) { return request({ url: `/cpq/approval/rule/${ruleId}`, method: 'delete' }) }
export function getAvailableFlows() { return request({ url: '/cpq/approval/rule/available-flows', method: 'get' }) as AxiosPromise<{ data: { flow_code: string; flow_name: string; version: number }[] }> }

// 审批矩阵 CRUD
export function listApprovalMatrix(params: any) { return request({ url: '/cpq/approval/matrix/list', method: 'get', params }) as AxiosPromise<{ rows: any[]; total: number }> }
export function getApprovalMatrix(matrixId: number) { return request({ url: `/cpq/approval/matrix/${matrixId}`, method: 'get' }) }
export function addApprovalMatrix(data: any) { return request({ url: '/cpq/approval/matrix', method: 'post', data }) }
export function updateApprovalMatrix(data: any) { return request({ url: '/cpq/approval/matrix', method: 'put', data }) }
export function delApprovalMatrix(matrixId: number) { return request({ url: `/cpq/approval/matrix/${matrixId}`, method: 'delete' }) }

// 用户/角色 搜索
export function searchUsers(keyword: string) { return request({ url: '/system/user/list', method: 'get', params: { userName: keyword, status: '0', pageSize: 20 } }) }
export function searchRoles(keyword: string) { return request({ url: '/system/role/list', method: 'get', params: { roleName: keyword, status: '0', pageSize: 20 } }) }
