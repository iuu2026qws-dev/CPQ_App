<template>
  <div class="cpq-page">
    <div class="search-bar">
      <el-input v-model="searchForm.accountName" placeholder="客户名称" clearable style="width: 200px" @keyup.enter="handleSearch" />
      <el-input v-model="searchForm.accountCode" placeholder="客户编码" clearable style="width: 180px" @keyup.enter="handleSearch" />
      <el-select v-model="searchForm.accountType" placeholder="类型" clearable style="width: 140px">
        <el-option label="企业客户" value="ENTERPRISE" />
        <el-option label="个人客户" value="INDIVIDUAL" />
        <el-option label="合作伙伴" value="PARTNER" />
      </el-select>
      <el-select v-model="searchForm.industry" placeholder="行业" clearable style="width: 150px">
        <el-option label="金融" value="金融" />
        <el-option label="制造" value="制造" />
        <el-option label="科技" value="科技" />
        <el-option label="零售" value="零售" />
        <el-option label="医疗" value="医疗" />
        <el-option label="教育" value="教育" />
      </el-select>
      <el-button type="primary" @click="handleSearch">搜索</el-button>
      <el-button @click="resetSearch">重置</el-button>
    </div>
    <div class="toolbar">
      <el-button type="primary" @click="handleCreate">+ 新增客户</el-button>
      <el-button @click="loadData">刷新</el-button>
    </div>
    <el-table v-loading="loading" :data="tableData" stripe>
      <el-table-column prop="accountName" label="客户名称" min-width="160">
        <template #default="{ row }">
          <el-link type="primary" @click="handleView(row)">{{ row.accountName }}</el-link>
        </template>
      </el-table-column>
      <el-table-column prop="accountCode" label="编码" width="130" />
      <el-table-column prop="accountType" label="类型" width="100" />
      <el-table-column prop="industry" label="行业" width="100" />
      <el-table-column prop="contactName" label="联系人" width="100" />
      <el-table-column prop="contactPhone" label="电话" width="140" />
      <el-table-column label="操作" width="180" fixed="right">
        <template #default="{ row }">
          <el-button size="small" @click="handleEdit(row)">编辑</el-button>
          <el-button size="small" type="danger" @click="handleDelete(row)">删除</el-button>
        </template>
      </el-table-column>
    </el-table>
    <el-pagination
      v-model:current-page="pageNum"
      v-model:page-size="pageSize"
      :total="total"
      layout="total, prev, pager, next"
      style="margin-top: 16px"
      @change="loadData"
    />

    <el-dialog v-model="dialogVisible" :title="dialogTitle" width="600px" @close="resetForm">
      <el-form ref="formRef" :model="form" :rules="rules" label-width="120px">
        <el-divider content-position="left">基本信息</el-divider>
        <el-form-item label="客户名称" prop="accountName">
          <el-input v-model="form.accountName" placeholder="请输入客户名称" maxlength="200" />
        </el-form-item>
        <el-form-item label="客户编码" prop="accountCode">
          <el-input v-model="form.accountCode" placeholder="请输入客户编码" maxlength="50" />
        </el-form-item>
        <el-form-item label="客户类型">
          <el-select v-model="form.accountType" placeholder="请选择客户类型" style="width: 100%">
            <el-option label="企业客户" value="ENTERPRISE" />
            <el-option label="个人客户" value="INDIVIDUAL" />
            <el-option label="合作伙伴" value="PARTNER" />
          </el-select>
        </el-form-item>
        <el-form-item label="行业">
          <el-select v-model="form.industry" placeholder="请选择行业" style="width: 100%">
            <el-option label="金融" value="金融" />
            <el-option label="制造" value="制造" />
            <el-option label="科技" value="科技" />
            <el-option label="零售" value="零售" />
            <el-option label="医疗" value="医疗" />
            <el-option label="教育" value="教育" />
          </el-select>
        </el-form-item>
        <el-form-item label="区域">
          <el-input v-model="form.region" placeholder="请输入区域" />
        </el-form-item>
        <el-divider content-position="left">企业信息</el-divider>
        <el-form-item label="法人代表">
          <el-input v-model="form.legalRepresentative" placeholder="请输入法人代表" />
        </el-form-item>
        <el-form-item label="统一社会信用代码">
          <el-input v-model="form.unifiedSocialCreditCode" placeholder="18位统一社会信用代码" maxlength="18" />
        </el-form-item>
        <el-form-item label="地址">
          <el-input v-model="form.address" placeholder="请输入地址" />
        </el-form-item>
        <el-form-item label="税号">
          <el-input v-model="form.taxId" placeholder="请输入税号" />
        </el-form-item>
        <el-divider content-position="left">联系信息</el-divider>
        <el-form-item label="联系人">
          <el-input v-model="form.contactName" placeholder="请输入联系人" />
        </el-form-item>
        <el-form-item label="联系电话">
          <el-input v-model="form.contactPhone" placeholder="请输入联系电话" />
        </el-form-item>
        <el-form-item label="联系邮箱">
          <el-input v-model="form.contactEmail" placeholder="请输入联系邮箱" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" @click="handleSubmit">确定</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage, ElMessageBox, type FormInstance, type FormRules } from 'element-plus'
