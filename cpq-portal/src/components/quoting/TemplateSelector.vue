<template>
  <el-dialog
    v-model="visible"
    title="选择报价模板"
    width="700px"
    destroy-on-close
  >
    <div class="template-grid">
      <el-card
        v-for="tpl in templates"
        :key="tpl.templateId"
        :class="['template-card', { selected: selectedId === tpl.templateId }]"
        shadow="hover"
        @click="selectedId = tpl.templateId!"
      >
        <div class="template-icon">
          <el-icon :size="36">
            <Document v-if="tpl.templateType === 'PDF' || tpl.templateType === 'DOCX'" />
            <Tickets v-else-if="tpl.templateType === 'STANDARD'" />
            <MagicStick v-else />
          </el-icon>
        </div>
        <div class="template-info">
          <h4>{{ tpl.templateName }}</h4>
          <div class="template-meta">
            <el-tag size="small" :type="tpl.templateType === 'PDF' ? 'danger' : tpl.templateType === 'STANDARD' ? 'primary' : 'warning'">
              {{ typeLabel(tpl.templateType) }}
            </el-tag>
            <el-tag v-if="tpl.isDefault === 'Y'" size="small" type="success">默认</el-tag>
          </div>
          <p class="template-preview-text">
            {{ tpl.templateType === 'STANDARD' ? '标准商务报价模板，含公司抬头、产品明细、金额汇总和条款说明。' : tpl.templateType === 'PDF' ? 'PDF 格式输出模板，适合正式商务场景，支持电子签章。' : tpl.templateType === 'DOCX' ? 'Word 可编辑模板，支持二次修改和自定义样式。' : '自定义模板，允许用户配置布局、颜色和字段。' }}
          </p>
        </div>
        <div v-if="selectedId === tpl.templateId" class="selected-badge">
          <el-icon :size="20"><CircleCheckFilled /></el-icon>
        </div>
      </el-card>
    </div>

    <el-empty v-if="templates.length === 0" description="暂无可用模板" />

    <template #footer>
      <el-button @click="visible = false">取消</el-button>
      <el-button type="primary" :disabled="!selectedId" @click="handleConfirm">确认选择</el-button>
    </template>
  </el-dialog>
</template>

<script setup lang="ts">
import { ref, watch, onMounted } from 'vue'
import { Document, Tickets, MagicStick, CircleCheckFilled } from '@element-plus/icons-vue'
import { listTemplate, type TemplateVo } from '@/api/quoting'

const props = defineProps<{ modelValue: boolean }>()
const emit = defineEmits<{
  'update:modelValue': [v: boolean]
  'select': [template: TemplateVo]
}>()

const visible = ref(props.modelValue)
watch(() => props.modelValue, v => { visible.value = v })
watch(visible, v => { emit('update:modelValue', v) })

const templates = ref<TemplateVo[]>([])
const selectedId = ref<string | null>(null)

function typeLabel(t: string) {
  const m: Record<string, string> = { PDF: 'PDF', DOCX: 'Word', STANDARD: '标准', CUSTOM: '自定义' }
  return m[t] || t
}

function handleConfirm() {
  const tpl = templates.value.find(t => t.templateId === selectedId.value)
  if (tpl) {
    emit('select', tpl)
    visible.value = false
  }
}

onMounted(async () => {
  try {
    const res = await listTemplate()
    templates.value = Array.isArray(res) ? res : ((res as any).rows || [])
    // 默认选中默认模板
    const def = templates.value.find(t => t.isDefault === 'Y')
    if (def) selectedId.value = def.templateId!
    else if (templates.value.length > 0) selectedId.value = templates.value[0].templateId!
  } catch { /* ignore */ }
})
</script>

<style scoped>
.template-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 16px; }
.template-card { cursor: pointer; position: relative; transition: all 0.2s; border: 2px solid transparent; }
.template-card:hover { border-color: #409eff; }
.template-card.selected { border-color: #409eff; background: #ecf5ff; }
.template-icon { text-align: center; margin-bottom: 8px; color: #409eff; }
.template-info h4 { margin: 0 0 8px; font-size: 15px; }
.template-meta { display: flex; gap: 6px; margin-bottom: 8px; }
.template-preview-text { color: #909399; font-size: 12px; line-height: 1.5; margin: 0; }
.selected-badge { position: absolute; top: 8px; right: 8px; color: #409eff; }
</style>
