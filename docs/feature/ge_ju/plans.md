# 七政四余格局计算系统设计方案

## 一、需求分析

### 目标
设计一个格局判断系统，输入命盘信息，输出该命盘符合的所有格局（支持多格局匹配）。

### 核心要求
- **精确匹配**：严格按古籍描述的条件判断
- **JSON配置**：格局规则以结构化JSON存储，支持用户自定义编辑
- **包含行限**：支持命盘格局和行限触发格局

---

## 二、现有代码基础（已实现）

### 2.1 格局模型（已有）
**文件**: `lib/domain/entities/models/ge_ju_model.dart`

```dart
class GeJuModel {
  String name;          // 格局名称
  String className;     // 分类名
  String books;         // 出处（灵台阁、十三补遗、通元赋）
  String description;   // 描述
  JiXiongEnum jiXiong;  // 吉凶
  GeJuType geJuType;    // 格局类型
}

enum GeJuType { pin, jian, fu, gui, yao, shou, xian, yu }
// 贫、贱、富、贵、夭、寿、贤、愚
```

### 2.2 星曜关系模型（已有）
**文件**: `lib/domain/entities/models/star_to_star_relationship_model.dart`

```dart
class StarToStarRelationshipModel {
  Map<EnumTwelveGong, Set<ElevenStarsInfo>> sameGongMap;      // 同宫
  Map<Enum28Constellations, Set<ElevenStarsInfo>> sameStarInnMap;  // 同宿
  Map<EnumStars, Map<Enum28Constellations, Set<ElevenStarsInfo>>> sameJingMap;  // 同经
  Set<Set<ElevenStarsInfo>> sameLuoSet;                       // 同络
  Map<DiZhiChong, Map<EnumTwelveGong, Set<ElevenStarsInfo>>> chongGongSet;  // 对宫
  Map<DiZhiSanHe, Map<EnumTwelveGong, Set<ElevenStarsInfo>>> threeHeGongMap;  // 三方
  Map<DiZhiFourZheng, Map<EnumTwelveGong, Set<ElevenStarsInfo>>> fourZhengMap;  // 四正

  factory StarToStarRelationshipModel.create(Set<ElevenStarsInfo> starsSet);
}
```

### 2.3 恩难仇用（已有）
**文件**: `lib/enums/enum_stars_four_type.dart`

```dart
enum EnumStarsFourType { En, Nan, Chou, Yong, Unknown }
// 恩、难、仇、用、无

// 获取星体间的恩难仇用关系
static Map<EnumStars, Map<EnumStarsFourType, Set<EnumStars>>> getStarsFourTypeMapper()
static Map<EnumStarsFourType, Set<EnumStars>> getStarsRelationshipMapper(EnumStars star)
```

### 2.4 庙旺状态（已有）
**文件**: `lib/enums/enum_star_position_status.dart`

```dart
enum EnumStarGongPositionStatusType {
  // 宫位状态 (isGong=true)
  Miao("庙"), Wang("旺"), Xi("喜"), Le("乐"),
  Nu("怒"), Xian("凶"), Zheng("正"), Pian("偏"), Yuan("垣"),
  // 星度状态 (isGong=false)
  Dian("殿"), Xiong("凶"), Gui("贵")
}
```

### 2.5 身命模型（已有）
**文件**: `lib/domain/entities/models/body_life_model.dart`

```dart
class BodyLifeModel {
  final GongDegree lifeGongInfo;              // 命宫
  final ConstellationDegree lifeConstellationInfo;  // 命度
  final GongDegree bodyGongInfo;              // 身宫
  final ConstellationDegree bodyConstellationInfo;  // 身度

  EnumTwelveGong get lifeGong => lifeGongInfo.gong;
  Enum28Constellations get lifeConstellatioin => lifeConstellationInfo.constellation;
  EnumTwelveGong get bodyGong => bodyGongInfo.gong;
  Enum28Constellations get bodyConstellation => bodyConstellationInfo.constellation;
}
```

### 2.6 宫位与宫主（已有）
**文件**: `lib/enums/enum_twelve_gong.dart`

```dart
enum EnumTwelveGong {
  Zi(DiZhi.ZI, ..., EnumStars.Saturn, ...),  // 子宫宫主为土星
  Chou(DiZhi.CHOU, ..., EnumStars.Saturn, ...),
  Yin(DiZhi.YIN, ..., EnumStars.Jupiter, ...),  // 寅宫宫主为木星
  Mao(DiZhi.MAO, ..., EnumStars.Mars, ...),
  Chen(DiZhi.CHEN, ..., EnumStars.Venus, ...),
  Si(DiZhi.SI, ..., EnumStars.Mercury, ...),
  Wu(DiZhi.WU, ..., EnumStars.Sun, ...),
  Wei(DiZhi.WEI, ..., EnumStars.Moon, ...),
  Shen(DiZhi.SHEN, ..., EnumStars.Mercury, ...),
  You(DiZhi.YOU, ..., EnumStars.Venus, ...),
  Xu(DiZhi.XU, ..., EnumStars.Mars, ...),
  Hai(DiZhi.HAI, ..., EnumStars.Jupiter, ...);

  final EnumStars sevenZheng;  // 宫主星

  EnumTwelveGong get opposite;  // 对宫
  List<EnumTwelveGong> get otherSquareGongList;  // 四正其他宫
  List<EnumTwelveGong> get otherTringleGongList;  // 三方其他宫
}
```

