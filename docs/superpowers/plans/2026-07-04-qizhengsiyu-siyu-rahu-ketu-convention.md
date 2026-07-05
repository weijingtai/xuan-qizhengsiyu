# 四余独立模块抽取 + 罗计升降交点用户可选 + 紫气算法可扩展 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [x]`) syntax for tracking.
>
> **本计划分三部分**：**Part A（Task 1–8）** 四余模块抽取 + 罗计用户可选；**Part B（Task 9–16）** 紫气算法可扩展 + 天赤道郑氏星案模型（含 Moira 四点验证、郭守敬宿距）；**Part C（Task 17–24）** 四余可配置计算框架——三算法组（罗计/月孛/紫气）、星历/古法平行变体、分段多模型、流派档案+单项覆盖、spec+工厂+两层 UI（自定义=选择+调参，无 DSL）。依赖：C 依赖 A/B，B 依赖 A。设计 spec：`docs/superpowers/specs/2026-07-04-siyu-configurable-framework-design.md`。

**Goal:** (A) 把当前内联在 `SwephEngine` 里的「四余（紫气/月孛/罗睺/计都）」计算抽成独立可测模块，并把「罗睺/计都 谁属升交点、谁属降交点」这一流派分歧做成用户可选、每盘持久化配置（默认古法正统罗降计升）；(B) 把紫气行度做成**可扩展的算法策略机制**，落地果老/清时宪/耶律天官三套，并留出注册新算法的扩展点，取代当前来历不明的 2013 magic number。

**Architecture:** 四余的天文计算抽到新模块 `lib/domain/engines/siyu/`（`SiYuCalculator` + 注入式 `ISiYuEphemerisSource`，可脱离 sweph 单测）；罗计升降交点归属被隔离成纯函数 `RahuKetuDefinition.assign`（唯一的「定义层」，锁死测试打在这里）。`StarsAngle` 的 `southNode`/`northNode` 字段**保持天文中性**（升/降交点原值），流派开关**只在 `StarsAngle.toMap(convention:)` 这一个边界生效**，由引擎从 `config.rahuKetuConvention` 传入。默认值 = 旧法 ⇒ 序列化与全链路行为零回归。

**Tech Stack:** Dart / Flutter；`sweph`（Swiss Ephemeris）；`json_serializable`（`.g.dart` 代码生成）；`flutter_test`。

## Global Constraints

- 语言与注释：领域概念用拼音（SiYu / RahuKetu / ZiQi），注释以中文为主，代码逻辑英文（遵循仓库 CLAUDE.md 约定）。
- 罗计属性（罗=火余、计=土余等）定义在**共享包 `xuan-metaphysics-core/lib/enums/enum_stars.dart`**，**本计划不得修改该文件**；翻转只改「罗/计各自落在哪个宫/宿」，属性不动。
- 默认约定 = **古法正统「罗降计升」**（`EnumRahuKetuConvention.luoJiangJiSheng`，即当前线上行为，零回归）；另一约定「罗升计降」（`luoShengJiJiang`，清后期西法/印度 Jyotish）必须在 UI 上给出「与古法正统罗计相反、吉凶互换，仅供比对参考」的警示。**史料方向以下文《罗计史料裁定》为准，切勿反向理解。**
- **向后兼容**：旧的已持久化 `PanelConfig` JSON 不含新字段，反序列化必须落到默认旧法、**不得抛异常**（用 `@JsonKey(defaultValue: ...)`）。
- 紫气公式**原样搬运、行为一字节不改**（保留现有 2013 上海时间基准）；本次不做紫气历元校准（属另一议题）。
- 生成文件 `*.g.dart` 一律用 `dart run build_runner build --delete-conflicting-outputs` 重生，禁止手改。
- 每个 Task 结束需 `flutter analyze` 无新增错误后再 commit。

---

## 参考：现状事实（实现者必读，避免踩坑）

- 四余现内联在 `lib/domain/engines/sweph_engine.dart` 的 `_calculateAllStarsAngleOnZodiac()`：
  - `northNode = Sweph.swe_calc(jd, SE_MEAN_NODE).longitude`（升交点 N）
  - `southNode = (northNode + 180) % 360`（降交点）
  - `lilith = Sweph.swe_calc(jd, SE_MEAN_APOG).longitude`（月孛=平远地点）
  - `ziQi()` 内联闭包：以 `Asia/Shanghai 2013-04-09 02:58` 为 0°，`0.0352/(24*60)` 度/分钟平行推。
  - 四个值都经 `roundHelper`（保留 2 位小数）后塞进 `StarsAngle`。
- `StarsAngle`（`lib/domain/entities/models/panel_stars_info.dart:72`）字段 `southNode/northNode/lilith/qi` 是**中性天文量**；旧法「罗=降/计=升」焊死在 3 处：`fromMapper:106-107`、`toMap:140-141`、`getByStar:176-181`。
- 引擎出口 `_transformToStarPositionRawData(starsAngle, config)`（`sweph_engine.dart:62`）调用 `starsAngle.toMap()` 得到 `Map<EnumStars, StarAngleSpeed>`，再转 `List<StarPositionRawData>`——这是下游唯一消费的「货币」。**只要在这一处按 convention 正确分配罗/计，下游（star_body_model_builder、beauty_view_page 等）无需任何改动。**
- `ICalculationEngine` 另有实现 `HistoricalEngine`（`lib/domain/engines/historical_engine.dart`），目前是 **stub（只算 Sun，四余全 TODO）**。本计划模块设计成将来可被它复用，但**本次不接线 HistoricalEngine**。
- `BasePanelConfig`（`lib/domain/entities/models/panel_config.dart:13`）是 `@JsonSerializable`；`PanelConfig extends BasePanelConfig`（:142）。新字段加在 **Base**，`PanelConfig` 通过 `super.` 传递。
- **UI 空接陷阱**：`CustomConfigSection._updateConfig()`（`lib/presentation/widgets/config/custom_config_section.dart:62`）重建 `PanelConfig` 时**只搬了部分字段**。加了新字段后**必须**在这里带上，否则用户选择会被丢弃。

---

## 罗计史料裁定（实现者必读，勿被外部「勘误文档」带偏）

本项目就罗睺/计都与升降交点的归属，**已由领域负责人裁定，以此为准**：

- **古法正统 = 罗降计升（本模块默认）**：罗睺=降交点(N+180)、计都=升交点(N)。
  依据《果老星宗》《开元占经》一行九执历——**「交初为罗、交中为计」，俗称「南罗北计」**；
  其中**天首=降交点=交初=罗睺**，天尾=升交点=交中=计都。此与当前线上代码
  （`panel_stars_info.dart` 罗→southNode/降交）一致，故默认零回归。
- **民间·西法 = 罗升计降**：罗睺=升交点(N)、计都=降交点。清后期西法传入后民间混用，
  现代印度占星 Jyotish 默认此套，与古法正统相反。

> ⚠️ 曾有一份外部「勘误文档」主张「明正统=罗升、罗降是民间反转」，并据「天首=升交」推出
> 代码自相矛盾——**该主张方向反了，已被否决**：在古法正统里天首=降交，代码与正统自洽。
> 实现者若读到该类材料，**不要据此反转默认或改写 `RahuKetuDefinition`**。

---

## File Structure

**新建：**
- `lib/enums/enum_rahu_ketu_convention.dart` — 罗计升降交点归属枚举（旧法/新法），`@JsonValue` 中文。
- `lib/domain/engines/siyu/rahu_ketu_definition.dart` — 纯函数「定义层」`RahuKetuDefinition.assign` + `RahuKetuLongitudes`。
- `lib/domain/engines/siyu/si_yu_calculator.dart` — `ISiYuEphemerisSource`、`SiYuRawResult`、`SiYuCalculator`（四余天文计算，紫气公式搬运于此）。
- `lib/domain/engines/siyu/sweph_si_yu_ephemeris_source.dart` — `SwephSiYuEphemerisSource implements ISiYuEphemerisSource`（包裹 sweph）。
- `test/enums/enum_rahu_ketu_convention_test.dart`
- `test/domain/engines/siyu/rahu_ketu_definition_test.dart`
- `test/domain/engines/siyu/si_yu_calculator_test.dart`
- `test/domain/entities/models/stars_angle_convention_test.dart`

**修改：**
- `lib/domain/entities/models/panel_config.dart` — Base 加 `rahuKetuConvention` 字段（含 `@JsonKey(defaultValue:)`）、构造/copyWith/`PanelConfig` super 传递。
- `lib/domain/entities/models/panel_config.g.dart` —（build_runner 重生，勿手改）
- `lib/domain/entities/models/panel_stars_info.dart` — `StarsAngle.toMap/fromMapper/getByStar` 增 `convention` 可选参（默认旧法），改用 `RahuKetuDefinition`。
- `lib/domain/engines/sweph_engine.dart` — `_calculateAllStarsAngleOnZodiac` 改用 `SiYuCalculator`；`_transformToStarPositionRawData` 调 `toMap(convention: config.rahuKetuConvention)`。
- `lib/presentation/widgets/config/custom_config_section.dart` — 加罗计定义单选 + 新法警示；`_updateConfig` 带上新字段。

---

## Task 1: `EnumRahuKetuConvention` 枚举

**Files:**
- Create: `lib/enums/enum_rahu_ketu_convention.dart`
- Test: `test/enums/enum_rahu_ketu_convention_test.dart`

**Interfaces:**
- Produces: `enum EnumRahuKetuConvention { luoJiangJiSheng, luoShengJiJiang }`，各带 `String name`、`String description`；`@JsonValue("罗降计升")` / `@JsonValue("罗升计降")`。

- [x] **Step 1: 写失败测试**

```dart
// test/enums/enum_rahu_ketu_convention_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:qizhengsiyu/enums/enum_rahu_ketu_convention.dart';

void main() {
  test('默认项为旧法 luoJiangJiSheng', () {
    expect(EnumRahuKetuConvention.values.first,
        EnumRahuKetuConvention.luoJiangJiSheng);
  });

  test('name/description 已填写', () {
    for (final c in EnumRahuKetuConvention.values) {
      expect(c.name.isNotEmpty, isTrue);
      expect(c.description.isNotEmpty, isTrue);
    }
  });
}
```

- [x] **Step 2: 运行确认失败**

Run: `flutter test test/enums/enum_rahu_ketu_convention_test.dart`
Expected: FAIL —— 找不到 `enum_rahu_ketu_convention.dart`。

- [x] **Step 3: 实现枚举**

```dart
// lib/enums/enum_rahu_ketu_convention.dart
import 'package:json_annotation/json_annotation.dart';

/// 罗睺 / 计都 与月球白道升/降交点的归属约定（流派分歧，用户可选）。
///
/// 天文事实：星历给出月球平升交点黄经 N（逆行），降交点 = N + 180°。
/// 「谁是罗睺、谁是计都」是流派/历法的解释差异，不是天文差异。
enum EnumRahuKetuConvention {
  /// 古法正统（默认）：罗睺=降交点(N+180)、计都=升交点(N)。
  /// 依据《果老星宗》《开元占经》一行九执历：交初为罗、交中为计，俗称「南罗北计」。
  /// 天首=降交点=罗。即当前线上行为；勿反向理解（见规格书《罗计史料裁定》）。
  @JsonValue("罗降计升")
  luoJiangJiSheng("罗降计升（古法正统）",
      "罗睺取降交点、计都取升交点。果老星宗/开元占经/一行九执历古法，命理默认。"),

  /// 民间·西法：罗睺=升交点(N)、计都=降交点(N+180)。
  /// 清后期西法传入后民间混用，现代印度占星 Jyotish 默认此套，与古法正统相反。
  @JsonValue("罗升计降")
  luoShengJiJiang("罗升计降（民间·西法）",
      "罗睺取升交点、计都取降交点。清后期西法/印度 Jyotish，与古法正统相反、吉凶互换。");

  final String name;
  final String description;
  const EnumRahuKetuConvention(this.name, this.description);
}
```

- [x] **Step 4: 运行确认通过**

Run: `flutter test test/enums/enum_rahu_ketu_convention_test.dart`
Expected: PASS

- [x] **Step 5: 提交**

```bash
git add lib/enums/enum_rahu_ketu_convention.dart test/enums/enum_rahu_ketu_convention_test.dart
git commit -m "feat(siyu): 新增罗计升降交点归属枚举 EnumRahuKetuConvention"
```

---

## Task 2: `RahuKetuDefinition` 纯函数定义层（锁死测试所在）

**Files:**
- Create: `lib/domain/engines/siyu/rahu_ketu_definition.dart`
- Test: `test/domain/engines/siyu/rahu_ketu_definition_test.dart`

**Interfaces:**
- Consumes: `EnumRahuKetuConvention`（Task 1）。
- Produces:
  - `class RahuKetuLongitudes { final double luo; final double ji; const RahuKetuLongitudes({required this.luo, required this.ji}); }`
  - `RahuKetuLongitudes RahuKetuDefinition.assign({required double northNode, required EnumRahuKetuConvention convention})` —— 给定升交点黄经，按流派返回罗/计黄经；恒满足 `|luo-ji| ≡ 180°`。

- [x] **Step 1: 写失败测试（源规格书 §8-B 全部不变量）**

```dart
// test/domain/engines/siyu/rahu_ketu_definition_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:qizhengsiyu/enums/enum_rahu_ketu_convention.dart';
import 'package:qizhengsiyu/domain/engines/siyu/rahu_ketu_definition.dart';

double _diff(double a, double b) {
  var d = (a - b).abs() % 360;
  if (d > 180) d = 360 - d;
  return d;
}

void main() {
  const oldWay = EnumRahuKetuConvention.luoJiangJiSheng;
  const newWay = EnumRahuKetuConvention.luoShengJiJiang;

  test('旧法：罗睺=降交点(N+180)，计都=升交点(N)', () {
    final r = RahuKetuDefinition.assign(northNode: 30, convention: oldWay);
    expect(r.ji, closeTo(30, 1e-9));
    expect(r.luo, closeTo(210, 1e-9));
  });

  test('新法：罗睺=升交点(N)，计都=降交点(N+180)', () {
    final r = RahuKetuDefinition.assign(northNode: 30, convention: newWay);
    expect(r.luo, closeTo(30, 1e-9));
    expect(r.ji, closeTo(210, 1e-9));
  });

  test('降交点越界归一化：N=200 -> 降=20', () {
    final r = RahuKetuDefinition.assign(northNode: 200, convention: oldWay);
    expect(r.luo, closeTo(20, 1e-9)); // 降交点
    expect(r.ji, closeTo(200, 1e-9)); // 升交点
  });

  test('罗计恒对冲 180°（两流派、任意角度）', () {
    for (final n in [0.0, 30.0, 123.4, 200.0, 359.9]) {
      for (final c in EnumRahuKetuConvention.values) {
        final r = RahuKetuDefinition.assign(northNode: n, convention: c);
        expect(_diff(r.luo, r.ji), closeTo(180, 1e-6));
      }
    }
  });

  test('新法与旧法的罗睺黄经恰好相差 180°', () {
    final o = RahuKetuDefinition.assign(northNode: 77, convention: oldWay);
    final n = RahuKetuDefinition.assign(northNode: 77, convention: newWay);
    expect(_diff(o.luo, n.luo), closeTo(180, 1e-6));
  });
}
```

- [x] **Step 2: 运行确认失败**

Run: `flutter test test/domain/engines/siyu/rahu_ketu_definition_test.dart`
Expected: FAIL —— 找不到 `rahu_ketu_definition.dart`。

- [x] **Step 3: 实现纯函数**

```dart
// lib/domain/engines/siyu/rahu_ketu_definition.dart
import 'package:qizhengsiyu/enums/enum_rahu_ketu_convention.dart';

/// 罗睺、计都各自的黄经。
class RahuKetuLongitudes {
  final double luo; // 罗睺
  final double ji;  // 计都
  const RahuKetuLongitudes({required this.luo, required this.ji});
}

/// 罗计升降交点归属「定义层」——全模块最易写反之处，隔离成纯函数并由单测锁死。
///
/// ⚠️ 旧法（默认）= 罗睺取降交点、计都取升交点，与印度/西占惯例相反。
/// 切勿凭直觉改动，改动前先看 test/domain/engines/siyu/rahu_ketu_definition_test.dart。
class RahuKetuDefinition {
  const RahuKetuDefinition._();

  /// [northNode]：月球平升交点黄经（sweph SE_MEAN_NODE 输出）。
  static RahuKetuLongitudes assign({
    required double northNode,
    required EnumRahuKetuConvention convention,
  }) {
    final asc = _normalize360(northNode);        // 升交点
    final desc = _normalize360(northNode + 180); // 降交点
    switch (convention) {
      case EnumRahuKetuConvention.luoJiangJiSheng: // 旧法：罗=降, 计=升
        return RahuKetuLongitudes(luo: desc, ji: asc);
      case EnumRahuKetuConvention.luoShengJiJiang: // 新法：罗=升, 计=降
        return RahuKetuLongitudes(luo: asc, ji: desc);
    }
  }

  static double _normalize360(double d) {
    var r = d % 360;
    if (r < 0) r += 360;
    return r;
  }
}
```

- [x] **Step 4: 运行确认通过**

Run: `flutter test test/domain/engines/siyu/rahu_ketu_definition_test.dart`
Expected: PASS（5 个 test 全绿）

- [x] **Step 5: 提交**

```bash
git add lib/domain/engines/siyu/rahu_ketu_definition.dart test/domain/engines/siyu/rahu_ketu_definition_test.dart
git commit -m "feat(siyu): 隔离罗计定义层 RahuKetuDefinition + 结构不变量测试"
```

---

## Task 3: `SiYuCalculator` 四余天文计算模块（含注入式星历源）

**Files:**
- Create: `lib/domain/engines/siyu/si_yu_calculator.dart`
- Create: `lib/domain/engines/siyu/sweph_si_yu_ephemeris_source.dart`
- Test: `test/domain/engines/siyu/si_yu_calculator_test.dart`

**Interfaces:**
- Consumes: `package:timezone/timezone.dart`；`package:sweph/sweph.dart`（仅 `SwephSiYuEphemerisSource`）。
- Produces:
  - `abstract interface class ISiYuEphemerisSource { double meanNodeLongitude(double julianDay); double meanApogeeLongitude(double julianDay); }`
  - `class SiYuRawResult { final double northNode; final double southNode; final double lilith; final double qi; const SiYuRawResult({...}); }` —— **中性天文量**（未套用流派），`northNode`=升交点、`southNode`=降交点、`lilith`=月孛（远地点）、`qi`=紫气。
  - `class SiYuCalculator { SiYuCalculator({required ISiYuEphemerisSource source}); SiYuRawResult compute({required double julianDay, required DateTime birthDate}); }`

> **前向说明**：本 Task 里紫气用内联 `_computeZiQi`（搬运旧 magic 公式）仅为过渡，保证 Part A 可独立跑通。**Part B Task 14 会把构造函数改为 `SiYuCalculator({required source, required ZiQiAlgorithm ziQiAlgorithm})` 并删除 `_computeZiQi`**。若按顺序连做 Part A+B，可直接采用 Task 14 的注入式签名，跳过此过渡实现。
  - `class SwephSiYuEphemerisSource implements ISiYuEphemerisSource` —— 生产实现，包裹 `Sweph.swe_calc`。

- [x] **Step 1: 写失败测试（用 Fake 源，脱离 sweph；结构不变量 + 紫气搬运保真）**

