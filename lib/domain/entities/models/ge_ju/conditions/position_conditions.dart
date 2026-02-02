import 'package:common/enums/enum_28_constellations.dart';
import 'package:common/enums/enum_stars.dart';
import 'package:qizhengsiyu/enums/enum_qi_zheng.dart';
import 'package:qizhengsiyu/domain/entities/models/ge_ju/ge_ju_condition.dart';
import 'package:qizhengsiyu/domain/entities/models/ge_ju/ge_ju_input.dart';
import 'package:qizhengsiyu/domain/entities/models/ge_ju/twelve_gong_system.dart';

/// T-007: 星曜在指定宫位条件
/// star: 目标星曜
/// gongs: 目标宫位名称列表（支持地支、十二次、黄道别名）
class StarInGongCondition extends GeJuCondition {
  final EnumStars star;
  final List<String> gongs;

  StarInGongCondition(this.star, this.gongs);

  @override
  bool evaluate(GeJuInput input) {
    final gong = input.getStarGong(star);
    if (gong == null) return false;

    // 检查是否在指定列表中
    for (var gongName in gongs) {
      final targetGong = TwelveGongSystem.resolve(gongName);
      if (targetGong == gong) return true;
    }
    return false;
  }

  @override
  String describe() {
    return "${star.singleName}入${gongs.join("/")}宫";
  }

  factory StarInGongCondition.fromJson(Map<String, dynamic> json) {
    final gongsList = (json['gongs'] as List).map((e) => e.toString()).toList();
    final star = EnumStars.getBySingleName(json['star']) ??
        EnumStars.values.byName(json['star']);

    return StarInGongCondition(star, gongsList);
  }
  @override
  Map<String, dynamic> toJson() => {
        'type': 'starInGong',
        'star': star.name,
        'gongs': gongs,
      };
}

/// T-008: 星曜在指定星宿条件
/// star: 目标星曜
/// constellations: 目标星宿名称列表（如"毕", "昴"）
class StarInConstellationCondition extends GeJuCondition {
  final EnumStars star;
  final List<String> constellations;

  StarInConstellationCondition(this.star, this.constellations);

  @override
  bool evaluate(GeJuInput input) {
    final inn = input.getStarConstellation(star);
    if (inn == null) return false;

    for (var name in constellations) {
      if (inn.starName == name) return true;
    }
    return false;
  }

  @override
  String describe() {
    return "${star.singleName}躔${constellations.join("/")}宿";
  }

  factory StarInConstellationCondition.fromJson(Map<String, dynamic> json) {
    final list =
        (json['constellations'] as List).map((e) => e.toString()).toList();
    final star = EnumStars.getBySingleName(json['star']) ??
        EnumStars.values.byName(json['star']);
    return StarInConstellationCondition(star, list);
  }
  @override
  Map<String, dynamic> toJson() => {
        'type': 'starInConstellation',
        'star': star.name,
        'constellations': constellations,
      };
}

/// T-009: 星曜运行状态条件
/// star: 目标星曜
/// states: 状态列表（如"逆", "留", "速"）
class StarWalkingStateCondition extends GeJuCondition {
  final EnumStars star;
  final List<FiveStarWalkingType> states;

  StarWalkingStateCondition(this.star, this.states);

  @override
  bool evaluate(GeJuInput input) {
    final state = input.getStarWalkingType(star);
    if (state == null) return false;

    return states.contains(state);
  }

  @override
  String describe() {
    return "${star.singleName}行${states.map((e) => e.name).join("/")}";
  }

  factory StarWalkingStateCondition.fromJson(Map<String, dynamic> json) {
    final list = (json['states'] as List).map((e) {
      // 支持中文名或枚举名
      for (var val in FiveStarWalkingType.values) {
        if (val.name == e || val.toString().split('.').last == e) return val;
      }
      throw ArgumentError("Invalid FiveStarWalkingType: $e");
    }).toList();

    final star = EnumStars.getBySingleName(json['star']) ??
        EnumStars.values.byName(json['star']);

    return StarWalkingStateCondition(star, list);
  }
  @override
  Map<String, dynamic> toJson() => {
        'type': 'starWalkingState',
        'star': star.name,
        'states': states.map((e) => e.name).toList(),
      };
}

/// T-010: 星曜落空亡条件
/// star: 目标星曜
class StarInKongWangCondition extends GeJuCondition {
  final EnumStars star;

  StarInKongWangCondition(this.star);

  @override
  bool evaluate(GeJuInput input) {
    return input.isStarInKongWang(star);
  }

  @override
  String describe() {
    return "${star.singleName}落空亡";
  }

  factory StarInKongWangCondition.fromJson(Map<String, dynamic> json) {
    final star = EnumStars.getBySingleName(json['star']) ??
        EnumStars.values.byName(json['star']);
    return StarInKongWangCondition(star);
  }
  @override
  Map<String, dynamic> toJson() => {
        'type': 'starInKongWang',
        'star': star.name,
      };
}
