<template>
  <div class="mobile-profile">
    <!-- 用户信息卡片 -->
    <div class="profile-card">
      <el-avatar :size="56" icon="UserFilled" class="profile-avatar" />
      <div class="profile-info">
        <div class="profile-name">{{ userStore.nickname || userStore.name || '用户' }}</div>
        <div class="profile-role">{{ roleLabel }}</div>
      </div>
    </div>

    <!-- 功能菜单 -->
    <div class="menu-group">
      <div class="menu-item" @click="navigate('/mobile/approval')">
        <el-icon color="#409eff"><Checked /></el-icon>
        <span>我的审批</span>
        <el-badge :value="pendingCount" :hidden="!pendingCount" />
        <el-icon class="arrow"><ArrowRight /></el-icon>
      </div>
      <div class="menu-item" @click="navigate('/quote')">
        <el-icon color="#67c23a"><Money /></el-icon>
        <span>我的报价</span>
        <el-icon class="arrow"><ArrowRight /></el-icon>
      </div>
      <div class="menu-item" @click="navigate('/knowledge')">
        <el-icon color="#e6a23c"><Reading /></el-icon>
        <span>知识库</span>
        <el-icon class="arrow"><ArrowRight /></el-icon>
      </div>
    </div>

    <div class="menu-group">
      <div class="menu-item" @click="navigate('/settings')">
        <el-icon color="#999"><Setting /></el-icon>
        <span>设置</span>
        <el-icon class="arrow"><ArrowRight /></el-icon>
      </div>
      <div class="menu-item danger" @click="handleLogout">
        <el-icon color="#f56c6c"><SwitchButton /></el-icon>
        <span>退出登录</span>
        <el-icon class="arrow"><ArrowRight /></el-icon>
      </div>
    </div>

    <div class="app-version">CPQ Mobile v1.5.0</div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, inject } from 'vue'
import { useRouter } from 'vue-router'
import {
  UserFilled, Checked, Money, Reading, Setting, SwitchButton, ArrowRight
} from '@element-plus/icons-vue'
import { useUserStore } from '@/store/user'

const router = useRouter()
const userStore = useUserStore()
const haptic = inject<(style: string) => void>('haptic')

const pendingCount = ref(0)

const roleLabel = computed(() => {
  const map: Record<string, string> = {
    sales_manager: '销售经理', sales_rep: '销售代表', pricing_manager: '定价经理',
    product_manager: '产品经理', presales: '售前工程师', executive: '高管',
    auditor: '审计', admin: '管理员', operations: '运营', supply_chain: '供应链',
    channel_partner: '渠道伙伴',
  }
  const roles = userStore.roles || []
  return roles.map(r => map[r] || r).join(', ') || '未分配角色'
})

function navigate(path: string) {
  haptic?.('light')
  router.push(path)
}

async function handleLogout() {
  haptic?.('heavy')
  try {
    await userStore.logout()
  } catch {
    router.push('/login')
  }
}
</script>

<style scoped>
.mobile-profile { padding: 20px 16px; min-height: 100%; }

.profile-card {
  display: flex; align-items: center; gap: 14px;
  padding: 20px; background: linear-gradient(135deg, #409eff, #337ecc);
  border-radius: 16px; margin-bottom: 20px;
}
.profile-avatar { border: 3px solid rgba(255,255,255,0.3); }
.profile-info { color: #fff; }
.profile-name { font-size: 18px; font-weight: 700; }
.profile-role { font-size: 13px; opacity: 0.85; margin-top: 2px; }

.menu-group {
  background: #fff; border-radius: 12px;
  margin-bottom: 14px; overflow: hidden;
}
.menu-item {
  display: flex; align-items: center; gap: 12px;
  padding: 14px 16px; font-size: 14px; cursor: pointer;
  border-bottom: 1px solid #f5f5f5;
  transition: background 0.15s;
}
.menu-item:last-child { border-bottom: none; }
.menu-item:active { background: #f8f8f8; }
.menu-item span { flex: 1; color: #333; }
.menu-item .arrow { color: #ccc; font-size: 14px; }
.menu-item.danger span { color: #f56c6c; }

.app-version { text-align: center; font-size: 12px; color: #ccc; margin-top: 32px; }
</style>