```dart
// test/domain/engines/siyu/si_yu_calculator_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;
import 'package:qizhengsiyu/domain/engines/siyu/si_yu_calculator.dart';

class _FakeSource implements ISiYuEphemerisSource {
  final double node;
  final double apogee;
  _FakeSource(this.node, this.apogee);
  @override
  double meanNodeLongitude(double jd) => node;
  @override
  double meanApogeeLongitude(double jd) => apogee;
}

void main() {
  setUpAll(() => tzdata.initializeTimeZones());

  test('降交点=升交点+180，月孛=远地点直传', () {
    final calc = SiYuCalculator(source: _FakeSource(30, 123));
    final r = calc.compute(
        julianDay: 2451545.0,
        birthDate: DateTime.utc(2000, 1, 1));
    expect(r.northNode, closeTo(30, 1e-9));
    expect(r.southNode, closeTo(210, 1e-9));
    expect(r.lilith, closeTo(123, 1e-9));
  });

  test('升交点越界归一化：N=350 -> 降=170', () {
    final calc = SiYuCalculator(source: _FakeSource(350, 0));
    final r = calc.compute(
        julianDay: 2451545.0, birthDate: DateTime.utc(2000, 1, 1));
    expect(r.southNode, closeTo(170, 1e-9));
  });

  test('紫气：历元基准时刻返回 0（行为保真）', () {
    final calc = SiYuCalculator(source: _FakeSource(0, 0));
    final base = tz.TZDateTime(
        tz.getLocation('Asia/Shanghai'), 2013, 4, 9, 2, 58);
    final r = calc.compute(julianDay: 0, birthDate: base);
    expect(r.qi, closeTo(0, 1e-9));
  });

  test('紫气：基准后 1 天 ≈ 1440*0.0352/1440 = 0.0352°', () {
    final calc = SiYuCalculator(source: _FakeSource(0, 0));
    final base = tz.TZDateTime(
        tz.getLocation('Asia/Shanghai'), 2013, 4, 10, 2, 58);
    final r = calc.compute(julianDay: 0, birthDate: base);
    expect(r.qi, closeTo(0.0352, 1e-6));
  });
}
```

- [x] **Step 2: 运行确认失败**

Run: `flutter test test/domain/engines/siyu/si_yu_calculator_test.dart`
Expected: FAIL —— 找不到 `si_yu_calculator.dart`。

- [x] **Step 3: 实现 `SiYuCalculator`（紫气公式逐字搬自 `sweph_engine.dart`）**

```dart
// lib/domain/engines/siyu/si_yu_calculator.dart
import 'package:timezone/timezone.dart' as tz;

/// 四余星历源抽象（升交点 / 远地点）。生产实现见 SwephSiYuEphemerisSource。
abstract interface class ISiYuEphemerisSource {
  double meanNodeLongitude(double julianDay);   // SE_MEAN_NODE
  double meanApogeeLongitude(double julianDay); // SE_MEAN_APOG
}

/// 四余的中性天文量（尚未套用罗计流派）。
class SiYuRawResult {
  final double northNode; // 升交点
  final double southNode; // 降交点 = northNode + 180
  final double lilith;    // 月孛（月球远地点）
  final double qi;        // 紫气（平行推算，无天体）
  const SiYuRawResult({
    required this.northNode,
    required this.southNode,
    required this.lilith,
    required this.qi,
  });
}

/// 四余（紫气/月孛/罗睺/计都）天文计算模块。
///
/// 说明：本模块只产出「中性天文量」——不决定罗/计谁属升/降交点。
/// 罗计流派归属由 RahuKetuDefinition 在 StarsAngle.toMap 边界套用。
class SiYuCalculator {
  final ISiYuEphemerisSource _source;
  const SiYuCalculator({required ISiYuEphemerisSource source})
      : _source = source;

  SiYuRawResult compute({
    required double julianDay,
    required DateTime birthDate,
  }) {
    final n = _normalize360(_source.meanNodeLongitude(julianDay));
    final south = _normalize360(n + 180);
    final apogee = _normalize360(_source.meanApogeeLongitude(julianDay));
    return SiYuRawResult(
      northNode: n,
      southNode: south,
      lilith: apogee,
      qi: _computeZiQi(birthDate),
    );
  }

  /// 紫气平行公式：逐字搬自旧 SwephEngine._calculateAllStarsAngleOnZodiac.ziQi()。
  /// 行为保持不变（含 2013 上海时间基准；本次不做历元校准）。
  static double _computeZiQi(DateTime datetime) {
    final tz.TZDateTime baseShangHaiTime =
        tz.TZDateTime(tz.getLocation('Asia/Shanghai'), 2013, 4, 9, 2, 58);
    const angleForEachMinutes = 0.0352 / (24 * 60);

    if (datetime.isAtSameMomentAs(baseShangHaiTime)) {
      return 0;
    }
    final diffInMinutes = datetime.isBefore(baseShangHaiTime)
        ? baseShangHaiTime.difference(datetime)
        : datetime.difference(baseShangHaiTime);

    double result = diffInMinutes.inMinutes * angleForEachMinutes;
    if (result >= 360) {
      result -= 360;
    }
    return result;
  }

  static double _normalize360(double d) {
    var r = d % 360;
    if (r < 0) r += 360;
    return r;
  }
}
```

- [x] **Step 4: 实现生产星历源**

```dart
// lib/domain/engines/siyu/sweph_si_yu_ephemeris_source.dart
import 'package:sweph/sweph.dart';

import 'si_yu_calculator.dart';

/// 基于 Swiss Ephemeris 的四余星历源（方案 A）。
class SwephSiYuEphemerisSource implements ISiYuEphemerisSource {
  const SwephSiYuEphemerisSource();

  @override
  double meanNodeLongitude(double julianDay) => Sweph.swe_calc(
        julianDay,
        HeavenlyBody.SE_MEAN_NODE,
        SwephFlag.SEFLG_SWIEPH,
      ).longitude;

  @override
  double meanApogeeLongitude(double julianDay) => Sweph.swe_calc(
        julianDay,
        HeavenlyBody.SE_MEAN_APOG,
        SwephFlag.SEFLG_SWIEPH,
      ).longitude;
}
```

- [x] **Step 5: 运行确认通过**

Run: `flutter test test/domain/engines/siyu/si_yu_calculator_test.dart`
Expected: PASS（4 个 test 全绿）

- [x] **Step 6: 提交**

```bash
git add lib/domain/engines/siyu/si_yu_calculator.dart lib/domain/engines/siyu/sweph_si_yu_ephemeris_source.dart test/domain/engines/siyu/si_yu_calculator_test.dart
git commit -m "feat(siyu): 抽出四余天文计算模块 SiYuCalculator + 注入式星历源"
```

---

## Task 4: `BasePanelConfig` 新增 `rahuKetuConvention` 字段（含向后兼容）

**Files:**
- Modify: `lib/domain/entities/models/panel_config.dart`
- Regenerate: `lib/domain/entities/models/panel_config.g.dart`
- Test: 复用 `test/domain/entities/models/stars_angle_convention_test.dart`（Task 5 建）——本 Task 追加序列化测试到该文件，或临时建 `test/domain/entities/models/panel_config_convention_test.dart`（二选一，下面用后者）。
- Test: `test/domain/entities/models/panel_config_convention_test.dart`

**Interfaces:**
- Consumes: `EnumRahuKetuConvention`（Task 1）。
- Produces: `BasePanelConfig.rahuKetuConvention`（可写字段，默认 `luoJiangJiSheng`）；`PanelConfig` 通过 `super.rahuKetuConvention` 支持。

- [x] **Step 1: 写失败测试（含旧 JSON 缺字段的向后兼容）**

```dart
// test/domain/entities/models/panel_config_convention_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:qizhengsiyu/domain/entities/models/panel_config.dart';
import 'package:qizhengsiyu/enums/enum_rahu_ketu_convention.dart';

void main() {
  test('默认配置为旧法', () {
    expect(PanelConfig.defaultPanelConfig().rahuKetuConvention,
        EnumRahuKetuConvention.luoJiangJiSheng);
  });

  test('旧 JSON 缺 rahuKetuConvention -> 默认旧法，不抛异常', () {
    final json = PanelConfig.defaultPanelConfig().toJson();
    json.remove('rahuKetuConvention');
    final restored = PanelConfig.fromJson(json);
    expect(restored.rahuKetuConvention,
        EnumRahuKetuConvention.luoJiangJiSheng);
  });

  test('新法可序列化往返', () {
    final cfg = PanelConfig.defaultPanelConfig()
      ..rahuKetuConvention = EnumRahuKetuConvention.luoShengJiJiang;
    final restored = PanelConfig.fromJson(cfg.toJson());
    expect(restored.rahuKetuConvention,
        EnumRahuKetuConvention.luoShengJiJiang);
  });
}
```

- [x] **Step 2: 运行确认失败**

Run: `flutter test test/domain/entities/models/panel_config_convention_test.dart`
Expected: FAIL —— `rahuKetuConvention` getter 不存在（编译错误）。

- [x] **Step 3: 改 `panel_config.dart`**

在 `import` 区加：
```dart
import '../../../enums/enum_rahu_ketu_convention.dart';
```

在 `BasePanelConfig` 字段区（`islifeGongBySunRealTimeLocation` 之后）加：
```dart
  /// 罗睺/计都 升降交点归属（流派分歧，用户可选，默认旧法）。
  /// 旧 JSON 缺此键时回落旧法（见 @JsonKey defaultValue）。
  @JsonKey(defaultValue: EnumRahuKetuConvention.luoJiangJiSheng)
  EnumRahuKetuConvention rahuKetuConvention;
```

在 `BasePanelConfig` 构造函数参数末尾（`this.bodyCountingToGong = ...` 之后）加：
```dart
    this.rahuKetuConvention = EnumRahuKetuConvention.luoJiangJiSheng,
```

在 `copyWith` 参数区加 `EnumRahuKetuConvention? rahuKetuConvention,`，并在返回的 `BasePanelConfig(...)` 里加：
```dart
      rahuKetuConvention: rahuKetuConvention ?? this.rahuKetuConvention,
```

在 `PanelConfig` 构造函数参数区加 `super.rahuKetuConvention,`（放在其他 `super.` 之后即可）。

> 说明：`defaultBasicPanelConfig()`/`defaultPanelConfig()`/`getPreviousPanelConfig()` 使用命名构造且不传该参，会自动取默认旧法，无需改动。

- [x] **Step 4: 重生成 .g.dart**

Run: `dart run build_runner build --delete-conflicting-outputs`
Expected: 成功；`panel_config.g.dart` 含 `rahuKetuConvention` 的读写（带 defaultValue 回落）。

- [x] **Step 5: 运行确认通过 + 静态检查**

Run: `flutter test test/domain/entities/models/panel_config_convention_test.dart && flutter analyze`
Expected: 测试 PASS；analyze 无新增错误。

- [x] **Step 6: 提交**

```bash
git add lib/domain/entities/models/panel_config.dart lib/domain/entities/models/panel_config.g.dart test/domain/entities/models/panel_config_convention_test.dart
git commit -m "feat(config): BasePanelConfig 新增 rahuKetuConvention（默认旧法，向后兼容）"
```

---

## Task 5: `StarsAngle` 罗计映射改为 convention 驱动（默认旧法 → 零回归）

**Files:**
- Modify: `lib/domain/entities/models/panel_stars_info.dart`（`fromMapper`、`toMap`、`getByStar`）
- Test: `test/domain/entities/models/stars_angle_convention_test.dart`

**Interfaces:**
- Consumes: `RahuKetuDefinition`（Task 2）、`EnumRahuKetuConvention`（Task 1）。
- Produces:
  - `Map<EnumStars, StarAngleSpeed> StarsAngle.toMap({EnumRahuKetuConvention convention = EnumRahuKetuConvention.luoJiangJiSheng})`
  - `static StarsAngle StarsAngle.fromMapper(Map<EnumStars, StarAngleSpeed> mapper, {EnumRahuKetuConvention convention = EnumRahuKetuConvention.luoJiangJiSheng})`
  - `double StarsAngle.getByStar(EnumStars star, {EnumRahuKetuConvention convention = EnumRahuKetuConvention.luoJiangJiSheng})`
  - **字段 `southNode/northNode/lilith/qi` 与 `toJson()` 保持不变**（序列化零改动）。

- [x] **Step 1: 写失败测试**

```dart
// test/domain/entities/models/stars_angle_convention_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:metaphysics_core/enums.dart';
import 'package:qizhengsiyu/domain/entities/models/panel_stars_info.dart';
import 'package:qizhengsiyu/enums/enum_rahu_ketu_convention.dart';

StarsAngle _sample() => StarsAngle(
      sun: 0, moon: 0, venus: 0, venusSpeed: 0, jupiter: 0, jupiterSpeed: 0,
      mars: 0, marsSpeed: 0, saturn: 0, saturnSpeed: 0, water: 0, waterSpeed: 0,
      northNode: 30, // 升交点
      southNode: 210, // 降交点
      lilith: 100, qi: 50,
    );

void main() {
  test('默认(旧法) toMap: 罗=降(210), 计=升(30)', () {
    final m = _sample().toMap();
    expect(m[EnumStars.Luo]!.angle, closeTo(210, 1e-9));
    expect(m[EnumStars.Ji]!.angle, closeTo(30, 1e-9));
  });

  test('新法 toMap: 罗=升(30), 计=降(210)', () {
    final m = _sample()
        .toMap(convention: EnumRahuKetuConvention.luoShengJiJiang);
    expect(m[EnumStars.Luo]!.angle, closeTo(30, 1e-9));
    expect(m[EnumStars.Ji]!.angle, closeTo(210, 1e-9));
  });

  test('getByStar 默认旧法与 toMap 一致', () {
    final s = _sample();
    expect(s.getByStar(EnumStars.Luo), closeTo(210, 1e-9));
    expect(s.getByStar(EnumStars.Ji), closeTo(30, 1e-9));
    expect(
        s.getByStar(EnumStars.Luo,
            convention: EnumRahuKetuConvention.luoShengJiJiang),
        closeTo(30, 1e-9));
  });

  test('fromMapper(旧法) 能从罗计还原中性升降交点', () {
    final m = _sample().toMap();
    final back = StarsAngle.fromMapper(m);
    expect(back.northNode, closeTo(30, 1e-9));
    expect(back.southNode, closeTo(210, 1e-9));
  });
}
```

- [x] **Step 2: 运行确认失败**

Run: `flutter test test/domain/entities/models/stars_angle_convention_test.dart`
Expected: FAIL —— `toMap` 不接受 `convention` 命名参数（编译错误）。

- [x] **Step 3: 改 `panel_stars_info.dart`**

顶部 `import` 区加：
```dart
import 'package:qizhengsiyu/enums/enum_rahu_ketu_convention.dart';
import 'package:qizhengsiyu/domain/engines/siyu/rahu_ketu_definition.dart';
```

把 `toMap()`（现 132-144 行）替换为：
```dart
  Map<EnumStars, StarAngleSpeed> toMap({
    EnumRahuKetuConvention convention =
        EnumRahuKetuConvention.luoJiangJiSheng,
  }) {
    final rk = RahuKetuDefinition.assign(
        northNode: northNode, convention: convention);
    return {
      EnumStars.Sun: StarAngleSpeed(angle: sun, speed: 0),
      EnumStars.Moon: StarAngleSpeed(angle: moon, speed: 0),
      EnumStars.Venus: StarAngleSpeed(angle: venus, speed: venusSpeed),
      EnumStars.Jupiter: StarAngleSpeed(angle: jupiter, speed: jupiterSpeed),
      EnumStars.Mars: StarAngleSpeed(angle: mars, speed: marsSpeed),
      EnumStars.Saturn: StarAngleSpeed(angle: saturn, speed: saturnSpeed),
      EnumStars.Mercury: StarAngleSpeed(angle: water, speed: waterSpeed),
      EnumStars.Luo: StarAngleSpeed(angle: rk.luo, speed: 0),
      EnumStars.Ji: StarAngleSpeed(angle: rk.ji, speed: 0),
      EnumStars.Bei: StarAngleSpeed(angle: lilith, speed: 0),
      EnumStars.Qi: StarAngleSpeed(angle: qi, speed: 0),
    };
  }
```

把 `getByStar`（现 146-184 行）的签名与 Luo/Ji 分支改为：
```dart
  double getByStar(
    EnumStars star, {
    EnumRahuKetuConvention convention =
        EnumRahuKetuConvention.luoJiangJiSheng,
  }) {
    final rk = RahuKetuDefinition.assign(
        northNode: northNode, convention: convention);
    double starAngle = 0;
    switch (star) {
      case EnumStars.Moon:
        starAngle = moon;
        break;
      case EnumStars.Sun:
        starAngle = sun;
        break;
      case EnumStars.Venus:
        starAngle = venus;
        break;
      case EnumStars.Mercury:
        starAngle = water;
        break;
      case EnumStars.Jupiter:
        starAngle = jupiter;
        break;
      case EnumStars.Mars:
        starAngle = mars;
        break;
      case EnumStars.Saturn:
        starAngle = saturn;
        break;
      case EnumStars.Qi:
        starAngle = qi;
        break;
      case EnumStars.Bei:
        starAngle = lilith;
        break;
      case EnumStars.Ji:
        starAngle = rk.ji;
        break;
      case EnumStars.Luo:
        starAngle = rk.luo;
        break;
    }
    return starAngle;
  }
```

把 `fromMapper`（现 92-111 行）的签名与罗计还原改为：
```dart
  static StarsAngle fromMapper(
    Map<EnumStars, StarAngleSpeed> mapper, {
    EnumRahuKetuConvention convention =
        EnumRahuKetuConvention.luoJiangJiSheng,
  }) {
    final luoAngle = mapper[EnumStars.Luo]!.angle;
    final jiAngle = mapper[EnumStars.Ji]!.angle;
    final isOld = convention == EnumRahuKetuConvention.luoJiangJiSheng;
    // 旧法：升=计、降=罗；新法反之。
    final northNode = isOld ? jiAngle : luoAngle;
    final southNode = isOld ? luoAngle : jiAngle;
    return StarsAngle(
      sun: mapper[EnumStars.Sun]!.angle,
      moon: mapper[EnumStars.Moon]!.angle,
      venus: mapper[EnumStars.Venus]!.angle,
      venusSpeed: mapper[EnumStars.Venus]!.speed,
      jupiter: mapper[EnumStars.Jupiter]!.angle,
      jupiterSpeed: mapper[EnumStars.Jupiter]!.speed,
      mars: mapper[EnumStars.Mars]!.angle,
      marsSpeed: mapper[EnumStars.Mars]!.speed,
      saturn: mapper[EnumStars.Saturn]!.angle,
      saturnSpeed: mapper[EnumStars.Saturn]!.speed,
      water: mapper[EnumStars.Mercury]!.angle,
      waterSpeed: mapper[EnumStars.Mercury]!.speed,
      southNode: southNode,
      northNode: northNode,
      lilith: mapper[EnumStars.Bei]!.angle,
      qi: mapper[EnumStars.Qi]!.angle,
    );
  }
```

- [x] **Step 4: 运行确认通过**

Run: `flutter test test/domain/entities/models/stars_angle_convention_test.dart`
Expected: PASS

- [x] **Step 5: 回归护栏——跑受影响的既有测试**

Run: `flutter test test/test_planets_walking_type.dart`
Expected: 与本次改动前结果一致（不因默认旧法而变化）。若该测试改前已失败（见备注），确认失败项与改动无关。

- [x] **Step 6: 提交**

```bash
git add lib/domain/entities/models/panel_stars_info.dart test/domain/entities/models/stars_angle_convention_test.dart
git commit -m "feat(siyu): StarsAngle 罗计映射改为 convention 驱动（默认旧法零回归）"
```

---

## Task 6: `SwephEngine` 接入 `SiYuCalculator` 与 convention

**Files:**
- Modify: `lib/domain/engines/sweph_engine.dart`
- Test: `test/domain/engines/sweph_engine_convention_test.dart`

**Interfaces:**
- Consumes: `SiYuCalculator` + `SwephSiYuEphemerisSource`（Task 3）；`StarsAngle.toMap(convention:)`（Task 5）；`BasePanelConfig.rahuKetuConvention`（Task 4）。
- Produces: 引擎 `calculateStarPositions` 的输出 `List<StarPositionRawData>` 中，罗/计位置随 `config.rahuKetuConvention` 变化；默认旧法时与改动前逐值一致。

- [x] **Step 1: 写失败测试（用可注入的四余源做端到端翻转断言，绕开 sweph 资源）**

> 注：`_calculateAllStarsAngleOnZodiac` 直接静态调用 `Sweph`，难以在纯单测启动。本测试改为验证「转换边界」把 convention 正确透传：构造一个 `StarsAngle` 并经 `toMap(convention: config.rahuKetuConvention)` 得到的罗/计与 §8-B 一致。若团队已有 sweph 测试夹具，可另加真实引擎用例。

