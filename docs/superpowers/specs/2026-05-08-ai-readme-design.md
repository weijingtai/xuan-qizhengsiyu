# AI_README.md 设计规格

## 目标

建立项目级 AI 协同宪法，让多种 AI 大模型 / IDE 在参与本项目开发时，遵循统一的开发原则、规范和工作流，以 MUST / MUST NOT 语言约束行为，最小化不同 AI 工具之间的风格差异、垃圾代码和协作混乱。

## 非目标

- 不生成各工具配置文件（如 `.cursor/rules/`）。工具适配是独立任务。
- 不编写 pre-commit hooks 或 CI 检查脚本。
- 不包含具体项目的领域知识（术语表限定为 AI 协同通用概念）。

---

## 文件结构

```
<项目根目录>/
  AI_README.md                   ← 宪法入口，所有 AI 工具首次必读
  docs/
    ai/
      principles.md              ← 开发核心原则（andrej-karpathy 四原则 + superpowers + 项目特有）
      phases.md                  ← AI 认知阶段与准入/准出条件（探索→设计→实现→验证→归档）
      delivery-pipeline.md       ← 代码交付流水线（分支→开发→测试→提交→合并），每步准入准出 + 判断标准
      code-style.md              ← Dart/Flutter 代码规范
      directory-structure.md     ← 目录与文件结构规范
      git-rules.md               ← Git 分支 / 提交 / PR 命名规范
      doc-standards.md           ← 文档存放与格式规范
      toolchain.md               ← 开发环境隔离与工具链
      glossary.md                ← AI 协同通用术语（不含项目专有术语）
      project-context-guide.md   ← 要求 AI 阅读项目相关内容的具体规则
```

---

## AI_README.md 总纲设计

### 板块顺序

1. **宪法地位**（Preamble）——声明此文件是 AI 协同最高规范
2. **核心原则摘要**——浓缩 6 条不可协商原则（每条约 2-3 行）
3. **强制工作流**——SPEC Coding (A1-A4 → B1-B3) + 平凡改动豁免条件
4. **SPEC Coding 阶段总览**——4 阶段 SPEC 生命周期（启动→填充→评审→锁定）+ 3 阶段交付（实现→验收→归档），每步准入准出
5. **代码交付流水线总览**——5 步（分支→开发→测试→提交→合并），准入准出 + 判断标准
6. **快速违规自检清单**——AI 在每次修改前需对照的 10 项清单
7. **模块索引**——指向 `docs/ai/` 下各模块的链接与一句话说明

### 关键设计决策

- AI_README.md 长度控制在 200 行以内（作为入口，不包含详细规则）
- 所有详细规则下沉到 `docs/ai/` 子模块
- 使用中文编写（项目语言环境为中文）
- 所有 MUST / MUST NOT 用英文大写，与说明文字区分

---

## 各子模块设计摘要

### 1. principles.md —— 开发核心原则

**来源：** `~/.claude/andrej-karpathy-skills.md` + superpowers 强制要求

| 原则 | 内容要点 |
|------|---------|
| SPEC First | 非平凡改动 MUST 先有已批准的 SPEC，SPEC 不批准 = 不编码 |
| Think Before Coding | 先陈述假设、呈现方案、明确不确定点 |
| Simplicity First | 不多写功能、不提前抽象、200→50 |
| Surgical Changes | 不改相邻代码、不改无关注释、匹配已有风格 |
| Goal-Driven | 定义验收标准、循环直到通过 |
| Superpowers Mandatory | SPEC Coding A1-A4 → 交付 B1-B3 |
| Chinese-First | 面向 AI 的注释用中文，提交信息用中文 |

**独有规则：**
- MUST 在首次分析项目时读取 AI_README.md 及 docs/ai/ 下所有模块
- MUST 在修改代码前阅读相关文件及其直接依赖
- MUST NOT 假设项目上下文——必须从实际文件中获取

### 2. phases.md —— AI 认知阶段

AI 认知流程分为两部分：
- **Part A: SPEC Coding（规格驱动编码）**——控制 SPEC 文档的生命周期
- **Part B: 交付阶段（Delivery）**——引用已批准 SPEC，进入代码实现与交付

**核心原则：SPEC First。** 任何非平凡改动 MUST 先有已批准的 SPEC 才能写代码。SPEC 是 AI 与用户之间的合同——SPEC 不批准 = 不写第一行代码。

---

#### Part A: SPEC Coding（规格驱动编码）

SPEC 文档是 AI 与用户之间的开发合同。SPEC Coding 控制 SPEC 文档从创建到批准的完整生命周期。

```
┌──────────────┐    准入满足      ┌──────────────┐    用户批准      ┌──────────────┐
│  Stage A1    │ ──────────────→ │  Stage A2    │ ─────────────→ │  Stage A3    │
│  启动 & 框架  │                 │  内容填充     │                │  评审 & 批准  │
└──────────────┘                 └──────────────┘                └──────────────┘
                                                                       │
                                                                       │ 批准
                                                                       ↓
                                                                 ┌──────────────┐
                                                                 │  Stage A4    │
                                                                 │  SPEC 锁定   │
                                                                 └──────────────┘
```

##### Stage A1: 启动与框架（Initiation & Scaffold）

**目的：** 确认任务为非平凡改动，搭建 SPEC 文档骨架。

