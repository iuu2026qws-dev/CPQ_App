<template>
  <div class="product-catalog">
    <div class="page-header">
      <h2>产品目录</h2>
      <p class="subtitle">浏览产品分类树与产品模型</p>
    </div>

    <!-- 搜索栏 -->
    <div class="search-bar">
      <el-input
        v-model="searchKeyword"
        placeholder="输入关键词搜索，多个关键词用逗号分隔"
        clearable
        @keyup.enter="handleSearch"
        class="search-input"
      >
        <template #append>
          <el-button @click="handleSearch" :loading="searchLoading" :icon="Search">
            搜索
          </el-button>
        </template>
      </el-input>
      <el-button type="success" @click="openImportDialog" style="margin-left:12px">📥 导入产品</el-button>
    </div>

    <!-- 导入弹窗 -->
    <el-dialog v-model="importDialogVisible" title="导入产品数据" width="520px" :close-on-click-modal="false">
      <el-form label-width="90px">
        <el-form-item label="产品分类" required>
          <el-cascader v-model="importForm.categoryId" :options="categoryTree" :props="{ value:'categoryId', label:'categoryName', children:'children', checkStrictly:true, emitPath:false }" placeholder="选择产品系列" style="width:100%" />
        </el-form-item>
        <el-form-item label="基准价格(¥)">
          <el-input-number v-model="importForm.basePrice" :min="0" :precision="2" style="width:100%" />
        </el-form-item>
        <el-form-item label="最小起订量">
          <el-input-number v-model="importForm.minOrderQty" :min="1" style="width:100%" />
        </el-form-item>
        <el-form-item label="交期(天)">
          <el-input-number v-model="importForm.leadTimeDays" :min="1" style="width:100%" />
        </el-form-item>
        <el-form-item label="数据文件" required>
          <el-upload ref="uploadRef" :auto-upload="false" :limit="1" accept=".csv,.tsv,.xlsx,.xls" :on-change="handleFileChange" drag>
            <el-icon class="el-icon--upload"><svg viewBox="0 0 24 24" width="36" height="36" stroke="#409eff" fill="none"><path d="M12 16V4M8 8l4-4 4 4M4 16v4h16v-4" stroke-width="2" stroke-linecap="round"/></svg></el-icon>
            <div class="el-upload__text">拖拽文件到此处，或<em>点击上传</em></div>
          </el-upload>
          <div style="margin-top:6px">
            <el-button link type="primary" size="small" @click="downloadTemplate">📥 下载导入模板</el-button>
            <span style="color:#909399;font-size:11px;margin-left:4px">含填写规范和示例数据</span>
          </div>
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="importDialogVisible = false">取消</el-button>
        <el-button type="primary" :loading="importLoading" :disabled="!importForm.categoryId || !importFile" @click="doImport">开始导入</el-button>
      </template>
    </el-dialog>

    <el-row :gutter="16">
      <el-col :span="8">
        <el-card shadow="never">
          <template #header><strong>产品分类</strong></template>
          <el-tree
            ref="treeRef"
            :data="categoryTree"
            :props="{ label: 'categoryName', children: 'children' }"
            node-key="categoryId"
            highlight-current
            @node-click="handleCategoryClick"
            default-expand-all
            :expand-on-click-node="false"
          >
            <template #default="{ data }">
              <span class="tree-node">
                <el-tag size="small" :type="levelTagType(data.categoryLevel)">
                  {{ levelLabel(data.categoryLevel) }}
                </el-tag>
                <span class="node-label">{{ data.categoryName }}</span>
              </span>
            </template>
          </el-tree>
        </el-card>
      </el-col>
      <el-col :span="16">
        <el-card shadow="never">
          <template #header>
            <strong>{{ selectedCategory?.categoryName || '请选择分类' }}</strong>
          </template>
          <el-table :data="models" stripe v-loading="loading" empty-text="暂无产品" row-key="modelId">
            <el-table-column type="expand">
              <template #default="{ row }">
                <VariantManager
                  :model="{ modelId: row.modelId, modelCode: row.modelCode, modelName: row.modelName }"
                  :visible="true"
                  @variant-changed="handleCategoryClick(selectedCategory!)"
                />
              </template>
            </el-table-column>
            <el-table-column prop="modelCode" label="产品编码" width="140" />
            <el-table-column prop="modelName" label="产品名称" />
            <el-table-column label="类型" width="90">
              <template #default="{ row }">
                <el-tag size="small" :type="configTypeTagType(row.configType)">
                  {{ row.configType || '-' }}
                </el-tag>
              </template>
            </el-table-column>
            <el-table-column prop="lifecycleStatus" label="状态" width="100">
              <template #default="{ row }">
                <el-tag size="small" :type="statusType(row.lifecycleStatus)">
                  {{ row.lifecycleStatus }}
                </el-tag>
              </template>
            </el-table-column>
            <el-table-column prop="basePrice" label="基准价" width="100" />
            <el-table-column prop="categoryPath" label="分类路径" min-width="180" />
          </el-table>
        </el-card>
      </el-col>
    </el-row>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { Search } from '@element-plus/icons-vue'
