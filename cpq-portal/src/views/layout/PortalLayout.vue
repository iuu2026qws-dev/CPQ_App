<template>
  <div class="portal-layout">
    <aside class="portal-sidebar">
      <div class="sidebar-header">
        <h1 class="logo">SmartCPQ</h1>
        <span class="logo-sub">智能配置报价</span>
      </div>
      <nav class="sidebar-nav">
        <el-menu
          :key="menuKey"
          :default-active="activePath"
          :default-openeds="openedGroups"
          background-color="transparent"
          text-color="rgba(255,255,255,0.65)"
          active-text-color="#fff"
          :unique-opened="false"
          router
        >
          <el-sub-menu
            v-for="group in menuItems"
            :key="group.label"
            :index="group.label"
          >
            <template #title>
              <el-icon><component :is="group.icon" /></el-icon>
              <span>{{ group.label }}</span>
            </template>
            <el-menu-item
              v-for="child in group.children"
              :key="child.path"
              :index="child.path"
            >
              <el-icon><component :is="child.icon" /></el-icon>
              <span>{{ child.label }}</span>
            </el-menu-item>
          </el-sub-menu>
        </el-menu>
      </nav>
    </aside>
    <main class="portal-main">
      <header class="portal-navbar">
        <el-breadcrumb separator="/">
          <el-breadcrumb-item :to="{ path: '/' }">首页</el-breadcrumb-item>
          <el-breadcrumb-item v-if="currentGroup">{{ currentGroup }}</el-breadcrumb-item>
          <el-breadcrumb-item v-if="currentTitle">{{ currentTitle }}</el-breadcrumb-item>
        </el-breadcrumb>
        <div class="navbar-actions">
          <el-dropdown @command="handleCommand">
            <span class="user-info">
              <el-avatar :size="28" icon="UserFilled" />
              <span class="user-name">{{ userStore.nickname || userStore.name || '用户' }}</span>
              <el-icon><ArrowDown /></el-icon>
            </span>
            <template #dropdown>
              <el-dropdown-menu>
                <el-dropdown-item command="logout">退出登录</el-dropdown-item>
              </el-dropdown-menu>
            </template>
          </el-dropdown>
        </div>
      </header>
      <div class="portal-content">
        <router-view />
      </div>
    </main>
  </div>
</template>

<script setup lang="ts">
import { computed } from 'vue'
import { useRoute } from 'vue-router'
import { ArrowDown } from '@element-plus/icons-vue'
import { useUserStore } from '@/store/user'
import { portalMenuItems, flatMenuItems } from '@/config/menu'

const route = useRoute()
const userStore = useUserStore()

const menuItems = portalMenuItems

/** 当路由跨一级分组切换时，强制 el-menu 重新渲染以正确展开新的父级 */
const menuKey = computed(() => {
  const group = portalMenuItems.find(g =>
    g.children.some(c => route.path === c.path || route.path.startsWith(c.path + '/'))
  )
  return group?.label || 'default'
})

/** 当前激活的菜单路径 */
const activePath = computed(() => route.path)

/** 根据当前路由找到所属的一级菜单分组，默认展开它 */
const openedGroups = computed(() => {
  const group = portalMenuItems.find(g =>
    g.children.some(c => route.path === c.path || route.path.startsWith(c.path + '/'))
  )
  return group ? [group.label] : []
})

/** 面包屑：当前一级菜单分组名 */
const currentGroup = computed(() => {
  const group = portalMenuItems.find(g =>
    g.children.some(c => route.path === c.path || route.path.startsWith(c.path + '/'))
  )
  return group?.label || ''
})

/** 面包屑：当前二级页面标题 */
const currentTitle = computed(() => {
  const item = flatMenuItems.find(m => route.path === m.path || route.path.startsWith(m.path + '/'))
  return item?.label || ''
})

async function handleCommand(command: string) {
  if (command === 'logout') {
    await userStore.logout()
  }
}
</script>

<style scoped lang="scss">
.portal-layout {
  display: flex;
  height: 100vh;
  overflow: hidden;
}

.portal-sidebar {
  width: var(--cpq-sidebar-width);
  background: #1a2332;
  color: #fff;
  display: flex;
  flex-direction: column;
  flex-shrink: 0;
  overflow-y: auto;

  .sidebar-header {
    padding: 20px 16px 16px;
    border-bottom: 1px solid rgba(255,255,255,0.08);
    flex-shrink: 0;
    .logo { font-size: 20px; font-weight: 700; color: #fff; }
    .logo-sub { font-size: 11px; color: rgba(255,255,255,0.45); display: block; margin-top: 2px; }
  }

  .sidebar-nav {
    flex: 1;
    overflow-y: auto;

    // el-menu 暗色主题定制
    :deep(.el-menu) {
      border-right: none;

      // 一级 sub-menu 标题
      .el-sub-menu__title {
        font-size: 14px;
        height: 44px;
        line-height: 44px;
        padding-left: 16px !important;
        &:hover {
          background: rgba(255,255,255,0.06);
          color: #fff;
        }
        .el-icon { margin-right: 10px; }
      }

      // sub-menu 展开时标题高亮
      .el-sub-menu.is-opened > .el-sub-menu__title {
        color: #fff;
      }

      // 二级 menu-item
      .el-menu-item {
        font-size: 13px;
        height: 40px;
        line-height: 40px;
        padding-left: 48px !important;
        border-radius: 0 6px 6px 0;
        margin: 2px 8px 2px 0;
        &:hover {
          background: rgba(255,255,255,0.06);
          color: #fff;
        }
        &.is-active {
          background: var(--cpq-primary);
          color: #fff;
        }
        .el-icon { font-size: 16px; }
      }
    }
  }
}

.portal-main {
  flex: 1;
  display: flex;
  flex-direction: column;
  overflow: hidden;
}

.portal-navbar {
  height: var(--cpq-navbar-height);
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0 24px;
  background: var(--cpq-bg-card);
  border-bottom: 1px solid var(--cpq-border);
  flex-shrink: 0;

  .navbar-actions {
    .user-info {
      display: flex;
      align-items: center;
      gap: 6px;
      font-size: 13px;
      color: var(--cpq-text-secondary);
      cursor: pointer;
      .user-name { display: inline-flex; align-items: center; }
    }
  }
}

.portal-content {
  flex: 1;
  overflow-y: auto;
  padding: 24px;
}
</style>
