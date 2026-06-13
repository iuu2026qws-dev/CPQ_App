<template>
  <div class="supersession-manager">
    <div class="page-header">
      <h2>替代品管理</h2>
      <p class="subtitle">查询产品替代关系与推荐替代方案</p>
    </div>

    <el-card shadow="never">
      <template #header>
        <el-row :gutter="16" align="middle">
          <el-col :span="10">
            <el-select
              v-model="searchModelId"
              filterable
              remote
              :remote-method="searchModelOptions"
              placeholder="搜索产品，查看其替代关系"
              style="width: 100%"
              clearable
            >
              <el-option
                v-for="m in modelOpts"
                :key="m.value"
                :label="m.label"
                :value="m.value"
              />
            </el-select>
          </el-col>
          <el-col :span="14">
            <el-button type="primary" :disabled="!searchModelId" @click="loadWhereUsed">
              where-used 查询
            </el-button>
            <el-button type="success" :disabled="!searchModelId" @click="loadRecommend">
              推荐替代品
            </el-button>
          </el-col>
        </el-row>
      </template>

      <el-tabs v-model="activeTab">
        <el-tab-pane label="替代关系列表" name="whereUsed">
          <el-table :data="whereUsedData" stripe v-loading="loading" empty-text="暂无替代关系">
            <el-table-column prop="originalModelCode" label="被替代产品" width="160" />
            <el-table-column prop="originalModelName" label="被替代产品名称" />
            <el-table-column prop="replacementModelCode" label="替代产品" width="160" />
            <el-table-column prop="replacementModelName" label="替代产品名称" />
            <el-table-column prop="supersessionType" label="替代类型" width="140">
              <template #default="{ row }">
                <el-tag size="small">
                  {{ row.supersessionType === 'REPLACE' ? '完全替代' : row.supersessionType === 'UPGRADE' ? '升级替代' : row.supersessionType || '-' }}
                </el-tag>
              </template>
            </el-table-column>
            <el-table-column prop="priceImpactPct" label="价格影响%" width="110">
              <template #default="{ row }">
                <span :style="{ color: (row.priceImpactPct || 0) > 0 ? 'var(--cpq-danger)' : 'var(--cpq-success)' }">
                  {{ row.priceImpactPct != null ? (row.priceImpactPct > 0 ? '+' : '') + row.priceImpactPct + '%' : '-' }}
                </span>
              </template>
            </el-table-column>
            <el-table-column prop="status" label="状态" width="90">
              <template #default="{ row }">
                <el-tag size="small" :type="row.status === 'ACTIVE' ? 'success' : 'info'">
                  {{ row.status }}
                </el-tag>
              </template>
            </el-table-column>
          </el-table>
        </el-tab-pane>
        <el-tab-pane label="推荐替代品" name="recommend">
          <el-table :data="recommendData" stripe v-loading="loading" empty-text="暂无推荐替代品">
            <el-table-column prop="replacementModelCode" label="推荐替代产品" width="160" />
            <el-table-column prop="replacementModelName" label="产品名称" />
            <el-table-column prop="supersessionType" label="替代类型" width="140">
              <template #default="{ row }">
                <el-tag size="small">
                  {{ row.supersessionType === 'REPLACE' ? '完全替代' : row.supersessionType === 'UPGRADE' ? '升级替代' : '-' }}
                </el-tag>
              </template>
            </el-table-column>
            <el-table-column prop="priceImpactPct" label="价格影响%" width="110">
              <template #default="{ row }">
                <span :style="{ color: (row.priceImpactPct || 0) > 0 ? 'var(--cpq-danger)' : 'var(--cpq-success)' }">
                  {{ row.priceImpactPct != null ? (row.priceImpactPct > 0 ? '+' : '') + row.priceImpactPct + '%' : '-' }}
                </span>
              </template>
            </el-table-column>
          </el-table>
        </el-tab-pane>
      </el-tabs>
    </el-card>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import request from '@/utils/request'

interface SupersessionItem {
  originalModelCode: string
  originalModelName: string
  replacementModelCode: string
  replacementModelName: string
  supersessionType: string
  priceImpactPct: number
  status: string
}

interface ModelOption {
  label: string
  value: number
}

const searchModelId = ref<number | null>(null)
const modelOpts = ref<ModelOption[]>([])
const activeTab = ref('whereUsed')
const whereUsedData = ref<SupersessionItem[]>([])
const recommendData = ref<SupersessionItem[]>([])
const loading = ref(false)

const searchModelOptions = async (query: string) => {
  if (!query || query.length < 1) { modelOpts.value = []; return }
  const data = await request.get('/cpq/product/model/search', { params: { keyword: query } })
  modelOpts.value = (data || []).map((m: any) => ({
    label: `${m.modelCode} - ${m.modelName}`,
    value: m.modelId
  }))
}

const loadWhereUsed = async () => {
  if (!searchModelId.value) return
  loading.value = true
  try {
    const data = await request.get(`/cpq/product/supersession/whereUsed/${searchModelId.value}`)
    whereUsedData.value = data || []
    activeTab.value = 'whereUsed'
  } finally { loading.value = false }
}

const loadRecommend = async () => {
  if (!searchModelId.value) return
  loading.value = true
  try {
    const data = await request.get(`/cpq/product/supersession/recommend/${searchModelId.value}`)
    recommendData.value = data || []
    activeTab.value = 'recommend'
  } finally { loading.value = false }
}
</script>

<style scoped lang="scss">
.supersession-manager {
  .page-header {
    margin-bottom: 20px;
    h2 { font-size: 20px; font-weight: 600; }
    .subtitle { font-size: 13px; color: var(--cpq-text-secondary); margin-top: 4px; }
  }
}
</style>
