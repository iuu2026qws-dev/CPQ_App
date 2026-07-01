<template>
  <div>
    <el-timeline v-if="activities.length">
      <el-timeline-item
        v-for="item in sortedActivities"
        :key="item.activityId"
        :timestamp="item.activityDate + (item.activityTime ? ' ' + item.activityTime : '')"
        placement="top"
        :icon="typeIcon(item.activityType)"
        :color="typeColor(item.activityType)"
      >
        <el-card shadow="hover" size="small">
          <div style="display: flex; justify-content: space-between; align-items: flex-start">
            <div>
              <el-tag :type="typeTag(item.activityType)" size="small" style="margin-bottom: 4px">
                {{ typeLabel(item.activityType) }}
              </el-tag>
              <h4 style="margin: 4px 0">{{ item.subject }}</h4>
              <div v-if="item.duration" style="color: #909399; font-size: 12px">耗时: {{ item.duration }} 分钟</div>
              <div v-if="item.participants" style="color: #606266; font-size: 13px; margin-top: 4px">参与人: {{ item.participants }}</div>
              <div v-if="item.result" style="margin-top: 8px">
                <el-button type="primary" link size="small" @click="toggleExpand(item)">查看结果</el-button>
                <div v-if="expandedMap[item.activityId!]" style="background: #f5f7fa; padding: 8px; border-radius: 4px; margin-top: 4px; font-size: 13px; white-space: pre-wrap">
                  {{ item.result }}
                </div>
              </div>
              <div v-if="item.nextPlan" style="color: #67c23a; font-size: 13px; margin-top: 4px">
                下一步: {{ item.nextPlan }}
              </div>
            </div>
          </div>
        </el-card>
      </el-timeline-item>
    </el-timeline>
    <el-empty v-if="!activities.length" description="暂无活动记录" :image-size="80" />

    <!-- 新增活动对话框 -->
    <el-dialog v-model="showDialog" title="新增活动" width="500px" @close="resetActivityForm">
      <el-form ref="actFormRef" :model="activityForm" :rules="activityRules" label-width="80px">
        <el-form-item label="类型" prop="activityType">
          <el-select v-model="activityForm.activityType" style="width: 100%">
            <el-option label="电话" value="CALL" />
            <el-option label="会议" value="MEETING" />
            <el-option label="邮件" value="EMAIL" />
            <el-option label="拜访" value="VISIT" />
            <el-option label="演示" value="DEMO" />
            <el-option label="谈判" value="NEGOTIATION" />
            <el-option label="其他" value="OTHER" />
            <el-option label="系统" value="SYSTEM" />
          </el-select>
        </el-form-item>
        <el-form-item label="主题" prop="subject">
          <el-input v-model="activityForm.subject" placeholder="请输入活动主题" maxlength="200" />
        </el-form-item>
        <el-form-item label="日期" prop="activityDate">
          <el-date-picker v-model="activityForm.activityDate" type="date" style="width: 100%" value-format="YYYY-MM-DD" />
        </el-form-item>
        <el-form-item label="时间">
          <el-time-picker v-model="activityForm.activityTime" placeholder="选择时间" style="width: 100%" value-format="HH:mm" />
        </el-form-item>
        <el-form-item label="耗时(分)">
          <el-input-number v-model="activityForm.duration" :min="0" style="width: 100%" />
        </el-form-item>
        <el-form-item label="参与人">
          <el-input v-model="activityForm.participants" placeholder="参与人，多个用逗号分隔" />
        </el-form-item>
        <el-form-item label="结果">
          <el-input v-model="activityForm.result" type="textarea" placeholder="活动结果" :rows="3" />
        </el-form-item>
        <el-form-item label="下一步计划">
          <el-input v-model="activityForm.nextPlan" type="textarea" placeholder="下一步计划" :rows="2" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="showDialog = false">取消</el-button>
        <el-button type="primary" @click="submitActivity">确定</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, computed, watch } from 'vue'
