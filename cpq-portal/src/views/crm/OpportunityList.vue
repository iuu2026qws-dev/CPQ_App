<template>
  <div class="cpq-page">
    <div class="search-bar">
      <el-input v-model="searchForm.opportunityName" placeholder="商机名称" clearable style="width: 180px" @keyup.enter="handleSearch" />
      <el-input v-model="searchForm.opportunityCode" placeholder="编码" clearable style="width: 150px" @keyup.enter="handleSearch" />
      <el-select v-model="searchForm.accountId" placeholder="客户" clearable filterable style="width: 200px" @change="handleSearch">
        <el-option v-for="a in accountOptions" :key="a.accountId" :label="a.accountName" :value="a.accountId" />
      </el-select>
      <el-select v-model="searchForm.stage" placeholder="阶段" clearable style="width: 140px">
        <el-option label="寻找线索" value="PROSPECTING" />
        <el-option label="资质审核" value="QUALIFICATION" />
        <el-option label="方案建议" value="PROPOSAL" />
        <el-option label="谈判中" value="NEGOTIATION" />
        <el-option label="赢单" value="CLOSED_WON" />
        <el-option label="输单" value="CLOSED_LOST" />
      </el-select>
      <el-select v-model="searchForm.ownerId" placeholder="负责人" clearable filterable style="width: 160px">
        <el-option v-for="u in ownerOptions" :key="u.userId" :label="u.userName" :value="u.userId" />
      </el-select>
      <el-button type="primary" @click="handleSearch">搜索</el-button>
      <el-button @click="resetSearch">重置</el-button>
    </div>
    <div class="toolbar">
      <el-button type="primary" @click="handleCreate">+ 新增商机</el-button>
      <el-button @click="loadData">刷新</el-button>
    </div>
    <el-table v-loading="loading" :data="tableData" stripe @row-click="handleRowClick" style="cursor: pointer">
      <el-table-column prop="opportunityName" label="商机名称" min-width="160">
        <template #default="{ row }">
          <el-link type="primary" @click.stop="handleDetail(row)">{{ row.opportunityName }}</el-link>
        </template>
      </el-table-column>
      <el-table-column prop="opportunityCode" label="编码" width="140" />
      <el-table-column prop="accountName" label="客户" width="140" />
      <el-table-column prop="stage" label="阶段" width="110">
        <template #default="{ row }">
          <el-tag :type="stageTagType(row.stage)">{{ stageLabel(row.stage) }}</el-tag>
        </template>
      </el-table-column>
      <el-table-column prop="amount" label="金额" width="140">
        <template #default="{ row }">{{ row.amount ? '¥' + Number(row.amount).toLocaleString() : '-' }}</template>
      </el-table-column>
      <el-table-column prop="probability" label="概率" width="80">
        <template #default="{ row }">{{ row.probability ? row.probability + '%' : '-' }}</template>
      </el-table-column>
      <el-table-column prop="closeDate" label="截止日期" width="120" />
      <el-table-column prop="ownerName" label="负责人" width="100" />
      <el-table-column label="操作" width="240" fixed="right">
        <template #default="{ row }">
          <el-button size="small" @click.stop="handleDetail(row)">详情</el-button>
          <el-button size="small" type="primary" @click.stop="handleEdit(row)">编辑</el-button>
          <el-button size="small" type="success" @click.stop="handlePromote(row)">推进阶段</el-button>
          <el-button size="small" type="danger" @click.stop="handleDelete(row)">删除</el-button>
        </template>
      </el-table-column>
    </el-table>
    <el-pagination
      v-model:current-page="pageNum" v-model:page-size="pageSize" :total="total"
      layout="total, prev, pager, next" style="margin-top: 16px" @change="loadData"
    />

    <!-- 新增/编辑对话框 -->
    <el-dialog v-model="dialogVisible" :title="dialogTitle" width="650px" @close="resetForm">
      <el-form ref="formRef" :model="form" :rules="rules" label-width="100px">
        <el-form-item label="商机名称" prop="opportunityName">
          <el-input v-model="form.opportunityName" placeholder="请输入商机名称" maxlength="200" />
        </el-form-item>
        <el-form-item label="关联客户" prop="accountId">
          <el-select v-model="form.accountId" placeholder="请选择客户" filterable style="width: 100%">
            <el-option v-for="a in accountOptions" :key="a.accountId" :label="a.accountName" :value="a.accountId" />
          </el-select>
        </el-form-item>
        <el-form-item label="阶段" prop="stage">
          <el-select v-model="form.stage" placeholder="请选择阶段" style="width: 100%">
            <el-option label="寻找线索" value="PROSPECTING" />
            <el-option label="资质审核" value="QUALIFICATION" />
            <el-option label="方案建议" value="PROPOSAL" />
            <el-option label="谈判中" value="NEGOTIATION" />
            <el-option label="赢单" value="CLOSED_WON" />
            <el-option label="输单" value="CLOSED_LOST" />
          </el-select>
        </el-form-item>
        <el-form-item label="金额">
          <el-input-number v-model="form.amount" :min="0" :precision="2" style="width: 100%" />
        </el-form-item>
        <el-form-item label="类型">
          <el-select v-model="form.opportunityType" placeholder="请选择类型" style="width: 100%">
            <el-option label="新客" value="NEW" />
            <el-option label="增购" value="UPSELL" />
            <el-option label="续约" value="RENEWAL" />
            <el-option label="升级" value="UPGRADE" />
          </el-select>
        </el-form-item>
        <el-form-item label="来源">
          <el-select v-model="form.source" placeholder="请选择来源" style="width: 100%">
            <el-option label="市场活动" value="MARKETING" />
            <el-option label="转介绍" value="REFERRAL" />
            <el-option label="官网" value="WEBSITE" />
            <el-option label="电话" value="PHONE" />
            <el-option label="其他" value="OTHER" />
          </el-select>
        </el-form-item>
        <el-form-item label="关闭日期">
          <el-date-picker v-model="form.closeDate" type="date" placeholder="选择日期" style="width: 100%" value-format="YYYY-MM-DD" />
        </el-form-item>
        <el-form-item label="负责人">
          <el-input v-model="form.ownerName" placeholder="负责人姓名" />
        </el-form-item>
        <el-form-item label="联系人">
          <el-input v-model="form.contactName" placeholder="联系人" />
        </el-form-item>
        <el-form-item label="电话">
          <el-input v-model="form.contactPhone" placeholder="联系电话" />
        </el-form-item>
        <el-form-item label="描述">
          <el-input v-model="form.description" type="textarea" placeholder="商机描述" :rows="3" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" @click="handleSubmit">确定</el-button>
      </template>
    </el-dialog>

    <!-- 推进阶段对话框 -->
    <el-dialog v-model="promoteVisible" title="推进阶段" width="450px">
      <el-form label-width="80px">
        <el-form-item label="当前阶段">
          <el-tag :type="stageTagType(promoteCurrentStage)">{{ stageLabel(promoteCurrentStage) }}</el-tag>
        </el-form-item>
        <el-form-item label="下一阶段">
          <el-select v-model="promoteNextStage" placeholder="请选择下一阶段" style="width: 100%">
            <el-option v-for="s in availableNextStages" :key="s.value" :label="s.label" :value="s.value" />
          </el-select>
        </el-form-item>
        <el-form-item label="下一步计划">
          <el-input v-model="promoteNextStep" type="textarea" placeholder="下一步行动计划（可选）" :rows="2" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="promoteVisible = false">取消</el-button>
        <el-button type="primary" @click="confirmPromote">确认推进</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage, ElMessageBox, type FormInstance, type FormRules } from 'element-plus'
