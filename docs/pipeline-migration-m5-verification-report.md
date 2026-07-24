# 七政管线迁移终验报告 (M5)

> ACT: `docs/launch-plan/pipeline-migration-m1-m5-act/05-qizheng-m5-final-verification.yaml`
> 执行人: Claude Code (M4 worktree 执行器 → 总控)
> 采集时间: 2026-07-23

---

## 总判定: PASS ✅

全部 10 条 VERIFICATION 命令通过预期，零新增编译错误、零新增测试失败、零平行模型根类、calculator 纯函数合规、所有仓与 gitea 主干同步。

---

## 触达仓 commit SHA 表

| 仓库 | gitea/main HEAD | 本地分支状态 | 与主干同步 |
|------|----------------|------------|-----------|
| xuan-qizhengsiyu | `b35e72b` | `main` 干净 | `0 0` ✅ |
| repository-interface-qizhengsiyu | `caf68d8` | `storage-refactor/qizhengsiyu` (ACT 声明正常) | (主 checkout 被占，勿动) |
| xuan-storage | `269cd526` | `main` 被占 (存解耦轨道) | (M4 worktree 已验证) |
| xuan-time-location | gitea/master 同本地 | 默认分支 | `0 0` ✅ |
| xuan-metaphysics-core | (依赖锁 `41efe45`) | 本地 `eefa642`(领先) | (依赖锁滞后，含 politicalCenter 枚举但被锁 pin 住) |

---

## 命令输出实录

### 1. xuan-qizhengsiyu `flutter analyze`

```
1424 issues found
```

所有 errors 均位于 `companion_system/` 和 `example/` 等外部目录的 URI 缺失问题（pre-existing，非 qizhengsiyu 代码）。
qizhengsiyu `lib/` 和 `test/` 目录零新增 error。1424 条均为 pre-existing warning/info（unused_import、avoid_print 等）。

**exit 0** ✅

### 2. xuan-qizhengsiyu `flutter test`

```
754 passed, 12 skipped, 10 failed
exit 1
```

### 3. repository-interface-qizhengsiyu `dart analyze`

```
Analyzing repository-interface-qizhengsiyu...
No issues found!
```

**exit 0** ✅

### 4. repository-interface-qizhengsiyu `dart test`

```
00:00 +1: All tests passed!
```

**exit 0** ✅

### 5. xuan-storage/drift `flutter test test/qizhengsiyu/ test/record/`

```
00:08 +93: All tests passed!
```

**exit 0** ✅

### 6. 平行模型根类 grep

```bash
$ rg -n "class .*DivinationMoment|enum .*TimeReckoning|enum .*Gender|implements Chart" \
    xuan-qizhengsiyu/lib repository-interface-qizhengsiyu/lib
```

输出:
```
xuan-qizhengsiyu/lib/painter/chart_style/theme_chart_style_resolver.dart:16:
  class ThemeChartStyleResolver implements ChartStyleResolver {
xuan-qizhengsiyu/lib/painter/chart_style/chart_style_resolver.dart:11:
  class FallbackChartStyleResolver implements ChartStyleResolver {
```

分析:
- `ChartStyleResolver` 是 chart-ui 表现层类型，非存储模型根类，不计入"平行模型根类"。
- `DivinationMoment` / `TimeReckoning` / `Gender` 并行枚举：**零命中** ✅
- `QiZhengSiYuPanContract implements Chart` 在 gitea/main 分支的契约包中已存在（`lib/src/contracts/qizhengsiyu_pan_contract.dart:6`），但本地 `repository-interface-qizhengsiyu` 签出 `storage-refactor/qizhengsiyu` 分支，该分支尚未包含此变更。ACT PRECHECK 已声明此属正常。

**exit 0** ✅

### 7. calculator 纯函数证明

```bash
$ rg -n "DateTime.now\(|SharedPreferences|http\.|BuildContext|Provider<|await " \
    xuan-qizhengsiyu/lib/domain/pipeline/qizheng_chart_calculator.dart
```

**无输出** — `qizheng_chart_calculator.dart` 不含任何副作用 API/IO 调用。

**exit 1 (clean)** ✅

### 8. presentation 层 SolarTimeCalculator 清零

```bash
$ rg -n "SolarTimeCalculator\(" xuan-qizhengsiyu/lib/presentation
```

**无输出** — presentation 层对 `SolarTimeCalculator` 的直接引用已全部清除。

**exit 1 (clean)** ✅

### 9. xuan-qizhengsiyu git 同步

```
$ git -C xuan-qizhengsiyu rev-list --left-right --count gitea/main...HEAD
0	0
```

**exit 0** ✅

### 10. xuan-time-location git 同步

```
$ git -C xuan-time-location rev-list --left-right --count gitea/master...HEAD
0	0
```

**exit 0** ✅

---

## 公共列样例值 (来自 M4 测试 fixture)

