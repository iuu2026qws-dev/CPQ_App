<template>
  <div class="designer-container">
    <!-- 顶部工具栏 -->
    <div class="designer-toolbar">
      <div class="toolbar-left">
        <el-button icon="ArrowLeft" @click="goBack">返回列表</el-button>
        <el-divider direction="vertical" />
        <span class="template-title">{{ templateName || '新建模板' }}</span>
        <el-tag v-if="templateType" size="small" :type="typeTagColor(templateType)">{{ typeLabel(templateType) }}</el-tag>
      </div>
      <div class="toolbar-right">
        <el-button icon="RefreshLeft" @click="resetDesign">重置</el-button>
        <el-button icon="View" @click="handlePreview">预览</el-button>
        <el-button type="primary" icon="Check" @click="handleSave" :loading="saving">保存设计</el-button>
      </div>
    </div>

    <!-- 主体三栏布局 -->
    <div class="designer-body">
      <!-- 左栏：字段库 -->
      <div class="panel panel-left">
        <div class="panel-header">
          <el-icon><Collection /></el-icon>
          <span>可用字段</span>
          <el-input v-model="fieldSearch" placeholder="搜索字段..." size="small" clearable style="margin-top:8px" />
        </div>
        <div class="panel-body">
          <template v-for="cat in filteredFieldLibrary" :key="cat.category">
            <div class="field-category">
              <div class="category-title">{{ cat.categoryLabel }}</div>
              <div
                v-for="field in cat.fields"
                :key="field.bindField"
                class="field-item"
                :draggable="true"
                @dragstart="onFieldDragStart($event, field)"
              >
                <el-icon :size="14"><component :is="fieldIcon(field.fieldType)" /></el-icon>
                <span class="field-label">{{ field.label }}</span>
                <span class="field-bind">{{ field.bindField }}</span>
              </div>
            </div>
          </template>
          <el-empty v-if="filteredFieldLibrary.length === 0" description="无匹配字段" :image-size="60" />
        </div>
      </div>

      <!-- 中栏：设计画布 -->
      <div class="panel panel-center">
        <div class="panel-header">
          <el-icon><EditPen /></el-icon>
          <span>设计画布</span>
          <span class="hint-text">拖拽左侧字段到对应区域</span>
        </div>
        <div class="panel-body canvas-body">
          <!-- 页面设置区 -->
          <div class="page-settings-section">
            <el-collapse v-model="pageSettingsOpen">
              <el-collapse-item title="页面设置" name="page">
                <el-form label-width="90px" size="small">
                  <el-form-item label="公司名称">
                    <el-input v-model="pageSettings.companyName" placeholder="显示在报价单顶部" />
                  </el-form-item>
                  <el-form-item label="页脚文字">
                    <el-input v-model="pageSettings.footerText" placeholder="页脚展示文字" />
                  </el-form-item>
                  <el-form-item label="主题色">
                    <el-color-picker v-model="pageSettings.primaryColor" />
                  </el-form-item>
                </el-form>
              </el-collapse-item>
            </el-collapse>
          </div>

          <!-- 各设计区域 -->
          <div
            v-for="section in sections"
            :key="section.id"
            class="design-section"
            :class="{ 'drag-over': dragOverSection === section.id }"
            @dragover.prevent="dragOverSection = section.id"
            @dragleave="dragOverSection = null"
            @drop="onFieldDrop($event, section)"
          >
            <div class="section-header">
              <div class="section-header-left">
                <el-icon><component :is="sectionIcon(section.type)" /></el-icon>
                <span>{{ section.label }}</span>
                <el-tag size="small" type="info">{{ section.type === 'grid' ? '网格布局' : '表格' }}</el-tag>
              </div>
              <el-button link type="danger" size="small" icon="Delete" @click="removeSection(section)" v-if="section.type === 'custom'">删除</el-button>
            </div>

            <!-- 表格类型区域 -->
            <template v-if="section.type === 'table'">
              <div class="table-columns-area">
                <div class="table-header-row">
                  <div
                    v-for="col in section.columns"
                    :key="col.id"
                    class="table-col-item"
                    draggable="true"
                    @dragstart="onColDragStart($event, section, col)"
                  >
                    <span>{{ col.label }}</span>
                    <el-icon :size="12" class="col-remove" @click="removeTableColumn(section, col)"><Close /></el-icon>
                  </div>
                  <div
                    class="table-col-add"
                    @drop="onColDrop($event, section)"
                    @dragover.prevent
                  >
                    <el-icon><Plus /></el-icon>
                    <span>拖入列</span>
                  </div>
                </div>
              </div>
              <el-empty v-if="!section.columns || section.columns.length === 0" description="从左侧拖入字段到此表格区域" :image-size="48" />
            </template>

            <!-- 网格类型区域 -->
            <template v-if="section.type === 'grid'">
              <div class="grid-fields-area" :style="{ gridTemplateColumns: `repeat(${section.columns || 2}, 1fr)` }">
                <div
                  v-for="field in section.fields"
                  :key="field.id"
                  class="grid-field-item"
                  :style="{ gridColumn: `span ${field.colSpan || 1}` }"
                  draggable="true"
                  @dragstart="onGridFieldDragStart($event, section, field)"
                >
                  <div class="grid-field-label">{{ field.label }}</div>
                  <div class="grid-field-value">{{ getFieldPreview(field.bindField) }}</div>
                  <el-icon :size="12" class="field-remove" @click="removeGridField(section, field)"><Close /></el-icon>
                </div>
                <div
                  class="grid-field-placeholder"
                  v-for="i in (section.columns || 2) - (section.fields ? section.fields.length % (section.columns || 2) : 0)"
                  :key="'ph-' + section.id + '-' + i"
                >
                  <span>拖入字段</span>
                </div>
              </div>
              <el-empty v-if="!section.fields || section.fields.length === 0" description="从左侧拖入字段到此区域" :image-size="48" />
            </template>
          </div>

          <!-- 添加自定义区域按钮 -->
          <div class="add-section-area">
            <el-button icon="Plus" @click="addCustomSection" size="small">添加自定义区域</el-button>
          </div>
        </div>
      </div>

      <!-- 右栏：属性面板 -->
      <div class="panel panel-right">
        <div class="panel-header">
          <el-icon><Setting /></el-icon>
          <span>属性</span>
        </div>
        <div class="panel-body">
          <template v-if="selectedField">
            <div class="prop-group">
              <div class="prop-group-title">字段属性</div>
              <el-form label-width="70px" size="small">
                <el-form-item label="标签">
                  <el-input v-model="selectedField.label" @change="onFieldPropChange" />
                </el-form-item>
                <el-form-item label="字段">
                  <el-tag size="small">{{ selectedField.bindField }}</el-tag>
                </el-form-item>
                <el-form-item label="类型">
                  <el-tag size="small" effect="plain">{{ selectedField.fieldType }}</el-tag>
                </el-form-item>
              </el-form>
            </div>
          </template>
          <template v-else-if="selectedSection">
            <div class="prop-group">
              <div class="prop-group-title">区域属性</div>
              <el-form label-width="70px" size="small">
                <el-form-item label="名称">
                  <el-input v-model="selectedSection.label" />
                </el-form-item>
                <el-form-item label="列数" v-if="selectedSection.type === 'grid'">
                  <el-input-number v-model="selectedSection.columns" :min="1" :max="6" />
                </el-form-item>
              </el-form>
            </div>
          </template>
          <el-empty v-else description="选择字段或区域查看属性" :image-size="60" />
        </div>
      </div>
    </div>

    <!-- 预览对话框 -->
    <el-dialog v-model="previewVisible" title="模板预览" width="85%" top="3vh" destroy-on-close>
      <div v-if="previewLoading" style="text-align:center;padding:60px">
        <el-icon class="is-loading" :size="36"><Loading /></el-icon>
        <p style="margin-top:12px">正在生成预览...</p>
      </div>
      <iframe v-else-if="previewHtml" :srcdoc="previewHtml" style="width:100%;height:75vh;border:1px solid #ddd;border-radius:4px" />
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, computed, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { getTemplate, updateTemplate, getFieldLibrary, saveTemplateDesign, previewTemplate, addTemplate } from '@/api/cpq/template'
import { ElMessage } from 'element-plus'
import { Collection, EditPen, Setting, Plus, Close, Loading, Star, Clock, Tickets, List } from '@element-plus/icons-vue'

