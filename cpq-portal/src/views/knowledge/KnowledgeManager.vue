<template>
  <div class="knowledge-manager">
    <div class="page-header">
      <h2>知识库</h2>
      <p class="subtitle">产品知识、销售话术、成功案例与培训资料</p>
    </div>

    <div class="toolbar">
      <el-select v-model="searchType" placeholder="文章类型" clearable style="width: 140px">
        <el-option label="产品知识" value="PRODUCT" />
        <el-option label="销售话术" value="SCRIPT" />
        <el-option label="成功案例" value="CASE" />
        <el-option label="培训中心" value="TRAINING" />
      </el-select>
      <el-input v-model="searchTitle" placeholder="搜索标题" style="width: 240px; margin-left: 8px" clearable @keyup.enter="fetchList" />
      <el-button type="primary" style="margin-left: 8px" @click="fetchList">搜索</el-button>
      <el-button type="success" style="margin-left: auto" @click="handleAdd">新增文章</el-button>
    </div>

    <el-table :data="articleList" stripe v-loading="loading" empty-text="暂无数据">
      <el-table-column prop="articleId" label="ID" width="80" />
      <el-table-column prop="title" label="标题" min-width="200" />
      <el-table-column prop="articleType" label="类型" width="100">
        <template #default="{ row }">
          <el-tag size="small" :type="typeTag(row.articleType)">{{ typeLabel(row.articleType) }}</el-tag>
        </template>
      </el-table-column>
      <el-table-column prop="category" label="分类" width="110" />
      <el-table-column prop="tags" label="标签" width="140" />
      <el-table-column prop="viewCount" label="浏览量" width="90" />
      <el-table-column prop="status" label="状态" width="80">
        <template #default="{ row }">
          <el-tag :type="row.status === '0' ? 'success' : 'danger'" size="small">{{ row.status === '0' ? '发布' : '草稿' }}</el-tag>
        </template>
      </el-table-column>
      <el-table-column label="操作" width="150" fixed="right">
        <template #default="{ row }">
          <el-button size="small" @click="handleEdit(row)">编辑</el-button>
          <el-button size="small" type="danger" @click="handleDelete(row)">删除</el-button>
        </template>
      </el-table-column>
    </el-table>

    <el-dialog :title="isEdit ? '编辑文章' : '新增文章'" v-model="dialogVisible" width="700px">
      <el-form :model="form" label-width="90px">
        <el-form-item label="标题" required>
          <el-input v-model="form.title" placeholder="文章标题" />
        </el-form-item>
        <el-form-item label="类型">
          <el-select v-model="form.articleType">
            <el-option label="产品知识" value="PRODUCT" />
            <el-option label="销售话术" value="SCRIPT" />
            <el-option label="成功案例" value="CASE" />
            <el-option label="培训中心" value="TRAINING" />
          </el-select>
        </el-form-item>
        <el-form-item label="分类">
          <el-input v-model="form.category" placeholder="如：价格策略、技术选型" />
        </el-form-item>
        <el-form-item label="标签">
          <el-input v-model="form.tags" placeholder="用逗号分隔多个标签" />
        </el-form-item>
        <el-form-item label="内容" required>
          <el-input v-model="form.content" type="textarea" :rows="8" placeholder="Markdown格式内容" />
        </el-form-item>
        <el-form-item label="状态">
          <el-radio-group v-model="form.status">
            <el-radio label="0">发布</el-radio>
            <el-radio label="1">草稿</el-radio>
          </el-radio-group>
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" @click="handleSubmit" :loading="submitting">确定</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { getArticleList, addArticle, updateArticle, deleteArticle } from '@/api/cpq/knowledge'

const loading = ref(false), submitting = ref(false)
const articleList = ref<any[]>([])
const dialogVisible = ref(false), isEdit = ref(false)
const searchTitle = ref(''), searchType = ref('')
const form = ref<any>({ articleType: 'PRODUCT', status: '0' })

function typeLabel(t: string) { const m: Record<string, string> = { PRODUCT: '产品知识', SCRIPT: '销售话术', CASE: '成功案例', TRAINING: '培训中心' }; return m[t] || t }
function typeTag(t: string) { const m: Record<string, string> = { PRODUCT: '', SCRIPT: 'success', CASE: 'warning', TRAINING: 'info' }; return m[t] || '' }

async function fetchList() {
  loading.value = true
  try {
    const params: any = {}
    if (searchTitle.value) params.title = searchTitle.value
    if (searchType.value) params.articleType = searchType.value
    const res = await getArticleList(params)
    articleList.value = Array.isArray(res) ? res : res.data || []
  } catch { articleList.value = [] }
  finally { loading.value = false }
}

function handleAdd() { isEdit.value = false; form.value = { articleType: 'PRODUCT', status: '0' }; dialogVisible.value = true }
function handleEdit(row: any) { isEdit.value = true; form.value = { ...row }; dialogVisible.value = true }

async function handleSubmit() {
  submitting.value = true
  try {
    if (isEdit.value) await updateArticle(form.value)
    else await addArticle(form.value)
    ElMessage.success(isEdit.value ? '修改成功' : '新增成功')
    dialogVisible.value = false; fetchList()
  } catch { ElMessage.error('操作失败') }
  finally { submitting.value = false }
}

async function handleDelete(row: any) {
  try { await ElMessageBox.confirm('确认删除？', '提示', { type: 'warning' }); await deleteArticle(String(row.articleId)); ElMessage.success('删除成功'); fetchList() } catch { /* */ }
}

onMounted(fetchList)
</script>

<style scoped lang="scss">
.page-header { margin-bottom: 16px; h2 { margin: 0; } .subtitle { color: #909399; font-size: 13px; } }
.toolbar { display: flex; align-items: center; margin-bottom: 12px; }
</style>
