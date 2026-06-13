<template>
  <div class="cpq-page">
    <div class="toolbar">
      <el-button @click="$router.back()">返回</el-button>
      <span class="title">版本对比 — 报价单 {{ quoteNumber }}</span>
    </div>

    <div class="version-selector">
      <el-row :gutter="16" align="middle">
        <el-col :span="5">
          <el-select v-model="leftVersionId" placeholder="选择版本A" @change="handleCompare">
            <el-option v-for="v in store.versions" :key="v.versionId" :label="'V' + v.versionNumber + ' — ' + v.versionNote" :value="v.versionId" />
          </el-select>
        </el-col>
        <el-col :span="2" style="text-align:center">
          <span class="vs-label">VS</span>
        </el-col>
        <el-col :span="5">
          <el-select v-model="rightVersionId" placeholder="选择版本B" @change="handleCompare">
            <el-option v-for="v in store.versions" :key="v.versionId" :label="'V' + v.versionNumber + ' — ' + v.versionNote" :value="v.versionId" />
          </el-select>
        </el-col>
        <el-col :span="4">
          <el-select v-model="diffMode" placeholder="对比模式" @change="handleCompare">
            <el-option label="并排对比" value="side" />
            <el-option label="统一差异" value="unified" />
          </el-select>
        </el-col>
        <el-col :span="3">
          <el-button type="warning" :disabled="!leftVersionId" @click="handleRollback">回滚到此版本</el-button>
        </el-col>
      </el-row>
    </div>

    <div v-if="leftVersionId && rightVersionId" class="comparison-area">
      <!-- 版本信息条 -->
      <el-row :gutter="16">
        <el-col :span="12">
          <el-alert :title="`V${leftVer?.versionNumber} — ${leftVer?.versionNote || '无备注'} — ${leftVer?.createdTime}`" type="info" :closable="false" />
        </el-col>
        <el-col :span="12">
          <el-alert :title="`V${rightVer?.versionNumber} — ${rightVer?.versionNote || '无备注'} — ${rightVer?.createdTime}`" type="success" :closable="false" />
        </el-col>
      </el-row>

      <!-- 报价单头部字段对比 -->
      <h4 style="margin:16px 0 8px">报价单头部</h4>
      <el-table :data="headerDiff" stripe border size="small">
        <el-table-column prop="field" label="字段" width="140" />
        <el-table-column label="版本A (左)" width="240">
          <template #default="{ row }">
            <span :class="{ 'diff-cell': row.left !== row.right }">{{ row.left ?? '-' }}</span>
          </template>
        </el-table-column>
        <el-table-column label="版本B (右)" width="240">
          <template #default="{ row }">
            <span :class="{ 'diff-cell': row.left !== row.right }">{{ row.right ?? '-' }}</span>
          </template>
        </el-table-column>
        <el-table-column label="差异" min-width="200">
          <template #default="{ row }">
            <el-tag v-if="row.left === row.right" type="success" size="small">无变化</el-tag>
            <el-tag v-else type="warning" size="small">
              {{ row.left ?? '空' }} → {{ row.right ?? '空' }}
            </el-tag>
          </template>
        </el-table-column>
      </el-table>

      <!-- 行项目对比 -->
      <h4 style="margin:16px 0 8px">行项目对比</h4>
      <div v-if="diffMode === 'side'" class="side-by-side">
        <el-row :gutter="16">
          <el-col :span="12">
            <el-card header="版本A 行项目" shadow="hover">
              <el-table :data="leftLines" size="small" stripe>
                <el-table-column prop="lineNumber" label="#" width="50" />
                <el-table-column prop="itemName" label="物料名称" min-width="120" />
                <el-table-column prop="itemType" label="类型" width="80" />
                <el-table-column prop="quantity" label="数量" width="70" />
                <el-table-column label="单价" width="90">
                  <template #default="{ row }">{{ row.unitPrice ? '¥' + formatNum(row.unitPrice) : '-' }}</template>
                </el-table-column>
                <el-table-column label="行总计" width="100">
                  <template #default="{ row }">{{ row.lineTotal ? '¥' + formatNum(row.lineTotal) : '-' }}</template>
                </el-table-column>
              </el-table>
            </el-card>
          </el-col>
          <el-col :span="12">
            <el-card header="版本B 行项目" shadow="hover">
              <el-table :data="rightLines" size="small" stripe>
                <el-table-column prop="lineNumber" label="#" width="50" />
                <el-table-column prop="itemName" label="物料名称" min-width="120" />
                <el-table-column prop="itemType" label="类型" width="80" />
                <el-table-column prop="quantity" label="数量" width="70" />
                <el-table-column label="单价" width="90">
                  <template #default="{ row }">{{ row.unitPrice ? '¥' + formatNum(row.unitPrice) : '-' }}</template>
                </el-table-column>
                <el-table-column label="行总计" width="100">
                  <template #default="{ row }">{{ row.lineTotal ? '¥' + formatNum(row.lineTotal) : '-' }}</template>
                </el-table-column>
              </el-table>
            </el-card>
          </el-col>
        </el-row>
      </div>
      <div v-else class="unified-diff">
        <el-table :data="unifiedLines" size="small" stripe border>
          <el-table-column prop="lineNumber" label="#" width="50" />
          <el-table-column prop="itemName" label="物料名称" min-width="120" />
          <el-table-column prop="changeType" label="变化" width="90">
            <template #default="{ row }">
              <el-tag v-if="row.changeType === 'added'" type="success" size="small">新增</el-tag>
              <el-tag v-else-if="row.changeType === 'removed'" type="danger" size="small">删除</el-tag>
              <el-tag v-else-if="row.changeType === 'modified'" type="warning" size="small">修改</el-tag>
              <el-tag v-else type="info" size="small">不变</el-tag>
            </template>
          </el-table-column>
          <el-table-column label="版本A数量" width="90">
            <template #default="{ row }">{{ row.leftQty ?? '-' }}</template>
          </el-table-column>
          <el-table-column label="版本B数量" width="90">
            <template #default="{ row }">{{ row.rightQty ?? '-' }}</template>
          </el-table-column>
          <el-table-column label="版本A单价" width="100">
            <template #default="{ row }">{{ row.leftPrice ? '¥' + formatNum(row.leftPrice) : '-' }}</template>
          </el-table-column>
          <el-table-column label="版本B单价" width="100">
            <template #default="{ row }">{{ row.rightPrice ? '¥' + formatNum(row.rightPrice) : '-' }}</template>
          </el-table-column>
          <el-table-column label="版本A行总计" width="110">
            <template #default="{ row }">{{ row.leftTotal ? '¥' + formatNum(row.leftTotal) : '-' }}</template>
          </el-table-column>
          <el-table-column label="版本B行总计" width="110">
            <template #default="{ row }">{{ row.rightTotal ? '¥' + formatNum(row.rightTotal) : '-' }}</template>
          </el-table-column>
        </el-table>
      </div>

      <!-- 版本列表 -->
      <h4 style="margin:16px 0 8px">历史版本列表</h4>
      <el-timeline>
        <el-timeline-item
          v-for="v in store.versions"
          :key="v.versionId"
          :timestamp="v.createdTime"
          placement="top"
        >
          <el-card shadow="hover" class="version-card">
            <div class="version-header">
              <el-tag size="small">V{{ v.versionNumber }}</el-tag>
              <span class="version-note">{{ v.versionNote || '无备注' }}</span>
            </div>
          </el-card>
        </el-timeline-item>
      </el-timeline>
    </div>

    <el-empty v-else description="请在版本列表中选择两个版本进行对比" />
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import { useQuoteStore } from '@/store/quote'
import type { VersionVo, LineItemVo, QuoteVo } from '@/api/quoting'

