<template>
  <div v-if="visible" class="variant-manager" @click.stop>
    <div class="variant-header">
      <span class="variant-title">变体管理（{{ model?.modelCode }}）</span>
      <el-button type="primary" size="small" @click="onAdd">新增变体</el-button>
    </div>

    <el-table :data="variants" stripe v-loading="loading" size="small" style="margin-top:8px">
      <el-table-column prop="variantCode" label="变体编码" width="160" />
      <el-table-column prop="variantName" label="变体名称" width="160" />
      <el-table-column label="属性" min-width="160">
        <template #default="{ row }">
          <span class="attr-text">{{ formatAttributes(row.attributes) }}</span>
        </template>
      </el-table-column>
      <el-table-column prop="basePrice" label="基础价" width="100">
        <template #default="{ row }">¥{{ row.basePrice }}</template>
      </el-table-column>
      <el-table-column label="默认" width="60" align="center">
        <template #default="{ row }">
          <el-tag v-if="row.isDefault === '1'" type="success" size="small">默认</el-tag>
          <span v-else style="color:#ccc">-</span>
        </template>
      </el-table-column>
      <el-table-column label="操作" width="120" fixed="right">
        <template #default="{ row }">
          <el-button link size="small" @click="onEdit(row)">编辑</el-button>
          <el-button link size="small" type="danger" @click="onDelete(row)">删除</el-button>
        </template>
      </el-table-column>
    </el-table>

    <!-- 变体对话框（append-to-body 防止被表格展开行裁剪） -->
    <el-dialog v-model="dialog.visible" :title="dialog.isEdit ? '编辑变体' : `新增变体 — ${model?.modelCode}`" width="520px" append-to-body :close-on-click-modal="false" destroy-on-close>
      <el-form :model="form" label-width="100px">
        <el-form-item label="变体编码">
          <el-input v-model="form.variantCode" placeholder="自动生成：型号编码-属性值缩写" />
        </el-form-item>
        <el-form-item label="变体名称">
          <el-input v-model="form.variantName" placeholder="如：SweepBot S1 Pro 白色款" />
        </el-form-item>
        <el-form-item label="属性配置">
          <el-input
            v-model="form.attributesJson"
            type="textarea"
            :rows="3"
            placeholder='JSON格式，如：{"颜色":"白色", "通信方式":"5G"}'
          />
          <span class="form-tip">属性以 JSON 对象格式输入，键值对用双引号</span>
        </el-form-item>
        <el-form-item label="基础价格">
          <el-input-number v-model="form.basePrice" :min="0" :precision="2" style="width:100%" />
        </el-form-item>
        <el-form-item label="缩略图URL">
          <el-input v-model="form.thumbnailUrl" placeholder="可选" />
        </el-form-item>
        <el-form-item label="是否默认">
          <el-switch v-model="form.isDefaultBool" active-value="1" inactive-value="0" />
        </el-form-item>
        <el-form-item label="状态">
          <el-radio-group v-model="form.status">
            <el-radio value="0">正常</el-radio>
            <el-radio value="1">停用</el-radio>
          </el-radio-group>
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="dialog.visible=false">取消</el-button>
        <el-button type="primary" @click="submit">确定</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, watch } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { getVariantList, addVariant, updateVariant, deleteVariant, type CpqProductVariantVo } from '@/api/cpq/variant'

interface ModelInfo {
  modelId: number
  modelCode: string
  modelName?: string
}

const props = defineProps<{
  model: ModelInfo | null
  visible: boolean
}>()

const emit = defineEmits<{
  'update:visible': [value: boolean]
  'variantChanged': []
}>()

const variants = ref<CpqProductVariantVo[]>([])
const loading = ref(false)

const dialog = reactive({ visible: false, isEdit: false })

interface VariantForm {
  variantId?: number
  variantCode: string
  variantName: string
  attributesJson: string
  basePrice: number | undefined
  thumbnailUrl: string
  isDefaultBool: string
  status: string
}

const form = reactive<VariantForm>({
  variantCode: '',
  variantName: '',
  attributesJson: '{}',
  basePrice: undefined,
  thumbnailUrl: '',
  isDefaultBool: '0',
  status: '0'
})

const formatAttributes = (attrs: string) => {
  try {
    const obj = JSON.parse(attrs)
    return Object.entries(obj).map(([k, v]) => `${k}: ${v}`).join(' | ')
  } catch {
    return attrs
  }
}

const load = async () => {
  if (!props.model?.modelId) { variants.value = []; return }
  loading.value = true
  try {
    const data = await getVariantList(props.model.modelId)
    variants.value = Array.isArray(data) ? data : []
  } catch {
    variants.value = []
  } finally {
    loading.value = false
  }
}

watch(() => [props.visible, props.model?.modelId], () => {
  if (props.visible && props.model?.modelId) load()
}, { immediate: true })

const resetForm = () => {
  Object.assign(form, {
    variantId: undefined,
    variantCode: props.model ? `${props.model.modelCode}-` : '',
    variantName: '',
    attributesJson: '{}',
    basePrice: undefined,
    thumbnailUrl: '',
    isDefaultBool: '0',
    status: '0'
  })
}

const onAdd = () => {
  resetForm()
  dialog.isEdit = false
  dialog.visible = true
}

const onEdit = (row: CpqProductVariantVo) => {
  Object.assign(form, {
    variantId: row.variantId,
    variantCode: row.variantCode,
    variantName: row.variantName,
    attributesJson: row.attributes,
    basePrice: row.basePrice,
    thumbnailUrl: row.thumbnailUrl || '',
    isDefaultBool: row.isDefault || '0',
    status: row.status || '0'
  })
  dialog.isEdit = true
  dialog.visible = true
}

const submit = async () => {
  // 验证 JSON
  let attrs: string
  try {
    JSON.parse(form.attributesJson)
    attrs = form.attributesJson
  } catch {
    ElMessage.error('属性格式错误，请输入合法的 JSON 对象')
    return
  }

  const data = {
    modelId: props.model!.modelId,
    variantCode: form.variantCode,
    variantName: form.variantName,
    attributes: attrs,
    basePrice: form.basePrice,
    thumbnailUrl: form.thumbnailUrl || undefined,
    isDefault: form.isDefaultBool,
    status: form.status,
    variantId: form.variantId
  }

  try {
    await (dialog.isEdit ? updateVariant(data) : addVariant(data))
    dialog.visible = false
    ElMessage.success(dialog.isEdit ? '变体修改成功' : '变体新增成功')
    load()
    emit('variantChanged')
  } catch (e: any) {
    ElMessage.error(e?.message || '操作失败')
  }
}

const onDelete = async (row: CpqProductVariantVo) => {
  try {
    await ElMessageBox.confirm(`确定删除变体「${row.variantCode} - ${row.variantName}」？如被价格条目引用将无法删除。`)
    await deleteVariant(row.variantId)
    ElMessage.success('变体删除成功')
    load()
    emit('variantChanged')
  } catch { /* cancelled */ }
}
</script>

<style scoped lang="scss">
.variant-manager {
  padding: 12px 16px;
  background: #fafbfc;
  border-top: 1px solid #e5e7eb;
}
.variant-header {
  display: flex; justify-content: space-between; align-items: center;
}
.variant-title {
  font-weight: 600; font-size: 14px; color: #374151;
}
.attr-text {
  font-size: 12px; color: #6b7280;
}
.form-tip {
  font-size: 11px; color: #9ca3af; display: block; margin-top: 4px;
}
</style>
