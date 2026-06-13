import { ref } from 'vue'
import { createRouter, createWebHistory } from 'vue-router'
import { getToken } from '@/utils/auth'
import { getRouters, type RouterVo } from '@/api/auth'
import type { Component } from 'vue'

/** 自动发现 views/ 下所有 .vue 文件，按后端 component 路径映射 */
const viewsModules = import.meta.glob('@/views/**/*.vue')

/** 将后端 component 路径（如 "system/user/index"）解析为实际 Vue 组件 */
function resolveComponent(componentPath: string): (() => Promise<Component>) | null {
  const clean = componentPath.trim()
  if (!clean || clean === '#' || clean === 'Layout' || clean === 'ParentView') return null

  const filePaths = [
    `${clean}.vue`,
    `${clean}/index.vue`,
  ]

  const keyCandidates = [
    ...filePaths.map(p => `@/views/${p}`),
    ...filePaths.map(p => `src/views/${p}`),
    ...filePaths.map(p => `/src/views/${p}`),
    ...filePaths.map(p => `views/${p}`),
  ]

  for (const key of keyCandidates) {
    if (viewsModules[key]) {
      return viewsModules[key] as () => Promise<Component>
    }
  }
  console.warn(`[Router] 组件未找到: ${componentPath}`, '尝试路径:', keyCandidates)
  return null
}

const Placeholder = () => import('@/views/placeholder/index.vue')

const LayoutRouteName = 'Layout'

const router = createRouter({
  history: createWebHistory(),
  routes: [
    {
      path: '/login',
      name: 'Login',
      component: () => import('@/views/login/index.vue'),
      meta: { title: '登录', noAuth: true }
    },
    {
      path: '/',
      name: LayoutRouteName,
      component: () => import('@/layout/index.vue'),
      redirect: '/dashboard',
      children: [
        {
          path: 'dashboard',
          name: 'Dashboard',
          component: () => import('@/views/dashboard/index.vue'),
          meta: { title: '首页工作台' }
        }
      ]
    }
  ]
})

/** 静态路由（供 store/modules/permission.ts 使用） */
export const constantRoutes = [
  {
    path: '/login',
    name: 'Login',
    component: () => import('@/views/login/index.vue'),
    meta: { title: '登录', noAuth: true }
  },
  {
    path: '/',
    name: 'Layout',
    component: () => import('@/layout/index.vue'),
    redirect: '/dashboard',
    children: [
      {
        path: 'dashboard',
        name: 'Dashboard',
        component: () => import('@/views/dashboard/index.vue'),
        meta: { title: '首页工作台' }
      }
    ]
  }
]

/** 动态路由列表（由 store/modules/permission.ts 使用，实际动态路由在 beforeEach 中加载） */
export const dynamicRoutes: any[] = []

/** 动态路由是否已加载 */
let routesReady = false

/** 全局加载中状态，供 App.vue 显示加载遮罩 */
export const routesLoading = ref(true)

/** 由守卫加载的菜单缓存，供 layout 读取避免重复 API 调用 */
let cachedMenus: RouterVo[] | null = null
export function getCachedMenus() {
  return cachedMenus
}

export function isRoutesReady() {
  return routesReady
}

/** 路由守卫：动态路由未加载时直接在守卫中拉取菜单并注册，不跳转加载页 */
router.beforeEach(async (to, _from, next) => {
  const token = getToken()

  // 登录页：已登录跳 dashboard，否则放行
  if (to.path === '/login') {
    // 关闭加载遮罩（登录页不需要等待动态路由加载）
    routesLoading.value = false
    if (token) {
      next('/dashboard')
    } else {
      next()
    }
    return
  }

  // 无 token 跳登录
  if (!token) {
    next({ path: '/login', replace: true })
    return
  }

  // 动态路由未加载：在守卫中直接拉取菜单、注册路由、然后重试本次导航
  if (!routesReady) {
    try {
      const menuList = await getRouters()
      cachedMenus = menuList as RouterVo[]
      addDynamicRoutes(menuList as RouterVo[])
      routesReady = true
      routesLoading.value = false
      // 路由已注册，用 replace 重试同一次导航
      next({ ...to, replace: true })
      return
    } catch {
      routesLoading.value = false
      next('/dashboard')
      return
    }
  }

  routesLoading.value = false
  next()
})