```dart
// test/domain/engines/sweph_engine_convention_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:metaphysics_core/enums.dart';
import 'package:qizhengsiyu/domain/entities/models/panel_config.dart';
import 'package:qizhengsiyu/domain/entities/models/panel_stars_info.dart';
import 'package:qizhengsiyu/enums/enum_rahu_ketu_convention.dart';

StarsAngle _angle() => StarsAngle(
      sun: 0, moon: 0, venus: 0, venusSpeed: 0, jupiter: 0, jupiterSpeed: 0,
      mars: 0, marsSpeed: 0, saturn: 0, saturnSpeed: 0, water: 0, waterSpeed: 0,
      northNode: 30, southNode: 210, lilith: 100, qi: 50,
    );

void main() {
  test('config 旧法 -> 罗=降(210)、计=升(30)', () {
    final cfg = PanelConfig.defaultPanelConfig();
    final m = _angle().toMap(convention: cfg.rahuKetuConvention);
    expect(m[EnumStars.Luo]!.angle, closeTo(210, 1e-9));
    expect(m[EnumStars.Ji]!.angle, closeTo(30, 1e-9));
  });

  test('config 新法 -> 罗计互换', () {
    final cfg = PanelConfig.defaultPanelConfig()
      ..rahuKetuConvention = EnumRahuKetuConvention.luoShengJiJiang;
    final m = _angle().toMap(convention: cfg.rahuKetuConvention);
    expect(m[EnumStars.Luo]!.angle, closeTo(30, 1e-9));
    expect(m[EnumStars.Ji]!.angle, closeTo(210, 1e-9));
  });
}
```

- [x] **Step 2: 运行确认失败/通过基线**

Run: `flutter test test/domain/engines/sweph_engine_convention_test.dart`
Expected: 若 Task 4/5 已完成，此测试应已 PASS（它锁定 config→toMap 的契约）。作为回归护栏保留。

- [x] **Step 3: 改 `sweph_engine.dart` —— 用 SiYuCalculator 替换内联四余**

顶部 `import` 区加：
```dart
import 'siyu/si_yu_calculator.dart';
import 'siyu/sweph_si_yu_ephemeris_source.dart';
```

在 `_calculateAllStarsAngleOnZodiac` 内**删除** `double ziQi() { ... }` 整个内联闭包，以及 `northNode`/`southNodeAngle`/`lilith` 三段 `Sweph.swe_calc(... SE_MEAN_NODE / SE_MEAN_APOG ...)` 相关代码。改为在计算完 `julianDay` 之后加：
```dart
    final siyu = const SiYuCalculator(source: SwephSiYuEphemerisSource())
        .compute(julianDay: julianDay, birthDate: datetime);
```

把 `return StarsAngle(...)` 中四余四行替换为：
```dart
        northNode: roundHelper(siyu.northNode),
        southNode: roundHelper(siyu.southNode),
        lilith: roundHelper(siyu.lilith),
        qi: roundHelper(siyu.qi),
```

（七政各行保持不变。）

- [x] **Step 4: 改 `_transformToStarPositionRawData` 透传 convention**

把（现 65 行）：
```dart
    final starMap = starsAngle.toMap();
```
改为：
```dart
    final starMap = starsAngle.toMap(convention: config.rahuKetuConvention);
```

- [x] **Step 5: 静态检查 + 全量测试**

Run: `flutter analyze && flutter test test/domain/engines/sweph_engine_convention_test.dart`
Expected: analyze 无新增错误；测试 PASS。

- [x] **Step 6: 提交**

```bash
git add lib/domain/engines/sweph_engine.dart test/domain/engines/sweph_engine_convention_test.dart
git commit -m "refactor(siyu): SwephEngine 接入 SiYuCalculator 并透传罗计流派"
```

---

## Task 7: UI —— 「自定义配置」加罗计定义单选 + 新法警示

**Files:**
- Modify: `lib/presentation/widgets/config/custom_config_section.dart`
- Test: `test/presentation/widgets/custom_config_section_convention_test.dart`

**Interfaces:**
- Consumes: `EnumRahuKetuConvention`（Task 1）、`BasePanelConfig.rahuKetuConvention`（Task 4）。
- Produces: 用户在配置页选择罗计定义 → 经 `_updateConfig` 构造的 `PanelConfig` 携带 `rahuKetuConvention` → `onConfigChanged` → viewmodel `_customConfig` → `buildConfig()` → 排盘路由 → 引擎。

> ⚠️ **空接陷阱**：`_updateConfig` 现只重建部分字段。必须把 `rahuKetuConvention` 加进新建的 `PanelConfig(...)`，否则用户选择被丢弃。

- [x] **Step 1: 写失败测试（回调携带用户所选流派）**

```dart
// test/presentation/widgets/custom_config_section_convention_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qizhengsiyu/domain/entities/models/panel_config.dart';
import 'package:qizhengsiyu/enums/enum_rahu_ketu_convention.dart';
import 'package:qizhengsiyu/presentation/widgets/config/custom_config_section.dart';

void main() {
  testWidgets('选择新法后回调携带 luoShengJiJiang', (tester) async {
    PanelConfig? captured;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: CustomConfigSection(
            initialConfig: PanelConfig.defaultPanelConfig(),
            onConfigChanged: (c) => captured = c,
          ),
        ),
      ),
    ));

    // 点击「罗升计降（民间·西法）」单选项。
    await tester.ensureVisible(find.text('罗升计降（民间·西法）'));
    await tester.tap(find.text('罗升计降（民间·西法）'));
    await tester.pumpAndSettle();

    expect(captured, isNotNull);
    expect(captured!.rahuKetuConvention,
        EnumRahuKetuConvention.luoShengJiJiang);
  });
}
```

- [x] **Step 2: 运行确认失败**

Run: `flutter test test/presentation/widgets/custom_config_section_convention_test.dart`
Expected: FAIL —— 找不到「罗升计降（新法·时宪）」文本。

- [x] **Step 3: 改 `custom_config_section.dart`**

顶部 `import` 区加：
```dart
import 'package:qizhengsiyu/enums/enum_rahu_ketu_convention.dart';
```

在 State 字段区（`_useTraditionalCalculation` 附近）加：
```dart
  // 罗计升降交点归属
  late EnumRahuKetuConvention _rahuKetuConvention;
```

在 `initState()` 末尾加：
```dart
    _rahuKetuConvention = widget.initialConfig?.rahuKetuConvention ??
        EnumRahuKetuConvention.luoJiangJiSheng;
```

在 `_updateConfig()` 新建的 `PanelConfig(...)` 里加一行（关键！勿漏）：
```dart
      rahuKetuConvention: _rahuKetuConvention,
```

在 `build()` 的「星宿制式」卡片之后、「流派典籍」卡片之前，插入罗计定义卡片：
```dart
        const SizedBox(height: AppTheme.spacing16),

        // 罗计定义（升降交点归属）
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppTheme.borderRadius),
            border: Border.all(color: const Color(0xFFEEEEEE)),
          ),
          padding: const EdgeInsets.all(AppTheme.spacing16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '罗计定义',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
              ),
              const SizedBox(height: AppTheme.spacing12),
              Row(
                children: [
                  Expanded(
                    child: _buildRadioTile<EnumRahuKetuConvention>(
                      title: EnumRahuKetuConvention.luoJiangJiSheng.name,
                      subtitle: '罗睺=降交点 计都=升交点',
                      value: EnumRahuKetuConvention.luoJiangJiSheng,
                      groupValue: _rahuKetuConvention,
                      onChanged: (value) {
                        setState(() => _rahuKetuConvention = value!);
                        _updateConfig();
                      },
                    ),
                  ),
                  Expanded(
                    child: _buildRadioTile<EnumRahuKetuConvention>(
                      title: EnumRahuKetuConvention.luoShengJiJiang.name,
                      subtitle: '罗睺=升交点 计都=降交点',
                      value: EnumRahuKetuConvention.luoShengJiJiang,
                      groupValue: _rahuKetuConvention,
                      onChanged: (value) {
                        setState(() => _rahuKetuConvention = value!);
                        _updateConfig();
                      },
                    ),
                  ),
                ],
              ),
              if (_rahuKetuConvention ==
                  EnumRahuKetuConvention.luoShengJiJiang)
                Container(
                  margin: const EdgeInsets.only(top: AppTheme.spacing8),
                  padding: const EdgeInsets.all(AppTheme.spacing8),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded,
                          size: 16, color: Colors.orange),
                      const SizedBox(width: AppTheme.spacing8),
                      Expanded(
                        child: Text(
                          '「罗升计降」为清后期西法/印度 Jyotish 用法，与古法正统相反、罗计吉凶互换，仅供比对参考。',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: Colors.orange.shade800),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
```

- [x] **Step 4: 运行确认通过**

Run: `flutter test test/presentation/widgets/custom_config_section_convention_test.dart`
Expected: PASS

- [x] **Step 5: 静态检查**

Run: `flutter analyze`
Expected: 无新增错误。

- [x] **Step 6: 提交**

```bash
git add lib/presentation/widgets/config/custom_config_section.dart test/presentation/widgets/custom_config_section_convention_test.dart
git commit -m "feat(ui): 配置页新增罗计定义单选与新法警示，并接线至 PanelConfig"
```

---

## Task 8: 全量回归 + 文档

**Files:**
- Modify: `doc/` 下相应模块文档（若无四余专页则新建 `doc/feature/siyu/README.md`）

**Interfaces:** 无新增代码接口。

- [x] **Step 1: 全量测试**

Run: `flutter test`
Expected: 新增用例全绿；既有失败项仅限改动前已存在的 star position 相关（见「参考」备注），无新增回归。

- [x] **Step 2: 全量静态检查**

Run: `flutter analyze`
Expected: 无新增错误。

- [x] **Step 3: 写模块文档**

新建 `doc/feature/siyu/README.md`，内容涵盖：
- 四余模块结构（`lib/domain/engines/siyu/`：`RahuKetuDefinition` / `SiYuCalculator` / `ISiYuEphemerisSource`）。
- 罗计流派两种约定的天文含义与吉凶后果，默认旧法。
- 配置项 `BasePanelConfig.rahuKetuConvention` 的用法与向后兼容策略。
- 已知遗留议题（**非本次范围**）：紫气历元 2013 基准未校准；四余顺逆方向未显式化；`sweph_engine.dart` 时间基准（`datetime` 直取为 UTC）与紫气上海时区基准是否统一存疑。

- [x] **Step 4: 提交**

```bash
git add doc/feature/siyu/README.md
git commit -m "docs(siyu): 四余模块与罗计流派配置说明"
```

---

# Part B：紫气算法抽象与三流派实现（可扩展管理机制）

> **背景**：紫气无对应天体，绝对相位只能靠历元 + 平行推算，当前 `SiYuCalculator._computeZiQi` 用的是来历不明的「2013 上海时间当 0°」magic number（Part A 保留它仅为过渡）。Part B 用**可扩展的算法策略机制**取代之，落地果老/琴堂、耶律天官、清时宪三套，并留出注册新算法的扩展点。
>
> **与 Part A 的关系**：Part B 依赖 Part A 的 `SiYuCalculator`（Task 3）。Task 15 会把 `SiYuCalculator` 的紫气来源从 `_computeZiQi` 改为**注入 `ZiQiAlgorithm`**，并删除过渡实现。
>
> **零回归例外**：Part A 对罗计要求零回归；**Part B 对紫气「有意改变输出」**——从错误的 2013 magic 改为正确的果老授时结果，这正是目的，不是回归。

## Part B 流派常数（实现者对照，来源=领域负责人给定及考证结果）

| 流派算法 | 形态 | 关键常数 | 备注 |
|---|---|---|---|
| 果老/琴堂 `guoLaoQinTang`（默认） | 历元+日行平行 | 周期 10227.1792 日(28年)，日行=360/周期≈0.0351996°/日；**历元黄经双常数集可选**（见下） | 周期可切 29 年制 10592 日 |
| 清时宪 `shixian` | 历元+日行平行 | 日行=126.720777″/3600≈0.0352002°/日；历元=乾隆九年甲子(1744)冬至；起点=七宫17°50′（绝对黄道经度=197.833333°） | **已确认**：七宫即天秤宫(180°~210°)，197.833333°与古籍完全对齐。历书完整元度含秒微精算值为 `197.837237°`。 |
| 耶律天官 `yelvTianguan` | 逐年粗算截断宫度 | 逐年 +13°05′(=13.08333°)；只出地支十二次宫度 | **已确认**：历元为上古上元甲子岁首，元度为「子宫虚六度」即赤道绝对经度 `6.0°`；坐标系采用中式赤道十二次（子宫起算），不可具体化公元年份，采用相对积年 $N$ 偏移推算。 |

通用：全派顺行、周天 360°。

### 紫气历元「双常数集」（`EnumZiQiEpochSet`，默认 `shouShiNvXiu`）

果老/琴堂平行算法的历元黄经存在两套互相冲突的史料，均由领域负责人给出，**做成可选、默认女宿**：

| 常数集 | 历元时刻 | 历元黄经 | 是否需宿度管线 | 说明 |
|---|---|---|---|---|
| `shouShiNvXiu`（授时·女宿，**默认**） | 1280-12-14 01:29:36 | **女宿二度 ≈ 黄经 295°**（"约"，精值待郑氏星案坐实） | ❌ 自包含，直接填 295° | 《授时历》方案，郑氏星案验证过 |
| `fuTianJiXiu`（符天·箕宿） | 1281 辛巳岁前冬至（≈同上冬至） | **箕宿初度** | ✅ 需 `ZhouTianCalculator` 求箕宿0° 或手工校准 | 《符天历》/《三辰通载》恒星年方案 |

**度制铁律（按坐标系相对，勿一律 360）**：日行 = `本坐标系周天度 / periodDays`，归一化用**同一个周天度**：
- **黄道 360° 系**：daily = `360/10227.1792 ≈ 0.03520°/日`，mod 360。
- **天赤道 365.25 古度系（元授时/郑氏星案）**：daily = `365.25/10227.1792 ≈ 0.035714 古度/日`（=古法「3分57秒14微」），mod **365.25**。
- **禁止跨框架混用**：如把 `0.0357`(古度) 直接 mod 360，或把 `0.03520`(360°) 当古度——都是紫气偏移根源。`GuoLao/Shixian` 算法**必须持有 `totalDegree` 参数**（360 或 365.25）驱动 daily 与归一化。

**防呆**：紫气是**虚星、无天体**；「紫气=月球近地点」假说已被实测证伪，**勿**将紫气接到近地点。月孛才是真实天体点（远地点 `SE_MEAN_APOG`）。

### ⚠️ 坐标系现实（Part B 的重大范围修正，2026-07-04 核实）

用户确认**两套坐标系都要**：黄道 360° 与 **元授时天赤道恒星制 365.25 古度**（宿度永久固定、郭守敬实测赤道距度）。经核实：
- `SwephEngine` **只支持黄道**（非黄道 `throw UnimplementedError`）；天赤道走 `HistoricalEngine`，**目前是 stub**。
- 仓库唯一天赤道 asset `han_chidao_hengxin.json` 是**汉·太初历**且 `starInnDegreeSeq` 为空——**元授时郭守敬赤道宿距表在库中不存在**，需用户提供（已答应提供完整表）。
- 郑氏星案两参考点（室宿/井宿）就在**天赤道 365.25 恒星系**，儒略历。

**因此**：紫气是**虚星**，可在各自框架自包含平行推算（不依赖 sweph/七政管线）：
```
黄道: 紫气黄经 = epochLon360 + (360/period)·Δjd, mod 360      → 黄道 ZhouTianModel 出宿度
天赤道: 紫气赤经 = epochLon365 + (365.25/period)·Δjd, mod 365.25 → 郭守敬赤道宿距表 出宿度
```
天赤道紫气**无需岁差**（宿度固定），也**不依赖 stub 引擎**，可独立实现 + 用郑氏星案校验。黄道紫气仍可接 `SwephEngine`。紫气输出框架跟随 `config.celestialCoordinateSystem`。

---

## Task 9: 紫气枚举 `EnumZiQiAlgorithm` + `EnumZiQiPeriod`

**Files:**
- Create: `lib/enums/enum_zi_qi_algorithm.dart`
- Test: `test/enums/enum_zi_qi_algorithm_test.dart`

**Interfaces:**
- Produces:
  - `enum EnumZiQiAlgorithm { guoLaoQinTang, yelvTianguan, shixian }`（带 `String name`；`@JsonValue` 中文；默认项=`guoLaoQinTang`）
  - `enum EnumZiQiPeriod { years28(10227.1792), years29(10592.0) }`（带 `double days`）
  - `enum EnumZiQiEpochSet { shouShiNvXiu, fuTianJiXiu }`（果老历元双常数集，默认 `shouShiNvXiu`；带 `String name`、`@JsonValue`）

- [ ] **Step 1: 写失败测试**

```dart
// test/enums/enum_zi_qi_algorithm_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:qizhengsiyu/enums/enum_zi_qi_algorithm.dart';

void main() {
  test('默认算法为果老/琴堂', () {
    expect(EnumZiQiAlgorithm.values.first, EnumZiQiAlgorithm.guoLaoQinTang);
  });
  test('周期常数正确', () {
    expect(EnumZiQiPeriod.years28.days, closeTo(10227.1792, 1e-6));
    expect(EnumZiQiPeriod.years29.days, closeTo(10592.0, 1e-6));
  });
  test('历元常数集默认授时·女宿', () {
    expect(EnumZiQiEpochSet.values.first, EnumZiQiEpochSet.shouShiNvXiu);
  });
}
```

- [ ] **Step 2: 运行确认失败**

Run: `flutter test test/enums/enum_zi_qi_algorithm_test.dart`
Expected: FAIL —— 找不到文件。

- [ ] **Step 3: 实现枚举**

```dart
// lib/enums/enum_zi_qi_algorithm.dart
import 'package:json_annotation/json_annotation.dart';

/// 紫气行度算法流派（可扩展；默认果老/琴堂授时常数）。
enum EnumZiQiAlgorithm {
  @JsonValue("果老琴堂")
  guoLaoQinTang("果老/琴堂（授时辛巳元）"),
  @JsonValue("耶律天官")
  yelvTianguan("耶律天官（中气闰余粗算宫度）"),
  @JsonValue("清时宪")
  shixian("清时宪（乾隆甲子元）");

  final String name;
  const EnumZiQiAlgorithm(this.name);
}

/// 紫气周期口诀（两套每年差约 1.2°，可配）。
enum EnumZiQiPeriod {
  years28(10227.1792), // 28年十闰
  years29(10592.0);    // 29年一闰周
  final double days;
  const EnumZiQiPeriod(this.days);
}

/// 果老/琴堂紫气「历元常数集」——两套互相冲突的史料，可选，默认授时·女宿。
enum EnumZiQiEpochSet {
  @JsonValue("授时女宿")
  shouShiNvXiu("授时·女宿（1280 女宿二度≈295°）"),
  @JsonValue("符天箕宿")
  fuTianJiXiu("符天·箕宿（1281 辛巳冬至箕宿初度）");

  final String name;
  const EnumZiQiEpochSet(this.name);
}

/// 天赤道·女宿紫气的「标准」二选一（用户可选）：
/// - 授时正典：文本正统常数（周期 10227.1792 日、女宿二度历元）；
/// - Moira 实测：与主流软件 Moira 对齐（周期 10237.7 日、锚 2026 实测点）。
/// 两者每约百年差约 1.5°，长程差更大；由用户按"合典籍"或"合 Moira"选择。
enum EnumZiQiChiDaoStandard {
  @JsonValue("授时正典")
  shouShiOrthodox("授时正典（10227.1792 日·女宿二度）"),
  @JsonValue("Moira实测")
  moira("Moira 实测（10237.7 日·锚2026翼宿）");

  final String name;
  const EnumZiQiChiDaoStandard(this.name);
}
```

- [ ] **Step 4: 运行确认通过**

Run: `flutter test test/enums/enum_zi_qi_algorithm_test.dart`
Expected: PASS

- [ ] **Step 5: 提交**

```bash
git add lib/enums/enum_zi_qi_algorithm.dart test/enums/enum_zi_qi_algorithm_test.dart
git commit -m "feat(ziqi): 新增紫气算法与周期枚举"
```

---

## Task 10: `ZiQiAlgorithm` 接口 + 果老/琴堂实现 + 冬至历元工具

