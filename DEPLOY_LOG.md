# DEPLOY_LOG.md — CPQ App 部署记录

> 每次部署到测试机后追加一条记录。用于版本对比、回滚和故障排查。

---

## 部署 #1 — 2026-07-03

| 项目 | 值 |
|------|----|
| **部署时间** | 2026-07-03 16:30 ~ 18:30 |
| **Git Tag** | `deploy-test-20260703` |
| **Git Commit** | `2b83b302b` — fix: 修复前端列表数据显示 + P01客户ID字段替换下拉搜索 |
| **分支** | `manong_20260702_ver` |
| **测试机 IP** | 100.119.232.95 |
| **测试机 SSH** | `ssh mac@100.119.232.95` (密码: 1234) |

### 部署内容

| 服务 | 端口 | 部署方式 | 状态 |
|------|------|----------|------|
| MySQL 8.0 | 3306 | 系统级 LaunchDaemon | ✅ 开机自启 |
| Redis 7.4.2 | 6379 | 用户 LaunchAgent，密码 `ruoyi123` | ✅ 开机自启 |
| ruoyi-admin.jar | 30000 | `/Users/mac/Downloads/cpq_app/` + LaunchAgent | ✅ 开机自启 |
| cpq-portal (Vite build) | 3000 | `/Users/mac/Downloads/cpq_app/cpq-portal/` + LaunchAgent | ✅ 开机自启 |
| ruoyi-ui (Vite build) | 2999 | `/Users/mac/Downloads/cpq_app/ruoyi-ui/` + LaunchAgent | ✅ 开机自启 |

### LaunchAgent plist 文件

| 文件 | 位置 | 服务 |
|------|------|------|
| `com.cpq.ruoyi-admin.plist` | `~/Library/LaunchAgents/` | ruoyi-admin.jar |
| `com.cpq.portal.plist` | `~/Library/LaunchAgents/` | cpq-portal |
| `com.cpq.admin-ui.plist` | `~/Library/LaunchAgents/` | ruoyi-ui |
| `com.redis.redis-server.plist` | `~/Library/LaunchAgents/` | Redis |
| `com.oracle.oss.mysql.mysqld.plist` | `/Library/LaunchDaemons/` | MySQL |

### 部署后修改（数据库）

| 日期 | 修改内容 |
|------|----------|
| 2026-07-04 15:30 | 新增属性选项 25 条、配置规则 10 条、属性映射 35 条、兼容性矩阵 16 条 |

### 注意事项

1. **pkill UURemote 可能导致机器断网** — UURemoteDaemon 以 root 运行，kill 后系统不稳
2. **修改 TCC.db 可能触发 tccd 异常** — 尽量通过 GUI 授权，不要直接写数据库
3. **JDK 26** 在 `/Library/Java/JavaVirtualMachines/jdk-26.jdk/Contents/Home`
4. **node/npm** 在 `/usr/local/bin/`

---

## 下次部署 checklist

- [ ] 对比本地 HEAD 与 `deploy-test-20260703` tag 的差异: `git diff deploy-test-20260703..HEAD`
- [ ] 构建前端: `cd cpq-portal && npm run build` / `cd ruoyi-ui && npm run build`
- [ ] 构建后端: `mvn clean package -pl ruoyi-admin -am -DskipTests`
- [ ] 同步到测试机: 使用 `sync-to-remote.sh` 或直传
- [ ] 重启测试机服务
- [ ] 验证 HTTP 200
- [ ] 打新 tag: `git tag deploy-test-YYYYMMDD`
- [ ] 更新本文件
