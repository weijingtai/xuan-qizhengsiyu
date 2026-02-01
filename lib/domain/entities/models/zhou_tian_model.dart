import 'package:common/enums.dart';
import 'package:common/widgets/twenty_four_jie_qi_tag.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:qizhengsiyu/enums/enum_twelve_gong.dart';
import 'package:tuple/tuple.dart';

import '../../../enums/enum_panel_system_type.dart';
import 'naming_degree_pair.dart';

part 'zhou_tian_model.g.dart';

@JsonSerializable()
class ZhouTianModel {
  // 黄道制，赤道制，天赤道制，拟黄道术
  CelestialCoordinateSystem systemType;

  // 古宿，今宿，矫正古宿，恒星不变
  ConstellationSystemType constellationSystemType;

  // 回归制，恒星制
  PanelSystemType panelSystemType;

  // 历法
  String epochCorrection;

  // 黄道为360°
  // 赤道(天赤道)为365.25°
  // 汉初历 为了便于计算为365.25度
  double totalDegree;
  // 十二宫度数
  // 等宫制， 黄道制时十二宫均为30°; 赤道制时十二宫均为30.44°
  // 子午宫，赤道制，除子午两宫位32.625°其余为30°；
  // 午未宫，赤道制，除午未两宫位32.625°其余为30°；
  // 四正制，赤道制，除子午卯酉两宫位31.324°其余为30°；
  // 不等宫制，明代使用“推黄道术”，天赤道二十八宿变为黄道二十八宿，度数改变，各宫度数也不相同
  List<GongDegree> gongDegreeSeq;
  // Map<EnumTwelveGong, double> twelvGongDegreeMap;

  // 二十八星宿 以及对应角度
  List<ConstellationDegree> starInnDegreeSeq;
  // Map<TwentyEightStarInn, double> starInnDegreeMap;

  // 星宿与十二宫的对齐点
  // 黄道回归制今宿，室火猪 6.5° 春分戌0°
  // 黄道回归制古宿, 奎木狼 1.72°
  // 黄道回归制古宿矫正, 室火 12.2°

  // 黄道恒星制（《三辰通载》）：虚6°，子宫0° --- 黄经0°
  // 黄道恒星制（天禧历）：虚危交界在子宫15° --- 黄经0°

  // 赤道恒星制，女宿2.1°，立春子宫0°，星宿十二宫对齐点为”虚宿6°子宫15°“
  // 明朝：
  ConstellationDegree alignmentPointAtConstellation;
  GongDegree alignmentPointAtGong;

  TwentyFourJieQi zeroPointJieQi;
  ConstellationDegree zeroPointAtConstellation;
  GongDegree zeroPointAtGong;
  double celestialLongitude;
  double zeroPointOffsetToNow;
  double rightAscension;
  List<EnumTwelveGong> gongOrder;
  List<Enum28Constellations> starInnOrder;

  List<String> specificationList;

  ZhouTianModel({
    required this.systemType,
    required this.constellationSystemType,
    required this.panelSystemType,
    required this.epochCorrection,
    required this.totalDegree,
    required this.gongDegreeSeq,
    required this.starInnDegreeSeq,
    required this.alignmentPointAtConstellation,
    required this.alignmentPointAtGong,
    required this.zeroPointJieQi,
    required this.zeroPointAtConstellation,
    required this.zeroPointAtGong,
    required this.celestialLongitude,
    required this.zeroPointOffsetToNow,
    required this.rightAscension,
    required this.specificationList,
    required this.gongOrder,
    required this.starInnOrder,
  });

  factory ZhouTianModel.fromJson(Map<String, dynamic> json) =>
      _$ZhouTianModelFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$ZhouTianModelToJson(this);
}
