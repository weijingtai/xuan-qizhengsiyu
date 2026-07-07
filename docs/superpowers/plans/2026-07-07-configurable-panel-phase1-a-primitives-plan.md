# 七政四余可配置盘制 · 阶段一（A 层配置原语）实施计划

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 把「坐标系(4)/周天制/黄赤道换算(含弧矢)/回归恒星/星宿表(+逐宿覆写)/起点/偏移量」全部做成用户可独立选择的配置原语，接进现有排盘管线，默认行为逐位不变。

**Architecture:** 全部走「`BasePanelConfig` 新增可选字段 → `SwephEngine.getSystemDefinition` 用扩展后的 `ZhouTianModel.applyOverrides` 覆写查表模型 → 现有 `ZhouTianCalculator`/`CelestialProjectorFactory` 链」。新增一个纯函数校验层 `PanelSystemResolver` 做非阻断安全网。弧矢割圆包成 `HuangChiDaoDiffType.hushi` 挂到既有 `TuiBianHuangDaoProjector`。

**Tech Stack:** Dart / Flutter；`json_serializable`（`.g.dart` 代码生成）；`flutter test`；Provider。

## Global Constraints

- 语言：源码注释与文档以中文为主；仅路径/符号用英文（用户全局规则）。
- 分支：`feat/chidao-huangdao-tuibian`（本计划所有提交落此分支，勿在 main）。
- **向后兼容红线**：所有新配置字段默认 `null`；`applyOverrides` 入参全 null 时**返回 `identical(this)`**；**禁止**在初始化写入 `degree360`/`linear`；默认 config 盘面星体/宫位落点须与改动前逐位一致。
- **缓存安全红线**：`ZhouTianModelManager._mapper` 是共享缓存实例，覆写一律 `copyWith` 克隆，**绝不原地 mutate**（含 `starInnDegreeSeq`/`zeroPointAtConstellation` 等列表/对象字段须深拷）。
- TDD：每个 Task 先写失败测试→跑红→最小实现→跑绿→提交。
- 每改一个既有符号前跑 `impact`，改完 `detect_changes`；HIGH/CRITICAL 先告警。
- 代码生成：改动 `@JsonSerializable` 类后必跑 `dart run build_runner build --delete-conflicting-outputs`。
- 单位：弧矢/推变周天恒取 `365.2575`；`diff(c)` 输入赤道古度、输出黄赤道差（度）。
- 参考文档：设计 spec `docs/superpowers/specs/2026-07-07-configurable-panel-school-system-design.md`；领域 `docs/project/architecture/001-*.md`；换算 `docs/project/architecture/002-*.md`。

---

## 文件结构（先锁边界）

| 文件 | 责任 | 动作 |
|---|---|---|
| `lib/enums/enum_zero_point_ref.dart` | 起点参考枚举（春分/冬至/…） | 新建 |
| `lib/enums/enum_constellation_offset_tier.dart` | 偏移档位枚举 + 各档默认偏移常数 | 新建 |
| `lib/domain/entities/models/panel_config.dart`(+`.g.dart`) | A 层新字段承载 | 改 |
| `lib/domain/entities/models/zhou_tian_model.dart` | `applyOverrides` 扩展契约 | 改 |
| `lib/domain/engines/projection/huang_chi_dao_diff.dart` | 新增 `HushiGeyuanDiff` | 改 |
| `lib/domain/entities/models/projection_config.dart`(+`.g.dart`) | `HuangChiDaoDiffType` 增 `hushi` | 改 |
| `lib/domain/managers/celestial_projector_factory.dart` | `_buildDiff` 增 `hushi` 分支 | 改 |
| `lib/domain/engines/sweph_engine.dart` | 资产路由矩阵 + 接扩展 applyOverrides | 改 |
| `lib/domain/managers/panel_system_resolver.dart` | 合法性校验纯函数 | 新建 |
| `lib/presentation/widgets/config/custom_config_section.dart` | 坐标4 + 换算hushi + 起点/偏移/星宿 UI + 警告条 | 改 |
| `test/...`（各对应） | TDD 测试 | 新建/改 |

---

## Task 1: 新增起点与偏移档位枚举

**Files:**
- Create: `lib/enums/enum_zero_point_ref.dart`
- Create: `lib/enums/enum_constellation_offset_tier.dart`
- Test: `test/enums/config_axis_enums_test.dart`

**Interfaces:**
- Produces: `enum EnumZeroPointRef { chunfen, dongzhi }`（含 `String label`）；`enum ConstellationOffsetTier { guXiu, adjusted, modern }`（含 `double defaultOffsetDeg`：`guXiu=0.0`、`adjusted=14.0`、`modern=0.0`）。

- [ ] **Step 1: 写失败测试**

```dart
// test/enums/config_axis_enums_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:qizhengsiyu/enums/enum_zero_point_ref.dart';
import 'package:qizhengsiyu/enums/enum_constellation_offset_tier.dart';

void main() {
  test('EnumZeroPointRef 取值与标签', () {
    expect(EnumZeroPointRef.values.length, 2);
    expect(EnumZeroPointRef.chunfen.label, '春分点');
    expect(EnumZeroPointRef.dongzhi.label, '冬至点');
  });

  test('ConstellationOffsetTier 各档默认偏移', () {
    expect(ConstellationOffsetTier.guXiu.defaultOffsetDeg, 0.0);
    expect(ConstellationOffsetTier.adjusted.defaultOffsetDeg, 14.0);
    expect(ConstellationOffsetTier.modern.defaultOffsetDeg, 0.0);
  });
}
```