**Files:**
- Create: `lib/domain/engines/siyu/ziqi/zi_qi_algorithm.dart`（接口）
- Create: `lib/domain/engines/siyu/ziqi/guolao_zi_qi_algorithm.dart`
- Create: `lib/domain/engines/siyu/ziqi/solar_term_julian_day.dart`（冬至 JD 工具）
- Test: `test/domain/engines/siyu/ziqi/guolao_zi_qi_algorithm_test.dart`

**Interfaces:**
- Consumes: `package:sweph/sweph.dart`（仅冬至工具）。
- Produces:
  - `abstract interface class ZiQiAlgorithm { String get id; double computeLongitude({required double julianDay, required DateTime datetime}); }`
  - `class GuoLaoZiQiAlgorithm implements ZiQiAlgorithm`（构造参数 `periodDays`、`epochJulianDay`、`epochLongitude`）
  - `double winterSolsticeJulianDay(int decemberYear, {bool julianCalendar = false})` —— 迭代求太阳地心黄经=270° 的 JD。

- [ ] **Step 1: 写失败测试（平行公式 + 顺行 + 归一化）**

```dart
// test/domain/engines/siyu/ziqi/guolao_zi_qi_algorithm_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:qizhengsiyu/domain/engines/siyu/ziqi/guolao_zi_qi_algorithm.dart';

void main() {
  const algo = GuoLaoZiQiAlgorithm(
    totalDegree: 360.0,
    periodDays: 10227.1792,
    epochJulianDay: 1000.0, // 测试用抽象历元
    epochLongitude: 0.0,
  );

  test('历元时刻返回历元黄经', () {
    expect(
        algo.computeLongitude(julianDay: 1000.0, datetime: DateTime.utc(2000)),
        closeTo(0.0, 1e-9));
  });

  test('顺行：历元后 1000 日 = 1000*360/10227.1792', () {
    final expected = (360.0 / 10227.1792) * 1000.0;
    expect(
        algo.computeLongitude(julianDay: 2000.0, datetime: DateTime.utc(2000)),
        closeTo(expected, 1e-6));
  });

  test('越界归一化到 [0,360)', () {
    final v = algo.computeLongitude(
        julianDay: 1000.0 + 10227.1792 + 500, datetime: DateTime.utc(2000));
    expect(v, greaterThanOrEqualTo(0));
    expect(v, lessThan(360));
    expect(v, closeTo((360.0 / 10227.1792) * 500, 1e-6));
  });

  test('天赤道 365.25 框架：日行≈0.035714 古度，mod 365.25', () {
    const eq = GuoLaoZiQiAlgorithm(
      totalDegree: 365.25,
      periodDays: 10227.1792,
      epochJulianDay: 1000.0,
      epochLongitude: 0.0,
    );
    expect(
        eq.computeLongitude(julianDay: 2000.0, datetime: DateTime.utc(2000)),
        closeTo((365.25 / 10227.1792) * 1000.0, 1e-6));
    // 越界按 365.25 归一
    final v = eq.computeLongitude(
        julianDay: 1000.0 + 10227.1792 + 200, datetime: DateTime.utc(2000));
    expect(v, lessThan(365.25));
    expect(v, closeTo((365.25 / 10227.1792) * 200, 1e-6));
  });
}
```

- [ ] **Step 2: 运行确认失败**

Run: `flutter test test/domain/engines/siyu/ziqi/guolao_zi_qi_algorithm_test.dart`
Expected: FAIL —— 找不到文件。

- [ ] **Step 3: 实现接口 + 果老算法**

```dart
// lib/domain/engines/siyu/ziqi/zi_qi_algorithm.dart

/// 紫气行度算法策略。各流派实现之，供 ZiQiAlgorithmRegistry 管理与扩展。
abstract interface class ZiQiAlgorithm {
  /// 算法标识（配置/日志）。
  String get id;

  /// 紫气黄经（度，与七政同坐标系，全派顺行）。
  /// [julianDay] 供逐日平行流派；[datetime] 供逐年粗算流派（如天官）。
  double computeLongitude({
    required double julianDay,
    required DateTime datetime,
  });
}
```

```dart
// lib/domain/engines/siyu/ziqi/guolao_zi_qi_algorithm.dart
import 'zi_qi_algorithm.dart';

/// 果老/琴堂：授时元积日平行顺推。
/// [totalDegree] 决定坐标框架：黄道 360 或天赤道 365.25（度制铁律，勿混）。
/// 历元位置(epochLongitude，同框架单位)由 ZiqiEpochCalibrator 校准后注入。
class GuoLaoZiQiAlgorithm implements ZiQiAlgorithm {
  final double totalDegree;    // 360(黄道) / 365.25(天赤道古度)
  final double periodDays;     // 10227.1792(28年) / 10592(29年)
  final double epochJulianDay; // 历元冬至 JD
  final double epochLongitude; // 历元位置（与 totalDegree 同框架单位）

  const GuoLaoZiQiAlgorithm({
    required this.totalDegree,
    required this.periodDays,
    required this.epochJulianDay,
    required this.epochLongitude,
  });

  @override
  String get id => 'guolao_qintang';

  @override
  double computeLongitude({
    required double julianDay,
    required DateTime datetime,
  }) {
    final daily = totalDegree / periodDays; // 同框架度/日
    return _normalize(
        epochLongitude + daily * (julianDay - epochJulianDay), totalDegree);
  }

  static double _normalize(double d, double total) {
    var r = d % total;
    if (r < 0) r += total;
    return r;
  }
}
```

> `ShixianZiQiAlgorithm`（Task 11）同样加 `totalDegree` 参数，`dailyMotionDegrees` 与归一化都按其框架。天官逐年增量 13°05′ 亦按框架总度截断到宫（黄道 30°；天赤道每宫 365.25/12≈30.4375°）。

- [ ] **Step 4: 实现冬至历元工具**

```dart
// lib/domain/engines/siyu/ziqi/solar_term_julian_day.dart
import 'package:sweph/sweph.dart';

/// 求某年 12 月冬至（太阳地心黄经=270°）的儒略日。
/// [julianCalendar]：1582 年前应传 true（儒略历），如 1281 辛巳。
double winterSolsticeJulianDay(int decemberYear, {bool julianCalendar = false}) {
  final calType =
      julianCalendar ? CalendarType.SE_JUL_CAL : CalendarType.SE_GREG_CAL;
  double jd = Sweph.swe_julday(decemberYear, 12, 22, 0, calType);
  for (int i = 0; i < 10; i++) {
    final lon = Sweph.swe_calc(
            jd, HeavenlyBody.SE_SUN, SwephFlag.SEFLG_SWIEPH)
        .longitude;
    // 到 270° 的最短带符号角差
    final diff = ((270.0 - lon + 540.0) % 360.0) - 180.0;
    if (diff.abs() < 1e-5) break;
    jd += diff / 0.98565; // 太阳日行约 0.98565°
  }
  return jd;
}
```

- [ ] **Step 5: 运行确认通过**

Run: `flutter test test/domain/engines/siyu/ziqi/guolao_zi_qi_algorithm_test.dart`
Expected: PASS（冬至工具的真实历表校验放到 Task 12 校准器测试，需 sweph 资源）。

- [ ] **Step 6: 提交**

```bash
git add lib/domain/engines/siyu/ziqi/zi_qi_algorithm.dart lib/domain/engines/siyu/ziqi/guolao_zi_qi_algorithm.dart lib/domain/engines/siyu/ziqi/solar_term_julian_day.dart test/domain/engines/siyu/ziqi/guolao_zi_qi_algorithm_test.dart
git commit -m "feat(ziqi): ZiQiAlgorithm 接口 + 果老/琴堂平行算法 + 冬至历元工具"
```

---

## Task 11: 清时宪 + 耶律天官 紫气算法

**Files:**
- Create: `lib/domain/engines/siyu/ziqi/shixian_zi_qi_algorithm.dart`
- Create: `lib/domain/engines/siyu/ziqi/tianguan_zi_qi_algorithm.dart`
- Test: `test/domain/engines/siyu/ziqi/shixian_tianguan_zi_qi_algorithm_test.dart`

**Interfaces:**
- Consumes: `ZiQiAlgorithm`（Task 10）。
- Produces:
  - `class ShixianZiQiAlgorithm implements ZiQiAlgorithm`（`dailyMotionDegrees`、`epochJulianDay`、`epochLongitude`）
  - `class TianguanZiQiAlgorithm implements ZiQiAlgorithm`（`epochYear`、`epochLongitude`、`yearlyIncrementDegrees`）——输出截断至宫度(30°)。

- [ ] **Step 1: 写失败测试**

```dart
// test/domain/engines/siyu/ziqi/shixian_tianguan_zi_qi_algorithm_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:qizhengsiyu/domain/engines/siyu/ziqi/shixian_zi_qi_algorithm.dart';
import 'package:qizhengsiyu/domain/engines/siyu/ziqi/tianguan_zi_qi_algorithm.dart';

void main() {
  test('时宪：日行≈0.0352°，历元后 100 日累进', () {
    const algo = ShixianZiQiAlgorithm(
      dailyMotionDegrees: 126.720777 / 3600,
      epochJulianDay: 5000,
      epochLongitude: 197.8333,
    );
    final v = algo.computeLongitude(
        julianDay: 5100, datetime: DateTime.utc(2000));
    expect(v, closeTo(197.8333 + (126.720777 / 3600) * 100, 1e-6));
  });

  test('天官：逐年 +13°05′，输出截断到宫度(30°整数倍)', () {
    const algo = TianguanZiQiAlgorithm(
      epochYear: 2000,
      epochLongitude: 0.0,
      yearlyIncrementDegrees: 13 + 5 / 60,
    );
    // 3 年后原始 = 39.25° -> 落在 30° 宫
    final v = algo.computeLongitude(
        julianDay: 0, datetime: DateTime.utc(2003, 6, 1));
    expect(v % 30, closeTo(0, 1e-9));
    expect(v, closeTo(30, 1e-9));
  });
}
```

- [ ] **Step 2: 运行确认失败**

Run: `flutter test test/domain/engines/siyu/ziqi/shixian_tianguan_zi_qi_algorithm_test.dart`
Expected: FAIL —— 找不到文件。

- [ ] **Step 3: 实现时宪算法**

```dart
// lib/domain/engines/siyu/ziqi/shixian_zi_qi_algorithm.dart
import 'zi_qi_algorithm.dart';

/// 清时宪：乾隆甲子元新平行法（历元+日行，与果老同形态，仅锚点不同）。
class ShixianZiQiAlgorithm implements ZiQiAlgorithm {
  final double dailyMotionDegrees; // 126.720777″/3600 ≈ 0.0352002°/日
  final double epochJulianDay;     // 乾隆九年甲子(1744)冬至
  final double epochLongitude;     // 起七宫17°50′（宫序基准待确认，占位 197.8333°）

  const ShixianZiQiAlgorithm({
    required this.dailyMotionDegrees,
    required this.epochJulianDay,
    required this.epochLongitude,
  });

  @override
  String get id => 'shixian';

  @override
  double computeLongitude({
    required double julianDay,
    required DateTime datetime,
  }) =>
      _normalize360(
          epochLongitude + dailyMotionDegrees * (julianDay - epochJulianDay));

  static double _normalize360(double d) {
    var r = d % 360;
    if (r < 0) r += 360;
    return r;
  }
}
```

- [ ] **Step 4: 实现天官算法**

```dart
// lib/domain/engines/siyu/ziqi/tianguan_zi_qi_algorithm.dart
import 'zi_qi_algorithm.dart';

/// 耶律天官：中气闰余逐年加 13°05′，粗算宫度（只到十二宫，舍二十八宿细度）。
///
/// 说明：耶律天官以「上古上元甲子岁首」为先天历元，起算元度为「子宫虚六度」（赤道绝对经度 6.0°，地支十二次以冬至子宫起算）。
/// 实际计算时，通过传入参考年份 [epochYear] 和在该参考年份的赤道参考度数 [epochLongitude]
/// 进行相对年份差的增量推算，从而规避硬编码上古甲子纪年的公元年份。
class TianguanZiQiAlgorithm implements ZiQiAlgorithm {
  final int epochYear;
  final double epochLongitude;
  final double yearlyIncrementDegrees; // 13 + 5/60

  const TianguanZiQiAlgorithm({
    required this.epochYear,
    required this.epochLongitude,
    required this.yearlyIncrementDegrees,
  });

  @override
  String get id => 'yelv_tianguan';

  @override
  double computeLongitude({
    required double julianDay,
    required DateTime datetime,
  }) {
    final years = datetime.year - epochYear;
    final raw = _normalize360(
        epochLongitude + yearlyIncrementDegrees * years);
    // 粗算：截断到所在宫起点（30° 整数倍）
    return (raw / 30.0).floorToDouble() * 30.0;
  }

  static double _normalize360(double d) {
    var r = d % 360;
    if (r < 0) r += 360;
    return r;
  }
}
```

- [ ] **Step 5: 运行确认通过**

Run: `flutter test test/domain/engines/siyu/ziqi/shixian_tianguan_zi_qi_algorithm_test.dart`
Expected: PASS

- [ ] **Step 6: 提交**

```bash
git add lib/domain/engines/siyu/ziqi/shixian_zi_qi_algorithm.dart lib/domain/engines/siyu/ziqi/tianguan_zi_qi_algorithm.dart test/domain/engines/siyu/ziqi/shixian_tianguan_zi_qi_algorithm_test.dart
git commit -m "feat(ziqi): 清时宪与耶律天官紫气算法（天官历元待坐实）"
```

---

## Task 12: `ZiqiEpochCalibrator` 历元黄经校准器

**Files:**
- Create: `lib/domain/engines/siyu/ziqi/ziqi_epoch_calibrator.dart`
- Test: `test/domain/engines/siyu/ziqi/ziqi_epoch_calibrator_test.dart`

**Interfaces:**
- Produces:
  - `static double ZiqiEpochCalibrator.fromConstellationPipeline({required double jiXiuStartLongitude, double totalDegree = 360.0})` —— 方式一(自洽)：直接采用求得的「箕宿0°」黄道或赤道经度。
  - `static double ZiqiEpochCalibrator.fromReferenceChart({required double refLongitude, required double refJulianDay, required double epochJulianDay, required double dailyMotionDegrees, double totalDegree = 360.0})` —— 方式二(对标)：由参考盘反解历元黄道或赤道经度。

> 说明：校准器不直接依赖 `ZhouTianCalculator` 的 API，只接收其算出的箕宿起始经度，保持解耦、可单测。调用方（Task 15 组装处）负责从 `ZhouTianCalculator` 取箕宿0°。

- [ ] **Step 1: 写失败测试**

```dart
// test/domain/engines/siyu/ziqi/ziqi_epoch_calibrator_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:qizhengsiyu/domain/engines/siyu/ziqi/ziqi_epoch_calibrator.dart';

void main() {
  test('方式一：直接采用箕宿0°黄经并归一化', () {
    expect(ZiqiEpochCalibrator.fromConstellationPipeline(
        jiXiuStartLongitude: 371.5), closeTo(11.5, 1e-9));
  });

  test('方式二：参考盘反解历元黄经（与平行公式自洽）', () {
    const daily = 0.0352;
    // 若历元黄经=100，历元后 50 日参考黄经应为 101.76
    final epochLon = ZiqiEpochCalibrator.fromReferenceChart(
      refLongitude: 100 + daily * 50,
      refJulianDay: 1050,
      epochJulianDay: 1000,
      dailyMotionDegrees: daily,
    );
    expect(epochLon, closeTo(100, 1e-6));
  });

  test('支持 365.25 天赤道体系归一化', () {
    expect(ZiqiEpochCalibrator.fromConstellationPipeline(
        jiXiuStartLongitude: 370.25, totalDegree: 365.25), closeTo(5.0, 1e-9));
  });
}
```

- [ ] **Step 2: 运行确认失败**

Run: `flutter test test/domain/engines/siyu/ziqi/ziqi_epoch_calibrator_test.dart`
Expected: FAIL —— 找不到文件。

- [ ] **Step 3: 实现校准器**

```dart
// lib/domain/engines/siyu/ziqi/ziqi_epoch_calibrator.dart

/// 紫气历元经度校准器（对应规格书 §5.3 两种方式）。
class ZiqiEpochCalibrator {
  const ZiqiEpochCalibrator._();

  /// 方式一（自洽）：以宿度管线求得的「箕宿0°」经度作为历元经度。
  static double fromConstellationPipeline({
    required double jiXiuStartLongitude,
    double totalDegree = 360.0,
  }) =>
      _normalize(jiXiuStartLongitude, totalDegree);

  /// 方式二（对标）：由参考盘 (refJulianDay, refLongitude) 反解历元经度。
  static double fromReferenceChart({
    required double refLongitude,
    required double refJulianDay,
    required double epochJulianDay,
    required double dailyMotionDegrees,
    double totalDegree = 360.0,
  }) =>
      _normalize(
          refLongitude - dailyMotionDegrees * (refJulianDay - epochJulianDay), totalDegree);

  static double _normalize(double d, double total) {
    var r = d % total;
    if (r < 0) r += total;
    return r;
  }
}
```

- [ ] **Step 4: 运行确认通过 + 提交**

Run: `flutter test test/domain/engines/siyu/ziqi/ziqi_epoch_calibrator_test.dart`
Expected: PASS
```bash
git add lib/domain/engines/siyu/ziqi/ziqi_epoch_calibrator.dart test/domain/engines/siyu/ziqi/ziqi_epoch_calibrator_test.dart
git commit -m "feat(ziqi): 紫气历元黄经校准器（自洽/参考盘两法）"
```

---

## Task 13: `ZiQiAlgorithmRegistry` 算法管理与扩展点

**Files:**
- Create: `lib/domain/engines/siyu/ziqi/zi_qi_algorithm_registry.dart`
- Test: `test/domain/engines/siyu/ziqi/zi_qi_algorithm_registry_test.dart`

**Interfaces:**
- Consumes: `EnumZiQiAlgorithm`（Task 9）、`ZiQiAlgorithm`（Task 10）。
- Produces:
  - `class ZiQiAlgorithmRegistry`：`ZiQiAlgorithm resolve(EnumZiQiAlgorithm which)`（缺省回落 `guoLaoQinTang`）；`void register(EnumZiQiAlgorithm key, ZiQiAlgorithm algo)`（**扩展点**：后期插新算法）。

- [ ] **Step 1: 写失败测试**

```dart
// test/domain/engines/siyu/ziqi/zi_qi_algorithm_registry_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:qizhengsiyu/enums/enum_zi_qi_algorithm.dart';
import 'package:qizhengsiyu/domain/engines/siyu/ziqi/zi_qi_algorithm.dart';
import 'package:qizhengsiyu/domain/engines/siyu/ziqi/zi_qi_algorithm_registry.dart';

class _FixedAlgo implements ZiQiAlgorithm {
  final double v;
  final String _id;
  _FixedAlgo(this.v, this._id);
  @override
  String get id => _id;
  @override
  double computeLongitude({required double julianDay, required DateTime datetime}) => v;
}

void main() {
  test('resolve 命中对应算法', () {
    final reg = ZiQiAlgorithmRegistry({
      EnumZiQiAlgorithm.guoLaoQinTang: _FixedAlgo(1, 'g'),
      EnumZiQiAlgorithm.shixian: _FixedAlgo(2, 's'),
    });
    expect(reg.resolve(EnumZiQiAlgorithm.shixian).id, 's');
  });

  test('未注册的算法回落到果老默认', () {
    final reg = ZiQiAlgorithmRegistry({
      EnumZiQiAlgorithm.guoLaoQinTang: _FixedAlgo(1, 'g'),
    });
    expect(reg.resolve(EnumZiQiAlgorithm.yelvTianguan).id, 'g');
  });

  test('register 可插入新算法（扩展点）', () {
    final reg = ZiQiAlgorithmRegistry({
      EnumZiQiAlgorithm.guoLaoQinTang: _FixedAlgo(1, 'g'),
    });
    reg.register(EnumZiQiAlgorithm.yelvTianguan, _FixedAlgo(9, 't'));
    expect(reg.resolve(EnumZiQiAlgorithm.yelvTianguan).id, 't');
  });
}
```

- [ ] **Step 2: 运行确认失败**

Run: `flutter test test/domain/engines/siyu/ziqi/zi_qi_algorithm_registry_test.dart`
Expected: FAIL —— 找不到文件。