import { ElMessage, type FormInstance, type FormRules } from 'element-plus'
import { addActivity, type ActivityVo, type ActivityBo } from '@/api/cpq/crm'

const props = defineProps<{
  activities: ActivityVo[]
  visible: boolean
  entityId?: number
  entityType?: string
}>()

const emit = defineEmits<{
  (e: 'update:visible', v: boolean): void
  (e: 'created'): void
}>()

const showDialog = ref(false)
const actFormRef = ref<FormInstance>()
const expandedMap = ref<Record<number, boolean>>({})

const sortedActivities = computed(() => {
  return [...props.activities].sort((a, b) => {
    return new Date(b.activityDate + ' ' + (b.activityTime || '00:00')).getTime() -
      new Date(a.activityDate + ' ' + (a.activityTime || '00:00')).getTime()
  })
})

const activityForm = reactive<ActivityBo>({
  activityType: 'CALL',
  subject: '',
  activityDate: '',
  activityTime: '',
  duration: 30,
  participants: '',
  result: '',
  nextPlan: ''
})

const activityRules: FormRules = {
  activityType: [{ required: true, message: '请选择类型', trigger: 'change' }],
  subject: [{ required: true, message: '请输入主题', trigger: 'blur' }],
  activityDate: [{ required: true, message: '请选择日期', trigger: 'change' }]
}

const iconMap: Record<string, string> = {
  CALL: 'Phone', MEETING: 'UserFilled', EMAIL: 'Message', VISIT: 'Location',
  DEMO: 'Monitor', NEGOTIATION: 'ChatDotRound', OTHER: 'MoreFilled', SYSTEM: 'Setting'
}
const colorMap: Record<string, string> = {
  CALL: '#409eff', MEETING: '#67c23a', EMAIL: '#e6a23c', VISIT: '#f56c6c',
  DEMO: '#909399', NEGOTIATION: '#9b59b6', OTHER: '#bdc3c7', SYSTEM: '#34495e'
}
const tagMap: Record<string, string> = {
  CALL: 'primary', MEETING: 'success', EMAIL: 'warning', VISIT: 'danger',
  DEMO: 'info', NEGOTIATION: '', OTHER: 'info', SYSTEM: 'info'
}
const labelMap: Record<string, string> = {
  CALL: '电话', MEETING: '会议', EMAIL: '邮件', VISIT: '拜访',
  DEMO: '演示', NEGOTIATION: '谈判', OTHER: '其他', SYSTEM: '系统'
}
function typeIcon(t: string) { return iconMap[t] || 'MoreFilled' }
function typeColor(t: string) { return colorMap[t] || '#909399' }
function typeTag(t: string) { return tagMap[t] || 'info' }
function typeLabel(t: string) { return labelMap[t] || t }

function toggleExpand(item: ActivityVo) {
  const id = item.activityId!
  expandedMap.value[id] = !expandedMap.value[id]
}

watch(() => props.visible, (v) => { showDialog.value = v })
watch(showDialog, (v) => { emit('update:visible', v) })

function resetActivityForm() {
  Object.assign(activityForm, {
    activityType: 'CALL', subject: '', activityDate: '', activityTime: '',
    duration: 30, participants: '', result: '', nextPlan: ''
  })
  actFormRef.value?.resetFields()
}

async function submitActivity() {
  if (!actFormRef.value) return
  await actFormRef.value.validate(async (valid) => {
    if (!valid) return
    try {
      const data: ActivityBo = { ...activityForm }
      if (props.entityType === 'opportunity') {
        data.opportunityId = props.entityId
      } else if (props.entityType === 'account') {
        data.accountId = props.entityId
      }
      await addActivity(data)
      ElMessage.success('活动添加成功')
      showDialog.value = false
      resetActivityForm()
      emit('created')
    } catch (e: any) {
      ElMessage.error(e?.message || '添加失败')
    }
  })
}
</script>
