<template>
  <el-dialog
    v-model="visible"
    :title="'报价单预览 — ' + (quote?.quoteNumber || '')"
    width="900px"
    top="5vh"
    destroy-on-close
    @opened="handleOpened"
  >
    <div v-if="quote" class="preview-body" id="quotePreviewContent">
      <!-- 公司抬头 -->
      <div class="preview-header">
        <div class="company-info">
          <h2>Smart CPQ</h2>
          <p>报价单</p>
        </div>
        <div class="quote-meta">
          <p><strong>报价单号：</strong>{{ quote.quoteNumber }}</p>
          <p><strong>日期：</strong>{{ quote.createTime || '—' }}</p>
          <p><strong>有效期至：</strong>{{ quote.validUntil || '—' }}</p>
        </div>
      </div>

      <el-divider />

      <!-- 客户信息 -->
      <el-descriptions :column="2" border size="small">
        <el-descriptions-item label="客户名称">{{ quote.accountName || '—' }}</el-descriptions-item>
        <el-descriptions-item label="报价类型">{{ typeLabel(quote.quoteType) }}</el-descriptions-item>
        <el-descriptions-item label="币种">{{ quote.currency || 'CNY' }}</el-descriptions-item>
        <el-descriptions-item label="状态">
          <el-tag size="small">{{ quote.status }}</el-tag>
        </el-descriptions-item>
      </el-descriptions>

      <!-- 行项目表格 -->
      <h4 style="margin:20px 0 8px">报价明细</h4>
      <el-table :data="lineItems" stripe border size="small" show-summary :summary-method="getSummaries">
        <el-table-column prop="lineNumber" label="序号" width="60" align="center" />
        <el-table-column prop="itemName" label="物料名称" min-width="160" />
        <el-table-column prop="itemCode" label="物料编码" width="120" />
        <el-table-column prop="itemType" label="类型" width="90">
          <template #default="{ row }">{{ typeLabel(row.itemType) }}</template>
        </el-table-column>
        <el-table-column prop="quantity" label="数量" width="80" align="right" />
        <el-table-column prop="unit" label="单位" width="70" align="center" />
        <el-table-column label="单价" width="110" align="right">
          <template #default="{ row }">{{ row.unitPrice ? '¥' + formatNum(row.unitPrice) : '—' }}</template>
        </el-table-column>
        <el-table-column label="折扣" width="80" align="center">
          <template #default="{ row }">{{ row.discountPct ? row.discountPct + '%' : '—' }}</template>
        </el-table-column>
        <el-table-column label="净价" width="110" align="right">
          <template #default="{ row }">{{ row.netPrice ? '¥' + formatNum(row.netPrice) : '—' }}</template>
        </el-table-column>
        <el-table-column label="行总计" width="120" align="right">
          <template #default="{ row }">
            <strong>{{ row.lineTotal ? '¥' + formatNum(row.lineTotal) : '—' }}</strong>
          </template>
        </el-table-column>
      </el-table>

      <!-- 金额汇总 -->
      <div class="summary-section">
        <el-row justify="end">
          <el-col :span="8">
            <div class="summary-item"><span>小计：</span><strong>¥{{ formatNum(quote.subtotal || 0) }}</strong></div>
            <div class="summary-item"><span>折扣：</span><strong>¥{{ formatNum(quote.discountTotal || 0) }}</strong></div>
            <div class="summary-item"><span>税额：</span><strong>¥{{ formatNum(quote.taxTotal || 0) }}</strong></div>
            <div class="summary-item total"><span>总计：</span><strong>¥{{ formatNum(quote.grandTotal || 0) }}</strong></div>
          </el-col>
        </el-row>
      </div>

      <!-- 备注 -->
      <div v-if="quote.remark" class="remark-section">
        <h4>备注</h4>
        <p>{{ quote.remark }}</p>
      </div>

      <!-- 页脚 -->
      <div class="preview-footer">
        <p>本报价单由 Smart CPQ 系统自动生成，如有疑问请联系销售代表。</p>
        <p>生成时间：{{ new Date().toLocaleString('zh-CN') }}</p>
      </div>
    </div>

    <template #footer>
      <el-button @click="visible = false">关闭</el-button>
      <el-button type="primary" @click="handlePrint" :loading="exportLoading">打印</el-button>
      <el-button type="success" @click="handleExportPdf" :loading="exportLoading">导出 PDF</el-button>
      <el-button type="success" @click="handleExportDocx" :loading="exportLoading">导出 Word</el-button>
    </template>
  </el-dialog>
</template>

<script setup lang="ts">
import { ref, watch } from 'vue'
import { ElMessage } from 'element-plus'
import { generateHtml, downloadPdf, downloadWord } from '@/api/quoting'
import type { QuoteVo, LineItemVo } from '@/api/quoting'

const props = defineProps<{
  modelValue: boolean
  quote: QuoteVo | null
  lineItems: LineItemVo[]
  templateId?: string // 用于 PDF/Word 后端模板生成
}>()

const emit = defineEmits<{ 'update:modelValue': [v: boolean] }>()

const visible = ref(props.modelValue)
const exportLoading = ref(false)
watch(() => props.modelValue, v => { visible.value = v })
watch(visible, v => { emit('update:modelValue', v) })

