<template>
  <div class="competitive-manager">
    <div class="page-header">
      <h2>竞品对标</h2>
      <p class="subtitle">竞品库管理、产品对比分析与推荐策略</p>
    </div>

    <el-tabs v-model="activeTab">
      <el-tab-pane label="竞品库" name="competitor">
        <div class="toolbar">
          <el-button type="primary" size="small" @click="handleAddCompetitor">新增竞品</el-button>
        </div>
        <el-table :data="competitorList" stripe v-loading="loading" empty-text="暂无数据">
          <el-table-column prop="competitorId" label="ID" width="80" />
          <el-table-column prop="competitorName" label="竞品名称" />
          <el-table-column prop="competitorCode" label="编码" width="120" />
          <el-table-column prop="industry" label="行业" width="100" />
          <el-table-column prop="website" label="官网" min-width="180" />
          <el-table-column prop="marketShare" label="市场份额(%)" width="110" />
          <el-table-column label="操作" width="150" fixed="right">
            <template #default="{ row }">
              <el-button size="small" @click="handleEditCompetitor(row)">编辑</el-button>
              <el-button size="small" type="danger" @click="handleDeleteCompetitor(row)">删除</el-button>
            </template>
          </el-table-column>
        </el-table>
      </el-tab-pane>

      <el-tab-pane label="竞品产品" name="product">
        <div class="toolbar">
          <el-button type="primary" size="small" @click="handleAddProduct">新增竞品产品</el-button>
        </div>
        <el-table :data="productList" stripe v-loading="loading2" empty-text="暂无数据">
          <el-table-column prop="productId" label="ID" width="80" />
          <el-table-column prop="productName" label="产品名称" />
          <el-table-column prop="productCode" label="编码" width="120" />
          <el-table-column prop="category" label="品类" width="100" />
          <el-table-column prop="basePrice" label="基准价" width="100" />
          <el-table-column prop="strengths" label="优势" min-width="150" />
          <el-table-column label="操作" width="150" fixed="right">
            <template #default="{ row }">
              <el-button size="small" @click="handleEditProduct(row)">编辑</el-button>
              <el-button size="small" type="danger" @click="handleDeleteProduct(row)">删除</el-button>
            </template>
          </el-table-column>
        </el-table>
      </el-tab-pane>

      <el-tab-pane label="推荐策略" name="recommendation">
        <div class="toolbar">
          <el-button type="primary" size="small" @click="handleAddRecommendation">新增策略</el-button>
        </div>
        <el-table :data="recList" stripe v-loading="loading4" empty-text="暂无数据">
          <el-table-column prop="recommendationId" label="ID" width="80" />
          <el-table-column prop="scenario" label="场景" />
          <el-table-column prop="strategyType" label="策略类型" width="120" />
          <el-table-column prop="strategyDesc" label="策略描述" min-width="200" />
          <el-table-column prop="priority" label="优先级" width="80" />
          <el-table-column label="操作" width="150" fixed="right">
            <template #default="{ row }">
              <el-button size="small" @click="handleEditRecommendation(row)">编辑</el-button>
              <el-button size="small" type="danger" @click="handleDeleteRecommendation(row)">删除</el-button>
            </template>
          </el-table-column>
        </el-table>
      </el-tab-pane>
    </el-tabs>

    <el-dialog :title="dialogTitle" v-model="dialogVisible" width="560px">
      <el-form :model="dialogForm" label-width="100px">
        <template v-if="activeTab === 'competitor'">
          <el-form-item label="竞品名称"><el-input v-model="dialogForm.competitorName" /></el-form-item>
          <el-form-item label="竞品编码"><el-input v-model="dialogForm.competitorCode" /></el-form-item>
          <el-form-item label="行业"><el-input v-model="dialogForm.industry" /></el-form-item>
          <el-form-item label="官网"><el-input v-model="dialogForm.website" /></el-form-item>
          <el-form-item label="市场份额"><el-input-number v-model="dialogForm.marketShare" :min="0" :max="100" /></el-form-item>
          <el-form-item label="描述"><el-input v-model="dialogForm.description" type="textarea" /></el-form-item>
        </template>
        <template v-else-if="activeTab === 'product'">
          <el-form-item label="产品名称"><el-input v-model="dialogForm.productName" /></el-form-item>
          <el-form-item label="产品编码"><el-input v-model="dialogForm.productCode" /></el-form-item>
          <el-form-item label="品类"><el-input v-model="dialogForm.category" /></el-form-item>
          <el-form-item label="基准价"><el-input-number v-model="dialogForm.basePrice" :min="0" /></el-form-item>
          <el-form-item label="优势"><el-input v-model="dialogForm.strengths" type="textarea" /></el-form-item>
          <el-form-item label="劣势"><el-input v-model="dialogForm.weaknesses" type="textarea" /></el-form-item>
        </template>
        <template v-else>
          <el-form-item label="场景"><el-input v-model="dialogForm.scenario" /></el-form-item>
          <el-form-item label="策略类型"><el-input v-model="dialogForm.strategyType" /></el-form-item>
          <el-form-item label="策略描述"><el-input v-model="dialogForm.strategyDesc" type="textarea" /></el-form-item>
          <el-form-item label="优先级"><el-input-number v-model="dialogForm.priority" :min="1" :max="10" /></el-form-item>
        </template>
      </el-form>
      <template #footer>
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" @click="handleDialogSubmit" :loading="submitting">确定</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { getCompetitorList, addCompetitor, updateCompetitor, deleteCompetitor } from '@/api/cpq/competitive'
import { getCompetitorProductList, addCompetitorProduct, updateCompetitorProduct, deleteCompetitorProduct } from '@/api/cpq/competitive'
import { getRecommendationList, addRecommendation, updateRecommendation, deleteRecommendation } from '@/api/cpq/competitive'

