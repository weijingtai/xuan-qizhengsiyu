# 七政四余可配置盘制 · 阶段二（B 层流派编排 + 阶段一尾巴）实施计划

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 在阶段一 A 层配置原语之上，做「流派(果老/琴堂/天官)+典籍 → 一键套配整套 A 层默认」(G4) 与「自定义流派存 Drift 命名档案」(G5)，并承接阶段一两条尾巴（逐宿覆写编辑器 UI、`PanelSystemResolver` 规则④）。

**Architecture:** B 层新增 `SchoolProfile`(仿 `SiYuProfile`)承载一整套 A 层默认；`SchoolConfigResolver` 把选中档案套进 `BasePanelConfig`(只用阶段一已冻结的 A 层字段做 `copyWith`)；活的 `PanelConfigViewModel.updateSchoolType` 实装为「查内置档案 → copyWith → notifyListeners」，并加 `isCustomized` 脱离跟随。G5 仿 `QizhengsiyuPanTable` 加 Drift 表 `t_user_school_profiles`。两条尾巴分别落在 `custom_config_section.dart` 与 `panel_system_resolver.dart`。

**Tech Stack:** Dart / Flutter；`json_serializable`（`.g.dart`）；`drift`（用户库 `AppDatabase`）；Provider；`flutter test`。

## Global Constraints

- 语言：源码注释与文档以中文为主；仅路径/符号用英文（用户全局规则）。
- 分支：`feat/chidao-huangdao-tuibian`（本计划所有提交落此分支，勿在 main、勿新建分支、勿动其他 worktree）。
- **只改本计划点名的文件**；暂存只 `git add` 该 Task 命名的文件，**禁止 `git add -A`**、禁止 push。
- **活 viewmodel 唯一**：只改 `lib/presentation/viewmodels/panel_config_viewmodel.dart`（被 `qi_zheng_si_yu_config_page.dart` import）。`lib/viewmodels/panel_config_viewmodel.dart` 是**死副本**，**本计划不改它**（清理它另开任务）。
- **A 层字段冻结**：B 层只消费阶段一冻结的 `BasePanelConfig` 字段（`celestialCoordinateSystem` / `panelSystemType` / `constellationSystemType` / `zhouTianModelOverride` / `projectionOverride` / `zeroPointRef` / `offsetTier` / `constellationOffsetDeg` / `starInnDegreeOverrides`），**不新增 A 层字段**。
- **起点几何化不做**：`zeroPointRef` 仍只存储透传，春分↔冬至几何平移（依赖未定锚点真值 O1）**不在本阶段**，不写猜测公式。
- **向后兼容红线**：不选流派 / 默认路径的盘面结果与阶段一逐位一致；`updateSchoolType(Customerized)` 保持当前配置不变。
- **Drift 红线**：新增表须 `schemaVersion` 3→4 + `onUpgrade` 补 `from < 4` 建表分支；`AppDatabase` 是单例，测试用 `AppDatabase.forTesting(e)` 注入内存库，**不 close 共享实例**。
- TDD：每个 Task 先写失败测试→跑红→最小实现→跑绿→提交。
- 每改一个既有符号前跑 `impact`，改完 `detect_changes`；HIGH/CRITICAL 先告警。
- 改动 `@JsonSerializable` / Drift 表后必跑 `dart run build_runner build --delete-conflicting-outputs`。
- 参考：设计 spec `docs/superpowers/specs/2026-07-07-configurable-panel-school-system-design.md` §4；阶段一计划同目录 `...-phase1-a-primitives-plan.md`；模板 `lib/domain/engines/siyu/profile/*`、`lib/data/datasources/local/tables/qizhengsiyu_pan_table.dart`。

---

## 文件结构（先锁边界）

| 文件 | 责任 | 动作 |
|---|---|---|
| `lib/domain/engines/school/school_profile.dart` | `SchoolProfile` 模型（一套 A 层默认 + 流派 + 典籍） | 新建 |
| `lib/domain/engines/school/built_in_school_profiles.dart` | 内置果老/琴堂/天官 × 典籍档案 | 新建 |
| `lib/domain/engines/school/school_config_resolver.dart` | 档案 → `BasePanelConfig` 套配 | 新建 |
| `lib/presentation/viewmodels/panel_config_viewmodel.dart` | 实装 `updateSchoolType` + 典籍 + `isCustomized` | 改 |
| `lib/data/datasources/local/tables/user_school_profile_table.dart` | Drift 用户流派表 | 新建 |
| `lib/data/datasources/local/daos/user_school_profile_dao.dart`(+`.g.dart`) | 用户流派 DAO | 新建 |
| `lib/data/datasources/local/app_database.dart`(+`.g.dart`) | 注册表/DAO + schemaVersion 3→4 + onUpgrade | 改 |
| `lib/presentation/widgets/config/custom_config_section.dart` | 尾巴A：逐宿覆写编辑器 UI | 改 |
| `lib/domain/managers/panel_system_resolver.dart` | 尾巴B：规则④ 回归/恒星×起点冲突 | 改 |
| `test/...`（各对应） | TDD 测试 | 新建/改 |

**依赖顺序**：Task 1→2→3（B 层核心链）可先落；Task 4→5→6（G5 持久化 + UI）依赖 1；Task 7（逐宿UI）、Task 8（规则④）独立可并；Task 9 收口。

---

## Task 1: `SchoolProfile` 模型 + 内置档案

**Files:**
- Create: `lib/domain/engines/school/school_profile.dart`
- Create: `lib/domain/engines/school/built_in_school_profiles.dart`
- Test: `test/domain/engines/school/built_in_school_profiles_test.dart`

**Interfaces:**
- Consumes: 阶段一枚举 `EnumZeroPointRef` / `ConstellationOffsetTier`、`EnumZhouTianModel`、`ProjectionConfig`、`CelestialCoordinateSystem` / `PanelSystemType` / `ConstellationSystemType`、`EnumSchoolType`（`lib/enums/enum_school.dart`）。
- Produces: `class SchoolProfile`（不可变，字段见下）；`class BuiltInSchoolProfiles { static List<SchoolProfile> all; static SchoolProfile byId(String); static List<SchoolProfile> bySchool(EnumSchoolType); static SchoolProfile defaultForSchool(EnumSchoolType); static const defaultId; }`。

- [ ] **Step 1: 写失败测试**

