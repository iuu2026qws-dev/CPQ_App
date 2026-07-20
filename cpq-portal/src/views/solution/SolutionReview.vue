<template>
  <div class="cpq-page">
    <div class="toolbar">
      <el-button @click="$router.back()">返回</el-button>
      <span style="margin-left:16px;font-weight:bold">方案评审</span>
      <el-tag v-if="doc" :type="statusTag(doc.status)" style="margin-left:12px">{{ statusLabel(doc.status) }}</el-tag>
    </div>

    <div v-if="!doc" class="empty-hint">加载中...</div>

    <template v-else>
      <!-- 方案信息 -->
      <el-descriptions :column="2" border style="margin-bottom:16px">
        <el-descriptions-item label="方案名称">{{ doc.documentName }}</el-descriptions-item>
        <el-descriptions-item label="方案类型">{{ typeLabel(doc.documentType) }}</el-descriptions-item>
        <el-descriptions-item label="版本">V{{ doc.version || 1 }}</el-descriptions-item>
        <el-descriptions-item label="状态">
          <el-tag :type="statusTag(doc.status)" size="small">{{ statusLabel(doc.status) }}</el-tag>
        </el-descriptions-item>
        <el-descriptions-item label="关联报价单">#{{ doc.quoteId || '-' }}</el-descriptions-item>
        <el-descriptions-item label="创建时间">{{ doc.createTime }}</el-descriptions-item>
      </el-descriptions>

      <!-- 评审操作区 -->
      <el-card header="评审操作" style="margin-bottom:16px">
        <div class="review-actions">
          <el-button type="success" @click="handleApprove">通过</el-button>
          <el-button type="warning" @click="handleConditionalApprove">条件通过</el-button>
          <el-button type="danger" @click="handleReject">驳回</el-button>
          <el-button @click="showAssignDialog = true">转审</el-button>
          <el-button @click="showCommentDialog = true">添加评审意见</el-button>
        </div>
      </el-card>

      <!-- 评审意见列表 -->
      <el-card header="评审意见">
        <div v-if="comments.length === 0" style="color:#c0c4cc;text-align:center;padding:20px">暂无评审意见</div>
        <el-timeline v-else>
          <el-timeline-item
            v-for="c in comments" :key="c.id"
            :timestamp="c.time"
            :color="commentColor(c.type)"
          >
            <el-card shadow="hover" size="small">
              <p style="margin:0"><strong>{{ c.author }}</strong> — {{ c.typeLabel }}</p>
              <p v-if="c.content" style="color:#606266;margin:4px 0 0">{{ c.content }}</p>
            </el-card>
          </el-timeline-item>
        </el-timeline>
      </el-card>

      <!-- 方案预览 -->
      <el-card header="方案内容预览" style="margin-top:16px">
        <div v-if="doc.documentContent" class="preview-content" v-html="doc.documentContent"></div>
        <div v-else style="color:#c0c4cc;text-align:center;padding:20px">暂无内容</div>
      </el-card>
    </template>

    <!-- 评审意见弹窗 -->
    <el-dialog v-model="showCommentDialog" title="添加评审意见" width="500px">
      <el-input v-model="commentForm.content" type="textarea" :rows="4" placeholder="请输入评审意见..." />
      <template #footer>
        <el-button @click="showCommentDialog = false">取消</el-button>
        <el-button type="primary" @click="addComment">提交</el-button>
      </template>
    </el-dialog>

    <!-- 转审弹窗 -->
    <el-dialog v-model="showAssignDialog" title="转审" width="400px">
      <el-form label-width="80px">
        <el-form-item label="转审人">
          <el-input v-model="assignTo" placeholder="请输入转审人姓名" />
        </el-form-item>
        <el-form-item label="转审原因">
          <el-input v-model="assignReason" type="textarea" :rows="2" placeholder="请输入原因" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="showAssignDialog = false">取消</el-button>
        <el-button type="primary" @click="handleAssign">确认转审</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useRoute } from 'vue-router'
import { ElMessage } from 'element-plus'
import { listSolution, updateSolution } from '@/api/quoting'
import type { SolutionVo } from '@/api/quoting'

const route = useRoute()
const doc = ref<SolutionVo | null>(null)
const showCommentDialog = ref(false)
const showAssignDialog = ref(false)
const assignTo = ref('')
const assignReason = ref('')
const commentForm = ref({ content: '' })

