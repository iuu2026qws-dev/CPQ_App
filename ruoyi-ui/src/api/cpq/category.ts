import request from '@/utils/request';

export interface CpqProductCategory {
  categoryId: number;
  parentCategoryId: number | null;
  categoryLevel: number;
  categoryCode: string;
  categoryName: string;
  sortOrder: number;
  status: string;
  tenantId: string;
  parentCategoryName: string;
  children: CpqProductCategory[];
  createTime: string;
  updateTime: string;
  remark: string;
}

export interface CpqProductCategoryForm {
  categoryId?: number;
  parentCategoryId: number | null;
  categoryLevel: number;
  categoryCode: string;
  categoryName: string;
  sortOrder?: number;
  status: string;
}

/** 获取分类树形结构 */
export function treeCategory(query?: Record<string, any>) {
  return request.get<CpqProductCategory[]>('/cpq/product/category/tree', { params: query });
}

/** 获取分类扁平列表 */
export function listCategory(query?: Record<string, any>) {
  return request.get<CpqProductCategory[]>('/cpq/product/category/list', { params: query });
}

/** 按层级查询（1=产品族, 2=产品线, 3=产品系列） */
export function listCategoryByLevel(level: number) {
  return request.get<CpqProductCategory[]>('/cpq/product/category/byLevel/' + level);
}

/** 按父分类查询子分类 */
export function listCategoryByParent(parentId: number | null) {
  const pid = parentId ?? '_root';
  return request.get<CpqProductCategory[]>('/cpq/product/category/byParent/' + pid);
}

/** 查询分类详情 */
export function getCategory(categoryId: number) {
  return request.get<CpqProductCategory>('/cpq/product/category/' + categoryId);
}

/** 新增分类 */
export function addCategory(data: CpqProductCategoryForm) {
  return request.post('/cpq/product/category', data);
}

/** 修改分类 */
export function updateCategory(data: CpqProductCategoryForm) {
  return request.put('/cpq/product/category', data);
}

/** 删除分类 */
export function delCategory(categoryId: number) {
  return request.delete('/cpq/product/category/' + categoryId);
}
