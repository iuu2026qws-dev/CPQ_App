<template>
  <div class="guided-selling">
    <!-- 无产品时：显示产品搜索入口 -->
    <template v-if="!route.params.modelId">
      <div class="search-entry">
        <div class="entry-header">
          <h1 class="entry-title">向导式配置</h1>
          <p class="entry-desc">逐步引导您选择最适合的产品配置。回答几个简单问题，系统将为您推荐最优配置方案。</p>
        </div>
        <div class="search-box">
          <el-input
            v-model="keyword"
            placeholder="输入产品名称或编码搜索"
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
            @click="startGuide(p.modelId)"
          >
            <div class="product-info">
              <h3>{{ p.modelCode }}</h3>
              <p>{{ p.modelName }}</p>
              <el-tag size="small" :type="configTypeTag(p.configType)">{{ p.configType }}</el-tag>
            </div>
          </el-card>
        </div>
        <el-empty v-if="searched && products.length === 0" description="未找到匹配的产品" />
      </div>
    </template>

    <!-- 有产品时：5阶段向导 -->
    <template v-else>
      <div class="wizard-header">
        <div class="model-info">
          <span class="model-code">{{ store.modelCode }}</span>
          <span class="model-name">{{ store.modelName }}</span>
        </div>
        <el-steps :active="currentStepIndex" align-center class="wizard-steps">
          <el-step title="问题引导" description="选择场景偏好" />
          <el-step title="范围缩小" description="过滤匹配产品" />
          <el-step title="智能推荐" description="推荐最优配置" />
          <el-step title="确认配置" description="查看配置详情" />
          <el-step title="完成" description="生成报价" />
        </el-steps>
      </div>

      <!-- 加载中状态 -->
      <div v-if="wizardLoading" class="loading-hint">
        <el-icon class="is-loading" :size="40"><Loading /></el-icon>
        <p class="loading-text">正在加载向导数据...</p>
        <p class="loading-sub">请稍候，正在与服务器通信</p>
        <el-button style="margin-top:20px" @click="forceStopLoading">取消等待</el-button>
      </div>

      <!-- 已加载状态 -->
      <div v-else class="wizard-content">
        <!-- 错误状态 -->
        <el-result v-if="wizardError" icon="error" title="向导加载失败" :sub-title="wizardError">
          <template #extra>
            <el-button type="primary" @click="goBackToSearch">返回搜索</el-button>
            <el-button @click="initWizard(route.params.modelId as string)">重试</el-button>
          </template>
        </el-result>

        <!-- 兜底：guideData存在但state不匹配（未知状态） -->
        <el-result v-else-if="guideData && !guideData.state" icon="warning" title="向导状态未知">
          <template #sub-title>当前状态: {{ guideData.state || '(未设置)' }}</template>
          <template #extra>
            <el-button type="primary" @click="goBackToSearch">返回搜索</el-button>
            <el-button @click="initWizard(route.params.modelId as string)">重新加载</el-button>
          </template>
        </el-result>

        <!-- 空状态：guideData还没有返回 -->
        <el-empty
          v-else-if="!guideData"
          description="向导数据尚未就绪，请稍候..."
        >
          <template #extra>
            <el-button type="primary" @click="goBackToSearch">返回搜索</el-button>
            <el-button @click="initWizard(route.params.modelId as string)">重新加载</el-button>
          </template>
        </el-empty>

        <!-- Step 1: Questioning 问题引导 -->
        <el-card v-else-if="guideData && guideData.state === 'QUESTIONING'" class="step-card">
          <template #header><span class="step-title">请选择「{{ guideData.currentAttribute || '未知属性' }}」</span></template>
          <div class="option-list">
            <el-card
              v-for="opt in (guideData.options || [])"
              :key="opt.code"
              class="option-card"
              :class="{ selected: selections[guideData.currentAttribute] === opt.code }"
              shadow="hover"
              @click="selectGuideOption(guideData.currentAttribute, opt.code)"
            >
              <div class="option-info">
                <h4>{{ opt.label }}</h4>
                <p v-if="opt.reason">{{ opt.reason }}</p>
              </div>
              <el-icon v-if="selections[guideData.currentAttribute] === opt.code" class="check-icon" color="#409EFF"><CircleCheckFilled /></el-icon>
            </el-card>
          </div>
          <el-empty v-if="!guideData.options || guideData.options.length === 0" description="当前属性无可选选项" />
          <div class="step-actions">
            <el-button type="primary" :disabled="!selections[guideData.currentAttribute]" @click="nextStep">下一步</el-button>
          </div>
        </el-card>

        <!-- Step 2: Narrowing 范围缩小 -->
        <el-card v-else-if="guideData && guideData.state === 'NARROWING'" class="step-card">
          <template #header>
            <span class="step-title">匹配产品范围已缩小</span>
          </template>
          <div class="narrow-summary">
            <p v-if="guideData.recommendation">{{ guideData.recommendation }}</p>
            <p v-else>基于您之前的选择，系统过滤掉了不满足约束的选项。</p>
            <div v-if="guideData.prohibited && Object.keys(guideData.prohibited).length > 0">
              <p>当前禁止的选项：</p>
              <el-tag v-for="(value, key) in guideData.prohibited" :key="key" type="danger" style="margin:2px">
                {{ key }}: {{ value }}
              </el-tag>
            </div>
          </div>
          <div class="step-actions">
            <el-button @click="prevStep">上一步</el-button>
            <el-button type="primary" @click="nextStep">查看推荐</el-button>
          </div>
        </el-card>

        <!-- Step 3: Recommending 智能推荐 -->
        <el-card v-else-if="guideData && guideData.state === 'RECOMMENDING'" class="step-card">
          <template #header><span class="step-title">推荐配置</span></template>
          <div class="recommend-list" v-if="guideData.recommendation">
            <el-alert type="success" :title="guideData.recommendation" :closable="false" show-icon />
          </div>
          <el-empty v-else description="暂无推荐结果" />
          <div class="step-actions">
            <el-button @click="prevStep">上一步</el-button>
            <el-button type="primary" @click="nextStep">进入配置确认</el-button>
          </div>
        </el-card>

        <!-- Step 4: Configuring 确认配置 -->
        <el-card v-else-if="guideData && guideData.state === 'CONFIGURING'" class="step-card">
          <template #header><span class="step-title">配置确认</span></template>
          <el-descriptions :column="2" border>
            <el-descriptions-item label="产品编码">{{ store.modelCode }}</el-descriptions-item>
            <el-descriptions-item label="产品名称">{{ store.modelName }}</el-descriptions-item>
            <el-descriptions-item
              v-for="(value, key) in selections"
              :key="key"
              :label="key"
            >{{ value }}</el-descriptions-item>
          </el-descriptions>
          <div class="step-actions">
            <el-button @click="prevStep">上一步</el-button>
            <el-button type="success" :loading="completing" @click="completeGuide">完成配置并生成报价</el-button>
          </div>
        </el-card>

        <!-- Step 5: Completed 完成 -->
        <el-card v-else-if="guideData && guideData.state === 'COMPLETED'" class="step-card">
          <template #header><span class="step-title">配置完成</span></template>
          <el-result icon="success" title="配置已完成" :sub-title="`产品「${store.modelName}」配置成功`">
            <template #extra>
              <el-button type="primary" @click="goToConfigurator">查看完整配置</el-button>
              <el-button @click="startOver">重新配置</el-button>
            </template>
          </el-result>
          <div v-if="store.priceResult" class="price-summary">
            <el-descriptions :column="2" border>
              <el-descriptions-item label="预估价格">¥ {{ store.priceResult.netPrice || '—' }}</el-descriptions-item>
              <el-descriptions-item label="基础价格">¥ {{ store.priceResult.basePrice || '—' }}</el-descriptions-item>
            </el-descriptions>
          </div>
        </el-card>
      </div>

      <div class="selection-breadcrumb" v-if="Object.keys(selections).length > 0">
        <span class="crumb-title">已选属性：</span>
        <el-tag v-for="(value, key) in selections" :key="key" closable @close="removeSelection(key)">
          {{ key }}: {{ value }}
        </el-tag>
      </div>
    </template>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted, onUnmounted, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { Search, CircleCheckFilled, Loading } from '@element-plus/icons-vue'
