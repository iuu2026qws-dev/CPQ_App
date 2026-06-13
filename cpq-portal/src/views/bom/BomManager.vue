<template>
  <div class="bom-manager">
    <div class="page-header">
      <h2>BOM管理</h2>
      <p class="subtitle">SBOM Header 与 Line 完整 CRUD，树形 BOM 展开</p>
    </div>

    <!-- ========== 产品选择区 ========== -->
    <el-card shadow="never" class="mb-card">
      <el-row :gutter="16" align="middle">
        <el-col :span="8">
          <el-select
            v-model="selectedModelId"
            filterable
            remote
            :remote-method="searchModels"
            placeholder="搜索产品编码/名称"
            style="width: 100%"
            @change="onModelChange"
            clearable
            :loading="modelSearching"
          >
            <el-option v-for="m in modelOptions" :key="m.value" :label="m.label" :value="m.value" />
          </el-select>
        </el-col>
        <el-col :span="4">
          <el-tag v-if="selectedModelName" type="success" effect="plain">{{ selectedModelName }}</el-tag>
        </el-col>
      </el-row>
    </el-card>

    <!-- ========== 双栏布局 ========== -->
    <el-row :gutter="16" v-if="selectedModelId">
      <!-- ===== 左侧：SBOM Header 列表 ===== -->
      <el-col :span="6">
        <el-card shadow="never" class="header-card">
          <template #header>
            <div class="card-header-row">
              <span>SBOM Header 列表</span>
              <el-button type="primary" size="small" :icon="Plus" @click="onAddHeader">新增</el-button>
            </div>
          </template>
          <div v-loading="headerLoading">
            <div v-if="headers.length === 0" class="empty-hint">暂无 SBOM Header</div>
            <div
              v-for="h in headers"
              :key="h.sbomHeaderId"
              class="header-item"
              :class="{ active: selectedHeaderId === h.sbomHeaderId }"
              @click="selectHeader(h.sbomHeaderId!)"
            >
              <div class="header-name">
                <span class="version-tag">{{ h.sbomVersion }}</span>
                {{ h.sbomName }}
              </div>
              <div class="header-meta">
                <el-tag size="small" :type="h.status === 'ACTIVE' ? 'success' : 'info'">{{ h.status }}</el-tag>
              </div>
              <div class="header-actions">
                <el-button text size="small" type="primary" :icon="Edit" @click.stop="onEditHeader(h)" />
                <el-button text size="small" type="danger" :icon="Delete" @click.stop="onDeleteHeader(h)" />
              </div>
            </div>
          </div>
        </el-card>
      </el-col>

      <!-- ===== 右侧：BOM 树形表格 ===== -->
      <el-col :span="18">
        <el-card shadow="never" class="bom-card">
          <template #header>
            <div class="card-header-row">
              <span>
                BOM 树
                <template v-if="selectedHeader">
                  — {{ selectedHeader.sbomVersion }} / {{ selectedHeader.sbomName }}
                </template>
              </span>
              <div>
                <el-button size="small" type="primary" :icon="Plus" @click="onAddRootLine">
                  添加根行
                </el-button>
                <el-button size="small" @click="toggleExpandAll">
                  {{ allExpanded ? '收起全部' : '展开全部' }}
                </el-button>
                <el-button size="small" @click="loadBomTree" :loading="bomLoading" :icon="Refresh">
                  刷新
                </el-button>
              </div>
            </div>
          </template>

          <el-table
            :data="bomTreeData"
            stripe
            v-loading="bomLoading"
            row-key="sbomLineId"
            :tree-props="{ children: 'children', hasChildren: 'hasChildren' }"
            :default-expand-all="allExpanded"
            empty-text="请选择一个 SBOM Header 展开"
            size="small"
          >
            <el-table-column prop="lineNumber" label="行号" width="70" />
            <el-table-column prop="itemCode" label="物料编码" width="140" />
            <el-table-column prop="itemName" label="物料名称" min-width="160" />
            <el-table-column prop="quantity" label="用量" width="80" />
            <el-table-column prop="unit" label="单位" width="70" />
            <el-table-column prop="itemType" label="类型" width="80">
              <template #default="{ row }">
                <el-tag size="small" :type="row.itemType === 'VIRTUAL' ? 'info' : ''">
                  {{ row.itemType === 'VIRTUAL' ? '虚项' : '实物' }}
                </el-tag>
              </template>
            </el-table-column>
            <el-table-column prop="isPhantom" label="虚项标记" width="85" align="center">
              <template #default="{ row }">
                <el-tag size="small" :type="row.isPhantom === 'Y' ? 'warning' : 'info'">
                  {{ row.isPhantom === 'Y' ? '虚' : '实' }}
                </el-tag>
              </template>
            </el-table-column>
            <el-table-column prop="isRequired" label="必选" width="65" align="center">
              <template #default="{ row }">
                <el-tag size="small" :type="row.isRequired === 'Y' ? 'danger' : 'info'">
                  {{ row.isRequired === 'Y' ? '必' : '选' }}
                </el-tag>
              </template>
            </el-table-column>
            <el-table-column prop="isReplaceable" label="可替换" width="75" align="center">
              <template #default="{ row }">
                <span>{{ row.isReplaceable === 'Y' ? '是' : '否' }}</span>
              </template>
            </el-table-column>
            <el-table-column prop="replacementGroup" label="替换组" width="90" />
            <el-table-column prop="sortOrder" label="排序" width="65" align="center" />
            <el-table-column label="操作" width="160" fixed="right">
              <template #default="{ row }">
                <el-button text size="small" type="primary" @click="onAddLine(row)">加子行</el-button>
                <el-button text size="small" type="primary" @click="onEditLine(row)">编辑</el-button>
                <el-button text size="small" type="danger" @click="onDeleteLine(row)">删除</el-button>
              </template>
            </el-table-column>
          </el-table>
        </el-card>
      </el-col>
    </el-row>

    <!-- 未选择产品的空状态 -->
    <el-empty v-else description="请搜索并选择一个产品，查看其 SBOM" />

    <!-- ========== Header 新增/编辑弹窗 ========== -->
    <el-dialog
      v-model="headerDialog.visible"
      :title="headerDialog.isEdit ? '编辑 SBOM Header' : '新增 SBOM Header'"
      width="500px"
      :close-on-click-modal="false"
    >
      <el-form ref="headerFormRef" :model="headerDialog.form" :rules="headerRules" label-width="100px">
        <el-form-item label="SBOM 名称" prop="sbomName">
          <el-input v-model="headerDialog.form.sbomName" placeholder="如：标准SBOM、150%SBOM" maxlength="100" />
        </el-form-item>
        <el-form-item label="版本号" prop="sbomVersion">
          <el-input v-model="headerDialog.form.sbomVersion" placeholder="如：V1.0、V2.0" maxlength="50" />
        </el-form-item>
        <el-form-item label="状态" prop="status">
          <el-select v-model="headerDialog.form.status" style="width: 100%">
            <el-option label="启用" value="ACTIVE" />
            <el-option label="停用" value="INACTIVE" />
            <el-option label="草稿" value="DRAFT" />
          </el-select>
        </el-form-item>
        <el-form-item label="备注" prop="remark">
          <el-input v-model="headerDialog.form.remark" type="textarea" :rows="2" maxlength="500" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="headerDialog.visible = false">取消</el-button>
        <el-button type="primary" @click="submitHeader" :loading="headerDialog.submitting">确定</el-button>
      </template>
    </el-dialog>

    <!-- ========== Line 新增/编辑弹窗 ========== -->
    <el-dialog
      v-model="lineDialog.visible"
      :title="lineDialogTitle"
      width="580px"
      :close-on-click-modal="false"
    >
      <el-form ref="lineFormRef" :model="lineDialog.form" :rules="lineRules" label-width="100px">
        <el-row :gutter="12">
          <el-col :span="12">
            <el-form-item label="物料编码" prop="itemCode">
              <el-input v-model="lineDialog.form.itemCode" placeholder="如：PD785-MB" maxlength="100" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="物料名称" prop="itemName">
              <el-input v-model="lineDialog.form.itemName" placeholder="如：PD785主板" maxlength="200" />
            </el-form-item>
          </el-col>
        </el-row>
        <el-row :gutter="12">
          <el-col :span="8">
            <el-form-item label="用量" prop="quantity">
              <el-input-number v-model="lineDialog.form.quantity" :min="0" :precision="4" style="width: 100%" />
            </el-form-item>
          </el-col>
          <el-col :span="8">
            <el-form-item label="单位" prop="unit">
              <el-input v-model="lineDialog.form.unit" placeholder="PCS" maxlength="20" />
            </el-form-item>
          </el-col>
          <el-col :span="8">
            <el-form-item label="类型" prop="itemType">
              <el-select v-model="lineDialog.form.itemType" style="width: 100%">
                <el-option label="实物" value="PHYSICAL" />
                <el-option label="虚项" value="VIRTUAL" />
              </el-select>
            </el-form-item>
          </el-col>
        </el-row>
        <el-row :gutter="12">
          <el-col :span="8">
            <el-form-item label="虚项标记">
              <el-switch
                v-model="lineDialog.form.isPhantomBool"
                active-text="虚"
                inactive-text="实"
                :active-value="true"
                :inactive-value="false"
              />
            </el-form-item>
          </el-col>
          <el-col :span="8">
            <el-form-item label="必选">
              <el-switch
                v-model="lineDialog.form.isRequiredBool"
                active-text="必"
                inactive-text="选"
                :active-value="true"
                :inactive-value="false"
              />
            </el-form-item>
          </el-col>
          <el-col :span="8">
            <el-form-item label="可替换">
              <el-switch
                v-model="lineDialog.form.isReplaceableBool"
                active-text="是"
                inactive-text="否"
                :active-value="true"
                :inactive-value="false"
              />
            </el-form-item>
          </el-col>
        </el-row>
        <el-row :gutter="12">
          <el-col :span="12">
            <el-form-item label="替换组">
              <el-input v-model="lineDialog.form.replacementGroup" placeholder="如：GROUP_A" maxlength="50" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="排序号">
              <el-input-number v-model="lineDialog.form.sortOrder" :min="0" style="width: 100%" />
            </el-form-item>
          </el-col>
        </el-row>
        <el-row :gutter="12">
          <el-col :span="8">
            <el-form-item label="最小用量">
              <el-input-number v-model="lineDialog.form.minQty" :min="0" :precision="4" style="width: 100%" />
            </el-form-item>
          </el-col>
          <el-col :span="8">
            <el-form-item label="最大用量">
              <el-input-number v-model="lineDialog.form.maxQty" :min="0" :precision="4" style="width: 100%" />
            </el-form-item>
          </el-col>
          <el-col :span="8">
            <el-form-item label="行号">
              <el-input-number v-model="lineDialog.form.lineNumber" :min="0" style="width: 100%" />
            </el-form-item>
          </el-col>
        </el-row>
      </el-form>
      <template #footer>
        <el-button @click="lineDialog.visible = false">取消</el-button>
        <el-button type="primary" @click="submitLine" :loading="lineDialog.submitting">确定</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, computed, nextTick } from 'vue'
