<template>
  <div class="app-container">
    <!-- 功能介绍卡片 -->
    <el-alert type="info" :closable="false" show-icon class="mb-16">
      <template #title>
        <strong>配置规则</strong> 定义产品属性之间的约束关系（CSP 约束满足问题）。支持四种规则类型：VALIDATION（阻止错误组合）、SELECTION（自动推荐）、ALERT（提示销售）、VISIBILITY（隐藏无关项）。
        规则通过条件表达式触发，执行动作表达式，是配置准确性的核心保障。
      </template>
    </el-alert>

    <!-- 统计卡片 -->
    <el-row :gutter="16" class="mb-16">
      <el-col :span="6">
        <el-statistic title="总规则数" :value="total" />
      </el-col>
      <el-col :span="6">
        <el-statistic title="VALIDATION" :value="dataList.filter(r => r.ruleType === 'VALIDATION').length" />
      </el-col>
      <el-col :span="6">
        <el-statistic title="ERROR严重" :value="dataList.filter(r => r.severity === 'ERROR').length" />
      </el-col>
      <el-col :span="6">
        <el-statistic title="已选" :value="selectedIds.length" />
      </el-col>
    </el-row>

    <el-card>
      <template #header>
        <div class="card-header">
          <span>配置规则管理</span>
          <div class="header-actions">
            <el-button type="primary" @click="handleAdd" v-hasPermi="['cpq:config:rule:add']">
              <el-icon><Plus /></el-icon>新增
            </el-button>
            <el-button type="danger" :disabled="selectedIds.length === 0" @click="handleBatchDelete" v-hasPermi="['cpq:config:rule:remove']">
              <el-icon><Delete /></el-icon>批量删除
            </el-button>
          </div>
        </div>
      </template>

      <!-- 搜索区 -->
      <el-form :model="queryParams" ref="queryFormRef" :inline="true" label-width="90px">
        <el-form-item label="规则名称" prop="ruleName">
          <el-input v-model="queryParams.ruleName" placeholder="请输入规则名称" clearable @keyup.enter="handleQuery" />
        </el-form-item>
        <el-form-item label="规则类型" prop="ruleType">
          <el-select v-model="queryParams.ruleType" placeholder="请选择" clearable style="width:160px">
            <el-option label="REQUIRES" value="REQUIRES" />
            <el-option label="EXCLUDES" value="EXCLUDES" />
            <el-option label="RECOMMENDS" value="RECOMMENDS" />
            <el-option label="FILTER" value="FILTER" />
            <el-option label="PRICE" value="PRICE" />
          </el-select>
        </el-form-item>
        <el-form-item label="产品模型ID" prop="modelId">
          <el-input v-model="queryParams.modelId" placeholder="请输入产品模型ID" clearable @keyup.enter="handleQuery" />
        </el-form-item>
        <el-form-item label="状态" prop="status">
          <el-select v-model="queryParams.status" placeholder="请选择" clearable style="width:120px">
            <el-option label="启用" value="0" />
            <el-option label="停用" value="1" />
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="handleQuery">
            <el-icon><Search /></el-icon>查询
          </el-button>
          <el-button @click="resetQuery">
            <el-icon><Refresh /></el-icon>重置
          </el-button>
        </el-form-item>
      </el-form>
    </el-card>

    <el-card class="mt-16">
      <el-table v-loading="loading" :data="dataList" @selection-change="handleSelectionChange" stripe border>
        <el-table-column type="selection" width="55" align="center" />
        <el-table-column label="ID" prop="ruleId" width="80" align="center" />
        <el-table-column label="规则名称" prop="ruleName" min-width="150" show-overflow-tooltip />
        <el-table-column label="规则类型" prop="ruleType" width="120" align="center">
          <template #default="{ row }">
            <el-tag :type="ruleTypeColor(row.ruleType)">{{ row.ruleType }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column label="产品模型ID" prop="modelId" width="120" align="center" />
        <el-table-column label="严重级别" prop="severity" width="100" align="center">
          <template #default="{ row }">
            <el-tag :type="severityColor(row.severity)">{{ row.severity }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column label="优先级" prop="priority" width="80" align="center" />
        <el-table-column label="状态" prop="status" width="80" align="center">
          <template #default="{ row }">
            <el-tag :type="row.status === '0' ? 'success' : 'danger'">
              {{ row.status === '0' ? '启用' : '停用' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="创建时间" prop="createTime" width="160" align="center" />
        <el-table-column label="操作" width="200" align="center" fixed="right">
          <template #default="{ row }">
            <el-button link type="primary" @click="handleEdit(row)" v-hasPermi="['cpq:config:rule:edit']">
              <el-icon><Edit /></el-icon>编辑
            </el-button>
            <el-button link type="danger" @click="handleDelete(row)" v-hasPermi="['cpq:config:rule:remove']">
              <el-icon><Delete /></el-icon>删除
            </el-button>
          </template>
        </el-table-column>
      </el-table>

      <el-pagination
        v-model:current-page="queryParams.pageNum"
        v-model:page-size="queryParams.pageSize"
        :total="total"
        :page-sizes="[10, 20, 50, 100]"
        layout="total, sizes, prev, pager, next, jumper"
        @size-change="loadData"
        @current-change="loadData"
      />
    </el-card>

    <!-- 新增/编辑弹窗 -->
    <el-dialog
      v-model="dialogVisible"
      :title="dialogTitle"
      width="700px"
      :close-on-click-modal="false"
      @close="handleDialogClose"
    >
      <el-form ref="formRef" :model="form" :rules="rules" label-width="110px">
        <el-form-item label="规则名称" prop="ruleName">
          <el-input v-model="form.ruleName" placeholder="请输入规则名称" maxlength="128" />
        </el-form-item>
        <el-form-item label="规则类型" prop="ruleType">
          <el-select v-model="form.ruleType" placeholder="请选择规则类型" style="width:100%">
            <el-option label="REQUIRES - 依赖" value="REQUIRES" />
            <el-option label="EXCLUDES - 互斥" value="EXCLUDES" />
            <el-option label="RECOMMENDS - 推荐" value="RECOMMENDS" />
            <el-option label="FILTER - 过滤" value="FILTER" />
            <el-option label="PRICE - 价格影响" value="PRICE" />
          </el-select>
        </el-form-item>
        <el-form-item label="产品模型ID" prop="modelId">
          <el-input-number v-model="form.modelId" :min="1" placeholder="请输入产品模型ID" style="width:100%" />
        </el-form-item>
        <el-form-item label="严重级别" prop="severity">
          <el-select v-model="form.severity" style="width:100%">
            <el-option label="HARD - 硬约束(必须满足)" value="HARD" />
            <el-option label="SOFT - 软约束(建议满足)" value="SOFT" />
            <el-option label="WARNING - 警告(仅提示)" value="WARNING" />
          </el-select>
        </el-form-item>
        <el-form-item label="优先级" prop="priority">
          <el-input-number v-model="form.priority" :min="0" :max="999" style="width:100%" />
        </el-form-item>
        <el-form-item label="条件表达式" prop="conditionExpr">
          <el-input v-model="form.conditionExpr" type="textarea" :rows="3" placeholder="如: attr['CPU'] == 'i7'" />
        </el-form-item>
        <el-form-item label="动作表达式" prop="actionExpr">
          <el-input v-model="form.actionExpr" type="textarea" :rows="3" placeholder="如: require('MEM', '64GB')" />
        </el-form-item>
        <el-form-item label="错误提示" prop="errorMessage">
          <el-input v-model="form.errorMessage" placeholder="违反规则时的提示信息" maxlength="255" />
        </el-form-item>
        <el-form-item label="生效日期">
          <el-date-picker v-model="form.effectiveDate" type="date" placeholder="选择生效日期" value-format="YYYY-MM-DD" style="width:100%" />
        </el-form-item>
        <el-form-item label="失效日期">
          <el-date-picker v-model="form.expiryDate" type="date" placeholder="选择失效日期" value-format="YYYY-MM-DD" style="width:100%" />
        </el-form-item>
        <el-form-item label="状态" prop="status">
          <el-radio-group v-model="form.status">
            <el-radio value="0">启用</el-radio>
            <el-radio value="1">停用</el-radio>
          </el-radio-group>
        </el-form-item>
        <el-form-item label="备注">
          <el-input v-model="form.remark" type="textarea" placeholder="备注信息" maxlength="500" show-word-limit />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" @click="handleSubmit" :loading="submitLoading">确定</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Plus, Delete, Edit, Search, Refresh } from '@element-plus/icons-vue'
import {
  listConfigRule,
  getConfigRule,
  addConfigRule,
  updateConfigRule,
  delConfigRule,
  type CpqConfigRule,
  type CpqConfigRuleForm
} from '@/api/cpq/config-rule'

const loading = ref(false)
const submitLoading = ref(false)
const dataList = ref<CpqConfigRule[]>([])
const total = ref(0)
const selectedIds = ref<number[]>([])
const dialogVisible = ref(false)
const dialogTitle = ref('新增配置规则')
const formRef = ref()
const queryFormRef = ref()

const queryParams = reactive({
  pageNum: 1,
  pageSize: 10,
  ruleName: '',
  ruleType: '',
  modelId: '',
  status: ''
})

const form = reactive<CpqConfigRuleForm>({
  ruleName: '',
  ruleType: 'REQUIRES',
  modelId: 0,
  conditionExpr: '',
  actionExpr: '',
  errorMessage: '',
  severity: 'HARD',
  priority: 0,
  effectiveDate: '',
  expiryDate: '',
  status: '0',
  remark: ''
})

const rules = {
  ruleName: [{ required: true, message: '请输入规则名称', trigger: 'blur' }],
  ruleType: [{ required: true, message: '请选择规则类型', trigger: 'change' }],
  modelId: [{ required: true, message: '请输入产品模型ID', trigger: 'blur' }],
  conditionExpr: [{ required: true, message: '请输入条件表达式', trigger: 'blur' }],
  actionExpr: [{ required: true, message: '请输入动作表达式', trigger: 'blur' }],
  errorMessage: [{ required: true, message: '请输入错误提示', trigger: 'blur' }],
  severity: [{ required: true, message: '请选择严重级别', trigger: 'change' }]
}

onMounted(() => { loadData() })

function ruleTypeColor(type: string) {
  const map: Record<string, string> = { REQUIRES: '', EXCLUDES: 'danger', RECOMMENDS: 'success', FILTER: 'warning', PRICE: 'info' }
  return map[type] || ''
}

function severityColor(s: string) {
  const map: Record<string, string> = { HARD: 'danger', SOFT: 'warning', WARNING: 'info' }
  return map[s] || ''
}

async function loadData() {
  loading.value = true
  try {
    const params: Record<string, any> = { ...queryParams }
    if (params.modelId) params.modelId = Number(params.modelId)
    const res = await listConfigRule(params)
    if (Array.isArray(res)) {
      dataList.value = res
      total.value = res.length
    } else {
      dataList.value = (res as any).rows || (res as any).data || []
      total.value = (res as any).total || dataList.value.length
    }
  } finally {
    loading.value = false
  }
}

function handleQuery() {
  queryParams.pageNum = 1
  loadData()
}

function resetQuery() {
  queryFormRef.value?.resetFields()
  handleQuery()
}

function handleSelectionChange(selection: CpqConfigRule[]) {
  selectedIds.value = selection.map(item => item.ruleId)
}

function handleAdd() {
  resetForm()
  dialogTitle.value = '新增配置规则'
  dialogVisible.value = true
}

async function handleEdit(row: CpqConfigRule) {
  resetForm()
  try {
    const data = await getConfigRule(row.ruleId)
    const detail = (data as any).data || data
    Object.assign(form, {
      ruleId: detail.ruleId,
      ruleName: detail.ruleName,
      ruleType: detail.ruleType,
      modelId: detail.modelId,
      conditionExpr: detail.conditionExpr,
      actionExpr: detail.actionExpr,
      errorMessage: detail.errorMessage,
      severity: detail.severity,
      priority: detail.priority,
      effectiveDate: detail.effectiveDate,
      expiryDate: detail.expiryDate,
      status: detail.status,
      remark: detail.remark
    })
    dialogTitle.value = '编辑配置规则'
    dialogVisible.value = true
  } catch { /* 异常已在拦截器处理 */ }
}

async function handleSubmit() {
  try {
    await formRef.value?.validate()
  } catch { return }
  submitLoading.value = true
  try {
    if (form.ruleId) {
      await updateConfigRule(form)
      ElMessage.success('修改成功')
    } else {
      await addConfigRule(form)
      ElMessage.success('新增成功')
    }
    dialogVisible.value = false
    loadData()
  } finally {
    submitLoading.value = false
  }
}

function handleDelete(row: CpqConfigRule) {
  ElMessageBox.confirm(`确认删除配置规则「${row.ruleName}」？`, '警告', {
    confirmButtonText: '确定', cancelButtonText: '取消', type: 'warning'
  }).then(async () => {
    await delConfigRule(row.ruleId)
    ElMessage.success('删除成功')
    loadData()
  }).catch(() => {})
}

function handleBatchDelete() {
  if (selectedIds.value.length === 0) {
    ElMessage.warning('请选择要删除的数据')
    return
  }
  ElMessageBox.confirm(`确认删除选中的 ${selectedIds.value.length} 条数据？`, '警告', {
    confirmButtonText: '确定', cancelButtonText: '取消', type: 'warning'
  }).then(async () => {
    for (const id of selectedIds.value) { await delConfigRule(id) }
    ElMessage.success('批量删除成功')
    loadData()
  }).catch(() => {})
}

function handleDialogClose() { formRef.value?.resetFields() }

function resetForm() {
  form.ruleId = undefined
  form.ruleName = ''
  form.ruleType = 'REQUIRES'
  form.modelId = 0
  form.conditionExpr = ''
  form.actionExpr = ''
  form.errorMessage = ''
  form.severity = 'HARD'
  form.priority = 0
  form.effectiveDate = ''
  form.expiryDate = ''
  form.status = '0'
  form.remark = ''
}
</script>

<style scoped>
.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}
.card-header span {
  font-size: 16px;
  font-weight: 600;
}
.header-actions {
  display: flex;
  gap: 8px;
}
.mt-16 {
  margin-top: 16px;
}
</style>
