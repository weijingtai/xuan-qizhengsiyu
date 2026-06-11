# Zhu Luo Xing Xian Integration ACT Tasks

## Assignment

- **Coding agent:** Execute ACT-ZL-CODE-001 only.
- **Coding for test agent:** Execute ACT-ZL-TEST-001 only.

Both agents must stay on a non-main branch. Neither agent may fix `xuan-common`.

---
TASK_ID: "ACT-ZL-CODE-001"
LANG: "Dart 3.10.7 / Flutter 3.38.6"
TARGET_FILE: "lib/xing_xian/zhu_luo_san_xian/zhu_luo_san_xian_input_builder.dart; lib/domain/managers/fate/zhu_luo_san_xian_manager.dart"
CONTEXT:
  DOMAIN: "七政四余 / 行限体系 / 竹罗三限接入"
  STRATEGY: "只做薄适配：生产星体宫位或 BasePanelModel -> ZhuLuoInput -> calculateZhuLuoSanXian；不得改变 A/B 纯算法。"
DEPENDENCY_ALLOWANCE:
  IMPORTS: ["package:metaphysics_core/enums.dart", "package:qizhengsiyu/domain/entities/models/base_panel_model.dart", "package:qizhengsiyu/enums/enum_twelve_gong.dart", "package:qizhengsiyu/xing_xian/zhu_luo_san_xian/zhu_luo_san_xian_calculator.dart", "package:qizhengsiyu/xing_xian/zhu_luo_san_xian/zhu_luo_san_xian_config.dart", "package:qizhengsiyu/xing_xian/zhu_luo_san_xian/zhu_luo_san_xian_tables.dart"]
  EXTERNAL_LIBS: []
SIGNATURE: |
  Map<ZhuLuoRuler, EnumTwelveGong> zhuLuoRulerPalacesFromStarPalaces(
    Map<EnumStars, EnumTwelveGong> starPalaces,
  )
  /// Convert production seven-star palace data into Zhu Luo ruler palace data.
  /// Must require Sun, Moon, Mars, Mercury, Jupiter, Venus, and Saturn.
  /// Must throw StateError when any required star is missing.

  ZhuLuoInput buildZhuLuoInputFromStarPalaces({
    required EnumTwelveGong lifePalace,
    required BirthSect birthSect,
    required Map<EnumStars, EnumTwelveGong> starPalaces,
    required int maxAge,
    required ZhuLuoAlgorithmConfig config,
  })
  /// Build a ZhuLuoInput from explicit production star-palace data.

  ZhuLuoInput buildZhuLuoInputFromPanel({
    required BasePanelModel panel,
    required BirthSect birthSect,
    required int maxAge,
    required ZhuLuoAlgorithmConfig config,
  })
  /// Build a ZhuLuoInput from panel.bodyLifeModel.lifeGong and panel.enteredGongMapper.

  class ZhuLuoSanXianManager extends FateManager {
    List<ZhuLuoYearResult> calculateFromRulerPalaces({
      required EnumTwelveGong lifePalace,
      required BirthSect birthSect,
      required Map<ZhuLuoRuler, EnumTwelveGong> rulerPalaces,
      required int maxAge,
      required ZhuLuoAlgorithmConfig config,
    });

    List<ZhuLuoYearResult> calculateFromStarPalaces({
      required EnumTwelveGong lifePalace,
      required BirthSect birthSect,
      required Map<EnumStars, EnumTwelveGong> starPalaces,
      required int maxAge,
      required ZhuLuoAlgorithmConfig config,
    });

    List<ZhuLuoYearResult> calculateFromPanel({
      required BasePanelModel panel,
      required BirthSect birthSect,
      required int maxAge,
      required ZhuLuoAlgorithmConfig config,
    });

    @override
    void calculate(DateTime date);
  }
ASSERTIONS:
  EXECENV: "flutter test / flutter analyze"
  CASES:
    - "flutter test test/xing_xian/zhu_luo_san_xian test/domain/managers/fate/zhu_luo_san_xian_manager_test.dart"
    - "flutter analyze lib/xing_xian/zhu_luo_san_xian lib/domain/managers/fate/zhu_luo_san_xian_manager.dart test/xing_xian/zhu_luo_san_xian test/domain/managers/fate/zhu_luo_san_xian_manager_test.dart"
PROTOCOL:
  MODE: "PATCH_ONLY"
  NO_PROSE: true
  OUTPUT_FORMAT: "强制返回包裹在 ``` 中的源码"

