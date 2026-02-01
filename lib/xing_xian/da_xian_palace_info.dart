import 'package:common/module.dart';
import 'package:json_annotation/json_annotation.dart';

import '../enums/enum_twelve_gong.dart';
import '../enums/enum_xing_xian_type.dart';
import 'da_xian_constellation_passage_info.dart';
import 'star_influence_model.dart';

part 'da_xian_palace_info.g.dart';

@JsonSerializable()
class DaXianPalaceInfo {
  /// 大限宫位的序号,从1开始计数
  final int order;

  /// 大限所在的宫位
  final EnumTwelveGong palace;

  /// 此大限的持续时长(年月)
  final YearMonth durationYears;

  /// 进入此大限的时间点
  final DateTime startTime;

  /// 离开此大限的时间点
  final DateTime endTime;

  /// 进入此大限时的年龄(年月)
  final YearMonth startAge;

  /// 离开此大限时的年龄(年月)
  final YearMonth endAge;

  /// 每度对应的年月数(用于计算星宿过限时长)
  final YearMonth rateYearsPerDegree;

  /// 此大限内所有星宿过限的详细信息列表
  final List<DaXianConstellationPassageInfo> constellationPassages;

  /// 宫位总度数
  final double totalGongDegreee;

  StarGongInfluence? starGongInfluence;

  /// 顶度星体影响映射表
  Map<EnumInfluenceType, List<DingStarInfluenceModel>>? dingStarMapper;

  /// 行限类型
  final EnumXingXianType xingXianType;

  DaXianPalaceInfo({
    required this.order,
    required this.palace,
    required this.durationYears,
    required this.startTime,
    required this.endTime,
    required this.startAge,
    required this.endAge,
    required this.rateYearsPerDegree,
    required this.constellationPassages,
    required this.totalGongDegreee,
    this.starGongInfluence,
    this.dingStarMapper,
    this.xingXianType = EnumXingXianType.daXian, // 默认为大限
  });

  DaXianPalaceInfo copyWith({
    int? order,
    EnumTwelveGong? palace,
    YearMonth? durationYears,
    DateTime? startTime,
    DateTime? endTime,
    YearMonth? startAge,
    YearMonth? endAge,
    YearMonth? rateYearsPerDegree,
    List<DaXianConstellationPassageInfo>? constellationPassages,
    double? totalGongDegreee,
    StarGongInfluence? starGongInfluence,
    Map<EnumInfluenceType, List<DingStarInfluenceModel>>? dingStarMapper,
  }) {
    return DaXianPalaceInfo(
      order: order ?? this.order,
      palace: palace ?? this.palace,
      durationYears: durationYears ?? this.durationYears,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      startAge: startAge ?? this.startAge,
      endAge: endAge ?? this.endAge,
      rateYearsPerDegree: rateYearsPerDegree ?? this.rateYearsPerDegree,
      constellationPassages:
          constellationPassages ?? this.constellationPassages,
      totalGongDegreee: totalGongDegreee ?? this.totalGongDegreee,
      starGongInfluence: starGongInfluence ?? this.starGongInfluence,
      dingStarMapper: dingStarMapper ?? this.dingStarMapper,
    );
  }

  @override
  String toString() {
    String passagesStr =
        constellationPassages.map((p) => p.toString()).join('\n');
    return 'Daxian ${order}: ${palace.name} ($durationYears)\n'
        '  Time: ${startTime.toIso8601String()} - ${endTime.toIso8601String()}\n'
        '  Age:  $startAge - $endAge\n'
        '  Rate: $rateYearsPerDegree yr/deg\n'
        '  Passages:\n$passagesStr';
  }

  factory DaXianPalaceInfo.fromJson(Map<String, dynamic> json) =>
      _$DaXianPalaceInfoFromJson(json);
  Map<String, dynamic> toJson() => _$DaXianPalaceInfoToJson(this);
}

@JsonSerializable()
class StarGongInfluence {
  // 同宫
  final List<PalaceStarInfluenceModel>? sameGongInfluence;

  // 对宫
  final List<PalaceStarInfluenceModel>? oppositeGongInfluence;
  // 三方
  final Map<EnumTwelveGong, List<PalaceStarInfluenceModel>>?
      triangleGongInfluence;
  // 四正
  final Map<EnumTwelveGong, List<PalaceStarInfluenceModel>>?
      squareGongInfluence;
  // 同络
  final Map<EnumTwelveGong, List<PalaceStarInfluenceModel>>? sameLuoInfluence;

  StarGongInfluence({
    this.sameGongInfluence,
    this.oppositeGongInfluence,
    this.triangleGongInfluence,
    this.squareGongInfluence,
    this.sameLuoInfluence,
  });

  factory StarGongInfluence.fromJson(Map<String, dynamic> json) =>
      _$StarGongInfluenceFromJson(json);
  Map<String, dynamic> toJson() => _$StarGongInfluenceToJson(this);
}
