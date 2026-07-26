# SmartCPQ 生产环境部署指引 v1

> 服务器：`10.100.111.55`（内网/VPN）
> 用户：`eveuser`（sudo）
> 部署目录：`/opt/`
> Docker Compose 命令：`docker-compose`（带连字符）
> Docker 版本：24.0.6

---

## 一、部署包：`eve-cpq-poc-deploy-0727/`

```
eve-cpq-poc-deploy-0727/
├── ruoyi-admin.jar              ← CPQ_App CI: cpq-app-jar
├── cpq-frontend.tar.gz          ← CPQ_App CI: cpq-frontend-image
├── cpq-agent-backend.tar.gz     ← CPQ_Agent CI: cpq-agent-backend-image
├── cpq-agent-frontend.tar.gz    ← CPQ_Agent CI: cpq-agent-frontend-image
├── agent-config.yaml            ← ★ 生产版（Qwen3 + 内网 API）
├── docker-compose.yml           ← ★ 生产版（xybot-redis + 生产DB + Agent）
├── application-dev.yml          ← 生产 DB 配置（从服务器获取）
└── cpq_poc_ddl.sql              ← 幂等版（INSERT IGNORE + IF NOT EXISTS）
```

**CI 下载地址：**
- CPQ_App：https://github.com/iuu2026qws-dev/CPQ_App/actions → `cpq-app-jar` + `cpq-frontend-image`
- CPQ_Agent：https://github.com/stormyangyf2026/CPQ_Agent/actions → `cpq-agent-backend-image` + `cpq-agent-frontend-image` + `cpq-agent-linux-deploy`

**本地准备好的文件**（无需 CI）：
- `docker-compose.yml` — 见附录 A
- `agent-config.yaml` — Qwen3 + 内网 API
- `application-dev.yml` — 从生产服务器 `/opt/application-dev.yml` 取得，确认 DB 配置
- `cpq_poc_ddl.sql` — 幂等处理后的版本

---

## 二、部署前确认

```bash
# SSH 到生产服务器（需 VPN/内网）
ssh eveuser@10.100.111.55

# 确认 Docker 版本
docker --version        # 24.0.6
docker-compose --version # v2.25.0

# 确认当前服务状态
cd /opt
docker-compose ps

# 确认磁盘空间
df -h /opt
```

---

## 三、阶段 1：上传部署包

本机执行（通过 VPN 连接后）：

```bash
scp -r ~/Desktop/eve-cpq-poc-deploy-0727 eveuser@10.100.111.55:/opt/
```

**验证**：
```bash
ssh eveuser@10.100.111.55 "ls -lh /opt/eve-cpq-poc-deploy-0727/"
```

---

## 四、阶段 2：加载 Docker 镜像

```bash
cd /opt/eve-cpq-poc-deploy-0727

# Agent 镜像（离线导入）
docker load < cpq-agent-backend.tar.gz
docker load < cpq-agent-frontend.tar.gz

# CPQ 前端镜像（cpq-portal + ruoyi-ui）
docker load < cpq-frontend.tar.gz
```

**验证**：
```bash
docker images | grep -E "cpq-frontend|cpq_agent"
# 应看到 3 个镜像
```

---

## 五、阶段 3：部署 Agent 配置

生产版 agent-config.yaml 已直接在部署包里，直接复制即可：

```bash
mkdir -p /opt/agent-config /opt/agent-data
cp /opt/eve-cpq-poc-deploy-0727/agent-config.yaml /opt/agent-config/config.yaml
```

**验证**：
```bash
grep -E "model_name|base_url|api_key" /opt/agent-config/config.yaml
# model_name: Qwen3-235B-A22B-w8a8
# base_url: https://ai-pool.evebattery.com/v1
# 确认 cpq.base_url: http://cpq-backend:30000
```

---

## 六、阶段 4：备份 & 停服

```bash
cd /opt
mkdir -p /opt/backup

# 备份 JAR
docker cp cpq-backend:/app/ruoyi-admin.jar /opt/backup/ruoyi-admin.$(date +%m%d_%H%M).jar 2>/dev/null || echo "跳过JAR备份"

# 备份 compose
cp docker-compose.yml /opt/backup/docker-compose.$(date +%m%d_%H%M).yml

# 备份数据库（可选）
mysqldump -h 10.100.111.48 -u yhs_data_uat -p'Zc8!jS5&mE4#' dm_app_yhs_safe --no-tablespaces \
  > /opt/backup/db_$(date +%m%d_%H%M).sql 2>/dev/null || echo "跳过DB备份"

# 停服
docker-compose down
```

**验证**：
```bash
ls -lh /opt/backup/
docker-compose ps -a
```

---

## 七、阶段 5：覆盖配置 & 启动

### 7.1 覆盖 compose

```bash
cp /opt/eve-cpq-poc-deploy-0727/docker-compose.yml /opt/docker-compose.yml
```

**验证**：
```bash
grep -E "cpq-agent|ruoyi-admin.jar|eve-cpq-poc-deploy-0727|xybot-redis" /opt/docker-compose.yml
# 确认：Agent 服务存在、JAR 挂载路径正确、redis 为 xybot-redis
grep "/config/config.yaml" /opt/docker-compose.yml
# 确认：/config/config.yaml（不是 /app/config）
```

### 7.2 确认 application-dev.yml

