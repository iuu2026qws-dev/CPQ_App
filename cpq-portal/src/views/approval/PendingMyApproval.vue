<template>
  <div class="cpq-page">
    <div class="page-header">
      <h2>待我审批</h2>
    </div>

    <el-table v-loading="loading" :data="records" stripe>
      <el-table-column prop="recordId" label="审批编号" width="100" />
      <el-table-column label="审批链ID" width="100">
        <template #default="{ row }">{{ row.chainId }}</template>
      </el-table-column>
      <el-table-column prop="approverName" label="当前审批人" width="100" />
      <el-table-column label="审批步骤" width="80">
        <template #default="{ row }">{{ row.stepNumber || 1 }}</template>
      </el-table-column>
      <el-table-column prop="actionTime" label="到达时间" width="160">
        <template #default="{ row }">{{ row.actionTime || row.slaDeadline || '—' }}</template>
      </el-table-column>
      <el-table-column label="SLA截止" width="160">
        <template #default="{ row }">{{ row.slaDeadline || '—' }}</template>
      </el-table-column>
      <el-table-column label="操作" width="200" fixed="right">
        <template #default="{ row }">
          <el-button size="small" type="primary" @click="handleApprove(row)">通过</el-button>
          <el-button size="small" type="danger" @click="handleReject(row)">驳回</el-button>
          <el-button size="small" link type="info" @click="handleView(row)">详情</el-button>
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

    <el-empty v-if="!loading && records.length === 0" description="暂无需您审批的记录" />
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import { listApprovalRecords, processApprovalAction, type ApprovalRecordVo } from '@/api/approval'
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
      status: 'pending',
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

const currentUserId = computed(() => Number(userStore.userId) || 0)
const currentUserName = computed(() => userStore.nickname || userStore.name || '用户')

async function handleApprove(row: ApprovalRecordVo) {
  try {
    await processApprovalAction({
      chainId: row.chainId!,
      approverId: currentUserId.value,
      approverName: currentUserName.value,
      action: 'APPROVE'
    })
    ElMessage.success('已通过')
    fetchData()
  } catch { /* 错误由拦截器统一处理 */ }
}

async function handleReject(row: ApprovalRecordVo) {
  try {
    const { value } = await ElMessageBox.prompt('请输入驳回原因', '驳回', { type: 'warning' })
    await processApprovalAction({
      chainId: row.chainId!,
      approverId: currentUserId.value,
      approverName: currentUserName.value,
      action: 'REJECT',
      comment: value
    })
    ElMessage.success('已驳回')
    fetchData()
  } catch { /* 用户取消 */ }
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
