# Zhu Luo Xing Xian Integration Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Connect the validated Zhu Luo San Xian pure algorithm to the existing 行限 calculation layer without touching UI, database, or unrelated 洞微/飞限/小限 code.

**Architecture:** Keep `lib/xing_xian/zhu_luo_san_xian/` as the pure algorithm module. Add a thin adapter that maps production star-palace data into `ZhuLuoInput`, then add a typed method on `ZhuLuoSanXianManager` while preserving its current `FateManager.calculate(DateTime)` chain behavior.

**Tech Stack:** Flutter 3.38.6, Dart 3.10.7, `flutter_test`, existing `EnumTwelveGong`, existing `BasePanelModel`, pure Zhu Luo module.

---

## Current State

Implemented and verified:

- `lib/xing_xian/zhu_luo_san_xian/zhu_luo_san_xian_tables.dart`
- `lib/xing_xian/zhu_luo_san_xian/zhu_luo_san_xian_palace_math.dart`
- `lib/xing_xian/zhu_luo_san_xian/zhu_luo_san_xian_config.dart`
- `lib/xing_xian/zhu_luo_san_xian/zhu_luo_san_xian_calculator.dart`
- `test/xing_xian/zhu_luo_san_xian/zhu_luo_san_xian_calculator_test.dart`

Verified commands:

```bash
flutter test test/xing_xian/zhu_luo_san_xian/zhu_luo_san_xian_calculator_test.dart
flutter analyze lib/xing_xian/zhu_luo_san_xian test/xing_xian/zhu_luo_san_xian
```

Out of scope for this plan:

- UI rendering.
- Database persistence.
- Ge Ju rule evaluation.
- Refactoring `DongWeiDaXianManager`.
- Changing 洞微、飞限、小限 calculators.
- Replacing the existing `FateManager` chain.

## File Structure

Create:

- `lib/xing_xian/zhu_luo_san_xian/zhu_luo_san_xian_input_builder.dart`  
  Converts production star-palace maps and `BasePanelModel` into `ZhuLuoInput`.

- `test/xing_xian/zhu_luo_san_xian/zhu_luo_san_xian_input_builder_test.dart`  
  Tests star mapping, missing-star errors, and Frederick input construction from production `EnumStars` data.

Modify:

- `lib/domain/managers/fate/zhu_luo_san_xian_manager.dart`  
  Add typed `calculateFromRulerPalaces(...)`, `calculateFromStarPalaces(...)`, and `calculateFromPanel(...)` methods that delegate to the pure algorithm. Keep `calculate(DateTime)` compatible with `FateManager`.

- `test/xing_xian/zhu_luo_san_xian/zhu_luo_san_xian_calculator_test.dart`  
  Add assertions for `usedBridge` and `isTransitionYear` at ages 54 and 55 if not already present.

Create:

- `test/domain/managers/fate/zhu_luo_san_xian_manager_test.dart`  
  Tests manager-level delegation without touching UI or database.

## Task 1: Add Star-Palace Adapter

**Files:**

- Create: `lib/xing_xian/zhu_luo_san_xian/zhu_luo_san_xian_input_builder.dart`
- Test: `test/xing_xian/zhu_luo_san_xian/zhu_luo_san_xian_input_builder_test.dart`

- [ ] **Step 1: Write failing tests for star-palace mapping**

