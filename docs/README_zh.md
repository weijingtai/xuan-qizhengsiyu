# AI 协同开发文档框架

一套可复用的、与具体项目解耦的 AI 辅助开发规范框架。核心理念：**SPEC First（规格先行）**——任何非平凡改动必须先有已批准的设计文档，再写代码。

## 框架提供什么

- **12 模块 AI 宪法**（`docs/ai/`）——所有 AI 工具 MUST 遵守的规则体系：原则、阶段、交付流水线、代码规范、Git 规范等
- **SPEC 驱动工作流**——Part A（SPEC 生命周期 A1-A4）+ Part B（交付 B1-B3），每步都有准入/准出条件
- **多 AI 工作区隔离**——每个 `<developer>-<Model>` 拥有独立目录，可读全局、只能写自己
- **看板协议**——共享 `TASKS.md` / `PROGRESS.md`，AI 写入必须走 W1-W5 五步通道（需经人许可）
- **平凡改动豁免**——≤5 行、错别字、格式化可直接跳过 SPEC 流程

## 快速开始

```bash
git clone https://github.com/weijingtai/docs.git docs/
```

然后阅读 [`ONBOARDING.md`](ONBOARDING.md) ——5 分钟了解全部。

AI 工具接入时，告诉它：

```
请先阅读 AI_README.md 和 docs/ai/ 下全部 12 个模块，然后开始工作。
```

## 目录结构

```
docs/
  ONBOARDING.md           ← 首次接入指南（5 分钟开箱）
  README.md               ← 英文说明
  README_zh.md            ← 本文件
  Plans.md                ← 项目开发计划（替换为你的）

  ai/                     ← AI 宪法（直接复用）
    CONSTITUTION.md       ← 12 模块版本矩阵
    board-protocol.md     ← 看板协议 + 权限矩阵
    glossary.md           ← 方法论术语
    principles.md         ← 7 条不可协商原则
    phases.md             ← SPEC Coding 阶段定义
    delivery-pipeline.md  ← 5 步代码交付流水线
    code-style.md         ← 代码规范（按语言替换）
    directory-structure.md← 目录结构规范
    git-rules.md          ← 分支/提交规范
    doc-standards.md      ← 文档格式与命名规范
    toolchain.md          ← 工具链配置（按技术栈替换）
    project-context-guide.md ← AI 上下文阅读规则

  board/                  ← 公共进度看板（空模板）
  project/                ← 项目内容（PRD/ADR/Changelog）
  superpowers/            ← SPEC 文档存档
```

## 适配你的项目

| 文件 | 操作 |
|------|------|
| `Plans.md` | 替换为你的项目开发计划 |
| `ai/code-style.md` | 非 Dart/Flutter 则替换为对应语言规范 |
| `ai/toolchain.md` | 替换为你的 SDK/工具链配置 |
| `ai/directory-structure.md` | 将 `lib/` 结构示例更新为你的项目结构 |
| `project/README.md` | 更新文件命名示例 |

其余模块均为方法论，与语言和技术栈无关，直接复用。

## 核心原则

1. **SPEC First** ——SPEC 不批准 = 不写代码
2. **先想再写** ——呈现假设、权衡和替代方案
3. **简洁优先** ——最小代码量，不过度抽象
4. **外科手术式修改** ——只改必须改的，匹配已有风格
5. **目标驱动** ——定义验收标准，循环直到通过
6. **中文优先** ——注释和提交信息用中文
7. **上下文感知** ——从实际文件获取信息，不猜测

详见：[`docs/ai/principles.md`](docs/ai/principles.md)

## 许可

MIT
