import 'package:json_annotation/json_annotation.dart';
import 'package:qizhengsiyu/enums/enum_settle_life_body.dart';
import 'package:qizhengsiyu/enums/enum_twelve_gong.dart';

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

  /// 立命宫是否以真太阳时计算, 默认以实时太阳时计算，否则根据月令不同，确定太阳所在宫位 如：“子月在寅，丑月在丑，寅月在亥。。。。”
  bool islifeGongBySunRealTimeLocation;

  /// UI 是否启动上升点 --- 移动至UI部分
  // bool withAscendant;

  // / UI 化曜系统 --- 移动至UI部分
  // EnumHuaYaoType displayHuaYaoType;

  /// 命盘排列顺序 --- 移动至UI部分
  // List<UIEnumPanelRing> uiPanelRingOrder;
  /// 批命提示流派 --- 移动至星盘高级部分
  // EnumSchoolType schoolType;
  /// 流派典籍 ---- 移动至星盘高级部分
  // List<String> classicBooks;

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
    );
  }

  factory BasePanelConfig.fromJson(Map<String, dynamic> json) =>
      _$BasePanelConfigFromJson(json);
  Map<String, dynamic> toJson() => _$BasePanelConfigToJson(this);

  /// 生成用于 GenerateBasePanelService 的默认面板配置。
  /// 返回: PanelConfig 对象。
  static BasePanelConfig defaultBasicPanelConfig() {
    return BasePanelConfig(
        celestialCoordinateSystem: CelestialCoordinateSystem.ecliptic, // 黄道坐标系
        houseDivisionSystem: HouseDivisionSystem.equal, // 等宫制
        panelSystemType: PanelSystemType.tropical, // 回归制
        constellationSystemType:
            ConstellationSystemType.classical, // 经典黄道十二宫/二十八宿 (需确认具体含义)
        settleLifeType: EnumSettleLifeType.Mao, // 定命宫方法 (需确认具体含义)
        settleBodyType: EnumSettleBodyType.moon, // 定身宫方法 (需确认具体含义)
        islifeGongBySunRealTimeLocation: true); // 是否根据太阳实时位置定命宫 (需确认具体含义)
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
  });

  factory PanelConfig.fromJson(Map<String, dynamic> json) =>
      _$PanelConfigFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$PanelConfigToJson(this);

  static PanelConfig defaultPanelConfig() {
    return PanelConfig(
      celestialCoordinateSystem: CelestialCoordinateSystem.ecliptic,
      houseDivisionSystem: HouseDivisionSystem.equal,
      panelSystemType: PanelSystemType.tropical,
      constellationSystemType: ConstellationSystemType.classical,
      settleLifeType: EnumSettleLifeType.Mao,
      settleBodyType: EnumSettleBodyType.moon,
      islifeGongBySunRealTimeLocation: true,
    );
  }
}
