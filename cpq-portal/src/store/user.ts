import { defineStore } from 'pinia'
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { getToken, removeToken, setToken } from '@/utils/auth'
import { login as loginApi, logout as logoutApi, getInfo as getUserInfo } from '@/api/login'

export const useUserStore = defineStore('user', () => {
  const router = useRouter()
  const token = ref(getToken())
  const name = ref('')
  const nickname = ref('')
  const userId = ref<string | number>('')
  const tenantId = ref('')
  const avatar = ref('')
  const roles = ref<Array<string>>([])
  const permissions = ref<Array<string>>([])

  const login = async (userInfo: any): Promise<void> => {
    const res = await loginApi(userInfo)
    if (res && res.access_token) {
      setToken(res.access_token)
      token.value = res.access_token
      return
    }
    throw new Error('登录失败')
  }

  const getInfo = async (): Promise<void> => {
    const res = await getUserInfo()
    if (res) {
      const data = res
      const user = data.user
      if (data.roles && data.roles.length > 0) {
        roles.value = data.roles
        permissions.value = data.permissions
      } else {
        roles.value = ['ROLE_DEFAULT']
      }
      name.value = user.userName
      nickname.value = user.nickName
      avatar.value = user.avatar || ''
      userId.value = user.userId
      tenantId.value = user.tenantId
      return
    }
    throw new Error('获取用户信息失败')
  }

  const logout = async (): Promise<void> => {
    try {
      await logoutApi()
    } catch {
      // 忽略注销 API 错误
    }
    token.value = ''
    roles.value = []
    permissions.value = []
    removeToken()
    router.push('/login')
  }

  return { token, name, nickname, userId, tenantId, avatar, roles, permissions, login, getInfo, logout }
})
