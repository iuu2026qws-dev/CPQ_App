<template>
  <div class="layout">
    <div class="layout-sidebar" :class="{ collapsed: sidebarCollapsed }">
      <div class="sidebar-logo" @click="goHome">
        <img src="@/assets/logo.svg" v-if="!sidebarCollapsed" class="logo-img" />
        <span v-if="!sidebarCollapsed">SmartCPQ</span>
        <span v-else class="logo-mini">CPQ</span>
      </div>
      <el-scrollbar>
        <el-menu
          :default-active="activeMenu"
          :collapse="sidebarCollapsed"
          :collapse-transition="false"
          background-color="#1e293b"
          text-color="#94a3b8"
          active-text-color="#fff"
          router
        >
          <template v-for="menu in menus" :key="menu.path">
            <el-sub-menu v-if="menu.children && menu.children.length > 0 && !menu.hidden" :index="menu.path">
              <template #title>
                <el-icon v-if="menu.meta?.icon"><component :is="menu.meta.icon" /></el-icon>
                <span>{{ menu.meta?.title || menu.name }}</span>
              </template>
              <!-- 子菜单支持递归渲染：有 children 的渲染为 el-sub-menu，否则为 el-menu-item -->
              <template v-for="child in menu.children" :key="child.path">
                <el-sub-menu
                  v-if="child.children && child.children.length > 0 && !child.hidden"
                  :index="resolvePath(child.path, menu.path)"
                >
                  <template #title>
                    <span>{{ child.meta?.title || child.name }}</span>
                  </template>
                  <el-menu-item
                    v-for="grandchild in child.children"
                    :key="grandchild.path"
                    :index="resolvePath(grandchild.path, resolvePath(child.path, menu.path))"
                    :class="{ 'is-hidden': grandchild.hidden }"
                  >
                    <span>{{ grandchild.meta?.title || grandchild.name }}</span>
                  </el-menu-item>
                </el-sub-menu>
                <el-menu-item
                  v-else-if="!child.hidden"
                  :index="resolvePath(child.path, menu.path)"
                >
                  <span>{{ child.meta?.title || child.name }}</span>
                </el-menu-item>
              </template>
            </el-sub-menu>
            <el-menu-item v-else-if="!menu.hidden" :index="resolvePath(menu.path)">
              <el-icon v-if="menu.meta?.icon"><component :is="menu.meta.icon" /></el-icon>
              <span>{{ menu.meta?.title || menu.name }}</span>
            </el-menu-item>
          </template>
        </el-menu>
      </el-scrollbar>
    </div>

    <div class="layout-main" :class="{ expanded: sidebarCollapsed }">
      <div class="layout-navbar">
        <div class="navbar-left">
          <el-icon class="collapse-btn" @click="toggleSidebar" :size="20">
            <Fold v-if="!sidebarCollapsed" />
            <Expand v-else />
          </el-icon>
          <el-breadcrumb separator="/">
            <el-breadcrumb-item :to="{ path: '/dashboard' }">首页</el-breadcrumb-item>
            <el-breadcrumb-item v-if="currentRoute">{{ currentRoute }}</el-breadcrumb-item>
          </el-breadcrumb>
        </div>
        <div class="navbar-right">
          <el-dropdown @command="handleCommand">
            <span class="user-info">
              <el-avatar :size="32" icon="UserFilled" />
              <span class="user-name">{{ userStore.userInfo?.user?.nickName || userStore.userInfo?.user?.userName || '用户' }}</span>
              <el-icon><ArrowDown /></el-icon>
            </span>
            <template #dropdown>
              <el-dropdown-menu>
                <el-dropdown-item command="profile">个人中心</el-dropdown-item>
                <el-dropdown-item divided command="logout">退出登录</el-dropdown-item>
              </el-dropdown-menu>
            </template>
          </el-dropdown>
        </div>
      </div>

      <div class="layout-content">
        <router-view />
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { computed, ref, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { Fold, Expand, ArrowDown } from '@element-plus/icons-vue'
import { useUserStore } from '@/store/user'
import { getCachedMenus } from '@/router'
import type { RouterVo } from '@/api/auth'

const route = useRoute()
const router = useRouter()
const userStore = useUserStore()
const sidebarCollapsed = ref(false)

const menus = computed<RouterVo[]>(() => userStore.menus)

const activeMenu = computed(() => route.path)

const currentRoute = computed(() => {
  return (route.meta?.title as string) || ''
})

function toggleSidebar() {
  sidebarCollapsed.value = !sidebarCollapsed.value
}

function goHome() {
  router.push('/dashboard')
}

async function handleCommand(command: string) {
  if (command === 'logout') {
    await userStore.logout()
  } else if (command === 'profile') {
    router.push('/profile')
  }
}

function resolvePath(path: string, parentPath?: string): string {
  if (path.startsWith('/')) return path
  if (parentPath) {
    // 去掉 parentPath 前导 /，避免产生双斜杠（如 //system/user）
    const cleanParent = parentPath.replace(/^\/+/, '')
    return `/${cleanParent}/${path}`
  }
  return `/${path}`
}

onMounted(async () => {
  // 菜单数据为空时，优先用守卫缓存的菜单（避免重复 API 调用）
  if (userStore.menus.length === 0) {
    const cached = getCachedMenus()
    if (cached) {
      userStore.menus = cached
    } else {
      try {
        await userStore.loadMenus()
      } catch {
        // ignore
      }
    }
  }
})
</script>

<style scoped>
.layout {
  display: flex;
  height: 100vh;
  overflow: hidden;
}

.layout-sidebar {
  width: 240px;
  background: #1e293b;
  transition: width 0.3s;
  display: flex;
  flex-direction: column;
  flex-shrink: 0;
}

.layout-sidebar.collapsed {
  width: 64px;
}

.sidebar-logo {
  height: 56px;
  display: flex;
  align-items: center;
  justify-content: center;
  color: #fff;
  font-size: 18px;
  font-weight: bold;
  cursor: pointer;
  border-bottom: 1px solid rgba(255,255,255,0.1);
  gap: 8px;
  overflow: hidden;
  white-space: nowrap;
}

.logo-img {
  width: 28px;
  height: 28px;
}

.logo-mini {
  font-size: 16px;
  letter-spacing: 2px;
}

.layout-main {
  flex: 1;
  display: flex;
  flex-direction: column;
  overflow: hidden;
  transition: margin-left 0.3s;
}

.layout-navbar {
  height: 56px;
  background: #fff;
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0 16px;
  box-shadow: 0 1px 4px rgba(0,0,0,0.08);
  flex-shrink: 0;
  z-index: 10;
}

.navbar-left {
  display: flex;
  align-items: center;
  gap: 12px;
}

.collapse-btn {
  cursor: pointer;
  color: #5f6368;
}

.collapse-btn:hover {
  color: #1a73e8;
}

.navbar-right {
  display: flex;
  align-items: center;
}

.user-info {
  display: flex;
  align-items: center;
  gap: 8px;
  cursor: pointer;
  color: #202124;
  font-size: 14px;
}

.user-name {
  max-width: 120px;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.layout-content {
  flex: 1;
  padding: 16px;
  background: #f0f2f5;
  overflow: auto;
}

:deep(.el-menu) {
  border-right: none;
}

:deep(.is-hidden) {
  display: none !important;
}
</style>
