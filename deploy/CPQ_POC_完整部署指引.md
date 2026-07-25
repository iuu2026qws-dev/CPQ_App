# SmartCPQ POC 测试环境完整部署指引

> 服务器：`8.148.208.235`（阿里云 ECS，root@）
> 部署目录：`/opt/`
> 数据库：`8.133.17.0:3306` / `Ruoyi_CPQ`
> 发布日期：2026-07-26

---

## 部署包概览

本次部署包含 **CPQ App**（Java 后端）和 **CPQ Agent**（AI 智能助手）两部分。

### 所需文件清单

| # | 文件 | 来源 | 大小 | 说明 |
|---|------|------|------|------|
| 1 | `ruoyi-admin.jar` | CPQ_App CI 构建 / 本地 Maven | ~168MB | CPQ App Spring Boot JAR |
| 2 | `cpq-agent-backend.tar.gz` | CPQ_Agent CI Artifact `cpq-agent-backend-image` | ~88MB | Agent 后端 Docker 镜像 |
| 3 | `cpq-agent-frontend.tar.gz` | CPQ_Agent CI Artifact `cpq-agent-frontend-image` | ~25MB | Agent 前端 Docker 镜像（含 nginx） |
| 4 | `docker-compose.yml` | **本地预先改好的最终版** | ~2KB | Docker Compose 编排文件 |
| 5 | `cpq-agent-deploy.tar.gz` | CPQ_Agent CI Artifact `cpq-agent-linux-deploy` | ~1KB | agent-config.yaml |
| 6 | `cpq_poc_ddl.sql` | CPQ_App `sql/` 目录 | ~14KB | 数据库增量脚本 |

### CI Artifact 下载地址

- **CPQ_Agent**：https://github.com/stormyangyf2026/CPQ_Agent/actions
  - 下载 `cpq-agent-backend-image`、`cpq-agent-frontend-image`、`cpq-agent-linux-deploy`
- **CPQ_App JAR**：https://github.com/iuu2026qws-dev/CPQ_App/actions
  - 下载 `cpq-app-jar`

---

## 阶段一：本地准备（一次性）

### 1.1 下载 CI Artifact 并解压

**目的**：获取最新构建的 Docker 镜像和配置文件

**操作**：
```bash
# 在本机创建部署目录
mkdir -p ~/Desktop/deploy-v5

# 下载 3 个 CI zip 文件到该目录，解压
cd ~/Desktop/deploy-v5
unzip cpq-agent-backend-image.zip      # → cpq-agent-backend.tar.gz
unzip cpq-agent-frontend-image.zip     # → cpq-agent-frontend.tar.gz
unzip cpq-agent-linux-deploy.zip       # → cpq-agent-deploy.tar.gz（含 agent-config.yaml）
```

**验证**：`ls -lh *.tar.gz` 应看到 3 个文件，大小分别约 88MB、25MB、1KB

---

### 1.2 准备 ruoyi-admin.jar

**目的**：获取 CPQ App 最新可执行 JAR

**方式 A — 从 CI 下载**（推荐）：
下载 `cpq-app-jar` Artifact，解压得到 `ruoyi-admin.jar`

**方式 B — 本地 Maven 构建**：
```bash
cd ~/Desktop/CPQ_App
# 注意：目录名含空格，需要先重命名
mv "ruoyi-admin 2" ruoyi-admin && mv "ruoyi-common 2" ruoyi-common
sed -i '' 's/ruoyi-admin 2/ruoyi-admin/g;s/ruoyi-common 2/ruoyi-common/g' pom.xml ruoyi-modules/pom.xml
mvn clean package -DskipTests -q
cp ruoyi-admin/target/ruoyi-admin.jar ~/Desktop/deploy-v5/
```

**验证**：`ls -lh ~/Desktop/deploy-v5/ruoyi-admin.jar` 约 168MB

---

### 1.3 准备 docker-compose.yml

**目的**：在本地准备好最终的 docker-compose.yml，服务器端直接覆盖，零手动编辑

**操作**：从服务器获取原始 docker-compose.yml，按以下 diff 修改后放到 `deploy-v5/`：

**修改点 1**：`cpq-backend` 的 `volumes` 段增加 JAR 挂载
```yaml
    volumes:
      - ./application-dev.yml:/app/config/application-dev.yml
      - ./deploy-v5/ruoyi-admin.jar:/app/ruoyi-admin.jar    # ★ 必须覆盖容器实际启动的JAR文件名
```

**修改点 2**：在 `cpq-frontend` 服务之后、`volumes:` 顶级节点之前，插入两个 Agent 服务
```yaml
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
      - ./agent-config/config.yaml:/config/config.yaml    # ★ 注意路径是 /config
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
```

