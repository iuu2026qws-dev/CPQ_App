<template>
  <div class="app-container">
    <!-- 功能介绍卡片 -->
    <el-alert type="info" :closable="false" show-icon class="mb-16">
      <template #title>
        <strong>属性选项</strong> 定义每个产品模型有哪些可配置属性及其可选值。例如：弧焊机器人「颜色」属性的可选值为「珍珠白、工业黄、石墨灰、曜石黑」。
        每个选项包含编码、标签、值、默认标记，是 CSP 配置器的数据基础。
      </template>
    </el-alert>

    <!-- 统计卡片 -->
    <el-row :gutter="16" class="mb-16">
      <el-col :span="6">
        <el-statistic title="总选项数" :value="total" />
      </el-col>
      <el-col :span="6">
        <el-statistic title="当前页" :value="dataList.length" />
      </el-col>
      <el-col :span="6">
        <el-statistic title="默认选项" :value="dataList.filter(r => r.isDefault === '1').length" />
      </el-col>
      <el-col :span="6">
        <el-statistic title="已选" :value="selectedIds.length" />
      </el-col>
    </el-row>

    <el-card>
      <template #header>
        <div class="card-header">
          <span>属性选项管理</span>
          <div class="header-actions">
            <el-button type="primary" @click="handleAdd" v-hasPermi="['cpq:config:attributeoption:add']">
              <el-icon><Plus /></el-icon>新增
            </el-button>
            <el-button type="danger" :disabled="selectedIds.length === 0" @click="handleBatchDelete" v-hasPermi="['cpq:config:attributeoption:remove']">
              <el-icon><Delete /></el-icon>批量删除
            </el-button>
          </div>
        </div>
      </template>

      <!-- 搜索区 -->
      <el-form :model="queryParams" ref="queryFormRef" :inline="true" label-width="90px">
        <el-form-item label="产品模型ID" prop="modelId">
          <el-input v-model="queryParams.modelId" placeholder="请输入产品模型ID" clearable @keyup.enter="handleQuery" />
        </el-form-item>
        <el-form-item label="属性名称" prop="attrName">
          <el-input v-model="queryParams.attrName" placeholder="请输入属性名称" clearable @keyup.enter="handleQuery" />
        </el-form-item>
        <el-form-item label="选项编码" prop="optionCode">
          <el-input v-model="queryParams.optionCode" placeholder="请输入选项编码" clearable @keyup.enter="handleQuery" />
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
      <!-- 数据表格 -->
      <el-table v-loading="loading" :data="dataList" @selection-change="handleSelectionChange" stripe border>
        <el-table-column type="selection" width="55" align="center" />
        <el-table-column label="ID" prop="optionId" width="80" align="center" />
        <el-table-column label="产品模型ID" prop="modelId" width="120" align="center" />
        <el-table-column label="属性名称" prop="attrName" min-width="120" show-overflow-tooltip />
        <el-table-column label="选项编码" prop="optionCode" min-width="120" show-overflow-tooltip />
        <el-table-column label="选项标签" prop="optionLabel" min-width="120" show-overflow-tooltip />
        <el-table-column label="选项值" prop="optionValue" min-width="120" show-overflow-tooltip />
        <el-table-column label="是否默认" prop="isDefault" width="100" align="center">
          <template #default="{ row }">
            <el-tag :type="row.isDefault === '1' ? 'success' : 'info'">
              {{ row.isDefault === '1' ? '是' : '否' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="排序" prop="sortOrder" width="80" align="center" />
        <el-table-column label="创建时间" prop="createTime" width="160" align="center" />
        <el-table-column label="操作" width="200" align="center" fixed="right">
          <template #default="{ row }">
            <el-button link type="primary" @click="handleEdit(row)" v-hasPermi="['cpq:config:attributeoption:edit']">
              <el-icon><Edit /></el-icon>编辑
            </el-button>
            <el-button link type="danger" @click="handleDelete(row)" v-hasPermi="['cpq:config:attributeoption:remove']">
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
      width="600px"
      :close-on-click-modal="false"
      @close="handleDialogClose"
    >
      <el-form ref="formRef" :model="form" :rules="rules" label-width="100px">
        <el-form-item label="产品模型ID" prop="modelId">
          <el-input-number v-model="form.modelId" :min="1" placeholder="请输入产品模型ID" style="width:100%" />
        </el-form-item>
        <el-form-item label="属性名称" prop="attrName">
          <el-input v-model="form.attrName" placeholder="如: CPU, 内存, 硬盘" maxlength="64" />
        </el-form-item>
        <el-form-item label="选项编码" prop="optionCode">
          <el-input v-model="form.optionCode" placeholder="如: cpu_i7, mem_64g" maxlength="64" />
        </el-form-item>
        <el-form-item label="选项标签" prop="optionLabel">
          <el-input v-model="form.optionLabel" placeholder="如: Intel i7, 64GB" maxlength="128" />
        </el-form-item>
        <el-form-item label="选项值" prop="optionValue">
          <el-input v-model="form.optionValue" placeholder="选项对应的实际值" maxlength="128" />
        </el-form-item>
        <el-form-item label="是否默认" prop="isDefault">
          <el-radio-group v-model="form.isDefault">
            <el-radio value="0">否</el-radio>
            <el-radio value="1">是</el-radio>
          </el-radio-group>
        </el-form-item>
        <el-form-item label="排序" prop="sortOrder">
          <el-input-number v-model="form.sortOrder" :min="0" style="width:100%" />
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
  listAttributeOption,
  getAttributeOption,
  addAttributeOption,
  updateAttributeOption,
  delAttributeOption,
  type CpqAttributeOption,
  type CpqAttributeOptionForm
} from '@/api/cpq/attribute-option'

const loading = ref(false)
const submitLoading = ref(false)
const dataList = ref<CpqAttributeOption[]>([])
const total = ref(0)
const selectedIds = ref<number[]>([])
const dialogVisible = ref(false)
const dialogTitle = ref('新增属性选项')
const formRef = ref()
const queryFormRef = ref()

const queryParams = reactive({
  pageNum: 1,
  pageSize: 10,
  modelId: '',
  attrName: '',
  optionCode: ''
})

const form = reactive<CpqAttributeOptionForm>({
  modelId: 0,
  attrName: '',
  optionCode: '',
  optionLabel: '',
  optionValue: '',
  isDefault: '0',
  sortOrder: 0,
  remark: ''
})

const rules = {
  modelId: [{ required: true, message: '请输入产品模型ID', trigger: 'blur' }],
  attrName: [{ required: true, message: '请输入属性名称', trigger: 'blur' }],
  optionCode: [{ required: true, message: '请输入选项编码', trigger: 'blur' }],
  optionLabel: [{ required: true, message: '请输入选项标签', trigger: 'blur' }],
  optionValue: [{ required: true, message: '请输入选项值', trigger: 'blur' }]
}

onMounted(() => { loadData() })

async function loadData() {
  loading.value = true
  try {
    const params: Record<string, any> = { ...queryParams }
    if (params.modelId) params.modelId = Number(params.modelId)
    const res = await listAttributeOption(params)
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

function handleSelectionChange(selection: CpqAttributeOption[]) {
  selectedIds.value = selection.map(item => item.optionId)
}

function handleAdd() {
  resetForm()
  dialogTitle.value = '新增属性选项'
  dialogVisible.value = true
}

async function handleEdit(row: CpqAttributeOption) {
  resetForm()
  try {
    const data = await getAttributeOption(row.optionId)
    const detail = (data as any).data || data
    Object.assign(form, {
      optionId: detail.optionId,
      modelId: detail.modelId,
      attrName: detail.attrName,
      optionCode: detail.optionCode,
      optionLabel: detail.optionLabel,
      optionValue: detail.optionValue,
      isDefault: detail.isDefault,
      sortOrder: detail.sortOrder,
      remark: detail.remark
    })
    dialogTitle.value = '编辑属性选项'
    dialogVisible.value = true
  } catch { /* 异常已在拦截器处理 */ }
}

async function handleSubmit() {
  try {
    await formRef.value?.validate()
  } catch { return }
  submitLoading.value = true
  try {
    if (form.optionId) {
      await updateAttributeOption(form)
      ElMessage.success('修改成功')
    } else {
      await addAttributeOption(form)
      ElMessage.success('新增成功')
    }
    dialogVisible.value = false
    loadData()
  } finally {
    submitLoading.value = false
  }
}

function handleDelete(row: CpqAttributeOption) {
  ElMessageBox.confirm(`确认删除属性选项「${row.optionLabel}」？`, '警告', {
    confirmButtonText: '确定', cancelButtonText: '取消', type: 'warning'
  }).then(async () => {
    await delAttributeOption(row.optionId)
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
    for (const id of selectedIds.value) { await delAttributeOption(id) }
    ElMessage.success('批量删除成功')
    loadData()
  }).catch(() => {})
}

function handleDialogClose() { formRef.value?.resetFields() }

function resetForm() {
  form.optionId = undefined
  form.modelId = 0
  form.attrName = ''
  form.optionCode = ''
  form.optionLabel = ''
  form.optionValue = ''
  form.isDefault = '0'
  form.sortOrder = 0
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
