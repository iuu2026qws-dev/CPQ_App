# CPQ 项目交接包 — 新 Agent 即接手即开发

> 📅 交接日期：2026-07-22
> 👤 交接人：码农（manong）
> 🎯 目标：新 Agent 读完本文档即可独立开发，无需追问任何基础信息

---

## 🗺️ 阅读顺序（按优先级）

| 顺序 | 文档 | 路径 | 阅读耗时 |
|:--:|------|------|:--:|
| 1 | **本文档** | `CPQ_HANDOVER.md` | 5 min |
| 2 | **项目状态** | `004_CPQ_App/STATUS.md` | 10 min |
| 3 | **踩坑记录** | `004_CPQ_App/LESSONS_LEARNED.md` | 5 min |
| 4 | **知识文档** | `004_CPQ_App/CPQ_KNOWLEDGE_BASE.md` | 15 min |
| 5 | **开发铁律** | `004_CPQ_App/dev_policy.md` | 3 min |
| 6 | **开发任务** | `004_CPQ_App/001_Product Design Docs/CPQ_开发任务清单.md` | 10 min |
| 7 | **部署记录** | `004_CPQ_App/DEPLOY_LOG.md` | 3 min |
| 8 | **运维手册** | `004_CPQ_App/doc/operations_manual.md` | 5 min |

---

## 🔧 三步上手

```bash
# Step 1: 进入项目
cd "/Users/mac/Library/Mobile Documents/com~apple~CloudDocs/创新万维/0004. platform_dev/004_CPQ_App"
git checkout manong_20260702_ver  # 主开发分支

# Step 2: 启动后端
java -jar "ruoyi-admin 2/target/ruoyi-admin.jar" --server.port=30000

# Step 3: 启动前端
cd cpq-portal && npm run dev   # http://localhost:3000
# 登录: admin / admin123
```

---

## 📊 当前状态（2026-07-22）

### Git 分支
```
origin/5.X ────────────────── (上游 RuoYi 框架，冻结)
  └── manong_20260702_ver ─── (主开发分支)
       └── feat/fix-quote-api (今天新建，修复分支)
```

| 分支 | 最新 Commit | 状态 |
|------|------------|:--:|
| `manong_20260702_ver` | `188ad07b1` | 当前工作分支 |
| `feat/fix-quote-api` | `188ad07b1` | 已推 GitHub |
| `5.X` | 上游冻结 | 仅拉取 |

### 远程仓库
| 别名 | URL | 用途 |
|------|-----|------|
| `github` | `git@github.com:iuu2026qws-dev/CPQ_App.git` (SSH) | 推送 |
| `origin` | `gitee.com/dromara/RuoYi-Vue-Plus` | 仅拉取框架更新 |

> ⚠️ GitHub 直连 IPv6 不通，推送需加 `-4`：`git push -4 github <branch>`

---

## 🖥️ 三套环境

| 环境 | 地址 | 用途 | 启动方式 |
|------|------|------|----------|
| **本地开发** | `localhost:30000` | 日常开发调试 | 直接 java -jar / npm run dev |
| **测试机** | `100.119.232.95:30000` | 内部测试 | SSH + LaunchAgent 开机自启 |
| **Docker 生产** | `8.148.208.235:2999` | 对外服务 | Docker Compose |

### 测试机 (mac@100.119.232.95)
```
SSH: mac@100.119.232.95 (密码 1234)
部署路径: /Users/mac/Downloads/cpq_app/
服务管理: LaunchAgent plist (~/Library/LaunchAgents/com.cpq.*.plist)
```

### Docker 生产 (root@8.148.208.235)
```
SSH: 需通过跳板机 mac@100.119.232.95 中转（公网出口 IP: 183.34.167.42）
密码: Pa$$20rd
部署路径: /opt/
容器名: cpq-backend
端口映射: 容器 30000 → 宿主机 2999
数据库: 8.133.17.0:3306 / Ruoyi_CPQ (root / Celnet2025.QY)

部署流程:
  1. SSH 跳板机: ssh mac@100.119.232.95
  2. SSH 目标: ssh root@8.148.208.235
  3. docker cp ruoyi-admin.jar cpq-backend:/app/
  4. docker compose restart
```

---

## 🗄️ 数据库

| 环境 | Host | 数据库 | 用户/密码 |
|------|------|--------|-----------|
| 本地 | localhost:3306 | ruoyi-vue-plus | root / Storm123@ |
| 测试机 | localhost:3306 | ruoyi-vue-plus | root / Storm123@ |
| Docker | 8.133.17.0:3306 | Ruoyi_CPQ | root / Celnet2025.QY |

> 本地 DDL 导出：`/tmp/cpq_tables_ddl.sql`

---

## 🧪 API 测试速查

