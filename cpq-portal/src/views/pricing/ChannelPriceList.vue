<template>
  <div class="channel-price-list">
    <div class="page-header">
      <h2>渠道价格</h2>
      <p class="subtitle">管理不同渠道的专属产品定价和折扣率</p>
    </div>
    <el-card shadow="never">
      <template #header><div class="card-header"><span>渠道价格列表</span><el-button type="primary" size="small" @click="onAdd">新增</el-button></div></template>
      <el-table :data="list" stripe v-loading="loading">
        <el-table-column prop="channelCode" label="渠道代码" width="120" />
        <el-table-column label="产品" width="180">
          <template #default="{ row }">
            {{ modelLabel(row.modelId) }}
          </template>
        </el-table-column>
            <el-table-column label="变体" width="180">
              <template #default="{ row }">
                <span v-if="row.variantCode">{{ row.variantCode }} - {{ row.variantName }}</span>
                <span v-else style="color:#9ca3af;font-size:12px">模型级定价</span>
              </template>
            </el-table-column>
        <el-table-column prop="channelListPrice" label="渠道目录价" width="130" />
        <el-table-column prop="channelDiscountPct" label="折扣率(%)" width="110" />
        <el-table-column prop="effectiveDate" label="生效日期" width="120" />
        <el-table-column prop="expiryDate" label="失效日期" width="120" />
        <el-table-column prop="status" label="状态" width="80"><template #default="{ row }"><el-tag :type="row.status==='0'?'success':'info'" size="small">{{ row.status==='0'?'启用':'停用' }}</el-tag></template></el-table-column>
        <el-table-column label="操作" width="140" fixed="right"><template #default="{ row }"><el-button link size="small" @click="onEdit(row)">编辑</el-button><el-button link size="small" type="danger" @click="onDelete(row)">删除</el-button></template></el-table-column>
      </el-table>
    </el-card>

    <el-dialog v-model="dialog.visible" :title="dialog.isEdit ? '编辑渠道价格' : '新增渠道价格'" width="500px">
      <el-form :model="form" label-width="120px">
        <el-form-item label="渠道代码"><el-input v-model="form.channelCode" /></el-form-item>
        <el-form-item label="产品" required>
          <ModelLookup
            v-model="form.modelId"
            @select="onModelSelected"
            @clear="onModelCleared"
          />
        </el-form-item>
        <el-form-item label="变体">
          <VariantLookup
            v-model="form.variantId"
            :model-id="form.modelId"
            :config-type="configType"
            @select="onVariantSelected"
          />
        </el-form-item>
        <el-form-item label="渠道目录价"><el-input-number v-model="form.channelListPrice" :min="0" :precision="2" style="width:100%" /></el-form-item>
        <el-form-item label="折扣率(%)"><el-input-number v-model="form.channelDiscountPct" :min="0" :max="100" :precision="2" style="width:100%" /></el-form-item>
        <el-form-item label="生效日期"><el-date-picker v-model="form.effectiveDate" type="date" value-format="YYYY-MM-DD" style="width:100%" /></el-form-item>
        <el-form-item label="失效日期"><el-date-picker v-model="form.expiryDate" type="date" value-format="YYYY-MM-DD" style="width:100%" /></el-form-item>
        <el-form-item label="状态"><el-select v-model="form.status" style="width:100%"><el-option label="启用" value="0" /><el-option label="停用" value="1" /></el-select></el-form-item>
      </el-form>
      <template #footer><el-button @click="dialog.visible=false">取消</el-button><el-button type="primary" @click="submit">确定</el-button></template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import request from '@/utils/request'
import { getChannelPriceList, addChannelPrice, updateChannelPrice, deleteChannelPrice, type CpqChannelPrice } from '@/api/pricing'
import ModelLookup from '@/components/cpq/ModelLookup.vue'
import VariantLookup from '@/components/cpq/VariantLookup.vue'
import type { CpqProductModelVo } from '@/api/cpq/product'
import type { CpqProductVariantVo } from '@/api/cpq/variant'

// 扩展 CpqChannelPrice 添加 variantId（阶段2）
interface ChannelPriceForm extends CpqChannelPrice {
  variantId?: number
}

const today = () => new Date().toISOString().split('T')[0]

const list = ref<CpqChannelPrice[]>([])
const loading = ref(false)
const dialog = reactive({ visible: false, isEdit: false })
const form = reactive<ChannelPriceForm>({ channelCode: '', modelId: 0, channelListPrice: 0, channelDiscountPct: undefined, effectiveDate: today(), expiryDate: '', status: '0' })

// 模型名称缓存（用于列表展示）
const modelCache = ref<Map<number, string>>(new Map())
const modelLabel = (modelId: number) => modelCache.value.get(modelId) || `#${modelId}`

// 产品/变体选择
const configType = ref<string | null>(null)

const onModelSelected = (model: CpqProductModelVo) => {
  modelCache.value.set(model.modelId, `${model.modelCode} - ${model.modelName}`)
  form.variantId = undefined
  configType.value = model.configType
}

const onModelCleared = () => {
  form.variantId = undefined
  configType.value = null
}

const onVariantSelected = (variant: CpqProductVariantVo) => {
  form.channelListPrice = variant.basePrice || form.channelListPrice
}

// ---- 预加载模型名称 ----
const preloadModelNames = (modelIds: number[]) => {
  const ids = modelIds.filter(id => id && !modelCache.value.has(id))
  if (ids.length > 0) {
    request.get('/cpq/product/model/listByIds', { params: { ids: ids.join(',') } }).then((models: any[]) => {
      (models || []).forEach((m: any) => modelCache.value.set(m.modelId, `${m.modelCode} - ${m.modelName}`))
    }).catch(() => { /* 后台暂未实现 */ })
  }
}

const load = async () => {
  loading.value = true
  try {
    const data = await getChannelPriceList()
    list.value = Array.isArray(data) ? data : (data?.rows || [])
    preloadModelNames(list.value.map(e => e.modelId))
  } finally { loading.value = false }
}

const onAdd = () => {
  Object.assign(form, { channelCode: '', modelId: 0, variantId: undefined, channelListPrice: 0, channelDiscountPct: undefined, effectiveDate: today(), expiryDate: '', status: '0' })
  configType.value = null
  dialog.isEdit = false; dialog.visible = true
}

const onEdit = (row: CpqChannelPrice) => {
  Object.assign(form, row)
  configType.value = null
  dialog.isEdit = true; dialog.visible = true
}

const submit = async () => {
  if (!form.expiryDate) form.expiryDate = undefined as any
  try {
    await (dialog.isEdit ? updateChannelPrice(form) : addChannelPrice(form))
    dialog.visible = false
    ElMessage.success(dialog.isEdit ? '修改成功' : '新增成功')
    load()
  } catch (e: any) { ElMessage.error(e?.message || '操作失败') }
}

const onDelete = async (row: CpqChannelPrice) => {
  try {
    await ElMessageBox.confirm('确定删除该渠道价格？')
    await deleteChannelPrice(row.channelPriceId!)
    ElMessage.success('删除成功')
    load()
  } catch { /* cancelled */ }
}

onMounted(load)
</script>

<style scoped lang="scss">
.page-header { margin-bottom: 20px; h2 { font-size: 20px; } .subtitle { color: var(--cpq-text-secondary); font-size: 13px; } }
.card-header { display: flex; justify-content: space-between; align-items: center; }
</style>
