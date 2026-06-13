<template>
  <div class="page-container">
    <!-- 搜索区域 -->
    <el-card class="search-card">
      <el-form :model="queryParams" inline>
        <el-form-item label="产品型号">
          <el-select
            v-model="queryParams.modelId"
            placeholder="请选择产品型号"
            clearable
            filterable
            style="width: 280px"
            @change="loadList"
          >
            <el-option
              v-for="m in modelList"
              :key="m.modelId"
              :label="`${m.modelCode} ${m.modelName}`"
              :value="m.modelId"
            />
          </el-select>
        </el-form-item>
        <el-form-item label="属性名称">
          <el-input
            v-model="queryParams.attrName"
            placeholder="搜索属性名称"
            clearable
            style="width: 180px"
            @keyup.enter="loadList"
          />
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="loadList">查询</el-button>
          <el-button @click="resetQuery">重置</el-button>
        </el-form-item>
      </el-form>
    </el-card>

    <!-- 表格区域 -->
    <el-card class="table-card">
      <div class="mb-4">
        <el-button type="primary" @click="onAdd" :disabled="!queryParams.modelId">
          新增选项
        </el-button>
        <span v-if="!queryParams.modelId" class="ml-2" style="color: #909399; font-size: 12px;">
          请先选择产品型号
        </span>
      </div>
      <el-table v-loading="loading" :data="list" border stripe>
        <el-table-column prop="optionId" label="ID" width="80" />
        <el-table-column prop="attrName" label="属性名称" min-width="140" />
        <el-table-column prop="optionCode" label="选项编码" min-width="140" />
        <el-table-column prop="optionLabel" label="选项显示名" min-width="140" />
        <el-table-column prop="optionValue" label="选项值" min-width="140">
          <template #default="{ row }">
            {{ row.optionValue || '-' }}
          </template>
        </el-table-column>
        <el-table-column prop="isDefault" label="默认" width="70" align="center">
          <template #default="{ row }">
            <el-tag :type="row.isDefault === '1' ? 'success' : 'info'" size="small">
              {{ row.isDefault === '1' ? '是' : '否' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="sortOrder" label="排序" width="70" align="center" />
        <el-table-column label="操作" width="140" fixed="right">
          <template #default="{ row }">
            <el-button size="small" @click="onEdit(row)">编辑</el-button>
            <el-button size="small" type="danger" @click="onDelete(row)">删除</el-button>
          </template>
        </el-table-column>
      </el-table>
    </el-card>

    <!-- 新增/编辑弹窗 -->
    <el-dialog
      v-model="dialog.visible"
      :title="dialog.isEdit ? '编辑属性选项' : '新增属性选项'"
      width="560px"
      append-to-body
      destroy-on-close
      :close-on-click-modal="false"
    >
      <el-form ref="formRef" :model="form" :rules="rules" label-width="100px">
        <el-form-item label="产品型号" required>
          <el-input :value="modelLabel" disabled />
        </el-form-item>
        <el-form-item label="属性名称" prop="attrName" required>
          <el-input v-model="form.attrName" placeholder="如：颜色、基站版本、内存" />
        </el-form-item>
        <el-form-item label="选项编码" prop="optionCode" required>
          <el-input v-model="form.optionCode" placeholder="如：CLR-RED、MEM-16G" />
        </el-form-item>
        <el-form-item label="选项显示名" prop="optionLabel" required>
          <el-input v-model="form.optionLabel" placeholder="如：红色、16GB" />
        </el-form-item>
        <el-form-item label="选项值" prop="optionValue">
          <el-input v-model="form.optionValue" placeholder="传入配置引擎的值，如：red、16g" />
          <div class="form-tip">选项值用于配置引擎约束求解，同一属性下必须唯一，不能为空</div>
        </el-form-item>
        <el-form-item label="默认选项" prop="isDefault">
          <el-switch v-model="form.isDefaultBool" active-text="是" inactive-text="否" />
        </el-form-item>
        <el-form-item label="排序号" prop="sortOrder">
          <el-input-number v-model="form.sortOrder" :min="0" :max="999" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="dialog.visible = false">取消</el-button>
        <el-button type="primary" @click="handleSubmit" :loading="submitting">确定</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, computed, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import type { FormInstance, FormRules } from 'element-plus'
import {
  getAttributeOptionList,
  addAttributeOption,
  updateAttributeOption,
  deleteAttributeOption,
  type CpqAttributeOptionVo,
  type CpqAttributeOptionBo
} from '@/api/config'
import { getModelList } from '@/api/cpq/product'

interface ModelOption {
  modelId: number
  modelCode: string
  modelName: string
}

const loading = ref(false)
const submitting = ref(false)
const list = ref<CpqAttributeOptionVo[]>([])
const modelList = ref<ModelOption[]>([])
const formRef = ref<FormInstance>()

const queryParams = reactive({
  modelId: null as number | null,
  attrName: ''
})

const dialog = reactive({
  visible: false,
  isEdit: false
})

const form = reactive<CpqAttributeOptionBo & { isDefaultBool: boolean }>({
  modelId: 0,
  attrName: '',
  optionCode: '',
  optionLabel: '',
  optionValue: '',
  isDefault: '0',
  sortOrder: 0,
  isDefaultBool: false
})

const rules: FormRules = {
  attrName: [{ required: true, message: '请输入属性名称', trigger: 'blur' }],
  optionCode: [{ required: true, message: '请输入选项编码', trigger: 'blur' }],
  optionLabel: [{ required: true, message: '请输入选项显示名', trigger: 'blur' }],
  optionValue: [{ required: true, message: '请输入选项值', trigger: 'blur' }]
}

const modelLabel = computed(() => {
  const m = modelList.value.find(m => m.modelId === queryParams.modelId)
  return m ? `${m.modelCode} ${m.modelName}` : ''
})

onMounted(async () => {
  try {
    const res = await getModelList({ pageNum: 1, pageSize: 500 })
    modelList.value = Array.isArray(res) ? res : (res.rows ?? [])
  } catch {
    // ignore
  }
})

async function loadList() {
  if (!queryParams.modelId) {
    list.value = []
    return
  }
  loading.value = true
  try {
    const params: any = { modelId: queryParams.modelId }
    if (queryParams.attrName) {
      params.attrName = queryParams.attrName
    }
    list.value = await getAttributeOptionList(params)
  } catch (e: any) {
    ElMessage.error(e?.message ?? '加载失败')
  } finally {
    loading.value = false
  }
}

function resetQuery() {
  queryParams.modelId = null
  queryParams.attrName = ''
  list.value = []
}

function resetForm() {
  form.optionId = undefined
  form.attrName = ''
  form.optionCode = ''
  form.optionLabel = ''
  form.optionValue = ''
  form.isDefault = '0'
  form.sortOrder = 0
  form.isDefaultBool = false
}

function onAdd() {
  if (!queryParams.modelId) {
    ElMessage.warning('请先选择产品型号')
    return
  }
  resetForm()
  form.modelId = queryParams.modelId
  dialog.isEdit = false
  dialog.visible = true
}

function onEdit(row: CpqAttributeOptionVo) {
  resetForm()
  form.optionId = row.optionId
  form.modelId = row.modelId
  form.attrName = row.attrName
  form.optionCode = row.optionCode
  form.optionLabel = row.optionLabel
  form.optionValue = row.optionValue ?? ''
  form.isDefault = row.isDefault
  form.sortOrder = row.sortOrder
  form.isDefaultBool = row.isDefault === '1'
  dialog.isEdit = true
  dialog.visible = true
}

async function onDelete(row: CpqAttributeOptionVo) {
  try {
    await ElMessageBox.confirm(
      `确定删除属性选项「${row.attrName} - ${row.optionLabel}」吗？`, '确认删除',
      { type: 'warning' }
    )
    await deleteAttributeOption(row.optionId)
    ElMessage.success('删除成功')
    await loadList()
  } catch {
    // cancelled
  }
}

async function handleSubmit() {
  const valid = await formRef.value?.validate().catch(() => false)
  if (!valid) return

  submitting.value = true
  try {
    const data: CpqAttributeOptionBo = {
      modelId: form.modelId,
      attrName: form.attrName,
      optionCode: form.optionCode,
      optionLabel: form.optionLabel,
      optionValue: form.optionValue,
      isDefault: form.isDefaultBool ? '1' : '0',
      sortOrder: form.sortOrder
    }

    if (dialog.isEdit && form.optionId) {
      (data as any).optionId = form.optionId
      await updateAttributeOption(data)
      ElMessage.success('更新成功')
    } else {
      await addAttributeOption(data)
      ElMessage.success('新增成功')
    }
    dialog.visible = false
    await loadList()
  } catch (e: any) {
    ElMessage.error(e?.message ?? '操作失败')
  } finally {
    submitting.value = false
  }
}
</script>

<style scoped>
.page-container {
  display: flex;
  flex-direction: column;
  gap: 16px;
}
.search-card, .table-card {
  border-radius: 8px;
}
.form-tip {
  font-size: 12px;
  color: #909399;
  margin-top: 4px;
}
</style>