const route = useRoute()
const router = useRouter()
const templateId = ref<number | null>(null)
const templateName = ref('')
const templateType = ref('')
const saving = ref(false)

// 页面设置
const pageSettings = reactive({ companyName: '', footerText: '本报价单由 CPQ 系统自动生成', primaryColor: '#409eff' })
const pageSettingsOpen = ref(['page'])

// 字段库
const fieldLibrary = ref<any[]>([])
const fieldSearch = ref('')
const filteredFieldLibrary = computed(() => {
  if (!fieldSearch.value) return fieldLibrary.value
  const kw = fieldSearch.value.toLowerCase()
  return fieldLibrary.value.map((cat: any) => ({
    ...cat,
    fields: cat.fields.filter((f: any) => f.label.toLowerCase().includes(kw) || f.bindField.toLowerCase().includes(kw))
  })).filter((cat: any) => cat.fields.length > 0)
})

// 设计区域
const sections = reactive<any[]>([])
const dragOverSection = ref<string | null>(null)
let idCounter = 0
function nextId() { return 'f-' + (++idCounter) + '-' + Date.now() }

// 选中的属性
const selectedField = ref<any>(null)
const selectedSection = ref<any>(null)

// 预览
const previewVisible = ref(false)
const previewLoading = ref(false)
const previewHtml = ref('')