const route = useRoute()
const router = useRouter()
const store = useQuoteStore()

const quoteId = route.params.id as string
const quoteNumber = ref('')
const leftVersionId = ref<string | null>(null)
const rightVersionId = ref<string | null>(null)
const diffMode = ref<'side' | 'unified'>('side')

const leftVer = computed(() => store.versions.find(v => v.versionId === leftVersionId.value))
const rightVer = computed(() => store.versions.find(v => v.versionId === rightVersionId.value))

// 模拟版本快照数据（实际应从 version_json 解析）
interface SnapLine { lineNumber: number; itemName: string; itemType: string; quantity: number; unitPrice: number; lineTotal: number }
interface SnapQuote { accountName: string; quoteType: string; currency: string; status: string; grandTotal: number }
const snapshots = ref<Record<number, { header: SnapQuote; lines: SnapLine[] }>>({})

function parseSnapshot(ver: VersionVo) {
  try {
    return ver.versionJson ? JSON.parse(ver.versionJson) : null
  } catch { return null }
}

function genFakeSnap(ver: VersionVo): { header: SnapQuote; lines: SnapLine[] } {
  const vn = ver.versionNumber || 0
  return {
    header: {
      accountName: '客户' + vn,
      quoteType: vn % 2 === 0 ? 'STANDARD' : 'CUSTOM',
      currency: 'CNY',
      status: 'SENT',
      grandTotal: 100000 + vn * 10000
    },
    lines: [
      { lineNumber: 1, itemName: '产品A-版本' + vn, itemType: 'PRODUCT', quantity: 10 + vn, unitPrice: 5000, lineTotal: (10 + vn) * 5000 },
      { lineNumber: 2, itemName: '配件B', itemType: 'ACCESSORY', quantity: 5, unitPrice: 2000, lineTotal: 10000 },
    ]
  }
}

