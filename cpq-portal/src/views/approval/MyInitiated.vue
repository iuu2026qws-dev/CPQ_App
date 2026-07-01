<template>
  <div class="cpq-page">
    <div class="page-header">
      <h2>我发起的</h2>
    </div>

    <el-table v-loading="loading" :data="chains" stripe>
      <el-table-column prop="chainId" label="审批链ID" width="100" />
      <el-table-column prop="quoteId" label="报价单ID" width="100" />
      <el-table-column label="进度" width="120">
        <template #default="{ row }">
          <el-progress :percentage="row.totalSteps ? Math.round((row.currentStep || 0) / row.totalSteps * 100) : 0" :status="progressStatus(row.status)" />
        </template>
      </el-table-column>
      <el-table-column label="步骤" width="80">
        <template #default="{ row }">{{ row.currentStep || 0 }}/{{ row.totalSteps || 0 }}</template>
      </el-table-column>
      <el-table-column label="状态" width="110">
        <template #default="{ row }">
          <el-tag :type="statusTag(row.status)" size="small">{{ statusLabel(row.status) }}</el-tag>
        </template>
      </el-table-column>
      <el-table-column prop="submittedTime" label="提交时间" width="160" />
      <el-table-column prop="completedTime" label="完成时间" width="160">
        <template #default="{ row }">{{ row.completedTime || '—' }}</template>
      </el-table-column>
      <el-table-column label="操作" width="100" fixed="right">
        <template #default="{ row }">
          <el-button size="small" link type="primary" @click="handleView(row)">查看</el-button>
        </template>
      </el-table-column>
    </el-table>

    <el-pagination
      v-if="total > 0"
      v-model:current-page="pageNum"
      v-model:page-size="pageSize"
      :total="total"
      layout="total, sizes, prev, pager, next"
      @change="fetchData"
      style="margin-top: 16px; justify-content: flex-end;"
    />

    <el-empty v-if="!loading && chains.length === 0" description="暂无发起的审批" />
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { listApprovalChain, type ApprovalChainVo } from '@/api/approval'
import { useUserStore } from '@/store/user'

const router = useRouter()
const userStore = useUserStore()
const loading = ref(false)
const total = ref(0)
const pageNum = ref(1)
const pageSize = ref(10)
const chains = ref<ApprovalChainVo[]>([])

async function fetchData() {
  loading.value = true
  try {
    const res = await listApprovalChain({
      pageNum: pageNum.value,
      pageSize: pageSize.value,
      submittedBy: userStore.userId
    })
    chains.value = Array.isArray(res) ? res as ApprovalChainVo[] : (res as { rows: ApprovalChainVo[] }).rows || []
    total.value = Array.isArray(res) ? chains.value.length : (res as { rows: ApprovalChainVo[]; total: number }).total || 0
  } catch {
    chains.value = []
    total.value = 0
  } finally {
    loading.value = false
  }
}

function statusLabel(s: string) {
  const m: Record<string, string> = { IN_PROGRESS: '审批中', APPROVED: '已通过', REJECTED: '已驳回', CANCELLED: '已取消', EXPIRED: '已过期' }
  return m[s] || s
}
function statusTag(s: string) {
  const m: Record<string, '' | 'success' | 'warning' | 'danger' | 'info'> = { IN_PROGRESS: 'warning', APPROVED: 'success', REJECTED: 'danger', CANCELLED: 'info', EXPIRED: 'danger' }
  return m[s] || 'info'
}
function progressStatus(s: string) {
  const m: Record<string, '' | 'success' | 'exception' | 'warning'> = { IN_PROGRESS: '', APPROVED: 'success', REJECTED: 'exception', CANCELLED: 'exception', EXPIRED: 'exception' }
  return m[s] || ''
}

function handleView(row: ApprovalChainVo) {
  router.push('/approval/' + row.chainId)
}

onMounted(() => { fetchData() })
</script>

<style scoped>
.cpq-page { padding: 16px; }
.page-header { display: flex; align-items: center; justify-content: space-between; margin-bottom: 16px; }
.page-header h2 { margin: 0; font-size: 18px; font-weight: 600; color: var(--cpq-text-primary, #303133); }
</style>
