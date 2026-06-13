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

### 原则 3：TypeScript 类型导入必须是 import type（2026-06-06 新增）

**铁律**：从纯类型文件（只包含 `interface` / `type`，无运行时导出）导入任何类型时，**必须**使用 `import type { ... }`，而非 `import { ... }`。

**为什么**：`@vue/tsconfig` 默认设置 `verbatimModuleSyntax: true`。在此模式下，`import { PostVO }` 被当作运行时值导入，但 TypeScript 接口在编译时被完全擦除，导致 Vite/esbuild 报错"does not provide an export named 'XXX'"。`import type { ... }` 则明确告知编译器这是类型级导入，esbuild 也遵循此规则。

**执行方法**：
- 所有 `api/*/types.ts` 文件中的相互引用必须用 `import type`
- 所有从 `api/*/types.ts` 导入到 `.vue`、`api/*.ts`、`store/*.ts` 的类型必须用 `import type`
- 编写脚本扫描：`grep -rn "from.*api/.*/types" src/ | grep -v "import type"` 排查遗漏

**反面案例**：`src/api/system/user/types.ts` 中 `import { PostVO, RoleVO }` 和 `src/api/login.ts` 中 `import { UserInfo }`，都因缺少 `type` 关键字导致 main.ts 加载失败，整个页面白屏。

### 原则 4：全局类型声明不可依赖 esbuild 跨文件传播（2026-06-06 新增）

**铁律**：在 `global.d.ts` 中通过 `declare global` 声明的接口（如 `BaseEntity`、`PageQuery`），在 esbuild 环境下**不会**被其他文件自动识别。必须在一个 `.ts` 文件（非 `.d.ts`）中具体 `export`，其他文件显式 `import type`。

**为什么**：TypeScript 编译器 (`tsc`) 会处理全局类型传播，但 Vite 的开发服务器使用 esbuild 进行**逐文件独立编译**，不会维护跨文件的全局类型上下文。esbuild 遇到 `extends BaseEntity` 且无法在当前文件找到 `BaseEntity` 时，会静默丢弃整个 interface 声明，导致编译产物为 `export {}`。

**执行方法**：
- 创建 `src/types/base.ts`，在其中 `export interface BaseEntity { ... }` 和 `export interface PageQuery { ... }`
- 所有 `api/*/types.ts` 中需要 `extends BaseEntity` 或 `extends PageQuery` 的，顶部添加 `import type { BaseEntity, PageQuery } from '@/types/base'`
- 保留 `global.d.ts` 作为 IDE 类型提示辅助，但运行时依赖必须指向 `.ts` 文件

### 原则 5：跨项目代码移植的依赖完整性（2026-06-06 新增）

**铁律**：从 plus-ui 等上游项目移植代码目录时，不能只复制视图文件。必须同时检查并补全以下依赖链：

**必须检查的层次**：
1. **npm 包** — 检查被移植代码的 `import` 语句，逐一安装缺失包（如 `await-to-js`、`@vueuse/core`、`echarts`、`vue-cropper`、`unplugin-auto-import`、`jsencrypt` 等）
2. **Vite 插件** — `vite/plugins/` 目录必须完整移植，尤其是 `auto-import.ts`（处理 `@vueuse/core` 的 `useStorage` 等自动导入）和 `components.ts`（Element Plus 组件按需注册）
3. **工具函数** — `utils/` 下的文件（如 `request.ts`、`crypto.ts`、`jsencrypt.ts`、`ruoyi.ts`、`validate.ts`、`errorCode.ts`）必须全部就位
4. **类型声明** — `types/`、`enums/`、`settings.ts` 等配置文件不可遗漏
5. **静态资源** — `assets/images/`、`assets/svg/` 中的图标和图片文件

**负面案例**：移植 `views/system/` 和 `components/` 目录后，缺失了 `unplugin-auto-import` 导致 `useStorage`（`@vueuse/core`）未定义；缺失 `await-to-js` 导致 store 加载失败；缺失 `globalHeaders` 函数导致组件报错。这些缺失的依赖导致页面白屏，逐一排查耗时约 40 分钟。

### 原则 6：响应拦截器必须统一解包 RuoYi 标准包裹体（2026-06-06 新增）

**铁律**：在 `request.ts` 响应拦截器的成功分支（`code === HttpStatus.SUCCESS`），必须自动解包 RuoYi 标准响应格式 `{ code: 200, data: <业务数据> }`，让所有 `request.get()` / `request.post()` 的调用方拿到的是纯业务数据，而非包裹体。

**实现方式**（在 `return Promise.resolve(...)` 之前）：
```typescript
const body = res.data;
if (body !== null && typeof body === 'object' && 'data' in body) {
    return Promise.resolve(body.data);  // 自动解包
}
return Promise.resolve(body);  // 兼容 blob / arraybuffer 等非标准格式
```

**为什么**：RuoYi-Vue-Plus 后端所有接口统一返回 `{ code, msg, data }` 包裹体。如果不在拦截器层统一解包，每个 API 调用方都需要自己处理 `res.data.xxx`，这不现实且会随着代码生成器新增模块而持续产生 Bug。统一解包后，未来所有代码生成器生成的模块代码默认直接取 `res.access_token`、`res.rows` 等，无需额外兼容。

**反面案例**：`store/user.ts` 调用 `loginApi()` 后执行 `res.access_token`，拿到的却是 `undefined`（因为 data 在 `res.data.access_token`）。导致 token 为空，`loadUserInfo()` 请求无 token → 后端返回 401 → 触发"登录状态已过期"弹窗。

**与代码生成器的兼容性**：此原则确保代码生成器生成的代码（如 `listApi().then(res => res.rows)`）无需任何修改即可直接使用，因为响应拦截器已经自动剥离了包裹体。

### 原则 7：import.meta.glob 的别名前缀不可靠，组件解析必须多 key 兼容（2026-06-06 新增）

**铁律**：在使用 `import.meta.glob` 动态加载 Vue 组件并通过 key 查找时，**绝不能**假定 key 的格式是固定的（带 `@/` 或不带 `@/`）。必须在 `resolveComponent` 中同时尝试多种 key 格式。

**为什么**：Vite 的 `import.meta.glob('@/views/**/*.vue')` 在不同版本或模式下，对 `@/` 别名的处理行为不一致。某些版本解析后返回的 key 不带 `@/` 前缀（如 `src/views/system/user/index.vue`），而查找时如果只用 `@/views/...` 拼接，将永远无法命中，导致所有动态路由全部落到 Placeholder 占位组件。

**实现方式**（`resolveComponent` 函数内）：
```typescript
// 构造可能的文件路径
const filePaths = [
  `${clean}.vue`,
  `${clean}/index.vue`,
]
// 尝试多种 key 格式
const keyCandidates = [
  ...filePaths.map(p => `@/views/${p}`),     // 带别名
  ...filePaths.map(p => `src/views/${p}`),   // 无别名
  ...filePaths.map(p => `/src/views/${p}`),   // 绝对路径式
  ...filePaths.map(p => `views/${p}`),        // 纯相对路径
]
for (const key of keyCandidates) {
  if (viewsModules[key]) {
    return viewsModules[key] as () => Promise<Component>
  }
}
console.warn(`[Router] 组件未找到: ${componentPath}`, '尝试路径:', keyCandidates)
return null
```

**反面案例**：系统管理/系统监控/系统工具下的所有二级菜单（用户管理、角色管理、菜单管理等共 20+ 个页面），点击后全部显示"页面建设中 — 该页面功能尚未实现或组件缺失"。实际 views/ 目录下所有页面文件均存在且功能完整，根因是 `import.meta.glob` 返回的 key 为 `src/views/...` 格式，而 `resolveComponent` 只查找 `@/views/...`，两边格式不匹配，全部返回 null。

**影响范围**：所有通过后端菜单数据动态注册的路由都会受影响。静态路由（如首页、登录页）不受影响，因为它们不通过 `import.meta.glob` + key 查找来解析。

### 原则 8：响应拦截器自动解包后，所有 API 调用方必须用 Array.isArray 兼容两种数据格式（2026-06-06 新增）

**铁律**：所有从 API 获取数据并访问 `res.data` 的地方，必须先判断数据是否已被响应拦截器自动解包。推荐模式：`Array.isArray(res) ? res : res.data`。

