import request from '@/utils/request';

export interface CpqProductCatalog {
  catalogId: number;
  catalogName: string;
  catalogType: string;
  effectiveDate: string;
  expiryDate: string;
  status: string;
  tenantId: string;
  createTime: string;
  updateTime: string;
  remark: string;
}

export interface CpqProductCatalogForm {
  catalogId?: number;
  catalogName: string;
  catalogType: string;
  effectiveDate?: string;
  expiryDate?: string;
  status: string;
}

/** 查询产品目录列表 */
export function listCatalog(query?: Record<string, any>) {
  return request.get<CpqProductCatalog[]>('/cpq/product/catalog/list', { params: query });
}

/** 查询产品目录详情 */
export function getCatalog(catalogId: number) {
  return request.get<CpqProductCatalog>('/cpq/product/catalog/' + catalogId);
}

/** 新增产品目录 */
export function addCatalog(data: CpqProductCatalogForm) {
  return request.post('/cpq/product/catalog', data);
}

/** 修改产品目录 */
export function updateCatalog(data: CpqProductCatalogForm) {
  return request.put('/cpq/product/catalog', data);
}

/** 删除产品目录 */
export function delCatalog(catalogId: number) {
  return request.delete('/cpq/product/catalog/' + catalogId);
}
