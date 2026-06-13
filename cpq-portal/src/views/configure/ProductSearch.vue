<template>
  <div class="product-search">
    <div class="search-header">
      <h2>产品配置器</h2>
      <p class="subtitle">选择产品型号开始配置报价流程</p>
    </div>

    <div class="search-box">
      <el-input
        v-model="keyword"
        placeholder="搜索产品名称或编码..."
        size="large"
        clearable
        @keyup.enter="doSearch"
        @clear="doSearch"
      >
        <template #prefix>
          <el-icon><Search /></el-icon>
        </template>
        <template #append>
          <el-button type="primary" :loading="loading" @click="doSearch">
            <el-icon><Search /></el-icon>
            搜索
          </el-button>
        </template>
      </el-input>
    </div>

    <div class="scenario-tabs">
      <el-radio-group v-model="configType" @change="doSearch" size="small">
        <el-radio-button value="">全部</el-radio-button>
        <el-radio-button value="STANDARD">标准品</el-radio-button>
        <el-radio-button value="ATO">按单装配</el-radio-button>
        <el-radio-button value="CTO">按单配置</el-radio-button>
        <el-radio-button value="ETO">按单设计</el-radio-button>
        <el-radio-button value="BUNDLE">捆绑包</el-radio-button>
      </el-radio-group>
    </div>

    <div v-loading="loading" class="search-results">
      <el-empty v-if="!loading && results.length === 0 && searched" description="未找到匹配的���品" />
      <div v-if="results.length > 0" class="result-list">
        <div
          v-for="item in results"
          :key="item.modelId"
          class="result-card"
          @click="handleSelect(item)"
        >
          <div class="card-header">
            <span class="model-code">{{ item.modelCode }}</span>
            <el-tag size="small" :type="configTypeTag(item.configType)">
              {{ item.configType ?? 'STANDARD' }}
            </el-tag>
          </div>
          <div class="card-body">
            <h3 class="model-name">{{ item.modelName }}</h3>
            <p class="model-desc" v-if="item.description">{{ item.description }}</p>
          </div>
          <div class="card-footer">
            <span v-if="item.basePrice" class="price">
              {{ formatPrice(item.basePrice) }} {{ item.currency ?? 'CNY' }}
            </span>
            <span v-if="item.leadTimeDays" class="lead-time">
              交期 {{ item.leadTimeDays }} 天
            </span>
            <span v-if="item.lifecycleStatus" class="lifecycle">
              <el-tag size="small" type="info">{{ item.lifecycleStatus }}</el-tag>
            </span>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { Search } from '@element-plus/icons-vue'
import { searchProducts } from '@/api/configure'
import type { CpqProductModelVo } from '@/api/cpq/product'

const router = useRouter()
const keyword = ref('')
const configType = ref('')
const loading = ref(false)
const searched = ref(false)
const results = ref<CpqProductModelVo[]>([])

function handleSelect(model: CpqProductModelVo) {
  router.push(`/configure/${model.modelId}`)
}

async function doSearch() {
  loading.value = true
  searched.value = true
  try {
    results.value = await searchProducts(keyword.value, configType.value || undefined)
  } finally {
    loading.value = false
  }
}

function configTypeTag(type?: string) {
  const map: Record<string, string> = {
    STANDARD: '', ATO: 'success', CTO: 'warning', ETO: 'danger', BUNDLE: 'info'
  }
  return map[type ?? ''] ?? ''
}

function formatPrice(price: number) {
  return '¥' + (price / 100).toLocaleString('zh-CN', { minimumFractionDigits: 0, maximumFractionDigits: 2 })
}

onMounted(() => {
  doSearch()
})
</script>

<style scoped>
.product-search {
  padding: 24px 32px;
  max-width: 1200px;
  margin: 0 auto;
}
.search-header {
  text-align: center;
  margin-bottom: 24px;
}
.search-header h2 {
  font-size: 28px;
  color: #303133;
  margin: 0 0 8px 0;
}
.subtitle {
  color: #909399;
  font-size: 14px;
  margin: 0;
}
.search-box {
  max-width: 640px;
  margin: 0 auto 16px;
}
.scenario-tabs {
  text-align: center;
  margin-bottom: 24px;
}
.result-list {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(320px, 1fr));
  gap: 12px;
}
.result-card {
  border: 1px solid #e4e7ed;
  border-radius: 8px;
  padding: 16px;
  cursor: pointer;
  transition: all 0.2s;
  background: #fff;
}
.result-card:hover {
  border-color: #409eff;
  box-shadow: 0 2px 8px rgba(64,158,255,0.15);
}
.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 8px;
}
.model-code {
  font-family: monospace;
  font-size: 13px;
  color: #909399;
}
.model-name {
  font-size: 16px;
  margin: 0 0 4px 0;
  color: #303133;
}
.model-desc {
  font-size: 13px;
  color: #909399;
  margin: 0 0 8px 0;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}
.card-footer {
  display: flex;
  gap: 12px;
  align-items: center;
}
.price {
  color: #f56c6c;
  font-weight: 600;
  font-size: 16px;
}
.lead-time {
  font-size: 12px;
  color: #909399;
}
.lifecycle {
  margin-left: auto;
}
</style>
