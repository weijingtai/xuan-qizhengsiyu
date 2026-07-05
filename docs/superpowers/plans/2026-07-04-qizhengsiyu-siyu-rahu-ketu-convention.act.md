# Qizhengsiyu SiYu configurable framework Implementation Tasks (ACT Format)

This document contains 24 structured tasks formatted in ACT specification for agentic implementation.

---

```yaml
TASK_ID: "qizhengsiyu-siyu-task-1"
LANG: "Dart 3.8.0"
TARGET_FILE: "lib/enums/enum_rahu_ketu_convention.dart"

CONTEXT:
  DOMAIN: "七政四余排盘算法 - 罗睺/计都白道升降交点归属流派定义"
  STRATEGY: "定义 EnumRahuKetuConvention 枚举以表示罗睺/计都与升降交点的映射约定。古法正统（罗降计升，即罗睺=降交点，计都=升交点）为默认；民间/新法（罗升计降）为另一约定。"

DEPENDENCY_ALLOWANCE:
  IMPORTS: ["package:json_annotation/json_annotation.dart"]
  EXTERNAL_LIBS: []

SIGNATURE: |
  enum EnumRahuKetuConvention {
    @JsonValue("罗降计升")
    luoJiangJiSheng("罗降计升（古法正统）", "罗睺取降交点、计都取升交点。果老星宗/开元占经/一行九执历古法，命理默认。"),

    @JsonValue("罗升计降")
    luoShengJiJiang("罗升计降（民间·西法）", "罗睺取升交点、计都取降交点。清后期西法/印度 Jyotish，与古法正统相反、吉凶互换。");

    final String name;
    final String description;
    const EnumRahuKetuConvention(this.name, this.description);
  }

GUARDRAILS:
  PROHIBITED: ["dart:io", "dart:html"]
  ABSOLUTELY_PROHIBITED: ["修改 xuan-metaphysics-core/lib/enums/enum_stars.dart"]

ASSERTIONS:
  EXECENV: "flutter test"
  CASES:
    - "expect(EnumRahuKetuConvention.values.first, EnumRahuKetuConvention.luoJiangJiSheng);"
    - "expect(EnumRahuKetuConvention.luoJiangJiSheng.name.isNotEmpty, isTrue);"

PROTOCOL:
  MODE: "FULL_FILE"
  NO_PROSE: true
  OUTPUT_FORMAT: "强制返回包裹在 ``` 中的源码"

VERIFICATION: "flutter test test/enums/enum_rahu_ketu_convention_test.dart && flutter analyze"
```

---

```yaml
TASK_ID: "qizhengsiyu-siyu-task-2"
LANG: "Dart 3.8.0"
TARGET_FILE: "lib/domain/engines/siyu/rahu_ketu_definition.dart"

CONTEXT:
  DOMAIN: "七政四余排盘算法 - 罗睺/计都经度分配纯函数"
  STRATEGY: "根据传入的升交点黄经（SE_MEAN_NODE）与流派约定，计算并分配罗睺和计都的绝对黄经，满足两者差值恒为 180° 的不变量。"

DEPENDENCY_ALLOWANCE:
  IMPORTS: ["package:qizhengsiyu/enums/enum_rahu_ketu_convention.dart"]
  EXTERNAL_LIBS: []

SIGNATURE: |
  class RahuKetuLongitudes {
    final double luo; // 罗睺经度
    final double ji;  // 计都经度
    const RahuKetuLongitudes({required this.luo, required this.ji});
  }

  class RahuKetuDefinition {
    const RahuKetuDefinition._();
    static RahuKetuLongitudes assign({
      required double northNode,
      required EnumRahuKetuConvention convention,
    });
  }

GUARDRAILS:
  PROHIBITED: ["dart:io"]
  ABSOLUTELY_PROHIBITED: []

ASSERTIONS:
  EXECENV: "flutter test"
  CASES:
    - "final r = RahuKetuDefinition.assign(northNode: 30, convention: EnumRahuKetuConvention.luoJiangJiSheng); expect(r.ji, closeTo(30, 1e-9)); expect(r.luo, closeTo(210, 1e-9));"
    - "final r = RahuKetuDefinition.assign(northNode: 30, convention: EnumRahuKetuConvention.luoShengJiJiang); expect(r.luo, closeTo(30, 1e-9)); expect(r.ji, closeTo(210, 1e-9));"

PROTOCOL:
  MODE: "FULL_FILE"
  NO_PROSE: true
  OUTPUT_FORMAT: "强制返回包裹在 ``` 中的源码"

VERIFICATION: "flutter test test/domain/engines/siyu/rahu_ketu_definition_test.dart && flutter analyze"
```

---

```yaml
TASK_ID: "qizhengsiyu-siyu-task-3"
LANG: "Dart 3.8.0"
TARGET_FILE: "lib/domain/engines/siyu/si_yu_calculator.dart"

CONTEXT:
  DOMAIN: "七政四余排盘算法 - 四余天文数值中性计算"
  STRATEGY: "基于外部注入的星历源计算白道升交点、降交点（升+180）、月孛（远地点）和紫气（过渡状态下使用注入式算法计算）的黄道经度，保持天文中性，暂不分配罗计流派。"

DEPENDENCY_ALLOWANCE:
  IMPORTS: ["package:timezone/timezone.dart"]
  EXTERNAL_LIBS: []

SIGNATURE: |
  abstract interface class ISiYuEphemerisSource {
    double meanNodeLongitude(double julianDay);
    double meanApogeeLongitude(double julianDay);
  }

  class SiYuRawResult {
    final double northNode;
    final double southNode;
    final double lilith;
    final double qi;
    const SiYuRawResult({
      required this.northNode,
      required this.southNode,
      required this.lilith,
      required this.qi,
    });
  }

  class SiYuCalculator {
    final ISiYuEphemerisSource _source;
    const SiYuCalculator({required ISiYuEphemerisSource source});
    SiYuRawResult compute({
      required double julianDay,
      required DateTime birthDate,
    });
  }

GUARDRAILS:
  PROHIBITED: ["package:sweph/sweph.dart"]
  ABSOLUTELY_PROHIBITED: ["在 SiYuCalculator 内部硬编码实例化 Swiss Ephemeris"]

ASSERTIONS:
  EXECENV: "flutter test"
  CASES:
    - "final calc = SiYuCalculator(source: FakeSource(30, 123)); final r = calc.compute(julianDay: 2451545.0, birthDate: DateTime.utc(2000,1,1)); expect(r.northNode, 30); expect(r.southNode, 210); expect(r.lilith, 123);"

PROTOCOL:
  MODE: "FULL_FILE"
  NO_PROSE: true
  OUTPUT_FORMAT: "强制返回包裹在 ``` 中的源码"

VERIFICATION: "flutter test test/domain/engines/siyu/si_yu_calculator_test.dart && flutter analyze"
```

---

```yaml
TASK_ID: "qizhengsiyu-siyu-task-4"
LANG: "Dart 3.8.0"
TARGET_FILE: "lib/domain/entities/models/panel_config.dart"

