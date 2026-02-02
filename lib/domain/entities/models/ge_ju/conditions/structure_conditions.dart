import 'package:common/enums/enum_stars.dart';
import 'package:qizhengsiyu/domain/entities/models/ge_ju/ge_ju_condition.dart';
import 'package:qizhengsiyu/domain/entities/models/ge_ju/ge_ju_input.dart';
import 'package:qizhengsiyu/domain/entities/models/ge_ju/twelve_gong_system.dart';
import 'package:qizhengsiyu/enums/enum_twelve_gong.dart';

/// T-018: 命宫所在位置条件
/// gongs: 目标宫位列表
class LifeGongAtCondition extends GeJuCondition {
  final List<String> gongs;

  LifeGongAtCondition(this.gongs);

  @override
  bool evaluate(GeJuInput input) {
    for (var name in gongs) {
      final targetGong = TwelveGongSystem.resolve(name);
      if (targetGong == input.lifeGong) return true;
    }
    return false;
  }

  @override
  String describe() {
    return "命宫在${gongs.join("/")}";
  }

  factory LifeGongAtCondition.fromJson(Map<String, dynamic> json) {
    return LifeGongAtCondition(
        (json['gongs'] as List).map((e) => e.toString()).toList());
  }
  @override
  Map<String, dynamic> toJson() => {
        'type': 'lifeGongAt',
        'gongs': gongs,
      };
}

/// T-019: 命度所在星宿条件
/// constellations: 目标星宿列表
class LifeConstellationAtCondition extends GeJuCondition {
  final List<String> constellations;

  LifeConstellationAtCondition(this.constellations);

  @override
  bool evaluate(GeJuInput input) {
    final lifeInnName = input.lifeConstellation.starName;
    return constellations.contains(lifeInnName);
  }

  @override
  String describe() {
    return "命度躔${constellations.join("/")}";
  }

  factory LifeConstellationAtCondition.fromJson(Map<String, dynamic> json) {
    return LifeConstellationAtCondition(
        (json['constellations'] as List).map((e) => e.toString()).toList());
  }
  @override
  Map<String, dynamic> toJson() => {
        'type': 'lifeConstellationAt',
        'constellations': constellations,
      };
}

/// T-020: 星曜守护命宫（在命宫）条件
/// star: 目标星
class StarGuardLifeCondition extends GeJuCondition {
  final EnumStars star;

  StarGuardLifeCondition(this.star);

  @override
  bool evaluate(GeJuInput input) {
    final gong = input.getStarGong(star);
    return gong != null && gong == input.lifeGong;
  }

  @override
  String describe() {
    return "${star.singleName}临命";
  }

  factory StarGuardLifeCondition.fromJson(Map<String, dynamic> json) {
    final star = EnumStars.getBySingleName(json['star']) ??
        EnumStars.values.byName(json['star']);
    return StarGuardLifeCondition(star);
  }
  @override
  Map<String, dynamic> toJson() => {
        'type': 'starGuardLife',
        'star': star.name,
      };
}

/// T-021: 星曜在指定命盘功能宫位（如财帛、官禄等）
/// star: 目标星
/// destinyGong: 命盘十二宫功能名称（如"财帛"）
class StarInDestinyGongCondition extends GeJuCondition {
  final EnumStars star;
  final EnumDestinyTwelveGong destinyGong;

  StarInDestinyGongCondition(this.star, this.destinyGong);

  @override
  bool evaluate(GeJuInput input) {
    // 1. 获取该功能宫对应地支
    final targetZhiGong = input.destinyGongMapper[destinyGong];
    if (targetZhiGong == null) return false;

    // 2. 获取星曜实际地支宫位
    final starGong = input.getStarGong(star);

    return starGong == targetZhiGong;
  }

  @override
  String describe() {
    return "${star.singleName}在${destinyGong.name}";
  }

  factory StarInDestinyGongCondition.fromJson(Map<String, dynamic> json) {
    final star = EnumStars.getBySingleName(json['star']) ??
        EnumStars.values.byName(json['star']);
    final destinyGongName = json['destinyGong'];
    final destinyGong = EnumDestinyTwelveGong.values
        .firstWhere((e) => e.name == destinyGongName);
    return StarInDestinyGongCondition(star, destinyGong);
  }
  @override
  Map<String, dynamic> toJson() => {
        'type': 'starInDestinyGong',
        'star': star.name,
        'destinyGong': destinyGong.name,
      };
}
