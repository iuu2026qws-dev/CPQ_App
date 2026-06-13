/** 基础实体类型（运行时非空，供 Vite/esbuild 解析用） */
export interface BaseEntity {
  createBy?: any
  createDept?: any
  createTime?: string
  updateBy?: any
  updateTime?: any
}

export interface PageQuery {
  pageNum: number
  pageSize: number
}