CONTEXT:
  DOMAIN: "七政四余排盘参数配置"
  STRATEGY: "在 BasePanelConfig 中增加 rahuKetuConvention 字段，其默认值为 EnumRahuKetuConvention.luoJiangJiSheng，确保旧 JSON 反序列化向后兼容不崩。"

DEPENDENCY_ALLOWANCE:
  IMPORTS: ["package:qizhengsiyu/enums/enum_rahu_ketu_convention.dart"]
  EXTERNAL_LIBS: []

SIGNATURE: |
  // 需在 BasePanelConfig 声明字段：
  // @JsonKey(defaultValue: EnumRahuKetuConvention.luoJiangJiSheng)
  // EnumRahuKetuConvention rahuKetuConvention;
  // 并对应在 copyWith，构造函数与子类 PanelConfig 中同步。

GUARDRAILS:
  PROHIBITED: ["手改 *.g.dart 生成文件"]
  ABSOLUTELY_PROHIBITED: ["反序列化旧 JSON 时无默认值抛出异常"]

ASSERTIONS:
  EXECENV: "flutter test"
  CASES:
    - "final restored = PanelConfig.fromJson(jsonWithoutConvention); expect(restored.rahuKetuConvention, EnumRahuKetuConvention.luoJiangJiSheng);"

PROTOCOL:
  MODE: "PATCH_ONLY"
  NO_PROSE: true
  OUTPUT_FORMAT: "强制返回包裹在 ``` 中的源码"

VERIFICATION: "dart run build_runner build --delete-conflicting-outputs && flutter test test/domain/entities/models/panel_config_convention_test.dart"
```

---

```yaml
TASK_ID: "qizhengsiyu-siyu-task-5"
LANG: "Dart 3.8.0"
TARGET_FILE: "lib/domain/entities/models/panel_stars_info.dart"

CONTEXT:
  DOMAIN: "七政四余排盘模型 - 星体经度实体"
  STRATEGY: "将 StarsAngle 的 toMap、fromMapper、getByStar 方法重构为通过 convention 动态解析罗睺/计都的位置。保持字段本身的中性天文属性（southNode/northNode）和基础的 JSON 序列化逻辑不变。"

DEPENDENCY_ALLOWANCE:
  IMPORTS: [
    "package:qizhengsiyu/enums/enum_rahu_ketu_convention.dart",
    "package:qizhengsiyu/domain/engines/siyu/rahu_ketu_definition.dart"
  ]
  EXTERNAL_LIBS: []

SIGNATURE: |
  // 对 toMap, fromMapper, getByStar 补充可选参数 convention (默认旧法)
  Map<EnumStars, StarAngleSpeed> toMap({EnumRahuKetuConvention convention = EnumRahuKetuConvention.luoJiangJiSheng});
  double getByStar(EnumStars star, {EnumRahuKetuConvention convention = EnumRahuKetuConvention.luoJiangJiSheng});
  static StarsAngle fromMapper(Map<EnumStars, StarAngleSpeed> mapper, {EnumRahuKetuConvention convention = EnumRahuKetuConvention.luoJiangJiSheng});

GUARDRAILS:
  PROHIBITED: []
  ABSOLUTELY_PROHIBITED: ["修改 toJson 导致存储结构破坏"]

ASSERTIONS:
  EXECENV: "flutter test"
  CASES:
    - "final m = sampleAngle.toMap(convention: EnumRahuKetuConvention.luoShengJiJiang); expect(m[EnumStars.Luo]!.angle, 30); expect(m[EnumStars.Ji]!.angle, 210);"

PROTOCOL:
  MODE: "PATCH_ONLY"
  NO_PROSE: true
  OUTPUT_FORMAT: "强制返回包裹在 ``` 中的源码"

VERIFICATION: "flutter test test/domain/entities/models/stars_angle_convention_test.dart && flutter analyze"
```

---

```yaml
TASK_ID: "qizhengsiyu-siyu-task-6"
LANG: "Dart 3.8.0"
TARGET_FILE: "lib/domain/engines/sweph_engine.dart"

CONTEXT:
  DOMAIN: "排盘计算核心引擎 - Swiss Ephemeris"
  STRATEGY: "在 _calculateAllStarsAngleOnZodiac 内，使用 SiYuCalculator 计算四余，并删除冗余的闭包与内联 Sweph.swe_calc 调用。在 _transformToStarPositionRawData 中透传 config.rahuKetuConvention 参数。"

DEPENDENCY_ALLOWANCE:
  IMPORTS: [
    "package:qizhengsiyu/domain/engines/siyu/si_yu_calculator.dart",
    "package:qizhengsiyu/domain/engines/siyu/sweph_si_yu_ephemeris_source.dart"
  ]
  EXTERNAL_LIBS: []

SIGNATURE: |
  // 局部重构：
  // 1. 在 _calculateAllStarsAngleOnZodiac 内实例化 SiYuCalculator(source: SwephSiYuEphemerisSource())
  // 2. 取代对 SE_MEAN_NODE, SE_MEAN_APOG 的多次内联调用。
  // 3. 在 _transformToStarPositionRawData 里: final starMap = starsAngle.toMap(convention: config.rahuKetuConvention);

GUARDRAILS:
  PROHIBITED: []
  ABSOLUTELY_PROHIBITED: ["破坏七政的计算或速度字段逻辑"]

ASSERTIONS:
  EXECENV: "flutter test"
  CASES:
    - "final positions = await engine.calculateStarPositions(input, config); // 验证罗计随 config.rahuKetuConvention 颠倒"

PROTOCOL:
  MODE: "PATCH_ONLY"
  NO_PROSE: true
  OUTPUT_FORMAT: "强制返回包裹在 ``` 中的源码"

VERIFICATION: "flutter test test/domain/engines/sweph_engine_convention_test.dart && flutter analyze"
```

---

```yaml
TASK_ID: "qizhengsiyu-siyu-task-7"
LANG: "Dart 3.8.0"
TARGET_FILE: "lib/presentation/widgets/config/custom_config_section.dart"

CONTEXT:
  DOMAIN: "排盘设置页 - 自定义配置卡片 UI"
  STRATEGY: "添加‘罗计定义’单选选择器。选中‘罗升计降（民间·西法）’时显示黄色背景的警告提示栏。确保 _updateConfig 新建 PanelConfig 时传入选中的 _rahuKetuConvention 值。"

DEPENDENCY_ALLOWANCE:
  IMPORTS: ["package:qizhengsiyu/enums/enum_rahu_ketu_convention.dart"]
  EXTERNAL_LIBS: []

SIGNATURE: |
  // 补充 _rahuKetuConvention 局部状态
  // 在 build 中于星宿制式卡片后插入“罗计定义” Container
  // 确保 _updateConfig() 中：rahuKetuConvention: _rahuKetuConvention

GUARDRAILS:
  PROHIBITED: ["破坏已有配置项的序列化或 callback 传参"]
  ABSOLUTELY_PROHIBITED: ["在 _updateConfig 里遗漏 rahuKetuConvention 字段，导致选择被抛弃（空接陷阱）"]

