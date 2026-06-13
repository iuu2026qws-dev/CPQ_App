<template>
  <div class="approval-chain-viz">
    <!-- 审批链流程可视化 -->
    <div class="chain-flow">
      <div
        v-for="(node, index) in nodes"
        :key="index"
        class="flow-node-wrapper"
      >
        <!-- 连接线 -->
        <div
          v-if="index > 0"
          class="flow-connector"
          :class="{
            'connector-active': index <= currentStep,
            'connector-pending': index > currentStep,
            'connector-rejected': isRejected && index === currentStep
          }"
        >
          <div class="connector-line"></div>
          <div class="connector-arrow"></div>
        </div>

        <!-- 审批节点 -->
        <div
          class="flow-node"
          :class="nodeClass(node, index)"
        >
          <!-- 节点形状：圆形 + 图标 -->
          <div class="node-icon" :style="{ background: nodeBg(node, index) }">
            <el-icon :size="18" color="#fff">
              <CircleCheck v-if="index < (currentStep || 0)" />
              <Clock v-else-if="index === (currentStep || 0) && !isRejected" />
              <CircleClose v-else-if="isRejected && index === (currentStep || 0)" />
              <More v-else />
            </el-icon>
          </div>

          <!-- 节点信息 -->
          <div class="node-info">
            <div class="node-title">{{ node.title }}</div>
            <div class="node-role">{{ node.role }}</div>
            <div v-if="node.approverName" class="node-approver">{{ node.approverName }}</div>

            <!-- 节点状态标签 -->
            <el-tag
              v-if="node.status"
              :type="nodeStatusTag(node.status)"
              size="small"
              effect="dark"
            >
              {{ nodeStatusLabel(node.status) }}
            </el-tag>

            <!-- SLA截止时间 -->
            <div v-if="node.slaDeadline && node.status === 'PENDING'" class="node-sla" :class="{ 'sla-urgent': isSlaUrgent(node.slaDeadline) }">
              <el-icon :size="12"><AlarmClock /></el-icon>
              <span>截止：{{ formatTime(node.slaDeadline) }}</span>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- 图例 -->
    <div class="legend">
      <div class="legend-item"><span class="legend-dot" style="background:#67c23a"></span>已批准</div>
      <div class="legend-item"><span class="legend-dot" style="background:#409eff"></span>审批中</div>
      <div class="legend-item"><span class="legend-dot" style="background:#f56c6c"></span>已驳回</div>
      <div class="legend-item"><span class="legend-dot" style="background:#e6a23c"></span>超时警告</div>
      <div class="legend-item"><span class="legend-dot" style="background:#dcdfe6"></span>待审批</div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { computed } from 'vue'
import { CircleCheck, Clock, CircleClose, More, AlarmClock } from '@element-plus/icons-vue'

export interface ApprovalNodeData {
  title: string        // 节点标题，如"部门经理审批"
  role: string         // 审批角色，如"部门经理"
  approverName?: string // 审批人姓名
  status?: 'APPROVED' | 'PENDING' | 'REJECTED' | 'SKIPPED' | 'TRANSFERRED'
  slaDeadline?: string  // SLA截止时间
  actionTime?: string   // 操作时间
  comment?: string       // 审批意见
}

const props = defineProps<{
  nodes: ApprovalNodeData[]
  currentStep: number     // 当前步骤（从1开始）
  isRejected?: boolean    // 审批链是否已被驳回
}>()

function nodeClass(node: ApprovalNodeData, index: number) {
  const step = index + 1  // 步骤从1开始
  return {
    'node-approved': node.status === 'APPROVED' || step < (props.currentStep || 0),
    'node-current': step === (props.currentStep || 0) && !props.isRejected,
    'node-rejected': (props.isRejected && step === props.currentStep) || node.status === 'REJECTED',
    'node-pending': step > (props.currentStep || 0) && node.status !== 'APPROVED',
    'node-transferred': node.status === 'TRANSFERRED' || node.status === 'SKIPPED',
  }
}

