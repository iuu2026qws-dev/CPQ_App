<template>
  <div class="atp-indicator" :class="{ available: available, unavailable: !available }">
    <span class="indicator-dot"></span>
    <span class="indicator-text">{{ available ? 'ATP 可承诺' : 'ATP 不可承诺' }}</span>
    <el-tooltip placement="top">
      <template #content>
        <div>需求量：{{ quantity }}</div>
        <div>状态：{{ available ? '三级检查全部通过' : '存在瓶颈' }}</div>
      </template>
      <el-icon class="info-icon"><QuestionFilled /></el-icon>
    </el-tooltip>
  </div>
</template>

<script setup lang="ts">
defineProps<{ available: boolean; quantity: number }>()
</script>

<style scoped>
.atp-indicator { display:inline-flex; align-items:center; gap:8px; padding:8px 16px; border-radius:6px; font-size:14px; font-weight:bold; }
.atp-indicator.available { background:#f0f9eb; color:#67c23a; border:1px solid #c2e7b0; }
.atp-indicator.unavailable { background:#fef0f0; color:#f56c6c; border:1px solid #fbc4c4; }
.indicator-dot { width:12px; height:12px; border-radius:50%; display:inline-block; }
.available .indicator-dot { background:#67c23a; }
.unavailable .indicator-dot { background:#f56c6c; }
.info-icon { cursor:pointer; color:#909399; }
</style>