function typeLabel(t: string) { const m: Record<string, string> = { STANDARD: 'HTML', PDF: 'PDF', WORD: 'Word', EXCEL: 'Excel' }; return m[t] || t }
function typeTagColor(t: string) { const m: Record<string, string> = { STANDARD: '', PDF: 'danger', WORD: 'primary', EXCEL: 'success' }; return m[t] || 'info' }

function fieldIcon(ft: string) {
  const m: Record<string, any> = { text: EditPen, number: Star, date: Clock, currency: Tickets }
  return m[ft] || EditPen
}

function sectionIcon(type: string) {
  return type === 'table' ? List : EditPen
}

function getFieldPreview(bindField: string) {
  const m: Record<string, string> = {
    'quote.quoteNumber': 'QT-2026-0001', 'quote.quoteType': '标准报价', 'quote.accountName': '示例客户',
    'quote.currency': 'CNY', 'quote.status': '草稿', 'quote.createTime': '2026-06-13',
    'quote.validUntil': '2026-07-13', 'quote.discountRate': '0.00%', 'quote.grandTotal': '¥158,000.00',
    'quote.remark': '—', 'line.index': '1', 'line.itemCode': 'ARC-200P', 'line.itemName': '弧焊机器人',
    'line.itemType': '成品', 'line.quantity': '1', 'line.unit': 'SET', 'line.unitPrice': '¥120,000',
    'line.discountPct': '0%', 'line.lineTotal': '¥120,000', 'summary.subtotal': '¥158,000',
    'summary.discount': '¥0', 'summary.grandTotal': '¥158,000', 'summary.lineCount': '2'
  }
  return m[bindField] || '—'
}

// 字段拖拽
let dragField: any = null
function onFieldDragStart(e: DragEvent, field: any) {
  dragField = field
  e.dataTransfer!.effectAllowed = 'copy'
  e.dataTransfer!.setData('text/plain', field.bindField)
}

function onFieldDrop(e: DragEvent, section: any) {
  dragOverSection.value = null
  if (!dragField) return

  if (section.type === 'grid') {
    if (!section.fields) section.fields = []
    section.fields.push({
      id: nextId(),
      label: dragField.label,
      bindField: dragField.bindField,
      fieldType: dragField.fieldType,
      colSpan: 1
    })
  } else if (section.type === 'table') {
    if (!section.columns) section.columns = []
    section.columns.push({
      id: nextId(),
      label: dragField.label,
      bindField: dragField.bindField,
      fieldType: dragField.fieldType
    })
  }
  dragField = null
}

