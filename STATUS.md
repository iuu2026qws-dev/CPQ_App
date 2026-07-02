# STATUS.md — CPQ App 项目交接单

> 最后更新: 2026-07-02 15:47
> 当前活跃项目

## 一句话状态

配置引擎核心链路已跑通，Mock 数据缺失是主要瓶颈。P0 任务：创建报价单/CRM Mock 数据、修复客户 ID 字段、排查管理后台登录。

## 项目定位

制造业智能 CPQ 系统（配置-定价-报价），基于 **RuoYi-Vue-Plus 5.x**（Spring Boot 3.x + Vue 3 + TypeScript + Element Plus）。

## 架构

```
cpq-portal (:3000, Vite)  ←──→  ruoyi-admin (:30000, Spring Boot)
                                       ├── MySQL 8.0+
                                       ├── Redis 6.0+
                                       └── MinIO
管理后台 ruoyi-ui (:2999)
```

## 服务状态

| 服务 | 端口 | 状态 |
|------|------|------|
| cpq-portal (Vue 前端) | 3000 | ✅ 运行中 |
| ruoyi-admin (Java 后端) | 30000 | ✅ 运行中 |
| 管理后台 | 2999 | ⚠️ 登录卡住 |

## 最近测试结果（2026-07-02）

- **通过 15 项**：登录、产品目录、搜索、三栏配置器、向导式配置等
- **修复验证 2 项**：向导式配置步骤、Vite 绑定地址
- **发现问题 5 项**：客户 ID 裸输入框(P01)、报价单无数据(P02)、CRM 无数据(P03)、管理后台登录(P04)、价格显示不一致(P05)
- **待测试 8 项**：审批中心、价格管理、BOM 管理、工程变更、配置规则、报价模板等

## 关键文档

| 文档 | 路径/链接 |
|------|----------|
| 测试报告 | 飞书 `OiekdKbH2oVaJDxgM31cYjzcnVe` |
| 用户场景说明书 | 飞书 `PLKsbQnjeofTNSxo0Kxcl4gTn3d` |
| 产品设计文档 | `001_Product Design Docs/` (8份) |
| Mock 数据 | `Mock Data/` (M-CPQ + M-CPQ_EVE) |
| 部署指南 | `doc/deployment_guide.md` |

## 启动命令

```bash
# 前端
cd "/Users/mac/Library/Mobile Documents/com~apple~CloudDocs/创新万维/0004. platform_dev/004_CPQ_App/cpq-portal"
npm run dev

# 后端
cd "/Users/mac/Library/Mobile Documents/com~apple~CloudDocs/创新万维/0004. platform_dev/004_CPQ_App/ruoyi-admin 2"
mvn spring-boot:run
```

## 当前阻塞

1. **Mock 数据缺失**：报价单/CRM 无数据，无法测试审批/CRM 流程
2. **客户 ID 字段规范**：新增报价单弹窗中客户 ID 是裸数字输入框
3. **管理后台登录**：`:2999` 登录卡住

## 下一步（优先级）

| P0 | 创建 Mock 数据 → 修复客户 ID 字段 → 排查管理后台登录 |
| P1 | 测试审批中心 → 价格管理 → BOM 管理 |
| P2 | 报价模板 → 工程变更 → 移动端适配 |
