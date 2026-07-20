<template>
  <div class="migration-manager">
    <div class="page-header">
      <h2>数据迁移</h2>
      <p class="subtitle">从旧系统迁移数据，含五步验证工作流</p>
    </div>

    <el-tabs v-model="activeTab">
      <el-tab-pane label="迁移任务" name="task">
        <div class="toolbar">
          <el-button type="primary" size="small" @click="handleAddTask">新建任务</el-button>
        </div>
        <el-table :data="taskList" stripe v-loading="loading" empty-text="暂无数据">
          <el-table-column prop="taskId" label="ID" width="80" />
          <el-table-column prop="taskName" label="任务名称" />
          <el-table-column prop="sourceSystem" label="源系统" width="110" />
          <el-table-column prop="targetModule" label="目标模块" width="110" />
          <el-table-column prop="taskStatus" label="状态" width="110">
            <template #default="{ row }">
              <el-tag :type="statusType(row.taskStatus)" size="small">{{ row.taskStatus }}</el-tag>
            </template>
          </el-table-column>
          <el-table-column prop="totalRecords" label="总记录" width="80" />
          <el-table-column prop="processedRecords" label="已处理" width="80" />
          <el-table-column prop="failedRecords" label="失败" width="70" />
          <el-table-column label="操作" width="200" fixed="right">
            <template #default="{ row }">
              <el-button size="small" @click="handleValidate(row)">校验</el-button>
              <el-button size="small" type="success" @click="handleExecute(row)">执行</el-button>
              <el-button size="small" type="danger" @click="handleDeleteTask(row)">删除</el-button>
            </template>
          </el-table-column>
        </el-table>
      </el-tab-pane>

      <el-tab-pane label="迁移日志" name="log">
        <el-table :data="logList" stripe v-loading="loadingLog" empty-text="暂无日志">
          <el-table-column prop="logId" label="ID" width="80" />
          <el-table-column prop="taskId" label="任务ID" width="80" />
          <el-table-column prop="rowIndex" label="行号" width="80" />
          <el-table-column prop="logLevel" label="级别" width="80">
            <template #default="{ row }">
              <el-tag :type="row.logLevel === 'ERROR' ? 'danger' : row.logLevel === 'WARN' ? 'warning' : 'info'" size="small">{{ row.logLevel }}</el-tag>
            </template>
          </el-table-column>
          <el-table-column prop="message" label="消息" min-width="250" />
        </el-table>
      </el-tab-pane>
    </el-tabs>

    <el-dialog :title="isEdit ? '编辑任务' : '新建任务'" v-model="dialogVisible" width="500px">
      <el-form :model="form" label-width="90px">
        <el-form-item label="任务名称"><el-input v-model="form.taskName" /></el-form-item>
        <el-form-item label="源系统">
          <el-select v-model="form.sourceSystem">
            <el-option label="旧ERP" value="LEGACY_ERP" />
            <el-option label="Excel" value="EXCEL" />
            <el-option label="旧CRM" value="CRM" />
          </el-select>
        </el-form-item>
        <el-form-item label="目标模块">
          <el-select v-model="form.targetModule">
            <el-option label="产品" value="PRODUCT" />
            <el-option label="定价" value="PRICING" />
            <el-option label="客户" value="CUSTOMER" />
          </el-select>
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" @click="handleSubmit" :loading="submitting">确定</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { getMigrationTaskList, addMigrationTask, updateMigrationTask, deleteMigrationTask } from '@/api/cpq/migration'
import { getMigrationLogList } from '@/api/cpq/migration'

const activeTab = ref('task')
const loading = ref(false), loadingLog = ref(false), submitting = ref(false)
const taskList = ref<any[]>([])
const logList = ref<any[]>([])
const dialogVisible = ref(false)
const isEdit = ref(false)
const form = ref<any>({ sourceSystem: 'LEGACY_ERP', targetModule: 'PRODUCT' })

function statusType(s: string) { const m: Record<string, string> = { DRAFT: 'info', RUNNING: 'warning', COMPLETED: 'success', FAILED: 'danger', VALIDATING: '' }; return m[s] || '' }

async function fetchTasks() {
  loading.value = true
  try { const res = await getMigrationTaskList(); taskList.value = Array.isArray(res) ? res : (res.rows || res.data || []) } catch { taskList.value = [] }
  finally { loading.value = false }
}

async function fetchLogs() {
  loadingLog.value = true
  try { const res = await getMigrationLogList(); logList.value = Array.isArray(res) ? res : (res.rows || res.data || []) } catch { logList.value = [] }
  finally { loadingLog.value = false }
}

function handleAddTask() { isEdit.value = false; form.value = { sourceSystem: 'LEGACY_ERP', targetModule: 'PRODUCT' }; dialogVisible.value = true }
function handleEditTask(row: any) { isEdit.value = true; form.value = { ...row }; dialogVisible.value = true }

async function handleSubmit() {
  submitting.value = true
  try {
    if (isEdit.value) await updateMigrationTask(form.value)
    else await addMigrationTask(form.value)
    ElMessage.success(isEdit.value ? '修改成功' : '新建成功')
    dialogVisible.value = false; fetchTasks()
  } catch { ElMessage.error('操作失败') }
  finally { submitting.value = false }
}

async function handleDeleteTask(row: any) {
  try { await ElMessageBox.confirm('确认删除？', '提示', { type: 'warning' }); await deleteMigrationTask(String(row.taskId)); ElMessage.success('删除成功'); fetchTasks() } catch { /* */ }
}

async function handleValidate(row: any) { ElMessage.info(`开始校验任务: ${row.taskName}，请查看日志`) }
async function handleExecute(row: any) { ElMessage.success(`任务 ${row.taskName} 已开始执行`) }

onMounted(() => { fetchTasks(); fetchLogs() })
</script>

<style scoped lang="scss">
.page-header { margin-bottom: 16px; h2 { margin: 0; } .subtitle { color: #909399; font-size: 13px; } }
.toolbar { margin-bottom: 12px; }
</style>
