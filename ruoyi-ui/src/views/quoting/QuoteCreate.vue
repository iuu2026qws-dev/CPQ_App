<template>
  <div class="app-container">
    <el-form ref="formRef" :model="form" label-width="120px">
      <el-form-item label="报价类型"><el-select v-model="form.quoteType"><el-option label="标准报价" value="STANDARD" /><el-option label="快速报价" value="QUICK" /></el-select></el-form-item>
      <el-form-item label="客户ID"><el-input-number v-model="form.accountId" :min="1" /></el-form-item>
      <el-form-item label="备注"><el-input v-model="form.remark" type="textarea" /></el-form-item>
      <el-form-item><el-button type="primary" @click="handleCreate">创建报价单</el-button><el-button @click="$router.push('/cpq/quoting/list')">返回列表</el-button></el-form-item>
    </el-form>
  </div>
</template>
<script setup lang="ts">
import { reactive } from 'vue'
import { addQuote } from '@/api/cpq/quote'
import { ElMessage } from 'element-plus'
import { useRouter } from 'vue-router'
const router = useRouter()
const form = reactive({ quoteType: 'STANDARD', accountId: undefined, remark: '' })
const handleCreate = async () => { await addQuote(form); ElMessage.success('报价单创建成功'); router.push('/cpq/quoting/list') }
</script>
