import 'package:json_annotation/json_annotation.dart';
import 'package:common/models/year_month.dart';

import '../enums/enum_twelve_gong.dart';
import '../enums/enum_xing_xian_type.dart';
import 'base_xian_palace.dart';
import 'da_xian_constellation_passage_info.dart';

part 'xiao_xian_detail_palace.g.dart';

@JsonSerializable()
class XiaoXianDetailPalace extends BaseXianPalace {
  XiaoXianDetailPalace({
    required super.order,
    required super.palace,
    required super.startAge,
    required super.endAge,
    required super.startTime,
    required super.endTime,
    required super.durationYears,
    required super.constellationPassages,
    required super.totalGongDegreee,
    super.xingXianType = EnumXingXianType.yang9,
  });

  factory XiaoXianDetailPalace.fromJson(Map<String, dynamic> json) =>
      _$XiaoXianDetailPalaceFromJson(json);
  Map<String, dynamic> toJson() => _$XiaoXianDetailPalaceToJson(this);
}
