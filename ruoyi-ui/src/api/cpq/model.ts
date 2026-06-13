import request from '@/utils/request';

export interface CpqProductModel {
  modelId: number;
  catalogId: number;
  categoryId: number;
  /** 分类路径（L1 > L2 > L3 拼接展示用） */
  categoryPath: string;
  modelCode: string;
  modelName: string;
  description: string;
  lifecycleStatus: string;
  successorModelId: number;
  basePrice: number;
  currency: string;
  minOrderQty: number;
  leadTimeDays: number;
  /** 配置类型: STANDARD/ATO/CTO/ETO/BUNDLE */
  configType: string;
  defaultBomId: number;
  thumbnailUrl: string;
  status: string;
  tenantId: string;
  catalogName: string;
  createTime: string;
  updateTime: string;
  remark: string;
}

export interface CpqProductModelForm {
  modelId?: number;
  catalogId: number;
  categoryId: number;
  modelCode: string;
  modelName: string;
  description?: string;
  lifecycleStatus?: string;
  successorModelId?: number;
  basePrice?: number;
  currency?: string;
  minOrderQty?: number;
  leadTimeDays?: number;
  /** 配置类型: STANDARD/ATO/CTO/ETO/BUNDLE */
  configType?: string;
  defaultBomId?: number;
  thumbnailUrl?: string;
  status: string;
}

/** 分页查询产品模型列表 */
export function listModel(query?: Record<string, any>) {
  return request.get<{ rows: CpqProductModel[]; total: number }>('/cpq/product/model/list', { params: query });
}

/** 查询产品模型详情 */
export function getModel(modelId: number) {
  return request.get<CpqProductModel>('/cpq/product/model/' + modelId);
}

/** 根据编码查询产品 */
export function getModelByCode(modelCode: string) {
  return request.get<CpqProductModel>('/cpq/product/model/code/' + modelCode);
}

/** 搜索产品 */
export function searchModels(keyword?: string, lifecycleStatus?: string) {
  return request.get<CpqProductModel[]>('/cpq/product/model/search', {
    params: { keyword, lifecycleStatus }
  });
}

/** 新增产品模型 */
export function addModel(data: CpqProductModelForm) {
  return request.post('/cpq/product/model', data);
}

/** 修改产品模型 */
export function updateModel(data: CpqProductModelForm) {
  return request.put('/cpq/product/model', data);
}

/** 删除产品模型 */
export function delModel(modelId: number) {
  return request.delete('/cpq/product/model/' + modelId);
}

/** 批量删除产品模型 */
export function delModels(modelIds: number[]) {
  return request.delete('/cpq/product/model/batch', { data: modelIds });
}