import { useConfiguratorStore } from '@/store/configurator'
import { searchModel } from '@/api/cpq/product'
import { getGuideStep } from '@/api/configure'
import type { CpqProductModelVo } from '@/api/cpq/product'
import type { GuideStep } from '@/api/configure'

const route = useRoute()
const router = useRouter()
const store = useConfiguratorStore()

const keyword = ref('')
const searchLoading = ref(false)
const searched = ref(false)
const products = ref<CpqProductModelVo[]>([])
const guideData = ref<GuideStep | null>(null)
const selections = ref<Record<string, string>>({})
const completing = ref(false)
const wizardLoading = ref(false)
const wizardError = ref('')
// 安全超时：如果加载超过 15 秒，强制暴露错误
const SAFETY_TIMEOUT_MS = 15000
let safetyTimer: ReturnType<typeof setTimeout> | null = null

const stepMap: Record<string, number> = {
  QUESTIONING: 0, NARROWING: 1, RECOMMENDING: 2, CONFIGURING: 3, COMPLETED: 4
}
const currentStepIndex = computed(() => {
  if (!guideData.value) return 0
  return stepMap[guideData.value.state] ?? 0
})

onMounted(async () => {
  const modelId = route.params.modelId as string
  if (modelId) {
    await initWizard(modelId)
  }
})