Create `test/xing_xian/zhu_luo_san_xian/zhu_luo_san_xian_input_builder_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:metaphysics_core/enums.dart';
import 'package:qizhengsiyu/domain/entities/models/base_panel_model.dart';
import 'package:qizhengsiyu/domain/entities/models/body_life_model.dart';
import 'package:qizhengsiyu/domain/entities/models/naming_degree_pair.dart';
import 'package:qizhengsiyu/domain/entities/models/star_enter_info.dart';
import 'package:qizhengsiyu/enums/enum_twelve_gong.dart';
import 'package:qizhengsiyu/xing_xian/zhu_luo_san_xian/zhu_luo_san_xian_config.dart';
import 'package:qizhengsiyu/xing_xian/zhu_luo_san_xian/zhu_luo_san_xian_input_builder.dart';
import 'package:qizhengsiyu/xing_xian/zhu_luo_san_xian/zhu_luo_san_xian_tables.dart';

void main() {
  group('Zhu Luo input builder', () {
    test('maps production star palaces to ZhuLuoRuler palaces', () {
      final result = zhuLuoRulerPalacesFromStarPalaces({
        EnumStars.Sun: EnumTwelveGong.Wu,
        EnumStars.Moon: EnumTwelveGong.Wei,
        EnumStars.Mars: EnumTwelveGong.Xu,
        EnumStars.Mercury: EnumTwelveGong.Si,
        EnumStars.Jupiter: EnumTwelveGong.Hai,
        EnumStars.Venus: EnumTwelveGong.Yin,
        EnumStars.Saturn: EnumTwelveGong.Chou,
      });

      expect(result[ZhuLuoRuler.sun], EnumTwelveGong.Wu);
      expect(result[ZhuLuoRuler.moon], EnumTwelveGong.Wei);
      expect(result[ZhuLuoRuler.mars], EnumTwelveGong.Xu);
      expect(result[ZhuLuoRuler.mercury], EnumTwelveGong.Si);
      expect(result[ZhuLuoRuler.jupiter], EnumTwelveGong.Hai);
      expect(result[ZhuLuoRuler.venus], EnumTwelveGong.Yin);
      expect(result[ZhuLuoRuler.saturn], EnumTwelveGong.Chou);
    });

    test('throws StateError with missing star names', () {
      expect(
        () => zhuLuoRulerPalacesFromStarPalaces({
          EnumStars.Sun: EnumTwelveGong.Wu,
        }),
        throwsA(isA<StateError>().having(
          (error) => error.message,
          'message',
          contains('Moon'),
        )),
      );
    });

    test('builds Frederick input from production star palaces', () {
      final input = buildZhuLuoInputFromStarPalaces(
        lifePalace: EnumTwelveGong.You,
        birthSect: BirthSect.day,
        starPalaces: {
          EnumStars.Sun: EnumTwelveGong.Wu,
          EnumStars.Moon: EnumTwelveGong.Wu,
          EnumStars.Mars: EnumTwelveGong.Zi,
          EnumStars.Mercury: EnumTwelveGong.Si,
          EnumStars.Jupiter: EnumTwelveGong.Hai,
          EnumStars.Venus: EnumTwelveGong.Yin,
          EnumStars.Saturn: EnumTwelveGong.Chou,
        },
        maxAge: 80,
        config: directAnnualWithBridgeConfig,
      );

      expect(input.lifePalace, EnumTwelveGong.You);
      expect(input.birthSect, BirthSect.day);
      expect(input.maxAge, 80);
      expect(input.config, directAnnualWithBridgeConfig);
      expect(input.rulerPalaces[ZhuLuoRuler.venus], EnumTwelveGong.Yin);
      expect(input.rulerPalaces[ZhuLuoRuler.moon], EnumTwelveGong.Wu);
      expect(input.rulerPalaces[ZhuLuoRuler.mars], EnumTwelveGong.Zi);
    });

    test('builds input from BasePanelModel entered gong data', () {
      final panel = _minimalPanel(
        lifePalace: EnumTwelveGong.You,
        starPalaces: {
          EnumStars.Sun: EnumTwelveGong.Wu,
          EnumStars.Moon: EnumTwelveGong.Wu,
          EnumStars.Mars: EnumTwelveGong.Zi,
          EnumStars.Mercury: EnumTwelveGong.Si,
          EnumStars.Jupiter: EnumTwelveGong.Hai,
          EnumStars.Venus: EnumTwelveGong.Yin,
          EnumStars.Saturn: EnumTwelveGong.Chou,
        },
      );

      final input = buildZhuLuoInputFromPanel(
        panel: panel,
        birthSect: BirthSect.day,
        maxAge: 80,
        config: directAnnualWithBridgeConfig,
      );

      expect(input.lifePalace, EnumTwelveGong.You);
      expect(input.rulerPalaces[ZhuLuoRuler.venus], EnumTwelveGong.Yin);
      expect(input.rulerPalaces[ZhuLuoRuler.moon], EnumTwelveGong.Wu);
      expect(input.rulerPalaces[ZhuLuoRuler.mars], EnumTwelveGong.Zi);
    });
  });
}

BasePanelModel _minimalPanel({
  required EnumTwelveGong lifePalace,
  required Map<EnumStars, EnumTwelveGong> starPalaces,
}) {
  return BasePanelModel(
    starAngleMapper: const {},
    enteredGongMapper: starPalaces.map(
      (star, palace) => MapEntry(star, _entered(star, palace)),
    ),
    fiveStarWalkingTypeMapper: const {},
    bodyLifeModel: BodyLifeModel(
      lifeGongInfo: GongDegree(gong: lifePalace, degree: 0),
      lifeConstellationInfo: ConstellationDegree(
        constellation: Enum28Constellations.Yi_Huo_She,
        degree: 0,
      ),
      bodyGongInfo: GongDegree(gong: EnumTwelveGong.Si, degree: 0),
      bodyConstellationInfo: ConstellationDegree(
        constellation: Enum28Constellations.Yi_Huo_She,
        degree: 0,
      ),
    ),
    twelveGongMapper: const {},
    shenShaItemMapper: const {},
    huaYaoItemMapper: const {},
    twelveZhangShengGongMapper: const {},
  );
}

EnteredInfo _entered(EnumStars star, EnumTwelveGong palace) {
  return EnteredInfo(
    originalStar: StarDegree(star: star, degree: 0),
    enterGongInfo: GongDegree(gong: palace, degree: 0),
    enterInnInfo: ConstellationDegree(
      constellation: Enum28Constellations.Yi_Huo_She,
      degree: 0,
    ),
  );
}
```

