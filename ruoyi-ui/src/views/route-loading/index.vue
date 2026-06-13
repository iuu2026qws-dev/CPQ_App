<template>
  <div class="route-loading">
    <div class="loading-card">
      <div class="spinner">
        <div class="spinner-ring"></div>
        <div class="spinner-ring spinner-ring-inner"></div>
      </div>
      <p class="loading-text">加载中...请稍等</p>
    </div>
  </div>
</template>

<script setup lang="ts">
import { onMounted, onUnmounted } from 'vue'
import { isRoutesReady, addDynamicRoutes } from '@/router'
import { useUserStore } from '@/store/user'
import { getRouters, type RouterVo } from '@/api/auth'

const userStore = useUserStore()

let timer: ReturnType<typeof setInterval> | null = null
let timeout: ReturnType<typeof setTimeout> | null = null

function tryNavigate() {
  if (isRoutesReady()) {
    stopPolling()
    const restorePath = sessionStorage.getItem('restorePath')
    if (restorePath && restorePath !== '/route-loading') {
      sessionStorage.removeItem('restorePath')
      // 路由已注册，但 Vue Router 的 SPA 导航可能在动态路由生效前就解析了
      // 使用 location.replace 触发完整页面加载，确保路由匹配正确
      window.location.replace(restorePath)
    } else {
      window.location.replace('/dashboard')
    }
  }
}

function stopPolling() {
  if (timer) {
    clearInterval(timer)
    timer = null
  }
  if (timeout) {
    clearTimeout(timeout)
    timeout = null
  }
}

async function initRoutes() {
  // 如果路由已就绪（Layout onMounted 抢先加载了），直接跳转
  if (isRoutesReady()) {
    tryNavigate()
    return
  }

  // 主动加载菜单和注册路由
  try {
    const menuList = await getRouters()
    userStore.menus = menuList as RouterVo[]
    // 暂存菜单数据到 sessionStorage，用于页面刷新后路由守卫快速恢复
    sessionStorage.setItem('_cached_menus', JSON.stringify(menuList))
    addDynamicRoutes(menuList as RouterVo[])
    // 标记刚完成路由注册，页面重载时跳过加载页
    sessionStorage.setItem('_routes_loaded', '1')
  } catch {
    // ignore, fallback to polling
  }

  tryNavigate()

  if (!isRoutesReady()) {
    timer = setInterval(tryNavigate, 200)
  }

  // 超时保护：10 秒后强制跳转 dashboard
  timeout = setTimeout(() => {
    stopPolling()
    sessionStorage.removeItem('restorePath')
    window.location.replace('/dashboard')
  }, 10000)
}

onMounted(() => {
  initRoutes()
})

onUnmounted(() => {
  stopPolling()
})
</script>

<style scoped>
.route-loading {
  display: flex;
  align-items: center;
  justify-content: center;
  height: 100vh;
  width: 100vw;
  background: #f0f2f5;
}

.loading-card {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 24px;
  padding: 48px 64px;
  background: #fff;
  border-radius: 12px;
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.08);
}

/* 双层旋转圆环 */
.spinner {
  position: relative;
  width: 56px;
  height: 56px;
}

.spinner-ring {
  position: absolute;
  inset: 0;
  border: 3px solid transparent;
  border-top-color: #1a73e8;
  border-radius: 50%;
  animation: spin 0.8s linear infinite;
}

.spinner-ring-inner {
  inset: 10px;
  border-top-color: #4a9af5;
  animation-duration: 0.6s;
  animation-direction: reverse;
}

@keyframes spin {
  to {
    transform: rotate(360deg);
  }
}

.loading-text {
  font-size: 15px;
  color: #5f6368;
  margin: 0;
  letter-spacing: 0.5px;
}
</style>
