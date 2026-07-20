<template>
  <div class="cpq-page">
    <div class="toolbar">
      <el-button @click="$router.back()">返回</el-button>
      <el-button type="warning" @click="$router.push(`/quoting/${route.params.id}/versions`)">版本对比</el-button>
      <el-button @click="showTemplateSelector = true">
        {{ selectedTemplate ? `模板: ${selectedTemplate.templateName}` : '选择模板' }}
      </el-button>
      <el-button type="primary" @click="handlePreview">预览报价单</el-button>
    </div>

    <el-descriptions v-if="store.currentQuote" :column="2" border>
      <el-descriptions-item label="报价单号">{{ store.currentQuote.quoteNumber }}</el-descriptions-item>
      <el-descriptions-item label="客户">{{ store.currentQuote.accountName }}</el-descriptions-item>
      <el-descriptions-item label="状态">
        <el-tag>{{ store.currentQuote.status }}</el-tag>
      </el-descriptions-item>
      <el-descriptions-item label="类型">{{ store.currentQuote.quoteType }}</el-descriptions-item>
      <el-descriptions-item label="总金额">{{ store.currentQuote.grandTotal ? '¥' + Number(store.currentQuote.grandTotal).toLocaleString() : '-' }}</el-descriptions-item>
      <el-descriptions-item label="币种">{{ store.currentQuote.currency }}</el-descriptions-item>
    </el-descriptions>

    <h3 style="margin-top:20px">行项目</h3>
    <el-button type="primary" size="small" @click="openLineDialog" style="margin-bottom:10px">添加行项目</el-button>
    <el-table :data="store.lineItems" stripe>
      <el-table-column prop="lineNumber" label="#" width="60" />
      <el-table-column prop="itemName" label="物料名称" min-width="160" />
      <el-table-column prop="itemCode" label="物料编码" min-width="120" />
      <el-table-column prop="itemType" label="类型" width="100" />
      <el-table-column prop="quantity" label="数量" width="80" />
      <el-table-column prop="unitPrice" label="单价" width="100">
        <template #default="{ row }">{{ row.unitPrice ? '¥' + Number(row.unitPrice).toLocaleString() : '-' }}</template>
      </el-table-column>
      <el-table-column prop="lineTotal" label="行总计" width="120">
        <template #default="{ row }">{{ row.lineTotal ? '¥' + Number(row.lineTotal).toLocaleString() : '-' }}</template>
      </el-table-column>
      <el-table-column label="操作" width="100">
        <template #default="{ row }">
          <el-button size="small" type="danger" @click="handleDelLine(row)">删除</el-button>
        </template>
      </el-table-column>
    </el-table>

    <el-dialog v-model="showLineDialog" title="添加行项目" width="520px" @closed="resetLineForm">
      <el-form :model="lineForm" label-width="90px">
        <el-form-item label="选择产品" required>
          <el-select
            v-model="lineForm.modelId"
            filterable
            remote
            reserve-keyword
            placeholder="输入产品名称或编码搜索"
            :remote-method="searchProducts"
            :loading="productSearchLoading"
            clearable
            @change="onProductSelect"
            style="width:100%"
          >
            <el-option
              v-for="item in productOptions"
              :key="item.modelId"
              :label="`${item.modelCode} - ${item.modelName}`"
              :value="item.modelId"
            />
          </el-select>
        </el-form-item>
        <el-form-item label="物料名称">
          <el-input v-model="lineForm.itemName" readonly placeholder="选择产品后自动填充" />
        </el-form-item>
        <el-form-item label="物料编码">
          <el-input v-model="lineForm.itemCode" readonly placeholder="选择产品后自动填充" />
        </el-form-item>
        <el-form-item label="类型">
          <el-select v-model="lineForm.itemType">
            <el-option label="产品" value="PRODUCT" />
            <el-option label="配件" value="ACCESSORY" />
            <el-option label="服务" value="SERVICE" />
          </el-select>
        </el-form-item>
        <el-form-item label="数量" required>
          <el-input-number v-model="lineForm.quantity" :min="1" />
        </el-form-item>
        <el-form-item label="单价">
          <el-input-number v-model="lineForm.unitPrice" :min="0" :precision="2" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="showLineDialog = false">取消</el-button>
        <el-button type="primary" @click="handleAddLine" :disabled="!lineForm.modelId">确定</el-button>
      </template>
    </el-dialog>

    <!-- 报价单预览 -->
    <QuotePreview v-model="showPreview" :quote="store.currentQuote" :line-items="store.lineItems" :template-id="selectedTemplate?.templateId" />

    <!-- 模板选择器 -->
    <TemplateSelector v-model="showTemplateSelector" @select="onTemplateSelected" />
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { useRoute } from 'vue-router'
import { ElMessage } from 'element-plus'
import { useQuoteStore } from '@/store/quote'
import { searchModel, type CpqProductModelVo } from '@/api/cpq/product'
import QuotePreview from '@/components/quoting/QuotePreview.vue'
import TemplateSelector from '@/components/quoting/TemplateSelector.vue'
import type { TemplateVo } from '@/api/quoting'

