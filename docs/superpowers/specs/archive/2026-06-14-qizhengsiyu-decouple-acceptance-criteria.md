# 验收标准 — QiZhengSiYu UI/MVVM/UseCase/Repository 解耦迁移

- **Date:** 2026-06-14
- **Branch:** `refactor/qizhengsiyu-decouple-mvvm-usecase-repository`
- **配套测试方案:** `docs/superpowers/plans/2026-06-14-qizhengsiyu-decouple-test-plan.md`
- **OpenSpec 来源:** `openspec/changes/decouple-qizhengsiyu-ui-mvvm-usecase-repository/spec.md`
- **本文档是门禁**：每条标准给「验证命令 / 期望输出 / 阶段 / 证据」，可机检。

---

## 0. 全局 Definition of Done（Q6 门禁）

迁移整体被判定 DONE 当且仅当全部满足：

1. 9 条边界扫描（A1 修订后的广义正则）干净，或剩余项在 `baseline-manifest.md` 有显式批准。
2. 触碰文件零新增 `flutter analyze` 问题（对 Q0 基线增量为 0）。
3. 业务 fixture 输出与 Q0 golden 一致（除显式批准的 behavior change）。
4. 接口包 `dart pub get && dart test` 通过（A2 运行门禁）。
5. Q4.3a 分类后：每个 must-sync/derived-compatible 字段有 pre/post 等价断言并通过；每个 retire-after-Q4/internal-only 字段有 no-consumer 证据断言并通过。
6. 测试方案中每个 Q-phase 的 `Q{n} evidence`（go/no-go）已产出并登记。
7. gStack Eng Review 复跑无 P1 未决。

---

## 1. 需求编号（canonical，对齐 spec.md）

| ID | spec.md Requirement |
|---|---|
| R1 | UI depends only on ViewModel state and intents |
| R2 | ViewModels delegate business work to UseCases |
| R3 | UseCases depend on repository-interface ports or pure domain services |
| R4 | Official assets are modeled as repository-interface ports |
| R5 | Repository-interface package remains pure Dart |
| R6 | Composition root constructs concrete storage once |
| R7 | Migration preserves business behavior |
| R8 | Domain does not depend on data-layer implementations |
| R9 | Main-pan legacy compatibility fields remain equivalent |
| DR1 | （design.md 层规则，非 spec ADDED）Domain has no Flutter dependency for business logic |

---

## 2. 逐需求验收

> 命令默认在 `xuan-qizhengsiyu/` 根执行；`(^\|/)data/` 为 A1 修订后的广义 data 正则。

### R1 — UI 仅依赖 ViewModel state/intents
- **验证:** `flutter test test/architecture/ui_boundary_test.dart`；扫描 `rg -n "(^|/)data/|rootBundle|persistence_drift|persistence_assets|AppDatabase|QiZhengSiYuPanRepository|ShenShaRepositoryImpl|HuaYaoRepositoryImpl|LocalDataSourceImpl|SaveCalculatedPanelUseCase\(|CalculateFateDongWeiUseCase\(" lib/presentation lib/controllers lib/navigator.dart`
- **期望:** 测试 pass；扫描匹配 ⊆ baseline allow-list（Q5 起新增 = 0）。
- **阶段:** Q0(建测)→Q4/Q5(达标)。**证据:** `____`

### R2 — ViewModel 委托 UseCase，无 data 实现 import
- **验证:** `flutter test test/architecture/viewmodel_boundary_test.dart`；扫描 `rg -n "(^|/)data/|rootBundle|persistence_drift|persistence_assets|AppDatabase|RepositoryImpl|LocalDataSourceImpl|package:flutter/services.dart" lib/presentation/viewmodels lib/presentation/pages/beauty_page_viewmodel.dart`
- **期望:** 0 匹配（baseline 之外）。
- **阶段:** Q4。**证据:** `____`

