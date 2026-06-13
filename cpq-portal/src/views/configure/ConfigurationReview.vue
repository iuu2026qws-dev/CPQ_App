<template>
  <div class="config-review">
    <!-- 无数据时提示（直接访问URL或store未初始化） -->
    <el-result
      v-if="!hasData"
      icon="warning"
      title="无配置数据"
      sub-title="请通过向导式配置完成产品配置后再查看，或直接访问产品配置页面"
    >
      <template #extra>
        <el-button type="primary" @click="goToGuided">返回向导式配置</el-button>
        <el-button @click="goToConfigurator">前往产品配置器</el-button>
      </template>
    </el-result>

    <!-- 有数据时展示完整配置 -->
    <template v-else>
      <!-- 产品信息卡片 -->
      <el-card class="section-card">
        <template #header>
          <div class="card-header">
            <span class="card-title">产品配置概览</span>
            <el-tag>{{ store.configType }}</el-tag>
          </div>
        </template>
        <el-descriptions :column="2" border>
          <el-descriptions-item label="产品编码">{{ store.modelCode }}</el-descriptions-item>
          <el-descriptions-item label="产品名称">{{ store.modelName }}</el-descriptions-item>
          <el-descriptions-item label="配置类型">{{ store.configType }}</el-descriptions-item>
          <el-descriptions-item label="已选属性">{{ store.selectionCount }} 项</el-descriptions-item>
        </el-descriptions>
      </el-card>

      <!-- 已选属性详情 -->
      <el-card class="section-card">
        <template #header>
          <span class="card-title">已选属性配置</span>
        </template>
        <el-descriptions :column="2" border>
          <el-descriptions-item
            v-for="(value, key) in store.selections"
            :key="key"
            :label="key"
          >{{ value }}</el-descriptions-item>
        </el-descriptions>
        <el-empty v-if="store.selectionCount === 0" description="未选择任何属性" :image-size="80" />
      </el-card>

      <!-- 验证结果 -->
      <el-card v-if="store.validationResult" class="section-card">
        <template #header>
          <span class="card-title">配置验证</span>
        </template>
        <el-alert
          :type="validationAlertType"
          :title="validationTitle"
          :closable="false"
          show-icon
        />
        <div v-if="store.validationResult.errors && store.validationResult.errors.length > 0" style="margin-top:12px">
          <p class="sub-label">错误信息：</p>
          <el-tag v-for="(err, i) in store.validationResult.errors" :key="i" type="danger" style="margin:2px">{{ err }}</el-tag>
        </div>
        <div v-if="store.validationResult.warnings && store.validationResult.warnings.length > 0" style="margin-top:12px">
          <p class="sub-label">警告信息：</p>
          <el-tag v-for="(warn, i) in store.validationResult.warnings" :key="i" type="warning" style="margin:2px">{{ warn }}</el-tag>
        </div>
      </el-card>

      <!-- MBOM 明细 -->
      <el-card v-if="store.mbomLines && store.mbomLines.length > 0" class="section-card">
        <template #header>
          <span class="card-title">制造BOM明细（{{ store.mbomLines.length }} 行）</span>
        </template>
        <el-table :data="store.mbomLines" border stripe size="small" max-height="400">
          <el-table-column prop="lineNumber" label="行号" width="70" align="center" />
          <el-table-column prop="materialCode" label="物料编码" min-width="130" show-overflow-tooltip />
          <el-table-column prop="materialDesc" label="物料描述" min-width="180" show-overflow-tooltip />
          <el-table-column prop="materialType" label="物料类型" width="100" />
          <el-table-column prop="quantity" label="数量" width="80" align="right" />
          <el-table-column prop="unit" label="单位" width="60" align="center" />
          <el-table-column prop="requirementType" label="需求类型" width="100" />
          <el-table-column prop="costComponent" label="成本组件" width="100" />
          <el-table-column prop="leadTimeDays" label="交期(天)" width="90" align="center" />
        </el-table>
      </el-card>
      <el-empty v-else-if="!store.mbomLines || store.mbomLines.length === 0" description="暂无制造BOM数据" :image-size="80" />

      <!-- 价格汇总 -->
      <el-card v-if="store.priceResult" class="section-card price-section">
        <template #header>
          <span class="card-title">价格汇总</span>
        </template>
        <el-descriptions :column="2" border size="large">
          <el-descriptions-item label="基础价格">
            <span class="price-value">{{ formatPrice(store.priceResult.basePrice) }}</span>
          </el-descriptions-item>
          <el-descriptions-item label="BOM成本">
            <span class="price-value">{{ formatPrice(store.priceResult.bomCost) }}</span>
          </el-descriptions-item>
          <el-descriptions-item label="最佳匹配价格">
            <span class="price-value">{{ formatPrice(store.priceResult.bestMatchPrice) }}</span>
          </el-descriptions-item>
          <el-descriptions-item label="阶梯调整价">
            <span class="price-value">{{ formatPrice(store.priceResult.tierAdjustedPrice) }}</span>
          </el-descriptions-item>
          <el-descriptions-item label="折扣">
            <span :class="store.priceResult.discountPct > 0 ? 'discount-text' : ''">
              {{ store.priceResult.discountPct }}%
            </span>
          </el-descriptions-item>
          <el-descriptions-item label="净价">
            <span class="net-price">{{ formatPrice(store.priceResult.netPrice) }}</span>
          </el-descriptions-item>
          <el-descriptions-item v-if="store.priceResult.needsApproval" label="审批状态" :span="2">
            <el-tag type="warning">需要审批 — {{ store.priceResult.approvalReason || '折扣超出审批权限' }}</el-tag>
          </el-descriptions-item>
        </el-descriptions>
        <div v-if="store.priceResult.pricingDetail" class="pricing-detail">
          <p class="sub-label">定价明细：</p>
          <pre>{{ store.priceResult.pricingDetail }}</pre>
        </div>
      </el-card>

      <!-- 底部操作栏 -->
      <div class="review-actions">
        <el-button type="primary" size="large" @click="goToGuided">
          重新配置
        </el-button>
        <el-button size="large" @click="goToConfigurator">
          前往产品配置器
        </el-button>
      </div>
    </template>
  </div>
