# project/ 目录说明

此目录存放与项目本身相关的文档，**不含任何 AI 内部工件**。

## 目录结构

```
project/
  prds/           ← 产品需求文档 (PRD)
  features/       ← 功能规格说明（非 AI SPEC）
  architecture/   ← 架构决策记录 (ADR)
  changelog/      ← 版本发布日志
```

## 文件命名规范

| 类型 | 格式 | 示例 |
|------|------|------|
| PRD | `YYYY-MM-DD-<short-name>-PRD.md` | `2026-05-08-用户认证系统-PRD.md` |
| 功能说明 | `YYYY-MM-DD-<short-name>-功能说明.md` | `2026-05-01-用户认证系统-功能说明.md` |
| ADR | `NNN-<short-name>.md` | `001-选择-Drift-作为本地数据库.md` |
| Changelog | `vX.Y.Z.md` | `v0.1.0.md` |

## 与 AI SPEC 的区别

- `docs/project/` → 项目需求/架构/规划，由"人"维护，面向全体
- `docs/<ai>/features/.../specs/` → 单个 AI 的 SPEC 设计文档，AI 生成，面向本任务
- `docs/<ai>/features/.../plans/` → 单个 AI 的实现计划，AI 生成，面向本任务