```dart
// test/domain/engines/school/built_in_school_profiles_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:metaphysics_core/enums.dart';
import 'package:qizhengsiyu/enums/enum_school.dart';
import 'package:qizhengsiyu/enums/enum_zhou_tian_model.dart';
import 'package:qizhengsiyu/domain/engines/school/school_profile.dart';
import 'package:qizhengsiyu/domain/engines/school/built_in_school_profiles.dart';

void main() {
  test('内置档案至少覆盖果老/琴堂/天官三派', () {
    final schools =
        BuiltInSchoolProfiles.all.map((p) => p.school).toSet();
    expect(schools.contains(EnumSchoolType.GuoLao), isTrue);
    expect(schools.contains(EnumSchoolType.QinTang), isTrue);
    expect(schools.contains(EnumSchoolType.TianGuan), isTrue);
  });

  test('果老默认档案=黄道坐标、360 度制', () {
    final p = BuiltInSchoolProfiles.defaultForSchool(EnumSchoolType.GuoLao);
    expect(p.coordinate, CelestialCoordinateSystem.Ecliptic);
    expect(p.zhouTianModelOverride, isNull); // 360 度制默认不覆写
  });

  test('琴堂默认档案=天赤道、365.25 度制', () {
    final p = BuiltInSchoolProfiles.defaultForSchool(EnumSchoolType.QinTang);
    expect(p.coordinate, CelestialCoordinateSystem.SkyEquatorial);
    expect(p.zhouTianModelOverride, EnumZhouTianModel.degree36525);
  });

  test('byId 命中；未知 id 回落默认档案', () {
    expect(BuiltInSchoolProfiles.byId(BuiltInSchoolProfiles.defaultId).id,
        BuiltInSchoolProfiles.defaultId);
    expect(BuiltInSchoolProfiles.byId('__不存在__').id,
        BuiltInSchoolProfiles.defaultId);
  });

  test('bySchool 返回该派全部典籍档案且非空', () {
    final books = BuiltInSchoolProfiles.bySchool(EnumSchoolType.GuoLao);
    expect(books, isNotEmpty);
    expect(books.every((p) => p.school == EnumSchoolType.GuoLao), isTrue);
  });
}
```

- [ ] **Step 2: 跑测试确认失败**

Run: `flutter test test/domain/engines/school/built_in_school_profiles_test.dart`
Expected: FAIL（`school_profile.dart` 未定义）

- [ ] **Step 3: 实现 `SchoolProfile`**

```dart
// lib/domain/engines/school/school_profile.dart
import 'package:metaphysics_core/enums.dart';
import 'package:qizhengsiyu/enums/enum_school.dart';
import 'package:qizhengsiyu/enums/enum_panel_system_type.dart';
import 'package:qizhengsiyu/enums/enum_zhou_tian_model.dart';
import 'package:qizhengsiyu/enums/enum_zero_point_ref.dart';
import 'package:qizhengsiyu/enums/enum_constellation_offset_tier.dart';
import 'package:qizhengsiyu/domain/entities/models/projection_config.dart';

/// 流派档案：一个「流派 × 典籍」对应一整套 A 层默认。
/// 仿 `SiYuProfile`；只承载阶段一冻结的 A 层字段，不新增维度。
class SchoolProfile {
  final String id;
  final String name;
  final EnumSchoolType school;
  final String classicBook;

  // ——— 一整套 A 层默认（对齐 BasePanelConfig 字段名）———
  final CelestialCoordinateSystem coordinate;
  final PanelSystemType panelSystemType;
  final ConstellationSystemType constellationSystemType;
  final EnumZhouTianModel? zhouTianModelOverride;
  final ProjectionConfig? projectionOverride;
  final EnumZeroPointRef? zeroPointRef;
  final ConstellationOffsetTier? offsetTier;
  final double? constellationOffsetDeg;

  /// 关联四余档案 id（可空；四余星历由 SiYuProfile 体系另行解析）
  final String? siYuProfileId;

  const SchoolProfile({
    required this.id,
    required this.name,
    required this.school,
    required this.classicBook,
    required this.coordinate,
    required this.panelSystemType,
    required this.constellationSystemType,
    this.zhouTianModelOverride,
    this.projectionOverride,
    this.zeroPointRef,
    this.offsetTier,
    this.constellationOffsetDeg,
    this.siYuProfileId,
  });
}
```

- [ ] **Step 4: 实现 `BuiltInSchoolProfiles`**

```dart
// lib/domain/engines/school/built_in_school_profiles.dart
import 'package:metaphysics_core/enums.dart';
import 'package:qizhengsiyu/enums/enum_school.dart';
import 'package:qizhengsiyu/enums/enum_panel_system_type.dart';
import 'package:qizhengsiyu/enums/enum_zhou_tian_model.dart';
import 'school_profile.dart';

/// 内置流派档案。每个「流派 × 典籍」一档；同派多典籍各出一档。
class BuiltInSchoolProfiles {
  static const defaultId = 'guolao_guolaoxingzong';

  // 果老·黄道（《果老星宗》）：现代黄道 + 360 度制，关联果老黄道四余档案
  static const _guoLao = SchoolProfile(
    id: 'guolao_guolaoxingzong',
    name: '果老派·果老星宗',
    school: EnumSchoolType.GuoLao,
    classicBook: '果老星宗',
    coordinate: CelestialCoordinateSystem.Ecliptic,
    panelSystemType: PanelSystemType.Tropical,
    constellationSystemType: ConstellationSystemType.Classical,
    siYuProfileId: 'guolao_ecliptic',
  );

  // 天官·黄道（《天官星经》）：现代黄道 + 360 度制
  static const _tianGuan = SchoolProfile(
    id: 'tianguan_tianguanxingjing',
    name: '天官派·天官星经',
    school: EnumSchoolType.TianGuan,
    classicBook: '天官星经',
    coordinate: CelestialCoordinateSystem.Ecliptic,
    panelSystemType: PanelSystemType.Tropical,
    constellationSystemType: ConstellationSystemType.Classical,
    siYuProfileId: 'guolao_ecliptic',
  );

  // 琴堂·天赤道（《星学大成》）：天赤道 365.25 + 恒星制
  static const _qinTang = SchoolProfile(
    id: 'qintang_xingxuedacheng',
    name: '琴堂派·星学大成',
    school: EnumSchoolType.QinTang,
    classicBook: '星学大成',
    coordinate: CelestialCoordinateSystem.SkyEquatorial,
    panelSystemType: PanelSystemType.Sidereal,
    constellationSystemType: ConstellationSystemType.Classical,
    zhouTianModelOverride: EnumZhouTianModel.degree36525,
    siYuProfileId: 'qintang_chidao',
  );

  static const List<SchoolProfile> all = [_guoLao, _tianGuan, _qinTang];

  static SchoolProfile byId(String id) =>
      all.firstWhere((p) => p.id == id, orElse: () => byId(defaultId));

  static List<SchoolProfile> bySchool(EnumSchoolType school) =>
      all.where((p) => p.school == school).toList();

  static SchoolProfile defaultForSchool(EnumSchoolType school) {
    final list = bySchool(school);
    return list.isNotEmpty ? list.first : byId(defaultId);
  }
}
```
> `byId` 的 `orElse` 递归回落到 `defaultId`（该 id 必在 `all` 中，不会无限递归）。若施工者发现 `PanelSystemType` 枚举无 `Sidereal`/`Tropical` 项，按实际枚举值改（阶段一测试已用 `PanelSystemType.Tropical`，`Sidereal` 若不存在则用其恒星制对应项，值以枚举实际为准）。

