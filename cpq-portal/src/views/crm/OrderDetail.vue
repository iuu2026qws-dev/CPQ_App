<template>
  <div class="cpq-page">
    <div class="back-bar">
      <el-button @click="$router.back()" text>← 返回</el-button>
      <h3 style="margin: 0">订单详情：{{ order?.orderName }}</h3>
    </div>

    <div v-loading="loading">
      <el-card v-if="order" style="margin-top: 16px">
        <el-descriptions :column="3" border title="订单信息">
          <el-descriptions-item label="订单名称">{{ order.orderName }}</el-descriptions-item>
          <el-descriptions-item label="订单编号">{{ order.orderNumber }}</el-descriptions-item>
          <el-descriptions-item label="客户">{{ order.accountName }}</el-descriptions-item>
          <el-descriptions-item label="关联合同">{{ order.contractNumber || '-' }}</el-descriptions-item>
          <el-descriptions-item label="状态">
            <el-tag :type="statusTag(order.status)">{{ order.status }}</el-tag>
          </el-descriptions-item>
          <el-descriptions-item label="金额">{{ order.amount ? '¥' + Number(order.amount).toLocaleString() : '-' }}</el-descriptions-item>
          <el-descriptions-item label="订单日期">{{ order.orderDate || '-' }}</el-descriptions-item>
          <el-descriptions-item label="创建时间">{{ order.createTime || '-' }}</el-descriptions-item>
        </el-descriptions>
      </el-card>

      <el-card style="margin-top: 16px">
        <template #header>
          <div style="display: flex; justify-content: space-between; align-items: center">
            <span>订单明细</span>
            <el-button type="primary" size="small" @click="addLine">+ 添加明细</el-button>
          </div>
        </template>
        <el-table :data="lines" border size="small">
          <el-table-column label="产品编码" width="150">
            <template #default="{ row, $index }">
              <el-input v-model="row.productCode" size="small" placeholder="产品编码" @change="calcTotal" />
            </template>
          </el-table-column>
          <el-table-column label="产品名称" min-width="160">
            <template #default="{ row, $index }">
              <el-input v-model="row.productName" size="small" placeholder="产品名称" />
            </template>
          </el-table-column>
          <el-table-column label="数量" width="120">
            <template #default="{ row }">
              <el-input-number v-model="row.quantity" :min="1" size="small" controls-position="right" @change="calcTotal" />
            </template>
          </el-table-column>
          <el-table-column label="单价" width="140">
            <template #default="{ row }">
              <el-input-number v-model="row.unitPrice" :min="0" :precision="2" size="small" controls-position="right" @change="calcTotal" />
            </template>
          </el-table-column>
          <el-table-column label="折扣(%)" width="120">
            <template #default="{ row }">
              <el-input-number v-model="row.discountPct" :min="0" :max="100" size="small" controls-position="right" @change="calcTotal" />
            </template>
          </el-table-column>
          <el-table-column label="税率(%)" width="120">
            <template #default="{ row }">
              <el-input-number v-model="row.taxRate" :min="0" :max="100" size="small" controls-position="right" @change="calcTotal" />
            </template>
          </el-table-column>
          <el-table-column label="行金额" width="140">
            <template #default="{ row }">
              {{ formatAmount(calcLineAmount(row)) }}
            </template>
          </el-table-column>
          <el-table-column label="操作" width="80">
            <template #default="{ $index }">
              <el-button size="small" type="danger" @click="removeLine($index)" :disabled="lines.length <= 1">删除</el-button>
            </template>
          </el-table-column>
        </el-table>
        <div style="margin-top: 12px; text-align: right; font-weight: bold; font-size: 16px">
          总计：¥{{ formatAmount(orderTotal) }}
        </div>
        <div style="margin-top: 12px; text-align: center">
          <el-button type="primary" @click="saveLines" :loading="saving">保存明细</el-button>
        </div>
      </el-card>
    </div>

    <el-empty v-if="!loading && !order" description="订单不存在" />
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { useRoute } from 'vue-router'
import { ElMessage } from 'element-plus'
import { getOrder, listOrderLines, addOrderLine, updateOrderLine, delOrderLine, type OrderVo, type OrderLineVo, type OrderLineBo } from '@/api/cpq/crm'

