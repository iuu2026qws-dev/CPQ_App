<template>
  <div class="app-container">
    <el-form :model="queryParams" :inline="true"><el-form-item label="方案名称"><el-input v-model="queryParams.documentName" placeholder="请输入" clearable @keyup.enter="getList" /></el-form-item><el-form-item><el-button type="primary" icon="Search" @click="getList">搜索</el-button></el-form-item></el-form>
    <el-row :gutter="10" class="mb8"><el-col :span="1.5"><el-button type="primary" icon="Plus" @click="handleAdd">新增方案</el-button></el-col></el-row>
    <el-table v-loading="loading" :data="list">
      <el-table-column label="方案名称" prop="documentName" /><el-table-column label="关联报价" prop="quoteId" /><el-table-column label="状态" prop="status" /><el-table-column label="创建时间" prop="createTime" width="160" />
      <el-table-column label="操作" width="180"><template #default="scope"><el-button link type="primary" icon="View" @click="handleView(scope.row)">查看</el-button><el-button link type="primary" icon="Edit" @click="handleEdit(scope.row)">编辑</el-button><el-button link type="primary" icon="Delete" @click="handleDelete(scope.row)">删除</el-button></template></el-table-column>
    </el-table>
    <pagination v-show="total>0" :total="total" v-model:page="queryParams.pageNum" v-model:limit="queryParams.pageSize" @pagination="getList" />
  </div>
</template>
<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { listSolution } from '@/api/cpq/solution'
import { ElMessage } from 'element-plus'
const loading=ref(false), total=ref(0), list=ref<any[]>([])
const queryParams=reactive({pageNum:1,pageSize:10,documentName:''})
const getList=async()=>{loading.value=true;try{const res=await listSolution(queryParams);list.value=res.rows;total.value=res.total}finally{loading.value=false}}
const handleAdd=()=>{ElMessage.info('方案创建功能开发中')}
const handleView=(row:any)=>{ElMessage.info('查看方案: '+row.documentName)}
const handleEdit=(row:any)=>{ElMessage.info('编辑方案功能开发中')}
const handleDelete=(row:any)=>{ElMessage.info('删除方案功能开发中')}
onMounted(getList)
</script>
