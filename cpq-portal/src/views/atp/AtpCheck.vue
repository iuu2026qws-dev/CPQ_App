<template>
  <div class="cpq-page">
    <div class="toolbar"><h3 style="margin:0">ATP 交期检查</h3></div>
    <el-form :inline="true">
      <el-form-item label="产品">
        <el-select
          v-model="productId"
          filterable
          remote
          reserve-keyword
          placeholder="输入产品名称或编码搜索"
          :remote-method="searchProducts"
          :loading="searchLoading"
          clearable
          style="width:260px"
        >
          <el-option
            v-for="item in productOptions"
            :key="item.modelId"
            :label="`${item.modelCode} - ${item.modelName}`"
            :value="item.modelId"
          />
        </el-select>
      </el-form-item>
      <el-form-item label="需求数量"><el-input-number v-model="quantity" :min="1" /></el-form-item>
      <el-form-item><el-button type="primary" @click="doCheck">检查</el-button></el-form-item>
    </el-form>
    <div v-if="result" class="result-area">
      <AtpIndicator :available="result.available" :quantity="result.requestedQuantity" />
      <el-descriptions :column="2" border style="margin-top:16px">
        <el-descriptions-item label="可承诺量">{{ result.availableQuantity }}</el-descriptions-item>
        <el-descriptions-item label="请求数量">{{ result.requestedQuantity }}</el-descriptions-item>
        <el-descriptions-item label="库存可用量">{{ result.inventoryStock }}</el-descriptions-item>
        <el-descriptions-item label="物料可用量">{{ result.materialAvailable }}</el-descriptions-item>
        <el-descriptions-item label="产能可用量">{{ result.capacityAvailable }}</el-descriptions-item>
        <el-descriptions-item label="瓶颈">{{ result.bottleneck || '无' }}</el-descriptions-item>
        <el-descriptions-item label="预计交期天数">{{ result.estimatedDays }} 天</el-descriptions-item>
      </el-descriptions>
      <div v-if="result.warnings && result.warnings.length" style="margin-top:12px">
        <el-alert v-for="w in result.warnings" :key="w" :title="w" type="warning" show-icon style="margin-bottom:6px" />
      </div>
      <!-- CTP推算 -->
      <el-button type="success" style="margin-top:12px" @click="doCtp">CTP交期推算</el-button>
      <div v-if="ctpResult" style="margin-top:16px">
        <DeliveryTimeline v-if="ctpResult.milestones" :milestones="ctpResult.milestones" />
        <el-descriptions :column="2" border style="margin-top:16px">
          <el-descriptions-item label="最早交付日期">{{ ctpResult.deliveryDate }}</el-descriptions-item>
          <el-descriptions-item label="交期天数">{{ ctpResult.deliveryDays }} 天</el-descriptions-item>
          <el-descriptions-item label="产能余量">{{ ctpResult.capacityRemaining }}</el-descriptions-item>
          <el-descriptions-item label="物料齐套天数">{{ ctpResult.materialReadinessDays }}</el-descriptions-item>
          <el-descriptions-item label="瓶颈工序天数">{{ ctpResult.bottleneckProcessDays }}</el-descriptions-item>
        </el-descriptions>
      </div>
      <!-- 替代方案 -->
      <el-button type="warning" style="margin-top:12px" @click="doAlternative" :disabled="result?.available">推荐替代方案</el-button>
      <el-table v-if="alternatives.length" :data="alternatives" style="margin-top:12px" border size="small">
        <el-table-column prop="productName" label="产品名称" />
        <el-table-column prop="availableQuantity" label="可用数量" />
        <el-table-column prop="deliveryDays" label="交期天数" />
        <el-table-column prop="reason" label="推荐原因" />
        <el-table-column label="价格差异">
          <template #default="{ row }">{{ row.priceDifference > 0 ? '+' : '' }}{{ row.priceDifference }}</template>
        </el-table-column>
      </el-table>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import { checkAtp, calculateCtp, recommendAlternative } from '@/api/atpctp'
import type { AtpResult, CtpResult, AlternativeRecommendation } from '@/api/atpctp'
import { searchModel } from '@/api/cpq/product'
import type { CpqProductModelVo } from '@/api/cpq/product'
import AtpIndicator from '@/components/atp/AtpIndicator.vue'
import DeliveryTimeline from '@/components/atp/DeliveryTimeline.vue'

const productId = ref<number | null>(null)
const quantity = ref(10)
const productOptions = ref<CpqProductModelVo[]>([])
const searchLoading = ref(false)
const result = ref<AtpResult | null>(null)
const ctpResult = ref<CtpResult | null>(null)
const alternatives = ref<AlternativeRecommendation[]>([])

async function searchProducts(keyword: string) {
  searchLoading.value = true
  try {
    const res = await searchModel(keyword)
    productOptions.value = Array.isArray(res) ? res : (res.rows || ((res as any).data || []))
  } finally {
    searchLoading.value = false
  }
}

async function doCheck() {
  if (!productId.value) return
  result.value = await checkAtp(productId.value, quantity.value); ctpResult.value = null; alternatives.value = []
}
async function doCtp() {
  if (!productId.value) return
  ctpResult.value = await calculateCtp(productId.value, quantity.value)
}
async function doAlternative() {
  if (!productId.value) return
  alternatives.value = await recommendAlternative(productId.value, quantity.value)
}
</script>

<style scoped>.result-area { margin-top:16px; }</style>
