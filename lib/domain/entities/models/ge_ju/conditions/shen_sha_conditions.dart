import 'package:common/enums/enum_stars.dart';
import 'package:qizhengsiyu/domain/entities/models/di_zhi_shen_sha.dart';
import 'package:qizhengsiyu/domain/entities/models/ge_ju/ge_ju_condition.dart';
import 'package:qizhengsiyu/domain/entities/models/ge_ju/ge_ju_input.dart';
import 'package:qizhengsiyu/domain/entities/models/ge_ju/twelve_gong_system.dart';

/// T-030: 星曜带神煞条件
class StarWithShenShaCondition extends GeJuCondition {
  final EnumStars star;
  final List<String> shenShaNames;

  StarWithShenShaCondition(this.star, this.shenShaNames);

  @override
  bool evaluate(GeJuInput input) {
    final gong = input.getStarGong(star);
    if (gong == null) return false;

    // 获取该宫位的神煞列表
    final shenShasOfGong = input.shenShaMapper[gong] ?? [];

    // 检查是否有匹配的神煞
    for (var name in shenShaNames) {
      if (shenShasOfGong.any((s) => s.name == name)) return true;
    }
    return false;
  }

  @override
  String describe() {
    return "${star.singleName}带${shenShaNames.join("/")}";
  }

  factory StarWithShenShaCondition.fromJson(Map<String, dynamic> json) {
    final star = EnumStars.getBySingleName(json['star']) ??
        EnumStars.values.byName(json['star']);
    final list =
        (json['shenShaNames'] as List).map((e) => e.toString()).toList();
    return StarWithShenShaCondition(star, list);
  }
  @override
  Map<String, dynamic> toJson() => {
        'type': 'starWithShenSha',
        'star': star.name,
        'shenShaNames': shenShaNames,
      };
}

/// T-031: 宫位带神煞条件
class GongHasShenShaCondition extends GeJuCondition {
  final String gongIdentifier; // 可以是宫位名，或者 "lifeGong", "bodyGong"
  final List<String> shenShaNames;

  GongHasShenShaCondition(this.gongIdentifier, this.shenShaNames);

  @override
  bool evaluate(GeJuInput input) {
    // 解析目标宫位
    var targetGong = TwelveGongSystem.resolve(gongIdentifier);
    if (gongIdentifier == "lifeGong") targetGong = input.lifeGong;
    if (gongIdentifier == "bodyGong") targetGong = input.bodyLifeModel.bodyGong;

    if (targetGong == null) return false;

    final shenShasOfGong = input.shenShaMapper[targetGong] ?? [];
    for (var name in shenShaNames) {
      if (shenShasOfGong.any((s) => s.name == name)) return true;
    }
    return false;
  }

  @override
  String describe() {
    final gongName = gongIdentifier == "lifeGong"
        ? "命宫"
        : (gongIdentifier == "bodyGong"
            ? "身宫"
            : (TwelveGongSystem.resolve(gongIdentifier)?.name ??
                gongIdentifier));
    return "$gongName带${shenShaNames.join("/")}";
  }

  factory GongHasShenShaCondition.fromJson(Map<String, dynamic> json) {
    return GongHasShenShaCondition(json['gongIdentifier'],
        (json['shenShaNames'] as List).map((e) => e.toString()).toList());
  }
  @override
  Map<String, dynamic> toJson() => {
        'type': 'gongHasShenSha',
        'gongIdentifier': gongIdentifier,
        'shenShaNames': shenShaNames,
      };
}