ASSERTIONS:
  EXECENV: "flutter test"
  CASES:
    - "await tester.tap(find.text('罗升计降（民间·西法）')); await tester.pumpAndSettle(); expect(capturedConfig!.rahuKetuConvention, EnumRahuKetuConvention.luoShengJiJiang);"

PROTOCOL:
  MODE: "PATCH_ONLY"
  NO_PROSE: true
  OUTPUT_FORMAT: "强制返回包裹在 ``` 中的源码"

VERIFICATION: "flutter test test/presentation/widgets/custom_config_section_convention_test.dart && flutter analyze"
```

---

```yaml
TASK_ID: "qizhengsiyu-siyu-task-8"
LANG: "Dart 3.8.0"
TARGET_FILE: "doc/feature/siyu/README.md"

CONTEXT:
  DOMAIN: "系统文档 - 四余与罗计流派流变设计"
  STRATEGY: "新建四余计算与配置说明文档，阐明罗降计升与罗升计降的学术背景、代码模块架构与兼容机制。"

DEPENDENCY_ALLOWANCE:
  IMPORTS: []
  EXTERNAL_LIBS: []

SIGNATURE: |
  # 四余计算与配置说明文档结构
  - 四余计算模块架构 (SiYuCalculator / RahuKetuDefinition)
  - 罗计流派解释与论证
  - 配置选项与持久化向后兼容说明
  - 已知待校准与扩展议题

GUARDRAILS:
  PROHIBITED: []
  ABSOLUTELY_PROHIBITED: []

ASSERTIONS:
  EXECENV: "none"
  CASES: []

PROTOCOL:
  MODE: "FULL_FILE"
  NO_PROSE: true
  OUTPUT_FORMAT: "直接返回 Markdown 原文"

VERIFICATION: "验证文档路径存在且包含‘罗降计升’和‘RahuKetuDefinition’描述"
```

---

```yaml
TASK_ID: "qizhengsiyu-siyu-task-9"
LANG: "Dart 3.8.0"
TARGET_FILE: "lib/enums/enum_zi_qi_algorithm.dart"

CONTEXT:
  DOMAIN: "七政四余排盘算法 - 紫气流派、周期与历元配置枚举"
  STRATEGY: "定义紫气计算所需策略的三个枚举：算法流派、运行周期、历元常数集、天赤道实测标准。"

DEPENDENCY_ALLOWANCE:
  IMPORTS: ["package:json_annotation/json_annotation.dart"]
  EXTERNAL_LIBS: []

SIGNATURE: |
  enum EnumZiQiAlgorithm {
    @JsonValue("果老琴堂") guoLaoQinTang("果老/琴堂（授时辛巳元）"),
    @JsonValue("耶律天官") yelvTianguan("耶律天官（中气闰余粗算宫度）"),
    @JsonValue("清时宪") shixian("清时宪（乾隆甲子元）");
    final String name;
    const EnumZiQiAlgorithm(this.name);
  }

  enum EnumZiQiPeriod {
    years28(10227.1792), years29(10592.0);
    final double days;
    const EnumZiQiPeriod(this.days);
  }

  enum EnumZiQiEpochSet {
    @JsonValue("授时女宿") shouShiNvXiu("授时·女宿（1280 女宿二度≈295°）"),
    @JsonValue("符天箕宿") fuTianJiXiu("符天·箕宿（1281 辛巳冬至箕宿初度）");
    final String name;
    const EnumZiQiEpochSet(this.name);
  }

  enum EnumZiQiChiDaoStandard {
    @JsonValue("授时正典") shouShiOrthodox("授时正典（10227.1792 日·女宿二度）"),
    @JsonValue("Moira实测") moira("Moira 实测（10237.7 日·锚2026翼宿）");
    final String name;
    const EnumZiQiChiDaoStandard(this.name);
  }

GUARDRAILS:
  PROHIBITED: []
  ABSOLUTELY_PROHIBITED: []

ASSERTIONS:
  EXECENV: "flutter test"
  CASES:
    - "expect(EnumZiQiAlgorithm.values.first, EnumZiQiAlgorithm.guoLaoQinTang);"
    - "expect(EnumZiQiPeriod.years28.days, closeTo(10227.1792, 1e-6));"

PROTOCOL:
  MODE: "FULL_FILE"
  NO_PROSE: true
  OUTPUT_FORMAT: "强制返回包裹在 ``` 中的源码"

VERIFICATION: "flutter test test/enums/enum_zi_qi_algorithm_test.dart && flutter analyze"
```

---

```yaml
TASK_ID: "qizhengsiyu-siyu-task-10"
LANG: "Dart 3.8.0"
TARGET_FILE: "lib/domain/engines/siyu/ziqi/guolao_zi_qi_algorithm.dart"

CONTEXT:
  DOMAIN: "七政四余排盘算法 - 果老琴堂紫气运行策略"
  STRATEGY: "实现基于授时元积日的平行顺推公式。引入冬至儒略日计算辅助函数，并依据 totalDegree 参数兼容黄道 360° 和赤道 365.25 古度体系，杜绝硬编码归一化底度。"

DEPENDENCY_ALLOWANCE:
  IMPORTS: [
    "package:sweph/sweph.dart",
    "package:qizhengsiyu/domain/engines/siyu/ziqi/zi_qi_algorithm.dart"
  ]
  EXTERNAL_LIBS: []

SIGNATURE: |
  // 接口定义在 lib/domain/engines/siyu/ziqi/zi_qi_algorithm.dart
  abstract interface class ZiQiAlgorithm {
    String get id;
    double computeLongitude({required double julianDay, required DateTime datetime});
  }

  // 实现类
  class GuoLaoZiQiAlgorithm implements ZiQiAlgorithm {
    final double totalDegree;    // 360(黄道) 或 365.25(赤道)
    final double periodDays;
    final double epochJulianDay;
    final double epochLongitude;

    const GuoLaoZiQiAlgorithm({
      required this.totalDegree,
      required this.periodDays,
      required this.epochJulianDay,
      required this.epochLongitude,
    });
  }

  // 冬至计算（定义在同目录的 solar_term_julian_day.dart 中）
  double winterSolsticeJulianDay(int decemberYear, {bool julianCalendar = false});

GUARDRAILS:
  PROHIBITED: []
  ABSOLUTELY_PROHIBITED: ["将紫气与月球近地点直接绑定", "在算法内部硬编码总周天度数 360"]

ASSERTIONS:
  EXECENV: "flutter test"
  CASES:
    - "const algo = GuoLaoZiQiAlgorithm(totalDegree: 360, periodDays: 10227.1792, epochJulianDay: 1000, epochLongitude: 0); expect(algo.computeLongitude(julianDay: 2000, datetime: DateTime.utc(2000)), closeTo((360 / 10227.1792)*1000, 1e-6));"