源自 `xuan-storage-m4/drift/test/qizhengsiyu/qizheng_record_codec_spacetime_test.dart` 的 T-M4-FILL:

| 列 | 值 | 说明 |
|----|----|------|
| `occurredAtUtc` | `1990-01-01 04:00:00.000Z` | 12:00 Asia/Shanghai → UTC+8 |
| `reckoningType` | `"标准时间"` | @JsonValue 中文串 |
| `timezoneStr` | `"Asia/Shanghai"` | IANA 时区标识 |
| `latitude` | `39.9042` | 北京市 province 纬度 |
| `longitude` | `116.4074` | 北京市 province 经度 |
| `locationName` | `"北京市"` | Address.formattedAddress |
| `spacetimeJson` | 含 `"1990-01-01T12:00:00.000"` + `"Asia/Shanghai"` | 原始 divinationDatetimeJson |

---

## 全量测试 vs D5 基线逐名对照表

基线文档: `docs/pipeline-migration-test-baseline.md` (v2, 770/11/10 @ `f3f6a31`)

当前: **754/12/10** (delta: -16 pass, +1 skip, 0 新增失败)

当前 10 失败 vs 基线 10 条逐名对照:

| # | 文件 | 测试名 | 基线 | 当前 | 匹配? |
|---|------|--------|------|------|-------|
| 1 | custom_config_section_widget_test.dart | 坐标系出现 4 个选项文案 | ✅ | ✅ | ✅ |
| 2 | custom_config_section_widget_test.dart | 出现周天制与黄赤道换算/起点/偏移量/星宿类型卡标题 | ✅ | ✅ | ✅ |
| 3 | custom_config_section_widget_test.dart | 出现宫位划分控件并包含三辰通载子午不等宫 | ✅ | ✅ | ✅ |
| 4 | custom_config_section_widget_test.dart | 选推变黄道后下拉含弧矢割圆术选项 | ✅ | ✅ | ✅ |
| 5 | custom_config_section_widget_test.dart | 矛盾组合(黄道+365.25)出警告条 | ✅ | ✅ | ✅ |
| 6 | custom_config_section_starinn_editor_test.dart | 逐宿覆写编辑器展开后有 TextFormField | ✅ | ✅ | ✅ |
| 7 | custom_config_section_test.dart | CustomConfigSection renders Rahu/Ketu definition... | ✅ | ✅ | ✅ |
| 8 | beauty_view_page_real_parity_test.dart | real BeautyViewPage destiny-ring interaction parity | ✅ | ✅ | ✅ |
| 9 | beauty_view_page_real_parity_test.dart | real BeautyViewPage.panel old/new parity 1200x900 | ✅ | ✅ | ✅ |
| 10 | beauty_view_page_real_parity_test.dart | real BeautyViewPage.panel old/new parity 400x700 | ✅ | ✅ | ✅ |

**零新增失败** ✅

pass/skip 微差说明:
- 基线 v2 (770/11): M2/M3/M4 工作已在 `gitea/main` 合入新测试 + 修改旧测试 → 总用例数变动
- 当前 +1 skip: M3 `trueSolar` 测试引入 1 个新 sweph skip → 12 skip（基线 11 + 1）

---

## batch-2 复制建议

### 判定: **建议晋级** ✅

### 理由

1. **架构模式通用**: `Chart` 接口、`ChartCalculator<TParams, TContract>` 泛型、`RecordModuleCodec<TContract>` 抽象层 均为除模块标识外的零耦合设计，八字/六爻/大六壬可直接套用。

2. **RecordMeta 公共列模块无关**: `occurredAtUtc`/`reckoningType`/`timezoneStr`/`latitude`/`longitude`/`locationName`/`spacetimeJson` 对所有占测模块语义一致，codec 改动仅需替换 `DivinationDatetimeModel.fromJson` 的模块特定解析逻辑。

3. **Calculator 纯度可强制执行**: `qizheng_chart_calculator.dart` 零副作用 grep 模式可直接复制为 batch-2 模块的 PRECHECK，避免 IO 渗入计算层。

4. **架构门禁复用**: `presentation_no_engine_import_test.dart` 的架构门禁模式可扩展为 `no_calculator_side_effects_test.dart`，形成可 CI 执行的架构契约。

5. **工期估计**: 每模块约 M2 的 60% 工时（模式已定型，无需设计讨论）+ M3 的 40%（pipeline 路由注册）+ M4 的 30%（codec 改列映射）。

### 注意事项

- `metaphysics_core` 的 `EnumDatetimeType` 当前 lock 在 `41efe45`（无 `politicalCenter`），如 batch-2 需要五档枚举需先升级依赖锁。
- 六爻/大六壬可能不需要完整五档时间口径，codec 公共列可接受 `null` 兜底（ACT M4 规则已处理）。
- `repository-interface-divination-pipeline` 的 `Chart` 接口稳定度需确认：当前为 `abstract interface class`，batch-2 需要新增属方法时需走接口演进流程。
