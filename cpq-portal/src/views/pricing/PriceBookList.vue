<template>
  <div class="price-book-list">
    <div class="page-header">
      <h2>价格手册</h2>
      <p class="subtitle">管理标准/渠道/促销/区域价格手册及其条目</p>
    </div>
    <el-row :gutter="16">
      <el-col :span="8">
        <el-card shadow="never">
          <template #header>
            <div class="card-header">
              <strong>价格手册</strong>
              <el-button type="primary" size="small" @click="onAddBook">新增</el-button>
            </div>
          </template>
          <el-table :data="books" stripe v-loading="bookLoading" highlight-current-row @current-change="onBookSelect" empty-text="暂无价格手册">
            <el-table-column prop="bookName" label="手册名称" />
            <el-table-column prop="bookType" label="类型" width="90">
              <template #default="{ row }"><el-tag size="small">{{ bookTypeLabel(row.bookType) }}</el-tag></template>
            </el-table-column>
            <el-table-column prop="currency" label="币种" width="70" />
            <el-table-column label="操作" width="100" fixed="right">
              <template #default="{ row }">
                <el-button link size="small" @click.stop="onEditBook(row)">编辑</el-button>
                <el-button link size="small" type="danger" @click.stop="onDeleteBook(row)">删除</el-button>
              </template>
            </el-table-column>
          </el-table>
        </el-card>
      </el-col>
      <el-col :span="16">
        <el-card shadow="never">
          <template #header>
            <div class="card-header">
              <strong>{{ selectedBook?.bookName || '请选择价格手册' }} — 条目</strong>
              <el-button v-if="selectedBook" type="primary" size="small" @click="onAddEntry">新增条目</el-button>
            </div>
          </template>
          <el-table :data="entries" stripe v-loading="entryLoading" empty-text="请先选择左侧价格手册">
            <el-table-column label="产品" width="180">
              <template #default="{ row }">
                {{ modelLabel(row.modelId) }}
              </template>
            </el-table-column>
            <el-table-column label="变体" width="180">
              <template #default="{ row }">
                <span v-if="row.variantCode">{{ row.variantCode }} - {{ row.variantName }}</span>
                <span v-else style="color:#9ca3af;font-size:12px">模型级定价</span>
              </template>
            </el-table-column>
            <el-table-column prop="itemCode" label="物料编码" width="130">
              <template #default="{ row }">{{ row.itemCode || '-' }}</template>
            </el-table-column>
            <el-table-column prop="listPrice" label="目录价" width="120" />
            <el-table-column prop="costPrice" label="成本价" width="120" />
            <el-table-column prop="minPrice" label="最低价" width="120" />
            <el-table-column prop="regionCode" label="区域" width="100" />
            <el-table-column prop="channelCode" label="渠道" width="100" />
            <el-table-column prop="status" label="状态" width="80" />
            <el-table-column label="操作" width="140" fixed="right">
              <template #default="{ row }">
                <el-button link size="small" @click="onEditEntry(row)">编辑</el-button>
                <el-button link size="small" type="danger" @click="onDeleteEntry(row)">删除</el-button>
              </template>
            </el-table-column>
          </el-table>
        </el-card>
      </el-col>
    </el-row>

    <!-- Book Dialog -->
    <el-dialog v-model="bookDialog.visible" :title="bookDialog.isEdit ? '编辑价格手册' : '新增价格手册'" width="500px">
      <el-form :model="bookForm" label-width="90px">
        <el-form-item label="手册名称"><el-input v-model="bookForm.bookName" /></el-form-item>
        <el-form-item label="类型"><el-select v-model="bookForm.bookType" style="width:100%"><el-option v-for="t in bookTypes" :key="t" :label="t" :value="t" /></el-select></el-form-item>
        <el-form-item label="币种"><el-input v-model="bookForm.currency" /></el-form-item>
        <el-form-item label="优先级"><el-input-number v-model="bookForm.priority" :min="0" /></el-form-item>
        <el-form-item label="生效日期"><el-date-picker v-model="bookForm.effectiveDate" type="date" value-format="YYYY-MM-DD" style="width:100%" /></el-form-item>
        <el-form-item label="失效日期"><el-date-picker v-model="bookForm.expiryDate" type="date" value-format="YYYY-MM-DD" style="width:100%" /></el-form-item>
        <el-form-item label="状态"><el-select v-model="bookForm.status" style="width:100%"><el-option label="正常" value="0" /><el-option label="停用" value="1" /></el-select></el-form-item>
        <el-form-item label="备注"><el-input v-model="bookForm.remark" type="textarea" /></el-form-item>
      </el-form>
      <template #footer><el-button @click="bookDialog.visible=false">取消</el-button><el-button type="primary" @click="submitBook">确定</el-button></template>
    </el-dialog>

    <!-- Entry Dialog -->
    <el-dialog v-model="entryDialog.visible" :title="entryDialog.isEdit ? '编辑条目' : '新增条目'" width="500px">
      <el-form :model="entryForm" label-width="90px">
        <el-form-item label="产品" required>
          <ModelLookup
            v-model="entryForm.modelId"
            @select="onEntryModelSelected"
            @clear="onEntryModelCleared"
          />
        </el-form-item>
        <el-form-item :label="variantRequired ? '变体（必选）' : '变体'">
          <VariantLookup
            v-model="entryForm.variantId"
            :model-id="entryForm.modelId"
            :config-type="entryConfigType"
            :required="variantRequired"
            @select="onEntryVariantSelected"
          />
        </el-form-item>
        <el-form-item label="物料编码"><el-input v-model="entryForm.itemCode" :disabled="true" placeholder="选择变体后自动填充" /></el-form-item>
        <el-form-item label="目录价"><el-input-number v-model="entryForm.listPrice" :min="0" :precision="2" style="width:100%" /></el-form-item>
        <el-form-item label="成本价"><el-input-number v-model="entryForm.costPrice" :min="0" :precision="2" style="width:100%" /></el-form-item>
        <el-form-item label="最低价"><el-input-number v-model="entryForm.minPrice" :min="0" :precision="2" style="width:100%" /></el-form-item>
        <el-form-item label="区域"><el-input v-model="entryForm.regionCode" /></el-form-item>
        <el-form-item label="渠道"><el-input v-model="entryForm.channelCode" /></el-form-item>
        <el-form-item label="生效日期"><el-date-picker v-model="entryForm.effectiveDate" type="date" value-format="YYYY-MM-DD" style="width:100%" /></el-form-item>
        <el-form-item label="失效日期"><el-date-picker v-model="entryForm.expiryDate" type="date" value-format="YYYY-MM-DD" style="width:100%" /></el-form-item>
        <el-form-item label="状态"><el-select v-model="entryForm.status" style="width:100%"><el-option label="正常" value="0" /><el-option label="停用" value="1" /></el-select></el-form-item>
      </el-form>
      <template #footer><el-button @click="entryDialog.visible=false">取消</el-button><el-button type="primary" @click="submitEntry">确定</el-button></template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import request from '@/utils/request'
