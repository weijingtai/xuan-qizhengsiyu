# 竹罗三限 ACT

以下 ACT 给编码 AI agents 使用。执行者必须只按 ACT 做事，不得自由发挥。

## ACT 1：基础类型与表

```yaml
---
TASK_ID: "ZLSX-001-base-tables"
LANG: "Flutter 3.38.6 / Dart 3.10.7"
TARGET_FILE: "lib/xing_xian/zhu_luo_san_xian/zhu_luo_san_xian_tables.dart"
CONTEXT:
  DOMAIN: "七政四余竹罗三限算法"
  STRATEGY: "复用项目已有 EnumTwelveGong；新增算法局部 ZhuLuoRuler、昼夜、三限序、三限主表、星数、限程，不写行限计算。"
DEPENDENCY_ALLOWANCE:
  IMPORTS:
    - "package:qizhengsiyu/enums/enum_twelve_gong.dart"
  EXTERNAL_LIBS: []
SIGNATURE: |
  /// Seven rulers used only inside Zhu Luo San Xian calculation.
  enum ZhuLuoRuler { sun, moon, mars, mercury, jupiter, venus, saturn }

  /// Birth sect for triplicity ruler selection.
  enum BirthSect { day, night }

  /// Three limit stages.
  enum LimitStage { first, middle, last }

  /// Returns the three Zhu Luo limit rulers for life palace and sect.
  List<ZhuLuoRuler> zhuLuoLimitRulers(EnumTwelveGong lifePalace, BirthSect sect);

  /// Returns star number: Moon/Mercury=1, Sun/Mars=2, Jupiter=3, Venus=4, Saturn=5.
  int rulerNumber(ZhuLuoRuler ruler);

  /// Returns duration: Moon/Mercury=24, Sun/Mars=28, Jupiter=30, Venus/Saturn=26.
  int rulerDuration(ZhuLuoRuler ruler);
ASSERTIONS:
  EXECENV: "flutter test"
  CASES:
    - "expect(zhuLuoLimitRulers(EnumTwelveGong.You, BirthSect.day), [ZhuLuoRuler.venus, ZhuLuoRuler.moon, ZhuLuoRuler.mars]);"
    - "expect(zhuLuoLimitRulers(EnumTwelveGong.You, BirthSect.night), [ZhuLuoRuler.moon, ZhuLuoRuler.venus, ZhuLuoRuler.mars]);"
    - "expect(rulerNumber(ZhuLuoRuler.venus), 4);"
    - "expect(rulerDuration(ZhuLuoRuler.mars), 28);"
PROTOCOL:
  MODE: "PATCH_ONLY"
  NO_PROSE: true
  OUTPUT_FORMAT: "强制返回包裹在 ``` 中的源码"
---
```

禁止：

- 不要修改其他业务代码。
- 不要引入第三方依赖。
- 不要使用 `xuan` 前缀命名类、函数、文件内标识符。
- 不要重复定义十二宫枚举；`ZhuLuoRuler` 是本算法局部枚举，允许新增。
- 不要导入 `package:xuan_common/...`；本 ACT 不做生产星体 adapter。

## ACT 2：宫位移动工具

```yaml
---
TASK_ID: "ZLSX-002-palace-move"
LANG: "Flutter 3.38.6 / Dart 3.10.7"
TARGET_FILE: "lib/xing_xian/zhu_luo_san_xian/zhu_luo_san_xian_palace_math.dart"
CONTEXT:
  DOMAIN: "七政四余竹罗三限算法"
  STRATEGY: "十二宫是循环数组，所有顺逆移动都用取模公式。"
DEPENDENCY_ALLOWANCE:
  IMPORTS:
    - "package:qizhengsiyu/enums/enum_twelve_gong.dart"
  EXTERNAL_LIBS: []
SIGNATURE: |
  /// Moves palace by offset in Zi-to-Hai order. Positive means forward, negative means backward.
  EnumTwelveGong movePalace(EnumTwelveGong palace, int offset);

  /// Forward distance from one palace to another, counting destination and excluding start.
  int forwardDistance(EnumTwelveGong from, EnumTwelveGong to);
ASSERTIONS:
  EXECENV: "flutter test"
  CASES:
    - "expect(movePalace(EnumTwelveGong.Si, -2), EnumTwelveGong.Mao);"
    - "expect(movePalace(EnumTwelveGong.Mao, -2), EnumTwelveGong.Chou);"
    - "expect(movePalace(EnumTwelveGong.Yin, 1), EnumTwelveGong.Mao);"
    - "expect(forwardDistance(EnumTwelveGong.Wei, EnumTwelveGong.Zi), 5);"
