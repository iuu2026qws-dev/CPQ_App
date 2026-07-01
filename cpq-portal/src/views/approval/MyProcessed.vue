<template>
  <div class="cpq-page">
    <div class="page-header">
      <h2>我已审批</h2>
    </div>

    <el-table v-loading="loading" :data="records" stripe>
      <el-table-column prop="recordId" label="审批编号" width="100" />
      <el-table-column label="审批链ID" width="100">
        <template #default="{ row }">{{ row.chainId }}</template>
      </el-table-column>
      <el-table-column label="审批动作" width="100">
        <template #default="{ row }">
          <el-tag :type="actionTag(row.action)" size="small">{{ actionLabel(row.action) }}</el-tag>
        </template>
      </el-table-column>
      <el-table-column prop="comment" label="审批意见" min-width="150" show-overflow-tooltip>
        <template #default="{ row }">{{ row.comment || '—' }}</template>
      </el-table-column>
      <el-table-column prop="actionTime" label="审批时间" width="160" />
      <el-table-column label="操作" width="100" fixed="right">
        <template #default="{ row }">
          <el-button size="small" link type="primary" @click="handleView(row)">查看详情</el-button>
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

    <el-empty v-if="!loading && records.length === 0" description="暂无已审批记录" />
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { listApprovalRecords, type ApprovalRecordVo } from '@/api/approval'
import { useUserStore } from '@/store/user'

const router = useRouter()
const userStore = useUserStore()
const loading = ref(false)
const total = ref(0)
const pageNum = ref(1)
const pageSize = ref(10)
const records = ref<ApprovalRecordVo[]>([])

async function fetchData() {
  loading.value = true
  try {
    const res = await listApprovalRecords({
      pageNum: pageNum.value,
      pageSize: pageSize.value,
      status: 'processed',
      approverId: userStore.userId
    })
    records.value = res.rows || []
    total.value = res.total || 0
  } catch {
    records.value = []
    total.value = 0
  } finally {
    loading.value = false
  }
}

function actionLabel(a?: string) {
  const m: Record<string, string> = { APPROVE: '通过', REJECT: '驳回', CONDITIONAL_APPROVE: '条件通过', TRANSFER: '转审', DELEGATE: '委托', ADD_SIGNER: '加签' }
  return m[a || ''] || a || '—'
}
function actionTag(a?: string) {
  const m: Record<string, '' | 'success' | 'danger' | 'warning' | 'info'> = { APPROVE: 'success', REJECT: 'danger', CONDITIONAL_APPROVE: 'warning', TRANSFER: 'info', DELEGATE: 'info', ADD_SIGNER: '' }
  return m[a || ''] || 'info'
}

function handleView(row: ApprovalRecordVo) {
  router.push('/approval/' + row.chainId)
}

onMounted(() => { fetchData() })
</script>

<style scoped>
.cpq-page { padding: 16px; }
.page-header { display: flex; align-items: center; justify-content: space-between; margin-bottom: 16px; }
.page-header h2 { margin: 0; font-size: 18px; font-weight: 600; color: var(--cpq-text-primary, #303133); }
</style>
