<script setup lang="ts">
import { ref, onMounted, watch } from 'vue';
import { ElMessage, ElMessageBox } from 'element-plus';
import type { FormInstance } from 'element-plus';
import {
  listModel, getModel, addModel, updateModel, delModel, delModels,
  type CpqProductModel, type CpqProductModelForm
} from '@/api/cpq/model';
import { listCatalog, type CpqProductCatalog } from '@/api/cpq/catalog';
import {
  listCategoryByLevel, listCategoryByParent,
  type CpqProductCategory
} from '@/api/cpq/category';
import {
  listVariants, addVariant, updateVariant, delVariant,
  listVariantBom,
  type CpqProductVariant, type CpqProductVariantForm
} from '@/api/cpq/variant';

const loading = ref(false);
const modelList = ref<CpqProductModel[]>([]);
const total = ref(0);
const dialogVisible = ref(false);
const dialogTitle = ref('');
const formRef = ref<FormInstance>();
const selectedIds = ref<number[]>([]);
const catalogOptions = ref<{ label: string; value: number }[]>([]);

// 三级级联 lookup
const l1Options = ref<{ label: string; value: number }[]>([]);
const l2Options = ref<{ label: string; value: number }[]>([]);
const l3Options = ref<{ label: string; value: number }[]>([]);
const cascadingLoading = ref(false);

const queryParams = ref({
  pageNum: 1,
  pageSize: 10,
  modelName: '',
  modelCode: '',
  catalogId: undefined as number | undefined,
  categoryId: undefined as number | undefined,
  lifecycleStatus: ''
});

const form = ref<CpqProductModelForm>({
  catalogId: 0,
  categoryId: 0,
  modelCode: '',
  modelName: '',
  configType: 'STANDARD',
  status: '0',
  lifecycleStatus: 'ACTIVE'
});

// 三级级联选择的暂存值
const selectedL1 = ref<number | undefined>();
const selectedL2 = ref<number | undefined>();

const rules = {
  categoryId: [{ required: true, message: '请选择产品分类(L3)', trigger: 'change' }],
  modelCode: [{ required: true, message: '请输入产品编码', trigger: 'blur' }],
  modelName: [{ required: true, message: '请输入产品名称', trigger: 'blur' }],
  catalogId: [{ required: true, message: '请选择目录', trigger: 'change' }]
};

const lifecycleOptions = [
  { label: '概念期', value: 'CONCEPT' },
  { label: '设计期', value: 'DESIGN' },
  { label: '预发布', value: 'PRE_RELEASE' },
  { label: '活跃', value: 'ACTIVE' },
  { label: 'EOL公告', value: 'EOL_ANNOUNCED' },
  { label: '最后采购', value: 'LAST_TIME_BUY' },
  { label: '停产', value: 'DISCONTINUED' },
  { label: '归档', value: 'ARCHIVED' }
];

const configTypeOptions = [
  { label: '标准品', value: 'STANDARD' },
  { label: 'ATO', value: 'ATO' },
  { label: 'CTO', value: 'CTO' },
  { label: 'ETO', value: 'ETO' },
  { label: '捆绑包', value: 'BUNDLE' }
];

// 加载 L1（产品族）分类
const loadL1 = async () => {
  const data = await listCategoryByLevel(2);
  l1Options.value = data.map((c: CpqProductCategory) => ({ label: c.categoryName, value: c.categoryId }));
};

// L1 变化时加载 L2
const loadL2 = async (l1Id: number | undefined) => {
  if (!l1Id) { l2Options.value = []; l3Options.value = []; return; }
  const data = await listCategoryByParent(l1Id);
  l2Options.value = data.map((c: CpqProductCategory) => ({ label: c.categoryName, value: c.categoryId }));
  l3Options.value = [];
};

// L2 变化时加载 L3
const loadL3 = async (l2Id: number | undefined) => {
  if (!l2Id) { l3Options.value = []; return; }
  const data = await listCategoryByParent(l2Id);
  l3Options.value = data.map((c: CpqProductCategory) => ({ label: c.categoryName, value: c.categoryId }));
};

const handleL1Change = (val: number | undefined) => {
  selectedL1.value = val;
  selectedL2.value = undefined;
  form.value.categoryId = 0;
  loadL2(val);
};

const handleL2Change = (val: number | undefined) => {
  selectedL2.value = val;
  form.value.categoryId = 0;
  loadL3(val);
};

const handleL3Change = (val: number | undefined) => {
  form.value.categoryId = val || 0;
};

