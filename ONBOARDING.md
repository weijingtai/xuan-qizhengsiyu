# 首次接入指南

**目的：** 让任何 AI 工具或人能在 5 分钟内理解这套文档体系，并适配到新项目。

---

## 一、这套文档体系是什么

这是一套可复用的 **AI 协同开发规范框架**，与具体项目解耦。核心思路：SPEC First（规格先行）——任何非平凡改动必须先有设计文档，再写代码。

```
docs/
  ONBOARDING.md           ← 本文件（首次必读）
  README.md               ← docs/ 使用说明
  Plans.md                ← 项目开发计划（需替换）

  ai/                     ← AI 协同宪法（直接复用）
    CONSTITUTION.md       ← 全局版本清单
    board-protocol.md     ← 看板使用协议 + 权限矩阵
    glossary.md           ← 术语定义（纯方法论）
    principles.md         ← 7 条不可协商原则
    phases.md             ← SPEC Coding 阶段定义
    delivery-pipeline.md  ← 代码交付流水线
    code-style.md         ← 代码规范（可按语言替换）
    directory-structure.md← 目录结构规范
    git-rules.md          ← Git 分支/提交规范
    doc-standards.md      ← 文档格式规范
    toolchain.md          ← 工具链（可按技术栈替换）
    project-context-guide.md ← AI 上下文阅读规则

  board/                  ← 公共进度看板（空模板）
    TASKS.md              ← 任务队列
    PROGRESS.md           ← 进度仪表盘

  project/                ← 项目内容（空模板）
    README.md             ← project/ 说明

  superpowers/            ← SPEC 系统（直接复用）
    specs/                ← SPEC 设计文档存档
    plans/                ← 实现计划存档
```

---

## 术语说明表

### 体系角色

| 术语 | 说明 |
|------|------|
| **人** | 项目维护者，唯一有权批准 SPEC、授权 AI 写看板/Plans/project/ |
| **AI** | 任意 LLM 或 AI IDE，遵守宪法规则参与开发 |
| **AI 工作区** | `docs/<developer>-<Model>/` 目录，AI 唯一可自主写入的区域 |

### 核心概念

| 术语 | 说明 |
|------|------|
| **SPEC** | AI 与用户之间的开发合同文档，定义做什么、怎么做、怎么验收 |
| **SPEC Coding** | SPEC 驱动的完整开发流程：Part A (A1-A4: SPEC 生命周期) + Part B (B1-B3: 交付) |
| **平凡改动** | ≤5 行、错别字、格式化——可跳过 SPEC 流程直接改 |
| **非平凡改动** | 超出平凡改动豁免的任何修改，MUST 走 SPEC Coding 全流程 |
| **宪法** | `docs/ai/` 下 12 个模块的总称，所有 AI MUST 遵守 |
| **AI_README.md** | 项目根目录的宪法入口文件，AI 首次接入时第一个读取 |

### 目录速查

| 路径 | 性质 | 说明 |
|------|------|------|
| `docs/ai/` | AI 只读 | 12 个宪法模块，定义所有协作规则 |
| `docs/board/` | AI 只读（写入需人许可） | 公共任务队列和进度看板 |
| `docs/project/` | AI 只读（写入需人许可） | 项目 PRD/ADR/Changelog |
| `docs/Plans.md` | AI 只读（写入需人许可） | 项目总体规划 |
| `docs/<me>/` | AI 读写 | 当前 AI 自己的任务工作区 |
| `docs/<other>/` | AI 只读 | 其他 AI 的工作区 |
| `docs/superpowers/` | AI 读写 specs/plans/ | SPEC 设计文档和实现计划存档 |

### 流程术语

| 术语 | 说明 |
|------|------|
| **SPEC Coding Part A** | A1 启动框架 → A2 内容填充 → A3 评审批准 → A4 SPEC 锁定 |
| **SPEC Coding Part B** | B1 代码实现 → B2 SPEC 验收 → B3 SPEC 归档 |
| **交付流水线** | Step 1 分支就绪 → Step 2 代码开发 → Step 3 自测验证 → Step 4 提交就绪 → Step 5 合并归档 |
| **W1-W5** | AI 写入看板的唯一合法通道：完成步骤→请求→等人批准→写入→报告 |
| **硬门禁** | 不满足则 MUST 停止的条件（如 `flutter analyze` 有 error） |
| **软提醒** | 不满足应完成的条件（如测试覆盖率不足） |

