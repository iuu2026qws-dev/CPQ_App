---
name: ruoyi-codereview-full
description: 开发完成后必做的端到端全链路验证。确保功能完整性、可用性和对设计文档/需求的遵从。当需要检查一个 Sprint 或功能的交付质量时应使用此技能。包含：后端 API 测试（curl 模拟数据操作）、前端 Playwright 浏览器自动化测试（模拟真实用户操作）、设计文档一致性校验。
---

# RuoYi 开发完成后全链路验证（Code Review Full）

## 核心原则

每次完成一个 Sprint 或功能性开发任务后，**必须**进行端到端的全链路验证测试。不允许跳过任何环节。此技能定义了两个关键验证维度：

### 维度 1：端到端功能完整性、可用性与设计遵从性

开发完成后必须对照设计文档（前端设计文档、后端设计文档、需求文档）逐项检查：
- 所有计划的后端 API 端点是否均已实现且在 Swagger 中可访问
- 所有前端页面是否渲染正常、交互逻辑是否符合设计描述
- 菜单、权限、路由配置是否与设计文档中的矩阵一致
- 数据库表结构是否与 Domain 类对齐

### 维度 2：UI 相关功能的双层测试

如果当前开发的功能**有用户界面**或**与用户界面相关**（含后端 API 驱动的前端页面），功能完整性验证**必须包含以下两层**：

#### A. 前端层：Playwright 浏览器自动化测试

使用 Playwright CLI（`playwright-cli` skill）模拟真实用户操作，验证 UI 功能可用性：

1. **页面加载**：打开目标页面，确认页面正常渲染，无白屏或报错
2. **表单操作**：填写新增/编辑表单，提交后确认列表刷新和数据回显
3. **列表交互**：分页、搜索、排序、多选批量删除等操作
4. **详情查看**：点击查看详情，确认数据完整展示
5. **删除操作**：确认弹窗提示后正确删除
6. **错误处理**：提交空表单或非法数据，确认后端校验提示正常
7. **截图存档**：关键操作步骤需要截图保存，作为验证证据

工作流步骤：
- 先加载 `playwright-cli` skill
- 打开浏览器窗口（headed mode），导航到目标页面 URL
- 逐步执行上述操作，每步截图
- 将截图保存到 `.codebuddy/test-screenshots/` 目录下，以 `{sprint}_{step}_{timestamp}.png` 命名

#### B. 后端层：curl API 数据连通性测试

通过 curl 调用后端 API，模拟完整的数据操作链路，验证后台数据连通性：

1. **获取 Token**：调用登录 API 获取认证 token
2. **创建数据**：POST 新增一条测试记录，验证返回 code=200
3. **查询列表**：GET 分页查询，验证新增记录出现在列表中
4. **查询详情**：GET 根据 ID 查询详情，验证字段值正确
5. **更新数据**：PUT 修改字段，再次查询验证修改生效
6. **删除数据**：DELETE 删除测试记录，再次查询验证已删除
7. **边界条件**：测试必填字段为空、重复编码等异常场景，验证返回合理错误码

curl 命令模板：
```bash
# 登录获取 token
TOKEN=$(curl -s http://localhost:8080/auth/login \
  -H 'Content-Type: application/json' \
  -d '{"tenantId":"000000","username":"admin","password":"admin123","code":"","uuid":""}' \
  | python3 -c "import sys,json; print(json.load(sys.stdin)['data']['token'])")

# CRUD 操作（示例）
curl -s http://localhost:8080/cpq/product/catalog/list -H "Authorization: Bearer $TOKEN"
curl -s -X POST http://localhost:8080/cpq/product/catalog -H "Authorization: Bearer $TOKEN" -H 'Content-Type: application/json' -d '{...}'
curl -s -X PUT http://localhost:8080/cpq/product/catalog -H "Authorization: Bearer $TOKEN" -H 'Content-Type: application/json' -d '{...}'
curl -s -X DELETE http://localhost:8080/cpq/product/catalog/1 -H "Authorization: Bearer $TOKEN"
```

## 验证流程

### 步骤 1：编译验证

确保前后端编译零错误：
```bash
# 后端
mvn clean package -DskipTests -pl "ruoyi-admin 2" -am

# 前端
cd ruoyi-ui && npx vue-tsc --noEmit
```

### 步骤 2：服务启动验证

确认后端 (8080) 和前端 (3000) 端口均正常响应。

### 步骤 3：Swagger 端点注册检查

访问 `http://localhost:8080/swagger-ui/index.html` 或解析 `/v3/api-docs`，确认当前模块所有 API 端点均已注册。

### 步骤 4：后端 curl 全链路测试

对当前模块的每个 Controller 执行完整 CRUD + 异常场景的 curl 测试。

### 步骤 5：前端 Playwright 浏览器测试（如涉及 UI）

对每个新增/修改的页面执行完整交互测试，截图存档。

### 步骤 6：设计文档一致性检查

逐条对比设计文档中的功能描述与实际实现，记录任何偏差。

## 输出要求

验证完成后，应产生以下产物：

1. **测试报告**：`.codebuddy/test-reports/sprint_{N}_report.md`，包含每个测试步骤的通过/失败状态
2. **截图**：`.codebuddy/test-screenshots/` 目录下的 Playwright 测试截图
3. **API 测试日志**：后端 curl 测试的完整请求/响应记录

## 检查清单

- [ ] `mvn package` 通过
- [ ] `vue-tsc --noEmit` 通过
- [ ] 后端 8080 端口正常
- [ ] 前端 3000 端口正常
- [ ] Swagger 中所有端点已注册
- [ ] curl 完整 CRUD 链路通过
- [ ] curl 异常场景返回合理错误
- [ ] Playwright 页面加载正常（如涉及 UI）
- [ ] Playwright 表单新增/编辑/删除操作正常（如涉及 UI）
- [ ] 菜单、路由、权限与设计文档一致（如涉及 UI）
- [ ] 数据库表字段与 Domain 类对齐
