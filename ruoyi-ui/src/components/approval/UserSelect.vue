<template>
  <el-select
    v-model="selectedIds"
    multiple
    filterable
    remote
    reserve-keyword
    placeholder="请输入关键词搜索用户或角色"
    :remote-method="handleSearch"
    :loading="loading"
    value-key="id"
    style="width: 100%"
    @change="handleChange"
  >
    <el-option
      v-for="item in options"
      :key="item.id"
      :label="item.label"
      :value="item.id"
    />
  </el-select>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import { searchUsers, searchRoles } from '@/api/cpq/approval'

interface Option {
  id: number
  label: string
  type: 'user' | 'role'
}

interface Props {
  modelValue: number[]
}

const props = withDefaults(defineProps<Props>(), {
  modelValue: () => []
})

const emit = defineEmits<{
  'update:modelValue': [value: number[]]
}>()

const loading = ref(false)
const options = ref<Option[]>([])
const selectedIds = ref<number[]>([...props.modelValue])

const handleSearch = async (keyword: string) => {
  if (!keyword || keyword.length < 1) {
    options.value = []
    return
  }
  loading.value = true
  try {
    const userOptions: Option[] = []
    const roleOptions: Option[] = []

    try {
      const userRes = await searchUsers(keyword)
      const userRows = (userRes as any).rows || (userRes as any).data?.rows || []
      userOptions.push(
        ...userRows.map((u: any) => ({
          id: u.userId,
          label: `${u.nickName || u.userName} (用户)`,
          type: 'user' as const
        }))
      )
    } catch {
      // 用户搜索失败，继续角色搜索
    }

    try {
      const roleRes = await searchRoles(keyword)
      const roleRows = (roleRes as any).rows || (roleRes as any).data?.rows || []
      roleOptions.push(
        ...roleRows.map((r: any) => ({
          id: r.roleId,
          label: `${r.roleName} (角色)`,
          type: 'role' as const
        }))
      )
    } catch {
      // 角色搜索失败
    }

    options.value = [...userOptions, ...roleOptions]
  } finally {
    loading.value = false
  }
}

const handleChange = (val: number[]) => {
  emit('update:modelValue', val)
}

// 同步外部变化
import { watch } from 'vue'
watch(
  () => props.modelValue,
  (newVal) => {
    selectedIds.value = [...newVal]
  }
)
</script>
