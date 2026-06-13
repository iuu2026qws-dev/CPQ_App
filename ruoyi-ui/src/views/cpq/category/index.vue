<script setup lang="ts">
import { ref, onMounted } from 'vue';
import { ElMessage, ElMessageBox } from 'element-plus';
import type { FormInstance } from 'element-plus';
import {
  treeCategory, getCategory, addCategory, updateCategory, delCategory,
  listCategoryByLevel, listCategoryByParent,
  type CpqProductCategory, type CpqProductCategoryForm
} from '@/api/cpq/category';

const loading = ref(false);
const treeData = ref<CpqProductCategory[]>([]);
const dialogVisible = ref(false);
const dialogTitle = ref('');
const formRef = ref<FormInstance>();

const levelOptions = [
  { label: '产品族', value: 1 },
  { label: '产品线', value: 2 },
  { label: '产品系列', value: 3 }
];

const parentOptions = ref<{ label: string; value: number | null }[]>([]);

const form = ref<CpqProductCategoryForm>({
  categoryLevel: 1,
  parentCategoryId: null,
  categoryCode: '',
  categoryName: '',
  sortOrder: 0,
  status: '0'
});

const rules = {
  categoryLevel: [{ required: true, message: '请选择层级', trigger: 'change' }],
  categoryCode: [{ required: true, message: '请输入分类编码', trigger: 'blur' }],
  categoryName: [{ required: true, message: '请输入分类名称', trigger: 'blur' }]
};

const loadTree = async () => {
  loading.value = true;
  try {
    treeData.value = await treeCategory();
  } finally {
    loading.value = false;
  }
};

// 获取父级 level（非顺序映射：1=产品线→父2=产品族, 2=产品族→无父, 3=产品系列→父1=产品线）
const getParentLevel = (level: number): number | null => {
  if (level === 1) return 2;
  if (level === 2) return null;
  if (level === 3) return 1;
  return null;
};

const loadParentOptions = async (level: number) => {
  const parentLevel = getParentLevel(level);
  if (parentLevel === null) {
    parentOptions.value = [{ label: '无（根节点）', value: null }];
    return;
  }
  const items = await listCategoryByLevel(parentLevel);
  parentOptions.value = items.map(c => ({ label: c.categoryName, value: c.categoryId }));
};

const handleLevelChange = (level: number) => {
  form.value.parentCategoryId = null;
  form.value.categoryLevel = level;
  loadParentOptions(level);
};

const handleAdd = (parentId: number | null = null, targetLevel: number = 1) => {
  dialogTitle.value = '新增分类';
  form.value = {
    categoryLevel: targetLevel,
    parentCategoryId: parentId,
    categoryCode: '',
    categoryName: '',
    sortOrder: 0,
    status: '0'
  };
  loadParentOptions(targetLevel);
  dialogVisible.value = true;
};

// 获取子级 level（1=产品族→子2=产品线, 2=产品线→子3=产品系列）
const getChildLevel = (parentLevel: number): number | null => {
  if (parentLevel === 1) return 2;
  if (parentLevel === 2) return 3;
  return null;
};

const handleAddChild = (parent: CpqProductCategory) => {
  const childLevel = getChildLevel(parent.categoryLevel);
  if (childLevel === null) {
    ElMessage.warning('该层级不支持添加子分类');
    return;
  }
  handleAdd(parent.categoryId, childLevel);
};

const handleEdit = async (row: CpqProductCategory) => {
  dialogTitle.value = '修改分类';
  const c = await getCategory(row.categoryId);
  form.value = {
    categoryId: c.categoryId,
    categoryLevel: c.categoryLevel,
    parentCategoryId: c.parentCategoryId,
    categoryCode: c.categoryCode,
    categoryName: c.categoryName,
    sortOrder: c.sortOrder,
    status: c.status
  };
  loadParentOptions(c.categoryLevel);
  dialogVisible.value = true;
};

