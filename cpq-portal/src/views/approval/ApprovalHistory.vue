<template>
  <div class="cpq-page">
    <div class="toolbar">
      <el-button @click="$router.back()">返回</el-button>
      <span class="title">审批历史</span>
    </div>

    <!-- 筛选栏 -->
    <el-form :model="query" inline class="filter-form">
      <el-form-item label="状态">
        <el-select v-model="query.status" clearable placeholder="全部状态" @change="handleQuery">
          <el-option label="审批中" value="IN_PROGRESS" />
          <el-option label="已通过" value="APPROVED" />
          <el-option label="已驳回" value="REJECTED" />
          <el-option label="已取消" value="CANCELLED" />
          <el-option label="已过期" value="EXPIRED" />
        </el-select>
      </el-form-item>
      <el-form-item label="报价单号">
        <el-input v-model="query.quoteId" placeholder="报价单ID" clearable style="width:150px" @keyup.enter="handleQuery" />
      </el-form-item>
      <el-form-item>
        <el-button type="primary" @click="handleQuery">搜索</el-button>
        <el-button @click="resetQuery">重置</el-button>
      </el-form-item>
    </el-form>

    <!-- 审批链列表 -->
    <el-table v-loading="loading" :data="chains" stripe border @row-click="handleRowClick">
      <el-table-column prop="chainId" label="审批链ID" width="100" />
      <el-table-column prop="quoteId" label="报价单ID" width="100" />
      <el-table-column prop="ruleId" label="规则ID" width="90" />
      <el-table-column label="进度" width="120">
        <template #default="{ row }">
          <el-progress :percentage="row.totalSteps ? Math.round((row.currentStep || 0) / row.totalSteps * 100) : 0" :status="progressStatus(row.status)" />
        </template>
      </el-table-column>
      <el-table-column label="步骤" width="80">
        <template #default="{ row }">{{ row.currentStep }}/{{ row.totalSteps }}</template>
      </el-table-column>
      <el-table-column label="状态" width="110">
        <template #default="{ row }">
          <el-tag :type="statusTag(row.status)" size="small">{{ statusLabel(row.status) }}</el-tag>
        </template>
      </el-table-column>
      <el-table-column label="SLA" width="80">
        <template #default="{ row }">{{ row.slaHours }}h</template>
      </el-table-column>
      <el-table-column prop="submittedBy" label="提交人" width="80" />
      <el-table-column prop="submittedTime" label="提交时间" width="160" />
      <el-table-column prop="completedTime" label="完成时间" width="160">
        <template #default="{ row }">{{ row.completedTime || '—' }}</template>
      </el-table-column>
      <el-table-column label="耗时" width="100">
        <template #default="{ row }">
          {{ row.submittedTime && row.completedTime ? calcDuration(row.submittedTime, row.completedTime) : '—' }}
        </template>
      </el-table-column>
      <el-table-column label="操作" width="80" fixed="right">
        <template #default="{ row }">
          <el-button size="small" type="primary" link @click.stop="handleViewDetail(row)">详情</el-button>
        </template>
      </el-table-column>
    </el-table>

    <el-empty v-if="!loading && chains.length === 0" description="暂无审批历史记录" />

    <!-- 详情抽屉 -->
    <el-drawer v-model="drawerVisible" title="审批详情" size="500px" destroy-on-close>
      <template v-if="selectedChain">
        <el-descriptions :column="1" border size="small">
          <el-descriptions-item label="审批链ID">{{ selectedChain.chainId }}</el-descriptions-item>
          <el-descriptions-item label="报价单ID">{{ selectedChain.quoteId }}</el-descriptions-item>
          <el-descriptions-item label="审批规则ID">{{ selectedChain.ruleId }}</el-descriptions-item>
          <el-descriptions-item label="当前步骤">{{ selectedChain.currentStep }}/{{ selectedChain.totalSteps }}</el-descriptions-item>
          <el-descriptions-item label="SLA">{{ selectedChain.slaHours }}小时</el-descriptions-item>
          <el-descriptions-item label="状态">
            <el-tag :type="statusTag(selectedChain.status)" size="small">{{ statusLabel(selectedChain.status) }}</el-tag>
          </el-descriptions-item>
          <el-descriptions-item label="提交人">{{ selectedChain.submittedBy }}</el-descriptions-item>
          <el-descriptions-item label="提交时间">{{ selectedChain.submittedTime }}</el-descriptions-item>
          <el-descriptions-item label="完成时间">{{ selectedChain.completedTime || '—' }}</el-descriptions-item>
        </el-descriptions>

        <h4 style="margin-top: 16px;">审批记录</h4>
        <el-timeline>
          <el-timeline-item
            v-for="r in selectedRecords"
            :key="r.recordId"
            :timestamp="r.actionTime"
            :color="recordColor(r.action || '')"
            placement="top"
          >
            <el-card shadow="hover" size="small">
              <p style="margin:0"><strong>{{ r.approverName }}</strong> — {{ actionLabel(r.action || '') }}</p>
              <p v-if="r.comment" style="margin:4px 0 0; color:#606266; font-size:13px">{{ r.comment }}</p>
            </el-card>
          </el-timeline-item>
        </el-timeline>
        <el-empty v-if="selectedRecords.length === 0" description="暂无审批记录" />
      </template>
    </el-drawer>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { listApprovalChain, listApprovalRecord, type ApprovalChainVo, type ApprovalRecordVo } from '@/api/approval'

