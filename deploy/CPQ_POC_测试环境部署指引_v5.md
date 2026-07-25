# SmartCPQ POC 测试环境部署指引 v5

> 服务器：8.148.208.235 | 部署目录：/opt/
> **v5 改进**：前端静态文件内嵌到 Docker 镜像，不再依赖 Docker Hub 拉取 nginx:alpine，彻底离线可用。

---

## CI Artifacts（GitHub Actions 自动打包）

每次推送自动生成 3 个 Artifact：

| Artifact | 内容 | 说明 |
|----------|------|------|
| `cpq-agent-backend-image` | `cpq-agent-backend.tar.gz` | Agent 后端 Docker 镜像 |
| `cpq-agent-frontend-image` | `cpq-agent-frontend.tar.gz` | Agent 前端 Docker 镜像（nginx + 静态文件） |
| `cpq-agent-linux-deploy` | `cpq-agent-deploy.tar.gz` | 配置文件 + docker-compose.agent.yml |

---

## 部署包准备

将以下文件放入服务器 `/opt/deploy-v5/`：

| 文件 | 来源 |
|------|------|
| `ruoyi-admin.jar` | 本地 `ruoyi-admin/target/` |
| `cpq-agent-backend.tar.gz` | CI Artifact `cpq-agent-backend-image` |
| `cpq-agent-frontend.tar.gz` | CI Artifact `cpq-agent-frontend-image` |
| `cpq-agent-deploy.tar.gz` | CI Artifact `cpq-agent-linux-deploy`（含 agent-config.yaml + docker-compose.agent.yml） |
| `cpq_poc_ddl.sql` | 数据库增量脚本 |

---

## 1. 加载 Docker 镜像

```bash
cd /opt/deploy-v5
docker load < cpq-agent-backend.tar.gz
docker load < cpq-agent-frontend.tar.gz
```

验证：
```bash
docker images | grep cpq
# 应看到 ghcr.io/stormyangyf2026/cpq_agent/cpq-backend 和 cpq-frontend
```

## 2. 部署 Agent 配置

```bash
mkdir -p /opt/agent-config /opt/agent-data
cd /opt/deploy-v5
tar xzf cpq-agent-deploy.tar.gz -C /tmp/agent-deploy
cp /tmp/agent-deploy/agent-config.yaml /opt/agent-config/config.yaml
```

## 3. 确认数据库连接

```bash
grep -E 'url|username|password' /opt/application-dev.yml
# 确认指向 8.133.17.0:3306 / Ruoyi_CPQ / root / Celnet2025.QY
```

## 4. 备份 + 停止服务

```bash
cd /opt
mkdir -p /opt/backup

# 备份旧 JAR（容器内实际文件名为 ruoyi-admin.jar）
docker cp cpq-backend:/app/ruoyi-admin.jar /opt/backup/ruoyi-admin.$(date +%m%d_%H%M).jar 2>/dev/null || echo "跳过JAR备份"

# 备份 compose 文件
cp docker-compose.yml /opt/backup/docker-compose.yml.$(date +%m%d_%H%M)

# 备份数据库（可选）
mysqldump -h 8.133.17.0 -u root -pCelnet2025.QY Ruoyi_CPQ --no-tablespaces > /opt/backup/db_$(date +%m%d_%H%M).sql 2>/dev/null || echo "跳过DB备份"

# 停止服务
docker compose down
```

## 5. 更新 JAR 挂载 + 追加 Agent 服务

```bash
# 在 cpq-backend 的 volumes 段追加 JAR 挂载
sed -i '/application-dev.yml/a\      - ./deploy-v5/ruoyi-admin.jar:/app/app.jar' /opt/docker-compose.yml

# 追加 Agent 服务（用 sed 插入到 volumes: 之前，避免被解析为 volumes 子属性）
sed -i '/^volumes:/i\  cpq-agent-backend:\n    image: ghcr.io/stormyangyf2026/cpq_agent/cpq-backend:latest\n    container_name: cpq-agent-backend\n    environment:\n      - PORT=58100\n      - TZ=Asia/Shanghai\n    ports:\n      - "58100:58100"\n    volumes:\n      - ./agent-config/config.yaml:/app/config/config.yaml\n      - ./agent-data:/app/data\n    restart: unless-stopped\n\n  cpq-agent-frontend:\n    image: ghcr.io/stormyangyf2026/cpq_agent/cpq-frontend:latest\n    container_name: cpq-agent-frontend\n    ports:\n      - "57100:80"\n    restart: unless-stopped' /opt/docker-compose.yml
```

## 6. 启动服务

```bash
cd /opt && docker compose up -d
sleep 90
docker compose ps
```

## 7. 数据库增量

```bash
mysql -h 8.133.17.0 -u root -pCelnet2025.QY Ruoyi_CPQ < /opt/deploy-v5/cpq_poc_ddl.sql
```

## 8. 验证

```bash
# Agent 后端健康检查
curl -s http://127.0.0.1:58100/health | python3 -m json.tool

# Agent 前端可达性
curl -s -o /dev/null -w "Agent前端: %{http_code}\n" http://127.0.0.1:57100

# CPQ App 健康检查
curl -s -o /dev/null -w "CPQ App: %{http_code}\n" http://127.0.0.1:2999/
```

浏览器访问：
- Agent 前端：`http://8.148.208.235:57100`
- CPQ Admin：`http://8.148.208.235:2999`

---

## 回滚

```bash
cd /opt
docker compose down
# 从备份恢复 docker-compose.yml
cp /opt/backup/docker-compose.yml.0714_XXXX /opt/docker-compose.yml
# 删掉 volumes 中 JAR 挂载行
# 删掉 Agent 服务段
docker compose up -d
```

---

## v5 vs v4 变化

| 项目 | v4 | v5 |
|------|-----|-----|
| Agent 前端部署方式 | `nginx:alpine` + volume 挂载静态文件 | `cpq-frontend` 镜像（nginx+静态文件内嵌） |
| Docker Hub 依赖 | 需要拉取 `nginx:alpine` | 无需（已内嵌到 ghcr.io 镜像） |
| Docker 镜像数 | 1 个（仅 backend） | 2 个（backend + frontend） |
| 前端文件部署 | `cp -r agent-frontend /opt/` | 不需要（已在镜像内） |
| docker-compose 追加方式 | `cat >>` (有 bug) | `sed` 插入到 volumes: 之前 |
| JAR 备份名 | `app.jar` (不存在) | `ruoyi-admin.jar` (正确) |
| 备份目录 | 未创建 `/opt/backup` | 显式 `mkdir -p /opt/backup` |
