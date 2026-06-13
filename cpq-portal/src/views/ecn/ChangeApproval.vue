<template>
  <div class="cpq-page">
    <div class="toolbar">
      <el-button @click="$router.back()">返回</el-button>
      <span style="font-weight:bold;margin-left:12px">ECN 审批</span>
    </div>
    <el-card header="审批操作">
      <div class="actions">
        <el-button type="success" @click="handleAction('APPROVE')">通过</el-button>
        <el-button type="danger" @click="handleAction('REJECT')">驳回</el-button>
        <el-button @click="showComment = true">添加意见</el-button>
      </div>
    </el-card>
    <el-card header="审批记录" style="margin-top:16px">
      <el-timeline>
        <el-timeline-item v-for="a in approvals" :key="a.ecnApprovalId" :timestamp="a.actionTime" :color="a.action==='APPROVE'?'#67c23a':'#f56c6c'">
          <el-card shadow="hover" size="small">
            <p style="margin:0"><strong>{{ a.approverName }}</strong> — {{ a.action }}</p>
            <p v-if="a.comment" style="color:#666;margin:4px 0 0">{{ a.comment }}</p>
          </el-card>
        </el-timeline-item>
      </el-timeline>
    </el-card>
    <el-dialog v-model="showComment" title="添加审批意见" width="400px">
      <el-input v-model="comment" type="textarea" :rows="3" placeholder="请输入审批意见" />
      <template #footer><el-button @click="showComment=false">取消</el-button><el-button type="primary" @click="submitComment">提交</el-button></template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useRoute } from 'vue-router'
import { ElMessage } from 'element-plus'
import request from '@/utils/request'

const route = useRoute()
const approvals = ref<any[]>([])
const showComment = ref(false)
const comment = ref('')

async function fetchApprovals() {
  const id = Number(route.params.id)
  const res = await request.get('/cpq/ecn/approval/list', { params: { changeOrderId: id, pageSize: 100 } })
  approvals.value = Array.isArray(res) ? res : (res.rows || [])
}

async function handleAction(action: string) {
  const id = Number(route.params.id)
  await request.post('/cpq/ecn/approval', {
    changeOrderId: id, approverName: '当前用户', stepNumber: 1,
    action, comment: comment.value, actionTime: new Date().toISOString()
  })
  ElMessage.success(action === 'APPROVE' ? '已通过' : '已驳回'); fetchApprovals()
}

function submitComment() { handleAction('COMMENT') }

onMounted(() => fetchApprovals())
</script>

<style scoped>.actions { display:flex; gap:12px; }</style>