import { listOpportunities, addOpportunity, updateOpportunity, delOpportunity, promoteOpportunity, listAccounts, type OpportunityVo, type OpportunityBo, type AccountVo } from '@/api/cpq/crm'

const router = useRouter()
const loading = ref(false)
const tableData = ref<OpportunityVo[]>([])
const pageNum = ref(1)
const pageSize = ref(10)
const total = ref(0)
const dialogVisible = ref(false)
const dialogTitle = ref('新增商机')
const formRef = ref<FormInstance>()
const accountOptions = ref<AccountVo[]>([])
const ownerOptions = ref<{ userId: number; userName: string }[]>([])

const searchForm = reactive({ opportunityName: '', opportunityCode: '', accountId: undefined as number | undefined, stage: '', ownerId: undefined as number | undefined })
const form = reactive<OpportunityBo>({
  opportunityName: '',
  accountId: 0,
  stage: 'PROSPECTING',
  amount: undefined,
  opportunityType: 'NEW',
  source: 'WEBSITE',
  closeDate: undefined,
  ownerName: '',
  contactName: '',
  contactPhone: '',
  description: ''
})

const rules: FormRules = {
  opportunityName: [{ required: true, message: '请输入商机名称', trigger: 'blur' }, { min: 1, max: 200, message: '长度在 1 到 200 个字符', trigger: 'blur' }],
  accountId: [{ required: true, message: '请选择客户', trigger: 'change' }],
  stage: [{ required: true, message: '请选择阶段', trigger: 'change' }]
}

const stageColorMap: Record<string, string> = {
  PROSPECTING: '', QUALIFICATION: 'info', PROPOSAL: 'warning',
  NEGOTIATION: 'primary', CLOSED_WON: 'success', CLOSED_LOST: 'danger'
}
const stageLabelMap: Record<string, string> = {
  PROSPECTING: '寻找线索', QUALIFICATION: '资质审核', PROPOSAL: '方案建议',
  NEGOTIATION: '谈判中', CLOSED_WON: '赢单', CLOSED_LOST: '输单'
}
function stageTagType(s: string) { return stageColorMap[s] || 'info' }
function stageLabel(s: string) { return stageLabelMap[s] || s }

