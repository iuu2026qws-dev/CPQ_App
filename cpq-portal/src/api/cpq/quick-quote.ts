import request from '@/utils/request'

export interface QuickQuoteResult {
  quoteNumber?: string
  totalAmount?: number
  status?: string
}

export function createQuickQuote(data: Record<string, any>) {
  return request<QuickQuoteResult>({ url: '/cpq/quote/quick/create', method: 'post', data })
}

export function getSimilarQuotes(customerId: number, productCategory?: string) {
  return request<QuickQuoteResult[]>({ url: '/cpq/quote/quick/similar', method: 'get', params: { customerId, productCategory } })
}