</template>

<script setup lang="ts">
import { computed } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useConfiguratorStore } from '@/store/configurator'

const route = useRoute()
const router = useRouter()
const store = useConfiguratorStore()

/** 是否有有效数据（至少要有模型数据 + 选择） */
const hasData = computed(() => {
  return !!store.modelCode && store.modelData !== null
})

/** 验证结果警告类型 */
const validationAlertType = computed(() => {
  if (!store.validationResult) return 'info'
  switch (store.validationResult.status) {
    case 'PASS': return 'success'
    case 'SOFT_FAIL': return 'warning'
    case 'HARD_FAIL': return 'error'
    default: return 'info'
  }
})

/** 验证结果标题 */
const validationTitle = computed(() => {
  if (!store.validationResult) return '未验证'
  switch (store.validationResult.status) {
    case 'PASS': return '配置验证通过'
    case 'SOFT_FAIL': return '配置存在警告（不影响提交）'
    case 'HARD_FAIL': return '配置验证失败，请返回重新选择'
    default: return '验证状态未知'
  }
})

/** 格式化价格 */
function formatPrice(val: number | undefined | null): string {
  if (val == null) return '—'
  return '¥ ' + val.toLocaleString('zh-CN', { minimumFractionDigits: 2, maximumFractionDigits: 2 })
}

/** 重新配置 → 回到向导式配置第一页 */
function goToGuided() {
  const modelId = route.params.modelId as string
  if (modelId) {
    router.push('/configure-guided/' + modelId)
  } else {
    router.push('/configure-guided')
  }
}

/** 前往产品配置器 */
function goToConfigurator() {
  const modelId = route.params.modelId as string
  if (modelId) {
    router.push('/configure/' + modelId)
  } else {
    router.push('/configure')
  }
}
</script>

<style scoped lang="scss">
.config-review {
  max-width: 960px;
  margin: 0 auto;
  padding-bottom: 32px;

  .section-card {
    margin-bottom: 20px;

    .card-header {
      display: flex;
      justify-content: space-between;
      align-items: center;
    }

    .card-title {
      font-size: 16px;
      font-weight: 600;
    }
  }

  .sub-label {
    font-size: 13px;
    color: #909399;
    margin-bottom: 6px;
  }

  .price-section {
    .price-value {
      font-weight: 600;
      color: #303133;
    }
    .net-price {
      font-size: 20px;
      font-weight: 700;
      color: #f56c6c;
    }
    .discount-text {
      color: #e6a23c;
      font-weight: 600;
    }
  }

  .pricing-detail {
    margin-top: 16px;
    pre {
      background: #f5f7fa;
      padding: 12px;
      border-radius: 6px;
      font-size: 12px;
      color: #606266;
      white-space: pre-wrap;
      word-break: break-all;
    }
  }

  .review-actions {
    display: flex;
    gap: 12px;
    justify-content: center;
    margin-top: 32px;
  }
}
</style>