import { ElMessage } from 'element-plus'
import request from '@/utils/request'
import VariantManager from '@/components/cpq/VariantManager.vue'

interface Category {
  categoryId: number
  categoryName: string
  categoryLevel: number
  children?: Category[]
  parentCategoryId?: number | null
}

interface Model {
  modelId: number
  modelCode: string
  modelName: string
  configType: string
  lifecycleStatus: string
  basePrice: number
  categoryPath: string
  categoryId: number
}

const categoryTree = ref<Category[]>([])
const models = ref<Model[]>([])
const selectedCategory = ref<Category | null>(null)
const loading = ref(false)
const searchKeyword = ref('')
const searchLoading = ref(false)
const treeRef = ref()

const loadCategoryTree = async () => {
  const data = await request.get('/cpq/product/category/tree')
  categoryTree.value = Array.isArray(data) ? data : (data.rows || data || [])
}

const handleCategoryClick = async (node: Category) => {
  selectedCategory.value = node
  loading.value = true
  try {
    const data = await request.get('/cpq/product/model/list', { params: { categoryId: node.categoryId } })
    models.value = data?.rows || data || []
  } finally {
    loading.value = false
  }
}

/** 递归搜索分类树，返回第一个名称包含 keyword 的节点 */
function searchCategory(tree: Category[], keyword: string): Category | null {
  const kw = keyword.toLowerCase()
  for (const node of tree) {
    if (node.categoryName.toLowerCase().includes(kw)) return node
    if (node.children) {
      const found = searchCategory(node.children, kw)
      if (found) return found
    }
  }
  return null
}

/** 递归按 ID 查找分类节点 */
function findCategoryById(tree: Category[], id: number): Category | null {
  for (const node of tree) {
    if (node.categoryId === id) return node
    if (node.children) {
      const found = findCategoryById(node.children, id)
      if (found) return found
    }
  }
  return null
}

/** 高亮并展开到指定分类节点，然后加载其下产品 */
async function locateCategory(category: Category) {
  treeRef.value?.setCurrentKey(category.categoryId)
  // 滚动高亮节点到可视区域
  await new Promise(r => setTimeout(r, 50))
  const el = document.querySelector('.el-tree-node.is-current')
  el?.scrollIntoView({ behavior: 'smooth', block: 'center' })
  await handleCategoryClick(category)
}

async function handleSearch() {
  const raw = searchKeyword.value.trim()
  if (!raw) return

  // 按逗号拆分多关键词
  const keywords = raw.split(',').map(k => k.trim()).filter(Boolean)
  if (keywords.length === 0) return

  searchLoading.value = true
  try {
    // 1. 先按关键词依次搜索分类树（本地）
    for (const kw of keywords) {
      const found = searchCategory(categoryTree.value, kw)
      if (found) {
        await locateCategory(found)
        searchLoading.value = false
        return
      }
    }

    // 2. 分类未命中 → 调用后端搜索产品
    const models: Model[] = await request.get('/cpq/product/model/search', {
      params: { keyword: keywords.join(' ') }
    })

    if (models && models.length > 0) {
      // 取第一个匹配产品的所属分类（产品系列 L3）
      const categoryId = models[0].categoryId
      const seriesCategory = findCategoryById(categoryTree.value, categoryId)
      if (seriesCategory) {
        await locateCategory(seriesCategory)
        searchLoading.value = false
        return
      }
    }

    // 3. 都未命中
    ElMessage.info('未找到匹配的分类或产品')
  } catch {
    ElMessage.warning('搜索失败，请稍后重试')
  } finally {
    searchLoading.value = false
  }
}

const levelTagType = (level: number) => {
  const map: Record<number, string> = { 1: 'success', 2: '', 3: 'warning' }
  return map[level] || 'info'
}

const levelLabel = (level: number) => {
  const map: Record<number, string> = { 1: '产品族', 2: '产品线', 3: '产品系列' }
  return map[level] || 'L' + level
}

const statusType = (status: string) => {
  const map: Record<string, string> = {
    ACTIVE: 'success', EOL_ANNOUNCED: 'warning', DISCONTINUED: 'danger',
    PRE_RELEASE: 'info', DESIGN: '', CONCEPT: 'info'
  }
  return map[status] || 'info'
}

