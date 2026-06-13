<template>
  <div class="quick-quote">
    <el-card>
      <template #header>
        <div class="card-header">
          <h2>快速报价</h2>
          <p class="subtitle">三步完成报价：填写需求 → 查看历史相似报价 → 一键生成</p>
        </div>
      </template>
      <el-row :gutter="24">
        <el-col :span="14">
          <el-form :model="form" label-width="100px" size="default">
            <el-form-item label="客户名称">
              <el-input v-model="form.customerName" placeholder="请输入客户名称" />
            </el-form-item>
            <el-form-item label="产品类别">
              <el-select v-model="form.productCategory" placeholder="选择产品类别" clearable style="width:100%">
                <el-option label="工业设备" value="INDUSTRIAL" />
                <el-option label="电子元器件" value="ELECTRONIC" />
                <el-option label="机械设备" value="MACHINERY" />
                <el-option label="自动化系统" value="AUTOMATION" />
                <el-option label="其他" value="OTHER" />
              </el-select>
            </el-form-item>
            <el-form-item label="预计预算">
              <el-input-number v-model="form.budget" :min="0" :step="10000" style="width:100%" placeholder="请输入预算金额" />
            </el-form-item>
            <el-form-item label="需求数量">
              <el-input-number v-model="form.quantity" :min="1" style="width:100%" />
            </el-form-item>
            <el-form-item label="期望交期">
              <el-date-picker v-model="form.expectedDate" type="date" placeholder="选择期望交期" style="width:100%" />
            </el-form-item>
            <el-form-item label="备注">
              <el-input v-model="form.remark" type="textarea" :rows="3" placeholder="额外需求说明..." />
            </el-form-item>
            <el-form-item>
              <el-button type="primary" :icon="MagicStick" @click="handleQuickCreate" :loading="creating">
                一键生成报价
              </el-button>
              <el-button @click="handleReset">重置</el-button>
            </el-form-item>
          </el-form>
        </el-col>
        <el-col :span="10">
          <el-card shadow="hover" class="similar-card">
            <template #header>
              <span style="font-weight:600">历史相似报价</span>
              <el-button size="small" type="primary" style="float:right" @click="loadSimilar" :loading="similarLoading">
                查询相似
              </el-button>
            </template>
            <el-empty v-if="similarList.length === 0" description="暂无数据，请先查询" :image-size="80" />
            <div v-else class="similar-list">
              <div v-for="(item, idx) in similarList" :key="idx" class="similar-item">
                <div class="quote-no">{{ item.quoteNumber }}</div>
                <div class="quote-amount">{{ formatAmount(item.totalAmount) }}</div>
                <el-tag size="small" :type="item.status === 'APPROVED' ? 'success' : 'info'">{{ item.status }}</el-tag>
              </div>
            </div>
          </el-card>
          <el-card v-if="result" shadow="hover" class="result-card" style="margin-top:16px">
            <template #header><span style="font-weight:600;color:#67c23a">报价已生成</span></template>
            <div class="result-item"><span>报价单号：</span><strong>{{ result.quoteNumber }}</strong></div>
            <div class="result-item"><span>总金额：</span><strong style="color:#e6a23c">¥{{ formatAmount(result.totalAmount) }}</strong></div>
            <div class="result-item"><span>状态：</span><el-tag type="success">{{ result.status }}</el-tag></div>
          </el-card>
        </el-col>
      </el-row>
    </el-card>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive } from 'vue'
import { MagicStick } from '@element-plus/icons-vue'
import { ElMessage } from 'element-plus'
import { createQuickQuote, getSimilarQuotes, type QuickQuoteResult } from '@/api/cpq/quick-quote'

const form = reactive({ customerName: '', productCategory: '', budget: 0, quantity: 1, expectedDate: '', remark: '' })
const creating = ref(false)
const similarLoading = ref(false)
const similarList = ref<QuickQuoteResult[]>([])
const result = ref<QuickQuoteResult | null>(null)

const formatAmount = (v?: number) => v != null ? v.toLocaleString('zh-CN') : '-'

const loadSimilar = async () => {
  similarLoading.value = true
  try {
    const res = await getSimilarQuotes(1, form.productCategory || undefined)
    similarList.value = (res as unknown as QuickQuoteResult[]) || []
  } finally { similarLoading.value = false }
}

const handleQuickCreate = async () => {
  creating.value = true
  try {
    const res = await createQuickQuote({ ...form })
    result.value = res as unknown as QuickQuoteResult
    ElMessage.success('快速报价生成成功！')
  } catch { ElMessage.error('生成失败，请重试') }
  finally { creating.value = false }
}

const handleReset = () => { Object.assign(form, { customerName: '', productCategory: '', budget: 0, quantity: 1, expectedDate: '', remark: '' }); result.value = null }
</script>

<style scoped>
.quick-quote { padding: 0; }
.card-header h2 { margin: 0; font-size: 18px; }
.subtitle { margin: 4px 0 0; color: #909399; font-size: 13px; }
.similar-list { max-height: 260px; overflow-y: auto; }
.similar-item { display: flex; align-items: center; justify-content: space-between; padding: 10px 0; border-bottom: 1px solid #ebeef5; }
.similar-item:last-child { border-bottom: none; }
.quote-no { font-weight: 600; color: #303133; }
.quote-amount { color: #e6a23c; font-weight: 600; }
.result-item { display: flex; align-items: center; margin: 8px 0; gap: 8px; }
.result-item span { color: #909399; }
</style>
