<template>
  <div class="mobile-approval">
    <div class="approval-header">
      <span class="approval-count">待审批 {{ approvals.length }} 项</span>
    </div>

    <!-- 审批卡片滑动 -->
    <div v-if="loading" class="loading-state">
      <el-icon class="loading-icon" :size="32"><Loading /></el-icon>
      <span>加载中...</span>
    </div>

    <div v-else-if="approvals.length === 0" class="empty-state">
      <el-icon :size="48" color="#ddd"><Checked /></el-icon>
      <span>没有待审批项</span>
    </div>

    <div v-else class="approval-stack">
      <div
        v-for="record in approvals"
        :key="record.recordId"
        class="approval-card"
        :class="swipeState[record.recordId]"
        @touchstart="onTouchStart($event, record)"
        @touchmove="onTouchMove($event, record)"
        @touchend="onTouchEnd($event, record)"
      >
        <!-- 滑动操作背景 -->
        <div class="swipe-bg">
          <div class="swipe-reject">驳回</div>
          <div class="swipe-approve">通过</div>
        </div>

        <!-- 卡片内容 -->
        <div class="card-content">
          <div class="card-header-row">
            <span class="card-type">{{ record.approvalType || '报价审批' }}</span>
            <span class="card-urgency" :class="record.urgency">{{ record.urgency || 'NORMAL' }}</span>
          </div>
          <div class="card-title">{{ record.title || record.quoteNumber || '审批单' }}</div>
          <div class="card-info">
            <span>{{ record.submitter || record.createBy }}</span>
            <span class="card-time">{{ formatTime(record.createTime) }}</span>
          </div>
          <div class="card-actions">
            <button class="btn-reject" @click.stop="handleReject(record)">
              <el-icon><Close /></el-icon> 驳回
            </button>
            <button class="btn-approve" @click.stop="handleApprove(record)">
              <el-icon><Check /></el-icon> 通过
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- 确认弹窗 -->
    <div v-if="confirmVisible" class="confirm-overlay" @click="confirmVisible = false">
      <div class="confirm-dialog" @click.stop>
        <h4>{{ confirmIsApprove ? '确认通过' : '确认驳回' }}</h4>
        <el-input
          v-model="confirmComment"
          type="textarea"
          :rows="2"
          :placeholder="confirmIsApprove ? '审批意见（可选）' : '驳回原因'"
        />
        <div class="confirm-buttons">
          <button class="cancel-btn" @click="confirmVisible = false">取消</button>
          <button
            class="confirm-btn"
            :class="confirmIsApprove ? 'approve' : 'reject'"
            @click="submitDecision"
          >确认</button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, inject } from 'vue'
import { Loading, Checked, Close, Check } from '@element-plus/icons-vue'
import { useUserStore } from '@/store/user'

const userStore = useUserStore()
const haptic = inject<(style: string) => void>('haptic')
const showToast = inject<(msg: string, type: string) => void>('showToast')

const loading = ref(true)
const approvals = ref<any[]>([])
const swipeState = ref<Record<string, string>>({})
const touchStartX = ref(0)
const touchCurrentX = ref(0)

const confirmVisible = ref(false)
const confirmIsApprove = ref(false)
const confirmComment = ref('')
const currentRecord = ref<any>(null)

function formatTime(v: string): string {
  if (!v) return '—'
  return v.substring(5, 16).replace('T', ' ')
}

function onTouchStart(e: TouchEvent, record: any) {
  touchStartX.value = e.touches[0].clientX
}

function onTouchMove(e: TouchEvent, record: any) {
  const delta = e.touches[0].clientX - touchStartX.value
  if (Math.abs(delta) > 10) {
    const key = record.recordId
    if (delta < -30) swipeState.value[key] = 'swiped-left'
    else if (delta > 30) swipeState.value[key] = 'swiped-right'
  }
}

function onTouchEnd(_e: TouchEvent, record: any) {
  const key = record.recordId
  if (swipeState.value[key] === 'swiped-left') {
    haptic?.('medium')
    handleReject(record)
  } else if (swipeState.value[key] === 'swiped-right') {
    haptic?.('medium')
    handleApprove(record)
  }
  swipeState.value[key] = ''
}

function handleApprove(record: any) {
  haptic?.('heavy')
  currentRecord.value = record
  confirmIsApprove.value = true
  confirmComment.value = ''
  confirmVisible.value = true
}

function handleReject(record: any) {
  haptic?.('heavy')
  currentRecord.value = record
  confirmIsApprove.value = false
  confirmComment.value = ''
  confirmVisible.value = true
}