const route = useRoute()
const store = useQuoteStore()
const showLineDialog = ref(false)
const showPreview = ref(false)
const showTemplateSelector = ref(false)
const selectedTemplate = ref<TemplateVo | null>(null)

const productOptions = ref<CpqProductModelVo[]>([])
const productSearchLoading = ref(false)

const defaultLineForm = { modelId: null as number | null, itemName: '', itemCode: '', itemType: 'PRODUCT', quantity: 1, unitPrice: 0 }
const lineForm = reactive({ ...defaultLineForm })

function resetLineForm() {
  Object.assign(lineForm, defaultLineForm)
  productOptions.value = []
}

function openLineDialog() {
  resetLineForm()
  showLineDialog.value = true
  // 打开时自动加载首批产品列表
  searchProducts('')
}

async function searchProducts(keyword: string) {
  productSearchLoading.value = true
  try {
    const res = await searchModel(keyword)
    productOptions.value = Array.isArray(res) ? res : (res.rows || ((res as unknown as { data: CpqProductModelVo[] }).data || []))
  } finally {
    productSearchLoading.value = false
  }
}

function onProductSelect(modelId: number | null) {
  if (!modelId) {
    lineForm.itemName = ''
    lineForm.itemCode = ''
    lineForm.unitPrice = 0
    return
  }
  const product = productOptions.value.find(p => p.modelId === modelId)
  if (product) {
    lineForm.itemName = product.modelName || ''
    lineForm.itemCode = product.modelCode || ''
    lineForm.unitPrice = product.basePrice || 0
    // 根据 configType 推断 itemType
    if (product.configType === 'SERVICE') {
      lineForm.itemType = 'SERVICE'
    } else {
      lineForm.itemType = 'PRODUCT'
    }
  }
}

function onTemplateSelected(template: TemplateVo) {
  selectedTemplate.value = template
  ElMessage.success(`已选择模板：${template.templateName}`)
}

function handlePreview() {
  if (!selectedTemplate.value) {
    ElMessage.warning('请先选择报价模板')
    showTemplateSelector.value = true
    return
  }
  showPreview.value = true
}

onMounted(async () => {
  const id = route.params.id as string
  if (id) {
    await store.fetchQuote(id)
    await store.fetchLineItems(id)
  }
})

async function handleAddLine() {
  if (!lineForm.modelId) {
    ElMessage.warning('请先选择产品')
    return
  }
  try {
    await store.createLineItem({
      quoteId: store.currentQuote?.quoteId,
      modelId: lineForm.modelId,
      itemName: lineForm.itemName,
      itemCode: lineForm.itemCode,
      itemType: lineForm.itemType,
      quantity: lineForm.quantity,
      unitPrice: lineForm.unitPrice
    })
    ElMessage.success('添加成功')
    showLineDialog.value = false
    if (store.currentQuote) await store.fetchLineItems(store.currentQuote.quoteId)
  } catch (e: any) {
    ElMessage.error(e?.message || '添加失败')
  }
}

async function handleDelLine(row: Record<string, unknown>) {
  await store.removeLineItem(row.lineId as string)
  ElMessage.success('删除成功')
  if (store.currentQuote) await store.fetchLineItems(store.currentQuote.quoteId)
}
</script>

<style scoped>
.cpq-page { padding: 16px; }
.toolbar { margin-bottom: 12px; }
</style>
