import 'package:common/enums.dart';
import 'package:common/module.dart';
import 'package:json_annotation/json_annotation.dart';

import '../enums/enum_twelve_gong.dart';
import 'star_influence_model.dart';

part 'da_xian_constellation_passage_info.g.dart';

@JsonSerializable()
class DaXianConstellationPassageInfo {
  /// 行限到达的星宿
  final Enum28Constellations constellation;

  /// 在星宿内的起始度数
  /// 例如: 如果一个星宿从10°开始,这个段从12°开始,则此值为2°
  final double startDegreeInConstellation;

  /// 在星宿内的结束度数
  /// 例如: 如果一个星宿从10°开始,这个段在15°结束,则此值为5°
  final double endDegreeInConstellation;

  /// 此段的角度跨度(以度为单位)
  /// 通常等于 endDegreeInConstellation - startDegreeInConstellation
  final double segmentAngularSpanDegrees;

  /// 此段的持续时长(年月)
  /// 使用YearMonth类型表示精确的年月数
  final YearMonth passageDurationYears;

  /// 进入此段的时间点
  final DateTime entryTime;

  /// 离开此段的时间点
  final DateTime exitTime;

  /// 进入此段时的年龄(年月)
  final YearMonth entryAge;

  /// 离开此段时的年龄(年月)
  final YearMonth exitAge;

  List<ConstellationStarInfluenceModel>? constellationStarInfluences;

  DaXianConstellationPassageInfo({
    required this.constellation,
    required this.startDegreeInConstellation,
    required this.endDegreeInConstellation,
    required this.segmentAngularSpanDegrees,
    required this.passageDurationYears,
    required this.entryTime,
    required this.exitTime,
    required this.entryAge,
    required this.exitAge,
    this.constellationStarInfluences,
  });

  @override
  String toString() {
    return '  -> ${constellation.name}: [${startDegreeInConstellation.toStringAsFixed(2)}°-${endDegreeInConstellation.toStringAsFixed(2)}°] of宿 (Span: ${segmentAngularSpanDegrees.toStringAsFixed(2)}°, Dur: $passageDurationYears)\n'
        '     Entry: ${entryTime.toIso8601String()} (Age: $entryAge)\n'
        '     Exit:  ${exitTime.toIso8601String()} (Age: $exitAge)';
  }

  factory DaXianConstellationPassageInfo.fromJson(Map<String, dynamic> json) =>
      _$DaXianConstellationPassageInfoFromJson(json);
  Map<String, dynamic> toJson() => _$DaXianConstellationPassageInfoToJson(this);
}
