# CPQ 项目 — 三套环境配置

> 最后更新：2026-07-25 | 维护人：码农

---

## 🖥️ 环境一：本地开发（Mac）

| 组件 | 地址 | 备注 |
|------|------|------|
| CPQ App 后端 | `localhost:30000` | `java -jar ruoyi-admin.jar` |
| CPQ App 前端 (门户) | `localhost:3000` | Vite (cpq-portal) |
| CPQ App 管理后台 | `localhost:2999` | Vite (ruoyi-ui) |
| CPQ Agent 后端 | `localhost:58100` | Python FastAPI |
| CPQ Agent 前端 | `localhost:5173` | Vite (Agent) |
| 数据库 | `8.148.208.235:3306` / `Ruoyi_CPQ` | root / Celnet2025.QY |
| Redis | `localhost:6379` | 密码 `ruoyi123` |
| 项目路径 (App) | `/Users/a1234/Desktop/CPQ_App` | |
| 项目路径 (Agent) | `/Users/a1234/Desktop/CPQ_Agent` | |
| DeepSeek | api.deepseek.com / deepseek-v4-pro | sk-5cefe4230add4f939357147790cec49c |
| 登录 | admin / admin123 | |
| 连通性 | ✅ 全部可达 | |

---

## 🧪 环境二：测试环境

| 组件 | 地址 | 备注 |
|------|------|------|
| 应用服务器 | `8.148.208.235` | Docker 部署 |
| CPQ App 后端 | `:2999`（外部）/ `:30000`（容器内） | Docker 端口映射 |
| CPQ App 前端 (门户) | `:3000` | Nginx (cpq-portal) |
| CPQ App 管理后台 | `:5173` | Nginx (ruoyi-ui) |
| CPQ Agent 后端 | `:58100` | Python FastAPI，新增于 v4 |
| CPQ Agent 前端 | `:57100` | Nginx，新增于 v4 |
| 数据库 | `8.133.17.0:3306` / `Ruoyi_CPQ` | root / Celnet2025.QY |
| Redis | `:6379`（容器内） | 密码 `ruoyi123` |
| DeepSeek | api.deepseek.com / deepseek-v4-pro | sk-5cefe4230add4f939357147790cec49c |
| SSH | `root@8.148.208.235` | 密码 Pa$$20rd |
| 部署路径 | `/opt/eve-cpq-docker-deploy/` | Docker Compose |
| 登录 | admin / admin123 | |
| 连通性 | ⚠️ 数据库需白名单 | |

---

## 🏭 环境三：生产环境

| 组件 | 地址 | 备注 |
|------|------|------|
| 应用服务器 | `10.100.111.55` | 内网可达 |
| CPQ App 后端 | `:2999`（外部）/ `:30000`（容器内） | Docker 部署 |
| CPQ App 前端 (门户) | `:3000` | Nginx (cpq-portal) |
| CPQ App 管理后台 | `:5173` | Nginx (ruoyi-ui) |
| CPQ Agent 后端 | `:58100` | 新增于 v4 |
| CPQ Agent 前端 | `:57100` | 新增于 v4 |
| 数据库 | `10.100.111.48:3306` / `dm_app_yhs_safe` | yhs_data_uat / Zc8!jS5&mE4# |
| Redis | `:6379`（容器内） | 密码 `ruoyi123` |
| DeepSeek | ai-pool.evebattery.com/v1 | Qwen3-235B-A22B-w8a8 / sk-XU6UJMoS2AylYlUQT7fuXt43oTLVUfEmQPnXKkfei2P5Dcwp |
| 登录 | admin / admin123 | |
| 连通性 | ❌ 需内网或 VPN | |

---

## 🔐 统一认证参数（三套通用）

```json
{
  "username": "admin",
  "password": "admin123",
  "clientId": "e5cd7e4891bf95d1d19206ce24a7b32e",
  "grantType": "password",
  "tenantId": "000000"
}
```

**API 固定 Header：** `clientid: e5cd7e4891bf95d1d19206ce24a7b32e`

---

## 🔗 环境关系图

```
┌─────────────────┐                   ┌─────────────────┐
│  本地 Mac        │                   │  测试环境        │
│  localhost:30000 │ ──────────────→  │  8.148.208.235   │
│  localhost:58100 │   直连 SSH        │  :2999 (CPQ)     │
│  localhost:57100 │                  │  Docker 部署     │
│                  │                  │                  │
│  共享数据库 ←────┼──────────────────│  DB 8.133.17.0   │
│  8.148.208.235   │                  │  Ruoyi_CPQ       │
│  Ruoyi_CPQ       │                  │                  │
└─────────────────┘                  └─────────────────┘

┌─────────────────┐                   ┌─────────────────┐
│  生产环境        │  内网/VPN         │  DB 10.100.111.48│
│  10.100.111.55  │ ← ─ ─ ─ ─ ─ →   │  dm_app_yhs_safe │
└─────────────────┘                   └─────────────────┘
```
