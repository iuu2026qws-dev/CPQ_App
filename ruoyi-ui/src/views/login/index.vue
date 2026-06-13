<template>
  <div class="login-wrapper">
    <div class="login-card">
      <div class="login-header">
        <h1>SmartCPQ</h1>
        <p>制造业智能配置报价系统</p>
      </div>
      <el-form ref="formRef" :model="loginForm" :rules="rules" size="large" @keyup.enter="handleLogin">
        <el-form-item prop="tenantId">
          <el-select v-model="loginForm.tenantId" placeholder="请选择租户" style="width:100%">
            <el-option label="默认租户 (000000)" value="000000" />
          </el-select>
        </el-form-item>
        <el-form-item prop="username">
          <el-input v-model="loginForm.username" placeholder="用户名" :prefix-icon="UserFilled" />
        </el-form-item>
        <el-form-item prop="password">
          <el-input v-model="loginForm.password" type="password" placeholder="密码" show-password :prefix-icon="Lock" />
        </el-form-item>
        <el-form-item>
          <el-button type="primary" :loading="loading" style="width:100%" @click="handleLogin">登 录</el-button>
        </el-form-item>
      </el-form>
    </div>
  </div>
</template>

<script setup lang="ts">
import { reactive, ref } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { UserFilled, Lock } from '@element-plus/icons-vue'
import { useUserStore } from '@/store/user'

const router = useRouter()
const userStore = useUserStore()
const loading = ref(false)
const formRef = ref()

const loginForm = reactive({
  tenantId: '000000',
  username: 'admin',
  password: 'admin123',
  code: '',
  uuid: ''
})

const rules = {
  tenantId: [{ required: true, message: '请选择租户', trigger: 'change' }],
  username: [{ required: true, message: '请输入用户名', trigger: 'blur' }],
  password: [{ required: true, message: '请输入密码', trigger: 'blur' }]
}

async function handleLogin() {
  const valid = await formRef.value?.validate().catch(() => false)
  if (!valid) return

  loading.value = true
  try {
    await userStore.login({
      clientId: 'e5cd7e4891bf95d1d19206ce24a7b32e',
      grantType: 'password',
      ...loginForm
    })
    ElMessage.success('登录成功')
    router.push('/dashboard')
  } catch (err: any) {
    ElMessage.error(err?.message || '登录失败，请检查用户名和密码')
  } finally {
    loading.value = false
  }
}
</script>

<style scoped>
.login-wrapper {
  display: flex;
  align-items: center;
  justify-content: center;
  min-height: 100vh;
  background: linear-gradient(135deg, #1a73e8 0%, #0f974a 100%);
}

.login-card {
  width: 420px;
  padding: 40px;
  background: #fff;
  border-radius: 12px;
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.18);
}

.login-header {
  text-align: center;
  margin-bottom: 32px;
}

.login-header h1 {
  font-size: 28px;
  color: #1a73e8;
  margin: 0 0 8px;
}

.login-header p {
  font-size: 14px;
  color: #9aa0a6;
  margin: 0;
}
</style>
