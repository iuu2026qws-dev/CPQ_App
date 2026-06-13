# CPQ 配置管理全栈改造设计方案（v2.0 - 完整版）

> 日期：2026-06-13
> 包含：Admin Portal 清理 + 配置数据管理 CRUD + CPQ Portal 扩展 + 后端补齐

---

## 一、范围定义

### 1.1 包含内容
1. Admin Portal 清理：删除配置报价下4个静态占位页
2. Admin Portal 新增：3个配置数据管理CRUD页面
3. CPQ Portal 扩展：配置管理下新增3个配置器入口
4. CPQ Portal 新建：向导式配置页面 + ATO定制配置页面
5. 后端补齐：ConfiguratorController暴露guide端点

### 1.2 不包含内容
- 不修改cpq-portal现有的ProductSearch.vue和Configurator.vue
- 不修改useConfiguratorStore核心逻辑
- 不修改后端CSP配置引擎
- 不新建cpq-portal下的ProductSearch组件副本

---

## 二、后端现状

### 2.1 三张配置数据表 CRUD（已完整实现）

| 表 | Controller路径 | API端点 |
|----|---------------|---------|
| cpq_attribute_option | `/cpq/config/attributeoption` | GET list, GET/{id}, POST, PUT, DELETE/{id} |
| cpq_config_rule | `/cpq/config/rule` | GET list, GET/{id}, POST, PUT, DELETE/{id} |
| cpq_attribute_mapping | `/cpq/config/attributemapping` | GET list, GET/{id}, POST, PUT, DELETE/{id} |

### 2.2 需要补齐的后端端点

在 `ConfiguratorController` 中新增：
```
POST /cpq/configure/guide?modelId={modelId}
Body: { "attrName": "optionCode", ... }
Response: GuideStep (包含 state, question, options, recommendations 等)
```

---

## 三、Admin Portal (ruoyi-ui) 改造

### 3.1 删除操作

**删除文件**（4个）：
```
ruoyi-ui/src/views/configure/ProductSearch.vue
ruoyi-ui/src/views/configure/Configurator.vue
ruoyi-ui/src/views/configure/GuidedSelling.vue
ruoyi-ui/src/views/configure/AtoCustomize.vue
```

**删除/清理API**：
```
ruoyi-ui/src/api/cpq/configure.ts  → 删除
```

**更新菜单SQL**（sql/cpq_menu.sql）：
```sql
-- 删除 50020配置报价（M目录）、50021产品搜索、50022新建标准配置、50023向导式配置、50024ATO定制配置
DELETE FROM sys_menu WHERE menu_id IN (50020, 50021, 50022, 50023, 50024);
```

### 3.2 新增配置数据管理页面

#### 3.2.1 属性选项管理 (attribute-option)

**文件**: `ruoyi-ui/src/views/cpq/attribute-option/index.vue`
**API文件**: `ruoyi-ui/src/api/cpq/attribute-option.ts`

**字段列表**:
| 字段 | 中文名 | 类型 | 搜索/表单 |
|------|--------|------|----------|
| optionId | ID | number | 只读 |
| modelId | 产品模型ID | number | 输入框 |
| attrName | 属性名称 | string | 搜索+输入框 |
| optionCode | 选项编码 | string | 搜索+输入框 |
| optionLabel | 选项标签 | string | 输入框 |
| optionValue | 选项值 | string | 输入框 |
| isDefault | 是否默认 | string(0/1) | 下拉选择 |
| sortOrder | 排序 | number | 输入框 |

**API端点**: `/cpq/config/attributeoption/*`

#### 3.2.2 配置规则管理 (config-rule)

**文件**: `ruoyi-ui/src/views/cpq/config-rule/index.vue`
**API文件**: `ruoyi-ui/src/api/cpq/config-rule.ts`

