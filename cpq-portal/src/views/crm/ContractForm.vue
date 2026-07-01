<template>
  <div class="cpq-page">
    <div class="back-bar">
      <el-button @click="$router.back()" text>← 返回</el-button>
      <h3 style="margin: 0">{{ isEdit ? '编辑合同' : '新增合同' }}</h3>
    </div>

    <el-steps :active="activeStep" finish-status="success" align-center style="margin: 20px 0">
      <el-step title="选择来源" />
      <el-step title="填写信息" />
    </el-steps>

    <!-- Step 1: 选择商机或客户 -->
    <div v-if="activeStep === 0" style="max-width: 600px; margin: 0 auto">
      <el-card>
        <el-form label-width="100px">
          <el-form-item label="合同类型">
            <el-select v-model="contractType" style="width: 100%">
              <el-option label="项目合同" value="PROJECT" />
              <el-option label="框架合同" value="FRAMEWORK" />
              <el-option label="补充协议" value="SUPPLEMENT" />
            </el-select>
          </el-form-item>
          <el-form-item v-if="contractType !== 'FRAMEWORK'" label="关联商机">
            <el-select v-model="selectedOppId" placeholder="搜索并选择商机" filterable style="width: 100%" @change="onOppSelect">
              <el-option v-for="o in oppOptions" :key="o.opportunityId" :label="o.opportunityName + ' - ' + o.accountName" :value="o.opportunityId" />
            </el-select>
          </el-form-item>
          <el-form-item v-if="contractType === 'FRAMEWORK' || !selectedOppId" label="选择客户">
            <el-select v-model="selectedAccountId" placeholder="搜索并选择客户" filterable style="width: 100%">
              <el-option v-for="a in accountOptions" :key="a.accountId" :label="a.accountName" :value="a.accountId" />
            </el-select>
          </el-form-item>
          <el-form-item>
            <el-button type="primary" @click="goToStep2" :disabled="!canProceed">下一步</el-button>
          </el-form-item>
        </el-form>
      </el-card>
    </div>

    <!-- Step 2: 填写合同详情 -->
    <div v-if="activeStep === 1">
      <el-card>
        <el-form ref="formRef" :model="form" :rules="rules" label-width="100px">
          <el-form-item label="合同名称" prop="contractName">
            <el-input v-model="form.contractName" placeholder="请输入合同名称" maxlength="200" />
          </el-form-item>
          <el-form-item label="合同编号">
            <el-input v-model="form.contractNumber" placeholder="自动生成" disabled />
          </el-form-item>
          <el-form-item label="合同类型">
            <el-tag :type="contractType === 'PROJECT' ? 'primary' : contractType === 'FRAMEWORK' ? 'success' : 'warning'">
              {{ contractType === 'PROJECT' ? '项目合同' : contractType === 'FRAMEWORK' ? '框架合同' : '补充协议' }}
            </el-tag>
          </el-form-item>
          <el-form-item label="客户">
            <el-input :model-value="selectedAccountName" disabled />
          </el-form-item>
          <el-form-item label="开始日期">
            <el-date-picker v-model="form.startDate" type="date" placeholder="选择日期" style="width: 100%" value-format="YYYY-MM-DD" />
          </el-form-item>
          <el-form-item label="结束日期">
            <el-date-picker v-model="form.endDate" type="date" placeholder="选择日期" style="width: 100%" value-format="YYYY-MM-DD" />
          </el-form-item>
          <el-form-item label="签约主体">
            <el-input v-model="form.signingEntity" placeholder="签约主体" />
          </el-form-item>
          <el-form-item label="付款条款">
            <el-input v-model="form.paymentTerms" type="textarea" placeholder="付款条款" :rows="2" />
          </el-form-item>
          <el-form-item label="负责人">
            <el-input v-model="form.ownerName" placeholder="负责人" />
          </el-form-item>
        </el-form>
      </el-card>

      <el-card style="margin-top: 16px">
        <template #header><span>产品明细</span></template>
        <el-table :data="productLines" border size="small">
          <el-table-column label="产品编码" width="150">
            <template #default="{ row, $index }">
              <el-input v-model="row.productCode" size="small" placeholder="产品编码" />
            </template>
          </el-table-column>
          <el-table-column label="产品名称" min-width="160">
            <template #default="{ row, $index }">
              <el-input v-model="row.productName" size="small" placeholder="产品名称" />
            </template>
          </el-table-column>
          <el-table-column label="数量" width="120">
            <template #default="{ row, $index }">
              <el-input-number v-model="row.quantity" :min="1" size="small" controls-position="right" />
            </template>
          </el-table-column>
          <el-table-column label="单价" width="140">
            <template #default="{ row, $index }">
              <el-input-number v-model="row.unitPrice" :min="0" :precision="2" size="small" controls-position="right" />
            </template>
          </el-table-column>
          <el-table-column label="操作" width="80">
            <template #default="{ $index }">
              <el-button size="small" type="danger" @click="removeLine($index)" :disabled="productLines.length <= 1">删除</el-button>
            </template>
          </el-table-column>
        </el-table>
        <el-button type="primary" size="small" style="margin-top: 8px" @click="addLine">+ 添加产品</el-button>
      </el-card>

      <div style="margin-top: 20px; text-align: center">
        <el-button @click="activeStep = 0">上一步</el-button>
        <el-button type="primary" @click="submitContract">提交合同</el-button>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, computed, onMounted, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessage, type FormInstance, type FormRules } from 'element-plus'
