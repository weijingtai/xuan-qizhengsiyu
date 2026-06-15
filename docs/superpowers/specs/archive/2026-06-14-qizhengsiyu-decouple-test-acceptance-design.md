# Design: QiZhengSiYu Decouple — 测试方案与验收标准蓝图

- **Date:** 2026-06-14
- **Branch:** `refactor/qizhengsiyu-decouple-mvvm-usecase-repository`
- **Scope:** 仅文档。产出「测试方案」与「验收标准」两份规划件，硬化既有 OpenSpec 迁移方案。**不修改任何 `lib/` 或 `test/` 生产代码**（严守 OpenSpec Q0「先冻结再迁移」纪律）。
- **Reviewed by:** gStack Eng Review（`plan-eng-review`），3 项发现已并入。

## 1. 问题与目标

OpenSpec 变更 `decouple-qizhengsiyu-ui-mvvm-usecase-repository` 已有 `proposal.md` / `design.md` / `tasks.md` / `spec.md`，但：

- `tasks.md` 只在**任务粒度**列出「add tests for X」，没有可执行的测试设计（文件、用例、断言、fixture）。
- `spec.md` 有 GIVEN/WHEN/THEN 场景，但没有独立、可度量的**验收标准**文档（命令 + 期望输出 + 追溯）。
- `design.md` 引用的测试目录 `test/architecture`、`test/domain/usecases`、`test/presentation` **尚不存在**（当前仅 `test/domain/` 与 `test/domain/fixtures/`）。

目标：把高层任务与场景落成 **(a) 按阶段索引的测试方案**、**(b) 按需求索引 + 追溯矩阵的验收标准**，使整套迁移在动代码前就有可机检的「行为冻结 + 边界守卫 + 等价回归」骨架定义。

## 2. 关键决策（已与用户确认）

| 维度 | 决定 |
|---|---|
| 范围 | 仅文档：测试方案 + 验收标准；不碰生产/测试代码 |
| 评审镜头 | 仅 gStack Eng Review |
| 文件位置 | 专用 refactor 分支；文档置于 `docs/superpowers/` |
| 文档结构 | 方案 C（测试方案按阶段索引；验收按需求索引 + 追溯矩阵） |
| 纪律 | 严守 Q0「先冻结再迁移」 |

> `docs/` 是 `weijingtai/docs` 的 pull-only subtree。本地工件随本仓库 commit，**绝不** `git subtree push` 到上游；项目已在 `docs/superpowers/plans|specs/` 沉淀本地工件，沿用既定模式。

## 3. 产出文件

| 文件 | 角色 |
|---|---|
| `docs/superpowers/specs/2026-06-14-qizhengsiyu-decouple-test-acceptance-design.md` | 本蓝图（决策 + 评审发现） |
| `docs/superpowers/plans/2026-06-14-qizhengsiyu-decouple-test-plan.md` | 产出①：测试方案（Q0–Q6 阶段索引） |
| `docs/superpowers/specs/2026-06-14-qizhengsiyu-decouple-acceptance-criteria.md` | 产出②：验收标准（需求索引 + 追溯矩阵） |

OpenSpec 衔接：可选地在 `openspec/changes/.../tasks.md` 顶部加一行指针回链这两份文档（不改其余内容）。

## 4. Eng Review 发现（已并入，附 file:line 证据）

### 已验证可行（无需变更）
- 20 个 Q4 遗留字段全部存在于 `lib/presentation/viewmodels/qi_zheng_si_yu_viewmodel.dart` → 等价矩阵（Q4.3b）可建。
- Provider 构造点共 8 处：`lib/navigator.dart` ×7 + `lib/main.dart:45` ×1 → Q1 重复作用域问题真实存在。
- `lib/domain/usecases/save_calculated_panel_usecase.dart:3` import `package:flutter/rendering.dart` → Q3.5 真实。
- `example/assets/qizhengsiyu/star_position_status.json` 存在；`repository-interface-qizhengsiyu`、`xuan-storage/{assets,drift}` 兄弟包齐备。

### A1 (P1) — 边界扫描有洞，会放过真实违规
`save_calculated_panel_usecase.dart:7` import `../../data/contract_mappers/qizhengsiyu_contract_mappers.dart`（usecase→data 真实依赖）。`design.md` 的 UseCase deny-list 与 domain-to-data deny-list 仅枚举 `data/datasources|data/repositories`，**`data/contract_mappers/` 今天能通过两条扫描**。
- **修订：** 所有边界扫描的 data 项改为广义 `(^|/)data/`。
- **副产物：** `SaveCalculatedPanelUseCase` 对 contract_mappers 的依赖是一个此前未登记的清理目标。

### A2 (P1) — 「接口包纯 Dart」会偺绿
`repository-interface-qizhengsiyu/lib` 自身 0 个 `package:flutter` import（好），但它依赖 `metaphysics_core`，后者 pubspec 拉取 `flutter_timezone: ^5.0.1` 与 `google_fonts: ^6.2.1`（均 Flutter 包）。`design.md` 的纯度正则扫描会**绿**，而包内 `dart test` 仍会传递性拖入 Flutter。
- **决策（用户选定）：** 验收 = 源码扫描绿 **且** `cd ../repository-interface-qizhengsiyu && dart pub get && dart test` 通过（纯 Dart，非 `flutter test`）。
- **衍生前置任务 Q2.0（已纠正范围）：** 经核验，repository-interface 的 `lib` import `metaphysics_core` **0 次**——它是 pubspec 里的**死依赖**。因此 Q2.0 = 仅删除接口包 pubspec 中未使用的 `metaphysics_core` 依赖 + 去掉 `flutter: sdk: flutter` + `flutter_test`→`test`，使包可跑纯 Dart `dart test`。**不修改 `metaphysics_core` 本身**。
- **明确排除：** 净化 `metaphysics_core` 出范围。它有直接 `package:flutter` import（`template_preset.dart:1`、`five_elements_colors.dart:1`、`day_pillar_strategy.dart:1`）且被约 15 个兄弟包依赖，属独立的上游包重构，需自带受影响包验证。

### A3 (medium) — 两个 `IQiZhengSiYuPanRepository`
接口包 `repository-interface-qizhengsiyu/lib/src/repositories/qizhengsiyu_ports.dart:24`（`SaveCalculatedPanelUseCase` 已正确使用此版本）与 data 层 `lib/data/repositories/interfaces/i_qizhengsiyu_pan_repository.dart` 并存。
- **修订：** 测试方案 Q0.10 的 fake 锁定为**接口包**版本；data 层重复件列为 Q5 清理 TODO，否则 domain-to-data 扫描语义含混。

## 5. 自检（Spec Self-Review）

- Placeholder：无 TBD/TODO 占位。
- 一致性：A1/A2/A3 在三份文件中表述一致（扫描正则、`dart test` 门禁、fake 目标）。
- 范围：单一可执行规划单元（文档），不含代码改动。
- 歧义：「纯 Dart」「边界干净」「等价」均给出可机检定义。

## 6. 后续

本蓝图 + 两份产出物落盘后，实际重构按 OpenSpec Q0→Q6 在本分支推进；每阶段以本测试方案为实现清单、以本验收标准为门禁。
