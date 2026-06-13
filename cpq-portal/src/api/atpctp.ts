import request from '@/utils/request'

export async function checkAtp(productId: number, quantity: number) {
  return request.get('/cpq/atp/check', { params: { productId, quantity } })
}
export async function calculateCtp(productId: number, quantity: number, targetDate?: string) {
  return request.get('/cpq/atp/ctp', { params: { productId, quantity, targetDate } })
}
export async function batchCheckAtp(items: Record<number, number>) {
  return request.post('/cpq/atp/batch', items)
}
export async function recommendAlternative(productId: number, quantity: number) {
  return request.get('/cpq/atp/alternative', { params: { productId, quantity } })
}

export interface AtpResult {
  available: boolean; availableQuantity: number; requestedQuantity: number
  inventoryStock: number; materialAvailable: number; capacityAvailable: number
  bottleneck: string; warnings: string[]; estimatedDays: number
}
export interface CtpResult {
  feasible: boolean; deliveryDays: number; deliveryDate: string
  capacityRemaining: number; materialReadinessDays: number; bottleneckProcessDays: number
  milestones: CtpMilestone[]
}
export interface CtpMilestone { name: string; dayOffset: number; status: string; description: string }
export interface AlternativeRecommendation {
  productId: number; productName: string; availableQuantity: number
  deliveryDays: number; reason: string; priceDifference: number
}
