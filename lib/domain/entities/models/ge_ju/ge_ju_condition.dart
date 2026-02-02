import 'package:json_annotation/json_annotation.dart';
import 'ge_ju_input.dart';
import 'conditions/position_conditions.dart';
import 'conditions/relationship_conditions.dart';
import 'conditions/structure_conditions.dart';
import 'conditions/yong_shen_conditions.dart';
import 'conditions/time_conditions.dart';
import 'conditions/gong_status_conditions.dart';
import 'conditions/shen_sha_conditions.dart';
import 'conditions/xian_conditions.dart';

// 移除 part 引用，因为这是基类文件，子类可能很多，建议手动实现 fromJson 分发或使用 parser
// 但为了简单起见，可以把逻辑条件放在这里

/// 格局条件基类
abstract class GeJuCondition {
  /// 评估当前条件是否满足
  bool evaluate(GeJuInput input);

  /// 返回条件的人类可读描述
  String describe();

  Map<String, dynamic> toJson();

  GeJuCondition();

  /// JSON 反序列化工厂
  /// 实际的解析逻辑通常由 GeJuRuleParser 处理，或者在这里做简单的 type 分发
  /// 为了避免循环依赖和复杂性，这里暂时定义接口，具体实现留给 Parser 或由具体子类如 And/Or 实现 fromJson
  factory GeJuCondition.fromJson(Map<String, dynamic> json) {
    // 简单的类型分发，后续会有更多具体 Condition
    final type = json['type'] as String?;
    switch (type) {
      case 'and':
        return AndCondition.fromJson(json);
      case 'or':
        return OrCondition.fromJson(json);
      case 'not':
        return NotCondition.fromJson(json);
      // Position Conditions
      case 'starInGong':
        return StarInGongCondition.fromJson(json);
      case 'starInConstellation':
        return StarInConstellationCondition.fromJson(json);
      case 'starWalkingState':
        return StarWalkingStateCondition.fromJson(json);
      case 'starInKongWang':
        return StarInKongWangCondition.fromJson(json);
      // Relationship Conditions
      case 'sameGong':
        return SameGongCondition.fromJson(json);
      case 'sameConstellation':
        return SameConstellationCondition.fromJson(json);
      case 'oppositeGong':
        return OppositeGongCondition.fromJson(json);
      case 'trineGong':
        return TrineGongCondition.fromJson(json);
      case 'squareGong':
        return SquareGongCondition.fromJson(json);
      case 'sameJing':
        return SameJingCondition.fromJson(json);
      case 'sameLuo':
        return SameLuoCondition.fromJson(json);
      // Structure Conditions
      case 'lifeGongAt':
        return LifeGongAtCondition.fromJson(json);
      case 'lifeConstellationAt':
        return LifeConstellationAtCondition.fromJson(json);
      case 'starGuardLife':
        return StarGuardLifeCondition.fromJson(json);
      case 'starInDestinyGong':
        return StarInDestinyGongCondition.fromJson(json);
      // YongShen Conditions
      case 'starIsSiZhu':
        return StarIsSiZhuCondition.fromJson(json);
      case 'starFourType':
        return StarFourTypeCondition.fromJson(json);
      case 'starHasHuaYao':
        return StarHasHuaYaoCondition.fromJson(json);
      // Time Conditions
      case 'seasonIs':
        return SeasonIsCondition.fromJson(json);
      case 'isDayBirth':
        return IsDayBirthCondition.fromJson(json);
      case 'moonPhaseIs':
        return MoonPhaseIsCondition.fromJson(json);
      case 'monthIs':
        return MonthIsCondition.fromJson(json);
      // Status Condition
      case 'starGongStatus':
        return StarGongStatusCondition.fromJson(json);
      // ShenSha Conditions
      case 'starWithShenSha':
        return StarWithShenShaCondition.fromJson(json);
      case 'gongHasShenSha':
        return GongHasShenShaCondition.fromJson(json);
      // Xian Conditions
      case 'xianAtGong':
        return XianAtGongCondition.fromJson(json);
      case 'xianAtConstellation':
        return XianAtConstellationCondition.fromJson(json);
      case 'xianMeetStar':
        return XianMeetStarCondition.fromJson(json);
      // 其他具体条件将在各自文件中注册或在此扩展
      // 实际上，为了避免单文件过大，通常建议使用注册表模式，或者 Parser 负责实例化
      // 这里暂时抛出未实现，由 Parser 统一处理，或者后续补充完整 case
      default:
        // 如果是具体业务条件，可能需要通过 Parser 注册的映射来创建
        // 暂时抛出异常或返回特定空实现
        throw UnimplementedError(
            "Condition type '$type' is not supported in base factory yet.");
    }
  }
}

/// 逻辑与条件 (AND)
class AndCondition extends GeJuCondition {
  final List<GeJuCondition> conditions;

  AndCondition(this.conditions);

  @override
  bool evaluate(GeJuInput input) {
    for (var condition in conditions) {
      if (!condition.evaluate(input)) {
        return false;
      }
    }
    return true;
  }

  @override
  String describe() {
    return "(${conditions.map((c) => c.describe()).join(' 且 ')})";
  }

  factory AndCondition.fromJson(Map<String, dynamic> json) {
    final list = json['conditions'] as List;
    final conditions = list.map((e) => GeJuCondition.fromJson(e)).toList();
    return AndCondition(conditions);
  }

  @override
  Map<String, dynamic> toJson() => {
        'type': 'and',
        'conditions': conditions.map((e) => e.toJson()).toList(),
      };
}

/// 逻辑或条件 (OR)
class OrCondition extends GeJuCondition {
  final List<GeJuCondition> conditions;

  OrCondition(this.conditions);

  @override
  bool evaluate(GeJuInput input) {
    for (var condition in conditions) {
      if (condition.evaluate(input)) {
        return true;
      }
    }
    return false;
  }

  @override
  String describe() {
    return "(${conditions.map((c) => c.describe()).join(' 或 ')})";
  }

  factory OrCondition.fromJson(Map<String, dynamic> json) {
    final list = json['conditions'] as List;
    final conditions = list.map((e) => GeJuCondition.fromJson(e)).toList();
    return OrCondition(conditions);
  }

  @override
  Map<String, dynamic> toJson() => {
        'type': 'or',
        'conditions': conditions.map((e) => e.toJson()).toList(),
      };
}

/// 逻辑非条件 (NOT)
class NotCondition extends GeJuCondition {
  final GeJuCondition condition;

  NotCondition(this.condition);

  @override
  bool evaluate(GeJuInput input) {
    return !condition.evaluate(input);
  }

  @override
  String describe() {
    return "非(${condition.describe()})";
  }

  factory NotCondition.fromJson(Map<String, dynamic> json) {
    final conditionJson = json['condition'];
    final condition = GeJuCondition.fromJson(conditionJson);
    return NotCondition(condition);
  }

  @override
  Map<String, dynamic> toJson() => {
        'type': 'not',
        'condition': condition.toJson(),
      };
}
