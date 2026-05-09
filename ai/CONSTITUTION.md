# 宪法版本清单

> AI MUST NOT 修改此文件。此文件由人通过 SPEC Coding 流程维护。
> 当前宪法体系 12 模块的版本矩阵与修订历史。

## 当前版本矩阵

| 模块 | 当前版本 | 最后修订日期 | 修订人 |
|------|---------|-------------|--------|
| AI_README.md | 1.0.0 | 2026-05-08 | wjt |
| CONSTITUTION.md | 1.0.0 | 2026-05-08 | wjt |
| board-protocol.md | 1.0.0 | 2026-05-08 | wjt |
| glossary.md | 1.0.0 | 2026-05-08 | wjt |
| principles.md | 1.0.0 | 2026-05-08 | wjt |
| phases.md | 1.0.0 | 2026-05-08 | wjt |
| delivery-pipeline.md | 1.0.0 | 2026-05-08 | wjt |
| code-style.md | 1.0.0 | 2026-05-08 | wjt |
| directory-structure.md | 1.0.0 | 2026-05-08 | wjt |
| git-rules.md | 1.0.0 | 2026-05-08 | wjt |
| doc-standards.md | 1.0.0 | 2026-05-08 | wjt |
| toolchain.md | 1.0.0 | 2026-05-08 | wjt |
| project-context-guide.md | 1.0.0 | 2026-05-08 | wjt |

## SemVer 规则

- **MAJOR (X):** 删除规则、新增硬门禁、改变行为后果 → 不向后兼容
- **MINOR (Y):** 新增规则/阶段/建议、扩展细则
- **PATCH (Z):** 措辞修正、示例更新、拼写修复

## 修订历史

| 日期 | 模块 | 旧版本 | 新版本 | 变更摘要 |
|------|------|--------|--------|---------|
| 2026-05-08 | 全部 13 项 | — | 1.0.0 | 初始创建：AI 协同宪法体系完整交付 |

## 兼容性

AI 在任务中途（SPEC 锁定后）如果宪法版本升级：

- **PATCH 升级:** MAY 继续，无需变更当前任务
- **MINOR 升级:** SHOULD 评估是否影响当前任务，向用户报告
- **MAJOR 升级:** MUST 暂停，向用户报告变更内容，等待用户决定是否继续

MUST NOT: 修改宪法而不更新本版本清单
MUST: 宪法修改 MUST 走 SPEC Coding 流程