### 规范语言

| 关键词 | 含义 |
|--------|------|
| **MUST** | 绝对要求，违反 = 提交无效 / 需重写 |
| **MUST NOT** | 绝对禁止 |
| **SHOULD** | 强烈建议，不遵守需注明理由 |
| **MAY** | 可选，AI 自主判断 |

> 完整术语定义见 [docs/ai/glossary.md](ai/glossary.md)。

---

## 二、开箱即用三步

### 第 1 步：替换项目专属内容

| 文件 | 做什么 |
|------|--------|
| `Plans.md` | 替换为你的项目开发计划 |
| `ai/code-style.md` | 如果技术栈不是 Dart/Flutter，替换为对应语言规范 |
| `ai/toolchain.md` | 替换为你的 SDK/构建/工具链配置 |
| `ai/directory-structure.md` | 将 `lib/` 结构示例替换为你项目的实际结构 |
| `project/README.md` | 更新文件命名示例 |
| `board/TASKS.md` | 保持空模板即可，任务按需添加 |
| `board/PROGRESS.md` | 保持空模板，由人维护 |

### 第 2 步：创建 AI_README.md（宪法入口）

在项目根目录创建 `AI_README.md`，内容为：
- 7 条核心原则摘要
- SPEC Coding 工作流（A1-A4 → B1-B3）
- 代码交付流水线 5 步
- 10 项快速自检清单
- 指向 `docs/ai/` 下 12 个模块的索引

> `superpowers/specs/2026-05-08-ai-readme-design.md` 和 `superpowers/plans/2026-05-08-ai-readme-implementation.md` 中有完整的 AI_README.md 设计规格和实现参考。

### 第 3 步：告知 AI

每次新 AI 接入时，告诉它：

```
请先阅读 AI_README.md 和 docs/ai/ 下全部 12 个模块，然后开始工作。
```

`docs/ai/project-context-guide.md` 中定义了完整的 AI 首次接入必读清单。

---

## 三、AI 首次接入时的行为

AI 在读完 `docs/ai/` 全部模块后，应能自行理解：

1. **权限边界**——只能写自己的 `docs/<me>/` 目录，其他区域需经人许可
2. **工作流**——非平凡改动 → SPEC Coding A1-A4 → 交付 B1-B3
3. **提交规范**——`<type>: <中文简述>`
4. **看板交互**——读/写看板必须走 W1-W5 通道
5. **冲突处理**——文档与代码矛盾时必须先问人

不需要人对每个 AI 重复解释规则。

---

## 四、人维护指南

| 频率 | 做什么 |
|------|--------|
| 每次新项目 | 更新 `Plans.md`，替换技术栈相关模块 |
| 每周 | 更新 `board/PROGRESS.md` |
| 规则变更时 | 走 SPEC Coding 流程修改 `docs/ai/`，更新 `CONSTITUTION.md` 版本号 |
| 任务完成时 | 将已完成的 TASK 从 `TASKS.md` 移入归档区 |

---

## 五、常见问题

**Q: 这套体系对小型项目会不会太重？**
A: 平凡改动豁免（≤5 行、错别字、格式化）可以直接跳过 SPEC 流程。小型项目大部分日常改动属于平凡改动。

**Q: 如果技术栈不是 Flutter/Dart？**
A: 替换 `ai/code-style.md` 和 `ai/toolchain.md` 为对应语言/工具链规范。其余 10 个 `ai/` 模块是方法论，与语言无关。

**Q: AI 违反规则怎么办？**
A: `ai/board-protocol.md` 第五章定义了违规处理：撤销写入权限 → 降级为全只读 → 移除工作目录。

**Q: Plans.md 必须写什么？**
A: 至少包含：目标、支持的功能/模块、总体原则、推荐目录结构、开发阶段、里程碑、风险点。当前 `Plans.md` 是一个完整示例可参考。
