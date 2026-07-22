# 七政四余测试基线（pre-existing 失败固化的权威记录）

> ACT: `docs/launch-plan/pipeline-migration-m1-m5-act/01b-qizheng-test-baseline.yaml`
> 采集时间: 2026-07-22
> 基线 SHA: `fb9abc5cd43e153b8504355e1eb0c0049ad78376`

## 1. 执行命令

```bash
cd xuan-qizhengsiyu && flutter test
```

## 2. 结果摘要

| 指标 | 值 |
|---|---|
| 通过 | 643 |
| 跳过 | 11 |
| 失败 | 33 |
| exit code | 1 |

全部 11 个 skip 均为 Sweph native bindings not available in flutter test（非迁移相关）。

## 3. 失败清单

### 3.1 编译/加载失败（27 个）

根因：上游包已提交代码 import `package:repository_interface_divination_pipeline`，但该包的 `geo.dart`（提供 BirthPlace/ObservationPlace/GeoPoint 类型）从未提交入库（仅本地 untracked shim），fresh checkout 必然编译失败。另存在 calendar 包对 `EnumDatetimeType.politicalCenter` 未穷尽 switch，以及 `xuan-time-location` git 路径解析失败。

#### 根因类型 A：`repository_interface_divination_pipeline` 包未解析

```
../xuan-metaphysics-core/lib/domain/calculators/four_zhu/four_zhu_engine.dart:2:8: Error: Not found: 'package:repository_interface_divination_pipeline/repository_interface_divination_pipeline.dart'
../xuan-storage/core/lib/time_location/daos/location_preference_dao.dart:2:8: Error: Not found: 'package:repository_interface_divination_pipeline/geo.dart'
```

以下 26 个测试文件因此报错无法加载：

| # | 测试文件 |
|---|---|
| 1 | `test/integration/drag_to_persist_wiring_test.dart` |
| 2 | `test/architecture/provider_bootstrap_test.dart` |
| 3 | `test/engines/calculation_engine_factory_test.dart` |
| 4 | `test/fix_ge_ju_parser_test.dart` |
| 5 | `test/data/user_school_profile_dao_test.dart` |
| 6 | `test/data/alignment_point_candidate_dao_test.dart` |
| 7 | `test/domain/engines/engine_provider_test.dart` |
| 8 | `test/domain/engines/sweph_asset_routing_test.dart` |
| 9 | `test/domain/engines/historical_engine_injection_test.dart` |
| 10 | `test/domain/ports/star_position_status_port_test.dart` |
| 11 | `test/domain/ports/historical_ephemeris_port_test.dart` |
| 12 | `test/domain/ports/zhou_tian_model_port_test.dart` |
| 13 | `test/domain/ports/ephemeris_resource_port_test.dart` |
| 14 | `test/domain/usecases/calculate_qizheng_base_panel_usecase_test.dart` |
| 15 | `test/domain/usecases/evaluate_qizheng_ge_ju_usecase_test.dart` |
| 16 | `test/domain/usecases/build_qizheng_timeline_usecase_test.dart` |
| 17 | `test/domain/usecases/compute_rise_set_usecase_test.dart` |
| 18 | `test/domain/usecases/save_calculated_panel_usecase_test.dart` |
| 19 | `test/domain/services/user_school_profile_service_test.dart` |
| 20 | `test/domain/entities/models/ge_ju/parser_conversion_test.dart` |
| 21 | `test/presentation/ge_ju_viewmodel_characterization_test.dart` |
| 22 | `test/presentation/qi_zheng_si_yu_viewmodel_usecase_wiring_test.dart` |
| 23 | `test/presentation/qi_zheng_si_yu_viewmodel_equivalence_test.dart` |
| 24 | `test/presentation/composition_root_test.dart` |
| 25 | `test/presentation/qi_zheng_si_yu_viewmodel_characterization_test.dart` |
| 26 | `test/presentation/chart_adapters/beauty_view_page_real_parity_test.dart` |

#### 根因类型 B：`xuan-time-location` git 包路径解析失败

```
Error when reading .../xuan-time-location-.../lib/contracts/xuan_time_location_contracts.dart': No such file or directory
```

此错误与类型 A 叠加（xuan-storage/time_location 同时依赖两个缺失包），影响的测试文件已全部包含在上述 26 个中。

#### 根因类型 C：calendar 包 `EnumDatetimeType.politicalCenter` 未穷尽 switch

```
../.pub-cache/git/calendar-.../lib/src/widgets/lunar_date_info_card.dart:94:13: Error:
  The type 'EnumDatetimeType' is not exhaustively matched by the switch cases since it
  doesn't match 'EnumDatetimeType.politicalCenter'.
```

此错误与类型 A 叠加（calendar 包是 dependency），影响的测试文件已全部包含在上述 26 个中。

### 3.2 运行时失败（6 个）

#### custom_config_section_widget_test.dart（5 个断言失败）

| # | 失败测试 | 原因摘要 |
|---|---|---|
| 27 | 坐标系出现 4 个选项文案 | ListTile 背景色被 DecoratedBox 遮挡的断言 |
| 28 | 出现周天制与黄赤道换算/起点/偏移量/星宿类型卡标题 | 同上 |
| 29 | 出现宫位划分控件并包含三辰通载子午不等宫 | 同上 |
| 30 | 选推变黄道后下拉含弧矢割圆术选项 | 同上 |
| 31 | 矛盾组合（黄道 + 365.25）出警告条 | 同上 |

#### custom_config_section_test.dart（1 个断言失败）

| # | 失败测试 | 原因摘要 |
|---|---|---|
| 32 | CustomConfigSection renders Rahu/Ketu definition and reacts to changes | Multiple exceptions (4) — ListTile 背景色被 DecoratedBox 遮挡 |

#### custom_config_section_starinn_editor_test.dart（1 个断言失败）

| # | 失败测试 | 原因摘要 |
|---|---|---|
| 33 | 逐宿覆写编辑器展开后有 TextFormField | 同上 ListTile 背景色断言 |

## 4. 与 AGENTS.md 记录的差异说明

- AGENTS.md 声称存在 "12 个 pre-existing 失败"。实际采集到 **33 个失败**。
- 其中 27 个编译加载失败系上游包 `repository-interface-divination-pipeline/lib/geo.dart` 从未提交入库所致，属**工作区级 pre-existing 问题**，非七政模块自身代码问题。
- 6 个运行时失败均与 `ListTile` 在 `DecoratedBox` 中的背景色渲染断言相关，属**七政模块 UI 测试 pre-existing 问题**。
- AGENTS.md 记录数量（12）严重低估了实际失败规模。本基线文档自即日起取代 AGENTS.md 中任何模糊的"12 个"说法，作为 M2-M5 测试回归的唯一权威参照。

## 5. 对本迁移的影响评估

- 编译失败的 26 个测试文件覆盖了全部核心 domain/presentation 测试。这意味着 **M2/M3/M4 的绝大多数验收测试在当前环境下不可运行**，直到 `repository-interface-divination-pipeline/geo.dart` shim 被提交入库或 workspace 依赖问题被修复。
- 6 个运行时失败与 UI 渲染无关，与排盘计算/编解码逻辑无关，不影响 M2-M4 的验收。
- 跳过项仅涉及 Sweph 原生绑定（CI 环境特有），不影响纯 Dart 单元测试。

**结论**：M2 阶段在此基线上的新增失败判定必须排除 27 个编译加载失败（属 upstream 问题），仅基于可成功加载并运行的 643+11 个测试。
