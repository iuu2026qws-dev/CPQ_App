<template>
  <div class="cpq-page">
    <!-- 搜索栏 -->
    <div class="search-bar">
      <el-input v-model="searchForm.templateName" placeholder="模板名称" clearable style="width: 200px" @keyup.enter="handleSearch" />
      <el-select v-model="searchForm.templateType" placeholder="模板类型" clearable style="width: 150px">
        <el-option label="标准报价" value="STANDARD" />
        <el-option label="PDF模板" value="PDF" />
        <el-option label="Word模板" value="WORD" />
        <el-option label="Excel模板" value="EXCEL" />
      </el-select>
      <el-button type="primary" @click="handleSearch">搜索</el-button>
      <el-button @click="resetSearch">重置</el-button>
    </div>

    <!-- 工具栏 -->
    <div class="toolbar">
      <el-button type="primary" @click="handleCreate">新增模板</el-button>
      <el-button @click="loadData">
        <el-icon><Refresh /></el-icon> 刷新
      </el-button>
    </div>

    <!-- 模板列表表格 -->
    <el-table v-loading="loading" :data="tableData" stripe>
      <el-table-column prop="templateName" label="模板名称" min-width="160" />
      <el-table-column prop="templateType" label="格式类型" width="100">
        <template #default="{ row }">
          <el-tag :type="typeTag(row.templateType)" size="small">{{ typeLabel(row.templateType) }}</el-tag>
        </template>
      </el-table-column>
      <el-table-column prop="isDefault" label="默认" width="70">
        <template #default="{ row }">
          <el-tag v-if="row.isDefault === '1'" type="success" size="small">默认</el-tag>
          <span v-else style="color: #999">-</span>
        </template>
      </el-table-column>
      <el-table-column prop="status" label="状态" width="80">
        <template #default="{ row }">
          <el-tag :type="row.status === '0' ? 'info' : 'success'" size="small">
            {{ row.status === '0' ? '停用' : '启用' }}
          </el-tag>
        </template>
      </el-table-column>
      <el-table-column prop="remark" label="备注" min-width="120" show-overflow-tooltip />
      <el-table-column label="操作" width="320" fixed="right">
        <template #default="{ row }">
          <el-button size="small" type="warning" link @click="handleDesign(row)">设计</el-button>
          <el-button size="small" type="primary" link @click="handlePreview(row)">预览</el-button>
          <el-button size="small" type="primary" link @click="handleEdit(row)">编辑</el-button>
          <el-button v-if="row.isDefault !== '1'" size="small" type="success" link @click="handleSetDefault(row)">设默认</el-button>
          <el-button size="small" type="danger" link @click="handleDelete(row)">删除</el-button>
        </template>
      </el-table-column>
    </el-table>

    <!-- 分页 -->
    <el-pagination
      v-model:current-page="pageNum"
      v-model:page-size="pageSize"
      :total="total"
      layout="total, prev, pager, next"
      @change="loadData"
      style="margin-top: 16px"
    />

    <!-- 新增/编辑弹窗 -->
    <el-dialog v-model="dialogVisible" :title="dialogTitle" width="680px" @close="resetForm">
      <el-tabs v-model="editTab">
        <el-tab-pane label="基本信息" name="basic">
          <el-form :model="form" label-width="100px">
            <el-form-item label="模板名称" required>
              <el-input v-model="form.templateName" placeholder="如：标准报价模板" maxlength="64" />
            </el-form-item>
            <el-form-item label="格式类型" required>
              <el-select v-model="form.templateType" style="width: 100%" @change="onTypeChange">
                <el-option label="标准报价（HTML）" value="STANDARD" />
                <el-option label="PDF模板" value="PDF" />
                <el-option label="Word模板" value="WORD" />
                <el-option label="Excel模板" value="EXCEL" />
              </el-select>
              <div class="form-hint" v-text="typeHint" />
            </el-form-item>
            <el-form-item label="状态">
              <el-switch v-model="formStatus" active-text="启用" inactive-text="停用" />
            </el-form-item>
            <el-form-item label="备注">
              <el-input v-model="form.remark" type="textarea" :rows="2" placeholder="备注说明" maxlength="200" />
            </el-form-item>
          </el-form>
        </el-tab-pane>
        <el-tab-pane label="高级内容" name="advanced">
          <div class="advanced-hint">
            <el-alert type="info" :closable="false" show-icon>
              <template #title>
                <span>HTML模板内容 — 用于报价单渲染。建议通过「设计」按钮进行可视化编辑，此处供高级用户直接修改 HTML 源码。</span>
              </template>
            </el-alert>
          </div>
          <el-form label-width="0">
            <el-form-item>
              <el-input v-model="form.templateContent" type="textarea" :rows="14" placeholder="HTML 模板内容（可选，留空则使用系统默认模板）" style="font-family: 'SF Mono', 'Monaco', 'Menlo', monospace; font-size: 12px;" />
            </el-form-item>
          </el-form>
          <!-- 占位符参考 -->
          <el-collapse style="margin-top: 8px">
            <el-collapse-item title="可用占位符参考 (Placeholder Reference)" name="ref">
              <div class="placeholder-ref">
                <div class="ref-group">
                  <div class="ref-group-title">报价单头部 &#123;&#123;quote.xxx&#125;&#125;</div>
                  <code v-for="p in quotePlaceholders" :key="p">{{ p }}</code>
                </div>
                <div class="ref-group">
                  <div class="ref-group-title">行项目 &#123;&#123;lines.table&#125;&#125;</div>
                  <code>&#123;&#123;lines.table&#125;&#125;</code>
                  <span class="ref-note">— 由系统自动生成表格行</span>
                </div>
                <div class="ref-group">
                  <div class="ref-group-title">价格汇总 &#123;&#123;summary.xxx&#125;&#125;</div>
                  <code v-for="p in summaryPlaceholders" :key="p">{{ p }}</code>
                </div>
              </div>
            </el-collapse-item>
          </el-collapse>
        </el-tab-pane>
      </el-tabs>
      <template #footer>
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" :loading="submitLoading" @click="handleSubmit">确定</el-button>
      </template>
    </el-dialog>

    <!-- 预览弹窗（所有类型统一 HTML 展示 mock data + 设计布局） -->
    <el-dialog v-model="previewVisible" title="模板预览" width="980px" top="10px" :close-on-click-modal="false">
      <div v-if="previewLoading" style="text-align: center; padding: 40px">
        <el-icon class="is-loading" :size="32"><Loading /></el-icon>
        <p style="margin-top: 12px; color: #999">正在生成预览...</p>
      </div>
      <div v-else-if="previewHtml" class="preview-frame-wrapper">
        <iframe :srcdoc="previewHtml" class="preview-frame" sandbox="allow-same-origin" />
      </div>
      <el-empty v-else description="暂无预览内容" />
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Refresh, Loading } from '@element-plus/icons-vue'
import { 
  listTemplate, addTemplate, updateTemplate, delTemplate, 
  setDefaultTemplate, previewTemplate,
  type TemplateVo 
} from '@/api/quoting'

