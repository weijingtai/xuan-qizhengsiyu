import 'package:common/enums.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../../qi_zheng_si_yu_constant_resources.dart';
import 'naming_degree_pair.dart';

part 'star_inn_gong_degree.g.dart';

@JsonSerializable()
class ConstellationGongDegreeInfo {
  // 例如(starType:"黄道古制",starXiu:TwentyEightXingXiu.Lou_Jin_Gou, degreeStartAt: 015.9, insideGongStartAtDegree: Tuple2<EnumTwelveGong,double>(EnumTwelveGong.Xu,15.9), insideGongEndAtDegree: Tuple2<EnumTwelveGong,double>(EnumTwelveGong.Xu,26.3), totalDegree:10.4),
  // 星宿类型
  final StarPanelType starType;

  // 二十八星宿
  final Enum28Constellations starXiu;
  // 星宿在周天二十八星宿开始的度数
  final double degreeStartAt;

  // 星宿在十二宫内开始的度数
  final GongDegree startAtGongDegree;
  // 星宿在十二宫内开始的度数
  final GongDegree endAtGongDegree;
  // 星宿的总度数
  final double totalDegree;
  ConstellationGongDegreeInfo({
    required this.starType,
    required this.starXiu,
    required this.degreeStartAt,
    required this.totalDegree,
    required this.startAtGongDegree,
    required this.endAtGongDegree,
  });

  factory ConstellationGongDegreeInfo.fromJson(Map<String, dynamic> json) =>
      _$ConstellationGongDegreeInfoFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$ConstellationGongDegreeInfoToJson(this);
}
