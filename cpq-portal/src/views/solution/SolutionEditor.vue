<template>
  <div class="cpq-page solution-editor">
    <!-- 顶部工具栏 -->
    <div class="editor-toolbar">
      <el-button-group>
        <el-button size="small" @click="handleSave">保存</el-button>
        <el-button size="small" @click="handlePreview">预览</el-button>
        <el-button size="small" type="warning" @click="handleSubmitReview">提交评审</el-button>
        <el-button size="small" @click="handleExport">导出</el-button>
      </el-button-group>
      <el-button-group style="margin-left:16px">
        <el-button size="small" :disabled="!canUndo" @click="undo">撤销</el-button>
        <el-button size="small" :disabled="!canRedo" @click="redo">重做</el-button>
      </el-button-group>
      <span style="margin-left:auto;font-size:13px;color:#909399">
        {{ doc?.documentName || '未命名方案' }} &nbsp;|&nbsp; V{{ doc?.version || 1 }}
      </span>
    </div>

    <!-- 四区布局 -->
    <div class="editor-layout">
      <!-- 左侧：模板章节导航 -->
      <div class="editor-sidebar">
        <h4>章节</h4>
        <div
          v-for="ch in chapters" :key="ch.id"
          class="chapter-item"
          :class="{ active: activeChapter === ch.id }"
          @click="activeChapter = ch.id"
        >
          <span class="chapter-status">{{ ch.status }}</span>
          {{ ch.title }}
        </div>
        <el-divider />
        <el-button size="small" @click="addChapter" style="width:100%">+ 添加章节</el-button>
      </div>

      <!-- 中间：编辑区 -->
      <div class="editor-main">
        <div class="editor-tabs">
          <el-radio-group v-model="editMode" size="small">
            <el-radio-button value="wysiwyg">所见即所得</el-radio-button>
            <el-radio-button value="markdown">Markdown</el-radio-button>
          </el-radio-group>
        </div>
        <!-- 富文本编辑区 -->
        <div v-if="editMode === 'wysiwyg'" class="rich-editor">
          <div class="format-bar">
            <el-button-group size="small">
              <el-button @click="execCmd('bold')"><b>B</b></el-button>
              <el-button @click="execCmd('italic')"><i>I</i></el-button>
              <el-button @click="execCmd('underline')"><u>U</u></el-button>
            </el-button-group>
            <el-select v-model="headingLevel" size="small" style="width:100px;margin-left:8px" @change="setHeading" placeholder="正文">
              <el-option label="正文" value="div" />
              <el-option label="标题1" value="h2" />
              <el-option label="标题2" value="h3" />
              <el-option label="标题3" value="h4" />
            </el-select>
            <el-button size="small" style="margin-left:8px" @click="execCmd('insertUnorderedList')">列表</el-button>
            <el-button size="small" @click="execCmd('insertOrderedList')">编号</el-button>
          </div>
          <div
            ref="editorRef"
            class="editor-content"
            contenteditable="true"
            @input="onEditorInput"
            @paste="onPaste"
          ></div>
        </div>
        <!-- Markdown 编辑区 -->
        <div v-else class="md-editor">
          <el-input
            v-model="mdContent"
            type="textarea"
            :rows="20"
            placeholder="使用 Markdown 编写方案..."
          />
        </div>
      </div>

      <!-- 右侧：配置数据面板 -->
      <div class="editor-panel">
        <h4>数据插入</h4>
        <el-button size="small" style="width:100%;margin-bottom:6px" @click="insertPlaceholder('config.paramTable')">插入参数表</el-button>
        <el-button size="small" style="width:100%;margin-bottom:6px" @click="insertPlaceholder('config.bomList')">插入BOM清单</el-button>
        <el-button size="small" style="width:100%;margin-bottom:6px" @click="insertPlaceholder('config.architectureDiagram')">插入架构图</el-button>
        <el-button size="small" style="width:100%;margin-bottom:6px" @click="insertPlaceholder('config.comparisonTable')">插入对比表</el-button>
        <el-button size="small" style="width:100%;margin-bottom:6px" @click="insertPlaceholder('config.caseReference')">插入案例引用</el-button>
        <el-divider />
        <h4>协同编辑</h4>
        <p style="font-size:12px;color:#909399">协作者将在此显示</p>
        <div v-if="collaborators.length === 0" style="color:#c0c4cc;font-size:12px">暂无协作者</div>
        <div v-for="c in collaborators" :key="c" class="collab-user">
          <span class="collab-dot" :style="{ background: collabColor(c) }"></span>
          {{ c }}
        </div>
        <el-divider />
        <el-input v-model="newCollab" size="small" placeholder="添加协作者" @keyup.enter="addCollaborator" />
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, nextTick } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { listSolution, updateSolution } from '@/api/quoting'
import type { SolutionVo } from '@/api/quoting'

