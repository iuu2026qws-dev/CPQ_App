<template>
  <div class="mobile-app">
    <!-- 顶部导航栏 -->
    <header class="mobile-header">
      <div class="header-left">
        <el-icon v-if="showBack" class="back-icon" @click="handleBack">
          <ArrowLeft />
        </el-icon>
      </div>
      <h1 class="header-title">{{ pageTitle }}</h1>
      <div class="header-right">
        <el-badge :value="pendingCount" :hidden="!pendingCount" class="notification-badge">
          <el-icon class="bell-icon"><Bell /></el-icon>
        </el-badge>
      </div>
    </header>

    <!-- 页面内容 -->
    <main class="mobile-content" :class="{ 'has-tabs': showTabs }">
      <router-view v-slot="{ Component, route }">
        <transition name="slide-fade" mode="out-in">
          <component :is="Component" :key="route.path" />
        </transition>
      </router-view>
    </main>

    <!-- 底部 Tab 导航 -->
    <nav v-if="showTabs" class="mobile-tabs">
      <div
        v-for="tab in tabs"
        :key="tab.path"
        class="tab-item"
        :class="{ active: isActive(tab.path) }"
        @click="switchTab(tab)"
      >
        <el-icon class="tab-icon"><component :is="tab.icon" /></el-icon>
        <span class="tab-label">{{ tab.label }}</span>
      </div>
    </nav>

    <!-- 下拉刷新指示器 -->
    <div v-if="refreshing" class="refresh-indicator">
      <el-icon class="spinning"><Loading /></el-icon>
      <span>刷新中...</span>
    </div>

    <!-- Toast 消息 -->
    <transition name="toast-fade">
      <div v-if="toast.visible" class="mobile-toast" :class="toast.type">
        {{ toast.message }}
      </div>
    </transition>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted, provide, watch } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import {
  ArrowLeft, Bell, Loading,
  HomeFilled, Money, Document, UserFilled
} from '@element-plus/icons-vue'
import { useUserStore } from '@/store/user'

const router = useRouter()
const route = useRoute()
const userStore = useUserStore()

// 标签页定义
const tabs = [
  { path: '/mobile/home',      label: '首页',  icon: HomeFilled },
  { path: '/mobile/quote',     label: '报价',  icon: Money },
  { path: '/mobile/solution',  label: '方案',  icon: Document },
  { path: '/mobile/profile',   label: '我的',  icon: UserFilled },
]

const showBack = computed(() => {
  return route.path !== '/mobile/home' && route.path.startsWith('/mobile')
})

const showTabs = computed(() => {
  const path = route.path
  return tabs.some(t => t.path === path) || path === '/mobile/home'
})

const pageTitle = computed(() => {
  const meta = route.meta as any
  return meta?.title || tabs.find(t => isActive(t.path))?.label || 'CPQ'
})

const pendingCount = ref(0)
const refreshing = ref(false)

// Toast 系统
const toast = ref<{ visible: boolean; message: string; type: string }>({
  visible: false, message: '', type: 'success'
})

const showToast = (message: string, type: 'success' | 'error' | 'warning' = 'success') => {
  toast.value = { visible: true, message, type }
  setTimeout(() => { toast.value.visible = false }, 2500)
}
provide('showToast', showToast)

const triggerRefresh = async (callback: () => Promise<void>) => {
  refreshing.value = true
  try {
    await callback()
    showToast('刷新完成', 'success')
  } catch {
    showToast('刷新失败', 'error')
  } finally {
    setTimeout(() => { refreshing.value = false }, 600)
  }
}
provide('triggerRefresh', triggerRefresh)

// 触觉反馈
const haptic = (style: 'light' | 'medium' | 'heavy' = 'light') => {
  if (navigator.vibrate) {
    const durations: Record<string, number> = { light: 10, medium: 25, heavy: 50 }
    navigator.vibrate(durations[style])
  }
}
provide('haptic', haptic)

function isActive(path: string): boolean {
  return route.path === path
}

function switchTab(tab: typeof tabs[0]) {
  haptic('light')
  if (!isActive(tab.path)) {
    router.push(tab.path)
  }
}