### R3 — UseCase 仅依赖端口/纯域服务
- **验证:** `flutter test test/architecture/usecase_boundary_test.dart`；扫描 `rg -n "package:flutter/(material|widgets|services|rendering)\.dart|presentation/|pages/|widgets/|BuildContext|rootBundle|AppDatabase|RepositoryImpl|LocalDataSourceImpl|(^|/)data/" lib/domain/usecases`
- **期望:** 0 匹配。**特别**：`save_calculated_panel_usecase.dart` 不再 import `package:flutter/rendering.dart` 与 `data/contract_mappers/`（A1）。
- **阶段:** Q3。**证据:** `____`

### R4 — 官方资产建模为端口
- **验证:** `flutter test test/domain/ports/`（4 个端口契约）+ `cd ../xuan-storage/assets && flutter test`
- **期望:** 4 个端口（StarPositionStatus / HistoricalEphemeris / EphemerisResource / ZhouTianModel）fake 与 assets adapter 往返一致；domain 不再 `rootBundle.loadString` 官方数据。
- **阶段:** Q2(建端口)→Q5(域接入)。**证据:** `____`

### R5 — 接口包纯 Dart（A2 运行门禁）
- **验证:** ① `rg -n "flutter:|sdk: flutter|package:flutter|package:qizhengsiyu/" ../repository-interface-qizhengsiyu/pubspec.yaml ../repository-interface-qizhengsiyu/lib` → 0 匹配；② `cd ../repository-interface-qizhengsiyu && dart pub get && dart test` → pass。
- **期望:** 两者皆满足。**前置 Q2.0**：删除接口包 pubspec 中**未使用的** `metaphysics_core` 依赖（`lib` import 0 次）+ 去 `flutter: sdk: flutter` + `flutter_test`→`test`。**不修改 `metaphysics_core`**（净化它出范围：有直接 `package:flutter` import，被 ~15 兄弟包依赖）。
- **阶段:** Q2.0→Q2.1。**证据:** `____`

### R6 — 组合根单次构造
- **验证:** `flutter test test/presentation/provider_bootstrap_test.dart test/presentation/composition_root_test.dart`
- **期望:** `createProviders(fakeDeps)` 不触碰 asset/DB；`/qizhengsiyu/panel` 与 GeJu 路由读取同一 deps 实例（identity 相等）；8 个原构造点收敛为 1（route-local 例外有文档化理由）。
- **阶段:** Q1。**证据:** `____`

### R7 — 行为保持
- **验证:** `flutter test test/domain/fixtures/ test/domain/usecases/calculate_base_panel_usecase_test.dart test/presentation/qi_zheng_si_yu_viewmodel_characterization_test.dart`
- **期望:** 每阶段产物与 Q0 golden 一致；不一致即阻塞（除批准的 behavior change）。
- **阶段:** Q0→Q6 每阶段。**证据:** `____`

### R8 — Domain 不依赖 data 层（含 A1 广义扫描）
- **验证:** `flutter test test/architecture/domain_to_data_test.dart`；扫描 `rg -n "(^|/)data/|LocalDataSource|RepositoryImpl|SystemDefinitionLocalDataSource" lib/domain`
- **期望:** 0 匹配（除 `lib/domain` 外显式批准的过渡适配器）。`historical_engine.dart` 不再 import `SystemDefinitionLocalDataSource`；A3 重复接口已对账。
- **阶段:** Q3→Q5。**证据:** `____`

### R9 — 主盘遗留字段等价 / 退役证据
- **验证:** `flutter test test/presentation/qi_zheng_si_yu_viewmodel_equivalence_test.dart test/architecture/retire_after_q4_consumer_scan_test.dart`
- **期望（按 Q4.3a 分类，二选一，无第三态）:**
  - **must-sync / derived-compatible** → 每个字段 ≥1 条 pre/post 等价断言通过；`*Notifier`/`*Listenable` 额外断言通知/重建语义。
  - **retire-after-Q4 / internal-only** → **不写等价测试**；改为 consumer-scan 证据断言：字段名在 `lib/presentation`+`lib/controllers` 无剩余 UI 消费者（Q5 清理前必须为空）。
- **阶段:** Q4（分类 + 测试）→ Q5（按证据清理）。**证据:** `____`

