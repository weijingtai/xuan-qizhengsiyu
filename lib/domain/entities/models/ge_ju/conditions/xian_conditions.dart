import 'package:common/enums/enum_28_constellations.dart';
import 'package:common/enums/enum_stars.dart';
import 'package:qizhengsiyu/domain/entities/models/ge_ju/ge_ju_condition.dart';
import 'package:qizhengsiyu/domain/entities/models/ge_ju/ge_ju_input.dart';
import 'package:qizhengsiyu/domain/entities/models/ge_ju/twelve_gong_system.dart';

/// T-032: 行限在指定宫位
class XianAtGongCondition extends GeJuCondition {
  final List<String> gongs;

  XianAtGongCondition(this.gongs);

  @override
  bool evaluate(GeJuInput input) {
    if (input.currentXianGong == null) return false; // 非行限模式直接返回 false

    for (var name in gongs) {
      final target = TwelveGongSystem.resolve(name);
      if (target == input.currentXianGong) return true;
    }
    return false;
  }

  @override
  String describe() {
    return "行限在${gongs.map((e) => TwelveGongSystem.resolve(e)?.name ?? e).join("/")}";
  }

  factory XianAtGongCondition.fromJson(Map<String, dynamic> json) {
    return XianAtGongCondition(
        (json['gongs'] as List).map((e) => e.toString()).toList());
  }
  @override
  Map<String, dynamic> toJson() => {
        'type': 'xianAtGong',
        'gongs': gongs,
      };
}

/// T-033: 行限在指定星宿
class XianAtConstellationCondition extends GeJuCondition {
  final List<String> constellations;

  XianAtConstellationCondition(this.constellations);

  @override
  bool evaluate(GeJuInput input) {
    if (input.currentXianConstellation == null) return false;

    return constellations.contains(input.currentXianConstellation!.starName);
  }

  @override
  String describe() {
    return "行限躔${constellations.join("/")}";
  }

  factory XianAtConstellationCondition.fromJson(Map<String, dynamic> json) {
    return XianAtConstellationCondition(
        (json['constellations'] as List).map((e) => e.toString()).toList());
  }
  @override
  Map<String, dynamic> toJson() => {
        'type': 'xianAtConstellation',
        'constellations': constellations,
      };
}

/// T-034: 行限遇星（限宫内有星）
class XianMeetStarCondition extends GeJuCondition {
  final List<EnumStars> stars;

  XianMeetStarCondition(this.stars);

  @override
  bool evaluate(GeJuInput input) {
    if (input.xianPalaceStars == null) return false;

    for (var star in stars) {
      if (input.xianPalaceStars!.contains(star)) return true;
    }
    return false;
  }

  @override
  String describe() {
    return "行限遇${stars.map((e) => e.singleName).join("/")}";
  }

  factory XianMeetStarCondition.fromJson(Map<String, dynamic> json) {
    final list = (json['stars'] as List)
        .map((e) => EnumStars.getBySingleName(e) ?? EnumStars.values.byName(e))
        .toList();
    return XianMeetStarCondition(list);
  }
  @override
  Map<String, dynamic> toJson() => {
        'type': 'xianMeetStar',
        'stars': stars.map((e) => e.name).toList(),
      };
}
