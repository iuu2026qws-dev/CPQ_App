import request from '@/utils/request'

export interface CpqPlant {
  plantId?: number
  plantCode: string
  plantName: string
  location?: string
  capacityPerDay?: number
  workingDaysPerYear?: number
  qualityLevel?: string
  status?: string
  createTime?: string
  updateTime?: string
}

export function getPlantList(params?: Partial<CpqPlant>) {
  return request<CpqPlant[]>({ url: '/cpq/plant/list', method: 'get', params })
}

export function getPlant(id: number) {
  return request<CpqPlant>({ url: `/cpq/plant/${id}`, method: 'get' })
}

export function addPlant(data: CpqPlant) {
  return request({ url: '/cpq/plant', method: 'post', data })
}

export function updatePlant(data: CpqPlant) {
  return request({ url: '/cpq/plant', method: 'put', data })
}

export function deletePlant(ids: number[]) {
  return request({ url: `/cpq/plant/${ids.join(',')}`, method: 'delete' })
}