### 2.6.1 十二宫体系：黄道与赤道（十二次）

格局判断需支持两种十二宫体系的选择：

| 黄道十二宫 | 赤道十二次 | 对应地支 |
|-----------|-----------|---------|
| 宝瓶 | 玄枵 | 子 |
| 磨羯 | 星纪 | 丑 |
| 人马 | 析木 | 寅 |
| 天蝎 | 大火 | 卯 |
| 天秤 | 寿星 | 辰 |
| 双女 | 鹑尾 | 巳 |
| 狮子 | 鹑火 | 午 |
| 巨蟹 | 鹑首 | 未 |
| 双子 | 实沈 | 申 |
| 金牛 | 大梁 | 酉 |
| 白羊 | 降娄 | 戌 |
| 双鱼 | 娵訾 | 亥 |

**现有代码支持**：
- `CelestialCoordinateSystem` 枚举：ecliptic(黄道制)、equatorial(赤道制)、skyEquatorial(天赤道制)
- `ZhouTianModel.systemType` 保存当前命盘使用的坐标体系
- `beauty_view_page.dart` 中有十二次名称映射

**格局判断应用**：
- JSON规则可指定 `"coordinateSystem": "equatorial"` 表示该格局基于赤道体系
- 若规则未指定体系，则使用命盘当前体系
- 宫位条件（如 starInGong）在赤道体系下应支持十二次名称匹配

### 2.7 四主计算方式
四主并非独立字段，而是通过以下方式获取：
- **命宫主** = `lifeGong.sevenZheng`
- **身宫主** = `bodyGong.sevenZheng`
- **命度主** = `lifeConstellatioin.sevenZheng`
- **身度主** = `bodyConstellation.sevenZheng`

### 2.8 化曜系统（已有）
**文件**: `lib/enums/enum_hua_yao.dart`

```dart
enum EnumGuoLaoHuaYao {
  Lu, An, Fu, Hao, Yin, Gui, Xing, Yin2, Qiu, Quan
  // 禄、暗、福、耗、荫、贵、刑、印、囚、权
}
// 含 calculateHuaYaoMapper(JiaZi) 方法
```

### 2.9 神煞系统（已有）
**文件**: `lib/enums/enum_hua_yao_shen_sha.dart`, `lib/domain/entities/models/di_zhi_shen_sha.dart`

- `EnumHuaYaoShenSha` - 化曜神煞（天干类、纳音类、纳甲类、命宫类、地支年类、地支月类）
- `JiaZiShenSha` - 空亡、孤虚、擎天、游奕
- `EnumBeforeTaiSuiShenSha`, `EnumAfterTaiSuiShenSha` - 太岁前后神煞

### 2.10 季节与昼夜（已有）
**文件**: `common/lib/enums/enum_four_seasons.dart`, `common/lib/enums/enum_day_night.dart`

```dart
enum FourSeasons { SPRING, SUMMER, AUTUMN, WINTER, EARTH }
static FourSeasons getFourSeason(DiZhi monthDiZhi)

enum EnumDayNight { day, night }
```

### 2.11 五星运行状态（已有）
**文件**: `lib/enums/enum_qi_zheng.dart`

```dart
enum FiveStarWalkingType { Fast, Normal, Slow, Stay, Retrograde }
// 速、常、迟、留、逆
```

---

## 三、格局判断输入参数设计

基于现有代码，设计 `GeJuInput` 输入模型：

### 3.1 输入参数表

| 参数名 | 类型 | 说明 | 数据来源 |
|-------|------|------|---------|
| **坐标体系** ||||
| `coordinateSystem` | CelestialCoordinateSystem | 黄道制/赤道制 | ZhouTianModel.systemType |
| **星曜位置** ||||
| `starsSet` | Set<ElevenStarsInfo> | 11颗星体信息集合 | 命盘计算 |
| `starRelationship` | StarToStarRelationshipModel | 星曜关系（同宫/对宫/三方等） | StarToStarRelationshipModel.create() |
| **命盘结构** ||||
| `bodyLifeModel` | BodyLifeModel | 身命模型 | BasePanelModel.bodyLifeModel |
| `destinyGongMapper` | Map<EnumDestinyTwelveGong, EnumTwelveGong> | 命理十二宫 | BasePanelModel.twelveGongMapper |
| **用神体系** ||||
| `starsFourTypeMapper` | Map<EnumStars, Map<EnumStarsFourType, Set<EnumStars>>> | 星曜恩难仇用 | EnumStarsFourType.getStarsFourTypeMapper() |
| `huaYaoMapper` | Map<EnumStars, List<HuaYaoItem>> | 化曜信息 | BasePanelModel.huaYaoItemMapper |
| **时间条件** ||||
| `season` | FourSeasons | 出生季节 | FourSeasons.getFourSeason(monthDiZhi) |
| `month` | DiZhi | 出生月支 | BasicPersonInfo |
| `isDayBirth` | bool | 昼生/夜生 | 由太阳位置判断 |
| `moonPhase` | EnumMoonPhases | 月相 | MoonInfo.moonPhase |
| **神煞** ||||
| `shenShaMapper` | Map<EnumTwelveGong, List<ShenSha>> | 各宫神煞 | BasePanelModel.shenShaItemMapper |
| `jiaZiShenSha` | JiaZiShenSha | 空亡孤虚等 | JiaZiShenSha(yearJiaZi) |
| **行限（可选）** ||||
| `currentXianGong` | EnumTwelveGong? | 当前行限宫位 | DaXianGongModel |
| `currentXianConstellation` | Enum28Constellations? | 当前行限星宿 | DaXianStarConstellationModel |