import { getPriceBookList, addPriceBook, updatePriceBook, deletePriceBook, getEntryList, addEntry, updateEntry, deleteEntry, type CpqPriceBook, type CpqPriceBookEntry } from '@/api/pricing'
import ModelLookup from '@/components/cpq/ModelLookup.vue'
import VariantLookup from '@/components/cpq/VariantLookup.vue'
import type { CpqProductModelVo } from '@/api/cpq/product'
import type { CpqProductVariantVo } from '@/api/cpq/variant'

// 扩展 CpqPriceBookEntry 添加 variantId（阶段2）
interface EntryForm extends CpqPriceBookEntry {
  variantId?: number
}

const today = () => new Date().toISOString().split('T')[0]

const bookTypes = ['STANDARD', 'CHANNEL', 'PROMOTION', 'REGION']
const books = ref<CpqPriceBook[]>([])
const entries = ref<CpqPriceBookEntry[]>([])
const selectedBook = ref<CpqPriceBook | null>(null)
const bookLoading = ref(false)
const entryLoading = ref(false)

// 模型名称缓存（用于列表展示）
const modelCache = ref<Map<number, string>>(new Map())
const modelLabel = (modelId: number) => modelCache.value.get(modelId) || `#${modelId}`

// 条目对话框 — 产品/变体选择
const entryConfigType = ref<string | null>(null)
const variantRequired = ref(false)

const onEntryModelSelected = (model: CpqProductModelVo) => {
  modelCache.value.set(model.modelId, `${model.modelCode} - ${model.modelName}`)
  entryForm.variantId = undefined
  entryForm.itemCode = ''
  entryConfigType.value = model.configType
  variantRequired.value = (model.configType === 'STANDARD')
}

const onEntryModelCleared = () => {
  entryForm.variantId = undefined
  entryForm.itemCode = ''
  entryConfigType.value = null
  variantRequired.value = false
}

const onEntryVariantSelected = (variant: CpqProductVariantVo) => {
  entryForm.itemCode = variant.variantCode
  entryForm.listPrice = variant.basePrice || entryForm.listPrice
}

const bookTypeLabel = (t: string) => ({ STANDARD: '标准', CHANNEL: '渠道', PROMOTION: '促销', REGION: '区域' }[t] || t)