const handleDelete = async (row: CpqProductCategory) => {
  await ElMessageBox.confirm('确认删除该分类？', '提示', { type: 'warning' });
  try {
    await delCategory(row.categoryId);
    ElMessage.success('删除成功');
    loadTree();
  } catch {
    // 接口异常已在拦截器中提示（如"该分类下存在子分类，无法删除"）
  }
};

const handleSubmit = async () => {
  try {
    const valid = await formRef.value?.validate();
    if (!valid) return;
    if (form.value.categoryId) {
      await updateCategory(form.value);
      ElMessage.success('修改成功');
    } else {
      await addCategory(form.value);
      ElMessage.success('新增成功');
    }
    dialogVisible.value = false;
    loadTree();
  } catch {
    // 接口异常已在拦截器中提示
  }
};

const getLevelTag = (level: number) => {
  const map: Record<number, { type: string; label: string }> = {
    1: { type: 'success', label: '产品族' },
    2: { type: '', label: '产品线' },
    3: { type: 'warning', label: '产品系列' }
  };
  return map[level] || { type: 'info', label: 'L' + level };
};

onMounted(() => {
  loadTree();
});
</script>

<template>
  <div class="cpq-category-container">
    <el-card>
      <div class="toolbar">
        <el-button type="primary" @click="handleAdd()">新增根分类</el-button>
        <el-button @click="loadTree">刷新</el-button>
      </div>
    </el-card>

    <el-card style="margin-top: 16px">
      <el-table
        v-loading="loading"
        :data="treeData"
        border
        stripe
        row-key="categoryId"
        :tree-props="{ children: 'children' }"
        default-expand-all
      >
        <el-table-column prop="categoryName" label="分类名称" min-width="180" show-overflow-tooltip />
        <el-table-column prop="categoryCode" label="分类编码" width="160" />
        <el-table-column label="层级" width="100" align="center">
          <template #default="{ row }">
            <el-tag :type="getLevelTag(row.categoryLevel).type" size="small">
              {{ getLevelTag(row.categoryLevel).label }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="sortOrder" label="排序" width="70" align="center" />
        <el-table-column label="状态" width="70" align="center">
          <template #default="{ row }">
            <el-tag :type="row.status === '0' ? 'success' : 'danger'" size="small">
              {{ row.status === '0' ? '正常' : '停用' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="160" fixed="right">
          <template #default="{ row }">
            <el-button link type="success" size="small" @click="handleAddChild(row)" v-if="row.categoryLevel < 3">
              添加子级
            </el-button>
            <el-button link type="primary" size="small" @click="handleEdit(row)">修改</el-button>
            <el-button link type="danger" size="small" @click="handleDelete(row)">删除</el-button>
          </template>
        </el-table-column>
      </el-table>
    </el-card>

    <el-dialog v-model="dialogVisible" :title="dialogTitle" width="500px" destroy-on-close>
      <el-form ref="formRef" :model="form" :rules="rules" label-width="100px">
        <el-form-item label="分类层级" prop="categoryLevel">
          <el-select v-model="form.categoryLevel" @change="handleLevelChange" :disabled="!!form.categoryId">
            <el-option v-for="o in levelOptions" :key="o.value" :label="o.label" :value="o.value" />
          </el-select>
        </el-form-item>
        <el-form-item label="父分类" prop="parentCategoryId" v-if="form.categoryLevel !== 1">
          <el-select v-model="form.parentCategoryId" placeholder="请选择父分类 (可为空)">
            <el-option
              v-for="o in parentOptions"
              :key="String(o.value)"
              :label="o.label"
              :value="o.value"
            />
          </el-select>
        </el-form-item>
        <el-form-item label="分类编码" prop="categoryCode">
          <el-input v-model="form.categoryCode" placeholder="如：DMR" />
        </el-form-item>
        <el-form-item label="分类名称" prop="categoryName">
          <el-input v-model="form.categoryName" placeholder="如：DMR数字对讲机" />
        </el-form-item>
        <el-form-item label="排序号">
          <el-input-number v-model="form.sortOrder" :min="0" style="width: 100%" />
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
.cpq-category-container {
  padding: 16px;
}
.toolbar {
  display: flex;
  gap: 8px;
}
</style>