// 网格内字段重排
let dragGridField: any = null; let dragSourceSection: any = null
function onGridFieldDragStart(e: DragEvent, section: any, field: any) {
  dragGridField = field
  dragSourceSection = section
  e.dataTransfer!.effectAllowed = 'move'
}

// 表格列拖拽
let dragCol: any = null; let dragColSection: any = null
function onColDragStart(e: DragEvent, section: any, col: any) {
  dragCol = col
  dragColSection = section
  e.dataTransfer!.effectAllowed = 'move'
}

function onColDrop(e: DragEvent, section: any) {
  if (!dragField) return
  if (!section.columns) section.columns = []
  const exists = section.columns.find((c: any) => c.bindField === dragField.bindField)
  if (!exists) {
    section.columns.push({
      id: nextId(),
      label: dragField.label,
      bindField: dragField.bindField,
      fieldType: dragField.fieldType
    })
  }
  dragField = null
  dragCol = null
}

function removeGridField(section: any, field: any) {
  const idx = section.fields.findIndex((f: any) => f.id === field.id)
  if (idx >= 0) section.fields.splice(idx, 1)
  if (selectedField.value?.id === field.id) selectedField.value = null
}

function removeTableColumn(section: any, col: any) {
  const idx = section.columns.findIndex((c: any) => c.id === col.id)
  if (idx >= 0) section.columns.splice(idx, 1)
}

function removeSection(section: any) {
  const idx = sections.findIndex((s: any) => s.id === section.id)
  if (idx >= 0) sections.splice(idx, 1)
}

function addCustomSection() {
  sections.push({
    id: 'custom-' + nextId(),
    label: '自定义区域',
    type: 'grid',
    columns: 2,
    fields: []
  })
}

function onFieldPropChange() { /* reactive binding handles this */ }

function selectField(field: any) { selectedField.value = field; selectedSection.value = null }
function selectSection(section: any) { selectedSection.value = section; selectedField.value = null }

// 数据加载
async function loadTemplate() {
  if (!templateId.value) return
  try {
    const res = await getTemplate(templateId.value)
    const tpl = res.data
    templateName.value = tpl.templateName || ''
    templateType.value = tpl.templateType || ''

    // 加载设计配置
    if (tpl.templateJson) {
      try {
        const design = JSON.parse(tpl.templateJson)
        if (design.sections) {
          sections.splice(0, sections.length, ...design.sections)
        }
        if (design.pageSettings) {
          Object.assign(pageSettings, design.pageSettings)
        }
      } catch { /* 使用默认配置 */ }
    }

    // 无设计配置时初始化默认区域
    if (sections.length === 0) {
      initDefaultSections()
    }
  } catch (e) {
    ElMessage.error('加载模板失败')
  }
}