onUnmounted(() => {
  clearSafetyTimer()
})

watch(() => route.params.modelId, async (newId) => {
  if (newId) {
    await initWizard(newId as string)
  }
})

function startSafetyTimer(modelId: string) {
  clearSafetyTimer()
  safetyTimer = setTimeout(() => {
    if (wizardLoading.value) {
      console.error('[GuidedSelling] SAFETY TIMEOUT after', SAFETY_TIMEOUT_MS, 'ms, force-clearing loading')
      wizardLoading.value = false
      wizardError.value = '加载超时（15秒），请检查网络连接或联系管理员。modelId=' + modelId
    }
  }, SAFETY_TIMEOUT_MS)
}

function clearSafetyTimer() {
  if (safetyTimer !== null) {
    clearTimeout(safetyTimer)
    safetyTimer = null
  }
}

async function initWizard(modelId: string) {
  wizardLoading.value = true
  wizardError.value = ''
  startSafetyTimer(modelId)
  console.log('[GuidedSelling] initWizard start, modelId:', modelId, 'store.loading:', store.loading)

  try {
    console.log('[GuidedSelling] calling store.initModel...')
    await store.initModel(modelId)
    console.log('[GuidedSelling] initModel SUCCESS. modelCode:', store.modelCode, 'modelName:', store.modelName, 'hasAttributes:', Object.keys(store.attributes).length)
  } catch (e: any) {
    const msg = e?.message || '加载产品模型失败'
    console.error('[GuidedSelling] initModel FAILED:', msg, e)
    wizardError.value = msg
    wizardLoading.value = false
    clearSafetyTimer()
    return // 模型加载失败，不再继续加载向导步骤
  }

  try {
    console.log('[GuidedSelling] calling loadGuideStep...')
    await loadGuideStep()
    console.log('[GuidedSelling] loadGuideStep SUCCESS. guideData.state:', guideData.value?.state, 'currentAttribute:', guideData.value?.currentAttribute)
  } catch (e: any) {
    const msg = e?.message || '加载向导步骤失败'
    console.error('[GuidedSelling] loadGuideStep FAILED:', msg, e)
    wizardError.value = msg
  } finally {
    wizardLoading.value = false
    clearSafetyTimer()
    console.log('[GuidedSelling] initWizard end. wizardLoading:', wizardLoading.value, 'wizardError:', wizardError.value, 'guideData:', !!guideData.value)
  }
}