const configTypeTagType = (ct: string) => {
  switch (ct) {
    case 'STANDARD': return ''
    case 'ATO': return 'success'
    case 'CTO': case 'ETO': return 'warning'
    case 'BUNDLE': return 'info'
    default: return 'info'
  }
}

// ── 导入 ──
const importDialogVisible = ref(false)
const importLoading = ref(false)
const importFile = ref<File | null>(null)
const importForm = reactive({ categoryId: null as number | null, basePrice: 5.00, minOrderQty: 1, leadTimeDays: 7 })

function openImportDialog() {
  importForm.categoryId = null; importForm.basePrice = 5.00; importForm.minOrderQty = 1; importForm.leadTimeDays = 7
  importFile.value = null; importDialogVisible.value = true
}
function handleFileChange(_file: any, uploadFiles: any) {
  importFile.value = uploadFiles[0]?.raw || null
}
function downloadTemplate() {
  const csv = '﻿电芯编码*,电芯型号*,参考尺寸,标称电压,标称容量,最大持续电流,最大脉冲电流,工作温度,最大尺寸,重量(g),存储温度,应用范围,成品编码*,成品描述*,机型号,插头线型号,插头方向,线长(mm),是否绕线,是否桶装,运输方式,产品类型,锂亚电芯数,结构,装箱数量,外贴商标,工时,近一年出货量\n' +
    'ER14250,ER14250,1/2AA,3.6V,1200mAh,50mA,100mA,-55~85℃,Φ14.5×25mm,10,-40~60℃,"GPS,安防",ER14250-BP-001,ER14250电池包 50mm线长 JST插头,TYPE-A,JST-XH-2P,正向,50,是,是,空运,电池包,1,单体,100,自有商标,2.5,5000\n' +
    'ER14505,ER14505,AA,3.6V,2400mAh,100mA,200mA,-40~+85℃,Φ14.5×50mm,18,-40~60℃,智能水表,ER14505-BP-001,ER14505电池包 200mm Molex,TYPE-B,Molex-51021,反向,200,否,否,海运,电池包,2,双串,50,自有商标,3.0,3000\n' +
    '\n# ⚠️ 填写数据前请删除以上2行示例数据及本注释行\n' +
    '# 必填列: 电芯编码,电芯型号,成品编码,成品描述\n' +
    '# 尺寸格式: Φ14.5x25.0mm 或 14.5×25mm | 温度格式: -55~85℃, -60℃~+85℃\n' +
    '# 多值字段用英文双引号包裹: "GPS,安防" | 数值填数字不要带单位'
  const blob = new Blob([csv], { type: 'text/csv;charset=UTF-8' })
  const url = URL.createObjectURL(blob)
  const a = document.createElement('a'); a.href = url; a.download = 'CPQ产品导入模版.csv'
  a.click(); URL.revokeObjectURL(url)
}
async function doImport() {
  if (!importForm.categoryId || !importFile.value) return
  importLoading.value = true
  try {
    const fd = new FormData()
    fd.append('file', importFile.value)
    fd.append('categoryId', String(importForm.categoryId))
    fd.append('basePrice', String(importForm.basePrice))
    fd.append('minOrderQty', String(importForm.minOrderQty))
    fd.append('leadTimeDays', String(importForm.leadTimeDays))
    const res: any = await request.post('/cpq/product/model/import', fd, { headers: { 'Content-Type': 'multipart/form-data' } })
    ElMessage.success(`导入完成：${res.products} 个产品，${res.attributes} 条属性，${res.sbomLines} 条BOM行`)
    importDialogVisible.value = false; handleSearch()
  } catch (e: any) { ElMessage.error('导入失败: ' + (e?.message || '未知错误')) }
  finally { importLoading.value = false }
}

onMounted(loadCategoryTree)
</script>

<style scoped lang="scss">
.product-catalog {
  .page-header {
    margin-bottom: 16px;
    h2 { font-size: 20px; font-weight: 600; }
    .subtitle { font-size: 13px; color: var(--cpq-text-secondary); margin-top: 4px; }
  }

  .search-bar {
    margin-bottom: 16px;
    .search-input {
      max-width: 520px;
    }
  }

  // 表格展开行不裁剪内容，允许 VariantManager 正常展示
  :deep(.el-table__expanded-cell) {
    overflow: visible;
  }

  .tree-node {
    display: flex;
    align-items: center;
    gap: 8px;
    .node-label { font-size: 14px; }
  }
}
</style>
