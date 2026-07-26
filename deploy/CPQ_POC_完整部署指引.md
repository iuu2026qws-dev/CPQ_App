# SmartCPQ POC 测试环境完整部署指引

> 服务器：`8.148.208.235` | 部署目录：`/opt/`
> 数据库：`8.133.17.0:3306` / `Ruoyi_CPQ` / `root` / `Celnet2025.QY`
> Redis 密码：`ruoyi123`
> 完整环境配置见 `ENVIRONMENTS.md`

---

## 一、架构总览

### 1.1 浏览器访问

| URL | 服务 | 说明 |
|-----|------|------|
| `http://8.148.208.235:3000` | cpq-portal | CPQ 业务前端（产品配置、报价） |
| `http://8.148.208.235:5173` | ruoyi-ui | CPQ 管理后台（系统管理、菜单、用户） |
| `http://8.148.208.235:2999` | cpq-backend | CPQ App 后端 API |
| `http://8.148.208.235:57100` | cpq-agent-frontend | Agent AI 助手前端 |
| `http://8.148.208.235:58100` | cpq-agent-backend | Agent 后端 API |

### 1.2 Docker 容器

```
5 个容器（docker-compose.yml）：
┌─────────────────────────────────────────────────────────┐
│  cpq-redis            redis:7-alpine                    │
│  cpq-backend          cpq-backend:latest (Java)         │
│  cpq-frontend         cpq-frontend:latest (nginx)       │
│                        ├─ :80  → cpq-portal 业务前端     │
│                        └─ :5173 → ruoyi-ui 管理后台      │
│  cpq-agent-backend    ghcr.io/.../cpq-backend (Python)  │
│  cpq-agent-frontend   ghcr.io/.../cpq-frontend (nginx)  │
└─────────────────────────────────────────────────────────┘
```

### 1.3 代码仓库 & CI

