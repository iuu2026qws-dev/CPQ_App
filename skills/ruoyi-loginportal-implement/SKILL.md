---
name: ruoyi-loginportal-implement
description: RuoYi-Vue-Plus 登录门户实现完整指南。当需要在 RuoYi-Vue-Plus 项目中实现登录页、登录认证流程、用户信息获取、动态菜单加载、路由守卫或 Token 管理时应使用此技能。包含后端配置清单、sys_client 表操作、Sa-Token 鉴权机制、前端完整实现步骤及常见陷阱排查。
---

# RuoYi-Vue-Plus 登录门户实现指南

## 概述

在 RuoYi-Vue-Plus 项目中实现完整的登录门户（登录页、Token 认证、用户信息获取、动态菜单加载、路由守卫）涉及前后端多个配置点和非显而易见的鉴权机制。本技能整理了实践中踩过的坑和正确的实现步骤。

## 后端必须完成的配置

### 1. 开发环境关闭 API 接口加密

RuoYi-Vue-Plus 默认开启了 API 请求体加密（SM2/SM4），若前端未实现对应的加密逻辑，所有 POST 请求体会被 CryptoFilter 拦截并返回 "请求正文解密失败"。

在 `application-dev.yml` 中添加：

```yaml
--- # API接口加密（开发环境关闭）
api-decrypt:
  enabled: false
```

### 2. 开发环境关闭验证码

框架默认开启登录验证码校验。若未实现验证码获取流程（调用 `/auth/code` 获取 uuid+图片），登录会因 `code` 字段为空而失败并返回 "验证码错误"。

在 `application-dev.yml` 中添加：

```yaml
--- # 验证码（开发环境关闭）
captcha:
  enable: false
```

### 3. 向 sys_client 表插入客户端记录

框架的 `PasswordAuthStrategy` 会根据 `clientId` 查询 `sys_client` 表做客户端合法性校验（状态、授权类型匹配等）。若表中无对应记录，登录会返回 "认证权限类型错误" 的 500 错误。

需要插入一条记录（ID 自增，按需替换）：

```sql
INSERT INTO sys_client (id, client_id, client_key, client_secret, grant_type, device_type, active_timeout, timeout, status)
VALUES (10, 'e5cd7e4891bf95d1d19206ce24a7b32e', '123456', '123456', 'password,social', 'pc', 1800, 604800, '0');
```

关键字段说明：
- `client_id`：客户端标识，前端登录请求体和后续 API 请求头都必须携带此值
- `grant_type`：必须包含 `password`（密码登录模式）或 `social`（社交登录），取决于使用的认证策略
- `status`：必须为 '0'（正常）；'1' 表示停用

验证是否插入成功：

```sql
SELECT id, client_id, grant_type, status FROM sys_client WHERE status = '0';
```

## Sa-Token 鉴权机制（关键）

RuoYi-Vue-Plus 使用 Sa-Token 作为认证框架，其默认配置将 Token 存入 Redis。**每个 API 请求必须通过两个鉴权点**：

1. **Authorization 头**：标准 Bearer Token（`Authorization: Bearer <token>`）- 由 `SaTokenConfig.tokenPrefix` 配置
2. **clientid 头**：客户端标识（`clientid: <client_id>`）- 由 `LoginHelper.CLIENT_KEY = "clientid"` 定义

`SecurityConfig` 中的 `SaTokenInterceptor` 会执行以下校验链：
- 从请求头提取 `Authorization` → 从 Redis 查询对应的 `SaSession`
- 从 SaSession 中提取 `clientId` 字段（登录时 `PasswordAuthStrategy.login()` 写入）
- 与请求头中的 `clientid` 比较 → 不一致则返回 401

**常见错误**：若忘记在请求中携带 `clientid` 头，或 `clientid` 头的值与登录时使用的 `clientId` 不一致，即使 Token 有效也会返回 401 或 403。

验证完整鉴权链路（curl）：

```bash
CID="e5cd7e4891bf95d1d19206ce24a7b32e"
TOKEN=$(curl -s http://localhost:8080/auth/login \
  -H 'Content-Type: application/json' \
  -d "{\"clientId\":\"$CID\",\"grantType\":\"password\",\"tenantId\":\"000000\",\"username\":\"admin\",\"password\":\"admin123\"}" \
  | python3 -c "import sys,json;print(json.load(sys.stdin)['data']['access_token'])")

# getInfo（必须同时携带 Authorization、clientid、tenant-id 三个头）
curl -s "http://localhost:8080/system/user/getInfo" \
  -H "Authorization: Bearer $TOKEN" \
  -H "clientid: $CID" \
  -H "tenant-id: 000000"

# getRouters（获取动态菜单）
curl -s "http://localhost:8080/system/menu/getRouters" \
  -H "Authorization: Bearer $TOKEN" \
  -H "clientid: $CID" \
  -H "tenant-id: 000000"
```

## 后端 API 契约

### 登录接口

- **URL**：`POST /auth/login`
- **Content-Type**：`application/json`
- **请求体**：`{clientId, grantType, tenantId, username, password}`
  - `clientId`：与 `sys_client.client_id` 一致
  - `grantType`：认证策略，如 `"password"`
  - `tenantId`：租户 ID，默认 `"000000"`
  - `password`：明文密码
- **响应**：
```json
{
  "code": 200,
  "msg": "操作成功",
  "data": {
    "access_token": "...",
    "refresh_token": "...",
    "clientId": "e5cd7e4891bf95d1d19206ce24a7b32e",
    "expires_in": 43200,
    "token_type": "Bearer"
  }
}
```

### 获取用户信息