function initDefaultSections() {
  sections.splice(0, sections.length,
    {
      id: 'header',
      label: '报价单头部',
      type: 'grid',
      columns: 4,
      fields: [
        { id: 'hf-1', label: '报价编号', bindField: 'quote.quoteNumber', fieldType: 'text', colSpan: 2 },
        { id: 'hf-2', label: '客户名称', bindField: 'quote.accountName', fieldType: 'text', colSpan: 2 },
        { id: 'hf-3', label: '报价类型', bindField: 'quote.quoteType', fieldType: 'text', colSpan: 2 },
        { id: 'hf-4', label: '创建日期', bindField: 'quote.createTime', fieldType: 'date', colSpan: 2 },
        { id: 'hf-5', label: '币种', bindField: 'quote.currency', fieldType: 'text', colSpan: 1 },
        { id: 'hf-6', label: '总金额', bindField: 'quote.grandTotal', fieldType: 'currency', colSpan: 1 },
      ]
    },
    {
      id: 'items',
      label: '行项目明细',
      type: 'table',
      columns: [
        { id: 'tc-1', label: '序号', bindField: 'line.index', fieldType: 'number' },
        { id: 'tc-2', label: '产品编码', bindField: 'line.itemCode', fieldType: 'text' },
        { id: 'tc-3', label: '产品名称', bindField: 'line.itemName', fieldType: 'text' },
        { id: 'tc-4', label: '数量', bindField: 'line.quantity', fieldType: 'number' },
        { id: 'tc-5', label: '单价', bindField: 'line.unitPrice', fieldType: 'currency' },
        { id: 'tc-6', label: '折扣(%)', bindField: 'line.discountPct', fieldType: 'number' },
        { id: 'tc-7', label: '小计', bindField: 'line.lineTotal', fieldType: 'currency' },
      ]
    },
    {
      id: 'summary',
      label: '价格汇总',
      type: 'grid',
      columns: 2,
      fields: [
        { id: 'sf-1', label: '小计', bindField: 'summary.subtotal', fieldType: 'currency', colSpan: 1 },
        { id: 'sf-2', label: '折扣', bindField: 'summary.discount', fieldType: 'currency', colSpan: 1 },
        { id: 'sf-3', label: '总金额', bindField: 'summary.grandTotal', fieldType: 'currency', colSpan: 2 },
        { id: 'sf-4', label: '行数', bindField: 'summary.lineCount', fieldType: 'number', colSpan: 1 },
      ]
    }
  )
}

function resetDesign() {
  initDefaultSections()
  pageSettings.companyName = ''
  pageSettings.footerText = '本报价单由 CPQ 系统自动生成'
  pageSettings.primaryColor = '#409eff'
  selectedField.value = null
  selectedSection.value = null
}

async function loadFieldLibrary() {
  try {
    const res = await getFieldLibrary()
    fieldLibrary.value = Array.isArray(res) ? res : (res.data || [])
  } catch { /* ignore */ }
}

// 操作
async function handleSave() {
  saving.value = true
  try {
    const designJson = JSON.stringify({
      sections: JSON.parse(JSON.stringify(sections)),
      pageSettings: JSON.parse(JSON.stringify(pageSettings))
    })
    await saveTemplateDesign(templateId.value!, designJson)
    ElMessage.success('设计保存成功')
  } catch {
    ElMessage.error('保存失败')
  } finally { saving.value = false }
}

async function handlePreview() {
  if (!templateId.value) return
  // 先保存，再预览
  await handleSave()
  previewVisible.value = true
  previewLoading.value = true
  previewHtml.value = ''
  try {
    const res = await previewTemplate(templateId.value)
    previewHtml.value = res.data || ''
  } catch { ElMessage.error('预览生成失败') }
  finally { previewLoading.value = false }
}

function goBack() { router.push('/quoting/templates') }

onMounted(async () => {
  const id = route.params.templateId
  if (id) {
    templateId.value = Number(id)
  }
  await Promise.all([loadTemplate(), loadFieldLibrary()])
})
</script>