- [ ] **Step 2: Run the failing test**

Run:

```bash
flutter test test/xing_xian/zhu_luo_san_xian/zhu_luo_san_xian_input_builder_test.dart
```

Expected:

```text
FAIL because zhu_luo_san_xian_input_builder.dart does not exist.
```

- [ ] **Step 3: Add the adapter implementation**

Create `lib/xing_xian/zhu_luo_san_xian/zhu_luo_san_xian_input_builder.dart`:

```dart
import 'package:metaphysics_core/enums.dart';
import 'package:qizhengsiyu/domain/entities/models/base_panel_model.dart';
import 'package:qizhengsiyu/enums/enum_twelve_gong.dart';

import 'zhu_luo_san_xian_calculator.dart';
import 'zhu_luo_san_xian_config.dart';
import 'zhu_luo_san_xian_tables.dart';

const Map<EnumStars, ZhuLuoRuler> _starToZhuLuoRuler = {
  EnumStars.Sun: ZhuLuoRuler.sun,
  EnumStars.Moon: ZhuLuoRuler.moon,
  EnumStars.Mars: ZhuLuoRuler.mars,
  EnumStars.Mercury: ZhuLuoRuler.mercury,
  EnumStars.Jupiter: ZhuLuoRuler.jupiter,
  EnumStars.Venus: ZhuLuoRuler.venus,
  EnumStars.Saturn: ZhuLuoRuler.saturn,
};

Map<ZhuLuoRuler, EnumTwelveGong> zhuLuoRulerPalacesFromStarPalaces(
  Map<EnumStars, EnumTwelveGong> starPalaces,
) {
  final missingStars = <EnumStars>[];
  final result = <ZhuLuoRuler, EnumTwelveGong>{};

  for (final entry in _starToZhuLuoRuler.entries) {
    final palace = starPalaces[entry.key];
    if (palace == null) {
      missingStars.add(entry.key);
      continue;
    }
    result[entry.value] = palace;
  }

  if (missingStars.isNotEmpty) {
    throw StateError(
      'Missing star palaces for Zhu Luo San Xian: '
      '${missingStars.map((star) => star.name).join(', ')}',
    );
  }

  return Map.unmodifiable(result);
}

ZhuLuoInput buildZhuLuoInputFromStarPalaces({
  required EnumTwelveGong lifePalace,
  required BirthSect birthSect,
  required Map<EnumStars, EnumTwelveGong> starPalaces,
  required int maxAge,
  ZhuLuoAlgorithmConfig config = directAnnualWithBridgeConfig,
}) {
  return ZhuLuoInput(
    lifePalace: lifePalace,
    birthSect: birthSect,
    rulerPalaces: zhuLuoRulerPalacesFromStarPalaces(starPalaces),
    maxAge: maxAge,
    config: config,
  );
}

ZhuLuoInput buildZhuLuoInputFromPanel({
  required BasePanelModel panel,
  required BirthSect birthSect,
  required int maxAge,
  ZhuLuoAlgorithmConfig config = directAnnualWithBridgeConfig,
}) {
  final starPalaces = <EnumStars, EnumTwelveGong>{};

  for (final entry in panel.enteredGongMapper.entries) {
    if (_starToZhuLuoRuler.containsKey(entry.key)) {
      starPalaces[entry.key] = entry.value.gong;
    }
  }

  return buildZhuLuoInputFromStarPalaces(
    lifePalace: panel.bodyLifeModel.lifeGong,
    birthSect: birthSect,
    starPalaces: starPalaces,
    maxAge: maxAge,
    config: config,
  );
}
```

