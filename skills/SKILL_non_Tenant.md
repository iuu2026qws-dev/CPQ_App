---
name: ruoyi-tenant-guard
description: "RuoYi-Vue-Plus 多租户拦截器治理。当创建新的 dental 模块数据库表时，必须在 application.yml 的 tenant.excludes 中注册该表，否则 MyBatisPlus 的 TenantLineInnerInterceptor 会自动注入 tenant_id 导致 SQL 报错。同时提供 BaseEntity 字段对齐检查清单。"
---

# RuoYi Tenant Guard — 多租户表治理

## 背景

RuoYi-Vue-Plus 启用了多租户插件 `TenantLineInnerInterceptor`（`tenant.enable: true`）。
该插件会**自动改写 SQL**：
- INSERT 语句自动添加 `tenant_id` 字段
- SELECT/UPDATE/DELETE 自动添加 `WHERE tenant_id = ?` 条件

如果表结构里没有 `tenant_id` 列，运行时会抛出：
```
java.sql.SQLSyntaxErrorException: Unknown column 'tenant_id' in 'field list'
```

## 治理规则

### Rule 1：新建数据表 → 必须注册到 tenant.excludes

**文件**：`ruoyi-admin/src/main/resources/application.yml`

每次新建 `dental_` 前缀的表后，立即在该文件的 `tenant.excludes` 列表末尾追加表名。

示例：
```yaml
tenant:
  enable: true
  excludes:
    - sys_menu
    - sys_tenant
    # ... 其他排除表
    # dental 模块（均无 tenant_id 字段）
    - dental_case
    - dental_case_comment
    - dental_user_content
    - dental_live_session
    - dental_xxxx          # ← 新建的表加在这里
```

**注意**：不支持通配符，`PlusTenantLineHandler.ignoreTable` 使用的是精确匹配。

### Rule 2：建表 SQL 必须包含 BaseEntity 全部字段

所有继承 `BaseEntity` 的 Domain 对应的表，必须包含以下列：

| Java 字段 | 数据库列 | 推荐类型 | 说明 |
|-----------|----------|----------|------|
| `createDept` | `create_dept` | `BIGINT` | 创建部门 |
| `createBy` | `create_by` | `BIGINT` | 创建者（与 BaseEntity `Long` 对齐） |
| `createTime` | `create_time` | `DATETIME` | 创建时间 |
| `updateBy` | `update_by` | `BIGINT` | 更新者（与 BaseEntity `Long` 对齐） |
| `updateTime` | `update_time` | `DATETIME` | 更新时间 |

**常见错误**：
- `create_by VARCHAR(64)` ❌ — BaseEntity 里是 `Long`，必须是 `BIGINT`
- 缺少 `create_dept` ❌ — MyBatisPlus 自动填充时会 INSERT 该字段

### Rule 3：建表后重启 ruoyi-admin

`application.yml` 修改后需要重新编译打包并重启 `ruoyi-admin` 才能生效。

```bash
cd ruoyi-vue-plus-backend
mvn clean package -DskipTests -pl ruoyi-admin -am
java -jar ruoyi-admin/target/ruoyi-admin.jar
```

## 快速检查清单（Checklist）

每当你为 dental 模块新建一张表时，按顺序执行：

- [ ] SQL 建表语句包含 `create_dept` / `create_by` / `create_time` / `update_by` / `update_time`
- [ ] `create_by` 和 `update_by` 类型为 `BIGINT`（不是 `VARCHAR`）
- [ ] 在 `ruoyi-admin/src/main/resources/application.yml` 的 `tenant.excludes` 追加新表名
- [ ] 重新编译并重启 `ruoyi-admin`
- [ ] 首次插入测试验证通过

## 相关文件

| 文件 | 作用 |
|------|------|
| `ruoyi-admin/src/main/resources/application.yml` | 多租户排除表配置 |
| `ruoyi-common-mybatis/src/.../domain/BaseEntity.java` | 基类字段定义 |
| `ruoyi-common-tenant/src/.../handle/PlusTenantLineHandler.java` | 多租户拦截逻辑 |
| `ruoyi-common-tenant/src/.../config/TenantConfig.java` | 多租户插件配置 |