const router = useRouter()
const loading = ref(false)
const submitLoading = ref(false)
const pageNum = ref(1)
const pageSize = ref(10)
const total = ref(0)
const tableData = ref<TemplateVo[]>([])
const dialogVisible = ref(false)
const dialogTitle = ref('新增模板')
const editTab = ref('basic')
const previewVisible = ref(false)
const previewLoading = ref(false)
const previewHtml = ref('')

const searchForm = reactive({ templateName: '', templateType: '' })
const form = reactive<{ templateId?: string; templateName: string; templateType: string; templateContent: string; status: string; remark: string; isDefault?: string }>({
  templateName: '',
  templateType: 'STANDARD',
  templateContent: '',
  status: '1',
  remark: ''
})

const formStatus = computed({
  get: () => form.status === '1',
  set: (v: boolean) => { form.status = v ? '1' : '0' }
})

const quotePlaceholders = [
  '{{quote.quoteNumber}}', '{{quote.quoteType}}', '{{quote.accountName}}',
  '{{quote.currency}}', '{{quote.status}}', '{{quote.createTime}}',
  '{{quote.validUntil}}', '{{quote.discountRate}}', '{{quote.grandTotal}}',
  '{{quote.remark}}'
]
const summaryPlaceholders = [
  '{{summary.subtotal}}', '{{summary.discount}}',
  '{{summary.grandTotal}}', '{{summary.lineCount}}'
]

