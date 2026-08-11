import 'package:metaphysics_core/enums.dart';
import 'package:qizhengsiyu/enums/enum_twelve_gong.dart';
import 'package:qizhengsiyu/domain/entities/models/ge_ju/ge_ju_condition.dart';
import 'package:qizhengsiyu/domain/entities/models/ge_ju/ge_ju_input.dart';

/// 数据超前于模型的条件类型补全（2026-08-10）。
///
/// 源 JSON（ge_ju_rules_document）含以下 10 种条件类型，旧工厂全部
/// 抛 UnimplementedError，导致 11 条格局无法解析（被 shell 适配器容错跳过）。
/// 本次补全：fromJson/describe/toJson 完整实现 + 工厂 case；
/// evaluate 能基于 GeJuInput 判定的实现（YearBranch/JupiterSeasonPosition），
/// 其余语义条件（日月调和/水火平衡等）保守返回 false（不误命中），
/// 精确判据待命理业务侧确认后补齐。

/// 地支中文名 → EnumTwelveGong 匹配：name getter 直接返回中文（如「巳」）。
const List<String> _kGongCnNames = [
  '子', '丑', '寅', '卯', '辰', '巳', '午', '未', '申', '酉', '戌', '亥',
];

/// 年支条件：命主年支为指定地支（如「寅年」）。
class YearBranchCondition extends GeJuCondition {
  final DiZhi branch;

  YearBranchCondition(this.branch);

  @override
  bool evaluate(GeJuInput input) => input.yearJiaZi.zhi == branch;

  @override
  String describe() => '年支${branch.name}';

  factory YearBranchCondition.fromJson(Map<String, dynamic> json) {
    return YearBranchCondition(
      DiZhi.values.firstWhere(
        (v) => v.name == json['branch'] || v.toString().split('.').last == json['branch'],
      ),
    );
  }

  @override
  Map<String, dynamic> toJson() => {'type': 'yearBranch', 'branch': branch.name};
}

/// 木星季节位置条件：生于指定季节且木星（岁星）落于指定地支宫。
class JupiterSeasonPositionCondition extends GeJuCondition {
  final FourSeasons season;
  final List<EnumTwelveGong> positions;

  JupiterSeasonPositionCondition(this.season, this.positions);

  @override
  bool evaluate(GeJuInput input) {
    if (input.season != season) return false;
    for (final star in input.starsSet) {
      if (star.star == EnumStars.Jupiter && positions.contains(star.enterInfo.gong)) {
        return true;
      }
    }
    return false;
  }

  @override
  String describe() => '${season.name}木星落${positions.map((g) => g.name).join('/')}';

  factory JupiterSeasonPositionCondition.fromJson(Map<String, dynamic> json) {
    final seasonInput = (json['season'] as String).toLowerCase();
    final season = FourSeasons.values.firstWhere(
      (v) =>
          v.name == json['season'] ||
          v.name.toLowerCase() == seasonInput ||
          v.toString().split('.').last.toLowerCase() == seasonInput,
    );
    final positions = (json['positions'] as List)
        .map((e) => EnumTwelveGong.values.firstWhere((g) => g.name == e))
        .toList();
    return JupiterSeasonPositionCondition(season, positions);
  }

  @override
  Map<String, dynamic> toJson() => {
        'type': 'jupiterSeasonPosition',
        'season': season.name,
        'positions': positions.map((g) => g.name).toList(),
      };
}

/// 宫度条件：某命理宫位于指定星宿度数（如「命宫尾度」）。
///
/// ⚠️ GeJuInput 暂无命宫宿度字段，evaluate 保守返回 false（不误命中）；
/// 待计算侧提供 `命理宫→宿度` 数据后补齐判定。
class GongDegreeCondition extends GeJuCondition {
  final String gong; // "Life" / "Spouse" / "Travel"
  final String degree; // "尾度" / "斗度" / "未宫" / "角度"

  GongDegreeCondition(this.gong, this.degree);

  @override
  bool evaluate(GeJuInput input) {
    // TODO(ge-ju): 需 input 提供命理宫对应星宿度（如尾宿度）后实现。
    return false;
  }

  @override
  String describe() => '$gong位于$degree';

  factory GongDegreeCondition.fromJson(Map<String, dynamic> json) {
    return GongDegreeCondition(json['gong'] as String, json['degree'] as String);
  }

  @override
  Map<String, dynamic> toJson() => {'type': 'gongDegree', 'gong': gong, 'degree': degree};
}

/// 身命和谐：身宫与命宫关系和谐。
///
/// ⚠️ 精确判据（身命同宫/六合等）待命理业务确认，evaluate 保守 false。
class BodyLifeHarmonyCondition extends GeJuCondition {
  BodyLifeHarmonyCondition();