### DR1 — Domain 无 Flutter 业务依赖
- **验证:** `flutter test test/architecture/domain_flutter_deny_test.dart`；扫描 `rg -n "package:flutter/(services|foundation|rendering|material|widgets)\.dart|rootBundle" lib/domain`
- **期望:** 0 匹配（除文档化 UI-only 文件）。
- **阶段:** Q5。**证据:** `____`

---

## 3. 追溯矩阵（Requirement ↔ Test ↔ Task ↔ 扫描 ↔ Phase）

| Req | 主要 Test ID | tasks.md | 边界扫描 | Phase |
|---|---|---|---|---|
| R1 | T-Q0-ARCH-01, T-Q0-GEJU-01, T-Q5-GEJU-01 | Q0.7,0.11,Q5.5 | UI deny-list | Q0→Q5 |
| R2 | T-Q4-VM-01, T-Q4-VM-02, T-Q4-BEAUTY-01 | Q4.4-4.8 | ViewModel deny-list | Q4 |
| R3 | T-Q0-SAVE-01, T-Q3-UC-05, T-Q3-NEG-01 | Q0.10,Q3.5,Q3.7 | UseCase deny-list | Q0,Q3 |
| R4 | T-Q2-PORT-01..04, T-Q2-ASSET-01, T-Q5-ENGINE/BUILDER/ZHOU | Q2.2-2.8,Q5.1-5.4 | — | Q2,Q5 |
| R5 | T-Q2-PURITY-01, T-Q2-EXPORT-01 | Q2.0,2.1,2.6,2.7 | interface 纯度 + `dart test` | Q2.0,Q2.1 |
| R6 | T-Q0-BOOT-01, T-Q1-ROOT-01/02 | Q0.9,Q1.1-1.5 | storage 反向依赖 | Q0,Q1 |
| R7 | T-Q0-FIX-01, T-Q0-PAN-01, T-Q3-UC-02 | Q0.12,Q3.2 | — | Q0→Q6 |
| R8 | T-Q3-INJ-03, T-Q3-ARCH-02, T-Q5-ARCH-02 | Q3.0c,3.9,Q5.9 | domain-to-data（广义） | Q3→Q5 |
| R9 | T-Q4-STATE-01, T-Q4-EQUIV-* (must-sync/derived), T-Q4-RETIRE-* (retire/internal) | Q4.1-4.3c,4.9 | retire-after-Q4 consumer-scan | Q4→Q5 |
| DR1 | T-Q5-ARCH-01 | Q5.6,5.8 | domain Flutter deny | Q5 |

三向闭环：每条 Req 有 Test、每个 Test 回指 Req + Task、每个 Phase 有验收门。

---

## 4. Q4 等价性矩阵（20 字段 × 策略）

策略：**must-sync**=新 `QiZhengPanUiState`/`QiZhengPanDisplayState` 必须值完全等价；**derived-compatible**=可由新 state 派生，但须与 Q0 fixture 行为一致；**retire-after-Q4**=Q5 清理前 UI 消费者须先迁移。每个 must-sync/derived 字段至少 1 条 pre/post 对比断言（同 fixture）。

> **P2-2 修订 — notifier/listenable 是「重建契约」，非仅「值契约」。** 已核验真实消费者：`uiBasePanelListenable` 传入 `QiZhengPanelController`（`beauty_view_page.dart:291`）；ZhouTian notifier 经 `ValueListenableBuilder`（`beauty_view_page.dart:856`）；`geJuSummaryNotifier` 经 `ValueListenableBuilder`（`ge_ju_result_panel.dart:48`）；`birthRiseSetNotifier`/`customRiseSetNotifier` 经 `ValueListenableBuilder`（`rise_set_info_panel.dart:46`）。因此凡 `*Notifier`/`*Listenable` 字段的等价测试**必须断言「值变化时监听者被通知 / builder 重建」**，不能只比深相等——一个每次都 new 出相等值但破坏 `==`/identity 的实现会让 `ValueListenableBuilder` 误重建或漏重建，深相等测试照样绿。
>
> **测试分配规则（按 Q4.3a 分类）：** 等价测试**只**为 must-sync / derived-compatible 字段写。retire-after-Q4 / internal-only 字段**不**写等价测试，改为 consumer-scan 证据断言（字段名在 `lib/presentation`+`lib/controllers` 零剩余消费者），作为 Q5 安全清理的前置证据。下表「建议策略」列在 Q4.3a 定稿后即决定每字段走哪条。