const loadCatalogs = async () => {
  const data = await listCatalog();
  catalogOptions.value = data.map((c: CpqProductCatalog) => ({
    label: c.catalogName,
    value: c.catalogId
  }));
};

const loadData = async () => {
  loading.value = true;
  try {
    const res = await listModel(queryParams.value);
    modelList.value = res.rows;
    total.value = res.total;
  } finally {
    loading.value = false;
  }
};

const handleQuery = () => {
  queryParams.value.pageNum = 1;
  loadData();
};

const handleAdd = () => {
  dialogTitle.value = '新增产品';
  selectedL1.value = undefined;
  selectedL2.value = undefined;
  l2Options.value = [];
  l3Options.value = [];
  form.value = { catalogId: 0, categoryId: 0, modelCode: '', modelName: '', configType: 'STANDARD', status: '0', lifecycleStatus: 'ACTIVE' };
  dialogVisible.value = true;
};

const handleEdit = async (row: CpqProductModel) => {
  dialogTitle.value = '修改产品';
  cascadingLoading.value = true;
  try {
    const m = await getModel(row.modelId);
    form.value = {
      modelId: m.modelId, catalogId: m.catalogId, categoryId: m.categoryId,
      modelCode: m.modelCode, modelName: m.modelName, description: m.description,
      lifecycleStatus: m.lifecycleStatus, basePrice: m.basePrice, currency: m.currency,
      minOrderQty: m.minOrderQty, leadTimeDays: m.leadTimeDays, configType: m.configType,
      defaultBomId: m.defaultBomId, thumbnailUrl: m.thumbnailUrl, status: m.status
    };
    // 回显级联选择器：根据 categoryId 反向查找 L1→L2→L3
    if (m.categoryId) {
      const cat3 = await (await import('@/api/cpq/category')).getCategory(m.categoryId);
      if (cat3 && cat3.parentCategoryId) {
        const cat2 = await (await import('@/api/cpq/category')).getCategory(cat3.parentCategoryId);
        if (cat2) {
          selectedL1.value = cat2.parentCategoryId || undefined;
          selectedL2.value = cat2.categoryId;
          if (selectedL1.value) await loadL2(selectedL1.value);
          await loadL3(cat2.categoryId);
        }
      }
    }
  } finally {
    cascadingLoading.value = false;
  }
  dialogVisible.value = true;
};

const handleDelete = async (row: CpqProductModel) => {
  await ElMessageBox.confirm('确认删除该产品？', '提示', { type: 'warning' });
  await delModel(row.modelId);
  ElMessage.success('删除成功');
  loadData();
};

const handleBatchDelete = async () => {
  if (selectedIds.value.length === 0) { ElMessage.warning('请选择产品'); return; }
  await ElMessageBox.confirm('确认批量删除所选产品？', '提示', { type: 'warning' });
  await delModels(selectedIds.value);
  ElMessage.success('批量删除成功');
  selectedIds.value = [];
  loadData();
};

const handleSubmit = async () => {
  try {
    const valid = await formRef.value?.validate();
    if (!valid) return;
    if (form.value.modelId) {
      await updateModel(form.value);
      ElMessage.success('修改成功');
    } else {
      await addModel(form.value);
      ElMessage.success('新增成功');
    }
    dialogVisible.value = false;
    loadData();
  } catch {
    // 接口异常已在拦截器中提示
  }
};

const handleSelectionChange = (rows: CpqProductModel[]) => {
  selectedIds.value = rows.map(r => r.modelId);
};

// ========== 变体管理 ==========
const variantDialogVisible = ref(false);
const variantDialogTitle = ref('');
const variantLoading = ref(false);
const variantList = ref<CpqProductVariant[]>([]);
const currentModel = ref<CpqProductModel | null>(null);
const variantFormRef = ref<FormInstance>();
const variantFormVisible = ref(false);
const variantFormTitle = ref('');
const variantSubmitting = ref(false);

const variantForm = ref<CpqProductVariantForm>({
  modelId: 0,
  variantCode: '',
  variantName: '',
  attributes: '{}',
  defaultBomId: undefined,
  basePrice: undefined,
  isDefault: '0',
  status: '0'
});

const variantRules = {
  variantCode: [{ required: true, message: '请输入变体编码', trigger: 'blur' }],
  variantName: [{ required: true, message: '请输入变体名称', trigger: 'blur' }]
};

