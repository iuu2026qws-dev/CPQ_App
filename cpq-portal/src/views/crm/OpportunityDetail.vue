<template>
  <div class="cpq-page">
    <div class="back-bar">
      <el-button @click="$router.back()" text>← 返回</el-button>
      <h3 style="margin: 0; flex: 1">商机详情：{{ opp?.opportunityName }}</h3>
      <el-button type="primary" @click="handleEdit">编辑</el-button>
      <el-button type="success" @click="handlePromote">推进阶段</el-button>
    </div>

    <div v-loading="loading">
      <el-card v-if="opp" style="margin-top: 16px">
        <el-descriptions :column="3" border title="商机信息">
          <el-descriptions-item label="商机名称">{{ opp.opportunityName }}</el-descriptions-item>
          <el-descriptions-item label="编码">{{ opp.opportunityCode }}</el-descriptions-item>
          <el-descriptions-item label="客户">{{ opp.accountName }}</el-descriptions-item>
          <el-descriptions-item label="阶段">
            <el-tag :type="stageTagType(opp.stage)">{{ stageLabel(opp.stage) }}</el-tag>
          </el-descriptions-item>
          <el-descriptions-item label="金额">{{ opp.amount ? '¥' + Number(opp.amount).toLocaleString() : '-' }}</el-descriptions-item>
          <el-descriptions-item label="概率">{{ opp.probability ? opp.probability + '%' : '-' }}</el-descriptions-item>
          <el-descriptions-item label="截止日期">{{ opp.closeDate || '-' }}</el-descriptions-item>
          <el-descriptions-item label="类型">{{ opp.opportunityType || '-' }}</el-descriptions-item>
          <el-descriptions-item label="来源">{{ opp.source || '-' }}</el-descriptions-item>
          <el-descriptions-item label="负责人">{{ opp.ownerName || '-' }}</el-descriptions-item>
          <el-descriptions-item label="联系人">{{ opp.contactName || '-' }}</el-descriptions-item>
          <el-descriptions-item label="电话">{{ opp.contactPhone || '-' }}</el-descriptions-item>
          <el-descriptions-item label="描述" :span="3">{{ opp.description || '-' }}</el-descriptions-item>
          <el-descriptions-item label="下一步" :span="3">{{ opp.nextStep || '-' }}</el-descriptions-item>
        </el-descriptions>
      </el-card>

      <el-card style="margin-top: 16px">
        <template #header>
          <div style="display: flex; justify-content: space-between; align-items: center">
            <span>销售活动时间线</span>
            <el-button type="primary" size="small" @click="activityVisible = true">+ 新增活动</el-button>
          </div>
        </template>
        <ActivityTimeline
          :activities="activities"
          :visible="activityVisible"
          :entity-id="oppId"
          entity-type="opportunity"
          @update:visible="(v: boolean) => activityVisible = v"
          @created="loadActivities"
        />
      </el-card>

      <el-card style="margin-top: 16px">
        <template #header>
          <div style="display: flex; justify-content: space-between; align-items: center">
            <span>关联报价单</span>
            <el-button type="primary" size="small" @click="createQuote">创建报价单</el-button>
          </div>
        </template>
        <el-table :data="quotes" size="small" :show-overflow-tooltip="true">
          <el-table-column prop="quoteNumber" label="报价单号" width="150" />
          <el-table-column prop="grandTotal" label="金额" width="140">
            <template #default="{ row }">{{ row.grandTotal ? '¥' + Number(row.grandTotal).toLocaleString() : '-' }}</template>
          </el-table-column>
          <el-table-column prop="status" label="状态" width="100" />
          <el-table-column prop="createTime" label="创建时间" width="160" />
        </el-table>
      </el-card>

      <el-card style="margin-top: 16px">
        <template #header><span>关联合同/订单</span></template>
        <el-table :data="contracts" size="small" :show-overflow-tooltip="true">
          <el-table-column prop="contractNumber" label="合同编号" width="150" />
          <el-table-column prop="contractName" label="合同名称" min-width="160" />
          <el-table-column prop="status" label="状态" width="100">
            <template #default="{ row }">
              <el-tag :type="contractStatusType(row.status)">{{ row.status }}</el-tag>
            </template>
          </el-table-column>
          <el-table-column prop="amount" label="金额" width="140">
            <template #default="{ row }">{{ row.amount ? '¥' + Number(row.amount).toLocaleString() : '-' }}</template>
          </el-table-column>
        </el-table>
      </el-card>
    </div>

    <el-empty v-if="!loading && !opp" description="商机不存在" />

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

    <!-- 编辑对话框 -->
    <el-dialog v-model="editVisible" title="编辑商机" width="650px">
      <el-form ref="editFormRef" :model="editForm" :rules="editRules" label-width="100px">
        <el-form-item label="商机名称" prop="opportunityName">
          <el-input v-model="editForm.opportunityName" placeholder="请输入商机名称" maxlength="200" />
        </el-form-item>
        <el-form-item label="阶段" prop="stage">
          <el-select v-model="editForm.stage" style="width: 100%">
            <el-option v-for="s in stageOptions" :key="s.value" :label="s.label" :value="s.value" />
          </el-select>
        </el-form-item>
        <el-form-item label="金额">
          <el-input-number v-model="editForm.amount" :min="0" :precision="2" style="width: 100%" />
        </el-form-item>
        <el-form-item label="概率">
          <el-input-number v-model="editForm.probability" :min="0" :max="100" style="width: 100%" />
        </el-form-item>
        <el-form-item label="截止日期">
          <el-date-picker v-model="editForm.closeDate" type="date" style="width: 100%" value-format="YYYY-MM-DD" />
        </el-form-item>
        <el-form-item label="负责人">
          <el-input v-model="editForm.ownerName" />
        </el-form-item>
        <el-form-item label="描述">
          <el-input v-model="editForm.description" type="textarea" :rows="3" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="editVisible = false">取消</el-button>
        <el-button type="primary" @click="saveEdit">保存</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, computed, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessage, type FormInstance, type FormRules } from 'element-plus'