async function searchProducts() {
  if (!keyword.value.trim()) return
  searchLoading.value = true
  searched.value = true
  try {
    const res = await searchModel(keyword.value.trim())
    products.value = Array.isArray(res) ? res : ((res as any).data || [])
  } finally {
    searchLoading.value = false
  }
}

function startGuide(modelId: number) {
  router.push('/configure-guided/' + modelId)
}

function configTypeTag(type: string): string {
  const map: Record<string, string> = { STANDARD: '', ATO: 'warning', CTO: 'danger', ETO: 'info', BUNDLE: 'success' }
  return map[type] || ''
}

async function loadGuideStep() {
  const modelId = route.params.modelId as string
  console.log('[GuidedSelling] loadGuideStep calling getGuideStep, modelId:', modelId, 'selections:', selections.value)

  let result: any
  try {
    result = await getGuideStep(modelId, selections.value)
    console.log('[GuidedSelling] getGuideStep raw result type:', typeof result, 'isNull:', result === null)
  } catch (e: any) {
    console.error('[GuidedSelling] getGuideStep HTTP error:', e?.message || e)
    // 使用 store 的 guideStep 作为兜底
    const fallback = store.guideStep
    if (fallback) {
      console.log('[GuidedSelling] using store.guideStep fallback')
      guideData.value = fallback
      return
    }
    throw e // 重新抛出，让 initWizard 处理
  }

  // 安全类型检查：防止 result 不是期望的对象
  if (!result || typeof result !== 'object') {
    console.error('[GuidedSelling] getGuideStep returned unexpected type:', typeof result)
    throw new Error('向导数据格式异常，请联系管理员')
  }

  // 确保 state 不为空
  if (!result.state) {
    console.warn('[GuidedSelling] guideStep.state is null/unset, setting to QUESTIONING fallback')
    result.state = 'QUESTIONING'
  }

  // NARROWING state 在模板中无选项选择UI，与 QUESTIONING 本质相同（都需要用户选择属性值）
  // 将 NARROWING 映射为 QUESTIONING，让用户能在选项卡片中选择
  if (result.state === 'NARROWING') {
    console.log('[GuidedSelling] NARROWING→QUESTIONING (need option selection UI)')
    result.state = 'QUESTIONING'
  }

  // 确保 options 不为 null
  if (!result.options) {
    console.warn('[GuidedSelling] guideStep.options is null, setting to []')
    result.options = []
  }

  if (!result.currentAttribute) {
    console.warn('[GuidedSelling] guideStep.currentAttribute is null, setting to empty string')
    result.currentAttribute = ''
  }

  // 确保 prohibited 不为 null（后端从未设置，必须兜底）
  if (!result.prohibited) {
    result.prohibited = {}
  }

  guideData.value = result as GuideStep
}

function selectGuideOption(attrName: string, optionCode: string) {
  selections.value[attrName] = optionCode
  store.selectOption(attrName, optionCode).catch(() => {})
}

function removeSelection(attrName: string) {
  delete selections.value[attrName]
  store.deselectOption(attrName)
}

async function nextStep() {
  // RECOMMENDING 状态下点击"进入配置确认" → 直接转到 CONFIGURING
  // 原因：后端 guidedSelling() 从不返回 CONFIGURING 状态（该状态转换后端未实现），
  // 若仍调用 loadGuideStep() 会进入死循环（永远返回 RECOMMENDING 或 QUESTIONING）
  if (guideData.value?.state === 'RECOMMENDING') {
    console.log('[GuidedSelling] RECOMMENDING → CONFIGURING (direct transition, skip guide API)')
    guideData.value = { ...guideData.value, state: 'CONFIGURING' } as GuideStep
    return
  }

  // NARROWING（已被映射为 QUESTIONING）→ 可能在选完后进入 RECOMMENDING 或 COMPLETED
  wizardLoading.value = true
  try {
    await loadGuideStep()
  } finally {
    wizardLoading.value = false
  }
}

