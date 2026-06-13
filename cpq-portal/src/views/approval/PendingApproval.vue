<template>
  <div class="cpq-page">
    <h2>待审批列表</h2>
    <el-table v-loading="store.loading" :data="store.chains" stripe>
      <el-table-column prop="chainId" label="审批链ID" width="120" />
      <el-table-column prop="quoteId" label="报价单ID" width="120" />
      <el-table-column prop="currentStep" label="当前步骤" width="100">
        <template #default="{ row }">{{ row.currentStep }}/{{ row.totalSteps }}</template>
      </el-table-column>
      <el-table-column prop="status" label="状态" width="120">
        <template #default="{ row }">
          <el-tag :type="row.status === 'IN_PROGRESS' ? 'warning' : row.status === 'APPROVED' ? 'success' : 'info'">{{ row.status }}</el-tag>
        </template>
      </el-table-column>
      <el-table-column prop="submittedTime" label="提交时间" width="160" />
      <el-table-column label="操作" width="150">
        <template #default="{ row }">
          <el-button size="small" type="primary" @click="$router.push('/approval/' + row.chainId)">查看</el-button>
        </template>
      </el-table-column>
    </el-table>
  </div>
</template>

<script setup lang="ts">
import { onMounted } from 'vue'
import { useApprovalStore } from '@/store/approval'

const store = useApprovalStore()

onMounted(() => { store.fetchChains() })
</script>

<style scoped>
.cpq-page { padding: 16px; }
</style>
