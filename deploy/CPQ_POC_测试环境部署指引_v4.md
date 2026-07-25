# SmartCPQ POC 测试环境部署指引

> 版本：v4.0 | 日期：2026-07-25 | 适用：Rocky Linux 9.x x86_64 + Docker
> 目标服务器：8.148.208.235 | 端口：2999/3000/5173/57100/58100

---

## 一、部署架构（v4 新增 Agent）

```
服务器 8.148.208.235

  Port  容器                    镜像                  说明
  ────  ──────────────────────  ────────────────────  ────────────
  6379  cpq-redis               redis:7-alpine        已有，不动
  2999→ cpq-backend:30000       cpq-backend:latest     ★ 更新 JAR
  3000  cpq-frontend (CPQ门户)   cpq-frontend:latest   ★ 更新
  5173  cpq-frontend (管理后台)   cpq-frontend:latest   ★ 更新
  58100 cpq-agent-backend       agent-backend:latest   ★ 新增
  57100 cpq-agent-frontend      agent-frontend:latest  ★ 新增

外部依赖：MySQL 8.133.17.0:3306 / Ruoyi_CPQ
```

---

## 二、部署前准备（本地一键构建）

### 2.1 构建所有产物

```bash
cd /Users/a1234/Desktop/CPQ_App

# 1. CPQ App JAR
mvn package -pl "ruoyi-admin 2" -am -DskipTests

# 2. CPQ 门户前端
cd cpq-portal && npm run build && cd ..

# 3. Agent 后端镜像
cd ../CPQ_Agent
docker build -t agent-backend:latest -f backend/Dockerfile backend/
docker save agent-backend:latest | gzip > agent-backend.tar.gz

# 4. Agent 前端镜像 (测试环境)
cd frontend && npm run build --mode staging && cd ..
docker build -t agent-frontend:latest -f frontend/Dockerfile frontend/
docker save agent-frontend:latest | gzip > agent-frontend.tar.gz
```

### 2.2 打包上传

```bash
mkdir -p /tmp/deploy-v4
cp "CPQ_App/ruoyi-admin 2/target/ruoyi-admin.jar" /tmp/deploy-v4/
cp -r CPQ_App/cpq-portal/dist /tmp/deploy-v4/cpq-portal-dist
cp CPQ_Agent/agent-backend.tar.gz /tmp/deploy-v4/
cp CPQ_Agent/agent-frontend.tar.gz /tmp/deploy-v4/
cp CPQ_Agent/config/staging/config.yaml /tmp/deploy-v4/agent-config.yaml
cp CPQ_Agent/docker-compose.agent.yml /tmp/deploy-v4/
cp CPQ_App/sql/cpq_poc_ddl.sql /tmp/deploy-v4/

# 上传到服务器
scp -r /tmp/deploy-v4/* root@8.148.208.235:/opt/deploy-v4/
```

---

## 三、停止当前服务

```bash
# SSH 到服务器
ssh root@8.148.208.235

# 进入部署目录
cd /opt/eve-cpq-docker-deploy

# 停止所有容器（保留数据卷）
docker compose down
```

---

## 四、备份当前版本（便于回滚）

```bash
# 备份当前 JAR
cp /opt/eve-cpq-docker-deploy/ruoyi-admin.jar /opt/backup/ruoyi-admin.jar.$(date +%Y%m%d_%H%M%S)

# 备份当前 CPQ 前端
cp -r /opt/eve-cpq-docker-deploy/cpq-portal-dist /opt/backup/cpq-portal-dist.$(date +%Y%m%d_%H%M%S)

# 导出当前数据库（可选的额外保险）
/opt/mysql-client/mysql -h 8.133.17.0 -u root -pCelnet2025.QY Ruoyi_CPQ \
  --skip-column-statistics --no-tablespaces \
  > /opt/backup/db_$(date +%Y%m%d_%H%M%S).sql
```

---

## 五、更新部署