### 3.2 GeJuInput 类定义

```dart
class GeJuInput {
  // ========== 坐标体系 ==========
  final CelestialCoordinateSystem coordinateSystem;  // 黄道制/赤道制

  // ========== 星曜信息 ==========
  final Set<ElevenStarsInfo> starsSet;
  final StarToStarRelationshipModel starRelationship;

  // ========== 命盘结构 ==========
  final BodyLifeModel bodyLifeModel;
  final Map<EnumDestinyTwelveGong, EnumTwelveGong> destinyGongMapper;

  // ========== 用神体系 ==========
  final Map<EnumStars, Map<EnumStarsFourType, Set<EnumStars>>> starsFourTypeMapper;
  final Map<EnumStars, List<HuaYaoItem>> huaYaoMapper;

  // ========== 时间条件 ==========
  final FourSeasons season;
  final DiZhi monthZhi;
  final bool isDayBirth;
  final EnumMoonPhases moonPhase;

  // ========== 神煞 ==========
  final Map<EnumTwelveGong, List<ShenSha>> shenShaMapper;
  final JiaZiShenSha jiaZiShenSha;

  // ========== 行限（可选） ==========
  final EnumTwelveGong? currentXianGong;
  final Enum28Constellations? currentXianConstellation;
  final List<EnumStars>? xianPalaceStars;

  // ========== 便捷方法 ==========

  /// 获取指定星曜信息
  ElevenStarsInfo? getStar(EnumStars star);

  /// 命宫
  EnumTwelveGong get lifeGong => bodyLifeModel.lifeGong;

  /// 命度
  Enum28Constellations get lifeConstellation => bodyLifeModel.lifeConstellatioin;

  /// 命宫主
  EnumStars get lifeGongMaster => lifeGong.sevenZheng;

  /// 命度主
  EnumStars get lifeConstellationMaster => lifeConstellation.sevenZheng;

  /// 身宫主
  EnumStars get bodyGongMaster => bodyLifeModel.bodyGong.sevenZheng;

  /// 身度主
  EnumStars get bodyConstellationMaster => bodyLifeModel.bodyConstellation.sevenZheng;

  /// 获取星曜所在宫位
  EnumTwelveGong? getStarGong(EnumStars star);

  /// 获取星曜所在星宿
  Enum28Constellations? getStarConstellation(EnumStars star);

  /// 判断两星是否同宫
  bool isSameGong(EnumStars star1, EnumStars star2);

  /// 判断两星是否对照
  bool isOpposite(EnumStars star1, EnumStars star2);

  /// 判断星曜是否在空亡宫
  bool isStarInKongWang(EnumStars star);
}
```

---

## 四、格局规则JSON结构设计

### 4.1 规则文件结构

```json
{
  "version": "1.0",
  "category": "木星格局",
  "patterns": [
    {
      "id": "ri_bian_hong_xing",
      "name": "日边红杏",
      "source": "《果老星宗·星格贵贱总赋》",
      "description": "日邊紅杏，早占鰲頭。紅杏者木星也，木為官、恩、命、令等用者，與太陽同行。",
      "jiXiong": "吉",
      "geJuType": "gui",
      "scope": "natal",
      "coordinateSystem": null,
      "conditions": { ... }
    }
  ]
}
```

**coordinateSystem 字段说明**：
- `null` 或省略：使用命盘当前坐标体系
- `"ecliptic"`：仅在黄道制下判断
- `"equatorial"`：仅在赤道制下判断
- `"both"`：两种体系下均判断

### 4.2 条件类型定义

#### 星曜位置条件
```json
// 星曜在指定宫位（支持黄道宫名/赤道十二次名/地支名）
{ "type": "starInGong", "star": "Jupiter", "gongs": ["Yin", "Hai"] }
// 等效写法（赤道十二次）：
{ "type": "starInGong", "star": "Jupiter", "gongs": ["析木", "娵訾"] }

// 星曜在指定星宿
{ "type": "starInConstellation", "star": "Jupiter",
  "constellations": ["Xin", "Zhang", "Wei", "Bi"] }

// 星曜运行状态
{ "type": "starWalkingState", "star": "Jupiter",
  "states": ["Retrograde", "Stay"] }

// 星曜落空亡
{ "type": "starInKongWang", "star": "Jupiter" }
```

#### 星曜关系条件（使用现有 StarToStarRelationshipModel）
```json
// 同宫（查 sameGongMap）
{ "type": "sameGong", "stars": ["Jupiter", "Sun"] }

// 同宿（查 sameStarInnMap）
{ "type": "sameConstellation", "stars": ["Jupiter", "Moon"] }

// 同经（查 sameJingMap）
{ "type": "sameJing", "stars": ["Jupiter", "Mercury"] }

// 同络（查 sameLuoSet）
{ "type": "sameLuo", "stars": ["Jupiter", "Venus"] }

// 对宫（查 chongGongSet）
{ "type": "oppositeGong", "stars": ["Jupiter", "Moon"] }

// 三方（查 threeHeGongMap）
{ "type": "trineGong", "stars": ["Jupiter", "Sun"] }

// 四正（查 fourZhengMap）
{ "type": "squareGong", "stars": ["Jupiter", "Saturn"] }
```

