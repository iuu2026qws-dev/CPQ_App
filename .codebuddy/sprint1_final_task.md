# Sprint 1 终版工作清单

> 版本：V1.1 | 日期：2026-06-07 00:59  
> 基于：Sprint1_Bundle_Impact_Modification_Plan.md + development_plan.md + development_plan_details.md  
> 状态：**全部完成** ✅

---

## 执行总结

**执行时间**：2026-06-07 00:55-00:59  
**全部29项任务已完成**。经代码审查确认，后端和前端的 S1.3 V2.1 变更已在之前的 session 中完成实现，本次 session 完成了全量编译验证、功能测试和数据修正（tenant_id 对齐）。

---

## 当前状态快照

### 已完成（不需要再动）
| 已完成项 | 说明 |
|----------|------|
| S1.1 Java 代码对齐（全部12项） | 9个Domain + 8个BO/VO + 6个Mapper + Service + Controller ✅ |
| S1.4 前端对齐（全部6项） | catalog/model/supersession 三个页面 + API ✅ |
| DDL `cpq_d01_product.sql` | 已含 `cpq_product_category` 建表 + `cpq_product_model` 字段改为 `category_id` ✅ |
| `model/index.vue` configTypeOptions | 已含 BUNDLE 选项 ✅ |
| `CpqProductModel.java` configType | 注释已含 BUNDLE ✅ |
| `CpqProductModelVo.java` configType | 注释已含 BUNDLE ✅ |
| Bundle 3表 DDL | 已含在 `cpq_d01_product.sql` ✅ |
| 前后端编译 | `mvn clean package` + `vue-tsc --noEmit` 均通过 ✅ |

### 尚未完成（Sprint 1 终版需交付）
| 未完成项 | 状态 |
|----------|------|
| S1.3.1-S1.3.6 全部6项 | ✅ 已完成（代码+数据库+前端） |
| CpqProductModelBo.java configType | ✅ 已含 BUNDLE |
| 菜单新增（产品分类管理） | ✅ menu_id=50085 已存在于数据库 |
| 数据库 ALTER（cpq_product_model 字段迁移） | ✅ category_id 已存在，product_line/family/series 已删除 |
| 种子数据 tenant_id 修正 | ✅ 已从 '1' 修正为 '000000' |

---

## 任务分组

### 组一：数据库（DB）

**T1.1** 向数据库执行 ALTER TABLE，将 `cpq_product_model` 字段迁移为 DDL 定义：
- 删除 `product_line`、`product_family`、`product_series` 三个旧字段
- 新增 `category_id BIGINT NOT NULL` 字段
- 新增 `INDEX idx_category (tenant_id, category_id)` 索引
- 删除旧索引 `idx_product_line`
- 修改 `config_type` COMMENT 含 BUNDLE
- ⚠️ **注意**：旧 seed 数据使用 product_line/family/series 字段，ALTER 前需备份或先创建 category 并回填 category_id

**T1.2** 向数据库创建 `cpq_product_category` 表（DDL 已在 `cpq_d01_product.sql` 中，如未执行则执行 `CREATE TABLE`）

**T1.3** 创建 `cpq_product_category` 的分类种子数据（L1产品线/L2产品族/L3产品系列的基础数据），用于 T1.1 回填 `category_id`

**T1.4** 更新 `cpq_product_model` 种子数据：将旧 product_line/product_family/product_series 值回填为对应的 category_id

**T1.5** 新增菜单：产品分类管理（`menu_id=50085`, `parent_id=50080`, `component=cpq/category`）

**T1.6** 更新 12 角色菜单分配：给产品经理(104)/系统管理员(111) 分配 50085 菜单权限

---

### 组二：后端 Java — 新增 CpqProductCategory 全套 CRUD（7个文件）

**T2.1** `CpqProductCategory.java` — Domain 实体
- 字段：`categoryId, tenantId, categoryCode, categoryName, categoryLevel, parentCategoryId, sortOrder, status, delFlag + BaseEntity`
- 自引用：`parentCategoryId` FK → `categoryId`
- `@AutoMapper` 注解

**T2.2** `CpqProductCategoryBo.java` — 业务对象（含 `parentCategoryId`）

