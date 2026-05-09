# AI 协同治理体系 v2 设计规格

## 元信息

- 创建日期: 2026-05-08
- 状态: 草稿
- 关联需求: 新增多 AI 隔离工作区、权限矩阵、看板系统、宪法版本控制、project/ 目录

---

## 目标

在现有 AI 协同宪法 v1（AI_README.md + 10 模块）基础上，增加：

1. **多 AI 工作区隔离**——每个 `<developer>-<Model>` 拥有独立的任务级目录，本 AI 读写、其他 AI 只读
2. **严格的全局权限矩阵**——AI 默认只读一切（除自己的 `<me>/` 目录），写操作 MUST 经"人"许可
3. **看板系统**——`docs/board/` 实现多 AI 进度同步，AI 读/写看板 MUST 走 protocol 定义的唯一通道
4. **宪法版本控制**——每模块独立 SemVer，`CONSTITUTION.md` 为全局版本清单
5. **SELF.md**——每个 AI 任务的自身说明文件（模型 ID、宪法版本、追溯链）
6. **project/ 目录**——纯项目内容，与 AI 工件物理隔离
7. **board-protocol.md**——新宪法模块，定义看板交互的 MUST/MUST NOT/唯一合法流程

## 非目标

- 不实现自动化看板工具（TASKS.md / PROGRESS.md 是纯 Markdown 文本）
- 不实现 AI 间的自动通信机制（一切通过 board/ 文件 + 人协调）
- 不修改现有 10 宪法模块的核心内容（只增加 board-protocol.md 和 CONSTITUTION.md）

---

## 架构设计

### 新版 docs/ 目录结构

```
docs/
  README.md                             ← docs/ 使用说明（人维护，AI 默认只读）

  ai/                                   ← 宪法（LLM 永远只读）
    CONSTITUTION.md                     ← NEW: 全局版本清单 + SemVer 规则
    board-protocol.md                   ← NEW: 看板使用协议 + 全局权限矩阵
    glossary.md                         ← vX.Y.Z (独立 SemVer)
    principles.md                       ← vX.Y.Z
    phases.md                           ← vX.Y.Z
    delivery-pipeline.md                ← vX.Y.Z
    code-style.md                       ← vX.Y.Z
    directory-structure.md              ← vX.Y.Z
    git-rules.md                        ← vX.Y.Z
    doc-standards.md                    ← vX.Y.Z
    toolchain.md                        ← vX.Y.Z
    project-context-guide.md            ← vX.Y.Z

  board/                                ← NEW: 公共进度看板
    TASKS.md                            ← 任务队列（AI 默认只读，写入走 W1-W5）
    PROGRESS.md                         ← 进度仪表盘（AI 永远只读）

  project/                              ← NEW: 纯项目内容
    prds/                               ← 产品需求文档
    features/                           ← 功能规格说明（非 AI SPEC）
    architecture/                       ← 架构决策记录 (ADR)
    changelog/                          ← 版本发布日志

  wjt-Deepseek/                         ← AI 工作区（本 AI 读写，其他 AI 只读）
    features/
      Login-2026-05-09/                 ← 任务级目录
        SELF.md                         ← 本次任务的 AI 自身说明
        specs/                          ← 本任务的 SPEC 设计文档
        plans/                          ← 本任务的实现计划
        logs/                           ← 本任务的执行日志（可选）
    refactors/
      Chat-Window-UI-2026-05-10/
        SELF.md                         ← 含"被重构来源"追溯字段
        specs/
        plans/

  wjt-Claude/
    features/
      Chat-2026-05-01/
        SELF.md
        specs/
        plans/
    refactors/
      ...

  Plans.md                              ← 项目总体规划（人维护，AI 默认只读）
```

### 任务目录命名规范

```
<type>/<name>-<YYYY-MM-DD>/

type: features | refactors | fixes | chores
name: 中文或英文功能关键词
日期: 任务创建日期
```

---

## 全局权限矩阵（全 AI 通用）

| 区域 | 默认权限 | 写入条件 |
|------|---------|---------|
| `AI_README.md` | **只读** | **永远不可写** |
| `docs/ai/` | **只读** | **永远不可写** |
| `docs/<other-ai>/` | **只读** | **永远不可写** |
| `docs/<me>/` | **读写** | 自主写入（仅限自己的任务目录） |
| `docs/board/` | **只读** | **仅在人明确命令 + 许可时**可写。写入 MUST 走 W1-W5 通道 |
| `docs/Plans.md` | **只读** | **仅在人明确命令 + 许可时**可写 |
| `docs/project/` | **只读** | **仅在人明确命令 + 许可时**可写 |
| `docs/README.md` | **只读** | **仅在人明确命令 + 许可时**可写 |
| `README.md` (根) | **只读** | **仅在人明确命令 + 许可时**可写 |

---

## 新增宪法模块设计

### board-protocol.md

在 `docs/ai/` 下新增，与现有 10 模块同级。内容包含：

1. **默认权限**——board/ 默认只读，MUST NOT 自主写入
2. **读取协议**——仅在用户指令时读取
3. **写入协议（W1-W5）**：
   - W1: AI 完成任务步骤
   - W2: AI 按格式向用户请求（目标文件、拟操作、涉及条目、变更内容、请确认）
   - W3: AI 等待用户明确批准
   - W4: AI 仅在批准后执行写入，范围严格 = 请求内容
   - W5: AI 写入后报告实际变更
