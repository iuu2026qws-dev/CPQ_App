<template>
  <div class="cpq-page">
    <div class="toolbar">
      <el-button @click="$router.back()">返回</el-button>
    </div>

    <!-- ★ 业务上下文：客户需求 + 选定产品 -->
    <h3>📋 工艺确认单</h3>
    <el-descriptions v-if="detail" :column="2" border style="margin-bottom:20px">
      <el-descriptions-item label="推荐产品">{{ detail.model_code }} {{ detail.model_name }}</el-descriptions-item>
      <el-descriptions-item label="基准价格">¥{{ detail.base_price }}</el-descriptions-item>
      <el-descriptions-item label="客户需求" :span="2">
        <div style="white-space:pre-wrap;font-size:13px;line-height:1.8">
          {{ detail?.requirement_text || reqSummary }}
        </div>
      </el-descriptions-item>
      <el-descriptions-item label="匹配结果" :span="2">
        <div v-if="scoredList.length > 0" style="max-height:200px;overflow:auto">
          <div v-for="(s, i) in scoredList" :key="i" style="font-size:12px;margin-bottom:4px">
            #{{ s.rank }} {{ s.modelCode }} — {{ s.totalScore }}分 | {{ s.aiReason || '' }}
          </div>
        </div>
        <span v-else>暂无</span>
      </el-descriptions-item>
      <el-descriptions-item label="工艺状态">
        <el-tag :type="detail.confirm_status === 'CONFIRMED' ? 'success' : detail.confirm_status === 'PENDING' ? 'warning' : 'danger'">
          {{ detail.confirm_status }}
        </el-tag>
      </el-descriptions-item>
      <el-descriptions-item v-if="detail.replaced_model_id" label="替代推荐" :span="2">
        <div style="padding:8px;background:#fef7e0;border:1px solid #fde3a7;border-radius:6px">
          <div style="margin-bottom:4px">
            <span style="color:#909399">原推荐：</span>
            <span style="text-decoration:line-through;color:#909399">{{ detail.replaced_model_code || detail.replaced_model_id }} {{ detail.replaced_model_name || '' }}</span>
          </div>
          <div style="margin-bottom:4px">
            <span style="color:#1A73E8;font-weight:600">替代产品：</span>
            <span style="color:#1A73E8;font-weight:600">{{ detail.model_code }} {{ detail.model_name }}</span>
          </div>
          <div v-if="detail.replaced_reason">
            <span style="color:#909399">推荐理由：</span>
            <span>{{ detail.replaced_reason }}</span>
          </div>
        </div>
      </el-descriptions-item>
    </el-descriptions>
    <div v-else-if="loading" style="text-align:center;padding:40px">加载中...</div>

    <!-- 审批操作 -->
    <div v-if="detail && detail.confirm_status === 'PENDING'" style="margin-bottom:20px">
      <el-button type="primary" @click="handleApprove">通过</el-button>
      <el-button type="danger" @click="handleReject">驳回</el-button>
      <el-button @click="dialogVisible = true">推荐替代产品</el-button>
    </div>

    <!-- ★ 推荐替代弹窗 -->
    <el-dialog v-model="dialogVisible" title="推荐替代产品" width="480px" :close-on-click-modal="false">
      <el-form ref="replaceFormRef" :model="replaceForm" :rules="replaceRules" label-width="auto">
        <el-form-item label="替代产品型号" prop="modelCode" required>
          <el-input v-model="replaceForm.modelCode" placeholder="如 ER14505" style="width:100%" />
        </el-form-item>
        <el-form-item label="推荐理由" prop="reason" required>
          <el-input v-model="replaceForm.reason" type="textarea" :rows="2" placeholder="请输入推荐理由" style="width:100%" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" @click="submitReplace">确认推荐</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, computed, onMounted } from 'vue'
import { useRoute } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import request from '@/utils/request'

const route = useRoute()
const loading = ref(false)
const detail = ref<any>(null)

const dialogVisible = ref(false)
const replaceFormRef = ref()
const replaceForm = reactive({ modelCode: '', reason: '' })
const replaceRules = {
  modelCode: [{ required: true, message: '请输入替代产品型号', trigger: 'blur' }],
  reason: [{ required: true, message: '请输入推荐理由', trigger: 'blur' }],
}

const reqSummary = computed(() => {
  try {
    const r = JSON.parse(detail.value?.requirement_json || '{}')
    const req = r.requirements || r
    return JSON.stringify(req, null, 2)
  } catch { return detail.value?.requirement_json || '-' }
})

const scoredList = computed(() => {
  try {
    const s = JSON.parse(detail.value?.scored_json || '[]')
    return Array.isArray(s) ? s : []
  } catch { return [] }
})

async function fetchDetail() {
  loading.value = true
  try {
    const chainId = String(route.params.id)
    const res: any = await request.get(`/cpq/process/detail/${chainId}`)
    detail.value = res
  } catch { detail.value = null }
  finally { loading.value = false }
}

async function handleApprove() {
  try {
    await request.post('/cpq/process/approve', { chainId: Number(route.params.id), action: 'APPROVED' })
    ElMessage.success('已通过')
    fetchDetail()
  } catch { }
}

async function handleReject() {
  try {
    const { value } = await ElMessageBox.prompt('驳回原因', '驳回', { type: 'warning' })
    await request.post('/cpq/process/approve', { chainId: Number(route.params.id), action: 'REJECTED', comment: value || '' })
    ElMessage.success('已驳回')
    fetchDetail()
  } catch { }
}

async function submitReplace() {
  const valid = await replaceFormRef.value?.validate().catch(() => false)
  if (!valid) return
  try {
    await request.post('/cpq/process/confirm', {
      resultId: detail.value?.result_id, modelId: detail.value?.model_id,
      action: 'REPLACE', replacedModelCode: replaceForm.modelCode.trim(), replacedReason: replaceForm.reason.trim()
    })
    ElMessage.success('已推荐替代产品')
    dialogVisible.value = false
    replaceForm.modelCode = ''
    replaceForm.reason = ''
    fetchDetail()
  } catch { }
}

onMounted(() => { fetchDetail() })
</script>

<style scoped>
.cpq-page { padding: 16px; }
.toolbar { margin-bottom: 12px; }
</style>
