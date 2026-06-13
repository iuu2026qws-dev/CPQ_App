import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import {
  loadConfigModel,
  validateSelections,
  completeConfiguration,
  propagateConstraints,
  getGuideStep,
  getBomPreview,
  calculatePrice,
  type ConfigModelResponse,
  type ValidationResult,
  type OptionInfo,
  type GuideStep,
  type PriceResult,
  type MbomLine
} from '@/api/configure'

/**
 * 配置器 Pinia Store（Sprint 6）
 * 管理配置会话状态：产品加载 → 属性选择 → 约束传播 → 验证 → 定价 → 完成
 */
export const useConfiguratorStore = defineStore('configurator', () => {
  // ========== 状态 ==========
  const modelId = ref<string | null>(null)
  const modelData = ref<ConfigModelResponse | null>(null)
  const selections = ref<Record<string, string>>({})
  const optionStates = ref<Record<string, OptionInfo[]>>({})
  const validationResult = ref<ValidationResult | null>(null)
  const guideStep = ref<GuideStep | null>(null)
  const priceResult = ref<PriceResult | null>(null)
  const mbomLines = ref<MbomLine[]>([])
  /** BOM预览：根据当前属性选择实时刷新（ATO等场景用） */
  const previewBomLines = ref<MbomLine[]>([])
  const loading = ref(false)
  const step = ref<'search' | 'configure' | 'review'>('search')

  // ========== 计算属性 ==========
  const modelName = computed(() => modelData.value?.modelName ?? '')
  const modelCode = computed(() => modelData.value?.modelCode ?? '')
  const configType = computed(() => modelData.value?.configType ?? '')
  const attributes = computed(() => modelData.value?.attributes ?? {})
  const bomLines = computed(() => modelData.value?.bomLines ?? [])
  const selectionCount = computed(() => Object.keys(selections.value).length)
  const isValid = computed(() => validationResult.value?.status === 'PASS')
  const hasErrors = computed(() => (validationResult.value?.errors?.length ?? 0) > 0)
  const hasWarnings = computed(() => (validationResult.value?.warnings?.length ?? 0) > 0)
  const currentAttribute = computed(() => guideStep.value?.currentAttribute ?? '')

  // ========== 操作 ==========

  /** 加载配置模型 */
  async function initModel(id: string) {
    loading.value = true
    try {
      modelId.value = id
      modelData.value = await loadConfigModel(id)
      selections.value = {}
      optionStates.value = {}
      validationResult.value = null
      guideStep.value = null
      priceResult.value = null
      mbomLines.value = []
      step.value = 'configure'
    } finally {
      loading.value = false
    }
  }

  /** 选择一个属性值 */
  async function selectOption(attrName: string, optionValue: string) {
    selections.value = { ...selections.value, [attrName]: optionValue }
    // 同步约束传播
    await refreshPropagation()
  }

  /** 取消选择一个属性 */
  function deselectOption(attrName: string) {
    const next = { ...selections.value }
    delete next[attrName]
    selections.value = next
    refreshPropagation()
  }

  /** 刷新约束传播 */
  async function refreshPropagation() {
    if (!modelId.value || Object.keys(selections.value).length === 0) return
    try {
      optionStates.value = await propagateConstraints(modelId.value, selections.value)
    } catch {
      // 传播失败不阻塞
    }
  }

  /** 验证当前选择 */
  async function validate() {
    if (!modelId.value) return
    loading.value = true
    try {
      validationResult.value = await validateSelections(modelId.value, selections.value)
    } finally {
      loading.value = false
    }
  }

  /** 获取向导步骤 */
  async function nextGuideStep() {
    if (!modelId.value) return
    loading.value = true
    try {
      guideStep.value = await getGuideStep(modelId.value, selections.value)
    } finally {
      loading.value = false
    }
  }

  /** 根据当前属性选择实时刷新BOM预览（ATO等场景） */
  async function refreshBomPreview() {
    if (!modelId.value) return
    try {
      previewBomLines.value = await getBomPreview(modelId.value, selections.value)
    } catch {
      // 预览刷新失败不阻塞用户操作
    }
  }

  /** 完成配置（验证 + BOM + 定价） */
  async function complete(quantity: number = 1) {
    if (!modelId.value) return null
    loading.value = true
    try {
      const result = await completeConfiguration(modelId.value, selections.value, quantity)
      validationResult.value = result.validation
      mbomLines.value = result.mbomLines ?? []
      priceResult.value = result.price
      step.value = 'review'
      return result
    } finally {
      loading.value = false
    }
  }

  /** 重置配置器 */
  function reset() {
    modelId.value = null
    modelData.value = null
    selections.value = {}
    optionStates.value = {}
    validationResult.value = null
    guideStep.value = null
    priceResult.value = null
    mbomLines.value = []
    step.value = 'search'
  }

  return {
    // state
    modelId, modelData, selections, optionStates,
    validationResult, guideStep, priceResult, mbomLines, previewBomLines,
    loading, step,
    // computed
    modelName, modelCode, configType, attributes, bomLines,
    selectionCount, isValid, hasErrors, hasWarnings, currentAttribute,
    // actions
    initModel, selectOption, deselectOption, refreshPropagation,
    validate, nextGuideStep, refreshBomPreview, complete, reset
  }
})