```bash
# 获取 Token
TOKEN=$(curl -s -X POST 'http://localhost:30000/auth/login' \
  -H 'Content-Type: application/json' \
  -d '{"username":"admin","password":"admin123","clientId":"e5cd7e4891bf95d1d19206ce24a7b32e","grantType":"password","tenantId":"000000"}' \
  | python3 -c "import sys,json; print(json.load(sys.stdin)['data']['access_token'])")

# 通用 Header
HEADER=(-H "clientid: e5cd7e4891bf95d1d19206ce24a7b32e" -H "Authorization: Bearer $TOKEN")

# 创建报价单 (新版 API)
curl -X POST 'http://localhost:30000/cpq/quote/header' \
  "${HEADER[@]}" -H 'Content-Type: application/json' \
  -d '{"accountId":"1","quoteType":"STANDARD","currency":"CNY"}'

# API 文档
open http://localhost:30000/swagger-ui.html
```

---

## ⚠️ 已知问题（待修）

| # | 问题 | 优先级 | 状态 |
|:--:|------|:--:|:--:|
| 1 | 11 个文件 Snowflake ID 精度丢失 | 🟡 P1 | 待修 |
| 2 | 审批中心未开发 | 🔴 P0 | 待开发 |
| 3 | CSP 执行引擎缺失 | 🔴 P0 | 待开发 |
| 4 | 配置审阅页无"生成报价单"按钮 | 🔴 P0 | 待修 |
| 5 | 配置结果快照不自动保存 | 🟡 P1 | 待修 |
| 6 | BOM 物料成本写死为 0 | 🟡 P1 | 待修 |
| 7 | 新增报价单表单缺少客户搜索 | 🟡 P1 | 待修 |

> 完整清单见 `001_Product Design Docs/CPQ_开发任务清单.md`

---

## 📐 开发铁律（三条红线）

1. **axios 响应解包**：拦截器统一 `{rows, total}`，取数据用 `res.rows \|\| res.data \|\| []`
2. **Snowflake ID**：19 位超 JS 精度，一律 `String(route.params.id)`，禁止 `Number()`
3. **status 字段**：DB CHAR(1) 取值 `'0'` / `'1'`，不要传 `'ACTIVE'`

> 更多见 `LESSONS_LEARNED.md` 和 `dev_policy.md`

---

## 📦 项目结构速查

```
004_CPQ_App/
├── ruoyi-admin 2/              ← 启动模块（Spring Boot 入口）
├── ruoyi-modules/
│   ├── ruoyi-cpq-quote/        ← 报价管理 ★
│   ├── ruoyi-cpq-config/       ← 配置引擎 ★
│   ├── ruoyi-cpq-pricing/      ← 定价引擎 ★
│   ├── ruoyi-cpq-customer/     ← 客户管理
│   ├── ruoyi-cpq-crm/          ← CRM
│   ├── ruoyi-cpq-ecn/          ← 工程变更 ★
│   ├── ruoyi-cpq-approval/     ← 审批中心
│   └── ...
├── cpq-portal/                 ← 前端门户 (Vue 3 + Vite, :3000)
├── ruoyi-ui/                   ← 管理后台 (Vue 3 + Vite, :2999)
├── 001_Product Design Docs/    ← 12 份设计文档
├── doc/                        ← 运维手册
├── Mock Data/                  ← Mock SQL
├── STATUS.md                   ← 项目状态（最先读）
├── LESSONS_LEARNED.md          ← 踩坑记录
├── CPQ_KNOWLEDGE_BASE.md       ← 知识文档（源码/DB/依赖全解析）
├── DEPLOY_LOG.md               ← 部署历史
└── dev_policy.md               ← 开发铁律
```

---

## 🔄 标准开发流程

```
1. 读 STATUS.md 了解当前状态
2. 从 manong_20260702_ver 创建 feature 分支
3. 开发 → 本地测试 → vue-tsc --noEmit → Playwright E2E
4. 提交 → git push -4 github <feature-branch>
5. 如需部署：参考 DEPLOY_LOG.md 或 Docker 生产流程
6. 完成后更新 STATUS.md
```

---

## 🆘 常见坑

| 问题 | 解法 |
|------|------|
| GitHub 推送报 HTTP2 错误 | `git push -4 github` 强制 IPv4 |
| 后端启动报 tenant_id | 检查 `application.yml` 的 `tenant.excludes` |
| 前端 npm install 失败 | `NODE_ENV=development npm install` |
| 修改了 Java 代码不生效 | 必须从根目录构建：`mvn clean package -pl "ruoyi-admin 2" -am -DskipTests` |
| PM2 启动失败 | 用系统 Python `/usr/local/bin/python3` |
| 跳板机到目标机不通 | 公网出口 IP `183.34.167.42` 需在目标机防火墙放行 22 端口 |
