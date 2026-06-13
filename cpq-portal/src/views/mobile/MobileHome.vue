<template>
  <div class="mobile-home">
    <!-- 搜索栏 -->
    <div class="search-bar" @click="haptic?.('light')">
      <el-icon class="search-icon"><Search /></el-icon>
      <span class="search-placeholder">搜索产品、报价、方案...</span>
    </div>

    <!-- 快捷入口 -->
    <div class="quick-actions">
      <div class="action-card" @click="navigate('/mobile/quick-quote')">
        <div class="action-icon quote-icon"><el-icon><Money /></el-icon></div>
        <span class="action-label">快速报价</span>
      </div>
      <div class="action-card" @click="navigate('/mobile/approval')">
        <div class="action-icon approval-icon"><el-icon><Checked /></el-icon></div>
        <span class="action-label">待审批</span>
      </div>
      <div class="action-card" @click="navigate('/configure')">
        <div class="action-icon config-icon"><el-icon><Setting /></el-icon></div>
        <span class="action-label">产品配置</span>
      </div>
      <div class="action-card" @click="navigate('/atp-check')">
        <div class="action-icon atp-icon"><el-icon><Timer /></el-icon></div>
        <span class="action-label">交期查询</span>
      </div>
    </div>

    <!-- 最近报价 -->
    <section class="section">
      <div class="section-header">
        <h3>最近报价</h3>
        <span class="section-more" @click="navigate('/mobile/quote')">全部<el-icon><ArrowRight /></el-icon></span>
      </div>
      <div v-if="loading" class="skeleton-list">
        <div v-for="i in 3" :key="i" class="skeleton-card" />
      </div>
      <div v-else-if="recentQuotes.length" class="quote-list">
        <div
          v-for="q in recentQuotes"
          :key="q.quoteId"
          class="quote-card"
          @click="navigate(`/quote/${q.quoteId}`)"
        >
          <div class="card-top">
            <span class="quote-number">{{ q.quoteNumber }}</span>
            <span class="quote-status" :class="q.status">{{ statusLabel(q.status) }}</span>
          </div>
          <div class="card-mid">
            <span>{{ q.customerName || '未指定客户' }}</span>
            <span class="quote-amount">¥{{ formatAmount(q.totalAmount) }}</span>
          </div>
          <div class="card-bottom">
            <span class="quote-date">{{ formatDate(q.createTime) }}</span>
          </div>
        </div>
      </div>
      <div v-else class="empty-hint">暂无报价记录</div>
    </section>

    <!-- 公告/知识 -->
    <section class="section">
      <div class="section-header">
        <h3>最新知识</h3>
        <span class="section-more" @click="navigate('/knowledge')">更多<el-icon><ArrowRight /></el-icon></span>
      </div>
      <div class="knowledge-list">
        <div v-for="k in knowledgeList" :key="k.id" class="knowledge-item" @click="navigate(`/knowledge/${k.id}`)">
          <span class="k-title">{{ k.title }}</span>
          <span class="k-date">{{ formatDate(k.publishTime) }}</span>
        </div>
      </div>
    </section>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, inject } from 'vue'
import { useRouter } from 'vue-router'
import { Search, Money, Checked, Setting, Timer, ArrowRight } from '@element-plus/icons-vue'
import { useUserStore } from '@/store/user'

const router = useRouter()
const userStore = useUserStore()
const haptic = inject<(style: string) => void>('haptic')
const showToast = inject<(msg: string, type: string) => void>('showToast')

const loading = ref(true)
const recentQuotes = ref<any[]>([])
const knowledgeList = ref<any[]>([])

function navigate(path: string) {
  haptic?.('light')
  router.push(path)
}

function statusLabel(s: string): string {
  const map: Record<string, string> = { DRAFT: '草稿', SUBMITTED: '已提交', APPROVED: '已审批', REJECTED: '已驳回' }
  return map[s] || s
}

function formatAmount(v: any): string {
  if (v == null) return '—'
  return Number(v).toLocaleString('zh-CN', { minimumFractionDigits: 2, maximumFractionDigits: 2 })
}

function formatDate(v: string): string {
  if (!v) return '—'
  return v.substring(0, 10)
}

