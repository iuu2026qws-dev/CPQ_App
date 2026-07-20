<template>
  <div class="page-container">
    <el-card class="search-card">
      <el-form :model="queryParams" inline>
        <el-form-item label="规则名称">
          <el-input v-model="queryParams.ruleName" placeholder="搜索规则名称" clearable @keyup.enter="load" style="width:200px" />
        </el-form-item>
        <el-form-item label="规则类型">
          <el-select v-model="queryParams.ruleType" placeholder="全部" clearable style="width:160px">
            <el-option label="校验(VALIDATION)" value="VALIDATION" />
            <el-option label="推荐(SELECTION)" value="SELECTION" />
            <el-option label="警告(ALERT)" value="ALERT" />
            <el-option label="隐藏(VISIBILITY)" value="VISIBILITY" />
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="load">查询</el-button>
          <el-button @click="resetQuery">重置</el-button>
        </el-form-item>
      </el-form>
    </el-card>

    <el-card class="table-card">
      <div class="mb-4">
        <el-button type="primary" @click="onAdd">新增规则</el-button>
      </div>
      <el-table v-loading="loading" :data="list" border stripe>
        <el-table-column prop="ruleId" label="ID" width="80" />
        <el-table-column prop="ruleName" label="规则名称" min-width="150" />
        <el-table-column prop="ruleType" label="类型" width="120">
          <template #default="{ row }">
            <el-tag :type="typeTag(row.ruleType)">{{ typeLabel(row.ruleType) }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="severity" label="严重级别" width="100">
          <template #default="{ row }">
            <el-tag :type="row.severity === 'ERROR' ? 'danger' : row.severity === 'WARNING' ? 'warning' : 'info'">{{ row.severity }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="priority" label="优先级" width="80" />
        <el-table-column prop="effectiveDate" label="生效日期" width="120" />
        <el-table-column prop="status" label="状态" width="80">
          <template #default="{ row }">
            <el-tag :type="row.status === '0' ? 'success' : 'danger'">{{ row.status === '0' ? '正常' : '停用' }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="150" fixed="right">
          <template #default="{ row }">
            <el-button size="small" @click="onEdit(row)">编辑</el-button>
            <el-button size="small" type="danger" @click="onDelete(row)">删除</el-button>
          </template>
        </el-table-column>
      </el-table>
    </el-card>

    <el-dialog v-model="dialog.visible" :title="dialog.isEdit ? '编辑规则' : '新增规则'" width="700px" append-to-body destroy-on-close :close-on-click-modal="false">
      <el-form ref="formRef" :model="form" label-width="110px">
        <el-form-item label="规则名称" required>
          <el-input v-model="form.ruleName" placeholder="请输入规则名称" />
        </el-form-item>
        <el-row :gutter="16">
          <el-col :span="12">
            <el-form-item label="规则类型" required>
              <el-select v-model="form.ruleType" style="width:100%">
                <el-option label="校验(VALIDATION)" value="VALIDATION" />
                <el-option label="推荐(SELECTION)" value="SELECTION" />
                <el-option label="警告(ALERT)" value="ALERT" />
                <el-option label="隐藏(VISIBILITY)" value="VISIBILITY" />
              </el-select>
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="严重级别">
              <el-select v-model="form.severity" style="width:100%">
                <el-option label="ERROR" value="ERROR" />
                <el-option label="WARNING" value="WARNING" />
                <el-option label="INFO" value="INFO" />
              </el-select>
            </el-form-item>
          </el-col>
        </el-row>
        <el-row :gutter="16">
          <el-col :span="12">
            <el-form-item label="优先级">
              <el-input-number v-model="form.priority" :min="0" style="width:100%" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="适用产品">
              <ModelLookup v-model="form.modelId" placeholder="搜索产品，空=全局规则" />
            </el-form-item>
          </el-col>
        </el-row>
        <el-form-item label="条件表达式(JSON)" required>
          <el-input v-model="form.conditionExpr" type="textarea" :rows="3" placeholder='{"attr_name": "颜色", "value": "珍珠白"}' />
        </el-form-item>
        <el-form-item label="动作表达式(JSON)" required>
          <el-input v-model="form.actionExpr" type="textarea" :rows="3" placeholder='{"action": "HIDE", "target_attrs": ["基站版本"]}' />
        </el-form-item>
        <el-form-item label="错误提示">
          <el-input v-model="form.errorMessage" placeholder="违反规则时的提示信息" />
        </el-form-item>
        <el-row :gutter="16">
          <el-col :span="12">
            <el-form-item label="生效日期" required>
              <el-date-picker v-model="form.effectiveDate" type="date" value-format="YYYY-MM-DD" style="width:100%" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="失效日期">
              <el-date-picker v-model="form.expiryDate" type="date" value-format="YYYY-MM-DD" style="width:100%" />
            </el-form-item>
          </el-col>
        </el-row>
        <el-form-item label="状态">
          <el-radio-group v-model="form.status">
            <el-radio value="0">正常</el-radio>
            <el-radio value="1">停用</el-radio>
          </el-radio-group>
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="dialog.visible = false">取消</el-button>
        <el-button type="primary" @click="submit">确定</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { getConfigRuleList, getConfigRuleById, addConfigRule, updateConfigRule, deleteConfigRule, type CpqConfigRuleVo } from '@/api/config'
import ModelLookup from '@/components/cpq/ModelLookup.vue'

const loading = ref(false)
const list = ref<CpqConfigRuleVo[]>([])
const queryParams = reactive({ ruleName: '', ruleType: '' })
const dialog = reactive({ visible: false, isEdit: false })

const today = () => new Date().toISOString().split('T')[0]
const form = reactive({
  ruleId: undefined as number | undefined, ruleName: '', ruleType: 'VALIDATION',
  modelId: undefined as number | undefined, conditionExpr: '{}', actionExpr: '{}',
  errorMessage: '', severity: 'ERROR', priority: 0,
  effectiveDate: today(), expiryDate: '', status: '0'
})

const typeLabel = (t: string) => ({ VALIDATION: '校验', SELECTION: '推荐', ALERT: '警告', VISIBILITY: '隐藏' })[t] || t
const typeTag = (t: string) => ({ VALIDATION: 'danger', SELECTION: 'success', ALERT: 'warning', VISIBILITY: 'info' })[t] || ''

async function load() {
  loading.value = true
  try {
    const res = await getConfigRuleList(queryParams)
    list.value = Array.isArray(res) ? res : (res.rows || [])
  } catch (e: any) { ElMessage.error(e?.message || '加载失败') }
  finally { loading.value = false }
}

function resetQuery() {
  queryParams.ruleName = ''
  queryParams.ruleType = ''
  load()
}

function resetForm() {
  Object.assign(form, { ruleId: undefined, ruleName: '', ruleType: 'VALIDATION', modelId: undefined, conditionExpr: '{}', actionExpr: '{}', errorMessage: '', severity: 'ERROR', priority: 0, effectiveDate: today(), expiryDate: '', status: '0' })
}

function onAdd() { resetForm(); dialog.isEdit = false; dialog.visible = true }
async function onEdit(row: CpqConfigRuleVo) {
  const data = await getConfigRuleById(row.ruleId)
  Object.assign(form, data)
  dialog.isEdit = true; dialog.visible = true
}
async function onDelete(row: CpqConfigRuleVo) {
  try {
    await ElMessageBox.confirm(`确认删除规则「${row.ruleName}」？`, '警告', { type: 'warning' })
    await deleteConfigRule(row.ruleId)
    ElMessage.success('删除成功')
    load()
  } catch { /* cancelled */ }
}

async function submit() {
  try {
    if (form.ruleId) { await updateConfigRule(form as any); ElMessage.success('修改成功') }
    else { await addConfigRule(form as any); ElMessage.success('新增成功') }
    dialog.visible = false; load()
  } catch (e: any) { ElMessage.error(e?.message || '操作失败') }
}

onMounted(() => load())
</script>