- [ ] **Step 5: 跑测试确认通过 + analyze**

Run: `flutter test test/domain/engines/school/built_in_school_profiles_test.dart && flutter analyze lib/domain/engines/school/`
Expected: PASS；0 error。

- [ ] **Step 6: 提交**

```bash
git add lib/domain/engines/school/school_profile.dart lib/domain/engines/school/built_in_school_profiles.dart test/domain/engines/school/built_in_school_profiles_test.dart
git commit -m "feat(school): SchoolProfile 模型 + 内置果老/琴堂/天官档案"
```

---

## Task 2: `SchoolConfigResolver` —— 档案套进 `BasePanelConfig`

**Files:**
- Create: `lib/domain/engines/school/school_config_resolver.dart`
- Test: `test/domain/engines/school/school_config_resolver_test.dart`

**Interfaces:**
- Consumes: Task 1 的 `SchoolProfile` / `BuiltInSchoolProfiles`；`BasePanelConfig.copyWith`（阶段一已含全 A 层字段）。
- Produces: `class SchoolConfigResolver { BasePanelConfig applyProfile(BasePanelConfig base, SchoolProfile profile); BasePanelConfig applyById(BasePanelConfig base, String profileId); }`。

- [ ] **Step 1: 写失败测试**

```dart
// test/domain/engines/school/school_config_resolver_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:metaphysics_core/enums.dart';
import 'package:qizhengsiyu/enums/enum_school.dart';
import 'package:qizhengsiyu/enums/enum_zhou_tian_model.dart';
import 'package:qizhengsiyu/domain/entities/models/panel_config.dart';
import 'package:qizhengsiyu/domain/engines/school/built_in_school_profiles.dart';
import 'package:qizhengsiyu/domain/engines/school/school_config_resolver.dart';

void main() {
  final r = SchoolConfigResolver();

  test('套琴堂档案 → 坐标/周天制随档案改写', () {
    final base = BasePanelConfig.defaultBasicPanelConfig();
    final qt = BuiltInSchoolProfiles.defaultForSchool(EnumSchoolType.QinTang);
    final out = r.applyProfile(base, qt);
    expect(out.celestialCoordinateSystem, CelestialCoordinateSystem.SkyEquatorial);
    expect(out.zhouTianModelOverride, EnumZhouTianModel.degree36525);
    expect(out.constellationSystemType, qt.constellationSystemType);
  });

  test('applyById 未知 id → 回落默认果老档案', () {
    final base = BasePanelConfig.defaultBasicPanelConfig();
    final out = r.applyById(base, '__无__');
    expect(out.celestialCoordinateSystem, CelestialCoordinateSystem.Ecliptic);
  });

  test('套档案不破坏 base 的人物/settle 字段（只改 A 层轴）', () {
    final base = BasePanelConfig.defaultBasicPanelConfig();
    final out = r.applyProfile(
        base, BuiltInSchoolProfiles.defaultForSchool(EnumSchoolType.QinTang));
    expect(out.settleLifeType, base.settleLifeType);
    expect(out.settleBodyType, base.settleBodyType);
  });
}
```

- [ ] **Step 2: 跑测试确认失败**

Run: `flutter test test/domain/engines/school/school_config_resolver_test.dart`
Expected: FAIL（`SchoolConfigResolver` 未定义）

- [ ] **Step 3: 实现 resolver**

```dart
// lib/domain/engines/school/school_config_resolver.dart
import 'package:qizhengsiyu/domain/entities/models/panel_config.dart';
import 'school_profile.dart';
import 'built_in_school_profiles.dart';

/// 把流派档案里的一整套 A 层默认套进给定 config。
/// 只改 A 层轴字段，其余（settle/location/人物）原样保留。
class SchoolConfigResolver {
  BasePanelConfig applyProfile(BasePanelConfig base, SchoolProfile p) {
    return base.copyWith(
      celestialCoordinateSystem: p.coordinate,
      panelSystemType: p.panelSystemType,
      constellationSystemType: p.constellationSystemType,
      zhouTianModelOverride: p.zhouTianModelOverride,
      projectionOverride: p.projectionOverride,
      zeroPointRef: p.zeroPointRef,
      offsetTier: p.offsetTier,
      constellationOffsetDeg: p.constellationOffsetDeg,
    );
  }

  BasePanelConfig applyById(BasePanelConfig base, String profileId) =>
      applyProfile(base, BuiltInSchoolProfiles.byId(profileId));
}
```
> 注意：`copyWith` 对可空字段的语义——若阶段一 `copyWith` 用 `field ?? this.field`，则档案里为 `null` 的项（如果老的 `zhouTianModelOverride`）**无法把已有非空值清回 null**。施工者先核对 `BasePanelConfig.copyWith` 是否支持「显式置 null」。若不支持，Task 2 需先给 `copyWith` 的这些 A 层字段加 sentinel 或改为「套档案时整体重建」策略（见下）。**这是必须核对的既有签名点，发现不支持立即停下报用户，不要自作主张改 copyWith 语义。**

- [ ] **Step 4: 跑测试 + analyze**

Run: `flutter test test/domain/engines/school/school_config_resolver_test.dart && flutter analyze lib/domain/engines/school/school_config_resolver.dart`
Expected: PASS；0 error。若「显式置 null」测试失败，暂停报用户裁决 copyWith 策略。

- [ ] **Step 5: 提交**

```bash
git add lib/domain/engines/school/school_config_resolver.dart test/domain/engines/school/school_config_resolver_test.dart
git commit -m "feat(school): SchoolConfigResolver 档案套配到 BasePanelConfig"
```

---

## Task 3: 活 `PanelConfigViewModel` 实装 `updateSchoolType` + 典籍 + `isCustomized`（G4）

