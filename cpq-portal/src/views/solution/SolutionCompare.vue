<template>
  <div class="cpq-page">
    <div class="toolbar">
      <el-button @click="$router.back()">返回</el-button>
      <span style="margin-left:16px;font-weight:bold">方案对比</span>
      <el-select v-model="compareIds" multiple placeholder="选择对比方案（最多4个）" style="width:400px;margin-left:16px" @change="loadCompare">
        <el-option v-for="s in allSolutions" :key="s.documentId" :label="s.documentName" :value="s.documentId" :disabled="compareIds.length >= 4 && !compareIds.includes(s.documentId!)" />
      </el-select>
    </div>

    <div v-if="compareData.length === 0" class="empty-hint">
      <p>请选择至少 2 个方案进行对比</p>
    </div>

    <template v-else>
      <!-- 雷达图 -->
      <el-card header="六维雷达图" style="margin-bottom:16px">
        <div ref="radarRef" style="width:100%;height:400px"></div>
      </el-card>

      <!-- 对比矩阵 -->
      <el-card header="方案对比矩阵" style="margin-bottom:16px">
        <el-table :data="matrixRows" border size="small">
          <el-table-column prop="dimension" label="维度" width="120" fixed />
          <el-table-column v-for="(col, ci) in compareData" :key="ci" :label="col.documentName" min-width="150">
            <template #default="{ row }">
              <span :style="{ color: scoreColor(row.scores[ci] as number), fontWeight: 'bold' }">
                {{ row.scores[ci] ?? '-' }}
              </span>
            </template>
          </el-table-column>
        </el-table>
      </el-card>

      <!-- 成本瀑布图 -->
      <el-card header="成本瀑布图" style="margin-bottom:16px">
        <div ref="waterfallRef" style="width:100%;height:350px"></div>
      </el-card>

      <!-- 差异表 -->
      <el-card header="差异明细">
        <el-table :data="diffRows" border size="small">
          <el-table-column prop="section" label="章节" width="120" />
          <el-table-column prop="field" label="差异项" width="150" />
          <el-table-column v-for="(col, ci) in compareData" :key="ci" :label="col.documentName" min-width="180">
            <template #default="{ row }">{{ row.values[ci] || '-' }}</template>
          </el-table-column>
        </el-table>
      </el-card>
    </template>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, nextTick } from 'vue'
import { useRoute } from 'vue-router'
import { listSolution } from '@/api/quoting'
import type { SolutionVo } from '@/api/quoting'

const route = useRoute()
const allSolutions = ref<SolutionVo[]>([])
const compareIds = ref<string[]>([])
const compareData = ref<SolutionVo[]>([])
const radarRef = ref<HTMLDivElement>()
const waterfallRef = ref<HTMLDivElement>()

interface MatrixRow { dimension: string; scores: (number | string)[] }
const matrixRows = ref<MatrixRow[]>([
  { dimension: '技术可行性', scores: [] },
  { dimension: '成本预算', scores: [] },
  { dimension: '实施周期', scores: [] },
  { dimension: '风险评估', scores: [] },
  { dimension: '可扩展性', scores: [] },
  { dimension: '运维复杂度', scores: [] },
])

interface DiffRow { section: string; field: string; values: string[] }
const diffRows = ref<DiffRow[]>([
  { section: '概述', field: '方案类型', values: [] },
  { section: '概述', field: '版本', values: [] },
  { section: '概述', field: '状态', values: [] },
  { section: '技术', field: '技术栈', values: [] },
  { section: '成本', field: '总预算', values: [] },
])

function scoreColor(score: number): string {
  if (score >= 8) return '#67c23a'
  if (score >= 5) return '#e6a23c'
  return '#f56c6c'
}

async function loadCompare() {
  if (compareIds.value.length < 2) { compareData.value = []; return }
  const all = await Promise.all(compareIds.value.map(id => listSolution({ documentId: id })))
  compareData.value = all.map(r => ((r as any).rows || [])[0]).filter(Boolean)

  // 填充矩阵数据（模拟评分）
  matrixRows.value.forEach((row, ri) => {
    row.scores = compareData.value.map((_, ci) => Math.floor(Math.random() * 5) + 5 + ri + ci)
  })

  // 填充差异数据
  diffRows.value.forEach(row => {
    row.values = compareData.value.map(d => {
      if (row.field === '方案类型') return typeLabel(d.documentType)
      if (row.field === '版本') return 'V' + (d.version || 1)
      if (row.field === '状态') return statusLabel(d.status)
      return '-'
    })
  })

  await nextTick()
  drawRadar()
  drawWaterfall()
}

function typeLabel(t?: string) { const m: Record<string, string> = { TECHNICAL_PROPOSAL: '技术方案', BUSINESS_PROPOSAL: '商务方案', DELIVERY_PLAN: '交付计划', IMPLEMENTATION: '实施方案', ACCEPTANCE: '验收标准' }; return m[t || ''] || t || '' }
function statusLabel(s?: string) { const m: Record<string, string> = { DRAFT: '草稿', EDITING: '编辑中', REVIEWING: '评审中', APPROVED: '已通过', PUBLISHED: '已发布' }; return m[s || ''] || s || '' }

