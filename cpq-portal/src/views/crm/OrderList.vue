<template>
  <div class="cpq-page">
    <div class="search-bar">
      <el-input v-model="searchForm.orderNumber" placeholder="订单编号" clearable style="width: 180px" @keyup.enter="handleSearch" />
      <el-input v-model="searchForm.orderName" placeholder="订单名称" clearable style="width: 180px" @keyup.enter="handleSearch" />
      <el-select v-model="searchForm.accountId" placeholder="客户" clearable filterable style="width: 200px">
        <el-option v-for="a in accountOptions" :key="a.accountId" :label="a.accountName" :value="a.accountId" />
      </el-select>
      <el-select v-model="searchForm.contractId" placeholder="合同" clearable filterable style="width: 200px">
        <el-option v-for="c in contractOptions" :key="c.contractId" :label="c.contractNumber" :value="c.contractId" />
      </el-select>
      <el-select v-model="searchForm.status" placeholder="状态" clearable style="width: 130px">
        <el-option label="草稿" value="DRAFT" />
        <el-option label="已确认" value="CONFIRMED" />
        <el-option label="生产中" value="IN_PRODUCTION" />
        <el-option label="已发货" value="SHIPPED" />
        <el-option label="已完成" value="COMPLETED" />
        <el-option label="已取消" value="CANCELLED" />
      </el-select>
      <el-button type="primary" @click="handleSearch">搜索</el-button>
      <el-button @click="resetSearch">重置</el-button>
    </div>
    <div class="toolbar">
      <el-button type="primary" @click="handleCreate">+ 新增订单</el-button>
      <el-button @click="loadData">刷新</el-button>
    </div>
    <el-table v-loading="loading" :data="tableData" stripe @row-click="handleRowClick" style="cursor: pointer">
      <el-table-column prop="orderNumber" label="订单编号" width="150" />
      <el-table-column prop="orderName" label="订单名称" min-width="160">
        <template #default="{ row }">
          <el-link type="primary" @click.stop="handleDetail(row)">{{ row.orderName }}</el-link>
        </template>
      </el-table-column>
      <el-table-column prop="accountName" label="客户" width="150" />
      <el-table-column prop="contractNumber" label="合同编号" width="150" />
      <el-table-column prop="status" label="状态" width="100">
        <template #default="{ row }">
          <el-tag :type="statusTagType(row.status)">{{ row.status }}</el-tag>
        </template>
      </el-table-column>
      <el-table-column prop="amount" label="金额" width="140">
        <template #default="{ row }">{{ row.amount ? '¥' + Number(row.amount).toLocaleString() : '-' }}</template>
      </el-table-column>
      <el-table-column prop="orderDate" label="日期" width="120" />
      <el-table-column label="操作" width="180" fixed="right">
        <template #default="{ row }">
          <el-button size="small" @click.stop="handleDetail(row)">详情</el-button>
          <el-button size="small" type="primary" @click.stop="handleEdit(row)">编辑</el-button>
          <el-button size="small" type="danger" @click.stop="handleDelete(row)">删除</el-button>
        </template>
      </el-table-column>
    </el-table>
    <el-pagination
      v-model:current-page="pageNum" v-model:page-size="pageSize" :total="total"
      layout="total, prev, pager, next" style="margin-top: 16px" @change="loadData"
    />

    <!-- 新增/编辑对话框 -->
    <el-dialog v-model="dialogVisible" :title="dialogTitle" width="550px">
      <el-form ref="formRef" :model="form" :rules="rules" label-width="100px">
        <el-form-item label="订单名称" prop="orderName">
          <el-input v-model="form.orderName" placeholder="请输入订单名称" maxlength="200" />
        </el-form-item>
        <el-form-item label="客户" prop="accountId">
          <el-select v-model="form.accountId" filterable placeholder="选择客户" style="width: 100%">
            <el-option v-for="a in accountOptions" :key="a.accountId" :label="a.accountName" :value="a.accountId" />
          </el-select>
        </el-form-item>
        <el-form-item label="关联合同">
          <el-select v-model="form.contractId" filterable clearable placeholder="选择合同" style="width: 100%">
            <el-option v-for="c in contractOptions" :key="c.contractId" :label="c.contractNumber" :value="c.contractId" />
          </el-select>
        </el-form-item>
        <el-form-item label="订单日期">
          <el-date-picker v-model="form.orderDate" type="date" style="width: 100%" value-format="YYYY-MM-DD" />
        </el-form-item>
        <el-form-item label="状态">
          <el-select v-model="form.status" style="width: 100%">
            <el-option label="草稿" value="DRAFT" />
            <el-option label="已确认" value="CONFIRMED" />
            <el-option label="生产中" value="IN_PRODUCTION" />
            <el-option label="已发货" value="SHIPPED" />
            <el-option label="已完成" value="COMPLETED" />
          </el-select>
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
import { ElMessage, ElMessageBox, type FormInstance, type FormRules } from 'element-plus'
import { listOrders, addOrder, updateOrder, delOrder, listAccounts, listContracts, type OrderVo, type OrderBo, type AccountVo, type ContractVo } from '@/api/cpq/crm'

