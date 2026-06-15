# 测试方案 — QiZhengSiYu UI/MVVM/UseCase/Repository 解耦迁移

- **Date:** 2026-06-14
- **Branch:** `refactor/qizhengsiyu-decouple-mvvm-usecase-repository`
- **配套验收标准:** `docs/superpowers/specs/2026-06-14-qizhengsiyu-decouple-acceptance-criteria.md`
- **OpenSpec 来源:** `openspec/changes/decouple-qizhengsiyu-ui-mvvm-usecase-repository/{design,tasks,spec}.md`
- **范围:** 本文档定义**测试设计**。实现按 OpenSpec Q0→Q6 在本分支推进；本文档是每阶段的实现清单。

---

## 0. 测试约定（Conventions）

### 0.1 五类测试 taxonomy

| 类型 | 缩写 | 目的 | 框架 |
|---|---|---|---|
| 表征/黄金测试 | CHAR/FIX | 迁移前冻结行为，输出存为 golden，跨阶段回归比对 | `flutter_test` |
| 架构边界测试 | ARCH | Dart 测试 + shell 扫描，命中禁用 import/依赖即失败 | `flutter_test` + `rg` |
| UseCase 单测 | UC | 用 fake ports 驱动应用动作，确定性输入 | `flutter_test` |
| Provider/Widget 测试 | BOOT/WIDGET | createProviders、路由 provider 图、widget 渲染 | `flutter_test` |
| 等价性测试 | EQUIV | Q4 遗留 notifier/getter ↔ 新 state 值相等 | `flutter_test` |

### 0.2 待建测试目录（由实现阶段创建，本文档仅定义）

```
test/
  architecture/        # ARCH 边界测试 + 扫描包装
  domain/
    usecases/          # UC 单测
    fixtures/          # CHAR/FIX 黄金 (已起头: base_panel_fixture_test.dart)
      data/            # golden JSON 输入/期望输出
  presentation/        # BOOT/WIDGET/EQUIV
  fakes/               # fake ports + fake QiZhengSiYuStorageDependencies
```

### 0.3 Fixture 策略

- 确定性输入（固定生辰/经纬/时区），禁用任何 `DateTime.now()`/随机源。
- Q0 捕获 golden 输出到 `test/domain/fixtures/data/`，作为后续所有阶段的**行为基线**。
- 任何阶段若改变 golden，必须显式标注为「approved behavior change」，否则视为回归（阻塞）。

### 0.4 命名与映射

- Test ID 格式 `T-Q{phase}-{TYPE}-{nn}`，每条标注映射的 `tasks.md` 任务号与覆盖的 `spec.md` Requirement（R1–R9 + DR1，见验收标准文档编号）。
- Fake ports 统一置于 `test/fakes/`，可被多阶段复用。

### 0.5 已知风险/前置债务（不可静默）

- **Q3 阻塞链**（已对代码验证）：`zhou_tian_model_manager.dart:16-18` 单例 + `:71` rootBundle；`calculation_engine_factory.dart:11` 静态 create；`historical_engine.dart:3-4,17-19,33` flutter/services + data 层 + rootBundle。Q3 必须先打注入缝。
- **既有失败测试**：`dev_stars_test.dart`、`star_enter_info_calculator_test.dart` 预先存在失败（非本次引入）。Q0 必须记录基线，后续仅对触碰文件证明「无新增失败」。
- **`flutter analyze` 既有债务**：Q0 记录精确基线，后续阶段对触碰文件证明零新增问题。
- **A2 接口包传递性 Flutter**：见 Q2.0。

---

## 1. 逐阶段测试设计

### Q0 · 基线与表征冻结

> Entry: 非 main/master 分支；未编辑生产迁移代码。

