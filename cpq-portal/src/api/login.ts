import request from '@/utils/request'
import type { LoginData, LoginResult } from './types'

const clientId = 'e5cd7e4891bf95d1d19206ce24a7b32e'

export function login(data: LoginData): Promise<LoginResult> {
  return request.post('/auth/login', {
    ...data,
    clientId: data.clientId || clientId,
    grantType: data.grantType || 'password'
  })
}

export function logout(): Promise<void> {
  return request.post('/auth/logout')
}

export function getInfo(): Promise<any> {
  return request.get('/system/user/getInfo')
}