onMounted(async () => {
  try {
    const token = userStore.token
    const headers = { Authorization: `Bearer ${token}`, clientid: 'e5cd7e4891bf95d1d19206ce24a7b32e' }

    // 加载最近报价
    const qRes = await fetch('/api/cpq/quote/header/list?pageNum=1&pageSize=5', { headers })
    const qData = await qRes.json()
    if (qData.code === 200 && qData.data) {
      recentQuotes.value = qData.data.rows || qData.data || []
    }

    // 加载知识
    const kRes = await fetch('/api/cpq/knowledge/article/list?pageNum=1&pageSize=4', { headers })
    const kData = await kRes.json()
    if (kData.code === 200 && kData.data) {
      knowledgeList.value = (kData.data.rows || kData.data || []).slice(0, 4)
    }
  } catch {
    // 静默失败
  } finally {
    loading.value = false
  }
})
</script>

<style scoped>
.mobile-home { padding: 12px 16px; }

.search-bar {
  display: flex;
  align-items: center;
  height: 38px;
  background: #fff;
  border-radius: 19px;
  padding: 0 16px;
  margin-bottom: 16px;
  box-shadow: 0 1px 3px rgba(0,0,0,0.06);
}

.search-icon { color: #999; margin-right: 8px; font-size: 16px; }
.search-placeholder { color: #bbb; font-size: 14px; }

.quick-actions {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 10px;
  margin-bottom: 20px;
}

.action-card {
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: 12px 8px;
  background: #fff;
  border-radius: 12px;
  cursor: pointer;
  transition: transform 0.15s;
  -webkit-tap-highlight-color: transparent;
}
.action-card:active { transform: scale(0.95); }

.action-icon {
  width: 42px; height: 42px;
  border-radius: 12px;
  display: flex; align-items: center; justify-content: center;
  margin-bottom: 6px;
  font-size: 20px;
}
.quote-icon    { background: #e6f7ff; color: #409eff; }
.approval-icon { background: #fff7e6; color: #e6a23c; }
.config-icon   { background: #f0f5ff; color: #7c6ff0; }
.atp-icon      { background: #f6ffed; color: #67c23a; }

.action-label { font-size: 11px; color: #666; }

.section { margin-bottom: 20px; }
.section-header {
  display: flex; justify-content: space-between; align-items: center;
  margin-bottom: 10px;
}
.section-header h3 { font-size: 16px; font-weight: 600; color: #1a1a1a; margin: 0; }
.section-more { font-size: 13px; color: #409eff; cursor: pointer; display: flex; align-items: center; gap: 2px; }

.quote-card {
  background: #fff; border-radius: 10px; padding: 12px 14px;
  margin-bottom: 8px; cursor: pointer;
  box-shadow: 0 1px 2px rgba(0,0,0,0.04);
}
.card-top, .card-mid, .card-bottom {
  display: flex; justify-content: space-between; align-items: center;
  margin-bottom: 4px;
}
.quote-number { font-weight: 600; font-size: 14px; }
.quote-status { font-size: 11px; padding: 2px 8px; border-radius: 10px; }
.quote-status.DRAFT     { background: #f0f0f0; color: #999; }
.quote-status.SUBMITTED { background: #e6f7ff; color: #409eff; }
.quote-status.APPROVED  { background: #f6ffed; color: #67c23a; }
.quote-status.REJECTED  { background: #fff1f0; color: #f56c6c; }
.quote-amount { font-size: 15px; font-weight: 700; color: #e6a23c; }
.quote-date   { font-size: 12px; color: #bbb; }

.skeleton-card {
  height: 64px; background: #eee; border-radius: 10px; margin-bottom: 8px;
  animation: pulse 1.5s infinite;
}
@keyframes pulse {
  0%, 100% { opacity: 1; }
  50%       { opacity: 0.5; }
}

.empty-hint { text-align: center; color: #bbb; font-size: 13px; padding: 20px 0; }

.knowledge-item {
  display: flex; justify-content: space-between;
  padding: 12px 0; border-bottom: 1px solid #f0f0f0; cursor: pointer;
}
.k-title { font-size: 14px; color: #333; flex: 1; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; margin-right: 12px; }
.k-date  { font-size: 12px; color: #bbb; flex-shrink: 0; }
</style>
