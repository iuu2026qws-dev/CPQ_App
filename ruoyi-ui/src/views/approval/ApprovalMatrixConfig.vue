<template>
  <div class="app-container">
    <!-- 搜索栏 -->
    <el-card shadow="hover" class="mb-[10px]">
      <el-form :model="queryParams" :inline="true">
        <el-form-item label="维度类型" prop="dimensionType">
          <el-select v-model="queryParams.dimensionType" placeholder="请选择" clearable>
            <el-option label="区域" value="REGION" />
            <el-option label="部门" value="DEPT" />
            <el-option label="金额区间" value="AMOUNT_RANGE" />
            <el-option label="产品线" value="PRODUCT_LINE" />
          </el-select>
        </el-form-item>
        <el-form-item label="维度值" prop="dimensionValue">
          <el-input
            v-model="queryParams.dimensionValue"
            placeholder="请输入维度值"
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
        <el-table-column label="维度类型" prop="dimensionType" width="120" align="center">
          <template #default="scope">
            <el-tag>{{ DIMENSION_LABELS[scope.row.dimensionType] || scope.row.dimensionType }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column label="维度值" prop="dimensionValue" min-width="140" show-overflow-tooltip />
        <el-table-column label="关联流程" prop="flowName" min-width="150" show-overflow-tooltip />
        <el-table-column label="审批角色" prop="approverRole" width="120" />
        <el-table-column label="审批人" prop="approverName" width="120" />
        <el-table-column label="最少通过人数" prop="minApprovals" width="110" align="center" />
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
        <el-table-column label="操作" fixed="right" width="140" align="center">
          <template #default="scope">
            <el-button link type="primary" icon="Edit" @click="handleEdit(scope.row)">编辑</el-button>
            <el-button link type="danger" icon="Delete" @click="handleDelete(scope.row)">删除</el-button>
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

    <!-- 新增/编辑对话框 -->
    <el-dialog v-model="dialog.visible" :title="dialog.title" width="600px" append-to-body @close="handleDialogClose">
      <el-form ref="formRef" :model="form" :rules="rules" label-width="110px">
        <el-form-item label="维度类型" prop="dimensionType">
          <el-select v-model="form.dimensionType" placeholder="请选择维度类型" style="width: 100%">
            <el-option label="区域 (REGION)" value="REGION" />
            <el-option label="部门 (DEPT)" value="DEPT" />
            <el-option label="金额区间 (AMOUNT_RANGE)" value="AMOUNT_RANGE" />
            <el-option label="产品线 (PRODUCT_LINE)" value="PRODUCT_LINE" />
          </el-select>
        </el-form-item>
        <el-form-item label="维度值" prop="dimensionValue">
          <el-input v-model="form.dimensionValue" placeholder="如：华东区/研发部/0-10000/产品线A" maxlength="100" />
        </el-form-item>
        <el-form-item label="关联流程" prop="flowCode">
          <el-select v-model="form.flowCode" placeholder="请选择审批流程" style="width: 100%">
            <el-option
              v-for="item in flowOptions"
              :key="item.flow_code"
              :label="`${item.flow_name} (v${item.version})`"
              :value="item.flow_code"
            />
          </el-select>
        </el-form-item>
        <el-form-item label="审批角色" prop="approverRole">
          <el-select
            v-model="form.approverRole"
            filterable
            remote
            reserve-keyword
            placeholder="输入角色名搜索"
            :remote-method="searchRolesRemote"
            :loading="roleSearchLoading"
            clearable
            style="width: 100%"
          >
            <el-option
              v-for="item in roleOptions"
              :key="item.roleId"
              :label="item.roleName"
              :value="item.roleName"
            />
          </el-select>
        </el-form-item>
        <el-form-item label="审批人" prop="approverIds">
          <UserSelect v-model="form.approverIds" />
        </el-form-item>
        <el-form-item label="最少通过人数" prop="minApprovals">
          <el-input-number v-model="form.minApprovals" :min="1" :max="20" controls-position="right" />
          <span style="margin-left: 8px; color: #909399; font-size: 12px">仅对并行审批生效</span>
        </el-form-item>
        <el-form-item label="启用状态" prop="status">
          <el-switch
            v-model="form.status"
            active-value="0"
            inactive-value="1"
            active-text="启用"
            inactive-text="停用"
          />
        </el-form-item>
        <el-form-item label="备注" prop="remark">
          <el-input v-model="form.remark" type="textarea" placeholder="可填写备注信息" :rows="3" />
        </el-form-item>
      </el-form>
      <template #footer>
        <div class="dialog-footer">
          <el-button type="primary" :loading="submitLoading" @click="submitForm">确 定</el-button>
          <el-button @click="handleDialogClose">取 消</el-button>
        </div>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted, nextTick } from 'vue'
