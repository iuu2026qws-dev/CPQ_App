<template>
  <div class="integration-manager">
    <div class="page-header">
      <h2>集成管理</h2>
      <p class="subtitle">管理与CRM、ERP、PLM系统的数据集成配置</p>
    </div>
    <el-card shadow="never">
      <template #header>
        <div class="card-header">
          <strong>集成配置列表</strong>
          <el-button type="primary" size="small" @click="handleAdd">新增配置</el-button>
        </div>
      </template>
      <el-table :data="configList" stripe v-loading="loading" empty-text="暂无数据">
        <el-table-column prop="configId" label="ID" width="80" />
        <el-table-column prop="systemType" label="系统类型" width="100" />
        <el-table-column prop="systemName" label="系统名称" />
        <el-table-column prop="endpointUrl" label="端点URL" min-width="200" />
        <el-table-column prop="authType" label="认证方式" width="110" />
        <el-table-column prop="syncDirection" label="同步方向" width="120" />
        <el-table-column prop="status" label="状态" width="90">
          <template #default="{ row }">
            <el-tag :type="row.status === '0' ? 'success' : 'danger'" size="small">
              {{ row.status === '0' ? '启用' : '停用' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="180" fixed="right">
          <template #default="{ row }">
            <el-button size="small" @click="handleEdit(row)">编辑</el-button>
            <el-button size="small" @click="testConnector(row)">测试</el-button>
            <el-button size="small" type="danger" @click="handleDelete(row)">删除</el-button>
          </template>
        </el-table-column>
      </el-table>
    </el-card>

    <el-dialog :title="dialogTitle" v-model="dialogVisible" width="560px">
      <el-form :model="form" label-width="100px">
        <el-form-item label="系统类型" required>
          <el-select v-model="form.systemType" placeholder="请选择">
            <el-option label="CRM" value="CRM" />
            <el-option label="ERP" value="ERP" />
            <el-option label="PLM" value="PLM" />
          </el-select>
        </el-form-item>
        <el-form-item label="系统名称" required>
          <el-input v-model="form.systemName" placeholder="如：纷享销客CRM" />
        </el-form-item>
        <el-form-item label="端点URL" required>
          <el-input v-model="form.endpointUrl" placeholder="https://..." />
        </el-form-item>
        <el-form-item label="认证方式">
          <el-select v-model="form.authType">
            <el-option label="API Key" value="API_KEY" />
            <el-option label="OAuth2" value="OAUTH2" />
            <el-option label="Basic" value="BASIC" />
          </el-select>
        </el-form-item>
        <el-form-item label="同步方向">
          <el-select v-model="form.syncDirection">
            <el-option label="双向同步" value="BIDIRECTIONAL" />
            <el-option label="仅拉取" value="INBOUND" />
            <el-option label="仅推送" value="OUTBOUND" />
          </el-select>
        </el-form-item>
        <el-form-item label="状态">
          <el-radio-group v-model="form.status">
            <el-radio label="0">启用</el-radio>
            <el-radio label="1">停用</el-radio>
          </el-radio-group>
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
import { ref, onMounted, computed } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { getConfigList, addConfig, updateConfig, deleteConfig, syncCrmOpportunity, createErpOrder, syncPlmProduct } from '@/api/cpq/integration'

const loading = ref(false)
const submitting = ref(false)
const configList = ref<any[]>([])
const dialogVisible = ref(false)
const form = ref<any>({ systemType: 'CRM', authType: 'API_KEY', syncDirection: 'BIDIRECTIONAL', status: '0' })
const isEdit = ref(false)

const dialogTitle = computed(() => isEdit.value ? '编辑集成配置' : '新增集成配置')

async function fetchList() {
  loading.value = true
  try {
    const res = await getConfigList()
    configList.value = Array.isArray(res) ? res : (res.rows || res.data || [])
  } catch { configList.value = [] }
  finally { loading.value = false }
}

function handleAdd() { isEdit.value = false; form.value = { systemType: 'CRM', authType: 'API_KEY', syncDirection: 'BIDIRECTIONAL', status: '0' }; dialogVisible.value = true }
function handleEdit(row: any) { isEdit.value = true; form.value = { ...row }; dialogVisible.value = true }

async function handleSubmit() {
  submitting.value = true
  try {
    if (isEdit.value) await updateConfig(form.value)
    else await addConfig(form.value)
    ElMessage.success(isEdit.value ? '修改成功' : '新增成功')
    dialogVisible.value = false
    fetchList()
  } catch { ElMessage.error('操作失败') }
  finally { submitting.value = false }
}

async function handleDelete(row: any) {
  try {
    await ElMessageBox.confirm('确认删除该配置？', '提示', { type: 'warning' })
    await deleteConfig(String(row.configId))
    ElMessage.success('删除成功')
    fetchList()
  } catch { /* cancelled */ }
}

async function testConnector(row: any) {
  try {
    if (row.systemType === 'CRM') await syncCrmOpportunity({ name: '测试商机', amount: 50000 })
    else if (row.systemType === 'ERP') await createErpOrder({ plantCode: 'SH01' })
    else if (row.systemType === 'PLM') await syncPlmProduct({ partNumber: 'TEST-001', name: '测试产品' })
    ElMessage.success(`${row.systemType} 连接测试成功`)
  } catch { ElMessage.error(`${row.systemType} 连接测试失败`) }
}

onMounted(fetchList)
</script>

<style scoped lang="scss">
.page-header { margin-bottom: 16px; h2 { margin: 0; } .subtitle { color: #909399; font-size: 13px; } }
.card-header { display: flex; justify-content: space-between; align-items: center; }
</style>