**Files:**
- Modify: `lib/presentation/viewmodels/panel_config_viewmodel.dart`
- Test: `test/presentation/viewmodels/panel_config_viewmodel_school_test.dart`

**Interfaces:**
- Consumes: Task 1/2；已有 `_customConfig`(`PanelConfig`)、`EnumSchoolType`。
- Produces: 实装 `void updateSchoolType(EnumSchoolType)`；新增 `void selectClassicBook(String bookProfileId)`；getter `List<SchoolProfile> availableBooks`、`String? selectedProfileId`、`bool isCustomized`；`updateCustomConfig` 里置 `isCustomized=true`。

- [ ] **Step 1: impact**

Run: `impact({target: "updateSchoolType", direction: "upstream"})`
Expected: 调用点 `qi_zheng_si_yu_config_page.dart:466`；确认实装不改签名（仍收 `EnumSchoolType`），附加式加新方法/ getter。

- [ ] **Step 2: 写失败测试**

```dart
// test/presentation/viewmodels/panel_config_viewmodel_school_test.dart
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:metaphysics_core/enums.dart';
import 'package:qizhengsiyu/enums/enum_school.dart';
import 'package:qizhengsiyu/enums/enum_zhou_tian_model.dart';
import 'package:qizhengsiyu/presentation/viewmodels/panel_config_viewmodel.dart';

void main() {
  testWidgets('选琴堂 → config 套天赤道/365.25，且通知监听', (tester) async {
    late PanelConfigViewModel vm;
    await tester.pumpWidget(Builder(builder: (ctx) {
      vm = PanelConfigViewModel(ctx);
      return const SizedBox();
    }));
    var notified = 0;
    vm.addListener(() => notified++);

    vm.updateSchoolType(EnumSchoolType.QinTang);

    expect(vm.customConfig.celestialCoordinateSystem,
        CelestialCoordinateSystem.SkyEquatorial);
    expect(vm.customConfig.zhouTianModelOverride,
        EnumZhouTianModel.degree36525);
    expect(notified, greaterThan(0));
    expect(vm.isCustomized, isFalse); // 刚套档案未自定义
  });

  testWidgets('套档案后手改 config → isCustomized=true', (tester) async {
    late PanelConfigViewModel vm;
    await tester.pumpWidget(Builder(builder: (ctx) {
      vm = PanelConfigViewModel(ctx);
      return const SizedBox();
    }));
    vm.updateSchoolType(EnumSchoolType.GuoLao);
    vm.updateCustomConfig(vm.customConfig.copyWith(
        celestialCoordinateSystem: CelestialCoordinateSystem.SkyEquatorial));
    expect(vm.isCustomized, isTrue);
  });

  testWidgets('Customerized 流派 → 保持当前配置不变', (tester) async {
    late PanelConfigViewModel vm;
    await tester.pumpWidget(Builder(builder: (ctx) {
      vm = PanelConfigViewModel(ctx);
      return const SizedBox();
    }));
    final before = vm.customConfig.celestialCoordinateSystem;
    vm.updateSchoolType(EnumSchoolType.Customerized);
    expect(vm.customConfig.celestialCoordinateSystem, before);
  });
}
```

- [ ] **Step 3: 跑测试确认失败**

Run: `flutter test test/presentation/viewmodels/panel_config_viewmodel_school_test.dart`
Expected: FAIL（`isCustomized` 未定义 / 套配未生效）

- [ ] **Step 4: 实装**

顶部 import 追加：
```dart
import 'package:qizhengsiyu/domain/engines/school/school_profile.dart';
import 'package:qizhengsiyu/domain/engines/school/built_in_school_profiles.dart';
import 'package:qizhengsiyu/domain/engines/school/school_config_resolver.dart';
```

类内新增字段/ getter：
```dart
final SchoolConfigResolver _schoolResolver = SchoolConfigResolver();
String? _selectedProfileId;
bool _isCustomized = false;

String? get selectedProfileId => _selectedProfileId;
bool get isCustomized => _isCustomized;
List<SchoolProfile> availableBooksFor(EnumSchoolType school) =>
    BuiltInSchoolProfiles.bySchool(school);
```

`updateSchoolType` 实装（替换全注释体）：
```dart
void updateSchoolType(EnumSchoolType schoolType) {
  if (schoolType == EnumSchoolType.Customerized) {
    // 自定义流派：保持当前配置，仅标记
    _isCustomized = true;
    notifyListeners();
    return;
  }
  final profile = BuiltInSchoolProfiles.defaultForSchool(schoolType);
  _customConfig = _schoolResolver.applyProfile(_customConfig, profile)
      as PanelConfig;
  _selectedProfileId = profile.id;
  _isCustomized = false;
  notifyListeners();
}

/// 选具体典籍档案（同派多典籍）
void selectClassicBook(String profileId) {
  final profile = BuiltInSchoolProfiles.byId(profileId);
  _customConfig = _schoolResolver.applyProfile(_customConfig, profile)
      as PanelConfig;
  _selectedProfileId = profile.id;
  _isCustomized = false;
  notifyListeners();
}
```
> **核对点**：`_schoolResolver.applyProfile` 返回 `BasePanelConfig`，而 `_customConfig` 是子类 `PanelConfig`。若 `copyWith` 返回的是 `BasePanelConfig` 而非 `PanelConfig`，`as PanelConfig` 会在运行期抛错——施工者须先确认 `PanelConfig.copyWith` 的返回类型是 `PanelConfig`（阶段一 Task 2 要求子类透传）。若返回基类，暂停报用户（需在 resolver 或 copyWith 上定协变返回，属签名决策）。

`updateCustomConfig` 置脏：
```dart
void updateCustomConfig(PanelConfig customConfig) {
  _customConfig = customConfig;
  _isCustomized = true;
  notifyListeners();
}
```
> 注：原 `updateCustomConfig` 未调 `notifyListeners()`（既有小疏漏）；本 Task 顺带补上（属实装必要，不算越界）。

- [ ] **Step 5: 跑测试 + analyze**

Run: `flutter test test/presentation/viewmodels/panel_config_viewmodel_school_test.dart && flutter analyze lib/presentation/viewmodels/panel_config_viewmodel.dart`
Expected: PASS；0 error。

- [ ] **Step 6: 提交**

```bash
git add lib/presentation/viewmodels/panel_config_viewmodel.dart test/presentation/viewmodels/panel_config_viewmodel_school_test.dart
git commit -m "feat(school): PanelConfigViewModel 实装流派套配+典籍+isCustomized"
```

---

## Task 4: Drift 用户流派表 `t_user_school_profiles`（G5 存储层）