async function submitDecision() {
  if (!currentRecord.value) return
  if (!confirmIsApprove.value && !confirmComment.value.trim()) {
    showToast?.('请输入驳回原因', 'warning')
    return
  }
  confirmVisible.value = false
  try {
    const token = userStore.token
    const r = await fetch('/api/cpq/approval/action/process', {
      method: 'POST',
      headers: { Authorization: `Bearer ${token}`, clientid: 'e5cd7e4891bf95d1d19206ce24a7b32e', 'Content-Type': 'application/json' },
      body: JSON.stringify({
        recordId: currentRecord.value.recordId,
        action: confirmIsApprove.value ? 'APPROVE' : 'REJECT',
        comment: confirmComment.value || undefined
      })
    })
    const data = await r.json()
    if (data.code === 200) {
      showToast?.(confirmIsApprove.value ? '已通过' : '已驳回', 'success')
      approvals.value = approvals.value.filter(a => a.recordId !== currentRecord.value.recordId)
    } else {
      showToast?.(data.msg || '操作失败', 'error')
    }
  } catch {
    showToast?.('网络错误', 'error')
  }
  currentRecord.value = null
}

onMounted(async () => {
  try {
    const token = userStore.token
    const r = await fetch('/api/cpq/approval/record/list?pageNum=1&pageSize=20', {
      headers: { Authorization: `Bearer ${token}`, clientid: 'e5cd7e4891bf95d1d19206ce24a7b32e' }
    })
    const data = await r.json()
    if (data.code === 200 && data.data) {
      approvals.value = (data.data.rows || data.data || []).filter((a: any) => a.status === 'PENDING')
    }
  } catch { /* silent */ } finally { loading.value = false }
})
</script>

<style scoped>
.mobile-approval { padding: 12px 16px; min-height: 100%; }
.approval-header { display: flex; justify-content: space-between; margin-bottom: 14px; }
.approval-count { font-size: 15px; font-weight: 600; color: #333; }

.loading-state, .empty-state {
  display: flex; flex-direction: column; align-items: center;
  padding: 48px 0; color: #bbb; font-size: 14px; gap: 8px;
}

.approval-card {
  position: relative;
  margin-bottom: 12px;
  border-radius: 12px;
  overflow: hidden;
  box-shadow: 0 2px 6px rgba(0,0,0,0.06);
}

.swipe-bg {
  position: absolute; inset: 0;
  display: flex; justify-content: space-between;
}
.swipe-reject  { background: #f56c6c; color: #fff; display: flex; align-items: center; padding-left: 20px; width: 80px; font-weight: 600; }
.swipe-approve { background: #67c23a; color: #fff; display: flex; align-items: center; justify-content: flex-end; padding-right: 20px; width: 80px; font-weight: 600; }

.card-content {
  background: #fff; padding: 14px;
  position: relative; z-index: 1;
  transition: transform 0.25s;
}
.swiped-left  .card-content { transform: translateX(-80px); }
.swiped-right .card-content { transform: translateX(80px); }

.card-header-row { display: flex; justify-content: space-between; margin-bottom: 6px; }
.card-type    { font-size: 13px; color: #666; }
.card-urgency { font-size: 11px; padding: 2px 8px; border-radius: 10px; }
.card-urgency.URGENT { background: #fff1f0; color: #f56c6c; }
.card-urgency.NORMAL { background: #f0f0f0; color: #999; }

.card-title { font-size: 15px; font-weight: 600; color: #1a1a1a; margin-bottom: 4px; }
.card-info  { font-size: 12px; color: #bbb; display: flex; justify-content: space-between; margin-bottom: 10px; }
.card-time  { color: #ccc; }

.card-actions { display: flex; gap: 10px; }
.card-actions button {
  flex: 1; height: 36px; border: none; border-radius: 8px;
  font-size: 13px; font-weight: 600; cursor: pointer;
  display: flex; align-items: center; justify-content: center; gap: 4px;
}
.btn-reject  { background: #fff1f0; color: #f56c6c; }
.btn-approve { background: #f6ffed; color: #67c23a; }

.confirm-overlay {
  position: fixed; inset: 0; background: rgba(0,0,0,0.4);
  display: flex; align-items: flex-end; justify-content: center; z-index: 500;
}
.confirm-dialog {
  background: #fff; border-radius: 16px 16px 0 0;
  padding: 20px; width: 100%; max-width: 430px;
}
.confirm-dialog h4 { margin: 0 0 12px; font-size: 16px; }
.confirm-dialog :deep(.el-textarea__inner) { border-radius: 8px; }

.confirm-buttons {
  display: flex; gap: 10px; margin-top: 14px;
}
.confirm-buttons button {
  flex: 1; height: 42px; border: none; border-radius: 10px;
  font-size: 15px; font-weight: 600; cursor: pointer;
}
.cancel-btn    { background: #f5f5f5; color: #666; }
.confirm-btn.approve { background: #67c23a; color: #fff; }
.confirm-btn.reject  { background: #f56c6c; color: #fff; }
</style>