| 仓库 | CI 产物 | 用途 |
|------|---------|------|
| [CPQ_App](https://github.com/iuu2026qws-dev/CPQ_App) | `cpq-app-jar` + `cpq-frontend-image` | 后端 JAR + 前端镜像（cpq-portal + ruoyi-ui） |
| [CPQ_Agent](https://github.com/stormyangyf2026/CPQ_Agent) | `cpq-agent-backend-image` + `cpq-agent-frontend-image` + `cpq-agent-linux-deploy` | Agent 后端镜像 + 前端镜像 + 配置文件 |

---

## 二、本地构建准备（CI 自动完成）

### 2.1 CPQ_App CI

| Job | 产物 | 关键处理 |
|-----|------|---------|
| `build-jar` | `ruoyi-admin.jar` (~168MB) | 目录名空格处理、Maven 构建 |
| `docker-frontend` | `cpq-frontend.tar.gz` (~30MB) | Dockerfile.frontend 双应用构建 |

**前端镜像 Dockerfile**（`Dockerfile.frontend`）：
- Stage 1：Node 22 构建 cpq-portal → dist
- Stage 2：Node 22 构建 ruoyi-ui → dist  
- Stage 3：Nginx 1.26-alpine 双端口服务
  - Port 80 → cpq-portal（代理 `/api/` → `cpq-backend:30000`）
  - Port 5173 → ruoyi-ui（代理 `/dev-api/` → `cpq-backend:30000`）

**已解决的构建问题**：

| # | 问题 | 修复 |
|---|------|------|
| 1 | `vue-tsc` 类型检查报错 | `vite build` 跳过类型检查 |
| 2 | Node 版本不匹配 (engines ≥22, Docker 用 18) | `node:22-alpine` |
| 3 | `terser` 缺失 | `npm install --save-dev terser` |
| 4 | macOS lock文件 Linux 不兼容 | CI 内 Docker 自行生成 |
| 5 | ruoyi-ui `.env.production` 缺失 | 新增 `VITE_APP_BASE_API=/dev-api` |

### 2.2 CPQ_Agent CI

| Job | 产物 | 说明 |
|-----|------|------|
| `docker-backend` | `cpq-agent-backend.tar.gz` (~88MB) | Python FastAPI |
| `docker-frontend` | `cpq-agent-frontend.tar.gz` (~25MB) | nginx + 静态文件 + API 反代 |
| `package-linux` | `cpq-agent-deploy.tar.gz` (~1KB) | agent-config.yaml |

---

## 三、阶段一：下载 Artifacts

### 3.1 从 GitHub Actions 下载

**CPQ_App** → https://github.com/iuu2026qws-dev/CPQ_App/actions

| Artifact | 解压得 | 用途 |
|----------|--------|------|
| `cpq-app-jar` | `ruoyi-admin.jar` | CPQ 后端 |
| `cpq-frontend-image` | `cpq-frontend.tar.gz` | cpq-portal + ruoyi-ui |

**CPQ_Agent** → https://github.com/stormyangyf2026/CPQ_Agent/actions

| Artifact | 解压得 | 用途 |
|----------|--------|------|
| `cpq-agent-backend-image` | `cpq-agent-backend.tar.gz` | Agent 后端 |
| `cpq-agent-frontend-image` | `cpq-agent-frontend.tar.gz` | Agent 前端 |
| `cpq-agent-linux-deploy` | `cpq-agent-deploy.tar.gz` | agent-config.yaml |

**注意**：下载 `.zip` → 解压得到 `.tar.gz` → 放到 `deploy-v5/` 目录

### 3.2 放入配套文件

```bash
# 放入 ddL、JAR、本地改好的 docker-compose.yml
cp ~/Desktop/CPQ_App/sql/cpq_poc_ddl.sql ~/Desktop/deploy-v5/
cp ~/Desktop/deploy-v5/docker-compose.yml ~/Desktop/deploy-v5/  # 确认已在
```

### 3.3 确认目录

```bash
ls -lh ~/Desktop/deploy-v5/
```

应含 7 个文件：

| 文件 | 大小 |
|------|------|
| `ruoyi-admin.jar` | ~168MB |
| `cpq-frontend.tar.gz` | ~30MB |
| `cpq-agent-backend.tar.gz` | ~88MB |
| `cpq-agent-frontend.tar.gz` | ~25MB |
| `cpq-agent-deploy.tar.gz` | ~1KB |
| `docker-compose.yml` | ~2KB |
| `cpq_poc_ddl.sql` | ~14KB |

---

## 四、阶段二：上传到服务器

```bash
scp -r ~/Desktop/deploy-v5 root@8.148.208.235:/opt/
```

**验证**：
```bash
ssh root@8.148.208.235 "ls -lh /opt/deploy-v5/"
```

---

## 五、阶段三：加载 Docker 镜像

```bash
cd /opt/deploy-v5

# Agent 镜像
docker load < cpq-agent-backend.tar.gz      # → ghcr.io/.../cpq-backend:latest
docker load < cpq-agent-frontend.tar.gz     # → ghcr.io/.../cpq-frontend:latest

# CPQ App 前端镜像（cpq-portal + ruoyi-ui）
docker load < cpq-frontend.tar.gz           # → cpq-frontend:latest
```

**验证**：
```bash
docker images | grep -E "cpq-frontend|cpq_agent"
# 应看到 3 个镜像
```

---

## 六、阶段四：部署 Agent 配置

```bash
mkdir -p /opt/agent-config /opt/agent-data
mkdir -p /tmp/agent-deploy
cd /opt/deploy-v5
tar xzf cpq-agent-deploy.tar.gz -C /tmp/agent-deploy
cp /tmp/agent-deploy/agent-config.yaml /opt/agent-config/config.yaml
```

**验证**：
```bash
grep -E "base_url|api_key" /opt/agent-config/config.yaml
# cpq.base_url: http://cpq-backend:30000
# api_key 不为空
```

---

## 七、阶段五：确认数据库配置

```bash
grep -E 'url:|username:|password:' /opt/application-dev.yml
```

**验证**：指向 `8.133.17.0:3306` / `Ruoyi_CPQ` / `root` / `Celnet2025.QY`

---

## 八、阶段六：备份 & 停服

```bash
cd /opt
mkdir -p /opt/backup

# 备份 JAR
docker cp cpq-backend:/app/ruoyi-admin.jar /opt/backup/ruoyi-admin.$(date +%m%d_%H%M).jar 2>/dev/null || echo "跳过"

# 备份 compose
cp docker-compose.yml /opt/backup/docker-compose.$(date +%m%d_%H%M).yml

# 备份数据库（可选）
mysqldump -h 8.133.17.0 -u root -pCelnet2025.QY Ruoyi_CPQ --no-tablespaces \
  > /opt/backup/db_$(date +%m%d_%H%M).sql 2>/dev/null || echo "跳过"

# 停服
docker compose down
```

---

## 九、阶段七：覆盖 compose & 启动

```bash
# 覆盖（本地已改好）
cp /opt/deploy-v5/docker-compose.yml /opt/docker-compose.yml

# 验证关键挂载路径
grep "ruoyi-admin.jar" /opt/docker-compose.yml        # → /app/ruoyi-admin.jar
grep "/config/config.yaml" /opt/docker-compose.yml    # → /config 不是 /app/config
grep "cpq-agent-backend" /opt/docker-compose.yml      # 应有输出
grep "5173:5173" /opt/docker-compose.yml              # ruoyi-ui 管理后台

# 启动
cd /opt && docker compose up -d
sleep 90
docker compose ps
```

**验证**：5 个容器全部 `Up`

---

## 十、阶段八：数据库增量

```bash
mysql -h 8.133.17.0 -u root -pCelnet2025.QY Ruoyi_CPQ --force \
  < /opt/deploy-v5/cpq_poc_ddl.sql 2>&1 | grep -v "Duplicate entry"
```

**验证**：
```bash
mysql -h 8.133.17.0 -u root -pCelnet2025.QY Ruoyi_CPQ -e "
  SELECT 'dims' tbl, COUNT(*) n FROM cpq_dimension_def
  UNION ALL SELECT 'weights', COUNT(*) FROM cpq_scoring_weight
  UNION ALL SELECT 'mappings', COUNT(*) FROM cpq_dimension_attr_mapping;"
```

预期：`dims:6, weights:6, mappings:≥9`

---

## 十一、阶段九：验证

### 11.1 全部 7 项验证

| # | 验证项 | 命令 | 预期 |
|---|--------|------|------|
| 1 | CPQ 后端 | `curl -s -o /dev/null -w "%{http_code}" http://127.0.0.1:2999/` | 200 |
| 2 | cpq-portal | `curl -s http://127.0.0.1:3000/ \| head -3` | `<!doctype html>` |
| 3 | ruoyi-ui | `curl -s http://127.0.0.1:5173/ \| head -3` | `<!doctype html>` |
| 4 | 匹配引擎 | 登录 + `POST /cpq/match/score` | 返回推荐列表 |
| 5 | Agent 后端 | `curl http://127.0.0.1:58100/health` | `{"status":"ok"}` |
| 6 | Agent 前端 | `curl -s http://127.0.0.1:57100/ \| head -3` | `<!doctype html>` |
| 7 | ruoyi-ui 菜单 | 浏览器 F12 Network 看 `/dev-api/system/menu/getRouters` | 返回菜单 JSON |

### 11.2 浏览器验证

| 页面 | URL |
|------|-----|
| CPQ 业务前端 | `http://8.148.208.235:3000` |
| CPQ 管理后台 | `http://8.148.208.235:5173` |
| Agent AI 助手 | `http://8.148.208.235:57100` |

---

## 十二、回滚

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
      - ./deploy-v5/ruoyi-admin.jar:/app/ruoyi-admin.jar
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
      - "3000:80"       # cpq-portal 业务前端
      - "5173:5173"     # ruoyi-ui 管理后台
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
      - ./agent-config/config.yaml:/config/config.yaml
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

| 文件 | 宿主机路径 | 容器内路径 | 注意 |
|------|-----------|-----------|------|
| compose | `/opt/docker-compose.yml` | — | 本地改好直接覆盖 |
| CPQ JAR | `/opt/deploy-v5/ruoyi-admin.jar` | `/app/ruoyi-admin.jar` | ★ 必须与容器启动命令一致 |
| CPQ 数据库配置 | `/opt/application-dev.yml` | `/app/config/application-dev.yml` | 确认 DB 地址 |
| Agent 配置 | `/opt/agent-config/config.yaml` | `/config/config.yaml` | ★ 不是 /app/config |
| Agent 数据 | `/opt/agent-data/` | `/app/data/` | 会话持久化 |

## 附录C：端口速查

| 端口 | 服务 | 说明 |
|------|------|------|
| 2999 | cpq-backend | CPQ App Java 后端 |
| 3000 | cpq-frontend | cpq-portal 业务前端 (nginx) |
| 5173 | cpq-frontend | ruoyi-ui 管理后台 (nginx) |
| 58100 | cpq-agent-backend | Agent Python 后端 |
| 57100 | cpq-agent-frontend | Agent 前端 (nginx + API 反代) |
| 6379 | cpq-redis | Redis |

## 附录D：踩坑速查表（19条）

| # | 坑 | 现象 | 修复 |
|---|------|------|------|
| 1 | Docker Hub 离线 | `nginx:alpine` 超时 | 静态文件内嵌镜像 |
| 2 | Config 挂载路径 | `Missing credentials` | `/config/config.yaml` |
| 3 | 前端 API 空 BASE_URL | 菜单不显示 | `.env.production` 设 `VITE_APP_BASE_API=/dev-api` |
| 4 | JAR 挂载文件不对 | 加载旧代码 | 覆盖 `ruoyi-admin.jar` |
| 5 | `vue-tsc` 类型错误 | CI 构建失败 | `vite build` 跳过 |
| 6 | Node 版本不匹配 | npm ci 失败 | `node:22-alpine` |
| 7 | `terser` 缺失 | 生产构建失败 | `--save-dev terser` |
| 8 | macOS lock 文件 | Linux CI npm 失败 | Docker 内自行生成 |
| 9 | DDL INSERT 缺列 | `Field doesn't have default` | 列清单对齐表结构 |
| 10 | DDL 旧列名 `rule_id` | `Unknown column` | 改为 `dimension_type`+`dimension_value` |
| 11 | `IF NOT EXISTS` for INDEX | MySQL 语法错误 | 去掉 |
| 12 | `image_url` 列缺失 | 匹配引擎 SQL 报错 | ALTER TABLE 补充 |
| 13 | 前端端口 3000:3000 | nginx 内部 80 | 改为 `3000:80` |
| 14 | 旧 cpq-frontend Vite dev | 缺 ruoyi-ui、vite.config | 生产构建 Dockerfile.frontend |
| 15 | UTF-8 BOM | CSV 导入全跳过 | `tail -c +4` |
| 16 | 备份文件名 | `file.yml.0726` | `file.0726.yml` |
| 17 | `tar -C` 目录不存在 | `Cannot open` | 先 `mkdir -p` |
| 18 | `cat >>` 追加 compose | 解析到 volumes 下 | 本地改好覆盖 |
| 19 | ruoyi-ui 遗漏 | 部署不完整 | Dockerfile.frontend 双应用 |
