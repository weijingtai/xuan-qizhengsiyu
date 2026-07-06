import 'package:json_annotation/json_annotation.dart';
import 'package:qizhengsiyu/enums/enum_settle_life_body.dart';
import 'package:qizhengsiyu/enums/enum_twelve_gong.dart';
import 'package:qizhengsiyu/enums/enum_rahu_ketu_convention.dart';
import 'package:qizhengsiyu/enums/enum_zi_qi_algorithm.dart';
import 'package:qizhengsiyu/domain/engines/siyu/spec/si_yu_group_spec.dart';

import '../../../enums/enum_panel_system_type.dart';
import '../../../enums/enum_zhou_tian_model.dart';
import 'fate_dong_wei_da_xian.dart';
import 'projection_config.dart';

part 'panel_config.g.dart';

/// 自定义配置数据模型
///
@JsonSerializable()
class BasePanelConfig {
  /// 星道制式
  CelestialCoordinateSystem celestialCoordinateSystem;

  /// 星盘制式
  PanelSystemType panelSystemType;

  /// 星宿类型
  ConstellationSystemType constellationSystemType;

  /// 宫位划分系统
  HouseDivisionSystem houseDivisionSystem;

  /// 立命方式
  EnumSettleLifeType settleLifeType;
  EnumTwelveGong lifeCountingToGong;

  /// 身宫方式
  EnumSettleBodyType settleBodyType;
  EnumTwelveGong bodyCountingToGong;

  /// 立命宫是否以真太阳时计算, 默认以实时太阳时计算，否则根据月令不同，确定太阳所在宫位 如：“子月在寅，丑月在丑，寅月在亥。。。”
  bool islifeGongBySunRealTimeLocation;

  /// 罗睺/计都 升降交点归属（流派分歧，用户可选，默认旧法）。
  /// 旧 JSON 缺此键时回落旧法（见 @JsonKey defaultValue）。
  @JsonKey(defaultValue: EnumRahuKetuConvention.luoJiangJiSheng)
  EnumRahuKetuConvention rahuKetuConvention;

  /// 紫气算法流派
  @JsonKey(defaultValue: EnumZiQiAlgorithm.guoLaoQinTang)
  EnumZiQiAlgorithm ziQiAlgorithm;

  /// 紫气周期
  @JsonKey(defaultValue: EnumZiQiPeriod.years28)
  EnumZiQiPeriod ziQiPeriod;

  /// 果老紫气历元常数集
  @JsonKey(defaultValue: EnumZiQiEpochSet.shouShiNvXiu)
  EnumZiQiEpochSet ziQiEpochSet;

  /// 天赤道·女宿紫气的标准
  @JsonKey(defaultValue: EnumZiQiChiDaoStandard.moira)
  EnumZiQiChiDaoStandard ziQiChiDaoStandard;

  @JsonKey(defaultValue: 'guolao_ecliptic')
  String siYuProfileId;

  @JsonKey(defaultValue: {})
  Map<String, SiYuGroupSpec> siYuOverrides; // 键=SiYuGroup.name

  CelestialCoordinateSystem? siYuCoordinateOverride;

  /// 周天制覆写：null = 用资产自带 totalDegree；degree36525 → 覆写为 365.2575。
  EnumZhouTianModel? zhouTianModelOverride;

  /// 黄赤道换算覆写：null = 用资产自带 projectionConfig（现状多为空/线性）。
  ProjectionConfig? projectionOverride;

