<template>
  <div class="app-container">
    <el-form :model="queryParams" ref="queryRef" :inline="true" v-show="showSearch">
      <el-form-item label="报价单号" prop="quoteNumber"><el-input v-model="queryParams.quoteNumber" placeholder="请输入报价单号" clearable @keyup.enter="handleQuery" /></el-form-item>
      <el-form-item label="状态" prop="status"><el-select v-model="queryParams.status" placeholder="请选择状态" clearable><el-option v-for="s in statusOptions" :key="s.value" :label="s.label" :value="s.value" /></el-select></el-form-item>
      <el-form-item><el-button type="primary" icon="Search" @click="handleQuery">搜索</el-button><el-button icon="Refresh" @click="reset">重置</el-button></el-form-item>
    </el-form>
    <el-row :gutter="10" class="mb8">
      <el-col :span="1.5"><el-button type="primary" plain icon="Plus" @click="handleAdd" v-hasPermi="['cpq:quoting:create']">新增</el-button></el-col>
      <right-toolbar v-model:showSearch="showSearch" @queryTable="getList" />
    </el-row>
    <el-table v-loading="loading" :data="list" @selection-change="handleSelectionChange">
      <el-table-column type="selection" width="55" align="center" />
      <el-table-column label="报价单号" prop="quoteNumber" :show-overflow-tooltip="true" width="160" />
      <el-table-column label="客户" prop="accountId" width="120" />
      <el-table-column label="报价类型" prop="quoteType" width="100" />
      <el-table-column label="状态" prop="status" width="100"><template #default="scope"><el-tag :type="statusTagType(scope.row.status)">{{ scope.row.status }}</el-tag></template></el-table-column>
      <el-table-column label="总金额" prop="totalAmount" width="120" />
      <el-table-column label="创建时间" prop="createTime" width="160" />
      <el-table-column label="操作" align="center" width="180" fixed="right">
        <template #default="scope">
          <el-button link type="primary" icon="View" @click="handleView(scope.row)">查看</el-button>
          <el-button link type="primary" icon="Edit" @click="handleUpdate(scope.row)" v-hasPermi="['cpq:quoting:create']">编辑</el-button>
          <el-button link type="primary" icon="Delete" @click="handleDelete(scope.row)" v-hasPermi="['cpq:quoting:create']">删除</el-button>
        </template>
      </el-table-column>
    </el-table>
    <pagination v-show="total>0" :total="total" v-model:page="queryParams.pageNum" v-model:limit="queryParams.pageSize" @pagination="getList" />
    <!-- 新增/编辑弹窗 -->
    <el-dialog :title="dialogTitle" v-model="dialogVisible" width="600px" append-to-body>
      <el-form ref="formRef" :model="form" :rules="rules" label-width="100px">
        <el-form-item label="报价单号" prop="quoteNumber"><el-input v-model="form.quoteNumber" placeholder="自动生成" disabled /></el-form-item>
        <el-form-item label="报价类型" prop="quoteType"><el-select v-model="form.quoteType" placeholder="请选择"><el-option label="标准报价" value="STANDARD" /><el-option label="快速报价" value="QUICK" /></el-select></el-form-item>
        <el-form-item label="客户ID" prop="accountId"><el-input-number v-model="form.accountId" placeholder="请输入客户ID" :min="1" /></el-form-item>
      </el-form>
      <template #footer><el-button @click="dialogVisible=false">取消</el-button><el-button type="primary" @click="submitForm">确定</el-button></template>
    </el-dialog>
  </div>
</template>
<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { listQuote, getQuote, addQuote, updateQuote, delQuote } from '@/api/cpq/quote'
import { ElMessage, ElMessageBox } from 'element-plus'

const loading = ref(false), showSearch = ref(true), total = ref(0)
const list = ref<any[]>([]), ids = ref<number[]>([])
const dialogVisible = ref(false), dialogTitle = ref('')
const queryParams = reactive({ pageNum: 1, pageSize: 10, quoteNumber: '', status: '' })
const form = reactive<any>({ quoteId: undefined, quoteNumber: '', quoteType: 'STANDARD', accountId: undefined, status: 'DRAFT' })
const rules = { quoteType: [{ required: true, message: '请选择报价类型', trigger: 'change' }], accountId: [{ required: true, message: '请输入客户ID', trigger: 'blur' }] }
const statusOptions = [{ label: '草稿', value: 'DRAFT' }, { label: '待审批', value: 'PENDING_APPROVAL' }, { label: '已审批', value: 'APPROVED' }, { label: '已关闭', value: 'CLOSED' }, { label: '已取消', value: 'CANCELLED' }]
const statusTagType = (s: string) => s === 'DRAFT' ? 'info' : s === 'APPROVED' ? 'success' : s === 'CLOSED' ? 'danger' : 'warning'

const getList = async () => { loading.value = true; try { const res = await listQuote(queryParams); list.value = res.rows; total.value = res.total } finally { loading.value = false } }
const reset = () => { queryParams.quoteNumber = ''; queryParams.status = ''; handleQuery() }
const handleQuery = () => { queryParams.pageNum = 1; getList() }
const handleSelectionChange = (sel: any[]) => { ids.value = sel.map(i => i.quoteId) }
const handleAdd = () => { dialogTitle.value = '新增报价'; Object.assign(form, { quoteId: undefined, quoteNumber: '', quoteType: 'STANDARD', accountId: undefined, status: 'DRAFT' }); dialogVisible.value = true }
const handleUpdate = async (row: any) => { dialogTitle.value = '编辑报价'; const res = await getQuote(row.quoteId); Object.assign(form, res.data); dialogVisible.value = true }
const handleView = (row: any) => { ElMessage.info('查看报价单: ' + row.quoteNumber) }
const submitForm = async () => { if (form.quoteId) { await updateQuote(form); ElMessage.success('修改成功') } else { await addQuote(form); ElMessage.success('新增成功') } dialogVisible.value = false; getList() }
const handleDelete = async (row: any) => { await ElMessageBox.confirm('确认删除该报价单?', '警告', { type: 'warning' }); await delQuote(row.quoteId); ElMessage.success('删除成功'); getList() }
onMounted(getList)
</script>
