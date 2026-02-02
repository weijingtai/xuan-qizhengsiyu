import 'package:common/enums/enum_stars.dart';
import 'package:qizhengsiyu/domain/entities/models/ge_ju/ge_ju_condition.dart';
import 'package:qizhengsiyu/domain/entities/models/ge_ju/ge_ju_input.dart';
import 'package:qizhengsiyu/enums/enum_hua_yao.dart';
import 'package:qizhengsiyu/enums/enum_stars_four_type.dart';

/// T-022: 星曜为四主（命主、身主等）条件
/// star: 目标星
/// roles: 角色列表 ["lifeGongMaster", "bodyGongMaster", "lifeConstellationMaster", "bodyConstellationMaster"]
class StarIsSiZhuCondition extends GeJuCondition {
  final EnumStars star;
  final List<String> roles;

  StarIsSiZhuCondition(this.star, this.roles);

  @override
  bool evaluate(GeJuInput input) {
    for (var role in roles) {
      EnumStars? master;
      switch (role) {
        case "lifeGongMaster":
          master = input.lifeGongMaster;
          break;
        case "bodyGongMaster":
          master = input.bodyGongMaster;
          break;
        case "lifeConstellationMaster":
          master = input.lifeConstellationMaster;
          break;
        case "bodyConstellationMaster":
          master = input.bodyConstellationMaster;
          break;
      }
      if (master == star) return true;
    }
    return false;
  }

  @override
  String describe() {
    // 简单映射描述
    final roleNames = roles.map((r) {
      switch (r) {
        case "lifeGongMaster":
          return "命主";
        case "bodyGongMaster":
          return "身主";
        case "lifeConstellationMaster":
          return "度主";
        case "bodyConstellationMaster":
          return "身度主";
        default:
          return r;
      }
    }).join("/");
    return "${star.singleName}为$roleNames";
  }

  factory StarIsSiZhuCondition.fromJson(Map<String, dynamic> json) {
    final star = EnumStars.getBySingleName(json['star']) ??
        EnumStars.values.byName(json['star']);
    return StarIsSiZhuCondition(
        star, (json['roles'] as List).map((e) => e.toString()).toList());
  }

  @override
  Map<String, dynamic> toJson() => {
        'type': 'starIsSiZhu',
        'star': star.name,
        'roles': roles,
      };
}

/// T-023: 星曜四令关系条件（恩难仇用）
/// star: 主星
/// target: 客星/参照星
/// types: 关系列表 [En, Nan, Chou, Yong]
class StarFourTypeCondition extends GeJuCondition {
  final EnumStars star;
  final EnumStars target;
  final List<EnumStarsFourType> types;

  StarFourTypeCondition(this.star, this.target, this.types);

  @override
  bool evaluate(GeJuInput input) {
    // input.starsFourTypeMapper 结构: Map<EnumStars, Map<EnumStarsFourType, Set<EnumStars>>>
    // 第一层 Key 是主星 (Host)，第二层 Key 是关系类型，Value 是该关系的星集合
    // 比如：木星为命度主，火星为其子（恩）。则 starsFourTypeMapper[木]?[En] 包含 火

    // 这里语义需明确：是判断 star 相对于 target 的关系，还是 target 相对于 star 的关系？
    // 通常语境： "火为木之恩" -> 主体是火，参照是木，火是木的恩星。
    // 即 check if 'star' is in 'target's 'type' list.

    final relationshipMap = input.starsFourTypeMapper[target];
    if (relationshipMap == null) return false;

    for (var type in types) {
      if (relationshipMap[type]?.contains(star) ?? false) return true;
    }
    return false;
  }

  @override
  String describe() {
    return "${star.singleName}为${target.singleName}之${types.map((e) => e.name).join("/")}";
  }

  factory StarFourTypeCondition.fromJson(Map<String, dynamic> json) {
    final star = EnumStars.getBySingleName(json['star']) ??
        EnumStars.values.byName(json['star']);
    final target = EnumStars.getBySingleName(json['target']) ??
        EnumStars.values.byName(json['target']);
    final types = (json['types'] as List)
        .map((e) => EnumStarsFourType.values.byName(e.toString()))
        .toList();

    return StarFourTypeCondition(star, target, types);
  }

  @override
  Map<String, dynamic> toJson() => {
        'type': 'starFourType',
        'star': star.name,
        'target': target.name,
        'types': types.map((e) => e.name).toList(),
      };
}

/// T-024: 星曜化曜条件（如木化禄）
/// star: 目标星
/// huaYaos: 化曜列表 [Lu, An, Fu, ...]
class StarHasHuaYaoCondition extends GeJuCondition {
  final EnumStars star;
  final List<EnumGuoLaoHuaYao> huaYaos;

  StarHasHuaYaoCondition(this.star, this.huaYaos);

  @override
  bool evaluate(GeJuInput input) {
    // input.huaYaoMapper: Map<EnumStars, List<HuaYaoItem>>
    final currentStarHuaYaos = input.huaYaoMapper[star] ?? [];
    for (var item in currentStarHuaYaos) {
      // item is HuaYaoItem, check if its name matches any required EnumGuoLaoHuaYao name
      for (var requiredHuaYao in this.huaYaos) {
        if (item.name == requiredHuaYao.name) return true;
      }
    }
    return false;
  }

  @override
  String describe() {
    return "${star.singleName}化${huaYaos.map((e) => e.name).join("/")}";
  }

  factory StarHasHuaYaoCondition.fromJson(Map<String, dynamic> json) {
    final star = EnumStars.getBySingleName(json['star']) ??
        EnumStars.values.byName(json['star']);
    final huaYaos = (json['huaYaos'] as List).map((e) {
      // 兼容中文或英文枚举名
      for (var val in EnumGuoLaoHuaYao.values) {
        if (val.name == e || val.toString().split('.').last == e) return val;
        // 中文名映射需要手动处理或依赖 EnumExtension，这里从简假设输入为英文或枚举key
        // 实际上 HuaYao 可能需要 enum_hua_yao.dart 里的定义
      }
      // 简单 fallback
      return EnumGuoLaoHuaYao.values.byName(e.toString());
    }).toList();

    return StarHasHuaYaoCondition(star, huaYaos);
  }

  @override
  Map<String, dynamic> toJson() => {
        'type': 'starHasHuaYao',
        'star': star.name,
        'huaYaos': huaYaos.map((e) => e.name).toList(),
      };
}