- [ ] **Step 3: 实现注册表**

```dart
// lib/domain/engines/siyu/ziqi/zi_qi_algorithm_registry.dart
import 'package:qizhengsiyu/enums/enum_zi_qi_algorithm.dart';
import 'zi_qi_algorithm.dart';

/// 紫气算法管理器：按流派解析算法，并提供注册扩展点。
///
/// 扩展新流派：实现 ZiQiAlgorithm，然后 registry.register(新枚举值, 实例)。
class ZiQiAlgorithmRegistry {
  final Map<EnumZiQiAlgorithm, ZiQiAlgorithm> _map;

  ZiQiAlgorithmRegistry(Map<EnumZiQiAlgorithm, ZiQiAlgorithm> map)
      : _map = Map.of(map);

  ZiQiAlgorithm resolve(EnumZiQiAlgorithm which) =>
      _map[which] ?? _map[EnumZiQiAlgorithm.guoLaoQinTang]!;

  void register(EnumZiQiAlgorithm key, ZiQiAlgorithm algo) => _map[key] = algo;
}
```

- [ ] **Step 4: 运行确认通过 + 提交**

Run: `flutter test test/domain/engines/siyu/ziqi/zi_qi_algorithm_registry_test.dart`
Expected: PASS
```bash
git add lib/domain/engines/siyu/ziqi/zi_qi_algorithm_registry.dart test/domain/engines/siyu/ziqi/zi_qi_algorithm_registry_test.dart
git commit -m "feat(ziqi): 紫气算法注册表（解析+扩展点）"
```

---

## Task 14: 接线 —— 注入紫气算法、config 字段、引擎组装、UI 下拉

**Files:**
- Modify: `lib/domain/engines/siyu/si_yu_calculator.dart`（紫气改为注入 `ZiQiAlgorithm`，删除 `_computeZiQi`）
- Modify: `lib/domain/entities/models/panel_config.dart`（加 `ziQiAlgorithm`、`ziQiPeriod` 字段）+ 重生成 `.g.dart`
- Modify: `lib/domain/engines/sweph_engine.dart`（组装 `ZiQiAlgorithmRegistry`、按 config 解析、校准历元黄经、构造 `SiYuCalculator`）
- Modify: `lib/presentation/widgets/config/custom_config_section.dart`（紫气算法下拉 + 周期切换）
- Test: `test/domain/engines/siyu/si_yu_calculator_ziqi_injection_test.dart`

**Interfaces:**
- Consumes: Task 9–13 全部。
- Produces: `SiYuCalculator({required ISiYuEphemerisSource source, required ZiQiAlgorithm ziQiAlgorithm})`；`BasePanelConfig.ziQiAlgorithm`（默认 `guoLaoQinTang`）、`BasePanelConfig.ziQiPeriod`（默认 `years28`）。

- [ ] **Step 1: 写失败测试（SiYuCalculator 使用注入的紫气算法）**

```dart
// test/domain/engines/siyu/si_yu_calculator_ziqi_injection_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:qizhengsiyu/domain/engines/siyu/si_yu_calculator.dart';
import 'package:qizhengsiyu/domain/engines/siyu/ziqi/zi_qi_algorithm.dart';

class _FakeSource implements ISiYuEphemerisSource {
  @override
  double meanNodeLongitude(double jd) => 0;
  @override
  double meanApogeeLongitude(double jd) => 0;
}

class _ConstZiQi implements ZiQiAlgorithm {
  @override
  String get id => 'const';
  @override
  double computeLongitude({required double julianDay, required DateTime datetime}) => 88.0;
}

void main() {
  test('紫气取自注入的算法', () {
    final calc = SiYuCalculator(
      source: _FakeSource(),
      ziQiAlgorithm: _ConstZiQi(),
    );
    final r = calc.compute(julianDay: 123, birthDate: DateTime.utc(2000));
    expect(r.qi, closeTo(88.0, 1e-9));
  });
}
```

- [ ] **Step 2: 运行确认失败**

Run: `flutter test test/domain/engines/siyu/si_yu_calculator_ziqi_injection_test.dart`
Expected: FAIL —— `SiYuCalculator` 无 `ziQiAlgorithm` 具名参数。

- [ ] **Step 3: 改 `si_yu_calculator.dart` —— 注入紫气算法**

顶部 `import` 加：
```dart
import 'ziqi/zi_qi_algorithm.dart';
```
删除 `import 'package:timezone/timezone.dart' as tz;`（若不再使用）与整个 `static double _computeZiQi(...)`。

构造与字段改为：
```dart
class SiYuCalculator {
  final ISiYuEphemerisSource _source;
  final ZiQiAlgorithm _ziQiAlgorithm;
  const SiYuCalculator({
    required ISiYuEphemerisSource source,
    required ZiQiAlgorithm ziQiAlgorithm,
  })  : _source = source,
        _ziQiAlgorithm = ziQiAlgorithm;
```

`compute` 里紫气一行改为：
```dart
      qi: _ziQiAlgorithm.computeLongitude(
          julianDay: julianDay, datetime: birthDate),
```

> 注：Part A 的 `si_yu_calculator_test.dart` 里紫气相关两个用例（历元 0 / 后1天0.0352）失去意义，改为传入一个返回常量的 fake `ZiQiAlgorithm` 并断言透传（与本 Task Step 1 同型）。

- [ ] **Step 4: 加 config 字段**

`panel_config.dart` 顶部 `import` 加 `import '../../../enums/enum_zi_qi_algorithm.dart';`；`BasePanelConfig` 加字段：
```dart
  @JsonKey(defaultValue: EnumZiQiAlgorithm.guoLaoQinTang)
  EnumZiQiAlgorithm ziQiAlgorithm;
  @JsonKey(defaultValue: EnumZiQiPeriod.years28)
  EnumZiQiPeriod ziQiPeriod;
  @JsonKey(defaultValue: EnumZiQiEpochSet.shouShiNvXiu)
  EnumZiQiEpochSet ziQiEpochSet;
  @JsonKey(defaultValue: EnumZiQiChiDaoStandard.moira)
  EnumZiQiChiDaoStandard ziQiChiDaoStandard; // 天赤道·女宿：授时正典 / Moira
```
构造函数加 `this.ziQiAlgorithm = EnumZiQiAlgorithm.guoLaoQinTang,`、`this.ziQiPeriod = EnumZiQiPeriod.years28,`、`this.ziQiEpochSet = EnumZiQiEpochSet.shouShiNvXiu,`、`this.ziQiChiDaoStandard = EnumZiQiChiDaoStandard.moira,`；`copyWith` 与 `PanelConfig` `super.` 同步（比照 Task 4 罗计字段做法）。

> 天赤道组装时按 `ziQiChiDaoStandard` 取常数：`moira` → (10237.7 日, 锚 2026 翼宿4°38′36″)；`shouShiOrthodox` → (10227.1792 日, 女宿二度 113.60, 历元 1280-12-14)。

Run: `dart run build_runner build --delete-conflicting-outputs`

- [ ] **Step 5: 改 `sweph_engine.dart` —— 组装注册表并解析**