const promoteVisible = ref(false)
const promoteCurrentStage = ref('')
const promoteNextStage = ref('')
const promoteNextStep = ref('')
const promoteOppId = ref(0)

const stageSequence = ['PROSPECTING', 'QUALIFICATION', 'PROPOSAL', 'NEGOTIATION', 'CLOSED_WON', 'CLOSED_LOST']
const availableNextStages = computed(() => {
  const idx = stageSequence.indexOf(promoteCurrentStage.value)
  if (idx < 0) return []
  return stageSequence.slice(idx + 1).map(s => ({ value: s, label: stageLabel(s) }))
})

async function loadData() {
  loading.value = true
  try {
    const params: Record<string, unknown> = { pageNum: pageNum.value, pageSize: pageSize.value }
    if (searchForm.opportunityName) params.opportunityName = searchForm.opportunityName
    if (searchForm.opportunityCode) params.opportunityCode = searchForm.opportunityCode
    if (searchForm.accountId) params.accountId = searchForm.accountId
    if (searchForm.stage) params.stage = searchForm.stage
    if (searchForm.ownerId) params.ownerId = searchForm.ownerId
    const res = await listOpportunities(params)
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
function resetSearch() { searchForm.opportunityName = ''; searchForm.opportunityCode = ''; searchForm.accountId = undefined; searchForm.stage = ''; searchForm.ownerId = undefined; handleSearch() }
function handleDetail(row: OpportunityVo) { router.push('/crm/opportunity/' + row.opportunityId) }
function handleRowClick(row: OpportunityVo) { router.push('/crm/opportunity/' + row.opportunityId) }

function handleCreate() {
  dialogTitle.value = '新增商机'
  Object.assign(form, { opportunityId: undefined, opportunityName: '', accountId: 0, stage: 'PROSPECTING', amount: undefined, opportunityType: 'NEW', source: 'WEBSITE', closeDate: undefined, ownerName: '', contactName: '', contactPhone: '', description: '' })
  dialogVisible.value = true
}

function handleEdit(row: OpportunityVo) {
  dialogTitle.value = '编辑商机'
  Object.assign(form, {
    opportunityId: row.opportunityId,
    opportunityName: row.opportunityName,
    accountId: row.accountId,
    stage: row.stage,
    amount: row.amount,
    opportunityType: row.opportunityType || 'NEW',
    source: row.source || 'WEBSITE',
    closeDate: row.closeDate,
    ownerName: row.ownerName || '',
    contactName: row.contactName || '',
    contactPhone: row.contactPhone || '',
    description: row.description || ''
  })
  dialogVisible.value = true
}

async function handleDelete(row: OpportunityVo) {
  try {
    await ElMessageBox.confirm('确定删除商机 "' + row.opportunityName + '" 吗？', '提示', { type: 'warning' })
    await delOpportunity(row.opportunityId)
    ElMessage.success('删除成功')
    loadData()
  } catch (e: any) {
    if (e !== 'cancel') ElMessage.error(e?.message || '删除失败')
  }
}

function handlePromote(row: OpportunityVo) {
  promoteOppId.value = row.opportunityId
  promoteCurrentStage.value = row.stage
  promoteNextStage.value = ''
  promoteNextStep.value = ''
  promoteVisible.value = true
}

async function confirmPromote() {
  if (!promoteNextStage.value) { ElMessage.warning('请选择下一阶段'); return }
  try {
    await promoteOpportunity(promoteOppId.value, { nextStage: promoteNextStage.value, nextStep: promoteNextStep.value })
    ElMessage.success('阶段推进成功')
    promoteVisible.value = false
    loadData()
  } catch (e: any) {
    ElMessage.error(e?.message || '推进失败')
  }
}

async function handleSubmit() {
  if (!formRef.value) return
  await formRef.value.validate(async (valid) => {
    if (!valid) return
    try {
      if (form.opportunityId) {
        await updateOpportunity(form)
        ElMessage.success('修改成功')
      } else {
        await addOpportunity(form)
        ElMessage.success('新增成功')
      }
      dialogVisible.value = false
      loadData()
    } catch (e: any) {
      ElMessage.error(e?.message || '操作失败')
    }
  })
}

function resetForm() {
  Object.assign(form, { opportunityId: undefined, opportunityName: '', accountId: 0, stage: 'PROSPECTING' })
  formRef.value?.resetFields()
}

onMounted(() => { loadData(); loadAccounts() })
</script>

<style scoped>
.cpq-page { padding: 16px; }
.search-bar { display: flex; gap: 12px; align-items: center; margin-bottom: 12px; flex-wrap: wrap; }
.toolbar { margin-bottom: 12px; display: flex; gap: 8px; }
</style>