> **关键坑点**：
> - Config 挂载目标路径是 `/config/config.yaml`，不是 `/app/config/config.yaml`
> - Agent 前端无需 volume 挂载静态文件（已内嵌在镜像中）
> - 不要用 `cat >>` 追加（会追加到 `volumes:` 下面导致 YAML 解析错误）

**验证**：`docker compose -f ~/Desktop/deploy-v5/docker-compose.yml config` 无报错

---

### 1.4 检查 DDL 脚本

**目的**：确认数据库增量脚本与服务器表结构兼容

**常见坑点**（本次已修复）：
- INSERT 语句列的 **数量和名称** 必须和实际表结构一致
- MySQL **不支持** `CREATE INDEX IF NOT EXISTS`（MariaDB/PostgreSQL 才支持）
- `cpq_approval_rule` 表有 `approval_chain_json json NOT NULL`（**无默认值**），INSERT 必须包含该列
- `cpq_product_model` 匹配引擎代码需要 `image_url` 列，DB 可能缺失，需 ALTER TABLE 补充

**验证**：在服务器上 `grep -n "CREATE INDEX.*IF NOT EXISTS" /opt/deploy-v5/cpq_poc_ddl.sql` 无输出则正确

---

### 1.5 确认 deploy-v5 目录完整

```bash
ls -lh ~/Desktop/deploy-v5/
```

预期输出：
```
cpq-agent-backend.tar.gz   ~88MB
cpq-agent-frontend.tar.gz  ~25MB
cpq-agent-deploy.tar.gz    ~1KB
docker-compose.yml         ~2KB
ruoyi-admin.jar            ~168MB
cpq_poc_ddl.sql            ~14KB
```

---

## 阶段二：上传到服务器

### 2.1 上传整目录

**目的**：将所有部署文件传输到服务器

**操作**：
```bash
scp -r ~/Desktop/deploy-v5 root@8.148.208.235:/opt/
```

**验证**：
```bash
ssh root@8.148.208.235 "ls -lh /opt/deploy-v5/"
# 确认 6 个文件都在，大小正常
```

---

## 阶段三：加载 Docker 镜像

### 3.1 加载 Agent 镜像

**目的**：将离线导出的 Docker 镜像导入服务器本地镜像库。这两个镜像分别包含：
- Backend：Python Agent 运行时（FastAPI + DeepSeek + CPQ 工具链）
- Frontend：Nginx + 编译好的 Vue 前端静态文件 + API 反向代理配置

**操作**：
```bash
cd /opt/deploy-v5
docker load < cpq-agent-backend.tar.gz
docker load < cpq-agent-frontend.tar.gz
```

**验证**：
```bash
docker images | grep cpq_agent
```
应看到两行：
```
ghcr.io/stormyangyf2026/cpq_agent/cpq-backend   latest   ...
ghcr.io/stormyangyf2026/cpq_agent/cpq-frontend  latest   ...
```

---

## 阶段四：配置部署

### 4.1 部署 Agent 配置文件

**目的**：把 Agent 的 config.yaml（含 DeepSeek API Key、CPQ 连接地址等）放到宿主机的 `/opt/agent-config/`，通过 Docker volume 挂载到容器内 `/config/config.yaml`

**操作**：
```bash
mkdir -p /opt/agent-config /opt/agent-data
cd /opt/deploy-v5
mkdir -p /tmp/agent-deploy
tar xzf cpq-agent-deploy.tar.gz -C /tmp/agent-deploy
cp /tmp/agent-deploy/agent-config.yaml /opt/agent-config/config.yaml   # 覆盖旧文件输 y
```

**验证**：
```bash
cat /opt/agent-config/config.yaml
```
应看到 `model:`、`cpq:`、`agent:` 等配置段，`cpq.base_url` 为 `http://cpq-backend:30000`

---

### 4.2 确认 CPQ App 数据库配置

**目的**：确认 application-dev.yml 中数据库连接信息正确

**操作**：
```bash
grep -E 'url:|username:|password:|host:' /opt/application-dev.yml
```

**验证**：确认指向 `8.133.17.0:3306` / `Ruoyi_CPQ` / `root` / `Celnet2025.QY`

---

## 阶段五：备份 & 停服

### 5.1 备份

**目的**：停服前保留旧 JAR、docker-compose.yml、数据库快照，以便回滚

**操作**：
```bash
cd /opt
mkdir -p /opt/backup

# 备份旧 JAR（容器内文件名是 ruoyi-admin.jar，不是 app.jar）
docker cp cpq-backend:/app/ruoyi-admin.jar /opt/backup/ruoyi-admin.$(date +%m%d_%H%M).jar 2>/dev/null || echo "跳过JAR备份"

# 备份 compose 文件（日期放在 .yml 前）
cp docker-compose.yml /opt/backup/docker-compose.$(date +%m%d_%H%M).yml

# 备份数据库（可选但强烈建议）
mysqldump -h 8.133.17.0 -u root -pCelnet2025.QY Ruoyi_CPQ --no-tablespaces \
  > /opt/backup/db_$(date +%m%d_%H%M).sql 2>/dev/null || echo "跳过DB备份"
```