function nodeBg(_node: ApprovalNodeData, index: number) {
  const step = index + 1
  if (props.isRejected && step === props.currentStep) return '#f56c6c'
  if (step < (props.currentStep || 0)) return '#67c23a'
  if (step === (props.currentStep || 0)) return '#409eff'
  return '#dcdfe6'
}

function nodeStatusLabel(s: string) {
  const m: Record<string, string> = { APPROVED: '已批准', PENDING: '待审批', REJECTED: '已驳回', SKIPPED: '已跳过', TRANSFERRED: '已转审' }
  return m[s] || s
}

function nodeStatusTag(s: string) {
  const m: Record<string, '' | 'success' | 'warning' | 'danger' | 'info'> = { APPROVED: 'success', PENDING: 'warning', REJECTED: 'danger', SKIPPED: 'info', TRANSFERRED: '' }
  return m[s] || 'info'
}

function isSlaUrgent(deadline: string) {
  return new Date(deadline).getTime() < Date.now()
}

function formatTime(t: string) {
  return new Date(t).toLocaleString('zh-CN', { month: '2-digit', day: '2-digit', hour: '2-digit', minute: '2-digit' })
}
</script>

<style scoped>
.approval-chain-viz { padding: 16px 0; }
.chain-flow { display: flex; align-items: flex-start; justify-content: center; flex-wrap: wrap; gap: 0; padding: 20px 0; }
.flow-node-wrapper { display: flex; flex-direction: column; align-items: center; position: relative; }

.flow-connector { display: flex; align-items: center; position: absolute; left: -40px; top: 28px; width: 40px; }
.connector-line { flex: 1; height: 2px; background: #dcdfe6; transition: background 0.3s; }
.connector-active .connector-line { background: #67c23a; }
.connector-pending .connector-line { background: #dcdfe6; }
.connector-rejected .connector-line { background: #f56c6c; }
.connector-arrow { width: 0; height: 0; border-top: 5px solid transparent; border-bottom: 5px solid transparent; border-left: 8px solid; transition: border-color 0.3s; }
.connector-active .connector-arrow { border-left-color: #67c23a; }
.connector-pending .connector-arrow { border-left-color: #dcdfe6; }
.connector-rejected .connector-arrow { border-left-color: #f56c6c; }

.flow-node { display: flex; flex-direction: column; align-items: center; width: 140px; padding: 12px 8px; border-radius: 8px; transition: all 0.3s; margin: 0 4px; }
.node-icon { width: 36px; height: 36px; border-radius: 50%; display: flex; align-items: center; justify-content: center; transition: all 0.3s; }
.node-info { text-align: center; margin-top: 8px; }
.node-title { font-size: 13px; font-weight: 500; margin-bottom: 2px; }
.node-role { font-size: 11px; color: #909399; margin-bottom: 2px; }
.node-approver { font-size: 11px; color: #606266; margin-bottom: 4px; }
.node-sla { display: flex; align-items: center; gap: 4px; justify-content: center; font-size: 11px; color: #909399; margin-top: 4px; }
.node-sla.sla-urgent { color: #e6a23c; font-weight: 500; }

.node-approved { background: #f0f9eb; }
.node-current { background: #ecf5ff; box-shadow: 0 0 0 2px #409eff; }
.node-current .node-icon { animation: pulse 2s infinite; }
.node-rejected { background: #fef0f0; box-shadow: 0 0 0 2px #f56c6c; }
.node-pending { background: #fafafa; }
.node-transferred { opacity: 0.6; }

@keyframes pulse {
  0%, 100% { box-shadow: 0 0 0 0 rgba(64, 158, 255, 0.4); }
  50% { box-shadow: 0 0 0 6px rgba(64, 158, 255, 0); }
}

.legend { display: flex; gap: 16px; justify-content: center; margin-top: 16px; padding-top: 12px; border-top: 1px solid #ebeef5; }
.legend-item { display: flex; align-items: center; gap: 4px; font-size: 12px; color: #909399; }
.legend-dot { width: 10px; height: 10px; border-radius: 50%; display: inline-block; }
</style>
