<template>
  <div class="app-container">
    <!-- 搜索栏 -->
    <el-form :model="queryParams" :inline="true" class="search-form">
      <el-form-item label="模板名称">
        <el-input v-model="queryParams.templateName" placeholder="请输入模板名称" clearable @keyup.enter="handleQuery" style="width: 200px" />
      </el-form-item>
      <el-form-item label="模板类型">
        <el-select v-model="queryParams.templateType" placeholder="全部" clearable style="width: 140px">
          <el-option label="标准报价" value="STANDARD" />
          <el-option label="PDF" value="PDF" />
          <el-option label="Word" value="WORD" />
          <el-option label="Excel" value="EXCEL" />
        </el-select>
      </el-form-item>
      <el-form-item>
        <el-button type="primary" icon="Search" @click="handleQuery">搜索</el-button>
        <el-button icon="Refresh" @click="resetQuery">重置</el-button>
      </el-form-item>
    </el-form>

    <!-- 操作栏 -->
    <el-row :gutter="10" class="mb8">
      <el-col :span="1.5">
        <el-button type="primary" icon="Plus" @click="handleAdd">新增模板</el-button>
      </el-col>
      <el-col :span="1.5">
        <el-button type="danger" icon="Delete" :disabled="selectedIds.length === 0" @click="handleBatchDelete">批量删除</el-button>
      </el-col>
    </el-row>

    <!-- 模板列表 -->
    <el-table v-loading="loading" :data="list" @selection-change="handleSelectionChange">
      <el-table-column type="selection" width="55" />
      <el-table-column label="模板名称" prop="templateName" min-width="180" show-overflow-tooltip />
      <el-table-column label="模板类型" prop="templateType" width="120">
        <template #default="scope">
          <el-tag :type="typeTagColor(scope.row.templateType)" size="small">
            {{ typeLabel(scope.row.templateType) }}
          </el-tag>
        </template>
      </el-table-column>
      <el-table-column label="默认模板" width="100" align="center">
        <template #default="scope">
          <el-tag v-if="scope.row.isDefault === '1'" type="success" size="small">默认</el-tag>
          <span v-else class="text-muted">—</span>
        </template>
      </el-table-column>
      <el-table-column label="状态" width="80" align="center">
        <template #default="scope">
          <el-switch v-model="scope.row.status" active-value="0" inactive-value="1" @change="(val: string) => handleStatusChange(scope.row, val)" />
        </template>
      </el-table-column>
      <el-table-column label="创建时间" prop="createTime" width="170" />
      <el-table-column label="操作" width="360" fixed="right">
        <template #default="scope">
          <el-button link type="primary" icon="Edit" @click="handleDesign(scope.row)">设计</el-button>
          <el-button link type="primary" icon="Setting" @click="handleEdit(scope.row)">编辑</el-button>
          <el-button link type="success" icon="Star" @click="handleSetDefault(scope.row)" v-if="scope.row.isDefault !== '1'">设默认</el-button>
          <el-button link type="primary" icon="View" @click="handlePreview(scope.row)">预览</el-button>
          <el-button link type="danger" icon="Delete" @click="handleDelete(scope.row)">删除</el-button>
        </template>
      </el-table-column>
    </el-table>

    <pagination v-show="total > 0" :total="total" v-model:page="queryParams.pageNum" v-model:limit="queryParams.pageSize" @pagination="getList" />

    <!-- 新增/编辑对话框 -->
    <el-dialog :title="dialogTitle" v-model="dialogVisible" width="500px" destroy-on-close>
      <el-form :model="form" label-width="100px">
        <el-form-item label="模板名称" prop="templateName" required>
          <el-input v-model="form.templateName" placeholder="请输入模板名称" maxlength="200" />
        </el-form-item>
        <el-form-item label="模板类型" prop="templateType" required>
          <el-select v-model="form.templateType" style="width: 100%">
            <el-option label="标准报价（HTML）" value="STANDARD" />
            <el-option label="PDF 输出" value="PDF" />
            <el-option label="Word 可编辑" value="WORD" />
            <el-option label="Excel 表格" value="EXCEL" />
          </el-select>
        </el-form-item>
        <el-form-item label="备注">
          <el-input v-model="form.remark" type="textarea" :rows="3" placeholder="模板用途说明" maxlength="500" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" @click="submitForm">确定</el-button>
      </template>
    </el-dialog>

    <!-- 预览对话框 -->
    <el-dialog v-model="previewVisible" title="模板预览" width="80%" top="5vh" destroy-on-close>
      <div v-if="previewLoading" style="text-align:center;padding:60px"><el-icon class="is-loading" :size="32"><Loading /></el-icon><p>正在生成预览...</p></div>
      <iframe v-else-if="previewHtml" :srcdoc="previewHtml" style="width:100%;height:70vh;border:1px solid #ddd;border-radius:4px" />
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { listTemplate, getTemplate, addTemplate, updateTemplate, delTemplate, setDefaultTemplate, previewTemplate } from '@/api/cpq/template'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Loading } from '@element-plus/icons-vue'