const route = useRoute()
const router = useRouter()
const doc = ref<SolutionVo | null>(null)
const editMode = ref<'wysiwyg' | 'markdown'>('wysiwyg')
const editorRef = ref<HTMLDivElement>()
const mdContent = ref('')
const activeChapter = ref('ch1')
const headingLevel = ref('div')
const canUndo = ref(false)
const canRedo = ref(false)
const collaborators = ref<string[]>([])
const newCollab = ref('')

interface Chapter { id: string; title: string; status: string }
const chapters = ref<Chapter[]>([
  { id: 'ch1', title: '公司介绍', status: '✓' },
  { id: 'ch2', title: '需求理解', status: '✓' },
  { id: 'ch3', title: '技术方案', status: '◐' },
  { id: 'ch4', title: '实施计划', status: '○' },
  { id: 'ch5', title: '验收标准', status: '○' },
])

const collabColors = ['#409eff','#67c23a','#e6a23c','#f56c6c','#909399','#b37feb','#36cfc9','#ff85c0']
function collabColor(name: string) { return collabColors[collaborators.value.indexOf(name) % collabColors.length] }

function addCollaborator() {
  if (newCollab.value && !collaborators.value.includes(newCollab.value)) {
    collaborators.value.push(newCollab.value)
    newCollab.value = ''
  }
}

function execCmd(cmd: string) { document.execCommand(cmd, false); editorRef.value?.focus() }
function setHeading() { document.execCommand('formatBlock', false, `<${headingLevel.value}>`); editorRef.value?.focus() }
function onEditorInput() { /* 自动保存可由此触发 */ }
function onPaste(e: ClipboardEvent) { e.preventDefault(); const text = e.clipboardData?.getData('text/plain') || ''; document.execCommand('insertText', false, text) }
function insertPlaceholder(key: string) {
  const placeholder = `{{${key}}}`
  if (editMode.value === 'wysiwyg') {
    const sel = window.getSelection()
    if (sel?.rangeCount) {
      const range = sel.getRangeAt(0)
      range.deleteContents()
      const span = document.createElement('span')
      span.className = 'placeholder-tag'
      span.contentEditable = 'false'
      span.textContent = placeholder
      range.insertNode(span)
      range.collapse(false)
    }
  } else {
    mdContent.value += ` ${placeholder} `
  }
}

function undo() { document.execCommand('undo'); editorRef.value?.focus() }
function redo() { document.execCommand('redo'); editorRef.value?.focus() }

async function handleSave() {
  if (!doc.value) return
  const content = editMode.value === 'wysiwyg' ? editorRef.value?.innerHTML || '' : mdContent.value
  await updateSolution({ documentId: doc.value.documentId, documentContent: content, status: 'EDITING' })
  ElMessage.success('已保存')
}