#### 命盘结构条件
```json
// 命宫在指定宫位
{ "type": "lifeGongAt", "gongs": ["Zi", "Wu"] }

// 命度在指定星宿
{ "type": "lifeConstellationAt", "constellations": ["Dou", "Niu"] }

// 星曜守命（入命宫）
{ "type": "starGuardLife", "star": "Jupiter" }

// 星曜在命理宫（如疾厄、官禄等）
{ "type": "starInDestinyGong", "star": "Mars", "destinyGong": "JiE" }
```

#### 用神条件
```json
// 星曜为四主之一
{ "type": "starIsSiZhu", "star": "Jupiter",
  "siZhuTypes": ["lifeGongMaster", "bodyGongMaster", "lifeConstellationMaster", "bodyConstellationMaster"] }

// 星曜为另一星的恩/难/仇/用
{ "type": "starFourType", "star": "Jupiter", "targetStar": "Sun",
  "fourTypes": ["En", "Yong"] }

// 星曜带化曜
{ "type": "starHasHuaYao", "star": "Jupiter",
  "huaYaoTypes": ["Lu", "Gui"] }
```

#### 时间条件
```json
// 季节
{ "type": "seasonIs", "seasons": ["WINTER", "SPRING"] }

// 昼夜
{ "type": "isDayBirth", "value": true }

// 月相
{ "type": "moonPhaseIs", "phases": ["WangQian", "WangHou"] }

// 月份（地支）
{ "type": "monthIs", "months": ["YIN", "MAO", "CHEN"] }
```

#### 神煞条件
```json
// 星曜带神煞
{ "type": "starWithShenSha", "star": "Jupiter",
  "shenSha": ["GuKe", "YangRen"] }

// 宫位有神煞
{ "type": "gongHasShenSha", "gong": "lifeGong",
  "shenSha": ["MaYuan", "LuYin"] }
```

#### 行限条件
```json
// 行限到宫位
{ "type": "xianAtGong", "gong": "Wu" }

// 行限遇星
{ "type": "xianMeetStar", "star": "Jupiter" }
```

### 4.3 组合逻辑
```json
{
  "logic": "AND",
  "rules": [
    { "type": "sameGong", "stars": ["Jupiter", "Sun"] },
    {
      "logic": "OR",
      "rules": [
        { "type": "starIsSiZhu", "star": "Jupiter", "siZhuTypes": ["lifeGongMaster"] },
        { "type": "starFourType", "star": "Jupiter", "targetStar": "Sun", "fourTypes": ["En", "Yong"] }
      ]
    }
  ]
}
```

---

## 五、系统架构设计

### 5.1 新建文件结构

```
lib/domain/
├── entities/models/
│   └── ge_ju/
│       ├── ge_ju_input.dart         # 格局判断输入模型
│       ├── ge_ju_rule.dart          # 格局规则模型（扩展现有GeJuModel）
│       ├── ge_ju_condition.dart     # 条件基类及所有子类
│       └── ge_ju_result.dart        # 判断结果模型
├── managers/
│   └── ge_ju/
│       ├── ge_ju_rule_parser.dart   # JSON规则解析器
│       ├── ge_ju_input_builder.dart # 输入构建器
│       └── ge_ju_manager.dart       # 格局判断管理器
└── ...

assets/ge_ju/
├── mu_xing_ge_ju.json               # 木星格局（100格）
├── huo_xing_ge_ju.json              # 火星格局（90格）
├── tu_xing_ge_ju.json               # 土星格局（68格）
├── jin_xing_ge_ju.json              # 金星格局（101格）
├── shui_xing_ge_ju.json             # 水星格局（86格）
└── custom/                          # 用户自定义
    └── user_ge_ju.json
```

### 5.2 核心类设计

#### GeJuRule（扩展现有GeJuModel）
```dart
class GeJuRule extends GeJuModel {
  final String id;           // 唯一标识
  final String source;       // 出处
  final GeJuScope scope;     // natal/xingxian/both
  final GeJuCondition conditions;  // 判断条件

  factory GeJuRule.fromJson(Map<String, dynamic> json);
}

enum GeJuScope { natal, xingxian, both }
```

#### GeJuCondition（条件基类）
```dart
abstract class GeJuCondition {
  bool evaluate(GeJuInput input);
  String describe();  // 返回条件的人类可读描述
  factory GeJuCondition.fromJson(Map<String, dynamic> json);
}

// 逻辑组合
class AndCondition extends GeJuCondition { ... }
class OrCondition extends GeJuCondition { ... }
class NotCondition extends GeJuCondition { ... }

// 具体条件（约20种）
class StarInGongCondition extends GeJuCondition { ... }
class SameGongCondition extends GeJuCondition { ... }
class OppositeGongCondition extends GeJuCondition { ... }
class TrineGongCondition extends GeJuCondition { ... }
class SquareGongCondition extends GeJuCondition { ... }
class LifeGongAtCondition extends GeJuCondition { ... }
class StarIsSiZhuCondition extends GeJuCondition { ... }
class StarFourTypeCondition extends GeJuCondition { ... }
class SeasonIsCondition extends GeJuCondition { ... }
class IsDayBirthCondition extends GeJuCondition { ... }
// ...
```

#### GeJuResult
```dart
class GeJuResult {
  final GeJuRule rule;
  final bool matched;
  final List<String> matchedConditionDescriptions;
}

class GeJuEvaluationReport {
  final List<GeJuResult> matchedPatterns;
  final int totalEvaluated;
  final DateTime evaluatedAt;

  List<GeJuResult> get jiPatterns;    // 吉格
  List<GeJuResult> get xiongPatterns; // 凶格
  List<GeJuResult> get guiPatterns;   // 贵格
  List<GeJuResult> get fuPatterns;    // 富格
}
```

