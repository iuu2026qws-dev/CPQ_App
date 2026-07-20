<template>
  <div class="cpq-page">
    <div class="toolbar">
      <el-button @click="$router.back()">返回</el-button>
      <el-button type="primary" @click="$router.push('/approval/history')">审批历史</el-button>
    </div>

    <!-- 审批链基本描述 -->
    <el-descriptions v-if="store.currentChain" :column="2" border>
      <el-descriptions-item label="审批链ID">{{ store.currentChain.chainId }}</el-descriptions-item>
      <el-descriptions-item label="报价单ID">{{ store.currentChain.quoteId }}</el-descriptions-item>
      <el-descriptions-item label="当前步骤">{{ store.currentChain.currentStep }}/{{ store.currentChain.totalSteps }}</el-descriptions-item>
      <el-descriptions-item label="SLA">{{ store.currentChain.slaHours }}小时</el-descriptions-item>
      <el-descriptions-item label="状态">
        <el-tag>{{ store.currentChain.status }}</el-tag>
      </el-descriptions-item>
      <el-descriptions-item label="提交时间">{{ store.currentChain.submittedTime }}</el-descriptions-item>
    </el-descriptions>

    <!-- 审批链节点可视化 -->
    <h3 style="margin-top:20px">审批流程</h3>
    <ApprovalNode
      v-if="approvalNodes.length > 0"
      :nodes="approvalNodes"
      :current-step="store.currentChain?.currentStep || 1"
      :is-rejected="store.currentChain?.status === 'REJECTED'"
    />

    <!-- 审批操作 -->
    <ApprovalAction
      v-if="store.currentChain"
      :chain-id="store.currentChain.chainId!"
      :chain-status="store.currentChain.status!"
      :current-step="store.currentChain.currentStep || 1"
      :total-steps="store.currentChain.totalSteps || 1"
      :approver="store.records.length > 0 ? store.records[store.records.length - 1]?.approverName : undefined"
      @action-completed="handleActionCompleted"
    />

    <!-- 审批记录时间线 -->
    <h3 style="margin-top:20px">审批记录</h3>
    <el-timeline>
      <el-timeline-item v-for="r in store.records" :key="r.recordId" :timestamp="r.actionTime" placement="top">
        <el-card>
          <p><strong>{{ r.approverName }}</strong> — {{ actionLabel(r.action || '') }}</p>
          <p v-if="r.comment" style="color:#666">{{ r.comment }}</p>
        </el-card>
      </el-timeline-item>
    </el-timeline>
  </div>
</template>

<script setup lang="ts">
import { computed, onMounted } from 'vue'
import { useRoute } from 'vue-router'
import { useApprovalStore } from '@/store/approval'
import ApprovalNode from '@/components/approval/ApprovalNode.vue'
import type { ApprovalNodeData } from '@/components/approval/ApprovalNode.vue'
import ApprovalAction from '@/components/approval/ApprovalAction.vue'

const route = useRoute()
const store = useApprovalStore()

function actionLabel(a: string) {
  const m: Record<string, string> = { APPROVE: '批准', CONDITIONAL_APPROVE: '条件通过', REJECT: '驳回', TRANSFER: '转审', DELEGATE: '委托', ADD_SIGNER: '加签' }
  return m[a] || a
}

// 从审批链和记录构建可视化节点
const approvalNodes = computed<ApprovalNodeData[]>(() => {
  if (!store.currentChain) return []
  const nodes: ApprovalNodeData[] = []
  for (let i = 1; i <= (store.currentChain.totalSteps || 1); i++) {
    const rec = store.records.find(r => r.stepNumber === i)
    nodes.push({
      title: `第${i}步审批`,
      role: i === 1 ? '部门经理' : i === 2 ? '总监' : i === 3 ? 'VP' : '审批人',
      approverName: rec?.approverName,
      status: rec ? (rec.action === 'APPROVE' ? 'APPROVED' : rec.action === 'REJECT' ? 'REJECTED' : 'APPROVED') : (i === store.currentChain!.currentStep ? 'PENDING' : undefined),
      actionTime: rec?.actionTime,
      comment: rec?.comment,
    })
  }
  return nodes
})

async function handleActionCompleted() {
  if (store.currentChain?.chainId) {
    await store.fetchChain(store.currentChain.chainId)
    await store.fetchRecords(store.currentChain.chainId)
  }
}

onMounted(async () => {
  const chainId = String(route.params.id)
  if (chainId) { await store.fetchChain(chainId); await store.fetchRecords(chainId) }
})
</script>

<style scoped>
.cpq-page { padding: 16px; }
.toolbar { margin-bottom: 12px; }
</style>