import { Plus, Edit, Delete, Refresh } from '@element-plus/icons-vue'
import { ElMessage, ElMessageBox, type FormInstance, type FormRules } from 'element-plus'
import request from '@/utils/request'
import {
  listSbomHeaders, getSbomHeader, addSbomHeader, editSbomHeader, deleteSbomHeader,
  listSbomLines, addSbomLine, editSbomLine, deleteSbomLine,
  explodeBom, type SbomHeader, type SbomLine
} from '@/api/bom'
import type { FormItemRule } from 'element-plus'

// ==================== 产品搜索 ====================

interface ModelOption { label: string; value: number }

const selectedModelId = ref<number | null>(null)
const selectedModelName = ref('')
const modelOptions = ref<ModelOption[]>([])
const modelSearching = ref(false)

const searchModels = async (query: string) => {
  if (!query || query.length < 1) { modelOptions.value = []; return }
  modelSearching.value = true
  try {
    const data = await request.get('/cpq/product/model/search', { params: { keyword: query } })
    modelOptions.value = (data || []).map((m: any) => ({
      label: `${m.modelCode} - ${m.modelName}`,
      value: m.modelId
    }))
  } finally {
    modelSearching.value = false
  }
}

// ==================== Header 管理 ====================

const headers = ref<SbomHeader[]>([])
const headerLoading = ref(false)
const selectedHeaderId = ref<number | null>(null)
const selectedHeader = computed(() => headers.value.find(h => h.sbomHeaderId === selectedHeaderId.value))

