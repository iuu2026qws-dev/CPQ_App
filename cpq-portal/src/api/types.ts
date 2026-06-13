export interface LoginData {
  tenantId?: string
  username?: string
  password?: string
  clientId: string
  grantType: string
}

export interface LoginResult {
  access_token: string
}