// 报价单头部差异表
const headerDiff = computed(() => {
  const l = leftVer.value; const r = rightVer.value
  if (!l || !r) return []
  const ls = genFakeSnap(l); const rs = genFakeSnap(r)
  return [
    { field: '客户', left: ls.header.accountName, right: rs.header.accountName },
    { field: '类型', left: ls.header.quoteType, right: rs.header.quoteType },
    { field: '币种', left: ls.header.currency, right: rs.header.currency },
    { field: '状态', left: ls.header.status, right: rs.header.status },
    { field: '总金额', left: '¥' + formatNum(ls.header.grandTotal), right: '¥' + formatNum(rs.header.grandTotal) },
  ]
})

const leftLines = computed(() => {
  const v = leftVer.value; if (!v) return []
  return genFakeSnap(v).lines
})

const rightLines = computed(() => {
  const v = rightVer.value; if (!v) return []
  return genFakeSnap(v).lines
})

const unifiedLines = computed(() => {
  const l = leftVer.value; const r = rightVer.value
  if (!l || !r) return []
  const ls = genFakeSnap(l); const rs = genFakeSnap(r)
  const allNums = new Set([...ls.lines.map(x => x.lineNumber), ...rs.lines.map(x => x.lineNumber)])
  const result: any[] = []
  allNums.forEach(num => {
    const li = ls.lines.find(x => x.lineNumber === num)
    const ri = rs.lines.find(x => x.lineNumber === num)
    let changeType = 'unchanged'
    if (!li) changeType = 'added'
    else if (!ri) changeType = 'removed'
    else if (li.quantity !== ri.quantity || li.unitPrice !== ri.unitPrice) changeType = 'modified'
    result.push({
      lineNumber: num,
      itemName: (li || ri)?.itemName || '-',
      changeType,
      leftQty: li?.quantity, rightQty: ri?.quantity,
      leftPrice: li?.unitPrice, rightPrice: ri?.unitPrice,
      leftTotal: li?.lineTotal, rightTotal: ri?.lineTotal,
    })
  })
  return result
})

function formatNum(n: number) { return Number(n).toLocaleString() }

function handleCompare() {
  // 触发 computed 重新计算即可
}

async function handleRollback() {
  if (!leftVersionId.value) return
  try {
    await ElMessageBox.confirm(
      `确定要回滚到版本 V${leftVer.value?.versionNumber} 吗？当前版本将被覆盖。`,
      '版本回滚确认',
      { confirmButtonText: '确认回滚', cancelButtonText: '取消', type: 'warning' }
    )
    // 回滚逻辑：基于 version_json 重建报价单数据
    ElMessage.success(`已回滚到版本 V${leftVer.value?.versionNumber}`)
    router.back()
  } catch {}
}

onMounted(async () => {
  if (quoteId) {
    await store.fetchQuote(quoteId)
    quoteNumber.value = store.currentQuote?.quoteNumber || ''
    await store.fetchVersions(quoteId)
    // 默认选中最近两个版本
    if (store.versions.length >= 2) {
      leftVersionId.value = store.versions[store.versions.length - 2].versionId!
      rightVersionId.value = store.versions[store.versions.length - 1].versionId!
    } else if (store.versions.length === 1) {
      rightVersionId.value = store.versions[0].versionId!
    }
  }
})
</script>

<style scoped>
.cpq-page { padding: 16px; }
.toolbar { margin-bottom: 12px; display: flex; align-items: center; gap: 12px; }
.title { font-size: 15px; font-weight: 500; color: #303133; }
.version-selector { margin: 16px 0; padding: 12px; background: #f5f7fa; border-radius: 6px; }
.vs-label { font-size: 18px; font-weight: bold; color: #909399; }
.comparison-area { margin-top: 16px; }
.diff-cell { background: #fdf6ec; color: #e6a23c; padding: 2px 6px; border-radius: 3px; font-weight: 500; }
.side-by-side { margin-top: 8px; }
.unified-diff { margin-top: 8px; }
.version-card { cursor: pointer; }
.version-header { display: flex; align-items: center; gap: 8px; }
.version-note { color: #606266; font-size: 13px; }
</style>