PROTOCOL:
  MODE: "FULL_FILE"
  NO_PROSE: true
  OUTPUT_FORMAT: "强制返回包裹在 ``` 中的源码"

VERIFICATION: "flutter test test/domain/engines/siyu/ziqi/guolao_zi_qi_algorithm_test.dart && flutter analyze"
```

---

```yaml
TASK_ID: "qizhengsiyu-siyu-task-11"
LANG: "Dart 3.8.0"
TARGET_FILE: "lib/domain/engines/siyu/ziqi/shixian_zi_qi_algorithm.dart"

CONTEXT:
  DOMAIN: "七政四余排盘算法 - 时宪与天官紫气运行策略"
  STRATEGY: "实现清代时宪历日行平行策略及耶律天官年差累加策略。天官法基于上古上元甲子岁首元度（子宫虚六度=6.0°），通过相对参考年份及参考度数运算，杜绝硬编码上古公元年份。"

DEPENDENCY_ALLOWANCE:
  IMPORTS: ["package:qizhengsiyu/domain/engines/siyu/ziqi/zi_qi_algorithm.dart"]
  EXTERNAL_LIBS: []

SIGNATURE: |
  class ShixianZiQiAlgorithm implements ZiQiAlgorithm {
    final double dailyMotionDegrees;
    final double epochJulianDay;
    final double epochLongitude; // 默认 197.833333（整分）或精算版 197.837237
    const ShixianZiQiAlgorithm({
      required this.dailyMotionDegrees,
      required this.epochJulianDay,
      required this.epochLongitude,
    });
  }

  class TianguanZiQiAlgorithm implements ZiQiAlgorithm {
    final int epochYear; // 参考历元公元年份（如 1281）
    final double epochLongitude; // 该参考年份对应的赤道绝对起点度数（如 6.0）
    final double yearlyIncrementDegrees; // 13.083333
    const TianguanZiQiAlgorithm({
      required this.epochYear,
      required this.epochLongitude,
      required this.yearlyIncrementDegrees,
    });
  }

GUARDRAILS:
  PROHIBITED: []
  ABSOLUTELY_PROHIBITED: ["在耶律天官算法内部硬编码上元甲子的 Gregorian 年份数字"]

ASSERTIONS:
  EXECENV: "flutter test"
  CASES:
    - "const shixian = ShixianZiQiAlgorithm(dailyMotionDegrees: 126.720777/3600, epochJulianDay: 5000, epochLongitude: 197.833333); expect(shixian.computeLongitude(julianDay: 5100, datetime: DateTime.utc(2000)), closeTo(197.833333 + (126.720777/3600)*100, 1e-6));"
    - "const tianguan = TianguanZiQiAlgorithm(epochYear: 2000, epochLongitude: 6.0, yearlyIncrementDegrees: 13.083333); expect(tianguan.computeLongitude(julianDay: 0, datetime: DateTime.utc(2003)), 30.0); // (6 + 3 * 13.083333) = 45.25, 截断到 30.0"

PROTOCOL:
  MODE: "FULL_FILE"
  NO_PROSE: true
  OUTPUT_FORMAT: "强制返回包裹在 ``` 中的源码"

VERIFICATION: "flutter test test/domain/engines/siyu/ziqi/shixian_tianguan_zi_qi_algorithm_test.dart && flutter analyze"
```

---

```yaml
TASK_ID: "qizhengsiyu-siyu-task-12"
LANG: "Dart 3.8.0"
TARGET_FILE: "lib/domain/engines/siyu/ziqi/ziqi_epoch_calibrator.dart"

CONTEXT:
  DOMAIN: "七政四余排盘算法 - 紫气历元经度校准器"
  STRATEGY: "提供从星宿管线自洽反解或基于已知参考盘对标反解历元黄道/赤道经度的计算工具。引入可选的 totalDegree 参数以自适应 360° 与 365.25° 等不同坐标框架的归一化。"

DEPENDENCY_ALLOWANCE:
  IMPORTS: []
  EXTERNAL_LIBS: []

SIGNATURE: |
  class ZiqiEpochCalibrator {
    const ZiqiEpochCalibrator._();
    static double fromConstellationPipeline({required double jiXiuStartLongitude, double totalDegree = 360.0});
    static double fromReferenceChart({
      required double refLongitude,
      required double refJulianDay,
      required double epochJulianDay,
      required double dailyMotionDegrees,
      double totalDegree = 360.0,
    });
  }

GUARDRAILS:
  PROHIBITED: []
  ABSOLUTELY_PROHIBITED: ["在归一化和计算中硬编码 360 度，忽视 totalDegree 参数"]

ASSERTIONS:
  EXECENV: "flutter test"
  CASES:
    - "expect(ZiqiEpochCalibrator.fromConstellationPipeline(jiXiuStartLongitude: 371.5), closeTo(11.5, 1e-9));"
    - "expect(ZiqiEpochCalibrator.fromConstellationPipeline(jiXiuStartLongitude: 370.25, totalDegree: 365.25), closeTo(5.0, 1e-9));"

PROTOCOL:
  MODE: "FULL_FILE"
  NO_PROSE: true
  OUTPUT_FORMAT: "强制返回包裹在 ``` 中的源码"

VERIFICATION: "flutter test test/domain/engines/siyu/ziqi/ziqi_epoch_calibrator_test.dart && flutter analyze"
```

---

```yaml
TASK_ID: "qizhengsiyu-siyu-task-13"
LANG: "Dart 3.8.0"
TARGET_FILE: "lib/domain/engines/siyu/ziqi/zi_qi_algorithm_registry.dart"

CONTEXT:
  DOMAIN: "七政四余排盘算法 - 紫气策略注册管理器"
  STRATEGY: "提供一个支持运行时注册与解析紫气算法实例的管理器，当遇到未注册项时安全地回落到默认的果老算法。"

DEPENDENCY_ALLOWANCE:
  IMPORTS: [
    "package:qizhengsiyu/enums/enum_zi_qi_algorithm.dart",
    "package:qizhengsiyu/domain/engines/siyu/ziqi/zi_qi_algorithm.dart"
  ]
  EXTERNAL_LIBS: []

SIGNATURE: |
  class ZiQiAlgorithmRegistry {
    final Map<EnumZiQiAlgorithm, ZiQiAlgorithm> _map;
    ZiQiAlgorithmRegistry(Map<EnumZiQiAlgorithm, ZiQiAlgorithm> map);
    ZiQiAlgorithm resolve(EnumZiQiAlgorithm which);
    void register(EnumZiQiAlgorithm key, ZiQiAlgorithm algo);
  }

GUARDRAILS:
  PROHIBITED: []
  ABSOLUTELY_PROHIBITED: ["在 resolve 阶段遇到缺失 key 抛出异常中断运行"]

ASSERTIONS:
  EXECENV: "flutter test"
  CASES:
    - "final reg = ZiQiAlgorithmRegistry({EnumZiQiAlgorithm.guoLaoQinTang: mockAlgo}); expect(reg.resolve(EnumZiQiAlgorithm.yelvTianguan), mockAlgo);"

