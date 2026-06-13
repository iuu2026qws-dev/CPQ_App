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
    </div>

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
import { ref, onMounted } from 'vue'
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
  categoryTree.value = data || []
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
