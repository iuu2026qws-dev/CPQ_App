<template>
  <div class="cpq-page">
    <div class="back-bar">
      <el-button @click="$router.back()" text>← 返回</el-button>
      <h3 style="margin: 0">合同详情：{{ contract?.contractName }}</h3>
    </div>

    <div v-loading="loading">
      <el-card v-if="contract" style="margin-top: 16px">
        <el-descriptions :column="3" border title="合同信息">
          <el-descriptions-item label="合同名称">{{ contract.contractName }}</el-descriptions-item>
          <el-descriptions-item label="合同编号">{{ contract.contractNumber }}</el-descriptions-item>
          <el-descriptions-item label="客户">{{ contract.accountName }}</el-descriptions-item>
          <el-descriptions-item label="类型">
            <el-tag :type="typeTag(contract.contractType)">{{ typeLabel(contract.contractType) }}</el-tag>
          </el-descriptions-item>
          <el-descriptions-item label="状态">
            <el-tag :type="statusTag(contract.status)">{{ contract.status }}</el-tag>
          </el-descriptions-item>
          <el-descriptions-item label="金额">{{ contract.amount ? '¥' + Number(contract.amount).toLocaleString() : '-' }}</el-descriptions-item>
          <el-descriptions-item label="开始日期">{{ contract.startDate || '-' }}</el-descriptions-item>
          <el-descriptions-item label="结束日期">{{ contract.endDate || '-' }}</el-descriptions-item>
          <el-descriptions-item label="签约主体">{{ contract.signingEntity || '-' }}</el-descriptions-item>
          <el-descriptions-item label="付款条款" :span="2">{{ contract.paymentTerms || '-' }}</el-descriptions-item>
          <el-descriptions-item label="负责人">{{ contract.ownerName || '-' }}</el-descriptions-item>
          <el-descriptions-item label="关联商机">{{ contract.opportunityName || '-' }}</el-descriptions-item>
          <el-descriptions-item label="创建时间">{{ contract.createTime || '-' }}</el-descriptions-item>
        </el-descriptions>
      </el-card>

      <el-card style="margin-top: 16px">
        <template #header><span>产品明细</span></template>
        <el-table :data="productLines" border size="small">
          <el-table-column prop="productCode" label="产品编码" width="150" />
          <el-table-column prop="productName" label="产品名称" min-width="160" />
          <el-table-column prop="quantity" label="数量" width="100" />
          <el-table-column prop="unitPrice" label="单价" width="140">
            <template #default="{ row }">¥{{ Number(row.unitPrice || 0).toLocaleString() }}</template>
          </el-table-column>
          <el-table-column label="小计" width="140">
            <template #default="{ row }">¥{{ Number((row.quantity || 0) * (row.unitPrice || 0)).toLocaleString() }}</template>
          </el-table-column>
        </el-table>
      </el-card>

      <el-card style="margin-top: 16px">
        <template #header><span>关联订单</span></template>
        <el-table :data="orders" border size="small" :show-overflow-tooltip="true">
          <el-table-column prop="orderNumber" label="订单编号" width="150">
            <template #default="{ row }">
              <el-link type="primary" @click="$router.push('/crm/order/' + row.orderId)">{{ row.orderNumber }}</el-link>
            </template>
          </el-table-column>
          <el-table-column prop="orderName" label="订单名称" min-width="160" />
          <el-table-column prop="status" label="状态" width="100">
            <template #default="{ row }">
              <el-tag :type="orderStatusTag(row.status)">{{ row.status }}</el-tag>
            </template>
          </el-table-column>
          <el-table-column prop="amount" label="金额" width="140">
            <template #default="{ row }">{{ row.amount ? '¥' + Number(row.amount).toLocaleString() : '-' }}</template>
          </el-table-column>
          <el-table-column prop="orderDate" label="日期" width="120" />
        </el-table>
      </el-card>
    </div>

    <el-empty v-if="!loading && !contract" description="合同不存在" />
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useRoute } from 'vue-router'
import { ElMessage } from 'element-plus'
import { getContract, listOrders, type ContractVo, type OrderVo, type ContractLineBo } from '@/api/cpq/crm'

const route = useRoute()
const loading = ref(false)
const contract = ref<ContractVo | null>(null)
const orders = ref<OrderVo[]>([])
const productLines = ref<ContractLineBo[]>([])

function typeTag(t: string) { const m: Record<string, string> = { PROJECT: 'primary', FRAMEWORK: 'success', SUPPLEMENT: 'warning' }; return m[t] || 'info' }
function typeLabel(t: string) { const m: Record<string, string> = { PROJECT: '项目合同', FRAMEWORK: '框架合同', SUPPLEMENT: '补充协议' }; return m[t] || t }
function statusTag(s: string) { const m: Record<string, string> = { DRAFT: 'info', ACTIVE: 'success', TERMINATED: 'danger', EXPIRED: 'warning' }; return m[s] || 'info' }
function orderStatusTag(s: string) { const m: Record<string, string> = { DRAFT: 'info', CONFIRMED: 'primary', IN_PRODUCTION: 'warning', SHIPPED: 'success', COMPLETED: 'success', CANCELLED: 'danger' }; return m[s] || 'info' }

async function loadData() {
  loading.value = true
  try {
    const id = String(route.params.id)
    contract.value = await getContract(id)
    // Product lines might come from contract detail or a separate API
    productLines.value = (contract.value as any)?.lines || []
    try {
      const res = await listOrders({ contractId: id })
      orders.value = res.rows || []
    } catch { /* ignore */ }
  } catch (e: any) {
    ElMessage.error(e?.message || '加载失败')
  } finally {
    loading.value = false
  }
}

onMounted(() => loadData())
</script>

<style scoped>
.cpq-page { padding: 16px; }
.back-bar { display: flex; align-items: center; gap: 12px; margin-bottom: 8px; }
</style>
