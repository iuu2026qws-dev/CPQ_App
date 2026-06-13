<template>
  <div class="cpq-page">
    <div class="toolbar"><h3 style="margin:0">批量交期查询</h3></div>
    <el-card header="批量产品添加">
      <div v-for="(item, i) in items" :key="i" style="display:flex;gap:12px;margin-bottom:8px;align-items:center">
        <el-input-number v-model="item.productId" :min="1" placeholder="产品ID" style="width:160px" />
        <el-input-number v-model="item.quantity" :min="1" placeholder="数量" style="width:120px" />
        <el-button type="danger" size="small" circle @click="items.splice(i,1)">✕</el-button>
      </div>
      <el-button @click="items.push({ productId: 1, quantity: 10 })">+ 添加产品</el-button>
      <el-button type="primary" style="margin-left:12px" @click="doBatchCheck" :disabled="items.length===0">批量检查</el-button>
    </el-card>
    <el-table v-if="batchResults.length" :data="batchResults" border style="margin-top:16px">
      <el-table-column prop="productId" label="产品ID" width="100" />
      <el-table-column label="状态" width="100">
        <template #default="{ row }"><el-tag :type="row.available?'success':'danger'" size="small">{{ row.available ? '可承诺' : '不可承诺' }}</el-tag></template>
      </el-table-column>
      <el-table-column prop="availableQuantity" label="可承诺量" />
      <el-table-column prop="requestedQuantity" label="需求量" />
      <el-table-column prop="inventoryStock" label="库存" />
      <el-table-column prop="materialAvailable" label="物料" />
      <el-table-column prop="capacityAvailable" label="产能" />
      <el-table-column prop="estimatedDays" label="预计天数" />
      <el-table-column prop="bottleneck" label="瓶颈" />
    </el-table>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import { batchCheckAtp } from '@/api/atpctp'

interface BatchItem { productId: number; quantity: number }
interface BatchResult { productId: number; available: boolean; availableQuantity: number; requestedQuantity: number; inventoryStock: number; materialAvailable: number; capacityAvailable: number; estimatedDays: number; bottleneck: string }
const items = ref<BatchItem[]>([{ productId: 1, quantity: 10 }])
const batchResults = ref<BatchResult[]>([])

async function doBatchCheck() {
  const map: Record<number, number> = {}
  items.value.forEach(i => { map[i.productId] = i.quantity })
  const res = await batchCheckAtp(map)
  batchResults.value = Object.entries(res as Record<number, any>).map(([productId, r]) => ({ productId: Number(productId), ...r }))
}
</script>