- [ ] **Step 2: 跑测试确认失败**

Run: `flutter test test/enums/config_axis_enums_test.dart`
Expected: FAIL（找不到 `enum_zero_point_ref.dart`）

- [ ] **Step 3: 实现枚举**

```dart
// lib/enums/enum_zero_point_ref.dart
import 'package:json_annotation/json_annotation.dart';

/// 周天 0° 原点的参考点（每年起始点）。
enum EnumZeroPointRef {
  /// 春分点（回归制常用）
  @JsonValue('chunfen')
  chunfen('春分点'),

  /// 冬至点（古历常用）
  @JsonValue('dongzhi')
  dongzhi('冬至点');

  const EnumZeroPointRef(this.label);
  final String label;
}
```

```dart
// lib/enums/enum_constellation_offset_tier.dart
import 'package:json_annotation/json_annotation.dart';

/// 星宿偏移档位；各档带默认偏移度数，用户可再用数值微调覆盖。
enum ConstellationOffsetTier {
  /// 古宿：不偏移
  @JsonValue('guXiu')
  guXiu('古宿', 0.0),

  /// 矫正古宿：默认 +14°（古今宿差经验值）
  @JsonValue('adjusted')
  adjusted('矫正古宿', 14.0),

  /// 今宿：不偏移
  @JsonValue('modern')
  modern('今宿', 0.0);

  const ConstellationOffsetTier(this.label, this.defaultOffsetDeg);
  final String label;
  final double defaultOffsetDeg;
}
```

- [ ] **Step 4: 跑测试确认通过**

Run: `flutter test test/enums/config_axis_enums_test.dart`
Expected: PASS

- [ ] **Step 5: 提交**

```bash
git add lib/enums/enum_zero_point_ref.dart lib/enums/enum_constellation_offset_tier.dart test/enums/config_axis_enums_test.dart
git commit -m "feat(config): 新增起点参考与星宿偏移档位枚举"
```

---

## Task 2: `BasePanelConfig` 新增 A 层字段

**Files:**
- Modify: `lib/domain/entities/models/panel_config.dart`
- Regenerate: `lib/domain/entities/models/panel_config.g.dart`
- Test: `test/domain/entities/panel_config_serialization_test.dart`（已存在，追加）

**Interfaces:**
- Consumes: Task 1 的 `EnumZeroPointRef` / `ConstellationOffsetTier`；已有 `EnumZhouTianModel` / `ProjectionConfig`。
- Produces: `BasePanelConfig` 新增可空字段 `EnumZeroPointRef? zeroPointRef`、`ConstellationOffsetTier? offsetTier`、`double? constellationOffsetDeg`、`Map<Enum28Constellations,double>? starInnDegreeOverrides`；`copyWith` 同步扩参。

- [ ] **Step 1: 先跑 impact**

Run: `impact({target: "BasePanelConfig", direction: "upstream"})`
Expected: 报告 `copyWith`/`fromJson`/`defaultBasicPanelConfig` 等；确认无 CRITICAL（新增可空字段为附加式）。

- [ ] **Step 2: 写失败测试（追加到既有序列化测试）**

```dart
// test/domain/entities/panel_config_serialization_test.dart 追加
test('A层新字段 zeroPointRef/offsetTier/偏移/逐宿覆写 往返保真', () {
  final cfg = BasePanelConfig.defaultBasicPanelConfig().copyWith(
    zeroPointRef: EnumZeroPointRef.dongzhi,
    offsetTier: ConstellationOffsetTier.adjusted,
    constellationOffsetDeg: 14.0,
    starInnDegreeOverrides: {Enum28Constellations.jiao: 12.3},
  );
  final round = BasePanelConfig.fromJson(cfg.toJson());
  expect(round.zeroPointRef, EnumZeroPointRef.dongzhi);
  expect(round.offsetTier, ConstellationOffsetTier.adjusted);
  expect(round.constellationOffsetDeg, 14.0);
  expect(round.starInnDegreeOverrides?[Enum28Constellations.jiao], 12.3);
});

test('旧 JSON 缺 A层新字段 → null，不抛异常', () {
  final legacy = BasePanelConfig.defaultBasicPanelConfig().toJson()
    ..remove('zeroPointRef')
    ..remove('offsetTier')
    ..remove('constellationOffsetDeg')
    ..remove('starInnDegreeOverrides');
  final cfg = BasePanelConfig.fromJson(legacy);
  expect(cfg.zeroPointRef, isNull);
  expect(cfg.starInnDegreeOverrides, isNull);
});
```

- [ ] **Step 3: 跑测试确认失败**

Run: `flutter test test/domain/entities/panel_config_serialization_test.dart`
Expected: FAIL（`zeroPointRef` 等未定义）

- [ ] **Step 4: 在 `BasePanelConfig` 加字段 + import + 构造 + copyWith + 两个 default**

在类字段区（`projectionOverride` 之后）加：

```dart
/// 起点参考（春分/冬至）；null=用资产 zeroPointJieQi。
EnumZeroPointRef? zeroPointRef;

/// 星宿偏移档位；null=不按档位偏移。
ConstellationOffsetTier? offsetTier;

/// 偏移数值（度），覆盖档位默认；null=用档位默认或不偏移。
double? constellationOffsetDeg;

/// 逐宿弧度覆写；null/空=不覆写。
Map<Enum28Constellations, double>? starInnDegreeOverrides;
```

顶部 import：

