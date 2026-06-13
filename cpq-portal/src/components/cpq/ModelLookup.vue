<template>
  <el-select
    :model-value="modelValue"
    @update:model-value="onChange"
    filterable
    remote
    :remote-method="onSearch"
    :placeholder="placeholder"
    :disabled="disabled"
    :size="size"
    :clearable="clearable"
    style="width:100%"
  >
    <el-option
      v-for="m in options"
      :key="m.value"
      :label="m.label"
      :value="m.value"
    >
      <span>{{ m.modelCode }} - {{ m.modelName }}</span>
      <el-tag size="small" style="margin-left:8px" :type="configTypeTagType(m.configType)">{{ m.configType }}</el-tag>
    </el-option>
  </el-select>
</template>

<script setup lang="ts">
import { ref, watch } from 'vue'
import { searchModel, type CpqProductModelVo } from '@/api/cpq/product'

interface ModelOption {
  label: string
  value: number
  modelCode: string
  modelName: string
  configType: string
}

const props = withDefaults(defineProps<{
  modelValue: number | null
  placeholder?: string
  disabled?: boolean
  size?: 'default' | 'large' | 'small'
  clearable?: boolean
  configType?: string
}>(), {
  placeholder: '搜索产品名称或编码',
  disabled: false,
  size: 'default',
  clearable: true
})

const emit = defineEmits<{
  'update:modelValue': [value: number | null]
  'select': [model: CpqProductModelVo]
  'clear': []
}>()

const options = ref<ModelOption[]>([])
// 缓存完整模型信息，供 select 事件使用
const modelCache = ref<Map<number, CpqProductModelVo>>(new Map())

const configTypeTagType = (ct: string) => {
  switch (ct) {
    case 'STANDARD': return ''
    case 'ATO': return 'success'
    case 'CTO': case 'ETO': return 'warning'
    case 'BUNDLE': return 'info'
    default: return 'info'
  }
}

const onSearch = async (query: string) => {
  if (!query || query.length < 1) {
    options.value = []
    return
  }
  try {
    const data = await searchModel(query, props.configType)
    const list = Array.isArray(data) ? data : []
    options.value = list.map((m: CpqProductModelVo) => {
      modelCache.value.set(m.modelId, m)
      return {
        label: `${m.modelCode} - ${m.modelName}`,
        value: m.modelId,
        modelCode: m.modelCode,
        modelName: m.modelName,
        configType: m.configType
      }
    })
  } catch {
    options.value = []
  }
}

const onChange = (val: number | null) => {
  emit('update:modelValue', val)
  if (!val) {
    emit('clear')
  } else {
    const model = modelCache.value.get(val)
    if (model) {
      emit('select', model)
    }
  }
}

// 如果外部传入了一个值但 options 中没有，预加载当前值
watch(() => props.modelValue, (val) => {
  if (val && !modelCache.value.has(val) && options.value.length === 0) {
    // 尝试用 modelId 作为搜索关键词预加载
    onSearch(String(val))
  }
}, { immediate: true })
</script>