const onModelChange = async (modelId: number | null) => {
  selectedHeaderId.value = null
  bomTreeData.value = []
  selectedModelName.value = ''
  if (!modelId) { headers.value = []; return }
  // 获取产品名称
  const opt = modelOptions.value.find(m => m.value === modelId)
  selectedModelName.value = opt?.label || ''
  // 加载该产品的 SBOM Header 列表
  headerLoading.value = true
  try {
    headers.value = await listSbomHeaders({ modelId })
  } finally {
    headerLoading.value = false
  }
}

const selectHeader = (headerId: number) => {
  selectedHeaderId.value = headerId
  loadBomTree()
}

// Header 弹窗
const headerDialog = reactive({
  visible: false,
  isEdit: false,
  submitting: false,
  form: {
    sbomHeaderId: undefined as number | undefined,
    modelId: 0,
    sbomName: '',
    sbomVersion: '',
    status: 'ACTIVE',
    remark: ''
  }
})

const headerRules: FormRules = {
  sbomName: [{ required: true, message: '请输入SBOM名称', trigger: 'blur' }],
  sbomVersion: [{ required: true, message: '请输入版本号', trigger: 'blur' }],
  status: [{ required: true, message: '请选择状态', trigger: 'change' }]
}

const headerFormRef = ref<FormInstance>()