```dart
import 'package:qizhengsiyu/enums/enum_zero_point_ref.dart';
import 'package:qizhengsiyu/enums/enum_constellation_offset_tier.dart';
```

构造函数参数区加 `this.zeroPointRef, this.offsetTier, this.constellationOffsetDeg, this.starInnDegreeOverrides,`；`copyWith` 参数区加同名可空参、返回体加 `zeroPointRef: zeroPointRef ?? this.zeroPointRef,` 等四行；`defaultBasicPanelConfig()` 与 `PanelConfig.defaultPanelConfig()` 四字段均显式写 `null`（红线：不写默认档位/偏移）。`PanelConfig` 子类构造 `super.` 透传四字段。

- [ ] **Step 5: 重生成 .g.dart**

Run: `dart run build_runner build --delete-conflicting-outputs`
Expected: 无冲突；`panel_config.g.dart` 出现 `zeroPointRef`/`starInnDegreeOverrides` 的编解码。
> 注：`Map<Enum28Constellations,double>` 的 JSON 键为枚举名字符串，`json_serializable` 默认可处理；若报错，给该字段加 `@JsonKey` 自定义 `toJson/fromJson`（key 用 `.name`）。

- [ ] **Step 6: 跑测试 + analyze**

Run: `flutter test test/domain/entities/panel_config_serialization_test.dart && flutter analyze lib/domain/entities/models/panel_config.dart`
Expected: PASS；analyze 0 error。

- [ ] **Step 7: 提交**

```bash
git add lib/domain/entities/models/panel_config.dart lib/domain/entities/models/panel_config.g.dart test/domain/entities/panel_config_serialization_test.dart
git commit -m "feat(config): BasePanelConfig 新增起点/偏移/逐宿覆写字段"
```

---

## Task 3: 扩展 `ZhouTianModel.applyOverrides` 契约

**Files:**
- Modify: `lib/domain/entities/models/zhou_tian_model.dart`
- Test: `test/domain/entities/zhou_tian_model_overrides_test.dart`（已存在，追加）

**Interfaces:**
- Consumes: Task 1 枚举、Task 2 config 字段、已有 `copyWith`。
- Produces: `ZhouTianModel applyOverrides({EnumZhouTianModel? zhouTianModelOverride, ProjectionConfig? projectionOverride, EnumZeroPointRef? zeroPointRef, ConstellationOffsetTier? offsetTier, double? constellationOffsetDeg, Map<Enum28Constellations,double>? starInnDegreeOverrides})`。**注意：签名由位置参改为命名参**——须同步更新调用点（Task 5 处理 `sweph_engine`，本 Task 处理 `zhou_tian_model_manager`）。

- [ ] **Step 1: impact**

Run: `impact({target: "applyOverrides", direction: "upstream"})`
Expected: 调用点 `sweph_engine.dart`、`zhou_tian_model_manager.dart`；确认改签名需同步这两处。

- [ ] **Step 2: 写失败测试（追加）**

```dart
test('applyOverrides 全 null → identical(this)', () {
  final m = _sampleModel(); // 复用文件内既有构造 helper
  expect(identical(m.applyOverrides(), m), isTrue);
});

test('applyOverrides 逐宿覆写 → 克隆生效且不 mutate 原实例', () {
  final m = _sampleModel();
  final before = List.of(m.starInnDegreeSeq);
  final r = m.applyOverrides(
    starInnDegreeOverrides: {Enum28Constellations.jiao: 12.3},
  );
  expect(identical(r, m), isFalse);
  expect(m.starInnDegreeSeq, equals(before), reason: '原实例列表不应被 mutate');
  // 找到 jiao 对应项在 r 中已改为 12.3（按 starInnOrder 定位）
  final idx = r.starInnOrder.indexOf(Enum28Constellations.jiao);
  expect(r.starInnDegreeSeq[idx].degree, 12.3);
});

test('applyOverrides 偏移量 → 零点平移、原实例不变', () {
  final m = _sampleModel();
  final r = m.applyOverrides(
    offsetTier: ConstellationOffsetTier.adjusted, // 默认 14°
  );
  expect(identical(r, m), isFalse);
  // 断言 r 的零点度数相对 m 平移 14°（具体字段依 zeroPointAtConstellation.degree）
  expect(r.zeroPointAtConstellation.degree,
      closeTo(m.zeroPointAtConstellation.degree + 14.0, 1e-9));
});
```
> 施工者须先确认 `ZhouTianModel` 的 `starInnDegreeSeq` 元素类型（`ConstellationDegree`，有 `.degree`）与 `zeroPointAtConstellation`（`ConstellationDegree`，有 `.degree`）的确切字段名，测试断言按实际字段调整。

- [ ] **Step 3: 跑测试确认失败**

Run: `flutter test test/domain/entities/zhou_tian_model_overrides_test.dart`
Expected: FAIL（命名参不存在 / 逐宿覆写未实现）

- [ ] **Step 4: 改 `applyOverrides` 为命名参并实现四维覆写**