- **URL**：`GET /system/user/getInfo`
- **请求头**：`Authorization: Bearer <token>`, `clientid: <id>`, `tenant-id: <tenant>`
- **响应**：`{code:200, data: {user: {...}, roles: [...], permissions: [...]}}`

### 获取动态路由菜单

- **URL**：`GET /system/menu/getRouters`
- **请求头**：同上
- **响应**：`{code:200, data: [...]}` — Vue Router 格式的菜单树

## 前端实现清单

### 文件结构

```
src/
├── utils/auth.ts        # Token / tenantId 的 localStorage 读写
├── utils/request.ts     # Axios 实例 + 拦截器（注入 3 个头）
├── api/auth.ts          # 登录 API 封装
├── store/user.ts        # Pinia 用户状态（token/user/roles/permissions/menus）
├── router/index.ts      # 路由守卫（未登录→/login，已登录→放行）
├── views/login/index.vue # 登录页
└── layout/index.vue     # 主布局（侧边栏+顶栏+内容区）
```

### utils/auth.ts — Token 存储

```typescript
const TOKEN_KEY = 'Admin-Token'
const TENANT_KEY = 'tenant-id'

export function getToken(): string | null {
  return localStorage.getItem(TOKEN_KEY)
}
export function setToken(token: string): void {
  localStorage.setItem(TOKEN_KEY, token)
}
export function removeToken(): void {
  localStorage.removeItem(TOKEN_KEY)
}
export function getTenantId(): string {
  return localStorage.getItem(TENANT_KEY) || '000000'
}
export function setTenantId(id: string): void {
  localStorage.setItem(TENANT_KEY, id)
}
```

### utils/request.ts — Axios 拦截器（三个必带头）

```typescript
const CLIENT_ID = 'e5cd7e4891bf95d1d19206ce24a7b32e' // 与 sys_client 一致

service.interceptors.request.use(config => {
  const token = getToken()
  if (token) {
    config.headers['Authorization'] = `Bearer ${token}`
    config.headers['clientid'] = CLIENT_ID   // Sa-Token 要求
  }
  const tenantId = getTenantId()
  if (tenantId) {
    config.headers['tenant-id'] = tenantId
  }
  return config
}, error => Promise.reject(error))

service.interceptors.response.use(
  response => response.data,
  error => {
    if (error.response?.status === 401) {
      removeToken()
      location.href = '/login'
    }
    ElMessage.error(error.message)
    return Promise.reject(error)
  }
)
```

### store/user.ts — Pinia 状态管理

登录流程步骤：
1. 调用登录 API → 获取 `access_token`
2. `setToken(token)` 存入 localStorage
3. 调用 `getInfo()` → 获取 user/roles/permissions
4. 调用 `getRouters()` → 获取动态菜单树
5. 跳转目标页面

### router/index.ts — 路由守卫

```typescript
router.beforeEach((to, _from, next) => {
  const token = getToken()
  if (!token && to.path !== '/login') {
    next('/login')        // 未登录 → 登录页
  } else if (token && to.path === '/login') {
    next('/dashboard')    // 已登录 → 首页
  } else {
    next()                // 正常放行
  }
})
```

### views/login/index.vue — 登录页

默认填充值：
- 租户：`000000`
- 用户名：`admin`
- 密码：`admin123`

登录表单包含：租户下拉（或直接默认值）、用户名输入、密码输入、登录按钮。点击登录时调用 `userStore.login()`。

## 登录失败排查流程

按以下顺序逐项检查，每完成一步用 curl 验证：

1. **后端是否在 8080 端口正常响应** → `curl http://localhost:8080`
2. **API 加密是否已关闭** → 检查 `application-dev.yml` 中 `api-decrypt.enabled: false`
3. **验证码是否已关闭** → 检查 `captcha.enable: false`
4. **sys_client 表是否有对应记录且 status=0** → `SELECT * FROM sys_client WHERE status='0'`
5. **登录请求的 clientId 是否与 sys_client.client_id 一致** → 使用 curl 比前端更快定位
6. **获取 Token 后，后续 API 是否携带了 clientid 头** → 这是最常见的 401 原因
7. **Redis 是否正常运行** → Sa-Token 将 Session 存入 Redis，Redis 挂了 Token 校验会失败

curl 快速验证模板（全链路）：

```bash
# 设置变量
CID="你的client_id"
TENANT="000000"
USER="admin"
PASS="admin123"

# 1. 登录
curl -s http://localhost:8080/auth/login -H 'Content-Type: application/json' \
  -d "{\"clientId\":\"$CID\",\"grantType\":\"password\",\"tenantId\":\"$TENANT\",\"username\":\"$USER\",\"password\":\"$PASS\"}" \
  | python3 -c "import sys,json; d=json.load(sys.stdin); print('login code:', d['code']); print('token:', d['data']['access_token'][:30]+'...') if d['code']==200 else print('msg:', d['msg'])"

# 2. 获取用户信息
TOKEN=$(curl -s ...同上...) 
curl -s http://localhost:8080/system/user/getInfo \
  -H "Authorization: Bearer $TOKEN" -H "clientid: $CID" -H "tenant-id: $TENANT"

# 3. 获取菜单
curl -s http://localhost:8080/system/menu/getRouters \
  -H "Authorization: Bearer $TOKEN" -H "clientid: $CID" -H "tenant-id: $TENANT"
```

## 多租户注意事项

- `tenant-id` 请求头为必填。框架的 `TenantLineInnerInterceptor`（MyBatis-Plus 多租户插件）会基于此头自动注入 `tenant_id` 过滤条件
- 登录时 `tenantId` 必须与数据库中的承租人 ID 一致（默认 `"000000"`）
- `auth.ts` 的 `getTenantId()` 默认返回 `'000000'`，在登录页可由用户选择后存储