import { addContract, updateContract, getContract, listAccounts, listOpportunities, generateContractNumber, type AccountVo, type OpportunityVo, type ContractBo, type ContractLineBo } from '@/api/cpq/crm'

const route = useRoute()
const router = useRouter()
const activeStep = ref(0)
const isEdit = computed(() => !!route.query.contractId)
const formRef = ref<FormInstance>()

const contractType = ref('PROJECT')
const selectedOppId = ref<number | null>(null)
const selectedAccountId = ref<number | null>(null)
const selectedAccountName = ref('')
const oppOptions = ref<OpportunityVo[]>([])
const accountOptions = ref<AccountVo[]>([])

const canProceed = computed(() => {
  if (!isEdit.value) {
    if (contractType.value === 'FRAMEWORK') return !!selectedAccountId.value
    return !!selectedOppId.value || !!selectedAccountId.value
  }
  return true
})

const form = reactive({
  contractName: '',
  contractNumber: '',
  startDate: undefined as string | undefined,
  endDate: undefined as string | undefined,
  signingEntity: '',
  paymentTerms: '',
  ownerName: ''
})

const rules: FormRules = {
  contractName: [{ required: true, message: '请输入合同名称', trigger: 'blur' }]
}

interface ProductLine { productCode: string; productName: string; quantity: number; unitPrice: number }
const productLines = ref<ProductLine[]>([{ productCode: '', productName: '', quantity: 1, unitPrice: 0 }])

function addLine() { productLines.value.push({ productCode: '', productName: '', quantity: 1, unitPrice: 0 }) }
function removeLine(idx: number) { productLines.value.splice(idx, 1) }

function onOppSelect(val: number | null) {
  if (val) {
    contractType.value = 'PROJECT'
    const opp = oppOptions.value.find(o => o.opportunityId === val)
    if (opp) {
      selectedAccountId.value = opp.accountId
      selectedAccountName.value = opp.accountName
    }
  }
}

async function loadOpps() {
  try {
    const res = await listOpportunities({ pageSize: 200 })
    oppOptions.value = res.rows || []
    // Pre-select from query params
    if (route.query.opportunityId) {
      selectedOppId.value = Number(route.query.opportunityId)
      onOppSelect(selectedOppId.value)
      activeStep.value = 1
      try { const num = await generateContractNumber(); form.contractNumber = typeof num === 'string' ? num : (num as any)?.data || '' } catch { /* ignore */ }
    }
  } catch { /* ignore */ }
}

async function loadAccounts() {
  try {
    const res = await listAccounts({ pageSize: 999 })
    accountOptions.value = res.rows || []
  } catch { /* ignore */ }
}

function goToStep2() {
  if (!canProceed.value) return
  if (!selectedAccountId.value) { ElMessage.warning('请选择客户'); return }
  const acct = accountOptions.value.find(a => a.accountId === selectedAccountId.value)
  selectedAccountName.value = acct?.accountName || ''
  if (contractType.value === 'PROJECT' && selectedOppId.value) {
    // Already locked to PROJECT by onOppSelect
  }
  activeStep.value = 1
  if (!isEdit.value && !form.contractNumber) {
    generateContractNumber().then(num => {
      form.contractNumber = typeof num === 'string' ? num : (num as any)?.data || ''
    }).catch(() => {})
  }
}

async function loadEditData() {
  const id = Number(route.query.contractId)
  if (!id) return
  try {
    const contract = await getContract(id)
    form.contractName = contract.contractName
    form.contractNumber = contract.contractNumber
    contractType.value = contract.contractType
    selectedAccountId.value = contract.accountId
    selectedAccountName.value = contract.accountName
    selectedOppId.value = contract.opportunityId || null
    form.startDate = contract.startDate
    form.endDate = contract.endDate
    form.signingEntity = contract.signingEntity || ''
    form.paymentTerms = contract.paymentTerms || ''
    form.ownerName = contract.ownerName || ''
    activeStep.value = 1
  } catch (e: any) {
    ElMessage.error(e?.message || '加载合同失败')
    router.back()
  }
}

async function submitContract() {
  if (!formRef.value) return
  await formRef.value.validate(async (valid) => {
    if (!valid) return
    const lines: ContractLineBo[] = productLines.value.map(l => ({
      productCode: l.productCode, productName: l.productName, quantity: l.quantity, unitPrice: l.unitPrice
    }))
    const data: ContractBo = {
      contractName: form.contractName,
      accountId: selectedAccountId.value!,
      opportunityId: selectedOppId.value || undefined,
      contractType: contractType.value,
      startDate: form.startDate,
      endDate: form.endDate,
      signingEntity: form.signingEntity,
      paymentTerms: form.paymentTerms,
      ownerName: form.ownerName,
      lines
    }
    try {
      if (isEdit.value) {
        await updateContract({ ...data, contractId: Number(route.query.contractId) })
        ElMessage.success('修改成功')
      } else {
        await addContract(data)
        ElMessage.success('创建成功')
      }
      router.push('/crm/contract')
    } catch (e: any) {
      ElMessage.error(e?.message || '提交失败')
    }
  })
}

onMounted(() => {
  loadOpps()
  loadAccounts()
  if (isEdit.value) loadEditData()
})
</script>

<style scoped>
.cpq-page { padding: 16px; }
.back-bar { display: flex; align-items: center; gap: 12px; margin-bottom: 8px; }
</style>