**为什么**：`request.ts` 响应拦截器在成功分支自动解包 `{ code, data: <业务数据> }` 格式。但不同后端 API 的响应格式不一致：
- 部分 API 返回 `{ code, data: [...] }`（如菜单列表、部门树）→ 拦截器解包后 res 为数组
- 部分 API 返回 `{ code, data: { rows, total } }`（如用户列表）→ 拦截器解包后 res 为 `{ rows, total }`
- 部分 API 返回 `{ total, rows, code, msg }`（如通知公告列表，无 data 包裹）→ 拦截器不解包

若 `res` 已是数组，再访问 `res.data` 会得到 `undefined`，导致页面白屏或无限 loading。反之若 `res` 是完整响应体，直接访问业务字段（如 `res.rows`）也会得到 `undefined`。

**受影响的文件模式**（全项目约 32 个文件）：
- `views/**/*.vue` 中调用 API 后访问 `res.data` 或 `response.data` 的地方
- `utils/dict.ts` 中 `useDict` 的 `resp.data.map(...)`
- 任何对 API 响应结果使用 `.data` 属性的地方

**修复模式**：
```typescript
// 原代码（在拦截器自动解包后可能出错）
const res = await listMenu()
menuList.value = res.data  // 如果拦截器已解包(返回数组)，res.data = undefined

// 修复后
const res = await listMenu()
const menuData = Array.isArray(res) ? res : res.data  // 兼容两种格式
menuList.value = menuData
```

**反面案例**：菜单管理页 `for (const menu of res.data)` → `res.data` 为 undefined → 循环不执行 → `loading` 永远不设为 false → 表格永远转圈。部门管理、通知公告、文件管理、字典加载等均受此影响。

**与原则 6 的关系**：原则 6 在拦截器层统一解包，原则 8 是调用方必须遵守的兼容模式。两者搭配使用才能确保新旧代码都能正常工作。

### 原则 9：路径拼接禁止盲目拼接，必须先归一化去前导斜杠（2026-06-06 新增）

**铁律**：在拼接 `parentPath` + `childPath` 形成完整路径时，**必须先**用 `.replace(/^\/+/, '')` 去除 `parentPath` 的前导 `/`，再进行拼接。绝对不能直接用模板字面量 `/${parentPath}/${childPath}`。

**为什么**：后端返回的菜单数据中，父菜单的 `path` 字段可能带前导 `/`（如 `/system`），也可能不带（如 `system`）。如果父路径已带 `/`，再用模板字面量 `/${parentPath}/${childPath}` 会产生双斜杠 `//system/user`。`el-menu` 的 `router` 模式或 Vue Router 的路径匹配会因双斜杠而失败，导致菜单点击无反应。

**正确实现**：
```typescript
function resolvePath(path: string, parentPath?: string): string {
  if (path.startsWith('/')) return path
  if (parentPath) {
    // 关键：去除 parentPath 的前导 /，避免产生双斜杠
    const cleanParent = parentPath.replace(/^\/+/, '')
    return `/${cleanParent}/${path}`   // → /system/user  ✅
  }
  return `/${path}`
}
```

**错误实现（反面案例）**：
```typescript
function resolvePath(path: string, parentPath?: string): string {
  if (path.startsWith('/')) return path
  if (parentPath) return `/${parentPath}/${path}`
  // 当 parentPath = '/system', path = 'user'
  // 结果 = '//system/user'  ❌ 双斜杠！
  return `/${path}`
}
```

**影响范围**：
- 所有侧边栏子菜单（`el-sub-menu` 下的 `el-menu-item`）点击导航全部失效
- 所有需要拼接路径的位置（如 tab 标签页、动态路由注册中的 `fullPath` 计算）
- 直接访问 URL 不受影响（Vue Router 会归一化直接输入的 URL），仅影响代码中通过 `resolvePath` 拼接后传给 `el-menu-item :index` 的情况

**执行方法**：
- 在所有路径拼接函数（`resolvePath`、`addMenuRoutes` 中的 `fullPath` 计算）中，拼接前统一对 `parentPath` 做 `.replace(/^\/+/, '')` 归一化
- 编写单测或控制台验证：传入 `/system` + `user`，输出必须为 `/system/user`（单个斜杠），而非 `//system/user`
- 对 `router.addRoute` 注入路径也做同样检查：用 `console.log` 打印所有已注册路由的 path，确认无双斜杠

**反面案例**：系统管理 → 用户管理、角色管理、菜单管理等所有子菜单点击后页面无任何反应，面包屑仍显示"首页工作台"，URL 不变。根因是 `resolvePath('user', '/system')` 返回 `//system/user`，`el-menu` 的 `router` 模式因双斜杠无法匹配任何路由，`$router.push` 静默失败。

### 原则 10：页面刷新会丢失动态路由，必须实现 sessionStorage 恢复机制（2026-06-06 新增）

**铁律**：Vue Router 的动态路由（`addRoute`）在页面刷新后会丢失，因为模块级变量（包括 `routesReady` 标志和已注册的路由）全部重置。必须在路由守卫中检测路由就绪状态，并用 sessionStorage 暂存目标路径，在 Layout 的 `onMounted` 中恢复。

**为什么**：RuoYi-Vue 的动态路由在登录时通过 `loadMenus()` → `addDynamicRoutes()` 注册。用户登录后一切正常，但按 F5 刷新页面后：
1. 路由守卫放行（token 有效）
2. Vue 渲染 Layout 组件
3. Layout 的 `onMounted` 异步加载菜单和注册路由
4. 但 Vue Router 的导航在 `onMounted` 完成前就已执行，目标路径的动态路由尚未注册
5. catch-all `:pathMatch(.*)*` 匹配 → 重定向到 `/dashboard`

**实现方式**：
1. `router/index.ts`：维护 `routesReady` 模块级标志，`addDynamicRoutes()` 末尾置 `true`，`clearDynamicRoutes()` 重置为 `false`，导出 `isRoutesReady()`
2. 路由守卫：`!routesReady && to.path !== '/dashboard'` → `sessionStorage.setItem('restorePath', to.fullPath)` → `next('/dashboard')`
3. `layout/index.vue` 的 `onMounted`：`await userStore.loadMenus()` 后读取 `sessionStorage.restorePath`，存在则 `router.push(restorePath)` 并清除

**反面案例**：登录后点击"文件管理"正常显示，但刷新页面（F5）后 URL 直接输入 `/system/oss` 会跳到首页工作台，因为动态路由尚未注册。

**注意**：此机制与同项目内可能存在的其他路由系统（如 `store/modules/permission.ts` 的 `generateRoutes` + `filterAsyncRouter`）不冲突，因为它们通过不同的 store 驱动。

### 原则 11：侧边栏模板必须支持多级菜单递归渲染，不可止步于一层（2026-06-06 新增）

**铁律**：`layout/index.vue` 的侧边栏 `<el-menu>` 模板中，渲染一级子菜单时（`v-for="child in menu.children"`），必须检查 `child.children` 是否非空。如果子菜单本身还有子菜单（典型的 `comp=ParentView` 的菜单项），**必须**渲染为嵌套 `<el-sub-menu>` 而不是平面 `<el-menu-item>`。

**为什么**：
1. **功能缺失**：若不支持递归渲染，用户无法在侧边栏看到三级菜单的子项（如"操作日志"、"登录日志"隐藏在"日志管理"下），只能靠重定向隐式跳转
2. **导航竞态**：平面渲染的 `<el-menu-item>` 点击后触发重定向（`/system/log` → `/system/log/operlog`），`route.path` 经历两次变化，`activeMenu` 快速切换触发 sidebar 重渲染。`el-menu` 在路由跳转中途重渲染可能导致导航中断，落入 catch-all 兜底路由 → 显示首页工作台。第二次点击时路由缓存稳定，又能正常工作。这是间歇性 bug，极易被忽略
3. **高亮缺失**：重定向后的最终路径（如 `/system/log/operlog`）无法匹配任何 `<el-menu-item>` 的 `index`，`el-menu` 无法高亮任何菜单项

**正确实现**（`layout/index.vue` 模板）：
```html
<el-sub-menu v-if="menu.children && menu.children.length > 0" :index="menu.path">
  <template #title>...</template>
  <!-- 关键：child 有 children 时渲染为嵌套 el-sub-menu -->
  <template v-for="child in menu.children" :key="child.path">
    <el-sub-menu
      v-if="child.children && child.children.length > 0 && !child.hidden"
      :index="resolvePath(child.path, menu.path)"
    >
      <template #title>
        <span>{{ child.meta?.title || child.name }}</span>
      </template>
      <el-menu-item
        v-for="grandchild in child.children"
        :key="grandchild.path"
        :index="resolvePath(grandchild.path, resolvePath(child.path, menu.path))"
        :class="{ 'is-hidden': grandchild.hidden }"
      >
        <span>{{ grandchild.meta?.title || grandchild.name }}</span>
      </el-menu-item>
    </el-sub-menu>
    <el-menu-item v-else-if="!child.hidden" :index="resolvePath(child.path, menu.path)">
      <span>{{ child.meta?.title || child.name }}</span>
    </el-menu-item>
  </template>
</el-sub-menu>
```

