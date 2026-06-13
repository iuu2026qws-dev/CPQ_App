<template>
  <div class="app-container">
    <el-card><template #header>方案对比分析</template>
    <el-row :gutter="20">
      <el-col :span="12"><el-select v-model="leftId" placeholder="选择方案A" filterable style="width:100%"><el-option v-for="s in solutions" :key="s.documentId" :label="s.documentName" :value="s.documentId" /></el-select></el-col>
      <el-col :span="12"><el-select v-model="rightId" placeholder="选择方案B" filterable style="width:100%"><el-option v-for="s in solutions" :key="s.documentId" :label="s.documentName" :value="s.documentId" /></el-select></el-col>
    </el-row>
    <el-divider />
    <el-table :data="compareData" v-if="leftId && rightId"><el-table-column prop="field" label="对比项" width="160" /><el-table-column prop="left" label="方案A" /><el-table-column prop="right" label="方案B" /></el-table>
    <el-empty v-else description="请选择两个方案进行对比" />
    </el-card>
  </div>
</template>
<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { listSolution } from '@/api/cpq/solution'
const solutions=ref<any[]>([]), leftId=ref(null), rightId=ref(null)
const compareData=ref([{field:'报价总额',left:'--',right:'--'},{field:'产品数量',left:'--',right:'--'},{field:'折扣率',left:'--',right:'--'}])
onMounted(async()=>{const res=await listSolution({pageNum:1,pageSize:100});solutions.value=res.rows})
</script>