PROTOCOL:
  MODE: "FULL_FILE"
  NO_PROSE: true
  OUTPUT_FORMAT: "强制返回包裹在 ``` 中的源码"

VERIFICATION: "flutter test test/domain/engines/siyu/ziqi/zi_qi_algorithm_registry_test.dart && flutter analyze"
```

---

```yaml
TASK_ID: "qizhengsiyu-siyu-task-14"
LANG: "Dart 3.8.0"
TARGET_FILE: "lib/domain/engines/siyu/si_yu_calculator.dart"

CONTEXT:
  DOMAIN: "七政四余排盘算法 - 四余算法中性计算与配置更新"
  STRATEGY: "重构 SiYuCalculator 构造注入 ZiQiAlgorithm 接口。在 BasePanelConfig 声明并生成序列化字段，并在 CustomConfigSection 接入配置项。在 `fuTianJiXiu` 选项启用时，通过私有方法从 ZhouTianCalculator 读取起算黄道或赤道经度，保持无环依赖。"

DEPENDENCY_ALLOWANCE:
  IMPORTS: [
    "package:qizhengsiyu/domain/engines/siyu/ziqi/zi_qi_algorithm.dart",
    "package:qizhengsiyu/enums/enum_zi_qi_algorithm.dart"
  ]
  EXTERNAL_LIBS: []

SIGNATURE: |
  // 改造 SiYuCalculator 构造与 compute 方法
  class SiYuCalculator {
    final ISiYuEphemerisSource _source;
    final ZiQiAlgorithm _ziQiAlgorithm;
    const SiYuCalculator({
      required ISiYuEphemerisSource source,
      required ZiQiAlgorithm ziQiAlgorithm,
    });
    // ...
  }
  // 需在 BasePanelConfig 声明 ziQiAlgorithm, ziQiPeriod, ziQiEpochSet, ziQiChiDaoStandard。
  // 在 sweph_engine.dart 中：若选择 fuTianJiXiu，动态查询 ZhouTianCalculator 获取箕宿经度作为基准传给 ZiqiEpochCalibrator。

GUARDRAILS:
  PROHIBITED: ["在 zhou_tian_model.dart 中反向导入业务层或校准器（导致循环依赖）"]
  ABSOLUTELY_PROHIBITED: ["在 UI 的 _updateConfig 里遗漏新增字段导致参数回存失效"]

ASSERTIONS:
  EXECENV: "flutter test"
  CASES:
    - "final calc = SiYuCalculator(source: FakeSource(), ziQiAlgorithm: ConstZiQi(88)); expect(calc.compute(julianDay: 0, birthDate: DateTime.now()).qi, 88);"

PROTOCOL:
  MODE: "PATCH_ONLY"
  NO_PROSE: true
  OUTPUT_FORMAT: "强制返回包裹在 ``` 中的源码"

VERIFICATION: "dart run build_runner build --delete-conflicting-outputs && flutter test test/domain/engines/siyu/si_yu_calculator_ziqi_injection_test.dart"
```

---

```yaml
TASK_ID: "qizhengsiyu-siyu-task-15"
LANG: "Dart 3.8.0"
TARGET_FILE: "test/domain/engines/siyu/ziqi/zheng_shi_xing_an_golden_test.dart"

CONTEXT:
  DOMAIN: "七政四余排盘算法 - 郑氏星案天赤道紫气定值验证"
  STRATEGY: "编写测试复现基于 Moira 4 个参考点的最小二乘拟合。校验在天赤道 365.25 古度体系、郭守敬宿距表以及 10237.7 日周期下，紫气预测位置与实测宿度残差应小于 1.0 古度。确定精确的女宿赤道历元回填到引擎中。"

DEPENDENCY_ALLOWANCE:
  IMPORTS: [
    "package:sweph/sweph.dart",
    "package:qizhengsiyu/domain/engines/siyu/ziqi/guolao_zi_qi_algorithm.dart",
    "package:qizhengsiyu/domain/engines/siyu/ziqi/ziqi_epoch_calibrator.dart",
    "package:qizhengsiyu/domain/entities/models/zhou_tian_model.dart"
  ]
  EXTERNAL_LIBS: []

SIGNATURE: |
  // 建立独立的测试用例：
  // 1. 根据宿内度换算赤道绝对经度：_xiuDegreeToLongitude(model, xiu, deg)
  // 2. JD 计算：_caseJulianDay(y, m, d, h, mi)
  // 3. 校验 Moira 实测周期（10237.7日）下 4 个点在天赤道模型中的高精度对齐情况。
  // 4. 调用 ZiqiEpochCalibrator.fromReferenceChart 时，必须显式传递 totalDegree: 365.25 参数。

GUARDRAILS:
  PROHIBITED: ["硬编码数字跳过校验逻辑"]
  ABSOLUTELY_PROHIBITED: []

ASSERTIONS:
  EXECENV: "flutter test"
  CASES:
    - "final epochLon = ZiqiEpochCalibrator.fromReferenceChart(refLongitude: l1, refJulianDay: jd1, epochJulianDay: epochJd, dailyMotionDegrees: daily, totalDegree: 365.25); expect(epochLon, isNotNull);"

PROTOCOL:
  MODE: "FULL_FILE"
  NO_PROSE: true
  OUTPUT_FORMAT: "强制返回包裹在 ``` 中的源码"

VERIFICATION: "flutter test test/domain/engines/siyu/ziqi/zheng_shi_xing_an_golden_test.dart"
```

---

```yaml
TASK_ID: "qizhengsiyu-siyu-task-16"
LANG: "Dart 3.8.0"
TARGET_FILE: "lib/domain/engines/siyu/ziqi/chi_dao_xiu_mapper.dart"

CONTEXT:
  DOMAIN: "七政四余天赤道映射 - 郭守敬赤道宿距与宿度换算"
  STRATEGY: "实现赤道绝对经度（365.25度制）与二十八宿度制（元授时郭守敬宿距）的双向转换。以 alignmentPointAtGong（丑15°/冬至）为累加零点计算各宿起点。数据均从 ZhouTianModel 加载，杜绝硬编码宿宽数据。"

DEPENDENCY_ALLOWANCE:
  IMPORTS: [
    "package:metaphysics_core/enums.dart",
    "package:qizhengsiyu/domain/entities/models/zhou_tian_model.dart"
  ]
  EXTERNAL_LIBS: []

SIGNATURE: |
  class ChiDaoXiuMapper {
    final ZhouTianModel model;
    ChiDaoXiuMapper(this.model);
    ({Enum28Constellations xiu, double deg}) toXiuDegree(double chiDaoLongitude);
    double xiuStartLongitude(Enum28Constellations xiu);
  }

GUARDRAILS:
  PROHIBITED: ["在 Mapper 内部硬编码各个星宿的精确度数值"]
  ABSOLUTELY_PROHIBITED: []