- [ ] **Step 4: Run the adapter test**

Run:

```bash
flutter test test/xing_xian/zhu_luo_san_xian/zhu_luo_san_xian_input_builder_test.dart
```

Expected:

```text
All tests passed.
```

- [ ] **Step 5: Run existing Zhu Luo tests**

Run:

```bash
flutter test test/xing_xian/zhu_luo_san_xian/zhu_luo_san_xian_calculator_test.dart
```

Expected:

```text
All tests passed.
```

## Task 2: Strengthen Existing Algorithm Tests for Transition Fields

**Files:**

- Modify: `test/xing_xian/zhu_luo_san_xian/zhu_luo_san_xian_calculator_test.dart`

- [ ] **Step 1: Add explicit transition field assertions**

In the Frederick B law test, after the existing age assertions, add:

```dart
final age54 = results.singleWhere((r) => r.age == 54);
final age55 = results.singleWhere((r) => r.age == 55);

expect(age54.palace, EnumTwelveGong.Zi);
expect(age55.palace, EnumTwelveGong.Zi);
expect(age54.usedBridge, isTrue);
expect(age55.usedBridge, isTrue);
expect(age54.isTransitionYear, isTrue);
expect(age55.isTransitionYear, isTrue);
```

- [ ] **Step 2: Run the calculator test**

Run:

```bash
flutter test test/xing_xian/zhu_luo_san_xian/zhu_luo_san_xian_calculator_test.dart
```

Expected:

```text
All tests passed.
```

## Task 3: Add Typed Manager Entry Point

**Files:**

- Modify: `lib/domain/managers/fate/zhu_luo_san_xian_manager.dart`
- Test: `test/domain/managers/fate/zhu_luo_san_xian_manager_test.dart`

- [ ] **Step 1: Write manager delegation test**

Create `test/domain/managers/fate/zhu_luo_san_xian_manager_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:metaphysics_core/enums.dart';
import 'package:qizhengsiyu/domain/managers/fate/zhu_luo_san_xian_manager.dart';
import 'package:qizhengsiyu/enums/enum_twelve_gong.dart';
import 'package:qizhengsiyu/xing_xian/zhu_luo_san_xian/zhu_luo_san_xian_config.dart';
import 'package:qizhengsiyu/xing_xian/zhu_luo_san_xian/zhu_luo_san_xian_tables.dart';

void main() {
  test('manager calculates Frederick B law from typed inputs', () {
    final manager = ZhuLuoSanXianManager();

    final results = manager.calculateFromRulerPalaces(
      lifePalace: EnumTwelveGong.You,
      birthSect: BirthSect.day,
      rulerPalaces: {
        ZhuLuoRuler.venus: EnumTwelveGong.Yin,
        ZhuLuoRuler.moon: EnumTwelveGong.Wu,
        ZhuLuoRuler.mars: EnumTwelveGong.Zi,
      },
      maxAge: 80,
      config: directAnnualWithBridgeConfig,
    );

    expect(results.singleWhere((r) => r.age == 19).palace, EnumTwelveGong.Si);
    expect(results.singleWhere((r) => r.age == 29).palace, EnumTwelveGong.Mao);
    expect(results.singleWhere((r) => r.age == 54).palace, EnumTwelveGong.Zi);
    expect(results.singleWhere((r) => r.age == 75).palace, EnumTwelveGong.Shen);
  });

  test('manager calculates Frederick B law from production star palaces', () {
    final manager = ZhuLuoSanXianManager();

    final results = manager.calculateFromStarPalaces(
      lifePalace: EnumTwelveGong.You,
      birthSect: BirthSect.day,
      starPalaces: {
        EnumStars.Sun: EnumTwelveGong.Wu,
        EnumStars.Moon: EnumTwelveGong.Wu,
        EnumStars.Mars: EnumTwelveGong.Zi,
        EnumStars.Mercury: EnumTwelveGong.Si,
        EnumStars.Jupiter: EnumTwelveGong.Hai,
        EnumStars.Venus: EnumTwelveGong.Yin,
        EnumStars.Saturn: EnumTwelveGong.Chou,
      },
      maxAge: 80,
      config: directAnnualWithBridgeConfig,
    );

    expect(results.singleWhere((r) => r.age == 19).palace, EnumTwelveGong.Si);
    expect(results.singleWhere((r) => r.age == 54).palace, EnumTwelveGong.Zi);
    expect(results.singleWhere((r) => r.age == 75).palace, EnumTwelveGong.Shen);
  });
}
```