| Test ID | 文件 | 类型 | Task | 覆盖 | 关键断言 |
|---|---|---|---|---|---|
| T-Q0-ARCH-01 | `test/architecture/ui_boundary_test.dart` | ARCH | Q0.7 | R1 | `lib/presentation`+`lib/controllers`+`navigator.dart` 新增 `(^\|/)data/`、`rootBundle`、`persistence_drift\|assets`、`*RepositoryImpl`、`*LocalDataSourceImpl` import → 失败（baseline allow-list 之外） |
| T-Q0-FAKE-01 | `test/fakes/fake_storage_dependencies.dart` | FAKE | Q0.8 | R6 | `QiZhengSiYuStorageDependencies` 所有现有端口可被 fake 实例化（无并发 DB/asset） |
| T-Q0-BOOT-01 | `test/presentation/provider_bootstrap_test.dart` | BOOT | Q0.9 | R6 | `createProviders(fakeDeps)` 构建成功且不触碰 asset/DB（fake 计数器为 0 次 IO） |
| T-Q0-SAVE-01 | `test/domain/usecases/save_calculated_panel_usecase_test.dart` | UC | Q0.10 | R3 | save/update/delete 调用 **接口包** `IQiZhengSiYuPanRepository`（fake）；记录当前 update 返回值行为（Q3.5 待修正点的冻结快照） |
| T-Q0-GEJU-01 | `test/presentation/ge_ju_viewmodel_characterization_test.dart` | CHAR | Q0.11 | R1 | GeJu list load / refresh / create-edit init / school load 状态稳定（经 adapter） |
| T-Q0-PAN-01 | `test/presentation/qi_zheng_si_yu_viewmodel_characterization_test.dart` | CHAR | Q0.12 | R7 | 初始态 / calculate 失败路径 / dispose / 官方数据加载错误处理 |
| T-Q0-FIX-01 | `test/domain/fixtures/base_panel_fixture_test.dart`（已起头） | FIX | — | R7 | base panel 输出锁定为 golden（确定性 fixture） |
| (制品) | `openspec/changes/.../baseline-manifest.md` | doc | Q0.1-0.6b | R7 | 记录分支/git status/路由表/8 个 createProviders 站点/`flutter analyze`+`flutter test` 基线/9 条扫描现状 allow-list/Q3 三阻塞 |

> Exit: 既有违规冻结进 allow-list；上述测试保护 bootstrap/fake ports/SaveUseCase/GeJu/主盘 VM；未迁移任何生产行为。
> Stop-the-line: 无法实例化 fake 依赖包；无法描述 provider 作用域；analyzer/test 基线未记录。

### Q1 · 单一组合根

| Test ID | 文件 | 类型 | Task | 覆盖 | 关键断言 |
|---|---|---|---|---|---|
| T-Q1-ROOT-01 | `test/presentation/composition_root_test.dart` | BOOT/WIDGET | Q1.5 | R6 | `/qizhengsiyu/panel` 与各 GeJu 路由读取**同一** `QiZhengSiYuStorageDependencies` 实例（identity 相等） |
| T-Q1-ROOT-02 | 同上 | WIDGET | Q1.3-1.4 | R6 | 移除重复 route-level `createProviders` 后，路由仍能取到所需 ViewModel provider；保留的 route-local provider 每个有文档化理由 |
| (回归) | T-Q0-BOOT-01 / T-Q0-GEJU-01 复跑 | — | Q1.6 | — | bootstrap 与 GeJu 路由不回归 |

> Stop-the-line: 任一路由丢失所需 provider；原 app-scope 状态变成 route-local。

### Q2 · 接口与官方资产边界

> **Q2.0（A2 前置，已纠正范围）**：repository-interface 的 `lib` import `metaphysics_core` 0 次（死依赖）。Q2.0 = 删除接口包 pubspec 中未使用的 `metaphysics_core` 依赖 + 去 `flutter: sdk: flutter` + `flutter_test`→`test`，使包可跑纯 Dart `dart test`。**不碰 `metaphysics_core`**（它有直接 `package:flutter` import 且被 ~15 包依赖，净化属独立上游重构，出范围）。

