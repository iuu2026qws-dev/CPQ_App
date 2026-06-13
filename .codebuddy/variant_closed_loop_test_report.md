# 变体实体化功能 — 闭环测试报告

测试时间：2026-06-07 20:20 - 20:37  
测试范围：阶段2 变体实体化全部功能（6项）  
测试工具：curl（后端API）+ Playwright CLI（前端浏览器自动化）

---

## 一、数据库与基础设施

| 检查项 | 结果 |
|--------|:--:|
| cpq_product_variant 表 | 已创建 |
| cpq_price_book_entry.variant_id 列 | 已添加（NULLABLE） |
| cpq_channel_price.variant_id 列 | 已添加（NULLABLE） |
| 种子变体数据 | 192 条（覆盖82个STANDARD/ATO产品） |
| mvn install | BUILD SUCCESS |
| 后端重启 | http://localhost:8080 正常 |

---

## 二、后端 API 测试（8/8 通过）

| # | 端点 | 测试内容 | 结果 |
|---|------|---------|:--:|
| 1 | GET /cpq/product/variant/list?modelId=1040 | 变体列表查询 | 200, 2条 |
| 2 | POST /cpq/product/variant | 新增变体 | 200, 操作成功 |
| 3 | GET /cpq/product/variant/2001 | 变体详情 | 200, variantCode=ARC-A-A-YW |
| 4 | PUT /cpq/product/variant | 编辑变体 | 200, 操作成功 |
| 5 | GET /cpq/product/variant/batch?ids=2001,2002,2003 | 批量查询 | 200, 3条 |
| 6 | DELETE /cpq/product/variant/{id} | 删除变体 | 200, 操作成功 |
| 7 | GET /cpq/pricing/entry/list?priceBookId=1 | 价格条目（变体 enrich） | 200, variantCode/variantName 正确填充 |
| 8 | GET /cpq/pricing/channelprice/list | 渠道价格列表 | 200, 2条 |

### enrich 验证

新增条目（modelId=1001, variantId=2001）查询结果：
- variantCode: `ARC-A-A-YW`
- variantName: `SLAM ArcBot A 黄色(已更新)`

变体名称由后端 JdbcTemplate 一次批量 JOIN 返回，无需前端缓存。

---

## 三、前端浏览器自动化测试（Playwright CLI）

### 3.1 产品目录 — 变体管理（展开行内 VariantManager）

| 步骤 | 操作 | 结果 |
|------|------|:--:|
| 登录 | admin/admin123 登录 cpq-portal | 跳转 /catalog |
| 展开分类 | 点击「ARC弧焊系列」 | 表格加载 4 个产品（STANDARD×2 + ATO×2） |
| 展开产品行 | 点击 ARC-160 展开按钮 | 变体管理面板展开 |
| 查看变体 | 表格显示 3 个变体（黄/蓝/灰） | 编码/名称/属性解析/价格/默认标记 正确 |
| 新增变体 | 点击「新增变体」 | 弹窗完整显示（append-to-body 生效） |
| 填写表单 | 编码/名称/属性/价格 | 正常填写 |
| 提交 | 点击「确定」 | 弹窗关闭，变体列表刷新，新增「红色限量款」¥195000 |
| 成功提示 | — | "变体新增成功" |

关键修复验证：el-dialog `append-to-body` 解决了弹窗被表格裁剪的问题。

### 3.2 价格手册 — ModelLookup + VariantLookup

| 步骤 | 操作 | 结果 |
|------|------|:--:|
| 导航 | 点击侧边栏「价格手册」 | /pricing/book 页面加载 |
| 选择手册 | 点击「浏览器测试-修复后」 | 条目面板激活 |
| 新增条目 | 点击「新增条目」 | 弹窗打开 |
| ModelLookup | 搜索 "ARC-160" | 下拉显示 "RW-ARC-160 - ARC-160 紧凑型弧焊机器人 STANDARD" |
| 选产品 | 点击选中 STANDARD 产品 | VariantLookup 出现「变体（必选）」 |
| VariantLookup | 展开变体下拉 | 4 个变体（含默认标记 "ARC-A-A-YW 默认 ¥188000"） |
| 选变体 | 点击默认变体 | 目录价自动填充 ¥188000.00 |
| 提交 | 点击「确定」 | 弹窗关闭，条目出现在列表 |
| 列表显示 | — | 产品列: "RW-ARC-160 - ARC-160..." 变体列: "ARC-A-A-YW - SLAM ArcBot A 黄色(已更新)" 物料编码列: "ARC-A-A-YW" |

### 3.3 渠道价格 — ModelLookup + VariantLookup

| 步骤 | 操作 | 结果 |
|------|------|:--:|
| 导航 | 点击侧边栏「渠道价格」 | /pricing/channelprice 页面加载 |
| 新增 | 点击「新增」 | 弹窗含 ModelLookup + VariantLookup（组件一致） |
| 日期 | 生效日期预填 2026-06-07 | 正确 |

---

## 四、完整交互流程验证

```
产品目录 → 展开行 → 变体管理（新增/编辑/删除变体）  ✅
价格手册 → 新增条目 → ModelLookup 搜索 STANDARD → VariantLookup（必选）→ 选变体自动填价格+编码 → 提交 ✅
价格手册 → 列表展示变体编码+名称（后端 enrich）✅
渠道价格 → ModelLookup + VariantLookup 组件一致 ✅
el-dialog 弹窗 → append-to-body 不被表格裁剪 ✅
```

---

## 五、结论

**6 项测试全部通过，零失败。**

阶段2 变体实体化功能闭环：
- 后端：6 个变体 API 端点 + entry/channel_price varientId 字段 + JdbcTemplate enrich
- 前端：VariantManager（展开行管理）+ ModelLookup（产品搜索）+ VariantLookup（级联选择）+ 列表展示变体信息
- 修复：el-dialog append-to-body（弹窗遮挡）、mvn install（本地仓库 JAR 过期）、DDL 建表（cpq_product_variant 未执行）