```bash
cd /opt/eve-cpq-docker-deploy

# 1. 更新 CPQ App JAR
cp /opt/deploy-v4/ruoyi-admin.jar ./

# 2. 更新 CPQ 门户前端
rm -rf cpq-portal-dist/*
cp -r /opt/deploy-v4/cpq-portal-dist/* cpq-portal-dist/

# 3. 加载 Agent 镜像
docker load < /opt/deploy-v4/agent-backend.tar.gz
docker load < /opt/deploy-v4/agent-frontend.tar.gz

# 4. 部署 Agent 配置
mkdir -p agent-config agent-data
cp /opt/deploy-v4/agent-config.yaml agent-config/config.yaml

# 5. 合并 Agent Compose（首次执行）
cat /opt/deploy-v4/docker-compose.agent.yml >> docker-compose.yml

# 6. 执行数据库增量（幂等可重复）
/opt/mysql-client/mysql -h 8.133.17.0 -u root -pCelnet2025.QY Ruoyi_CPQ \
  < /opt/deploy-v4/cpq_poc_ddl.sql
```

### 5.7 启动所有服务

```bash
cd /opt/eve-cpq-docker-deploy

# 拉取/重建前端镜像（如果用了本地 Dockerfile）
docker compose up -d

# 等待服务初始化
echo "等待服务启动（90 秒）..."
sleep 90

# 查看状态
docker compose ps
```

---

## 六、健康检查

```bash
# 运行健康检查脚本
bash /opt/smoke-test.sh

# 手动验证新增服务
echo "=== Agent 后端 ==="
curl -s http://127.0.0.1:58100/health | python3 -m json.tool

echo "=== Agent 前端 ==="
curl -s -o /dev/null -w "HTTP %{http_code}" http://127.0.0.1:57100

echo "=== CPQ 后端 ==="
curl -s -o /dev/null -w "HTTP %{http_code}" http://127.0.0.1:2999

echo "=== CPQ 门户 ==="
curl -s -o /dev/null -w "HTTP %{http_code}" http://127.0.0.1:3000
```

期望：全部返回 200/OK。

---

## 七、验证清单

在浏览器访问以下地址，执行功能验证：

| 验证项 | 地址 | 检查点 |
|--------|------|--------|
| CPQ 门户登录 | `http://8.148.208.235:3000` | admin/admin123 登录成功 |
| CPQ 审批中心 | `:3000/approval/pending` | 待审批列表正常显示 |
| CPQ 产品目录 | `:3000/catalog` | 产品列表 + 导入按钮 |
| Agent 前端 | `http://8.148.208.235:57100` | 欢迎页正常，发送消息有回复 |
| Agent 匹配 | 输入"找GPS电池，-40~85度" | 返回产品卡片 |
| Agent 报价 | 选品→审批通过→创建报价 | QTE 报价单生成 |

---

## 八、部署失败如何回滚

### 情况 A：新容器启动失败

```bash
# 停止新容器
docker compose down

# 恢复旧 docker-compose.yml（去掉新增的 Agent 部分）
cp /opt/backup/docker-compose.yml.bak /opt/eve-cpq-docker-deploy/docker-compose.yml

# 启动旧版本
docker compose up -d
```

### 情况 B：新 JAR 报错

```bash
# 停止服务
docker compose down

# 恢复旧 JAR
cp /opt/backup/ruoyi-admin.jar.20260725_* /opt/eve-cpq-docker-deploy/ruoyi-admin.jar

# 启动
docker compose up -d
```

### 情况 C：数据库脚本有问题

```bash
# 如果有备份
/opt/mysql-client/mysql -h 8.133.17.0 -u root -pCelnet2025.QY Ruoyi_CPQ \
  < /opt/backup/db_20260725_*.sql
```

### 完全回滚到 v3 版本

```bash
docker compose down
cp /opt/backup/ruoyi-admin.jar.* /opt/eve-cpq-docker-deploy/ruoyi-admin.jar
cp -r /opt/backup/cpq-portal-dist.* /opt/eve-cpq-docker-deploy/cpq-portal-dist
# 删掉新增的 Agent 相关配置
sed -i '/cpq-agent-backend/,/restart: unless-stopped/d' /opt/eve-cpq-docker-deploy/docker-compose.yml
docker compose up -d
```

---

## 九、故障速查

| 症状 | 可能原因 | 检查命令 |
|------|----------|----------|
| Agent 报 502 | CPQ 连不上 | `docker exec cpq-agent-backend curl http://cpq-backend:30000/health` |
| Agent 前端白屏 | 前端 dist 未替换 | `docker exec cpq-agent-frontend ls /usr/share/nginx/html/` |
| Agent 匹配无结果 | DB 种子数据缺失 | 检查 `cpq_scoring_weight` 表是否有 507 的 7 行 |
| 端口冲突 | 58100/57100 被占用 | `ss -tlnp \| grep -E '57100\|58100'` |