4. **MUST NOT**——自主读、自主写、超出范围写、删除历史、创建新文件
5. **违规处理**——失去信任 → 撤销写权 → 移除工作目录
6. **完整权限矩阵**——上述 9 行表的副本

### CONSTITUTION.md

在 `docs/ai/` 下新增。内容包含：

1. **当前版本矩阵**——11 个模块的 文件名 | 当前版本 | 最后修订日期 | 修订人
2. **SemVer 规则**——MAJOR (不兼容)、MINOR (新增)、PATCH (修正)
3. **修订历史**——日期 | 模块 | 旧版本 → 新版本 | 变更摘要
4. **兼容性规则**——PATCH 可继续、MINOR 应评估、MAJOR 必须暂停

---

## SELF.md 模板

每个任务目录首次创建时 MUST 写入：

```markdown
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
| ... (全部 12 模块逐项列出) |

## 本任务
- 任务类型: feature | refactor | fix | chore
- 任务名称: <具体功能/模块名>
- 关联看板任务 ID: TASK-NNN (如存在)
- 创建日期: YYYY-MM-DD

## 追溯信息（refactor 类型 MUST 填写）
- 被重构来源: <完整目录路径>
- 重构原因: <具体原因>
```

MUST: SELF.md 创建后不再修改（任务锁定）
MUST: 宪法版本表逐模块列出

---

## board/ 文件格式

### TASKS.md

```markdown
# 任务队列

> AI MUST NOT 修改此文件，除非用户明确命令 + 许可。
> AI MAY 在用户明确命令下读取此文件。

## 状态定义
- [ ] 待认领
- [~] 进行中
- [!] 阻塞
- [x] 已完成
- [R] 已撤销

## 条目格式
TASK-NNN | 状态 | 类型 | 标题 | 发布人 | 认领人 | 创建 | 完成 | 工作目录 | 阻塞原因
```

每条 TASK 的必填字段：TASK-ID、状态、类型、标题、发布人、认领人、创建日期、工作目录路径。阻塞时 MUST 填写阻塞原因。

发布人 = 认领人（当前协议下同一身份，如 `wjt-Deepseek`）。

### PROGRESS.md

由"人"维护的进度仪表盘。AI 永远只读。

包含：当前 Sprint 模块进度表 + 风险项。

---

## 现有模块变更清单

| 模块 | 变更级别 | 变更点 |
|------|---------|--------|
| `directory-structure.md` | MAJOR | 新版 docs/ 结构：增加 `<ai>/features|refactors/`、`board/`、`project/`，任务目录命名规则 |
| `doc-standards.md` | MINOR | 增加 SELF.md 模板、project/ 命名规范 |
| `project-context-guide.md` | MINOR | 必读清单增加 board-protocol.md、CONSTITUTION.md |
| `AI_README.md` | MAJOR | 模块索引增加 2 项（12→14）、权限矩阵摘要、看板协议一句话 |

---

## 技术决策

| 决策 | 选择 | 理由 |
|------|------|------|
| 工作区标识 | `<developer>-<Model>` | 人 + 模型唯一标识，跨会话持久 |
| 任务粒度 | `type/name-date/` | 一个任务一个独立目录，便于追溯和隔离 |
| 看板载体 | 纯 Markdown 文件 | 零基础设施依赖，Git 可追踪 |
| 宪法版本 | 每文件独立 SemVer | 精确追踪，避免"全局版本号"的假精确 |
| 权限执行 | AI 自律 + MUST/MUST NOT 语言 | 与现有宪法一致，不引入技术强制 |
| 看板写协议 | W1-W5 五步通道 | 确保"人"始终是看板写操作的闸门 |
| 追溯链 | refactor SELF.md 标注"被重构来源"路径 | 跨 AI 的完整代码溯源 |

## 权衡与已知限制

1. 看板的人控协议依赖"人"的及时响应——如果人不在场，AI 完成了步骤也无法更新看板。可接受的权衡：宁可延迟同步也不允许 AI 自主写看板
2. TASKS.md 如果条目过多会膨胀——不设上限，定期由人手动归档已完成的条目到历史区
3. SELF.md 的宪法版本表需要 AI 主动读取 CONSTITUTION.md 来填充——如果 AI 忽略此步骤，SELF.md 版本可能不准确。在 project-context-guide.md 的首次必读清单中强化此要求

## 验收条件

- [ ] docs/ai/ 下新增 board-protocol.md，含完整权限矩阵 + W1-W5 通道
- [ ] docs/ai/ 下新增 CONSTITUTION.md，含 12 模块版本表 + SemVer 规则
- [ ] docs/ai/directory-structure.md 更新为新版 docs/ 结构
- [ ] docs/ai/doc-standards.md 增加 SELF.md 模板 + project/ 命名规范
- [ ] docs/ai/project-context-guide.md 更新必读清单（增加 board-protocol.md、CONSTITUTION.md）
- [ ] AI_README.md 更新模块索引（12 项） + 权限矩阵摘要
- [ ] docs/board/TASKS.md 创建（空模板）
- [ ] docs/board/PROGRESS.md 创建（空模板）
- [ ] docs/project/ 目录结构创建（prds/features/architecture/changelog/ + README.md）
- [ ] docs/README.md 创建（docs/ 使用说明）
- [ ] 所有新模块和更新模块的版本号标注（初始 1.0.0 或递增）

## 变更记录

| 日期 | 变更内容 | 原因 |
|------|---------|------|
| — | — | — |
