<template>
  <div class="cpq-page">
    <div class="toolbar">
      <el-button type="primary" @click="handleCreate">新建方案</el-button>
      <el-input v-model="searchKey" placeholder="搜索方案名称..." style="width:240px;margin-left:12px" clearable @keyup.enter="fetchList" />
      <el-select v-model="statusFilter" placeholder="状态筛选" clearable style="width:140px;margin-left:12px" @change="fetchList">
        <el-option label="草稿" value="DRAFT" />
        <el-option label="编辑中" value="EDITING" />
        <el-option label="评审中" value="REVIEWING" />
        <el-option label="已通过" value="APPROVED" />
        <el-option label="已发布" value="PUBLISHED" />
      </el-select>
    </div>

    <el-table :data="list" v-loading="loading" stripe>
      <el-table-column prop="documentId" label="ID" width="80" />
      <el-table-column prop="documentName" label="方案名称" min-width="200" />
      <el-table-column prop="documentType" label="类型" width="130">
        <template #default="{ row }">{{ typeLabel(row.documentType) }}</template>
      </el-table-column>
      <el-table-column prop="version" label="版本" width="80">
        <template #default="{ row }">V{{ row.version || 1 }}</template>
      </el-table-column>
      <el-table-column prop="status" label="状态" width="100">
        <template #default="{ row }">
          <el-tag :type="statusTag(row.status)" size="small">{{ statusLabel(row.status) }}</el-tag>
        </template>
      </el-table-column>
      <el-table-column prop="createTime" label="创建时间" width="170" />
      <el-table-column label="操作" width="280" fixed="right">
        <template #default="{ row }">
          <el-button size="small" type="primary" link @click="openEditor(row)">编辑</el-button>
          <el-button size="small" type="warning" link @click="openCompare(row)">对比</el-button>
          <el-button size="small" type="success" link @click="openReview(row)">评审</el-button>
          <el-button size="small" type="danger" link @click="handleDelete(row)">删除</el-button>
        </template>
      </el-table-column>
    </el-table>

    <el-pagination
      v-model:current-page="pageNum" v-model:page-size="pageSize"
      :total="total" layout="total, prev, pager, next"
      @current-change="fetchList" style="margin-top:16px;justify-content:flex-end"
    />

    <!-- 新建方案弹窗 -->
    <el-dialog v-model="showDialog" :title="editingId ? '编辑方案' : '新建方案'" width="520px">
      <el-form :model="form" label-width="100px">
        <el-form-item label="方案名称" required>
          <el-input v-model="form.documentName" placeholder="请输入方案名称" />
        </el-form-item>
        <el-form-item label="方案类型" required>
          <el-select v-model="form.documentType" style="width:100%">
            <el-option label="技术方案" value="TECHNICAL_PROPOSAL" />
            <el-option label="商务方案" value="BUSINESS_PROPOSAL" />
            <el-option label="交付计划" value="DELIVERY_PLAN" />
            <el-option label="实施方案" value="IMPLEMENTATION" />
            <el-option label="验收标准" value="ACCEPTANCE" />
          </el-select>
        </el-form-item>
        <el-form-item label="关联报价单">
          <el-input-number v-model="form.quoteId" :min="1" style="width:100%" placeholder="可选" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="showDialog = false">取消</el-button>
        <el-button type="primary" @click="handleSubmit">确定</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import { listSolution, addSolution, updateSolution, delSolution } from '@/api/quoting'
import type { SolutionVo } from '@/api/quoting'

const router = useRouter()
const list = ref<SolutionVo[]>([])
const loading = ref(false)
const total = ref(0)
const pageNum = ref(1)
const pageSize = ref(10)
const searchKey = ref('')
const statusFilter = ref('')
const showDialog = ref(false)
const editingId = ref<number | null>(null)
const form = ref<Partial<SolutionVo>>({ documentType: 'TECHNICAL_PROPOSAL' })

function typeLabel(t?: string) {
  const m: Record<string, string> = { TECHNICAL_PROPOSAL: '技术方案', BUSINESS_PROPOSAL: '商务方案', DELIVERY_PLAN: '交付计划', IMPLEMENTATION: '实施方案', ACCEPTANCE: '验收标准' }
  return m[t || ''] || t || ''
}
function statusLabel(s?: string) {
  const m: Record<string, string> = { DRAFT: '草稿', EDITING: '编辑中', REVIEWING: '评审中', APPROVED: '已通过', PUBLISHED: '已发布' }
  return m[s || ''] || s || ''
}
function statusTag(s?: string) {
  const m: Record<string, string> = { DRAFT: 'info', EDITING: '', REVIEWING: 'warning', APPROVED: 'success', PUBLISHED: 'success' }
  return m[s || ''] || 'info'
}

async function fetchList() {
  loading.value = true
  try {
    const params: Record<string, unknown> = { pageNum: pageNum.value, pageSize: pageSize.value }
    if (searchKey.value) params.documentName = searchKey.value
    if (statusFilter.value) params.status = statusFilter.value
    const res = await listSolution(params)
    list.value = (res as any).rows || []
    total.value = (res as any).total || 0
  } finally { loading.value = false }
}

function handleCreate() {
  editingId.value = null
  form.value = { documentType: 'TECHNICAL_PROPOSAL' }
  showDialog.value = true
}

async function handleSubmit() {
  if (!form.value.documentName) { ElMessage.warning('请输入方案名称'); return }
  if (editingId.value) {
    await updateSolution({ ...form.value, documentId: editingId.value })
    ElMessage.success('更新成功')
  } else {
    await addSolution(form.value)
    ElMessage.success('创建成功')
  }
  showDialog.value = false
  fetchList()
}

async function handleDelete(row: SolutionVo) {
  await ElMessageBox.confirm(`确认删除方案「${row.documentName}」？`, '警告', { type: 'warning' })
  await delSolution(row.documentId!)
  ElMessage.success('已删除')
  fetchList()
}

function openEditor(row: SolutionVo) { router.push(`/solution/${row.documentId}/editor`) }
function openCompare(row: SolutionVo) { router.push(`/solution/${row.documentId}/compare`) }
function openReview(row: SolutionVo) { router.push(`/solution/${row.documentId}/review`) }

onMounted(() => fetchList())
</script>
