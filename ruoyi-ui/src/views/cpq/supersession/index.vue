<script setup lang="ts">
import { ref, onMounted } from 'vue';
import { ElMessage, ElMessageBox } from 'element-plus';
import type { FormInstance } from 'element-plus';
import {
  listSupersession, getSupersession, addSupersession, updateSupersession, delSupersession,
  type CpqProductSupersession, type CpqProductSupersessionForm
} from '@/api/cpq/supersession';
import { searchModels, type CpqProductModel } from '@/api/cpq/model';

const loading = ref(false);
const list = ref<CpqProductSupersession[]>([]);
const dialogVisible = ref(false);
const dialogTitle = ref('');
const formRef = ref<FormInstance>();
const queryParams = ref({ originalModelId: undefined as number | undefined });

const form = ref<CpqProductSupersessionForm>({
  originalModelId: undefined as unknown as number,
  replacementModelId: undefined as unknown as number,
  supersessionType: 'FULL',
  status: '0'
});

const rules = {
  originalModelId: [{ required: true, message: '请选择被替代产品', trigger: 'change' }],
  replacementModelId: [{ required: true, message: '请选择替代产品', trigger: 'change' }],
  supersessionType: [{ required: true, message: '请选择替代类型', trigger: 'change' }]
};

const typeOptions = [
  { label: '完全替代', value: 'FULL' },
  { label: '条件替代', value: 'CONDITIONAL' },
  { label: '拆分替代', value: 'SPLIT' },
  { label: '合并替代', value: 'AGGREGATE' }
];

// --- 产品远程搜索 lookup ---
const queryModelOptions = ref<{ label: string; value: number }[]>([]);
const originalModelOptions = ref<{ label: string; value: number }[]>([]);
const replacementModelOptions = ref<{ label: string; value: number }[]>([]);
const searchLoading = ref(false);

const buildOptions = (models: CpqProductModel[]) =>
  models.map(m => ({ label: `${m.modelCode} - ${m.modelName}`, value: m.modelId }));

const searchQueryModels = async (keyword: string) => {
  if (!keyword) { queryModelOptions.value = []; return; }
  try {
    const models = await searchModels(keyword);
    queryModelOptions.value = buildOptions(models);
  } catch { /* ignore */ }
};

const searchOriginalModels = async (keyword: string) => {
  searchLoading.value = true;
  try {
    const models = keyword ? await searchModels(keyword) : [];
    originalModelOptions.value = buildOptions(models);
  } finally { searchLoading.value = false; }
};

const searchReplacementModels = async (keyword: string) => {
  searchLoading.value = true;
  try {
    const models = keyword ? await searchModels(keyword) : [];
    replacementModelOptions.value = buildOptions(models);
  } finally { searchLoading.value = false; }
};

const loadData = async () => {
  loading.value = true;
  try {
    list.value = await listSupersession(queryParams.value);
  } finally {
    loading.value = false;
  }
};

const handleAdd = () => {
  dialogTitle.value = '新增替代关系';
  form.value = { originalModelId: undefined as unknown as number, replacementModelId: undefined as unknown as number, supersessionType: 'FULL', status: '0' };
  originalModelOptions.value = [];
  replacementModelOptions.value = [];
  dialogVisible.value = true;
};

const handleEdit = async (row: CpqProductSupersession) => {
  dialogTitle.value = '修改替代关系';
  const s = await getSupersession(row.supersessionId);
  form.value = {
    supersessionId: s.supersessionId, originalModelId: s.originalModelId,
    replacementModelId: s.replacementModelId, supersessionType: s.supersessionType,
    conditionExpr: s.conditionExpr, priceImpactPct: s.priceImpactPct,
    effectiveDate: s.effectiveDate, status: s.status
  };
  // 预填当前产品选项以回显
  originalModelOptions.value = [{ label: `${s.originalModelCode} - ${s.originalModelName}`, value: s.originalModelId }];
  replacementModelOptions.value = [{ label: `${s.replacementModelCode} - ${s.replacementModelName}`, value: s.replacementModelId }];
  dialogVisible.value = true;
};

const handleDelete = async (row: CpqProductSupersession) => {
  await ElMessageBox.confirm('确认删除该替代关系？', '提示', { type: 'warning' });
  await delSupersession(row.supersessionId);
  ElMessage.success('删除成功');
  loadData();
};

