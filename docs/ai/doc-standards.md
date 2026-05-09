# 文档规范

## 文档类型与存放位置

| 文档类型 | 存放位置 | 命名格式 |
|---------|---------|---------|
| SPEC 设计文档（全局） | `docs/superpowers/specs/` | `YYYY-MM-DD-<topic>-design.md` |
| AI 协同规范 | `docs/ai/` | kebab-case 或中文 |
| 看板文件 | `docs/board/` | `TASKS.md` / `PROGRESS.md` |
| 项目 PRD | `docs/project/prds/` | `YYYY-MM-DD-<short-name>-PRD.md` |
| 项目功能说明 | `docs/project/features/` | `YYYY-MM-DD-<short-name>-功能说明.md` |
| 架构决策记录 | `docs/project/architecture/` | `NNN-<short-name>.md` |
| 发布日志 | `docs/project/changelog/` | `vX.Y.Z.md` |
| AI 任务目录 | `docs/<developer>-<Model>/<type>/` | `<name>-<YYYY-MM-DD>/` |
| AI 自身说明 | 任务目录根 | `SELF.md` |
| 项目规划 | `docs/` | 中文或 kebab-case |

MUST NOT: 设计文档命名为 `spec.md`、`design.md`、`plan.md` 等无日期无主题的通用名

## 文件格式

MUST: 所有文档使用 Markdown 格式
MUST: 编码 UTF-8
MUST: 文件名不包含空格（用 `-` 替代）
MUST NOT: 文件名包含特殊字符（`&`, `%`, `#`, `!` 等）

## Markdown 写作规范

| 规范 | 说明 |
|------|------|
| MUST: 标题层级 `# → ## → ###` | 不跳级（如 `#` 下直接用 `####`） |
| MUST: 代码块标注语言 | ```dart 而非 ``` |
| MUST: 表格有表头分隔行 | 必须存在 `|------|` 分隔行 |
| SHOULD: 列表使用 `-` 而非 `*` | 保持项目一致 |
| SHOULD: 中文与英文/数字间加空格 | `定义 SPEC 文档` 而非 `定义SPEC文档` |

## SPEC 设计文档模板（全局）

SPEC 文档 MUST 包含以下全部 10 个必填节（已在 SPEC Coding Stage A1 中定义）：

```
# <主题> 设计规格

## 元信息
- 创建日期: YYYY-MM-DD
- 状态: 草稿 | 评审中 | 已批准 | 已锁定 | 已验收 | 已归档
- 关联需求: <用户原始指令摘要>

## 目标
## 非目标
## 架构设计
## 数据流
## 技术决策
## 权衡与已知限制
## 验收条件（必须可逐项勾选）
## 变更记录
```

MUST NOT: 设计文档中出现未定义的缩写（首次使用 MUST 给出全称）
MUST NOT: 设计文档中包含 TBD / TODO / FIXME / ??? 等占位符（在 SPEC 锁定时必须全部清除）

---

## SELF.md 模板（AI 任务目录）

每个 AI 任务目录创建时 MUST 写入 SELF.md，内容如下：

```
# SELF

## AI 身份
- 使用者: <name>
- 模型 ID: <model-id>
- 模型品牌: <brand>
- 访问入口: <entry-point>

## 本项目宪法版本
| 模块 | 版本 |
|------|------|
| AI_README.md | X.Y.Z |
| CONSTITUTION.md | X.Y.Z |
| board-protocol.md | X.Y.Z |
| glossary.md | X.Y.Z |
| principles.md | X.Y.Z |
| phases.md | X.Y.Z |
| delivery-pipeline.md | X.Y.Z |
| code-style.md | X.Y.Z |
| directory-structure.md | X.Y.Z |
| git-rules.md | X.Y.Z |
| doc-standards.md | X.Y.Z |
| toolchain.md | X.Y.Z |
| project-context-guide.md | X.Y.Z |

## 本任务
- 任务类型: feature | refactor | fix | chore
- 任务名称: <具体功能/模块名>
- 关联看板任务 ID: TASK-NNN (如存在)
- 创建日期: YYYY-MM-DD

## 追溯信息（refactor 类型 MUST 填写）
- 被重构来源: <完整目录路径，如 docs/wjt-Claude/features/Chat-2026-05-01/>
- 重构原因: <说明为什么重构/谁决定>
```

MUST: SELF.md 创建后不再修改（任务锁定）
MUST: 宪法版本表 MUST 逐模块列出，不可仅写"最新版"
MUST: refactor 任务 MUST 填写"被重构来源"完整路径
MUST NOT: 删除被重构来源的任务目录（它是历史记录）
