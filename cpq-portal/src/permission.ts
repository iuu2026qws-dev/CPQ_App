import router from './router'
import { getToken } from '@/utils/auth'
import { useUserStore } from '@/store/user'
import { ElMessage } from 'element-plus'

const whiteList = ['/login']

router.beforeEach(async (to, _from, next) => {
  const token = getToken()

  if (token) {
    if (to.path === '/login') {
      // 已登录 → 跳首页
      next({ path: '/' })
      return
    }
    // 已登录但尚未拉取用户信息
    if (useUserStore().roles.length === 0) {
      try {
        await useUserStore().getInfo()
        next()
      } catch (err: any) {
        await useUserStore().logout()
        // 401/认证失败时不显示错误（登录态过期是正常流程）
        const msg = err?.message || ''
        if (!msg.includes('认证失败') && !msg.includes('401')) {
          ElMessage.error(msg || '获取用户信息失败')
        }
        next(`/login?redirect=${encodeURIComponent(to.fullPath)}`)
      }
    } else {
      next()
    }
  } else {
    // 无 token
    if (whiteList.includes(to.path)) {
      next()
    } else {
      next(`/login?redirect=${encodeURIComponent(to.fullPath)}`)
    }
  }
})
