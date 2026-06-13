<template>
  <div class="page-container">
    <el-card class="search-card" shadow="never">
      <el-form :model="query" inline>
        <el-form-item label="产品编码">
          <el-input v-model="query.modelCode" placeholder="请输入编码" clearable style="width:150px" @keyup.enter="onSearch" />
        </el-form-item>
        <el-form-item label="产品名称">
          <el-input v-model="query.modelName" placeholder="请输入名称" clearable style="width:180px" @keyup.enter="onSearch" />
        </el-form-item>
        <el-form-item label="配置类型">
          <el-select v-model="query.configType" placeholder="全部" clearable style="width:140px">
            <el-option label="标准(STANDARD)" value="STANDARD" />
            <el-option label="按单装配(ATO)" value="ATO" />
            <el-option label="按单配置(CTO)" value="CTO" />
            <el-option label="按单设计(ETO)" value="ETO" />
            <el-option label="捆绑(BUNDLE)" value="BUNDLE" />
          </el-select>
        </el-form-item>
        <el-form-item label="生命周期">
          <el-select v-model="query.lifecycleStatus" placeholder="全部" clearable style="width:160px">
            <el-option v-for="s in lifecycles" :key="s.value" :label="s.label" :value="s.value" />
          </el-select>
        </el-form-item>
        <el-form-item label="目录">
          <el-select v-model="query.catalogId" placeholder="全部" clearable style="width:160px" filterable>
            <el-option v-for="c in catalogList" :key="c.catalogId" :label="c.catalogName" :value="c.catalogId" />
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="onSearch">查询</el-button>
          <el-button @click="onReset">重置</el-button>
        </el-form-item>
      </el-form>
    </el-card>

    <el-card class="table-card" shadow="never">
      <div class="table-header">
        <div class="left">
          <span class="title">产品模型</span>
          <span class="count">共 {{ total }} 条</span>
        </div>
        <div class="right">
          <el-button type="primary" @click="onAdd">新增产品</el-button>
        </div>
      </div>
      <el-table v-loading="loading" :data="list" stripe border>
        <el-table-column prop="modelId" label="ID" width="70" />
        <el-table-column prop="modelCode" label="产品编码" width="150" show-overflow-tooltip />
        <el-table-column prop="modelName" label="产品名称" min-width="160" show-overflow-tooltip />
        <el-table-column label="配置类型" width="110">
          <template #default="{ row }">
            <el-tag :type="configTag(row.configType)" size="small">{{ configLabel(row.configType) }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column label="生命周期" width="140">
          <template #default="{ row }">
            <el-tag :type="lifecycleTag(row.lifecycleStatus)" size="small" effect="plain">{{ lifecycleLabel(row.lifecycleStatus) }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="catalogName" label="所属目录" width="130" show-overflow-tooltip />
        <el-table-column label="分类路径" width="200" show-overflow-tooltip>
          <template #default="{ row }">
            <span>{{ row.categoryPath || '-' }}</span>
          </template>
        </el-table-column>
        <el-table-column label="基础价" width="100" align="right">
          <template #default="{ row }">
            <span v-if="row.basePrice != null">{{ row.basePrice }} {{ row.currency || 'CNY' }}</span>
            <span v-else>-</span>
          </template>
        </el-table-column>
        <el-table-column prop="minOrderQty" label="起订量" width="80" align="center" />
        <el-table-column label="状态" width="70" align="center">
          <template #default="{ row }">
            <el-tag :type="row.status === '0' ? 'success' : 'info'" size="small">{{ row.status === '0' ? '正常' : '停用' }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="160" fixed="right">
          <template #default="{ row }">
            <el-button link size="small" @click="onEdit(row)">编辑</el-button>
            <el-button link size="small" type="danger" @click="onDelete(row)">删除</el-button>
          </template>
        </el-table-column>
      </el-table>
      <div class="pagination-wrap">
        <el-pagination
          v-model:current-page="query.pageNum"
          v-model:page-size="query.pageSize"
          :total="total"
          :page-sizes="[10, 20, 50, 100]"
          layout="total, sizes, prev, pager, next, jumper"
          @size-change="load"
          @current-change="load"
        />
      </div>
    </el-card>

    <!-- Add / Edit Dialog -->
    <el-dialog
      v-model="dialog.visible"
      :title="dialog.isEdit ? '编辑产品' : '新增产品'"
      width="700px"
      append-to-body
      destroy-on-close
      :close-on-click-modal="false"
    >
      <el-form ref="formRef" :model="form" :rules="rules" label-width="110px">
        <el-row :gutter="16">
          <el-col :span="12">
            <el-form-item label="产品编码" prop="modelCode">
              <el-input v-model="form.modelCode" placeholder="如 SERVO-X100" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="产品名称" prop="modelName">
              <el-input v-model="form.modelName" placeholder="如 X100伺服驱动器" />
            </el-form-item>
          </el-col>
        </el-row>
        <el-row :gutter="16">
          <el-col :span="12">
            <el-form-item label="所属目录" prop="catalogId">
              <el-select v-model="form.catalogId" placeholder="选择目录" style="width:100%" filterable>
                <el-option v-for="c in catalogList" :key="c.catalogId" :label="c.catalogName" :value="c.catalogId" />
              </el-select>
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="产品分类" prop="categoryId">
              <el-cascader
                v-model="form.categoryPath"
                :options="categoryTree"
                :props="{ value: 'categoryId', label: 'categoryName', children: 'children', emitPath: false }"
                placeholder="选择L3产品系列"
                style="width:100%"
                filterable
                clearable
                @change="onCategoryChange"
              />
            </el-form-item>
          </el-col>
        </el-row>
        <el-form-item label="描述">
          <el-input v-model="form.description" type="textarea" :rows="2" placeholder="产品简要描述" />
        </el-form-item>
        <el-row :gutter="16">
          <el-col :span="12">
            <el-form-item label="配置类型" prop="configType">
              <el-select v-model="form.configType" style="width:100%">
                <el-option label="标准(STANDARD)" value="STANDARD" />
                <el-option label="按单装配(ATO)" value="ATO" />
                <el-option label="按单配置(CTO)" value="CTO" />
                <el-option label="按单设计(ETO)" value="ETO" />
                <el-option label="捆绑(BUNDLE)" value="BUNDLE" />
              </el-select>
            </el-form-item>
          </el-col>
          <el-col v-if="dialog.isEdit" :span="12">
            <el-form-item label="生命周期">
              <el-select v-model="form.lifecycleStatus" style="width:100%">
                <el-option v-for="s in lifecycles" :key="s.value" :label="s.label" :value="s.value" />
              </el-select>
            </el-form-item>
          </el-col>
        </el-row>
        <el-row :gutter="16">
          <el-col :span="8">
            <el-form-item label="基础价">
              <el-input-number v-model="form.basePrice" :min="0" :precision="2" :controls="false" style="width:100%" />
            </el-form-item>
          </el-col>
          <el-col :span="8">
            <el-form-item label="币种">
              <el-select v-model="form.currency" style="width:100%">
                <el-option label="CNY" value="CNY" />
                <el-option label="USD" value="USD" />
                <el-option label="EUR" value="EUR" />
                <el-option label="JPY" value="JPY" />
              </el-select>
            </el-form-item>
          </el-col>
          <el-col :span="8">
            <el-form-item label="交期(天)">
              <el-input-number v-model="form.leadTimeDays" :min="0" :controls="false" style="width:100%" />
            </el-form-item>
          </el-col>
        </el-row>
        <el-row :gutter="16">
          <el-col :span="8">
            <el-form-item label="起订量">
              <el-input-number v-model="form.minOrderQty" :min="1" :controls="false" style="width:100%" />
            </el-form-item>
          </el-col>
          <el-col :span="8">
            <el-form-item label="默认BOM ID">
              <el-input-number v-model="form.defaultBomId" :min="1" :controls="false" style="width:100%" />
            </el-form-item>
          </el-col>
          <el-col :span="8">
            <el-form-item label="替代品ID">
              <el-input-number v-model="form.successorModelId" :min="1" :controls="false" style="width:100%" />
            </el-form-item>
          </el-col>
        </el-row>
        <el-form-item label="状态">
          <el-radio-group v-model="form.status">
            <el-radio value="0">正常</el-radio>
            <el-radio value="1">停用</el-radio>
          </el-radio-group>
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="dialog.visible = false">取消</el-button>
        <el-button type="primary" :loading="submitting" @click="submit">确定</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import type { FormInstance, FormRules } from 'element-plus'
import request from '@/utils/request'
import {
  getModelList, getModelById, addModel, updateModel, deleteModel,
  type CpqProductModelVo, type CpqProductModelBo
} from '@/api/cpq/product'

const loading = ref(false)
const submitting = ref(false)
const list = ref<CpqProductModelVo[]>([])
const total = ref(0)
const formRef = ref<FormInstance>()

const query = reactive({
  pageNum: 1, pageSize: 10,
  modelCode: '', modelName: '',
  configType: '', lifecycleStatus: '',
  catalogId: undefined as number | undefined
})

const dialog = reactive({ visible: false, isEdit: false })

const initForm = (): CpqProductModelBo => ({
  catalogId: 0, categoryId: 0,
  modelCode: '', modelName: '',
  description: '', configType: 'STANDARD',
  lifecycleStatus: 'CONCEPT',
  basePrice: undefined, currency: 'CNY',
  minOrderQty: 1, leadTimeDays: undefined,
  defaultBomId: undefined, successorModelId: undefined,
  status: '0'
})

const form = reactive<CpqProductModelBo & { categoryPath?: number[] }>({
  ...initForm(), categoryPath: []
})

const rules: FormRules = {
  modelCode: [{ required: true, message: '请输入产品编码', trigger: 'blur' }],
  modelName: [{ required: true, message: '请输入产品名称', trigger: 'blur' }],
  catalogId: [{ required: true, message: '请选择目录', trigger: 'change' }],
  configType: [{ required: true, message: '请选择配置类型', trigger: 'change' }]
}

const lifecycles = [
  { value: 'CONCEPT', label: '概念(CONCEPT)' },
  { value: 'DESIGN', label: '设计中(DESIGN)' },
  { value: 'PRE_RELEASE', label: '预发布(PRE_RELEASE)' },
  { value: 'ACTIVE', label: '量产中(ACTIVE)' },
  { value: 'EOL_ANNOUNCED', label: '停产通告(EOL_ANNOUNCED)' },
  { value: 'LAST_TIME_BUY', label: '末次采购(LAST_TIME_BUY)' },
  { value: 'DISCONTINUED', label: '已停产(DISCONTINUED)' },
  { value: 'ARCHIVED', label: '已归档(ARCHIVED)' }
]

const lifecycleLabel = (s: string) => {
  const m: Record<string, string> = {}
  lifecycles.forEach(l => m[l.value] = l.label)
  return m[s] || s || '-'
}

const lifecycleTag = (s: string) => {
  const m: Record<string, string> = {
    CONCEPT: 'info', DESIGN: 'info', PRE_RELEASE: 'warning',
    ACTIVE: 'success', EOL_ANNOUNCED: 'warning',
    LAST_TIME_BUY: 'danger', DISCONTINUED: 'danger', ARCHIVED: 'info'
  }
  return m[s] || 'info'
}

const configLabel = (t: string) => {
  const m: Record<string, string> = { STANDARD: '标准', ATO: '装配', CTO: '配置', ETO: '设计', BUNDLE: '捆绑' }
  return m[t] || t
}

const configTag = (t: string) => {
  const m: Record<string, string> = { STANDARD: '', ATO: 'success', CTO: 'warning', ETO: 'danger', BUNDLE: 'info' }
  return m[t] || ''
}

// Catalog dropdown
interface CatalogItem { catalogId: number; catalogName: string }
const catalogList = ref<CatalogItem[]>([])

async function loadCatalogs() {
  try {
    const data: any = await request.get('/cpq/product/catalog/list', { params: { pageNum: 1, pageSize: 200 } })
    catalogList.value = (data?.rows || data || [])
  } catch { /* silent */ }
}

// Category tree for cascader
interface CategoryNode { categoryId: number; categoryName: string; level: number; children?: CategoryNode[] }
const categoryTree = ref<CategoryNode[]>([])

async function loadCategories() {
  try {
    const data: any = await request.get('/cpq/product/category/tree')
    categoryTree.value = (data?.children || data || []) as CategoryNode[]
  } catch { /* silent */ }
}

function onCategoryChange(value: any) {
  if (typeof value === 'number') {
    form.categoryId = value
  }
}

// Load data
async function load() {
  loading.value = true
  try {
    const params: any = { pageNum: query.pageNum, pageSize: query.pageSize }
    if (query.modelCode) params.modelCode = query.modelCode
    if (query.modelName) params.modelName = query.modelName
    if (query.configType) params.configType = query.configType
    if (query.lifecycleStatus) params.lifecycleStatus = query.lifecycleStatus
    if (query.catalogId) params.catalogId = query.catalogId
    const data = await getModelList(params)
    if (data) {
      list.value = data.rows || []
      total.value = data.total || 0
    }
  } catch (e: any) {
    ElMessage.error(e?.message || '加载失败')
  } finally {
    loading.value = false
  }
}

function onSearch() { query.pageNum = 1; load() }
function onReset() {
  Object.assign(query, { pageNum: 1, pageSize: 10, modelCode: '', modelName: '', configType: '', lifecycleStatus: '', catalogId: undefined })
  load()
}

function onAdd() {
  Object.assign(form, { ...initForm(), categoryPath: [] })
  dialog.isEdit = false; dialog.visible = true
}

async function onEdit(row: CpqProductModelVo) {
  try {
    const data = await getModelById(row.modelId)
    if (data) {
      Object.assign(form, {
        modelId: data.modelId,
        catalogId: data.catalogId,
        categoryId: data.categoryId,
        categoryPath: data.categoryId ? [data.categoryId] : [],
        modelCode: data.modelCode,
        modelName: data.modelName,
        description: data.description || '',
        configType: data.configType,
        lifecycleStatus: data.lifecycleStatus,
        basePrice: data.basePrice,
        currency: data.currency || 'CNY',
        minOrderQty: data.minOrderQty ?? 1,
        leadTimeDays: data.leadTimeDays,
        defaultBomId: data.defaultBomId,
        successorModelId: data.successorModelId,
        status: data.status
      })
    }
    dialog.isEdit = true; dialog.visible = true
  } catch (e: any) {
    ElMessage.error(e?.message || '加载详情失败')
  }
}

async function onDelete(row: CpqProductModelVo) {
  try {
    await ElMessageBox.confirm(`确认删除产品「${row.modelName}」(${row.modelCode})？`, '警告', {
      type: 'warning', confirmButtonText: '确定', cancelButtonText: '取消'
    })
    await deleteModel(row.modelId)
    ElMessage.success('删除成功')
    load()
  } catch { /* cancelled */ }
}

async function submit() {
  const valid = await formRef.value?.validate().catch(() => false)
  if (!valid) return
  submitting.value = true
  try {
    const payload: CpqProductModelBo = {
      modelId: form.modelId,
      catalogId: form.catalogId,
      categoryId: form.categoryId,
      modelCode: form.modelCode,
      modelName: form.modelName,
      description: form.description,
      configType: form.configType,
      lifecycleStatus: form.lifecycleStatus,
      basePrice: form.basePrice,
      currency: form.currency,
      minOrderQty: form.minOrderQty,
      leadTimeDays: form.leadTimeDays,
      defaultBomId: form.defaultBomId,
      successorModelId: form.successorModelId,
      status: form.status
    }
    if (form.modelId) {
      await updateModel(payload)
      ElMessage.success('修改成功')
    } else {
      await addModel(payload)
      ElMessage.success('新增成功')
    }
    dialog.visible = false
    load()
  } catch (e: any) {
    ElMessage.error(e?.message || '操作失败')
  } finally {
    submitting.value = false
  }
}

onMounted(() => {
  loadCatalogs()
  loadCategories()
  load()
})
</script>

<style scoped lang="scss">
.page-container {
  padding: 16px;
}
.search-card {
  margin-bottom: 16px;
  :deep(.el-card__body) { padding-bottom: 0; }
}
.table-header {
  display: flex; justify-content: space-between; align-items: center;
  margin-bottom: 14px;
  .left {
    display: flex; align-items: center; gap: 10px;
    .title { font-size: 15px; font-weight: 600; }
    .count { font-size: 12px; color: var(--el-text-color-secondary); }
  }
}
.pagination-wrap {
  display: flex; justify-content: flex-end;
  margin-top: 16px;
}
</style>
