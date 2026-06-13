<template>
  <div class="delivery-timeline">
    <h4 style="margin:0 0 12px;font-size:14px">交期里程碑</h4>
    <div class="timeline-track">
      <div v-for="(m, i) in milestones" :key="i" class="milestone" :class="m.status.toLowerCase()">
        <div class="milestone-node">
          <span class="node-dot"></span>
          <span v-if="i < milestones.length - 1" class="node-connector"></span>
        </div>
        <div class="milestone-info">
          <div class="milestone-name">{{ m.name }}</div>
          <div class="milestone-day">第{{ m.dayOffset }}天</div>
          <el-tag :type="tagType(m.status)" size="small">{{ statusLabel(m.status) }}</el-tag>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import type { CtpMilestone } from '@/api/atpctp'

defineProps<{ milestones: CtpMilestone[] }>()
function tagType(s: string) { const m: Record<string, string> = { ON_TRACK: 'success', AT_RISK: 'warning', DELAYED: 'danger' }; return m[s] || 'info' }
function statusLabel(s: string) { const m: Record<string, string> = { ON_TRACK: '正常', AT_RISK: '风险', DELAYED: '延迟' }; return m[s] || s }
</script>

<style scoped>
.delivery-timeline { padding:12px; background:#fafafa; border-radius:8px; }
.timeline-track { display:flex; align-items:flex-start; overflow-x:auto; padding-bottom:8px; }
.milestone { flex:1; min-width:100px; text-align:center; position:relative; }
.milestone-node { display:flex; align-items:center; justify-content:center; margin-bottom:8px; position:relative; }
.node-dot { width:16px; height:16px; border-radius:50%; background:#409eff; z-index:1; }
.milestone.on_track .node-dot { background:#67c23a; }
.milestone.at_risk .node-dot { background:#e6a23c; }
.milestone.delayed .node-dot { background:#f56c6c; }
.node-connector { position:absolute; top:8px; left:50%; width:100%; height:2px; background:#dcdfe6; z-index:0; }
.milestone-info { font-size:12px; }
.milestone-name { font-weight:bold; color:#303133; margin-bottom:2px; }
.milestone-day { color:#909399; margin-bottom:4px; }
</style>