```dart
ZhouTianModel applyOverrides({
  EnumZhouTianModel? zhouTianModelOverride,
  ProjectionConfig? projectionOverride,
  EnumZeroPointRef? zeroPointRef,
  ConstellationOffsetTier? offsetTier,
  double? constellationOffsetDeg,
  Map<Enum28Constellations, double>? starInnDegreeOverrides,
}) {
  final hasAny = zhouTianModelOverride != null ||
      projectionOverride != null ||
      zeroPointRef != null ||
      offsetTier != null ||
      constellationOffsetDeg != null ||
      (starInnDegreeOverrides != null && starInnDegreeOverrides.isNotEmpty);
  if (!hasAny) return this;

  // 偏移量：数值优先，否则用档位默认；两者皆无=0
  final offset = constellationOffsetDeg ?? offsetTier?.defaultOffsetDeg ?? 0.0;

  // 逐宿覆写：深拷贝新列表，仅改被覆写宿
  List<ConstellationDegree>? newStarInn;
  if (starInnDegreeOverrides != null && starInnDegreeOverrides.isNotEmpty) {
    newStarInn = starInnDegreeSeq.map((cd) {
      final ov = starInnDegreeOverrides[cd.constellation];
      return ov == null ? cd : cd.copyWith(degree: ov); // 若无 copyWith 则 new 一个
    }).toList();
  }

  // 零点平移：偏移 + 起点参考（起点参考的具体平移量依资产/002 定义，本期先按 offset 叠加，
  // 起点=冬至/春分的差量作为 TODO-hook 由后续任务/资产提供；此处仅接偏移数值，起点参考先透传存储）
  final newZero = offset == 0.0
      ? zeroPointAtConstellation
      : zeroPointAtConstellation.copyWith(
          degree: zeroPointAtConstellation.degree + offset);

  return copyWith(
    totalDegree: zhouTianModelOverride?.totalDegree ?? totalDegree,
    projectionConfig: projectionOverride ?? projectionConfig,
    starInnDegreeSeq: newStarInn ?? starInnDegreeSeq,
    zeroPointAtConstellation: newZero,
  );
}
```
> `ConstellationDegree.copyWith` 若不存在，先给它补一个最小 `copyWith({double? degree})`（同一步提交）。`zeroPointRef` 的春分↔冬至平移量在 A 层先仅存储、由 B 层/资产提供换算，本 Task 只保证偏移数值与逐宿覆写生效——在测试里不断言 zeroPointRef 的几何效果，只断言其被 `copyWith` 透传保存（如需，给 `copyWith` 加 `zeroPointRef` 存储字段；若 `ZhouTianModel` 无该字段则记为 Phase-2 hook，不在本 Task 强加）。

- [ ] **Step 5: 同步 `zhou_tian_model_manager.dart` 调用点为命名参**

`getZhouTianModelBy` 内：
```dart
return _mapper[key]!.applyOverrides(
  zhouTianModelOverride: config.zhouTianModelOverride,
  projectionOverride: config.projectionOverride,
  zeroPointRef: config.zeroPointRef,
  offsetTier: config.offsetTier,
  constellationOffsetDeg: config.constellationOffsetDeg,
  starInnDegreeOverrides: config.starInnDegreeOverrides,
);
```

- [ ] **Step 6: 跑测试 + analyze**

Run: `flutter test test/domain/entities/zhou_tian_model_overrides_test.dart && flutter analyze lib/domain/entities/models/zhou_tian_model.dart lib/domain/managers/zhou_tian_model_manager.dart`
Expected: PASS；0 error。

- [ ] **Step 7: 提交**

```bash
git add lib/domain/entities/models/zhou_tian_model.dart lib/domain/managers/zhou_tian_model_manager.dart test/domain/entities/zhou_tian_model_overrides_test.dart
git commit -m "feat(config): applyOverrides 扩展起点/偏移/逐宿覆写（克隆安全）"
```

---

## Task 4: 弧矢割圆接成 `HuangChiDaoDiffType.hushi`

**Files:**
- Modify: `lib/domain/engines/projection/huang_chi_dao_diff.dart`（新增 `HushiGeyuanDiff`）
- Modify: `lib/domain/entities/models/projection_config.dart`(+`.g.dart`)（枚举增 `hushi`）
- Modify: `lib/domain/managers/celestial_projector_factory.dart`（`_buildDiff` 增分支）
- Test: `test/domain/engines/projection/hushi_geyuan_diff_test.dart`

**Interfaces:**
- Consumes: 已有 `HuangChiDaoDiff`（`double get quadrant; double diff(double c)`）、`HushiGeyuan`（`rightAscension(λ, {eps})` 黄道→赤道、`quadrant`、`zhouTian`）。
- Produces: `class HushiGeyuanDiff extends HuangChiDaoDiff`；`HuangChiDaoDiffType.hushi`；工厂 `_buildDiff` 支持 `hushi`。

**关键点（方向反演）**：`HushiGeyuan.rightAscension(λ)=α` 是黄道→赤道；`diff(c)` 需赤道→黄赤差。故在 `[0,quadrant]` 内二分反演求 λ 使 α(λ)=c，返回 `d=λ-c`。

- [ ] **Step 1: 写失败测试**