ASSERTIONS:
  EXECENV: "flutter test"
  CASES:
    - "final m = ChiDaoXiuMapper(shoushiModel); final start = m.xiuStartLongitude(Enum28Constellations.Shi); expect(m.toXiuDegree(start).xiu, Enum28Constellations.Shi); expect(m.toXiuDegree(start).deg, closeTo(0, 1e-6));"

PROTOCOL:
  MODE: "FULL_FILE"
  NO_PROSE: true
  OUTPUT_FORMAT: "强制返回包裹在 ``` 中的源码"

VERIFICATION: "flutter test test/domain/engines/siyu/ziqi/chi_dao_xiu_mapper_test.dart && flutter analyze"
```

---

```yaml
TASK_ID: "qizhengsiyu-siyu-task-17"
LANG: "Dart 3.8.0"
TARGET_FILE: "lib/domain/engines/siyu/group/linear_parallel_core.dart"

CONTEXT:
  DOMAIN: "四余通用计算框架 - 平行计算内核与组算法接口"
  STRATEGY: "定义通用平行推算内核 LinearParallelCore 以及四余算法组策略接口 SiYuGroupAlgorithm。支持方向控制（+1顺，-1逆）和归一化周天度数。"

DEPENDENCY_ALLOWANCE:
  IMPORTS: ["package:metaphysics_core/enums.dart"]
  EXTERNAL_LIBS: []

SIGNATURE: |
  enum SiYuGroup { luoJi, yueBo, ziQi }

  abstract interface class SiYuGroupAlgorithm {
    String get id;
    Set<EnumStars> get bodies;
    Map<EnumStars, double> computePositions({required double julianDay, required DateTime datetime});
  }

  class LinearParallelCore {
    final double totalDegree;
    final double dailyMotion;
    final int direction;
    final double epochJulianDay;
    final double epochPosition;

    const LinearParallelCore({
      required this.totalDegree,
      required this.dailyMotion,
      required this.direction,
      required this.epochJulianDay,
      required this.epochPosition,
    });

    double positionAt(double julianDay);
  }

GUARDRAILS:
  PROHIBITED: []
  ABSOLUTELY_PROHIBITED: ["在 positionAt 计算时遗漏 direction 导致顺逆向计算相反"]

ASSERTIONS:
  EXECENV: "flutter test"
  CASES:
    - "const c = LinearParallelCore(totalDegree: 360, dailyMotion: 0.0352, direction: 1, epochJulianDay: 1000, epochPosition: 10); expect(c.positionAt(2000), closeTo((10 + 0.0352 * 1000) % 360, 1e-9));"

PROTOCOL:
  MODE: "FULL_FILE"
  NO_PROSE: true
  OUTPUT_FORMAT: "强制返回包裹在 ``` 中的源码"

VERIFICATION: "flutter test test/domain/engines/siyu/group/linear_parallel_core_test.dart && flutter analyze"
```

---

```yaml
TASK_ID: "qizhengsiyu-siyu-task-18"
LANG: "Dart 3.8.0"
TARGET_FILE: "lib/domain/engines/siyu/group/luo_ji_group_algorithm.dart"

CONTEXT:
  DOMAIN: "四余通用计算框架 - 罗计组星历与平行算法实现"
  STRATEGY: "实现 SiYuGroupAlgorithm 接口，编写基于星历源和基于古法平行内核的两个变体。恒定返回罗睺与计都的位置，且需经过 RahuKetuDefinition.assign 分配满足 180° 对冲和流派映射。"

DEPENDENCY_ALLOWANCE:
  IMPORTS: [
    "package:metaphysics_core/enums.dart",
    "package:qizhengsiyu/enums/enum_rahu_ketu_convention.dart",
    "package:qizhengsiyu/domain/engines/siyu/rahu_ketu_definition.dart",
    "package:qizhengsiyu/domain/engines/siyu/si_yu_calculator.dart",
    "package:qizhengsiyu/domain/engines/siyu/group/linear_parallel_core.dart",
    "package:qizhengsiyu/domain/engines/siyu/group/si_yu_group_algorithm.dart"
  ]
  EXTERNAL_LIBS: []

SIGNATURE: |
  class EphemerisNodePairAlgorithm implements SiYuGroupAlgorithm {
    final ISiYuEphemerisSource source;
    final EnumRahuKetuConvention convention;
    const EphemerisNodePairAlgorithm({required this.source, required this.convention});
    // ...
  }

  class LinearNodePairAlgorithm implements SiYuGroupAlgorithm {
    final LinearParallelCore nodeCore;
    final EnumRahuKetuConvention convention;
    const LinearNodePairAlgorithm({required this.nodeCore, required this.convention});
    // ...
  }

GUARDRAILS:
  PROHIBITED: []
  ABSOLUTELY_PROHIBITED: ["在返回的 map 中缺失 Luo 或 Ji 星体，或两者角度差不等于 180°"]

ASSERTIONS:
  EXECENV: "flutter test"
  CASES:
    - "final algo = LinearNodePairAlgorithm(nodeCore: const LinearParallelCore(totalDegree: 360, dailyMotion: 0.052993, direction: -1, epochJulianDay: 1000, epochPosition: 30), convention: EnumRahuKetuConvention.luoJiangJiSheng); expect(algo.computePositions(julianDay: 1000, datetime: DateTime.utc(2000))[EnumStars.Ji], closeTo(30, 1e-6));"

PROTOCOL:
  MODE: "FULL_FILE"
  NO_PROSE: true
  OUTPUT_FORMAT: "强制返回包裹在 ``` 中的源码"

VERIFICATION: "flutter test test/domain/engines/siyu/group/luo_ji_group_algorithm_test.dart && flutter analyze"
```

---

```yaml
TASK_ID: "qizhengsiyu-siyu-task-19"
LANG: "Dart 3.8.0"
TARGET_FILE: "lib/domain/engines/siyu/group/yue_bo_group_algorithm.dart"

CONTEXT:
  DOMAIN: "四余通用计算框架 - 月孛与紫气策略桥接"
  STRATEGY: "实现月孛星历版、月孛平行版以及对既有 ZiQiAlgorithm 接口紫气算法进行桥接，统一为 SiYuGroupAlgorithm 接口。"

DEPENDENCY_ALLOWANCE:
  IMPORTS: [
    "package:metaphysics_core/enums.dart",
    "package:qizhengsiyu/domain/engines/siyu/si_yu_calculator.dart",
    "package:qizhengsiyu/domain/engines/siyu/ziqi/zi_qi_algorithm.dart",
    "package:qizhengsiyu/domain/engines/siyu/group/linear_parallel_core.dart",
    "package:qizhengsiyu/domain/engines/siyu/group/si_yu_group_algorithm.dart",
    "package:qizhengsiyu/domain/engines/siyu/group/zi_qi_group_algorithm.dart"
  ]
  EXTERNAL_LIBS: []

