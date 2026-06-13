<template>
  <router-view />
  <!-- 全局加载遮罩：动态路由未注册时显示 -->
  <div v-if="routesLoading" class="global-loading-overlay">
    <div class="loading-card">
      <div class="spinner">
        <div class="spinner-ring"></div>
        <div class="spinner-ring spinner-ring-inner"></div>
      </div>
      <p class="loading-text">加载中...请稍等</p>
    </div>
  </div>
</template>

<script setup lang="ts">
import { routesLoading } from '@/router'
</script>

<style>
* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
}

html, body, #app {
  height: 100%;
  font-family: 'Helvetica Neue', Helvetica, 'PingFang SC', 'Microsoft YaHei', Arial, sans-serif;
  background: #f0f2f5;
}

/* 全屏加载遮罩 */
.global-loading-overlay {
  position: fixed;
  inset: 0;
  z-index: 9999;
  display: flex;
  align-items: center;
  justify-content: center;
  background: #f0f2f5;
}

.loading-card {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 24px;
  padding: 48px 64px;
  background: #fff;
  border-radius: 12px;
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.08);
}

.spinner {
  position: relative;
  width: 56px;
  height: 56px;
}

.spinner-ring {
  position: absolute;
  inset: 0;
  border: 3px solid transparent;
  border-top-color: #1a73e8;
  border-radius: 50%;
  animation: spin 0.8s linear infinite;
}

.spinner-ring-inner {
  inset: 10px;
  border-top-color: #4a9af5;
  animation-duration: 0.6s;
  animation-direction: reverse;
}

@keyframes spin {
  to {
    transform: rotate(360deg);
  }
}

.loading-text {
  font-size: 15px;
  color: #5f6368;
  margin: 0;
  letter-spacing: 0.5px;
}
</style>