function handleBack() {
  haptic('light')
  router.back()
}

onMounted(() => {
  // 加载待审批数量
  if (userStore.token) {
    fetch('/api/cpq/approval/record/list?pageNum=1&pageSize=1', {
      headers: { Authorization: `Bearer ${userStore.token}`, clientid: 'e5cd7e4891bf95d1d19206ce24a7b32e' }
    }).then(r => r.json()).then(data => {
      pendingCount.value = data.total || 0
    }).catch(() => {})
  }
})
</script>

<style scoped>
.mobile-app {
  display: flex;
  flex-direction: column;
  height: 100dvh;
  max-width: 430px;
  margin: 0 auto;
  background: var(--mobile-bg, #f5f7fa);
  overflow: hidden;
  position: relative;
}

.mobile-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  height: 48px;
  padding: 0 16px;
  background: #fff;
  border-bottom: 1px solid #e8e8e8;
  flex-shrink: 0;
  z-index: 100;
}

.header-left, .header-right {
  width: 40px;
  display: flex;
  align-items: center;
}

.back-icon, .bell-icon {
  font-size: 22px;
  color: #333;
  cursor: pointer;
}

.header-title {
  flex: 1;
  text-align: center;
  font-size: 17px;
  font-weight: 600;
  color: #1a1a1a;
  margin: 0;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.notification-badge :deep(.el-badge__content) {
  top: -2px;
  right: -4px;
}

.mobile-content {
  flex: 1;
  overflow-y: auto;
  overflow-x: hidden;
  -webkit-overflow-scrolling: touch;
  padding-bottom: env(safe-area-inset-bottom, 0);
}

.mobile-content.has-tabs {
  padding-bottom: 60px;
}

.mobile-tabs {
  display: flex;
  justify-content: space-around;
  align-items: center;
  height: 56px;
  background: #fff;
  border-top: 1px solid #e8e8e8;
  padding-bottom: env(safe-area-inset-bottom, 0);
  flex-shrink: 0;
  z-index: 100;
}

.tab-item {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 2px;
  cursor: pointer;
  padding: 4px 12px;
  transition: color 0.2s;
  -webkit-tap-highlight-color: transparent;
}

.tab-item .tab-icon {
  font-size: 22px;
  color: #999;
  transition: color 0.2s;
}

.tab-item .tab-label {
  font-size: 10px;
  color: #999;
  transition: color 0.2s;
}

.tab-item.active .tab-icon,
.tab-item.active .tab-label {
  color: #409eff;
}

.refresh-indicator {
  position: absolute;
  top: 56px;
  left: 50%;
  transform: translateX(-50%);
  background: rgba(0,0,0,0.75);
  color: #fff;
  padding: 8px 16px;
  border-radius: 20px;
  display: flex;
  align-items: center;
  gap: 6px;
  font-size: 13px;
  z-index: 200;
}

.spinning {
  animation: spin 0.8s linear infinite;
}

@keyframes spin {
  from { transform: rotate(0deg); }
  to   { transform: rotate(360deg); }
}

/* Toast */
.mobile-toast {
  position: absolute;
  top: 72px;
  left: 50%;
  transform: translateX(-50%);
  padding: 10px 24px;
  border-radius: 8px;
  font-size: 14px;
  z-index: 300;
  white-space: nowrap;
  pointer-events: none;
}

.mobile-toast.success { background: #67c23a; color: #fff; }
.mobile-toast.error   { background: #f56c6c; color: #fff; }
.mobile-toast.warning { background: #e6a23c; color: #fff; }

/* Transitions */
.slide-fade-enter-active, .slide-fade-leave-active {
  transition: all 0.25s ease;
}
.slide-fade-enter-from { opacity: 0; transform: translateX(20px); }
.slide-fade-leave-to   { opacity: 0; transform: translateX(-20px); }

.toast-fade-enter-active, .toast-fade-leave-active {
  transition: all 0.3s ease;
}
.toast-fade-enter-from, .toast-fade-leave-to {
  opacity: 0;
  transform: translate(-50%, -10px);
}
</style>
