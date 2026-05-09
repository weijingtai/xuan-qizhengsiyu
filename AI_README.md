# AI 协同宪法

**Preamble：** 本文件是此项目的 AI 协同开发唯一权威规范。所有 AI 大模型和 AI IDE 在参与本项目开发时，MUST 在第一次接触项目时完整读取本文件及 `docs/ai/` 下全部 10 个模块。任何与本文件冲突的行为视为违规。

本项目的 AI 协同规范基于 SPEC-Driven Development（规格驱动开发）。核心原则：**SPEC First——SPEC 不批准 = 不写第一行代码。**

---

## 核心原则摘要

以下 7 条原则不可协商。详见 [docs/ai/principles.md](docs/ai/principles.md)。

| # | 原则 | 一句话 |
|---|------|--------|
| 1 | **SPEC First** | 非平凡改动 MUST 先有已批准的 SPEC |
| 2 | **Think Before Coding** | 不假设、不隐藏困惑、呈现方案再动手 |
| 3 | **Simplicity First** | 不写未被要求的功能、不过度抽象 |
| 4 | **Surgical Changes** | 只改相关、不改相邻、匹配已有风格 |
| 5 | **Goal-Driven** | 定义验收标准、循环直到通过 |
| 6 | **Chinese-First** | 注释和提交信息用中文 |
| 7 | **Context-Aware** | 从实际文件获取上下文，不猜测 |

---

## 强制工作流

### 非平凡改动（所有超出平凡豁免的修改）

```
SPEC Coding Part A (SPEC 生命周期)
  A1 启动框架 → A2 内容填充 → A3 评审批准 → A4 SPEC 锁定

SPEC Coding Part B (交付生命周期)
  B1 代码实现 → B2 SPEC 验收 → B3 SPEC 归档
```

同时遵循代码交付流水线（[docs/ai/delivery-pipeline.md](docs/ai/delivery-pipeline.md)）：
```
Step 1 分支就绪 → Step 2 代码开发 → Step 3 自测验证 → Step 4 提交就绪 → Step 5 合并归档
```

### 平凡改动豁免

以下情况允许跳过 SPEC Coding Part A 直接进入 Part B：

- 错别字 / 文字修正
- 单行修复（≤5 行）
- `dart format` 自动格式化
- 用户明确指定的微调（≤5 行）
- 测试数据更新

**边界：** 逻辑变更、新增文件、结构调整、超过 5 行的修改 → MUST 走完整 SPEC Coding。

---

## SPEC Coding 阶段总览

详见 [docs/ai/phases.md](docs/ai/phases.md)。

### Part A: SPEC 生命周期

| 阶段 | 做什么 | 准出文件 |
|------|--------|---------|
| A1 启动框架 | 确认非平凡改动，搭建 SPEC 骨架（10 个必填节） | `docs/superpowers/specs/YYYY-MM-DD-<topic>-design.md` (草稿) |
| A2 内容填充 | 填入设计内容，验收条件逐项可勾选，内部自洽 | 同上 (评审中) |
| A3 评审批准 | 呈交用户，获取明确批准 | 同上 (已批准) |
| A4 SPEC 锁定 | SPEC 正式冻结，成为实现合同 | 同上 (已锁定) |

### Part B: 交付生命周期

| 阶段 | 做什么 | 修改文件 |
|------|--------|---------|
| B1 代码实现 | 严格按 SPEC 编写代码，flutter analyze + dart format 通过 | `lib/...` `test/...` |
| B2 SPEC 验收 | 逐条 `[ ]` → `[x]`，100% 验收通过 | SPEC 文件 + 代码 |
| B3 SPEC 归档 | SPEC 永久存档，架构变更同步更新 Plans.md | SPEC → 已归档 |

### SPEC 变更流程

SPEC 锁定后如需修改：回退→变更记录→重审→重锁。详见 [docs/ai/phases.md](docs/ai/phases.md)。

---

## 代码交付流水线总览

详见 [docs/ai/delivery-pipeline.md](docs/ai/delivery-pipeline.md)。

| 步骤 | 硬门禁（不满足 MUST 停止） |
|------|--------------------------|
| Step 1 分支就绪 | 分支名匹配规范 `type/short-description`，从最新 main 创建 |
| Step 2 代码开发 | `flutter analyze` 零 warning，`dart format` 通过，SPEC 锁定 |
| Step 3 自测验证 | `flutter test` 全通过，新增方法有测试 |
| Step 4 提交就绪 | 提交信息 `<type>: <中文简述>`，diff 无敏感文件 |
| Step 5 合并归档 | Post-merge test 通过，架构变更同步 docs/Plans.md |

### 判断标准三级

| 级别 | 含义 |
|------|------|
| **硬门禁** | 不满足 = MUST 停止修复 |
| **软提醒** | 不满足 = SHOULD 完成 |
| **最佳实践** | 推荐，MAY 酌情 |

---

## 快速违规自检清单

AI 在每次修改前 MUST 对照此清单：

```
[ ] 1. 我是否已读完 AI_README.md 及 docs/ai/ 全部模块？
[ ] 2. 这个改动是平凡改动还是非平凡改动？
[ ] 3. 如果是非平凡改动，SPEC 是否已写、已批、已锁定？
[ ] 4. 我是否已阅读与任务直接相关的所有源文件及其依赖？
[ ] 5. 我的改动是否严格限定在 SPEC / 用户要求范围内？
[ ] 6. flutter analyze 是否零 warning？
[ ] 7. flutter test 是否全部通过？
[ ] 8. 提交信息是否符合 <type>: <中文简述> 格式？
[ ] 9. diff 中有无死代码、调试打印、注释掉的代码？
[ ] 10. 有没有我不小心改到的无关文件？
```

---

## 模块索引

所有详细规则在 `docs/ai/` 下。MUST 按顺序完整阅读。

| # | 模块 | 说明 |
|---|------|------|
| 1 | [glossary.md](docs/ai/glossary.md) | AI 协同通用术语定义 |
| 2 | [principles.md](docs/ai/principles.md) | 7 条不可协商的开发原则 |
| 3 | [phases.md](docs/ai/phases.md) | SPEC Coding A1-A4 + B1-B3 阶段定义 |
| 4 | [delivery-pipeline.md](docs/ai/delivery-pipeline.md) | 代码交付流水线 5 步 + 三级判断标准 |
| 5 | [code-style.md](docs/ai/code-style.md) | Dart/Flutter 命名、文件、注释、代码质量 |
| 6 | [directory-structure.md](docs/ai/directory-structure.md) | 顶层、lib/、test/、docs/ 目录约束 |
| 7 | [git-rules.md](docs/ai/git-rules.md) | 分支命名、提交格式、粒度、红线 |
| 8 | [doc-standards.md](docs/ai/doc-standards.md) | 文档位置、Markdown 规范、SPEC 模板 |
| 9 | [toolchain.md](docs/ai/toolchain.md) | SDK 版本、依赖管理、开发前检查、隔离、qizhengsiyu 项目专有约定 |
| 10 | [project-context-guide.md](docs/ai/project-context-guide.md) | 首次必读清单、任务前必读、冲突处理 |

---

**AI MUST:** 在读取本文件后，立即按顺序读取 docs/ai/ 下全部 10 个模块。未读完所有模块前禁止编写任何代码。
