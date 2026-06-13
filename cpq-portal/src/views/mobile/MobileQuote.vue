<template>
  <div class="mobile-quote">
    <!-- 步骤导航 -->
    <div class="step-progress">
      <div
        v-for="(step, i) in steps"
        :key="i"
        class="step-dot"
        :class="{ active: i <= currentStep }"
      />
    </div>
    <h4 class="step-title">{{ steps[currentStep] }}</h4>

    <!-- 步骤 1：选择产品 -->
    <div v-if="currentStep === 0" class="step-content">
      <div class="quick-options">
        <div
          v-for="p in suggestedProducts"
          :key="p.id"
          class="product-option"
          :class="{ selected: selectedProduct?.id === p.id }"
          @click="selectProduct(p)"
        >
          <span class="product-name">{{ p.name }}</span>
          <span class="product-desc">{{ p.description }}</span>
          <el-icon v-if="selectedProduct?.id === p.id" class="check-mark" color="#409eff"><Check /></el-icon>
        </div>
      </div>
      <div v-if="!suggestedProducts.length" class="empty-hint">加载产品中...</div>
    </div>

    <!-- 步骤 2：核心参数 -->
    <div v-if="currentStep === 1" class="step-content">
      <div class="param-group">
        <label class="param-label">预计数量</label>
        <div class="qty-input">
          <button class="qty-btn" @click="adjustQty(-1)">−</button>
          <input v-model.number="quantity" type="number" min="1" class="qty-field" />
          <button class="qty-btn" @click="adjustQty(1)">+</button>
          <span class="qty-unit">{{ selectedProduct?.unit || '台' }}</span>
        </div>
      </div>
      <div class="param-group">
        <label class="param-label">期望交期</label>
        <input v-model="deliveryDate" type="date" class="date-input" />
      </div>
      <div class="param-group">
        <label class="param-label">目标区域</label>
        <el-select v-model="region" placeholder="选择区域" class="region-select">
          <el-option label="华东" value="EAST" />
          <el-option label="华南" value="SOUTH" />
          <el-option label="华北" value="NORTH" />
          <el-option label="西南" value="WEST" />
        </el-select>
      </div>
    </div>

    <!-- 步骤 3：确认提交 -->
    <div v-if="currentStep === 2" class="step-content">
      <div class="summary-card">
        <div class="summary-row"><span>产品</span><span>{{ selectedProduct?.name }}</span></div>
        <div class="summary-row"><span>数量</span><span>{{ quantity }} {{ selectedProduct?.unit || '台' }}</span></div>
        <div class="summary-row"><span>交期</span><span>{{ deliveryDate || '未指定' }}</span></div>
        <div class="summary-row"><span>区域</span><span>{{ region }}</span></div>
        <div class="summary-divider" />
        <div class="summary-row total">
          <span>预估总价</span>
          <span class="total-amount">¥{{ estimatedPrice > 0 ? estimatedPrice.toLocaleString() : '计算中...' }}</span>
        </div>
      </div>
    </div>

    <!-- 底部操作 -->
    <div class="step-footer">
      <button v-if="currentStep > 0" class="btn-prev" @click="currentStep--">上一步</button>
      <button
        v-if="currentStep < 2"
        class="btn-next"
        :disabled="!canProceed"
        @click="nextStep"
      >下一步</button>
      <button
        v-if="currentStep === 2"
        class="btn-submit"
        :disabled="submitting"
        @click="submitQuote"
      >
        <el-icon v-if="submitting" class="spinning"><Loading /></el-icon>
        {{ submitting ? '提交中...' : '提交报价' }}
      </button>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted, inject } from 'vue'
import { useRouter } from 'vue-router'
import { Check, Loading } from '@element-plus/icons-vue'
import { useUserStore } from '@/store/user'

const router = useRouter()
const userStore = useUserStore()
const haptic = inject<(style: string) => void>('haptic')
const showToast = inject<(msg: string, type: string) => void>('showToast')

const steps = ['选择产品', '核心参数', '确认提交']
const currentStep = ref(0)
const submitting = ref(false)

const suggestedProducts = ref<any[]>([])
const selectedProduct = ref<any>(null)
const quantity = ref(1)
const deliveryDate = ref('')
const region = ref('EAST')
const estimatedPrice = ref(0)

const canProceed = computed(() => {
  if (currentStep.value === 0) return selectedProduct.value !== null
  if (currentStep.value === 1) return quantity.value >= 1
  return true
})

function selectProduct(p: any) {
  haptic?.('light')
  selectedProduct.value = p
}

function adjustQty(delta: number) {
  haptic?.('light')
  quantity.value = Math.max(1, quantity.value + delta)
}

function nextStep() {
  haptic?.('medium')
  if (currentStep.value === 1 && estimatedPrice.value === 0) {
    computePrice()
  }
  currentStep.value++
}

async function computePrice() {
  if (!selectedProduct.value) return
  try {
    const token = userStore.token
    const r = await fetch('/api/cpq/engine/pricing/calculate', {
      method: 'POST',
      headers: { Authorization: `Bearer ${token}`, clientid: 'e5cd7e4891bf95d1d19206ce24a7b32e', 'Content-Type': 'application/json' },
      body: JSON.stringify({
        productId: selectedProduct.value.id,
        quantity: quantity.value,
        region: region.value
      })
    })
    const data = await r.json()
    if (data.code === 200 && data.data) {
      estimatedPrice.value = data.data.netPrice || data.data.totalPrice || 0
    }
  } catch {}
}