PROTOCOL:
  MODE: "PATCH_ONLY"
  NO_PROSE: true
  OUTPUT_FORMAT: "强制返回包裹在 ``` 中的源码"
---
```

禁止：

- 不要用 switch 手写十二宫跳转。
- 不要把“逆数三宫”写在这里；这里只做通用移动。

## ACT 3：配置模型与 A/B 配置

```yaml
---
TASK_ID: "ZLSX-003-config"
LANG: "Flutter 3.38.6 / Dart 3.10.7"
TARGET_FILE: "lib/xing_xian/zhu_luo_san_xian/zhu_luo_san_xian_config.dart"
CONTEXT:
  DOMAIN: "七政四余竹罗三限算法"
  STRATEGY: "A 和 B 都是配置，不是两个重复计算器。"
DEPENDENCY_ALLOWANCE:
  IMPORTS: ["zhu_luo_san_xian_tables.dart"]
  EXTERNAL_LIBS: []
SIGNATURE: |
  /// Supported algorithm ids.
  enum ZhuLuoAlgorithmId { classicInverseSections, directAnnualWithBridge }

  /// Bridge mode for transition handling.
  enum BridgeMode { none, nextRulerNumberBridge }

  /// Configuration for a Zhu Luo San Xian limit algorithm.
  class ZhuLuoAlgorithmConfig {
    const ZhuLuoAlgorithmConfig({
      required this.id,
      required this.usesInverseSections,
      required this.sectionLength,
      required this.inverseSectionOffset,
      required this.annualDirection,
      required this.bridgeMode,
    });

    final ZhuLuoAlgorithmId id;
    final bool usesInverseSections;
    final int sectionLength;
    final int inverseSectionOffset;
    final int annualDirection;
    final BridgeMode bridgeMode;
  }

  /// A: original inverse-section then direct-remainder model.
  const ZhuLuoAlgorithmConfig classicInverseSectionsConfig = ZhuLuoAlgorithmConfig(
    id: ZhuLuoAlgorithmId.classicInverseSections,
    usesInverseSections: true,
    sectionLength: 10,
    inverseSectionOffset: -2,
    annualDirection: 1,
    bridgeMode: BridgeMode.none,
  );

  /// B: direct annual model with optional next-ruler-number bridge.
  const ZhuLuoAlgorithmConfig directAnnualWithBridgeConfig = ZhuLuoAlgorithmConfig(
    id: ZhuLuoAlgorithmId.directAnnualWithBridge,
    usesInverseSections: false,
    sectionLength: 0,
    inverseSectionOffset: 0,
    annualDirection: 1,
    bridgeMode: BridgeMode.nextRulerNumberBridge,
  );
ASSERTIONS:
  EXECENV: "flutter test"
  CASES:
    - "expect(classicInverseSectionsConfig.inverseSectionOffset, -2);"
    - "expect(classicInverseSectionsConfig.bridgeMode, BridgeMode.none);"
    - "expect(directAnnualWithBridgeConfig.annualDirection, 1);"
    - "expect(directAnnualWithBridgeConfig.bridgeMode, BridgeMode.nextRulerNumberBridge);"
PROTOCOL:
  MODE: "PATCH_ONLY"
  NO_PROSE: true
  OUTPUT_FORMAT: "强制返回包裹在 ``` 中的源码"
---
```

禁止：

- 不要把算法逻辑写进配置文件。
- 不要新增 C、D 实现，只保留未来扩展空间。

## ACT 4：行限计算器

```yaml
---
TASK_ID: "ZLSX-004-calculator"
LANG: "Flutter 3.38.6 / Dart 3.10.7"
TARGET_FILE: "lib/xing_xian/zhu_luo_san_xian/zhu_luo_san_xian_calculator.dart"
CONTEXT:
  DOMAIN: "七政四余竹罗三限算法"
  STRATEGY: "用同一个计算器读取配置；A=逆节零顺，B=顺排行年加补桥。"
DEPENDENCY_ALLOWANCE:
  IMPORTS:
    - "package:qizhengsiyu/enums/enum_twelve_gong.dart"
    - "zhu_luo_san_xian_tables.dart"
    - "zhu_luo_san_xian_palace_math.dart"
    - "zhu_luo_san_xian_config.dart"
  EXTERNAL_LIBS: []