| 准入条件 | 判断标准 |
|---------|---------|
| 接收到开发任务 | 任务描述清晰可理解 |
| 任务确认为非平凡改动 | 不满足平凡改动豁免清单（≤5 行、错别字、格式化等） |
| 已阅读与任务相关的源码及依赖 | AI 在会话中已读取并理解 |
| 已阅读 AI_README.md 全部模块 | 当前会话中已加载 |

| 准出条件 | 判断标准 |
|---------|---------|
| SPEC 文件已创建 | 文件存在于 `docs/superpowers/specs/YYYY-MM-DD-<topic>-design.md` |
| SPEC 文件包含全部必填字段的骨架 | 见下方必填字段清单 |
| 非目标 (Non-Goals) 已填写 | 明确本次不做什么 |
| 用户确认 SPEC 骨架 | 用户知道 spec 文件已创建 |

**此阶段产生的文件：**
```
docs/superpowers/specs/YYYY-MM-DD-<topic>-design.md   ← SPEC 文档（骨架阶段）
```

**SPEC 必填字段清单（MUST 全部存在）：**
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

MUST: SPEC 文件内含上述 10 个必填节
MUST NOT: 在骨架不完整时进入内容填充

##### Stage A2: 内容填充（Content Fill）

**目的：** 将设计内容填入 SPEC 骨架，完成完整的内部自洽文档。

| 准入条件 | 判断标准 |
|---------|---------|
| Stage A1 准出全部满足 | SPEC 骨架存在且字段完整 |
| 用户已确认方向 | 用户没有否定架构方向 |

| 准出条件 | 判断标准 |
|---------|---------|
| 所有必填节已填入实质内容 | 每节内容不少于 50 字（元信息和变更记录除外） |
| 验收条件可逐项勾选 | 每条验收条件以 `[ ]` 开头，独立可验证 |
| 内部自洽检查通过 | 无自相矛盾（如目标说要 A，技术决策选了反 A 的方案） |
| 无 TBD / TODO / FIXME / ??? 占位符 | Grep 零命中 |
| 设计能回答"谁在什么场景下做什么" | 数据流至少覆盖一条完整路径 |

**修改的文件：**
```
docs/superpowers/specs/YYYY-MM-DD-<topic>-design.md   ← 内容填充完成，状态: "评审中"
```

MUST: 内部一致性自查——逐条验收条件反向核对目标和非目标
MUST NOT: 在验收条件中写模糊表述（"尽量"、"最好"、"差不多"）
MUST: 验收条件每项必须可客观判定真/假

##### Stage A3: 评审与批准（Review & Approval）

**目的：** 向用户呈交 SPEC，获取明确批准。

| 准入条件 | 判断标准 |
|---------|---------|
| Stage A2 准出全部满足 | SPEC 内容填充完整 |
| 内部自审通过 | 无占位符、无自相矛盾、验收条件可检查 |

| 准出条件 | 判断标准 |
|---------|---------|
| SPEC 已呈现给用户 | AI 明确提示用户阅读 SPEC 文件 |
| 用户明确表达批准 | "批准" / "OK" / "可以" / "开始" 等确认词 |
| 或用户给出修改意见 | 回退到 Stage A2 修改 |

**此阶段：** 无新文件产生。SPEC 状态为 "评审中" → "已批准"。

MUST: 等待用户批准，不提早进入 Stage A4
MUST: 如用户有修改意见，循环 A2→A3 直到批准
MUST NOT: 在用户批准前编写任何代码（不包括原型验证片段）

##### Stage A4: SPEC 锁定（SPEC Lock）

**目的：** SPEC 正式冻结，成为后续实现的唯一合同。任何实现阶段的 SPEC 变更 MUST 走正式变更流程。

| 准入条件 | 判断标准 |
|---------|---------|
| Stage A3 准出全部满足 | 用户已明确批准 |
| SPEC 状态为 "已批准" | SPEC 文件元信息中标记 |

| 准出条件 | 判断标准 |
|---------|---------|
| SPEC 状态更新为 "已锁定" | 元信息中 `状态: 已锁定` |
| AI 已通知用户 SPEC 已锁定 | "SPEC 已锁定，进入交付阶段" |
| 交付阶段可启动 | 进入 Part B |

**修改的文件：**
```
docs/superpowers/specs/YYYY-MM-DD-<topic>-design.md   ← 状态: 已锁定
```

#### SPEC 变更流程（SPEC Amendment）

SPEC 锁定后如需修改，MUST 走以下流程，不允许直接修改 SPEC：

```
1. AI 发现 SPEC 与现实矛盾 → 向用户报告
2. 用户确认需要变更 → SPEC 状态从 "已锁定" 回退到 "评审中"
3. 在变更记录中新增条目（日期 + 变更内容 + 原因）
4. 重新走 A3（评审）→ A4（锁定）
5. 已实现但需要改的代码纳入变更范围重新实现
```

MUST: SPEC 变更记录 MUST 包含日期、变更内容、变更原因
MUST NOT: 不记录变更直接修改已锁定 SPEC
MUST: 变更后的验收条件必须与变更一致

---

#### Part B: 交付阶段（Delivery）

SPEC 锁定后，进入代码交付。此部分对应 SPEC Coding 的"执行"和"验收"，同时桥接到代码交付流水线（delivery-pipeline.md）。

```
Stage A4 (SPEC 已锁定)
       │
       ↓
┌──────────────┐    准入满足      ┌──────────────┐    验收通过      ┌──────────────┐
│  Stage B1    │ ──────────────→ │  Stage B2    │ ─────────────→ │  Stage B3    │
│  代码实现     │                 │  SPEC 验收   │                │  SPEC 归档   │
└──────────────┘                 └──────────────┘                └──────────────┘
```

