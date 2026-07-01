<template>
  <div class="order-line-editor">
    <el-row :gutter="12">
      <el-col :span="5">
        <el-input-number
          :model-value="modelValue.quantity"
          :min="1"
          placeholder="数量"
          controls-position="right"
          size="small"
          @update:model-value="updateField('quantity', $event)"
        />
      </el-col>
      <el-col :span="6">
        <el-input-number
          :model-value="modelValue.unitPrice"
          :min="0"
          :precision="2"
          placeholder="单价"
          controls-position="right"
          size="small"
          @update:model-value="updateField('unitPrice', $event)"
        />
      </el-col>
      <el-col :span="6">
        <el-input-number
          :model-value="modelValue.discountPct"
          :min="0"
          :max="100"
          placeholder="折扣%"
          controls-position="right"
          size="small"
          @update:model-value="updateField('discountPct', $event)"
        />
      </el-col>
      <el-col :span="5">
        <el-input-number
          :model-value="modelValue.taxRate"
          :min="0"
          :max="100"
          placeholder="税率%"
          controls-position="right"
          size="small"
          @update:model-value="updateField('taxRate', $event)"
        />
      </el-col>
      <el-col :span="2" style="text-align: right; line-height: 32px; font-weight: bold">
        {{ formattedAmount }}
      </el-col>
    </el-row>
  </div>
</template>

<script setup lang="ts">
import { computed } from 'vue'
import type { OrderLineBo } from '@/api/cpq/crm'

const props = defineProps<{
  modelValue: OrderLineBo
}>()

const emit = defineEmits<{
  (e: 'update:modelValue', v: OrderLineBo): void
}>()

const lineAmount = computed(() => {
  const qty = props.modelValue.quantity || 0
  const price = props.modelValue.unitPrice || 0
  const discount = props.modelValue.discountPct || 0
  return Math.round(qty * price * (1 - discount / 100) * 100) / 100
})

const formattedAmount = computed(() => {
  return '¥' + lineAmount.value.toLocaleString('zh-CN', { minimumFractionDigits: 2 })
})

function updateField(field: string, value: any) {
  const updated = { ...props.modelValue, [field]: value || 0 }
  // auto-calc lineAmount
  updated.lineAmount = Math.round((updated.quantity || 0) * (updated.unitPrice || 0) * (1 - (updated.discountPct || 0) / 100) * 100) / 100
  emit('update:modelValue', updated)
}
</script>

<style scoped>
.order-line-editor {
  padding: 2px 0;
}
</style>