- [ ] **Step 2: Run the failing manager test**

Run:

```bash
flutter test test/domain/managers/fate/zhu_luo_san_xian_manager_test.dart
```

Expected:

```text
FAIL because calculateFromRulerPalaces is not defined.
```

- [ ] **Step 3: Add typed methods to manager**

Modify `lib/domain/managers/fate/zhu_luo_san_xian_manager.dart`:

```dart
import 'package:qizhengsiyu/domain/entities/models/base_panel_model.dart';
import 'package:qizhengsiyu/enums/enum_twelve_gong.dart';
import 'package:metaphysics_core/enums.dart';
import 'package:qizhengsiyu/xing_xian/zhu_luo_san_xian/zhu_luo_san_xian_calculator.dart';
import 'package:qizhengsiyu/xing_xian/zhu_luo_san_xian/zhu_luo_san_xian_config.dart';
import 'package:qizhengsiyu/xing_xian/zhu_luo_san_xian/zhu_luo_san_xian_input_builder.dart';
import 'package:qizhengsiyu/xing_xian/zhu_luo_san_xian/zhu_luo_san_xian_tables.dart';
import 'package:xuan_logger/xuan_logger.dart';

import 'fate_manager.dart';

class ZhuLuoSanXianManager extends FateManager {
  List<ZhuLuoYearResult> calculateFromRulerPalaces({
    required EnumTwelveGong lifePalace,
    required BirthSect birthSect,
    required Map<ZhuLuoRuler, EnumTwelveGong> rulerPalaces,
    required int maxAge,
    ZhuLuoAlgorithmConfig config = directAnnualWithBridgeConfig,
  }) {
    return calculateZhuLuoSanXian(
      ZhuLuoInput(
        lifePalace: lifePalace,
        birthSect: birthSect,
        rulerPalaces: rulerPalaces,
        maxAge: maxAge,
        config: config,
      ),
    );
  }

  List<ZhuLuoYearResult> calculateFromStarPalaces({
    required EnumTwelveGong lifePalace,
    required BirthSect birthSect,
    required Map<EnumStars, EnumTwelveGong> starPalaces,
    required int maxAge,
    ZhuLuoAlgorithmConfig config = directAnnualWithBridgeConfig,
  }) {
    return calculateZhuLuoSanXian(
      buildZhuLuoInputFromStarPalaces(
        lifePalace: lifePalace,
        birthSect: birthSect,
        starPalaces: starPalaces,
        maxAge: maxAge,
        config: config,
      ),
    );
  }

  List<ZhuLuoYearResult> calculateFromPanel({
    required BasePanelModel panel,
    required BirthSect birthSect,
    required int maxAge,
    ZhuLuoAlgorithmConfig config = directAnnualWithBridgeConfig,
  }) {
    return calculateZhuLuoSanXian(
      buildZhuLuoInputFromPanel(
        panel: panel,
        birthSect: birthSect,
        maxAge: maxAge,
        config: config,
      ),
    );
  }

  @override
  void calculate(DateTime date) {
    logger.i('计算竹罗三限...');
    passToNext(date);
  }
}
```

- [ ] **Step 4: Run manager test**

Run:

```bash
flutter test test/domain/managers/fate/zhu_luo_san_xian_manager_test.dart
```

Expected:

```text
All tests passed.
```

- [ ] **Step 5: Run Zhu Luo test suite**

Run:

```bash
flutter test test/xing_xian/zhu_luo_san_xian test/domain/managers/fate/zhu_luo_san_xian_manager_test.dart
```

Expected:

```text
All tests passed.
```

## Task 4: Verify Boundaries and Static Analysis

**Files:**

- No source changes unless checks fail.

- [ ] **Step 1: Confirm no UI/database files changed**

Run:

```bash
git status --short lib/xing_xian/zhu_luo_san_xian lib/domain/managers/fate/zhu_luo_san_xian_manager.dart test/xing_xian/zhu_luo_san_xian test/domain/managers/fate/zhu_luo_san_xian_manager_test.dart
```

Expected changed paths only:

```text
lib/xing_xian/zhu_luo_san_xian/zhu_luo_san_xian_input_builder.dart
lib/domain/managers/fate/zhu_luo_san_xian_manager.dart
test/xing_xian/zhu_luo_san_xian/zhu_luo_san_xian_input_builder_test.dart
test/xing_xian/zhu_luo_san_xian/zhu_luo_san_xian_calculator_test.dart
test/domain/managers/fate/zhu_luo_san_xian_manager_test.dart
```

