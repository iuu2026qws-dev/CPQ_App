# STATUS.md — CPQ App 项目交接单

> 最后更新: 2026-07-02 16:20 | 当前活跃项目
> **本机 IP: 172.16.1.115** | localhost

## 一句话状态

Mock 数据已创建（6 客户 + 6 商机 + 7 报价单），但前端列表页不显示数据（API 正常返回，前端搜索过滤疑似 bug）。P0 下一步：修复前端数据展示。

## 环境

| 项目 | 值 |
|------|----|
| 本机 IP | **172.16.1.115** |
| 本机 hostname | localhost |
| Git 分支 | `manong_20260702_ver` |
| 远程测试机 | ~~100.117.79.31~~（不使用） |

## 最近改动（2026-07-02）

- 切 Git 分支 `manong_20260702_ver`
- 通过 API 插入 Mock 数据（`/api/cpq/customer/account` + `/api/cpq/crm/opportunity` + `/api/cpq/quote/header`）
- 发现前端列表页不显示数据 — API 返回正确（6 客户/6 商机/7 报价），但前端搜索传参导致显示"暂无数据"

## 项目定位

制造业智能 CPQ 系统（配置-定价-报价），基于 **RuoYi-Vue-Plus 5.x**（Spring Boot 3.x + Vue 3 + TypeScript + Element Plus）。

## 架构

```
cpq-portal (:3000, Vite)  ←──→  ruoyi-admin (:30000, Spring Boot)
                                       ├── MySQL 8.0+ (root/Storm123@)
                                       ├── Redis 6.0+
                                       └── MinIO
管理后台 ruoyi-ui (:2999) — 本地未启动
```

## 服务状态

| 服务 | 端口 | 状态 |
|------|------|------|
| cpq-portal (Vue 前端) | 3000 | ✅ 运行中 |
| ruoyi-admin (Java 后端) | 30000 | ✅ 运行中 |
| MySQL | 3306 | ✅ 运行中 |
| Redis | 6379 | ✅ 运行中 |

## 测试进度

| 模块 | 状态 | 备注 |
|------|------|------|
| 价格手册 | ✅ | 1 本手册，99+ 条目 |
| 定价规则 | ✅ 页面正常 | 待补充规则数据 |
| 阶梯定价 | ✅ 页面正常 | 待补充阶梯数据 |
| 渠道价格 | ✅ 页面正常 | 待补充渠道数据 |
| 汇率配置 | — | 页面存在 |
| 配置规则(门户) | ✅ 页面正常 | |
| BOM管理 | ✅ 页面正常 | 需选择产品 |
| 标准配置 | ✅ | 四步流程已测 |
| 向导式配置 | ✅ | 五步流程已测(之前修复) |
| 三栏配置器 | ✅ | 已测 |
| ATO配置 | ✅ | 页面存在 |
| CRM客户 | ⚠️ API有数据，前端不显示 | 6 条在 DB |
| CRM商机 | ⚠️ 同上 | 6 条在 DB |
| 报价单 | ⚠️ 同上 | 7 条在 DB |
| 审批中心 | ❌ Vue 页面未开发 | |

## 当前阻塞

1. **前端列表不显示数据（新发现）**：CRM/报价单 API 返回正确，前端页面显示"暂无数据"
2. **客户 ID 字段规范**（P01）：新增报价单弹窗中客户 ID 裸数字输入框
3. **管理后台登录**（P04）：本地未启动 ruoyi-ui

## API 登录方式

```bash
# 获取 token 需要 OAuth2 流程。前端用 axios + cpq_token (localStorage) + clientid header
# 通过浏览器 run-code 调用:
fetch('/api/cpq/customer/account/list', {
  headers: {
    'clientid': 'e5cd7e4891bf95d1d19206ce24a7b32e',
    'Authorization': 'Bearer ' + localStorage.getItem('cpq_token')
  }
})
```

## 关键文档

| 文档 | 路径/链接 |
|------|----------|
| 测试报告 | 飞书 `OiekdKbH2oVaJDxgM31cYjzcnVe` |
| 用户场景说明书 | 飞书 `PLKsbQnjeofTNSxo0Kxcl4gTn3d`，已下载到本地 `cpq_app_user_scenario.md` |
| 产品设计文档 | `001_Product Design Docs/` (8份) |
| Mock 数据 | `Mock Data/` (M-CPQ + M-CPQ_EVE) |

## 下一步（优先级）

| P0 | 修复前端列表数据不显示 → 修复客户 ID 字段 |
| P1 | 补充定价/阶梯/渠道数据 → 测试审批中心 |
| P2 | 报价模板 → 工程变更 → 移动端适配 |
