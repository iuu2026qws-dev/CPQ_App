<template>
  <div class="cpq-page">
    <div class="toolbar">
      <el-button @click="$router.back()">返回</el-button>
      <el-button type="primary" @click="doAnalyze">执行影响分析</el-button>
      <el-button type="success" @click="doPropagate" :disabled="!hasAnalysis">传播变更</el-button>
      <span style="margin-left:12px;color:#909399">ECN: {{ order?.ecnNumber }} — {{ order?.title }}</span>
    </div>
    <el-descriptions v-if="order" :column="3" border style="margin-bottom:16px">
      <el-descriptions-item label="编号">{{ order.ecnNumber }}</el-descriptions-item>
      <el-descriptions-item label="类型">{{ order.changeType }}</el-descriptions-item>
      <el-descriptions-item label="状态"><el-tag :type="tag(order.status)" size="small">{{ order.status }}</el-tag></el-descriptions-item>
      <el-descriptions-item label="严重程度">{{ order.severity }}</el-descriptions-item>
      <el-descriptions-item label="发起人">{{ order.originatorName }}</el-descriptions-item>
      <el-descriptions-item label="变更原因">{{ order.reason }}</el-descriptions-item>
    </el-descriptions>
    <el-card header="五级传播链影响分析">
      <div ref="treeRef" style="width:100%;height:350px"></div>
    </el-card>
    <el-card header="影响明细" style="margin-top:16px">
      <el-table :data="impacts" border size="small">
        <el-table-column prop="propagationLevel" label="传播层级" width="80">
          <template #default="{ row }">L{{ row.propagationLevel }}</template>
        </el-table-column>
        <el-table-column prop="affectedEntityType" label="受影响实体" width="120" />
        <el-table-column prop="affectedEntityName" label="实体名称" min-width="180" />
        <el-table-column prop="impactDescription" label="影响描述" min-width="250" />
        <el-table-column prop="severity" label="影响程度" width="100">
          <template #default="{ row }"><el-tag :type="row.severity==='HIGH'?'danger':row.severity==='MEDIUM'?'warning':'info'" size="small">{{ row.severity }}</el-tag></template>
        </el-table-column>
        <el-table-column prop="remediation" label="缓解措施" min-width="200" />
      </el-table>
    </el-card>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, nextTick } from 'vue'
import { useRoute } from 'vue-router'
import { ElMessage } from 'element-plus'
import request from '@/utils/request'

const route = useRoute()
const order = ref<any>(null)
const impacts = ref<any[]>([])
const treeRef = ref<HTMLDivElement>()
const hasAnalysis = ref(false)

function tag(s: string) { const m: Record<string,string>={DRAFT:'info',ANALYZING:'warning',ANALYZED:'',APPROVED:'success',REJECTED:'danger',IMPLEMENTED:'success',CLOSED:'info'}; return m[s]||'info' }

async function loadOrder() {
  const id = Number(route.params.id)
  order.value = await request.get(`/cpq/ecn/order/${id}`)
  try {
    const res = await request.get('/cpq/ecn/impact/list', { params: { changeOrderId: id, pageSize: 100 } })
    impacts.value = Array.isArray(res) ? res : (res.rows || []); hasAnalysis.value = impacts.value.length > 0
    if (impacts.value.length > 0) await nextTick().then(drawTree)
  } catch { /* no analysis yet */ }
}

async function doAnalyze() {
  const id = Number(route.params.id)
  impacts.value = await request.post(`/cpq/ecn/impact/analyze/${id}`)
  hasAnalysis.value = true; ElMessage.success('影响分析完成')
  await nextTick().then(drawTree)
}

async function doPropagate() {
  const id = Number(route.params.id)
  const count = await request.post(`/cpq/ecn/impact/propagate/${id}`)
  ElMessage.success(`已传播 ${count} 项变更`); loadOrder()
}

function drawTree() {
  if (!treeRef.value || impacts.value.length === 0) return
  const canvas = document.createElement('canvas')
  treeRef.value.innerHTML = ''; treeRef.value.appendChild(canvas)
  canvas.width = treeRef.value.clientWidth; canvas.height = 350
  const ctx = canvas.getContext('2d')!
  const cx = 100; const cy = 175
  const levels = [1,2,3,4,5]; const levelX = canvas.width / (levels.length + 1)
  // 根节点
  ctx.beginPath(); ctx.arc(cx, cy, 20, 0, Math.PI * 2); ctx.fillStyle = '#409eff'; ctx.fill()
  ctx.fillStyle = '#fff'; ctx.font = '12px sans-serif'; ctx.textAlign = 'center'; ctx.fillText('ECN', cx, cy + 4)
  // 层级节点
  levels.forEach(l => {
    const x = cx + l * levelX; const lvlImpacts = impacts.value.filter((i: any) => i.propagationLevel === l)
    lvlImpacts.forEach((imp: any, j: number) => {
      const ny = cy - 60 + j * 50; const nx = x
      ctx.beginPath(); ctx.moveTo(cx + (l-1)*levelX + 20, cy); ctx.lineTo(nx - 20, ny); ctx.strokeStyle = '#dcdfe6'; ctx.stroke()
      ctx.beginPath(); ctx.arc(nx, ny, 16, 0, Math.PI * 2)
      ctx.fillStyle = imp.severity === 'HIGH' ? '#f56c6c' : imp.severity === 'MEDIUM' ? '#e6a23c' : '#67c23a'; ctx.fill()
      ctx.fillStyle = '#fff'; ctx.font = '10px sans-serif'; ctx.fillText('L' + l, nx, ny + 4)
      ctx.fillStyle = '#303133'; ctx.font = '11px sans-serif'; ctx.fillText(imp.affectedEntityType || '', nx, ny + 28)
    })
  })
}

onMounted(() => loadOrder())
</script>