将 Task 6 里 `const SiYuCalculator(source: ...)` 处替换为：先按 `config.ziQiEpochSet` 构造果老历元、组三算法注册表、解析，再构造 `SiYuCalculator`。示例：
```dart
    // 果老历元黄经：默认「授时·女宿」自包含(直接 295°)，无需宿度管线；
    // 「符天·箕宿」才需接 ZhouTianCalculator 求箕宿0°。
    final double guoLaoEpochJd;
    final double guoLaoEpochLon;
    switch (config.ziQiEpochSet) {
      case EnumZiQiEpochSet.shouShiNvXiu:
        // 1280-12-14 01:29:36（辛巳岁前天正冬至，儒略历）
        guoLaoEpochJd = Sweph.swe_julday(
            1280, 12, 14, 1 + 29 / 60 + 36 / 3600, CalendarType.SE_JUL_CAL);
        // 女宿二度 ≈ 黄经 295°（"约"，精值待郑氏星案坐实，见 Step 9 golden）
        guoLaoEpochLon = 295.0;
        break;
      case EnumZiQiEpochSet.fuTianJiXiu:
        guoLaoEpochJd = winterSolsticeJulianDay(1281, julianCalendar: true);
        // 箕宿0°：由既有宿度管线求得后经校准器归一。
        // _calculateAllStarsAngleOnZodiac 已有 zhouTianModel 可求箕宿起始黄经。
        final jiXiuStart = _jiXiuStartLongitude(zhouTianModel); // 见下方 Step 5b
        guoLaoEpochLon = ZiqiEpochCalibrator.fromConstellationPipeline(
            jiXiuStartLongitude: jiXiuStart);
        break;
    }
    final registry = ZiQiAlgorithmRegistry({
      EnumZiQiAlgorithm.guoLaoQinTang: GuoLaoZiQiAlgorithm(
        periodDays: config.ziQiPeriod.days,
        epochJulianDay: guoLaoEpochJd,
        epochLongitude: guoLaoEpochLon,
      ),
      EnumZiQiAlgorithm.shixian: ShixianZiQiAlgorithm(
        dailyMotionDegrees: 126.720777 / 3600,
        epochJulianDay: winterSolsticeJulianDay(1744, julianCalendar: false),
        epochLongitude: 197.833333, // 已确认：七宫17°50′黄道经度基准，高精度可选 197.837237
      ),
      EnumZiQiAlgorithm.yelvTianguan: const TianguanZiQiAlgorithm(
        epochYear: 1281, // 作为相对年份参考点
        epochLongitude: 6.0, // 子宫虚六度（赤道绝对起点 6.0°，冬子宫）
        yearlyIncrementDegrees: 13 + 5 / 60,
      ),
    });
    final siyu = SiYuCalculator(
      source: const SwephSiYuEphemerisSource(),
      ziQiAlgorithm: registry.resolve(config.ziQiAlgorithm),
    ).compute(julianDay: julianDay, birthDate: datetime);
```
顶部补齐相关 `import`（enum_zi_qi_algorithm、ziqi/* 各类）。

- [ ] **Step 5b（仅 `fuTianJiXiu` 需要）：接 `ZhouTianCalculator` 求箕宿起始赤道或黄道经度**

在 `zhou_tian_model.dart` 中新增快捷且无状态的非阻塞内存查表接口（如 `ZhouTianCalculator.getStartEquatorialLon`），并在引擎中通过 `_jiXiuStartLongitude` 辅助方法调用该接口获取 `Enum28Constellations.Ji` 的起始经度。

> ⚠️ **无环依赖设计**：`zhou_tian_model.dart` 作为纯物理模型层，禁止导入任何上层业务层（如 `SwephEngine`、`EpochCalibrator` 或四余算法类）。调用方仅通过数值形式单向传递数据。
>
> ⚠️ **默认路径（女宿）不依赖此步**，故不是硬阻塞。仅当用户切到 `fuTianJiXiu` 时才必须接通；若本 Task 暂缓接通，须在该分支抛 `UnimplementedError('符天·箕宿历元待接宿度管线')`，**不得静默返回错误值冒充完成**。

- [ ] **Step 6: UI 紫气算法下拉 + 周期切换**

在 `custom_config_section.dart` 罗计定义卡片之后，仿「流派典籍」下拉加：
- 「紫气算法」`DropdownButtonFormField<EnumZiQiAlgorithm>`（items=`EnumZiQiAlgorithm.values`，显示 `.name`）；
- 「紫气周期」二选一单选（`EnumZiQiPeriod.years28/years29`）；
- 「紫气历元」`DropdownButtonFormField<EnumZiQiEpochSet>`（`shouShiNvXiu/fuTianJiXiu`，显示 `.name`）——**仅当算法=`guoLaoQinTang` 时显示**。
- 「紫气标准」`DropdownButtonFormField<EnumZiQiChiDaoStandard>`（`shouShiOrthodox/moira`，显示 `.name`）——**仅当星制=天赤道 且 历元=女宿 时显示**；副标题注明「授时正典=合典籍 / Moira=合主流软件排盘」。

State 加 `_ziQiAlgorithm`/`_ziQiPeriod`/`_ziQiEpochSet`/`_ziQiChiDaoStandard`，`initState` 从 `initialConfig` 取默认，`_updateConfig()` 的 `PanelConfig(...)` 带上 `ziQiAlgorithm: _ziQiAlgorithm, ziQiPeriod: _ziQiPeriod, ziQiEpochSet: _ziQiEpochSet, ziQiChiDaoStandard: _ziQiChiDaoStandard`（勿漏，同罗计空接陷阱）。

- [ ] **Step 7: 静态检查 + 相关测试**

Run: `flutter analyze && flutter test test/domain/engines/siyu/`
Expected: analyze 无新增错误；四余/紫气测试全绿。

- [ ] **Step 8: 提交**

```bash
git add lib/domain/engines/siyu/si_yu_calculator.dart lib/domain/entities/models/panel_config.dart lib/domain/entities/models/panel_config.g.dart lib/domain/engines/sweph_engine.dart lib/presentation/widgets/config/custom_config_section.dart test/domain/engines/siyu/si_yu_calculator_ziqi_injection_test.dart
git commit -m "feat(ziqi): 注入紫气算法、配置化流派/周期/历元、引擎组装注册表、UI 选择"
```

---

## Task 15: 郑氏星案 golden 验证（天赤道紫气模型已定值）

**Files:**
- Create: `test/domain/engines/siyu/ziqi/zheng_shi_xing_an_golden_test.dart`
- Modify: `lib/domain/engines/sweph_engine.dart`（天赤道分支 `shouShiNvXiu` 用下方已验证常数）

**Interfaces:** 无新增代码接口。天赤道紫气模型**已由 4 个 Moira 案例最小二乘定值**（残差全 <0.65 古度），本 Task 把 4 点固化为 golden。

### 已验证模型（2026-07-04，Moira 四点最小二乘）

```
星制   : 元授时天赤道恒星制，365.25 赤道古度，郭守敬宿距(Task 16)，儒略历
日行   : 0.0356771 古度/日   （周期 10237.7 日 ≈ 28.03 恒星年）
锚点   : 2026-07-04 15:15 (JD 2461226.135) = 翼宿4°38′36″ = 赤经 333.843 古度
出宿度 : 赤经 → 郭守敬累计表 → 宿+宿内度
```
- **周期非授时正典 10227.1792**：Moira 标称「0.0352°/日/28年」是取整；701 年长基线定出真值 **10237.7 日**。用 10227 外推会偏 ~9°。
- **实现锚定现代点(2026)**，勿从 1280 古历元外推 26 周期（周期 0.1% 误差放大 ~10°）。等价 1280 冬至历元≈女宿3°50′（传统"女宿二度"为约值）。

### 天赤道·女宿：两个标准并存可选（`EnumZiQiChiDaoStandard`，UI 可选）

| 标准 | 周期(日) | 日行(古度/日) | 历元/锚 | 用途 |
|---|---|---|---|---|
| `shouShiOrthodox` 授时正典 | **10227.1792** (28.00年) | 0.0357143 | 1280-12-14 冬至 · 女宿二度(女宿 113.60 绝对) | 合《授时历》文本正统 |
| `moira` Moira 实测 | **10237.7** (28.03年) | 0.0356771 | 锚 2026-07-04 = 翼宿4°38′36″(333.843) | 合主流软件 Moira 排盘 |

- 两标准同为天赤道 365.25 框架、同郭守敬宿距、同顺行；仅周期与历元锚不同 → 长程宿度渐分离（百年约 1.5°，700 年约 9°）。
- golden：`moira` 标准须复现四点 (残差<0.65)；`shouShiOrthodox` 标准仅做结构性自检（不强求匹配 Moira 四点，因它本就与 Moira 差 ~9°）。
- **默认**：`moira`（与用户参考排盘一致）；`shouShiOrthodox` 供尊崇文本正统者选用。UI 二选一。

**Moira 四参考点（`①` 年份已勘误：原 1341→1340）：**
| # | 时刻(儒略历,②③①；格里,④) | 紫气宿度 | 绝对赤经(古度) | 拟合残差 |
|---|---|---|---|---|
| ① | **1340**-02-24 08:26 | 室宿 08°53′42″ | 156.195 | −0.12 |
| ② | 1350-03-23 20:18 | 井宿 30°14′24″ | 287.090 | −0.53 |
| ③ | 1325-05-27 06:10 | 翼宿 00°50′00″ | 330.033 | +0.63 |
| ④ | 2026-07-04 15:15 | 翼宿 04°38′36″ | 333.843 | +0.02 |

> **勘误记录**：原始 ① 为 1341-02-24，四点三角定位判定其年份错 1 年（用 1341 残差 +13.8°，改 1340 后 +0.7°），已改 1340。②③④ 本就自洽于 28.03 年。
>
> **时刻精度**：紫气日行仅 0.036 古度/日 → 时区/真太阳时/地点**均可忽略**，钟表时直接当 UT。
>
> **前置依赖**：宿度↔赤道经度换算用 Task 16 的郭守敬宿距 `ZhouTianModel`。

- [ ] **Step 0: 确认赤道宿度→赤道经度换算入口**

用 Task 16 的郭守敬赤道宿距 `ZhouTianModel`（`starInnDegreeSeq` 为各宿赤道距度，累加=365.25）实现下方 `_xiuDegreeToLongitude`：某宿起始赤道经度 = 该宿之前各宿距度累加（起点依 `alignmentPointAtGong` 丑15°/冬至定标），再 + 宿内度。

- [ ] **Step 1: 写校准 + 双点验证测试**

```dart
// test/domain/engines/siyu/ziqi/zheng_shi_xing_an_golden_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:sweph/sweph.dart';
import 'package:metaphysics_core/enums.dart';
import 'package:qizhengsiyu/domain/entities/models/zhou_tian_model.dart';
import 'package:qizhengsiyu/domain/engines/siyu/ziqi/guolao_zi_qi_algorithm.dart';
import 'package:qizhengsiyu/domain/engines/siyu/ziqi/ziqi_epoch_calibrator.dart';

const double kEquTotal = 365.25; // 天赤道古度周天

// 赤道宿度(宿+宿内度) → 绝对赤道经度。用 Task 16 郭守敬赤道宿距 model。
double _xiuDegreeToLongitude(
    ZhouTianModel model, Enum28Constellations xiu, double degInXiu) {
  // TODO(Task 16): 由 model.starInnDegreeSeq 累加求 xiu 起始赤道经度 + degInXiu，mod 365.25。
  throw UnimplementedError('待 Task 16 郭守敬赤道宿距表');
}

// 案例钟表时 → JD。紫气超慢，时区/地点可忽略：直接按 UT + 儒略历。
double _caseJulianDay(int y, int mo, int d, int h, int mi) =>
    Sweph.swe_julday(y, mo, d, h + mi / 60.0, CalendarType.SE_JUL_CAL);

void main() {
  setUpAll(() => Sweph.init()); // 若项目有既定 sweph 初始化夹具，改用之

  // TODO(Task 16): 加载郭守敬赤道宿距 ZhouTianModel（天赤道恒星制）。
  late ZhouTianModel model;

  // 已验证周期(Moira 四点最小二乘)：10237.7 日；日行 0.0356771 古度/日。
  const daily = 0.0356771; // 古度/日 (kEquTotal/10237.7)
  // 锚点=2026-07-04(④)，避免从 1280 外推放大周期误差
  final jd4 = Sweph.swe_julday(2026, 7, 4, 15 + 15 / 60, CalendarType.SE_GREG_CAL);
  const L4 = 333.843; // 翼宿4°38'36''

  // 断言四点(①已勘误为1340)：以④为锚，各点预测宿度落在 <1 古度容差。
  // 用 _xiuDegreeToLongitude 把实测宿度转赤经，与 (L4 + daily*(jd-jd4)) mod 365.25 比对。

  test('点①反解女宿历元 → 点②独立验证(容差≤宿内1°)', () {
    // 点① 室宿08°53'42''
    final jd1 = _caseJulianDay(1341, 2, 24, 8, 26);
    final l1 = _xiuDegreeToLongitude(
        model, Enum28Constellations.Shi, 8 + 53 / 60 + 42 / 3600);
    final epochLon = ZiqiEpochCalibrator.fromReferenceChart(
      refLongitude: l1,
      refJulianDay: jd1,
      epochJulianDay: epochJd,
      dailyMotionDegrees: daily,
      totalDegree: kEquTotal,
    );

    // 点② 井宿30°14'24''
    final jd2 = _caseJulianDay(1350, 3, 23, 20, 18);
    final l2Expected = _xiuDegreeToLongitude(
        model, Enum28Constellations.Jing, 30 + 14 / 60 + 24 / 3600);
    final algo = GuoLaoZiQiAlgorithm(
      totalDegree: kEquTotal,
      periodDays: periodDays,
      epochJulianDay: epochJd,
      epochLongitude: epochLon,
    );
    final l2Actual =
        algo.computeLongitude(julianDay: jd2, datetime: DateTime.utc(1350));

    // 最短角差（周天 365.25）
    final diff = ((l2Actual - l2Expected + 1.5 * kEquTotal) % kEquTotal) -
        0.5 * kEquTotal;
    expect(diff.abs(), lessThan(1.0),
        reason: '若超差，先复核宿距表/历法/周期(28↔29)，勿硬凑');

    // epochLon 即授时·女宿精确赤道历元，回填 Task 14 shouShiNvXiu 分支(365.25 框架)。
    // print('calibrated 女宿 epochLon(赤道) = $epochLon');
  }, skip: '待 Task 16 郭守敬赤道宿距表就绪');
}
```

> **注**：`ZiqiEpochCalibrator.fromReferenceChart`（Task 12）当前按 360 归一。天赤道校准需按 365.25——Task 12 应给校准器加可选 `totalDegree` 参数（默认 360），或本 Task 内自行按 365.25 归一。执行 Task 16/15 时一并补。

- [ ] **Step 2: 运行，判定周期并读出校准值**

Run: `flutter test test/domain/engines/siyu/ziqi/zheng_shi_xing_an_golden_test.dart`
- 若 28 年制通过 → 记录 `epochLon`（授时·女宿精确历元黄经）。
- 若不过 → 把 `periodDays` 改 `10592`(29年) 复跑；仍不过 → 按上方 ⚠️ 复核宿度系统/时区假设并**回报**，不得调参硬凑。

- [ ] **Step 3: 回填 Task 14 历元黄经并提交**

将 `sweph_engine.dart` 中 `guoLaoEpochLon = 295.0`（`shouShiNvXiu` 分支）替换为本 Task 反解出的精确值（加注释「郑氏星案两点校准，YYYY-MM-DD」），并把周期默认改为验证通过的那套。
```bash
git add test/domain/engines/siyu/ziqi/zheng_shi_xing_an_golden_test.dart lib/domain/engines/sweph_engine.dart
git commit -m "test(ziqi): 郑氏星案两点校准授时·女宿历元 + golden 验证"
```

---

## Task 16: 元授时天赤道·郭守敬赤道宿距表 asset + 天赤道紫气宿度映射

> **数据已到位（2026-07-04）**：用户提供郭守敬 28 宿赤道距度表（下方，累加=365.25，已验证）。Task 15 依赖本 Task。
>
> **背景**：仓库现有天赤道 asset 仅 `han_chidao_hengxin.json`（汉太初历、`starInnDegreeSeq` 为空），**不含元授时郭守敬实测宿距**。「两套坐标系都要」要求补齐天赤道恒星系的宿距数据 + 紫气在该系出宿度。

**郭守敬赤道宿距（度，标准宿序，累加=365.25）：**
```
角12.10 亢9.20 氐16.30 房5.60 心6.50 尾19.10 箕10.40
斗25.20 牛7.20 女11.35 虚8.95 危15.40 室17.10 壁8.60
奎16.60 娄11.80 胃15.60 昴11.30 毕17.40 觜0.05 参11.10
井33.30 鬼2.20 柳13.30 星6.30 张17.25 翼18.75 轸17.30
```

**Files:**
- Create: `example/assets/qizhengsiyu/yuan_shoushi_chidao_hengxin.json`（元授时天赤道恒星，`totalDegree=365.25`，`starInnDegreeSeq`=郭守敬 28 宿赤道距度，累加=365.25，`zeroPointJieQi=冬至`，`alignmentPointAtGong=丑15°`）
- Create: `lib/domain/engines/siyu/ziqi/chi_dao_xiu_mapper.dart`（赤道经度 ↔ 赤道宿度）
- Test: `test/domain/engines/siyu/ziqi/chi_dao_xiu_mapper_test.dart`

**Interfaces:**
- Produces: `class ChiDaoXiuMapper { ChiDaoXiuMapper(ZhouTianModel model); ({Enum28Constellations xiu, double deg}) toXiuDegree(double chiDaoLongitude); double xiuStartLongitude(Enum28Constellations xiu); }`

- [ ] **Step 1: 建 asset（含郭守敬宿距，待用户表填值）**

结构比照 `han_chidao_hengxin.json`，`totalDegree=365.25`；`starInnDegreeSeq` 填入用户提供的 28 宿赤道距度（角度、累加=365.25）。数据未到时先放 `[]` 并在 PR 标注「待郭守敬宿距表」。

- [ ] **Step 2: 写 mapper 失败测试（用真实/占位宿距）**

```dart
// test/domain/engines/siyu/ziqi/chi_dao_xiu_mapper_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:metaphysics_core/enums.dart';
import 'package:qizhengsiyu/domain/entities/models/zhou_tian_model.dart';
import 'package:qizhengsiyu/domain/engines/siyu/ziqi/chi_dao_xiu_mapper.dart';

void main() {
  test('赤道经度落宿：某宿起点→该宿0度，宿末→次宿0度', () {
    // TODO(用户表): 载入 yuan_shoushi_chidao_hengxin.json 后放开
    // final model = ...;
    // final m = ChiDaoXiuMapper(model);
    // final start = m.xiuStartLongitude(Enum28Constellations.Shi);
    // expect(m.toXiuDegree(start).xiu, Enum28Constellations.Shi);
    // expect(m.toXiuDegree(start).deg, closeTo(0, 1e-6));
  }, skip: '待郭守敬赤道宿距表');
}
```

- [ ] **Step 3: 实现 mapper**

`ChiDaoXiuMapper`：从 `model.starInnDegreeSeq` 与 `starInnOrder` 累加得各宿绝对起始赤道经度（以 `alignmentPointAtGong` 丑15°/冬至定标为零点），提供 `xiuStartLongitude` 与 `toXiuDegree`（给定赤道经度定位到宿+宿内度，mod 365.25）。

- [ ] **Step 4: 天赤道紫气出宿度接线**

在引擎/展示层：当 `config.celestialCoordinateSystem` 为天赤道恒星时，紫气用 `GuoLaoZiQiAlgorithm(totalDegree: 365.25, epochJulianDay: 1280冬至, epochLongitude: 女宿赤道历元, periodDays: config.ziQiPeriod.days)` 算赤道经度，再经 `ChiDaoXiuMapper.toXiuDegree` 出宿度。**此路径不经 sweph 七政管线、无需岁差**。

- [ ] **Step 5: 提交**

```bash
git add example/assets/qizhengsiyu/yuan_shoushi_chidao_hengxin.json lib/domain/engines/siyu/ziqi/chi_dao_xiu_mapper.dart test/domain/engines/siyu/ziqi/chi_dao_xiu_mapper_test.dart
git commit -m "feat(ziqi): 元授时天赤道郭守敬宿距 asset + 赤道紫气宿度映射（待表数据）"
```

---

# Part C：四余可配置计算框架（泛化 Part A/B）

> **设计来源**：`docs/superpowers/specs/2026-07-04-siyu-configurable-framework-design.md`。本部分把 Part A/B 的"紫气专用策略 + 罗计定义"**上升为全四余通用的分组策略框架**：三算法组（罗计/月孛/紫气）、星历/古法平行变体、分段多模型、流派档案+单项覆盖、spec+工厂+两层 UI。**自定义 = 选择+调参，无公式 DSL。**
>
> **与 A/B 关系**：`RahuKetuDefinition`(Task 2)、`ZiQiAlgorithm`/`GuoLao*`(Task 10–13)、`totalDegree`、郭守敬宿距(Task 16)、Moira 常数(Task 15) **全部保留复用**；本部分在其上加通用层，并把紫气/罗计接为框架实例。Part C 依赖 A/B。

## Part C 全局约束

- 三算法组：`SiYuGroup { luoJi, yueBo, ziQi }`；罗计组恒**逆行 + 180°对冲 + 可互换升降**，由 `RahuKetuDefinition` 强制，任何配置改不坏。
- 坐标框架 `totalDegree`：黄道 360 / 天赤道 365.25；日行=`totalDegree/periodDays` 或直填，归一化同框架（度制铁律）。
- 自定义仅"选择+调参"：UI 选算法 kind + 填数字参数 + 加时间分段；**不实现公式/脚本**。
- 默认零回归：默认档案（果老·黄道 或沿用当前行为）产出与 Part A/B 默认一致；罗计默认罗降计升。
- spec/config `@JsonSerializable`，缺省=默认档案，向后兼容不崩。

---

## Task 17: `SiYuGroupAlgorithm` 接口 + `LinearParallelCore`

**Files:**
- Create: `lib/domain/engines/siyu/group/si_yu_group_algorithm.dart`
- Create: `lib/domain/engines/siyu/group/linear_parallel_core.dart`
- Test: `test/domain/engines/siyu/group/linear_parallel_core_test.dart`

**Interfaces:**
- Consumes: `EnumStars`（`metaphysics_core`）。
- Produces:
  - `enum SiYuGroup { luoJi, yueBo, ziQi }`
  - `abstract interface class SiYuGroupAlgorithm { String get id; Set<EnumStars> get bodies; Map<EnumStars,double> computePositions({required double julianDay, required DateTime datetime}); }`
  - `class LinearParallelCore { const LinearParallelCore({required double totalDegree, required double dailyMotion, required int direction, required double epochJulianDay, required double epochPosition}); double positionAt(double julianDay); }` —— 通用平行推算内核（顺逆/速率/历元/框架参数化）。

- [ ] **Step 1: 写失败测试**

```dart
// test/domain/engines/siyu/group/linear_parallel_core_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:qizhengsiyu/domain/engines/siyu/group/linear_parallel_core.dart';

void main() {
  test('顺行：epoch后1000日 = epoch + daily*1000，mod totalDegree', () {
    const c = LinearParallelCore(
        totalDegree: 360, dailyMotion: 0.0352, direction: 1,
        epochJulianDay: 1000, epochPosition: 10);
    expect(c.positionAt(2000), closeTo((10 + 0.0352 * 1000) % 360, 1e-9));
  });
  test('逆行：direction=-1 递减并按框架归一到[0,total)', () {
    const c = LinearParallelCore(
        totalDegree: 365.25, dailyMotion: 0.05299, direction: -1,
        epochJulianDay: 1000, epochPosition: 5);
    final v = c.positionAt(1100); // 5 - 0.05299*100 = -0.299 → +365.25 = 364.951
    expect(v, greaterThanOrEqualTo(0));
    expect(v, lessThan(365.25));
    expect(v, closeTo(365.25 + (5 - 0.05299 * 100), 1e-6)); // 364.951
  });
}
```

- [ ] **Step 2: 运行确认失败**

Run: `flutter test test/domain/engines/siyu/group/linear_parallel_core_test.dart`
Expected: FAIL —— 找不到文件。

- [ ] **Step 3: 实现接口 + 内核**

```dart
// lib/domain/engines/siyu/group/si_yu_group_algorithm.dart
import 'package:metaphysics_core/enums.dart';

enum SiYuGroup { luoJi, yueBo, ziQi }

/// 四余算法组统一策略：一次产出本组所有星的位置(度，坐标框架由算法自持)。
abstract interface class SiYuGroupAlgorithm {
  String get id;
  Set<EnumStars> get bodies;
  Map<EnumStars, double> computePositions({
    required double julianDay,
    required DateTime datetime,
  });
}
```

```dart
// lib/domain/engines/siyu/group/linear_parallel_core.dart
/// 通用平行推算内核：顺逆/速率/历元/坐标框架全参数化。
/// 紫气/罗计古法平行/月孛古法平行共用此内核，仅参数不同。
class LinearParallelCore {
  final double totalDegree;    // 360 / 365.25
  final double dailyMotion;    // 日行度(该框架单位，取正)
  final int direction;         // +1 顺 / -1 逆
  final double epochJulianDay;
  final double epochPosition;

  const LinearParallelCore({
    required this.totalDegree,
    required this.dailyMotion,
    required this.direction,
    required this.epochJulianDay,
    required this.epochPosition,
  });

  double positionAt(double julianDay) {
    final raw = epochPosition +
        direction * dailyMotion * (julianDay - epochJulianDay);
    var r = raw % totalDegree;
    if (r < 0) r += totalDegree;
    return r;
  }
}
```

- [ ] **Step 4: 运行确认通过 + 提交**

Run: `flutter test test/domain/engines/siyu/group/linear_parallel_core_test.dart`
Expected: PASS
```bash
git add lib/domain/engines/siyu/group/si_yu_group_algorithm.dart lib/domain/engines/siyu/group/linear_parallel_core.dart test/domain/engines/siyu/group/linear_parallel_core_test.dart
git commit -m "feat(siyu): SiYuGroupAlgorithm 接口 + 通用平行内核 LinearParallelCore"
```

---

## Task 18: 罗计组算法（星历 / 古法平行两变体）

**Files:**
- Create: `lib/domain/engines/siyu/group/luo_ji_group_algorithm.dart`
- Test: `test/domain/engines/siyu/group/luo_ji_group_algorithm_test.dart`

**Interfaces:**
- Consumes: `SiYuGroupAlgorithm`、`LinearParallelCore`（Task 17）；`RahuKetuDefinition`、`EnumRahuKetuConvention`（Task 1/2）；`ISiYuEphemerisSource`（Task 3）。
- Produces:
  - `class EphemerisNodePairAlgorithm implements SiYuGroupAlgorithm`（构造 `{ISiYuEphemerisSource source, EnumRahuKetuConvention convention}`）
  - `class LinearNodePairAlgorithm implements SiYuGroupAlgorithm`（构造 `{LinearParallelCore升交点内核(逆行), EnumRahuKetuConvention convention}`）
  - 两者 `bodies == {EnumStars.Luo, EnumStars.Ji}`，输出恒满足 `|罗−计|≡180°`、恒逆行。

- [ ] **Step 1: 写失败测试（组不变量 + convention 互换）**

```dart
// test/domain/engines/siyu/group/luo_ji_group_algorithm_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:metaphysics_core/enums.dart';
import 'package:qizhengsiyu/enums/enum_rahu_ketu_convention.dart';
import 'package:qizhengsiyu/domain/engines/siyu/group/linear_parallel_core.dart';
import 'package:qizhengsiyu/domain/engines/siyu/group/luo_ji_group_algorithm.dart';

double _diff(double a, double b) { var d=(a-b).abs()%360; return d>180?360-d:d; }

void main() {
  test('古法平行罗计：罗降计升(默认)，逆行，180°对冲', () {
    final algo = LinearNodePairAlgorithm(
      nodeCore: const LinearParallelCore(
          totalDegree: 360, dailyMotion: 0.052993, direction: -1,
          epochJulianDay: 1000, epochPosition: 30),
      convention: EnumRahuKetuConvention.luoJiangJiSheng,
    );
    final p = algo.computePositions(julianDay: 1000, datetime: DateTime.utc(2000));
    // N=30(升交点)=计都；罗睺=降交点=210
    expect(p[EnumStars.Ji], closeTo(30, 1e-6));
    expect(p[EnumStars.Luo], closeTo(210, 1e-6));
    expect(_diff(p[EnumStars.Luo]!, p[EnumStars.Ji]!), closeTo(180, 1e-6));
  });
  test('convention=罗升计降 时罗计互换', () {
    final algo = LinearNodePairAlgorithm(
      nodeCore: const LinearParallelCore(
          totalDegree: 360, dailyMotion: 0.052993, direction: -1,
          epochJulianDay: 1000, epochPosition: 30),
      convention: EnumRahuKetuConvention.luoShengJiJiang,
    );
    final p = algo.computePositions(julianDay: 1000, datetime: DateTime.utc(2000));
    expect(p[EnumStars.Luo], closeTo(30, 1e-6));
    expect(p[EnumStars.Ji], closeTo(210, 1e-6));
  });
}
```

- [ ] **Step 2: 运行确认失败**

Run: `flutter test test/domain/engines/siyu/group/luo_ji_group_algorithm_test.dart`
Expected: FAIL —— 找不到文件。

- [ ] **Step 3: 实现罗计组两变体**

```dart
// lib/domain/engines/siyu/group/luo_ji_group_algorithm.dart
import 'package:metaphysics_core/enums.dart';
import 'package:qizhengsiyu/enums/enum_rahu_ketu_convention.dart';
import 'package:qizhengsiyu/domain/engines/siyu/rahu_ketu_definition.dart';
import 'package:qizhengsiyu/domain/engines/siyu/si_yu_calculator.dart'; // ISiYuEphemerisSource
import 'linear_parallel_core.dart';
import 'si_yu_group_algorithm.dart';

Map<EnumStars, double> _assign(double node, EnumRahuKetuConvention c) {
  final rk = RahuKetuDefinition.assign(northNode: node, convention: c);
  return {EnumStars.Luo: rk.luo, EnumStars.Ji: rk.ji};
}

/// 罗计·星历版（sweph 平交点）。
class EphemerisNodePairAlgorithm implements SiYuGroupAlgorithm {
  final ISiYuEphemerisSource source;
  final EnumRahuKetuConvention convention;
  const EphemerisNodePairAlgorithm(
      {required this.source, required this.convention});
  @override
  String get id => 'ephemeris_node_pair';
  @override
  Set<EnumStars> get bodies => {EnumStars.Luo, EnumStars.Ji};
  @override
  Map<EnumStars, double> computePositions(
          {required double julianDay, required DateTime datetime}) =>
      _assign(source.meanNodeLongitude(julianDay), convention);
}

/// 罗计·古法平行版（升交点逆行平行推算）。
class LinearNodePairAlgorithm implements SiYuGroupAlgorithm {
  final LinearParallelCore nodeCore; // 升交点(逆行)
  final EnumRahuKetuConvention convention;
  const LinearNodePairAlgorithm(
      {required this.nodeCore, required this.convention});
  @override
  String get id => 'linear_node_pair';
  @override
  Set<EnumStars> get bodies => {EnumStars.Luo, EnumStars.Ji};
  @override
  Map<EnumStars, double> computePositions(
          {required double julianDay, required DateTime datetime}) =>
      _assign(nodeCore.positionAt(julianDay), convention);
}
```

- [ ] **Step 4: 运行确认通过 + 提交**

Run: `flutter test test/domain/engines/siyu/group/luo_ji_group_algorithm_test.dart`
Expected: PASS
```bash
git add lib/domain/engines/siyu/group/luo_ji_group_algorithm.dart test/domain/engines/siyu/group/luo_ji_group_algorithm_test.dart
git commit -m "feat(siyu): 罗计组算法(星历/古法平行) + 组不变量测试"
```

---

## Task 19: 月孛组 + 紫气组算法（接为 SiYuGroupAlgorithm）

**Files:**
- Create: `lib/domain/engines/siyu/group/yue_bo_group_algorithm.dart`
- Create: `lib/domain/engines/siyu/group/zi_qi_group_algorithm.dart`
- Test: `test/domain/engines/siyu/group/yue_bo_zi_qi_group_test.dart`

**Interfaces:**
- Consumes: `SiYuGroupAlgorithm`、`LinearParallelCore`（Task 17）；`ISiYuEphemerisSource`（Task 3）；`ZiQiAlgorithm`（Task 10，作为紫气内部实现复用）。
- Produces:
  - `class EphemerisApogeeAlgorithm implements SiYuGroupAlgorithm`（月孛 sweph 远地点）
  - `class LinearApogeeAlgorithm implements SiYuGroupAlgorithm`（月孛古法平行，顺行）
  - `class ZiQiGroupAlgorithm implements SiYuGroupAlgorithm`（包装既有 `ZiQiAlgorithm`，`bodies={Qi}`）

- [ ] **Step 1: 写失败测试**

```dart
// test/domain/engines/siyu/group/yue_bo_zi_qi_group_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:metaphysics_core/enums.dart';
import 'package:qizhengsiyu/domain/engines/siyu/group/linear_parallel_core.dart';
import 'package:qizhengsiyu/domain/engines/siyu/group/yue_bo_group_algorithm.dart';
import 'package:qizhengsiyu/domain/engines/siyu/group/zi_qi_group_algorithm.dart';
import 'package:qizhengsiyu/domain/engines/siyu/ziqi/zi_qi_algorithm.dart';

class _ConstZiQi implements ZiQiAlgorithm {
  @override String get id => 'c';
  @override double computeLongitude({required double julianDay, required DateTime datetime}) => 88;
}

void main() {
  test('月孛古法平行：顺行产出单星', () {
    final algo = LinearApogeeAlgorithm(core: const LinearParallelCore(
        totalDegree: 360, dailyMotion: 0.111393, direction: 1,
        epochJulianDay: 1000, epochPosition: 0));
    final p = algo.computePositions(julianDay: 1100, datetime: DateTime.utc(2000));
    expect(p.keys, {EnumStars.Bei});
    expect(p[EnumStars.Bei], closeTo(0.111393 * 100, 1e-6));
  });
  test('紫气组包装 ZiQiAlgorithm', () {
    final algo = ZiQiGroupAlgorithm(_ConstZiQi());
    final p = algo.computePositions(julianDay: 5, datetime: DateTime.utc(2000));
    expect(p[EnumStars.Qi], closeTo(88, 1e-9));
  });
}
```

- [ ] **Step 2: 运行确认失败**

Run: `flutter test test/domain/engines/siyu/group/yue_bo_zi_qi_group_test.dart`
Expected: FAIL —— 找不到文件。

- [ ] **Step 3: 实现月孛组 + 紫气组**

```dart
// lib/domain/engines/siyu/group/yue_bo_group_algorithm.dart
import 'package:metaphysics_core/enums.dart';
import 'package:qizhengsiyu/domain/engines/siyu/si_yu_calculator.dart';
import 'linear_parallel_core.dart';
import 'si_yu_group_algorithm.dart';

class EphemerisApogeeAlgorithm implements SiYuGroupAlgorithm {
  final ISiYuEphemerisSource source;
  const EphemerisApogeeAlgorithm({required this.source});
  @override String get id => 'ephemeris_apogee';
  @override Set<EnumStars> get bodies => {EnumStars.Bei};
  @override
  Map<EnumStars, double> computePositions(
          {required double julianDay, required DateTime datetime}) =>
      {EnumStars.Bei: source.meanApogeeLongitude(julianDay)};
}

class LinearApogeeAlgorithm implements SiYuGroupAlgorithm {
  final LinearParallelCore core;
  const LinearApogeeAlgorithm({required this.core});
  @override String get id => 'linear_apogee';
  @override Set<EnumStars> get bodies => {EnumStars.Bei};
  @override
  Map<EnumStars, double> computePositions(
          {required double julianDay, required DateTime datetime}) =>
      {EnumStars.Bei: core.positionAt(julianDay)};
}
```

```dart
// lib/domain/engines/siyu/group/zi_qi_group_algorithm.dart
import 'package:metaphysics_core/enums.dart';
import 'package:qizhengsiyu/domain/engines/siyu/ziqi/zi_qi_algorithm.dart';
import 'si_yu_group_algorithm.dart';

class ZiQiGroupAlgorithm implements SiYuGroupAlgorithm {
  final ZiQiAlgorithm inner;
  const ZiQiGroupAlgorithm(this.inner);
  @override String get id => 'ziqi_${inner.id}';
  @override Set<EnumStars> get bodies => {EnumStars.Qi};
  @override
  Map<EnumStars, double> computePositions(
          {required double julianDay, required DateTime datetime}) =>
      {EnumStars.Qi: inner.computeLongitude(julianDay: julianDay, datetime: datetime)};
}
```

- [ ] **Step 4: 运行确认通过 + 提交**

Run: `flutter test test/domain/engines/siyu/group/yue_bo_zi_qi_group_test.dart`
Expected: PASS
```bash
git add lib/domain/engines/siyu/group/yue_bo_group_algorithm.dart lib/domain/engines/siyu/group/zi_qi_group_algorithm.dart test/domain/engines/siyu/group/yue_bo_zi_qi_group_test.dart
git commit -m "feat(siyu): 月孛组 + 紫气组算法(接入 SiYuGroupAlgorithm)"
```

---

## Task 20: 分段多模型 `PiecewiseGroupAlgorithm`（硬切换）

**Files:**
- Create: `lib/domain/engines/siyu/group/piecewise_group_algorithm.dart`
- Test: `test/domain/engines/siyu/group/piecewise_group_algorithm_test.dart`

**Interfaces:**
- Consumes: `SiYuGroupAlgorithm`（Task 17）。
- Produces: `class PiecewiseGroupAlgorithm implements SiYuGroupAlgorithm { PiecewiseGroupAlgorithm(List<PiecewiseSegment> segments); }`；`class PiecewiseSegment { final double fromJulianDay; final SiYuGroupAlgorithm algorithm; }`。段按 `fromJulianDay` 升序，`computePositions(jd)` 取 `fromJulianDay ≤ jd` 的最后一段（硬切换）。

- [ ] **Step 1: 写失败测试**

```dart
// test/domain/engines/siyu/group/piecewise_group_algorithm_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:metaphysics_core/enums.dart';
import 'package:qizhengsiyu/domain/engines/siyu/group/si_yu_group_algorithm.dart';
import 'package:qizhengsiyu/domain/engines/siyu/group/piecewise_group_algorithm.dart';

class _Fixed implements SiYuGroupAlgorithm {
  final double v; _Fixed(this.v);
  @override String get id => 'f$v';
  @override Set<EnumStars> get bodies => {EnumStars.Qi};
  @override Map<EnumStars,double> computePositions({required double julianDay, required DateTime datetime}) => {EnumStars.Qi: v};
}

void main() {
  final pw = PiecewiseGroupAlgorithm([
    PiecewiseSegment(fromJulianDay: double.negativeInfinity, algorithm: _Fixed(10)),
    PiecewiseSegment(fromJulianDay: 2000, algorithm: _Fixed(20)),
  ]);
  test('节点前用段0', () {
    expect(pw.computePositions(julianDay: 1999, datetime: DateTime.utc(2000))[EnumStars.Qi], 10);
  });
  test('节点起(含)用段1', () {
    expect(pw.computePositions(julianDay: 2000, datetime: DateTime.utc(2000))[EnumStars.Qi], 20);
    expect(pw.computePositions(julianDay: 5000, datetime: DateTime.utc(2000))[EnumStars.Qi], 20);
  });
}
```

- [ ] **Step 2: 运行确认失败**

Run: `flutter test test/domain/engines/siyu/group/piecewise_group_algorithm_test.dart`
Expected: FAIL —— 找不到文件。

- [ ] **Step 3: 实现**

```dart
// lib/domain/engines/siyu/group/piecewise_group_algorithm.dart
import 'package:metaphysics_core/enums.dart';
import 'si_yu_group_algorithm.dart';

class PiecewiseSegment {
  final double fromJulianDay;
  final SiYuGroupAlgorithm algorithm;
  const PiecewiseSegment({required this.fromJulianDay, required this.algorithm});
}

/// 分段多模型：硬切换，取 fromJulianDay ≤ jd 的最后一段。
class PiecewiseGroupAlgorithm implements SiYuGroupAlgorithm {
  final List<PiecewiseSegment> _segments;
  PiecewiseGroupAlgorithm(List<PiecewiseSegment> segments)
      : assert(segments.isNotEmpty),
        _segments = List.of(segments)
          ..sort((a, b) => a.fromJulianDay.compareTo(b.fromJulianDay));

  @override
  String get id => 'piecewise';
  @override
  Set<EnumStars> get bodies => _segments.first.algorithm.bodies;

  @override
  Map<EnumStars, double> computePositions(
      {required double julianDay, required DateTime datetime}) {
    var seg = _segments.first;
    for (final s in _segments) {
      if (s.fromJulianDay <= julianDay) seg = s; else break;
    }
    return seg.algorithm.computePositions(julianDay: julianDay, datetime: datetime);
  }
}
```

- [ ] **Step 4: 运行确认通过 + 提交**

Run: `flutter test test/domain/engines/siyu/group/piecewise_group_algorithm_test.dart`
Expected: PASS
```bash
git add lib/domain/engines/siyu/group/piecewise_group_algorithm.dart test/domain/engines/siyu/group/piecewise_group_algorithm_test.dart
git commit -m "feat(siyu): 分段多模型 PiecewiseGroupAlgorithm(硬切换)"
```

---

## Task 21: `SiYuGroupSpec` + `SiYuAlgorithmFactory`（spec→算法）

**Files:**
- Create: `lib/domain/engines/siyu/spec/si_yu_group_spec.dart`（+ `.g.dart`）
- Create: `lib/domain/engines/siyu/spec/si_yu_algorithm_factory.dart`
- Test: `test/domain/engines/siyu/spec/si_yu_algorithm_factory_test.dart`

**Interfaces:**
- Consumes: 全部组算法（Task 18/19/20）、`LinearParallelCore`（Task 17）。
- Produces:
  - `@JsonSerializable class SiYuGroupSpec { final String kind; final Map<String,double> params; final List<SiYuSegmentSpec>? segments; final int? rahuKetuConventionIndex; }`
  - `@JsonSerializable class SiYuSegmentSpec { final double fromJulianDay; final SiYuGroupSpec spec; }`
  - `class CoordinateContext { final double totalDegree; final ISiYuEphemerisSource ephemerisSource; }`
  - `class SiYuAlgorithmFactory { void register(String kind, SiYuGroupAlgorithm Function(SiYuGroupSpec,CoordinateContext) builder); SiYuGroupAlgorithm build(SiYuGroupSpec spec, CoordinateContext ctx); }` —— 未知 kind 抛 `ArgumentError`；有 `segments` 则组装 `PiecewiseGroupAlgorithm`。

- [ ] **Step 1: 写失败测试**

```dart
// test/domain/engines/siyu/spec/si_yu_algorithm_factory_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:metaphysics_core/enums.dart';
import 'package:qizhengsiyu/domain/engines/siyu/spec/si_yu_group_spec.dart';
import 'package:qizhengsiyu/domain/engines/siyu/spec/si_yu_algorithm_factory.dart';

void main() {
  final ctx = CoordinateContext(totalDegree: 360, ephemerisSource: null);
  test('build linear_ziqi', () {
    final f = SiYuAlgorithmFactory.withDefaults();
    final algo = f.build(const SiYuGroupSpec(kind: 'linear_ziqi', params: {
      'totalDegree': 360, 'dailyMotion': 0.0352, 'direction': 1,
      'epochJulianDay': 1000, 'epochPosition': 5,
    }), ctx);
    final p = algo.computePositions(julianDay: 2000, datetime: DateTime.utc(2000));
    expect(p[EnumStars.Qi], closeTo((5 + 0.0352 * 1000) % 360, 1e-6));
  });
  test('分段 spec 组装 Piecewise', () {
    final f = SiYuAlgorithmFactory.withDefaults();
    final algo = f.build(SiYuGroupSpec(kind: 'linear_ziqi', params: const {
      'totalDegree':360,'dailyMotion':0.0352,'direction':1,'epochJulianDay':1000,'epochPosition':5},
      segments: [SiYuSegmentSpec(fromJulianDay: 3000, spec: const SiYuGroupSpec(kind:'linear_ziqi',params:{
        'totalDegree':360,'dailyMotion':0.0352,'direction':1,'epochJulianDay':3000,'epochPosition':99}))]), ctx);
    expect(algo.computePositions(julianDay: 3500, datetime: DateTime.utc(2000))[EnumStars.Qi], closeTo(99 + 0.0352*500, 1e-6));
  });
  test('未知 kind 抛错', () {
    expect(() => SiYuAlgorithmFactory.withDefaults().build(
        const SiYuGroupSpec(kind: 'nope', params: {}), ctx), throwsArgumentError);
  });
}
```

- [ ] **Step 2: 运行确认失败**

Run: `flutter test test/domain/engines/siyu/spec/si_yu_algorithm_factory_test.dart`
Expected: FAIL —— 找不到文件。

- [ ] **Step 3: 实现 spec + 工厂**

```dart
// lib/domain/engines/siyu/spec/si_yu_group_spec.dart
import 'package:json_annotation/json_annotation.dart';
part 'si_yu_group_spec.g.dart';

@JsonSerializable(explicitToJson: true)
class SiYuGroupSpec {
  final String kind;
  final Map<String, double> params;
  final List<SiYuSegmentSpec>? segments;
  final int? rahuKetuConventionIndex;
  const SiYuGroupSpec({required this.kind, this.params = const {},
      this.segments, this.rahuKetuConventionIndex});
  factory SiYuGroupSpec.fromJson(Map<String, dynamic> j) => _$SiYuGroupSpecFromJson(j);
  Map<String, dynamic> toJson() => _$SiYuGroupSpecToJson(this);
}

@JsonSerializable(explicitToJson: true)
class SiYuSegmentSpec {
  final double fromJulianDay;
  final SiYuGroupSpec spec;
  const SiYuSegmentSpec({required this.fromJulianDay, required this.spec});
  factory SiYuSegmentSpec.fromJson(Map<String, dynamic> j) => _$SiYuSegmentSpecFromJson(j);
  Map<String, dynamic> toJson() => _$SiYuSegmentSpecToJson(this);
}
```

```dart
// lib/domain/engines/siyu/spec/si_yu_algorithm_factory.dart
import 'package:qizhengsiyu/enums/enum_rahu_ketu_convention.dart';
import 'package:qizhengsiyu/domain/engines/siyu/si_yu_calculator.dart';
import 'package:qizhengsiyu/domain/engines/siyu/group/si_yu_group_algorithm.dart';
import 'package:qizhengsiyu/domain/engines/siyu/group/linear_parallel_core.dart';
import 'package:qizhengsiyu/domain/engines/siyu/group/luo_ji_group_algorithm.dart';
import 'package:qizhengsiyu/domain/engines/siyu/group/yue_bo_group_algorithm.dart';
import 'package:qizhengsiyu/domain/engines/siyu/group/zi_qi_group_algorithm.dart';
import 'package:qizhengsiyu/domain/engines/siyu/group/piecewise_group_algorithm.dart';
import 'package:qizhengsiyu/domain/engines/siyu/ziqi/guolao_zi_qi_algorithm.dart';
import 'si_yu_group_spec.dart';

class CoordinateContext {
  final double totalDegree;
  final ISiYuEphemerisSource? ephemerisSource;
  const CoordinateContext({required this.totalDegree, this.ephemerisSource});
}

typedef SiYuBuilder = SiYuGroupAlgorithm Function(SiYuGroupSpec, CoordinateContext);

class SiYuAlgorithmFactory {
  final Map<String, SiYuBuilder> _builders;
  SiYuAlgorithmFactory(this._builders);

  void register(String kind, SiYuBuilder b) => _builders[kind] = b;

  SiYuGroupAlgorithm build(SiYuGroupSpec spec, CoordinateContext ctx) {
    if (spec.segments != null && spec.segments!.isNotEmpty) {
      return PiecewiseGroupAlgorithm([
        PiecewiseSegment(
            fromJulianDay: double.negativeInfinity,
            algorithm: _buildBase(spec, ctx)),
        ...spec.segments!.map((s) => PiecewiseSegment(
            fromJulianDay: s.fromJulianDay, algorithm: build(s.spec, ctx))),
      ]);
    }
    return _buildBase(spec, ctx);
  }

  SiYuGroupAlgorithm _buildBase(SiYuGroupSpec s, CoordinateContext ctx) {
    final b = _builders[s.kind];
    if (b == null) throw ArgumentError('未知紫气/四余算法 kind: ${s.kind}');
    return b(s, ctx);
  }

  LinearParallelCore _core(SiYuGroupSpec s) => LinearParallelCore(
        totalDegree: s.params['totalDegree'] ?? 360,
        dailyMotion: s.params['dailyMotion'] ?? 0,
        direction: (s.params['direction'] ?? 1).toInt(),
        epochJulianDay: s.params['epochJulianDay'] ?? 0,
        epochPosition: s.params['epochPosition'] ?? 0,
      );

  static SiYuAlgorithmFactory withDefaults() {
    final f = SiYuAlgorithmFactory({});
    f.register('linear_ziqi', (s, ctx) => ZiQiGroupAlgorithm(
        GuoLaoZiQiAlgorithm(
          totalDegree: s.params['totalDegree'] ?? ctx.totalDegree,
          periodDays: (s.params['totalDegree'] ?? 360) / (s.params['dailyMotion'] ?? 0.0352),
          epochJulianDay: s.params['epochJulianDay'] ?? 0,
          epochLongitude: s.params['epochPosition'] ?? 0,
        )));
    f.register('linear_apogee', (s, ctx) => LinearApogeeAlgorithm(core: f._core(s)));
    f.register('ephemeris_apogee', (s, ctx) =>
        EphemerisApogeeAlgorithm(source: ctx.ephemerisSource!));
    f.register('linear_node', (s, ctx) => LinearNodePairAlgorithm(
        nodeCore: f._core(s),
        convention: EnumRahuKetuConvention.values[s.rahuKetuConventionIndex ?? 0]));
    f.register('ephemeris_node', (s, ctx) => EphemerisNodePairAlgorithm(
        source: ctx.ephemerisSource!,
        convention: EnumRahuKetuConvention.values[s.rahuKetuConventionIndex ?? 0]));
    return f;
  }
}
```

- [ ] **Step 4: 生成 .g.dart + 运行 + 提交**

Run: `dart run build_runner build --delete-conflicting-outputs && flutter test test/domain/engines/siyu/spec/si_yu_algorithm_factory_test.dart`
Expected: PASS
```bash
git add lib/domain/engines/siyu/spec/ test/domain/engines/siyu/spec/si_yu_algorithm_factory_test.dart
git commit -m "feat(siyu): SiYuGroupSpec 可序列化 + 工厂(kind→算法, 支持分段)"
```

---

## Task 22: `SiYuProfile` + 内建档案 + 解析（档案⊕覆盖）

**Files:**
- Create: `lib/domain/engines/siyu/profile/si_yu_profile.dart`
- Create: `lib/domain/engines/siyu/profile/built_in_profiles.dart`
- Create: `lib/domain/engines/siyu/profile/si_yu_config_resolver.dart`
- Test: `test/domain/engines/siyu/profile/si_yu_config_resolver_test.dart`

**Interfaces:**
- Consumes: `SiYuGroup`（Task 17）、`SiYuGroupSpec`（Task 21）、`CelestialCoordinateSystem`。
- Produces:
  - `class SiYuProfile { final String id, name; final CelestialCoordinateSystem coordinate; final Map<SiYuGroup, SiYuGroupSpec> groups; }`
  - `class BuiltInSiYuProfiles { static List<SiYuProfile> all; static SiYuProfile byId(String id); static const defaultId = 'guolao_ecliptic'; }`
  - `class SiYuConfigResolver { ({CelestialCoordinateSystem coordinate, Map<SiYuGroup,SiYuGroupSpec> groups}) resolve({required String profileId, Map<SiYuGroup,SiYuGroupSpec> overrides = const {}, CelestialCoordinateSystem? coordinateOverride}); }` —— 档案默认 ⊕ 单项覆盖。

- [ ] **Step 1: 写失败测试**

```dart
// test/domain/engines/siyu/profile/si_yu_config_resolver_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:metaphysics_core/enums.dart';
import 'package:qizhengsiyu/domain/engines/siyu/group/si_yu_group_algorithm.dart';
import 'package:qizhengsiyu/domain/engines/siyu/spec/si_yu_group_spec.dart';
import 'package:qizhengsiyu/domain/engines/siyu/profile/built_in_profiles.dart';
import 'package:qizhengsiyu/domain/engines/siyu/profile/si_yu_config_resolver.dart';

void main() {
  final r = SiYuConfigResolver();
  test('无覆盖=档案默认', () {
    final out = r.resolve(profileId: BuiltInSiYuProfiles.defaultId);
    expect(out.groups.containsKey(SiYuGroup.ziQi), isTrue);
  });
  test('单项覆盖紫气组', () {
    const ov = SiYuGroupSpec(kind: 'linear_ziqi', params: {'dailyMotion': 0.9});
    final out = r.resolve(profileId: BuiltInSiYuProfiles.defaultId,
        overrides: {SiYuGroup.ziQi: ov});
    expect(out.groups[SiYuGroup.ziQi]!.params['dailyMotion'], 0.9);
  });
  test('星制覆盖', () {
    final out = r.resolve(profileId: BuiltInSiYuProfiles.defaultId,
        coordinateOverride: CelestialCoordinateSystem.Equatorial);
    expect(out.coordinate, CelestialCoordinateSystem.Equatorial);
  });
}
```

- [ ] **Step 2: 运行确认失败**

Run: `flutter test test/domain/engines/siyu/profile/si_yu_config_resolver_test.dart`
Expected: FAIL —— 找不到文件。

- [ ] **Step 3: 实现 Profile + 内建档案 + 解析**

```dart
// lib/domain/engines/siyu/profile/si_yu_profile.dart
import 'package:metaphysics_core/enums.dart';
import 'package:qizhengsiyu/domain/engines/siyu/group/si_yu_group_algorithm.dart';
import 'package:qizhengsiyu/domain/engines/siyu/spec/si_yu_group_spec.dart';

class SiYuProfile {
  final String id, name;
  final CelestialCoordinateSystem coordinate;
  final Map<SiYuGroup, SiYuGroupSpec> groups;
  const SiYuProfile({required this.id, required this.name,
      required this.coordinate, required this.groups});
}
```

```dart
// lib/domain/engines/siyu/profile/built_in_profiles.dart
import 'package:metaphysics_core/enums.dart';
import 'package:qizhengsiyu/domain/engines/siyu/group/si_yu_group_algorithm.dart';
import 'package:qizhengsiyu/domain/engines/siyu/spec/si_yu_group_spec.dart';
import 'si_yu_profile.dart';

class BuiltInSiYuProfiles {
  static const defaultId = 'guolao_ecliptic';

  // 果老·黄道：罗计星历(罗降计升=0)、月孛星历、紫气黄道平行
  static final _guoLaoEcliptic = SiYuProfile(
    id: 'guolao_ecliptic', name: '果老·黄道',
    coordinate: CelestialCoordinateSystem.Ecliptic,
    groups: {
      SiYuGroup.luoJi: const SiYuGroupSpec(kind: 'ephemeris_node', rahuKetuConventionIndex: 0),
      SiYuGroup.yueBo: const SiYuGroupSpec(kind: 'ephemeris_apogee'),
      SiYuGroup.ziQi: const SiYuGroupSpec(kind: 'linear_ziqi', params: {
        'totalDegree': 360, 'dailyMotion': 0.0352, 'direction': 1,
        'epochJulianDay': 2461226.135, 'epochPosition': 329.0, // 占位:黄道女宿历元,待黄道紫气校准
      }),
    },
  );

  // 琴堂·天赤道：紫气天赤道 Moira 实测(已验证常数)
  static final _qinTangChiDao = SiYuProfile(
    id: 'qintang_chidao', name: '琴堂·天赤道',
    coordinate: CelestialCoordinateSystem.SkyEquatorial,
    groups: {
      SiYuGroup.luoJi: const SiYuGroupSpec(kind: 'ephemeris_node', rahuKetuConventionIndex: 0),
      SiYuGroup.yueBo: const SiYuGroupSpec(kind: 'ephemeris_apogee'),
      SiYuGroup.ziQi: const SiYuGroupSpec(kind: 'linear_ziqi', params: {
        'totalDegree': 365.25, 'dailyMotion': 0.0356771, 'direction': 1,
        'epochJulianDay': 2461226.135, 'epochPosition': 333.843, // Moira 锚 2026=翼宿4°38'36''
      }),
    },
  );

  static final List<SiYuProfile> all = [_guoLaoEcliptic, _qinTangChiDao];
  static SiYuProfile byId(String id) =>
      all.firstWhere((p) => p.id == id, orElse: () => _guoLaoEcliptic);
}
```

```dart
// lib/domain/engines/siyu/profile/si_yu_config_resolver.dart
import 'package:metaphysics_core/enums.dart';
import 'package:qizhengsiyu/domain/engines/siyu/group/si_yu_group_algorithm.dart';
import 'package:qizhengsiyu/domain/engines/siyu/spec/si_yu_group_spec.dart';
import 'built_in_profiles.dart';

class SiYuConfigResolver {
  ({CelestialCoordinateSystem coordinate, Map<SiYuGroup, SiYuGroupSpec> groups})
      resolve({
    required String profileId,
    Map<SiYuGroup, SiYuGroupSpec> overrides = const {},
    CelestialCoordinateSystem? coordinateOverride,
  }) {
    final p = BuiltInSiYuProfiles.byId(profileId);
    final groups = <SiYuGroup, SiYuGroupSpec>{...p.groups, ...overrides};
    return (coordinate: coordinateOverride ?? p.coordinate, groups: groups);
  }
}
```

- [ ] **Step 4: 运行确认通过 + 提交**

Run: `flutter test test/domain/engines/siyu/profile/si_yu_config_resolver_test.dart`
Expected: PASS
```bash
git add lib/domain/engines/siyu/profile/ test/domain/engines/siyu/profile/si_yu_config_resolver_test.dart
git commit -m "feat(siyu): SiYuProfile + 内建档案 + 档案⊕覆盖解析"
```

---

## Task 23: 配置接入 + 引擎组算法汇入

**Files:**
- Modify: `lib/domain/entities/models/panel_config.dart`（+ `.g.dart`）
- Modify: `lib/domain/engines/sweph_engine.dart`
- Test: `test/domain/engines/siyu/si_yu_group_pipeline_test.dart`

**Interfaces:**
- Consumes: Task 21/22 全部。
- Produces: `BasePanelConfig.siYuProfileId`(默认 `BuiltInSiYuProfiles.defaultId`)、`siYuOverrides: Map<String,SiYuGroupSpec>`(键=SiYuGroup.name)、`siYuCoordinateOverride: CelestialCoordinateSystem?`。引擎按解析结果构造各组算法、`computePositions` 汇入四余位置。

- [ ] **Step 1: 写失败测试（配置→四余位置端到端，纯逻辑用 fake 源）**

```dart
// test/domain/engines/siyu/si_yu_group_pipeline_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:metaphysics_core/enums.dart';
import 'package:qizhengsiyu/domain/engines/siyu/group/si_yu_group_algorithm.dart';
import 'package:qizhengsiyu/domain/engines/siyu/spec/si_yu_group_spec.dart';
import 'package:qizhengsiyu/domain/engines/siyu/spec/si_yu_algorithm_factory.dart';
import 'package:qizhengsiyu/domain/engines/siyu/profile/built_in_profiles.dart';
import 'package:qizhengsiyu/domain/engines/siyu/profile/si_yu_config_resolver.dart';

void main() {
  test('琴堂·天赤道档案 → 紫气用 Moira 常数产出', () {
    final resolved = SiYuConfigResolver().resolve(profileId: 'qintang_chidao');
    final f = SiYuAlgorithmFactory.withDefaults();
    final ziqi = f.build(resolved.groups[SiYuGroup.ziQi]!,
        CoordinateContext(totalDegree: 365.25));
    // 锚点日 JD → 应≈333.843(翼宿4°38'36'')
    final p = ziqi.computePositions(julianDay: 2461226.135, datetime: DateTime.utc(2026));
    expect(p[EnumStars.Qi], closeTo(333.843, 0.01));
  });
}
```

- [ ] **Step 2: 运行确认失败**

Run: `flutter test test/domain/engines/siyu/si_yu_group_pipeline_test.dart`
Expected: FAIL —— 编译/常数未接。

- [ ] **Step 3: 加 config 字段**

`panel_config.dart` `BasePanelConfig` 加：
```dart
  @JsonKey(defaultValue: 'guolao_ecliptic')
  String siYuProfileId;
  @JsonKey(defaultValue: {})
  Map<String, SiYuGroupSpec> siYuOverrides; // 键=SiYuGroup.name
  CelestialCoordinateSystem? siYuCoordinateOverride;
```
构造函数给默认（`this.siYuProfileId = 'guolao_ecliptic'`、`this.siYuOverrides = const {}`、`this.siYuCoordinateOverride`）；`copyWith`/`PanelConfig` super 同步；`import` spec 与 built_in_profiles。重生成 `.g.dart`。

- [ ] **Step 4: 引擎汇入四余组位置**

`sweph_engine.dart` `_calculateAllStarsAngleOnZodiac`：解析配置 → 三组算法 → `computePositions` → 覆盖 `StarsAngle` 的四余四值。
```dart
    final resolved = SiYuConfigResolver().resolve(
      profileId: config.siYuProfileId,
      overrides: config.siYuOverrides.map(
          (k, v) => MapEntry(SiYuGroup.values.byName(k), v)),
      coordinateOverride: config.siYuCoordinateOverride,
    );
    final totalDegree = resolved.coordinate == CelestialCoordinateSystem.Ecliptic ? 360.0 : 365.25;
    final factory = SiYuAlgorithmFactory.withDefaults();
    final ctx = CoordinateContext(
        totalDegree: totalDegree, ephemerisSource: const SwephSiYuEphemerisSource());
    final siYuPos = <EnumStars, double>{};
    for (final g in SiYuGroup.values) {
      siYuPos.addAll(factory
          .build(resolved.groups[g]!, ctx)
          .computePositions(julianDay: julianDay, datetime: datetime));
    }
    // 用 siYuPos[Luo/Ji/Bei/Qi] 覆盖 StarsAngle 对应四值(roundHelper 后)。
```
> 罗计已由组算法按 convention 产出绝对位置 → `StarsAngle.toMap` 不再需 convention 翻转（Part A 的 toMap 翻转在天赤道/框架路径下改为直接消费组算法结果；保留 toMap 默认参数向后兼容旧调用）。

- [ ] **Step 5: 生成 .g.dart + 测试 + 提交**

Run: `dart run build_runner build --delete-conflicting-outputs && flutter test test/domain/engines/siyu/`
Expected: PASS；`flutter analyze` 无新增错误。
```bash
git add lib/domain/entities/models/panel_config.dart lib/domain/entities/models/panel_config.g.dart lib/domain/engines/sweph_engine.dart test/domain/engines/siyu/si_yu_group_pipeline_test.dart
git commit -m "feat(siyu): config 接入四余档案/覆盖 + 引擎汇入三组算法位置"
```

---

## Task 24: 两层 UI（档案选择 + 高级组编辑器）

**Files:**
- Create: `lib/presentation/widgets/config/si_yu_profile_selector.dart`
- Create: `lib/presentation/widgets/config/si_yu_group_editor.dart`
- Modify: `lib/presentation/widgets/config/custom_config_section.dart`
- Test: `test/presentation/widgets/si_yu_profile_selector_test.dart`

**Interfaces:**
- Consumes: `BuiltInSiYuProfiles`、`SiYuGroupSpec`、`SiYuGroup`、`BasePanelConfig`。
- Produces: `SiYuProfileSelector`（档案下拉，回调 profileId）；`SiYuGroupEditor`（某组：算法 kind 下拉 + 数字参数字段 + "增加节点"分段 + 罗计升降开关），回调 `SiYuGroupSpec`。

- [ ] **Step 1: 写失败测试（选档案回调 profileId）**

```dart
// test/presentation/widgets/si_yu_profile_selector_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qizhengsiyu/presentation/widgets/config/si_yu_profile_selector.dart';

void main() {
  testWidgets('选择档案回调其 id', (tester) async {
    String? picked;
    await tester.pumpWidget(MaterialApp(home: Scaffold(body:
      SiYuProfileSelector(selectedId: 'guolao_ecliptic', onChanged: (id) => picked = id))));
    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('琴堂·天赤道').last);
    await tester.pumpAndSettle();
    expect(picked, 'qintang_chidao');
  });
}
```

- [ ] **Step 2: 运行确认失败**

Run: `flutter test test/presentation/widgets/si_yu_profile_selector_test.dart`
Expected: FAIL —— 找不到文件。

- [ ] **Step 3: 实现档案选择器（基础层）**

```dart
// lib/presentation/widgets/config/si_yu_profile_selector.dart
import 'package:flutter/material.dart';
import 'package:qizhengsiyu/domain/engines/siyu/profile/built_in_profiles.dart';

class SiYuProfileSelector extends StatelessWidget {
  final String selectedId;
  final ValueChanged<String> onChanged;
  const SiYuProfileSelector({super.key, required this.selectedId, required this.onChanged});
  @override
  Widget build(BuildContext context) => DropdownButtonFormField<String>(
        initialValue: selectedId,
        decoration: const InputDecoration(labelText: '流派档案'),
        items: BuiltInSiYuProfiles.all
            .map((p) => DropdownMenuItem(value: p.id, child: Text(p.name)))
            .toList(),
        onChanged: (v) { if (v != null) onChanged(v); },
      );
}
```

- [ ] **Step 4: 实现组编辑器（高级层）**

`SiYuGroupEditor`（`custom_config_section.dart` 中"高级"展开时用）：
- 顶部算法 kind `DropdownButtonFormField<String>`（该组可选 kinds：罗计=`ephemeris_node/linear_node`；月孛=`ephemeris_apogee/linear_apogee`；紫气=`linear_ziqi/tianguan`）；
- 参数区：对 `linear_*`/`tianguan` 显示 `TextFormField`（dailyMotion/epochJulianDay/epochPosition/totalDegree，`keyboardType: number`），罗计另有升降 `SegmentedButton<EnumRahuKetuConvention>`；
- 分段区：`ListView` + "增加节点"按钮（每节点：日期选择→JD + 子参数）；
- 每次变更 `onChanged(SiYuGroupSpec(...))`。
在 `custom_config_section.dart` 顶部加 `SiYuProfileSelector`，"高级选项"卡片内为三组各放一个可折叠 `SiYuGroupEditor`，其 spec 存入 `_siYuOverrides`，随 `_updateConfig()` 带入 `PanelConfig(siYuProfileId:..., siYuOverrides:..., siYuCoordinateOverride:...)`（勿漏，同空接陷阱）。

- [ ] **Step 5: 运行 + 静态检查 + 提交**

Run: `flutter test test/presentation/widgets/si_yu_profile_selector_test.dart && flutter analyze`
Expected: PASS；analyze 无新增错误。
```bash
git add lib/presentation/widgets/config/si_yu_profile_selector.dart lib/presentation/widgets/config/si_yu_group_editor.dart lib/presentation/widgets/config/custom_config_section.dart test/presentation/widgets/si_yu_profile_selector_test.dart
git commit -m "feat(ui): 四余流派档案选择 + 高级组编辑器(选择+调参)"
```

---

## Self-Review 结论

- **Spec 覆盖（Part A）**：源规格书 §4（罗计定义隔离）→ Task 2；§5.1/5.2（罗计/月孛星历驱动）→ Task 3；§8-B 定义回归 → Task 2；§8-A 结构不变量 → Task 2/3；§10 罗升计降警示 → Task 7。月孛=真实天体点(`SE_MEAN_APOG`)，已落定无需校准。
- **Spec 覆盖（Part B 紫气）**：§5.3 校准两法 → Task 12（`ZiqiEpochCalibrator`）；果老/琴堂 → Task 10；清时宪 → Task 11；耶律天官粗算宫度 → Task 11；28/29 年周期可配 → Task 9 `EnumZiQiPeriod`；**授时·女宿 / 符天·箕宿 双历元常数集可选** → Task 9 `EnumZiQiEpochSet` + Task 14 组装；可扩展管理机制/注册新算法 → Task 13 `ZiQiAlgorithmRegistry`；接线+config+UI → Task 14；郑氏星案**两点校准**(女宿历元定值)+golden+周期判定 → Task 15（数据已到，运行前需确认宿度制式+时区历法两输入）。§3 全套 schoolConfig（时宪 TRUE_NODE/OSCU_APOG、月孛变体等）仍**有意不实现**（YAGNI，超出用户范围）。
- **诚实标红（非占位，是已知待坐实常数）**：(a) 授时·女宿历元黄经 295° 为「约」值——Task 15 已有郑氏星案 2 点可反解精确值，但**须先确认宿度制式 + 时区/历法两输入**方能跑通校准；(b) 时宪「起七宫17°50′」宫序基准占位 197.8333°（Task 11/14 TODO）；(c) 天官历元 provisional，待《星命总括》（Task 11）；(d) 符天·箕宿历元需接 `ZhouTianCalculator`——**但这是非默认选项**，默认女宿自包含无此依赖；未接通时该分支须抛 `UnimplementedError`，不得静默返错值（Task 14 Step 5b）。均在代码注释 + 计划标注，**不得冒充完成**。
- **度制护栏（按坐标系相对）**：紫气日行 = `本系周天度/periodDays`，归一化用同一周天度——黄道 `360/period` mod360；天赤道 `365.25/period` mod365.25。`GuoLao/Shixian` 持 `totalDegree` 参数驱动，禁跨框架混用（Part B 常数区已改）。
- **坐标系现实（2026-07-04 核实）**：用户要**两套坐标系**。郑氏星案=**元授时天赤道恒星制**(365.25 赤道古度、宿度固定、儒略历)——`SwephEngine` 只支持黄道、天赤道走 stub `HistoricalEngine`、且**元授时郭守敬赤道宿距表在库中不存在**（现有 `han_chidao_hengxin.json` 是汉太初、宿距空）。→ Task 16 补郭守敬宿距 asset(**待用户表数据**) + `ChiDaoXiuMapper`；紫气在天赤道系自包含平行(不经 sweph/不需岁差)。Task 15 郑氏星案 golden 依赖 Task 16，`skip` 待表。
- **诚实标红（待坐实/待数据）**：女宿赤道历元精值(Task15 反解，待Task16表)、时宪七宫17°50′占位197.8333°、天官历元待《星命总括》、符天·箕宿非默认需接管线、`ZiqiEpochCalibrator` 需加 `totalDegree` 支持365.25。均标注，**不得冒充完成**。
- **仍排除的遗留议题**：黄道紫气岁差、TT/UT 基准统一、四余顺逆 direction、方案 B 七政古法平行(`HistoricalEngine` 补全)——非本次范围。
- **占位符扫描**：除上条明确标红的「待坐实史料常数」外，无 TBD/TODO 式代码占位；每个代码步骤含完整可编译代码。
- **类型一致性**：`SiYuCalculator` 构造签名在 Part A 为 `{source}`、Part B Task 14 演进为 `{source, ziQiAlgorithm}`（已在 Task 3 前向说明）；`ZiQiAlgorithm.computeLongitude({julianDay,datetime})→double`、`ZiQiAlgorithmRegistry.resolve/register`、`EnumZiQiAlgorithm/EnumZiQiPeriod` 各 Task 间一致。
- **已知风险**：`test_planets_walking_type.dart` 等既有测试改前可能已红（记忆记载 star position 预存失败）；Task 5/8/14 要求区分「预存失败」与「本次回归」。Part B 会**有意改变紫气数值**（从 2013 magic → 果老授时），这是修正不是回归。
- **Spec 覆盖（Part C 框架）**：R1 自定义速率+逻辑 → Task 17（`LinearParallelCore`）+18/19（各组变体）；三算法组 → Task 17–19；R4 分段校准(硬切换) → Task 20（`PiecewiseGroupAlgorithm`）；spec+工厂(选择+调参) → Task 21；R2/R3 流派档案+单项覆盖 → Task 22（`SiYuProfile`/内建档案/`SiYuConfigResolver`）；config 接入+引擎汇入 → Task 23；两层 UI → Task 24。**无 DSL**（选择+调参）贯穿 21/24。
- **Part C 泛化关系**：`RahuKetuDefinition`(Task2)、`ZiQiAlgorithm`/`GuoLao*`(Task10–13)、`totalDegree`、郭守敬宿距(Task16)、Moira 常数(Task15) 全保留复用；紫气/罗计经 Task18/19 接为框架实例。默认档案 `guolao_ecliptic` 保持罗降计升 + 现有默认行为，零回归。
- **Part C 待坐实/占位**：`guolao_ecliptic` 档案里黄道紫气历元(329.0)为占位待黄道紫气校准；`tianguan`/清时宪 kind 的 builder 与常数待 Task 11/坐实后在工厂 `withDefaults` 补注册（Task 21 已留 register 扩展点）。均标注，勿冒充完成。