#### GeJuManager
```dart
class GeJuManager {
  final List<GeJuRule> _rules = [];

  Future<void> loadRulesFromAssets();
  Future<void> loadRulesFromFile(String path);

  GeJuEvaluationReport evaluateNatal(GeJuInput input);
  GeJuEvaluationReport evaluateXingXian(GeJuInput input);
  GeJuEvaluationReport evaluateAll(GeJuInput input);
}
```

#### GeJuInputBuilder
```dart
class GeJuInputBuilder {
  /// 从命盘构建输入
  static GeJuInput buildFromPanel(
    Set<ElevenStarsInfo> starsSet,
    BodyLifeModel bodyLifeModel,
    Map<EnumDestinyTwelveGong, EnumTwelveGong> destinyGongMapper,
    Map<EnumStars, List<HuaYaoItem>> huaYaoMapper,
    Map<EnumTwelveGong, List<ShenSha>> shenShaMapper,
    BasicPersonInfo personInfo,
    EnumMoonPhases moonPhase,
  );

  /// 从行限扩展输入
  static GeJuInput extendForXingXian(
    GeJuInput natalInput,
    DaXianGongModel xianModel,
  );
}
```

---

## 六、实现步骤

### 第一阶段：基础框架
1. [ ] 创建 `ge_ju_input.dart` - GeJuInput 类
2. [ ] 创建 `ge_ju_rule.dart` - GeJuRule 类（扩展 GeJuModel）
3. [ ] 创建 `ge_ju_condition.dart` - 条件基类和逻辑组合类
4. [ ] 创建 `ge_ju_rule_parser.dart` - JSON 解析器

### 第二阶段：条件实现
5. [ ] 实现星曜位置条件（StarInGongCondition, StarInConstellationCondition, StarWalkingStateCondition, StarInKongWangCondition）
6. [ ] 实现星曜关系条件（SameGongCondition, SameConstellationCondition, OppositeGongCondition, TrineGongCondition, SquareGongCondition）
7. [ ] 实现命盘结构条件（LifeGongAtCondition, LifeConstellationAtCondition, StarGuardLifeCondition, StarInDestinyGongCondition）
8. [ ] 实现用神条件（StarIsSiZhuCondition, StarFourTypeCondition, StarHasHuaYaoCondition）
9. [ ] 实现时间条件（SeasonIsCondition, IsDayBirthCondition, MoonPhaseIsCondition, MonthIsCondition）
10. [ ] 实现神煞条件（StarWithShenShaCondition, GongHasShenShaCondition）
11. [ ] 实现行限条件（XianAtGongCondition, XianMeetStarCondition）

### 第三阶段：规则数据
12. [ ] 将 ge_ju_1.txt 中的木星格局转换为 JSON
13. [ ] 转换火星格局
14. [ ] 转换土星格局
15. [ ] 转换金星格局
16. [ ] 转换水星格局

### 第四阶段：管理器与集成
17. [ ] 创建 `ge_ju_input_builder.dart`
18. [ ] 创建 `ge_ju_manager.dart`
19. [ ] 创建 `ge_ju_result.dart`
20. [ ] 集成到命盘计算流程

### 第五阶段：用户自定义
21. [ ] 支持从文件系统加载自定义规则
22. [ ] 规则的增删改查接口

---

## 七、关键文件路径汇总

### 新建文件
| 文件路径 | 说明 |
|---------|------|
| `lib/domain/entities/models/ge_ju/ge_ju_input.dart` | 格局判断输入 |
| `lib/domain/entities/models/ge_ju/ge_ju_rule.dart` | 格局规则（扩展GeJuModel） |
| `lib/domain/entities/models/ge_ju/ge_ju_condition.dart` | 条件类 |
| `lib/domain/entities/models/ge_ju/ge_ju_result.dart` | 结果类 |
| `lib/domain/managers/ge_ju/ge_ju_rule_parser.dart` | JSON解析器 |
| `lib/domain/managers/ge_ju/ge_ju_input_builder.dart` | 输入构建器 |
| `lib/domain/managers/ge_ju/ge_ju_manager.dart` | 格局管理器 |
| `assets/ge_ju/*.json` | 格局规则数据 |

### 复用现有文件
| 文件路径 | 复用内容 |
|---------|---------|
| `lib/domain/entities/models/ge_ju_model.dart` | GeJuModel, GeJuType |
| `lib/domain/entities/models/star_to_star_relationship_model.dart` | 星曜关系计算 |
| `lib/domain/entities/models/body_life_model.dart` | 身命模型 |
| `lib/enums/enum_stars_four_type.dart` | 恩难仇用 |
| `lib/enums/enum_star_position_status.dart` | 庙旺状态 |
| `lib/enums/enum_hua_yao.dart` | 化曜 |
| `lib/enums/enum_twelve_gong.dart` | 宫位与宫主 |
| `common/lib/enums/enum_four_seasons.dart` | 季节 |
| `common/lib/enums/enum_day_night.dart` | 昼夜 |

---

## 八、格局示例JSON