**Files:**
- Create: `lib/data/datasources/local/tables/user_school_profile_table.dart`
- Create: `lib/data/datasources/local/daos/user_school_profile_dao.dart`
- Modify: `lib/data/datasources/local/app_database.dart`（注册 + schemaVersion 3→4 + onUpgrade）
- Regenerate: `app_database.g.dart`、`user_school_profile_dao.g.dart`
- Test: `test/data/user_school_profile_dao_test.dart`

**Interfaces:**
- Consumes: 已有 `AppDatabase`（单例 + `forTesting`）、Drift 表/DAO 模式（仿 `QizhengsiyuPanTable` / `QiZhengSiYuPanDao`）。
- Produces: 表 `UserSchoolProfileTable`（列：uuid PK、name、school、classicBook、panelConfigJson(用 `PanelConfigConverter`)、createdAt、lastUpdatedAt、deletedAt nullable）；DAO `UserSchoolProfileDao { Future<void> upsert(...); Future<List<...>> listAll(); Future<void> softDelete(String uuid); }`。

- [ ] **Step 1: impact**

Run: `impact({target: "AppDatabase", direction: "upstream"})`
Expected: DI/repo 层多点；改动为「加表 + bump schemaVersion」附加式，既有表不动。**HIGH 概率**（DB schema 变更）——先告警用户再继续。

- [ ] **Step 2: 写失败测试（内存库）**

```dart
// test/data/user_school_profile_dao_test.dart
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:metaphysics_core/enums.dart';
import 'package:qizhengsiyu/data/datasources/local/app_database.dart';
import 'package:qizhengsiyu/domain/entities/models/panel_config.dart';

void main() {
  test('upsert → listAll 往返；softDelete 后不在列表', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    final cfg = BasePanelConfig.defaultBasicPanelConfig().copyWith(
      celestialCoordinateSystem: CelestialCoordinateSystem.SkyEquatorial,
    );

    await db.userSchoolProfileDao.upsert(
      uuid: 'u1', name: '我的琴堂', school: '琴堂派',
      classicBook: '星学大成', config: cfg,
    );
    var list = await db.userSchoolProfileDao.listAll();
    expect(list.length, 1);
    expect(list.first.name, '我的琴堂');
    expect(list.first.config.celestialCoordinateSystem,
        CelestialCoordinateSystem.SkyEquatorial);

    await db.userSchoolProfileDao.softDelete('u1');
    list = await db.userSchoolProfileDao.listAll();
    expect(list, isEmpty);
  });
}
```
> 施工者按现有 `QiZhengSiYuPanDao` 的行类/返回结构定 `listAll()` 的返回元素类型（可用 Drift 生成的行类 `UserSchoolProfileTableData`，`config` 经 converter 已是 `BasePanelConfig`）。

- [ ] **Step 3: 跑测试确认失败**

Run: `flutter test test/data/user_school_profile_dao_test.dart`
Expected: FAIL（表/DAO 未定义）

- [ ] **Step 4: 建表（仿 `qizhengsiyu_pan_table.dart`）**

```dart
// lib/data/datasources/local/tables/user_school_profile_table.dart
import 'package:drift/drift.dart';
import '../../../models/converters/panel_config_converter.dart';

class UserSchoolProfileTable extends Table {
  @override
  String get tableName => 't_user_school_profiles';

  TextColumn get uuid => text().withLength(min: 1).named('uuid')();
  TextColumn get name => text().named('name')();
  TextColumn get school => text().named('school')();
  TextColumn get classicBook => text().named('classic_book')();

  /// 一整套 A 层默认，直接存 PanelConfig JSON
  TextColumn get panelConfig =>
      text().map(const PanelConfigConverter()).named('panel_config_json')();

  DateTimeColumn get createdAt => dateTime().named('created_at')();
  DateTimeColumn get lastUpdatedAt => dateTime().named('last_updated_at')();
  DateTimeColumn get deletedAt => dateTime().nullable().named('deleted_at')();

  @override
  Set<Column> get primaryKey => {uuid};
}
```

- [ ] **Step 5: 建 DAO**

```dart
// lib/data/datasources/local/daos/user_school_profile_dao.dart
import 'package:drift/drift.dart';
import '../../../../domain/entities/models/panel_config.dart';
import '../app_database.dart';
import '../tables/user_school_profile_table.dart';

part 'user_school_profile_dao.g.dart';

@DriftAccessor(tables: [UserSchoolProfileTable])
class UserSchoolProfileDao extends DatabaseAccessor<AppDatabase>
    with _$UserSchoolProfileDaoMixin {
  UserSchoolProfileDao(super.db);

  Future<void> upsert({
    required String uuid,
    required String name,
    required String school,
    required String classicBook,
    required BasePanelConfig config,
  }) {
    final now = DateTime.now();
    return into(userSchoolProfileTable).insertOnConflictUpdate(
      UserSchoolProfileTableCompanion.insert(
        uuid: uuid,
        name: name,
        school: school,
        classicBook: classicBook,
        panelConfig: config,
        createdAt: now,
        lastUpdatedAt: now,
      ),
    );
  }

  Future<List<UserSchoolProfileTableData>> listAll() {
    return (select(userSchoolProfileTable)
          ..where((t) => t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.desc(t.lastUpdatedAt)]))
        .get();
  }

  Future<void> softDelete(String uuid) {
    return (update(userSchoolProfileTable)..where((t) => t.uuid.equals(uuid)))
        .write(UserSchoolProfileTableCompanion(deletedAt: Value(DateTime.now())));
  }
}
```
> `panelConfig` 列用 converter，`Companion.insert` 直接收 `BasePanelConfig`。若生成的 Companion 要求 `panelConfig: config`（已 map），照 Drift 生成签名调整；`UserSchoolProfileTableData` 行类的 `panelConfig` getter 即 `BasePanelConfig`。

- [ ] **Step 6: 注册进 `app_database.dart` + bump schemaVersion**

`@DriftDatabase` 的 `tables:` 追加 `UserSchoolProfileTable`，`daos:` 追加 `UserSchoolProfileDao`；顶部 import 两文件。
`schemaVersion` 由 `3` 改 `4`。
`onUpgrade` 末尾追加：
```dart
if (from < 4) {
  // v4: 用户自定义流派档案表
  await m.createTable(userSchoolProfileTable);
}
```

- [ ] **Step 7: 重生成 + 跑测试**

Run: `dart run build_runner build --delete-conflicting-outputs`
然后：`flutter test test/data/user_school_profile_dao_test.dart`
Expected: 生成 `_$UserSchoolProfileDaoMixin` / `userSchoolProfileDao` getter；测试 PASS。

