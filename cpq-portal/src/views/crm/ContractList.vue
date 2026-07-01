<template>
  <div class="cpq-page">
    <div class="search-bar">
      <el-input v-model="searchForm.contractNumber" placeholder="合同编号" clearable style="width: 180px" @keyup.enter="handleSearch" />
      <el-input v-model="searchForm.contractName" placeholder="合同名称" clearable style="width: 180px" @keyup.enter="handleSearch" />
      <el-select v-model="searchForm.accountId" placeholder="客户" clearable filterable style="width: 200px">
        <el-option v-for="a in accountOptions" :key="a.accountId" :label="a.accountName" :value="a.accountId" />
      </el-select>
      <el-select v-model="searchForm.contractType" placeholder="类型" clearable style="width: 130px">
        <el-option label="项目合同" value="PROJECT" />
        <el-option label="框架合同" value="FRAMEWORK" />
        <el-option label="补充协议" value="SUPPLEMENT" />
      </el-select>
      <el-select v-model="searchForm.status" placeholder="状态" clearable style="width: 130px">
        <el-option label="草稿" value="DRAFT" />
        <el-option label="生效中" value="ACTIVE" />
        <el-option label="已终止" value="TERMINATED" />
        <el-option label="已过期" value="EXPIRED" />
      </el-select>
      <el-button type="primary" @click="handleSearch">搜索</el-button>
      <el-button @click="resetSearch">重置</el-button>
    </div>
    <div class="toolbar">
      <el-button type="primary" @click="handleCreate">+ 新增合同</el-button>
      <el-button @click="handleFromOpp">从商机生成</el-button>
      <el-button @click="loadData">刷新</el-button>
    </div>
    <el-table v-loading="loading" :data="tableData" stripe @row-click="handleRowClick" style="cursor: pointer">
      <el-table-column prop="contractNumber" label="合同编号" width="150" />
      <el-table-column prop="contractName" label="合同名称" min-width="160">
        <template #default="{ row }">
          <el-link type="primary" @click.stop="handleDetail(row)">{{ row.contractName }}</el-link>
        </template>
      </el-table-column>
      <el-table-column prop="accountName" label="客户" width="150" />
      <el-table-column prop="contractType" label="类型" width="100">
        <template #default="{ row }">
          <el-tag :type="typeTagType(row.contractType)">{{ typeLabel(row.contractType) }}</el-tag>
        </template>
      </el-table-column>
      <el-table-column prop="status" label="状态" width="100">
        <template #default="{ row }">
          <el-tag :type="statusTagType(row.status)">{{ row.status }}</el-tag>
        </template>
      </el-table-column>
      <el-table-column prop="amount" label="金额" width="140">
        <template #default="{ row }">{{ row.amount ? '¥' + Number(row.amount).toLocaleString() : '-' }}</template>
      </el-table-column>
      <el-table-column prop="startDate" label="开始日期" width="120" />
      <el-table-column prop="endDate" label="结束日期" width="120" />
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

    <!-- 从商机生成对话框 -->
    <el-dialog v-model="oppSelectVisible" title="选择商机生成合同" width="500px">
      <el-select v-model="selectedOppId" placeholder="搜索并选择商机" filterable style="width: 100%">
        <el-option v-for="o in oppOptions" :key="o.opportunityId" :label="o.opportunityName + ' (' + o.accountName + ')'" :value="o.opportunityId" />
      </el-select>
      <template #footer>
        <el-button @click="oppSelectVisible = false">取消</el-button>
        <el-button type="primary" @click="confirmFromOpp">下一步</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import { listContracts, addContract, updateContract, delContract, listAccounts, listOpportunities, generateContractNumber, type ContractVo, type ContractBo, type AccountVo, type OpportunityVo } from '@/api/cpq/crm'

const router = useRouter()
const loading = ref(false)
const tableData = ref<ContractVo[]>([])
const pageNum = ref(1)
const pageSize = ref(10)
const total = ref(0)
const accountOptions = ref<AccountVo[]>([])
const oppOptions = ref<OpportunityVo[]>([])
const oppSelectVisible = ref(false)
const selectedOppId = ref<number | null>(null)

const searchForm = reactive({ contractNumber: '', contractName: '', accountId: undefined as number | undefined, contractType: '', status: '' })

function typeTagType(t: string) { const m: Record<string, string> = { PROJECT: 'primary', FRAMEWORK: 'success', SUPPLEMENT: 'warning' }; return m[t] || 'info' }
function typeLabel(t: string) { const m: Record<string, string> = { PROJECT: '项目合同', FRAMEWORK: '框架合同', SUPPLEMENT: '补充协议' }; return m[t] || t }
function statusTagType(s: string) { const m: Record<string, string> = { DRAFT: 'info', ACTIVE: 'success', TERMINATED: 'danger', EXPIRED: 'warning' }; return m[s] || 'info' }

async function loadData() {
  loading.value = true
  try {
    const params: Record<string, unknown> = { pageNum: pageNum.value, pageSize: pageSize.value }
    if (searchForm.contractNumber) params.contractNumber = searchForm.contractNumber
    if (searchForm.contractName) params.contractName = searchForm.contractName
    if (searchForm.accountId) params.accountId = searchForm.accountId
    if (searchForm.contractType) params.contractType = searchForm.contractType
    if (searchForm.status) params.status = searchForm.status
    const res = await listContracts(params)
    tableData.value = res.rows || []
    total.value = res.total || 0
  } catch (e: any) {
    ElMessage.error(e?.message || '加载失败')
  } finally {
    loading.value = false
  }
}

async function loadAccounts() {
  try {
    const res = await listAccounts({ pageSize: 999 })
    accountOptions.value = res.rows || []
  } catch { /* ignore */ }
}

function handleSearch() { pageNum.value = 1; loadData() }
function resetSearch() { searchForm.contractNumber = ''; searchForm.contractName = ''; searchForm.accountId = undefined; searchForm.contractType = ''; searchForm.status = ''; handleSearch() }
function handleDetail(row: ContractVo) { router.push('/crm/contract/' + row.contractId) }
function handleRowClick(row: ContractVo) { router.push('/crm/contract/' + row.contractId) }
function handleCreate() { router.push('/crm/contract/create') }
function handleEdit(row: ContractVo) { router.push('/crm/contract/create?contractId=' + row.contractId) }

async function handleDelete(row: ContractVo) {
  try {
    await ElMessageBox.confirm('确定删除合同 "' + row.contractName + '" 吗？', '提示', { type: 'warning' })
    await delContract(row.contractId)
    ElMessage.success('删除成功')
    loadData()
  } catch (e: any) {
    if (e !== 'cancel') ElMessage.error(e?.message || '删除失败')
  }
}

async function handleFromOpp() {
  try {
    const res = await listOpportunities({ pageSize: 200, stage: 'PROPOSAL' })
    oppOptions.value = res.rows || []
    selectedOppId.value = null
    oppSelectVisible.value = true
  } catch (e: any) {
    ElMessage.error(e?.message || '加载商机列表失败')
  }
}

function confirmFromOpp() {
  if (!selectedOppId.value) { ElMessage.warning('请选择商机'); return }
  oppSelectVisible.value = false
  router.push('/crm/contract/create?opportunityId=' + selectedOppId.value)
}

onMounted(() => { loadData(); loadAccounts() })
</script>

<style scoped>
.cpq-page { padding: 16px; }
.search-bar { display: flex; gap: 12px; align-items: center; margin-bottom: 12px; flex-wrap: wrap; }
.toolbar { margin-bottom: 12px; display: flex; gap: 8px; }
</style>
