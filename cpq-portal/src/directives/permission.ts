import type { Directive, DirectiveBinding } from 'vue'
import { useUserStore } from '@/store/user'

/**
 * v-hasPermi — CPQ 操作权限指令
 * 用法：v-hasPermi="['cpq:quote:add', 'cpq:quote:edit']"
 * 拥有 *:*:* 超级权限的用户直接放行
 */
export const hasPermi: Directive = {
  mounted(el: HTMLElement, binding: DirectiveBinding) {
    const userStore = useUserStore()
    const permissions: string[] = userStore.permissions || []
    const { value } = binding
    if (value && value instanceof Array && value.length > 0) {
      const hasPermission = permissions.some((p: string) => {
        return p === '*:*:*' || value.includes(p)
      })
      if (!hasPermission) {
        el.parentNode && el.parentNode.removeChild(el)
      }
    } else {
      throw new Error("v-hasPermi 需要权限数组，如 v-hasPermi=\"['cpq:quote:add']\"")
    }
  }
}

/**
 * v-hasRole — CPQ 角色权限指令
 * 用法：v-hasRole="['sales_manager', 'pricing_manager']"
 * superadmin / admin 角色直接放行
 */
export const hasRole: Directive = {
  mounted(el: HTMLElement, binding: DirectiveBinding) {
    const userStore = useUserStore()
    const roles: string[] = userStore.roles || []
    const { value } = binding
    if (value && value instanceof Array && value.length > 0) {
      const hasRole = roles.some((r: string) => {
        return r === 'superadmin' || r === 'admin' || value.includes(r)
      })
      if (!hasRole) {
        el.parentNode && el.parentNode.removeChild(el)
      }
    } else {
      throw new Error("v-hasRole 需要角色数组，如 v-hasRole=\"['sales_manager']\"")
    }
  }
}
