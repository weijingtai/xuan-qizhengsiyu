# Zhu Luo Xing Xian Integration ACT Tasks

## Assignment

- **Coding agent:** Execute ACT-ZL-CODE-001 only.
- **Coding for test agent:** Execute ACT-ZL-TEST-001 only.
- **Verify agent:** Execute ACT-ZL-VERIFY-001 only, after CODE and TEST are complete.
- **Doc closeout agent:** Execute ACT-ZL-DOC-001 only, after VERIFY is complete.

All agents must stay on a non-main branch. No agent may fix `xuan-common`.

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

---
TASK_ID: "ACT-ZL-VERIFY-001"
LANG: "Dart 3.10.7 / Flutter 3.38.6"
TARGET_FILE: "docs/superpowers/plans/2026-06-11-zhu-luo-xing-xian-verification-evidence.md"
CONTEXT:
  DOMAIN: "七政四余 / 行限体系 / 竹罗三限闭环验收"
  STRATEGY: "只做验证与证据记录：运行 focused test/analyze，确认 CODE 与 TEST 的产物满足 ACT，不修代码。"
DEPENDENCY_ALLOWANCE:
  IMPORTS: []
  EXTERNAL_LIBS: []
SIGNATURE: |
  # Verification evidence document
  # Must record:
  # - git branch
  # - changed files relevant to Zhu Luo integration
  # - command results
  # - ignored xuan-common/common blockers, if any
  # - final acceptance verdict
ASSERTIONS:
  EXECENV: "zsh + flutter test + flutter analyze"
  CASES:
    - "git branch --show-current"
    - "git status --short"
    - "flutter test test/xing_xian/zhu_luo_san_xian"
    - "flutter test test/domain/managers/fate/zhu_luo_san_xian_manager_test.dart"
    - "flutter analyze lib/xing_xian/zhu_luo_san_xian lib/domain/managers/fate/zhu_luo_san_xian_manager.dart test/xing_xian/zhu_luo_san_xian test/domain/managers/fate/zhu_luo_san_xian_manager_test.dart"
    - "rg -n \"package:xuan_common|package:common\" lib test"
PROTOCOL:
  MODE: "PATCH_ONLY"
  NO_PROSE: true
  OUTPUT_FORMAT: "强制返回包裹在 ``` 中的 Markdown"

ABSOLUTE_DO_NOT:
- Do not edit production code.
- Do not edit test code.
- Do not fix analyzer failures unrelated to focused Zhu Luo files.
- Do not repair `xuan-common` or common-related failures.
- Do not claim full repository validation if only focused gates were run.
- Do not modify UI, database, 洞微, 飞限, 小限, or Ge Ju files.

PASS_CONDITION:
- Focused Zhu Luo tests pass.
- Focused manager test passes.
- Focused analyzer command passes, or any failure is explicitly proven unrelated to Zhu Luo integration and caused by existing common/xuan-common instability.

---
TASK_ID: "ACT-ZL-DOC-001"
LANG: "Markdown / Dart 3.10.7 interface references"
TARGET_FILE: "doc/zhu_luo_san_xian/竹罗三限调查报告.md; docs/superpowers/plans/2026-06-10-zhu-luo-xing-xian-integration.md; docs/superpowers/plans/2026-06-11-zhu-luo-xing-xian-test-plan.md"
CONTEXT:
  DOMAIN: "七政四余 / 行限体系 / 竹罗三限交付文档闭环"
  STRATEGY: "只回填已经实现并验证的事实：接口、测试命令、验收结论、限制边界；不得新增算法解释或修改历史推导。"
DEPENDENCY_ALLOWANCE:
  IMPORTS: []
  EXTERNAL_LIBS: []
SIGNATURE: |
  # Documentation closeout
  # Must update human-readable docs with:
  # - implemented entry points
  # - A/B config remains pure algorithm
  # - adapter path: EnumStars/BasePanelModel -> ZhuLuoInput
  # - manager path: ZhuLuoSanXianManager typed methods
  # - verification evidence file link
  # - remaining out-of-scope boundaries
ASSERTIONS:
  EXECENV: "Markdown review + rg"
  CASES:
    - "rg -n \"calculateFromRulerPalaces|calculateFromStarPalaces|calculateFromPanel|buildZhuLuoInputFromPanel\" doc/zhu_luo_san_xian docs/superpowers/plans"
    - "rg -n \"TODO|TBD|待定|implement later|fill in|Similar to|适当|以后\" doc/zhu_luo_san_xian docs/superpowers/plans/2026-06-10-zhu-luo-xing-xian-integration.md docs/superpowers/plans/2026-06-11-zhu-luo-xing-xian-test-plan.md docs/superpowers/plans/2026-06-11-zhu-luo-xing-xian-act-tasks.md"
PROTOCOL:
  MODE: "PATCH_ONLY"
  NO_PROSE: true
  OUTPUT_FORMAT: "强制返回包裹在 ``` 中的 Markdown"

ABSOLUTE_DO_NOT:
- Do not edit production code.
- Do not edit test code.
- Do not change algorithm formulas or historical interpretation.
- Do not mark UI/database/Ge Ju integration as complete.
- Do not hide unresolved focused gate failures.
- Do not repair `xuan-common` or common-related failures.

PASS_CONDITION:
- Documents clearly say this closeout covers algorithm-to-行限-manager integration only.
- Documents link or name the verification evidence file.
- No placeholder terms remain in the touched docs.
