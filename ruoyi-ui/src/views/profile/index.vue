<template>
  <div class="profile-page">
    <el-card>
      <template #header><span>个人中心</span></template>
      <div v-if="userStore.userInfo" class="profile-content">
        <el-descriptions :column="2" border>
          <el-descriptions-item label="用户名称">{{ userStore.userInfo.user.nickName || userStore.userInfo.user.userName }}</el-descriptions-item>
          <el-descriptions-item label="手机号码">{{ userStore.userInfo.user.phonenumber || '-' }}</el-descriptions-item>
          <el-descriptions-item label="邮箱">{{ userStore.userInfo.user.email || '-' }}</el-descriptions-item>
          <el-descriptions-item label="部门">{{ userStore.userInfo.user.deptName || '-' }}</el-descriptions-item>
          <el-descriptions-item label="角色" :span="2">{{ userStore.roles.join(', ') || '-' }}</el-descriptions-item>
        </el-descriptions>
      </div>
      <el-empty v-else description="暂无用户信息" />
    </el-card>
  </div>
</template>

<script setup lang="ts">
import { useUserStore } from '@/store/user'

const userStore = useUserStore()
</script>

<style scoped>
.profile-page {
  max-width: 800px;
  margin: 0 auto;
}
</style>