**错误实现（反面案例）**：
```html
<!-- 只渲染一层，child 无论是否有 children 都渲染为 el-menu-item → 日志管理子菜单不可见 -->
<el-menu-item v-for="child in menu.children" :index="resolvePath(child.path, menu.path)">
  <span>{{ child.meta?.title || child.name }}</span>
</el-menu-item>
```

**影响范围**：
- 所有 `comp=ParentView` 的二级菜单（如系统管理 → 日志管理 → 操作日志/登录日志）
- 所有 `comp=ParentView` 的嵌套菜单（如工作流 → 流程监控 → 流程实例/全部待办）
- 不影响的：顶层 `comp=ParentView` 菜单（如 CPQ 管理下的产品主数据等），它们位于 `menus` 顶层，`v-for="menu in menus"` 已正确渲染为 `<el-sub-menu>`

**验证方法**：
- 登录系统后，展开含 ParentView 子菜单的菜单（如系统管理），确认 ParentView 项渲染为可展开的 `<el-sub-menu>`（有箭头图标），而非平面 `<el-menu-item>`
- 点击其子项（如"操作日志"），确认首次点击即可正确导航（不跳到首页工作台）
- 确认导航后面包屑和页面内容正确，侧边栏父菜单保持展开状态

**反面案例**：系统管理 → 日志管理 → 操作日志。首次点击日志管理跳到首页工作台，第二次才能正常显示；侧边栏中看不到操作日志和登录日志两个子项。

### 原则 12：所有 Vue 页面中禁止使用 `res.data` / `{ data }` 解构访问 API 响应（2026-06-06 新增）

**铁律**：在任何 Vue 页面中，所有通过 `request()` （含 `request.get()`、`request.post()` 等）发起的 API 调用，**禁止**使用 `.data` 访问响应数据，也**禁止**使用 `{ data }` 解构赋值。直接用 `res` 本身即为业务数据。

**为什么**：`src/utils/request.ts` 响应拦截器（第 167-170 行）对 RuoYi 标准格式 `{ code: 200, data: <业务数据> }` 自动解包，`await someApi()` 的返回值已经是内层业务数据（而非 `{ code, data }` 包裹体）。此时 `res.data` 为 `undefined`，`{ data }` 解构得到 `undefined`。

| 错误写法 | 后果 | 正确写法 |
|---------|------|---------|
| `Object.assign(form.value, res.data);` | `form` 保持初始空值→弹窗空白 | `Object.assign(form.value, res);` |
| `form.value = res.data;` | `form` 被赋为 `undefined`→模板访问 `form.xxx` 时 **TypeError 崩溃** | `form.value = res;` |
| `const { data } = await someApi(); form = data;` | 同上 | `const res = await someApi(); form = res;` |
| `res.data.menus` / `res.data.depts` | `undefined.menus` → **TypeError 崩溃** | `res.menus` / `res.depts` |
| `handleTree(response.data, ...)` | `handleTree(undefined)` → 返回空/null，下拉树为空 | `handleTree(response, ...)` |
| `deptOptions.value = res.data;` | 下拉选项为空数组 | `deptOptions.value = res;` |

**适用范围**：全部 Vue 页面的 `<script>` 区域，包括但不限于：
- 列表页的 `getList()`（查询数据填充表格）
- 编辑页/弹窗的 `handleUpdate()`（回填表单）
- 所有 `.value = res.data` 或 `Object.assign(x, res.data)` 的赋值
- 所有 `{ data }` 解构 API 返回值的语句
- 树数据、下拉选项数据的赋值

**代码生成规则（铁律）**：
- AI 或代码生成器生成 CRUD 页面时，**禁止**输出 `res.data`、`response.data`、`{ data }` 解构
- 所有 API 调用后的赋值，直接使用 `res` / `response` 作为数据源
- 生成完成后，必须 grep 扫描 `.data` 确认无遗漏

**验证方法**：
```bash
cd ruoyi-ui
grep -rn "\.data" src/views/ --include="*.vue" | grep -v "//.*\.data" | grep -v "\.data()" | grep -v "\.dataSource"
```
检查所有输出，确认无 `res.data`、`response.data`、`{ data }` 等模式。对每条输出，确认是合理的非 API 响应访问（如 `el-table` 的 `:data` 属性等），非合理项必须修复。

**反面案例**：系统管理 → 菜单管理 → 点击修改按钮 → `form.value.menuType` 访问 `undefined` 的属性 → TypeError 崩溃；角色管理 → 点击编辑 → `res.data.menus` → 同上崩溃。影响 17 个文件，共 50+ 处。

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
9. **type import 完整性扫描（2026-06-06 新增）** — 移植代码后执行 `grep -rn "from '.*api/.*/types'" src/ | grep -v "import type"` 排查所有遗漏的 `import type`
10. **浏览器运行时验证（2026-06-06 新增）** — `vue-tsc --noEmit` 通过不代表页面能渲染，必须用 agent-browser 打开实际页面并 eval `import('/src/main.ts')` 确认无运行时模块加载错误
11. **响应拦截器数据解包检查（2026-06-06 新增）** — 确认 `request.ts` 成功分支已自动解包 `{ code, data }` 包裹体，确保代码生成器生成的模块无需手动处理 `res.data.xxx` 二次解包
12. **动态路由组件解析多 key 兼容检查（2026-06-06 新增）** — 确认 `router/index.ts` 的 `resolveComponent` 函数尝试了多种 key 格式（`@/views/...`、`src/views/...`、`/src/views/...`、`views/...`），确保无论 Vite 的 `import.meta.glob` 以哪种格式返回 key 都能命中组件
13. **API 响应数据访问兼容性检查（2026-06-06 新增）** — 确认所有访问 `res.data` 的地方使用了 `Array.isArray(res) ? res : res.data` 模式，兼容拦截器自动解包后的两种数据格式。同时也必须检查 `utils/dict.ts`、store 和所有 views 文件
14. **页面刷新动态路由恢复检查（2026-06-06 新增）** — 确认 `router/index.ts` 有 `routesReady` 标志和 sessionStorage 暂存机制，Layout 的 `onMounted` 能在路由加载后恢复目标路径。验证方式：登录后直接刷新 `/system/oss` 或 `/system/log` 等动态路由页面，应能正确渲染而非跳到首页工作台
15. **路径拼接双斜杠检查（2026-06-06 新增）** — 所有路径拼接函数（`resolvePath`、`addMenuRoutes` 中的 `fullPath` 计算等）在拼接 `parentPath + childPath` 时，必须先对 `parentPath` 做 `.replace(/^\/+/, '')` 归一化。验证方式：`console.log` 打印所有 `el-menu-item` 的 `:index` 值，确认无双斜杠（如 `//system/user`）。也可在 `addDynamicRoutes` 完成后打印所有已注册路由的 path 做检查
16. **多级菜单递归渲染检查（2026-06-06 新增）** — 新建或修改菜单后，扫描后端菜单表（`sys_menu`）中所有 `component='ParentView'` 的记录。如果该记录不是顶级菜单（`parent_id=0`），则侧边栏模板必须支持递归渲染：`layout/index.vue` 的 `v-for="child in menu.children"` 内部应先检查 `child.children.length > 0` 来决定渲染嵌套 `<el-sub-menu>` 还是 `<el-menu-item>`。验证方式：用 agent-browser 登录后，逐级展开含 ParentView 子菜单的菜单组，确认子项可见、首次点击即可正确导航、面包屑能正确高亮
17. **全量 `.data` 访问扫描（2026-06-06 新增）** — 每次新增或修改 Vue 页面后，必须执行 `grep -rn "\.data" src/views/ --include="*.vue"` 扫描所有 `.data` 访问，确认无 `res.data`、`response.data`、`{ data }` 等拦截器解包后的冗余访问。如果发现 `.data` 出现在 API 响应后的赋值语句中，必须改为直接从 `res` 取值。验证方式：先跑 grep 扫描，再用 agent-browser 打开各页面的弹窗（新增/修改），确认表单回填正常，无 TypeError
18. **userStore import 一致性审计（2026-06-06 新增）** — 项目稳定后执行一次 `grep -rn "import.*useUserStore" src/ --include="*.ts" --include="*.vue"`，确认只有一套 store 路径被引用。如有两套路径混用，必须统一
19. **localStorage 读写配对检查（2026-06-06 新增）** — 对每个 store 文件执行 `grep -n "localStorage.setItem"` vs `grep -n "localStorage.getItem"`，确认每条写入在 store 初始化中有对应的读取恢复
20. **菜单 SQL path 字段 NULL 检查（2026-06-06 新增）** — 执行 `SELECT menu_id, menu_name, path FROM sys_menu WHERE path IS NULL`。所有结果必须修复：顶级父菜单（parent_id=0）设 path=''，子菜单设合法 path 值（不能为 NULL）。同时检查前端 `addMenuRoutes` 中是否有对 `'null'`/`'/null'` 的防御性处理。验证方式：修复后调用 `/getRouters` 接口，确认所有菜单 path 不为字符串 "null"
21. **BO/Entity 继承链与 @AutoMapper 一致性检查（2026-06-06 新增）** — 对每个 BO 类：(1) 确认其 extends 父类与对应 Entity 完全一致（同是 BaseEntity 或同是 TenantEntity）；(2) 确认有 `@AutoMapper(target = XxxEntity.class, reverseConvertGenerate = false)` 注解；(3) 执行 `mvn clean package -DskipTests` 全量打包（非子模块编译）后，启动应用验证新增/修改接口返回 200。验证方式：curl POST 新增一条数据，确认 code=200 且数据写入数据库
22. **@TableLogic delval 统一性检查（2026-06-09 新增）** — 新增实体或修改模块后，执行 `grep -rn "@TableLogic" --include="*.java" -A1 | grep -E "@TableLogic|delval"` 扫描模块内所有 `@TableLogic` 注解，确认全部显式指定 `value = "0", delval = "2"`（与 SQL DDL 中「0正常 2删除」一致）。同时执行 SQL 检查数据库中 `del_flag='1'` 的残留数据：`SELECT del_flag, COUNT(*) FROM <table> WHERE del_flag != '0' GROUP BY del_flag`，输出应只有 '2'。特别注意：当唯一键不包含 `del_flag` 时，序列号（行号、编号）生成必须考虑软删除行占用的唯一键，用专门的 MAX+1 方法（不能绕过 @TableLogic 替换所有查询）

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