function typeLabel(t: string) {
  const m: Record<string, string> = {
    STANDARD: '标准报价', CUSTOM: '自定义报价',
    PRODUCT: '产品', ACCESSORY: '配件', SERVICE: '服务', BUNDLE: '捆绑包'
  }
  return m[t] || t
}

function formatNum(n: number) { return Number(n).toLocaleString() }

function getSummaries(param: { columns: any[]; data: LineItemVo[] }) {
  const sums: string[] = []
  param.columns.forEach((col, idx) => {
    if (idx === 0) { sums[idx] = '合计'; return }
    const vals = param.data.map(d => Number(d[col.property as keyof LineItemVo] || 0))
    if (['quantity', 'unitPrice', 'netPrice', 'lineTotal'].includes(String(col.property))) {
      sums[idx] = '¥' + vals.reduce((a, b) => a + b, 0).toLocaleString()
    } else { sums[idx] = '' }
  })
  return sums
}

function handleOpened() { /* 渲染完成后可做额外处理 */ }

function handlePrint() {
  // 有模板时用后端生成的完整 HTML；否则用当前预览 DOM
  if (props.templateId && props.quote?.quoteId) {
    printViaTemplate()
    return
  }
  printDom()
}

/** 使用当前预览 DOM 打印（无模板时的后备方案） */
function printDom() {
  const content = document.getElementById('quotePreviewContent')
  if (!content) return
  const win = window.open('', '_blank', 'width=900,height=700')
  if (!win) return
  win.document.write(`
    <html><head><title>报价单预览</title>
    <style>
      body { font-family: 'Microsoft YaHei', sans-serif; padding: 20px; color: #333; }
      .preview-header { display:flex; justify-content:space-between; }
      .preview-footer { margin-top:40px; text-align:center; color:#999; font-size:12px; }
      table { width:100%; border-collapse:collapse; margin:16px 0; }
      th,td { border:1px solid #dcdfe6; padding:8px; text-align:center; }
      .summary-section { text-align:right; margin-top:4px; }
      .summary-item { margin:4px 0; }
      .total { font-size:18px; color:#e6a23c; }
      .remark-section { margin-top:20px; padding:12px; background:#f5f7fa; border-radius:4px; }
    </style></head><body>
    ${content.innerHTML}
    </body></html>
  `)
  win.document.close()
  setTimeout(() => win.print(), 300)
}

/** 使用后端模板生成 HTML 后打印 */
async function printViaTemplate() {
  try {
    exportLoading.value = true
    const html = await generateHtml(props.quote!.quoteId, props.templateId!)
    const win = window.open('', '_blank', 'width=900,height=700')
    if (!win) { ElMessage.warning('请允许弹出窗口'); return }
    win.document.write(html)
    win.document.close()
    setTimeout(() => win.print(), 500)
  } catch (e: any) {
    ElMessage.error(e?.message || '打印失败')
  } finally {
    exportLoading.value = false
  }
}

/** 下载 Blob 文件 */
function downloadBlob(blob: Blob, filename: string) {
  const url = URL.createObjectURL(blob)
  const a = document.createElement('a')
  a.href = url
  a.download = filename
  document.body.appendChild(a)
  a.click()
  document.body.removeChild(a)
  URL.revokeObjectURL(url)
}

async function handleExportPdf() {
  if (!props.templateId || !props.quote?.quoteId) {
    ElMessage.warning('请先在报价单详情页选择一个模板')
    return
  }
  try {
    exportLoading.value = true
    const blob = await downloadPdf(props.quote.quoteId, props.templateId)
    downloadBlob(blob, `报价单_${props.quote.quoteNumber || props.quote.quoteId}.pdf`)
    ElMessage.success('PDF 导出成功')
  } catch (e: any) {
    ElMessage.error(e?.message || 'PDF 导出失败')
  } finally {
    exportLoading.value = false
  }
}

async function handleExportDocx() {
  if (!props.templateId || !props.quote?.quoteId) {
    ElMessage.warning('请先在报价单详情页选择一个模板')
    return
  }
  try {
    exportLoading.value = true
    const blob = await downloadWord(props.quote.quoteId, props.templateId)
    downloadBlob(blob, `报价单_${props.quote.quoteNumber || props.quote.quoteId}.docx`)
    ElMessage.success('Word 导出成功')
  } catch (e: any) {
    ElMessage.error(e?.message || 'Word 导出失败')
  } finally {
    exportLoading.value = false
  }
}
</script>

<style scoped>
.preview-body { font-size: 14px; }
.preview-header { display: flex; justify-content: space-between; align-items: flex-start; }
.company-info h2 { margin: 0; color: #409eff; }
.company-info p { margin: 4px 0 0; color: #909399; font-size: 16px; }
.quote-meta p { margin: 2px 0; font-size: 13px; }
.summary-section { margin-top: 12px; padding: 12px; background: #f5f7fa; border-radius: 4px; }
.summary-item { margin: 4px 0; display: flex; justify-content: space-between; padding: 0 20px; }
.summary-item.total { font-size: 16px; color: #e6a23c; border-top: 1px dashed #dcdfe6; padding-top: 8px; margin-top: 8px; }
.remark-section { margin-top: 20px; padding: 12px; background: #f5f7fa; border-radius: 4px; }
.remark-section h4 { margin: 0 0 8px; }
.remark-section p { margin: 0; color: #606266; }
.preview-footer { margin-top: 30px; text-align: center; color: #c0c4cc; font-size: 12px; }
.preview-footer p { margin: 2px 0; }
</style>