**字段列表**:
| 字段 | 中文名 | 类型 | 搜索/表单 |
|------|--------|------|----------|
| ruleId | ID | number | 只读 |
| ruleName | 规则名称 | string | 搜索+输入框 |
| ruleType | 规则类型 | string | 下拉(REQUIRES/EXCLUDES/RECOMMENDS/FILTER/PRICE) |
| modelId | 产品模型ID | number | 输入框 |
| conditionExpr | 条件表达式 | string | textarea |
| actionExpr | 动作表达式 | string | textarea |
| errorMessage | 错误提示 | string | 输入框 |
| severity | 严重级别 | string | 下拉(HARD/SOFT/WARNING) |
| priority | 优先级 | number | 输入框 |
| effectiveDate | 生效日期 | date | 日期选择 |
| expiryDate | 失效日期 | date | 日期选择 |
| status | 状态 | string | 下拉(0启用/1停用) |

**API端点**: `/cpq/config/rule/*`

#### 3.2.3 属性映射管理 (attribute-mapping)

**文件**: `ruoyi-ui/src/views/cpq/attribute-mapping/index.vue`
**API文件**: `ruoyi-ui/src/api/cpq/attribute-mapping.ts`

**字段列表**:
| 字段 | 中文名 | 类型 | 搜索/表单 |
|------|--------|------|----------|
| mappingId | ID | number | 只读 |
| modelId | 产品模型ID | number | 输入框 |
| attrName | 属性名称 | string | 搜索+输入框 |
| attrValue | 属性值 | string | 输入框 |
| materialCode | 物料编码 | string | 搜索+输入框 |
| sbomLineId | SBOM行ID | number | 输入框 |
| conditionExpr | 条件表达式 | string | textarea |
| sortOrder | 排序 | number | 输入框 |

**API端点**: `/cpq/config/attributemapping/*`

#### 3.2.4 菜单SQL

在 `sql/cpq_menu.sql` 中新增（在配置规则50083之后）：
```sql
-- 属性选项管理 (在 产品管理 的 配置规则 后面)
INSERT INTO sys_menu VALUES(50086, '属性选项管理', 50080, 6, 'attribute-option',
    'cpq/attribute-option/index', NULL, 1, 0, 'C', '0', '0',
    'cpq:config:attributeoption:list', '#', 103, 1, now(), NULL, NULL, '');

-- 属性映射管理
INSERT INTO sys_menu VALUES(50087, '属性映射管理', 50080, 7, 'attribute-mapping',
    'cpq/attribute-mapping/index', NULL, 1, 0, 'C', '0', '0',
    'cpq:config:attributemapping:list', '#', 103, 1, now(), NULL, NULL, '');
```

注意：配置规则管理 (menu_id=50083) 已存在于 `cpq_menu.sql` 第 73-75 行，component 为 `cpq/config-rule/index`。如果该页面也是占位页，需要同时替换为实际CRUD页面。检查发现 50083 component 指向 `cpq/config-rule/index` 但该文件可能不存在或为空——本次开发一并创建。

---

## 四、CPQ Portal (cpq-portal) 扩展

### 4.1 菜单扩展

`cpq-portal/src/config/menu.ts` - 配置管理下新增3个子项：
```typescript
{
  label: '配置管理',
  icon: Setting,
  children: [
    { path: '/config',              label: '配置规则',     icon: Setting },
    { path: '/configure',           label: '产品配置器',   icon: MagicStick },
    { path: '/configure-standard',  label: '新建标准配置', icon: MagicStick },  // 复用ProductSearch
    { path: '/configure-guided',    label: '向导式配置',   icon: Compass },
    { path: '/configure-ato',       label: 'ATO定制配置',  icon: SetUp },
  ]
}
```

新增图标导入：`Compass`, `SetUp` from `@element-plus/icons-vue`

### 4.2 路由注册

