import 'package:common/module.dart';
import 'package:json_annotation/json_annotation.dart';
import '../enums/enum_twelve_gong.dart';
import '../enums/enum_xing_xian_type.dart';
import 'da_xian_constellation_passage_info.dart';

/// 行限宫位基类
abstract class BaseXianPalace {
  /// 序号
  final int order;

  /// 宫位
  final EnumTwelveGong palace;

  /// 起始年龄
  final YearMonth startAge;

  /// 结束年龄
  final YearMonth endAge;

  /// 开始时间
  final DateTime startTime;

  /// 结束时间
  final DateTime endTime;

  /// 持续年数
  final YearMonth durationYears;

  /// 宫位总度数
  final double totalGongDegreee;

  /// 此大限内所有星宿过限的详细信息列表
  final List<DaXianConstellationPassageInfo> constellationPassages;

  /// 星体影响模型

  /// 行限类型
  final EnumXingXianType xingXianType;

  BaseXianPalace({
    required this.order,
    required this.palace,
    required this.startAge,
    required this.endAge,
    required this.startTime,
    required this.endTime,
    required this.durationYears,
    required this.constellationPassages,
    required this.totalGongDegreee,
    required this.xingXianType,
  });
}