**T2.3** `CpqProductCategoryVo.java` — 展示对象（含 `parentCategoryName`、`children` 递归子节点列表）

**T2.4** `CpqProductCategoryMapper.java` + XML
- 查询方法：按租户查询全部、按 parent_id 查询子节点、按 category_level 查询指定层级

**T2.5** `ICpqProductCategoryService.java` — Service 接口
- 方法：selectCategoryList、selectCategoryById、insertCategory、updateCategory、deleteCategory、selectCategoryTree、selectByLevel

**T2.6** `CpqProductCategoryServiceImpl.java` — Service 实现
- `selectCategoryTree`：递归构建树形结构
- `deleteCategory`：有子节点的分类不可删除

**T2.7** `CpqProductCategoryController.java` — REST Controller
- API：GET `/category/tree`（树形数据）、GET `/category/list`（扁平列表）、GET `/category/{id}`、POST `/category`、PUT `/category`、DELETE `/{ids}`、GET `/category/byLevel/{level}`（按层级查）

---

### 组三：后端 Java — 修改已有 CpqProductModel（4个文件）

**T3.1** `CpqProductModel.java` — Domain 字段变更
- 删除字段：`productLine`、`productFamily`、`productSeries`
- 新增字段：`categoryId` (Long, FK → cpq_product_category)
- ⚠️ `@AutoMapper` 的字段索引可能会变化，需验证

**T3.2** `CpqProductModelBo.java` — BO 字段变更
- 删除字段：`productLine`、`productFamily`、`productSeries`
- 新增字段：`categoryId` (Long)
- 修改 configType 注释：添加 BUNDLE

**T3.3** `CpqProductModelVo.java` — VO 字段变更
- 删除字段：`productLine`、`productFamily`、`productSeries`
- 新增字段：`categoryId` (Long)、`categoryPath` (String，例如 "DMR数字对讲机 > 手持终端 > PD700系列")

**T3.4** `CpqProductModelMapper.xml` — 字段映射更新
- `<resultMap>` 中删除 productLine/productFamily/productSeries 映射
- 新增 categoryId 映射
- `<sql id="selectVo">` 和 `<sql id="selectBo">` 中同步更新字段列表

---

### 组四：后端 Java — Service 增强

**T4.1** `CpqProductModelServiceImpl.java` — 新增 `enrichCategoryPath` 方法
- 在 `selectModelList` 和 `selectModelById` 返回前，调用该方法
- 方法逻辑：根据 model 的 `categoryId` 查询 category 表，向上递归拼接 L1>L2>L3 路径字符串，set到 Vo 的 `categoryPath`
- 使用 `@Slf4j` 记录耗时

---

### 组五：前端 — 新增分类管理页面

**T5.1** `ruoyi-ui/src/api/cpq/category.ts` — API 模块
```typescript
// GET /cpq/category/tree — 获取树形结构
// GET /cpq/category/list — 获取扁平列表
// GET /cpq/category/{id} — 获取详情
// POST /cpq/category — 新增
// PUT /cpq/category — 编辑
// DELETE /cpq/category/{ids} — 删除
// GET /cpq/category/byLevel/{level} — 按层级查询
```

**T5.2** `ruoyi-ui/src/views/cpq/category/index.vue` — 分类管理页面
- 树形表格展示三级分类层级结构（Element Plus `<el-table>` + `row-key` + `tree-props`）
- 列：分类编码、分类名称、层级(产品线/产品族/产品系列)、父分类、排序、状态、操作
- 新增/编辑弹窗：分类编码、名称、层级(下拉选择1/2/3)、父分类(级联选择)、排序
- 删除：有子节点不可删除，提示"该分类下存在子分类，无法删除"
- L1级：创建时 `parentCategoryId=null` 或 0
- L2级：创建时选择 L1 父节点
- L3级：创建时选择 L2 父节点
- 风格参考现有 `catalog/index.vue`、`model/index.vue` 的 UI 规范

---

### 组六：前端 — 修改产品模型表单