### plus-ui 管理后台移植 & 白屏修复（2026-06-06）

**背景**：从官方 plus-ui 仓库移植完整的管理后台界面（系统管理/租户管理/系统监控/系统工具/工作流等），替换原有占位页面。移植后 `vue-tsc --noEmit` 零错误，但浏览器打开 `localhost:3000` 一片空白。

**遗漏和错误**：

1. **缺失 10+ npm 包** — `await-to-js`、`@vueuse/core`、`echarts`、`vue-cropper`、`unplugin-auto-import`、`unplugin-vue-components`、`jsencrypt`、`crypto-js` 等全部缺失，Vite 报 `Failed to resolve import` 逐个暴露
2. **`DirectiveBinding` 等类型从 `vue` 的值导入失败** — plus-ui 使用 `import { DirectiveBinding } from 'vue'`，但 Vue 3.5 不直接导出此类型，必须改为 `import type`
3. **全局类型 `BaseEntity` / `PageQuery` 在 esbuild 中失效** — 26 个 `api/*/types.ts` 文件都用 `extends BaseEntity` 扩展全局接口，但 esbuild 逐文件编译时不传播 `global.d.ts` 的声明，导致所有接口编译为 `export {}`，浏览器报 `does not provide an export named 'XXX'`
4. **`verbatimModuleSyntax` 导致接口 value import 失败** — `login.ts` 和 `user/types.ts` 中 `import { UserInfo/PostVO/RoleVO }` 缺少 `type` 关键字，模块加载失败
5. **自定义 request.ts 功能不完备** — 缺少 plus-ui 组件的运行时依赖：`globalHeaders()`、`download()`、`isRelogin`
6. **Vite 插件体系不完整** — 只复制了 UnoCSS，缺失 `unplugin-auto-import`（`useStorage`/`useRouter` 等 @vueuse/core 函数未自动导入）和 `unplugin-vue-components`（Element Plus 组件未按需注册）
7. **独立文件的缺失** — `utils/crypto.ts`、`utils/jsencrypt.ts`、`utils/validate.ts`、`api/login.ts`、`api/types.ts`、`assets/images/profile.jpg` 等文件逐个暴露

**总耗时**：约 1 小时 20 分钟（从开始移植到页面正常渲染），其中 40 分钟用于逐一排查白屏根因。

**如果当时执行了本原则**：
- 移植前先 `diff` plus-ui 和当前项目的 `package.json`，一次性安装所有缺失包（节省 15 分钟逐包安装）
- 用脚本扫描 `import type` 遗漏（节省 10 分钟排查 interface export 错误）
- 将 `global.d.ts` 中的类型提前迁移到 `.ts` 具体导出（节省 15 分钟排查 `BaseEntity` 问题）
- 检查 `vite/plugins/` 完整性（节省 10 分钟排查 `useStorage` 未定义）
- 用 agent-browser 代替 `vue-tsc --noEmit` 做最终验证（**vue-tsc 零错误 ≠ 页面可渲染**）

### 系统管理子菜单点击无反应（2026-06-06）

**背景**：登录系统后，展开"系统管理"菜单，点击任何子菜单（用户管理、角色管理、菜单管理等）页面均无反应，面包屑和 URL 不变，始终停留在首页工作台。与之对照，直接在浏览器地址栏输入 URL（如 `/system/user`）可以正常访问该页面。

**根因**：`layout/index.vue` 中 `resolvePath` 函数拼接子菜单路径时产生双斜杠。后端返回的父菜单 `path` 已带前导 `/`（如 `/system`），模板字面量 `/${parentPath}/${childPath}` 又追加一个 `/`，结果 `resolvePath('user', '/system')` 返回 `//system/user`。`el-menu` 的 `router` 模式因双斜杠无法匹配路由，`router.push` 静默失败。

**修复**：`resolvePath` 拼接前用 `.replace(/^\/+/, '')` 去除 `parentPath` 前导斜杠，修改一行代码即可：
```typescript
// 修复前：resolvePath('user', '/system') → '//system/user' ❌
// 修复后：resolvePath('user', '/system') → '/system/user'  ✅
if (parentPath) {
  const cleanParent = parentPath.replace(/^\/+/, '')
  return `/${cleanParent}/${path}`
}
```

**教训**：路径拼接时永远不能假设数据源的格式（带或不带前导 `/`）。必须先归一化（`.replace(/^\/+/, '')`），再统一加 `/` 前缀拼接。此外，路由注册时 `addMenuRoutes` 已做了 `cleanPath` 处理（`router.addRoute` 用的是无前导 `/` 的 `system/user`），但侧边栏的 `el-menu-item :index` 是另一个独立的路径计算路径，必须各自独立保证格式正确。

### 日志管理三级菜单首次点击跳到首页工作台（2026-06-06）

**背景**：后台菜单中，"操作日志"和"登录日志"是"日志管理"（`comp=ParentView`）的子项，"日志管理"又是"系统管理"的子项，构成三级嵌套（系统管理 → 日志管理 → 操作日志）。登录后展开系统管理，点击"日志管理"偶尔跳到首页工作台（不是操作日志页面），再点一次才能正常跳转。其他同级子菜单（用户管理、角色管理等）完全正常。

**根因**：`layout/index.vue` 的侧边栏模板只支持一层嵌套（`el-sub-menu` → `el-menu-item`），遇到有子菜单的 `child`（如日志管理），仍然渲染为平面 `el-menu-item` 而不是嵌套 `el-sub-menu`。用户只能点击"日志管理"这个 `el-menu-item`（index=`/system/log`），触发路由重定向（`/system/log` → `/system/log/operlog`），`route.path` 经历两次快速变化（`activeMenu` 先变 `/system/log` 再变 `/system/log/operlog`），sidebar 在路由跳转中途重渲染。`el-menu` 在此竞态窗口可能进入不一致状态，导致 Vue Router 的重定向解析被打断，导航落入 catch-all `:pathMatch(.*)*` → 重定向到 `/dashboard`（首页工作台）。第二次点击时路由缓存已稳定，重定向正常执行。