- [ ] **Step 2: Run local analyze**

Run:

```bash
flutter analyze lib/xing_xian/zhu_luo_san_xian lib/domain/managers/fate/zhu_luo_san_xian_manager.dart test/xing_xian/zhu_luo_san_xian test/domain/managers/fate/zhu_luo_san_xian_manager_test.dart
```

Expected:

```text
No issues found.
```

- [ ] **Step 3: Run all Zhu Luo tests**

Run:

```bash
flutter test test/xing_xian/zhu_luo_san_xian test/domain/managers/fate/zhu_luo_san_xian_manager_test.dart
```

Expected:

```text
All tests passed.
```

- [ ] **Step 4: Confirm no accidental `xuan_common` or `package:common` import**

Run:

```bash
rg -n "package:xuan_common|package:common" lib/xing_xian/zhu_luo_san_xian lib/domain/managers/fate/zhu_luo_san_xian_manager.dart test/xing_xian/zhu_luo_san_xian test/domain/managers/fate/zhu_luo_san_xian_manager_test.dart
```

Expected:

```text
No matches.
```

## Task 5: Update Zhu Luo Documentation

**Files:**

- Modify: `doc/zhu_luo_san_xian/gstack_validation_report.md`

- [ ] **Step 1: Add integration evidence section**

Append this section:

````markdown
## Manager Integration Evidence

Scope:

- Pure algorithm remains in `lib/xing_xian/zhu_luo_san_xian/`.
- `ZhuLuoSanXianManager` exposes typed calculation methods, including production `EnumStars` star-palace input.
- UI, database, 洞微、飞限、小限 are unchanged.

Verification commands:

```bash
flutter analyze lib/xing_xian/zhu_luo_san_xian lib/domain/managers/fate/zhu_luo_san_xian_manager.dart test/xing_xian/zhu_luo_san_xian test/domain/managers/fate/zhu_luo_san_xian_manager_test.dart
flutter test test/xing_xian/zhu_luo_san_xian test/domain/managers/fate/zhu_luo_san_xian_manager_test.dart
rg -n "package:xuan_common|package:common" lib/xing_xian/zhu_luo_san_xian lib/domain/managers/fate/zhu_luo_san_xian_manager.dart test/xing_xian/zhu_luo_san_xian test/domain/managers/fate/zhu_luo_san_xian_manager_test.dart
```
````

- [ ] **Step 2: Run documentation grep**

Run:

```bash
rg -n "Manager Integration Evidence|ZhuLuoSanXianManager|calculateFromPanel" doc/zhu_luo_san_xian/gstack_validation_report.md
```

Expected:

```text
Matches for all three terms.
```

## Final Verification

Run:

```bash
flutter analyze lib/xing_xian/zhu_luo_san_xian lib/domain/managers/fate/zhu_luo_san_xian_manager.dart test/xing_xian/zhu_luo_san_xian test/domain/managers/fate/zhu_luo_san_xian_manager_test.dart
flutter test test/xing_xian/zhu_luo_san_xian test/domain/managers/fate/zhu_luo_san_xian_manager_test.dart
rg -n "package:xuan_common|package:common" lib/xing_xian/zhu_luo_san_xian lib/domain/managers/fate/zhu_luo_san_xian_manager.dart test/xing_xian/zhu_luo_san_xian test/domain/managers/fate/zhu_luo_san_xian_manager_test.dart
```

Expected:

```text
Analyze: No issues found.
Tests: All tests passed.
Import scan: no matches.
```

## Commit Guidance

After final verification:

```bash
git add \
  lib/xing_xian/zhu_luo_san_xian \
  lib/domain/managers/fate/zhu_luo_san_xian_manager.dart \
  test/xing_xian/zhu_luo_san_xian \
  test/domain/managers/fate/zhu_luo_san_xian_manager_test.dart \
  doc/zhu_luo_san_xian/gstack_validation_report.md

git commit -m "feat: integrate zhu luo san xian with xing xian layer"
```

## Self-Review

- Spec coverage: The plan connects the pure algorithm to the 行限 layer through adapter and manager without touching UI/database.
- Placeholder scan: No unresolved placeholder markers are present.
- Type consistency: `ZhuLuoRuler`, `BirthSect`, `ZhuLuoInput`, `ZhuLuoYearResult`, and `ZhuLuoAlgorithmConfig` match the current pure algorithm module.
