# SmartCPQ POC 测试环境部署指引 v4

> 服务器：8.148.208.235 | 部署目录：/opt/

---

## 部署包

在服务器 `/opt/deploy-v4/` 下应有：

| 文件 | 说明 |
|------|------|
| `ruoyi-admin.jar` | CPQ App 新 JAR |
| `cpq-agent-backend.tar.gz` | Agent 后端镜像（zip 解压后） |
| `agent-config.yaml` | Agent 配置（zip 解压后） |
| `agent-frontend/` | Agent 前端静态文件（zip 解压后） |
| `cpq_poc_ddl.sql` | 数据库增量脚本 |

---

## 1. 加载 Agent 镜像

```bash
cd /opt/deploy-v4
docker load < cpq-agent-backend.tar.gz
```

## 2. 部署 Agent 目录

```bash
mkdir -p /opt/agent-config /opt/agent-data
cp /opt/deploy-v4/agent-config.yaml /opt/agent-config/config.yaml
cp -r /opt/deploy-v4/agent-frontend /opt/
```

## 3. 更新 application-dev.yml

在 `/opt/application-dev.yml` 中确认数据库连接正确（已配置则跳过）。

## 4. 备份 + 停止服务

```bash
cd /opt
mkdir -p /opt/backup

# 备份旧 JAR
docker cp cpq-backend:/app/ruoyi-admin.jar /opt/backup/ruoyi-admin.$(date +%m%d_%H%M).jar 2>/dev/null || echo "跳过JAR备份"
# 备份 compose 文件
cp docker-compose.yml /opt/backup/docker-compose.yml.$(date +%m%d_%H%M)
# 备份数据库（可选）
mysqldump -h 8.133.17.0 -u root -pCelnet2025.QY Ruoyi_CPQ --no-tablespaces > /opt/backup/db_$(date +%m%d_%H%M).sql 2>/dev/null || echo "跳过DB备份"

# 停止服务
docker compose down
```

## 5. 更新 JAR + 追加 Agent + 启动

```bash
# 在 cpq-backend 的 volumes 段追加 JAR 挂载
sed -i '/application-dev.yml/a\      - ./deploy-v4/ruoyi-admin.jar:/app/app.jar' /opt/docker-compose.yml

# 追加 Agent 服务（插入到 volumes: 之前，cat >> 会追加到末尾导致 YAML 解析错误）
sed -i '/^volumes:/i\  cpq-agent-backend:\n    image: ghcr.io/stormyangyf2026/cpq_agent/cpq-backend:latest\n    container_name: cpq-agent-backend\n    environment:\n      - PORT=58100\n      - TZ=Asia/Shanghai\n    ports:\n      - "58100:58100"\n    volumes:\n      - ./agent-config/config.yaml:/app/config/config.yaml\n      - ./agent-data:/app/data\n    restart: unless-stopped\n\n  cpq-agent-frontend:\n    image: nginx:alpine\n    container_name: cpq-agent-frontend\n    ports:\n      - "57100:80"\n    volumes:\n      - ./agent-frontend:/usr/share/nginx/html:ro\n    restart: unless-stopped' /opt/docker-compose.yml

cd /opt && docker compose up -d
sleep 90
docker compose ps
```

## 7. 数据库

```bash
mysql -h 8.133.17.0 -u root -pCelnet2025.QY Ruoyi_CPQ < /opt/deploy-v4/cpq_poc_ddl.sql
```

## 8. 启动

```bash
cd /opt
docker compose up -d
sleep 90
docker compose ps
```

## 9. 验证

```bash
curl -s http://127.0.0.1:58100/health | python3 -m json.tool
curl -s -o /dev/null -w "Agent前端: %{http_code}\n" http://127.0.0.1:57100
```

浏览器：`http://8.148.208.235:57100`

---

## 回滚

```bash
cd /opt
docker compose down
# 删掉 docker-compose.yml 中 Agent 相关的行
# 删掉 volumes 中 JAR 挂载行
docker compose up -d
```
