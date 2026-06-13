const TOKEN_KEY = 'cpq_token'
const REFRESH_TOKEN_KEY = 'cpq_refresh_token'
const TENANT_KEY = 'cpq_tenant_id'

export function getToken(): string | null {
  return localStorage.getItem(TOKEN_KEY)
}

export function setToken(token: string) {
  localStorage.setItem(TOKEN_KEY, token)
}

export function removeToken() {
  localStorage.removeItem(TOKEN_KEY)
}

export function getRefreshToken(): string | null {
  return localStorage.getItem(REFRESH_TOKEN_KEY)
}

export function setRefreshToken(token: string) {
  localStorage.setItem(REFRESH_TOKEN_KEY, token)
}

export function removeRefreshToken() {
  localStorage.removeItem(REFRESH_TOKEN_KEY)
}

export function getTenantId(): string {
  return localStorage.getItem(TENANT_KEY) || '000000'
}

export function setTenantId(tenantId: string) {
  localStorage.setItem(TENANT_KEY, tenantId)
}
