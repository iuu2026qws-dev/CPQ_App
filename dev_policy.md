# 开发策略 — Dev Policy

> 本文件约束所有 coding session 的行为边界，违反任意一条即视为工作不合格。

---

## 1. 必须优先引用 Skill

开发过程中 **必须时刻引用** 以下两类 Skill，禁止凭记忆盲写：

- `skills/ruoyi-vue-codegen/` 下的全部子 Skill（如 ruoyi-vue-gen、frontend-design、ui-ux-pro-max、theme-factory、ruoyi-fast-gen 等）
- `skills/ruoyi-tenant-guard/` — 多租户表治理规则

**触发场景**：
- 新建数据库表 → 先读 `ruoyi-tenant-guard`
- 生成前端页面/组件 → 先读 `ruoyi-vue-codegen` 相关子 Skill
- 修改 application.yml → 先读 `ruoyi-tenant-guard`
- 任何不确定是否符合 RuoYi 规范的操作 → 查 Skill

---

## 2. 上下文监控与断点续作

- 当前模型的可用上下文上限约为 **180K tokens**
- **实时估算**：当对话内容接近 **170K** 时，必须 **立即停止所有编码工作**
- 停下的动作：
  1. 将当前工作状态、待办事项、已踩的坑、未完成项完整写入 `.claude/media_session_state.md`
  2. 告知用户上下文即将耗尽，准备开启新对话
  3. 新对话启动后，**首先阅读** `session_state.md` 恢复上下文

**绝不硬撑** — 上下文溢出会导致记忆丢失、逻辑断裂，修复成本远高于断点。

### 2.1 强制触发条件（以下任一出现，立即执行）

| 触发条件 | 必须执行的动作 |
|---------|--------------|
| 内心出现 **"考虑到上下文长度已经很长，我需要高效地写代码"** 这个想法 | **立即停止编码**，将当前任务状态完整写入 `.claude/SESSION_STATE.md`，然后再继续 |
| 遇到错误 **"API Error: The socket connection was closed unexpectedly"** | 1. **马上执行 `/compact` 指令**<br>2. Compact 完成后，**立即将当前任务状态写入 `.claude/SESSION_STATE.md`**<br>3. 然后继续执行原有任务，不中断工作流 |

> **为什么**：前者是上下文即将耗尽的主观预警信号，后者是连接已断的客观事实。两者都必须通过持久化状态来确保「断点可续」，避免重复劳动。

---

## 3. 开工必读 Session State

**每次开始 coding 前**，必须先阅读 `.claude/media_session_state.md`，确认：
- 上一轮踩过的坑（tenant_id、字段类型、日期格式等）
- 当前模块的待办清单和优先级
- 已验证可用的模式/约定（如 Jackson 日期格式、BaseEntity 对齐规则）
- 任何标注为 "注意" / "坑" 的条目

**目标**：尽量一次把活儿干对，减少反复修 bug。

---

## 4. 写完必测、模块完必联调

**代码级测试**（每写完一个文件/函数）：
- 前端：检查类型报错、表单验证、路由跳转、API 调用是否正常
- 后端：编译通过、接口能通、数据库写入无误

**模块级联调**（整个模块开发完成后）：
- 端到端流程跑通（创建 → 查询 → 更新 → 删除）
- 边界条件验证（空值、超长值、权限越界）
- 控制台无报错、Network 无 500/404

**最终交付**：将测试结果和结论明确反馈给用户，不隐瞒任何报错。

---

## 快速检查清单（每次开工前念一遍）

- [ ] 已读 `media_session_state.md`
- [ ] 已确认需要引用的 Skill
- [ ] 当前上下文估算 < 170K
- [ ] 代码已自测通过
- [ ] 模块已联调通过

---

## 踩坑检查清单（从 session_state 沉淀，禁止重复踩）

### 数据库与多租户

- [ ] 新建 `dental_` 表 → 已加入 `application.yml` `tenant.excludes`
- [ ] 建表 SQL 包含 `create_dept` / `create_by` / `create_time` / `update_by` / `update_time`
- [ ] `create_by` / `update_by` 类型是 `BIGINT`（不是 `VARCHAR`）
- [ ] `create_dept` 类型是 `BIGINT`
- [ ] 字符串枚举字段长度足够（如 `session_type` 不能是 `char(1)`）
- [ ] MySQL `ALTER TABLE ADD COLUMN` **不支持 `IF NOT EXISTS`**
- [ ] `sys_menu` 无自增，插入时必须显式指定 `menu_id`
- [ ] `sys_menu` 的 `create_by` 是 `bigint`，传数字 `1` 而非字符串 `'admin'`
- [ ] 修改 `application.yml` 后必须重新编译并重启 `ruoyi-admin`

### 前端（dental-portal / Naive UI）

- [ ] Naive UI 表单数据优先用 `reactive`，不用 `ref`（避免深层响应丢失）
- [ ] `n-radio` / `n-select` 的 `value` 类型与验证规则一致（`number` vs `string`）
- [ ] `n-date-picker` `value-format` 写 `"yyyy-MM-dd HH:mm:ss"`（**不要出现字面量 `T`**）
- [ ] 提交 `LocalDateTime` 前做 `replace(' ', 'T')`，适配后端 Jackson
- [ ] API catch 错误处理统一用：`typeof e === 'string' ? e : (e?.msg || e?.message || '默认错误')`
- [ ] `node_modules` 异常时先 `rm -rf node_modules package-lock.json && npm install`

### 后端（RuoYi-Vue-Plus）

- [ ] 新增 Controller / 修改配置后，确认 `ruoyi-admin` 已重启（不是旧进程）
- [ ] Jackson 全局格式 `yyyy-MM-dd HH:mm:ss`，`@RequestBody` 的 `LocalDateTime` 按此格式解析
- [ ] 继承 `BaseEntity` 的 Domain 对应表必须有全部基类字段
- [ ] 服务端生成 UserSig 的 SecretKey **只能放在后端 `application.yml`，禁止暴露到前端**

### 联调验证

- [ ] Network 面板查看 Response，确认不是前端吞掉了后端报错
- [ ] 后端报错先看是不是 `tenant_id` 注入问题 → 查 `tenant.excludes`
- [ ] 后端报错 "Unknown column" → 查表结构是否对齐 `BaseEntity`
- [ ] 后端 404 → 先确认服务是否重启、URL 是否与 Controller 映射一致