**T6.1** `ruoyi-ui/src/views/cpq/model/index.vue` — 表单字段变更
- 删除 3 个 `<el-input>`：产品线(L1)、产品族(L2)、产品系列(L3)
- 新增 3 级级联 lookup 选择器替代：
  - 第1级：`<el-select>` 加载所有 L1（`GET /cpq/category/byLevel/1`）
  - 第2级：根据选中 L1 `<el-select>` 加载 L2（`GET /cpq/category/list?parentId=xxx`）
  - 第3级：根据选中 L2 `<el-select>` 加载 L3（`GET /cpq/category/list?parentId=xxx`）
  - 最终只存储选中的 L3 `categoryId` 到表单
  - 使用 `filterable` + `remote` 属性
- 搜索栏：同样将 3 个文本搜索改为级联 lookup
- 列表列：将原来三列（产品线/产品族/产品系列）合并为一列「产品分类」，显示 `categoryPath`

**T6.2** `ruoyi-ui/src/api/cpq/model.ts` — API 类型变更
- `CpqProductModel` 接口：删除 `productLine`/`productFamily`/`productSeries`，新增 `categoryId: number`、`categoryPath?: string`
- `CpqProductModelQuery` 查询参数：同上变更

---

### 组七：编译验证

**T7.1** 后端编译：`mvn clean compile` 零错误，解决 MapStruct 字段变更后的 `@AutoMapper` 重新生成

**T7.2** 前端编译：`vue-tsc --noEmit` 零错误

**T7.3** 后端启动：确保 Spring Boot 正常启动，Swagger 中 CpqProductCategory 和更新后的 CpqProductModel 端点可见

**T7.4** 前端启动：确保 `npm run dev` 正常，分类管理页面、产品模型页面可访问

---

### 组八：功能测试

**T8.1** 分类管理 CRUD 测试（通过 Swagger 或 curl）：
- 创建 L1（DMR数字对讲机）、L2（手持终端）、L3（PD700系列）
- 验证树形查询返回正确层级
- 验证删除有子节点的 L1/L2 被拒绝
- 验证删除 L3 成功

**T8.2** 产品模型表单测试：通过浏览器手动操作
- 新建模型时通过三级级联选择分类
- 列表正确显示 `categoryPath`
- 搜索筛选功能正常
- 编辑已有模型，分类信息正确回显

**T8.3** 已有功能回归：
- 产品目录(catalog) CRUD 正常
- 替代品管理(supersession) CRUD 正常

---

## 依赖关系与建议执行顺序

```
阶段 1（数据库）
  T1.2（建 category 表）
    → T1.3（种子数据：category）
      → T1.1（ALTER product_model 表）
        → T1.4（回填 category_id）
          → T1.5（新增菜单 50085）
            → T1.6（角色分配菜单）

阶段 2（后端）
  T2.1-T2.7（CpqProductCategory 全套 CRUD）
  T3.1-T3.4（CpqProductModel 字段变更）
  T4.1（enrichCategoryPath）

阶段 3（前端）
  T5.1-T5.2（category 页面）
  T6.1-T6.2（model 页面改造）

阶段 4（验证）
  T7.1-T7.4（编译验证）
  T8.1-T8.3（功能测试）
```

## 关键风险点

| 风险 | 影响 | 缓解措施 |
|------|------|---------|
| `CpqProductModel.java` 字段删除后，`@AutoMapper` 重建可能失败 | 编译错误 | T3.1 执行后立即 `mvn compile` 验证 MapStruct 生成 |
| 已有 seed 数据使用 product_line 旧字段 | 数据丢失 | T1.3 先建分类再回填（T1.4） |
| 级联 lookup 组件复杂度 | 前端交互延迟 | 使用 `remote` + `filterable` 减少选项加载量 |
| Mapper XML 字段变更遗漏 | 查询报错 | T3.4 需逐字段比对，T7.1 编译后全量 API 测试 |

## 总任务数

| 组 | 任务数 | 主要产出 |
|----|:---:|------|
| 数据库 | 6 | ALTER TABLE + 种子数据 + 菜单 |
| 后端新增 | 7 | CpqProductCategory 全套 CRUD |
| 后端修改 | 5 | CpqProductModel 字段迁移 + Service 增强 |
| 前端新增 | 2 | category API + 页面 |
| 前端修改 | 2 | model 表单 + 类型 |
| 验证 | 4 | 编译 + 启动 |
| 测试 | 3 | CRUD + 回归 |
| **总计** | **29** | — |
