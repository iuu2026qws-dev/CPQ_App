<template>
  <div class="configurator-page">
    <!-- 顶部栏 -->
    <div class="config-header">
      <div class="header-left">
        <el-button text @click="$router.push('/configure')">
          <el-icon><ArrowLeft /></el-icon>
        </el-button>
        <span class="product-info">
          <strong>{{ store.modelCode }}</strong> {{ store.modelName }}
        </span>
        <el-tag v-if="store.configType" size="small" :type="typeTag">{{ store.configType }}</el-tag>
      </div>
      <div class="header-right">
        <el-button @click="$router.push('/configure')" :disabled="store.loading">重新选择</el-button>
        <el-button :type="store.isValid ? 'success' : 'primary'" @click="handleComplete" :loading="store.loading">
          完成配置
          <el-icon><Check /></el-icon>
        </el-button>
      </div>
    </div>

    <!-- 三栏主体 -->
    <div class="config-main">
      <!-- 左栏：属性导航 -->
      <div class="config-left">
        <div class="attr-list">
          <div
            v-for="(options, attrName) in store.attributes"
            :key="attrName"
            class="attr-group"
            :class="{ active: activeAttr === attrName, selected: store.selections[attrName] }"
            @click="activeAttr = attrName"
          >
            <div class="attr-label">
              {{ attrName }}
              <el-icon v-if="store.selections[attrName]" class="check-icon"><CircleCheck /></el-icon>
            </div>
            <div class="attr-count">{{ options.length }} 选项</div>
          </div>
        </div>
        <el-empty v-if="Object.keys(store.attributes).length === 0" description="无可配置属性" :image-size="60" />
      </div>

      <!-- 中栏：选项选择 -->
      <div class="config-center">
        <template v-if="activeAttr">
          <div class="options-header">
            <h4>{{ activeAttr }}</h4>
            <el-button v-if="store.selections[activeAttr]" text type="danger" size="small" @click="store.deselectOption(activeAttr)">
              清除选择
            </el-button>
          </div>
          <div class="options-grid">
            <div
              v-for="option in currentOptions"
              :key="option.optionValue"
              class="option-card"
              :class="{
                selected: store.selections[activeAttr] === option.optionValue,
                disabled: getOptionState(option.optionValue)?.available === false
              }"
              @click="handleSelectOption(option)"
            >
              <div class="option-label">{{ option.optionLabel }}</div>
              <div class="option-value">{{ option.optionValue }}</div>
              <div v-if="getOptionState(option.optionValue)?.reason" class="option-reason">
                {{ getOptionState(option.optionValue)?.reason }}
              </div>
              <el-tag v-if="getOptionState(option.optionValue)?.recommended" size="small" type="success" class="recommend-tag">
                推荐
              </el-tag>
            </div>
          </div>
          <el-empty v-if="currentOptions.length === 0" description="请先在左侧选择属性" :image-size="60" />
        </template>
        <div v-else class="placeholder-center">
          <el-empty description="请在左侧选择一个属性开始配置" :image-size="80" />
        </div>
      </div>

      <!-- 右栏：BOM预览 + 验证结果 -->
      <div class="config-right">
        <!-- BOM 预览 -->
        <div class="right-section">
          <div class="section-title">BOM 预览</div>
          <div v-if="store.bomLines.length > 0" class="bom-list">
            <div v-for="line in store.bomLines" :key="line.sbomLineId ?? line.lineNumber" class="bom-line">
              <span class="bom-code">{{ line.itemCode }}</span>
              <span class="bom-name">{{ line.itemName }}</span>
              <span class="bom-qty">x{{ line.quantity }}</span>
            </div>
          </div>
          <el-empty v-else description="未加载BOM" :image-size="40" />
        </div>

        <!-- 验证结果 -->
        <div class="right-section" v-if="store.validationResult">
          <div class="section-title">验证结果</div>
          <div :class="['validation-status', validationClass]">
            <el-tag :type="validationTag">{{ validationText }}</el-tag>
          </div>
          <div v-if="store.hasErrors" class="validation-errors">
            <div v-for="err in store.validationResult?.errors" :key="err" class="error-item">
              <el-icon color="#f56c6c"><WarningFilled /></el-icon>
              {{ err }}
            </div>
          </div>
          <div v-if="store.hasWarnings" class="validation-warnings">
            <div v-for="warn in store.validationResult?.warnings" :key="warn" class="warn-item">
              <el-icon color="#e6a23c"><Warning /></el-icon>
              {{ warn }}
            </div>
          </div>
        </div>

        <!-- 定价结果 -->
        <div class="right-section" v-if="store.priceResult">
          <div class="section-title">定价结果</div>
          <div class="price-summary">
            <div class="price-row">
              <span>基准价格</span>
              <span>{{ formatPrice(store.priceResult.basePrice) }}</span>
            </div>
            <div class="price-row" v-if="store.priceResult.discountPct > 0">
              <span>折扣</span>
              <span>{{ store.priceResult.discountPct }}%</span>
            </div>
            <div class="price-row net-price">
              <span>净价</span>
              <span class="net-value">{{ formatPrice(store.priceResult.netPrice) }}</span>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted, watch } from 'vue'
