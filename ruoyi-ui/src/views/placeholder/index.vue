<template>
  <div class="placeholder-page">
    <el-result icon="info" title="页面建设中" :sub-title="pageTitle">
      <template #extra>
        <el-button type="primary" @click="$router.push('/dashboard')">返回首页</el-button>
      </template>
    </el-result>
  </div>
</template>

<script setup lang="ts">
import { computed } from 'vue'
import { useRoute } from 'vue-router'

const route = useRoute()
const pageTitle = computed(() => `${route.meta?.title || route.path} — 该页面功能尚未实现或组件缺失`)
</script>

<style scoped>
.placeholder-page {
  display: flex;
  justify-content: center;
  align-items: center;
  height: 100%;
  background: #fff;
  border-radius: 8px;
}
</style>
