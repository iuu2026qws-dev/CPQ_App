<template>
  <div class="currency-config">
    <div class="page-header">
      <h2>汇率配置</h2>
      <p class="subtitle">管理多币种汇率，支持多币种报价</p>
    </div>
    <el-card shadow="never">
      <template #header><div class="card-header"><span>汇率列表</span><el-button type="primary" size="small" @click="onAdd">新增汇率</el-button></div></template>
      <el-table :data="list" stripe v-loading="loading">
        <el-table-column prop="fromCurrency" label="源币种" width="110">
          <template #default="{ row }"><el-tag size="small" type="warning">{{ row.fromCurrency }}</el-tag></template>
        </el-table-column>
        <el-table-column prop="toCurrency" label="目标币种" width="110">
          <template #default="{ row }"><el-tag size="small" type="success">{{ row.toCurrency }}</el-tag></template>
        </el-table-column>
        <el-table-column prop="exchangeRate" label="汇率" width="150">
          <template #default="{ row }">1 {{ row.fromCurrency }} = {{ row.exchangeRate }} {{ row.toCurrency }}</template>
        </el-table-column>
        <el-table-column prop="effectiveDate" label="生效日期" width="130" />
        <el-table-column prop="status" label="状态" width="80"><template #default="{ row }"><el-tag :type="row.status==='0'?'success':'info'" size="small">{{ row.status==='0'?'启用':'停用' }}</el-tag></template></el-table-column>
        <el-table-column label="操作" width="140" fixed="right"><template #default="{ row }"><el-button link size="small" @click="onEdit(row)">编辑</el-button><el-button link size="small" type="danger" @click="onDelete(row)">删除</el-button></template></el-table-column>
      </el-table>
    </el-card>

    <el-dialog v-model="dialog.visible" :title="dialog.isEdit ? '编辑汇率' : '新增汇率'" width="420px">
      <el-form :model="form" label-width="100px">
        <el-form-item label="源币种"><el-input v-model="form.fromCurrency" placeholder="CNY" /></el-form-item>
        <el-form-item label="目标币种"><el-input v-model="form.toCurrency" placeholder="USD" /></el-form-item>
        <el-form-item label="汇率"><el-input-number v-model="form.exchangeRate" :min="0" :precision="6" style="width:100%" placeholder="1.000000" /></el-form-item>
        <el-form-item label="生效日期"><el-date-picker v-model="form.effectiveDate" type="date" value-format="YYYY-MM-DD" style="width:100%" /></el-form-item>
        <el-form-item label="状态"><el-select v-model="form.status" style="width:100%"><el-option label="启用" value="0" /><el-option label="停用" value="1" /></el-select></el-form-item>
      </el-form>
      <template #footer><el-button @click="dialog.visible=false">取消</el-button><el-button type="primary" @click="submit">确定</el-button></template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { getCurrencyRateList, addCurrencyRate, updateCurrencyRate, deleteCurrencyRate, type CpqCurrencyRate } from '@/api/pricing'

const today = () => new Date().toISOString().split('T')[0]

const list = ref<CpqCurrencyRate[]>([])
const loading = ref(false)
const dialog = reactive({ visible: false, isEdit: false })
const form = reactive<CpqCurrencyRate>({ fromCurrency: '', toCurrency: '', exchangeRate: 0, effectiveDate: today(), status: '0' })

const load = async () => { loading.value = true; try { const data = await getCurrencyRateList(); list.value = (Array.isArray(data) ? data : []) } finally { loading.value = false } }
const onAdd = () => { Object.assign(form, { fromCurrency: '', toCurrency: '', exchangeRate: 0, effectiveDate: today(), status: '0' }); dialog.isEdit = false; dialog.visible = true }
const onEdit = (row: CpqCurrencyRate) => { Object.assign(form, row); dialog.isEdit = true; dialog.visible = true }
const submit = async () => { try { await (dialog.isEdit ? updateCurrencyRate(form) : addCurrencyRate(form)); dialog.visible = false; ElMessage.success(dialog.isEdit ? '修改成功' : '新增成功'); load() } catch (e: any) { ElMessage.error(e?.message || '操作失败') } }
const onDelete = async (row: CpqCurrencyRate) => { try { await ElMessageBox.confirm('确定删除该汇率？'); await deleteCurrencyRate(row.rateId!); ElMessage.success('删除成功'); load() } catch { /* cancelled */ } }

onMounted(load)
</script>

<style scoped lang="scss">
.page-header { margin-bottom: 20px; h2 { font-size: 20px; } .subtitle { color: var(--cpq-text-secondary); font-size: 13px; } }
.card-header { display: flex; justify-content: space-between; align-items: center; }
</style>
