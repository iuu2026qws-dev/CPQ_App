<template>
  <div class="app-container">
    <!-- 功能介绍卡片 -->
    <el-alert type="info" :closable="false" show-icon class="mb-16">
      <template #title>
        <strong>属性映射</strong> 定义属性选项值与物料编码之间的映射关系。当用户选择了某个属性值（如：颜色=珍珠白），系统自动匹配对应的物料（如：PAINT-WHITE-RAL9016）。
        这是 SBOM→MBOM 转换的核心桥梁，支撑配置后的自动物料清单生成。
      </template>
    </el-alert>

    <!-- 统计卡片 -->
    <el-row :gutter="16" class="mb-16">
      <el-col :span="6">
        <el-statistic title="总映射数" :value="total" />
      </el-col>
      <el-col :span="6">
        <el-statistic title="当前页" :value="dataList.length" />
      </el-col>
      <el-col :span="6">
        <el-statistic title="关联物料" :value="new Set(dataList.map(r => r.materialCode)).size" />
      </el-col>
      <el-col :span="6">
        <el-statistic title="已选" :value="selectedIds.length" />
      </el-col>
    </el-row>

    <el-card>
      <template #header>
        <div class="card-header">
          <span>属性映射管理</span>
          <div class="header-actions">
            <el-button type="primary" @click="handleAdd" v-hasPermi="['cpq:config:attributemapping:add']">
              <el-icon><Plus /></el-icon>新增
            </el-button>
            <el-button type="danger" :disabled="selectedIds.length === 0" @click="handleBatchDelete" v-hasPermi="['cpq:config:attributemapping:remove']">
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
        <el-form-item label="物料编码" prop="materialCode">
          <el-input v-model="queryParams.materialCode" placeholder="请输入物料编码" clearable @keyup.enter="handleQuery" />
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
        <el-table-column label="ID" prop="mappingId" width="80" align="center" />
        <el-table-column label="产品模型ID" prop="modelId" width="120" align="center" />
        <el-table-column label="属性名称" prop="attrName" min-width="120" show-overflow-tooltip />
        <el-table-column label="属性值" prop="attrValue" min-width="120" show-overflow-tooltip />
        <el-table-column label="物料编码" prop="materialCode" min-width="130" show-overflow-tooltip />
        <el-table-column label="SBOM行ID" prop="sbomLineId" width="100" align="center" />
        <el-table-column label="条件表达式" prop="conditionExpr" min-width="150" show-overflow-tooltip />
        <el-table-column label="排序" prop="sortOrder" width="80" align="center" />
        <el-table-column label="创建时间" prop="createTime" width="160" align="center" />
        <el-table-column label="操作" width="200" align="center" fixed="right">
          <template #default="{ row }">
            <el-button link type="primary" @click="handleEdit(row)" v-hasPermi="['cpq:config:attributemapping:edit']">
              <el-icon><Edit /></el-icon>编辑
            </el-button>
            <el-button link type="danger" @click="handleDelete(row)" v-hasPermi="['cpq:config:attributemapping:remove']">
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
      <el-form ref="formRef" :model="form" :rules="rules" label-width="110px">
        <el-form-item label="产品模型ID" prop="modelId">
          <el-input-number v-model="form.modelId" :min="1" placeholder="请输入产品模型ID" style="width:100%" />
        </el-form-item>
        <el-form-item label="属性名称" prop="attrName">
          <el-input v-model="form.attrName" placeholder="如: CPU, 内存, 硬盘" maxlength="64" />
        </el-form-item>
        <el-form-item label="属性值" prop="attrValue">
          <el-input v-model="form.attrValue" placeholder="如: i7, 64GB, 2TB_SSD" maxlength="128" />
        </el-form-item>
        <el-form-item label="物料编码" prop="materialCode">
          <el-input v-model="form.materialCode" placeholder="如: MAT-CPU-001" maxlength="64" />
        </el-form-item>
        <el-form-item label="SBOM行ID">
          <el-input-number v-model="form.sbomLineId" :min="0" placeholder="关联的SBOM行ID" style="width:100%" />
        </el-form-item>
        <el-form-item label="条件表达式">
          <el-input v-model="form.conditionExpr" type="textarea" :rows="2" placeholder="如: attr['MEM']=='64GB'" />
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
  listAttributeMapping,
  getAttributeMapping,
  addAttributeMapping,
  updateAttributeMapping,
  delAttributeMapping,
  type CpqAttributeMapping,
  type CpqAttributeMappingForm
} from '@/api/cpq/attribute-mapping'