/** 打开变体管理弹窗 */
const handleVariantManage = async (row: CpqProductModel) => {
  currentModel.value = row;
  variantDialogTitle.value = `${row.modelName}（${row.modelCode}）的变体管理`;
  variantDialogVisible.value = true;
  await loadVariants();
};

/** 加载变体列表 */
const loadVariants = async () => {
  if (!currentModel.value) return;
  variantLoading.value = true;
  try {
    const res = await listVariants(currentModel.value.modelId);
    variantList.value = Array.isArray(res) ? res : ((res as any).data || (res as any).rows || []);
  } finally {
    variantLoading.value = false;
  }
};

/** 新增变体 */
const handleVariantAdd = () => {
  variantFormTitle.value = '新增变体';
  variantForm.value = {
    modelId: currentModel.value!.modelId,
    variantCode: '',
    variantName: '',
    attributes: '{}',
    basePrice: currentModel.value!.basePrice,
    isDefault: '0',
    status: '0'
  };
  variantFormVisible.value = true;
};

/** 编辑变体 */
const handleVariantEdit = (row: CpqProductVariant) => {
  variantFormTitle.value = '修改变体';
  variantForm.value = {
    variantId: row.variantId,
    modelId: row.modelId,
    variantCode: row.variantCode,
    variantName: row.variantName,
    attributes: row.attributes || '{}',
    defaultBomId: row.defaultBomId,
    basePrice: row.basePrice,
    isDefault: row.isDefault,
    status: row.status
  };
  variantFormVisible.value = true;
};

/** 删除变体 */
const handleVariantDelete = async (row: CpqProductVariant) => {
  await ElMessageBox.confirm(`确认删除变体「${row.variantName}」？`, '提示', { type: 'warning' });
  await delVariant(row.variantId);
  ElMessage.success('删除成功');
  loadVariants();
};

/** 提交变体表单 */
const handleVariantSubmit = async () => {
  try {
    const valid = await variantFormRef.value?.validate();
    if (!valid) return;
  } catch { return; }
  variantSubmitting.value = true;
  try {
    // 确保 attributes 为合法 JSON
    const attrs = variantForm.value.attributes || '{}';
    try { JSON.parse(attrs); } catch { variantForm.value.attributes = '{}'; }
    if (variantForm.value.variantId) {
      await updateVariant(variantForm.value);
      ElMessage.success('修改成功');
    } else {
      await addVariant(variantForm.value);
      ElMessage.success('新增成功');
    }
    variantFormVisible.value = false;
    loadVariants();
  } finally {
    variantSubmitting.value = false;
  }
};

/** 格式化属性JSON为可读文本 */
const formatAttributes = (attributes: string): string => {
  if (!attributes) return '-';
  try {
    const obj = JSON.parse(attributes);
    if (typeof obj === 'object' && obj !== null) {
      return Object.entries(obj).map(([k, v]) => `${k}: ${v}`).join('；');
    }
    return attributes;
  } catch {
    return attributes;
  }
};

/** 判断JSON字符串是否为空 */
const isEmptyAttributes = (attrs: string): boolean => {
  if (!attrs || attrs === '{}' || attrs === '') return true;
  try {
    const obj = JSON.parse(attrs);
    return Object.keys(obj).length === 0;
  } catch { return true; }
};

onMounted(() => {
  loadCatalogs();
  loadL1();
  loadData();
});
</script>