| Test ID | 文件 | 类型 | Task | 覆盖 | 关键断言 |
|---|---|---|---|---|---|
| T-Q2-PURITY-01 | `../repository-interface-qizhengsiyu/test/purity_test.dart` + CI 脚本 | ARCH | Q2.0/Q2.1/Q2.7 | R5 | 源码扫描无 `flutter:\|sdk: flutter\|package:flutter\|package:qizhengsiyu/` **且** `dart pub get && dart test` 通过（纯 Dart 运行门禁，非 flutter test） |
| T-Q2-PORT-01 | `test/domain/ports/star_position_status_port_test.dart` | UC/ARCH | Q2.2 | R4 | `QiZhengStarPositionStatusRepository` 契约：fake + assets adapter 往返一致（对 `star_position_status.json`） |
| T-Q2-PORT-02 | `test/domain/ports/historical_ephemeris_port_test.dart` | UC/ARCH | Q2.3 | R4 | `QiZhengHistoricalEphemerisRepository` 契约（`sun_speeds.json`） |
| T-Q2-PORT-03 | `test/domain/ports/ephemeris_resource_port_test.dart` | UC/ARCH | Q2.4 | R4 | `QiZhengEphemerisResourceRepository` 契约（Sweph 资源） |
| T-Q2-PORT-04 | `test/domain/ports/zhou_tian_model_port_test.dart` | UC/ARCH | Q2.5 | R4 | `QiZhengZhouTianModelRepository` 契约（ZhouTian 模型文件） |
| T-Q2-EXPORT-01 | `../repository-interface-qizhengsiyu/test/exports_test.dart` | ARCH | Q2.6 | R5 | 4 个新端口/契约从 `repository_interface_qizhengsiyu.dart` 正确导出 |
| T-Q2-ASSET-01 | `../xuan-storage/assets/test/qizhengsiyu_assets_test.dart` | UC | Q2.8 | R4 | assets 适配器实现 4 个新端口，从真实资产读出非空类型化数据 |
| T-Q2-REVDEP-01 | `test/architecture/storage_reverse_dep_test.dart` | ARCH | Q2.12 | R5 | `xuan-storage/{assets,drift}/lib` 无 `presentation/\|pages/\|widgets/\|ViewModel\|BuildContext` |

> Stop-the-line: 接口包必须依赖 Flutter 或 `qizhengsiyu`；新适配器需要 UI import；类型化契约无法无损表达官方数据。

### Q3 · 主盘 UseCase 层

