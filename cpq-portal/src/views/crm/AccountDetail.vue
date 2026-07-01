<template>
  <div class="cpq-page">
    <div class="back-bar">
      <el-button @click="$router.back()" text>← 返回</el-button>
      <h3 style="margin: 0">客户详情：{{ account?.accountName }}</h3>
    </div>

    <div v-loading="loading">
      <el-card v-if="account" style="margin-top: 16px">
        <el-divider content-position="left">基本信息</el-divider>
        <el-descriptions :column="3" border>
          <el-descriptions-item label="客户名称">{{ account.accountName }}</el-descriptions-item>
          <el-descriptions-item label="客户编码">{{ account.accountCode }}</el-descriptions-item>
          <el-descriptions-item label="客户类型">{{ account.accountType }}</el-descriptions-item>
          <el-descriptions-item label="行业">{{ account.industry || '-' }}</el-descriptions-item>
          <el-descriptions-item label="区域">{{ account.region || '-' }}</el-descriptions-item>
        </el-descriptions>

        <el-divider content-position="left">企业信息</el-divider>
        <el-descriptions :column="3" border>
          <el-descriptions-item label="法人代表">{{ account.legalRepresentative || '-' }}</el-descriptions-item>
          <el-descriptions-item label="统一社会信用代码">{{ account.unifiedSocialCreditCode || '-' }}</el-descriptions-item>
          <el-descriptions-item label="税号">{{ account.taxId || '-' }}</el-descriptions-item>
          <el-descriptions-item label="地址" :span="3">{{ account.address || '-' }}</el-descriptions-item>
        </el-descriptions>

        <el-divider content-position="left">联系信息</el-divider>
        <el-descriptions :column="3" border>
          <el-descriptions-item label="联系人">{{ account.contactName || '-' }}</el-descriptions-item>
          <el-descriptions-item label="电话">{{ account.contactPhone || '-' }}</el-descriptions-item>
          <el-descriptions-item label="邮箱">{{ account.contactEmail || '-' }}</el-descriptions-item>
        </el-descriptions>
      </el-card>

      <el-card style="margin-top: 16px">
        <template #header>
          <div style="display: flex; justify-content: space-between; align-items: center">
            <span>关联商机</span>
            <el-link type="primary" @click="viewAll('opportunity')">查看全部</el-link>
          </div>
        </template>
        <el-table :data="opportunities" size="small" :show-overflow-tooltip="true">
          <el-table-column prop="opportunityName" label="商机名称" min-width="160" />
          <el-table-column prop="stage" label="阶段" width="120">
            <template #default="{ row }">
              <el-tag :type="stageTagType(row.stage)">{{ stageLabel(row.stage) }}</el-tag>
            </template>
          </el-table-column>
          <el-table-column prop="amount" label="金额" width="140">
            <template #default="{ row }">{{ row.amount ? '¥' + Number(row.amount).toLocaleString() : '-' }}</template>
          </el-table-column>
          <el-table-column prop="closeDate" label="关闭日期" width="120" />
        </el-table>
      </el-card>

      <el-card style="margin-top: 16px">
        <template #header>
          <div style="display: flex; justify-content: space-between; align-items: center">
            <span>关联合同</span>
            <el-link type="primary" @click="viewAll('contract')">查看全部</el-link>
          </div>
        </template>
        <el-table :data="contracts" size="small" :show-overflow-tooltip="true">
          <el-table-column prop="contractNumber" label="合同编号" width="150" />
          <el-table-column prop="contractType" label="类型" width="100" />
          <el-table-column prop="status" label="状态" width="100">
            <template #default="{ row }">
              <el-tag :type="contractStatusType(row.status)">{{ row.status }}</el-tag>
            </template>
          </el-table-column>
          <el-table-column prop="amount" label="金额" width="140">
            <template #default="{ row }">{{ row.amount ? '¥' + Number(row.amount).toLocaleString() : '-' }}</template>
          </el-table-column>
        </el-table>
      </el-card>

      <el-card style="margin-top: 16px">
        <template #header>
          <div style="display: flex; justify-content: space-between; align-items: center">
            <span>关联订单</span>
            <el-link type="primary" @click="viewAll('order')">查看全部</el-link>
          </div>
        </template>
        <el-table :data="orders" size="small" :show-overflow-tooltip="true">
          <el-table-column prop="orderNumber" label="订单编号" width="150" />
          <el-table-column prop="status" label="状态" width="100">
            <template #default="{ row }">
              <el-tag :type="orderStatusType(row.status)">{{ row.status }}</el-tag>
            </template>
          </el-table-column>
          <el-table-column prop="amount" label="金额" width="140">
            <template #default="{ row }">{{ row.amount ? '¥' + Number(row.amount).toLocaleString() : '-' }}</template>
          </el-table-column>
          <el-table-column prop="orderDate" label="日期" width="120" />
        </el-table>
      </el-card>
    </div>

    <el-empty v-if="!loading && !account" description="客户信息不存在" />
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { getAccount, type AccountVo } from '@/api/cpq/crm'
import { listOpportunities, type OpportunityVo } from '@/api/cpq/crm'
import { listContracts, type ContractVo } from '@/api/cpq/crm'
import { listOrders, type OrderVo } from '@/api/cpq/crm'

const route = useRoute()
const router = useRouter()
const loading = ref(false)
const account = ref<AccountVo | null>(null)
const opportunities = ref<OpportunityVo[]>([])
const contracts = ref<ContractVo[]>([])
const orders = ref<OrderVo[]>([])

const stageColorMap: Record<string, string> = {
  PROSPECTING: 'info', QUALIFICATION: '', PROPOSAL: 'warning',
  NEGOTIATION: 'primary', CLOSED_WON: 'success', CLOSED_LOST: 'danger'
}
const stageLabelMap: Record<string, string> = {
  PROSPECTING: '寻找线索', QUALIFICATION: '资质审核', PROPOSAL: '方案建议',
  NEGOTIATION: '谈判中', CLOSED_WON: '赢单', CLOSED_LOST: '输单'
}
function stageTagType(s: string) { return stageColorMap[s] || 'info' }
function stageLabel(s: string) { return stageLabelMap[s] || s }

function contractStatusType(s: string) {
  const m: Record<string, string> = { DRAFT: 'info', ACTIVE: 'success', TERMINATED: 'danger', EXPIRED: 'warning' }
  return m[s] || 'info'
}
function orderStatusType(s: string) {
  const m: Record<string, string> = { DRAFT: 'info', CONFIRMED: 'primary', IN_PRODUCTION: 'warning', SHIPPED: 'success', COMPLETED: 'success', CANCELLED: 'danger' }
  return m[s] || 'info'
}

function viewAll(type: string) {
  if (type === 'opportunity') router.push('/crm/opportunity')
  else if (type === 'contract') router.push('/crm/contract')
  else if (type === 'order') router.push('/crm/order')
}

async function loadData() {
  loading.value = true
  try {
    const id = Number(route.params.id)
    const [acc, oppRes, conRes, ordRes] = await Promise.all([
      getAccount(id),
      listOpportunities({ accountId: id, pageSize: 5 }),
      listContracts({ accountId: id, pageSize: 5 }),
      listOrders({ accountId: id, pageSize: 5 })
    ])
    account.value = acc
    opportunities.value = oppRes.rows || []
    contracts.value = conRes.rows || []
    orders.value = ordRes.rows || []
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