**验证**：
```bash
ls -lh /opt/backup/
```
应看到 `.jar`、`.yml`、`.sql` 三个备份文件

---

### 5.2 停止所有服务

**目的**：停止所有运行中的容器，准备更新

**操作**：
```bash
cd /opt
docker compose down
```

**验证**：
```bash
docker compose ps
```
应显示所有容器状态为 `exited` 或无输出

---

## 阶段六：覆盖配置 & 启动

### 6.1 覆盖 docker-compose.yml

**目的**：用本地预先改好的 docker-compose.yml 替换服务器上的旧版本，一步完成 JAR 挂载和 Agent 服务追加

**操作**：
```bash
# 再备份一次当前版本（安全起见）
cp /opt/docker-compose.yml /opt/backup/docker-compose.$(date +%m%d_%H%M).yml

# 覆盖
cp /opt/deploy-v5/docker-compose.yml /opt/docker-compose.yml
```

**验证**：
```bash
grep "cpq-agent-backend" /opt/docker-compose.yml    # 应有输出
grep "cpq-agent-frontend" /opt/docker-compose.yml   # 应有输出
grep "deploy-v5/ruoyi-admin.jar" /opt/docker-compose.yml  # 应有输出
grep "/config/config.yaml" /opt/docker-compose.yml  # ★ 确认是 /config，不是 /app/config
```

---

### 6.2 启动所有服务

**目的**：启动全部 5 个容器（redis + cpq-backend + cpq-frontend + cpq-agent-backend + cpq-agent-frontend）

**操作**：
```bash
cd /opt
docker compose up -d
```

**验证**：等待 90 秒后检查
```bash
sleep 90
docker compose ps
```
预期 5 个容器全部 `Up`，`cpq-redis` 为 `healthy`。刚启动时 `cpq-backend` 和 `cpq-agent-backend` 可能显示 `unhealthy`，等待健康检查通过即可。

---

## 阶段七：数据库增量

### 7.1 执行增量 DDL

**目的**：将评分匹配引擎、审批规则等新表和数据写入数据库

**操作**：
```bash
mysql -h 8.133.17.0 -u root -pCelnet2025.QY Ruoyi_CPQ --force \
  < /opt/deploy-v5/cpq_poc_ddl.sql 2>&1 | grep -v "Duplicate entry"
```

> `--force` 让 MySQL 遇到重复主键错误时继续执行（不影响已存在的数据）
> `grep -v "Duplicate entry"` 过滤掉重复键的 warning，只显示真正的错误

**验证**：
```bash
# 确认关键表和数据已存在
mysql -h 8.133.17.0 -u root -pCelnet2025.QY Ruoyi_CPQ \
  -e "SELECT COUNT(*) AS dims FROM cpq_dimension_def;
      SELECT COUNT(*) AS weights FROM cpq_scoring_weight;
      SELECT COUNT(*) AS mappings FROM cpq_dimension_attr_mapping;
      SELECT COUNT(*) AS configs FROM cpq_match_config;
      SELECT COUNT(*) AS rules FROM cpq_approval_rule;
      SELECT COUNT(*) AS matrix FROM cpq_approval_matrix;"
```

预期输出：
```
dims: 6
weights: 6
mappings: 9
configs: 5
rules: 1
matrix: 1
```

---

## 阶段八：验证

### 8.1 验证 CPQ App（Java 后端）

**操作**：
```bash
# HTTP 可达性
curl -s -o /dev/null -w "HTTP状态: %{http_code}\n" http://127.0.0.1:2999/

# 登录认证
curl -s -X POST http://127.0.0.1:2999/auth/login \
  -H 'Content-Type: application/json' \
  -d '{"username":"admin","password":"admin123","clientId":"e5cd7e4891bf95d1d19206ce24a7b32e","grantType":"password","tenantId":"000000"}'
```

**验证**：第一条返回 `200`，第二条返回 JSON 含 `access_token`

### 8.2 验证 Agent 后端

**操作**：
```bash
curl -s http://127.0.0.1:58100/health | python3 -m json.tool
```

**验证**：
```json
{
    "status": "ok",
    "cpq": {
        "status": "ok",
        "message": "CPQ 服务可达 (http://cpq-backend:30000)"
    },
    "agent": {
        "status": "ok",
        "message": "DeepAgents"
    }
}
```
- `cpq.status` 必须为 `"ok"` — 说明 Agent 能连通 CPQ App
- 如果 `cpq.status` 为 `"error"`，先确认 cpq-backend 容器已启动且 healthy

### 8.3 验证 Agent 前端

