# CPQ 运维手册（S21.6 / S21.7）

## 1. 系统架构

```
┌─────────────┐    ┌──────────────┐    ┌─────────────────┐
│  Nginx      │───▶│  cpq-portal   │───▶│  ruoyi-admin     │
│  (SSL/反代) │    │  (Vue3 SPA)  │    │  (Spring Boot)  │
└─────────────┘    └──────────────┘    └────────┬────────┘
                                                │
                          ┌─────────────────────┼──────────────┐
                          │                     │              │
                    ┌─────▼─────┐    ┌───────▼──────┐  ┌─────▼─────┐
                    │  MySQL     │    │  Redis        │  │  MinIO    │
                    │  8.0+      │    │  6.0+         │  │  OSS      │
                    └───────────┘    └──────────────┘  └───────────┘
```

## 2. 启动 / 停止

### 2.1 Docker Compose 一键启动
```bash
cd /opt/cpq
docker compose up -d
```

### 2.2 停止
```bash
docker compose down
```

### 2.3 重启单个服务
```bash
docker compose restart ruoyi-admin
docker compose restart cpq-portal
```

### 2.4 查看日志
```bash
# 查看所有服务日志
docker compose logs -f

# 只看后端
docker compose logs -f ruoyi-admin

# 只看 Nginx
docker compose logs -f nginx
```

## 3. 备份 / 恢复

### 3.1 数据库备份（每日定时）
```bash
# crontab: 0 2 * * * /opt/cpq/scripts/backup-db.sh
mysqldump -h 127.0.0.1 -u root -p'Storm123@' \
  --single-transaction --routines --triggers \
  Ruoyi_CPQ | gzip > /backup/cpq_$(date +%Y%m%d).sql.gz

# 保留最近 30 天
find /backup/ -name 'cpq_*.sql.gz' -mtime +30 -delete
```

### 3.2 数据库恢复
```bash
gunzip < /backup/cpq_20260609.sql.gz | mysql -h 127.0.0.1 -u root -p'Storm123@' Ruoyi_CPQ
```

### 3.3 Redis 备份（自动 RDB）
```bash
# Redis 配置中已启用：save 900 1 300 10 60 10000
# 备份文件位置：/data/redis/dump.rdb
cp /data/redis/dump.rdb /backup/redis_$(date +%Y%m%d).rdb
```

### 3.4 MinIO 备份
```bash
mc mirror minio/cpq-bucket /backup/minio/
```

## 4. 扩容 / 缩容

### 4.1 水平扩容后端
```bash
# docker-compose.yml 中增加实例
docker compose up -d --scale ruoyi-admin=3
```

### 4.2 Nginx 负载均衡
```nginx
upstream cpq_backend {
    least_conn;
    server ruoyi-admin-1:8080 weight=1;
    server ruoyi-admin-2:8080 weight=1;
    server ruoyi-admin-3:8080 weight=1;
}
```

### 4.3 Redis 主从
```bash
# 从节点配置
cp redis-slave.conf /data/redis-slave/
docker compose up -d redis-slave
```

## 5. 回滚

### 5.1 Docker 镜像回滚
```bash
# 查看历史版本
docker images cpq-backend --format '{{.Tag}} {{.CreatedAt}}'

# 回滚到指定版本
docker tag registry.example.com/cpq-backend:v1.4.0 registry.example.com/cpq-backend:latest
docker compose up -d ruoyi-admin
```

### 5.2 数据库回滚
```bash
# 从最近备份恢复
gunzip < /backup/cpq_20260609.sql.gz | mysql -u root -p Ruoyi_CPQ
```

## 6. 故障排查

### 6.1 后端无法启动
```bash
# 检查日志
docker compose logs ruoyi-admin --tail 100

# 常见问题：
# - 数据库连接失败 → 检查 MySQL 是否运行、网络是否畅通
# - 端口占用 → lsof -i :8080
# - JVM OOM → 增加内存 docker compose 中 JAVA_OPTS=-Xmx2g
# - Redis 连接失败 → 检查 Redis 是否运行、密码是否正确
```

### 6.2 前端白屏
```bash
# 检查 Nginx 日志
docker compose logs nginx

# 验证 API 可达性
curl http://localhost:8080/health

# 强制刷新构建
cd cpq-portal && npm run build && docker compose restart cpq-portal
```

### 6.3 数据库慢查询
```bash
# 查看慢查询日志
mysql -u root -p -e "SHOW VARIABLES LIKE 'slow_query%';"

# 开启慢查询日志（1s 阈值）
mysql -u root -p -e "SET GLOBAL slow_query_log=ON; SET GLOBAL long_query_time=1;"

# 分析慢查询
mysqldumpslow /var/log/mysql/slow-query.log -t 10
```

### 6.4 Redis 内存不足
```bash
# 检查内存使用
redis-cli INFO memory | grep used_memory_human

# 设置最大内存策略
redis-cli CONFIG SET maxmemory 2gb
redis-cli CONFIG SET maxmemory-policy allkeys-lru
```

## 7. 监控指标（S20.5）

### 7.1 关键指标
| 指标 | 目标 | 告警阈值 |
|------|------|---------|
| API 延迟 (P95) | <500ms | >2s |
| 吞吐量 | >100 QPS | <50 QPS |
| 错误率 | <0.1% | >1% |
| DB 连接池 | <80% | >90% |
| Redis 命中率 | >95% | <80% |
| JVM 堆使用 | <80% | >90% |

### 7.2 健康检查端点
```bash
# 应用健康
curl http://localhost:8080/actuator/health
# Spring Boot Admin
curl http://localhost:9090/actuator/health
# 数据库连接池
curl http://localhost:8080/actuator/metrics/hikaricp.connections.active
# Redis 连接
curl http://localhost:8080/actuator/metrics/redis.connections.cluster
```

## 8. 安全

### 8.1 SSL 证书续期
```bash
certbot renew --nginx --post-hook "docker compose exec nginx nginx -s reload"
```

### 8.2 防火墙
```bash
ufw allow 443/tcp
ufw allow 80/tcp
ufw deny 8080/tcp    # 后端不暴露公网
ufw deny 3306/tcp    # 数据库不暴露公网
ufw deny 6379/tcp    # Redis 不暴露公网
```

### 8.3 系统更新
```bash
# 定期更新基础镜像
docker compose pull
docker compose up -d
```
