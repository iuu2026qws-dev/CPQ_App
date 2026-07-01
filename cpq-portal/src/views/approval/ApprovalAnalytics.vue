<template>
  <div class="cpq-page">
    <div class="page-header">
      <h2>效率看板</h2>
    </div>

    <el-row :gutter="20" class="stats-row">
      <el-col :span="6">
        <el-card shadow="hover" class="stat-card stat-pending">
          <template #header>待审批数</template>
          <el-statistic :value="stats.pendingCount" />
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card shadow="hover" class="stat-card stat-duration">
          <template #header>平均审批时长</template>
          <el-statistic :value="stats.avgDuration" suffix="h" />
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card shadow="hover" class="stat-card stat-rate">
          <template #header>审批通过率</template>
          <el-statistic :value="stats.passRate + '%'" />
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card shadow="hover" class="stat-card stat-sla">
          <template #header>SLA达标率</template>
          <el-statistic :value="stats.slaRate + '%'" />
        </el-card>
      </el-col>
    </el-row>

    <el-card shadow="never" class="table-card">
      <template #header>
        <span class="table-title">周期统计</span>
      </template>
      <el-table :data="periodStats" stripe>
        <el-table-column prop="period" label="周期" width="100" />
        <el-table-column prop="totalCount" label="总数" width="100" />
        <el-table-column prop="approvedCount" label="通过" width="100" />
        <el-table-column prop="rejectedCount" label="驳回" width="100" />
        <el-table-column prop="avgDuration" label="平均耗时" width="120" />
        <el-table-column label="通过率" width="100">
          <template #default="{ row }">
            <el-progress :percentage="calcRate(row.approvedCount, row.totalCount)" :stroke-width="8" />
          </template>
        </el-table-column>
      </el-table>
    </el-card>
  </div>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue'

interface PeriodStat {
  period: string
  totalCount: number
  approvedCount: number
  rejectedCount: number
  avgDuration: string
}

const periodStats = ref<PeriodStat[]>([
  { period: '本周', totalCount: 45, approvedCount: 39, rejectedCount: 6, avgDuration: '1.8h' },
  { period: '本月', totalCount: 180, approvedCount: 157, rejectedCount: 23, avgDuration: '2.1h' },
  { period: '本季度', totalCount: 520, approvedCount: 452, rejectedCount: 68, avgDuration: '2.5h' },
])

const stats = computed(() => {
  const current = periodStats.value[1] // 本月
  const passRate = current.totalCount > 0 ? Math.round(current.approvedCount / current.totalCount * 100) : 0
  return {
    pendingCount: 12,
    avgDuration: parseFloat(current.avgDuration),
    passRate,
    slaRate: 92
  }
})

function calcRate(part: number, total: number) {
  return total > 0 ? Math.round(part / total * 100) : 0
}
</script>

<style scoped>
.cpq-page { padding: 16px; }
.page-header { margin-bottom: 16px; }
.page-header h2 { margin: 0; font-size: 18px; font-weight: 600; color: var(--cpq-text-primary, #303133); }
.stats-row { margin-bottom: 16px; }
.stat-card { text-align: center; }
.stat-pending { border-top: 3px solid #e6a23c; }
.stat-duration { border-top: 3px solid #409eff; }
.stat-rate { border-top: 3px solid #67c23a; }
.stat-sla { border-top: 3px solid #9060f0; }
.table-card { margin-top: 0; }
.table-title { font-weight: 500; }
</style>
