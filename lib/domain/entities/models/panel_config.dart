import 'package:json_annotation/json_annotation.dart';
import 'package:qizhengsiyu/enums/enum_settle_life_body.dart';
import 'package:qizhengsiyu/enums/enum_twelve_gong.dart';
import 'package:qizhengsiyu/enums/enum_rahu_ketu_convention.dart';

import '../../../enums/enum_panel_system_type.dart';
import 'fate_dong_wei_da_xian.dart';

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
  }) {
    return BasePanelConfig(
      celestialCoordinateSystem:
          celestialCoordinateSystem ?? this.celestialCoordinateSystem,
      houseDivisionSystem: houseDivisionSystem ?? this.houseDivisionSystem,
      panelSystemType: panelSystemType ?? this.panelSystemType,
      constellationSystemType:
          constellationSystemType ?? this.constellationSystemType,
      settleLifeType: celestialSettleLifeType ?? this.settleLifeType,
      settleBodyType: settleBodyType ?? this.settleBodyType,
      islifeGongBySunRealTimeLocation:
          lifeGongBySunRealTimeLocation ?? this.islifeGongBySunRealTimeLocation,
      rahuKetuConvention: rahuKetuConvention ?? this.rahuKetuConvention,
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
        rahuKetuConvention: EnumRahuKetuConvention.luoJiangJiSheng);
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
    );
  }
}
