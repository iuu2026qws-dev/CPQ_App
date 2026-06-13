<template>
  <div class="app-container">
    <el-tabs v-model="activeTab" @tab-click="handleTabClick">
      <el-tab-pane label="待我审批" name="pending"><el-table v-loading="loading" :data="list"><el-table-column label="审批编号" prop="recordId" width="100" /><el-table-column label="标题" prop="title" /><el-table-column label="发起人" prop="submitter" width="120" /><el-table-column label="状态" prop="status" width="100" /><el-table-column label="提交时间" prop="createTime" width="160" /><el-table-column label="操作" width="180" fixed="right"><template #default="scope"><el-button link type="primary" @click="handleApprove(scope.row)">通过</el-button><el-button link type="danger" @click="handleReject(scope.row)">驳回</el-button></template></el-table-column></el-table><pagination v-show="total>0" :total="total" v-model:page="queryParams.pageNum" v-model:limit="queryParams.pageSize" @pagination="getList" /></el-tab-pane>
      <el-tab-pane label="我已审批" name="processed"><el-table v-loading="loading" :data="list"><el-table-column label="审批编号" prop="recordId" width="100" /><el-table-column label="标题" prop="title" /><el-table-column label="审批结果" prop="result" width="100"><template #default="scope"><el-tag :type="scope.row.result==='APPROVED'?'success':'danger'">{{scope.row.result}}</el-tag></template></el-table-column><el-table-column label="审批时间" prop="createTime" width="160" /></el-table><pagination v-show="total>0" :total="total" v-model:page="queryParams.pageNum" v-model:limit="queryParams.pageSize" @pagination="getList" /></el-tab-pane>
      <el-tab-pane label="我发起的" name="initiated"><el-table v-loading="loading" :data="list"><el-table-column label="审批编号" prop="recordId" width="100" /><el-table-column label="标题" prop="title" /><el-table-column label="当前状态" prop="status" width="100" /><el-table-column label="提交时间" prop="createTime" width="160" /></el-table><pagination v-show="total>0" :total="total" v-model:page="queryParams.pageNum" v-model:limit="queryParams.pageSize" @pagination="getList" /></el-tab-pane>
    </el-tabs>
  </div>
</template>
<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { listApproval, processApproval } from '@/api/cpq/approval'
import { ElMessage, ElMessageBox } from 'element-plus'
const loading=ref(false), total=ref(0), list=ref<any[]>([]), activeTab=ref('pending')
const queryParams=reactive({pageNum:1,pageSize:10,status:'pending'})
const getList=async()=>{loading.value=true;try{const res=await listApproval(queryParams);list.value=res.rows;total.value=res.total}finally{loading.value=false}}
const handleTabClick=(tab:any)=>{queryParams.status=tab.paneName==='pending'?'PENDING':tab.paneName==='processed'?'PROCESSED':'INITIATED';queryParams.pageNum=1;getList()}
const handleApprove=async(row:any)=>{await processApproval({recordId:row.recordId,action:'APPROVE'});ElMessage.success('已通过');getList()}
const handleReject=async(row:any)=>{const r=await ElMessageBox.prompt('请输入驳回原因','驳回',{type:'warning'});await processApproval({recordId:row.recordId,action:'REJECT',comment:r.value});ElMessage.success('已驳回');getList()}
onMounted(getList)
</script>
