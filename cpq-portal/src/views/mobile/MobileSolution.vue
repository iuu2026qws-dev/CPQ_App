<template>
  <div class="mobile-solution">
    <div v-if="loading" class="loading-state">
      <el-icon class="spinning" :size="32"><Loading /></el-icon>
      <span>加载方案中...</span>
    </div>

    <div v-else-if="!solutions.length" class="empty-state">
      <el-icon :size="48" color="#ddd"><Document /></el-icon>
      <span>暂无方案</span>
      <button class="create-btn" @click="navigate('/mobile/quote')">创建报价方案</button>
    </div>

    <div v-else class="solution-list">
      <div
        v-for="s in solutions"
        :key="s.solutionId"
        class="solution-card"
        @click="viewSolution(s)"
      >
        <div class="card-header">
          <span class="solution-name">{{ s.solutionName || s.title }}</span>
          <span class="solution-status" :class="s.status">{{ s.status }}</span>
        </div>
        <div class="card-body">
          <span>{{ s.customerName || '—' }}</span>
          <span class="solution-amount">¥{{ formatAmount(s.totalAmount) }}</span>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, inject } from 'vue'
import { useRouter } from 'vue-router'
import { Document, Loading } from '@element-plus/icons-vue'
import { useUserStore } from '@/store/user'

const router = useRouter()
const userStore = useUserStore()
const haptic = inject<(style: string) => void>('haptic')

const loading = ref(true)
const solutions = ref<any[]>([])

function formatAmount(v: any): string {
  if (v == null) return '—'
  return Number(v).toLocaleString('zh-CN', { minimumFractionDigits: 2, maximumFractionDigits: 2 })
}

function navigate(path: string) {
  haptic?.('light')
  router.push(path)
}

function viewSolution(s: any) {
  haptic?.('light')
  router.push(`/solution/${s.solutionId}`)
}

onMounted(async () => {
  try {
    const token = userStore.token
    const r = await fetch('/api/cpq/solution/list?pageNum=1&pageSize=10', {
      headers: { Authorization: `Bearer ${token}`, clientid: 'e5cd7e4891bf95d1d19206ce24a7b32e' }
    })
    const data = await r.json()
    if (data.code === 200 && data.data) {
      solutions.value = data.data.rows || data.data || []
    }
  } catch {} finally { loading.value = false }
})
</script>

<style scoped>
.mobile-solution { padding: 12px 16px; min-height: 100%; }

.loading-state, .empty-state {
  display: flex; flex-direction: column; align-items: center;
  padding: 48px 0; color: #bbb; font-size: 14px; gap: 8px;
}

.create-btn {
  margin-top: 12px; padding: 10px 32px;
  background: #409eff; color: #fff;
  border: none; border-radius: 8px; font-size: 14px; cursor: pointer;
}

.solution-list { display: flex; flex-direction: column; gap: 10px; }
.solution-card {
  background: #fff; border-radius: 10px; padding: 14px;
  box-shadow: 0 1px 3px rgba(0,0,0,0.06); cursor: pointer;
}
.card-header, .card-body {
  display: flex; justify-content: space-between; align-items: center;
  margin-bottom: 4px;
}
.solution-name { font-weight: 600; font-size: 14px; }
.solution-status { font-size: 11px; padding: 2px 8px; border-radius: 10px; background: #f0f0f0; color: #999; }
.solution-amount { font-size: 15px; font-weight: 700; color: #e6a23c; }

.spinning { animation: spin 0.8s linear infinite; }
@keyframes spin { from { transform: rotate(0deg); } to { transform: rotate(360deg); } }
</style>
