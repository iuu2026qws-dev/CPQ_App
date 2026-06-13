<template>
  <div class="cpq-page">
    <div class="toolbar"><h3 style="margin:0">交期 SLA 看板</h3></div>
    <el-row :gutter="16">
      <el-col :span="6">
        <el-card><el-statistic title="总订单" :value="stats.total" /></el-card>
      </el-col>
      <el-col :span="6">
        <el-card><el-statistic title="按时交付" :value="stats.onTime" /><span style="color:#67c23a;font-size:12px">{{ ((stats.onTime/stats.total)*100).toFixed(1) }}%</span></el-card>
      </el-col>
      <el-col :span="6">
        <el-card><el-statistic title="延迟交付" :value="stats.delayed" /><span style="color:#f56c6c;font-size:12px">{{ ((stats.delayed/stats.total)*100).toFixed(1) }}%</span></el-card>
      </el-col>
      <el-col :span="6">
        <el-card><el-statistic title="平均交期(天)" :value="stats.avgDays" /></el-card>
      </el-col>
    </el-row>
    <el-card header="交期趋势" style="margin-top:16px">
      <div ref="trendRef" style="width:100%;height:300px"></div>
    </el-card>
    <el-card header="SLA 预警列表" style="margin-top:16px">
      <el-table :data="alerts" border size="small">
        <el-table-column prop="productName" label="产品" />
        <el-table-column prop="orderQty" label="订单量" />
        <el-table-column prop="deliveryDays" label="承诺交期(天)" />
        <el-table-column prop="actualDays" label="实际交期(天)" />
        <el-table-column label="状态" width="120">
          <template #default="{ row }">
            <el-tag :type="row.actualDays > row.deliveryDays ? 'danger' : row.actualDays > row.deliveryDays * 0.8 ? 'warning' : 'success'" size="small">
              {{ row.actualDays > row.deliveryDays ? '超期' : row.actualDays > row.deliveryDays * 0.8 ? '预警' : '正常' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="bottleneck" label="瓶颈" />
      </el-table>
    </el-card>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, nextTick } from 'vue'

const stats = ref({ total: 128, onTime: 107, delayed: 21, avgDays: 8.5 })
const trendRef = ref<HTMLDivElement>()
const alerts = ref([
  { productName: '产品A-高端版', orderQty: 50, deliveryDays: 7, actualDays: 9, bottleneck: '产能' },
  { productName: '产品B-标准版', orderQty: 30, deliveryDays: 5, actualDays: 4, bottleneck: '无' },
  { productName: '产品C-定制版', orderQty: 20, deliveryDays: 14, actualDays: 16, bottleneck: '物料' },
  { productName: '产品D-出口版', orderQty: 15, deliveryDays: 10, actualDays: 11, bottleneck: '物流' },
])

onMounted(async () => {
  await nextTick()
  drawTrend()
})

function drawTrend() {
  if (!trendRef.value) return
  const canvas = document.createElement('canvas')
  trendRef.value.innerHTML = ''
  trendRef.value.appendChild(canvas)
  canvas.width = trendRef.value.clientWidth
  canvas.height = 300
  const ctx = canvas.getContext('2d')!
  const data = [6, 7, 8.5, 7, 9, 8, 7.5, 9.5, 8, 10, 8.5, 9]
  const labels = ['6月','7月','8月','9月','10月','11月','12月','1月','2月','3月','4月','5月']
  const max = 14; const chartH = 220; const top = 30; const left = 50
  ctx.beginPath(); ctx.moveTo(left, top); ctx.lineTo(left, top + chartH); ctx.lineTo(canvas.width - 20, top + chartH)
  ctx.strokeStyle = '#303133'; ctx.stroke()
  const stepX = (canvas.width - left - 30) / (labels.length - 1)
  ctx.beginPath(); ctx.strokeStyle = '#409eff'; ctx.lineWidth = 2
  data.forEach((d, i) => {
    const x = left + i * stepX; const y = top + chartH - (d / max) * chartH
    i === 0 ? ctx.moveTo(x, y) : ctx.lineTo(x, y)
  })
  ctx.stroke()
  data.forEach((d, i) => {
    const x = left + i * stepX; const y = top + chartH - (d / max) * chartH
    ctx.beginPath(); ctx.arc(x, y, 4, 0, Math.PI * 2); ctx.fillStyle = '#409eff'; ctx.fill()
    ctx.fillStyle = '#303133'; ctx.font = '11px sans-serif'; ctx.textAlign = 'center'
    ctx.fillText(d + '', x, y - 10)
    ctx.fillText(labels[i], x, top + chartH + 18)
  })
}
</script>
