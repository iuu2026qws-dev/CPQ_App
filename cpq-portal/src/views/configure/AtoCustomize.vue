<template>
  <div class="ato-customize">
    <!-- 无产品时：搜索ATO产品 -->
    <template v-if="!selectedModelId">
      <div class="search-entry">
        <div class="entry-header">
          <h1 class="entry-title">ATO定制配置</h1>
          <p class="entry-desc">选择ATO类型产品进行参数化配置，并可提交非结构化定制需求。</p>
        </div>
        <div class="search-box">
          <el-input
            v-model="keyword"
            placeholder="输入产品名称或编码搜索（仅显示ATO类型）"
            size="large"
            clearable
            @keyup.enter="searchProducts"
          >
            <template #prefix><el-icon><Search /></el-icon></template>
            <template #append>
              <el-button type="primary" @click="searchProducts" :loading="searchLoading">搜索</el-button>
            </template>
          </el-input>
        </div>
        <div class="product-grid" v-if="products.length > 0">
          <el-card
            v-for="p in products"
            :key="p.modelId"
            class="product-card"
            shadow="hover"
            @click="selectProduct(p.modelId)"
          >
            <div class="product-info">
              <h3>{{ p.modelCode }}</h3>
              <p>{{ p.modelName }}</p>
              <el-tag type="warning" size="small">ATO</el-tag>
            </div>
          </el-card>
        </div>
        <el-empty v-if="searched && products.length === 0" description="未找到匹配的ATO产品" />
      </div>
    </template>

    <!-- 已选产品：配置 + 定制需求 -->
    <template v-else>
      <div class="config-header">
        <div class="model-info">
          <span class="model-code">{{ store.modelCode }}</span>
          <span class="model-name">{{ store.modelName }}</span>
          <el-tag type="warning">ATO定制</el-tag>
        </div>
        <el-button @click="selectedModelId = null" text>重新选择产品</el-button>
      </div>

      <el-row :gutter="20">
        <!-- 左栏：标准属性配置 -->
        <el-col :span="16">
          <el-card class="config-card">
            <template #header><span class="card-title">标准属性配置</span></template>
            <div v-if="Object.keys(store.attributes).length > 0" class="attr-sections">
              <div v-for="(options, attrName) in store.attributes" :key="attrName" class="attr-group">
                <h4 class="attr-name">{{ attrName }}</h4>
                <div class="attr-options">
                  <el-radio-group
                    :model-value="store.selections[attrName]"
                    @change="(val: string) => handleSelect(attrName, val)"
                  >
                    <el-radio-button
                      v-for="opt in options"
                      :key="opt.optionValue"
                      :value="opt.optionValue"
                    >
                      {{ opt.optionLabel }}
                    </el-radio-button>
                  </el-radio-group>
                </div>
              </div>
            </div>
            <el-empty v-else description="该产品暂无标准属性" />
          </el-card>

          <!-- BOM预览：根据当前属性选择实时刷新 -->
          <el-card class="mt-16" v-if="store.previewBomLines && store.previewBomLines.length > 0">
            <template #header><span class="card-title">BOM预览</span></template>
            <el-table :data="store.previewBomLines" size="small" border>
              <el-table-column prop="materialCode" label="物料编码" min-width="130" />
              <el-table-column prop="materialDesc" label="物料名称" min-width="150" />
              <el-table-column prop="quantity" label="数量" width="80" align="center" />
              <el-table-column prop="unit" label="单位" width="60" align="center" />
            </el-table>
          </el-card>
        </el-col>

        <!-- 右栏：定制需求面板 -->
        <el-col :span="8">
          <el-card class="custom-card">
            <template #header><span class="card-title">定制需求</span></template>
            <el-form :model="customForm" label-width="80px" size="default">
              <el-form-item label="需求描述">
                <el-input
                  v-model="customForm.description"
                  type="textarea"
                  :rows="4"
                  placeholder="描述您的定制需求，如特殊尺寸、接口、材料等"
                  maxlength="1000"
                  show-word-limit
                />
              </el-form-item>
              <el-form-item label="期望数量">
                <el-input-number v-model="customForm.quantity" :min="1" :max="99999" style="width:100%" />
              </el-form-item>
              <el-form-item label="期望交期">
                <el-date-picker v-model="customForm.expectedDate" type="date" placeholder="选择期望交期" value-format="YYYY-MM-DD" style="width:100%" />
              </el-form-item>
              <el-form-item label="优先级">
                <el-radio-group v-model="customForm.priority">
                  <el-radio value="normal">普通</el-radio>
                  <el-radio value="urgent">紧急</el-radio>
                </el-radio-group>
              </el-form-item>
              <el-form-item label="附件">
                <el-upload
                  :action="uploadUrl"
                  :on-success="handleUploadSuccess"
                  :file-list="customForm.attachments"
                  drag
                >
                  <el-icon class="el-icon--upload"><UploadFilled /></el-icon>
                  <div class="el-upload__text">拖拽或<em>点击上传</em>需求文档</div>
                </el-upload>
              </el-form-item>
            </el-form>

            <div class="price-preview" v-if="store.priceResult">
              <el-divider />
              <div class="price-row">
                <span>预估价格</span>
                <span class="price-value">¥ {{ store.priceResult.netPrice || '—' }}</span>
              </div>
            </div>

            <el-button
              type="success"
              size="large"
              style="width:100%; margin-top:16px"
              :loading="submitting"
              @click="handleSubmit"
            >
              提交定制评审
            </el-button>
          </el-card>
        </el-col>
      </el-row>

      <!-- 已选摘要 -->
      <div class="selection-summary" v-if="Object.keys(store.selections).length > 0">
        <span class="summary-label">已选属性：</span>
        <el-tag v-for="(value, key) in store.selections" :key="key" size="small" closable @close="store.deselectOption(key)">
          {{ key }}: {{ value }}
        </el-tag>
      </div>
    </template>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import { Search, InfoFilled, UploadFilled } from '@element-plus/icons-vue'
