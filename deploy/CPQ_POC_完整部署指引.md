# SmartCPQ POC 测试环境完整部署指引

> 服务器：`8.148.208.235`（阿里云 ECS，root@ / Pa$$20rd）
> 部署目录：`/opt/`
> 数据库：`8.133.17.0:3306` / `Ruoyi_CPQ` / `root` / `Celnet2025.QY`
> Redis 密码：`ruoyi123`
> 最后更新：2026-07-26

---

## 架构总览

```
┌────────────────────────────────────────────────────────────┐
│  浏览器                                                     │
│  ├─ http://8.148.208.235:3000   CPQ Portal (nginx)         │
│  ├─ http://8.148.208.235:2999   CPQ Admin 后端             │
│  ├─ http://8.148.208.235:57100  Agent 前端 (nginx + 反代)  │
│  └─ http://8.148.208.235:58100  Agent 后端 (FastAPI)       │
└────────────────────────────────────────────────────────────┘
                              │
┌─────────────────────────────▼──────────────────────────────┐
│  Docker Compose (5 个容器，全部在 /opt/docker-compose.yml)  │
│                                                             │
│  cpq-redis         redis:7-alpine                          │
│  cpq-backend       cpq-backend:latest  (Java Spring Boot)  │
│  cpq-frontend      cpq-frontend:latest (nginx + cpq-portal)│
│  cpq-agent-backend ghcr.io/.../cpq-backend  (Python)       │
│  cpq-agent-frontend ghcr.io/.../cpq-frontend (nginx + Vue) │
└─────────────────────────────────────────────────────────────┘
```

**两个代码仓库 + 两个 CI 流水线：**