/** 递归将菜单树注册为 Layout 路由的 children */
function addMenuRoutes(menus: RouterVo[], parentPath: string) {
  for (const menu of menus) {
    if (menu.hidden) continue

    const rawPath = (menu.path || '').replace(/^\/+/, '')
    // 防御：后端 NULL path 可能被序列化为 "null" 或 "/null"
    const cleanPath = (rawPath === 'null' || rawPath === '/null') ? '' : rawPath
    const fullPath = parentPath ? `${parentPath}/${cleanPath}` : cleanPath

    if (menu.children && menu.children.length > 0) {
      // 先递归处理子菜单
      addMenuRoutes(menu.children, fullPath)
    }

    // 注册当前菜单的路由（如果有 component）
    if (menu.component && menu.component !== '#' && menu.component !== 'Layout' && menu.component !== 'ParentView') {
      const component = resolveComponent(menu.component) || Placeholder
      console.log('[Router] 注册组件路由:', fullPath, 'component:', menu.component, 'name:', menu.name)
      router.addRoute(LayoutRouteName, {
        path: fullPath,
        name: menu.name || undefined,
        component,
        meta: { title: menu.meta?.title || menu.name }
      })
    } else if (menu.children && menu.children.length > 0) {
      // 目录型菜单（type=M）或 ParentView 没有自己的 component，但有子菜单
      // 注册一个重定向路由，将当前路径重定向到第一个可见子菜单
      const firstVisible = findFirstVisibleChildPath(menu.children, fullPath)
      if (firstVisible) {
        console.log('[Router] 注册重定向路由:', fullPath, '→', firstVisible, 'name:', menu.name)
        router.addRoute(LayoutRouteName, {
          path: fullPath,
          name: menu.name || undefined,
          redirect: firstVisible,
          meta: { title: menu.meta?.title || menu.name }
        })
      } else {
        console.warn('[Router] 目录型菜单未找到可见子路由:', fullPath, 'name:', menu.name)
      }
    }
  }
}

/** 递归查找第一个可见子菜单的完整路径 */
function findFirstVisibleChildPath(children: RouterVo[], parentPath: string): string | null {
  for (const child of children) {
    if (child.hidden) continue
    const cleanPath = (child.path || '').replace(/^\/+/, '')
    const fullPath = `${parentPath}/${cleanPath}`
    if (child.children && child.children.length > 0) {
      const nested = findFirstVisibleChildPath(child.children, fullPath)
      if (nested) return nested
    }
    if (child.component && child.component !== '#' && child.component !== 'Layout' && child.component !== 'ParentView') {
      return fullPath
    }
  }
  return null
}

let registeredRouteNames: (string | number)[] = []

export function addDynamicRoutes(menus: RouterVo[]) {
  for (const name of registeredRouteNames) {
    router.removeRoute(name)
  }
  registeredRouteNames = []

  for (const menu of menus) {
    addMenuRoutes([menu], '')
  }

  const staticNames = new Set([LayoutRouteName, 'Login', 'Dashboard'])
  for (const r of router.getRoutes()) {
    if (r.name && !staticNames.has(r.name as string)) {
      registeredRouteNames.push(r.name)
    }
  }

  // 调试：打印所有已注册路由
  console.log('[Router] 所有已注册路由:')
  for (const r of router.getRoutes()) {
    const children = r.children || []
    for (const c of children) {
      console.log(`  ${c.path} → ${c.redirect ? 'redirect:' + c.redirect : c.name || '(no name)'}`)
    }
  }

  router.addRoute(LayoutRouteName, {
    path: ':pathMatch(.*)*',
    redirect: '/dashboard'
  })

  // 标记路由已就绪
  routesReady = true
}

export function clearDynamicRoutes() {
  for (const name of registeredRouteNames) {
    router.removeRoute(name)
  }
  registeredRouteNames = []
  routesReady = false
  routesLoading.value = true
}

export default router
