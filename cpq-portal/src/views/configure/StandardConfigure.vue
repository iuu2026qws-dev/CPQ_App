<template>
  <div class="standard-configure">
    <!-- 标题区 -->
    <div class="page-hero">
      <el-icon class="hero-icon" :size="40"><MagicStick /></el-icon>
      <h1>新建标准配置</h1>
      <p class="hero-desc">
        标准配置适用于<strong>标准化产品</strong>（configType=STANDARD），通过选择产品型号 → 配置属性选项 → 自动验证约束 → 生成 BOM 和报价的完整流程。
        适用于参数确定、无需定制的标准品报价场景。
      </p>
    </div>

    <!-- 流程引导卡片 -->
    <div class="guide-steps">
      <div class="step-card" :class="{ active: currentStep === 1 }">
        <div class="step-num">1</div>
        <div class="step-body">
          <h4>选择产品</h4>
          <p>从产品目录搜索并选择要配置的标准产品型号</p>
        </div>
      </div>
      <el-icon class="step-arrow" :size="20"><ArrowRight /></el-icon>
      <div class="step-card" :class="{ active: currentStep === 2 }">
        <div class="step-num">2</div>
        <div class="step-body">
          <h4>配置属性</h4>
          <p>选择颜色、版本、工艺等属性，系统自动验证约束</p>
        </div>
      </div>
      <el-icon class="step-arrow" :size="20"><ArrowRight /></el-icon>
      <div class="step-card" :class="{ active: currentStep === 3 }">
        <div class="step-num">3</div>
        <div class="step-body">
          <h4>验证 & BOM</h4>
          <p>CSP 约束求解验证配置合理性，自动生成物料清单</p>
        </div>
      </div>
      <el-icon class="step-arrow" :size="20"><ArrowRight /></el-icon>
      <div class="step-card" :class="{ active: currentStep === 4 }">
        <div class="step-num">4</div>
        <div class="step-body">
          <h4>生成报价</h4>
          <p>自动计算价格，生成标准配置报价单</p>
        </div>
      </div>
    </div>

    <el-divider />

    <!-- 产品搜索区 -->
    <div class="search-section">
      <h3 class="section-title">
        <el-icon><Search /></el-icon>
        选择要配置的标准产品
      </h3>
      <p class="section-hint">以下展示所有标准品（STANDARD）产品，选择一款开始配置</p>

      <el-input
        v-model="keyword"
        placeholder="搜索产品名称或编码..."
        size="large"
        clearable
        class="search-input"
        @keyup.enter="doSearch"
        @clear="doSearch"
      >
        <template #prefix>
          <el-icon><Search /></el-icon>
        </template>
        <template #append>
          <el-button type="primary" :loading="loading" @click="doSearch">
            <el-icon><Search /></el-icon> 搜索
          </el-button>
        </template>
      </el-input>

      <div v-loading="loading" class="search-results">
        <el-empty v-if="!loading && results.length === 0 && searched" description="未找到匹配的标准产品">
          <template #extra>
            <el-button type="primary" @click="goToProductSearch">去产品配置器查看全部产品</el-button>
          </template>
        </el-empty>

        <div v-if="results.length > 0" class="result-list">
          <div
            v-for="item in results"
            :key="item.modelId"
            class="result-card"
            @click="startConfigure(item)"
          >
            <div class="card-top">
              <span class="model-code">{{ item.modelCode }}</span>
              <el-tag size="small" type="">STANDARD</el-tag>
            </div>
            <h3 class="model-name">{{ item.modelName }}</h3>
            <p class="model-desc" v-if="item.description">{{ item.description }}</p>
            <div class="card-bottom">
              <span v-if="item.basePrice" class="price">
                {{ formatPrice(item.basePrice) }} {{ item.currency ?? 'CNY' }}
              </span>
              <span v-if="item.leadTimeDays" class="lead-time">
                交期 {{ item.leadTimeDays }} 天
              </span>
              <el-button type="primary" size="small" class="config-btn">
                开始配置
              </el-button>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { Search, MagicStick, ArrowRight } from '@element-plus/icons-vue'
import { searchProducts } from '@/api/configure'
import type { CpqProductModelVo } from '@/api/cpq/product'

const router = useRouter()
const keyword = ref('')
const loading = ref(false)
const searched = ref(false)
const results = ref<CpqProductModelVo[]>([])
const currentStep = ref(1)