const bookDialog = reactive({ visible: false, isEdit: false })
const bookForm = reactive<CpqPriceBook>({ bookName: '', bookType: 'STANDARD', currency: 'CNY', priority: 0, effectiveDate: today(), expiryDate: '', status: '0', remark: '' })

const entryDialog = reactive({ visible: false, isEdit: false })
const entryForm = reactive<EntryForm>({ priceBookId: 0, modelId: 0, listPrice: 0, effectiveDate: today(), status: '0' })

// ---- 预加载模型名称（用于列表） ----
const preloadModelNames = (modelIds: number[]) => {
  const ids = modelIds.filter(id => id && !modelCache.value.has(id))
  if (ids.length > 0) {
    request.get('/cpq/product/model/listByIds', { params: { ids: ids.join(',') } }).then((models: any[]) => {
      (models || []).forEach((m: any) => modelCache.value.set(m.modelId, `${m.modelCode} - ${m.modelName}`))
    }).catch(() => { /* 后台暂未实现 */ })
  }
}

// ---- 加载数据 ----
const loadBooks = async () => { bookLoading.value = true; try { const data = await getPriceBookList(); books.value = (Array.isArray(data) ? data : []) } finally { bookLoading.value = false } }

const onBookSelect = async (row: CpqPriceBook | null) => {
  selectedBook.value = row; entries.value = []
  if (!row?.priceBookId) return
  entryLoading.value = true
  try {
    const data = await getEntryList({ priceBookId: row.priceBookId })
    entries.value = (Array.isArray(data) ? data : [])
    preloadModelNames(entries.value.map(e => e.modelId))
  } finally { entryLoading.value = false }
}

const onAddBook = () => { Object.assign(bookForm, { bookName: '', bookType: 'STANDARD', currency: 'CNY', priority: 0, effectiveDate: today(), expiryDate: '', status: '0', remark: '' }); bookDialog.isEdit = false; bookDialog.visible = true }
const onEditBook = (row: CpqPriceBook) => { Object.assign(bookForm, row); bookDialog.isEdit = true; bookDialog.visible = true }
const submitBook = async () => { try { await (bookDialog.isEdit ? updatePriceBook(bookForm) : addPriceBook(bookForm)); bookDialog.visible = false; ElMessage.success(bookDialog.isEdit ? '修改成功' : '新增成功'); loadBooks() } catch (e: any) { ElMessage.error(e?.message || '操作失败') } }
const onDeleteBook = async (row: CpqPriceBook) => { try { await ElMessageBox.confirm('确定删除该价格手册？'); await deletePriceBook(row.priceBookId!); ElMessage.success('删除成功'); if (selectedBook.value?.priceBookId === row.priceBookId) { selectedBook.value = null; entries.value = [] }; loadBooks() } catch { /* cancelled */ } }

const onAddEntry = () => {
  Object.assign(entryForm, { priceBookId: selectedBook.value!.priceBookId, modelId: 0, variantId: undefined, itemCode: '', listPrice: 0, costPrice: undefined, minPrice: undefined, regionCode: '', channelCode: '', effectiveDate: today(), expiryDate: '', status: '0' })
  entryConfigType.value = null; variantRequired.value = false
  entryDialog.isEdit = false; entryDialog.visible = true
}

const onEditEntry = (row: CpqPriceBookEntry) => {
  Object.assign(entryForm, row)
  entryConfigType.value = null; variantRequired.value = false
  entryDialog.isEdit = true; entryDialog.visible = true
}

const submitEntry = async () => {
  // STANDARD 必选变体校验
  if (variantRequired.value && !entryForm.variantId) {
    ElMessage.warning('标准产品必须选择变体')
    return
  }
  // 清理空字符串
  if (!entryForm.expiryDate) entryForm.expiryDate = undefined as any
  try {
    await (entryDialog.isEdit ? updateEntry(entryForm) : addEntry(entryForm))
    entryDialog.visible = false
    ElMessage.success(entryDialog.isEdit ? '修改成功' : '新增成功')
    onBookSelect(selectedBook.value)
  } catch (e: any) { ElMessage.error(e?.message || '操作失败') }
}

const onDeleteEntry = async (row: CpqPriceBookEntry) => { try { await ElMessageBox.confirm('确定删除该条目？'); await deleteEntry(row.entryId!); ElMessage.success('删除成功'); onBookSelect(selectedBook.value) } catch { /* cancelled */ } }

onMounted(loadBooks)
</script>

<style scoped lang="scss">
.page-header { margin-bottom: 20px; h2 { font-size: 20px; } .subtitle { color: var(--cpq-text-secondary); font-size: 13px; } }
.card-header { display: flex; justify-content: space-between; align-items: center; }
</style>