此外，最终 URL `/system/log/operlog` 在 sidebar 中没有任何 `el-menu-item` 的 `:index` 能匹配（sidebar 中"日志管理"的 index 是 `/system/log`，不是 `/system/log/operlog`），导致 `el-menu` 无法高亮任何菜单项。

受影响的不仅是日志管理，工作流下的"流程监控"（同样 `comp=ParentView`）也存在相同的间歇性导航失败和高亮缺失问题。

**修复**：修改 `layout/index.vue` 模板，将渲染 `child` 的单一 `<el-menu-item>` 循环替换为条件判断——`child.children` 非空时渲染嵌套 `<el-sub-menu>`，否则渲染 `<el-menu-item>`：

```html
<!-- 修复前：所有 child 统一渲染为 el-menu-item → 日志管理子菜单不可见 -->
<el-menu-item v-for="child in menu.children" :index="resolvePath(child.path, menu.path)">
  <span>{{ child.meta?.title || child.name }}</span>
</el-menu-item>

<!-- 修复后：child 有 children 时渲染为嵌套 el-sub-menu -->
<template v-for="child in menu.children" :key="child.path">
  <el-sub-menu
    v-if="child.children && child.children.length > 0 && !child.hidden"
    :index="resolvePath(child.path, menu.path)"
  >
    <template #title><span>{{ child.meta?.title || child.name }}</span></template>
    <el-menu-item
      v-for="grandchild in child.children"
      :key="grandchild.path"
      :index="resolvePath(grandchild.path, resolvePath(child.path, menu.path))"
      :class="{ 'is-hidden': grandchild.hidden }"
    >
      <span>{{ grandchild.meta?.title || grandchild.name }}</span>
    </el-menu-item>
  </el-sub-menu>
  <el-menu-item v-else-if="!child.hidden" :index="resolvePath(child.path, menu.path)">
    <span>{{ child.meta?.title || child.name }}</span>
  </el-menu-item>
</template>
```

**验证结果**：
- 系统管理 → 日志管理 展开后显示"操作日志"和"登录日志"两个子项（之前不可见）
- 点击"操作日志"或"登录日志"首次即可正确导航（不再跳到首页工作台）
- 面包屑正确显示，侧边栏对应菜单项正确高亮
- 工作流 → 流程监控 同样修复（显示流程实例、全部待办等子项）
- 其他菜单（用户管理、CPQ 管理下的所有 ParentView 菜单）无回归，功能正常
- `vue-tsc --noEmit` 零错误

**教训**：
1. 侧边栏模板不能假设菜单只有两层。任何引入 `ParentView` 组件作为非顶级菜单时，sidebar 必须能递归渲染
2. 路由重定向 + sidebar 重渲染的竞态是一个隐蔽的坑——看上去"第二次点击就好了"常被误判为偶发问题，实则是确定性 bug
3. 新增菜单时，应扫描后端 `sys_menu` 表中所有 `component='ParentView'` 且 `parent_id != 0` 的记录，确保侧边栏能正确渲染
4. Element Plus 的 `el-menu` 原生支持多级嵌套，不需要额外的工作

### 全局 .data 访问导致表单回填崩溃和弹窗空白（2026-06-06）

**背景**：Plan B 修复按钮权限后，用户开始正常使用 RuoYi 系统页面的编辑功能，发现点击修改按钮时，菜单管理页报 `TypeError: Cannot read properties of undefined (reading 'menuType')`，部门管理、角色管理等页面也有类似崩溃。排查发现是拦截器自动解包后，所有页面仍用 `res.data` / `{ data }` 访问响应数据。

**根因**：`src/utils/request.ts` 响应拦截器（第 167-170 行）对 `{ code: 200, data: <业务数据> }` 自动解包，返回 `body.data`（即内层业务数据）。但 17 个 Vue 页面共 50+ 处代码仍使用 `res.data`、`response.data`、`{ data }` 解构来访问响应数据，导致 `undefined`。

**影响分级**：
- **TypeError 崩溃（3 个文件）**：
  - `system/menu/index.vue:471`：`const { data } = await getMenu()` → `form.value = undefined` → 模板 `form.menuType` TypeError
  - `system/dept/index.vue:282`：`form.value = res.data` → `form = undefined` → 模板 TypeError；`response.data` → 树数据为空
  - `system/role/index.vue:394,401`：`res.data.menus` / `res.data.depts` → TypeError
- **表单空白（7 个文件）**：`Object.assign(form, res.data)` / `Object.assign(form, data)` → `undefined` → 静默失败，修改弹窗数据不回填
  - `system/client/index.vue:259`、`system/config/index.vue:219`、`system/dict/index.vue:462,563`、`system/notice/index.vue:215`、`system/oss/config.vue:297`、`system/post/index.vue:320`、`system/user/index.vue:353`
- **下拉/树数据为空（2 个文件）**：`deptOptions.value = res.data` → 选项为 undefined；`res.data.menus/depts` → TypeError
  - `system/post/index.vue:250`、`system/role/index.vue:394,401`

**修复**：17 个文件，逐一将 `res.data` → `res`，`{ data }` → 直接用 `res`，`response.data` → `response`。

| 错误模式 | 修复 |
|---------|------|
| `Object.assign(form.value, res.data)` | `Object.assign(form.value, res)` |
| `form.value = res.data` | `form.value = res` |
| `const { data } = await someApi(); form = data` | `const res = await someApi(); form = res` |
| `res.data.menus; return res.data` | `res.menus; return res` |
| `handleTree(response.data, ...)` | `handleTree(response, ...)` |
| `deptOptions.value = res.data` | `deptOptions.value = res` |

**验证**：`vue-tsc --noEmit` 零错误，agent-browser 打开系统管理下各页面的编辑弹窗，确认表单回填正常。

**教训**：
1. `.data` 访问是拦截器自动解包后的系统性冗余，不是个别代码写法问题，而是所有通过 RuoYi `request()` 发起的 API 调用都不应有 `.data`
2. 代码生成器（含 AI 生成）生成 CRUD 页面时，**禁止**输出 `res.data`、`{ data }` 解构、`response.data` 等模式。生成后必须 grep 扫描确认
3. 新增页面完成后执行 `grep -rn "\.data" src/views/ --include="*.vue"` 作为收尾检查

### 双 Store 体系下 401 拦截器清错 Token 导致权限丢失和菜单修改触发连锁故障（2026-06-06）

**背景**：在菜单管理中修改菜单的上级菜单（结构变更），保存后所有页面的操作按钮全部消失，但重新登录后恢复正常。只改排序号等非结构性字段不会触发。

**根因**：`src/utils/request.ts` 的 401 响应拦截器 import 的 `useUserStore` 来自 `@/store/modules/user`（旧 `'user'` store），而登录流程和权限指令使用的是 `@/store/user`（新 `'cpqUser'` store）。当后端因菜单结构变更使 token 失效时，`listMenu` API 返回 401，拦截器调用旧 store 的 `logout()` → `removeToken()` 清除了 localStorage 中的 token，但 `'cpqUser'` store 内存中的状态未被同步清理。两套 store 的 token 状态不一致导致权限指令读取到过期数据，所有按钮消失。

**核心矛盾**：项目存在两套 Pinia user store：
| Store | ID | 用途 | 401 时被清理 |
|-------|-----|------|-------------|
| `store/modules/user.ts` | `'user'` | RuoYi 原有系统 | 旧 store 的 logout |
| `store/user.ts` | `'cpqUser'` | CPQ 新系统 | 不受影响 |

两套 store 共享同一 localStorage token key，但各自维护独立的内存状态。

**修复**：`src/utils/request.ts:2` 将 `@/store/modules/user` → `@/store/user`，使 401 拦截器使用 CPQ store 的 `logout()`，确保 token 清理、权限清空、动态路由清除和登录跳转在同一套 store 内原子完成。

**教训**：
1. 项目中只应存在一套 user store。如因重构需要并行保留两套，所有跨 store 的副作用（如 401 handler）必须指向实际生效的那一套
2. 拦截器、路由守卫等基础设施层面的 store 引用应定期审计，确认与当前活跃的登录流程一致
3. 菜单模块的 CRUD 回归测试必须覆盖修改上级菜单（结构变更）场景

### 原则 13：401 拦截器使用的 userStore 必须与实际登录流程使用的 store 一致（2026-06-06 新增）