- [ ] **Step 8: 既有 DB 回归（确保 schemaVersion bump 不砸旧表）**

Run: `flutter test test/data/ test/domain/managers/ge_ju_*`（跑既有 DB 相关测试）
Expected: 既有用户库/GeJu 测试零回归。

- [ ] **Step 9: 提交**

```bash
git add lib/data/datasources/local/tables/user_school_profile_table.dart lib/data/datasources/local/daos/user_school_profile_dao.dart lib/data/datasources/local/daos/user_school_profile_dao.g.dart lib/data/datasources/local/app_database.dart lib/data/datasources/local/app_database.g.dart test/data/user_school_profile_dao_test.dart
git commit -m "feat(school): Drift 用户流派表 t_user_school_profiles + DAO（schemaVersion 3→4）"
```

---

## Task 5: 自定义流派存/取服务（G5 编排）

**Files:**
- Create: `lib/domain/services/user_school_profile_service.dart`
- Test: `test/domain/services/user_school_profile_service_test.dart`

**Interfaces:**
- Consumes: Task 4 的 `UserSchoolProfileDao`；`BasePanelConfig`；`uuid` 生成（复用项目现有 uuid 工具，见 `pan` 存法）。
- Produces: `class UserSchoolProfileService { Future<String> saveCurrentAsProfile({required String name, required EnumSchoolType school, required String classicBook, required BasePanelConfig config}); Future<List<UserSchoolProfileTableData>> listAll(); Future<void> delete(String uuid); }`。

- [ ] **Step 1: 写失败测试**

```dart
// test/domain/services/user_school_profile_service_test.dart
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qizhengsiyu/enums/enum_school.dart';
import 'package:qizhengsiyu/data/datasources/local/app_database.dart';
import 'package:qizhengsiyu/domain/entities/models/panel_config.dart';
import 'package:qizhengsiyu/domain/services/user_school_profile_service.dart';

void main() {
  test('保存当前配置为命名档案 → 可列出', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    final svc = UserSchoolProfileService(db.userSchoolProfileDao);
    final id = await svc.saveCurrentAsProfile(
      name: '自定义A', school: EnumSchoolType.Customerized,
      classicBook: '', config: BasePanelConfig.defaultBasicPanelConfig(),
    );
    expect(id, isNotEmpty);
    final list = await svc.listAll();
    expect(list.any((e) => e.uuid == id), isTrue);
  });
}
```

- [ ] **Step 2: 跑测试确认失败**

Run: `flutter test test/domain/services/user_school_profile_service_test.dart`
Expected: FAIL（service 未定义）

- [ ] **Step 3: 实现 service**

```dart
// lib/domain/services/user_school_profile_service.dart
import 'package:uuid/uuid.dart';
import 'package:qizhengsiyu/enums/enum_school.dart';
import 'package:qizhengsiyu/data/datasources/local/app_database.dart';
import 'package:qizhengsiyu/data/datasources/local/daos/user_school_profile_dao.dart';
import 'package:qizhengsiyu/domain/entities/models/panel_config.dart';

class UserSchoolProfileService {
  final UserSchoolProfileDao _dao;
  const UserSchoolProfileService(this._dao);

  Future<String> saveCurrentAsProfile({
    required String name,
    required EnumSchoolType school,
    required String classicBook,
    required BasePanelConfig config,
  }) async {
    final id = 'user_${const Uuid().v4()}';
    await _dao.upsert(
      uuid: id, name: name, school: school.name,
      classicBook: classicBook, config: config,
    );
    return id;
  }

  Future<List<UserSchoolProfileTableData>> listAll() => _dao.listAll();
  Future<void> delete(String uuid) => _dao.softDelete(uuid);
}
```
> `uuid` 包与前缀 `user_` 沿用 GeJu 用户规则的既有做法（`user_`-prefixed UUID）。若项目已有 uuid 工具/封装，改用它而非直接 `Uuid()`（施工者核对 `pubspec` 是否已依赖 `uuid`）。

- [ ] **Step 4: 跑测试 + analyze**

Run: `flutter test test/domain/services/user_school_profile_service_test.dart && flutter analyze lib/domain/services/user_school_profile_service.dart`
Expected: PASS；0 error。

- [ ] **Step 5: 提交**

```bash
git add lib/domain/services/user_school_profile_service.dart test/domain/services/user_school_profile_service_test.dart
git commit -m "feat(school): 自定义流派存取服务 UserSchoolProfileService"
```

---

## Task 6: UI —— 典籍下拉 + 已自定义徽标 + 存为自定义流派

**Files:**
- Modify: `lib/presentation/pages/qi_zheng_si_yu_config_page.dart`
- Test: `test/presentation/pages/config_page_school_widget_test.dart`

**Interfaces:**
- Consumes: Task 3 的 `availableBooksFor` / `selectClassicBook` / `isCustomized` / `selectedProfileId`；已有 `_buildSchoolSelector()`、`_viewModel`、`_selectedSchool`。
- Produces: 流派选择器下方增「典籍下拉」（列 `availableBooksFor(_selectedSchool)`）、「已自定义」徽标（`isCustomized` 时显示）、「存为自定义流派」按钮（弹名字输入 → `UserSchoolProfileService.saveCurrentAsProfile`）。

- [ ] **Step 1: impact**

Run: `impact({target: "_buildSchoolSelector", direction: "upstream"})`
Expected: 仅配置页内部；纯 UI 增量。

- [ ] **Step 2: 写 widget 失败测试**

```dart
// test/presentation/pages/config_page_school_widget_test.dart
// pump 配置页（或抽出的 _buildSchoolSelector 宿主 widget），断言：
// - 选中某流派后出现「典籍」下拉（find.text('典籍') 或 DropdownButton 存在）
// - 手改配置后出现「已自定义」文案
// - 存在「存为自定义流派」按钮
```
> 若整页 pump 依赖过多（Provider/DI），施工者把「典籍下拉 + 徽标 + 存档按钮」抽成一个独立 `SchoolProfileBar` 小 widget（入参：selectedSchool、books、isCustomized、回调），对该小 widget 做 widget 测试，页面里嵌入它。抽 widget 属本 Task 合理拆分，不算越界。

- [ ] **Step 3: 跑测试确认失败**

Run: `flutter test test/presentation/pages/config_page_school_widget_test.dart`
Expected: FAIL

- [ ] **Step 4: 改 UI**

