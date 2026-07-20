import request from '@/utils/request';

/** 产品变体 */
export interface CpqProductVariant {
  variantId: number;
  modelId: number;
  variantCode: string;
  variantName: string;
  attributes: string;       // JSON: {"attr_name":"attr_value", ...}
  defaultBomId: number;
  basePrice: number;
  thumbnailUrl: string;
  isDefault: string;        // '0' or '1'
  status: string;           // '0' 正常 / '1' 停用
  tenantId: string;
  createTime: string;
  updateTime: string;
  remark: string;
}

export interface CpqProductVariantForm {
  variantId?: number;
  modelId: number;
  variantCode: string;
  variantName: string;
  attributes?: string;
  defaultBomId?: number;
  basePrice?: number;
  thumbnailUrl?: string;
  isDefault?: string;
  status?: string;
}

/** 变体BOM */
export interface CpqVariantBom {
  variantId: number;
  modelId: number;
  sbomLineId: number;
  materialCode: string;
  quantity: number;
  effectivityCondition: string;  // JSON: {attr_name: value, ...}
  isDefault: string;
  sortOrder: number;
  tenantId: string;
  createTime: string;
  updateTime: string;
  remark: string;
}

export interface CpqVariantBomForm {
  variantId?: number;
  modelId: number;
  sbomLineId?: number;
  materialCode: string;
  quantity: number;
  effectivityCondition?: string;
  isDefault?: string;
  sortOrder?: number;
}

// ================ 变体 API ================

/** 查询某个产品型号的所有变体 */
export function listVariants(modelId: number) {
  return request.get<CpqProductVariant[]>('/cpq/product/variant/list', { params: { modelId } });
}

/** 获取单个变体 */
export function getVariant(variantId: number) {
  return request.get<{ data: CpqProductVariant }>('/cpq/product/variant/' + variantId);
}

/** 批量查询变体 */
export function batchVariants(ids: number[]) {
  return request.get<CpqProductVariant[]>('/cpq/product/variant/batch', { params: { ids: ids.join(',') } });
}

/** 新增变体 */
export function addVariant(data: CpqProductVariantForm) {
  return request.post('/cpq/product/variant', data);
}

/** 修改变体 */
export function updateVariant(data: CpqProductVariantForm) {
  return request.put('/cpq/product/variant', data);
}

/** 删除变体 */
export function delVariant(variantId: number) {
  return request.delete('/cpq/product/variant/' + variantId);
}

// ================ 变体BOM API ================

/** 查询变体BOM列表（可按modelId过滤） */
export function listVariantBom(query?: Record<string, any>) {
  return request.get<CpqVariantBom[]>('/cpq/config/variantbom/list', { params: query });
}

/** 新增变体BOM */
export function addVariantBom(data: CpqVariantBomForm) {
  return request.post('/cpq/config/variantbom', data);
}

/** 修改变体BOM */
export function updateVariantBom(data: CpqVariantBomForm) {
  return request.put('/cpq/config/variantbom', data);
}

/** 删除变体BOM */
export function delVariantBom(variantId: number) {
  return request.delete('/cpq/config/variantbom/' + variantId);
}