##### Stage B1: 代码实现（Implementation）

**目的：** 严格按照已锁定 SPEC 编写代码。

| 准入条件 | 判断标准 |
|---------|---------|
| Stage A4 准出全部满足 | SPEC 状态为 "已锁定" |
| 已阅读 code-style.md、directory-structure.md | 当前会话已加载 |
| 开发分支已就绪（delivery-pipeline Step 1） | 分支名符合规范 |

| 准出条件 | 判断标准 |
|---------|---------|
| SPEC 验收条件每项均有对应代码 | 代码可逐行追溯至验收条件 |
| `flutter analyze` 零 warning | 输出 "No issues found!" |
| `dart format` 通过 | 无需修改 |
| 无超出 SPEC 范围的改动 | Git diff 中无 SPEC 未提及的改动 |

**新增/修改文件：**
```
lib/...                   ← 源码（按 SPEC 和 directory-structure.md 约定位置）
test/...                  ← 测试（镜像源码结构）
```

MUST: 严格对照 SPEC——"这行代码对应验收条件第 X 条"
MUST: 新增公开方法 MUST 在 test/ 有对应测试
MUST NOT: 在实现中修改 SPEC（如需变动 = SPEC 变更流程）

##### Stage B2: SPEC 验收（SPEC Acceptance）

**目的：** 逐项验证代码实现是否满足 SPEC 中每一条验收条件。

| 准入条件 | 判断标准 |
|---------|---------|
| Stage B1 准出全部满足 | 代码实现完成 |
| `flutter test` 全通过 | 所有测试通过 |

| 准出条件 | 判断标准 |
|---------|---------|
| SPEC 中每条验收条件 `[ ]` → `[x]` | AI 逐条核对代码后勾选 |
| 验收条件 100% 通过 | 不存在 `[ ]` 未勾选条目 |
| SPEC 状态更新为 "已验收" | 元信息中标明 `状态: 已验收` |
| 提交已就绪（delivery-pipeline Step 4） | 提交信息格式正确 |

**修改的文件：**
```
docs/superpowers/specs/YYYY-MM-DD-<topic>-design.md   ← 验收条件全部 [x]，状态: 已验收
```

MUST: AI MUST 逐条读代码验证，不允许批量勾选
MUST: 验收不通过的条目 MUST 返回 B1 修复
MUST NOT: "好像没问题就勾了"——每条验收必须有对应代码行号

##### Stage B3: SPEC 归档（SPEC Archive）

**目的：** SPEC 进入永久存档，作为项目开发历史的一部分。如有必要，更新项目总文档。

| 准入条件 | 判断标准 |
|---------|---------|
| Stage B2 准出全部满足 | SPEC 已验收，100% `[x]` |
| 代码已合并到 main | delivery-pipeline Step 5 完成 |
| Git 提交已进入 main 历史 | `git log` 可见 |

| 准出条件 | 判断标准 |
|---------|---------|
| SPEC 状态更新为 "已归档" | 元信息中 `状态: 已归档` |
| 相关设计决策已记录（如有必要） | 架构变更 → 已同步 docs/Plans.md |
| 变更记录完整 | SPEC 底部的变更记录含全部修订历史 |

**修改的文件：**
```
docs/superpowers/specs/YYYY-MM-DD-<topic>-design.md   ← 状态: 已归档
docs/Plans.md                                          ← 仅在架构变更时更新
```

MUST: 归档后 SPEC 文件不再修改（它是历史记录）
MUST: 架构变更 MUST 同步更新 docs/Plans.md
MUST NOT: 归档后继续编辑 SPEC（如需后续修改 = 新开 SPEC 文档）

### 3. delivery-pipeline.md —— 代码交付流水线

**目的：** 定义一个小功能从分支创建到合并的完整生命周期，与 AI 认知阶段（Phase 1-5）并行运行。AI 认知控制"怎么想"，交付流水线控制"怎么交付"。两者同时约束。

#### 流水线总览

```
┌─────────────┐   准入满足    ┌─────────────┐   准入满足    ┌─────────────┐
│  Step 1     │ ────────────→ │  Step 2     │ ────────────→ │  Step 3     │
│  分支就绪    │               │  代码开发    │               │  自测验证    │
└─────────────┘               └─────────────┘               └─────────────┘
                                                                  │
                                                                  │ 准入满足
                                                                  ↓
┌─────────────┐   准入满足    ┌─────────────┐               ┌─────────────┐
│  Step 5     │ ←─────────── │  Step 4     │ ←─────────── │              │
│  合并归档    │               │  提交就绪    │               │  (Step 3)   │
└─────────────┘               └─────────────┘               └─────────────┘
```

#### Step 1: 分支就绪（Branch Ready）

**目的：** 基于最新 main 创建符合规范的开发分支。

| 准入条件 | 判断标准 |
|---------|---------|
| 当前在 main 分支且无脏文件 | `git status --porcelain` 输出为空 |
| main 分支已同步远端 | `git fetch && git diff main..origin/main` 输出为空 |
| 分支名符合规范 | 匹配 `<type>/<short-description>` |
| type 在允许列表中 | type ∈ {feat, fix, refactor, doc, chore} |
| 分支描述包含中文关键词 | 如 `feat/yang-dun-calculator` 后段为中文拼音或英文关键字，不可为无意义数字 |

