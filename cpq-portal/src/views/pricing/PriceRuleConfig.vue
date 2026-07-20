<template>
  <div class="price-rule-config">
    <div class="page-header">
      <h2>定价规则</h2>
      <p class="subtitle">配置折扣/加价/促销/合同定价规则，支持JSON条件和动作</p>
    </div>
    <el-card shadow="never">
      <template #header><div class="card-header"><span>规则列表</span><el-button type="primary" size="small" @click="onAdd">新增规则</el-button></div></template>
      <el-table :data="rules" stripe v-loading="loading">
        <el-table-column prop="ruleName" label="规则名称" width="180" />
        <el-table-column prop="ruleType" label="类型" width="100"><template #default="{ row }"><el-tag size="small">{{ ruleTypeLabel(row.ruleType) }}</el-tag></template></el-table-column>
        <el-table-column prop="priority" label="优先级" width="80" />
        <el-table-column prop="conditionJson" label="条件" min-width="200"><template #default="{ row }"><el-tooltip :content="row.conditionJson || '-'" placement="top"><span class="json-preview">{{ (row.conditionJson || '').substring(0, 40) || '-' }}</span></el-tooltip></template></el-table-column>
        <el-table-column prop="actionJson" label="动作" min-width="200"><template #default="{ row }"><el-tooltip :content="row.actionJson || '-'" placement="top"><span class="json-preview">{{ (row.actionJson || '').substring(0, 40) || '-' }}</span></el-tooltip></template></el-table-column>
        <el-table-column prop="approvalThreshold" label="审批阈值" width="120" />
        <el-table-column prop="status" label="状态" width="80"><template #default="{ row }"><el-tag :type="row.status==='0'?'success':'info'" size="small">{{ row.status==='0'?'启用':'停用' }}</el-tag></template></el-table-column>
        <el-table-column label="操作" width="140" fixed="right"><template #default="{ row }"><el-button link size="small" @click="onEdit(row)">编辑</el-button><el-button link size="small" type="danger" @click="onDelete(row)">删除</el-button></template></el-table-column>
      </el-table>
    </el-card>

    <el-dialog v-model="dialog.visible" :title="dialog.isEdit ? '编辑规则' : '新增规则'" width="560px">
      <el-form :model="form" label-width="100px">
        <el-form-item label="规则名称"><el-input v-model="form.ruleName" /></el-form-item>
        <el-form-item label="类型"><el-select v-model="form.ruleType" style="width:100%"><el-option v-for="t in ruleTypes" :key="t" :label="t" :value="t" /></el-select></el-form-item>
        <el-form-item label="优先级"><el-input-number v-model="form.priority" :min="0" /></el-form-item>
        <el-form-item label="条件JSON"><el-input v-model="form.conditionJson" type="textarea" :rows="3" placeholder='{"product_ids":[],"regions":[]}' /></el-form-item>
        <el-form-item label="动作JSON"><el-input v-model="form.actionJson" type="textarea" :rows="3" placeholder='{"adjustment_type":"discount","adjustment_value":10}' /></el-form-item>
        <el-form-item label="审批阈值"><el-input-number v-model="form.approvalThreshold" :min="0" :precision="2" style="width:100%" /></el-form-item>
        <el-form-item label="生效日期"><el-date-picker v-model="form.effectiveDate" type="date" value-format="YYYY-MM-DD" style="width:100%" /></el-form-item>
        <el-form-item label="失效日期"><el-date-picker v-model="form.expiryDate" type="date" value-format="YYYY-MM-DD" style="width:100%" /></el-form-item>
        <el-form-item label="状态"><el-select v-model="form.status" style="width:100%"><el-option label="启用" value="0" /><el-option label="停用" value="1" /></el-select></el-form-item>
        <el-form-item label="备注"><el-input v-model="form.remark" type="textarea" /></el-form-item>
      </el-form>
      <template #footer><el-button @click="dialog.visible=false">取消</el-button><el-button type="primary" @click="submit">确定</el-button></template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { getPriceRuleList, addPriceRule, updatePriceRule, deletePriceRule, type CpqPriceRule } from '@/api/pricing'

const today = () => new Date().toISOString().split('T')[0]

const ruleTypes = ['DISCOUNT', 'MARKUP', 'PROMOTION', 'CONTRACT']
const rules = ref<CpqPriceRule[]>([])
const loading = ref(false)
const ruleTypeLabel = (t: string) => ({ DISCOUNT: '折扣', MARKUP: '加价', PROMOTION: '促销', CONTRACT: '合同' }[t] || t)

const dialog = reactive({ visible: false, isEdit: false })
const form = reactive<CpqPriceRule>({ ruleName: '', ruleType: 'DISCOUNT', priority: 0, actionJson: '', conditionJson: '', approvalThreshold: undefined, effectiveDate: today(), expiryDate: '', status: '0', remark: '' })

const load = async () => { loading.value = true; try { const data = await getPriceRuleList(); rules.value = Array.isArray(data) ? data : (data?.rows || []) } finally { loading.value = false } }
const onAdd = () => { Object.assign(form, { ruleName: '', ruleType: 'DISCOUNT', priority: 0, actionJson: '', conditionJson: '', approvalThreshold: undefined, effectiveDate: today(), expiryDate: '', status: '0', remark: '' }); dialog.isEdit = false; dialog.visible = true }
const onEdit = (row: CpqPriceRule) => { Object.assign(form, row); dialog.isEdit = true; dialog.visible = true }
const submit = async () => {
  // 清理空字符串：MySQL JSON 列不接受空字符串，Date 列不接受空字符串
  if (!form.conditionJson) form.conditionJson = undefined as any
  if (!form.actionJson) form.actionJson = '{}'
  if (!form.expiryDate) form.expiryDate = undefined as any
  try { await (dialog.isEdit ? updatePriceRule(form) : addPriceRule(form)); dialog.visible = false; ElMessage.success(dialog.isEdit ? '修改成功' : '新增成功'); load() } catch (e: any) { ElMessage.error(e?.message || '操作失败') } }
const onDelete = async (row: CpqPriceRule) => { try { await ElMessageBox.confirm('确定删除该规则？'); await deletePriceRule(row.priceRuleId!); ElMessage.success('删除成功'); load() } catch { /* cancelled */ } }

onMounted(load)
</script>

<style scoped lang="scss">
.page-header { margin-bottom: 20px; h2 { font-size: 20px; } .subtitle { color: var(--cpq-text-secondary); font-size: 13px; } }
.card-header { display: flex; justify-content: space-between; align-items: center; }
.json-preview { font-family: monospace; font-size: 12px; color: var(--cpq-text-secondary); }
</style>
