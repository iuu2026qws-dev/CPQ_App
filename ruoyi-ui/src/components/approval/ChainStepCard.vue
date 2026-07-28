<template>
  <el-card shadow="hover" class="chain-step-card">
    <template #header>
      <div style="display: flex; align-items: center; justify-content: space-between">
        <span>步骤 {{ step.step }}</span>
        <el-button link type="danger" icon="Delete" @click="$emit('remove', index)">删除</el-button>
      </div>
    </template>

    <el-form label-width="100px" :model="localStep">
      <el-form-item label="审批类型">
        <el-radio-group
          v-model="localStep.type"
          @change="handleTypeChange"
        >
          <el-radio-button value="SERIAL">串行</el-radio-button>
          <el-radio-button value="PARALLEL">并行</el-radio-button>
        </el-radio-group>
      </el-form-item>

      <el-form-item v-if="localStep.type === 'PARALLEL'" label="最少通过人数">
        <el-input-number
          v-model="localStep.minApprovals"
          :min="1"
          :max="localStep.approverIds.length || 1"
          controls-position="right"
          style="width: 200px"
        />
        <span style="margin-left: 8px; color: #909399; font-size: 12px">
          已选 {{ localStep.approverIds?.length || 0 }} 人
        </span>
      </el-form-item>

      <el-form-item label="审批人">
        <UserSelect v-model="localStep.approverIds" />
      </el-form-item>

      <el-form-item label="审批角色">
        <el-select
          v-model="localStep.approverRole"
          filterable
          remote
          reserve-keyword
          placeholder="输入角色名称搜索"
          :remote-method="searchRolesRemote"
          :loading="roleSearchLoading"
          clearable
          style="width: 100%"
        >
          <el-option
            v-for="item in roleOptions"
            :key="item.roleId"
            :label="item.roleName"
            :value="item.roleName"
          />
        </el-select>
      </el-form-item>
    </el-form>
  </el-card>
</template>

<script setup lang="ts">
import { ref, reactive, watch } from 'vue'
import { searchRoles } from '@/api/cpq/approval'
import UserSelect from './UserSelect.vue'

interface StepData {
  step: number
  approverRole: string
  approverIds: number[]
  type: string
  minApprovals?: number
}

interface Props {
  step: StepData
  index: number
  isLast: boolean
}

const props = defineProps<Props>()

const emit = defineEmits<{
  remove: [index: number]
  update: [step: StepData]
}>()

const localStep = reactive<StepData>({ ...props.step })
const roleSearchLoading = ref(false)
const roleOptions = ref<any[]>([])

watch(
  () => props.step,
  (newVal) => {
    Object.assign(localStep, newVal)
  },
  { deep: true }
)

watch(
  () => localStep,
  () => {
    emit('update', { ...localStep })
  },
  { deep: true }
)

const handleTypeChange = () => {
  emit('update', { ...localStep })
}

const searchRolesRemote = async (keyword: string) => {
  if (!keyword) {
    roleOptions.value = []
    return
  }
  roleSearchLoading.value = true
  try {
    const res = await searchRoles(keyword)
    roleOptions.value = (res as any).rows || (res as any).data?.rows || []
  } finally {
    roleSearchLoading.value = false
  }
}
</script>

<style scoped>
.chain-step-card {
  margin-bottom: 12px;
}
</style>