async function prevStep() {
  // CONFIGURING → 回到 RECOMMENDING（保持之前的推荐状态）
  if (guideData.value?.state === 'CONFIGURING') {
    console.log('[GuidedSelling] CONFIGURING → RECOMMENDING (direct transition back)')
    guideData.value = { ...guideData.value, state: 'RECOMMENDING' } as GuideStep
    return
  }

  // QUESTIONING/其他 → 重新调用 guide API 获取上一步状态
  wizardLoading.value = true
  try {
    await loadGuideStep()
  } finally {
    wizardLoading.value = false
  }
}

async function completeGuide() {
  completing.value = true
  try {
    await store.complete()
    guideData.value = { ...guideData.value!, state: 'COMPLETED' } as GuideStep
  } catch (e: any) {
    console.error('完成配置失败:', e)
  } finally {
    completing.value = false
  }
}

function goToConfigurator() {
  router.push('/configure-review/' + route.params.modelId)
}

function startOver() {
  selections.value = {}
  guideData.value = null
  wizardError.value = ''
  store.reset()
  // 直接重新初始化向导（不能用 router.push 同路由，Vue Router 不会触发 navigation）
  const modelId = route.params.modelId as string
  if (modelId) {
    initWizard(modelId)
  } else {
    router.push('/configure-guided')
  }
}

/** 强制停止 loading（安全网） */
function forceStopLoading() {
  console.warn('[GuidedSelling] forceStopLoading called by user')
  wizardLoading.value = false
  wizardError.value = '用户取消了等待。请检查网络连接后重试。'
  clearSafetyTimer()
}

/** 回退到搜索页 */
function goBackToSearch() {
  startOver()
}
</script>

<style scoped lang="scss">
.guided-selling {
  max-width: 900px;
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

  .wizard-header {
    margin-bottom: 24px;
    .model-info {
      display: flex;
      align-items: center;
      gap: 12px;
      margin-bottom: 20px;
      .model-code { font-size: 20px; font-weight: 700; color: var(--cpq-primary); }
      .model-name { font-size: 14px; color: #909399; }
    }
    .wizard-steps { max-width: 800px; margin: 0 auto; }
  }

  .loading-hint {
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    padding: 80px 20px;
    color: #909399;
    .loading-text { font-size: 18px; font-weight: 600; margin: 16px 0 8px; color: #606266; }
    .loading-sub { font-size: 13px; }
  }

  .wizard-content {
    .step-card {
      margin-bottom: 24px;
      .step-title { font-size: 16px; font-weight: 600; }
      .step-actions { display: flex; gap: 12px; justify-content: flex-end; margin-top: 24px; }
    }

    .option-list {
      display: grid;
      grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
      gap: 12px;
      .option-card {
        cursor: pointer;
        position: relative;
        transition: all 0.2s;
        border: 2px solid transparent;
        &.selected { border-color: var(--cpq-primary); background: rgba(64,158,255,0.04); }
        &:hover { border-color: #c0c4cc; }
        .option-info {
          h4 { font-size: 15px; margin-bottom: 4px; }
          p { color: #909399; font-size: 12px; }
        }
        .check-icon { position: absolute; top: 12px; right: 12px; font-size: 20px; }
      }
    }

    .narrow-summary { padding: 12px 0; color: #606266; }
    .recommend-list {
      display: flex;
      flex-direction: column;
      gap: 12px;
      .recommend-card {
        .recommend-header { display: flex; justify-content: space-between; align-items: center; }
        .recommend-reason { color: #909399; font-size: 13px; margin-top: 8px; }
      }
    }

    .price-summary { margin-top: 24px; }
  }

  .selection-breadcrumb {
    display: flex;
    align-items: center;
    gap: 8px;
    flex-wrap: wrap;
    padding: 12px 16px;
    background: #f5f7fa;
    border-radius: 8px;
    margin-top: 16px;
    .crumb-title { font-size: 13px; color: #909399; }
  }
}
</style>