**操作**：
```bash
# 检查 HTML 是否正常返回
curl -s http://127.0.0.1:57100 | head -3
```

**验证**：输出应包含 `<!doctype html>` 和 `<html lang="zh-CN">`

### 8.4 浏览器验证

在浏览器访问：
- **Agent 前端**：`http://8.148.208.235:57100`
- **CPQ Admin**：`http://8.148.208.235:2999`

发送消息测试 Agent 对话功能（如输入"你好"或"ER14250"）。

---

## 阶段九：常见问题排查

### Q1：cpq-backend 一直 unhealthy

```bash
docker compose logs cpq-backend --tail 50
```
常见原因：
- JAR 文件不存在或路径错误
- 数据库连接失败
- application-dev.yml 配置错误

### Q2：cpq-agent-backend 启动后报 `Missing credentials`

检查：`cat /opt/agent-config/config.yaml | grep api_key`
确认 api_key 不为空。

另外确认 docker-compose 中 config 挂载路径为 `/config/config.yaml`（不是 `/app/config/config.yaml`）。

### Q3：浏览器访问 57100 能加载页面但对话无响应

打开浏览器 F12 → Network 标签，发送消息后查看 `/agent/chat` 请求：
- 如果请求发到了 `localhost:58100`：前端镜像版本过旧，需要重新拉取 `cpq-frontend:latest`
- 如果请求返回 502/504：nginx 无法连接 `cpq-agent-backend:58100`，确认后端容器 running

### Q4：DDL 脚本执行报错

常见错误及修复：

| 错误 | 原因 | 修复 |
|------|------|------|
| `Field 'xxx' doesn't have a default value` | INSERT 缺少 NOT NULL 列 | 在 INSERT 列清单中补全该列 |
| `Unknown column 'xxx'` | 表结构已变更，列名/列不存在 | 查 `SHOW COLUMNS FROM 表名`，修正列名 |
| `syntax error near 'IF NOT EXISTS'` | MySQL 不支持 `CREATE INDEX IF NOT EXISTS` | 改为 `CREATE INDEX` |
| `Duplicate entry` | 数据已存在 | 安全，可忽略（`--force` 自动跳过） |

### Q5：完全回滚

```bash
cd /opt
docker compose down
cp /opt/backup/docker-compose.XXXXXX.yml /opt/docker-compose.yml
docker compose up -d
```

---

## 部署坑点速查表

| # | 坑 | 现象 | 正确做法 |
|---|------|------|------|
| 1 | Docker Hub 离线 | `nginx:alpine` 拉取超时 | 前端静态文件内嵌到 Docker 镜像，走 ghcr.io |
| 2 | Config 挂载路径 | `no config file found` → `Missing credentials` | 挂载到 `/config/config.yaml`（非 `/app/config/config.yaml`） |
| 3 | 前端 API 地址 | 页面能打开，对话无响应 | nginx 反向代理 + 空 BASE_URL（同源请求） |
| 4 | `cat >>` 追加 compose | 服务被解析为 volumes 子属性，`docker compose up` 失败 | 本地改好 docker-compose.yml，直接覆盖 |
| 5 | JAR 容器内文件名 | `docker cp` 找不到 `/app/app.jar` | 容器启动命令用 `ruoyi-admin.jar`，挂载必须覆盖原名 |
| 6 | DDL INSERT 缺列 | `Field 'approval_chain_json' doesn't have a default value` | INSERT 列清单与表结构对齐 |
| 7 | `CREATE INDEX IF NOT EXISTS` | MySQL 语法错误 | 去掉 `IF NOT EXISTS` |
| 8 | 备份文件名日期位置 | `docker-compose.yml.0726` 扩展名丢了 | 日期放 `.yml` 前：`docker-compose.0726.yml` |
| 9 | `tar -C` 目录不存在 | `tar: Cannot open: No such file or directory` | 先 `mkdir -p /tmp/agent-deploy` |
| 10 | 匹配引擎 SQL 列表不匹配 | `bad SQL grammar SELECT ... image_url FROM cpq_product_model` | ALTER TABLE 补 `image_url` 列（DDL 中取消注释） |

---

## 部署包内容最终确认

上传前用以下命令确认 `deploy-v5/` 目录完整：

```bash
ls -lh ~/Desktop/deploy-v5/
```

| 文件 | 最小大小 | 说明 |
|------|----------|------|
| `ruoyi-admin.jar` | > 100MB | CPQ App JAR |
| `cpq-agent-backend.tar.gz` | > 50MB | Agent 后端镜像 |
| `cpq-agent-frontend.tar.gz` | > 10MB | Agent 前端镜像 |
| `cpq-agent-deploy.tar.gz` | > 500B | Agent 配置文件 |
| `docker-compose.yml` | > 1KB | Docker 编排 |
| `cpq_poc_ddl.sql` | > 5KB | 数据库增量 |
