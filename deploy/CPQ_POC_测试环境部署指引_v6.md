# SmartCPQ 测试环境部署指引 v6

> 服务器：`8.148.208.235`（root@ / Pa$$20rd）
> 部署目录：`/opt/`
> 数据库：`8.133.17.0:3306` / `Ruoyi_CPQ` / `root` / `Celnet2025.QY`
> 最后更新：2026-07-27

---

## 本次变更

| 变更 | 涉及文件 | 部署方式 |
|------|---------|---------|
| Token 统一 + 报价单修复 | `tools.py`, `config.py`, `cpq_api.py` | `docker load` 新 `cpq-agent-backend-image` |
| quoteUrl 修正 | `agent-config.yaml` 加 `frontend_url` | 服务器上手动改一行 |

---

## 部署步骤（5 步）

### 1. 下载 & 上传

从 CPQ_Agent CI 下载 `cpq-agent-backend-image`，解压得 `cpq-agent-backend.tar.gz`，上传：

```bash
scp cpq-agent-backend.tar.gz root@8.148.208.235:/opt/deploy-v5/
```

### 2. 加载镜像

```bash
ssh root@8.148.208.235
cd /opt/deploy-v5
docker load < cpq-agent-backend.tar.gz
docker images | grep cpq_agent
```

### 3. 更新 agent-config.yaml

```bash
python3 -c "
import yaml
with open('/opt/agent-config/config.yaml') as f:
    c = yaml.safe_load(f)
c.setdefault('cpq', {})['frontend_url'] = 'http://8.148.208.235:3000'
with open('/opt/agent-config/config.yaml', 'w') as f:
    yaml.dump(c, f, allow_unicode=True)
"
grep frontend_url /opt/agent-config/config.yaml
```

### 4. 重建 Agent 后端

```bash
cd /opt
docker compose up -d --force-recreate cpq-agent-backend
sleep 10
docker compose logs cpq-agent-backend --tail 20
```

### 5. 验证

```bash
# Agent 后端健康
curl -s http://127.0.0.1:58100/health | python3 -m json.tool
# 应该显示 "status": "ok"，cpq 连通

# 浏览器验证
# http://8.148.208.235:57100 → 测试完整对话链路：
#   搜索产品 → 需求匹配 → 选品 → 工艺确认 → 创建报价
```

---

## 验证清单

| 检查项 | 命令 | 预期 |
|--------|------|------|
| Agent 后端启动 | `docker compose logs cpq-agent-backend --tail 5` | `Agent ready` |
| CPQ 连通 | `curl http://127.0.0.1:58100/health` | `cpq: ok` |
| 报价链接 | 浏览器创建报价后检查链接 | `http://8.148.208.235:3000/quoting/...` |
| 工艺进度 | 对话中点击"工艺确认进度" | 正常返回状态 |