const router = useRouter()
const loading = ref(false)
const tableData = ref<OrderVo[]>([])
const pageNum = ref(1)
const pageSize = ref(10)
const total = ref(0)
const dialogVisible = ref(false)
const dialogTitle = ref('新增订单')
const formRef = ref<FormInstance>()
const accountOptions = ref<AccountVo[]>([])
const contractOptions = ref<ContractVo[]>([])

const searchForm = reactive({ orderNumber: '', orderName: '', accountId: undefined as number | undefined, contractId: undefined as number | undefined, status: '' })
const form = reactive<OrderBo>({ orderName: '', accountId: 0, contractId: undefined, status: 'DRAFT', orderDate: undefined })

const rules: FormRules = {
  orderName: [{ required: true, message: '请输入订单名称', trigger: 'blur' }],
  accountId: [{ required: true, message: '请选择客户', trigger: 'change' }]
}

function statusTagType(s: string) { const m: Record<string, string> = { DRAFT: 'info', CONFIRMED: 'primary', IN_PRODUCTION: 'warning', SHIPPED: 'success', COMPLETED: 'success', CANCELLED: 'danger' }; return m[s] || 'info' }

async function loadData() {
  loading.value = true
  try {
    const params: Record<string, unknown> = { pageNum: pageNum.value, pageSize: pageSize.value }
    if (searchForm.orderNumber) params.orderNumber = searchForm.orderNumber
    if (searchForm.orderName) params.orderName = searchForm.orderName
    if (searchForm.accountId) params.accountId = searchForm.accountId
    if (searchForm.contractId) params.contractId = searchForm.contractId
    if (searchForm.status) params.status = searchForm.status
    const res = await listOrders(params)
    tableData.value = res.rows || []
    total.value = res.total || 0
  } catch (e: any) {
    ElMessage.error(e?.message || '加载失败')
  } finally {
    loading.value = false
  }
}

async function loadRefs() {
  try {
    const [a, c] = await Promise.all([listAccounts({ pageSize: 999 }), listContracts({ pageSize: 999 })])
    accountOptions.value = a.rows || []
    contractOptions.value = c.rows || []
  } catch { /* ignore */ }
}

function handleSearch() { pageNum.value = 1; loadData() }
function resetSearch() { searchForm.orderNumber = ''; searchForm.orderName = ''; searchForm.accountId = undefined; searchForm.contractId = undefined; searchForm.status = ''; handleSearch() }
function handleDetail(row: OrderVo) { router.push('/crm/order/' + row.orderId) }
function handleRowClick(row: OrderVo) { router.push('/crm/order/' + row.orderId) }

function handleCreate() {
  dialogTitle.value = '新增订单'
  Object.assign(form, { orderId: undefined, orderName: '', accountId: 0, contractId: undefined, status: 'DRAFT', orderDate: undefined })
  dialogVisible.value = true
}

function handleEdit(row: OrderVo) {
  dialogTitle.value = '编辑订单'
  Object.assign(form, { orderId: row.orderId, orderName: row.orderName, accountId: row.accountId, contractId: row.contractId, status: row.status, orderDate: row.orderDate })
  dialogVisible.value = true
}

async function handleDelete(row: OrderVo) {
  try {
    await ElMessageBox.confirm('确定删除订单 "' + row.orderName + '" 吗？', '提示', { type: 'warning' })
    await delOrder(row.orderId)
    ElMessage.success('删除成功')
    loadData()
  } catch (e: any) {
    if (e !== 'cancel') ElMessage.error(e?.message || '删除失败')
  }
}

async function handleSubmit() {
  if (!formRef.value) return
  await formRef.value.validate(async (valid) => {
    if (!valid) return
    try {
      if (form.orderId) {
        await updateOrder(form)
        ElMessage.success('修改成功')
      } else {
        await addOrder(form)
        ElMessage.success('新增成功')
      }
      dialogVisible.value = false
      loadData()
    } catch (e: any) {
      ElMessage.error(e?.message || '操作失败')
    }
  })
}

onMounted(() => { loadData(); loadRefs() })
</script>

<style scoped>
.cpq-page { padding: 16px; }
.search-bar { display: flex; gap: 12px; align-items: center; margin-bottom: 12px; flex-wrap: wrap; }
.toolbar { margin-bottom: 12px; display: flex; gap: 8px; }
</style>
