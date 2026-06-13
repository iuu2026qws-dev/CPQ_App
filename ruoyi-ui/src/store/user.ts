import { defineStore } from 'pinia'
import { ref } from 'vue'
import { login as loginApi, logout as logoutApi, getUserInfo, getRouters, type LoginBody, type UserInfo, type RouterVo } from '@/api/auth'
import { getToken, setToken, removeToken, setRefreshToken, removeRefreshToken, getTenantId, setTenantId } from '@/utils/auth'
import router, { addDynamicRoutes, clearDynamicRoutes } from '@/router'

/** 安全地从 localStorage 读取 JSON 数组 */
function getStoredArray(key: string): string[] {
  try {
    const stored = localStorage.getItem(key)
    return stored ? JSON.parse(stored) : []
  } catch {
    return []
  }
}

export const useUserStore = defineStore('cpqUser', () => {
  const token = ref<string>(getToken() || '')
  const userInfo = ref<UserInfo | null>(null)
  // 页面刷新（F5）后 store 重新初始化，从 localStorage 恢复登录时持久化的权限数据
  const permissions = ref<string[]>(getStoredArray('permissions'))
  const roles = ref<string[]>(getStoredArray('roles'))
  const menus = ref<RouterVo[]>([])
  const tenantId = ref<string>(getTenantId())

  /** 登录 */
  async function login(body: LoginBody) {
    const res = await loginApi(body)
    token.value = res.access_token
    setToken(res.access_token)
    setRefreshToken(res.refresh_token)
    setTenantId(body.tenantId)
    tenantId.value = body.tenantId
    // 获取用户信息和权限
    await loadUserInfo()
    // 获取路由菜单并动态注册路由
    await loadMenus()
    return res
  }

  /** 加载用户信息 */
  async function loadUserInfo() {
    const info = await getUserInfo()
    userInfo.value = info
    permissions.value = info.permissions || []
    roles.value = info.roles || []
    localStorage.setItem('permissions', JSON.stringify(permissions.value))
    localStorage.setItem('roles', JSON.stringify(roles.value))
  }

  /** 加载菜单路由并动态注册 */
  async function loadMenus() {
    const menuList = await getRouters()
    menus.value = menuList
    // 将后端菜单数据注册为 Vue Router 动态路由
    addDynamicRoutes(menuList)
  }

  /** 退出登录 */
  async function logout() {
    try {
      await logoutApi()
    } catch {
      // ignore
    }
    token.value = ''
    userInfo.value = null
    permissions.value = []
    roles.value = []
    menus.value = []
    removeToken()
    removeRefreshToken()
    localStorage.removeItem('permissions')
    localStorage.removeItem('roles')
    clearDynamicRoutes()
    router.push('/login')
  }

  return { token, userInfo, permissions, roles, menus, tenantId, login, logout, loadUserInfo, loadMenus }
})
