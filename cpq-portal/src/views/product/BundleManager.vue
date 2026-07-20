<template>
  <div class="page-container">
    <el-card class="table-card">
      <div class="mb-4">
        <el-button type="primary" @click="onAdd">新增捆绑包</el-button>
      </div>
      <el-table v-loading="loading" :data="list" border stripe>
        <el-table-column prop="bundleId" label="ID" width="80" />
        <el-table-column prop="description" label="捆绑包名称" min-width="180">
          <template #default="{ row }">
            <span>{{ row.description || `捆绑包#${row.bundleId}` }}</span>
          </template>
        </el-table-column>
        <el-table-column prop="bundleType" label="类型" width="130">
          <template #default="{ row }">
            <el-tag :type="bundleTypeTag(row.bundleType)">{{ bundleTypeLabel(row.bundleType) }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="pricingStrategy" label="定价策略" width="130">
          <template #default="{ row }">
            {{ row.pricingStrategy === 'BUNDLE_PRICE' ? '捆绑定价' : '组件求和' }}
          </template>
        </el-table-column>
        <el-table-column prop="bundleDiscountPct" label="折扣率(%)" width="100">
          <template #default="{ row }">
            {{ row.bundleDiscountPct != null ? row.bundleDiscountPct + '%' : '-' }}
          </template>
        </el-table-column>
        <el-table-column prop="isActive" label="启用" width="70">
          <template #default="{ row }">
            <el-tag :type="row.isActive === '1' ? 'success' : 'info'">{{ row.isActive === '1' ? '是' : '否' }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="150" fixed="right">
          <template #default="{ row }">
            <el-button size="small" @click="onEdit(row)">编辑</el-button>
            <el-button size="small" type="danger" @click="onDelete(row)">删除</el-button>
          </template>
        </el-table-column>
      </el-table>
    </el-card>

    <el-dialog v-model="dialog.visible" :title="dialog.isEdit ? '编辑捆绑包' : '新增捆绑包'" width="600px" append-to-body destroy-on-close :close-on-click-modal="false">
      <el-form ref="formRef" :model="form" label-width="110px">
        <el-form-item label="捆绑包产品" required>
          <ModelLookup v-model="form.modelId" config-type="BUNDLE" placeholder="搜索config_type=BUNDLE的产品" @select="onModelSelect" @clear="onModelClear" />
          <span v-if="selectedModelCode" style="margin-left:8px;color:#409eff">{{ selectedModelCode }}</span>
        </el-form-item>
        <el-row :gutter="16">
          <el-col :span="12">
            <el-form-item label="捆绑类型" required>
              <el-select v-model="form.bundleType" style="width:100%">
                <el-option label="固定组合(FIXED)" value="FIXED" />
                <el-option label="可配组合(CONFIGURABLE)" value="CONFIGURABLE" />
                <el-option label="方案型(SOLUTION)" value="SOLUTION" />
              </el-select>
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="定价策略" required>
              <el-select v-model="form.pricingStrategy" style="width:100%">
                <el-option label="捆绑定价" value="BUNDLE_PRICE" />
                <el-option label="组件求和" value="SUM_COMPONENTS" />
              </el-select>
            </el-form-item>
          </el-col>
        </el-row>
        <el-form-item label="折扣率(%)">
          <el-input-number v-model="form.bundleDiscountPct" :min="0" :max="100" :precision="2" style="width:100%" />
        </el-form-item>
        <el-form-item label="描述">
          <el-input v-model="form.description" type="textarea" :rows="2" placeholder="捆绑包描述" />
        </el-form-item>
        <el-form-item label="状态">
          <el-radio-group v-model="form.status">
            <el-radio value="0">正常</el-radio>
            <el-radio value="1">停用</el-radio>
          </el-radio-group>
        </el-form-item>
        <el-form-item label="是否启用">
          <el-switch v-model="form.isActiveBool" active-value="1" inactive-value="0" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="dialog.visible = false">取消</el-button>
        <el-button type="primary" @click="submit">确定</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { getBundleList, getBundleById, addBundle, updateBundle, deleteBundle, type CpqBundleVo } from '@/api/bundle'
import ModelLookup from '@/components/cpq/ModelLookup.vue'
import type { CpqProductModelVo } from '@/api/cpq/product'

const loading = ref(false)
const list = ref<CpqBundleVo[]>([])
const dialog = reactive({ visible: false, isEdit: false })
const selectedModelCode = ref('')

const form = reactive({
  bundleId: undefined as number | undefined, modelId: null as number | null,
  bundleType: 'FIXED', pricingStrategy: 'BUNDLE_PRICE', bundleDiscountPct: undefined as number | undefined,
  isActive: '1', isActiveBool: '1' as string, description: '', status: '0'
})

function onModelSelect(model: CpqProductModelVo) {
  selectedModelCode.value = model.modelCode
}
function onModelClear() {
  selectedModelCode.value = ''
}

const bundleTypeLabel = (t: string) => ({ FIXED: '固定组合', CONFIGURABLE: '可配组合', SOLUTION: '方案型' })[t] || t
const bundleTypeTag = (t: string) => ({ FIXED: '', CONFIGURABLE: 'success', SOLUTION: 'warning' })[t] || ''

async function load() {
  loading.value = true
  try {
    const res = await getBundleList()
    list.value = Array.isArray(res) ? res : (res.rows || [])
  } catch (e: any) { ElMessage.error(e?.message || '加载失败') }
  finally { loading.value = false }
}

function resetForm() {
  Object.assign(form, { bundleId: undefined, modelId: null, bundleType: 'FIXED', pricingStrategy: 'BUNDLE_PRICE', bundleDiscountPct: undefined, isActive: '1', isActiveBool: '1', description: '', status: '0' })
  selectedModelCode.value = ''
}

function onAdd() { resetForm(); dialog.isEdit = false; dialog.visible = true }
async function onEdit(row: CpqBundleVo) {
  const data = await getBundleById(row.bundleId)
  Object.assign(form, { ...data, isActiveBool: data.isActive })
  dialog.isEdit = true; dialog.visible = true
}
async function onDelete(row: CpqBundleVo) {
  try {
    await ElMessageBox.confirm(`确认删除捆绑包？`, '警告', { type: 'warning' })
    await deleteBundle(row.bundleId)
    ElMessage.success('删除成功')
    load()
  } catch { /* cancelled */ }
}

async function submit() {
  try {
    const payload = { ...form, isActive: form.isActiveBool }
    if (form.bundleId) { await updateBundle(payload as any); ElMessage.success('修改成功') }
    else { await addBundle(payload as any); ElMessage.success('新增成功') }
    dialog.visible = false; load()
  } catch (e: any) { ElMessage.error(e?.message || '操作失败') }
}

onMounted(() => load())
</script>