SIGNATURE: |
  class EphemerisApogeeAlgorithm implements SiYuGroupAlgorithm {
    final ISiYuEphemerisSource source;
    const EphemerisApogeeAlgorithm({required this.source});
  }

  class LinearApogeeAlgorithm implements SiYuGroupAlgorithm {
    final LinearParallelCore core;
    const LinearApogeeAlgorithm({required this.core});
  }

  class ZiQiGroupAlgorithm implements SiYuGroupAlgorithm {
    final ZiQiAlgorithm inner;
    const ZiQiGroupAlgorithm(this.inner);
  }

GUARDRAILS:
  PROHIBITED: []
  ABSOLUTELY_PROHIBITED: []

ASSERTIONS:
  EXECENV: "flutter test"
  CASES:
    - "final algo = LinearApogeeAlgorithm(core: const LinearParallelCore(totalDegree: 360, dailyMotion: 0.111393, direction: 1, epochJulianDay: 1000, epochPosition: 0)); expect(algo.computePositions(julianDay: 1100, datetime: DateTime.utc(2000))[EnumStars.Bei], closeTo(11.1393, 1e-6));"

PROTOCOL:
  MODE: "FULL_FILE"
  NO_PROSE: true
  OUTPUT_FORMAT: "强制返回包裹在 ``` 中的源码"

VERIFICATION: "flutter test test/domain/engines/siyu/group/yue_bo_zi_qi_group_test.dart && flutter analyze"
```

---

```yaml
TASK_ID: "qizhengsiyu-siyu-task-20"
LANG: "Dart 3.8.0"
TARGET_FILE: "lib/domain/engines/siyu/group/piecewise_group_algorithm.dart"

CONTEXT:
  DOMAIN: "四余通用计算框架 - 分段多模型计算支持"
  STRATEGY: "实现硬切换的分段算法组，将多个算法按生效 JulianDay 升序排列。在计算时寻找满足 fromJulianDay <= julianDay 的最大生效段来计算位置。"

DEPENDENCY_ALLOWANCE:
  IMPORTS: [
    "package:metaphysics_core/enums.dart",
    "package:qizhengsiyu/domain/engines/siyu/group/si_yu_group_algorithm.dart"
  ]
  EXTERNAL_LIBS: []

SIGNATURE: |
  class PiecewiseSegment {
    final double fromJulianDay;
    final SiYuGroupAlgorithm algorithm;
    const PiecewiseSegment({required this.fromJulianDay, required this.algorithm});
  }

  class PiecewiseGroupAlgorithm implements SiYuGroupAlgorithm {
    final List<PiecewiseSegment> _segments;
    PiecewiseGroupAlgorithm(List<PiecewiseSegment> segments);
  }

GUARDRAILS:
  PROHIBITED: []
  ABSOLUTELY_PROHIBITED: ["在构造函数中未按 fromJulianDay 排序导致查找错乱", "传入 segments 列表为空"]

ASSERTIONS:
  EXECENV: "flutter test"
  CASES:
    - "final pw = PiecewiseGroupAlgorithm([PiecewiseSegment(fromJulianDay: double.negativeInfinity, algorithm: mock1), PiecewiseSegment(fromJulianDay: 2000, algorithm: mock2)]); expect(pw.computePositions(julianDay: 2001, datetime: DateTime.utc(2000))[EnumStars.Qi], mock2Value);"

PROTOCOL:
  MODE: "FULL_FILE"
  NO_PROSE: true
  OUTPUT_FORMAT: "强制返回包裹在 ``` 中的源码"

VERIFICATION: "flutter test test/domain/engines/siyu/group/piecewise_group_algorithm_test.dart && flutter analyze"
```

---

```yaml
TASK_ID: "qizhengsiyu-siyu-task-21"
LANG: "Dart 3.8.0"
TARGET_FILE: "lib/domain/engines/siyu/spec/si_yu_group_spec.dart"

CONTEXT:
  DOMAIN: "四余通用计算框架 - 配置数据规约与工厂"
  STRATEGY: "定义可序列化的 SiYuGroupSpec 与分段配置，并编写工厂类根据 kind（如 linear_ziqi 等）动态构建出具体的 SiYuGroupAlgorithm 实例。若存在 segments 配置，自动打包为 PiecewiseGroupAlgorithm。"

DEPENDENCY_ALLOWANCE:
  IMPORTS: [
    "package:json_annotation/json_annotation.dart",
    "package:qizhengsiyu/domain/engines/siyu/group/si_yu_group_algorithm.dart",
    "package:qizhengsiyu/domain/engines/siyu/spec/si_yu_algorithm_factory.dart"
  ]
  EXTERNAL_LIBS: []