| 准出条件 | 判断标准 |
|---------|---------|
| 新分支已从 main 创建 | `git branch --show-current` 输出新分支名 |
| 分支名符合规范 | 检查正则: `^(feat|fix|refactor|doc|chore)/[a-z][a-z0-9-]+[a-z0-9]$` |

MUST: 分支从 main 最新提交创建
MUST NOT: 从其他非 main 分支派生
MUST NOT: 在已有脏工作区时创建分支

#### Step 2: 代码开发（Development）

**目的：** 在分支内完成代码开发，随时自查。此步骤对应 SPEC Coding Stage B1（代码实现）。

| 准入条件 | 判断标准 |
|---------|---------|
| Step 1 准出全部满足 | 分支已就绪 |
| SPEC 已锁定（非平凡改动） | SPEC 状态为 "已锁定"，文件存在于 docs/superpowers/specs/ |
| 已阅读相关规范（code-style, directory-structure, doc-standards） | AI 在会话中已读取对应模块 |

| 准出条件 | 判断标准 |
|---------|---------|
| 所有计划的功能点已实现 | 对照设计文档逐项勾选 |
| `flutter analyze` 无 error/warning | 运行 `flutter analyze` 输出 "No issues found!" |
| `dart format` 通过无需修改 | 运行 `dart format --set-exit-if-changed lib/ test/` 返回 0 |
| 无死代码/注释代码/调试打印 | Grep 搜索 `// TODO`、`print(`、注释掉的 import 等，全部清除 |
| 代码符合设计文档范围 | diff 中无超出设计范围的改动 |

MUST: 每次修改后立即运行 `flutter analyze`
MUST: 新增公开类/方法需有一行中文注释
MUST NOT: 提交调试代码、打印语句、注释掉的废弃代码
MUST NOT: 超出设计文档范围进行修改
MUST NOT: 修改 analysis_options.yaml 降低 lint 标准

#### Step 3: 自测验证（Testing）

**目的：** 确保代码正确、无回归。

| 准入条件 | 判断标准 |
|---------|---------|
| Step 2 准出全部满足 | 代码开发完成且零 warning |
| 测试文件已存在或被新增 | 如为新增功能，对应 test/ 下有镜像文件 |

| 准出条件 | 判断标准 |
|---------|---------|
| `flutter test` 全通过 | 输出 "All tests passed!" |
| 新增代码有对应测试覆盖（非平凡功能） | 新增公开函数/方法在 test/ 下有对应 test case |
| 无遗留 console 输出 | 测试输出中无异常 print/debugPrint |
| 手动验证路径通过（UI 相关） | UI 改动已在模拟器或真机上确认 |

MUST: 每次新增公开方法 MUST 编写对应测试
MUST: 测试命名: `test('场景描述_预期结果')` 中文格式
MUST NOT: 用 `skip` 跳过失败的测试
MUST: 发现失败的旧测试时 MUST 先修复再继续
MUST NOT: 降低测试标准或删除测试来"通过"

**测试通过门槛：**
```
所有测试 MUST 通过，以下情况属于"不通过":
  - 任何 test case 返回 failure
  - flutter analyze 出现新 warning
  - 测试输出中有未预期的 stderr
```

#### Step 4: 提交就绪（Commit Ready）

**目的：** 将变更组织为符合规范的提交。

| 准入条件 | 判断标准 |
|---------|---------|
| Step 3 准出全部满足 | 测试全部通过 |
| 变更文件已确认 | `git diff --stat` 只包含预期文件 |
| 无意外文件变更 | 无 `build/`、`.dart_tool/`、用户配置等 |

| 准出条件 | 判断标准 |
|---------|---------|
| 提交信息格式正确 | 匹配 `<type>: <中文简述>` |
| 提交信息描述准确 | 第一行简要说明更改内容 |
| 一个提交 = 一个逻辑变更 | 本提交的 diff 可单独 revert 而不破坏其他功能 |
| 无敏感文件 | diff 中无 .env、私钥、密码、token |

**提交信息判断标准：**
```
MUST:  <type>: <中文简述>
type ∈ {add, fix, update, refactor, remove, init}

正确: add 用户认证服务
      fix 登录超时边界错误
      update 数据库迁移配置
错误: "fix bug"
      "update"
      "修改了一些东西"
      "WIP"
      "merged"
```

MUST: 一个提交一个逻辑变更（单一职责）
MUST: 提交信息用中文，格式: `<type>: <简述>`
MUST NOT: 提交不相关的多个改动（分散在多个文件的不同逻辑）
MUST NOT: 提交含 `--no-verify` 跳过检查

#### Step 5: 合并归档（Merge & Archive）

**目的：** 将开发分支合并到 main，保留历史清晰。

| 准入条件 | 判断标准 |
|---------|---------|
| Step 4 准出全部满足 | 提交符合规范 |
| main 无新冲突 | `git fetch && git merge-base --is-ancestor HEAD origin/main` |
| 与 main 合并成功 | merge 无冲突（如有，需解决后重新走 Step 3） |

| 准出条件 | 判断标准 |
|---------|---------|
| main 已包含分支所有提交 | `git log origin/main..HEAD` 对比确认 |
| 提交历史无 "fix typo" / "fix fix" 等噪声 | 如果存在，在合并前 squash 清理 |
| 设计文档已更新（如必要） | 架构变更 MUST 同步更新 docs/Plans.md 或相关 spec |

MUST: 合并前确认所有测试再次通过（post-merge test）
MUST: 合并后删除远程开发分支
MUST: 架构变更 MUST 更新 docs/Plans.md
MUST NOT: 绕过流水线步骤直接推送 main
MUST NOT: 合并后遗留开发分支