import { useRoute } from 'vue-router'
import { ArrowLeft, Check, CircleCheck, WarningFilled, Warning } from '@element-plus/icons-vue'
import { useConfiguratorStore } from '@/store/configurator'
import { ElMessage } from 'element-plus'
import type { AttributeOptionVo, OptionInfo } from '@/api/configure'

const route = useRoute()
const store = useConfiguratorStore()
const activeAttr = ref<string>('')

const loadModel = async (modelId: string) => {
  try {
    console.log('[Configurator] loading model:', modelId)
    await store.initModel(modelId)
    console.log('[Configurator] model loaded, bomLines count:', store.bomLines.length,
      'first line:', store.bomLines[0])
    const attrs = Object.keys(store.attributes)
    if (attrs.length > 0) {
      activeAttr.value = attrs[0]
    }
  } catch (e: any) {
    console.error('[Configurator] loadModel failed:', e?.message || e)
    ElMessage.error('加载产品配置失败')
  }
}

onMounted(async () => {
  const modelId = route.params.modelId as string
  if (modelId) {
    await loadModel(modelId)
  }
})

// 监听路由参数变化（同一组件内切换产品）
watch(() => route.params.modelId, async (newId) => {
  if (newId) {
    await loadModel(newId as string)
  }
})

const currentOptions = computed<AttributeOptionVo[]>(() => {
  if (!activeAttr.value) return []
  return store.attributes[activeAttr.value] ?? []
})

function getOptionState(optionValue: string): OptionInfo | undefined {
  if (!activeAttr.value) return undefined
  const states = store.optionStates[activeAttr.value]
  if (!states) return undefined
  return states.find(o => o.code === optionValue)
}

function handleSelectOption(option: AttributeOptionVo) {
  const state = getOptionState(option.optionValue)
  if (state && !state.available) {
    ElMessage.warning(state.reason ?? '该选项不可用')
    return
  }
  store.selectOption(activeAttr.value!, option.optionValue)
}

async function handleComplete() {
  if (store.selectionCount === 0) {
    ElMessage.warning('请至少选择一个属性')
    return
  }
  try {
    const result = await store.complete(1)
    console.log('[Configurator] 配置完成响应:', result)
    ElMessage.success('配置完成！')
  } catch (e: any) {
    console.error('[Configurator] 配置完成失败:', e?.message || e)
    const msg = e?.message || e?.toString() || '未知错误'
    ElMessage.error('配置完成失败：' + msg)
  }
}

const typeTag = computed(() => {
  const map: Record<string, string> = {
    STANDARD: '', ATO: 'success', CTO: 'warning', ETO: 'danger', BUNDLE: 'info'
  }
  return map[store.configType] ?? ''
})

const validationClass = computed(() => {
  if (!store.validationResult) return ''
  return {
    PASS: 'pass', SOFT_FAIL: 'soft-fail', HARD_FAIL: 'hard-fail'
  }[store.validationResult.status] ?? ''
})

const validationTag = computed(() => {
  if (!store.validationResult) return ''
  return {
    PASS: 'success', SOFT_FAIL: 'warning', HARD_FAIL: 'danger'
  }[store.validationResult.status] ?? ''
})