const activeTab = ref('competitor')
const loading = ref(false), loading2 = ref(false), loading4 = ref(false)
const submitting = ref(false)
const competitorList = ref<any[]>([])
const productList = ref<any[]>([])
const recList = ref<any[]>([])
const dialogVisible = ref(false)
const isEdit = ref(false)
const dialogForm = ref<any>({})

const dialogTitle = computed(() => {
  const labels: Record<string, string> = { competitor: '竞品', product: '竞品产品', recommendation: '推荐策略' }
  return (isEdit.value ? '编辑' : '新增') + (labels[activeTab.value] || '')
})

async function fetchAll() {
  loading.value = true; loading2.value = true; loading4.value = true
  try {
    const [c, p, r] = await Promise.all([getCompetitorList(), getCompetitorProductList(), getRecommendationList()])
    competitorList.value = Array.isArray(c) ? c : (c.rows || c.data || [])
    productList.value = Array.isArray(p) ? p : (p.rows || p.data || [])
    recList.value = Array.isArray(r) ? r : (r.rows || r.data || [])
  } catch { /* ignore */ }
  finally { loading.value = loading2.value = loading4.value = false }
}

// Competitor handlers
function handleAddCompetitor() { isEdit.value = false; dialogForm.value = {}; dialogVisible.value = true; activeTab.value = 'competitor' }
function handleEditCompetitor(row: any) { isEdit.value = true; dialogForm.value = { ...row }; dialogVisible.value = true }
async function handleDeleteCompetitor(row: any) {
  try { await ElMessageBox.confirm('确认删除？', '提示', { type: 'warning' }); await deleteCompetitor(String(row.competitorId)); ElMessage.success('删除成功'); fetchAll() } catch { /* */ }
}

// Product handlers
function handleAddProduct() { isEdit.value = false; dialogForm.value = {}; dialogVisible.value = true; activeTab.value = 'product' }
function handleEditProduct(row: any) { isEdit.value = true; dialogForm.value = { ...row }; dialogVisible.value = true }
async function handleDeleteProduct(row: any) {
  try { await ElMessageBox.confirm('确认删除？', '提示', { type: 'warning' }); await deleteCompetitorProduct(String(row.productId)); ElMessage.success('删除成功'); fetchAll() } catch { /* */ }
}

// Recommendation handlers
function handleAddRecommendation() { isEdit.value = false; dialogForm.value = {}; dialogVisible.value = true; activeTab.value = 'recommendation' }
function handleEditRecommendation(row: any) { isEdit.value = true; dialogForm.value = { ...row }; dialogVisible.value = true }
async function handleDeleteRecommendation(row: any) {
  try { await ElMessageBox.confirm('确认删除？', '提示', { type: 'warning' }); await deleteRecommendation(String(row.recommendationId)); ElMessage.success('删除成功'); fetchAll() } catch { /* */ }
}

async function handleDialogSubmit() {
  submitting.value = true
  try {
    const tab = activeTab.value
    if (isEdit.value) {
      if (tab === 'competitor') await updateCompetitor(dialogForm.value)
      else if (tab === 'product') await updateCompetitorProduct(dialogForm.value)
      else await updateRecommendation(dialogForm.value)
    } else {
      if (tab === 'competitor') await addCompetitor(dialogForm.value)
      else if (tab === 'product') await addCompetitorProduct(dialogForm.value)
      else await addRecommendation(dialogForm.value)
    }
    ElMessage.success(isEdit.value ? '修改成功' : '新增成功')
    dialogVisible.value = false
    fetchAll()
  } catch { ElMessage.error('操作失败') }
  finally { submitting.value = false }
}

onMounted(fetchAll)
</script>

<style scoped lang="scss">
.page-header { margin-bottom: 16px; h2 { margin: 0; } .subtitle { color: #909399; font-size: 13px; } }
.toolbar { margin-bottom: 12px; }
</style>