const onAddHeader = () => {
  headerDialog.isEdit = false
  headerDialog.form = {
    sbomHeaderId: undefined,
    modelId: selectedModelId.value!,
    sbomName: '',
    sbomVersion: '',
    status: 'ACTIVE',
    remark: ''
  }
  headerDialog.visible = true
}

const onEditHeader = (h: SbomHeader) => {
  headerDialog.isEdit = true
  headerDialog.form = {
    sbomHeaderId: h.sbomHeaderId,
    modelId: h.modelId,
    sbomName: h.sbomName,
    sbomVersion: h.sbomVersion,
    status: h.status,
    remark: h.remark || ''
  }
  headerDialog.visible = true
}

const onDeleteHeader = async (h: SbomHeader) => {
  try {
    await ElMessageBox.confirm(
      `确定删除 SBOM Header「${h.sbomVersion} / ${h.sbomName}」吗？该操作会级联删除所有关联的 BOM Line。`,
      '删除确认',
      { confirmButtonText: '确定删除', cancelButtonText: '取消', type: 'warning' }
    )
  } catch { return }
  headerDialog.submitting = true
  try {
    await deleteSbomHeader(h.sbomHeaderId!)
    ElMessage.success('删除成功')
    if (selectedHeaderId.value === h.sbomHeaderId) {
      selectedHeaderId.value = null
      bomTreeData.value = []
    }
    await onModelChange(selectedModelId.value)
  } finally {
    headerDialog.submitting = false
  }
}

const submitHeader = async () => {
  const valid = await headerFormRef.value?.validate().catch(() => false)
  if (!valid) return
  headerDialog.submitting = true
  try {
    const payload: SbomHeader = {
      modelId: headerDialog.form.modelId,
      sbomName: headerDialog.form.sbomName,
      sbomVersion: headerDialog.form.sbomVersion,
      status: headerDialog.form.status,
      remark: headerDialog.form.remark
    }
    if (headerDialog.isEdit && headerDialog.form.sbomHeaderId) {
      await editSbomHeader({ ...payload, sbomHeaderId: headerDialog.form.sbomHeaderId } as SbomHeader)
      ElMessage.success('修改成功')
    } else {
      await addSbomHeader(payload)
      ElMessage.success('新增成功')
    }
    headerDialog.visible = false
    await onModelChange(selectedModelId.value)
  } finally {
    headerDialog.submitting = false
  }
}

// ==================== BOM 树 ====================