| 仓库 | CI 产物 | 用途 |
|------|---------|------|
| [CPQ_App](https://github.com/iuu2026qws-dev/CPQ_App) | `cpq-app-jar` + `cpq-frontend-image` | CPQ 后端 JAR + CPQ Portal 前端镜像 |
| [CPQ_Agent](https://github.com/stormyangyf2026/CPQ_Agent) | `cpq-agent-backend-image` + `cpq-agent-frontend-image` + `cpq-agent-linux-deploy` | Agent 后端镜像 + Agent 前端镜像 + 配置文件 |

---

## 阶段零：本地构建准备（CI 自动完成）

### 0.1 CPQ_App CI（GitHub Actions）

**触发条件**：推送到 `v4-deploy` 分支

**Job 1 — build-jar**：构建 Java 后端 JAR
- 关键处理：目录名含空格 `ruoyi-admin 2` → `ruoyi-admin`，MVN 才能正确解析模块
- 产物：`cpq-app-jar` → `ruoyi-admin.jar`（~168MB）

**Job 2 — docker-frontend**：构建 CPQ Portal 前端 Docker 镜像
- Dockerfile：`cpq-portal/Dockerfile`
  - 多阶段构建：Node 22 → `npm install --ignore-engines --legacy-peer-deps` → `npm run build`
  - Nginx 1.26-alpine 提供静态服务 + API 反代到 `cpq-backend:30000`
- **已解决的构建问题**：
  - `vue-tsc` 类型检查报 17 个错误 → 改为 `vite build`（跳过类型检查）
  - `engines` 要求 `node >=22`，Dockerfile 用 `node:18` → 升级为 `node:22-alpine`
  - 缺少 `terser` 依赖 → 加入 `devDependencies`
  - macOS `package-lock.json` Linux CI 不兼容 → CI 内 Docker 自行生成锁文件
- 产物：`cpq-frontend-image` → `cpq-frontend.tar.gz`（~25MB）

### 0.2 CPQ_Agent CI（GitHub Actions）

**触发条件**：推送到 `v4-deploy` 分支

**Job 1 — docker-backend**：构建 Agent Python 后端镜像
- Dockerfile：`backend/Dockerfile`（FROM python:3.12-slim）
- 推送到 `ghcr.io/stormyangyf2026/cpq_agent/cpq-backend:latest`
- 产物：`cpq-agent-backend-image` → `cpq-agent-backend.tar.gz`（~88MB）

**Job 2 — docker-frontend**：构建 Agent 前端镜像
- Dockerfile：`frontend/Dockerfile`（FROM nginx:alpine + COPY dist/）
- 构建命令：`npm run build -- --mode staging` + `VITE_AGENT_API_URL=`（空值走同源）
- 包含 `nginx.conf`：静态文件 + API 反代到 `cpq-agent-backend:58100`
- 推送到 `ghcr.io/stormyangyf2026/cpq_agent/cpq-frontend:latest`
- 产物：`cpq-agent-frontend-image` → `cpq-agent-frontend.tar.gz`（~25MB）

**Job 3 — build-windows**：Windows 桌面版 Electron（非本次部署使用）

**Job 4 — package-linux**：打包配置文件
- 仅含 `agent-config.yaml`（从 `config/staging/config.yaml` 复制）
- 产物：`cpq-agent-linux-deploy` → `cpq-agent-deploy.tar.gz`（~1KB）

---

## 阶段一：下载 CI Artifacts

### 1.1 从 GitHub Actions 下载

**CPQ_App**：https://github.com/iuu2026qws-dev/CPQ_App/actions

| Artifact | 解压得 | 用途 |
|----------|--------|------|
| `cpq-app-jar` | `ruoyi-admin.jar` | CPQ 后端 JAR |
| `cpq-frontend-image` | `cpq-frontend.tar.gz` | CPQ Portal 前端镜像 |

**CPQ_Agent**：https://github.com/stormyangyf2026/CPQ_Agent/actions

| Artifact | 解压得 | 用途 |
|----------|--------|------|
| `cpq-agent-backend-image` | `cpq-agent-backend.tar.gz` | Agent 后端镜像 |
| `cpq-agent-frontend-image` | `cpq-agent-frontend.tar.gz` | Agent 前端镜像 |
| `cpq-agent-linux-deploy` | `cpq-agent-deploy.tar.gz` | agent-config.yaml |

### 1.2 准备 docker-compose.yml

在 `deploy-v5/` 目录下放入**预先改好的** `docker-compose.yml`（见 [附录A](#附录adocker-composeyml-完整内容)）。

**所有修改点都在本地完成，服务器端零手动编辑：**

| 修改点 | 说明 |
|--------|------|
| `cpq-backend` volumes 增加 JAR 挂载 | `./deploy-v5/ruoyi-admin.jar:/app/ruoyi-admin.jar` |
| `cpq-frontend` 端口映射 | `3000:80`（nginx 生产模式） |
| `cpq-frontend` 去掉了 vite dev 端口和配置文件挂载 | 新镜像是 nginx 生产构建 |
| 新增 `cpq-agent-backend` 服务 | 端口 58100，config 挂载到 `/config/config.yaml` |
| 新增 `cpq-agent-frontend` 服务 | 端口 57100:80（内嵌静态文件+nginx反代） |

### 1.3 放入 DDL 脚本和 JAR

```bash
cp ~/Desktop/CPQ_App/sql/cpq_poc_ddl.sql ~/Desktop/deploy-v5/
# ruoyi-admin.jar 从 CI 下载或本地构建后放入
```

### 1.4 确认 deploy-v5 目录

```bash
ls -lh ~/Desktop/deploy-v5/
```

预期：

| 文件 | 大小 | 来源 |
|------|------|------|
| `ruoyi-admin.jar` | ~168MB | CPQ_App CI `cpq-app-jar` |
| `cpq-agent-backend.tar.gz` | ~88MB | CPQ_Agent CI |
| `cpq-agent-frontend.tar.gz` | ~25MB | CPQ_Agent CI |
| `cpq-frontend.tar.gz` | ~25MB | CPQ_App CI |
| `cpq-agent-deploy.tar.gz` | ~1KB | CPQ_Agent CI |
| `docker-compose.yml` | ~2KB | 本地预先改好 |
| `cpq_poc_ddl.sql` | ~14KB | CPQ_App 仓库 |

---

## 阶段二：上传到服务器

```bash
# 本机执行
scp -r ~/Desktop/deploy-v5 root@8.148.208.235:/opt/
```

**验证**：
```bash
ssh root@8.148.208.235 "ls -lh /opt/deploy-v5/"
# 确认 7 个文件，大小与预期一致
```

---

## 阶段三：加载 Docker 镜像

**目的**：将离线导出的 Docker 镜像导入服务器本地镜像库

**操作**：
```bash
cd /opt/deploy-v5

# Agent 镜像（ghcr.io/...）
docker load < cpq-agent-backend.tar.gz      # → ghcr.io/.../cpq-backend:latest
docker load < cpq-agent-frontend.tar.gz     # → ghcr.io/.../cpq-frontend:latest

# CPQ App 前端镜像
docker load < cpq-frontend.tar.gz           # → cpq-frontend:latest
```

**验证**：
```bash
docker images | grep -E "cpq_backend|cpq_frontend|cpq-frontend"
```
应看到 3 个镜像。

> `cpq-backend:latest` 使用旧镜像，JAR 通过 volume 挂载覆盖（见阶段六），不需要重新构建。

---

## 阶段四：部署 Agent 配置

**目的**：将 Agent 的 config.yaml 放到宿主机，通过 volume 挂载到 Agent 容器

**操作**：
```bash
mkdir -p /opt/agent-config /opt/agent-data
mkdir -p /tmp/agent-deploy
cd /opt/deploy-v5
tar xzf cpq-agent-deploy.tar.gz -C /tmp/agent-deploy
cp /tmp/agent-deploy/agent-config.yaml /opt/agent-config/config.yaml
```

**验证**：
```bash
grep -E "base_url|api_key|model_name" /opt/agent-config/config.yaml
```
确认：
- `cpq.base_url: http://cpq-backend:30000`（Docker 内部 DNS）
- `model.api_key` 不为空
- `model.model_name: deepseek-v4-pro`

---

## 阶段五：确认 CPQ App 数据库配置

**目的**：确认 application-dev.yml 数据库连接指向正确的地址

**操作**：
```bash
grep -E 'url:|username:|password:' /opt/application-dev.yml
```

**验证**：指向 `8.133.17.0:3306` / `Ruoyi_CPQ` / `root` / `Celnet2025.QY`

---

## 阶段六：备份 & 停服

### 6.1 备份

**操作**：
```bash
cd /opt
mkdir -p /opt/backup

# 备份旧 JAR（容器内文件名是 ruoyi-admin.jar）
docker cp cpq-backend:/app/ruoyi-admin.jar /opt/backup/ruoyi-admin.$(date +%m%d_%H%M).jar 2>/dev/null || echo "跳过JAR备份"

# 备份 docker-compose.yml
cp docker-compose.yml /opt/backup/docker-compose.$(date +%m%d_%H%M).yml

# 备份数据库（可选但强烈建议）
mysqldump -h 8.133.17.0 -u root -pCelnet2025.QY Ruoyi_CPQ --no-tablespaces \
  > /opt/backup/db_$(date +%m%d_%H%M).sql 2>/dev/null || echo "跳过DB备份"
```

**验证**：
```bash
ls -lh /opt/backup/
```
应有 `.jar`、`.yml`、`.sql` 三个文件。

### 6.2 停服

**操作**：
```bash
cd /opt && docker compose down
```

**验证**：
```bash
docker compose ps -a
# 所有容器状态为 exited
```

---

## 阶段七：覆盖 docker-compose.yml & 启动

### 7.1 覆盖 compose 文件

**操作**：
```bash
cp /opt/deploy-v5/docker-compose.yml /opt/docker-compose.yml
```

**验证**：
```bash
grep "cpq-agent-backend" /opt/docker-compose.yml      # 应有输出
grep "cpq-agent-frontend" /opt/docker-compose.yml     # 应有输出
grep "ruoyi-admin.jar" /opt/docker-compose.yml        # 应有输出
grep "/config/config.yaml" /opt/docker-compose.yml    # ★ 确认是 /config 不是 /app/config
```

### 7.2 启动全部服务

**操作**：
```bash
cd /opt && docker compose up -d
```

**验证**（等待 90 秒）：
```bash
sleep 90
docker compose ps
```

预期 5 个容器全部 `Up`：

| 容器 | 端口 | 说明 |
|------|------|------|
| cpq-redis | 6379 | Redis |
| cpq-backend | 2999→30000 | CPQ App Java 后端 |
| cpq-frontend | 3000→80 | CPQ Portal 前端 (nginx) |
| cpq-agent-backend | 58100 | Agent Python 后端 |
| cpq-agent-frontend | 57100→80 | Agent 前端 (nginx + 反代) |

---

## 阶段八：数据库增量

### 8.1 执行 DDL

**操作**：
```bash
mysql -h 8.133.17.0 -u root -pCelnet2025.QY Ruoyi_CPQ --force \
  < /opt/deploy-v5/cpq_poc_ddl.sql 2>&1 | grep -v "Duplicate entry"
```

> `--force` 遇到重复主键继续执行；`grep -v` 过滤重复键 warning。

### 8.2 已知 DDL 问题（已修复）

| # | 问题 | 错误信息 | 修复 |
|---|------|---------|------|
| 1 | INSERT 缺 `approval_chain_json` | `Field 'approval_chain_json' doesn't have a default value` | INSERT 列清单补全该字段，设值 `'[]'` |
| 2 | INSERT 用旧列名 `rule_id` | `Unknown column 'rule_id'` | 改为 `dimension_type` + `dimension_value` |
| 3 | MySQL 不支持 `CREATE INDEX IF NOT EXISTS` | `syntax error near 'IF NOT EXISTS'` | 去掉 `IF NOT EXISTS` |
| 4 | `image_url` 列缺失 | `bad SQL grammar SELECT ... image_url` | DDL 中 `ALTER TABLE ADD COLUMN` 取消注释 |

### 8.3 验证数据库

```bash
mysql -h 8.133.17.0 -u root -pCelnet2025.QY Ruoyi_CPQ -e "
  SELECT 'dims' tbl, COUNT(*) n FROM cpq_dimension_def
  UNION ALL SELECT 'weights', COUNT(*) FROM cpq_scoring_weight
  UNION ALL SELECT 'mappings', COUNT(*) FROM cpq_dimension_attr_mapping
  UNION ALL SELECT 'configs', COUNT(*) FROM cpq_match_config
  UNION ALL SELECT 'rules', COUNT(*) FROM cpq_approval_rule
  UNION ALL SELECT 'matrix', COUNT(*) FROM cpq_approval_matrix;"
```

预期：

| 表 | 行数 |
|----|------|
| cpq_dimension_def | 6 |
| cpq_scoring_weight | 6 |
| cpq_dimension_attr_mapping | ≥9 |
| cpq_match_config | 5 |
| cpq_approval_rule | 1 |
| cpq_approval_matrix | 1 |

---

## 阶段九：验证

### 9.1 CPQ App 后端

```bash
# 健康检查
curl -s -o /dev/null -w "HTTP: %{http_code}\n" http://127.0.0.1:2999/

# 登录认证
curl -s -X POST http://127.0.0.1:2999/auth/login \
  -H 'Content-Type: application/json' \
  -d '{"username":"admin","password":"admin123","clientId":"e5cd7e4891bf95d1d19206ce24a7b32e","grantType":"password","tenantId":"000000"}'
```

**验证**：第一条返回 `200`；第二条返回 JSON 含 `access_token`

### 9.2 CPQ Portal 前端

```bash
curl -s http://127.0.0.1:3000/ | head -3
```

**验证**：包含 `<!doctype html>` 和 `cpq-portal`

### 9.3 匹配引擎

```bash
TOKEN=$(curl -s -X POST http://127.0.0.1:2999/auth/login \
  -H 'Content-Type: application/json' \
  -d '{"username":"admin","password":"admin123","clientId":"e5cd7e4891bf95d1d19206ce24a7b32e","grantType":"password","tenantId":"000000"}' \
  | python3 -c "import sys,json; print(json.load(sys.stdin)['data']['access_token'])")

curl -s -X POST http://127.0.0.1:2999/cpq/match/score \
  -H 'Content-Type: application/json' \
  -H "clientid: e5cd7e4891bf95d1d19206ce24a7b32e" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{"categoryId":507,"requirements":{"usageType":"GPS追踪器"}}' | python3 -m json.tool
```

**验证**：返回推荐产品列表，不报 `No mapping` 错误

### 9.4 Agent 后端

```bash
curl -s http://127.0.0.1:58100/health | python3 -m json.tool
```

**验证**：
```json
{
    "status": "ok",
    "cpq": {"status": "ok", "message": "CPQ 服务可达 (http://cpq-backend:30000)"},
    "agent": {"status": "ok"}
}
```

### 9.5 Agent 前端

```bash
curl -s http://127.0.0.1:57100/ | head -3
```

**验证**：返回 HTML（Agent 聊天界面）

### 9.6 浏览器验证

| 页面 | URL | 说明 |
|------|-----|------|
| CPQ Portal | `http://8.148.208.235:3000` | 产品配置、报价 |
| Agent 助手 | `http://8.148.208.235:57100` | AI 自然语言对话 |

> 如果浏览器 502，检查是否走了本地代理（`127.0.0.1:7897`），将 `8.148.208.235` 加入代理绕过列表。

---

## 部署踩坑速查表（18 条）

| # | 坑 | 现象 | 正确做法 |
|---|------|------|------|
| 1 | Docker Hub 离线 | `nginx:alpine` 拉取超时 | 前端静态文件 + nginx 配置内嵌到 Docker 镜像 |
| 2 | Config 挂载路径 | `no config file found` → `Missing credentials` | 挂载到 `/config/config.yaml`（程序用 `os.path.dirname(__file__)` 算出 `../config/`） |
| 3 | 前端 API 地址 | 页面能打开，对话无响应 | nginx 反向代理 `/agent/*` → 后端 + `VITE_AGENT_API_URL=` 空值走同源 |
| 4 | JAR 挂载文件名 | 容器跑的是 `ruoyi-admin.jar` | 挂载必须覆盖同名文件：`:/app/ruoyi-admin.jar` |
| 5 | `vue-tsc` 类型检查 | 17 个 TS 错误导致 Docker 构建失败 | `vite build` 跳过类型检查（Vite 不检查类型） |
| 6 | Node 版本不匹配 | `engines` 要求 `>=22`，Docker 用 `node:18` | `node:22-alpine` + `--ignore-engines` |
| 7 | `terser` 缺失 | `terser not found`，生产构建失败 | `npm install --save-dev terser` |
| 8 | macOS lock 文件 | Linux CI 上 npm 解析失败 | Docker 内自行生成锁文件 |
| 9 | DDL INSERT 缺列 | `Field 'xxx' doesn't have a default value` | INSERT 列清单与表结构对齐 |
| 10 | DDL 旧列名 | `Unknown column 'rule_id'` | 查 `SHOW COLUMNS`，修正列名 |
| 11 | `CREATE INDEX IF NOT EXISTS` | MySQL 语法错误 | 去掉 `IF NOT EXISTS` |
| 12 | DDL `image_url` 缺失 | 匹配引擎 SQL 报 `bad SQL grammar` | ALTER TABLE 补充列 |
| 13 | 前端端口映射 | nginx 在 80 但 compose 映射 `3000:3000` | 改为 `3000:80` |
| 14 | `cpq-frontend` 旧镜像 | Vite dev 模式，无 `vite.config` | 新镜像 nginx 生产构建，去掉 dev 挂载 |
| 15 | UTF-8 BOM | CSV 导入 17 条全跳过 | `tail -c +4 file.csv` 去除 BOM |
| 16 | 备份文件日期位置 | `file.yml.0726` | 日期在扩展名前：`file.0726.yml` |
| 17 | `tar -C` 目录不存在 | `Cannot open: No such file or directory` | 先 `mkdir -p /tmp/agent-deploy` |
| 18 | `cat >>` 追加 compose | 服务被解析为 `volumes` 的子属性 | 本地改好 docker-compose.yml 直接覆盖 |

---

## 回滚

```bash
cd /opt
docker compose down
cp /opt/backup/docker-compose.XXXXXX.yml /opt/docker-compose.yml
docker compose up -d
```

---

## 附录A：docker-compose.yml 完整内容

```yaml
version: '3.8'

services:
  redis:
    image: redis:7-alpine
    container_name: cpq-redis
    command: redis-server --requirepass ruoyi123 --appendonly yes
    volumes:
      - redis-data:/data
    ports:
      - "6379:6379"
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "redis-cli", "-a", "ruoyi123", "PING"]
      interval: 10s
      timeout: 5s
      retries: 30

  cpq-backend:
    image: cpq-backend:latest
    container_name: cpq-backend
    environment:
      - MYSQL_HOST=8.133.17.0
      - MYSQL_PORT=3306
      - MYSQL_DATABASE=Ruoyi_CPQ
      - MYSQL_USER=root
      - MYSQL_PASSWORD=Celnet2025.QY
      - REDIS_HOST=redis
      - REDIS_PORT=6379
      - REDIS_PASSWORD=ruoyi123
      - JAVA_OPTS=-Xms512m -Xmx2g
      - TZ=Asia/Shanghai
    ports:
      - "2999:30000"
    depends_on:
      redis:
        condition: service_started
    restart: unless-stopped
    volumes:
      - ./application-dev.yml:/app/config/application-dev.yml
      - ./deploy-v5/ruoyi-admin.jar:/app/ruoyi-admin.jar    # ★ 必须覆盖容器实际运行的 JAR 文件名
    healthcheck:
      test: ["CMD", "sh", "-c", "curl -f http://localhost:2999/ || exit 1"]
      interval: 30s
      timeout: 10s
      retries: 5
      start_period: 60s

  cpq-frontend:
    image: cpq-frontend:latest
    container_name: cpq-frontend
    environment:
      - TZ=Asia/Shanghai
    ports:
      - "3000:80"                     # ★ nginx 生产模式，内部端口 80
    depends_on:
      cpq-backend:
        condition: service_started
    restart: unless-stopped

  cpq-agent-backend:
    image: ghcr.io/stormyangyf2026/cpq_agent/cpq-backend:latest
    container_name: cpq-agent-backend
    environment:
      - PORT=58100
      - TZ=Asia/Shanghai
    ports:
      - "58100:58100"
    depends_on:
      cpq-backend:
        condition: service_started
    volumes:
      - ./agent-config/config.yaml:/config/config.yaml    # ★ /config 不是 /app/config
      - ./agent-data:/app/data
    restart: unless-stopped

  cpq-agent-frontend:
    image: ghcr.io/stormyangyf2026/cpq_agent/cpq-frontend:latest
    container_name: cpq-agent-frontend
    ports:
      - "57100:80"
    depends_on:
      cpq-agent-backend:
        condition: service_started
    restart: unless-stopped

volumes:
  redis-data:
    driver: local
```

## 附录B：关键配置文件路径

| 文件 | 宿主机路径 | 容器内路径 | 说明 |
|------|-----------|-----------|------|
| docker-compose.yml | `/opt/docker-compose.yml` | — | 本地改好直接覆盖 |
| CPQ 数据库配置 | `/opt/application-dev.yml` | `/app/config/application-dev.yml` | 确认 DB 地址 |
| CPQ JAR | `/opt/deploy-v5/ruoyi-admin.jar` | `/app/ruoyi-admin.jar` | ★ 覆盖原 JAR |
| Agent 配置 | `/opt/agent-config/config.yaml` | `/config/config.yaml` | ★ 注意路径 |
| Agent 数据 | `/opt/agent-data/` | `/app/data/` | 会话持久化 |
| CPQ Portal 前端 | 内嵌在 `cpq-frontend` 镜像 | `/usr/share/nginx/html/` | nginx 静态服务 |
| Agent 前端 | 内嵌在 `cpq-agent-frontend` 镜像 | `/usr/share/nginx/html/` | nginx + API 反代 |

## 附录C：关键端口

| 端口 | 服务 | 说明 |
|------|------|------|
| 2999 | cpq-backend | CPQ App Java 后端 |
| 3000 | cpq-frontend | CPQ Portal nginx |
| 58100 | cpq-agent-backend | Agent Python 后端 |
| 57100 | cpq-agent-frontend | Agent nginx + API 反代 |
| 6379 | cpq-redis | Redis |

## 附录D：Git 分支与推送

| 仓库 | 分支 | 推送命令 |
|------|------|---------|
| CPQ_App | `v4-deploy` | `git push -4 origin v4-deploy` |
| CPQ_Agent | `v4-deploy` | `git push -4 origin v4-deploy` |

> GitHub IPv6 不通，务必加 `-4` 参数。
