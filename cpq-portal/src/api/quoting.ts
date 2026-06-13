import request from '@/utils/request'

// ========== 报价单 API ==========
// 注意：Snowflake ID 超出 JS 安全整数范围，所有 ID 字段使用 string 类型
export interface QuoteVo {
  quoteId: string; quoteNumber: string; opportunityId: string; accountId: string; accountName: string
  quoteType: string; currency: string; subtotal: number; discountTotal: number; taxTotal: number; grandTotal: number
  status: string; validUntil: string; approvalChainId: string; createdBy: string; createdByName: string
  submittedDate: string; wonDate: string; createTime: string; remark: string
}
export interface QuoteBo { quoteId?: string; quoteNumber?: string; accountId?: string; accountName?: string; quoteType?: string; currency?: string; status?: string; validUntil?: string; remark?: string }

export function listQuote(params: Record<string, unknown>) { return request.get<{ rows: QuoteVo[]; total: number }>('/cpq/quote/header/list', { params }) }
export function getQuote(quoteId: string) { return request.get<QuoteVo>('/cpq/quote/header/' + quoteId) }
export function addQuote(data: QuoteBo) { return request.post('/cpq/quote/header', data) }
export function updateQuote(data: QuoteBo) { return request.put('/cpq/quote/header', data) }
export function delQuote(quoteId: string) { return request.delete('/cpq/quote/header/' + quoteId) }

// ========== 行项目 API ==========
export interface LineItemVo {
  lineId: string; quoteId: string; parentLineId: string; lineNumber: number; modelId: string; sbomLineId: string
  itemType: string; itemCode: string; itemName: string; quantity: number; unit: string
  listPrice: number; unitPrice: number; discountPct: number; netPrice: number; lineTotal: number
  configurationJson: string; atpStatus: string; sortOrder: number
}
export function listLineItem(quoteId: string) { return request.get<{ rows: LineItemVo[]; total: number }>('/cpq/quote/lineitem/list', { params: { quoteId } }) }
export function addLineItem(data: Record<string, unknown>) { return request.post('/cpq/quote/lineitem', data) }
export function updateLineItem(data: Record<string, unknown>) { return request.put('/cpq/quote/lineitem', data) }
export function delLineItem(lineId: string) { return request.delete('/cpq/quote/lineitem/' + lineId) }

// ========== 配置快照 API ==========
export interface SnapshotVo { snapshotId: string; quoteId: string; modelId: string; selectionsJson: string; bomJson: string; snapshotTime: string }
export function listSnapshot(quoteId: string) { return request.get<{ rows: SnapshotVo[]; total: number }>('/cpq/quote/snapshot/list', { params: { quoteId } }) }

// ========== 报价版本 API ==========
export interface VersionVo { versionId?: string; quoteId?: string; versionNumber?: number; versionJson?: string; versionNote?: string; createdTime?: string }
export function listVersion(quoteId: string) { return request.get<{ rows: VersionVo[]; total: number }>('/cpq/quote/version/list', { params: { quoteId } }) }
export function getVersion(versionId: string) { return request.get<VersionVo>('/cpq/quote/version/' + versionId) }

// ========== 报价模板 API ==========
export interface TemplateVo { templateId: string; templateName: string; templateType: string; isDefault: string; status: string; templateJson?: string; templateContent?: string; remark?: string }
export function listTemplate(params?: Record<string, unknown>) { return request.get<{ rows: TemplateVo[]; total: number }>('/cpq/quote/template/list', { params }) }
export function getTemplate(id: string) { return request.get<TemplateVo>('/cpq/quote/template/' + id) }
export function addTemplate(data: Record<string, unknown>) { return request.post('/cpq/quote/template', data) }
export function updateTemplate(data: Record<string, unknown>) { return request.put('/cpq/quote/template', data) }
export function delTemplate(id: string) { return request.delete('/cpq/quote/template/' + id) }
export function getFieldLibrary() { return request.get('/cpq/quote/template/fields') }
export function previewTemplate(id: string) { return request.get<string>('/cpq/quote/template/' + id + '/preview') }
export function setDefaultTemplate(id: string) { return request.put('/cpq/quote/template/' + id + '/default') }
export function saveTemplateDesign(id: string, templateJson: string) { return request.put('/cpq/quote/template/' + id + '/design', { templateJson }) }

// ========== 报价单生成/导出 API ==========
/** 填充模板返回 HTML 字符串（前端预览/打印用） */
export function generateHtml(quoteId: string, templateId: string) { return request.get<string>('/cpq/quote/generate/html', { params: { quoteId, templateId } }) }
/** 下载 PDF（返回 Blob），前端自行创建下载链接 */
export function downloadPdf(quoteId: string, templateId: string) { return request.get<Blob>('/cpq/quote/generate/pdf', { params: { quoteId, templateId }, responseType: 'blob' }) }
/** 下载 Word（返回 Blob），前端自行创建下载链接 */
export function downloadWord(quoteId: string, templateId: string) { return request.get<Blob>('/cpq/quote/generate/word', { params: { quoteId, templateId }, responseType: 'blob' }) }

// ========== 方案文档 API ==========
export interface SolutionVo { documentId?: string; quoteId?: string; documentType?: string; documentName?: string; documentContent?: string; version?: number; status?: string; createTime?: string }
export function listSolution(params?: Record<string, unknown>) { return request.get<{ rows: SolutionVo[]; total: number }>('/cpq/quote/solution/list', { params }) }
export function addSolution(data: Record<string, unknown>) { return request.post('/cpq/quote/solution', data) }
export function updateSolution(data: Record<string, unknown>) { return request.put('/cpq/quote/solution', data) }
export function delSolution(id: string) { return request.delete('/cpq/quote/solution/' + id) }
