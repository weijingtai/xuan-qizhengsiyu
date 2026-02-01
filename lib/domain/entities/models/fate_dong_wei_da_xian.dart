import 'package:common/models/year_month.dart';
import 'package:common/module.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../../enums/enum_twelve_gong.dart';

part 'fate_dong_wei_da_xian.g.dart';

enum DongWeiDaXianMingGongCountingType {
  // 命宫起点固定15度
  @JsonValue('hundredSix')
  HundredSix,
  // 古代方式计算
  @JsonValue('Ancient')
  Ancient, // 0~3 度 11年 3~6 度 12年 6~9 度 13年 9~12 度 14年 12~15 度 15年 15~18 度 16年 18~21 度 17年 21~24 度 18年 24~27 度 19年 27~30 度 20年
  // 现代方式计算
  @JsonValue('Modern')
  Modern, // 以10年为基础 加太阳入宫度数转换为年 3°/12月 + 10年
}

@JsonSerializable()
class DaXianGong {
  int order;
  EnumDestinyTwelveGong destinyGong;
  EnumTwelveGong gong;
  YearMonth start;
  YearMonth end;
  YearMonth totalYears;

  DaXianGong(
      {required this.order,
      required this.destinyGong,
      required this.gong,
      required this.start,
      required this.end,
      required this.totalYears});

  factory DaXianGong.fromJson(Map<String, dynamic> json) =>
      _$DaXianGongFromJson(json);
  Map<String, dynamic> toJson() => _$DaXianGongToJson(this);
}

@JsonSerializable()
class DaXianFeiXianGong {
  int order;
  EnumTwelveGong gong;
  YearMonth start;
  YearMonth end;
  YearMonth totalYears;

  DaXianFeiXianGong(
      {required this.order,
      required this.gong,
      required this.start,
      required this.end,
      required this.totalYears});

  factory DaXianFeiXianGong.fromJson(Map<String, dynamic> json) =>
      _$DaXianFeiXianGongFromJson(json);
  Map<String, dynamic> toJson() => _$DaXianFeiXianGongToJson(this);
}

@JsonSerializable()
class DongWeiFate {
  final DongWeiDaXianMingGongCountingType type;
  List<DaXianGong> daXianGongs;

  DongWeiFate({
    required this.type,
    required this.daXianGongs,
  });

  factory DongWeiFate.fromJson(Map<String, dynamic> json) =>
      _$DongWeiFateFromJson(json);
  Map<String, dynamic> toJson() => _$DongWeiFateToJson(this);
}
