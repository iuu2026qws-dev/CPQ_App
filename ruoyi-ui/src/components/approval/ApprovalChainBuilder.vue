<template>
  <div>
    <div v-if="!modelValue || modelValue.length === 0" style="text-align: center; padding: 20px; color: #909399">
      暂无审批步骤，请点击下方按钮添加
    </div>

    <div v-for="(step, index) in modelValue" :key="index" style="position: relative">
      <ChainStepCard
        :step="step"
        :index="index"
        :is-last="index === modelValue.length - 1"
        @remove="handleRemove(index)"
        @update="(updated: any) => handleUpdate(index, updated)"
      />

      <!-- Arrow between steps -->
      <div v-if="index < modelValue.length - 1" style="text-align: center; padding: 4px 0 12px 0">
        <div style="display: flex; align-items: center; justify-content: center; gap: 8px">
          <span style="color: #409eff; font-size: 20px">&#8595;</span>
        </div>
      </div>

      <!-- Move buttons for reorder -->
      <div v-if="modelValue.length > 1" style="position: absolute; top: 50%; right: -50px; transform: translateY(-50%); display: flex; flex-direction: column; gap: 4px">
        <el-button
          v-if="index > 0"
          size="small"
          circle
          icon="Top"
          title="上移"
          @click="handleMoveUp(index)"
        />
        <el-button
          v-if="index < modelValue.length - 1"
          size="small"
          circle
          icon="Bottom"
          title="下移"
          @click="handleMoveDown(index)"
        />
      </div>
    </div>

    <div style="text-align: center; margin-top: 16px">
      <el-button type="primary" plain icon="Plus" @click="handleAddStep">
        添加步骤
      </el-button>
    </div>
  </div>
</template>

<script setup lang="ts">
import ChainStepCard from './ChainStepCard.vue'

interface StepData {
  step: number
  approverRole: string
  approverIds: number[]
  type: string
  minApprovals?: number
}

interface Props {
  modelValue: StepData[]
}

const props = withDefaults(defineProps<Props>(), {
  modelValue: () => []
})

const emit = defineEmits<{
  'update:modelValue': [value: StepData[]]
}>()

const handleAddStep = () => {
  const newStep: StepData = {
    step: (props.modelValue.length + 1),
    approverRole: '',
    approverIds: [],
    type: 'SERIAL',
    minApprovals: 1
  }
  const newList = [...props.modelValue, newStep]
  // 重新编号
  newList.forEach((s, i) => { s.step = i + 1 })
  emit('update:modelValue', newList)
}

const handleRemove = (index: number) => {
  const newList = props.modelValue.filter((_, i) => i !== index)
  // 重新编号
  newList.forEach((s, i) => { s.step = i + 1 })
  emit('update:modelValue', newList)
}

const handleUpdate = (index: number, updated: StepData) => {
  const newList = [...props.modelValue]
  newList[index] = updated
  emit('update:modelValue', newList)
}

const handleMoveUp = (index: number) => {
  if (index <= 0) return
  const newList = [...props.modelValue]
  ;[newList[index], newList[index - 1]] = [newList[index - 1], newList[index]]
  // 重新编号
  newList.forEach((s, i) => { s.step = i + 1 })
  emit('update:modelValue', newList)
}

const handleMoveDown = (index: number) => {
  if (index >= props.modelValue.length - 1) return
  const newList = [...props.modelValue]
  ;[newList[index], newList[index + 1]] = [newList[index + 1], newList[index]]
  // 重新编号
  newList.forEach((s, i) => { s.step = i + 1 })
  emit('update:modelValue', newList)
}
</script>

<style scoped>
</style>