```bash
grep -E "url:|username:|password:" /opt/application-dev.yml
# 确认指向 10.100.111.48 / dm_app_yhs_safe
```

### 7.3 启动

```bash
cd /opt && docker-compose up -d
sleep 90
docker-compose ps
```

**验证**：5 个容器全部 `Up`

---

## 八、阶段 6：数据库增量

```bash
mysql -h 10.100.111.48 -u yhs_data_uat -p'Zc8!jS5&mE4#' dm_app_yhs_safe \
  < /opt/eve-cpq-poc-deploy-0727/cpq_poc_ddl.sql 2>&1 | grep -v "already exists\|Duplicate"
```

> DDL 已做幂等处理：`CREATE TABLE IF NOT EXISTS` + `INSERT IGNORE` + 列/索引存在判断。可安全重复执行。

---

## 九、阶段 7：验证

### 9.1 服务健康检查

```bash
# CPQ 后端
curl -s -o /dev/null -w "CPQ: %{http_code}\n" http://127.0.0.1:2999/

# cpq-portal 前端
curl -s -o /dev/null -w "Portal: %{http_code}\n" http://127.0.0.1:3000/

# ruoyi-ui 管理后台
curl -s -o /dev/null -w "Admin: %{http_code}\n" http://127.0.0.1:5173/

# Agent 后端
curl -s http://127.0.0.1:58100/health | python3 -m json.tool

# Agent 前端
curl -s -o /dev/null -w "Agent FE: %{http_code}\n" http://127.0.0.1:57100/
```

### 9.2 匹配引擎

```bash
TOKEN=$(curl -s -X POST http://127.0.0.1:2999/auth/login \
  -H 'Content-Type: application/json' \
  -d '{"username":"admin","password":"admin123","clientId":"e5cd7e4891bf95d1d19206ce24a7b32e","grantType":"password","tenantId":"000000"}' \
  | python3 -c "import sys,json; print(json.load(sys.stdin)['data']['access_token'])")

curl -s -X POST http://127.0.0.1:2999/cpq/match/score \
  -H "Authorization: Bearer $TOKEN" \
  -H "clientid: e5cd7e4891bf95d1d19206ce24a7b32e" \
  -H 'Content-Type: application/json' \
  -d '{"categoryId":507,"requirements":{"usageType":"测试"}}' | python3 -c "import sys,json; d=json.load(sys.stdin); print('score count:', len(d.get('data',{}).get('recommendations',[])))" 2>/dev/null || echo "match API check done"
```

### 9.3 浏览器验证（需 VPN）

| 页面 | URL |
|------|-----|
| 业务前端 | `http://10.100.111.55:3000` |
| 管理后台 | `http://10.100.111.55:5173` |
| Agent 助手 | `http://10.100.111.55:57100` |

---

## 十、回滚

```bash
cd /opt
docker-compose down
cp /opt/backup/docker-compose.XXXXXX.yml /opt/docker-compose.yml
docker-compose up -d
```

---

## 附录A：docker-compose.yml

```yaml
version: '3.8'

services:
  cpq-redis:
    image: xybot-redis:7.2.4.private
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
      - MYSQL_HOST=10.100.111.48
      - MYSQL_PORT=3306
      - MYSQL_DATABASE=dm_app_yhs_safe
      - MYSQL_USER=yhs_data_uat
      - MYSQL_PASSWORD=Zc8!jS5&mE4#
      - REDIS_HOST=cpq-redis
      - REDIS_PORT=6379
      - REDIS_PASSWORD=ruoyi123
      - JAVA_OPTS=-Xms512m -Xmx2g
      - TZ=Asia/Shanghai
    ports:
      - "2999:30000"
    depends_on:
      cpq-redis:
        condition: service_started
    restart: unless-stopped
    volumes:
      - ./application-dev.yml:/app/config/application-dev.yml
      - ./eve-cpq-poc-deploy-0727/ruoyi-admin.jar:/app/ruoyi-admin.jar
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
      - "3000:80"       # cpq-portal
      - "5173:5173"     # ruoyi-ui
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

## 附录B：生产环境端口

| 端口 | 服务 | 说明 |
|------|------|------|
| 2999 | cpq-backend | CPQ App 后端 |
| 3000 | cpq-frontend :80 | cpq-portal 业务前端 |
| 5173 | cpq-frontend :5173 | ruoyi-ui 管理后台 |
| 58100 | cpq-agent-backend | Agent Python 后端 |
| 57100 | cpq-agent-frontend :80 | Agent 前端 (nginx + API 反代) |
| 6379 | cpq-redis | Redis |

## 附录C：测试 vs 生产差异速查

| 配置 | 测试 | 生产 |
|------|------|------|
| 服务器 | 8.148.208.235 | 10.100.111.55 |
| 用户 | root | eveuser |
| Compose 命令 | `docker compose` | `docker-compose` |
| Redis 镜像 | redis:7-alpine | xybot-redis:7.2.4.private |
| DB | 8.133.17.0 / Ruoyi_CPQ | 10.100.111.48 / dm_app_yhs_safe |
| DB 用户 | root | yhs_data_uat |
| AI 模型 | DeepSeek v4-pro | Qwen3-235B |
| AI API | api.deepseek.com | ai-pool.evebattery.com/v1 |
| 网络 | 公网 | 内网/VPN |
| 部署目录 | `/opt/deploy-v5/` | `/opt/eve-cpq-poc-deploy-0727/` |
