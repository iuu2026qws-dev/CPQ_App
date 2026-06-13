<template>
  <div class="cpq-page">
    <div class="toolbar">
      <el-button type="primary" @click="handleCreate">新建变更单</el-button>
      <el-select v-model="statusFilter" placeholder="状态筛选" clearable style="width:140px;margin-left:12px" @change="fetchList">
        <el-option label="草稿" value="DRAFT" /><el-option label="分析中" value="ANALYZING" />
        <el-option label="已分析" value="ANALYZED" /><el-option label="已通过" value="APPROVED" />
        <el-option label="已驳回" value="REJECTED" /><el-option label="已实施" value="IMPLEMENTED" />
        <el-option label="已关闭" value="CLOSED" />
      </el-select>
    </div>
    <el-table :data="list" v-loading="loading" stripe @row-click="selectRow">
      <el-table-column prop="ecnNumber" label="ECN编号" width="180" />
      <el-table-column prop="title" label="标题" min-width="200" />
      <el-table-column prop="changeType" label="变更类型" width="100" />
      <el-table-column prop="severity" label="严重程度" width="100">
        <template #default="{ row }"><el-tag :type="sevTag(row.severity)" size="small">{{ row.severity }}</el-tag></template>
      </el-table-column>
      <el-table-column prop="status" label="状态" width="100">
        <template #default="{ row }"><el-tag :type="statusTag(row.status)" size="small">{{ row.status }}</el-tag></template>
      </el-table-column>
      <el-table-column prop="originatorName" label="发起人" width="100" />
      <el-table-column prop="createTime" label="创建时间" width="170" />
      <el-table-column label="操作" width="240" fixed="right">
        <template #default="{ row }">
          <el-button size="small" link type="primary" @click.stop="viewImpact(row)">影响分析</el-button>
          <el-button size="small" link type="warning" @click.stop="submitEcn(row)" :disabled="row.status!=='DRAFT'">提交</el-button>
          <el-button size="small" link type="success" @click.stop="closeEcn(row)" :disabled="row.status==='CLOSED'">关闭</el-button>
          <el-button size="small" link type="danger" @click.stop="handleDelete(row)">删除</el-button>
        </template>
      </el-table-column>
    </el-table>
    <el-pagination v-model:current-page="page" v-model:page-size="size" :total="total" layout="total,prev,pager,next" @current-change="fetchList" style="margin-top:16px;justify-content:flex-end" />

    <el-dialog v-model="showDialog" title="新建ECN变更单" width="560px">
      <el-form :model="form" label-width="100px">
        <el-form-item label="标题" required><el-input v-model="form.title" /></el-form-item>
        <el-form-item label="变更类型" required>
          <el-select v-model="form.changeType" style="width:100%">
            <el-option label="产品变更" value="PRODUCT" /><el-option label="BOM变更" value="BOM" />
            <el-option label="价格变更" value="PRICE" /><el-option label="工艺变更" value="PROCESS" />
            <el-option label="文档变更" value="DOCUMENT" />
          </el-select>
        </el-form-item>
        <el-form-item label="严重程度"><el-select v-model="form.severity" style="width:100%">
          <el-option label="严重" value="CRITICAL" /><el-option label="重要" value="MAJOR" />
          <el-option label="一般" value="NORMAL" /><el-option label="轻微" value="MINOR" />
        </el-select></el-form-item>
        <el-form-item label="变更原因"><el-input v-model="form.reason" type="textarea" :rows="3" /></el-form-item>
      </el-form>
      <template #footer><el-button @click="showDialog=false">取消</el-button><el-button type="primary" @click="doCreate">确定</el-button></template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import request from '@/utils/request'

const router = useRouter()
const list = ref<any[]>([])
const loading = ref(false)
const total = ref(0); const page = ref(1); const size = ref(10)
const statusFilter = ref('')
const showDialog = ref(false)
const form = ref({ title: '', changeType: 'PRODUCT', severity: 'NORMAL', reason: '' })

function sevTag(s: string) { const m: Record<string,string>={CRITICAL:'danger',MAJOR:'warning',NORMAL:'',MINOR:'info'}; return m[s]||'info' }
function statusTag(s: string) { const m: Record<string,string>={DRAFT:'info',ANALYZING:'warning',ANALYZED:'',APPROVED:'success',REJECTED:'danger',IMPLEMENTED:'success',CLOSED:'info'}; return m[s]||'info' }

async function fetchList() {
  loading.value = true
  try {
    const params: any = { pageNum: page.value, pageSize: size.value }
    if (statusFilter.value) params.status = statusFilter.value
    const res = await request.get('/cpq/ecn/order/list', { params })
    list.value = Array.isArray(res) ? res : (res.rows || []); total.value = Array.isArray(res) ? res.length : (res.total || 0)
  } finally { loading.value = false }
}

function handleCreate() { form.value = { title: '', changeType: 'PRODUCT', severity: 'NORMAL', reason: '' }; showDialog.value = true }
async function doCreate() {
  if (!form.value.title) { ElMessage.warning('请输入标题'); return }
  await request.post('/cpq/ecn/order', form.value)
  ElMessage.success('变更单已创建'); showDialog.value = false; fetchList()
}

async function submitEcn(row: any) { await request.post(`/cpq/ecn/order/${row.changeOrderId}/submit`); ElMessage.success('已提交分析'); fetchList() }
async function closeEcn(row: any) { await request.post(`/cpq/ecn/order/${row.changeOrderId}/close`); ElMessage.success('已关闭'); fetchList() }
function viewImpact(row: any) { router.push(`/ecn/${row.changeOrderId}/impact`) }
async function handleDelete(row: any) {
  await ElMessageBox.confirm('确认删除？', '警告', { type: 'warning' })
  await request.delete(`/cpq/ecn/order/${row.changeOrderId}`); ElMessage.success('已删除'); fetchList()
}
function selectRow(row: any) { viewImpact(row) }

onMounted(() => fetchList())
</script>
