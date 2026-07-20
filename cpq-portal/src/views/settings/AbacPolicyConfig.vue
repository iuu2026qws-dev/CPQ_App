<template>
  <div class="abac-policy-page">
    <el-card shadow="never">
      <template #header>
        <div class="card-header">
          <span class="title">ABAC 权限策略管理</span>
          <el-button type="primary" @click="handleAdd">
            <el-icon><Plus /></el-icon>新增策略
          </el-button>
        </div>
      </template>

      <!-- 筛选栏 -->
      <el-row :gutter="12" class="filter-bar">
        <el-col :span="6">
          <el-input v-model="queryParams.policyName" placeholder="策略名称" clearable @keyup.enter="fetchList" />
        </el-col>
        <el-col :span="5">
          <el-select v-model="queryParams.policyType" placeholder="策略类型" clearable>
            <el-option label="成本可见性" value="COST_VISIBILITY" />
            <el-option label="区域范围" value="REGION_SCOPE" />
            <el-option label="产品线范围" value="PRODUCT_LINE_SCOPE" />
          </el-select>
        </el-col>
        <el-col :span="4">
          <el-select v-model="queryParams.subjectType" placeholder="主体类型" clearable>
            <el-option label="角色" value="ROLE" />
            <el-option label="用户" value="USER" />
            <el-option label="部门" value="DEPT" />
          </el-select>
        </el-col>
        <el-col :span="4">
          <el-button type="primary" @click="fetchList">查询</el-button>
          <el-button @click="resetQuery">重置</el-button>
        </el-col>
      </el-row>

      <!-- 数据表格 -->
      <el-table v-loading="loading" :data="tableData" border stripe style="margin-top: 16px">
        <el-table-column prop="policyId" label="ID" width="70" align="center" />
        <el-table-column prop="policyName" label="策略名称" min-width="160" show-overflow-tooltip />
        <el-table-column label="策略类型" width="140" align="center">
          <template #default="{ row }">
            <el-tag :type="policyTypeTag(row.policyType)" size="small">
              {{ policyTypeLabel(row.policyType) }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="主体" width="180" align="center">
          <template #default="{ row }">
            <span>{{ subjectTypeLabel(row.subjectType) }}: {{ row.subjectValue }}</span>
          </template>
        </el-table-column>
        <el-table-column prop="attributeKey" label="属性键" width="170" show-overflow-tooltip />
        <el-table-column prop="attributeValue" label="属性值" width="160" show-overflow-tooltip />
        <el-table-column label="状态" width="80" align="center">
          <template #default="{ row }">
            <el-tag :type="row.status === '0' ? 'success' : 'info'" size="small">
              {{ row.status === '0' ? '启用' : '停用' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="160" align="center" fixed="right">
          <template #default="{ row }">
            <el-button link type="primary" size="small" @click="handleEdit(row)">编辑</el-button>
            <el-button link type="danger" size="small" @click="handleDelete(row)">删除</el-button>
          </template>
        </el-table-column>
      </el-table>
    </el-card>

    <!-- 新增/编辑弹窗 -->
    <el-dialog :title="dialogTitle" v-model="dialogVisible" width="600px" destroy-on-close>
      <el-form ref="formRef" :model="form" :rules="formRules" label-width="100px">
        <el-form-item label="策略名称" prop="policyName">
          <el-input v-model="form.policyName" placeholder="如: 销售代表成本可见性" maxlength="100" />
        </el-form-item>
        <el-form-item label="策略类型" prop="policyType">
          <el-select v-model="form.policyType" placeholder="请选择策略类型" style="width: 100%">
            <el-option label="成本可见性 (COST_VISIBILITY)" value="COST_VISIBILITY" />
            <el-option label="区域范围 (REGION_SCOPE)" value="REGION_SCOPE" />
            <el-option label="产品线范围 (PRODUCT_LINE_SCOPE)" value="PRODUCT_LINE_SCOPE" />
          </el-select>
        </el-form-item>
        <el-form-item label="主体类型" prop="subjectType">
          <el-select v-model="form.subjectType" placeholder="请选择主体类型" style="width: 100%">
            <el-option label="角色 (ROLE)" value="ROLE" />
            <el-option label="用户 (USER)" value="USER" />
            <el-option label="部门 (DEPT)" value="DEPT" />
          </el-select>
        </el-form-item>
        <el-form-item label="主体值" prop="subjectValue">
          <el-input v-model="form.subjectValue" placeholder="如: sales_rep / 1001 / D001" maxlength="100" />
          <div class="form-tip">角色填 role_key，用户填 user_id，部门填 dept_id</div>
        </el-form-item>
        <el-form-item label="属性键" prop="attributeKey">
          <el-select v-model="form.attributeKey" placeholder="请选择属性键" style="width: 100%" filterable allow-create>
            <el-option label="cost_visibility_level" value="cost_visibility_level" />
            <el-option label="region_list" value="region_list" />
            <el-option label="product_line_list" value="product_line_list" />
          </el-select>
        </el-form-item>
        <el-form-item label="属性值" prop="attributeValue">
          <el-input v-model="form.attributeValue" placeholder="如: 0/1/2/3 或 csv列表" maxlength="500" />
          <div class="form-tip">成本可见性: 0(仅协议价) 1(销售价+毛利%) 2(毛利+物料成本) 3(全成本)</div>
        </el-form-item>
        <el-form-item label="状态" prop="status">
          <el-radio-group v-model="form.status">
            <el-radio value="0">启用</el-radio>
            <el-radio value="1">停用</el-radio>
          </el-radio-group>
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" @click="submitForm" :loading="submitting">保存</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted, computed } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Plus } from '@element-plus/icons-vue'
import {
  getAbacPolicyList,
  addAbacPolicy,
  updateAbacPolicy,
  deleteAbacPolicy,
  type CpqAbacPolicy
} from '@/api/cpq/abac'

const loading = ref(false)
const submitting = ref(false)
const tableData = ref<CpqAbacPolicy[]>([])
const dialogVisible = ref(false)
const formRef = ref()
const isEdit = ref(false)

const queryParams = reactive({
  policyName: '',
  policyType: '',
  subjectType: ''
})

const form = reactive<CpqAbacPolicy>({
  policyName: '',
  policyType: '',
  subjectType: '',
  subjectValue: '',
  attributeKey: '',
  attributeValue: '',
  status: '0'
})

const formRules = {
  policyName: [{ required: true, message: '请输入策略名称', trigger: 'blur' }],
  policyType: [{ required: true, message: '请选择策略类型', trigger: 'change' }],
  subjectType: [{ required: true, message: '请选择主体类型', trigger: 'change' }],
  subjectValue: [{ required: true, message: '请输入主体值', trigger: 'blur' }],
  attributeKey: [{ required: true, message: '请选择属性键', trigger: 'change' }],
  attributeValue: [{ required: true, message: '请输入属性值', trigger: 'blur' }]
}

const dialogTitle = computed(() => isEdit.value ? '编辑ABAC策略' : '新增ABAC策略')

const policyTypeLabel = (type: string) =>
  ({ COST_VISIBILITY: '成本可见性', REGION_SCOPE: '区域范围', PRODUCT_LINE_SCOPE: '产品线范围' }[type] || type)

const policyTypeTag = (type: string) =>
  ({ COST_VISIBILITY: 'warning', REGION_SCOPE: 'primary', PRODUCT_LINE_SCOPE: 'success' }[type] || '')

const subjectTypeLabel = (type: string) =>
  ({ ROLE: '角色', USER: '用户', DEPT: '部门' }[type] || type)

async function fetchList() {
  loading.value = true
  try {
    const res = await getAbacPolicyList(queryParams)
    tableData.value = Array.isArray(res) ? res : (res.rows || (res as any)?.data || [])
  } finally {
    loading.value = false
  }
}

function resetQuery() {
  queryParams.policyName = ''
  queryParams.policyType = ''
  queryParams.subjectType = ''
  fetchList()
}

function handleAdd() {
  isEdit.value = false
  resetForm()
  dialogVisible.value = true
}

function handleEdit(row: CpqAbacPolicy) {
  isEdit.value = true
  Object.assign(form, row)
  dialogVisible.value = true
}

async function handleDelete(row: CpqAbacPolicy) {
  try {
    await ElMessageBox.confirm(`确定删除策略「${row.policyName}」吗？`, '删除确认', { type: 'warning' })
    await deleteAbacPolicy([row.policyId!])
    ElMessage.success('删除成功')
    fetchList()
  } catch {
    // 用户取消
  }
}

function resetForm() {
  form.policyName = ''
  form.policyType = ''
  form.subjectType = ''
  form.subjectValue = ''
  form.attributeKey = ''
  form.attributeValue = ''
  form.status = '0'
  formRef.value?.resetFields()
}

async function submitForm() {
  const valid = await formRef.value?.validate().catch(() => false)
  if (!valid) return
  submitting.value = true
  try {
    if (isEdit.value) {
      await updateAbacPolicy(form)
      ElMessage.success('修改成功')
    } else {
      await addAbacPolicy(form)
      ElMessage.success('新增成功')
    }
    dialogVisible.value = false
    fetchList()
  } finally {
    submitting.value = false
  }
}

onMounted(() => fetchList())
</script>

<style scoped>
.abac-policy-page { padding: 0; }

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.card-header .title {
  font-size: 16px;
  font-weight: 600;
}

.filter-bar {
  display: flex;
  align-items: center;
}

.form-tip {
  font-size: 12px;
  color: #909399;
  margin-top: 4px;
}
</style>