#### 判断标准分级

流水线中判断标准分三级，AI MUST 在每步自评：

| 级别 | 含义 | 行为 |
|------|------|------|
| **硬门禁 (Hard Gate)** | 未满足 = 绝对禁止进入下一步 | MUST 停止，修复后重试 |
| **软提醒 (Soft Reminder)** | 未满足 = 当前步骤不算完成 | SHOULD 完成后再进入下一步 |
| **最佳实践 (Best Practice)** | 推荐但不强制 | MAY 酌情处理 |

硬门禁示例：
- `flutter analyze` 有 error
- 分支名不符合规范
- 提交信息为空或纯英文数字

软提醒示例：
- 测试覆盖率未达到目标线
- 注释中缺少某个方法的简述

---

### 4. code-style.md —— Dart/Flutter 代码规范

#### 4.1 基础规则

MUST: 代码 MUST 通过 `flutter analyze`（基于 `analysis_options.yaml` 中的 `flutter_lints`）
MUST: 代码 MUST 通过 `dart format`，无格式差异
MUST: 编码使用 UTF-8

#### 4.2 命名规范

| 类型 | 规范 | 示例 (正确) | 示例 (错误) |
|------|------|------------|------------|
| 文件名 | snake_case | `auth_service.dart` | `AuthService.dart` |
| 类名 | PascalCase | `AuthService` | `authService` |
| 方法/函数 | camelCase | `calculateJuNumber()` | `CalculateJuNumber()` |
| 变量 | camelCase | `accumulatedYear` | `accumulated_year` |
| 常量 | camelCase | `defaultJuCycle` | `DEFAULT_JU_CYCLE` |
| 枚举值 | camelCase | `jingMirror` | `JING_MIRROR` |
| 私有成员 | `_` 前缀 + camelCase | `_ruleSet` | `ruleSet_` |

MUST NOT: 拼音命名（项目专有术语除外：已约定的领域术语可用拼音）
MUST NOT: 单字母变量名（循环索引 `i`, `j`, `k` 除外）
MUST NOT: 匈牙利命名法或前缀类型编码（`strName`, `bIsValid`）
MUST NOT: SCREAMING_SNAKE_CASE 常量（Dart 风格用 camelCase）

#### 4.3 文件结构

MUST: 一个文件一个核心类/职责
MUST: 文件行数上限 300 行（超出 MUST 拆分）
MUST NOT: 一个文件中混合不相关的多个类

导入顺序（各组间空行分隔）：
```dart
// 1. dart: 内置库
import 'dart:math';

// 2. package: 依赖
import 'package:flutter/material.dart';

// 3. 相对路径导入
import 'auth_service.dart';
```

MUST NOT: 使用 `show` / `hide` 修饰符（除非解决直接命名冲突）

#### 4.4 注释规范

| 场景 | 规范 |
|------|------|
| 公开类/方法/函数 | MUST 有一行中文 `///` 简述 |
| 私有核心方法 | MUST 有一行中文 `//` 简述（非核心的私有助手方法可省略） |
| 复杂逻辑分支 | MUST 在分支前有 `//` 说明 WHY（不说 WHAT） |
| 枚举值 | 每个值 MUST 有 `///` 中文说明 |

示例：
```dart
/// 用户认证统一入口，按认证方式和配置完成完整认证流程
class AuthService {
  /// 验证用户凭据，不同认证方式使用不同验证策略
  Future<AuthResult> _authenticate(AuthRequest request) async {
    // OAuth 和本地认证使用不同的验证流程
    if (request.method == AuthMethod.oauth) {
      return _oauthFlow(request);
    }
    return _localAuth(request);
  }
}
```

MUST NOT: 注释描述 WHAT（代码本身已表达）
MUST: 注释描述 WHY（为什么这样写、为什么不用另一种方式）
MUST NOT: 冗余注释（如 `// 创建对象` 在 `new Foo()` 上方）
MUST NOT: 注释掉的代码（直接删除，Git 历史可恢复）

#### 4.5 代码质量

| 规则 | 级别 |
|------|------|
| MUST NOT 硬编码字符串/数字（提取为常量或枚举） | 硬门禁 |
| MUST NOT 超过 300 行单文件 | 软提醒 |
| MUST NOT 嵌套超过 3 层的 if/for/while | 软提醒 |
| MUST NOT 使用 `dynamic`（除非与平台通道交互） | 软提醒 |
| MUST NOT 忽略异常而不记录原因 | 硬门禁 |
| SHOULD 优先使用 `const` 构造函数 | 最佳实践 |
| SHOULD 使用 `final` 而非 `var`（当变量不再赋值时） | 最佳实践 |

---

### 5. directory-structure.md —— 目录与文件结构规范

#### 5.1 顶层目录约束

```
<项目根目录>/
  AI_README.md         ← 允许（AI 宪法入口）
  README.md            ← 允许（项目说明）
  pubspec.yaml         ← 允许（Flutter 项目配置）
  analysis_options.yaml ← 允许（Lint 配置）
  build.yaml           ← 允许（构建配置）
  .gitignore           ← 允许（Git 忽略规则）

  lib/                 ← MUST: 所有源代码
  test/                ← MUST: 所有测试（镜像 lib/ 结构）
  docs/                ← MUST: 所有文档
  scripts/             ← MAY: 辅助脚本

  build/               ← MUST NOT 提交
  .dart_tool/          ← MUST NOT 提交
  .android/            ← MUST NOT 手动修改
  .ios/                ← MUST NOT 手动修改
```

