<template>
  <div class="approval-actions">
    <el-card shadow="never">
      <template #header>
        <span class="action-title">审批操作</span>
      </template>

      <!-- 当前审批步骤信息 -->
      <div class="current-step-info">
        <el-descriptions :column="1" border size="small">
          <el-descriptions-item label="当前步骤">{{ currentStep }} / {{ totalSteps }}</el-descriptions-item>
          <el-descriptions-item label="审批人">{{ approver || currentApprover }}</el-descriptions-item>
          <el-descriptions-item label="状态">
            <el-tag :type="chainStatusTag" size="small">{{ chainStatusLabel }}</el-tag>
          </el-descriptions-item>
        </el-descriptions>
      </div>

      <!-- 待审批态：显示操作按钮 -->
      <div v-if="canApprove" class="action-buttons">
        <el-input
          v-model="comment"
          type="textarea"
          :rows="3"
          placeholder="审批意见（可选）"
          maxlength="500"
          show-word-limit
          class="comment-input"
        />

        <div class="button-group">
          <el-button type="success" :loading="submitting" @click="handleAction('APPROVE')">
            <el-icon><CircleCheck /></el-icon> 通过
          </el-button>
          <el-button type="warning" :loading="submitting" @click="handleAction('CONDITIONAL_APPROVE')">
            <el-icon><Warning /></el-icon> 条件通过
          </el-button>
          <el-button type="danger" :loading="submitting" @click="showRejectDialog = true">
            <el-icon><CircleClose /></el-icon> 驳回
          </el-button>
          <el-button :loading="submitting" @click="showTransferDialog = true">
            <el-icon><Share /></el-icon> 转审
          </el-button>
          <el-button :loading="submitting" @click="showAddSignerDialog = true">
            <el-icon><UserFilled /></el-icon> 加签
          </el-button>
        </div>
      </div>

      <!-- 已完成态：显示结果 -->
      <div v-else class="result-display">
        <el-result
          v-if="chainStatus === 'APPROVED'"
          icon="success"
          title="审批已通过"
          :sub-title="'审批链已完成，共' + totalSteps + '个步骤'"
        />
        <el-result
          v-else-if="chainStatus === 'REJECTED'"
          icon="error"
          title="审批已驳回"
          sub-title="该审批链已被驳回，报价单需要修改后重新提交"
        />
        <el-result
          v-else-if="chainStatus === 'EXPIRED'"
          icon="warning"
          title="审批已过期"
          sub-title="审批链已超时，SLA 窗口已关闭"
        />
        <el-result
          v-else
          icon="info"
          title="待审批"
          sub-title="请等待上一级审批完成后操作"
        />
      </div>
    </el-card>

    <!-- 驳回确认弹窗 -->
    <el-dialog v-model="showRejectDialog" title="驳回确认" width="450px" append-to-body>
      <el-form label-width="80px">
        <el-form-item label="驳回原因" required>
          <el-input v-model="rejectReason" type="textarea" :rows="4" placeholder="请输入驳回原因（必填）" maxlength="500" show-word-limit />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="showRejectDialog = false">取消</el-button>
        <el-button type="danger" :disabled="!rejectReason.trim()" :loading="submitting" @click="handleReject">确认驳回</el-button>
      </template>
    </el-dialog>

    <!-- 转审弹窗 -->
    <el-dialog v-model="showTransferDialog" title="转审" width="400px" append-to-body>
      <el-form label-width="80px">
        <el-form-item label="转审人" required>
          <el-input v-model="transferTo" placeholder="请输入转审人姓名" />
        </el-form-item>
        <el-form-item label="转审原因">
          <el-input v-model="transferReason" type="textarea" :rows="2" placeholder="转审原因（可选）" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="showTransferDialog = false">取消</el-button>
        <el-button type="primary" :disabled="!transferTo.trim()" :loading="submitting" @click="handleTransfer">确认转审</el-button>
      </template>
    </el-dialog>

    <!-- 加签弹窗 -->
    <el-dialog v-model="showAddSignerDialog" title="加签" width="400px" append-to-body>
      <el-form label-width="80px">
        <el-form-item label="加签人" required>
          <el-input v-model="addSignerTo" placeholder="请输入加签人姓名" />
        </el-form-item>
        <el-form-item label="加签原因">
          <el-input v-model="addSignerReason" type="textarea" :rows="2" placeholder="加签原因（可选）" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="showAddSignerDialog = false">取消</el-button>
        <el-button type="primary" :disabled="!addSignerTo.trim()" :loading="submitting" @click="handleAddSigner">确认加签</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue'
