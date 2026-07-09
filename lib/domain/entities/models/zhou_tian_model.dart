import 'package:metaphysics_core/enums.dart';
import 'package:metaphysics_core/enums.dart';
import 'package:xuan_four_zhu_card/widgets/twenty_four_jie_qi_tag.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:qizhengsiyu/enums/enum_twelve_gong.dart';
import 'package:tuple/tuple.dart';

export '../../../enums/enum_panel_system_type.dart';
import '../../../enums/enum_panel_system_type.dart';
import '../../../enums/enum_zhou_tian_model.dart';
import '../../../enums/enum_zero_point_ref.dart';
import '../../../enums/enum_constellation_offset_tier.dart';
import 'naming_degree_pair.dart';
import 'projection_config.dart';

part 'zhou_tian_model.g.dart';

@JsonSerializable()
class ZhouTianModel {
  // 黄道制，赤道制，天赤道制，似黄道恒星制
  @JsonKey(fromJson: CelestialCoordinateSystem.fromJson)
  CelestialCoordinateSystem systemType;

  // 投影配置
  ProjectionConfig? projectionConfig;

  // 古宿，今宿，矫正古宿，恒星不变
  @JsonKey(fromJson: ConstellationSystemType.fromJson)
  ConstellationSystemType constellationSystemType;

  // 回归制，恒星制
  @JsonKey(fromJson: PanelSystemType.fromJson)
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
    this.projectionConfig,
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

  ZhouTianModel copyWith({
    CelestialCoordinateSystem? systemType,
    ProjectionConfig? projectionConfig,
    ConstellationSystemType? constellationSystemType,
    PanelSystemType? panelSystemType,
    String? epochCorrection,
    double? totalDegree,
    List<GongDegree>? gongDegreeSeq,
    List<ConstellationDegree>? starInnDegreeSeq,
    ConstellationDegree? alignmentPointAtConstellation,
    GongDegree? alignmentPointAtGong,
    TwentyFourJieQi? zeroPointJieQi,
    ConstellationDegree? zeroPointAtConstellation,
    GongDegree? zeroPointAtGong,
    double? celestialLongitude,
    double? zeroPointOffsetToNow,
    double? rightAscension,
    List<EnumTwelveGong>? gongOrder,
    List<Enum28Constellations>? starInnOrder,
    List<String>? specificationList,
  }) {
    return ZhouTianModel(
      systemType: systemType ?? this.systemType,
      projectionConfig: projectionConfig ?? this.projectionConfig,
      constellationSystemType:
          constellationSystemType ?? this.constellationSystemType,
      panelSystemType: panelSystemType ?? this.panelSystemType,
      epochCorrection: epochCorrection ?? this.epochCorrection,
      totalDegree: totalDegree ?? this.totalDegree,
      gongDegreeSeq: gongDegreeSeq ?? this.gongDegreeSeq,
      starInnDegreeSeq: starInnDegreeSeq ?? this.starInnDegreeSeq,
      alignmentPointAtConstellation:
          alignmentPointAtConstellation ?? this.alignmentPointAtConstellation,
      alignmentPointAtGong: alignmentPointAtGong ?? this.alignmentPointAtGong,
      zeroPointJieQi: zeroPointJieQi ?? this.zeroPointJieQi,
      zeroPointAtConstellation:
          zeroPointAtConstellation ?? this.zeroPointAtConstellation,
      zeroPointAtGong: zeroPointAtGong ?? this.zeroPointAtGong,
      celestialLongitude: celestialLongitude ?? this.celestialLongitude,
      zeroPointOffsetToNow: zeroPointOffsetToNow ?? this.zeroPointOffsetToNow,
      rightAscension: rightAscension ?? this.rightAscension,
      specificationList: specificationList ?? this.specificationList,
      gongOrder: gongOrder ?? this.gongOrder,
      starInnOrder: starInnOrder ?? this.starInnOrder,
    );
  }

  /// 按面板配置产出覆写副本；config 两字段均 null 时返回 this（零成本、零行为变化）。
  /// 关键约束：ZhouTianModelManager._mapper 是共享缓存实例，覆写必须走此克隆，严禁原地 mutate。
  ZhouTianModel applyOverrides({
    EnumZhouTianModel? zhouTianModelOverride,
    ProjectionConfig? projectionOverride,
    EnumZeroPointRef? zeroPointRef,
    ConstellationOffsetTier? offsetTier,
    double? constellationOffsetDeg,
    Map<Enum28Constellations, double>? starInnDegreeOverrides,
    HouseDivisionSystem? houseDivisionSystemOverride,
  }) {
    final hasAny =
        zhouTianModelOverride != null ||
        projectionOverride != null ||
        zeroPointRef != null ||
        offsetTier != null ||
        constellationOffsetDeg != null ||
        (starInnDegreeOverrides != null && starInnDegreeOverrides.isNotEmpty) ||
        houseDivisionSystemOverride != null;
    if (!hasAny) return this;

    final offset =
        constellationOffsetDeg ?? offsetTier?.defaultOffsetDeg ?? 0.0;
    final newTotalDegree = zhouTianModelOverride?.totalDegree ?? totalDegree;

    List<ConstellationDegree>? newStarInn;
    if (starInnDegreeOverrides != null && starInnDegreeOverrides.isNotEmpty) {
      newStarInn = starInnDegreeSeq.map((cd) {
        final ov = starInnDegreeOverrides[cd.constellation];
        return ov == null ? cd : cd.copyWith(degree: ov);
      }).toList();
    }

    final newZero = offset == 0.0
        ? zeroPointAtConstellation
        : zeroPointAtConstellation.copyWith(
            degree: zeroPointAtConstellation.degree + offset,
          );

    return copyWith(
      totalDegree: zhouTianModelOverride?.totalDegree ?? totalDegree,
      projectionConfig: projectionOverride ?? projectionConfig,
      gongDegreeSeq: houseDivisionSystemOverride == null
          ? gongDegreeSeq
          : _buildGongDegreeSeq(houseDivisionSystemOverride, newTotalDegree),
      starInnDegreeSeq: newStarInn ?? starInnDegreeSeq,
      zeroPointAtConstellation: newZero,
    );
  }

  List<GongDegree> _buildGongDegreeSeq(
    HouseDivisionSystem system,
    double targetTotalDegree,
  ) {
    double widthFor(EnumTwelveGong gong) {
      switch (system) {
        case HouseDivisionSystem.equal:
        case HouseDivisionSystem.equatorialEqual:
        case HouseDivisionSystem.unequal:
          return targetTotalDegree / 12;
        case HouseDivisionSystem.equatorialFourZheng:
          return {
                EnumTwelveGong.Zi,
                EnumTwelveGong.Wu,
                EnumTwelveGong.Mao,
                EnumTwelveGong.You,
              }.contains(gong)
              ? 31.312
              : 30.0;
        case HouseDivisionSystem.equatorialSunMoon:
          return {EnumTwelveGong.Wu, EnumTwelveGong.Wei}.contains(gong)
              ? 32.625
              : 30.0;
        case HouseDivisionSystem.equatorialZiWu:
          return {EnumTwelveGong.Zi, EnumTwelveGong.Wu}.contains(gong)
              ? 32.625
              : 30.0;
        case HouseDivisionSystem.equatorialZiWuSanChenTongZai:
          return {EnumTwelveGong.Zi, EnumTwelveGong.Wu}.contains(gong)
              ? 30.4380
              : 30.4979;
      }
    }

    return gongOrder
        .map((gong) => GongDegree(gong: gong, degree: widthFor(gong)))
        .toList();
  }
}
