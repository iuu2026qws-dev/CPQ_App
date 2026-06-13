import request from '@/utils/request';

export interface CpqProductSupersession {
  supersessionId: number;
  originalModelId: number;
  replacementModelId: number;
  supersessionType: string;
  conditionExpr: string;
  priceImpactPct: number;
  effectiveDate: string;
  status: string;
  tenantId: string;
  originalModelName: string;
  originalModelCode: string;
  replacementModelName: string;
  replacementModelCode: string;
  createTime: string;
}

export interface CpqProductSupersessionForm {
  supersessionId?: number;
  originalModelId: number;
  replacementModelId: number;
  supersessionType: string;
  conditionExpr?: string;
  priceImpactPct?: number;
  effectiveDate?: string;
  status: string;
}

export function listSupersession(query?: Record<string, any>) {
  return request.get<CpqProductSupersession[]>('/cpq/product/supersession/list', { params: query });
}

export function getSupersession(supersessionId: number) {
  return request.get<CpqProductSupersession>('/cpq/product/supersession/' + supersessionId);
}

export function addSupersession(data: CpqProductSupersessionForm) {
  return request.post('/cpq/product/supersession', data);
}

export function updateSupersession(data: CpqProductSupersessionForm) {
  return request.put('/cpq/product/supersession', data);
}

export function delSupersession(supersessionId: number) {
  return request.delete('/cpq/product/supersession/' + supersessionId);
}
