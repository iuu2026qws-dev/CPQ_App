<template>
  <div class="mobile-configurator">
    <div class="config-header">
      <h4>引导式产品配置</h4>
      <p>回答 {{ questions.length }} 个问题即可完成配置</p>
    </div>

    <!-- 问答式引导 -->
    <div
      v-for="(q, qi) in questions"
      :key="qi"
      class="question-card"
      :class="{ answered: answers[qi] !== undefined }"
    >
      <div class="question-label">Q{{ qi + 1 }}. {{ q.label }}</div>
      <div class="option-list">
        <div
          v-for="opt in q.options"
          :key="opt.value"
          class="option-item"
          :class="{ selected: answers[qi] === opt.value }"
          @click="selectOption(qi, opt.value)"
        >
          <span>{{ opt.label }}</span>
          <el-icon v-if="answers[qi] === opt.value" color="#409eff"><Check /></el-icon>
        </div>
      </div>
    </div>

    <!-- 配置摘要 -->
    <div v-if="configComplete" class="config-summary">
      <h4>配置摘要</h4>
      <div v-for="(a, i) in answers" :key="i" class="summary-row">
        <span>{{ questions[i].label }}</span>
        <span>{{ getOptionLabel(i, a) }}</span>
      </div>
    </div>

    <button
      v-if="allAnswered && !configComplete"
      class="btn-complete"
      @click="completeConfig"
    >完成配置</button>
    <button
      v-if="configComplete"
      class="btn-to-quote"
      @click="proceedToQuote"
    >去报价</button>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, inject } from 'vue'
import { useRouter } from 'vue-router'
import { Check } from '@element-plus/icons-vue'

const router = useRouter()
const haptic = inject<(style: string) => void>('haptic')
const showToast = inject<(msg: string, type: string) => void>('showToast')

const questions = [
  {
    label: '使用场景',
    options: [
      { label: '常规生产', value: 'PRODUCTION' },
      { label: '高负荷连续运转', value: 'HIGH_LOAD' },
      { label: '洁净环境', value: 'CLEAN_ROOM' },
    ]
  },
  {
    label: '控制方式',
    options: [
      { label: 'PLC 标准控制', value: 'PLC' },
      { label: '嵌入式专用控制', value: 'EMBEDDED' },
      { label: '物联网远程控制', value: 'IOT' },
    ]
  },
  {
    label: '防护等级',
    options: [
      { label: 'IP54 标准防护', value: 'IP54' },
      { label: 'IP65 防尘防水', value: 'IP65' },
      { label: 'IP67 浸水防护', value: 'IP67' },
    ]
  },
]

const answers = ref<(string | undefined)[]>(new Array(questions.length).fill(undefined))
const configComplete = ref(false)

const allAnswered = computed(() => answers.value.every(a => a !== undefined))

function selectOption(qi: number, val: string) {
  haptic?.('light')
  answers.value[qi] = val
}

function getOptionLabel(qi: number, val: string | undefined): string {
  if (!val) return '—'
  return questions[qi].options.find(o => o.value === val)?.label || val
}

function completeConfig() {
  haptic?.('medium')
  configComplete.value = true
  showToast?.('配置完成', 'success')
}

function proceedToQuote() {
  haptic?.('heavy')
  router.push('/mobile/quote')
}
</script>

<style scoped>
.mobile-configurator { padding: 16px; min-height: 100%; }
.config-header { text-align: center; margin-bottom: 20px; }
.config-header h4 { font-size: 17px; margin: 0 0 4px; }
.config-header p  { font-size: 13px; color: #999; }

.question-card {
  background: #fff; border-radius: 12px; padding: 16px;
  margin-bottom: 12px; border: 2px solid transparent;
  transition: border-color 0.3s;
}
.question-card.answered { border-color: #e6f7ff; }
.question-label { font-size: 15px; font-weight: 600; color: #333; margin-bottom: 10px; }

.option-list { display: flex; flex-direction: column; gap: 8px; }
.option-item {
  display: flex; justify-content: space-between; align-items: center;
  padding: 12px; background: #f9f9f9; border-radius: 8px;
  border: 1.5px solid transparent;
  font-size: 14px; cursor: pointer;
  transition: all 0.2s;
}
.option-item.selected { border-color: #409eff; background: #f0f5ff; font-weight: 500; }
.option-item:active   { transform: scale(0.98); }

.config-summary {
  background: #fff; border-radius: 12px; padding: 16px; margin: 16px 0;
}
.config-summary h4 { margin: 0 0 12px; font-size: 16px; }
.summary-row { display: flex; justify-content: space-between; padding: 6px 0; font-size: 14px; color: #555; }

.btn-complete, .btn-to-quote {
  width: 100%; height: 46px; border: none; border-radius: 12px;
  font-size: 16px; font-weight: 600; cursor: pointer; margin-top: 10px;
}
.btn-complete { background: #409eff; color: #fff; }
.btn-to-quote { background: #67c23a; color: #fff; }
</style>