const bomTreeData = ref<SbomLine[]>([])
const bomLoading = ref(false)
const allExpanded = ref(true)

const toggleExpandAll = () => {
  allExpanded.value = !allExpanded.value
}

const loadBomTree = async () => {
  if (!selectedHeaderId.value) return
  bomLoading.value = true
  try {
    const data = await explodeBom(selectedHeaderId.value)
    bomTreeData.value = formatChildren(data || [])
  } finally {
    bomLoading.value = false
  }
}

const formatChildren = (items: SbomLine[]): SbomLine[] => {
  return items.map(item => ({
    ...item,
    children: item.children && item.children.length > 0 ? formatChildren(item.children) : undefined,
    hasChildren: !!(item.children && item.children.length > 0)
  } as SbomLine))
}

// ==================== Line 弹窗 ====================

interface LineFormData {
  sbomLineId?: number
  sbomHeaderId: number
  parentLineId?: number | null
  lineNumber?: number
  itemCode: string
  itemName: string
  quantity: number
  unit: string
  itemType: string
  isPhantomBool: boolean
  isRequiredBool: boolean
  isReplaceableBool: boolean
  replacementGroup: string
  minQty?: number
  maxQty?: number
  sortOrder?: number
}

const lineDialog = reactive({
  visible: false,
  isEdit: false,
  isChild: false,     // 是否为添加子行模式
  parentLine: null as SbomLine | null,
  submitting: false,
  form: {
    sbomLineId: undefined,
    sbomHeaderId: 0,
    parentLineId: null,
    lineNumber: 10,
    itemCode: '',
    itemName: '',
    quantity: 1,
    unit: 'PCS',
    itemType: 'PHYSICAL',
    isPhantomBool: false,
    isRequiredBool: false,
    isReplaceableBool: false,
    replacementGroup: '',
    minQty: undefined,
    maxQty: undefined,
    sortOrder: 0
  } as LineFormData
})

const lineDialogTitle = computed(() => {
  if (lineDialog.isEdit) return '编辑 BOM Line'
  if (lineDialog.isChild && lineDialog.parentLine) {
    return `添加子行（父物料：${lineDialog.parentLine.itemCode}）`
  }
  return '新增 BOM Line（根节点）'
})

const lineRules: FormRules = {
  itemCode: [{ required: true, message: '请输入物料编码', trigger: 'blur' }],
  itemName: [{ required: true, message: '请输入物料名称', trigger: 'blur' }],
  quantity: [{ required: true, message: '请输入用量', trigger: 'blur' }],
  unit: [{ required: true, message: '请输入单位', trigger: 'blur' }]
}

const lineFormRef = ref<FormInstance>()

const resetLineForm = () => {
  lineDialog.form = {
    sbomLineId: undefined,
    sbomHeaderId: selectedHeaderId.value!,
    parentLineId: null,
    lineNumber: 10,
    itemCode: '',
    itemName: '',
    quantity: 1,
    unit: 'PCS',
    itemType: 'PHYSICAL',
    isPhantomBool: false,
    isRequiredBool: false,
    isReplaceableBool: false,
    replacementGroup: '',
    minQty: undefined,
    maxQty: undefined,
    sortOrder: 0
  }
}

// 添加根节点行
const onAddRootLine = () => {
  lineDialog.isEdit = false
  lineDialog.isChild = false
  lineDialog.parentLine = null
  resetLineForm()
  lineDialog.form.parentLineId = null
  lineDialog.visible = true
}

// 添加子行
const onAddLine = (row: SbomLine) => {
  lineDialog.isEdit = false
  lineDialog.isChild = true
  lineDialog.parentLine = row
  resetLineForm()
  lineDialog.form.parentLineId = row.sbomLineId!
  lineDialog.visible = true
}

