/**
 * CPQ BOM (SBOM) API 模块
 * 对应后端 CpqSbomController — /cpq/product/sbom/**
 */
import request from '@/utils/request'

// ==================== TypeScript 类型 ====================

export interface SbomHeader {
  sbomHeaderId?: number
  modelId: number
  sbomName: string
  sbomVersion: string
  status: string
  tenantId?: string
  createTime?: string
  updateTime?: string
  remark?: string
}

export interface SbomLine {
  sbomLineId?: number
  sbomHeaderId: number
  parentLineId?: number | null
  level?: number
  lineNumber?: number
  itemCode: string
  itemName: string
  itemType: string           // PHYSICAL / VIRTUAL
  quantity: number
  unit: string
  isRequired: string         // Y / N
  isReplaceable: string      // Y / N
  replacementGroup?: string
  isPhantom: string           // Y / N
  minQty?: number
  maxQty?: number
  priceImpact?: string
  leadTimeDays?: number
  sortOrder?: number
  unitPrice?: number
  costPrice?: number
  children?: SbomLine[]
}

// ==================== Header CRUD ====================

/** 查询SBOM Header列表 */
export function listSbomHeaders(params?: { modelId?: number }) {
  return request.get<SbomHeader[]>('/cpq/product/sbom/header/list', { params })
}

/** 查询单个SBOM Header */
export function getSbomHeader(sbomHeaderId: number) {
  return request.get<SbomHeader>(`/cpq/product/sbom/header/${sbomHeaderId}`)
}

/** 新增SBOM Header */
export function addSbomHeader(data: SbomHeader) {
  return request.post('/cpq/product/sbom/header', data)
}

/** 修改SBOM Header */
export function editSbomHeader(data: SbomHeader) {
  return request.put('/cpq/product/sbom/header', data)
}

/** 删除SBOM Header */
export function deleteSbomHeader(sbomHeaderId: number) {
  return request.delete(`/cpq/product/sbom/header/${sbomHeaderId}`)
}

// ==================== Line CRUD ====================

/** 查询SBOM Line列表 */
export function listSbomLines(params?: { sbomHeaderId?: number }) {
  return request.get<SbomLine[]>('/cpq/product/sbom/line/list', { params })
}

/** 查询单个SBOM Line */
export function getSbomLine(sbomLineId: number) {
  return request.get<SbomLine>(`/cpq/product/sbom/line/${sbomLineId}`)
}

/** 新增SBOM Line */
export function addSbomLine(data: SbomLine) {
  return request.post('/cpq/product/sbom/line', data)
}

/** 修改SBOM Line */
export function editSbomLine(data: SbomLine) {
  return request.put('/cpq/product/sbom/line', data)
}

/** 删除SBOM Line */
export function deleteSbomLine(sbomLineId: number) {
  return request.delete(`/cpq/product/sbom/line/${sbomLineId}`)
}

// ==================== BOM 引擎 ====================

/** 展开BOM树 */
export function explodeBom(sbomHeaderId: number) {
  return request.get<SbomLine[]>(`/cpq/product/sbom/explode/${sbomHeaderId}`)
}

/** 展开扁平BOM */
export function explodeBomFlat(sbomHeaderId: number) {
  return request.get<SbomLine[]>(`/cpq/product/sbom/explode/flat/${sbomHeaderId}`)
}

/** 根据产品ID查询BOM */
export function getBomByProduct(productId: number) {
  return request.get<SbomLine[]>(`/cpq/product/sbom/byProduct/${productId}`)
}
