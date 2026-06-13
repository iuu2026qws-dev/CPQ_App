import request from '@/utils/request'

export interface KnowledgeArticle {
  articleId?: number
  title: string
  content: string
  category?: string
  articleType: string
  tags?: string
  viewCount?: number
  status: string
  tenantId?: string
  createTime?: string
  updateTime?: string
}

export function getArticleList(params?: any) { return request.get('/cpq/knowledge/article/list', { params }) }
export function getArticleById(id: number) { return request.get<KnowledgeArticle>(`/cpq/knowledge/article/${id}`) }
export function addArticle(data: KnowledgeArticle) { return request.post('/cpq/knowledge/article', data) }
export function updateArticle(data: KnowledgeArticle) { return request.put('/cpq/knowledge/article', data) }
export function deleteArticle(ids: string) { return request.delete(`/cpq/knowledge/article/${ids}`) }