const validationText = computed(() => {
  if (!store.validationResult) return ''
  return {
    PASS: '配置通过', SOFT_FAIL: '有警告', HARD_FAIL: '配置冲突'
  }[store.validationResult.status] ?? ''
})

function formatPrice(price: number) {
  return '¥' + ((price ?? 0) / 100).toLocaleString('zh-CN', { minimumFractionDigits: 0, maximumFractionDigits: 2 })
}
</script>

<style scoped>
.configurator-page {
  display: flex;
  flex-direction: column;
  height: 100%;
  background: #f5f7fa;
}
.config-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 12px 20px;
  background: #fff;
  border-bottom: 1px solid #e4e7ed;
}
.header-left {
  display: flex;
  align-items: center;
  gap: 12px;
}
.product-info strong {
  font-size: 16px;
  color: #303133;
}
.config-main {
  display: flex;
  flex: 1;
  overflow: hidden;
}
.config-left {
  width: 220px;
  background: #fff;
  border-right: 1px solid #e4e7ed;
  overflow-y: auto;
  padding: 8px 0;
}
.attr-group {
  padding: 12px 16px;
  cursor: pointer;
  border-left: 3px solid transparent;
  transition: all 0.15s;
}
.attr-group:hover { background: #f0f5ff; }
.attr-group.active { border-left-color: #409eff; background: #e8f0fe; }
.attr-group.selected { background: #f6ffed; }
.attr-label {
  font-size: 14px;
  font-weight: 500;
  color: #303133;
  display: flex;
  align-items: center;
  gap: 4px;
}
.attr-count { font-size: 12px; color: #909399; margin-top: 2px; }
.check-icon { color: #67c23a; }

.config-center {
  flex: 1;
  overflow-y: auto;
  padding: 20px 24px;
  background: #fff;
}
.options-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 16px;
}
.options-header h4 { margin: 0; font-size: 16px; color: #303133; }
.options-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(180px, 1fr));
  gap: 10px;
}
.option-card {
  border: 2px solid #e4e7ed;
  border-radius: 8px;
  padding: 14px;
  cursor: pointer;
  transition: all 0.15s;
  position: relative;
}
.option-card:hover { border-color: #a0cfff; }
.option-card.selected { border-color: #409eff; background: #ecf5ff; }
.option-card.disabled { opacity: 0.5; cursor: not-allowed; border-color: #f5f5f5; }
.option-label { font-size: 15px; font-weight: 500; color: #303133; }
.option-value { font-size: 12px; color: #909399; margin-top: 4px; }
.option-reason { font-size: 11px; color: #f56c6c; margin-top: 4px; }
.recommend-tag { position: absolute; top: 8px; right: 8px; }
.placeholder-center {
  display: flex;
  align-items: center;
  justify-content: center;
  height: 100%;
}

.config-right {
  width: 300px;
  background: #fff;
  border-left: 1px solid #e4e7ed;
  overflow-y: auto;
  padding: 12px;
}
.right-section {
  margin-bottom: 16px;
}
.section-title {
  font-size: 13px;
  font-weight: 600;
  color: #909399;
  margin-bottom: 8px;
  padding-bottom: 4px;
  border-bottom: 1px solid #f0f0f0;
}
.bom-line {
  display: flex;
  align-items: center;
  padding: 4px 0;
  font-size: 12px;
  gap: 6px;
}
.bom-code { font-family: monospace; color: #409eff; }
.bom-name { flex: 1; color: #303133; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
.bom-qty { color: #909399; }

.validation-status { margin-bottom: 4px; }
.validation-errors { margin-top: 8px; }
.error-item, .warn-item {
  display: flex;
  align-items: center;
  gap: 4px;
  font-size: 12px;
  padding: 2px 0;
}
.error-item { color: #f56c6c; }
.warn-item { color: #e6a23c; }

.price-summary { font-size: 13px; }
.price-row {
  display: flex;
  justify-content: space-between;
  padding: 4px 0;
  color: #606266;
}
.net-price {
  font-weight: 600;
  color: #303133;
  border-top: 1px solid #e4e7ed;
  padding-top: 8px;
  margin-top: 4px;
}
.net-value { color: #f56c6c; font-size: 16px; }
</style>