```dart
// test/domain/engines/projection/hushi_geyuan_diff_test.dart
import 'dart:math' as math;
import 'package:flutter_test/flutter_test.dart';
import 'package:qizhengsiyu/domain/engines/projection/huang_chi_dao_diff.dart';
import 'package:qizhengsiyu/utils/math/arc_circle.dart';

void main() {
  const zhou = 365.2575;
  final geyuan = HushiGeyuan(zhouTian: zhou, daJu: 23.9030, piRatio: math.pi);
  final diff = HushiGeyuanDiff(zhouTian: zhou, epsilonDeg: 23.9030);

  test('两端(分点/至点)黄赤道差为 0', () {
    expect(diff.diff(0.0), closeTo(0.0, 1e-6));
    expect(diff.diff(diff.quadrant), closeTo(0.0, 5e-4));
  });

  test('diff(c) 反演与 rightAscension 自洽：对给定 λ，令 c=α(λ) 应得 d≈λ-c', () {
    for (final lam in [10.0, 30.0, 60.0, 85.0]) {
      final alpha = geyuan.rightAscension(lam); // 黄道 λ → 赤道 α
      final d = diff.diff(alpha);               // 赤道 α → 黄赤差
      expect(alpha + d, closeTo(lam, 1e-3),
          reason: 'λ=$lam: 赤道+差 应还原黄道');
    }
  });

  test('象限内 d≥0 且最大 ≈2.5°（授时实测量级）', () {
    double maxD = 0;
    for (double c = 0; c <= diff.quadrant; c += 1) {
      final d = diff.diff(c);
      expect(d, greaterThanOrEqualTo(-1e-6));
      if (d > maxD) maxD = d;
    }
    expect(maxD, closeTo(2.5, 0.4));
  });
}
```
> 施工前确认 `HushiGeyuan` 构造参数名（`zhouTian`/`daJu`/`piRatio`）与 `rightAscension` 签名，按实际微调。

- [ ] **Step 2: 跑测试确认失败**

Run: `flutter test test/domain/engines/projection/hushi_geyuan_diff_test.dart`
Expected: FAIL（`HushiGeyuanDiff` 未定义）

- [ ] **Step 3: 实现 `HushiGeyuanDiff`（在 huang_chi_dao_diff.dart 追加）**

```dart
import '../../../utils/math/arc_circle.dart'; // 文件顶部 import（若尚无）

/// 第四种算法 —— 元授时历弧矢割圆术（HushiGeyuan 的黄赤道换算）。
///
/// HushiGeyuan.rightAscension(λ)=α 为黄道→赤道；diff(c) 需赤道→黄赤差，
/// 故在 [0, quadrant] 内二分反演求 λ 使 α(λ)=c，返回 d=λ-c。
/// 见 docs/project/architecture/002 弧矢割圆术章节。
class HushiGeyuanDiff extends HuangChiDaoDiff {
  final HushiGeyuan _geyuan;
  final double _zhouTian;

  HushiGeyuanDiff({double zhouTian = 365.2575, double epsilonDeg = 23.9030})
      : _zhouTian = zhouTian,
        _geyuan = HushiGeyuan(
          zhouTian: zhouTian,
          daJu: epsilonDeg,
          piRatio: 3.141592653589793,
        );

  @override
  double get quadrant => _zhouTian / 4.0;

  @override
  double diff(double c) {
    final x = c.abs().clamp(0.0, quadrant);
    if (x <= 0) return 0.0;
    // 二分反演：找 λ∈[x, quadrant] 使 rightAscension(λ) == x
    double lo = 0.0, hi = quadrant;
    for (var i = 0; i < 60; i++) {
      final mid = (lo + hi) / 2.0;
      final alpha = _geyuan.rightAscension(mid);
      if (alpha < x) {
        lo = mid;
      } else {
        hi = mid;
      }
    }
    final lam = (lo + hi) / 2.0;
    final d = lam - x;
    return d < 0 ? 0.0 : d;
  }
}
```

- [ ] **Step 4: 枚举增 `hushi` + 工厂分支**

`projection_config.dart` 的 `HuangChiDaoDiffType` 加：
```dart
@JsonValue('hushi')
hushi,
```
重生成：`dart run build_runner build --delete-conflicting-outputs`

`celestial_projector_factory.dart` 的 `_buildDiff` switch 加分支：
```dart
case HuangChiDaoDiffType.hushi:
  return HushiGeyuanDiff(
      epsilonDeg: c.epsilonDeg ?? 23.9030, zhouTian: zhouTian);
```

- [ ] **Step 5: 跑测试 + 工厂路由回归**

Run: `flutter test test/domain/engines/projection/hushi_geyuan_diff_test.dart test/domain/managers/celestial_projector_factory_test.dart`
Expected: PASS（含既有工厂测试不回归）

- [ ] **Step 6: 提交**

```bash
git add lib/domain/engines/projection/huang_chi_dao_diff.dart lib/domain/entities/models/projection_config.dart lib/domain/entities/models/projection_config.g.dart lib/domain/managers/celestial_projector_factory.dart test/domain/engines/projection/hushi_geyuan_diff_test.dart
git commit -m "feat(projection): 弧矢割圆接成 HuangChiDaoDiffType.hushi"
```

---

## Task 5: `SwephEngine` 资产路由矩阵 + 接扩展 applyOverrides

**Files:**
- Modify: `lib/domain/engines/sweph_engine.dart`
- Test: `test/domain/engines/sweph_asset_routing_test.dart`

**Interfaces:**
- Consumes: Task 3 的命名参 `applyOverrides`；已有 `_ephemerisRes.loadEphemerisResource`。
- Produces: `getSystemDefinition` 支持 4 坐标系的资产选择（`Equatorial`/`PseudoEcliptic` 复用赤道基准资产），并接命名参 applyOverrides。

- [ ] **Step 1: impact**

Run: `impact({target: "getSystemDefinition", direction: "upstream"})`
Expected: 7 调用点（usecases/viewmodels/engines）；改动为附加式（新坐标分支 + 命名参），默认路径不变。

- [ ] **Step 2: 写失败测试**