import { useConfiguratorStore } from '@/store/configurator'
import { searchModel } from '@/api/cpq/product'
import type { CpqProductModelVo } from '@/api/cpq/product'

const store = useConfiguratorStore()

const keyword = ref('')
const searchLoading = ref(false)
const searched = ref(false)
const products = ref<CpqProductModelVo[]>([])
const selectedModelId = ref<number | null>(null)
const submitting = ref(false)

const uploadUrl = '/api/common/upload'

const customForm = reactive({
  description: '',
  quantity: 10,
  expectedDate: '',
  priority: 'normal' as 'normal' | 'urgent',
  attachments: [] as any[]
})

onMounted(async () => {
  if (selectedModelId.value) {
    await store.initModel(String(selectedModelId.value))
  }
})

async function searchProducts() {
  if (!keyword.value.trim()) return
  searchLoading.value = true
  searched.value = true
  try {
    const res = await searchModel(keyword.value.trim())
    const all = Array.isArray(res) ? res : (res.rows || ((res as any).data || []))
    // 仅显示ATO类型
    products.value = all.filter((p: CpqProductModelVo) => p.configType === 'ATO')
  } finally {
    searchLoading.value = false
  }
}

async function selectProduct(modelId: number) {
  selectedModelId.value = modelId
  await store.initModel(String(modelId))
  // 加载初始BOM预览（空选择 = 默认BOM）
  await store.refreshBomPreview()
}

async function handleSelect(attrName: string, optionCode: string) {
  await store.selectOption(attrName, optionCode)
  await store.refreshBomPreview()
}

function handleUploadSuccess(response: any) {
  customForm.attachments.push(response)
}

async function handleSubmit() {
  if (!customForm.description.trim()) {
    ElMessage.warning('请填写定制需求描述')
    return
  }
  submitting.value = true
  try {
    await store.complete()
    ElMessage.success('定制需求已提交，售前团队将尽快评审')
  } catch {
    ElMessage.info('需求已记录，将随配置提交至售前评审')
  } finally {
    submitting.value = false
  }
}
</script>

<style scoped lang="scss">
.ato-customize {
  max-width: 1200px;
  margin: 0 auto;

  .search-entry {
    text-align: center;
    padding-top: 60px;
    .entry-header {
      margin-bottom: 32px;
      .entry-title { font-size: 28px; font-weight: 700; color: #1a2332; }
      .entry-desc { color: #909399; margin-top: 8px; font-size: 14px; }
    }
    .search-box { max-width: 560px; margin: 0 auto 32px; }
    .product-grid {
      display: grid;
      grid-template-columns: repeat(auto-fill, minmax(240px, 1fr));
      gap: 16px;
      .product-card {
        cursor: pointer;
        transition: transform 0.2s;
        &:hover { transform: translateY(-2px); }
        .product-info {
          h3 { font-size: 16px; margin-bottom: 4px; }
          p { color: #909399; font-size: 13px; margin-bottom: 8px; }
        }
      }
    }
  }

  .config-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 20px;
    .model-info {
      display: flex;
      align-items: center;
      gap: 12px;
      .model-code { font-size: 20px; font-weight: 700; color: var(--cpq-primary); }
      .model-name { font-size: 14px; color: #909399; }
    }
  }

  .config-card {
    .card-title { font-size: 15px; font-weight: 600; }
    .attr-group {
      margin-bottom: 20px;
      .attr-name { font-size: 14px; color: #606266; margin-bottom: 8px; }
      .attr-options { display: flex; flex-wrap: wrap; gap: 8px; }
    }
  }

  .custom-card {
    position: sticky;
    top: 16px;
    .card-title { font-size: 15px; font-weight: 600; }
    .price-preview {
      .price-row {
        display: flex;
        justify-content: space-between;
        align-items: center;
        font-size: 14px;
        .price-value { font-size: 20px; font-weight: 700; color: var(--cpq-primary); }
      }
    }
  }

  .mt-16 { margin-top: 16px; }

  .selection-summary {
    display: flex;
    gap: 8px;
    flex-wrap: wrap;
    align-items: center;
    margin-top: 16px;
    padding: 12px 16px;
    background: #f5f7fa;
    border-radius: 8px;
    .summary-label { font-size: 13px; color: #909399; }
  }
}
</style>