在 `_buildSchoolSelector()` 返回的 Column 内、`SchoolSelector` 之后追加：
- 典籍 `DropdownButtonFormField<String>`：items = `_viewModel.availableBooksFor(_selectedSchool).map((p) => DropdownMenuItem(value: p.id, child: Text(p.classicBook)))`；`onChanged: (id) { if (id != null) { setState(() {}); _viewModel.selectClassicBook(id); } }`。
- 徽标：`if (_viewModel.isCustomized) const Chip(label: Text('已自定义'))`。
- 「存为自定义流派」`TextButton`：点按弹 `showDialog` 收名字 → `await UserSchoolProfileService(AppDatabase().userSchoolProfileDao).saveCurrentAsProfile(name: 输入, school: _selectedSchool, classicBook: 当前档案 classicBook, config: _viewModel.customConfig)` → `SnackBar` 提示成功。
> `SchoolSelector` 的 `onChanged`（line 464-466）里在 `_viewModel.updateSchoolType(school)` 后加 `setState(() {})` 以刷新典籍下拉与徽标。

- [ ] **Step 5: 跑测试 + analyze**

Run: `flutter test test/presentation/pages/config_page_school_widget_test.dart && flutter analyze lib/presentation/pages/qi_zheng_si_yu_config_page.dart`
Expected: PASS；0 error。

- [ ] **Step 6: 提交**

```bash
git add lib/presentation/pages/qi_zheng_si_yu_config_page.dart test/presentation/pages/config_page_school_widget_test.dart
git commit -m "feat(school): 配置页典籍下拉+已自定义徽标+存为自定义流派"
```

---

## Task 7: 尾巴A —— 逐宿覆写编辑器 UI（G1 补完）

**Files:**
- Modify: `lib/presentation/widgets/config/custom_config_section.dart`
- Test: `test/presentation/config/custom_config_section_starinn_editor_test.dart`

**Interfaces:**
- Consumes: 阶段一 `BasePanelConfig.starInnDegreeOverrides`(`Map<Enum28Constellations,double>?`)、`Enum28Constellations`、已有 `_updateConfig()`。
- Produces: 「星宿类型」卡内的折叠面板从占位入口升为真实逐宿编辑器：列二十八宿，每宿一个数值输入，改值写回 `starInnDegreeOverrides` 并 `_updateConfig()`。

- [ ] **Step 1: 写 widget 失败测试**

```dart
// test/presentation/config/custom_config_section_starinn_editor_test.dart
// pump CustomConfigSection，展开逐宿编辑器折叠面板，断言：
// - 出现二十八宿的行（至少能 find 到「角」等宿名文案）
// - 在某宿输入框填入数值 → onConfigChanged 回调的 config.starInnDegreeOverrides 含该宿
```
> 施工者用 `Enum28Constellations` 实际宿名文案（阶段一金标里用了 `Jiao_Mu_Jiao`=角、`Kang_Jin_Long`=亢）；输入用 `tester.enterText`。

- [ ] **Step 2: 跑测试确认失败**

Run: `flutter test test/presentation/config/custom_config_section_starinn_editor_test.dart`
Expected: FAIL（编辑器仍是占位入口）

- [ ] **Step 3: 实现逐宿编辑器**

在「星宿类型」卡的 `ExpansionTile`（阶段一占位入口）内放：`Enum28Constellations.values.map((c) => Row(宿名 Text + TextFormField))`；`onChanged` 里 `final map = {...?_starInnDegreeOverrides}; final v = double.tryParse(text); if (v == null) { map.remove(c); } else { map[c] = v; } _starInnDegreeOverrides = map.isEmpty ? null : map; _updateConfig();`。`initState` 回填已存覆写到各输入框初值。
> 二十八宿列表较长——放在 `ExpansionTile` 折叠内 + `shrinkWrap` ListView，避免撑爆布局。空输入=移除该宿覆写（不写 0）。

- [ ] **Step 4: 跑测试 + analyze**

Run: `flutter test test/presentation/config/custom_config_section_starinn_editor_test.dart && flutter analyze lib/presentation/widgets/config/custom_config_section.dart`
Expected: PASS；0 error。

- [ ] **Step 5: 提交**

```bash
git add lib/presentation/widgets/config/custom_config_section.dart test/presentation/config/custom_config_section_starinn_editor_test.dart
git commit -m "feat(config): 逐宿覆写编辑器 UI（阶段一尾巴A）"
```

---

## Task 8: 尾巴B —— `PanelSystemResolver` 规则④（回归/恒星 × 起点）

**Files:**
- Modify: `lib/domain/managers/panel_system_resolver.dart`
- Test: `test/domain/managers/panel_system_resolver_test.dart`（阶段一已存在，追加）

**Interfaces:**
- Consumes: 阶段一 `BasePanelConfig.panelSystemType`(`Tropical`/`Sidereal`)、`zeroPointRef`(`chunfen`/`dongzhi`)。
- Produces: `validate` 内新增规则④——回归制(`Tropical`) 与冬至起点、恒星制(`Sidereal`) 与春分起点的语义提示（非阻断 warning）。

- [ ] **Step 1: 写失败测试（追加到阶段一 resolver 测试）**

```dart
test('规则④：回归制 + 冬至起点 → 语义提示', () {
  final cfg = BasePanelConfig.defaultBasicPanelConfig().copyWith(
    panelSystemType: PanelSystemType.Tropical,
    zeroPointRef: EnumZeroPointRef.dongzhi,
  );
  final c = PanelSystemResolver().validate(cfg);
  expect(c.warnings.any((w) => w.contains('回归') || w.contains('冬至')), isTrue);
});

test('规则④：回归制 + 春分起点 → 无④类提示（常规组合）', () {
  final cfg = BasePanelConfig.defaultBasicPanelConfig().copyWith(
    panelSystemType: PanelSystemType.Tropical,
    zeroPointRef: EnumZeroPointRef.chunfen,
  );
  final c = PanelSystemResolver().validate(cfg);
  expect(c.warnings.any((w) => w.contains('回归制通常配春分')), isFalse);
});
```
> import 顶部补 `enum_zero_point_ref.dart`、`enum_panel_system_type.dart`（若阶段一测试未 import）。宿名/枚举值以实际为准。

- [ ] **Step 2: 跑测试确认失败**

Run: `flutter test test/domain/managers/panel_system_resolver_test.dart`
Expected: FAIL（无④类提示）

- [ ] **Step 3: 在 `validate` 加规则④**