ABSOLUTE_DO_NOT:
- Do not edit `lib/xing_xian/zhu_luo_san_xian/zhu_luo_san_xian_calculator.dart`.
- Do not edit `lib/xing_xian/zhu_luo_san_xian/zhu_luo_san_xian_tables.dart`.
- Do not edit `lib/xing_xian/zhu_luo_san_xian/zhu_luo_san_xian_config.dart`.
- Do not edit UI, database, 洞微, 飞限, 小限, or Ge Ju files.
- Do not add any dependency.
- Do not introduce identifiers containing `xuan_` or `xuan-`.
- Do not repair `xuan-common` failures.

---
TASK_ID: "ACT-ZL-TEST-001"
LANG: "Dart 3.10.7 / Flutter 3.38.6"
TARGET_FILE: "test/xing_xian/zhu_luo_san_xian/zhu_luo_san_xian_input_builder_test.dart; test/domain/managers/fate/zhu_luo_san_xian_manager_test.dart; test/xing_xian/zhu_luo_san_xian/zhu_luo_san_xian_calculator_test.dart"
CONTEXT:
  DOMAIN: "七政四余 / 行限体系 / 竹罗三限测试"
  STRATEGY: "测试只锁定接入契约：star map/panel -> input -> manager delegation；算法正确性继续由既有 A/B calculator tests 负责。"
DEPENDENCY_ALLOWANCE:
  IMPORTS: ["package:flutter_test/flutter_test.dart", "package:metaphysics_core/enums.dart", "package:qizhengsiyu/domain/entities/models/base_panel_model.dart", "package:qizhengsiyu/domain/entities/models/body_life_model.dart", "package:qizhengsiyu/domain/entities/models/naming_degree_pair.dart", "package:qizhengsiyu/domain/entities/models/star_enter_info.dart", "package:qizhengsiyu/domain/managers/fate/zhu_luo_san_xian_manager.dart", "package:qizhengsiyu/enums/enum_twelve_gong.dart", "package:qizhengsiyu/xing_xian/zhu_luo_san_xian/zhu_luo_san_xian_calculator.dart", "package:qizhengsiyu/xing_xian/zhu_luo_san_xian/zhu_luo_san_xian_config.dart", "package:qizhengsiyu/xing_xian/zhu_luo_san_xian/zhu_luo_san_xian_input_builder.dart", "package:qizhengsiyu/xing_xian/zhu_luo_san_xian/zhu_luo_san_xian_tables.dart"]
  EXTERNAL_LIBS: []
SIGNATURE: |
  void main()
  /// Add focused Flutter tests for:
  /// 1. Star palace adapter mapping.
  /// 2. Missing required star error.
  /// 3. Frederick B-law input construction from star palaces.
  /// 4. BasePanelModel input construction.
  /// 5. Manager delegation from ruler palaces, star palaces, and panel.
  /// 6. Calculator regression metadata for Frederick bridge years.
ASSERTIONS:
  EXECENV: "flutter_test"
  CASES:
    - "expect(zhuLuoRulerPalacesFromStarPalaces({...})[ZhuLuoRuler.venus], EnumTwelveGong.Yin);"
    - "expect(() => zhuLuoRulerPalacesFromStarPalaces({EnumStars.Sun: EnumTwelveGong.Wu}), throwsA(isA<StateError>()));"
    - "expect(buildZhuLuoInputFromStarPalaces(...Frederick...).rulerPalaces[ZhuLuoRuler.mars], EnumTwelveGong.Zi);"
    - "expect(manager.calculateFromStarPalaces(...Frederick...).firstWhere((r) => r.age == 61).palace, EnumTwelveGong.Wu);"
    - "expect(manager.calculateFromPanel(...FrederickPanel...).firstWhere((r) => r.age == 75).palace, EnumTwelveGong.Shen);"
    - "expect(results.firstWhere((r) => r.age == 54).usedBridge, true);"
    - "expect(results.firstWhere((r) => r.age == 55).isTransitionYear, true);"
PROTOCOL:
  MODE: "PATCH_ONLY"
  NO_PROSE: true
  OUTPUT_FORMAT: "强制返回包裹在 ``` 中的源码"

ABSOLUTE_DO_NOT:
- Do not edit production files except when adding missing imports required by test compilation is explicitly delegated back to Coding agent.
- Do not weaken or delete existing calculator assertions.
- Do not skip tests.
- Do not add mocks for the pure calculator.
- Do not add external test packages.
- Do not repair `xuan-common` failures.
- Do not introduce identifiers containing `xuan_` or `xuan-`.

FINAL_GATE:
```bash
flutter test test/xing_xian/zhu_luo_san_xian
flutter test test/domain/managers/fate/zhu_luo_san_xian_manager_test.dart
flutter analyze lib/xing_xian/zhu_luo_san_xian lib/domain/managers/fate/zhu_luo_san_xian_manager.dart test/xing_xian/zhu_luo_san_xian test/domain/managers/fate/zhu_luo_san_xian_manager_test.dart
```