MUST NOT: 根目录散落 `.dart` 文件
MUST NOT: 根目录散落非上述列出的 `.md` 文件（所有 .md 文档 MUST 放在 `docs/` 下，除 AI_README.md 和 README.md）
MUST NOT: 根目录出现配置文件（`.env`、`local.properties`、用户 IDE 配置等）

#### 5.2 lib/ 结构约定

```
lib/
  main.dart              ← 入口
  navigator.dart         ← 路由

  services/              ← 核心业务逻辑
    core/                ← 引擎、枚举、输入输出模型
    rules/               ← 规则集实现
    calculators/         ← 计算步骤
    data/                ← 常量/查表数据
    analytics/           ← 分析追踪

  models/                ← 通用数据模型
  enums/                 ← 枚举定义
  pages/                 ← 页面 Widget
  widgets/               ← 复用 Widget 组件
  controllers/           ← 状态管理/控制器
  painter/               ← 自定义绘制
  theme/                 ← 主题配置
```

MUST: 新包按功能域组织，不按技术层（如不放 models/ 下混放所有模型）
MUST: 已在 docs/Plans.md 中约定的结构，MUST 遵守
SHOULD: 新增独立功能域在 lib/ 下新建包目录

#### 5.3 test/ 结构约定

```
test/
  services/
    core/
    rules/
    calculators/
  models/
  ...
```

MUST: test/ 目录结构镜像 lib/ 结构
MUST: 测试文件命名: `<source_file>_test.dart`
MUST NOT: 测试文件散落在 test/ 根目录

#### 5.4 docs/ 结构约定

```
docs/
  Plans.md                          ← 项目总体规划
  ai/                               ← AI 协同规范模块
  superpowers/
    specs/                          ← SPEC 设计文档
      YYYY-MM-DD-<topic>-design.md
```

MUST: 设计文档放在 `docs/superpowers/specs/`
MUST: AI 协同规范放在 `docs/ai/`
MUST NOT: docs/ 下放代码、二进制、图片（如有需要，放在 `docs/assets/`）

#### 5.5 新增文件/目录的准入标准

| 检查项 | 标准 |
|--------|------|
| 文件位置 | 是否符合上述目录约定 |
| 文件命名 | snake_case (Dart) / kebab-case (Markdown) |
| 是否冲突 | 不重复已有文件的职责 |
| 是否过细 | 单一函数不单独建文件（除非是公开 API 核心算法） |

---

### 6. git-rules.md —— Git 分支/提交/PR 命名规范

#### 6.1 分支命名

```
MUST 格式: <type>/<short-description>

type 允许值:
  feat      ← 新功能
  fix       ← 缺陷修复
  refactor  ← 纯重构（不改变功能）
  doc       ← 文档变更
  chore     ← 构建/依赖/工具变更

short-description:
  MUST: 小写英文字母 + 连字符
  MUST: 至少包含一个中文拼音或英文功能关键词
  MUST: 长度 8-40 字符

正确: feat/yang-dun-calculator
      fix/wenchang-redouble
      refactor/gong-panel-extract
      doc/ai-readme

错误: dev                   ← type 不在允许列表
      feat/fix-bug          ← 描述无意义
      feat/a                ← 描述太短
      测试分支               ← 未使用英文/拼音
```

#### 6.2 提交信息

```
MUST 格式: <type>: <中文简述>

type 允许值:
  add       ← 新增文件/功能
  fix       ← 修复缺陷
  update    ← 修改已有功能/逻辑
  refactor  ← 纯重构
  remove    ← 删除文件/功能
  init      ← 项目初始化

MUST: 简述不超 30 个中文字
MUST: 简述准确描述"做了什么"，不描述"为什么"（为什么在注释中）

正确: add 用户认证服务
      fix 登录超时边界错误
      update 数据库迁移配置
      refactor 列表组件提取为独立组件
      remove 废弃的旧缓存模型
      init Flutter 项目基础结构

错误: "fix bug"              ← type 错误 + 无意义
      "fix"                  ← 缺少简述
      "修改了一些代码"        ← 无意义
      "WIP"                  ← 不可合并的临时提交
      "update code"          ← 无意义 + type/subject 语言混合
      "add: new feature"     ← 不该有冒号分隔符
```

#### 6.3 提交粒度

MUST: 一个提交 = 一个逻辑变更
MUST: 一个逻辑变更的 diff 可独立 revert 而不破坏其他功能
MUST NOT: 混入不相关的文件修改（如修 A 功能时顺带改 B 功能的不相关代码）
MUST NOT: 提交调试代码、打印语句、注释掉的代码
MUST NOT: 提交 `--no-verify`（跳过 Git hooks）

#### 6.4 提交内容红线

| MUST NOT | 示例 |
|----------|------|
| 密钥/凭证 | `.env`, `credentials.json`, API keys |
| 大二进制 | `*.apk`, `*.ipa`, `*.zip`, 图片资源（>100KB 除外） |
| 生成目录 | `build/`, `.dart_tool/`, `.android/`, `.ios/` |
| IDE 配置 | `.vscode/`, `.idea/`（已在 .gitignore 中则为安全） |

MUST: Git 操作前确认 .gitignore 已排除生成目录

---

### 7. doc-standards.md —— 文档存放与格式规范

#### 7.1 文档类型与存放位置