### 示例1：日边红杏
```json
{
  "id": "ri_bian_hong_xing",
  "name": "日边红杏",
  "source": "《果老星宗·星格贵贱总赋》",
  "description": "日邊紅杏，早占鰲頭。紅杏者木星也，木為官、恩、命、令等用者，與太陽同行。",
  "jiXiong": "吉",
  "geJuType": "gui",
  "scope": "natal",
  "conditions": {
    "logic": "AND",
    "rules": [
      { "type": "sameGong", "stars": ["Jupiter", "Sun"] },
      {
        "logic": "OR",
        "rules": [
          { "type": "starIsSiZhu", "star": "Jupiter", "siZhuTypes": ["lifeGongMaster", "lifeConstellationMaster"] },
          { "type": "starFourType", "star": "Jupiter", "targetStar": "Sun", "fourTypes": ["En", "Yong"] }
        ]
      }
    ]
  }
}
```

### 示例2：木临真垣
```json
{
  "id": "mu_lin_zhen_yuan",
  "name": "木临真垣",
  "source": "《果老星宗·躔度赋》",
  "description": "木臨寅亥是真垣，精神百倍",
  "jiXiong": "吉",
  "geJuType": "gui",
  "scope": "natal",
  "conditions": {
    "type": "starInGong",
    "star": "Jupiter",
    "gongs": ["Yin", "Hai"]
  }
}
```

### 示例3：雪压寒梅（复杂条件）
```json
{
  "id": "xue_ya_han_mei",
  "name": "雪压寒梅",
  "source": "《果老星宗·星格贵贱总赋》",
  "description": "雪壓寒梅，終身餓莩。寒梅者木星也，木水同躔，夜生冬值，倘或在子丑地及水宮、水度者亦是。",
  "jiXiong": "凶",
  "geJuType": "pin",
  "scope": "natal",
  "conditions": {
    "logic": "AND",
    "rules": [
      { "type": "sameGong", "stars": ["Jupiter", "Mercury"] },
      { "type": "isDayBirth", "value": false },
      { "type": "seasonIs", "seasons": ["WINTER"] },
      {
        "logic": "OR",
        "rules": [
          { "type": "starInGong", "star": "Jupiter", "gongs": ["Zi", "Chou"] },
          { "type": "starInGong", "star": "Jupiter", "gongs": ["Si", "Shen"] },
          { "type": "starInConstellation", "star": "Jupiter",
            "constellations": ["Ji", "Dou", "Nv", "Xu", "Wei", "Shi", "Bi"] }
        ]
      }
    ]
  }
}
```

---

## 九、格局文本转JSON方案

### 9.1 文本格式分析

每个格局的文本结构：
```
{序号}.{格局名}：
《{书名}·{章节}》：{格言}。[{条件解释}]
{可选：双鱼按：注释}
```

### 9.2 转换策略：三层处理

#### 层级1：自动解析元数据（100%自动化）
提取：格局ID、名称、出处、描述、条件原文

#### 层级2：关键词映射（80%自动化）
定义星曜、宫位、星宿、条件模式的关键词映射表

#### 层级3：人工审核（需人工确认）
生成带置信度标记的JSON模板，人工审核复杂条件

### 9.3 关键词映射表