```dart
// test/domain/engines/sweph_asset_routing_test.dart
// 用假的 QiZhengEphemerisResourceRepository 记录被请求的 assetName，
// 断言 4 坐标系分别请求预期资产；PseudoEcliptic/Equatorial 复用赤道基准资产名。
```
> 施工者按 `SwephEngine` 现有依赖类型写一个 fake repo（记录 `loadEphemerisResource(name)` 的入参），断言：
> - `Ecliptic×Tropical×Classical` → `ecliptic_tropical_classical.json`
> - `SkyEquatorial` → `yuan_shoushi_chidao_hengxin.json`
> - `Equatorial` → 复用赤道基准资产（同上或等价，值在本 Task 核定并写死）
> - `PseudoEcliptic` → 复用赤道基准资产 + 后续由 config.projectionOverride 决定投影

- [ ] **Step 3: 跑测试确认失败**

Run: `flutter test test/domain/engines/sweph_asset_routing_test.dart`
Expected: FAIL（`Equatorial`/`PseudoEcliptic` 命中 `UnimplementedError`）

- [ ] **Step 4: 补 `getSystemDefinition` 分支 + 命名参**

在坐标系判断补 `Equatorial`/`PseudoEcliptic` 分支（复用赤道基准资产名，值核定后写死并注释来源）；末尾返回改为命名参：

```dart
return ZhouTianModel.fromJson(jsonDecode(jsonString)).applyOverrides(
  zhouTianModelOverride: panelConfig.zhouTianModelOverride,
  projectionOverride: panelConfig.projectionOverride,
  zeroPointRef: panelConfig.zeroPointRef,
  offsetTier: panelConfig.offsetTier,
  constellationOffsetDeg: panelConfig.constellationOffsetDeg,
  starInnDegreeOverrides: panelConfig.starInnDegreeOverrides,
);
```

- [ ] **Step 5: 跑测试 + analyze**

Run: `flutter test test/domain/engines/sweph_asset_routing_test.dart && flutter analyze lib/domain/engines/sweph_engine.dart`
Expected: PASS；0 error。

- [ ] **Step 6: 提交**

```bash
git add lib/domain/engines/sweph_engine.dart test/domain/engines/sweph_asset_routing_test.dart
git commit -m "feat(engine): getSystemDefinition 四坐标资产路由 + 接扩展 applyOverrides"
```

---

## Task 6: `PanelSystemResolver` 合法性校验层

**Files:**
- Create: `lib/domain/managers/panel_system_resolver.dart`
- Test: `test/domain/managers/panel_system_resolver_test.dart`

**Interfaces:**
- Consumes: `BasePanelConfig`（含 Task 2 新字段）。
- Produces: `class PanelSystemResolver { PanelSystemCheck validate(BasePanelConfig config, {Set<String> availableAssetKeys = const {}}); }`；`class PanelSystemCheck { bool isCoherent; List<String> warnings; BasePanelConfig? suggestedFix; }`。

- [ ] **Step 1: 写失败测试**

```dart
// test/domain/managers/panel_system_resolver_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:qizhengsiyu/domain/managers/panel_system_resolver.dart';
import 'package:qizhengsiyu/domain/entities/models/panel_config.dart';
import 'package:qizhengsiyu/domain/entities/models/projection_config.dart';
import 'package:qizhengsiyu/enums/enum_zhou_tian_model.dart';

void main() {
  final r = PanelSystemResolver();

  test('现代黄道 + 365.25 = 矛盾并给 suggestedFix', () {
    final cfg = BasePanelConfig.defaultBasicPanelConfig().copyWith(
      celestialCoordinateSystem: CelestialCoordinateSystem.Ecliptic,
      zhouTianModelOverride: EnumZhouTianModel.degree36525,
    );
    final c = r.validate(cfg);
    expect(c.isCoherent, isFalse);
    expect(c.warnings.any((w) => w.contains('365')), isTrue);
    expect(c.suggestedFix, isNotNull);
  });

  test('现代黄道 + 推变黄道 = 矛盾', () {
    final cfg = BasePanelConfig.defaultBasicPanelConfig().copyWith(
      celestialCoordinateSystem: CelestialCoordinateSystem.Ecliptic,
      projectionOverride: ProjectionConfig(
          strategy: MappingStrategy.tuiBianHuangDao,
          huangChiDaoDiffType: HuangChiDaoDiffType.shoushi),
    );
    expect(r.validate(cfg).isCoherent, isFalse);
  });

  test('默认 config = 一致、无警告', () {
    expect(r.validate(BasePanelConfig.defaultBasicPanelConfig()).isCoherent, isTrue);
  });
}
```

- [ ] **Step 2: 跑测试确认失败**

Run: `flutter test test/domain/managers/panel_system_resolver_test.dart`
Expected: FAIL（类未定义）

- [ ] **Step 3: 实现校验器**