| 文档类型 | 存放位置 | 命名格式 |
|---------|---------|---------|
| SPEC 设计文档 | `docs/superpowers/specs/` | `YYYY-MM-DD-<topic>-design.md` |
| AI 协同规范 | `docs/ai/` | kebab-case 或中文 |
| 项目规划 | `docs/` | 中文或 kebab-case |
| API 文档 | `docs/api/` (如存在) | kebab-case |
| 用户指南 | `docs/` | 中文 |

MUST NOT: 设计文档命名为 `spec.md`、`design.md`、`plan.md` 等无日期无主题的通用名

#### 7.2 文件格式

MUST: 所有文档使用 Markdown 格式
MUST: 编码 UTF-8
MUST: 文件名不包含空格（用 `-` 替代）
MUST NOT: 文件名包含特殊字符（`&`, `%`, `#`, `!` 等）

#### 7.3 Markdown 写作规范

| 规范 | 说明 |
|------|------|
| MUST 标题层级: # → ## → ### | 不跳级（如 # 下直接用 ####） |
| MUST: 代码块标注语言 | ```dart 而非 ``` |
| MUST: 表格有表头行 | 必须存在 `|------|` 分隔行 |
| SHOULD: 列表使用 `-` 而非 `*` | 保持项目一致 |
| SHOULD: 中文与英文/数字间加空格 | `定义 SPEC 文档` 而非 `定义SPEC文档` |

#### 7.4 SPEC 设计文档模板

SPEC 文档 MUST 包含以下全部字段（已在 SPEC Coding A1 中定义）：

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
MUST NOT: 设计文档中包含 TBD / TODO / FIXME / ??? 等占位符（在 SPEC 锁定时）

---

### 8. toolchain.md —— 开发环境隔离与工具链

#### 8.1 Flutter/Dart SDK 版本

MUST: SDK 版本以 `pubspec.yaml` 中 `environment` 声明为准
MUST: 推荐使用 FVM (Flutter Version Management) 管理 Flutter 版本
MUST: Dart SDK 版本由 Flutter 版本隐含确定，不在 pubspec 中单独指定不兼容版本
MUST NOT: 随意升级 `pubspec.yaml` 中的 SDK 版本约束（需经过 SPEC Coding）

#### 8.2 依赖管理

MUST: 所有依赖通过 `pubspec.yaml` 声明
MUST: 主版本锁定（使用 `^` 兼容范围或精确版本）
MUST: `pubspec.lock` MUST 提交到 Git（应用项目，非 package）
MUST NOT: 引入未使用的依赖
MUST NOT: 直接修改 `pubspec.lock`（使用 `flutter pub get` 生成）

#### 8.3 开发前检查清单

```
每次开发会话启动时:
[ ] flutter clean          ← 清理上次构建缓存
[ ] flutter pub get        ← 同步依赖
[ ] flutter analyze        ← 确认起点无 lint 错误
[ ] flutter test           ← 确认起点测试全通过
```

MUST: 在开始修改代码前运行上述 4 个命令
MUST: 如 `flutter analyze` 在修改前已有错误，MUST 先报告用户再继续

#### 8.4 构建与运行

MUST: 开发阶段使用 `flutter run --debug`（不发布 release 构建）
MUST: 测试使用 `flutter test`（不依赖特定设备）
MUST NOT: 在开发分支上执行发布构建（release build 仅在 main/release 分支上）

#### 8.5 隔离承诺

MUST: 每个功能在独立分支开发
MUST: 不修改 `.gitignore` 排除规则以绕过规范
MUST NOT: 在多个分支间共享未提交的改动（`git stash` 除外）
MUST NOT: 提交 `.flutter-plugins-dependencies`（已在 .gitignore）

### 9. glossary.md —— AI 协同通用术语

**目的：** 消除 AI 对协同规范的歧义理解。所有术语为 AI 协同通用概念，不包含项目业务术语。

#### 9.1 核心方法论术语

| 术语 | 精确定义 |
|------|---------|
| **SPEC (规格文档)** | AI 与用户之间的开发合同文档，位于 `docs/superpowers/specs/`。定义做什么、怎么做、怎么验收。 |
| **SPEC First** | 不可协商原则：任何非平凡改动 MUST 先有已批准的 SPEC 才能写代码。 |
| **SPEC Coding** | 以 SPEC 驱动的完整开发流程：Part A (A1-A4: SPEC 生命周期) + Part B (B1-B3: 交付生命周期)。 |
| **Superpowers Mandatory** | 非平凡改动 MUST 走 SPEC Coding 全流程。 |
| **Brainstorm** | 设计探索阶段，对应 SPEC Coding A1-A2，输出 DESIGN SPEC。 |
| **Plan** | 拆解 SPEC 为可执行任务，对应 A3→A4 过渡。 |
| **Do** | 按计划执行实现，对应 B1-B3。 |

#### 9.2 规范语言 (RFC 2119 风格)

| 关键词 | 语义 | 违反后果 |
|--------|------|---------|
| **MUST** | 绝对要求 | 提交无效 / 代码需重写 / 回退分支 |
| **MUST NOT** | 绝对禁止 | 同上 |
| **SHOULD** | 强烈建议 | 不遵守须在代码中注明理由 |
| **MAY** | 可选 | AI 自主判断 |

#### 9.3 流程控制

| 术语 | 定义 |
|------|------|
| **准入条件 (Entry)** | 进入阶段前 MUST 满足的条件 |
| **准出条件 (Exit)** | 离开阶段前 MUST 满足的条件 |
| **判断标准** | 验证准入/准出的客观方法，可被任何人复现 |