// 编辑行
const onEditLine = (row: SbomLine) => {
  lineDialog.isEdit = true
  lineDialog.isChild = false
  lineDialog.parentLine = null
  lineDialog.form = {
    sbomLineId: row.sbomLineId,
    sbomHeaderId: selectedHeaderId.value!,
    parentLineId: row.parentLineId || null,
    lineNumber: row.lineNumber || 10,
    itemCode: row.itemCode,
    itemName: row.itemName,
    quantity: row.quantity,
    unit: row.unit,
    itemType: row.itemType,
    isPhantomBool: row.isPhantom === 'Y',
    isRequiredBool: row.isRequired === 'Y',
    isReplaceableBool: row.isReplaceable === 'Y',
    replacementGroup: row.replacementGroup || '',
    minQty: row.minQty,
    maxQty: row.maxQty,
    sortOrder: row.sortOrder || 0
  }
  lineDialog.visible = true
}

// 删除行
const onDeleteLine = async (row: SbomLine) => {
  try {
    await ElMessageBox.confirm(
      `确定删除 BOM Line「${row.itemCode} - ${row.itemName}」吗？该操作会级联删除所有子行。`,
      '删除确认',
      { confirmButtonText: '确定删除', cancelButtonText: '取消', type: 'warning' }
    )
  } catch { return }
  lineDialog.submitting = true
  try {
    await deleteSbomLine(row.sbomLineId!)
    ElMessage.success('删除成功')
    await loadBomTree()
  } finally {
    lineDialog.submitting = false
  }
}

// 提交 Line 表单
const submitLine = async () => {
  const valid = await lineFormRef.value?.validate().catch(() => false)
  if (!valid) return
  lineDialog.submitting = true
  try {
    const f = lineDialog.form
    const payload: SbomLine = {
      sbomHeaderId: f.sbomHeaderId,
      parentLineId: f.parentLineId || null,
      lineNumber: f.lineNumber || 10,
      itemCode: f.itemCode,
      itemName: f.itemName,
      quantity: f.quantity,
      unit: f.unit,
      itemType: f.itemType,
      isPhantom: f.isPhantomBool ? 'Y' : 'N',
      isRequired: f.isRequiredBool ? 'Y' : 'N',
      isReplaceable: f.isReplaceableBool ? 'Y' : 'N',
      replacementGroup: f.replacementGroup || undefined,
      minQty: f.minQty,
      maxQty: f.maxQty,
      sortOrder: f.sortOrder || 0
    }
    if (lineDialog.isEdit && f.sbomLineId) {
      await editSbomLine({ ...payload, sbomLineId: f.sbomLineId } as SbomLine)
      ElMessage.success('修改成功')
    } else {
      await addSbomLine(payload)
      ElMessage.success('新增成功')
    }
    lineDialog.visible = false
    await loadBomTree()
  } finally {
    lineDialog.submitting = false
  }
}
</script>

<style scoped lang="scss">
.bom-manager {
  .page-header {
    margin-bottom: 16px;
    h2 { font-size: 20px; font-weight: 600; margin: 0 0 2px; }
    .subtitle { font-size: 13px; color: var(--cpq-text-secondary, #909399); margin: 0; }
  }
}

.mb-card { margin-bottom: 16px; }

.header-card {
  .card-header-row {
    display: flex; align-items: center; justify-content: space-between;
    font-weight: 600; font-size: 14px;
  }
  .empty-hint { text-align: center; padding: 24px 0; color: #909399; font-size: 13px; }
}

.header-item {
  padding: 10px 12px;
  border-bottom: 1px solid #ebeef5;
  cursor: pointer;
  transition: background .2s;
  position: relative;
  &:hover { background: #f5f7fa; }
  &.active { background: #ecf5ff; border-left: 3px solid #409eff; padding-left: 9px; }
  .header-name {
    font-weight: 500; font-size: 14px; margin-bottom: 4px;
    .version-tag {
      display: inline-block; background: #409eff; color: #fff; padding: 1px 6px;
      border-radius: 3px; font-size: 11px; margin-right: 6px;
    }
  }
  .header-meta { margin-bottom: 2px; }
  .header-actions {
    position: absolute; top: 6px; right: 4px; opacity: 0; transition: opacity .2s;
  }
  &:hover .header-actions { opacity: 1; }
}

.bom-card {
  .card-header-row {
    display: flex; align-items: center; justify-content: space-between;
    font-weight: 600; font-size: 14px;
    span { white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
    > div { display: flex; gap: 8px; }
  }
}
</style>
