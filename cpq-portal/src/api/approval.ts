import request from '@/utils/request'

// ========== 审批规则 API ==========
export interface ApprovalRuleVo { ruleId: number; ruleName: string; triggerType: string; triggerValue: number; approvalChainJson: string; priority: number; status: string }
export function listApprovalRule(params?: Record<string, unknown>) { return request.get<{ rows: ApprovalRuleVo[]; total: number }>('/cpq/approval/rule/list', { params }) }
export function addApprovalRule(data: Record<string, unknown>) { return request.post('/cpq/approval/rule', data) }
export function updateApprovalRule(data: Record<string, unknown>) { return request.put('/cpq/approval/rule', data) }
export function delApprovalRule(id: number) { return request.delete('/cpq/approval/rule/' + id) }

// ========== 审批链 API ==========
export interface ApprovalChainVo { chainId: number; quoteId: number; ruleId: number; currentStep: number; totalSteps: number; status: string; submittedBy: number; submittedTime: string; completedTime: string; slaHours: number }
export function listApprovalChain(params?: Record<string, unknown>) { return request.get<{ rows: ApprovalChainVo[]; total: number }>('/cpq/approval/chain/list', { params }) }
export function getApprovalChain(chainId: number) { return request.get<ApprovalChainVo>('/cpq/approval/chain/' + chainId) }

// ========== 审批记录 API ==========
export interface ApprovalRecordVo { recordId?: number; chainId?: number; stepNumber?: number; approverId?: number; approverName?: string; action?: string; comment?: string; actionTime?: string; slaDeadline?: string }
export function listApprovalRecord(chainId: number) { return request.get<ApprovalRecordVo[]>('/cpq/approval/record/chain/' + chainId) }
/** 分页查询审批记录（支持 status=pending/processed/initiated） */
export function listApprovalRecords(params?: Record<string, unknown>) { return request.get<{ rows: ApprovalRecordVo[]; total: number }>('/cpq/approval/record/list', { params }) }

// ========== 审批动作 API ==========
export function processApprovalAction(data: { chainId: number; approverId: number; approverName: string; action: string; comment?: string }) {
  return request.post('/cpq/approval/action/process', data)
}
export function escalateApprovalTimeout() { return request.post('/cpq/approval/action/escalate') }

// ========== 审批矩阵 API ==========
export interface ApprovalMatrixVo { matrixId: number; dimensionType: string; dimensionValue: string; approverRole: string; approverIds: string; minApprovals: number; status: string }
export function listApprovalMatrix(params?: Record<string, unknown>) { return request.get<{ rows: ApprovalMatrixVo[]; total: number }>('/cpq/approval/matrix/list', { params }) }
export function addApprovalMatrix(data: Record<string, unknown>) { return request.post('/cpq/approval/matrix', data) }
export function updateApprovalMatrix(data: Record<string, unknown>) { return request.put('/cpq/approval/matrix', data) }
export function delApprovalMatrix(id: number) { return request.delete('/cpq/approval/matrix/' + id) }