const typeHint = computed(() => {
  const m: Record<string, string> = {
    STANDARD: '通过「设计」按钮可视化编排报价单布局（字段拖拽、网格/表格/汇总区域）。预览和输出均为 HTML 格式，支持打印。',
    PDF: '通过「设计」按钮可视化编排布局。预览/输出时系统将布局转换为 PDF 文件下载，数据为静态模拟数据供查看布局效果。',
    WORD: '通过「设计」按钮可视化编排布局。预览/输出时系统将布局生成为 .docx Word 文档下载，数据为静态模拟数据。',
    EXCEL: '通过「设计」按钮可视化编排布局。预览/输出时系统将布局生成为 .xlsx Excel 工作簿下载，数据为静态模拟数据。'
  }
  return m[form.templateType] || ''
})

function onTypeChange() {
  // 切换类型时保留当前 content，只是提示信息变化
}

function typeLabel(t: string): string {
  const m: Record<string, string> = { STANDARD: 'HTML', PDF: 'PDF', WORD: 'Word', EXCEL: 'Excel' }
  return m[t] || t
}

function typeTag(t: string): string {
  const m: Record<string, string> = { STANDARD: '', PDF: 'danger', WORD: 'primary', EXCEL: 'success' }
  return m[t] || ''
}

async function loadData() {
  loading.value = true
  try {
    const res = await listTemplate()
    let rows = res.rows || []
    // 本地过滤（后端 list 接口无分页参数时）
    if (searchForm.templateName) {
      rows = rows.filter(r => r.templateName.includes(searchForm.templateName))
    }
    if (searchForm.templateType) {
      rows = rows.filter(r => r.templateType === searchForm.templateType)
    }
    total.value = rows.length
    const start = (pageNum.value - 1) * pageSize.value
    tableData.value = rows.slice(start, start + pageSize.value)
  } catch {
    //
  } finally {
    loading.value = false
  }
}

function handleSearch() { pageNum.value = 1; loadData() }
function resetSearch() { searchForm.templateName = ''; searchForm.templateType = ''; handleSearch() }

function handleCreate() {
  dialogTitle.value = '新增模板'
  editTab.value = 'basic'
  Object.assign(form, { templateId: undefined, templateName: '', templateType: 'STANDARD', templateContent: '', status: '1', remark: '' })
  dialogVisible.value = true
}

function handleEdit(row: TemplateVo) {
  dialogTitle.value = '编辑模板'
  editTab.value = 'basic'
  Object.assign(form, {
    templateId: row.templateId,
    templateName: row.templateName,
    templateType: row.templateType,
    templateContent: row.templateContent || '',
    status: row.status || '1',
    remark: (row as any).remark || ''
  })
  dialogVisible.value = true
}

async function handleDelete(row: TemplateVo) {
  try {
    await ElMessageBox.confirm(`确定删除模板「${row.templateName}」吗？`, '提示', { type: 'warning' })
    await delTemplate(row.templateId)
    ElMessage.success('删除成功')
    loadData()
  } catch {
    // 取消
  }
}

function handleDesign(row: TemplateVo) {
  router.push(`/quoting/template-design/${row.templateId}`)
}

async function handleSetDefault(row: TemplateVo) {
  try {
    await ElMessageBox.confirm(`将「${row.templateName}」设为默认模板？同类型其他模板的默认标记将被取消。`, '提示', { type: 'info' })
    await setDefaultTemplate(row.templateId)
    ElMessage.success('已设为默认模板')
    loadData()
  } catch {
    // 取消
  }
}