| Test ID | 文件 | 类型 | Task | 覆盖 | 关键断言 |
|---|---|---|---|---|---|
| T-Q3-INJ-01 | `test/domain/managers/zhou_tian_model_manager_injectable_test.dart` | UC | Q3.0a/0d | R7 | 可用注入的 built-in models 或 `QiZhengZhouTianModelRepository` 构造实例；无 Flutter binding；`instance` 仅作过渡门面 |
| T-Q3-INJ-02 | `test/domain/engines/engine_provider_test.dart` | UC | Q3.0b/0d | R7 | 引擎选择经可注入 provider 或显式 `ICalculationEngine`；无静态硬构造 |
| T-Q3-INJ-03 | `test/domain/engines/historical_engine_injectable_test.dart` | UC | Q3.0c/0d | R8 | `HistoricalEngine` 注入 datasource + ephemeris；构造路径不含 `(^\|/)data/`、`rootBundle` |
| T-Q3-UC-01 | `test/domain/usecases/initialize_official_data_usecase_test.dart` | UC | Q3.1 | R4 | 经 ShenSha/HuaYao/ZhouTian/star-status/ephemeris/resource fake 端口初始化 |
| T-Q3-UC-02 | `test/domain/usecases/calculate_base_panel_usecase_test.dart` | UC | Q3.2 | R7 | 注入引擎 + ZhouTian 查找 + 星位计算 + base panel 生成，用 fake 内存数据；输出匹配 Q0 golden |
| T-Q3-UC-03 | `test/domain/usecases/evaluate_ge_ju_usecase_test.dart` | UC | Q3.3 | R1 | 经 `GeJuEvaluationService` 评估，无 UI 级 service 访问 |
| T-Q3-UC-04 | `test/domain/usecases/build_timeline_usecase_test.dart` | UC | Q3.4 | R7 | lunar date / YunLiu / DaXian / rise-set 显示数据 |
| T-Q3-UC-05 | `test/domain/usecases/save_calculated_panel_usecase_test.dart`（扩展 T-Q0-SAVE-01） | UC | Q3.5 | R3 | 移除 `package:flutter/rendering.dart`（:3）后行为不变；**update 成功返回 true**；**移除 A1 的 `data/contract_mappers` 依赖** |
| T-Q3-NEG-01 | `test/architecture/usecase_boundary_test.dart` | ARCH | Q3.7 | R3 | `lib/domain/usecases` 无 `package:flutter/(material\|widgets\|services\|rendering)`、`presentation/`、`pages/`、`widgets/`、`BuildContext`、`rootBundle`、`(^\|/)data/`、`*RepositoryImpl`、`*LocalDataSourceImpl`（**A1 修订：广义 data/**） |
| T-Q3-ARCH-02 | `test/architecture/domain_to_data_test.dart` | ARCH | Q3.9 | R8 | `lib/domain` 无 `(^\|/)data/`、`LocalDataSource`、`RepositoryImpl`、`SystemDefinitionLocalDataSource`（**A1 修订**），baseline 之外零匹配 |

> Stop-the-line: UseCase import Flutter UI/具体存储；三阻塞仍挡 fake-data 测试；`HistoricalEngine` 仍直接 import `SystemDefinitionLocalDataSource`；domain-to-data 扫描有新增/未决匹配；任何业务结果与 Q0 表征不符且未批准。

### Q4 · 主盘 ViewModel 迁移

| Test ID | 文件 | 类型 | Task | 覆盖 | 关键断言 |
|---|---|---|---|---|---|
| T-Q4-STATE-01 | `test/presentation/states/qi_zheng_pan_state_test.dart` | UC | Q4.1-4.3 | R7 | `QiZhengPanInputState` / `QiZhengPanUiState`(idle/loading/success/error) / `QiZhengPanDisplayState` 单元行为 |
| T-Q4-EQUIV-* | `test/presentation/qi_zheng_si_yu_viewmodel_equivalence_test.dart` | EQUIV | Q4.3b/4.9 | R9 | **仅** Q4.3a 标为 must-sync/derived-compatible 的字段，逐一：同 Q0 fixture 下，遗留 notifier/getter 值 == 新 state 派生值。**`*Notifier`/`*Listenable` 字段须额外断言通知/重建语义**（值变化时监听者被通知，经 `ValueListenableBuilder` 的 widget 重建），不止深相等。字段集由 Q4.3a 定稿（见验收文档 §4） |
| T-Q4-RETIRE-* | `test/architecture/retire_after_q4_consumer_scan_test.dart` | ARCH | Q4.3c/4.9 | R9 | **仅** Q4.3a 标为 retire-after-Q4/internal-only 的字段，逐一：consumer-scan 证据断言——该字段名在 `lib/presentation`+`lib/controllers` 无剩余 UI 消费者（清理前必须为空），证明可在 Q5 安全删除/停更，**不**为其写等价测试 |
| T-Q4-VM-01 | `test/presentation/qi_zheng_si_yu_viewmodel_usecase_wiring_test.dart` | CHAR | Q4.4-4.6 | R2 | VM 经 UseCase 完成 init/calculate/GeJu/timeline；遗留 ValueNotifier 作为兼容门面由新 state 回填 |
| T-Q4-VM-02 | `test/architecture/viewmodel_boundary_test.dart` | ARCH | Q4.5 | R2 | `viewmodels/**` + `beauty_page_viewmodel.dart` 无 `(^\|/)data/`、`rootBundle`、`*RepositoryImpl`、`*LocalDataSourceImpl`、`package:flutter/services.dart`（baseline 之外） |
| T-Q4-BEAUTY-01 | `test/presentation/beauty_page_viewmodel_test.dart` | CHAR | Q4.7-4.8 | R1/R2 | `BeautyPageViewModel` 委托给 VM/兼容门面；移除 `rootBundle.loadString` 与仓库构造 |
| (回归) | T-Q0-PAN-01 + 路由 smoke 复跑 | — | Q4.10 | — | 主盘路由可计算 Q0 fixture |

> Stop-the-line: 主盘路由无法计算已知 Q0 fixture；notifier 兼容破坏既有 widget；任一 must-sync/derived 字段缺等价断言；VM 仍 import data/repo 实现（baseline 之外）。

### Q5 · 纯净 domain 与遗留清理

| Test ID | 文件 | 类型 | Task | 覆盖 | 关键断言 |
|---|---|---|---|---|---|
| T-Q5-ENGINE-01 | `test/domain/engines/sweph_engine_injected_test.dart` | UC | Q5.1 | R4 | `SwephEngine` 经 UseCase/注入 provider 接收 `QiZhengEphemerisResourceRepository` 数据 |
| T-Q5-ENGINE-02 | `historical_engine_injectable_test.dart`（扩展） | UC | Q5.2 | R4 | `HistoricalEngine` 接收 `QiZhengHistoricalEphemerisRepository` 数据 |
| T-Q5-BUILDER-01 | `test/domain/builders/yuan_le_panel_builder_test.dart` | UC | Q5.3 | R4 | `YuanLePanelBuilder` 接收 `QiZhengStarPositionStatusRepository` 数据 |
| T-Q5-ZHOU-01 | `zhou_tian_model_manager_injectable_test.dart`（扩展） | UC | Q5.4 | R4 | `ZhouTianModelManager` 接收 `QiZhengZhouTianModelRepository` 数据 |
| T-Q5-GEJU-01 | `test/domain/managers/ge_ju_manager_test.dart` | UC | Q5.5 | R1 | `GeJuManager` asset 读取改走 `GeJuBuiltInDataSource` 或退役 |
| T-Q5-ARCH-01 | `test/architecture/domain_flutter_deny_test.dart` | ARCH | Q5.8 | DR1 | `lib/domain` 无 `package:flutter/(services\|foundation\|rendering\|material\|widgets)`、`rootBundle`；除文档化 UI-only 文件外零匹配 |
| T-Q5-ARCH-02 | `domain_to_data_test.dart`（复用 T-Q3-ARCH-02） | ARCH | Q5.9 | R8 | domain-to-data 广义扫描零匹配（除 `lib/domain` 外显式批准的过渡适配器） |
| (清理) | A3 重复接口 | — | Q5.7 | R8 | data 层 `i_qizhengsiyu_pan_repository.dart` 重复件退役/对账，确认无消费者 |

> Stop-the-line: domain 仍需 rootBundle；任何清理改变计算输出；测试/扫描无法证明边界分离。

### Q6 · 交付门禁

| 检查 | 文件/命令 | Task | 覆盖 |
|---|---|---|---|
| 全量聚合 | `flutter analyze` + `flutter test` + `test/architecture` + `test/domain/usecases` + `test/presentation` + 9 条扫描 + 接口包 `dart test` | Q6.1-6.4 | R1–R9 + DR1 |
| 代码评审 | gStack Eng Review 复跑，聚焦边界泄漏 / 行为漂移 / 弱测试 | Q6.5 | — |
| 归档 | OpenSpec 变更归档（实现+验证+评审证据齐全后） | Q6.6 | — |

---

## 2. 测试执行门禁（每阶段必跑）

```bash
# 产品包
flutter analyze
flutter test
flutter test test/architecture
flutter test test/domain/usecases
flutter test test/presentation
# 接口包纯度运行门禁 (Q2 起，A2)
( cd ../repository-interface-qizhengsiyu && dart pub get && dart test )
```

每阶段产出 `Q{n} evidence`（go/no-go），路径登记进验收标准文档的「证据路径」列。

## 3. 覆盖率目标

- 新增 UseCase / state / port：行为 + 边缘 + 错误路径（★★★）。
- 边界扫描：每条都有对应 ARCH 测试包装（不止 shell，CI 可跑）。
- Q4 等价：仅 must-sync/derived 字段（Q4.3a 定）每个 ≥1 条 pre/post 对比断言（notifier/listenable 加通知语义）；retire-after-Q4/internal-only 字段改为 no-consumer 证据断言，不写等价测试。
- 回归铁律：任何「原本可行、被 diff 破坏」的路径，立即补回归测试（最高优先级）。

## 4. A1 自证测试（证明门禁有效）

`T-Q3-NEG-01` 必须包含一条**针对 `data/contract_mappers/` 的断言**：在广义 `(^|/)data/` 正则下，`save_calculated_panel_usecase.dart` 当前对 contract_mappers 的依赖应被检出（修复前红 → 修复后绿）。这条断言同时验证「扫描洞已补」与「真实违规已清」。