```dart
/// 星曜关键词映射
const Map<String, dynamic> starKeywords = {
  // 七政
  '木': 'Jupiter', '木星': 'Jupiter',
  '火': 'Mars', '火星': 'Mars', '熒惑': 'Mars',
  '土': 'Saturn', '土星': 'Saturn', '鎮星': 'Saturn',
  '金': 'Venus', '金星': 'Venus', '太白': 'Venus',
  '水': 'Mercury', '水星': 'Mercury', '辰星': 'Mercury',
  '日': 'Sun', '太陽': 'Sun',
  '月': 'Moon', '太陰': 'Moon',
  // 四余
  '紫氣': 'Qi', '氣': 'Qi',
  '月孛': 'Bei', '孛': 'Bei',
  '羅睺': 'Luo', '羅': 'Luo',
  '計都': 'Ji', '計': 'Ji',
  // 组合
  '木氣': ['Jupiter', 'Qi'],
  '火羅': ['Mars', 'Luo'],
  '土計': ['Saturn', 'Ji'],
  '金水': ['Venus', 'Mercury'],
  '水孛': ['Mercury', 'Bei'],
};

/// 宫位关键词映射
const Map<String, String> gongKeywords = {
  // 地支名
  '子': 'Zi', '丑': 'Chou', '寅': 'Yin', '卯': 'Mao',
  '辰': 'Chen', '巳': 'Si', '午': 'Wu', '未': 'Wei',
  '申': 'Shen', '酉': 'You', '戌': 'Xu', '亥': 'Hai',
  // 黄道宫别名
  '寶瓶': 'Zi', '磨羯': 'Chou', '人馬': 'Yin',
  '天蝎': 'Mao', '天秤': 'Chen', '雙女': 'Si',
  '獅子': 'Wu', '巨蟹': 'Wei', '雙子': 'Shen',
  '金牛': 'You', '白羊': 'Xu', '雙魚': 'Hai',
  // 赤道十二次名
  '玄枵': 'Zi', '星紀': 'Chou', '析木': 'Yin',
  '大火': 'Mao', '壽星': 'Chen', '鶉尾': 'Si',
  '鶉火': 'Wu', '鶉首': 'Wei', '實沈': 'Shen',
  '大梁': 'You', '降婁': 'Xu', '娵訾': 'Hai',
  // 方位
  '東方': ['Yin', 'Mao', 'Chen'],
  '南方': ['Si', 'Wu', 'Wei'],
  '西方': ['Shen', 'You', 'Xu'],
  '北方': ['Hai', 'Zi', 'Chou'],
};

/// 星宿关键词映射
const Map<String, String> constellationKeywords = {
  '角': 'Jiao', '亢': 'Kang', '氐': 'Di', '房': 'Fang',
  '心': 'Xin', '尾': 'Wei', '箕': 'Ji',
  '斗': 'Dou', '牛': 'Niu', '女': 'Nv', '虛': 'Xu',
  '危': 'Wei', '室': 'Shi', '壁': 'Bi',
  '奎': 'Kui', '婁': 'Lou', '胃': 'Wei', '昴': 'Mao',
  '畢': 'Bi', '觜': 'Zi', '參': 'Shen',
  '井': 'Jing', '鬼': 'Gui', '柳': 'Liu', '星': 'Xing',
  '張': 'Zhang', '翼': 'Yi', '軫': 'Zhen',
};

/// 条件模式映射
const List<ConditionPattern> conditionPatterns = [
  // 同宫/同行关系
  ConditionPattern(r'(.+)與(.+)同宮', 'sameGong'),
  ConditionPattern(r'(.+)同躔', 'sameGong'),
  ConditionPattern(r'(.+)同行', 'sameGong'),
  ConditionPattern(r'(.+)會(.+)', 'sameGong'),

  // 星曜在宫位
  ConditionPattern(r'(.+)在(.+)宮', 'starInGong'),
  ConditionPattern(r'(.+)居(.+)', 'starInGong'),
  ConditionPattern(r'(.+)臨(.+)', 'starInGong'),
  ConditionPattern(r'(.+)入(.+)', 'starInGong'),

  // 星曜在星宿
  ConditionPattern(r'(.+)躔(.+)度', 'starInConstellation'),
  ConditionPattern(r'在(.+)度', 'starInConstellation'),

  // 季节
  ConditionPattern(r'春生', 'seasonIs:SPRING'),
  ConditionPattern(r'夏生', 'seasonIs:SUMMER'),
  ConditionPattern(r'秋生', 'seasonIs:AUTUMN'),
  ConditionPattern(r'冬生', 'seasonIs:WINTER'),
  ConditionPattern(r'冬值', 'seasonIs:WINTER'),

  // 昼夜
  ConditionPattern(r'晝生', 'isDayBirth:true'),
  ConditionPattern(r'夜生', 'isDayBirth:false'),
  ConditionPattern(r'逢晝', 'isDayBirth:true'),
  ConditionPattern(r'逢夜', 'isDayBirth:false'),

  // 用神
  ConditionPattern(r'為命主', 'starIsSiZhu:lifeGongMaster'),
  ConditionPattern(r'為用神', 'starIsSiZhu:lifeGongMaster'),
  ConditionPattern(r'為官', 'starFourType:Yong'),
  ConditionPattern(r'為恩', 'starFourType:En'),
  ConditionPattern(r'為難', 'starFourType:Nan'),
  ConditionPattern(r'為仇', 'starFourType:Chou'),

  // 行限
  ConditionPattern(r'行限(.+)宮', 'xianAtGong'),
  ConditionPattern(r'限到(.+)', 'xianAtGong'),
];
```

### 9.4 转换工具类