<template>
  <div class="cpq-model-container">
    <el-card>
      <el-form :model="queryParams" inline>
        <el-form-item label="产品名称">
          <el-input v-model="queryParams.modelName" placeholder="请输入" clearable @keyup.enter="handleQuery" />
        </el-form-item>
        <el-form-item label="产品编码">
          <el-input v-model="queryParams.modelCode" placeholder="请输入" clearable @keyup.enter="handleQuery" />
        </el-form-item>
        <el-form-item label="所属目录">
          <el-select v-model="queryParams.catalogId" placeholder="请选择" clearable>
            <el-option v-for="o in catalogOptions" :key="o.value" :label="o.label" :value="o.value" />
          </el-select>
        </el-form-item>
        <el-form-item label="生命周期">
          <el-select v-model="queryParams.lifecycleStatus" placeholder="请选择" clearable>
            <el-option v-for="o in lifecycleOptions" :key="o.value" :label="o.label" :value="o.value" />
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="handleQuery">查询</el-button>
          <el-button @click="queryParams = { pageNum:1,pageSize:10,modelName:'',modelCode:'',catalogId:undefined,lifecycleStatus:'' }; loadData()">重置</el-button>
        </el-form-item>
      </el-form>
    </el-card>

    <el-card style="margin-top:16px">
      <div class="toolbar">
        <el-button type="primary" @click="handleAdd">新增</el-button>
        <el-button type="danger" :disabled="selectedIds.length===0" @click="handleBatchDelete">批量删除</el-button>
      </div>
      <el-table v-loading="loading" :data="modelList" border stripe @selection-change="handleSelectionChange">
        <el-table-column type="selection" width="50" />
        <el-table-column prop="modelCode" label="产品编码" width="130" />
        <el-table-column prop="modelName" label="产品名称" min-width="150" show-overflow-tooltip />
        <el-table-column prop="categoryPath" label="产品分类" min-width="200" show-overflow-tooltip />
        <el-table-column prop="catalogName" label="目录" width="120" />
        <el-table-column prop="configType" label="配置类型" width="100">
          <template #default="{ row }">
            <el-tag size="small">{{ configTypeOptions.find(o => o.value === row.configType)?.label || row.configType }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="lifecycleStatus" label="生命周期" width="120">
          <template #default="{ row }">
            <el-tag :type="row.lifecycleStatus==='ACTIVE'?'success':row.lifecycleStatus==='EOL_ANNOUNCED'?'warning':'info'" size="small">
              {{ lifecycleOptions.find(o=>o.value===row.lifecycleStatus)?.label || row.lifecycleStatus }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="basePrice" label="目录价" width="100">
          <template #default="{ row }">{{ row.basePrice ? '¥' + row.basePrice : '-' }}</template>
        </el-table-column>
        <el-table-column prop="status" label="状态" width="70">
          <template #default="{ row }">
            <el-tag :type="row.status==='0'?'success':'danger'" size="small">{{ row.status==='0'?'正常':'停用' }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="200" fixed="right">
          <template #default="{ row }">
            <el-button link type="primary" @click="handleEdit(row)">修改</el-button>
            <el-button link type="success" @click="handleVariantManage(row)">变体</el-button>
            <el-button link type="danger" @click="handleDelete(row)">删除</el-button>
          </template>
        </el-table-column>
      </el-table>
      <el-pagination
        v-model:current-page="queryParams.pageNum"
        v-model:page-size="queryParams.pageSize"
        :total="total" layout="total, prev, pager, next, sizes"
        style="margin-top:12px;justify-content:flex-end"
        @change="loadData"
      />
    </el-card>

    <el-dialog v-model="dialogVisible" :title="dialogTitle" width="700px" destroy-on-close>
      <el-form ref="formRef" :model="form" :rules="rules" label-width="100px">
        <el-row :gutter="16">
          <el-col :span="12">
            <el-form-item label="产品族(L1)">
              <el-select v-model="selectedL1" placeholder="请选择产品族" clearable filterable @change="handleL1Change" style="width:100%">
                <el-option v-for="o in l1Options" :key="o.value" :label="o.label" :value="o.value" />
              </el-select>
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="产品线(L2)">
              <el-select v-model="selectedL2" placeholder="请选择产品线" clearable filterable :disabled="!selectedL1" @change="handleL2Change" style="width:100%">
                <el-option v-for="o in l2Options" :key="o.value" :label="o.label" :value="o.value" />
              </el-select>
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="产品系列(L3)" prop="categoryId">
              <el-select v-model="form.categoryId" placeholder="请选择产品系列" clearable filterable :disabled="!selectedL2" @change="handleL3Change" style="width:100%">
                <el-option v-for="o in l3Options" :key="o.value" :label="o.label" :value="o.value" />
              </el-select>
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="产品编码" prop="modelCode">
              <el-input v-model="form.modelCode" placeholder="如：PD785" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="产品名称" prop="modelName">
              <el-input v-model="form.modelName" placeholder="请输入产品名称" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="所属目录" prop="catalogId">
              <el-select v-model="form.catalogId">
                <el-option v-for="o in catalogOptions" :key="o.value" :label="o.label" :value="o.value" />
              </el-select>
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="配置类型">
              <el-select v-model="form.configType">
                <el-option v-for="o in configTypeOptions" :key="o.value" :label="o.label" :value="o.value" />
              </el-select>
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="生命周期">
              <el-select v-model="form.lifecycleStatus">
                <el-option v-for="o in lifecycleOptions" :key="o.value" :label="o.label" :value="o.value" />
              </el-select>
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="基础目录价">
              <el-input-number v-model="form.basePrice" :precision="2" :min="0" style="width:100%" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="最小起订量">
              <el-input-number v-model="form.minOrderQty" :min="1" style="width:100%" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="标准交期(天)">
              <el-input-number v-model="form.leadTimeDays" :min="0" style="width:100%" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="状态">
              <el-radio-group v-model="form.status">
                <el-radio value="0">正常</el-radio>
                <el-radio value="1">停用</el-radio>
              </el-radio-group>
            </el-form-item>
          </el-col>
          <el-col :span="24">
            <el-form-item label="产品描述">
              <el-input v-model="form.description" type="textarea" :rows="3" />
            </el-form-item>
          </el-col>
        </el-row>
      </el-form>
      <template #footer>
        <el-button @click="dialogVisible=false">取消</el-button>
        <el-button type="primary" @click="handleSubmit">确定</el-button>
      </template>
    </el-dialog>

    <!-- 变体管理弹窗 -->
    <el-dialog v-model="variantDialogVisible" :title="variantDialogTitle" width="1000px" destroy-on-close>
      <div class="toolbar">
        <el-button type="primary" @click="handleVariantAdd">新增变体</el-button>
      </div>
      <el-table v-loading="variantLoading" :data="variantList" border stripe>
        <el-table-column prop="variantCode" label="变体编码" width="170" show-overflow-tooltip />
        <el-table-column prop="variantName" label="变体名称" min-width="160" show-overflow-tooltip />
        <el-table-column label="属性值" min-width="200" show-overflow-tooltip>
          <template #default="{ row }">
            <span>{{ formatAttributes(row.attributes) }}</span>
          </template>
        </el-table-column>
        <el-table-column prop="basePrice" label="基础价" width="100">
          <template #default="{ row }">{{ row.basePrice ? '¥' + row.basePrice : '-' }}</template>
        </el-table-column>
        <el-table-column prop="isDefault" label="默认" width="70" align="center">
          <template #default="{ row }">
            <el-tag :type="row.isDefault === '1' ? 'success' : 'info'" size="small">{{ row.isDefault === '1' ? '是' : '否' }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="status" label="状态" width="70" align="center">
          <template #default="{ row }">
            <el-tag :type="row.status === '0' ? 'success' : 'danger'" size="small">{{ row.status === '0' ? '正常' : '停用' }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="140" fixed="right" align="center">
          <template #default="{ row }">
            <el-button link type="primary" @click="handleVariantEdit(row)">修改</el-button>
            <el-button link type="danger" @click="handleVariantDelete(row)">删除</el-button>
          </template>
        </el-table-column>
      </el-table>
      <template #footer>
        <el-button @click="variantDialogVisible = false">关闭</el-button>
      </template>
    </el-dialog>

    <!-- 变体编辑弹窗 -->
    <el-dialog v-model="variantFormVisible" :title="variantFormTitle" width="600px" destroy-on-close append-to-body>
      <el-form ref="variantFormRef" :model="variantForm" :rules="variantRules" label-width="100px">
        <el-form-item label="变体编码" prop="variantCode">
          <el-input v-model="variantForm.variantCode" placeholder="如：PD785-WHT" maxlength="100" />
        </el-form-item>
        <el-form-item label="变体名称" prop="variantName">
          <el-input v-model="variantForm.variantName" placeholder="如：白色款" maxlength="200" />
        </el-form-item>
        <el-form-item label="属性值(JSON)">
          <el-input v-model="variantForm.attributes" type="textarea" :rows="4" placeholder='{&#34;color&#34;:&#34;white&#34;,&#34;size&#34;:&#34;L&#34;}' />
        </el-form-item>
        <el-form-item label="基础价">
          <el-input-number v-model="variantForm.basePrice" :precision="2" :min="0" style="width:100%" />
        </el-form-item>
        <el-form-item label="默认变体">
          <el-radio-group v-model="variantForm.isDefault">
            <el-radio value="0">否</el-radio>
            <el-radio value="1">是</el-radio>
          </el-radio-group>
        </el-form-item>
        <el-form-item label="状态">
          <el-radio-group v-model="variantForm.status">
            <el-radio value="0">正常</el-radio>
            <el-radio value="1">停用</el-radio>
          </el-radio-group>
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="variantFormVisible = false">取消</el-button>
        <el-button type="primary" :loading="variantSubmitting" @click="handleVariantSubmit">确定</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<style lang="scss" scoped>
.cpq-model-container { padding: 16px; }
.toolbar { margin-bottom: 12px; }
</style>