const route = useRoute()
const loading = ref(false)
const saving = ref(false)
const order = ref<OrderVo | null>(null)
const lines = ref<(OrderLineBo & { _isNew?: boolean; _original?: OrderLineVo })[]>([])

function statusTag(s: string) {
  const m: Record<string, string> = { DRAFT: 'info', CONFIRMED: 'primary', IN_PRODUCTION: 'warning', SHIPPED: 'success', COMPLETED: 'success', CANCELLED: 'danger' }
  return m[s] || 'info'
}

function calcLineAmount(row: OrderLineBo): number {
  const qty = row.quantity || 0
  const price = row.unitPrice || 0
  const discount = row.discountPct || 0
  return Math.round(qty * price * (1 - discount / 100) * 100) / 100
}

function formatAmount(v: number): string {
  return Number(v || 0).toLocaleString('zh-CN', { minimumFractionDigits: 2, maximumFractionDigits: 2 })
}

const orderTotal = computed(() => {
  return lines.value.reduce((sum, l) => sum + calcLineAmount(l), 0)
})

function calcTotal() { /* reactive triggers computed */ }

function addLine() {
  lines.value.push({ productCode: '', productName: '', quantity: 1, unitPrice: 0, discountPct: 0, taxRate: 0, orderId: Number(route.params.id), _isNew: true })
}

function removeLine(idx: number) {
  lines.value.splice(idx, 1)
}

async function loadData() {
  loading.value = true
  try {
    const id = Number(route.params.id)
    order.value = await getOrder(id)
    const existingLines = await listOrderLines(id)
    lines.value = (existingLines || []).map((l: OrderLineVo) => ({
      lineId: l.lineId,
      orderId: l.orderId,
      productCode: l.productCode,
      productName: l.productName,
      quantity: l.quantity,
      unitPrice: l.unitPrice,
      discountPct: l.discountPct,
      taxRate: l.taxRate,
      lineAmount: l.lineAmount,
      _original: l
    }))
  } catch (e: any) {
    ElMessage.error(e?.message || '加载失败')
  } finally {
    loading.value = false
  }
}

async function saveLines() {
  saving.value = true
  try {
    const orderId = Number(route.params.id)
    const currentLineIds = new Set(lines.value.filter(l => l.lineId).map(l => l.lineId))
    const originalLineIds = new Set(
      lines.value.filter(l => l._original).map(l => l._original!.lineId)
    )

    // Delete removed lines
    const toDelete = [...originalLineIds].filter(id => !currentLineIds.has(id))
    for (const lineId of toDelete) {
      await delOrderLine(lineId)
    }

    // Save each line
    for (const line of lines.value) {
      const data: OrderLineBo = {
        orderId,
        lineId: line.lineId,
        productCode: line.productCode,
        productName: line.productName,
        quantity: line.quantity,
        unitPrice: line.unitPrice,
        discountPct: line.discountPct,
        taxRate: line.taxRate,
        lineAmount: calcLineAmount(line)
      }
      if (line._isNew || !line.lineId) {
        await addOrderLine(data)
      } else {
        const orig = line._original
        if (orig && (
          orig.quantity !== line.quantity || orig.unitPrice !== line.unitPrice ||
          orig.discountPct !== line.discountPct || orig.taxRate !== line.taxRate ||
          orig.productCode !== line.productCode || orig.productName !== line.productName
        )) {
          await updateOrderLine(data)
        }
      }
    }
    ElMessage.success('保存成功')
    await loadData()
  } catch (e: any) {
    ElMessage.error(e?.message || '保存失败')
  } finally {
    saving.value = false
  }
}

onMounted(() => loadData())
</script>

<style scoped>
.cpq-page { padding: 16px; }
.back-bar { display: flex; align-items: center; gap: 12px; margin-bottom: 8px; }
</style>