function handlePreview() {
  const html = editMode.value === 'wysiwyg' ? editorRef.value?.innerHTML || '' : mdContent.value
  const win = window.open('', '_blank', 'width=900,height=700')
  if (win) {
    win.document.write(`<!DOCTYPE html><html><head><meta charset="UTF-8"><title>方案预览</title><style>body{font-family:'Microsoft YaHei',sans-serif;padding:40px;max-width:800px;margin:auto;line-height:1.8}</style></head><body>${html}</body></html>`)
    win.document.close()
  }
}

async function handleSubmitReview() {
  if (!doc.value) return
  await updateSolution({ documentId: doc.value.documentId, status: 'REVIEWING' })
  ElMessage.success('已提交评审')
  router.push(`/solution/${doc.value.documentId}/review`)
}

async function handleExport() {
  if (!doc.value) return
  const html = editMode.value === 'wysiwyg' ? editorRef.value?.innerHTML || '' : mdContent.value
  const blob = new Blob([`<!DOCTYPE html><html><head><meta charset="UTF-8"><title>${doc.value.documentName}</title></head><body>${html}</body></html>`], { type: 'text/html' })
  const url = URL.createObjectURL(blob)
  const a = document.createElement('a'); a.href = url; a.download = `${doc.value.documentName || '方案'}.html`; a.click(); URL.revokeObjectURL(url)
}

function addChapter() {
  const id = 'ch' + (chapters.value.length + 1)
  chapters.value.push({ id, title: '新章节', status: '○' })
}

async function loadDoc() {
  const id = Number(route.params.id)
  const res = await listSolution({ documentId: id })
  const rows = (res as any).rows || []
  if (rows.length > 0) {
    doc.value = rows[0]
    if (doc.value?.documentContent) {
      await nextTick()
      if (editorRef.value) editorRef.value.innerHTML = doc.value.documentContent
    }
  }
}

onMounted(() => loadDoc())
</script>

<style scoped>
.solution-editor { display:flex; flex-direction:column; height:calc(100vh - 120px); }
.editor-toolbar { display:flex; align-items:center; padding:8px 16px; background:#f5f7fa; border-bottom:1px solid #e4e7ed; flex-shrink:0; }
.editor-layout { display:flex; flex:1; overflow:hidden; }
.editor-sidebar { width:200px; padding:12px; border-right:1px solid #e4e7ed; overflow-y:auto; flex-shrink:0; }
.editor-sidebar h4 { margin:0 0 12px; font-size:14px; color:#303133; }
.chapter-item { padding:8px 10px; cursor:pointer; border-radius:4px; font-size:13px; margin-bottom:4px; display:flex; align-items:center; gap:6px; }
.chapter-item:hover { background:#ecf5ff; }
.chapter-item.active { background:#409eff; color:#fff; }
.chapter-status { font-size:12px; }
.editor-main { flex:1; display:flex; flex-direction:column; overflow:hidden; }
.editor-tabs { padding:8px 16px; border-bottom:1px solid #e4e7ed; }
.format-bar { display:flex; align-items:center; padding:8px 16px; border-bottom:1px solid #ebeef5; gap:4px; }
.rich-editor { flex:1; display:flex; flex-direction:column; overflow:hidden; }
.editor-content { flex:1; padding:16px; overflow-y:auto; outline:none; font-size:14px; line-height:1.8; }
.editor-content:empty::before { content:'在此编写方案内容...'; color:#c0c4cc; }
.md-editor { flex:1; padding:16px; }
.editor-panel { width:220px; padding:12px; border-left:1px solid #e4e7ed; overflow-y:auto; flex-shrink:0; }
.editor-panel h4 { margin:0 0 12px; font-size:14px; color:#303133; }
.collab-user { display:flex; align-items:center; gap:6px; font-size:12px; padding:4px 0; }
.collab-dot { width:10px; height:10px; border-radius:50%; }
:deep(.placeholder-tag) { background:#ecf5ff; color:#409eff; padding:2px 6px; border-radius:3px; font-size:12px; margin:0 2px; border:1px dashed #409eff; }
</style>