/** 预览：STANDARD → 弹窗 HTML 展示；PDF/WORD/EXCEL → 下载文件查看 */
async function handlePreview(row: TemplateVo) {
  const type = row.templateType?.toUpperCase()
  if (type === 'PDF' || type === 'WORD' || type === 'EXCEL') {
    // 非 HTML 类型直接下载文件
    previewLoading.value = true
    try {
      await downloadPreviewFile(row.templateId, row.templateName, type)
      ElMessage.success('文件下载中...')
    } catch {
      ElMessage.error('预览生成失败')
    } finally {
      previewLoading.value = false
    }
    return
  }
  // STANDARD / 其他 → 弹窗 HTML 展示
  previewVisible.value = true
  previewHtml.value = ''
  previewLoading.value = true
  try {
    const res = await previewTemplate(row.templateId)
    previewHtml.value = (typeof res === 'string') ? res : ((res as any)?.data || (res as any)?.msg || '')
  } catch {
    ElMessage.error('预览生成失败')
  } finally {
    previewLoading.value = false
  }
}

/** 下载预览文件（PDF/WORD/EXCEL） */
async function downloadPreviewFile(templateId: string, templateName: string, type: string) {
  const extMap: Record<string, string> = { PDF: '.pdf', WORD: '.docx', EXCEL: '.xlsx' }
  const ext = extMap[type] || ''
  // 使用 fetch 请求 blob
  const baseURL = import.meta.env.VITE_API_BASE_URL || ''
  const token = localStorage.getItem('token') || ''
  const res = await fetch(`${baseURL}/cpq/quote/template/${templateId}/preview/file`, {
    headers: { 'Authorization': `Bearer ${token}`, 'clientid': 'e5cd7e4891bf95d1d19206ce24a7b32e' }
  })
  if (!res.ok) throw new Error('请求失败')
  const blob = await res.blob()
  const url = URL.createObjectURL(blob)
  const a = document.createElement('a')
  a.href = url
  a.download = `${templateName}_预览${ext}`
  document.body.appendChild(a)
  a.click()
  document.body.removeChild(a)
  URL.revokeObjectURL(url)
}

async function handleSubmit() {
  if (!form.templateName.trim()) {
    ElMessage.warning('请输入模板名称')
    return
  }
  submitLoading.value = true
  try {
    if (form.templateId) {
      await updateTemplate({
        templateId: form.templateId,
        templateName: form.templateName,
        templateType: form.templateType,
        templateContent: form.templateContent,
        status: form.status,
        remark: form.remark
      })
      ElMessage.success('修改成功')
    } else {
      await addTemplate({
        templateName: form.templateName,
        templateType: form.templateType,
        templateContent: form.templateContent,
        status: form.status,
        remark: form.remark
      })
      ElMessage.success('新增成功')
    }
    dialogVisible.value = false
    loadData()
  } catch (e: any) {
    ElMessage.error(e?.message || '操作失败')
  } finally {
    submitLoading.value = false
  }
}

function resetForm() {
  Object.assign(form, { templateId: undefined, templateName: '', templateType: 'STANDARD', templateContent: '', status: '1', remark: '' })
}

onMounted(() => { loadData() })
</script>

<style scoped>
.cpq-page { padding: 16px; }
.search-bar { display: flex; gap: 12px; align-items: center; margin-bottom: 12px; flex-wrap: wrap; }
.toolbar { margin-bottom: 12px; display: flex; gap: 8px; }
.preview-frame-wrapper {
  width: 100%;
  height: 72vh;
  border: 1px solid #ebeef5;
  border-radius: 4px;
  overflow: hidden;
}
.preview-frame {
  width: 100%;
  height: 100%;
  border: none;
}

/* 编辑弹窗 */
.form-hint { margin-top: 4px; font-size: 12px; color: #909399; line-height: 1.5; }
.advanced-hint { margin-bottom: 12px; }
.placeholder-ref { display: flex; flex-wrap: wrap; gap: 16px; }
.ref-group { min-width: 180px; margin-bottom: 8px; }
.ref-group-title { font-size: 13px; font-weight: 600; margin-bottom: 4px; color: #303133; }
.ref-group code { display: inline-block; padding: 2px 6px; margin: 2px 4px 2px 0; background: #f0f2f5; border-radius: 3px; font-size: 11px; color: #e6a23c; cursor: pointer; }
.ref-note { font-size: 11px; color: #909399; }
</style>