```dart
class GeJuTextParser {
  /// 解析单个格局文本
  static GeJuParseResult parse(String text) {
    final result = GeJuParseResult();

    // 1. 提取格局名称
    final nameMatch = RegExp(r'(\d+)[.．](.+)[：:]').firstMatch(text);
    if (nameMatch != null) {
      result.index = int.parse(nameMatch.group(1)!);
      result.name = nameMatch.group(2)!.trim();
    }

    // 2. 提取出处
    final sourceMatch = RegExp(r'《(.+?)》').firstMatch(text);
    if (sourceMatch != null) {
      result.source = sourceMatch.group(1)!;
    }

    // 3. 提取描述（出处后到方括号前）
    final descMatch = RegExp(r'》[：:]\s*(.+?)[。\[]').firstMatch(text);
    if (descMatch != null) {
      result.description = descMatch.group(1)!;
    }

    // 4. 提取条件原文（方括号内）
    final conditionMatch = RegExp(r'\[(.+?)\]').firstMatch(text);
    if (conditionMatch != null) {
      result.rawCondition = conditionMatch.group(1)!;
      // 尝试解析条件
      result.parsedConditions = _parseConditions(result.rawCondition);
    }

    // 5. 判断吉凶
    result.jiXiong = _inferJiXiong(result.description);
    result.geJuType = _inferGeJuType(result.description);

    return result;
  }

  /// 解析条件文本
  static List<ParsedCondition> _parseConditions(String raw) {
    final conditions = <ParsedCondition>[];

    for (final pattern in conditionPatterns) {
      final match = RegExp(pattern.regex).firstMatch(raw);
      if (match != null) {
        conditions.add(ParsedCondition(
          type: pattern.conditionType,
          raw: match.group(0)!,
          groups: [for (int i = 1; i <= match.groupCount; i++) match.group(i)],
          confidence: 0.8,
        ));
      }
    }

    return conditions;
  }

  /// 推断吉凶
  static JiXiongEnum _inferJiXiong(String desc) {
    final jiKeywords = ['貴', '榮', '福', '吉', '美', '佳', '富'];
    final xiongKeywords = ['凶', '災', '禍', '貧', '賤', '夭', '困'];

    for (final k in jiKeywords) {
      if (desc.contains(k)) return JiXiongEnum.ji;
    }
    for (final k in xiongKeywords) {
      if (desc.contains(k)) return JiXiongEnum.xiong;
    }
    return JiXiongEnum.zhong;
  }

  /// 推断格局类型
  static GeJuType _inferGeJuType(String desc) {
    if (desc.contains('貴') || desc.contains('官')) return GeJuType.gui;
    if (desc.contains('富') || desc.contains('財')) return GeJuType.fu;
    if (desc.contains('貧')) return GeJuType.pin;
    if (desc.contains('賤')) return GeJuType.jian;
    if (desc.contains('夭')) return GeJuType.yao;
    if (desc.contains('壽')) return GeJuType.shou;
    if (desc.contains('賢') || desc.contains('學')) return GeJuType.xian;
    if (desc.contains('愚')) return GeJuType.yu;
    return GeJuType.gui; // 默认
  }
}

class GeJuParseResult {
  int? index;
  String? name;
  String? source;
  String? description;
  String? rawCondition;
  List<ParsedCondition> parsedConditions = [];
  JiXiongEnum? jiXiong;
  GeJuType? geJuType;

  /// 转换为JSON（带审核标记）
  Map<String, dynamic> toJsonWithReview() {
    return {
      'id': _generateId(),
      'name': name,
      'source': source,
      'description': description,
      'rawCondition': rawCondition,
      'jiXiong': jiXiong?.name,
      'geJuType': geJuType?.name,
      'scope': 'natal',
      '_autoGenerated': true,
      '_needsReview': parsedConditions.where((c) => c.confidence < 0.9).map((c) => c.raw).toList(),
      'conditions': _buildConditions(),
    };
  }

  String _generateId() {
    // 将中文名转为拼音ID
    return name?.toLowerCase().replaceAll(' ', '_') ?? 'unknown';
  }

  Map<String, dynamic>? _buildConditions() {
    if (parsedConditions.isEmpty) return null;
    if (parsedConditions.length == 1) {
      return parsedConditions.first.toJson();
    }
    return {
      'logic': 'AND',
      'rules': parsedConditions.map((c) => c.toJson()).toList(),
    };
  }
}
```

### 9.5 转换工作流程

```
1. 运行自动解析器 → 生成 draft/*.json
2. 人工审核 draft 文件：
   - 检查 _needsReview 标记的条件
   - 补充复杂条件
   - 确认吉凶和格局类型
3. 移除审核标记 → 生成 final/*.json
4. 单元测试验证
```

### 9.6 示例：自动解析结果

输入：
```
1.日边红杏：
《果老星宗·星格贵贱总赋》：日邊紅杏，早占鰲頭。[紅杏者木星也，木為官、恩、命、令等用者，與太陽同行。]
```

自动解析输出：
```json
{
  "id": "ri_bian_hong_xing",
  "name": "日边红杏",
  "source": "《果老星宗·星格贵贱总赋》",
  "description": "日邊紅杏，早占鰲頭",
  "rawCondition": "紅杏者木星也，木為官、恩、命、令等用者，與太陽同行。",
  "jiXiong": "吉",
  "geJuType": "gui",
  "scope": "natal",
  "_autoGenerated": true,
  "_needsReview": ["木為官、恩、命、令等用者"],
  "conditions": {
    "logic": "AND",
    "rules": [
      {
        "type": "sameGong",
        "stars": ["Jupiter", "Sun"],
        "_raw": "與太陽同行",
        "_confidence": 0.95
      },
      {
        "type": "starIsSiZhu",
        "star": "Jupiter",
        "siZhuTypes": ["lifeGongMaster"],
        "_raw": "木為官、恩、命、令等用者",
        "_confidence": 0.6,
        "_note": "需确认：原文提到'官、恩、命、令'多种用神"
      }
    ]
  }
}
```

人工审核后：
```json
{
  "id": "ri_bian_hong_xing",
  "name": "日边红杏",
  "source": "《果老星宗·星格贵贱总赋》",
  "description": "日邊紅杏，早占鰲頭",
  "jiXiong": "吉",
  "geJuType": "gui",
  "scope": "natal",
  "conditions": {
    "logic": "AND",
    "rules": [
      { "type": "sameGong", "stars": ["Jupiter", "Sun"] },
      {
        "logic": "OR",
        "rules": [
          { "type": "starIsSiZhu", "star": "Jupiter", "siZhuTypes": ["lifeGongMaster"] },
          { "type": "starFourType", "star": "Jupiter", "targetStar": "Sun", "fourTypes": ["En", "Yong"] }
        ]
      }
    ]
  }
}
```

---

## 十、验证方案

### 单元测试
- 测试每种 Condition 的 evaluate() 方法
- 测试 AND/OR/NOT 组合逻辑
- 测试 JSON 解析和序列化

### 集成测试
- 使用已知命盘验证格局判断结果
- 对比古籍中的示例命盘

### 测试用例示例
```dart
test('日边红杏格局匹配', () {
  final input = GeJuInput(
    starsSet: {...},  // 木星、太阳同在午宫
    bodyLifeModel: BodyLifeModel(lifeGongInfo: GongDegree(gong: EnumTwelveGong.Wu, ...)),
    ...
  );
  final rule = GeJuRule.fromJson(riHianHongXingJson);
  expect(rule.conditions.evaluate(input), isTrue);
});
```