`cpq-portal/src/router/index.ts` 新增：
```typescript
// 新建标准配置 → 复用ProductSearch组件
{ path: 'configure-standard', component: () => import('@/views/configure/ProductSearch.vue'), meta: { title: '新建标准配置' } },
// 向导式配置列表页
{ path: 'configure-guided', name: 'GuidedSelling', component: () => import('@/views/configure/GuidedSelling.vue'), meta: { title: '向导式配置' } },
// 向导式配置 - 选定产品后的向导页
{ path: 'configure-guided/:modelId', name: 'GuidedConfigurator', component: () => import('@/views/configure/GuidedSelling.vue'), meta: { title: '向导配置产品' } },
// ATO定制配置
{ path: 'configure-ato', name: 'AtoCustomize', component: () => import('@/views/configure/AtoCustomize.vue'), meta: { title: 'ATO定制配置' } },
```

### 4.3 向导式配置页面

**文件**: `cpq-portal/src/views/configure/GuidedSelling.vue`（新建）

**设计**:
- 当无modelId参数时：显示产品搜索入口（复用ProductSearch的搜索逻辑）
- 当有modelId参数时：进入5阶段向导
- 复用`useConfiguratorStore`
- 后端API: `POST /cpq/configure/guide?modelId=`

**5阶段向导**:
1. QUESTIONING: 展示当前属性选项，用户选择一个
2. NARROWING: 约束传播后的可选范围缩小
3. RECOMMENDING: 推荐配置
4. CONFIGURING: 最终确认配置
5. COMPLETED: 显示完成摘要

### 4.4 ATO定制配置页面

**文件**: `cpq-portal/src/views/configure/AtoCustomize.vue`（新建）

**设计**:
- 产品搜索（仅显示ATO类型产品）
- 标准属性配置区（复用Configurator逻辑）
- 定制需求面板（文本描述+期望数量+期望交期+附件上传）
- 复用`useConfiguratorStore`

---

## 五、后端补齐

### ConfiguratorController 新增guide端点

```java
@PostMapping("/guide")
public R<GuideStep> guide(@RequestParam Long modelId, @RequestBody Map<String, String> selections) {
    GuideStep step = configEngineService.guidedSelling(modelId, selections);
    return R.ok(step);
}
```

## 六、文件清单

### 新建文件（8个）
1. `ruoyi-ui/src/api/cpq/attribute-option.ts`
2. `ruoyi-ui/src/api/cpq/config-rule.ts`
3. `ruoyi-ui/src/api/cpq/attribute-mapping.ts`
4. `ruoyi-ui/src/views/cpq/attribute-option/index.vue`
5. `ruoyi-ui/src/views/cpq/config-rule/index.vue`
6. `ruoyi-ui/src/views/cpq/attribute-mapping/index.vue`
7. `cpq-portal/src/views/configure/GuidedSelling.vue`
8. `cpq-portal/src/views/configure/AtoCustomize.vue`

### 删除文件（5个）
1. `ruoyi-ui/src/views/configure/ProductSearch.vue`
2. `ruoyi-ui/src/views/configure/Configurator.vue`
3. `ruoyi-ui/src/views/configure/GuidedSelling.vue`
4. `ruoyi-ui/src/views/configure/AtoCustomize.vue`
5. `ruoyi-ui/src/api/cpq/configure.ts`

### 修改文件（5个）
1. `sql/cpq_menu.sql` - 删除50020-50024，新增50086-50087
2. `cpq-portal/src/config/menu.ts` - 配置管理新增3个菜单项
3. `cpq-portal/src/router/index.ts` - 新增4条路由
4. `cpq-portal/src/views/layout/PortalLayout.vue` - 已修改（两级菜单），本次不再改动
5. `ruoyi-modules/ruoyi-cpq-config/.../ConfiguratorController.java` - 新增guide端点

---

## 七、实施优先级

| 优先级 | 组件 | 说明 |
|--------|------|------|
| P0 | 配置数据管理CRUD（3页面+3API） | 核心数据管理能力 |
| P0 | Admin Portal清理 | 移除占位页，修复菜单 |
| P1 | CPQ Portal 菜单+路由扩展 | 新增入口 |
| P1 | 向导式配置页面 | 完整5阶段向导 |
| P1 | ATO定制配置页面 | ATO定制流程 |
| P2 | 后端guide端点 | 向导式配置后端支持 |