```dart
// 规则④：回归/恒星 与 起点(春分/冬至) 的语义匹配（非阻断提示）
final ref = config.zeroPointRef;
if (ref != null) {
  final isTropical = config.panelSystemType == PanelSystemType.Tropical;
  if (isTropical && ref == EnumZeroPointRef.dongzhi) {
    warnings.add('回归制通常配春分起点，当前选了冬至起点，请确认');
  }
  if (!isTropical && ref == EnumZeroPointRef.chunfen) {
    warnings.add('恒星制通常配冬至/固定恒星起点，当前选了春分起点，请确认');
  }
}
```
顶部按需 import `enum_zero_point_ref.dart`、`enum_panel_system_type.dart`。

- [ ] **Step 4: 跑测试确认通过**

Run: `flutter test test/domain/managers/panel_system_resolver_test.dart`
Expected: PASS（含阶段一既有规则不回归）

- [ ] **Step 5: 提交**

```bash
git add lib/domain/managers/panel_system_resolver.dart test/domain/managers/panel_system_resolver_test.dart
git commit -m "feat(config): PanelSystemResolver 规则④ 回归/恒星×起点提示（阶段一尾巴B）"
```

---

## Task 9: 金标 + 全量回归收口

**Files:**
- Test: `test/domain/engines/school/school_orchestration_golden_test.dart`

**Interfaces:**
- Consumes: 全链（`updateSchoolType` → `SchoolConfigResolver` → `BasePanelConfig`）。

- [ ] **Step 1: 写流派套配金标**

```dart
// test/domain/engines/school/school_orchestration_golden_test.dart
// 对三派默认档案逐一断言套配后 config 的 A 层关键值：
// - 果老 → Ecliptic + zhouTianModelOverride==null
// - 天官 → Ecliptic + zhouTianModelOverride==null
// - 琴堂 → SkyEquatorial + degree36525
// 并断言：不选流派（默认 config）的 A 层字段与阶段一默认逐位一致（回归红线）。
import 'package:flutter_test/flutter_test.dart';
import 'package:metaphysics_core/enums.dart';
import 'package:qizhengsiyu/enums/enum_school.dart';
import 'package:qizhengsiyu/enums/enum_zhou_tian_model.dart';
import 'package:qizhengsiyu/domain/entities/models/panel_config.dart';
import 'package:qizhengsiyu/domain/engines/school/built_in_school_profiles.dart';
import 'package:qizhengsiyu/domain/engines/school/school_config_resolver.dart';

void main() {
  final r = SchoolConfigResolver();
  final base = BasePanelConfig.defaultBasicPanelConfig();

  test('三派默认档案套配后 A 层关键值符合基线', () {
    final gl = r.applyProfile(
        base, BuiltInSchoolProfiles.defaultForSchool(EnumSchoolType.GuoLao));
    expect(gl.celestialCoordinateSystem, CelestialCoordinateSystem.Ecliptic);
    expect(gl.zhouTianModelOverride, isNull);

    final qt = r.applyProfile(
        base, BuiltInSchoolProfiles.defaultForSchool(EnumSchoolType.QinTang));
    expect(qt.celestialCoordinateSystem, CelestialCoordinateSystem.SkyEquatorial);
    expect(qt.zhouTianModelOverride, EnumZhouTianModel.degree36525);
  });

  test('不选流派：默认 config A 层字段全默认（回归红线）', () {
    expect(base.celestialCoordinateSystem, CelestialCoordinateSystem.Ecliptic);
    expect(base.zhouTianModelOverride, isNull);
    expect(base.zeroPointRef, isNull);
    expect(base.starInnDegreeOverrides, isNull);
  });
}
```

- [ ] **Step 2: 跑金标**

Run: `flutter test test/domain/engines/school/school_orchestration_golden_test.dart`
Expected: PASS

- [ ] **Step 3: 全量回归**

Run: `flutter test`
Expected: All tests passed（零回归；阶段一 38 项 + 本阶段新增全绿）。

- [ ] **Step 4: analyze + detect_changes 复核**

Run: `flutter analyze lib/`（0 error）；`detect_changes({scope: "compare", base_ref: "main"})`
Expected: 仅本计划涉及符号/流程受影响，无意外扩散。

- [ ] **Step 5: 提交**

```bash
git add test/domain/engines/school/school_orchestration_golden_test.dart
git commit -m "test(school): 流派套配金标 + 默认路径回归红线"
```

---

## 阶段二验收（DoD）

- [ ] 选流派(果老/琴堂/天官)一键套配整套 A 层默认，`updateSchoolType` 实装、通知监听；G4 达成。
- [ ] 典籍下拉由所选流派驱动；手改任一 A 层项后显示「已自定义」，不再跟随流派。
- [ ] 「存为自定义流派」把当前配置存进 Drift `t_user_school_profiles`，可列出/软删；G5 达成。
- [ ] 逐宿覆写有真实编辑器（尾巴A）；`PanelSystemResolver` 规则④ 提示回归/恒星×起点冲突（尾巴B）。
- [ ] 不选流派/默认路径盘面与阶段一逐位一致；`flutter analyze` 0 error；`flutter test` 全绿；`detect_changes` 无意外扩散。

## 明确不做（YAGNI / 范围外）

- **起点春分↔冬至几何平移**：`zeroPointRef` 仍只存储；几何换算依赖未定锚点真值 O1，留待用户定锚后单出。
- **自定义星盘全编辑器**：G5 星盘侧仅「导入选择」`user_schemes` JSON（可另开小任务），全字段编辑器 YAGNI。
- **删除死副本 `lib/viewmodels/panel_config_viewmodel.dart`**：本计划不动它；清理另开任务。
- **流派档案 asset 化**：内置档案先用 Dart 常量；迁 asset JSON 待需要。

## Self-Review 备注（施工者须知的既有签名核对点）

实施前逐一核对（发现与计划不符：**停下报用户，不要自作决定**）：
- `BasePanelConfig.copyWith` 是否支持「显式把非空 A 层字段置回 null」（Task 2/3 套档案清值依赖；若用 `?? this.field` 语义则不支持，需用户裁决 copyWith 策略）。
- `PanelConfig.copyWith` 返回类型是 `PanelConfig` 还是基类 `BasePanelConfig`（Task 3 `as PanelConfig` 依赖协变返回）。
- `PanelSystemType` 枚举实际项名（`Tropical`/`Sidereal` 或其他；Task 1/8）。
- Drift 生成物命名：`UserSchoolProfileTableData` 行类、`userSchoolProfileTable` getter、`_$UserSchoolProfileDaoMixin`、Companion 字段（Task 4 按生成实际调整）。
- `pubspec.yaml` 是否已依赖 `uuid`（Task 5；未依赖则用项目既有 id 生成工具）。
- `PanelConfigConverter` 是否把 `BasePanelConfig` 双向编解码（Task 4 复用它存 config JSON）。
