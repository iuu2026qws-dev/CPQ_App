<template>
  <div class="cpq-page">
    <div class="page-header">
      <h2>任务看板</h2>
      <div class="header-actions">
        <el-select v-model="filterPriority" placeholder="优先级筛选" clearable style="width:140px" @change="fetchTasks">
          <el-option label="高优先级" value="HIGH" />
          <el-option label="中优先级" value="MEDIUM" />
          <el-option label="低优先级" value="LOW" />
        </el-select>
        <el-select v-model="filterStatus" placeholder="状态筛选" clearable style="width:120px" @change="fetchTasks">
          <el-option label="待领取" value="PENDING" />
          <el-option label="进行中" value="IN_PROGRESS" />
          <el-option label="已完成" value="COMPLETED" />
        </el-select>
      </div>
    </div>

    <el-row :gutter="20" class="stats-row">
      <el-col :span="8">
        <el-card shadow="hover" class="stat-card stat-pending">
          <template #header>待处理任务</template>
          <el-statistic :value="stats.pending" />
        </el-card>
      </el-col>
      <el-col :span="8">
        <el-card shadow="hover" class="stat-card stat-progress">
          <template #header>进行中</template>
          <el-statistic :value="stats.inProgress" />
        </el-card>
      </el-col>
      <el-col :span="8">
        <el-card shadow="hover" class="stat-card stat-done">
          <template #header>已完成</template>
          <el-statistic :value="stats.completed" />
        </el-card>
      </el-col>
    </el-row>

    <el-card shadow="never" class="table-card">
      <template #header>
        <span class="table-title">任务列表</span>
      </template>
      <el-table v-loading="loading" :data="displayTasks" stripe>
        <el-table-column prop="taskName" label="任务名称" min-width="180" />
        <el-table-column prop="priority" label="优先级" width="90">
          <template #default="{ row }">
            <el-tag :type="priorityTag(row.priority)" size="small">{{ priorityLabel(row.priority) }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="status" label="状态" width="100">
          <template #default="{ row }">
            <el-tag :type="statusTag(row.status)" size="small">{{ statusLabel(row.status) }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="deadline" label="截止日期" width="120" />
        <el-table-column label="操作" width="130" fixed="right">
          <template #default="{ row }">
            <el-button v-if="row.status === 'PENDING'" link type="primary" @click="handleTake(row)">领取</el-button>
            <el-button v-if="row.status === 'IN_PROGRESS'" link type="success" @click="handleComplete(row)">完成</el-button>
            <el-button link type="info" @click="handleView(row)">详情</el-button>
          </template>
        </el-table-column>
      </el-table>
      <el-empty v-if="!loading && displayTasks.length === 0" description="暂无任务" />
    </el-card>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { ElMessage } from 'element-plus'

interface TaskItem {
  taskId: number
  taskName: string
  priority: string
  status: string
  deadline: string
}

const loading = ref(false)
const filterPriority = ref('')
const filterStatus = ref('')
const tasks = ref<TaskItem[]>([
  { taskId: 1, taskName: '方案A技术评审', priority: 'HIGH', status: 'PENDING', deadline: '2026-06-15' },
  { taskId: 2, taskName: '报价B合规检查', priority: 'MEDIUM', status: 'IN_PROGRESS', deadline: '2026-06-14' },
  { taskId: 3, taskName: '竞品对标分析', priority: 'LOW', status: 'COMPLETED', deadline: '2026-06-08' },
  { taskId: 4, taskName: '产品配置规则审核', priority: 'HIGH', status: 'PENDING', deadline: '2026-06-16' },
  { taskId: 5, taskName: '价格手册更新', priority: 'MEDIUM', status: 'IN_PROGRESS', deadline: '2026-06-13' },
  { taskId: 6, taskName: 'ECN变更评估', priority: 'HIGH', status: 'COMPLETED', deadline: '2026-06-10' },
])

const stats = computed(() => ({
  pending: tasks.value.filter(t => t.status === 'PENDING').length,
  inProgress: tasks.value.filter(t => t.status === 'IN_PROGRESS').length,
  completed: tasks.value.filter(t => t.status === 'COMPLETED').length,
}))

const displayTasks = computed(() => {
  let list = tasks.value
  if (filterPriority.value) list = list.filter(t => t.priority === filterPriority.value)
  if (filterStatus.value) list = list.filter(t => t.status === filterStatus.value)
  return list
})

function fetchTasks() { /* 预留API对接 */ }

function priorityTag(p: string) {
  const m: Record<string, '' | 'danger' | 'warning' | 'info'> = { HIGH: 'danger', MEDIUM: 'warning', LOW: 'info' }
  return m[p] || ''
}
function priorityLabel(p: string) {
  const m: Record<string, string> = { HIGH: '高', MEDIUM: '中', LOW: '低' }
  return m[p] || p
}
function statusTag(s: string) {
  const m: Record<string, '' | 'warning' | 'primary' | 'success'> = { PENDING: 'warning', IN_PROGRESS: 'primary', COMPLETED: 'success' }
  return m[s] || ''
}
function statusLabel(s: string) {
  const m: Record<string, string> = { PENDING: '待领取', IN_PROGRESS: '进行中', COMPLETED: '已完成' }
  return m[s] || s
}

function handleTake(row: TaskItem) {
  row.status = 'IN_PROGRESS'
  ElMessage.success('已领取任务: ' + row.taskName)
}
function handleComplete(row: TaskItem) {
  row.status = 'COMPLETED'
  ElMessage.success('已完成任务: ' + row.taskName)
}
function handleView(row: TaskItem) {
  ElMessage.info('查看任务详情: ' + row.taskName)
}

onMounted(() => { fetchTasks() })
</script>

<style scoped>
.cpq-page { padding: 16px; }
.page-header { display: flex; align-items: center; justify-content: space-between; margin-bottom: 16px; }
.page-header h2 { margin: 0; font-size: 18px; font-weight: 600; color: var(--cpq-text-primary, #303133); }
.header-actions { display: flex; gap: 12px; }
.stats-row { margin-bottom: 16px; }
.stat-card { text-align: center; }
.stat-pending { border-top: 3px solid #e6a23c; }
.stat-progress { border-top: 3px solid #409eff; }
.stat-done { border-top: 3px solid #67c23a; }
.table-card { margin-top: 0; }
.table-title { font-weight: 500; }
</style>
