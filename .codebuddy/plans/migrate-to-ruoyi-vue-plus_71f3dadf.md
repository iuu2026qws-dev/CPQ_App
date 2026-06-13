---
name: migrate-to-ruoyi-vue-plus
overview: 删除当前 RuoYi-Vue 标准版代码，保留 CPQ 产品设计文档等工作文件，从 Gitee clone RuoYi-Vue-Plus 仓库
todos:
  - id: cleanup-old-code
    content: 删除所有 RuoYi-Vue 标准版代码文件：ruoyi-admin/、ruoyi-common/、ruoyi-framework/、ruoyi-generator/、ruoyi-quartz/、ruoyi-system/、ruoyi-ui/、bin/、pom.xml、LICENSE、README.md、ry.bat、ry.sh、.gitignore、.git/
    status: completed
  - id: clone-ruoyi-plus
    content: 从 Gitee 克隆 RuoYi-Vue-Plus 到临时目录 temp_rvp，然后将所有文件（含隐藏文件）移动到当前工作目录根路径
    status: completed
    dependencies:
      - cleanup-old-code
  - id: verify-work-files
    content: 验证工作文件完整性：确认 001_Product Design Docs/、002_Ruoyi_Study/、skills/、.codebuddy/、dev_policy.md、doc/、sql/ 均未被删除
    status: completed
    dependencies:
      - clone-ruoyi-plus
  - id: update-memory
    content: 更新 MEMORY.md 和日工作日志，记录框架从 RuoYi-Vue 标准版迁移到 RuoYi-Vue-Plus 的操作
    status: completed
    dependencies:
      - verify-work-files
---

## 用户需求

将当前工作目录从 RuoYi-Vue 标准版（v3.9.2）迁移到 RuoYi-Vue-Plus 框架。

### 具体操作

- 删除当前目录下所有 RuoYi-Vue 标准版代码文件及目录
- 保留 CPQ 产品相关的工作文件（设计文档、学习笔记、技能包、开发政策、文档、SQL 脚本等）
- 从 Gitee 仓库 `https://gitee.com/dromara/RuoYi-Vue-Plus` 克隆完整代码到当前目录
- 克隆完成后不做任何初始化或配置操作

### 保留文件清单

- `.codebuddy/` — 项目记忆、配置和 AI 工作数据
- `001_Product Design Docs/` — CPQ 产品全套设计文档（研究报告、V2.0、阶段一/二/三）
- `002_Ruoyi_Study/` — RuoYi-Vue-Plus 框架学习笔记
- `skills/` — 技能包和代码生成模板
- `dev_policy.md` — 开发政策文档
- `doc/` — 原有文档
- `sql/` — SQL 脚本

### 删除文件清单

- `ruoyi-admin/`、`ruoyi-common/`、`ruoyi-framework/`、`ruoyi-generator/`、`ruoyi-quartz/`、`ruoyi-system/`、`ruoyi-ui/` — 所有 Java 模块和前端项目
- `pom.xml` — Maven 父 POM
- `LICENSE`、`README.md`、`ry.bat`、`ry.sh` — 项目根文件
- `bin/` — 启动脚本
- `.gitignore`、`.git/` — 旧版 Git 仓库

## 迁移策略

由于当前目录中存在需保留的工作文件（非空目录），不能直接执行 `git clone` 到当前目录。采用「临时目录中转」策略：

1. 清理旧代码：删除所有 RuoYi-Vue 标准版文件和 `.git/`
2. 克隆到临时目录：`git clone https://gitee.com/dromara/RuoYi-Vue-Plus.git temp_rvp`
3. 移动文件：将临时目录中所有文件（含 `.git/`、`.gitignore` 等隐藏文件）移动到当前目录
4. 清理临时目录：删除 `temp_rvp/`

### 安全措施

- 所有需保留的目录和文件不会被删除操作触及
- 使用精确路径匹配删除，避免误删工作文件
- 克隆完成后验证工作文件完整性

### 无需初始化的原因

用户明确要求在克隆完成后不做任何配置或初始化操作，后续将根据 CPQ 产品设计文档统一规划技术栈适配和模块开发。