import { listAccounts, addAccount, updateAccount, delAccount, type AccountVo, type AccountBo } from '@/api/cpq/crm'

const router = useRouter()
const loading = ref(false)
const tableData = ref<AccountVo[]>([])
const pageNum = ref(1)
const pageSize = ref(10)
const total = ref(0)
const dialogVisible = ref(false)
const dialogTitle = ref('新增客户')
const formRef = ref<FormInstance>()

const searchForm = reactive({ accountName: '', accountCode: '', accountType: '', industry: '' })
const form = reactive<AccountBo>({
  accountName: '',
  accountCode: '',
  accountType: 'ENTERPRISE',
  industry: '',
  region: '',
  legalRepresentative: '',
  unifiedSocialCreditCode: '',
  contactName: '',
  contactPhone: '',
  contactEmail: '',
  address: '',
  taxId: ''
})

const validateCode = (_rule: any, value: string, callback: any) => {
  if (!value) { callback(new Error('请输入客户编码')); return }
  if (!/^[a-zA-Z0-9]+$/.test(value)) { callback(new Error('客户编码只能包含字母和数字')); return }
  callback()
}

const rules: FormRules = {
  accountName: [{ required: true, message: '请输入客户名称', trigger: 'blur' }, { min: 1, max: 200, message: '长度在 1 到 200 个字符', trigger: 'blur' }],
  accountCode: [{ required: true, validator: validateCode, trigger: 'blur' }]
}

async function loadData() {
  loading.value = true
  try {
    const params: Record<string, unknown> = { pageNum: pageNum.value, pageSize: pageSize.value }
    if (searchForm.accountName) params.accountName = searchForm.accountName
    if (searchForm.accountCode) params.accountCode = searchForm.accountCode
    if (searchForm.accountType) params.accountType = searchForm.accountType
    if (searchForm.industry) params.industry = searchForm.industry
    const res = await listAccounts(params)
    tableData.value = res.rows || []
    total.value = res.total || 0
  } catch (e: any) {
    ElMessage.error(e?.message || '加载失败')
  } finally {
    loading.value = false
  }
}

function handleSearch() { pageNum.value = 1; loadData() }
function resetSearch() { searchForm.accountName = ''; searchForm.accountCode = ''; searchForm.accountType = ''; searchForm.industry = ''; handleSearch() }
function handleView(row: AccountVo) { router.push('/crm/account/' + row.accountId) }

function handleCreate() {
  dialogTitle.value = '新增客户'
  Object.assign(form, { accountId: undefined, accountName: '', accountCode: '', accountType: 'ENTERPRISE', industry: '', region: '', legalRepresentative: '', unifiedSocialCreditCode: '', contactName: '', contactPhone: '', contactEmail: '', address: '', taxId: '' })
  dialogVisible.value = true
}

function handleEdit(row: AccountVo) {
  dialogTitle.value = '编辑客户'
  Object.assign(form, {
    accountId: row.accountId,
    accountName: row.accountName,
    accountCode: row.accountCode,
    accountType: row.accountType || 'ENTERPRISE',
    industry: row.industry || '',
    region: row.region || '',
    legalRepresentative: row.legalRepresentative || '',
    unifiedSocialCreditCode: row.unifiedSocialCreditCode || '',
    contactName: row.contactName || '',
    contactPhone: row.contactPhone || '',
    contactEmail: row.contactEmail || '',
    address: row.address || '',
    taxId: row.taxId || ''
  })
  dialogVisible.value = true
}

async function handleDelete(row: AccountVo) {
  try {
    await ElMessageBox.confirm('确定删除客户 "' + row.accountName + '" 吗？', '提示', { type: 'warning' })
    await delAccount(row.accountId)
    ElMessage.success('删除成功')
    loadData()
  } catch (e: any) {
    if (e !== 'cancel') ElMessage.error(e?.message || '删除失败')
  }
}

async function handleSubmit() {
  if (!formRef.value) return
  await formRef.value.validate(async (valid) => {
    if (!valid) return
    try {
      if (form.accountId) {
        await updateAccount(form)
        ElMessage.success('修改成功')
      } else {
        await addAccount(form)
        ElMessage.success('新增成功')
      }
      dialogVisible.value = false
      loadData()
    } catch (e: any) {
      ElMessage.error(e?.message || '操作失败')
    }
  })
}

function resetForm() {
  Object.assign(form, { accountId: undefined, accountName: '', accountCode: '', accountType: 'ENTERPRISE' })
  formRef.value?.resetFields()
}

onMounted(() => loadData())
</script>

<style scoped>
.cpq-page { padding: 16px; }
.search-bar { display: flex; gap: 12px; align-items: center; margin-bottom: 12px; flex-wrap: wrap; }
.toolbar { margin-bottom: 12px; display: flex; gap: 8px; }
</style>
