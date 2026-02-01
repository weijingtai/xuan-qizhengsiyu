import 'package:common/module.dart';
import 'package:json_annotation/json_annotation.dart';

import '../enums/enum_twelve_gong.dart';
import 'fei_xian_calculator.dart';

part 'fei_xian_detail_palace.g.dart';

/// 洞微飞限信息
@JsonSerializable()
class FeiXianDetailPalace {
  final int order;

  /// 飞限宫位
  final EnumTwelveGong palace;

  final FeiXianGongType feiXianGongType;

  final int? triangleIndex;

  /// 起始年龄
  final YearMonth startAge;

  /// 结束年龄
  final YearMonth endAge;

  final DateTime startTime;
  final DateTime endTime;

  /// 持续年数
  final YearMonth durationYears;

  FeiXianDetailPalace({
    required this.palace,
    required this.startAge,
    required this.endAge,
    required this.startTime,
    required this.endTime,
    required this.durationYears,
    required this.order,
    required this.feiXianGongType,
    this.triangleIndex,
  });

  factory FeiXianDetailPalace.fromJson(Map<String, dynamic> json) =>
      _$FeiXianDetailPalaceFromJson(json);
  Map<String, dynamic> toJson() => _$FeiXianDetailPalaceToJson(this);
}