interface Comment { id: number; author: string; type: string; typeLabel: string; content: string; time: string }
const comments = ref<Comment[]>([
  { id: 1, author: '张工', type: 'comment', typeLabel: '评审意见', content: '技术方案结构完整，建议补充备选方案', time: '2026-06-08 14:30' },
])

function typeLabel(t?: string) { const m: Record<string, string> = { TECHNICAL_PROPOSAL: '技术方案', BUSINESS_PROPOSAL: '商务方案', DELIVERY_PLAN: '交付计划', IMPLEMENTATION: '实施方案', ACCEPTANCE: '验收标准' }; return m[t || ''] || t || '' }
function statusLabel(s?: string) { const m: Record<string, string> = { DRAFT: '草稿', EDITING: '编辑中', REVIEWING: '评审中', APPROVED: '已通过', PUBLISHED: '已发布' }; return m[s || ''] || s || '' }
function statusTag(s?: string) { const m: Record<string, string> = { DRAFT: 'info', EDITING: '', REVIEWING: 'warning', APPROVED: 'success', PUBLISHED: 'success' }; return m[s || ''] || 'info' }
function commentColor(t: string) { const m: Record<string, string> = { approve: '#67c23a', reject: '#f56c6c', conditional: '#e6a23c', comment: '#409eff', assign: '#909399' }; return m[t] || '#909399' }

async function handleApprove() {
  if (!doc.value) return
  await updateSolution({ documentId: doc.value.documentId, status: 'APPROVED' })
  comments.value.push({ id: Date.now(), author: '当前用户', type: 'approve', typeLabel: '通过', content: '方案评审通过', time: new Date().toLocaleString() })
  ElMessage.success('方案已通过')
  loadDoc()
}

async function handleConditionalApprove() {
  if (!doc.value) return
  await updateSolution({ documentId: doc.value.documentId, status: 'APPROVED' })
  comments.value.push({ id: Date.now(), author: '当前用户', type: 'conditional', typeLabel: '条件通过', content: commentForm.value.content || '条件通过', time: new Date().toLocaleString() })
  ElMessage.success('条件通过已记录')
  showCommentDialog.value = false
  loadDoc()
}

async function handleReject() {
  if (!doc.value) return
  if (!commentForm.value.content) { ElMessage.warning('请填写驳回原因'); showCommentDialog.value = true; return }
  await updateSolution({ documentId: doc.value.documentId, status: 'EDITING' })
  comments.value.push({ id: Date.now(), author: '当前用户', type: 'reject', typeLabel: '驳回', content: commentForm.value.content, time: new Date().toLocaleString() })
  ElMessage.warning('方案已驳回')
  showCommentDialog.value = false
  loadDoc()
}

function addComment() {
  if (!commentForm.value.content) { ElMessage.warning('请输入评审意见'); return }
  comments.value.push({ id: Date.now(), author: '当前用户', type: 'comment', typeLabel: '评审意见', content: commentForm.value.content, time: new Date().toLocaleString() })
  ElMessage.success('意见已提交')
  showCommentDialog.value = false
  commentForm.value.content = ''
}

async function handleAssign() {
  if (!assignTo.value) { ElMessage.warning('请输入转审人'); return }
  comments.value.push({ id: Date.now(), author: '当前用户', type: 'assign', typeLabel: '转审', content: `转审至 ${assignTo.value}：${assignReason.value || '无'}`, time: new Date().toLocaleString() })
  ElMessage.success(`已转审至 ${assignTo.value}`)
  showAssignDialog.value = false
}

async function loadDoc() {
  const id = String(route.params.id)
  const res = await listSolution({ documentId: id })
  const rows = (res as any).rows || []
  if (rows.length > 0) doc.value = rows[0]
}

onMounted(() => loadDoc())
</script>

<style scoped>
.empty-hint { text-align:center; padding:60px; color:#c0c4cc; font-size:16px; }
.review-actions { display:flex; gap:12px; }
.preview-content { max-height:500px; overflow-y:auto; padding:16px; background:#fafafa; border-radius:4px; }
.preview-content :deep(h2), .preview-content :deep(h3) { margin-top:16px; }
.preview-content :deep(table) { border-collapse:collapse; width:100%; margin:8px 0; }
.preview-content :deep(td), .preview-content :deep(th) { border:1px solid #ddd; padding:6px 10px; }
</style>
