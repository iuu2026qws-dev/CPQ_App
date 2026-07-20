<template>
  <div class="volume-tier-config">
    <div class="page-header">
      <h2>阶梯定价</h2>
      <p class="subtitle">配置按数量阶梯的递减/递增定价，支持多阶梯档位</p>
    </div>
    <el-card shadow="never">
      <template #header>
        <div class="card-header">
          <span>阶梯定价列表</span>
          <el-button type="primary" size="small" @click="onAdd">新增阶梯</el-button>
        </div>
      </template>
      <el-table :data="tiers" stripe v-loading="loading">
        <el-table-column prop="priceBookEntryId" label="价格条目ID" width="120" />
        <el-table-column prop="minQuantity" label="最小数量" width="120" />
        <el-table-column prop="maxQuantity" label="最大数量" width="120"><template #default="{ row }">{{ row.maxQuantity ?? '∞' }}</template></el-table-column>
        <el-table-column prop="unitPrice" label="阶梯单价" width="120" />
        <el-table-column prop="sortOrder" label="排序" width="70" />
        <el-table-column label="操作" width="140" fixed="right"><template #default="{ row }"><el-button link size="small" @click="onEdit(row)">编辑</el-button><el-button link size="small" type="danger" @click="onDelete(row)">删除</el-button></template></el-table-column>
      </el-table>
    </el-card>

    <!-- 阶梯可视化：级联台阶 + 均价曲线 -->
    <el-card v-if="sortedTiers.length" shadow="never" style="margin-top:16px">
      <template #header>
        <div style="display:flex;justify-content:space-between;align-items:center">
          <strong>价格阶梯可视化</strong>
          <span style="font-size:12px;color:var(--cpq-text-secondary)">数量 → 单价趋势，买越多越便宜</span>
        </div>
      </template>

      <!-- 阶梯卡片流 -->
      <div class="tier-card-flow">
        <template v-for="(t, idx) in sortedTiers" :key="t.tierId || idx">
          <div class="tier-card" :class="{ 'tier-best': idx === bestTierIdx }">
            <div class="tier-card-quantity">
              <span class="tier-qty-number">{{ fmtQty(t.minQuantity) }}</span>
              <span class="tier-qty-sep">→</span>
              <span class="tier-qty-number">{{ t.maxQuantity ? fmtQty(t.maxQuantity) : '∞' }}</span>
              <span class="tier-qty-unit">个</span>
            </div>
            <div class="tier-card-price">
              <span class="tier-price-symbol">¥</span>
              <span class="tier-price-value">{{ t.unitPrice }}</span>
              <span class="tier-price-per">/个</span>
            </div>
            <div v-if="idx > 0 && sortedTiers[idx-1].unitPrice" class="tier-card-save">
              ↓{{ calcSavePct(sortedTiers[idx-1].unitPrice!, t.unitPrice!) }}%
            </div>
            <div v-if="idx === 0" class="tier-card-save tier-base">基准</div>
          </div>
          <div v-if="idx < sortedTiers.length - 1" class="tier-arrow">▶</div>
        </template>
      </div>

      <!-- 均价对比柱状图 -->
      <div v-if="sortedTiers.length >= 2" class="tier-chart" style="margin-top:20px">
        <div class="tier-chart-title">阶梯均价对比</div>
        <div class="tier-chart-bars">
          <div v-for="(t, idx) in sortedTiers" :key="'bar-'+ (t.tierId || idx)" class="tier-chart-col">
            <div class="tier-chart-bar-fill" :style="{ height: chartHeight(t) }">
              <span class="tier-chart-bar-label">¥{{ t.unitPrice }}</span>
            </div>
            <div class="tier-chart-bar-name">{{ fmtQty(t.minQuantity) }}{{ t.maxQuantity ? '-'+fmtQty(t.maxQuantity) : '+' }}</div>
          </div>
        </div>
      </div>
    </el-card>

    <el-dialog v-model="dialog.visible" :title="dialog.isEdit ? '编辑阶梯' : '新增阶梯'" width="460px">
      <el-form :model="form" label-width="110px">
        <el-form-item label="价格条目ID"><el-input-number v-model="form.priceBookEntryId" :min="1" style="width:100%" /></el-form-item>
        <el-form-item label="最小数量"><el-input-number v-model="form.minQuantity" :min="0" :precision="4" style="width:100%" /></el-form-item>
        <el-form-item label="最大数量"><el-input-number v-model="form.maxQuantity" :min="0" :precision="4" style="width:100%" placeholder="留空=无限" /></el-form-item>
        <el-form-item label="阶梯单价"><el-input-number v-model="form.unitPrice" :min="0" :precision="2" style="width:100%" /></el-form-item>
        <el-form-item label="排序号"><el-input-number v-model="form.sortOrder" :min="0" /></el-form-item>
      </el-form>
      <template #footer><el-button @click="dialog.visible=false">取消</el-button><el-button type="primary" @click="submit">确定</el-button></template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, computed, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { getVolumeTierList, addVolumeTier, updateVolumeTier, deleteVolumeTier, type CpqVolumeTier } from '@/api/pricing'

const tiers = ref<CpqVolumeTier[]>([])
const loading = ref(false)
const sortedTiers = computed(() => [...tiers.value].sort((a, b) => (a.sortOrder || 0) - (b.sortOrder || 0)))

