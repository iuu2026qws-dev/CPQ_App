# CPQ 部署指南 + 快速入门（S21.7）

## 前置条件

- Docker 24+ & Docker Compose v2+
- 或：JDK 17+ / Node 18+ / MySQL 8.0+ / Redis 6.0+ / Maven 3.8+
- 最低配置：4 核 CPU / 8GB RAM / 50GB 磁盘

## Docker Compose 一键部署

```bash
# 1. 克隆代码
git clone <repo-url> cpq && cd cpq

# 2. 配置环境变量
cp .env.example .env
# 编辑 .env 修改数据库密码、JWT 密钥等

# 3. 初始化数据库
docker compose up -d mysql redis
sleep 15
cat sql/cpq_init_all.sql | docker compose exec -T mysql mysql -u root -p"${DB_PASSWORD}" Ruoyi_CPQ

# 4. 启动所有服务
docker compose up -d

# 5. 验证
curl http://localhost:8080/health
curl http://localhost:3000
```

## 手动部署

### 后端
```bash
cd ruoyi-admin\ 2
mvn clean package -DskipTests
java -jar target/ruoyi-admin.jar --server.port=8080 --spring.profiles.active=prod
```

### 前端
```bash
cd cpq-portal
npm ci
npm run build
# 将 dist/ 部署到 Nginx 或任何静态文件服务器
```

## 服务地址

| 服务 | 地址 | 默认端口 |
|------|------|:---:|
| CPQ Portal | https://cpq.example.com | 443/80 |
| Admin Portal | https://cpq.example.com/admin | — |
| Swagger API | https://cpq.example.com/swagger-ui/ | — |
| Knife4j | https://cpq.example.com/doc.html | — |
| Spring Boot Admin | http://localhost:9090 | 9090 |
| Grafana | http://localhost:3001 | 3001 |

## 快速验证

```bash
# 1. 登录获取 Token
TOKEN=$(curl -s -X POST http://localhost:8080/auth/login \
  -H 'Content-Type: application/json' \
  -H 'clientid: e5cd7e4891bf95d1d19206ce24a7b32e' \
  -d '{"clientId":"e5cd7e4891bf95d1d19206ce24a7b32e","grantType":"password","username":"admin","password":"admin123","tenantId":"000000"}' \
  | python3 -c "import sys,json; print(json.load(sys.stdin)['data']['access_token'])")

# 2. 测试 API
curl http://localhost:8080/cpq/product/catalog/list \
  -H "Authorization: Bearer $TOKEN" \
  -H 'clientid: e5cd7e4891bf95d1d19206ce24a7b32e'

# 3. 打开 Swagger
open http://localhost:8080/doc.html
```