import {
  listApprovalMatrix,
  getApprovalMatrix,
  addApprovalMatrix,
  updateApprovalMatrix,
  delApprovalMatrix,
  getAvailableFlows,
  searchRoles
} from '@/api/cpq/approval'
import { ElMessage, ElMessageBox } from 'element-plus'
import UserSelect from '@/components/approval/UserSelect.vue'

// --------------- 常量映射 ---------------
const DIMENSION_LABELS: Record<string, string> = {
  REGION: '区域',
  DEPT: '部门',
  AMOUNT_RANGE: '金额区间',
  PRODUCT_LINE: '产品线'
}

// --------------- 查询参数 ---------------
const queryParams = reactive({
  pageNum: 1,
  pageSize: 10,
  dimensionType: '',
  dimensionValue: ''
})

const loading = ref(false)
const total = ref(0)
const list = ref<any[]>([])

// --------------- 对话框 ---------------
const dialog = reactive({
  visible: false,
  title: ''
})

const isEdit = ref(false)
const currentMatrixId = ref<number | null>(null)

const defaultForm = {
  dimensionType: '',
  dimensionValue: '',
  flowCode: '',
  approverRole: '',
  approverIds: [] as number[],
  minApprovals: 1,
  status: '0',
  remark: ''
}

const form = reactive<any>({ ...defaultForm })
const submitLoading = ref(false)
const formRef = ref()

const rules = {
  dimensionType: [{ required: true, message: '请选择维度类型', trigger: 'change' }],
  dimensionValue: [{ required: true, message: '请填写维度值', trigger: 'blur' }]
}

// --------------- 流程选项 ---------------
const flowOptions = ref<{ flow_code: string; flow_name: string; version: number }[]>([])

// --------------- 角色搜索 ---------------
const roleSearchLoading = ref(false)
const roleOptions = ref<any[]>([])

const searchRolesRemote = async (keyword: string) => {
  if (!keyword) {
    roleOptions.value = []
    return
  }
  roleSearchLoading.value = true
  try {
    const res = await searchRoles(keyword)
    roleOptions.value = (res as any).rows || (res as any).data?.rows || []
  } finally {
    roleSearchLoading.value = false
  }
}

// --------------- 查询列表 ---------------
const getList = async () => {
  loading.value = true
  try {
    const res = await listApprovalMatrix(queryParams)
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
  queryParams.dimensionType = ''
  queryParams.dimensionValue = ''
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

// --------------- 新增 ---------------
const handleAdd = () => {
  isEdit.value = false
  currentMatrixId.value = null
  Object.assign(form, JSON.parse(JSON.stringify(defaultForm)))
  dialog.title = '新增审批矩阵'
  dialog.visible = true
  nextTick(() => {
    formRef.value?.clearValidate()
  })
}

// --------------- 编辑 ---------------
const handleEdit = async (row: any) => {
  isEdit.value = true
  currentMatrixId.value = row.matrixId
  dialog.title = '编辑审批矩阵'
  dialog.visible = true

  try {
    const res = await getApprovalMatrix(row.matrixId)
    const data = (res as any).data || res
    Object.assign(form, {
      dimensionType: data.dimensionType || '',
      dimensionValue: data.dimensionValue || '',
      flowCode: data.flowCode || '',
      approverRole: data.approverRole || '',
      approverIds: data.approverIds || [],
      minApprovals: data.minApprovals ?? 1,
      status: data.status ?? '0',
      remark: data.remark || ''
    })
  } catch {
    ElMessage.error('获取矩阵详情失败')
  }
  nextTick(() => {
    formRef.value?.clearValidate()
  })
}

// --------------- 删除 ---------------
const handleDelete = async (row: any) => {
  try {
    await ElMessageBox.confirm(`确认删除该矩阵记录吗？`, '提示', { type: 'warning' })
    await delApprovalMatrix(row.matrixId)
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
    await ElMessageBox.confirm(`确认${text}该矩阵记录吗？`, '提示')
    await updateApprovalMatrix({ matrixId: row.matrixId, status: row.status })
    ElMessage.success(`${text}成功`)
  } catch {
    row.status = row.status === '0' ? '1' : '0'
  }
}

// --------------- 提交保存 ---------------
const submitForm = () => {
  formRef.value?.validate(async (valid: boolean) => {
    if (!valid) return

    submitLoading.value = true
    try {
      const payload = { ...form }
      if (isEdit.value && currentMatrixId.value) {
        payload.matrixId = currentMatrixId.value
        await updateApprovalMatrix(payload)
        ElMessage.success('更新成功')
      } else {
        await addApprovalMatrix(payload)
        ElMessage.success('新增成功')
      }
      dialog.visible = false
      getList()
    } finally {
      submitLoading.value = false
    }
  })
}

// --------------- 关闭对话框 ---------------
const handleDialogClose = () => {
  dialog.visible = false
  formRef.value?.resetFields()
  formRef.value?.clearValidate()
}

// --------------- 初始化 ---------------
onMounted(() => {
  getList()
  loadFlows()
})
</script>
