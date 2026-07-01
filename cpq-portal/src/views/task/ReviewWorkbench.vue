<template>
  <div class="cpq-page">
    <div class="page-header">
      <h2>评审工作台</h2>
      <div class="header-actions">
        <el-select v-model="filterStatus" placeholder="状态筛选" clearable style="width:130px" @change="fetchReviews">
          <el-option label="待评审" value="PENDING" />
          <el-option label="已通过" value="PASSED" />
          <el-option label="已驳回" value="REJECTED" />
        </el-select>
      </div>
    </div>

    <el-row :gutter="20" class="stats-row">
      <el-col :span="6">
        <el-card shadow="hover" class="stat-card stat-pending">
          <template #header>待评审</template>
          <el-statistic :value="stats.pending" />
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card shadow="hover" class="stat-card stat-passed">
          <template #header>已通过</template>
          <el-statistic :value="stats.passed" />
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card shadow="hover" class="stat-card stat-rejected">
          <template #header>已驳回</template>
          <el-statistic :value="stats.rejected" />
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card shadow="hover" class="stat-card stat-rate">
          <template #header>通过率</template>
          <el-statistic :value="stats.passRate + '%'" />
        </el-card>
      </el-col>
    </el-row>

    <el-card shadow="never" class="table-card">
      <template #header>
        <span class="table-title">评审列表</span>
      </template>
      <el-table v-loading="loading" :data="displayReviews" stripe @row-click="handleRowClick">
        <el-table-column prop="reviewId" label="评审编号" width="100" />
        <el-table-column prop="title" label="评审标题" min-width="200" />
        <el-table-column prop="reviewer" label="评审人" width="100" />
        <el-table-column prop="status" label="状态" width="100">
          <template #default="{ row }">
            <el-tag :type="statusTag(row.status)" size="small">{{ statusLabel(row.status) }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="reviewDate" label="评审日期" width="120" />
        <el-table-column label="操作" width="180" fixed="right">
          <template #default="{ row }">
            <el-button link type="primary" @click.stop="handleViewDetail(row)">查看详情</el-button>
            <el-button v-if="row.status === 'PENDING'" link type="success" @click.stop="handlePass(row)">通过</el-button>
            <el-button v-if="row.status === 'PENDING'" link type="danger" @click.stop="handleReject(row)">驳回</el-button>
          </template>
        </el-table-column>
      </el-table>
      <el-empty v-if="!loading && displayReviews.length === 0" description="暂无评审记录" />
    </el-card>

    <!-- 详情抽屉 -->
    <el-drawer v-model="drawerVisible" title="评审详情" size="500px" destroy-on-close>
      <template v-if="selectedReview">
        <el-descriptions :column="1" border size="small">
          <el-descriptions-item label="评审编号">{{ selectedReview.reviewId }}</el-descriptions-item>
          <el-descriptions-item label="评审标题">{{ selectedReview.title }}</el-descriptions-item>
          <el-descriptions-item label="评审人">{{ selectedReview.reviewer }}</el-descriptions-item>
          <el-descriptions-item label="状态">
            <el-tag :type="statusTag(selectedReview.status)" size="small">{{ statusLabel(selectedReview.status) }}</el-tag>
          </el-descriptions-item>
          <el-descriptions-item label="评审日期">{{ selectedReview.reviewDate }}</el-descriptions-item>
          <el-descriptions-item label="评审意见">{{ selectedReview.comment || '暂无' }}</el-descriptions-item>
        </el-descriptions>
      </template>
    </el-drawer>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'

interface ReviewItem {
  reviewId: number
  title: string
  reviewer: string
  status: string
  reviewDate: string
  comment?: string
}

const loading = ref(false)
const filterStatus = ref('')
const drawerVisible = ref(false)
const selectedReview = ref<ReviewItem | null>(null)

const reviews = ref<ReviewItem[]>([
  { reviewId: 1001, title: '服务器配置方案A评审', reviewer: '张工', status: 'PENDING', reviewDate: '2026-06-09' },
  { reviewId: 1002, title: '存储方案B技术评审', reviewer: '李工', status: 'PASSED', reviewDate: '2026-06-08', comment: '方案可行，建议优化成本' },
  { reviewId: 1003, title: '网络方案C合规评审', reviewer: '王工', status: 'REJECTED', reviewDate: '2026-06-07', comment: '不符合安全规范' },
  { reviewId: 1004, title: '安全方案D架构评审', reviewer: '赵工', status: 'PENDING', reviewDate: '2026-06-12' },
  { reviewId: 1005, title: '数据库方案E性能评审', reviewer: '孙工', status: 'PASSED', reviewDate: '2026-06-06', comment: '性能指标达标' },
])

const stats = computed(() => {
  const total = reviews.value.length
  const passed = reviews.value.filter(r => r.status === 'PASSED').length
  const rejected = reviews.value.filter(r => r.status === 'REJECTED').length
  const pending = reviews.value.filter(r => r.status === 'PENDING').length
  return {
    pending,
    passed,
    rejected,
    passRate: total > 0 ? Math.round((passed / (passed + rejected || 1)) * 100) : 0
  }
})

const displayReviews = computed(() => {
  if (filterStatus.value) return reviews.value.filter(r => r.status === filterStatus.value)
  return reviews.value
})

function fetchReviews() { /* 预留API对接 */ }

function statusTag(s: string) {
  const m: Record<string, '' | 'success' | 'danger' | 'warning'> = { PENDING: 'warning', PASSED: 'success', REJECTED: 'danger' }
  return m[s] || ''
}
function statusLabel(s: string) {
  const m: Record<string, string> = { PENDING: '待评审', PASSED: '已通过', REJECTED: '已驳回' }
  return m[s] || s
}

function handleRowClick(row: ReviewItem) {
  selectedReview.value = row
  drawerVisible.value = true
}
function handleViewDetail(row: ReviewItem) { handleRowClick(row) }

async function handlePass(row: ReviewItem) {
  await ElMessageBox.confirm('确认通过该评审?', '评审通过', { type: 'success' })
  row.status = 'PASSED'
  ElMessage.success('评审已通过: ' + row.title)
}
async function handleReject(row: ReviewItem) {
  const { value } = await ElMessageBox.prompt('请输入驳回原因', '评审驳回', { type: 'warning' })
  row.status = 'REJECTED'
  row.comment = value || ''
  ElMessage.success('已驳回评审: ' + row.title)
}

onMounted(() => { fetchReviews() })
</script>

<style scoped>
.cpq-page { padding: 16px; }
.page-header { display: flex; align-items: center; justify-content: space-between; margin-bottom: 16px; }
.page-header h2 { margin: 0; font-size: 18px; font-weight: 600; color: var(--cpq-text-primary, #303133); }
.header-actions { display: flex; gap: 12px; }
.stats-row { margin-bottom: 16px; }
.stat-card { text-align: center; }
.stat-pending { border-top: 3px solid #e6a23c; }
.stat-passed { border-top: 3px solid #67c23a; }
.stat-rejected { border-top: 3px solid #f56c6c; }
.stat-rate { border-top: 3px solid #409eff; }
.table-card { margin-top: 0; }
.table-title { font-weight: 500; }
</style>