// 最低单价（最优）阶梯索引
const bestTierIdx = computed(() => {
  let best = 0
  sortedTiers.value.forEach((t, i) => { if ((t.unitPrice || 0) > 0 && (t.unitPrice || 0) < (sortedTiers.value[best]?.unitPrice || Infinity)) best = i })
  return best
})

// 数量格式化（去掉多余小数）
const fmtQty = (v: any) => {
  const n = Number(v)
  if (Number.isNaN(n)) return v
  return n % 1 === 0 ? n.toString() : n.toFixed(2)
}

// 降价百分比
const calcSavePct = (prev: number, curr: number) => {
  if (!prev || prev <= 0) return 0
  return Math.round((1 - curr / prev) * 100)
}

// 均价柱状图高度（按比例）
const chartHeight = (t: CpqVolumeTier) => {
  const maxPrice = Math.max(...sortedTiers.value.map(x => x.unitPrice || 0), 1)
  const minPrice = Math.min(...sortedTiers.value.map(x => x.unitPrice || 0), maxPrice)
  const range = maxPrice - minPrice || 1
  return `${40 + ((maxPrice - (t.unitPrice || 0)) / range) * 60}%`
}

const dialog = reactive({ visible: false, isEdit: false })
const form = reactive<CpqVolumeTier>({ priceBookEntryId: 0, minQuantity: 0, maxQuantity: undefined, unitPrice: 0, sortOrder: 0 })

const load = async () => { loading.value = true; try { const data = await getVolumeTierList(); tiers.value = Array.isArray(data) ? data : (data?.rows || []) } finally { loading.value = false } }
const onAdd = () => { Object.assign(form, { priceBookEntryId: 0, minQuantity: 0, maxQuantity: undefined, unitPrice: 0, sortOrder: 0 }); dialog.isEdit = false; dialog.visible = true }
const onEdit = (row: CpqVolumeTier) => { Object.assign(form, row); dialog.isEdit = true; dialog.visible = true }
const submit = async () => { try { await (dialog.isEdit ? updateVolumeTier(form) : addVolumeTier(form)); dialog.visible = false; ElMessage.success(dialog.isEdit ? '修改成功' : '新增成功'); load() } catch (e: any) { ElMessage.error(e?.message || '操作失败') } }
const onDelete = async (row: CpqVolumeTier) => { try { await ElMessageBox.confirm('确定删除该阶梯？'); await deleteVolumeTier(row.tierId!); ElMessage.success('删除成功'); load() } catch { /* cancelled */ } }

onMounted(load)
</script>

<style scoped lang="scss">
.page-header { margin-bottom: 20px; h2 { font-size: 20px; } .subtitle { color: var(--cpq-text-secondary); font-size: 13px; } }
.card-header { display: flex; justify-content: space-between; align-items: center; }

// --- 阶梯卡片流 ---
.tier-card-flow {
  display: flex; align-items: stretch; gap: 0; flex-wrap: wrap;
}
.tier-card {
  flex: 1; min-width: 140px;
  background: #f5f7fa; border-radius: 8px;
  padding: 16px 14px;
  text-align: center;
  display: flex; flex-direction: column; gap: 8px;
  transition: all 0.2s;
  &.tier-best {
    background: #ecfdf5; border: 2px solid #10b981; box-shadow: 0 2px 8px rgba(16,185,129,0.12);
    .tier-card-price { color: #059669; }
  }
}
.tier-arrow {
  display: flex; align-items: center; padding: 0 6px;
  font-size: 14px; color: #9ca3af; flex-shrink: 0;
}
.tier-card-quantity {
  display: flex; align-items: center; justify-content: center; gap: 6px;
  flex-wrap: wrap;
}
.tier-qty-number { font-size: 18px; font-weight: 700; color: #1f2937; }
.tier-qty-sep { color: #9ca3af; font-size: 13px; }
.tier-qty-unit { font-size: 12px; color: #9ca3af; }
.tier-card-price {
  display: flex; align-items: baseline; justify-content: center; gap: 2px;
  color: #3b82f6; font-weight: 700;
}
.tier-price-symbol { font-size: 14px; }
.tier-price-value { font-size: 24px; line-height: 1; }
.tier-price-per { font-size: 12px; color: #6b7280; font-weight: 400; }
.tier-card-save {
  font-size: 12px; padding: 2px 8px; border-radius: 10px;
  background: #fef2f2; color: #ef4444; display: inline-block; align-self: center;
  &.tier-base { background: #f3f4f6; color: #6b7280; }
}

// --- 均价对比柱状图 ---
.tier-chart-title {
  font-size: 13px; color: var(--cpq-text-secondary); margin-bottom: 12px;
}
.tier-chart-bars {
  display: flex; align-items: flex-end; gap: 24px; height: 160px; padding: 0 8px;
}
.tier-chart-col {
  flex: 1; display: flex; flex-direction: column; align-items: center; height: 100%; justify-content: flex-end;
}
.tier-chart-bar-fill {
  width: 100%; max-width: 80px;
  background: linear-gradient(180deg, #3b82f6 0%, #93c5fd 100%);
  border-radius: 6px 6px 0 0;
  display: flex; align-items: flex-start; justify-content: center;
  transition: height 0.4s;
  position: relative;
  min-height: 40%;
}
.tier-chart-bar-label {
  font-size: 12px; font-weight: 600; color: #fff;
  padding-top: 6px;
}
.tier-chart-bar-name {
  margin-top: 8px; font-size: 12px; color: #6b7280; text-align: center; white-space: nowrap;
}
</style>
