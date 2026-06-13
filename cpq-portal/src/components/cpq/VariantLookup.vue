<template>
  <div v-if="show">
    <el-select
      v-if="showSelector"
      :model-value="modelValue"
      @update:model-value="onChange"
      :placeholder="placeholder"
      :disabled="disabled || isEmpty"
      :size="size"
      clearable
      style="width:100%"
    >
      <el-option
        v-for="v in variants"
        :key="v.variantId"
        :label="`${v.variantCode} - ${v.variantName}`"
        :value="v.variantId"
      >
        <span>{{ v.variantCode }} - {{ v.variantName }}</span>
        <el-tag v-if="v.isDefault === '1'" size="small" type="success" style="margin-left:8px">默认</el-tag>
        <span style="margin-left:8px;color:#999">¥{{ v.basePrice }}</span>
      </el-option>
      <template #empty>
        <div style="padding:12px;text-align:center">
          <p v-if="isEmpty" style="color:#999">该产品尚未定义变体，请先在产品模型中创建变体</p>
          <p v-else style="color:#999">暂无变体数据</p>
        </div>
      </template>
    </el-select>
    <div v-else class="variant-hint">
      ⓘ {{ hintText }}
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, watch, onMounted } from 'vue'
import { getVariantList, type CpqProductVariantVo } from '@/api/cpq/variant'

const props = withDefaults(defineProps<{
  modelValue: number | null
  modelId: number | null
  configType: string | null   // 由父组件从 ModelLookup select 事件中获取
  required?: boolean
  disabled?: boolean
  placeholder?: string
  size?: 'default' | 'large' | 'small'
}>(), {
  required: false,
  disabled: false,
  placeholder: '请选择变体',
  size: 'default'
})

const emit = defineEmits<{
  'update:modelValue': [value: number | null]
  'select': [variant: CpqProductVariantVo]
}>()

const variants = ref<CpqProductVariantVo[]>([])
const loading = ref(false)

// 是否显示变体选择区域
const show = computed(() => {
  return !!props.modelId
})

// 是否显示选择器（STANDARD/ATO 显示，CTO/ETO/BUNDLE 隐藏）
const showSelector = computed(() => {
  if (!props.configType) return false
  return props.configType === 'STANDARD' || props.configType === 'ATO'
})

// 变体列表为空
const isEmpty = computed(() => {
  return variants.value.length === 0 && !loading.value
})

// 提示文字
const hintText = computed(() => {
  if (!props.configType) return ''
  switch (props.configType) {
    case 'CTO': return 'CTO产品通过定价规则计算配置后的价格'
    case 'ETO': return 'ETO产品为定制报价，价格在报价时确定'
    case 'BUNDLE': return '捆绑包通过组件选择和定价规则确定价格'
    default: return ''
  }
})

const loadVariants = async () => {
  if (!props.modelId || !showSelector.value) {
    variants.value = []
    return
  }
  loading.value = true
  try {
    const data = await getVariantList(props.modelId)
    variants.value = Array.isArray(data) ? data : []
  } catch {
    variants.value = []
  } finally {
    loading.value = false
  }
}

const onChange = (val: number | null) => {
  emit('update:modelValue', val)
  if (val) {
    const variant = variants.value.find(v => v.variantId === val)
    if (variant) {
      emit('select', variant)
    }
  }
}

// 监听 modelId 变化重新加载变体
watch(() => props.modelId, () => {
  emit('update:modelValue', null)
  loadVariants()
})
</script>

<style scoped lang="scss">
.variant-hint {
  padding: 8px 12px;
  background: #f0f9ff;
  border: 1px dashed #93c5fd;
  border-radius: 4px;
  color: #6b7280;
  font-size: 13px;
  line-height: 1.5;
}
</style>