import { ElMessage } from 'element-plus'
import { CircleCheck, Warning, CircleClose, Share, UserFilled } from '@element-plus/icons-vue'
import request from '@/utils/request'

const props = defineProps<{
  chainId: number
  chainStatus: string       // IN_PROGRESS / APPROVED / REJECTED / CANCELLED / EXPIRED
  currentStep: number
  totalSteps: number
  approver?: string
  approverId?: number
  currentApprover?: string  // 从链数据获取当前步骤审批人
}>()

const emit = defineEmits<{ 'action-completed': [] }>()

const submitting = ref(false)
const comment = ref('')

// 驳回
const showRejectDialog = ref(false)
const rejectReason = ref('')

// 转审
const showTransferDialog = ref(false)
const transferTo = ref('')
const transferReason = ref('')

// 加签
const showAddSignerDialog = ref(false)
const addSignerTo = ref('')
const addSignerReason = ref('')

const canApprove = computed(() => props.chainStatus === 'IN_PROGRESS')
const chainStatusLabel = computed(() => {
  const m: Record<string, string> = { IN_PROGRESS: '审批中', APPROVED: '已通过', REJECTED: '已驳回', CANCELLED: '已取消', EXPIRED: '已过期' }
  return m[props.chainStatus] || props.chainStatus
})
const chainStatusTag = computed(() => {
  const m: Record<string, '' | 'success' | 'warning' | 'danger' | 'info'> = { IN_PROGRESS: 'warning', APPROVED: 'success', REJECTED: 'danger', CANCELLED: 'info', EXPIRED: 'danger' }
  return m[props.chainStatus] || 'info'
})

async function submitAction(action: string, actionComment: string) {
  submitting.value = true
  try {
    await request.post('/cpq/approval/action/process', {
      chainId: props.chainId,
      approverId: props.approverId || 1,
      approverName: props.approver || props.currentApprover || '当前用户',
      action,
      comment: actionComment
    })
    ElMessage.success('操作成功')
    emit('action-completed')
  } catch (e: any) {
    ElMessage.error(e?.message || '操作失败')
  } finally {
    submitting.value = false
  }
}

async function handleAction(action: string) {
  await submitAction(action, comment.value)
  comment.value = ''
}

async function handleReject() {
  if (!rejectReason.value.trim()) return
  await submitAction('REJECT', rejectReason.value)
  showRejectDialog.value = false
  rejectReason.value = ''
}

async function handleTransfer() {
  const reason = transferReason.value || '转审给 ' + transferTo.value
  await submitAction('TRANSFER', reason)
  showTransferDialog.value = false
  transferTo.value = ''
  transferReason.value = ''
}

async function handleAddSigner() {
  const reason = addSignerReason.value || '加签：' + addSignerTo.value
  await submitAction('ADD_SIGNER', reason)
  showAddSignerDialog.value = false
  addSignerTo.value = ''
  addSignerReason.value = ''
}
</script>

<style scoped>
.approval-actions { margin-top: 12px; }
.action-title { font-weight: 500; font-size: 15px; }
.current-step-info { margin-bottom: 16px; }
.comment-input { margin-bottom: 16px; }
.button-group { display: flex; gap: 8px; flex-wrap: wrap; }
.result-display { padding: 20px 0; }
</style>
