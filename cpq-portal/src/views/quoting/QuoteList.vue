<template>
  <div class="cpq-page">
    <div class="search-bar">
      <el-input v-model="searchForm.quoteNumber" placeholder="报价单号" clearable style="width: 180px" @keyup.enter="handleSearch" />
      <el-select v-model="searchForm.status" placeholder="状态" clearable style="width: 140px">
        <el-option label="草稿" value="DRAFT" />
        <el-option label="审批中" value="APPROVING" />
        <el-option label="已批准" value="APPROVED" />
        <el-option label="已发送" value="SENT" />
        <el-option label="赢单" value="WON" />
        <el-option label="输单" value="LOST" />
      </el-select>
      <el-button type="primary" @click="handleSearch">搜索</el-button>
      <el-button @click="resetSearch">重置</el-button>
    </div>
    <div class="toolbar">
      <el-button type="primary" @click="handleCreate">新增报价单</el-button>
    </div>
    <el-table v-loading="store.loading" :data="store.quoteList" stripe>
      <el-table-column prop="quoteNumber" label="报价单号" width="160" />
      <el-table-column prop="accountName" label="客户" min-width="140" />
      <el-table-column prop="quoteType" label="类型" width="100" />
      <el-table-column prop="grandTotal" label="总金额" width="120">
        <template #default="{ row }">{{ row.grandTotal ? '¥' + Number(row.grandTotal).toLocaleString() : '-' }}</template>
      </el-table-column>
      <el-table-column prop="status" label="状态" width="100">
        <template #default="{ row }">
          <el-tag :type="statusType(row.status)">{{ row.status }}</el-tag>
        </template>
      </el-table-column>
      <el-table-column prop="createTime" label="创建时间" width="160" />
      <el-table-column label="操作" width="200" fixed="right">
        <template #default="{ row }">
          <el-button size="small" @click="handleView(row)">详情</el-button>
          <el-button size="small" type="primary" @click="handleEdit(row)">编辑</el-button>
          <el-button size="small" type="danger" @click="handleDelete(row)">删除</el-button>
        </template>
      </el-table-column>
    </el-table>
    <el-pagination v-model:current-page="pageNum" v-model:page-size="pageSize" :total="total" layout="total, prev, pager, next" @change="loadData" />

    <el-dialog v-model="dialogVisible" :title="dialogTitle" width="650px" @close="resetForm">
      <el-form :model="form" label-width="100px">
        <el-form-item label="报价单号" v-if="form.quoteId"><strong>{{ form.quoteNumber }}</strong></el-form-item>
        <el-form-item label="客户ID" required v-if="!form.quoteId">
          <el-input-number v-model="form.accountId" :min="1" />
        </el-form-item>
        <el-form-item label="客户名称">
          <el-input v-model="form.accountName" placeholder="客户名称" />
        </el-form-item>
        <el-form-item label="类型">
          <el-select v-model="form.quoteType">
            <el-option label="标准报价" value="STANDARD" />
            <el-option label="续约报价" value="RENEWAL" />
            <el-option label="修订报价" value="REVISION" />
          </el-select>
        </el-form-item>
        <el-form-item label="币种">
          <el-select v-model="form.currency"><el-option label="CNY" value="CNY" /></el-select>
        </el-form-item>
        <el-form-item label="有效期至">
          <el-date-picker v-model="form.validUntil" type="date" />
        </el-form-item>
        <el-form-item label="备注">
          <el-input v-model="form.remark" type="textarea" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" @click="handleSubmit">确定</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import { useQuoteStore } from '@/store/quote'
import type { QuoteVo, QuoteBo } from '@/api/quoting'

const router = useRouter()
const store = useQuoteStore()
const pageNum = ref(1)
const pageSize = ref(10)
const total = ref(0)
const dialogVisible = ref(false)
const dialogTitle = ref('新增报价单')

const searchForm = reactive({ quoteNumber: '', status: '' })
const form = reactive<QuoteBo>({ quoteType: 'STANDARD', currency: 'CNY' })

async function loadData() {
  await store.fetchQuoteList({ pageNum: pageNum.value, pageSize: pageSize.value, ...searchForm })
  total.value = (store.quoteList.length > 0) ? 100 : 0
}

function handleSearch() { pageNum.value = 1; loadData() }
function resetSearch() { searchForm.quoteNumber = ''; searchForm.status = ''; handleSearch() }

function statusType(s: string) {
  const m: Record<string, string> = { DRAFT: 'info', APPROVED: 'success', SENT: 'primary', WON: 'success', LOST: 'danger', REJECTED: 'danger' }
  return m[s] || 'info'
}

function handleCreate() { dialogTitle.value = '新增报价单'; Object.assign(form, { quoteId: undefined, quoteType: 'STANDARD', currency: 'CNY', accountId: undefined, accountName: '' }); dialogVisible.value = true }
function handleEdit(row: QuoteVo) { dialogTitle.value = '编辑报价单'; Object.assign(form, row); dialogVisible.value = true }
function handleView(row: QuoteVo) { router.push('/quoting/' + row.quoteId) }

async function handleDelete(row: QuoteVo) {
  await ElMessageBox.confirm('确定删除报价单 ' + row.quoteNumber + ' 吗？', '提示', { type: 'warning' })
  await store.removeQuote(row.quoteId)
  ElMessage.success('删除成功')
  loadData()
}

async function handleSubmit() {
  try {
    if (form.quoteId) {
      await store.editQuote(form as QuoteBo)
      ElMessage.success('修改成功')
    } else {
      await store.createQuote(form as QuoteBo)
      ElMessage.success('新增成功')
    }
    dialogVisible.value = false
    loadData()
  } catch (e: any) {
    ElMessage.error(e?.message || '操作失败，请稍后重试')
  }
}

function resetForm() { Object.assign(form, { quoteId: undefined, quoteType: 'STANDARD', currency: 'CNY' }) }

onMounted(() => { loadData() })
</script>

<style scoped>
.cpq-page { padding: 16px; }
.search-bar { display: flex; gap: 12px; align-items: center; margin-bottom: 12px; flex-wrap: wrap; }
.toolbar { margin-bottom: 12px; }
</style>
