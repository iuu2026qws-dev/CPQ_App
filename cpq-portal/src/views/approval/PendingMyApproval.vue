<template>
  <div class="cpq-page">
    <div class="page-header">
      <h2>待我审批</h2>
    </div>

    <el-table v-loading="loading" :data="records" stripe>
      <el-table-column prop="record_id" label="审批编号" width="100" />
      <el-table-column label="推荐产品" width="180">
        <template #default="{ row }">{{ row.model_code }} {{ row.model_name }}</template>
      </el-table-column>
      <el-table-column prop="chain_status" label="状态" width="100" />
      <el-table-column prop="submitted_time" label="提交时间" width="160" />
      <el-table-column label="操作" width="200" fixed="right">
        <template #default="{ row }">
          <el-button size="small" type="primary" @click="handleApprove(row)">通过</el-button>
          <el-button size="small" type="danger" @click="handleReject(row)">驳回</el-button>
          <el-button size="small" link type="info" @click="handleView(row)">详情</el-button>
        </template>
      </el-table-column>
    </el-table>

    <el-pagination
      v-if="total > 0"
      v-model:current-page="pageNum"
      v-model:page-size="pageSize"
      :total="total"
      layout="total, sizes, prev, pager, next"
      @change="fetchData"
      style="margin-top: 16px; justify-content: flex-end;"
    />

    <el-empty v-if="!loading && records.length === 0" description="暂无需您审批的记录" />
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import request from '@/utils/request'
import { useUserStore } from '@/store/user'

const router = useRouter()
const userStore = useUserStore()
const loading = ref(false)
const records = ref<any[]>([])

async function fetchData() {
  loading.value = true
  try {
    const res: any = await request.get('/cpq/process/pending', { params: { approverId: userStore.userId || 1 } })
    records.value = res.rows || res.data || res || []
  } catch {
    records.value = []
  } finally {
    loading.value = false
  }
}

const currentUserId = computed(() => Number(userStore.userId) || 0)
const currentUserName = computed(() => userStore.nickname || userStore.name || '用户')

async function handleApprove(row: any) {
  try {
    await request.post('/cpq/process/approve', { chainId: row.chain_id, action: 'APPROVED' })
    ElMessage.success('已通过')
    fetchData()
  } catch { /* 错误由拦截器统一处理 */ }
}

async function handleReject(row: any) {
  try {
    const { value } = await ElMessageBox.prompt('请输入驳回原因', '驳回', { type: 'warning' })
    await request.post('/cpq/process/approve', { chainId: row.chain_id, action: 'REJECTED', comment: value || '' })
    ElMessage.success('已驳回')
    fetchData()
  } catch { /* 用户取消 */ }
}

function handleView(row: any) {
  router.push('/approval/' + row.chain_id)
}

onMounted(() => { fetchData() })
</script>

<style scoped>
.cpq-page { padding: 16px; }
.page-header { display: flex; align-items: center; justify-content: space-between; margin-bottom: 16px; }
.page-header h2 { margin: 0; font-size: 18px; font-weight: 600; color: var(--cpq-text-primary, #303133); }
</style>
