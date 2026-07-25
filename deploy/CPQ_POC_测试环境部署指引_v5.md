# SmartCPQ POC 测试环境部署指引 v5

> 服务器：8.148.208.235 | 部署目录：/opt/
> **v5 改进**：
> - 前端静态文件内嵌 Docker 镜像，不依赖 Docker Hub（离线可用）
> - `docker-compose.yml` 预先本地改好，服务器端零手动编辑
> - 修复 v4 所有已知 bug

---

## CI Artifacts（GitHub Actions 自动打包）

| Artifact | 内容 | 说明 |
|----------|------|------|
| `cpq-agent-backend-image` | `cpq-agent-backend.tar.gz` | Agent 后端镜像 |
| `cpq-agent-frontend-image` | `cpq-agent-frontend.tar.gz` | Agent 前端镜像（nginx + 静态文件） |
| `cpq-agent-linux-deploy` | `cpq-agent-deploy.tar.gz` | agent-config.yaml |

---

## 部署包（本地整理后上传 `/opt/deploy-v5/`）

| 文件 | 来源 | 说明 |
|------|------|------|
| `docker-compose.yml` | **本地预先改好** | 完整最终版，含 JAR 挂载 + Agent 服务 |
| `ruoyi-admin.jar` | 本地 Maven 构建 | CPQ App 新 JAR |
| `cpq_poc_ddl.sql` | 数据库增量脚本 | — |
| `cpq-agent-backend.tar.gz` | CI Artifact | `docker load` 用 |
| `cpq-agent-frontend.tar.gz` | CI Artifact | `docker load` 用 |
| `cpq-agent-deploy.tar.gz` | CI Artifact | 含 `agent-config.yaml` |

---

## 1. 加载 Docker 镜像

```bash
cd /opt/deploy-v5
docker load < cpq-agent-backend.tar.gz
docker load < cpq-agent-frontend.tar.gz
docker images | grep cpq
```

## 2. 部署 Agent 配置

```bash
mkdir -p /opt/agent-config /opt/agent-data
cd /opt/deploy-v5
tar xzf cpq-agent-deploy.tar.gz -C /tmp/agent-deploy
cp /tmp/agent-deploy/agent-config.yaml /opt/agent-config/config.yaml
```

## 3. 备份 + 停服

```bash
cd /opt
mkdir -p /opt/backup

# 备份 JAR（容器内文件名为 ruoyi-admin.jar）
docker cp cpq-backend:/app/ruoyi-admin.jar /opt/backup/ruoyi-admin.$(date +%m%d_%H%M).jar 2>/dev/null || echo "跳过JAR备份"

# 备份 compose
cp docker-compose.yml /opt/backup/docker-compose.yml.$(date +%m%d_%H%M)

# 备份数据库
mysqldump -h 8.133.17.0 -u root -pCelnet2025.QY Ruoyi_CPQ --no-tablespaces > /opt/backup/db_$(date +%m%d_%H%M).sql 2>/dev/null || echo "跳过DB备份"

# 停服
docker compose down
```

## 4. 替换 docker-compose.yml（本地已改好，直接覆盖）

```bash
cp /opt/docker-compose.yml /opt/backup/docker-compose.$(date +%m%d_%H%M).yml
cp /opt/deploy-v5/docker-compose.yml /opt/docker-compose.yml
```

## 5. 启动

```bash
cd /opt && docker compose up -d
sleep 90
docker compose ps
```

## 6. 数据库增量

```bash
mysql -h 8.133.17.0 -u root -pCelnet2025.QY Ruoyi_CPQ < /opt/deploy-v5/cpq_poc_ddl.sql
```

## 7. 验证

```bash
curl -s http://127.0.0.1:58100/health | python3 -m json.tool
curl -s -o /dev/null -w "Agent前端: %{http_code}\n" http://127.0.0.1:57100
curl -s -o /dev/null -w "CPQ App: %{http_code}\n" http://127.0.0.1:2999/
```

- Agent 前端：`http://8.148.208.235:57100`
- CPQ Admin：`http://8.148.208.235:2999`

---

## 回滚

```bash
cd /opt
docker compose down
cp /opt/backup/docker-compose.yml.0726_XXXX /opt/docker-compose.yml
docker compose up -d
```

---

## v5 vs v4 变化

| 项目 | v4 | v5 |
|------|-----|-----|
| 前端部署 | `nginx:alpine` + volume 挂载静态文件 | `cpq-frontend` 镜像（内嵌） |
| Docker Hub 依赖 | 需要（离线环境拉不到） | 无 |
| compose 修改 | 服务器上 sed/cat 编辑（易出错） | 本地改好直接覆盖 |
| 步骤数 | 9 步 | 7 步 |
