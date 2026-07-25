<template>
  <div class="cpq-page">
    <div class="page-header">
      <h2>我已审批</h2>
    </div>

    <el-table v-loading="loading" :data="records" stripe>
      <el-table-column prop="record_id" label="审批编号" width="100" />
      <el-table-column label="推荐产品" width="200">
        <template #default="{ row }">{{ row.model_code }} {{ row.model_name }}</template>
      </el-table-column>
      <el-table-column label="审批动作" width="100">
        <template #default="{ row }">
          <el-tag :type="actionTag(row.action)" size="small">{{ actionLabel(row.action) }}</el-tag>
        </template>
      </el-table-column>
      <el-table-column prop="comment" label="审批意见" min-width="150" show-overflow-tooltip>
        <template #default="{ row }">{{ row.comment || '—' }}</template>
      </el-table-column>
      <el-table-column prop="action_time" label="审批时间" width="160" />
      <el-table-column label="操作" width="100" fixed="right">
        <template #default="{ row }">
          <el-button size="small" link type="primary" @click="handleView(row)">查看详情</el-button>
        </template>
      </el-table-column>
    </el-table>

    <el-empty v-if="!loading && records.length === 0" description="暂无已审批记录" />
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import request from '@/utils/request'
import { useUserStore } from '@/store/user'

const router = useRouter()
const userStore = useUserStore()
const loading = ref(false)
const records = ref<any[]>([])

async function fetchData() {
  loading.value = true
  try {
    const res: any = await request.get('/cpq/process/processed', {
      params: { approverId: userStore.userId || 1 }
    })
    records.value = res.rows || res.data || res || []
  } catch {
    records.value = []
  } finally {
    loading.value = false
  }
}

function actionLabel(a?: string) {
  const m: Record<string, string> = {
    APPROVED: '通过', REJECTED: '驳回',
    APPROVE: '通过', REJECT: '驳回',
    CONDITIONAL_APPROVE: '条件通过', TRANSFER: '转审',
    DELEGATE: '委托', ADD_SIGNER: '加签'
  }
  return m[a || ''] || a || '—'
}
function actionTag(a?: string) {
  const m: Record<string, '' | 'success' | 'danger' | 'warning' | 'info'> = {
    APPROVED: 'success', REJECTED: 'danger',
    APPROVE: 'success', REJECT: 'danger',
    CONDITIONAL_APPROVE: 'warning', TRANSFER: 'info',
    DELEGATE: 'info', ADD_SIGNER: ''
  }
  return m[a || ''] || 'info'
}

function handleView(row: any) {
  router.push('/approval/' + row.chain_id)
}

onMounted(() => { fetchData() })
</script>

<style scoped>
.cpq-page { padding: 16px; }
.page-header { display: flex; align-items: center; justify-content: space-between; margin-bottom: 16px; }
.page-header h2 { margin: 0; font-size: 18px; font-weight: 600; color: var(--cpq-text-primary, #303133); }
</style>
