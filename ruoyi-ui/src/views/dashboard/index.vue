<template>
  <div class="dashboard">
    <div class="welcome-card">
      <h2>{{ greeting }}</h2>
      <p>欢迎使用 SmartCPQ 制造业智能配置报价系统</p>
    </div>

    <!-- 快速入口 -->
    <div class="quick-actions">
      <el-card v-for="action in quickActions" :key="action.title" class="action-card" shadow="hover" @click="router.push(action.path)">
        <el-icon :size="32" :color="action.color"><component :is="action.icon" /></el-icon>
        <span class="action-title">{{ action.title }}</span>
        <span class="action-desc">{{ action.desc }}</span>
      </el-card>
    </div>

    <!-- 统计卡片 -->
    <el-row :gutter="16" class="stats-row">
      <el-col :span="6" v-for="stat in stats" :key="stat.title">
        <el-card shadow="hover" class="stat-card">
          <div class="stat-header">
            <span class="stat-title">{{ stat.title }}</span>
            <el-icon :color="stat.color" :size="24"><component :is="stat.icon" /></el-icon>
          </div>
          <div class="stat-value">{{ stat.value }}</div>
          <div class="stat-trend" :style="{ color: stat.trendUp ? '#0f974a' : '#d93025' }">
            {{ stat.trend }}
          </div>
        </el-card>
      </el-col>
    </el-row>
  </div>
</template>

<script setup lang="ts">
import { computed } from 'vue'
import { useRouter } from 'vue-router'
import { Setting, Document, List, Edit, DataAnalysis } from '@element-plus/icons-vue'
import { useUserStore } from '@/store/user'

const router = useRouter()
const userStore = useUserStore()

const greeting = computed(() => {
  const hour = new Date().getHours()
  const name = userStore.userInfo?.user?.nickName || userStore.userInfo?.user?.userName || '用户'
  if (hour < 12) return `早上好，${name}`
  if (hour < 18) return `下午好，${name}`
  return `晚上好，${name}`
})

const quickActions = [
  { title: '产品目录', desc: '管理产品分类目录', icon: 'Setting', color: '#1a73e8', path: '/cpq/product/catalog' },
  { title: '产品模型', desc: '管理产品模型数据', icon: 'Document', color: '#0f974a', path: '/cpq/product/model' },
  { title: '替代品管理', desc: '产品替代关系维护', icon: 'List', color: '#f9ab00', path: '/cpq/product/supersession' },
  { title: '个人中心', desc: '个人信息与设置', icon: 'Edit', color: '#8b5cf6', path: '/profile' }
]

const stats = [
  { title: '产品目录', value: '--', trend: '即将上线', trendUp: true, icon: 'Setting', color: '#1a73e8' },
  { title: '产品模型', value: '--', trend: '即将上线', trendUp: true, icon: 'Document', color: '#0f974a' },
  { title: '替代关系', value: '--', trend: '即将上线', trendUp: true, icon: 'DataAnalysis', color: '#f9ab00' },
  { title: '活跃用户', value: '--', trend: '开发中', trendUp: true, icon: 'Edit', color: '#8b5cf6' }
]
</script>

<style scoped>
.dashboard {
  max-width: 1200px;
  margin: 0 auto;
}

.welcome-card {
  background: linear-gradient(135deg, #1a73e8, #0f974a);
  color: #fff;
  padding: 32px;
  border-radius: 12px;
  margin-bottom: 24px;
}

.welcome-card h2 {
  font-size: 24px;
  margin: 0 0 8px;
}

.welcome-card p {
  font-size: 14px;
  opacity: 0.85;
  margin: 0;
}

.quick-actions {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 16px;
  margin-bottom: 24px;
}

.action-card {
  text-align: center;
  cursor: pointer;
  transition: transform 0.2s;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 8px;
  padding: 24px 16px;
}

.action-card:hover {
  transform: translateY(-2px);
}

.action-title {
  font-size: 15px;
  font-weight: 600;
  color: #202124;
}

.action-desc {
  font-size: 12px;
  color: #9aa0a6;
}

.stats-row {
  margin: 0 !important;
}

.stat-card {
  padding: 4px 0;
}

.stat-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 8px;
}

.stat-title {
  font-size: 13px;
  color: #9aa0a6;
}

.stat-value {
  font-size: 28px;
  font-weight: 700;
  color: #202124;
  margin-bottom: 4px;
}

.stat-trend {
  font-size: 12px;
}
</style>