import { getOpportunity, updateOpportunity, promoteOpportunity, listActivities, listContracts, type OpportunityVo, type ActivityVo, type ContractVo } from '@/api/cpq/crm'
import ActivityTimeline from './components/ActivityTimeline.vue'

const route = useRoute()
const router = useRouter()
const loading = ref(false)
const opp = ref<OpportunityVo | null>(null)
const oppId = computed(() => Number(route.params.id))
const activities = ref<ActivityVo[]>([])
const contracts = ref<ContractVo[]>([])
const quotes = ref<any[]>([])
const activityVisible = ref(false)

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

function contractStatusType(s: string) {
  const m: Record<string, string> = { DRAFT: 'info', ACTIVE: 'success', TERMINATED: 'danger', EXPIRED: 'warning' }
  return m[s] || 'info'
}

const stageOptions = [
  { value: 'PROSPECTING', label: '寻找线索' },
  { value: 'QUALIFICATION', label: '资质审核' },
  { value: 'PROPOSAL', label: '方案建议' },
  { value: 'NEGOTIATION', label: '谈判中' },
  { value: 'CLOSED_WON', label: '赢单' },
  { value: 'CLOSED_LOST', label: '输单' }
]

const promoteVisible = ref(false)
const promoteCurrentStage = ref('')
const promoteNextStage = ref('')
const promoteNextStep = ref('')

const stageSequence = ['PROSPECTING', 'QUALIFICATION', 'PROPOSAL', 'NEGOTIATION', 'CLOSED_WON', 'CLOSED_LOST']
const availableNextStages = computed(() => {
  const idx = stageSequence.indexOf(promoteCurrentStage.value)
  if (idx < 0) return []
  return stageSequence.slice(idx + 1).map(s => ({ value: s, label: stageLabel(s) }))
})

const editVisible = ref(false)
const editFormRef = ref<FormInstance>()
const editForm = reactive({ opportunityName: '', stage: '', amount: undefined as number | undefined, probability: undefined as number | undefined, closeDate: undefined as string | undefined, ownerName: '', description: '' })
const editRules: FormRules = {
  opportunityName: [{ required: true, message: '请输入商机名称', trigger: 'blur' }],
  stage: [{ required: true, message: '请选择阶段', trigger: 'change' }]
}

function handleEdit() {
  if (!opp.value) return
  Object.assign(editForm, {
    opportunityName: opp.value.opportunityName,
    stage: opp.value.stage,
    amount: opp.value.amount,
    probability: opp.value.probability,
    closeDate: opp.value.closeDate,
    ownerName: opp.value.ownerName || '',
    description: opp.value.description || ''
  })
  editVisible.value = true
}

async function saveEdit() {
  if (!editFormRef.value || !opp.value) return
  await editFormRef.value.validate(async (valid) => {
    if (!valid) return
    try {
      await updateOpportunity({ opportunityId: opp.value!.opportunityId, ...editForm, accountId: opp.value!.accountId })
      ElMessage.success('保存成功')
      editVisible.value = false
      loadData()
    } catch (e: any) {
      ElMessage.error(e?.message || '保存失败')
    }
  })
}

function handlePromote() {
  if (!opp.value) return
  promoteCurrentStage.value = opp.value.stage
  promoteNextStage.value = ''
  promoteNextStep.value = ''
  promoteVisible.value = true
}

async function confirmPromote() {
  if (!promoteNextStage.value) { ElMessage.warning('请选择下一阶段'); return }
  try {
    await promoteOpportunity(oppId.value, { nextStage: promoteNextStage.value, nextStep: promoteNextStep.value })
    ElMessage.success('阶段推进成功')
    promoteVisible.value = false
    loadData()
  } catch (e: any) {
    ElMessage.error(e?.message || '推进失败')
  }
}

function createQuote() {
  router.push({ path: '/quoting', query: { opportunityId: oppId.value } })
}

async function loadData() {
  loading.value = true
  try {
    opp.value = await getOpportunity(oppId.value)
  } catch (e: any) {
    ElMessage.error(e?.message || '加载失败')
  } finally {
    loading.value = false
  }
}

async function loadActivities() {
  try {
    const res = await listActivities({ opportunityId: oppId.value, pageSize: 50 })
    activities.value = Array.isArray(res) ? res : (res.rows || [])
  } catch { /* ignore */ }
}

async function loadRelated() {
  try {
    const [conRes] = await Promise.all([
      listContracts({ opportunityId: oppId.value })
    ])
    contracts.value = conRes.rows || []
  } catch { /* ignore */ }
}

onMounted(() => { loadData(); loadActivities(); loadRelated() })
</script>

<style scoped>
.cpq-page { padding: 16px; }
.back-bar { display: flex; align-items: center; gap: 12px; margin-bottom: 8px; }
</style>