  BasePanelConfig({
    /// 星道制式
    required this.celestialCoordinateSystem,

    /// 宫位划分系统
    required this.houseDivisionSystem,

    /// 星宿制式
    required this.panelSystemType,

    /// 星宿类型
    required this.constellationSystemType,

    /// 立命方式
    required this.settleLifeType,

    /// 身宫方式
    required this.settleBodyType,
    required this.islifeGongBySunRealTimeLocation,
    this.lifeCountingToGong = EnumTwelveGong.Mao,
    this.bodyCountingToGong = EnumTwelveGong.You,
    this.rahuKetuConvention = EnumRahuKetuConvention.luoJiangJiSheng,
    this.ziQiAlgorithm = EnumZiQiAlgorithm.guoLaoQinTang,
    this.ziQiPeriod = EnumZiQiPeriod.years28,
    this.ziQiEpochSet = EnumZiQiEpochSet.shouShiNvXiu,
    this.ziQiChiDaoStandard = EnumZiQiChiDaoStandard.moira,
    this.siYuProfileId = 'guolao_ecliptic',
    this.siYuOverrides = const {},
    this.siYuCoordinateOverride,
    this.zhouTianModelOverride,
    this.projectionOverride,
  });

  // copy with
  BasePanelConfig copyWith({
    /// 星道制式
    CelestialCoordinateSystem? celestialCoordinateSystem,

    /// 星盘制式
    PanelSystemType? panelSystemType,

    /// 星宿类型
    ConstellationSystemType? constellationSystemType,

    /// 宫位划分系统
    HouseDivisionSystem? houseDivisionSystem,

    /// 立命方式
    EnumSettleLifeType? celestialSettleLifeType,

    /// 身宫方式
    EnumSettleBodyType? settleBodyType,
    bool? lifeGongBySunRealTimeLocation,
    EnumRahuKetuConvention? rahuKetuConvention,
    EnumZiQiAlgorithm? ziQiAlgorithm,
    EnumZiQiPeriod? ziQiPeriod,
    EnumZiQiEpochSet? ziQiEpochSet,
    EnumZiQiChiDaoStandard? ziQiChiDaoStandard,
    String? siYuProfileId,
    Map<String, SiYuGroupSpec>? siYuOverrides,
    CelestialCoordinateSystem? siYuCoordinateOverride,
    EnumZhouTianModel? zhouTianModelOverride,
    ProjectionConfig? projectionOverride,
  }) {
    return BasePanelConfig(
      celestialCoordinateSystem:
          celestialCoordinateSystem ?? this.celestialCoordinateSystem,
      houseDivisionSystem: houseDivisionSystem ?? this.houseDivisionSystem,
      panelSystemType: panelSystemType ?? this.panelSystemType,
      constellationSystemType:
          constellationSystemType ?? this.constellationSystemType,
      settleLifeType: celestialSettleLifeType ?? settleLifeType,
      settleBodyType: settleBodyType ?? this.settleBodyType,
      islifeGongBySunRealTimeLocation:
          lifeGongBySunRealTimeLocation ?? islifeGongBySunRealTimeLocation,
      rahuKetuConvention: rahuKetuConvention ?? this.rahuKetuConvention,
      ziQiAlgorithm: ziQiAlgorithm ?? this.ziQiAlgorithm,
      ziQiPeriod: ziQiPeriod ?? this.ziQiPeriod,
      ziQiEpochSet: ziQiEpochSet ?? this.ziQiEpochSet,
      ziQiChiDaoStandard: ziQiChiDaoStandard ?? this.ziQiChiDaoStandard,
      siYuProfileId: siYuProfileId ?? this.siYuProfileId,
      siYuOverrides: siYuOverrides ?? this.siYuOverrides,
      siYuCoordinateOverride: siYuCoordinateOverride ?? this.siYuCoordinateOverride,
      zhouTianModelOverride: zhouTianModelOverride ?? this.zhouTianModelOverride,
      projectionOverride: projectionOverride ?? this.projectionOverride,
    );
  }

  factory BasePanelConfig.fromJson(Map<String, dynamic> json) =>
      _$BasePanelConfigFromJson(json);
  Map<String, dynamic> toJson() => _$BasePanelConfigToJson(this);

