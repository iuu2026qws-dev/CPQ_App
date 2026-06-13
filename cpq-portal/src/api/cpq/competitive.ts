import request from '@/utils/request'

// Competitor
export function getCompetitorList(params?: any) { return request.get('/cpq/competitive/competitor/list', { params }) }
export function getCompetitorById(id: number) { return request.get(`/cpq/competitive/competitor/${id}`) }
export function addCompetitor(data: any) { return request.post('/cpq/competitive/competitor', data) }
export function updateCompetitor(data: any) { return request.put('/cpq/competitive/competitor', data) }
export function deleteCompetitor(ids: string) { return request.delete(`/cpq/competitive/competitor/${ids}`) }

// Competitor Product
export function getCompetitorProductList(params?: any) { return request.get('/cpq/competitive/product/list', { params }) }
export function addCompetitorProduct(data: any) { return request.post('/cpq/competitive/product', data) }
export function updateCompetitorProduct(data: any) { return request.put('/cpq/competitive/product', data) }
export function deleteCompetitorProduct(ids: string) { return request.delete(`/cpq/competitive/product/${ids}`) }

// Comparison
export function getComparisonList(params?: any) { return request.get('/cpq/competitive/comparison/list', { params }) }
export function addComparison(data: any) { return request.post('/cpq/competitive/comparison', data) }
export function updateComparison(data: any) { return request.put('/cpq/competitive/comparison', data) }
export function deleteComparison(ids: string) { return request.delete(`/cpq/competitive/comparison/${ids}`) }

// Recommendation
export function getRecommendationList(params?: any) { return request.get('/cpq/competitive/recommendation/list', { params }) }
export function addRecommendation(data: any) { return request.post('/cpq/competitive/recommendation', data) }
export function updateRecommendation(data: any) { return request.put('/cpq/competitive/recommendation', data) }
export function deleteRecommendation(ids: string) { return request.delete(`/cpq/competitive/recommendation/${ids}`) }

// Analysis services
export function getAnalysisRecommend(productId: number) { return request.get(`/cpq/competitive/analysis/recommend/${productId}`) }
