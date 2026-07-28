<template>
  <div class="app-container">
    <!-- 搜索栏 -->
    <el-card shadow="hover" class="mb-[10px]">
      <el-form :model="queryParams" :inline="true">
        <el-form-item label="规则名称" prop="ruleName">
          <el-input
            v-model="queryParams.ruleName"
            placeholder="请输入规则名称关键字"
            clearable
            @keyup.enter="handleQuery"
          />
        </el-form-item>
        <el-form-item>
          <el-button type="primary" icon="Search" @click="handleQuery">搜索</el-button>
          <el-button icon="Refresh" @click="resetQuery">重置</el-button>
        </el-form-item>
      </el-form>
    </el-card>

    <!-- 表格 -->
    <el-card shadow="hover">
      <template #header>
        <el-row :gutter="10">
          <el-col :span="1.5">
            <el-button type="primary" plain icon="Plus" @click="handleAdd">新增</el-button>
          </el-col>
        </el-row>
      </template>

      <el-table v-loading="loading" border :data="list">
        <el-table-column label="规则名称" prop="ruleName" min-width="160" show-overflow-tooltip />
        <el-table-column label="触发场景" prop="scene" width="120" align="center">
          <template #default="scope">
            <el-tag>{{ SCENE_LABELS[scope.row.triggerScene] || scope.row.triggerScene }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column label="触发条件类型" prop="triggerType" width="140" align="center">
          <template #default="scope">
            <el-tag type="warning">{{ TRIGGER_LABELS[scope.row.triggerType] || scope.row.triggerType }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column label="对应流程" prop="flowName" min-width="150" show-overflow-tooltip />
        <el-table-column label="优先级" prop="priority" width="80" align="center" />
        <el-table-column label="SLA(h)" prop="slaHours" width="80" align="center" />
        <el-table-column label="状态" width="80" align="center">
          <template #default="scope">
            <el-switch
              v-model="scope.row.status"
              active-value="0"
              inactive-value="1"
              @change="handleStatusChange(scope.row)"
            />
          </template>
        </el-table-column>
        <el-table-column label="操作" fixed="right" width="180" align="center">
          <template #default="scope">
            <el-dropdown @command="(cmd: string) => handleCommand(cmd, scope.row)">
              <el-button type="primary" link>
                更多<el-icon class="el-icon--right"><ArrowDown /></el-icon>
              </el-button>
              <template #dropdown>
                <el-dropdown-menu>
                  <el-dropdown-item command="edit" icon="Edit">编辑</el-dropdown-item>
                  <el-dropdown-item command="copy" icon="CopyDocument">复制</el-dropdown-item>
                  <el-dropdown-item
                    :command="scope.row.status === '0' ? 'disable' : 'enable'"
                    :icon="scope.row.status === '0' ? 'Remove' : 'CircleCheck'"
                  >
                    {{ scope.row.status === '0' ? '停用' : '启用' }}
                  </el-dropdown-item>
                  <el-dropdown-item command="delete" icon="Delete" divided style="color: #f56c6c">删除</el-dropdown-item>
                </el-dropdown-menu>
              </template>
            </el-dropdown>
          </template>
        </el-table-column>
      </el-table>

      <pagination
        v-show="total > 0"
        v-model:page="queryParams.pageNum"
        v-model:limit="queryParams.pageSize"
        :total="total"
        @pagination="getList"
      />
    </el-card>

    <!-- 编辑抽屉 -->
    <el-drawer
      v-model="drawer.visible"
      :title="drawer.title"
      size="80%"
      :before-close="handleDrawerClose"
    >
      <el-form ref="formRef" :model="form" :rules="rules" label-width="120px" style="padding: 0 20px">
        <!-- 基本信息分区 -->
        <el-divider content-position="left">基本信息</el-divider>
        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="规则名称" prop="ruleName">
              <el-input v-model="form.ruleName" placeholder="请输入规则名称" maxlength="100" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="触发场景" prop="triggerScene">
              <el-select v-model="form.triggerScene" placeholder="请选择触发场景" style="width: 100%">
                <el-option
                  v-for="(label, value) in SCENE_LABELS"
                  :key="value"
                  :label="label"
                  :value="value"
                />
              </el-select>
            </el-form-item>
          </el-col>
        </el-row>

        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="触发条件类型" prop="triggerType">
              <el-select v-model="form.triggerType" placeholder="请选择触发条件类型" style="width: 100%" @change="handleTriggerTypeChange">
                <el-option
                  v-for="(label, value) in TRIGGER_LABELS"
                  :key="value"
                  :label="label"
                  :value="value"
                />
              </el-select>
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="阈值" prop="triggerValue">
              <el-input-number
                v-model="form.triggerValue"
                :min="0"
                :precision="2"
                controls-position="right"
                placeholder="请输入阈值"
                style="width: 100%"
              />
            </el-form-item>
          </el-col>
        </el-row>

        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="对应流程" prop="flowCode">
              <el-select v-model="form.flowCode" placeholder="请选择审批流程" style="width: 100%">
                <el-option
                  v-for="item in flowOptions"
                  :key="item.flow_code"
                  :label="`${item.flow_name} (v${item.version})`"
                  :value="item.flow_code"
                />
              </el-select>
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="优先级" prop="priority">
              <el-select v-model="form.priority" placeholder="请选择优先级" style="width: 100%">
                <el-option label="P1 - 最高" :value="1" />
                <el-option label="P2 - 高" :value="2" />
                <el-option label="P3 - 中" :value="3" />
                <el-option label="P4 - 低" :value="4" />
                <el-option label="P5 - 最低" :value="5" />
              </el-select>
            </el-form-item>
          </el-col>
        </el-row>

        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="SLA(小时)" prop="slaHours">
              <el-input-number
                v-model="form.slaHours"
                :min="1"
                :max="720"
                controls-position="right"
                style="width: 100%"
              />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="启用状态" prop="status">
              <el-switch
                v-model="form.status"
                active-value="0"
                inactive-value="1"
                active-text="启用"
                inactive-text="停用"
              />
            </el-form-item>
          </el-col>
        </el-row>

        <!-- 审批链编排 -->
        <el-divider v-if="showApprovalChain" content-position="left">
          审批链编排
          <span style="font-size: 12px; color: #909399; margin-left: 8px">
            （当触发条件为"工艺确认"时使用 Warm-Flow 流程，无需手动编排）
          </span>
        </el-divider>
        <div v-if="showApprovalChain" style="padding-left: 50px; padding-right: 50px">
          <ApprovalChainBuilder v-model="form.approvalChain" />
        </div>

        <!-- 提示信息 -->
        <div v-if="!showApprovalChain" style="padding: 20px; text-align: center; color: #909399">
          当前触发条件类型为"工艺确认"，审批链由 Warm-Flow 流程引擎管理，无需手动编排。
        </div>
      </el-form>

      <template #footer>
        <div style="text-align: right; padding-right: 20px">
          <el-button @click="handleDrawerClose">取消</el-button>
          <el-button type="primary" :loading="submitLoading" @click="submitForm">保存</el-button>
        </div>
      </template>
    </el-drawer>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted, computed, nextTick } from 'vue'
import {
  listApprovalRule,
  getApprovalRule,
  addApprovalRule,
  updateApprovalRule,
  delApprovalRule,
  getAvailableFlows
} from '@/api/cpq/approval'
import { ElMessage, ElMessageBox } from 'element-plus'
import ApprovalChainBuilder from '@/components/approval/ApprovalChainBuilder.vue'

// --------------- 常量映射 ---------------
const SCENE_LABELS: Record<string, string> = {
  QUOTE: '报价审批',
  PROCESS: '工艺确认',
  ECN: '工程变更',
  PRICING: '定价变更',
  CONFIG: '配置审批',
  CRM: 'CRM审批',
  CUSTOMER: '客户审批'
}

const TRIGGER_LABELS: Record<string, string> = {
  DISCOUNT_EXCEED: '折扣超限',
  AMOUNT_ABOVE: '金额超限',
  MARGIN_BELOW: '利润率过低',
  NEW_CONFIG: '新配置方案',
  CUSTOM_PART: '含定制件',
  FIRST_ORDER: '新客户首单',
  EXPORT_CONTROL: '出口管制',
  PROCESS_CONFIRM: '工艺确认'
}

// --------------- 查询参数 ---------------
const queryParams = reactive({
  pageNum: 1,
  pageSize: 10,
  ruleName: ''
})

const loading = ref(false)
const total = ref(0)
const list = ref<any[]>([])

// --------------- 抽屉 ---------------
const drawer = reactive({
  visible: false,
  title: ''
})

const isEdit = ref(false)
const currentRuleId = ref<number | null>(null)

const defaultForm = {
  ruleName: '',
  triggerScene: '',
  triggerType: '',
  triggerValue: null as number | null,
  flowCode: '',
  priority: 3,
  slaHours: 48,
  status: '0',
  approvalChain: [] as any[]
}

const form = reactive<any>({ ...defaultForm })
const submitLoading = ref(false)
const formRef = ref()

const rules = {
  ruleName: [{ required: true, message: '请填写规则名称', trigger: 'blur' }],
  triggerScene: [{ required: true, message: '请选择触发场景', trigger: 'change' }],
  triggerType: [{ required: true, message: '请选择触发条件类型', trigger: 'change' }]
}

// --------------- 流程选项 ---------------
const flowOptions = ref<{ flow_code: string; flow_name: string; version: number }[]>([])

// 是否显示审批链编排区
const showApprovalChain = computed(() => {
  return form.triggerType && form.triggerType !== 'PROCESS_CONFIRM'
})

// --------------- 查询列表 ---------------
const getList = async () => {
  loading.value = true
  try {
    const res = await listApprovalRule(queryParams)
    list.value = (res as any).rows || []
    total.value = (res as any).total || 0
  } finally {
    loading.value = false
  }
}

const handleQuery = () => {
  queryParams.pageNum = 1
  getList()
}

const resetQuery = () => {
  queryParams.ruleName = ''
  queryParams.pageNum = 1
  getList()
}

// --------------- 加载可用流程 ---------------
const loadFlows = async () => {
  try {
    const res = await getAvailableFlows()
    flowOptions.value = (res as any).data || (res as any) || []
  } catch {
    // ignore
  }
}

// --------------- 触发类型变更 ---------------
const handleTriggerTypeChange = () => {
  // 当切换到 PROCESS_CONFIRM 时自动清空审批链
  if (form.triggerType === 'PROCESS_CONFIRM') {
    form.approvalChain = []
  }
}

// --------------- 新增 ---------------
const handleAdd = () => {
  isEdit.value = false
  currentRuleId.value = null
  Object.assign(form, { ...defaultForm })
  drawer.title = '新增审批规则'
  drawer.visible = true
  nextTick(() => {
    formRef.value?.clearValidate()
  })
}

// --------------- 编辑 ---------------
const handleEdit = async (row: any) => {
  isEdit.value = true
  currentRuleId.value = row.ruleId
  drawer.title = '编辑审批规则'
  drawer.visible = true

  try {
    const res = await getApprovalRule(row.ruleId)
    const data = (res as any).data || res
    Object.assign(form, {
      ruleName: data.ruleName || '',
      scene: data.triggerScene || '',
      triggerType: data.triggerType || '',
      thresholdValue: data.triggerValue ?? 0,
      flowCode: data.flowCode || '',
      priority: data.priority || 3,
      slaHours: data.slaHours ?? 48,
      status: data.status ?? '0',
      approvalChain: data.approvalChainJson || []
    })
  } catch {
    ElMessage.error('获取规则详情失败')
  }
  nextTick(() => {
    formRef.value?.clearValidate()
  })
}

// --------------- 复制 ---------------
const handleCopy = async (row: any) => {
  try {
    const res = await getApprovalRule(row.ruleId)
    const data = (res as any).data || res
    Object.assign(form, {
      ruleName: (data.ruleName || '') + ' - 副本',
      scene: data.triggerScene || '',
      triggerType: data.triggerType || '',
      thresholdValue: data.triggerValue ?? 0,
      flowCode: data.flowCode || '',
      priority: data.priority || 3,
      slaHours: data.slaHours ?? 48,
      status: '0',
      approvalChain: data.approvalChainJson || []
    })
    isEdit.value = false
    currentRuleId.value = null
    drawer.title = '新增审批规则（复制）'
    drawer.visible = true
    nextTick(() => {
      formRef.value?.clearValidate()
    })
  } catch {
    ElMessage.error('复制失败')
  }
}

// --------------- 删除 ---------------
const handleDelete = async (row: any) => {
  try {
    await ElMessageBox.confirm(`确认删除规则"${row.ruleName}"吗？`, '提示', {
      type: 'warning'
    })
    await delApprovalRule(row.ruleId)
    ElMessage.success('删除成功')
    getList()
  } catch {
    // 用户取消
  }
}

// --------------- 启用/停用 ---------------
const handleStatusChange = async (row: any) => {
  const text = row.status === '0' ? '启用' : '停用'
  try {
    await ElMessageBox.confirm(`确认${text}规则"${row.ruleName}"吗？`, '提示')
    // 状态直接通过 el-switch 修改，后端更新
    // 如果后台有单独的更新接口，在这里调用
    await updateApprovalRule({ ruleId: row.ruleId, status: row.status })
    ElMessage.success(`${text}成功`)
  } catch {
    row.status = row.status === '0' ? '1' : '0'
  }
}

// --------------- 操作分发 ---------------
const handleCommand = (command: string, row: any) => {
  switch (command) {
    case 'edit':
      handleEdit(row)
      break
    case 'copy':
      handleCopy(row)
      break
    case 'enable':
      row.status = '0'
      handleStatusChange(row)
      break
    case 'disable':
      row.status = '1'
      handleStatusChange(row)
      break
    case 'delete':
      handleDelete(row)
      break
  }
}

// --------------- 提交保存 ---------------
const submitForm = () => {
  formRef.value?.validate(async (valid: boolean) => {
    if (!valid) return

    submitLoading.value = true
    try {
      const payload = { ...form }
      if (isEdit.value && currentRuleId.value) {
        payload.ruleId = currentRuleId.value
        await updateApprovalRule(payload)
        ElMessage.success('更新成功')
      } else {
        await addApprovalRule(payload)
        ElMessage.success('新增成功')
      }
      drawer.visible = false
      getList()
    } finally {
      submitLoading.value = false
    }
  })
}

// --------------- 关闭抽屉 ---------------
const handleDrawerClose = () => {
  drawer.visible = false
  formRef.value?.resetFields()
  formRef.value?.clearValidate()
}

// --------------- 初始化 ---------------
onMounted(() => {
  getList()
  loadFlows()
})
</script>