const router = useRouter()
const loading = ref(false)
const total = ref(0)
const list = ref<any[]>([])
const selectedIds = ref<number[]>([])
const dialogVisible = ref(false)
const dialogTitle = ref('')
const form = reactive<any>({})

const queryParams = reactive({ pageNum: 1, pageSize: 10, templateName: '', templateType: '' })

const previewVisible = ref(false)
const previewLoading = ref(false)
const previewHtml = ref('')

function typeLabel(t: string) {
  const m: Record<string, string> = { STANDARD: 'HTML', PDF: 'PDF', WORD: 'Word', EXCEL: 'Excel' }
  return m[t] || t
}
function typeTagColor(t: string) {
  const m: Record<string, string> = { STANDARD: '', PDF: 'danger', WORD: 'primary', EXCEL: 'success' }
  return m[t] || 'info'
}

async function getList() {
  loading.value = true
  try {
    const res = await listTemplate(queryParams)
    list.value = res.rows || []
    total.value = res.total || 0
  } finally { loading.value = false }
}

function handleQuery() { queryParams.pageNum = 1; getList() }
function resetQuery() { queryParams.templateName = ''; queryParams.templateType = ''; handleQuery() }
function handleSelectionChange(rows: any[]) { selectedIds.value = rows.map(r => r.templateId) }

function handleAdd() {
  dialogTitle.value = '新增模板'
  Object.assign(form, { templateId: undefined, templateName: '', templateType: 'STANDARD', remark: '' })
  dialogVisible.value = true
}

async function handleEdit(row: any) {
  dialogTitle.value = '编辑模板'
  const res = await getTemplate(row.templateId)
  Object.assign(form, res.data)
  dialogVisible.value = true
}

async function submitForm() {
  if (!form.templateName) { ElMessage.warning('请输入模板名称'); return }
  if (form.templateId) {
    await updateTemplate(form)
  } else {
    await addTemplate(form)
  }
  ElMessage.success('操作成功')
  dialogVisible.value = false
  getList()
}

async function handleDelete(row: any) {
  await ElMessageBox.confirm(`确认删除模板「${row.templateName}」吗？`, '警告', { type: 'warning' })
  await delTemplate(row.templateId)
  ElMessage.success('删除成功')
  getList()
}

async function handleBatchDelete() {
  if (selectedIds.value.length === 0) return
  await ElMessageBox.confirm(`确认删除选中的 ${selectedIds.value.length} 个模板吗？`, '批量删除', { type: 'warning' })
  await request({ url: '/cpq/quote/template/batch', method: 'delete', data: selectedIds.value })
  ElMessage.success('批量删除成功')
  getList()
}

function handleDesign(row: any) {
  router.push(`/quoting/template-design/${row.templateId}`)
}

async function handleSetDefault(row: any) {
  await setDefaultTemplate(row.templateId)
  ElMessage.success(`已将「${row.templateName}」设为默认模板`)
  getList()
}

async function handlePreview(row: any) {
  const type = (row.templateType || '').toUpperCase()
  if (type === 'PDF' || type === 'WORD' || type === 'EXCEL') {
    // 非 HTML 类型：下载文件查看
    previewLoading.value = true
    try {
      const baseURL = import.meta.env.VITE_APP_BASE_API || ''
      const token = localStorage.getItem('token') || ''
      const res = await fetch(`${baseURL}/cpq/quote/template/${row.templateId}/preview/file`, {
        headers: { 'Authorization': `Bearer ${token}` }
      })
      if (!res.ok) throw new Error('请求失败')
      const blob = await res.blob()
      const extMap: Record<string, string> = { PDF: '.pdf', WORD: '.docx', EXCEL: '.xlsx' }
      const ext = extMap[type] || ''
      const url = URL.createObjectURL(blob)
      const a = document.createElement('a')
      a.href = url; a.download = `${row.templateName}_预览${ext}`
      document.body.appendChild(a); a.click(); document.body.removeChild(a)
      URL.revokeObjectURL(url)
      ElMessage.success('文件下载中...')
    } catch {
      ElMessage.error('预览生成失败')
    } finally {
      previewLoading.value = false
    }
    return
  }
  // STANDARD → 弹窗 HTML 展示
  previewVisible.value = true
  previewLoading.value = true
  previewHtml.value = ''
  try {
    const res = await previewTemplate(row.templateId)
    previewHtml.value = res.data || ''
  } catch {
    ElMessage.error('预览生成失败')
  } finally {
    previewLoading.value = false
  }
}

async function handleStatusChange(row: any, val: string) {
  await updateTemplate({ templateId: row.templateId, status: val, templateName: row.templateName, templateType: row.templateType })
  ElMessage.success('状态更新成功')
}

onMounted(getList)

// module augmentation for request
import request from '@/utils/request'
</script>

<style scoped>
.search-form { background: #fff; padding: 16px 16px 0; border-radius: 4px; margin-bottom: 16px; }
.mb8 { margin-bottom: 8px; }
.text-muted { color: #c0c4cc; }
</style>