const router = useRouter()
const loading = ref(false)
const chains = ref<ApprovalChainVo[]>([])
const query = reactive({ status: '', quoteId: '' })

const drawerVisible = ref(false)
const selectedChain = ref<ApprovalChainVo | null>(null)
const selectedRecords = ref<ApprovalRecordVo[]>([])

function statusLabel(s: string) {
  const m: Record<string, string> = { IN_PROGRESS: '审批中', APPROVED: '已通过', REJECTED: '已驳回', CANCELLED: '已取消', EXPIRED: '已过期' }
  return m[s] || s
}

function statusTag(s: string) { 
  const m: Record<string, '' | 'success' | 'warning' | 'danger' | 'info'> = { IN_PROGRESS: 'warning', APPROVED: 'success', REJECTED: 'danger', CANCELLED: 'info', EXPIRED: 'danger' }
  return m[s] || ''
}

function progressStatus(s: string) {
  const m: Record<string, '' | 'success' | 'exception' | 'warning'> = { IN_PROGRESS: '', APPROVED: 'success', REJECTED: 'exception', CANCELLED: 'exception', EXPIRED: 'exception' }
  return m[s] || ''
}

function actionLabel(a: string) {
  const m: Record<string, string> = { APPROVE: '批准', CONDITIONAL_APPROVE: '条件通过', REJECT: '驳回', TRANSFER: '转审', DELEGATE: '委托', ADD_SIGNER: '加签' }
  return m[a] || a
}

function recordColor(a: string) {
  const m: Record<string, string> = { APPROVE: '#67c23a', CONDITIONAL_APPROVE: '#e6a23c', REJECT: '#f56c6c', TRANSFER: '#909399', DELEGATE: '#909399', ADD_SIGNER: '#409eff' }
  return m[a] || '#909399'
}

function calcDuration(start: string, end: string) {
  const diff = new Date(end).getTime() - new Date(start).getTime()
  const hours = Math.floor(diff / 3600000)
  const mins = Math.floor((diff % 3600000) / 60000)
  if (hours > 0) return hours + 'h' + mins + 'm'
  return mins + 'm'
}

async function handleQuery() {
  loading.value = true
  try {
    const params: Record<string, unknown> = {}
    if (query.status) params.status = query.status
    if (query.quoteId) params.quoteId = Number(query.quoteId)
    const res = await listApprovalChain(params)
    chains.value = Array.isArray(res) ? res : ((res as any).rows || [])
  } finally { loading.value = false }
}

function resetQuery() { query.status = ''; query.quoteId = ''; handleQuery() }

async function handleRowClick(row: ApprovalChainVo) {
  selectedChain.value = row
  drawerVisible.value = true
  try {
    const res = await listApprovalRecord(row.chainId!)
    selectedRecords.value = Array.isArray(res) ? res : (res as any)
  } catch { selectedRecords.value = [] }
}

function handleViewDetail(row: ApprovalChainVo) { handleRowClick(row) }

onMounted(() => { handleQuery() })
</script>

<style scoped>
.cpq-page { padding: 16px; }
.toolbar { margin-bottom: 12px; display: flex; align-items: center; gap: 12px; }
.title { font-size: 15px; font-weight: 500; color: #303133; }
.filter-form { margin-bottom: 16px; }
</style>
