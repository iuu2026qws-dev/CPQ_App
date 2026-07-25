---
name: ruoyi-lesson-learn
description: "RuoYi 项目开发教训与铁律。当需要在现有模块中新增页面、批量开发功能、或完成一轮开发后进行收尾检查时使用此 skill。包含模块内布局一致性原则、三端覆盖检查、路径冲突扫描等闭环验证规则，防止重复犯同样的错误。"
---

# RuoYi Lesson Learn — 开发教训与铁律

## 核心原则

### 原则 1：模块内布局一致性（2026-06-04 新增）

**铁律**：在某个模块内新增功能页面时，页面结构、布局、样式必须与该模块下已有页面**完全一致**。不允许新增页面自创一套布局风格。

**为什么**：同一模块下的页面是用户在同一子导航下切换使用的，布局不一致会造成割裂感，严重损害用户体验。

**执行方法**：
- 新增页面前，先打开该模块下任意一个已有页面（如列表页），复制其完整 `<template>` 结构骨架
- 在此基础上替换数据字段和标题，不要改动外层容器、grid 布局、卡片样式、分页组件等结构元素
- 完成后用 `diff` 工具对比新旧页面，确认结构骨架一致

**反面案例**：口腔学堂模块下，`CoursePlazaView` 使用 `n-grid` + `n-gi` + `CourseCard` 卡片组件，而新增的 `LearningPathView` 自创了一套 `card-grid` + `clay-card` + 内联 `style` 的结构。这就是违反一致性原则。

### 原则 2：做完不等于做完备

批量代码生成后，必须有系统性闭环校验，不能只验证"代码能编译"就认为完成。

---

## 闭环检查清单（每次批量开发完成后逐项执行）

1. **设计文档对照** — 逐模块核对设计文档中列出的功能点，确认前端+后端+DB 全部覆盖，不允许凭记忆
2. **三端覆盖检查** — 管理后台(ruoyi-vue-plus-frontend)、用户端(dental-portal)、后端(ruoyi-dental) 三方必须全部检查，不允许只检查一方
3. **路径冲突扫描** — 批量生成 Controller 后必须用脚本扫描所有 `@RequestMapping` 路径，检查是否有重复（两个 Controller 映射同一 URL 会导致 Spring 启动失败）
4. **入口状态审计** — 检查所有页面/模块的状态字段（如 PortalHomeView 的 `status: 'online' | 'dev'`），确保用户入口实际可用
5. **菜单入口对齐** — 不同入口（App.vue 导航 vs 首页卡片 vs 路由）的模块列表必须对齐，不允许一处有一处无
6. **JAR 打包验证** — `mvn compile` 通过不等于 `mvn package` 通过，必须实际打包并启动验证所有端点返回 200
7. **静态编译检查** — 后端 `mvn compile` + 前端 `vue-tsc --noEmit` 都必须零错误才算通过，不能只看后端
8. **布局一致性检查（2026-06-04 新增）** — 用户端新增页面必须与同模块已有页面使用相同的布局骨架，不允许自创风格

---

## 路径冲突扫描脚本

```bash
cd ruoyi-vue-plus-backend/ruoyi-modules/ruoyi-dental/src/main/java/org/dromara/dental/controller
python3 -c "
import re, os
paths = {}
for f in sorted(os.listdir('.')):
    if f.endswith('.java'):
        content = open(f).read()
        m = re.search(r'@RequestMapping\(\"(.*?)\"\)', content)
        if m:
            path = m.group(1)
            if path in paths:
                print(f'CONFLICT: {path} -> {paths[path]} vs {f}')
            else:
                paths[path] = f
"
```

---

## 真实教训案例（以此为镜）

### V2.0 批量开发（2026-06-04）

**背景**：完成 26 模块、91 实体、前后端全量 CRUD 代码生成。

**遗漏和错误**：

