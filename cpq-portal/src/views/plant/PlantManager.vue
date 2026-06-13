<template>
  <div class="plant-manager">
    <el-card>
      <template #header>
        <div class="card-header">
          <h2>工厂管理</h2>
          <p class="subtitle">工厂注册、产能参数、工作日历与资质管理</p>
        </div>
      </template>
      <div class="toolbar">
        <el-input v-model="searchName" placeholder="搜索工厂名称..." clearable style="width:240px" @clear="loadData" @keyup.enter="loadData" />
        <el-select v-model="searchStatus" placeholder="状态" clearable style="width:140px;margin-left:12px" @change="loadData">
          <el-option label="启用" value="0" />
          <el-option label="停用" value="1" />
        </el-select>
        <el-button type="primary" :icon="Plus" @click="openAdd">新增工厂</el-button>
      </div>
      <el-table :data="tableData" v-loading="loading" stripe border>
        <el-table-column prop="plantCode" label="工厂编码" width="120" />
        <el-table-column prop="plantName" label="工厂名称" min-width="160" />
        <el-table-column prop="location" label="位置" width="120" />
        <el-table-column prop="capacityPerDay" label="日产能" width="100" />
        <el-table-column prop="workingDaysPerYear" label="年工作天数" width="110" />
        <el-table-column prop="qualityLevel" label="质量评级" width="100">
          <template #default="{ row }">
            <el-tag :type="row.qualityLevel === 'A' ? 'success' : row.qualityLevel === 'B' ? 'warning' : ''">
              {{ row.qualityLevel || '-' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="status" label="状态" width="80">
          <template #default="{ row }">
            <el-tag :type="row.status === '0' ? 'success' : 'danger'">{{ row.status === '0' ? '启用' : '停用' }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="160" fixed="right">
          <template #default="{ row }">
            <el-button type="primary" size="small" @click="openEdit(row)">编辑</el-button>
            <el-button type="danger" size="small" @click="handleDelete(row)">删除</el-button>
          </template>
        </el-table-column>
      </el-table>
    </el-card>

    <el-dialog :title="dialogTitle" v-model="dialogVisible" width="560px" destroy-on-close>
      <el-form ref="formRef" :model="form" :rules="rules" label-width="120px">
        <el-form-item label="工厂编码" prop="plantCode">
          <el-input v-model="form.plantCode" placeholder="如 PLANT01" maxlength="50" />
        </el-form-item>
        <el-form-item label="工厂名称" prop="plantName">
          <el-input v-model="form.plantName" maxlength="100" />
        </el-form-item>
        <el-form-item label="位置" prop="location">
          <el-input v-model="form.location" placeholder="如 上海" maxlength="200" />
        </el-form-item>
        <el-row :gutter="16">
          <el-col :span="12">
            <el-form-item label="日产能">
              <el-input-number v-model="form.capacityPerDay" :min="0" style="width:100%" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="年工作天数">
              <el-input-number v-model="form.workingDaysPerYear" :min="0" :max="366" style="width:100%" />
            </el-form-item>
          </el-col>
        </el-row>
        <el-form-item label="质量评级" prop="qualityLevel">
          <el-select v-model="form.qualityLevel" style="width:100%">
            <el-option label="A级" value="A" />
            <el-option label="B级" value="B" />
            <el-option label="C级" value="C" />
          </el-select>
        </el-form-item>
        <el-form-item label="状态" prop="status">
          <el-radio-group v-model="form.status">
            <el-radio value="0">启用</el-radio>
            <el-radio value="1">停用</el-radio>
          </el-radio-group>
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" @click="handleSave">保存</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { Plus } from '@element-plus/icons-vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { getPlantList, addPlant, updatePlant, deletePlant, type CpqPlant } from '@/api/cpq/plant'

const loading = ref(false)
const tableData = ref<CpqPlant[]>([])
const searchName = ref('')
const searchStatus = ref('')
const dialogVisible = ref(false)
const dialogTitle = ref('新增工厂')
const isEdit = ref(false)
const formRef = ref()
const form = reactive<CpqPlant>({ plantCode: '', plantName: '', location: '', capacityPerDay: 0, workingDaysPerYear: 250, qualityLevel: 'A', status: '0' })

const rules = {
  plantCode: [{ required: true, message: '请输入工厂编码', trigger: 'blur' }],
  plantName: [{ required: true, message: '请输入工厂名称', trigger: 'blur' }],
}

const loadData = async () => {
  loading.value = true
  try {
    const params: Partial<CpqPlant> = {}
    if (searchName.value) params.plantName = searchName.value
    if (searchStatus.value) params.status = searchStatus.value
    const res = await getPlantList(params)
    tableData.value = res as unknown as CpqPlant[] || []
  } finally { loading.value = false }
}

const openAdd = () => {
  dialogTitle.value = '新增工厂'
  isEdit.value = false
  Object.assign(form, { plantCode: '', plantName: '', location: '', capacityPerDay: 0, workingDaysPerYear: 250, qualityLevel: 'A', status: '0' })
  dialogVisible.value = true
}

const openEdit = (row: CpqPlant) => {
  dialogTitle.value = '编辑工厂'
  isEdit.value = true
  Object.assign(form, { ...row })
  dialogVisible.value = true
}

const handleSave = async () => {
  await formRef.value?.validate()
  if (isEdit.value && form.plantId) {
    await updatePlant({ ...form })
    ElMessage.success('更新成功')
  } else {
    await addPlant({ ...form })
    ElMessage.success('新增成功')
  }
  dialogVisible.value = false
  loadData()
}

const handleDelete = async (row: CpqPlant) => {
  await ElMessageBox.confirm('确认删除该工厂？', '警告', { type: 'warning' })
  if (row.plantId) { await deletePlant([row.plantId]); ElMessage.success('删除成功'); loadData() }
}

onMounted(loadData)
</script>

<style scoped>
.plant-manager { padding: 0; }
.card-header h2 { margin: 0; font-size: 18px; }
.subtitle { margin: 4px 0 0; color: #909399; font-size: 13px; }
.toolbar { display: flex; align-items: center; gap: 12px; margin-bottom: 16px; }
.toolbar .el-button { margin-left: auto; }
</style>