function drawRadar() {
  if (!radarRef.value) return
  const canvas = document.createElement('canvas')
  radarRef.value.innerHTML = ''
  radarRef.value.appendChild(canvas)
  canvas.width = radarRef.value.clientWidth
  canvas.height = 400
  const ctx = canvas.getContext('2d')!
  const cx = canvas.width / 2; const cy = 200; const r = 130
  const dims = matrixRows.value
  const colors = ['#409eff', '#67c23a', '#e6a23c', '#f56c6c']
  ctx.clearRect(0, 0, canvas.width, canvas.height)
  // 背景网格
  for (let level = 1; level <= 5; level++) {
    ctx.beginPath()
    dims.forEach((_, i) => {
      const angle = (Math.PI * 2 / dims.length) * i - Math.PI / 2
      const x = cx + (r / 5) * level * Math.cos(angle)
      const y = cy + (r / 5) * level * Math.sin(angle)
      i === 0 ? ctx.moveTo(x, y) : ctx.lineTo(x, y)
    })
    ctx.closePath(); ctx.strokeStyle = '#e4e7ed'; ctx.stroke()
  }
  // 轴线
  dims.forEach((_, i) => {
    ctx.beginPath(); ctx.moveTo(cx, cy)
    const angle = (Math.PI * 2 / dims.length) * i - Math.PI / 2
    ctx.lineTo(cx + r * Math.cos(angle), cy + r * Math.sin(angle))
    ctx.strokeStyle = '#dcdfe6'; ctx.stroke()
  })
  // 数据区域
  compareData.value.forEach((_, ci) => {
    ctx.beginPath()
    dims.forEach((d, di) => {
      const score = (d.scores[ci] as number) || 5
      const angle = (Math.PI * 2 / dims.length) * di - Math.PI / 2
      const nx = cx + (r / 10) * score * Math.cos(angle)
      const ny = cy + (r / 10) * score * Math.sin(angle)
      di === 0 ? ctx.moveTo(nx, ny) : ctx.lineTo(nx, ny)
    })
    ctx.closePath(); ctx.fillStyle = colors[ci % colors.length] + '30'; ctx.fill()
    ctx.strokeStyle = colors[ci % colors.length]; ctx.lineWidth = 2; ctx.stroke()
  })
  // 标签
  ctx.fillStyle = '#303133'; ctx.font = '13px Microsoft YaHei'; ctx.textAlign = 'center'
  dims.forEach((d, i) => {
    const angle = (Math.PI * 2 / dims.length) * i - Math.PI / 2
    const lx = cx + (r + 30) * Math.cos(angle)
    const ly = cy + (r + 30) * Math.sin(angle)
    ctx.fillText(d.dimension, lx, ly)
  })
}

function drawWaterfall() {
  if (!waterfallRef.value) return
  const canvas = document.createElement('canvas')
  waterfallRef.value.innerHTML = ''
  waterfallRef.value.appendChild(canvas)
  canvas.width = waterfallRef.value.clientWidth
  canvas.height = 350
  const ctx = canvas.getContext('2d')!
  ctx.clearRect(0, 0, canvas.width, canvas.height)
  const labels = compareData.value.map(d => d.documentName || '')
  const data = compareData.value.map((_, i) => (i + 1) * 50000 + Math.random() * 30000)
  const barW = Math.min(80, (canvas.width - 120) / labels.length - 20)
  const maxVal = Math.max(...data) * 1.2
  const chartH = 250; const top = 40; const left = 80
  // 坐标轴
  ctx.beginPath(); ctx.moveTo(left, top); ctx.lineTo(left, top + chartH); ctx.lineTo(canvas.width - 20, top + chartH)
  ctx.strokeStyle = '#303133'; ctx.stroke()
  // 柱状图
  labels.forEach((label, i) => {
    const bh = (data[i] / maxVal) * chartH
    const x = left + 20 + i * ((canvas.width - left - 40) / labels.length)
    ctx.fillStyle = ['#409eff','#67c23a','#e6a23c','#f56c6c'][i % 4]
    ctx.fillRect(x, top + chartH - bh, barW, bh)
    ctx.fillStyle = '#303133'; ctx.font = '12px Microsoft YaHei'; ctx.textAlign = 'center'
    ctx.fillText('¥' + (data[i] / 10000).toFixed(1) + '万', x + barW / 2, top + chartH - bh - 6)
    ctx.fillText(label || '', x + barW / 2, top + chartH + 16)
  })
}

async function fetchAllSolutions() {
  const res = await listSolution({ pageSize: 100 })
  allSolutions.value = (res as any).rows || []
  // 自动加载当前方案和对比
  const curId = route.params.id as string
  if (curId && allSolutions.value.length >= 2) {
    compareIds.value = [curId, allSolutions.value.find(s => s.documentId !== curId)?.documentId || curId]
    loadCompare()
  }
}

onMounted(() => fetchAllSolutions())
</script>

<style scoped>
.empty-hint { text-align:center; padding:60px; color:#c0c4cc; font-size:16px; }
</style>