  /// 生成用于 GenerateBasePanelService 的默认面板配置。
  /// 返回: PanelConfig 对象。
  static BasePanelConfig defaultBasicPanelConfig() {
    return BasePanelConfig(
        celestialCoordinateSystem: CelestialCoordinateSystem.Ecliptic, // 黄道坐标系
        houseDivisionSystem: HouseDivisionSystem.equal, // 等宫制
        panelSystemType: PanelSystemType.Tropical, // 回归制
        constellationSystemType:
            ConstellationSystemType.Classical, // 经典黄道十二宫/二十八宿
        settleLifeType: EnumSettleLifeType.Mao, // 定命宫方法
        settleBodyType: EnumSettleBodyType.moon, // 定身宫方法
        islifeGongBySunRealTimeLocation: true, // 是否根据太阳实时位置定命宫
        rahuKetuConvention: EnumRahuKetuConvention.luoJiangJiSheng,
        ziQiAlgorithm: EnumZiQiAlgorithm.guoLaoQinTang,
        ziQiPeriod: EnumZiQiPeriod.years28,
        ziQiEpochSet: EnumZiQiEpochSet.shouShiNvXiu,
        ziQiChiDaoStandard: EnumZiQiChiDaoStandard.moira,
        siYuProfileId: 'guolao_ecliptic',
        siYuOverrides: const {},
        siYuCoordinateOverride: null,
        zhouTianModelOverride: null,
        projectionOverride: null);
  }
}

@JsonSerializable()
class FatePanelConfig {
  DongWeiDaXianMingGongCountingType mingCountingType;
  FatePanelConfig({required this.mingCountingType});

  factory FatePanelConfig.fromJson(Map<String, dynamic> json) =>
      _$FatePanelConfigFromJson(json);
  Map<String, dynamic> toJson() => _$FatePanelConfigToJson(this);

  static FatePanelConfig defaultFatePanelConfig() {
    return FatePanelConfig(
        mingCountingType: DongWeiDaXianMingGongCountingType.Modern);
  }
}

@JsonSerializable()
class PanelConfig extends BasePanelConfig {
  PanelConfig({
    required super.celestialCoordinateSystem,
    required super.houseDivisionSystem,
    required super.panelSystemType,
    required super.constellationSystemType,
    required super.settleLifeType,
    required super.settleBodyType,
    required super.islifeGongBySunRealTimeLocation,
    super.lifeCountingToGong,
    super.bodyCountingToGong,
    super.rahuKetuConvention,
    super.ziQiAlgorithm,
    super.ziQiPeriod,
    super.ziQiEpochSet,
    super.ziQiChiDaoStandard,
    super.siYuProfileId,
    super.siYuOverrides,
    super.siYuCoordinateOverride,
    super.zhouTianModelOverride,
    super.projectionOverride,
  });

  factory PanelConfig.fromJson(Map<String, dynamic> json) =>
      _$PanelConfigFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$PanelConfigToJson(this);

  static PanelConfig defaultPanelConfig() {
    return PanelConfig(
      celestialCoordinateSystem: CelestialCoordinateSystem.Ecliptic,
      houseDivisionSystem: HouseDivisionSystem.equal,
      panelSystemType: PanelSystemType.Tropical,
      constellationSystemType: ConstellationSystemType.Classical,
      settleLifeType: EnumSettleLifeType.Mao,
      settleBodyType: EnumSettleBodyType.moon,
      islifeGongBySunRealTimeLocation: true,
      rahuKetuConvention: EnumRahuKetuConvention.luoJiangJiSheng,
      ziQiAlgorithm: EnumZiQiAlgorithm.guoLaoQinTang,
      ziQiPeriod: EnumZiQiPeriod.years28,
      ziQiEpochSet: EnumZiQiEpochSet.shouShiNvXiu,
      ziQiChiDaoStandard: EnumZiQiChiDaoStandard.moira,
      siYuProfileId: 'guolao_ecliptic',
      siYuOverrides: const {},
      siYuCoordinateOverride: null,
      zhouTianModelOverride: null,
      projectionOverride: null,
    );
  }
}