- 26 个后端模块全部生成完毕，但 dental-portal 用户端 0 更新
- `DentalChapterController` 与 `DentalCourseChapterController` 路径冲突（`/dental/chapter`）
- `CreditRuleController` 与 `DentalCreditRuleController` 路径冲突（`/dental/creditRule`）
- PortalHomeView 缺「创作者中心」入口，且除口腔学堂外全部 `status='dev'` 无法点击
- `mvn compile` 通过但 `mvn package` 有 spring-boot-maven-plugin 冲突，需要 `clean` 后重建
- 新增的 dental-portal 页面（LearningPathView、ExamRecordView）布局结构与该模块已有页面不一致

**如果当时执行了闭环清单**：以上 6 个问题全部可以在代码生成后的 10 分钟内发现并修复，而不是部署上线后才逐个暴露。

---

## 移动端开发铁律（2026-07-23 新增，基于 UniApp 微信小程序实战）

> **适用范围**：以下铁律中，标注「通用」的为跨项目普适规则；标注「Dental 项目」的仅适用于口腔学堂项目，新项目应根据自身设计系统调整。

### 铁律 1（通用）：图标必须用 Sharp 渲染 Lucide SVG，严禁 PIL 手绘

**为什么**：PIL 手绘图标极其丑陋。Sharp 是专业 SVG 渲染引擎，能正确渲染 SVG 的 `stroke`、`fill` 属性。

**正确做法**：
```javascript
const sharp = require('sharp');
// 1. 读 Lucide SVG
const svg = fs.readFileSync('node_modules/lucide-static/icons/user.svg', 'utf8');
// 2. 注入颜色（stroke="currentColor" 在渲染时是黑色，必须替换）
svg = svg.replace(/stroke="currentColor"/g, 'stroke="#17B5C5"');
// 3. 渲染 PNG
await sharp(Buffer.from(svg)).resize(w, h).png().toFile('output.png');
// 4. 头像用 composite 分层：先渲图标，再复合到色圈上
await sharp(circleBuffer).composite([{ input: iconBuffer, top: y, left: x }]).png().toFile('avatar.png');
```

**禁止**：`from PIL import Image, ImageDraw` / `d.ellipse()` / `d.polygon()` 手绘任何图标。

### 铁律 2（通用）：占位图按容器尺寸单独生成

不用已存在的图标直接放大塞进大容器。每个容器尺寸需要独立渲染对应尺寸的 PNG。

### 铁律 3（通用）：WeChat 小程序禁用 `<scroll-view>` + flex 布局

### 铁律 4（通用）：UniApp 中避免重量级 UI 库，优先用原生组件

### 铁律 5（通用）：登录页 `uni.login()` 加 3 秒超时

### 铁律 6（通用）：小程序按钮用 `<button>` + `@tap`

### 铁律 7（Dental 项目）：每个角色独立 Lucide 图标

本项目用心跳/听诊器/奖章/学位帽。线框风格 + `#4A5566`。**新项目根据自身角色选对应图标。**

### 设计令牌参考（Dental 项目，新项目替换为自己的）

| 令牌 | 值 |
|------|-----|
| 品牌主色 | `#17B5C5`（青色，同桌面） |
| 卡片圆角 | `24px` |
| 按钮形状 | Pill 胶囊（`border-radius: 48rpx`） |
| 文字主色 | `#0A1520` |
| 文字辅色 | `#4A5566` |
| 背景色 | `#F7F9FC` |
| 阴影 | `0 2px 8px rgba(10,21,32,0.04)` |
| TabBar 未选中 | `#8A93A3` |
| TabBar 选中 | `#17B5C5`（同名同色） |

---

## 使用方式

当以下场景触发时，AI 必须主动加载此 skill：
- 在已有模块中新增前端页面
- 批量生成代码完成后
- 用户提到"查漏补缺"、"检查遗漏"、"对齐"等关键词
- 部署到新环境前做最终检查

加载此 skill 后，AI 必须逐项执行闭环检查清单，并汇报检查结果。