SIGNATURE: |
  @JsonSerializable(explicitToJson: true)
  class SiYuGroupSpec {
    final String kind;
    final Map<String, double> params;
    final List<SiYuSegmentSpec>? segments;
    final int? rahuKetuConventionIndex;
    const SiYuGroupSpec({required this.kind, this.params = const {}, this.segments, this.rahuKetuConventionIndex});
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

  class CoordinateContext {
    final double totalDegree;
    final ISiYuEphemerisSource? ephemerisSource;
    const CoordinateContext({required this.totalDegree, this.ephemerisSource});
  }

  class SiYuAlgorithmFactory {
    static SiYuAlgorithmFactory withDefaults();
    SiYuGroupAlgorithm build(SiYuGroupSpec spec, CoordinateContext ctx);
  }

GUARDRAILS:
  PROHIBITED: ["手改 *.g.dart 生成文件"]
  ABSOLUTELY_PROHIBITED: ["对未知或未注册的 kind 静默返回默认空星体位置"]

ASSERTIONS:
  EXECENV: "flutter test"
  CASES:
    - "final f = SiYuAlgorithmFactory.withDefaults(); final algo = f.build(SiYuGroupSpec(kind: 'linear_ziqi', params: {'totalDegree': 360, 'dailyMotion': 0.0352, 'epochJulianDay': 1000, 'epochPosition': 5}), ctx); expect(algo.computePositions(julianDay: 2000, datetime: DateTime.utc(2000))[EnumStars.Qi], closeTo((5 + 0.0352*1000)%360, 1e-6));"

PROTOCOL:
  MODE: "FULL_FILE"
  NO_PROSE: true
  OUTPUT_FORMAT: "强制返回包裹在 ``` 中的源码"

VERIFICATION: "dart run build_runner build --delete-conflicting-outputs && flutter test test/domain/engines/siyu/spec/si_yu_algorithm_factory_test.dart"
```

---

```yaml
TASK_ID: "qizhengsiyu-siyu-task-22"
LANG: "Dart 3.8.0"
TARGET_FILE: "lib/domain/engines/siyu/profile/si_yu_profile.dart"

CONTEXT:
  DOMAIN: "四余通用计算框架 - 档案定义与合并器"
  STRATEGY: "定义流派档案 SiYuProfile、内建档案库 BuiltInSiYuProfiles（果老·黄道，琴堂·天赤道），以及合并配置解析器 SiYuConfigResolver，支持从流派默认设置和用户级 overrides 进行配置合并。"

DEPENDENCY_ALLOWANCE:
  IMPORTS: [
    "package:metaphysics_core/enums.dart",
    "package:qizhengsiyu/domain/engines/siyu/group/si_yu_group_algorithm.dart",
    "package:qizhengsiyu/domain/engines/siyu/spec/si_yu_group_spec.dart"
  ]
  EXTERNAL_LIBS: []

SIGNATURE: |
  class SiYuProfile {
    final String id;
    final String name;
    final CelestialCoordinateSystem coordinate;
    final Map<SiYuGroup, SiYuGroupSpec> groups;
    const SiYuProfile({required this.id, required this.name, required this.coordinate, required this.groups});
  }

  class BuiltInSiYuProfiles {
    static const defaultId = 'guolao_ecliptic';
    static final List<SiYuProfile> all;
    static SiYuProfile byId(String id);
  }

  class SiYuConfigResolver {
    ({CelestialCoordinateSystem coordinate, Map<SiYuGroup, SiYuGroupSpec> groups}) resolve({
      required String profileId,
      Map<SiYuGroup, SiYuGroupSpec> overrides = const {},
      CelestialCoordinateSystem? coordinateOverride,
    });
  }

GUARDRAILS:
  PROHIBITED: []
  ABSOLUTELY_PROHIBITED: []

ASSERTIONS:
  EXECENV: "flutter test"
  CASES:
    - "final out = resolver.resolve(profileId: 'guolao_ecliptic', overrides: {SiYuGroup.ziQi: mockSpec}); expect(out.groups[SiYuGroup.ziQi], mockSpec);"

PROTOCOL:
  MODE: "FULL_FILE"
  NO_PROSE: true
  OUTPUT_FORMAT: "强制返回包裹在 ``` 中的源码"

VERIFICATION: "flutter test test/domain/engines/siyu/profile/si_yu_config_resolver_test.dart && flutter analyze"
```

---

```yaml
TASK_ID: "qizhengsiyu-siyu-task-23"
LANG: "Dart 3.8.0"
TARGET_FILE: "lib/domain/entities/models/panel_config.dart"

CONTEXT:
  DOMAIN: "四余通用计算框架 - 配置数据与计算管线接入"
  STRATEGY: "在 BasePanelConfig 声明 siYuProfileId、siYuOverrides 等配置项。在 SwephEngine 内利用配置解析器 resolve 目标流派和覆盖，使用 Factory 实例化三组四余算法并汇入 StarsAngle。"

DEPENDENCY_ALLOWANCE:
  IMPORTS: [
    "package:qizhengsiyu/domain/engines/siyu/group/si_yu_group_algorithm.dart",
    "package:qizhengsiyu/domain/engines/siyu/spec/si_yu_group_spec.dart",
    "package:qizhengsiyu/domain/engines/siyu/spec/si_yu_algorithm_factory.dart",
    "package:qizhengsiyu/domain/engines/siyu/profile/built_in_profiles.dart",
    "package:qizhengsiyu/domain/engines/siyu/profile/si_yu_config_resolver.dart"
  ]
  EXTERNAL_LIBS: []

SIGNATURE: |
  // 1. 在 BasePanelConfig 声明：
  // @JsonKey(defaultValue: 'guolao_ecliptic') String siYuProfileId;
  // @JsonKey(defaultValue: {}) Map<String, SiYuGroupSpec> siYuOverrides;
  // CelestialCoordinateSystem? siYuCoordinateOverride;
  // 并重新运行 build_runner 生成器。
  //
  // 2. 重构 sweph_engine.dart 的 _calculateAllStarsAngleOnZodiac 方法：
  // 使用 SiYuConfigResolver 与 SiYuAlgorithmFactory 动态实例化三组算法组，
  // 循环运行并使用 siYuPos[Luo/Ji/Bei/Qi] 的数值覆盖 StarsAngle 中对应的位置。

GUARDRAILS:
  PROHIBITED: []
  ABSOLUTELY_PROHIBITED: ["罗计重组后直接抛弃 convention 导致旧数据乱序", "UI 重建 PanelConfig 时丢失新增配置字段"]

ASSERTIONS:
  EXECENV: "flutter test"
  CASES:
    - "final resolved = SiYuConfigResolver().resolve(profileId: 'qintang_chidao'); final ziqi = factory.build(resolved.groups[SiYuGroup.ziQi]!, ctx); expect(ziqi.computePositions(julianDay: 2461226.135, datetime: DateTime.utc(2026))[EnumStars.Qi], closeTo(333.843, 0.01));"

PROTOCOL:
  MODE: "PATCH_ONLY"
  NO_PROSE: true
  OUTPUT_FORMAT: "强制返回包裹在 ``` 中的源码"

VERIFICATION: "dart run build_runner build --delete-conflicting-outputs && flutter test test/domain/engines/siyu/si_yu_group_pipeline_test.dart"
```

---

```yaml
TASK_ID: "qizhengsiyu-siyu-task-24"
LANG: "Dart 3.8.0"
TARGET_FILE: "lib/presentation/widgets/config/si_yu_profile_selector.dart"

CONTEXT:
  DOMAIN: "四余通用计算框架 - 流派档案选择与组参数高级编辑器"
  STRATEGY: "编写基础层 SiYuProfileSelector 下拉组件以及高级层 SiYuGroupEditor 编辑组件，并在 CustomConfigSection 接入，使用户能在前台可视化完成流派档案切换、各组算法 kind 选择、平行参数调优及分段节点日期添加。"

DEPENDENCY_ALLOWANCE:
  IMPORTS: [
    "package:flutter/material.dart",
    "package:qizhengsiyu/domain/engines/siyu/profile/built_in_profiles.dart",
    "package:qizhengsiyu/domain/engines/siyu/spec/si_yu_group_spec.dart"
  ]
  EXTERNAL_LIBS: []

SIGNATURE: |
  class SiYuProfileSelector extends StatelessWidget {
    final String selectedId;
    final ValueChanged<String> onChanged;
    const SiYuProfileSelector({super.key, required this.selectedId, required this.onChanged});
  }

  // 另在 si_yu_group_editor.dart 实现高级组配置编辑器：
  // Class SiYuGroupEditor extends StatefulWidget
  // 支持编辑特定组算法的参数（dailyMotion/epochPosition等）及增加分段节点。

GUARDRAILS:
  PROHIBITED: ["在编辑过程中直接产生公式或动态执行 Dart 脚本"]
  ABSOLUTELY_PROHIBITED: ["编辑时未正确派发变更回调，导致配置无法应用并回存"]

ASSERTIONS:
  EXECENV: "flutter test"
  CASES:
    - "await tester.tap(find.byType(DropdownButtonFormField<String>)); await tester.pumpAndSettle(); await tester.tap(find.text('琴堂·天赤道').last); expect(pickedId, 'qintang_chidao');"

PROTOCOL:
  MODE: "FULL_FILE"
  NO_PROSE: true
  OUTPUT_FORMAT: "强制返回包裹在 ``` 中的源码"

VERIFICATION: "flutter test test/presentation/widgets/si_yu_profile_selector_test.dart && flutter analyze"
```