**铁律**：`src/utils/request.ts` 响应拦截器中的 `useUserStore` import 路径必须与 `src/views/login/index.vue` 和 `src/layout/index.vue` 中使用的 `useUserStore` 完全一致。否则跨 store 的 token 清理会破坏状态一致性，导致权限指令失效、按钮消失等难以定位的全局故障。

**验证方法**：
```bash
# 检查所有 import useUserStore 的路径是否一致
grep -rn "import.*useUserStore.*from" src/ --include="*.ts" --include="*.vue" | grep -v permission.ts
```
检查输出——所有路径应为同一个（`@/store/user` 或 `@/store/modules/user`，不能混用）。

**检查项 18：userStore import 一致性审计（2026-06-06 新增）** — 项目稳定后执行一次 `grep -rn "import.*useUserStore" src/ --include="*.ts" --include="*.vue"`，确认只有一套 store 路径被引用。如有两套路径混用，必须统一。

### 页面刷新（F5）后权限丢失，所有操作按钮消失（2026-06-06）

**背景**：用户修改菜单结构后 F5 刷新页面验证菜单变更是否生效，刷新后所有页面的操作按钮全部消失。排查发现是 Pinia store 初始化时未从 localStorage 恢复权限数据。

**根因**：`loadUserInfo()` 在登录时将 `permissions` 和 `roles` 存入了 localStorage（`store/user.ts:36-37`），但 store 初始化时（第 10-11 行）硬编码为 `ref<string[]>([])`，从未读回 localStorage。页面刷新时整个 Vue 应用重新初始化，router 守卫只加载了 menus/routes，没有任何代码调用 `loadUserInfo()` 来恢复权限，导致 `v-hasPermi` 指令读到空数组，所有按钮被移除。

**修复前的数据流**：
```
F5 刷新 → store 初始化 → permissions = [] (硬编码空数组)
  → router.beforeEach → 只加载 menus，不调 loadUserInfo()
  → layout.onMounted → 只恢复 menus 缓存
  → v-hasPermi 读取 [] → 按钮消失
```

**修复**：`store/user.ts` 新增 `getStoredArray()` 辅助函数，store 初始化时从 localStorage 读取持久化的权限数据：
```typescript
const permissions = ref<string[]>(getStoredArray('permissions'))
const roles = ref<string[]>(getStoredArray('roles'))
```

**教训**：
1. `localStorage.setItem` 必须有对应的 `getItem` 恢复逻辑，否则持久化只做了一半
2. Pinia store 的初始值不应硬编码空数组，应优先从持久化存储恢复
3. F5 刷新是 SPA 中最容易被忽略的测试场景——开发时 HMR 热更新不会重置 store，但真实用户的 F5 会
4. 每次新增 localStorage 写入，必须在 store 初始化中增加对应的读取恢复

### CPQ 子菜单点击无反应 — 菜单 path=NULL 被序列化为 "null"（2026-06-06）

**背景**：CPQ 产品目录/产品模型/替代品管理三个页面已经开发完毕（有完整 Vue 组件），但通过侧边栏菜单点击时完全无反应，URL 不改变，始终停留在首页工作台。对比系统管理下的子菜单（如用户管理）完全正常。

**根因**：CPQ管理（menu_id=50000）的 `path` 在 SQL 中为 NULL。后端 `getRouters` 接口将 NULL 序列化为 JSON 字符串 `"null"`（带前导斜杠则为 `"/null"`）。前端 `addMenuRoutes` 的 `fullPath` 计算：
```typescript
const parentPath = menu.path  // 值为 '/null'
fullPath = parentPath ? `/${parentPath}/${childPath}`  // → '/null/cpq/product/catalog'
```
而侧边栏 `el-menu` 的 `resolvePath` 使用子菜单自己的路径数据拼接出 `/cpq/product/catalog`。两边的路径字符串不同，`el-menu` 的 `router` 模式无法匹配任何已注册路由，点击静默失败。

对比系统管理（path=`'/system'` → 子菜单 `/system/user`）正常工作的原因是 path 有合法值。

**修复（3 处）**：
1. 数据库：`UPDATE sys_menu SET path = '' WHERE menu_id = 50000`
2. SQL 源文件：`cpq_menu.sql` 中将 50000 的 path 从 NULL 改为 `''`（空字符串）
3. 前端防御：`router/index.ts` 的 `addMenuRoutes` 中增加对 `'null'`/`'/null'` 的处理：
```typescript
const cleanPath = (rawPath === 'null' || rawPath === '/null' || !rawPath) ? '' : rawPath
```

**验证**：agent-browser 直接访问 `/cpq/product/catalog`、`/cpq/product/model`、`/cpq/product/supersession` 均正常渲染搜索框/新增按钮/表格。`vue-tsc --noEmit` 零错误。

**教训**：
1. 数据库字段 NULL 值在 JSON 序列化时不会变成空字符串或省略，而是变成字符串 `"null"`——这是一个极易被忽略的陷阱
2. 所有顶级父菜单的 path 必须显式设为 `''` 而非 NULL。与之对比，系统管理（path=`'/system'`）正常工作的原因就在于有合法值
3. 前端动态路由的 fullPath 计算和侧边栏的 resolvePath 是两套独立的路径拼接逻辑，必须各自确保正确。用 `console.log` 打印对比这两套路径的输出是快速定位此类问题的有效手段
4. 前端应对后端数据做防御性归一化处理（对 `'null'`、`'/null'`、`null`、`undefined` 统一转为空字符串），不能假定后端一定返回合法值

### CPQ 新增数据报"发生未知异常" — BO/Entity 继承链不匹配 + 缺少 @AutoMapper（2026-06-06）

**背景**：在产品目录页点击"新增"按钮，填写数据后点确定，前端提示"发生未知异常，请联系管理员"。后端异常日志：
```
io.github.linpeilie.ConvertException: cannot find converter from CpqProductCatalogBo to CpqProductCatalog
```

**根因（三层）**：

**层 1：BO 继承链与 Entity 不匹配**。`CpqProductCatalogBo` 继承 `BaseEntity`，而 `CpqProductCatalog` 继承 `TenantEntity`。MapStruct Plus 在生成转换器时需要分析两个类的字段映射关系，父类不同导致分析失败，无法自动生成转换器。

**层 2：缺少 @AutoMapper 注解**。三个 BO 类（`CpqProductCatalogBo`、`CpqProductModelBo`、`CpqProductSupersessionBo`）均未加 MapStruct Plus 的 `@AutoMapper` 注解。该注解是 MapStruct Plus 识别需要生成转换器的标记，缺少则编译期不会生成对应的 MapperImpl。

**层 3：编译产物未进 admin jar**。之前使用 `mvn compile -pl cpq -am` 仅编译 CPQ 子模块，生成的 `XxxBoToXxxEntityMapperImpl` 在 CPQ 的 `target/` 下，但运行的 admin jar 是旧版本，不包含这个 MapperImpl。必须通过 `mvn clean package -DskipTests` 全量打包才能将新的 MapperImpl 打入 admin jar。

**修复（每个 BO 两处）**：
```java
// 修复前
public class CpqProductCatalogBo extends BaseEntity {  // ❌ Entity 继承的是 TenantEntity
    // ...
}

// 修复后
@AutoMapper(target = CpqProductCatalog.class, reverseConvertGenerate = false)
public class CpqProductCatalogBo extends TenantEntity {  // ✅ 与 Entity 一致
    // ...
}
```
同时修复了前端 3 个页面中的 `res.data` 问题（拦截器已解包）和 `handleSubmit` 增加 try/catch。

**验证**：curl POST 新增产品目录数据返回 `code: 200, msg: "操作成功"`；数据库确认数据写入；`mvn clean package -DskipTests` 全量构建成功。

**教训**：
1. BO 和 Entity 的继承链必须完全一致——查看 Entity 的父类后再写 BO 的 extends，不要假设都用 BaseEntity。多租户场景下 Entity 通常继承 TenantEntity（有 tenant_id 字段），而 BaseEntity 没有此字段
2. `@AutoMapper` 注解不是可选装饰，是 MapStruct Plus 生成转换器的**必要条件**。缺少它不会在编译时显式报错（因为注解处理器只生成 MapperImpl，不检查是否需要的转换器存在），只会在运行时抛出 ConvertException
3. `mvn compile` 和 `mvn package` 不等价——`compile` 只编译当前模块，`package` 才会将编译产物打包进可执行 jar。子模块编译通过不代表 admin jar 包含最新代码
4. 代码生成器生成 BO 时，必须：（a）检查 Entity 的父类类型；（b）自动添加 `@AutoMapper` 注解；（c）生成完成后必须执行全量打包验证