  @override
  bool evaluate(GeJuInput input) {
    // TODO(ge-ju): 基于 input.bodyLifeModel 实现身命关系判据。
    return false;
  }

  @override
  String describe() => '身命和谐';

  factory BodyLifeHarmonyCondition.fromJson(Map<String, dynamic> json) =>
      BodyLifeHarmonyCondition();

  @override
  Map<String, dynamic> toJson() => {'type': 'bodyLifeHarmony'};
}

/// 日月调和：太阳与月亮的关系（同宫/六合/和照等）。
///
/// ⚠️ 精确判据待命理业务确认，evaluate 保守 false。
class SunMoonHarmonyCondition extends GeJuCondition {
  SunMoonHarmonyCondition();

  @override
  bool evaluate(GeJuInput input) {
    // TODO(ge-ju): 基于 input.starsSet 中 Sun/Moon 的宫位关系实现。
    return false;
  }

  @override
  String describe() => '日月调和';

  factory SunMoonHarmonyCondition.fromJson(Map<String, dynamic> json) =>
      SunMoonHarmonyCondition();

  @override
  Map<String, dynamic> toJson() => {'type': 'sunMoonHarmony'};
}

/// 水火平衡：水星与火星的关系。
///
/// ⚠️ 精确判据待命理业务确认，evaluate 保守 false。
class WaterFireBalanceCondition extends GeJuCondition {
  WaterFireBalanceCondition();

  @override
  bool evaluate(GeJuInput input) {
    // TODO(ge-ju): 基于 input.starsSet 中 Water/Mars 的关系实现。
    return false;
  }

  @override
  String describe() => '水火平衡';

  factory WaterFireBalanceCondition.fromJson(Map<String, dynamic> json) =>
      WaterFireBalanceCondition();

  @override
  Map<String, dynamic> toJson() => {'type': 'waterFireBalance'};
}

/// 五星汇聚：金木水火土五星聚于一宫/一宿。
///
/// ⚠️ 精确判据待命理业务确认，evaluate 保守 false。
class FivePlanetsAlignmentCondition extends GeJuCondition {
  FivePlanetsAlignmentCondition();

  @override
  bool evaluate(GeJuInput input) {
    // TODO(ge-ju): 基于 input.starsSet 判断五星是否汇聚。
    return false;
  }

  @override
  String describe() => '五星汇聚';

  factory FivePlanetsAlignmentCondition.fromJson(Map<String, dynamic> json) =>
      FivePlanetsAlignmentCondition();

  @override
  Map<String, dynamic> toJson() => {'type': 'fivePlanetsAlignment'};
}

/// 七政入宫：日、月、五星（七政）落于特定宫位组合。
///
/// ⚠️ 精确判据待命理业务确认，evaluate 保守 false。
class SevenPlanetsInPalaceCondition extends GeJuCondition {
  SevenPlanetsInPalaceCondition();

  @override
  bool evaluate(GeJuInput input) {
    // TODO(ge-ju): 基于 input.starsSet 判断七政落宫组合。
    return false;
  }

  @override
  String describe() => '七政入宫';

  factory SevenPlanetsInPalaceCondition.fromJson(Map<String, dynamic> json) =>
      SevenPlanetsInPalaceCondition();

  @override
  Map<String, dynamic> toJson() => {'type': 'sevenPlanetsInPalace'};
}

/// 命主得地：命主星落于庙旺/得地宫位。
///
/// ⚠️ 精确判据待命理业务确认，evaluate 保守 false。
class LifeLordInFavorablePlaceCondition extends GeJuCondition {
  LifeLordInFavorablePlaceCondition();

  @override
  bool evaluate(GeJuInput input) {
    // TODO(ge-ju): 基于 input.starGongStatusMapper 判断命主星状态。
    return false;
  }

  @override
  String describe() => '命主得地';

  factory LifeLordInFavorablePlaceCondition.fromJson(Map<String, dynamic> json) =>
      LifeLordInFavorablePlaceCondition();

  @override
  Map<String, dynamic> toJson() => {'type': 'lifeLordInFavorablePlace'};
}

/// 官星格局：官禄主星呈现特定格局。
///
/// ⚠️ 精确判据待命理业务确认，evaluate 保守 false。
class OfficialStarPatternsCondition extends GeJuCondition {
  OfficialStarPatternsCondition();

  @override
  bool evaluate(GeJuInput input) {
    // TODO(ge-ju): 基于 input 判断官禄主星格局。
    return false;
  }

  @override
  String describe() => '官星格局';

  factory OfficialStarPatternsCondition.fromJson(Map<String, dynamic> json) =>
      OfficialStarPatternsCondition();

  @override
  Map<String, dynamic> toJson() => {'type': 'officialStarPatterns'};
}