const handleSubmit = async () => {
  try {
    const valid = await formRef.value?.validate();
    if (!valid) return;
    if (form.value.supersessionId) {
      await updateSupersession(form.value);
      ElMessage.success('修改成功');
    } else {
      await addSupersession(form.value);
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
  <div class="cpq-supersession-container">
    <el-card>
      <el-form :model="queryParams" inline>
        <el-form-item label="被替代产品">
          <el-select
            v-model="queryParams.originalModelId"
            filterable remote :remote-method="searchQueryModels"
            placeholder="输入产品编码或名称搜索" clearable style="width:240px"
            @clear="searchQueryModels(''); loadData">
          >
            <el-option v-for="o in queryModelOptions" :key="o.value" :label="o.label" :value="o.value" />
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="loadData">查询</el-button>
        </el-form-item>
      </el-form>
    </el-card>

    <el-card style="margin-top:16px">
      <div class="toolbar">
        <el-button type="primary" @click="handleAdd">新增</el-button>
      </div>
      <el-table v-loading="loading" :data="list" border stripe>
        <el-table-column prop="supersessionId" label="ID" width="80" />
        <el-table-column prop="originalModelName" label="被替代产品" min-width="150">
          <template #default="{ row }">
            <div>{{ row.originalModelName }}</div>
            <div style="font-size:12px;color:#909399">{{ row.originalModelCode }}</div>
          </template>
        </el-table-column>
        <el-table-column prop="replacementModelName" label="替代产品" min-width="150">
          <template #default="{ row }">
            <div>{{ row.replacementModelName }}</div>
            <div style="font-size:12px;color:#909399">{{ row.replacementModelCode }}</div>
          </template>
        </el-table-column>
        <el-table-column prop="supersessionType" label="替代类型" width="100">
          <template #default="{ row }">
            <el-tag :type="row.supersessionType==='FULL'?'success':row.supersessionType==='CONDITIONAL'?'warning':'info'" size="small">
              {{ typeOptions.find(o=>o.value===row.supersessionType)?.label || row.supersessionType }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="priceImpactPct" label="价格影响%" width="100">
          <template #default="{ row }">{{ row.priceImpactPct ? row.priceImpactPct + '%' : '-' }}</template>
        </el-table-column>
        <el-table-column prop="effectiveDate" label="生效日期" width="120" />
        <el-table-column prop="status" label="状态" width="70">
          <template #default="{ row }">
            <el-tag :type="row.status==='0'?'success':'danger'" size="small">{{ row.status==='0'?'正常':'停用' }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="140" fixed="right">
          <template #default="{ row }">
            <el-button link type="primary" @click="handleEdit(row)">修改</el-button>
            <el-button link type="danger" @click="handleDelete(row)">删除</el-button>
          </template>
        </el-table-column>
      </el-table>
    </el-card>

    <el-dialog v-model="dialogVisible" :title="dialogTitle" width="550px" destroy-on-close>
      <el-form ref="formRef" :model="form" :rules="rules" label-width="120px">
        <el-form-item label="被替代产品" prop="originalModelId">
          <el-select
            v-model="form.originalModelId"
            filterable remote :remote-method="searchOriginalModels"
            :loading="searchLoading"
            placeholder="输入产品编码或名称搜索" style="width:100%"
          >
            <el-option v-for="o in originalModelOptions" :key="o.value" :label="o.label" :value="o.value" />
          </el-select>
        </el-form-item>
        <el-form-item label="替代产品" prop="replacementModelId">
          <el-select
            v-model="form.replacementModelId"
            filterable remote :remote-method="searchReplacementModels"
            :loading="searchLoading"
            placeholder="输入产品编码或名称搜索" style="width:100%"
          >
            <el-option v-for="o in replacementModelOptions" :key="o.value" :label="o.label" :value="o.value" />
          </el-select>
        </el-form-item>
        <el-form-item label="替代类型" prop="supersessionType">
          <el-select v-model="form.supersessionType">
            <el-option v-for="o in typeOptions" :key="o.value" :label="o.label" :value="o.value" />
          </el-select>
        </el-form-item>
        <el-form-item label="条件表达式">
          <el-input v-model="form.conditionExpr" placeholder="条件替代时填写" />
        </el-form-item>
        <el-form-item label="价格影响%">
          <el-input-number v-model="form.priceImpactPct" :precision="2" :min="-100" :max="1000" style="width:100%" />
        </el-form-item>
        <el-form-item label="生效日期">
          <el-date-picker v-model="form.effectiveDate" type="date" placeholder="选择日期" />
        </el-form-item>
        <el-form-item label="状态">
          <el-radio-group v-model="form.status">
            <el-radio value="0">正常</el-radio>
            <el-radio value="1">停用</el-radio>
          </el-radio-group>
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="dialogVisible=false">取消</el-button>
        <el-button type="primary" @click="handleSubmit">确定</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<style lang="scss" scoped>
.cpq-supersession-container { padding: 16px; }
.toolbar { margin-bottom: 12px; }
</style>
