import request from '@/utils/request'

/** 登录请求体 */
export interface LoginBody {
  clientId: string
  grantType: string
  tenantId: string
  username: string
  password: string
  code?: string
  uuid?: string
}

/** 登录响应 */
export interface LoginVo {
  access_token: string
  refresh_token: string
  expire_in: number
  refresh_expire_in: number
  client_id: string
  scope: string
  openid: string
}

/** 用户信息 */
export interface UserInfo {
  user: {
    userId: number
    userName: string
    nickName: string
    avatar: string
    phonenumber: string
    email: string
    deptId: number
    deptName: string
  }
  permissions: string[]
  roles: string[]
}

/** 路由菜单 */
export interface RouterVo {
  name: string
  path: string
  hidden: boolean
  redirect?: string
  component: string
  query?: string
  alwaysShow?: boolean
  meta: {
    title: string
    icon: string
    noCache: boolean
    link?: string
    activeMenu?: string
  }
  children?: RouterVo[]
}

/** 登录 */
export function login(data: LoginBody) {
  return request.post<LoginVo>('/auth/login', data, {
    headers: {
      isToken: false
    }
  })
}

/** 退出登录 */
export function logout() {
  return request.post('/auth/logout')
}

/** 获取当前用户信息 */
export function getUserInfo() {
  return request.get<UserInfo>('/system/user/getInfo')
}

/** 获取前端路由菜单 */
export function getRouters() {
  return request.get<RouterVo[]>('/system/menu/getRouters')
}

/** 获取租户列表 */
export function getTenantList() {
  return request.get('/auth/tenant/list')
}