| # | 字段 | 建议策略 | 等价断言要点 |
|---|---|---|---|
| 1 | `basicLifePanel` | must-sync | panel model 深相等 |
| 2 | `uiBasicLifeStars` | derived-compatible | 星列表派生自 DisplayState |
| 3 | `uiFateLifeStars` | derived-compatible | 同上（命主） |
| 4 | `uiZhouTianModelNotifier` | must-sync | 模型 id/值相等 |
| 5 | `uiBasePanelNotifier` | must-sync | base panel 通知值相等 |
| 6 | `uiBasePanelListenable` | derived-compatible | 监听对象暴露同值 |
| 7 | `uiDaXianPanelNotifier` | must-sync | 大限 panel 相等 |
| 8 | `uiBasicLifeStarsNotifier` | must-sync | 通知值相等 |
| 9 | `uiBasicLifeStarsListenable` | derived-compatible | 同 #8 暴露 |
| 10 | `uiFateLifeStarsNotifier` | must-sync | 通知值相等 |
| 11 | `uiFateLifeStarsListenable` | derived-compatible | 同 #10 暴露 |
| 12 | `baseObserverPositionNotifier` | must-sync | 观测点位置相等 |
| 13 | `geJuSummaryNotifier` | must-sync | GeJu 摘要相等 |
| 14 | `birthRiseSetNotifier` | must-sync | 生时升降相等 |
| 15 | `customRiseSetNotifier` | must-sync | 自定义升降相等 |
| 16 | `lunarDateInfoNotifier` | must-sync | 农历信息相等 |
| 17 | `yunLiuViewModel` | derived-compatible | 运流子 VM 派生一致 |
| 18 | `birthLocationName` | derived-compatible | 地名字符串一致 |
| 19 | `daXianMapper` | derived-compatible | 映射函数输出一致 |
| 20 | `lifeObserver` / `fateObserver` | must-sync | 观测者对象相等 |

> 策略列为**建议**；Q4.3a 须基于 `baseline-manifest.md` 列出每字段的真实 UI 消费者后定稿。任一 must-sync/derived 缺断言 → Stop-the-line。

---

## 5. 边界扫描验收（9 条，A1 修订）

| # | 扫描 | 修订点 | 阈值 |
|---|---|---|---|
| 1 | UI deny-list | data 项 → `(^\|/)data/` | baseline 之外 0 |
| 2 | ViewModel deny-list | 同上 | baseline 之外 0 |
| 3 | UseCase deny-list | 同上（捕获 `data/contract_mappers`） | 0 |
| 4 | Domain Flutter deny-list | 不变 | 0（除 UI-only 文档化） |
| 5 | Domain data-layer deny-list | data 项 → `(^\|/)data/` | 0（除批准过渡） |
| 6 | 接口包纯度扫描 | + `dart test` 运行门禁 | 0 + dart test pass |
| 7 | storage 反向依赖扫描 | 不变 | 0 |
| 8 | A1 自证（usecase contract_mappers） | 新增 | 修复前红→修复后绿 |
| 9 | 8 个 createProviders 站点收敛 | 新增 | 收敛为 1（例外文档化） |

每条扫描在 `test/architecture/` 有 Dart 包装测试，可随 `flutter test` 跑，不止 shell。

---

## 6. 证据归档

每阶段 go/no-go 证据写入 `openspec/changes/decouple-qizhengsiyu-ui-mvvm-usecase-repository/`（如 `q{n}-evidence.md`），并回填本文档 §2 「证据」列与 §3 矩阵。Q6 汇总后归档 OpenSpec 变更。