function startConfigure(model: CpqProductModelVo) {
  router.push(`/configure/${model.modelId}`)
}

async function doSearch() {
  loading.value = true
  searched.value = true
  try {
    // 新建标准配置只搜索 STANDARD 类型产品
    const res = await searchProducts(keyword.value, 'STANDARD')
    results.value = Array.isArray(res) ? res : (res.rows || [])
  } finally {
    loading.value = false
  }
}

function goToProductSearch() {
  router.push('/configure')
}

function formatPrice(price: number) {
  return '¥' + (price / 100).toLocaleString('zh-CN', { minimumFractionDigits: 0, maximumFractionDigits: 2 })
}

onMounted(() => {
  doSearch()
})
</script>

<style scoped>
.standard-configure {
  padding: 24px 32px;
  max-width: 1100px;
  margin: 0 auto;
}

/* 标题区 */
.page-hero {
  text-align: center;
  margin-bottom: 28px;
  padding: 32px 24px;
  background: linear-gradient(135deg, #f0f9ff 0%, #e0f2fe 50%, #f0fdf4 100%);
  border-radius: 12px;
  border: 1px solid #bae6fd;
}
.hero-icon {
  color: #0284c7;
  margin-bottom: 8px;
}
.page-hero h1 {
  font-size: 26px;
  color: #0f172a;
  margin: 0 0 12px 0;
  font-weight: 700;
}
.hero-desc {
  font-size: 14px;
  color: #475569;
  margin: 0 auto;
  max-width: 680px;
  line-height: 1.7;
}
.hero-desc strong {
  color: #0284c7;
}

/* 流程引导卡片 */
.guide-steps {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
  margin-bottom: 8px;
  flex-wrap: wrap;
}
.step-card {
  display: flex;
  align-items: flex-start;
  gap: 10px;
  padding: 14px 16px;
  border-radius: 10px;
  border: 2px solid #e2e8f0;
  background: #fff;
  min-width: 140px;
  transition: all 0.25s;
}
.step-card.active {
  border-color: #0284c7;
  background: #f0f9ff;
  box-shadow: 0 2px 8px rgba(2,132,199,0.12);
}
.step-num {
  width: 28px;
  height: 28px;
  border-radius: 50%;
  background: #e2e8f0;
  color: #64748b;
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: 700;
  font-size: 14px;
  flex-shrink: 0;
}
.step-card.active .step-num {
  background: #0284c7;
  color: #fff;
}
.step-body h4 {
  margin: 0 0 2px 0;
  font-size: 14px;
  color: #334155;
}
.step-body p {
  margin: 0;
  font-size: 12px;
  color: #94a3b8;
  line-height: 1.4;
}
.step-arrow {
  color: #cbd5e1;
  flex-shrink: 0;
}

/* 搜索区 */
.search-section {
  margin-top: 8px;
}
.section-title {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 17px;
  color: #1e293b;
  margin: 0 0 4px 0;
}
.section-hint {
  font-size: 13px;
  color: #94a3b8;
  margin: 0 0 16px 0;
}
.search-input {
  max-width: 560px;
  margin-bottom: 20px;
}

/* 搜索结果 */
.result-list {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(340px, 1fr));
  gap: 14px;
}
.result-card {
  border: 1px solid #e2e8f0;
  border-radius: 10px;
  padding: 18px;
  cursor: pointer;
  transition: all 0.2s;
  background: #fff;
}
.result-card:hover {
  border-color: #0284c7;
  box-shadow: 0 4px 16px rgba(2,132,199,0.12);
  transform: translateY(-1px);
}
.card-top {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 8px;
}
.model-code {
  font-family: 'SF Mono', 'Fira Code', monospace;
  font-size: 13px;
  color: #64748b;
}
.model-name {
  font-size: 17px;
  margin: 0 0 6px 0;
  color: #0f172a;
}
.model-desc {
  font-size: 13px;
  color: #94a3b8;
  margin: 0 0 10px 0;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}
.card-bottom {
  display: flex;
  align-items: center;
  gap: 14px;
}
.price {
  color: #dc2626;
  font-weight: 700;
  font-size: 17px;
}
.lead-time {
  font-size: 12px;
  color: #94a3b8;
}
.config-btn {
  margin-left: auto;
}
</style>
