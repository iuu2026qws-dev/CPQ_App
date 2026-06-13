<script setup lang="ts">
import { ref, onMounted } from 'vue';
import { ElMessage, ElMessageBox } from 'element-plus';
import type { FormInstance } from 'element-plus';
import {
  listCatalog, getCatalog, addCatalog, updateCatalog, delCatalog,
  type CpqProductCatalog, type CpqProductCatalogForm
} from '@/api/cpq/catalog';

const loading = ref(false);
const catalogList = ref<CpqProductCatalog[]>([]);
const dialogVisible = ref(false);
const dialogTitle = ref('');
const formRef = ref<FormInstance>();
const queryParams = ref({ catalogName: '', catalogType: '' });

const form = ref<CpqProductCatalogForm>({
  catalogName: '',
  catalogType: 'SALES',
  status: '0'
});

const rules = {
  catalogName: [{ required: true, message: '请输入目录名称', trigger: 'blur' }],
  catalogType: [{ required: true, message: '请选择目录类型', trigger: 'change' }]
};

const catalogTypeOptions = [
  { label: '销售目录', value: 'SALES' },
  { label: '渠道目录', value: 'CHANNEL' },
  { label: '内部目录', value: 'INTERNAL' }
];

const loadData = async () => {
  loading.value = true;
  try {
    catalogList.value = await listCatalog(queryParams.value);
  } finally {
    loading.value = false;
  }
};

const handleAdd = () => {
  dialogTitle.value = '新增产品目录';
  form.value = { catalogName: '', catalogType: 'SALES', status: '0' };
  dialogVisible.value = true;
};

const handleEdit = async (row: CpqProductCatalog) => {
  dialogTitle.value = '修改产品目录';
  const data = await getCatalog(row.catalogId);
  form.value = {
    catalogId: data.catalogId,
    catalogName: data.catalogName,
    catalogType: data.catalogType,
    effectiveDate: data.effectiveDate,
    expiryDate: data.expiryDate,
    status: data.status
  };
  dialogVisible.value = true;
};

const handleDelete = async (row: CpqProductCatalog) => {
  await ElMessageBox.confirm('确认删除该产品目录？', '提示', { type: 'warning' });
  await delCatalog(row.catalogId);
  ElMessage.success('删除成功');
  loadData();
};

const handleSubmit = async () => {
  try {
    const valid = await formRef.value?.validate();
    if (!valid) return;
    if (form.value.catalogId) {
      await updateCatalog(form.value);
      ElMessage.success('修改成功');
    } else {
      await addCatalog(form.value);
      ElMessage.success('新增成功');
    }
    dialogVisible.value = false;
    loadData();
  } catch {
    // 接口异常已在拦截器中提示
  }
};

onMounted(loadData);
</script>

<template>
  <div class="cpq-catalog-container">
    <el-card>
      <div class="search-bar">
        <el-form :model="queryParams" inline>
          <el-form-item label="目录名称">
            <el-input v-model="queryParams.catalogName" placeholder="请输入目录名称" clearable @keyup.enter="loadData" />
          </el-form-item>
          <el-form-item label="目录类型">
            <el-select v-model="queryParams.catalogType" placeholder="请选择" clearable>
              <el-option v-for="o in catalogTypeOptions" :key="o.value" :label="o.label" :value="o.value" />
            </el-select>
          </el-form-item>
          <el-form-item>
            <el-button type="primary" @click="loadData">查询</el-button>
            <el-button @click="queryParams = { catalogName: '', catalogType: '' }; loadData()">重置</el-button>
          </el-form-item>
        </el-form>
      </div>
    </el-card>

    <el-card style="margin-top: 16px;">
      <div class="toolbar">
        <el-button type="primary" @click="handleAdd">新增</el-button>
      </div>
      <el-table v-loading="loading" :data="catalogList" border stripe>
        <el-table-column prop="catalogId" label="ID" width="80" />
        <el-table-column prop="catalogName" label="目录名称" min-width="150" />
        <el-table-column prop="catalogType" label="目录类型" width="120">
          <template #default="{ row }">
            <el-tag :type="row.catalogType === 'SALES' ? '' : row.catalogType === 'CHANNEL' ? 'success' : 'info'">
              {{ row.catalogType === 'SALES' ? '销售目录' : row.catalogType === 'CHANNEL' ? '渠道目录' : '内部目录' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="effectiveDate" label="生效日期" width="120" />
        <el-table-column prop="expiryDate" label="失效日期" width="120" />
        <el-table-column prop="status" label="状态" width="80">
          <template #default="{ row }">
            <el-tag :type="row.status === '0' ? 'success' : 'danger'">
              {{ row.status === '0' ? '正常' : '停用' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="createTime" label="创建时间" width="180" />
        <el-table-column label="操作" width="160" fixed="right">
          <template #default="{ row }">
            <el-button link type="primary" @click="handleEdit(row)">修改</el-button>
            <el-button link type="danger" @click="handleDelete(row)">删除</el-button>
          </template>
        </el-table-column>
      </el-table>
    </el-card>

    <el-dialog v-model="dialogVisible" :title="dialogTitle" width="500px" destroy-on-close>
      <el-form ref="formRef" :model="form" :rules="rules" label-width="100px">
        <el-form-item label="目录名称" prop="catalogName">
          <el-input v-model="form.catalogName" placeholder="请输入目录名称" />
        </el-form-item>
        <el-form-item label="目录类型" prop="catalogType">
          <el-select v-model="form.catalogType">
            <el-option v-for="o in catalogTypeOptions" :key="o.value" :label="o.label" :value="o.value" />
          </el-select>
        </el-form-item>
        <el-form-item label="生效日期">
          <el-date-picker v-model="form.effectiveDate" type="date" placeholder="选择日期" />
        </el-form-item>
        <el-form-item label="失效日期">
          <el-date-picker v-model="form.expiryDate" type="date" placeholder="选择日期" />
        </el-form-item>
        <el-form-item label="状态">
          <el-radio-group v-model="form.status">
            <el-radio value="0">正常</el-radio>
            <el-radio value="1">停用</el-radio>
          </el-radio-group>
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" @click="handleSubmit">确定</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<style lang="scss" scoped>
.cpq-catalog-container {
  padding: 16px;
  .search-bar { margin-bottom: 0; }
  .toolbar { margin-bottom: 12px; }
}
</style>