async function submitQuote() {
  haptic?.('heavy')
  submitting.value = true
  try {
    const token = userStore.token
    const r = await fetch('/api/cpq/quickquote/create', {
      method: 'POST',
      headers: { Authorization: `Bearer ${token}`, clientid: 'e5cd7e4891bf95d1d19206ce24a7b32e', 'Content-Type': 'application/json' },
      body: JSON.stringify({
        productId: selectedProduct.value.id,
        productName: selectedProduct.value.name,
        quantity: quantity.value,
        deliveryDate: deliveryDate.value || undefined,
        region: region.value
      })
    })
    const data = await r.json()
    if (data.code === 200) {
      showToast?.('报价提交成功', 'success')
      setTimeout(() => router.push('/mobile/home'), 1200)
    } else {
      showToast?.(data.msg || '提交失败', 'error')
    }
  } catch {
    showToast?.('网络错误', 'error')
  } finally {
    submitting.value = false
  }
}

onMounted(async () => {
  try {
    const token = userStore.token
    const r = await fetch('/api/cpq/product/model/list?pageNum=1&pageSize=10', {
      headers: { Authorization: `Bearer ${token}`, clientid: 'e5cd7e4891bf95d1d19206ce24a7b32e' }
    })
    const data = await r.json()
    if (data.code === 200 && data.data) {
      const models = data.data.rows || data.data || []
      suggestedProducts.value = models.map((m: any) => ({
        id: m.modelId,
        name: m.modelName || m.modelCode,
        description: m.modelDesc || '',
        unit: m.unit || '台'
      }))
    }
  } catch {}
})
</script>

<style scoped>
.mobile-quote { padding: 16px; padding-bottom: 90px; min-height: 100%; }

.step-progress { display: flex; justify-content: center; gap: 12px; margin-bottom: 12px; }
.step-dot {
  width: 10px; height: 10px; border-radius: 50%; background: #e0e0e0; transition: all 0.3s;
}
.step-dot.active { background: #409eff; transform: scale(1.2); }

.step-title { text-align: center; font-size: 17px; font-weight: 600; margin: 0 0 20px; color: #1a1a1a; }

.step-content { margin-bottom: 20px; }

.quick-options { display: flex; flex-direction: column; gap: 10px; }
.product-option {
  display: flex; align-items: center; gap: 10px;
  padding: 14px; background: #fff; border-radius: 10px;
  border: 2px solid transparent; cursor: pointer;
}
.product-option.selected { border-color: #409eff; background: #f0f5ff; }
.product-name { font-weight: 600; font-size: 14px; flex-shrink: 0; }
.product-desc { font-size: 12px; color: #999; flex: 1; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }

.param-group { margin-bottom: 16px; }
.param-label { display: block; font-size: 13px; font-weight: 500; color: #666; margin-bottom: 6px; }

.qty-input { display: flex; align-items: center; gap: 8px; }
.qty-btn {
  width: 36px; height: 36px; border: 1px solid #dcdfe6;
  border-radius: 8px; background: #fff; font-size: 18px; cursor: pointer;
  display: flex; align-items: center; justify-content: center;
}
.qty-field {
  width: 80px; height: 36px; text-align: center;
  border: 1px solid #dcdfe6; border-radius: 8px; font-size: 16px; font-weight: 600;
}
.qty-unit { color: #999; font-size: 13px; }

.date-input {
  width: 100%; height: 40px; border: 1px solid #dcdfe6; border-radius: 8px; padding: 0 12px; font-size: 14px;
}
.region-select { width: 100%; }

.summary-card { background: #fff; border-radius: 12px; padding: 16px; }
.summary-row { display: flex; justify-content: space-between; padding: 8px 0; font-size: 14px; color: #555; }
.summary-row.total { font-weight: 700; font-size: 16px; color: #1a1a1a; }
.total-amount { color: #e6a23c; font-size: 18px; }
.summary-divider { border-top: 1px solid #f0f0f0; margin: 8px 0; }

.step-footer {
  position: fixed; bottom: 0; left: 0; right: 0;
  display: flex; gap: 10px; padding: 12px 16px;
  padding-bottom: calc(12px + env(safe-area-inset-bottom, 0));
  background: #fff; border-top: 1px solid #e8e8e8;
  max-width: 430px; margin: 0 auto;
}
.step-footer button {
  flex: 1; height: 44px; border: none; border-radius: 10px;
  font-size: 15px; font-weight: 600; cursor: pointer;
}
.btn-prev   { background: #f5f5f5; color: #666; }
.btn-next   { background: #409eff; color: #fff; }
.btn-submit { background: #67c23a; color: #fff; }
button:disabled { opacity: 0.5; cursor: not-allowed; }

.spinning { animation: spin 0.8s linear infinite; }
@keyframes spin { from { transform: rotate(0deg); } to { transform: rotate(360deg); } }
</style>
