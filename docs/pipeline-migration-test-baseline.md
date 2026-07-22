# 七政四余测试基线 v2（pre-existing 失败固化的权威记录）

> ACT: `docs/launch-plan/pipeline-migration-m1-m5-act/01b-qizheng-test-baseline.yaml`
> 采集时间: 2026-07-22（v2，环境修复后复采）
> 基线工作区: `f3f6a31` + 依赖刷新（见 §2）
> v1 历史: 首采 33 失败（27 编译 + 6 运行时），全文见本文件在 `f3f6a31` 的版本

## 1. 执行命令

```bash
cd xuan-qizhengsiyu && flutter test
```

## 2. v1 → v2 之间的环境修复（Claude Code 执行，2026-07-22）

v1 的 27 个编译加载失败全部源于工作区依赖漂移，已修复：

1. `repository-interface-divination-pipeline/lib/geo.dart` shim 转正入库并推送
   （契约包 gitea/main `ed17984 → 038c27a`，方案 A，人类批准）。
2. 根包与 example 的 `pubspec_overrides.yaml` 统一 pipeline 契约包及其间接依赖
   （divination_case / repository_interface_record / repository_interface_qizhengsiyu /
   metaphysics_core）为 path 单一来源，消除 path/git 双来源 pub solving 冲突。
   ⚠ 注意：`pubspec_overrides.yaml` 存在时会**整节取代** pubspec.yaml 的
   dependency_overrides，必须包含原节全量条目。
3. `flutter pub upgrade` 刷新 git 依赖 lock：calendar 拉到含 politicalCenter
   穷尽修复的 `87fc0d4`+，time-location 拉到 contracts 文件齐备的新主干。

## 3. v2 结果摘要

| 指标 | 值 |
|---|---|
| 通过 | 770 |
| 跳过 | 11 |
| 失败 | **10** |
| exit code | 1 |

11 个 skip 均为 Sweph native bindings not available in flutter test（非迁移相关）。
v1 的 27 个编译失败**全部消除**（643→770 通过，+127）。

## 4. 失败清单（10 条，全部为 presentation 层 UI 测试）

### 4.1 custom_config_section 族（7 条，v1 已知）

| # | 测试文件 | 失败测试 | 原因摘要 |
|---|---|---|---|
| 1 | `test/presentation/config/custom_config_section_widget_test.dart` | 坐标系出现 4 个选项文案 | ListTile 背景色被 DecoratedBox 遮挡断言 |
| 2 | 同上 | 出现周天制与黄赤道换算/起点/偏移量/星宿类型卡标题 | 同上 |
| 3 | 同上 | 出现宫位划分控件并包含三辰通载子午不等宫 | 同上 |
| 4 | 同上 | 选推变黄道后下拉含弧矢割圆术选项 | 同上 |
| 5 | 同上 | 矛盾组合（黄道 + 365.25）出警告条 | 同上 |
| 6 | `test/presentation/config/custom_config_section_starinn_editor_test.dart` | 逐宿覆写编辑器展开后有 TextFormField | 同上 |
| 7 | `test/presentation/widgets/config/custom_config_section_test.dart` | CustomConfigSection renders Rahu/Ketu definition and reacts to changes | Multiple exceptions (4)，同族 |

### 4.2 beauty_view_page_real_parity 族（3 条，v1 时被编译失败掩盖，v2 首次现形）

| # | 失败测试 | 说明 |
|---|---|---|
| 8 | real BeautyViewPage destiny-ring interaction parity | chart-ui 新旧盘面 parity 断言，属 chart-ui 轨道债 |
| 9 | real BeautyViewPage.panel old/new parity at 1200.0x900.0 | 同上 |
| 10 | real BeautyViewPage.panel old/new parity at 400.0x700.0 | 同上 |

## 5. 对 M2-M5 的影响评估

- 10 条失败全部在 presentation 层 UI/渲染断言，**零排盘计算、零时间口径、零编解码相关**。
  M2（calculator）/M3（pipeline 接入）/M4（codec）的验收不受影响。
- 4.2 的 parity 三条属 chart-ui 统一治理轨道的已知债务域（样式 golden 假阳性同族），
  不得由 M 轨道 agent 顺手修。
- **回归判定规则**：M2-M5 任何 ACT 完成后全量 `flutter test`，失败清单与本节 10 条
  逐名对照；出现第 11 个名字即为新增失败，一律不得归咎 pre-existing。

## 6. 与 AGENTS.md 记录的差异

AGENTS.md 声称"12 个 pre-existing 失败"，实为 v2 基线 **10 条**（v1 曾采 33，含 27 条
环境性编译失败已修复）。本文档自即日起为唯一权威参照。