const loading = ref(false)
const submitLoading = ref(false)
const dataList = ref<CpqAttributeMapping[]>([])
const total = ref(0)
const selectedIds = ref<number[]>([])
const dialogVisible = ref(false)
const dialogTitle = ref('新增属性映射')
const formRef = ref()
const queryFormRef = ref()

const queryParams = reactive({
  pageNum: 1,
  pageSize: 10,
  modelId: '',
  attrName: '',
  materialCode: ''
})

const form = reactive<CpqAttributeMappingForm>({
  modelId: 0,
  attrName: '',
  attrValue: '',
  materialCode: '',
  sbomLineId: undefined,
  conditionExpr: '',
  sortOrder: 0,
  remark: ''
})

const rules = {
  modelId: [{ required: true, message: '请输入产品模型ID', trigger: 'blur' }],
  attrName: [{ required: true, message: '请输入属性名称', trigger: 'blur' }],
  attrValue: [{ required: true, message: '请输入属性值', trigger: 'blur' }],
  materialCode: [{ required: true, message: '请输入物料编码', trigger: 'blur' }]
}

onMounted(() => { loadData() })

async function loadData() {
  loading.value = true
  try {
    const params: Record<string, any> = { ...queryParams }
    if (params.modelId) params.modelId = Number(params.modelId)
    const res = await listAttributeMapping(params)
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

function handleSelectionChange(selection: CpqAttributeMapping[]) {
  selectedIds.value = selection.map(item => item.mappingId)
}

function handleAdd() {
  resetForm()
  dialogTitle.value = '新增属性映射'
  dialogVisible.value = true
}

async function handleEdit(row: CpqAttributeMapping) {
  resetForm()
  try {
    const data = await getAttributeMapping(row.mappingId)
    const detail = (data as any).data || data
    Object.assign(form, {
      mappingId: detail.mappingId,
      modelId: detail.modelId,
      attrName: detail.attrName,
      attrValue: detail.attrValue,
      materialCode: detail.materialCode,
      sbomLineId: detail.sbomLineId,
      conditionExpr: detail.conditionExpr,
      sortOrder: detail.sortOrder,
      remark: detail.remark
    })
    dialogTitle.value = '编辑属性映射'
    dialogVisible.value = true
  } catch { /* 异常已在拦截器处理 */ }
}

async function handleSubmit() {
  try {
    await formRef.value?.validate()
  } catch { return }
  submitLoading.value = true
  try {
    if (form.mappingId) {
      await updateAttributeMapping(form)
      ElMessage.success('修改成功')
    } else {
      await addAttributeMapping(form)
      ElMessage.success('新增成功')
    }
    dialogVisible.value = false
    loadData()
  } finally {
    submitLoading.value = false
  }
}

function handleDelete(row: CpqAttributeMapping) {
  ElMessageBox.confirm(`确认删除属性映射「${row.attrName}=${row.attrValue} → ${row.materialCode}」？`, '警告', {
    confirmButtonText: '确定', cancelButtonText: '取消', type: 'warning'
  }).then(async () => {
    await delAttributeMapping(row.mappingId)
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
    for (const id of selectedIds.value) { await delAttributeMapping(id) }
    ElMessage.success('批量删除成功')
    loadData()
  }).catch(() => {})
}

function handleDialogClose() { formRef.value?.resetFields() }

function resetForm() {
  form.mappingId = undefined
  form.modelId = 0
  form.attrName = ''
  form.attrValue = ''
  form.materialCode = ''
  form.sbomLineId = undefined
  form.conditionExpr = ''
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