### 原则 14：Pinia store 中写入 localStorage 的数据，必须在 store 初始化时恢复（2026-06-06 新增）

**铁律**：任何在 store 方法中写入 `localStorage.setItem(key, value)` 的状态，必须在 store 的初始化（`defineStore` 的 `setup` 函数）中通过 `getStoredArray()` / `getItem()` 恢复。不允许出现「只写不读」的 localStorage 使用模式。

**验证方法**：搜索 store 文件中的 `localStorage.setItem` 和对应的 `localStorage.getItem`，确认每对读写都配对存在。

**检查项 19：localStorage 读写配对检查（2026-06-06 新增）** — 对每个 store 文件执行：
```bash
echo "写入:"
grep -n "localStorage.setItem" src/store/*.ts
echo "读取:"
grep -n "localStorage.getItem" src/store/*.ts
```
确认每条 `setItem` 在 store 初始化中（或初始化辅助函数中）有对应的 `getItem`。不一致的记录下来需要修复。

### 原则 15：菜单 SQL 中顶级父菜单的 path 字段不能为 NULL，必须设置为空字符串（2026-06-06 新增）

**铁律**：在 `sys_menu` 表中，任何作为父菜单（有子菜单）的菜单项，其 `path` 字段**绝对不能**为 NULL。顶级父菜单（`parent_id=0`）必须设置 `path = ''`（空字符串），子菜单的 path 可以不为空但必须与前端路由匹配。

**为什么**：后端 `getRouters` 接口在序列化菜单数据时，NULL path 会被转换为 JSON 字符串 `"null"`（带前导斜杠则为 `"/null"`）。前端 `addMenuRoutes` 将此作为 `parentPath` 参与完整路径拼接时，所有子菜单路由变为 `"/null/cpq/product/catalog"` 之类的无效路径。而侧边栏的 `resolvePath` 根据子菜单自己的数据拼接出正常路径（如 `/cpq/product/catalog`），两边路径不匹配，导致 `el-menu` 点击无反应、路由永远无法命中。

**正确实现**（SQL）：
```sql
-- 错误：path 为 NULL
INSERT INTO sys_menu VALUES (50000, 'CPQ管理', 0, ..., NULL, ...);
-- 正确：path 为空字符串
INSERT INTO sys_menu VALUES (50000, 'CPQ管理', 0, ..., '', ...);
```

**前端防御**（`router/index.ts` 的 `addMenuRoutes`）：
```typescript
// 对后端传来的路径做归一化防御
const cleanPath = (rawPath === 'null' || rawPath === '/null' || !rawPath) ? '' : rawPath;
```

**反面案例**：CPQ 管理菜单 (menu_id=50000) 的 path 在 SQL 中为 NULL，后端 `getRouters` 序列化为 `"/null"`。`addMenuRoutes` 中 `parentPath = '/null'` → `fullPath = '/null/cpq/product/catalog'`，而侧边栏 `resolvePath` 拼接的是 `/cpq/product/catalog`。两边不匹配，产品目录、产品模型、替代品管理三个子菜单全部点击无反应。

**影响范围**：所有 path 为 NULL 的父菜单下的所有子菜单。数据库中应执行 `UPDATE sys_menu SET path = '' WHERE path IS NULL` 做预防性修复。

### 原则 16：BO 类必须继承与对应 Entity 完全相同的父类，且必须加 @AutoMapper 注解（2026-06-06 新增）

**铁律**：每个 BO（Business Object）类必须满足以下两条，否则 MapStruct Plus 无法生成转换器：

1. **继承链对齐**：BO 必须 extends 与对应 Entity 完全相同的父类。如果 Entity 继承的是 `TenantEntity`（含 `tenant_id` 字段），BO 也必须继承 `TenantEntity`，不能继承 `BaseEntity`。继承链不匹配会导致 MapStruct Plus 自动转换失败（`ConvertException: cannot find converter`）。

2. **@AutoMapper 注解**：BO 类必须添加 `@AutoMapper(target = XxxEntity.class, reverseConvertGenerate = false)` 注解。框架（mapstruct-plus）依赖此注解在编译期生成 `XxxBoToXxxEntityMapperImpl` 转换器类。缺少此注解，`ConvertHelper.convert(bo, Entity.class)` 会抛 ConvertException。

**为什么**：
- MapStruct Plus 通过 `@AutoMapper` 注解和继承链分析来决定如何生成转换器。如果 BO 和 Entity 的父类不同（一个继承 `BaseEntity`，另一个继承 `TenantEntity`），MapStruct Plus 无法建立字段映射关系。
- 生成的 MapperImpl 类在 `target/` 目录的编译产物中，**必须通过全量 `mvn clean package` 打包进 admin jar**。仅编译子模块（`mvn compile -pl cpq`）不会将生成的 MapperImpl 包含进已运行的 admin jar。

**正确实现**：
```java
// Entity
public class CpqProductCatalog extends TenantEntity {
    private String catalogName;
    // ...
}

// BO — 继承链必须与 Entity 一致，且必须加 @AutoMapper
@AutoMapper(target = CpqProductCatalog.class, reverseConvertGenerate = false)
public class CpqProductCatalogBo extends TenantEntity {
    private String catalogName;
    // ...
}
```

**错误实现（反面案例）**：
```java
// ❌ 错误 1：BO 继承 BaseEntity，但 Entity 继承 TenantEntity → 继承链不匹配
public class CpqProductCatalogBo extends BaseEntity { ... }

// ❌ 错误 2：缺少 @AutoMapper 注解 → 编译期不生成转换器
public class CpqProductCatalogBo extends TenantEntity { ... }
```

**影响范围**：所有包含 BO → Entity 转换的业务模块（新增/修改操作）。错误在后端抛 `ConvertException: cannot find converter from XxxBo to XxxEntity`，前端收到 500 错误显示"发生未知异常，请联系管理员"。

**代码生成规则（铁律）**：
- AI 或代码生成器生成 BO 类时，**必须先查看对应 Entity 的父类**（是 `BaseEntity` 还是 `TenantEntity`），确保 BO 使用相同的父类
- **必须**为每个 BO 添加 `@AutoMapper(target = XxxEntity.class, reverseConvertGenerate = false)` 注解
- 生成完成后，必须执行 `mvn clean package -DskipTests`（全量打包，确保 MapperImpl 包含进 admin jar），不能用 `mvn compile -pl cpq -am`

**验证方法**：
- 检查每个 BO 的 extends 是否与对应 Entity 一致：`grep -A1 "class.*Bo"` vs `grep -A1 "class.*Entity"` 对比继承链
- 检查每个 BO 是否都有 `@AutoMapper` 注解：`grep -rn "@AutoMapper" --include="*Bo.java"`
- 全量打包后，检查 `target/generated-sources/` 下是否生成了对应的 `XxxBoToXxxEntityMapperImpl.java`

### 原则 17：@TableLogic 的 delval 必须与系统标准一致（delval='2'，非 MP 默认的 '1'）（2026-06-09 新增）

**铁律**：所有使用 `@TableLogic` 注解的实体，必须显式指定 `value = "0", delval = "2"`，不能依赖全局 MyBatis-Plus 默认值 `delval = "1"`。同时必须检查模块内**所有**关联实体的 `@TableLogic` 是否统一。

**为什么**：
- 系统 SQL 建表脚本全部标注「0正常 2删除」，这是系统标准
- MyBatis-Plus 全局默认 `logicDeleteValue: 1`，但此值与系统标准不一致
- 如果 `@TableLogic` 未显式指定 delval（或全局配置为 '1'），`removeById()` 会将 `del_flag` 设为 '1'，而非系统标准的 '2'
- 软删除行（`del_flag='1'`）虽被 `@TableLogic` 过滤掉不参与业务查询，但如果存在不包含 `del_flag` 的唯一键（如 `uk_quote_line(tenant_id, quote_id, line_number)`），这些被过滤的行仍然占用唯一键值，导致新插入数据发生 `Duplicate entry` 冲突
- 修复方向：**不能**绕过 `@TableLogic` 用原生 SQL 查所有行，而应该把 `@TableLogic` 的 delval 修正为 '2'，并把历史数据中 `del_flag='1'` 的行改为 '2'