```dart
// lib/domain/managers/panel_system_resolver.dart
import '../entities/models/panel_config.dart';
import '../entities/models/projection_config.dart';
import '../../enums/enum_zhou_tian_model.dart';

class PanelSystemCheck {
  final bool isCoherent;
  final List<String> warnings;
  final BasePanelConfig? suggestedFix;
  const PanelSystemCheck(this.isCoherent, this.warnings, this.suggestedFix);
}

class PanelSystemResolver {
  PanelSystemCheck validate(BasePanelConfig config,
      {Set<String> availableAssetKeys = const {}}) {
    final warnings = <String>[];
    BasePanelConfig? fix;
    final coord = config.celestialCoordinateSystem;
    final is365 = config.zhouTianModelOverride == EnumZhouTianModel.degree36525;
    final isTuiBian =
        config.projectionOverride?.strategy == MappingStrategy.tuiBianHuangDao;

    // ① 现代黄道/赤道 + 365.25 矛盾
    if ((coord == CelestialCoordinateSystem.Ecliptic ||
            coord == CelestialCoordinateSystem.Equatorial) &&
        is365) {
      warnings.add('现代黄道/赤道为 360 度制，与古度 365.25 冲突');
      fix = (fix ?? config).copyWith(zhouTianModelOverride: null);
    }
    // ② 现代黄道 + 推变黄道 矛盾
    if (coord == CelestialCoordinateSystem.Ecliptic && isTuiBian) {
      warnings.add('黄道制本身不做赤黄投影，推变黄道无意义');
      fix = (fix ?? config).copyWith(projectionOverride: null);
    }
    // ③ 古黄道 + 线性 提示退化
    if (coord == CelestialCoordinateSystem.PseudoEcliptic && !isTuiBian) {
      warnings.add('古黄道未选推黄道算法，将退化为直接 365.25÷360 缩放');
    }
    // ⑤ 逐宿覆写 Σ 超差（周天目标 = 365.25 或 360，按周天制）
    final overrides = config.starInnDegreeOverrides;
    if (overrides != null && overrides.isNotEmpty) {
      final target = is365 ? 365.2575 : 360.0;
      // 仅对“被覆写宿的增量”做粗校验：提示用户 Σ 可能偏离周天（精确 Σ 需全宿表，留 UI 层细算）
      warnings.add('已覆写 ${overrides.length} 宿弧度，请确认二十八宿总和≈$target');
    }
    // ⑥ 资产缺失（三元组无对应资产）
    if (availableAssetKeys.isNotEmpty) {
      final key =
          '${coord.name}_${config.panelSystemType.name}_${config.constellationSystemType.name}';
      if (!availableAssetKeys.contains(key)) {
        warnings.add('当前坐标×星盘×星宿组合暂无对应资产（$key）');
      }
    }
    // ④ 回归/恒星 与 起点(春分/冬至) 的语义冲突：依赖 zeroPointRef 的几何换算，
    //    该几何量由阶段二/资产提供，本阶段不校验（见计划 Self-Review 备注）。
    return PanelSystemCheck(warnings.isEmpty, warnings, fix);
  }
}
```
> 规则 ⑤ 的精确 Σ 校验（读全宿表求和）在 UI 层或阶段二补；此处只做"有覆写即提示核对"的轻校验，避免 resolver 依赖资产装载。规则 ④ 显式推迟（zeroPointRef 几何换算量未就位）。

- [ ] **Step 4: 跑测试确认通过**

Run: `flutter test test/domain/managers/panel_system_resolver_test.dart`
Expected: PASS

- [ ] **Step 5: 提交**

```bash
git add lib/domain/managers/panel_system_resolver.dart test/domain/managers/panel_system_resolver_test.dart
git commit -m "feat(config): PanelSystemResolver 组合合法性校验（非阻断）"
```

---

## Task 7: UI —— 坐标 4 选项 + 弧矢 + 起点/偏移/星宿 + 警告条

**Files:**
- Modify: `lib/presentation/widgets/config/custom_config_section.dart`
- Test: `test/presentation/config/custom_config_section_widget_test.dart`

**Interfaces:**
- Consumes: Task 1/2/6 的枚举、config 字段、`PanelSystemResolver`；已有 `_buildRadioTile<T>`、`_updateConfig()`、状态回填模式。
- Produces: 4 坐标系可选、换算子选项含"弧矢割圆术"、起点/偏移档位+数值/星宿表 3 组新控件、resolver 警告条。

- [ ] **Step 1: impact**

Run: `impact({target: "CustomConfigSection", direction: "upstream"})`
Expected: 配置页 `qi_zheng_si_yu_config_page.dart` 等；纯 UI 增量。

- [ ] **Step 2: 写 widget 失败测试**

```dart
// test/presentation/config/custom_config_section_widget_test.dart
// pump CustomConfigSection，断言：
// - 坐标系出现 4 个选项文案（现代黄道/现代赤道/天赤道/古黄道）
// - 换算下拉在选“推变黄道”后其算法子选项含“弧矢割圆术”
// - 出现“周天制与黄赤道换算”“起点”“偏移量”“星宿制式”卡标题
```
> 用 `WidgetTester` + `find.text('现代黄道')` 等断言存在性；矛盾组合后 `find.byType` 警告条存在。

- [ ] **Step 3: 跑测试确认失败**

Run: `flutter test test/presentation/config/custom_config_section_widget_test.dart`
Expected: FAIL

- [ ] **Step 4: 改 UI**

4a. 坐标系「星道制式」卡：由 2 个 `_buildRadioTile` 扩为遍历 `CelestialCoordinateSystem.values` 生成 4 项（文案取 `.name`），`onChanged` 里在 `setState` 中联动填推荐默认（`Ecliptic/Equatorial`→`_zhouTianModel=null,_mappingStrategy=linear`；`SkyEquatorial`→`_zhouTianModel=degree36525,_mappingStrategy=linear`；`PseudoEcliptic`→`_zhouTianModel=degree36525,_mappingStrategy=tuiBianHuangDao`）后 `_updateConfig()`。

4b. 换算算法子下拉（推变黄道下）增加一项：
```dart
DropdownMenuItem(value: HuangChiDaoDiffType.hushi, child: Text('弧矢割圆术')),
```