#### 9.4 判断标准三级

| 级别 | 含义 | 示例 |
|------|------|------|
| **硬门禁** | 不满足 = MUST 停止 | `flutter analyze` 有 error |
| **软提醒** | 不满足 = SHOULD 完成 | 测试覆盖率不够 |
| **最佳实践** | 推荐，MAY 酌情 | 使用特定设计模式 |

#### 9.5 变更管理

| 术语 | 定义 |
|------|------|
| **平凡改动** | 不涉及逻辑、不新增文件、≤5 行、错别字/格式化/明确微调 |
| **非平凡改动** | 不满足平凡改动的任何修改，MUST 走 SPEC Coding |
| **SPEC 变更** | 锁定后回退→登记→重审→重锁的正式变更流程 |
| **外科手术式修改** | 不改相邻代码、不改无关文件、diff = SPEC 覆盖范围 |

#### 9.6 交付术语

| 术语 | 定义 |
|------|------|
| **分支就绪** | 分支从最新 main 创建，命名合规 |
| **提交就绪** | analyze+test 通过，提交信息格式正确 |
| **合并就绪** | 无冲突，PR 通过，可合并 main |
| **代码冻结** | SPEC 锁定后，不允许超范围修改 |

---

### 10. project-context-guide.md —— 项目上下文阅读规则

**目的：** AI 首次接入时建立正确心智模型，防止基于猜测编码。

#### 10.1 AI 首次接入必读清单

MUST 按以下顺序完整阅读：

**第 1 批: AI 宪法层 (MUST 读全)**
```
AI_README.md → docs/ai/ 全部 10 个模块
```

**第 2 批: 项目概况层 (MUST 读全)**
```
README.md → pubspec.yaml → analysis_options.yaml → docs/Plans.md
```

**第 3 批: 源码层 (MUST 读全)**
```
lib/ 下所有 .dart 文件（按目录顺序）
```

**第 4 批: 测试层 (MUST 读全)**
```
test/ 下所有 test 文件
```

**第 5 批: 最近 SPEC (SHOULD)**
```
docs/superpowers/specs/ 下最近 5 个 SPEC
```

#### 10.2 任务前必读

1. 确认已读过 docs/ai/ 全部模块 + docs/Plans.md
2. 找到与任务相关的源文件
3. 阅读相关文件的所有直接 import（本项目的）
4. 阅读对应的 test 文件
5. 如任务延续某功能 → 阅读该功能最近 SPEC

**"直接相关"定义：** 任务要修改的代码块所在文件 + 该文件 import 的本项目文件 + 被依赖的文件

#### 10.3 禁止

MUST NOT: 跳过 AI_README.md 直接编码
MUST NOT: 只读 pubspec.yaml 就推测项目结构
MUST NOT: 假设项目遵循某种模式而不验证
MUST NOT: 依赖训练数据推测（"Flutter 项目一般..."）
MUST NOT: 文档与代码矛盾时自行选一边 → MUST 向用户报告

#### 10.4 文档与代码冲突处理

```
1. 停止当前任务
2. 明确指出: 文档说 X，代码实际 Y
3. 询问用户以哪个为准
4. 用户确认后: 以文档为准→创建 fix 任务 / 以代码为准→创建 doc 任务
5. MUST NOT 在确认前继续
```

#### 10.5 同步更新规则

| 变更类型 | 需更新的文档 |
|---------|-------------|
| 架构变更 | docs/Plans.md |
| 新增依赖 | pubspec.yaml + docs/Plans.md |
| 目录调整 | docs/ai/directory-structure.md |
| 规范变更 | 对应 docs/ai/ 模块 |
| SPEC 交付完成 | SPEC 验收条件 + 状态字段 |

MUST NOT: 只改代码不更新受影响文档

---

## 平凡改动豁免（Trivial Change Exemption）

以下情况允许跳过 SPEC Coding (A1-A4) 直接进入交付 (B1)：

| 类型 | 示例 |
|------|------|
| 错别字 / 文字修正 | 修复注释中的错字 |
| 单行修复 | 修正一个变量名拼写错误 |
| 格式化 | `dart format` 自动格式化 |
| 明确指定的微调 | 用户说"把这里改成 X"且改动范围 ≤ 5 行 |
| 测试数据更新 | 更新测试用例中的预期值 |

**边界：** 任何涉及逻辑变更、新增文件、结构调整、超过 5 行的修改，MUST 走完整 SPEC Coding 流程。

---

## 技术决策

| 决策 | 选择 | 理由 |
|------|------|------|
| 文件格式 | 纯 Markdown | 通用，所有 AI 工具可消费 |
| 语言 | 中文 | 匹配项目语言环境 |
| 规范语言 | MUST / MUST NOT (RFC 2119 风格) | 明确、无歧义、跨模型可理解 |
| 结构策略 | 入口文件 + 子模块 | 兼顾首读效率和模块化维护 |
| 执行机制 | AI 自律 + 约束语言 | 轻量、不需额外基础设施 |
| 术语表 | 通用术语，无业务术语 | 业务术语属于项目文档，不属于 AI 协作协议 |

## 风险

1. AI 读不全子模块——入口文件 MUST 声明"不读完子模块禁止编码"来降低此风险
2. MUST/MUST NOT 无技术约束力——靠措辞强硬度 + 快速自检清单提供行为框架
3. 规则膨胀——子模块各自维护，首次建立后按需修订，不预加未来需求