**执行方法**：
1. 模块内所有实体：搜索 `@TableLogic` 注解，确认每个都显式写了 `value = "0", delval = "2"`
2. 历史数据清理：`UPDATE <table> SET del_flag = '2' WHERE del_flag = '1'`
3. 行号/序列号生成：如果唯一键不包含 `del_flag`，序列号不应因删除而重复，由专门的 `selectMaxXxx()` 原生 SQL 查所有行（含软删除）取 MAX+1。此方法只在序列号生成场景使用，业务查询仍通过 `@TableLogic` 正确过滤
4. 如果模块使用全局 `common-mybatis.yml` 中的 `logicDeleteValue: 1`，评估是否改为 '2'（影响全局所有模块）；若不能，则模块内每个 `@TableLogic` 都必须显式覆盖

**反面案例**：quote 模块 `CpqQuoteLineItem` 的唯一键 `uk_quote_line(tenant_id, quote_id, line_number)` 不含 `del_flag`。三个实体（`CpqQuote`、`CpqQuoteTemplate`、`CpqSolutionDocument`）的 `@TableLogic` 未显式指定 delval，使用了全局默认 '1'。`removeById()` 将 `del_flag` 设为 '1'，软删除行仍占用唯一键；新插入行分配相同 line_number 时触发 `Duplicate entry` 错误。错误方案是写绕过 @TableLogic 的原生 SQL 直接查所有行——因为问题不在查询而在 delval 值错误。正确方案是：修正 @TableLogic delval='2'，清理历史数据，然后用专用方法生成不重复行号。

**验证方法**：
```bash
# 1. 扫描模块内所有 @TableLogic 注解，确认 delval='2'
grep -rn "@TableLogic" --include="*.java" -A1 | grep -E "@TableLogic|delval"
# 输出应全部包含 delval = "2"

# 2. 检查数据库是否残留 del_flag='1' 的数据
mysql -e "SELECT del_flag, COUNT(*) FROM <table> WHERE del_flag != '0' GROUP BY del_flag"
# 输出只应有 del_flag='2'，不应有 '1'
```

---

### quote 模块 @TableLogic delval 不一致 + 行号序列唯一键冲突（2026-06-09）

**背景**：quote 模块行项目表 `cpq_quote_line_item` 有唯一键 `uk_quote_line(tenant_id, quote_id, line_number)`，不包含 `del_flag`。此前 `insert()` 使用绕过 `@TableLogic` 的原生 SQL（`selectMaxLineNumber()` 直接查所有行含软删除）来生成行号，以避免唯一键冲突。用户指出这是错的——问题根因不是查询方法，而是 `@TableLogic` 的 delval 应该设为 '2' 而非 '1'。

**根因（三层）**：

**层 1：@TableLogic 值不一致**。quote 模块 4 个实体中，`CpqQuoteLineItem` 已显式设 `delval = "2"`，但其余 3 个（`CpqQuote`、`CpqQuoteTemplate`、`CpqSolutionDocument`）使用全局默认 `delval = "1"`。而 SQL 建表脚本全部标注「0正常 2删除」——这是系统标准。全局 MyBatis-Plus 配置 `logicDeleteValue: 1` 与系统标准冲突。

**层 2：MP removeById() 设错 del_flag 值**。因为 3 个实体的 `@TableLogic` 未显式覆盖 delval，`removeById()` 将 `del_flag` 设为 '1' 而非系统标准的 '2'。数据库中出现 `del_flag='1'` 的软删除行，它们被 `@TableLogic` 从业务查询中过滤掉，但仍占用 `uk_quote_line` 唯一键。

**层 3：错误修复方向**。之前的修复方案是写绕过 `@TableLogic` 的原生 SQL（`SELECT MAX(line_number) FROM cpq_quote_line_item WHERE quote_id = ?`）直接查所有行来生成行号——表面解决了冲突，但没修复根本问题（delval 错了）。用户明确指出：正确的方向是修正 `@TableLogic` delval='2'、清理历史数据，而不是绕过框架的过滤机制。

**行号序列设计决策**：用户确认行号不应因删除而重复（审计追溯需求）。因此 `selectMaxLineNumber()` 仍需保留（查所有行含软删除取 MAX+1），但这是出于序列不重复的业务设计，而非为了绕过错误的 @TableLogic 值。方法上加了清晰的注释说明原因。

**修复（三处）**：
1. 统一 3 个实体的 `@TableLogic`：`CpqQuote.java`、`CpqQuoteTemplate.java`、`CpqSolutionDocument.java` 均改为 `@TableLogic(value = "0", delval = "2")`
2. 清理历史数据：`DELETE FROM cpq_quote_line_item WHERE del_flag = '1'`（当时无残留，但验证了清理逻辑）
3. 恢复 `selectMaxLineNumber()`：加清晰注释（序列不重复 + UK 含 del_flag），`insert()` 恢复使用 `baseMapper.selectMaxLineNumber()`

**验证**：E2E 测试 → 创建 3 条行项目 → 软删 #2 → 创建 #4（lineNumber=4，不冲突）→ DB 验证仅 `del_flag=0` 和 '2'，无 '1'。Playwright 前端：搜索→选中→自动填充→提交→表格正确显示。

**教训**：
1. `@TableLogic` 的 delval 是全局基础设施配置，不能依赖 MP 默认值。必须与 SQL 建表脚本中的删除标志定义一致（全部是「0正常 2删除」）
2. 修复软删除相关 bug 时，先检查 delval 是否设对，再检查数据中是否有错误值（del_flag='1'），最后才考虑查询层面的问题。**永远不要绕过 @TableLogic 作为首选项**，先修复配置
3. 唯一键不包含 del_flag 时，序列号（行号、编号等）生成应采用「查所有行 MAX+1」避免重复，但这是序列设计问题，不是绕过 @TableLogic 的理由
4. 模块内所有实体必须统一检查 `@TableLogic` 配置，一个不一致就会影响所有关联操作
5. 用户反馈「不要绕过 TableLogic」是正确的——框架提供的过滤机制是有意设计，绕过它说明配置出了错

---

## 使用方式

当以下场景触发时，AI 必须主动加载此 skill：
- 在已有模块中新增前端页面
- 批量生成代码完成后
- 从上游项目（plus-ui、ruoyi 官方等）移植代码
- 安装新依赖或新增 Vite 插件
- 用户提到"查漏补缺"、"检查遗漏"、"对齐"、"白屏"、"移植"等关键词
- 部署到新环境前做最终检查
- **新建或修改菜单配置**，特别是新增 `component='ParentView'` 的菜单项时
- **修改 `layout/index.vue` 侧边栏模板**时
- 用户报告"菜单点击无反应"、"点击跳到首页"、"第二次点击才正常"时
- **新建或修改 Vue 页面**，特别是 CRUD 页面中涉及 API 响应数据处理时
- **代码生成完成后**，grep 扫描 `.data` 确认无拦截器解包后的冗余访问
- 用户报告"修改弹窗空白"、"编辑按钮报错"、"TypeError: Cannot read properties of undefined"时
- **修改菜单结构**（调整上级菜单、菜单树层级变化）后用户报告按钮消失、权限异常时
- **修改 `src/utils/request.ts` 拦截器**或 **修改 store import** 时，检查 userStore 一致性
- 用户报告"修改菜单后所有按钮不见了，重新登录恢复"时
- 用户报告"F5 刷新后按钮没了"、"刷新页面后权限丢失"时
- **新增或修改 store 中的 `localStorage.setItem` 持久化逻辑**时，检查对应的恢复代码
- **编写菜单 SQL 时**，必须检查所有 path 字段是否为 NULL（特别是顶级父菜单）
- **用户报告特定菜单点击无反应但其他菜单正常**时，检查 path 字段值和路由拼接
- **生成 BO/VO 类**（包括 AI 代码生成）时，必须检查 Entity 的继承链和 @AutoMapper 注解
- **用户报告新增/修改数据报"未知异常"**且后端错误为 ConvertException 时，检查 BO 继承链和 @AutoMapper
- **仅编译子模块后验证功能**时，必须改为全量 `mvn clean package` 打包
- **新增实体或模块**时，必须检查 `@TableLogic` 的 `delval` 是否为 '2'（与 SQL 建表脚本中「0正常 2删除」一致），不能依赖全局默认值 '1'
- **用户报告 Duplicate entry 唯一键冲突**时，优先检查是否由 `@TableLogic` delval 错误导致软删除行占用唯一键
- **用户提到"不要绕过"、"修复方向不对"、"问题不在查询"**等纠正反馈时，重新审视修复方案的根本原因分析

当前 skill 统计：**17 条原则 + 21 项检查 + 10 个真实案例**

加载此 skill 后，AI 必须逐项执行闭环检查清单，并汇报检查结果。