4c. 新增「起点与偏移」卡：起点 `DropdownButtonFormField<EnumZeroPointRef?>`（含"跟随资产(null)"+春分+冬至）；偏移档位 3 个 `_buildRadioTile<ConstellationOffsetTier?>`；偏移数值 `TextFormField`（档位变→默认值随 `defaultOffsetDeg`，可手改）。三者写回 `_zeroPointRef`/`_offsetTier`/`_constellationOffsetDeg` 并 `_updateConfig()`。

4d. 「星宿制式」卡（`ConstellationSystemType`）：3 个 `_buildRadioTile`（古宿/矫正/今宿）写回 `_constellationSystemType`；逐宿覆写折叠面板本期可仅放入口占位（真正逐宿编辑器可作 4e 子步，YAGNI 视需要）。

4e. 警告条：在 `build` 顶部用 `PanelSystemResolver().validate(_currentConfig())`，`!isCoherent` 时渲染黄条 + "一键归正"按钮（点按套 `suggestedFix` 回填状态并 `_updateConfig()`）。

4f. `initState` 回填新增 `_zeroPointRef/_offsetTier/_constellationOffsetDeg/_constellationSystemType`；`_updateConfig()` 的 `copyWith` 追加这些字段。

- [ ] **Step 5: 跑测试 + analyze**

Run: `flutter test test/presentation/config/custom_config_section_widget_test.dart && flutter analyze lib/presentation/widgets/config/custom_config_section.dart`
Expected: PASS；0 error（弃用告警不算 error）。

- [ ] **Step 6: 提交**

```bash
git add lib/presentation/widgets/config/custom_config_section.dart test/presentation/config/custom_config_section_widget_test.dart
git commit -m "feat(ui): 坐标4选项+弧矢+起点/偏移/星宿+合法性警告条"
```

---

## Task 8: 向后兼容金标（红线加硬）

**Files:**
- Test: `test/domain/engines/backward_compat_golden_test.dart`

**Interfaces:**
- Consumes: 全链（`getSystemDefinition` → 计算）。

- [ ] **Step 1: 写四种 golden 测试**

```dart
// test/domain/engines/backward_compat_golden_test.dart
// 通过一个装载了内置资产的 SwephEngine（或 ZhouTianModelManager）产出模型/关键角度，
// 对以下四路径断言“与基线一致”：
// (a) 旧 JSON 缺全部新字段 → 反序列化 config；
// (b) 新建默认 config；
// (c) UI 打开不操作（= 默认 config）；
// (d) 显式 degree360+linear 与 (b) null 默认 结果一致。
// 基线：先用 (b) 跑一次记录 model.totalDegree / starInnDegreeSeq / zeroPoint 作为期望，
// 再断言 (a)(c)(d) 与之逐位相等。
```
> 施工者用现有测试里已有的资产装载 helper（参考 `zhou_tian_model_manager_injection_test`）构造，避免依赖 Flutter asset bundle。

- [ ] **Step 2: 跑测试确认（先红后绿）**

Run: `flutter test test/domain/engines/backward_compat_golden_test.dart`
Expected: 若默认路径已污染则 FAIL（据此定位）；修正后 PASS。

- [ ] **Step 3: 全量回归**

Run: `flutter test test/domain/engines test/domain/entities test/domain/managers`
Expected: All tests passed（零回归）。

- [ ] **Step 4: detect_changes 复核**

Run: `detect_changes({scope: "compare", base_ref: "main"})`
Expected: 仅本计划涉及符号/流程受影响，无意外扩散。

- [ ] **Step 5: 提交**

```bash
git add test/domain/engines/backward_compat_golden_test.dart
git commit -m "test(config): 向后兼容四路径金标（默认盘面逐位不变）"
```

---

## 阶段一验收（DoD）

- [ ] 坐标系 UI 可选 4 项，各自联动推荐周天制/换算；矛盾组合有黄条警告 + 一键归正。
- [ ] 换算可选"弧矢割圆术"，`HushiGeyuanDiff` 反演自洽金标通过。
- [ ] 起点(春分/冬至)、偏移量(档位+数值)、星宿表(古/矫正/今)可选且经 `applyOverrides` 生效；逐宿覆写克隆安全。
- [ ] 四路径向后兼容金标全绿；默认 config 盘面逐位不变。
- [ ] `flutter analyze` 0 error；`flutter test` 全绿；`detect_changes` 无意外扩散。

## 阶段二（B 层流派编排）—— 待阶段一落地后单出计划

阶段二（`SchoolProfile` / `BuiltInSchoolProfiles` / `updateSchoolType` 预载 / 自定义档案 Drift 持久化）依赖阶段一最终确定的 A 层字段签名，且**先决阻塞项**（`.gitignore` 误吞 `siyu/profile/`）已由 commit `b96cde5` 解除。阶段一合并后，用 `writing-plans` 依本 spec §4 单出阶段二计划。

## Self-Review 备注（施工者须知的既有签名核对点）

实施前逐一核对（本计划基于已观察到的签名，个别字段名以实际为准）：
- `ConstellationDegree` 是否有 `.degree` / `copyWith`（Task 3）——无则先补最小 `copyWith`。
- `ZhouTianModel.copyWith` 是否已含 `starInnDegreeSeq`/`zeroPointAtConstellation`（feature 分支已加，确认参数名）。
- `HushiGeyuan` 构造参数名与 `rightAscension` 签名（Task 4）。
- `Enum28Constellations` 各宿名（逐宿覆写 map 键）。
- `Map<Enum,double>` 的 `json_serializable` 支持（Task 2，必要时加 `@JsonKey`）。
