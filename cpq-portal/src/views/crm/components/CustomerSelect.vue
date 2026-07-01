<template>
  <el-select
    :model-value="modelValue"
    :placeholder="placeholder"
    filterable
    remote
    :remote-method="remoteSearch"
    :loading="searchLoading"
    clearable
    :disabled="disabled"
    style="width: 100%"
    @update:model-value="onSelect"
    @change="onSelect"
  >
    <el-option
      v-for="item in options"
      :key="item.accountId"
      :label="item.accountName"
      :value="item.accountId"
    />
  </el-select>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { listAccounts, type AccountVo } from '@/api/cpq/crm'

const props = withDefaults(defineProps<{
  modelValue?: number | null
  placeholder?: string
  disabled?: boolean
}>(), {
  placeholder: '请选择客户',
  disabled: false
})

const emit = defineEmits<{
  (e: 'update:modelValue', v: number | null): void
}>()

const options = ref<AccountVo[]>([])
const searchLoading = ref(false)

async function remoteSearch(keyword: string) {
  searchLoading.value = true
  try {
    const res = await listAccounts({ accountName: keyword, pageSize: 50 })
    options.value = res.rows || []
  } catch {
    options.value = []
  } finally {
    searchLoading.value = false
  }
}

function onSelect(val: number | null) {
  emit('update:modelValue', val)
}

onMounted(() => {
  remoteSearch('')
})
</script>