SIGNATURE: |
  /// Input data for Zhu Luo San Xian calculation.
  class ZhuLuoInput {
    const ZhuLuoInput({
      required this.lifePalace,
      required this.birthSect,
      required this.rulerPalaces,
      required this.maxAge,
      required this.config,
    });

    final EnumTwelveGong lifePalace;
    final BirthSect birthSect;
    final Map<ZhuLuoRuler, EnumTwelveGong> rulerPalaces;
    final int maxAge;
    final ZhuLuoAlgorithmConfig config;
  }

  /// One yearly result.
  class ZhuLuoYearResult {
    const ZhuLuoYearResult({
      required this.age,
      required this.stage,
      required this.ruler,
      required this.palace,
      required this.algorithmId,
      required this.phase,
      required this.isTransitionYear,
      required this.usedBridge,
    });

    final int age;
    final LimitStage stage;
    final ZhuLuoRuler ruler;
    final EnumTwelveGong palace;
    final ZhuLuoAlgorithmId algorithmId;
    final String phase;
    final bool isTransitionYear;
    final bool usedBridge;
  }

  /// Calculates yearly Zhu Luo San Xian results from age 1 through maxAge.
  List<ZhuLuoYearResult> calculateZhuLuoSanXian(ZhuLuoInput input);
ASSERTIONS:
  EXECENV: "flutter test"
  CASES:
    - "A law: Saturn in Si returns age 5 Si, age 15 Mao, age 25 Chou, age 26 Yin."
    - "B law: Venus in Yin returns age 4 Yin, age 5 Mao, age 7 Si."
    - "Frederick B law returns age 19 Si, age 29 Mao, age 54 Zi, age 75 Shen."
PROTOCOL:
  MODE: "PATCH_ONLY"
  NO_PROSE: true
  OUTPUT_FORMAT: "强制返回包裹在 ``` 中的源码"
---
```

禁止：

- 不要改 UI。
- 不要改数据库。
- 不要改既有洞微、飞限、小限代码。
- 不要修改 `lib/domain/managers/fate/zhu_luo_san_xian_manager.dart`；本 ACT 只做纯算法模块。
- 不要假装 A 法能复现腓特烈图。
- 不要省略 `algorithmId`、`phase`、`usedBridge`。
- 不要为同一年龄生成多条记录。
- 不要导入 `package:xuan_common/...`。

## ACT 5：测试

```yaml
---
TASK_ID: "ZLSX-005-tests"
LANG: "Flutter 3.38.6 / Dart 3.10.7"
TARGET_FILE: "test/xing_xian/zhu_luo_san_xian_calculator_test.dart"
CONTEXT:
  DOMAIN: "七政四余竹罗三限算法"
  STRATEGY: "测试必须证明 A 和 B 是两套不同配置，且 B 能复现腓特烈图的关键年龄。"
DEPENDENCY_ALLOWANCE:
  IMPORTS:
    - "package:flutter_test/flutter_test.dart"
    - "package:qizhengsiyu/enums/enum_twelve_gong.dart"
    - "package:qizhengsiyu/xing_xian/zhu_luo_san_xian/zhu_luo_san_xian_tables.dart"
    - "package:qizhengsiyu/xing_xian/zhu_luo_san_xian/zhu_luo_san_xian_config.dart"
    - "package:qizhengsiyu/xing_xian/zhu_luo_san_xian/zhu_luo_san_xian_calculator.dart"
  EXTERNAL_LIBS: []
SIGNATURE: |
  # Write tests only. Do not change production code in this ACT.
ASSERTIONS:
  EXECENV: "flutter test test/xing_xian/zhu_luo_san_xian_calculator_test.dart"
  CASES:
    - "expect A law Saturn-in-Si ages 5/15/25/26 to be Si/Mao/Chou/Yin."
    - "expect B law Venus-in-Yin ages 4/5/7 to be Yin/Mao/Si."
    - "expect Frederick B law ages 19/29/32/46/47/54/55/61/75 to match Si/Mao/Wu/Shen/Shen/Zi/Zi/Wu/Shen."
    - "expect Frederick B law to emit exactly one record for age 54 and exactly one record for age 55."
    - "expect A and B with Venus-in-Yin to differ at age 19."
PROTOCOL:
  MODE: "PATCH_ONLY"
  NO_PROSE: true
  OUTPUT_FORMAT: "强制返回包裹在 ``` 中的源码"
---
```

禁止：

- 不要用截图、日志、人工目测作为测试。
- 不要跳过分叉测试。
- 不要修改生产代码来迎合测试。
- 不要重复定义项目已有十二宫枚举。
- 不要导入 `package:xuan_common/...`。