<style scoped>
.designer-container { display: flex; flex-direction: column; height: calc(100vh - 86px); background: #f0f2f5; }
.designer-toolbar { display: flex; justify-content: space-between; align-items: center; padding: 8px 16px; background: #fff; border-bottom: 1px solid #e4e7ed; flex-shrink: 0; }
.toolbar-left { display: flex; align-items: center; gap: 8px; }
.toolbar-right { display: flex; gap: 8px; }
.template-title { font-size: 16px; font-weight: 600; color: #303133; }

.designer-body { display: flex; flex: 1; overflow: hidden; gap: 0; }
.panel { display: flex; flex-direction: column; background: #fff; }
.panel-left { width: 260px; border-right: 1px solid #e4e7ed; flex-shrink: 0; }
.panel-center { flex: 1; overflow-y: auto; }
.panel-right { width: 260px; border-left: 1px solid #e4e7ed; flex-shrink: 0; }

.panel-header { display: flex; align-items: center; gap: 6px; padding: 12px 16px; border-bottom: 1px solid #f0f0f0; font-weight: 600; font-size: 14px; color: #303133; flex-shrink: 0; }
.panel-header .hint-text { font-weight: 400; font-size: 12px; color: #909399; margin-left: auto; }
.panel-body { flex: 1; overflow-y: auto; padding: 12px; }

/* 字段库 */
.field-category { margin-bottom: 12px; }
.category-title { font-size: 12px; color: #909399; text-transform: uppercase; letter-spacing: 0.5px; padding: 4px 0; margin-bottom: 4px; border-bottom: 1px dashed #ebeef5; }
.field-item { display: flex; align-items: center; gap: 6px; padding: 6px 8px; margin: 2px 0; border-radius: 4px; cursor: grab; transition: all 0.15s; border: 1px solid #ebeef5; background: #fafafa; }
.field-item:hover { background: #ecf5ff; border-color: #409eff; }
.field-item:active { cursor: grabbing; }
.field-label { font-size: 13px; color: #303133; flex: 1; }
.field-bind { font-size: 11px; color: #c0c4cc; }

/* 画布 */
.canvas-body { background: #f5f7fa; }
.page-settings-section { margin-bottom: 12px; }
.design-section { background: #fff; border: 2px solid #e4e7ed; border-radius: 6px; margin-bottom: 12px; transition: border-color 0.2s; }
.design-section.drag-over { border-color: #409eff; border-style: dashed; background: #ecf5ff; }
.section-header { display: flex; justify-content: space-between; align-items: center; padding: 8px 12px; background: #fafafa; border-bottom: 1px solid #ebeef5; border-radius: 6px 6px 0 0; }
.section-header-left { display: flex; align-items: center; gap: 6px; font-weight: 600; font-size: 14px; }

/* 网格区域 */
.grid-fields-area { display: grid; gap: 8px; padding: 12px; }
.grid-field-item { position: relative; background: #f0f7ff; border: 1px dashed #b3d8ff; border-radius: 4px; padding: 8px 12px; cursor: grab; transition: all 0.15s; }
.grid-field-item:hover { background: #ecf5ff; border-color: #409eff; }
.grid-field-label { font-size: 11px; color: #909399; margin-bottom: 2px; }
.grid-field-value { font-size: 13px; color: #303133; }
.field-remove { position: absolute; top: 4px; right: 4px; color: #c0c4cc; cursor: pointer; display: none; }
.grid-field-item:hover .field-remove { display: flex; }
.grid-field-placeholder { display: flex; align-items: center; justify-content: center; min-height: 40px; border: 1px dashed #dcdfe6; border-radius: 4px; color: #c0c4cc; font-size: 12px; }

/* 表格区域 */
.table-columns-area { padding: 12px; overflow-x: auto; }
.table-header-row { display: flex; gap: 4px; align-items: center; flex-wrap: wrap; }
.table-col-item { display: flex; align-items: center; gap: 4px; padding: 6px 10px; background: #f0f7ff; border: 1px solid #b3d8ff; border-radius: 4px; font-size: 13px; cursor: grab; }
.table-col-item:hover { background: #ecf5ff; }
.col-remove { color: #c0c4cc; cursor: pointer; }
.col-remove:hover { color: #f56c6c; }
.table-col-add { display: flex; align-items: center; gap: 4px; padding: 6px 12px; border: 1px dashed #dcdfe6; border-radius: 4px; color: #909399; font-size: 12px; cursor: pointer; min-width: 80px; }
.table-col-add:hover { border-color: #409eff; color: #409eff; }

/* 添加区域 */
.add-section-area { text-align: center; padding: 16px; }
.add-section-area .el-button { width: 100%; border-style: dashed; }

/* 属性面板 */
.prop-group { margin-bottom: 16px; }
.prop-group-title { font-size: 13px; font-weight: 600; color: #303133; margin-bottom: 8px; padding-bottom: 4px; border-bottom: 1px solid #ebeef5; }

/* 通用 */
.is-loading { animation: rotating 2s linear infinite; }
@keyframes rotating { from { transform: rotate(0deg); } to { transform: rotate(360deg); } }
</style>
