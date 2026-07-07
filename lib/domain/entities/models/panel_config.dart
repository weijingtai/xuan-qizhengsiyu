import 'package:json_annotation/json_annotation.dart';
import 'package:qizhengsiyu/enums/enum_settle_life_body.dart';
import 'package:qizhengsiyu/enums/enum_twelve_gong.dart';
import 'package:qizhengsiyu/enums/enum_rahu_ketu_convention.dart';
import 'package:qizhengsiyu/enums/enum_zi_qi_algorithm.dart';
import 'package:qizhengsiyu/domain/engines/siyu/spec/si_yu_group_spec.dart';

import '../../../enums/enum_panel_system_type.dart';
import '../../../enums/enum_zhou_tian_model.dart';
import '../../../enums/enum_zero_point_ref.dart';
import '../../../enums/enum_constellation_offset_tier.dart';
import 'package:metaphysics_core/enums.dart';
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

  /// 起点参考（春分/冬至）；null=用资产 zeroPointJieQi。
  EnumZeroPointRef? zeroPointRef;

  /// 星宿偏移档位；null=不按档位偏移。
  ConstellationOffsetTier? offsetTier;

  /// 偏移数值（度），覆盖档位默认；null=用档位默认或不偏移。
  double? constellationOffsetDeg;

  /// 逐宿弧度覆写；null/空=不覆写。
  @JsonKey(
    fromJson: _starInnOverridesFromJson,
    toJson: _starInnOverridesToJson,
  )
  Map<Enum28Constellations, double>? starInnDegreeOverrides;

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
    this.zeroPointRef,
    this.offsetTier,
    this.constellationOffsetDeg,
    this.starInnDegreeOverrides,
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
    EnumZeroPointRef? zeroPointRef,
    ConstellationOffsetTier? offsetTier,
    double? constellationOffsetDeg,
    Map<Enum28Constellations, double>? starInnDegreeOverrides,
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
      zeroPointRef: zeroPointRef ?? this.zeroPointRef,
      offsetTier: offsetTier ?? this.offsetTier,
      constellationOffsetDeg: constellationOffsetDeg ?? this.constellationOffsetDeg,
      starInnDegreeOverrides: starInnDegreeOverrides ?? this.starInnDegreeOverrides,
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
        projectionOverride: null,
        zeroPointRef: null,
        offsetTier: null,
        constellationOffsetDeg: null,
        starInnDegreeOverrides: null);
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
    super.zeroPointRef,
    super.offsetTier,
    super.constellationOffsetDeg,
    super.starInnDegreeOverrides,
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
      zeroPointRef: null,
      offsetTier: null,
      constellationOffsetDeg: null,
      starInnDegreeOverrides: null,
    );
  }
}

/// Enum28Constellations 的 @JsonValue 映射（中文名 → 枚举值）。
const _starInnEnumFromChinese = {
  '角': Enum28Constellations.Jiao_Mu_Jiao,
  '亢': Enum28Constellations.Kang_Jin_Long,
  '氐': Enum28Constellations.Di_Tu_Lu,
  '房': Enum28Constellations.Fang_Ri_Tu,
  '心': Enum28Constellations.Xin_Yue_Hu,
  '尾': Enum28Constellations.Wei_Huo_Hu,
  '箕': Enum28Constellations.Ji_Shui_Bao,
  '斗': Enum28Constellations.Dou_Mu_Xie,
  '牛': Enum28Constellations.Niu_Jin_Niu,
  '女': Enum28Constellations.Nv_Tu_Fu,
  '虚': Enum28Constellations.Xu_Ri_Shu,
  '危': Enum28Constellations.Wei_Yue_Yan,
  '室': Enum28Constellations.Shi_Huo_Zhu,
  '壁': Enum28Constellations.Bi_Shui_Yu,
  '奎': Enum28Constellations.Kui_Mu_Lang,
  '娄': Enum28Constellations.Lou_Jin_Gou,
  '胃': Enum28Constellations.Wei_Tu_Zhi,
  '昴': Enum28Constellations.Mao_Ri_Ji,
  '毕': Enum28Constellations.Bi_Yue_Wu,
  '觜': Enum28Constellations.Zi_Huo_Hou,
  '参': Enum28Constellations.Shen_Shui_Yuan,
  '井': Enum28Constellations.Jing_Mu_Han,
  '鬼': Enum28Constellations.Gui_Jin_Yang,
  '柳': Enum28Constellations.Liu_Tu_Zhang,
  '星': Enum28Constellations.Xing_Ri_Ma,
  '张': Enum28Constellations.Zhang_Yue_Lu,
  '翼': Enum28Constellations.Yi_Huo_She,
  '轸': Enum28Constellations.Zhen_Shui_Yin,
};

/// Enum28Constellations 的 @JsonValue 反向映射（枚举值 → 中文名）。
const _starInnEnumToChinese = {
  Enum28Constellations.Jiao_Mu_Jiao: '角',
  Enum28Constellations.Kang_Jin_Long: '亢',
  Enum28Constellations.Di_Tu_Lu: '氐',
  Enum28Constellations.Fang_Ri_Tu: '房',
  Enum28Constellations.Xin_Yue_Hu: '心',
  Enum28Constellations.Wei_Huo_Hu: '尾',
  Enum28Constellations.Ji_Shui_Bao: '箕',
  Enum28Constellations.Dou_Mu_Xie: '斗',
  Enum28Constellations.Niu_Jin_Niu: '牛',
  Enum28Constellations.Nv_Tu_Fu: '女',
  Enum28Constellations.Xu_Ri_Shu: '虚',
  Enum28Constellations.Wei_Yue_Yan: '危',
  Enum28Constellations.Shi_Huo_Zhu: '室',
  Enum28Constellations.Bi_Shui_Yu: '壁',
  Enum28Constellations.Kui_Mu_Lang: '奎',
  Enum28Constellations.Lou_Jin_Gou: '娄',
  Enum28Constellations.Wei_Tu_Zhi: '胃',
  Enum28Constellations.Mao_Ri_Ji: '昴',
  Enum28Constellations.Bi_Yue_Wu: '毕',
  Enum28Constellations.Zi_Huo_Hou: '觜',
  Enum28Constellations.Shen_Shui_Yuan: '参',
  Enum28Constellations.Jing_Mu_Han: '井',
  Enum28Constellations.Gui_Jin_Yang: '鬼',
  Enum28Constellations.Liu_Tu_Zhang: '柳',
  Enum28Constellations.Xing_Ri_Ma: '星',
  Enum28Constellations.Zhang_Yue_Lu: '张',
  Enum28Constellations.Yi_Huo_She: '翼',
  Enum28Constellations.Zhen_Shui_Yin: '轸',
};

Map<String, dynamic>? _starInnOverridesToJson(
    Map<Enum28Constellations, double>? map) {
  if (map == null) return null;
  return map.map((k, v) => MapEntry(_starInnEnumToChinese[k]!, v));
}

Map<Enum28Constellations, double>? _starInnOverridesFromJson(
    Map<String, dynamic>? json) {
  if (json == null) return null;
  return json.map((k, v) =>
      MapEntry(_starInnEnumFromChinese[k]!, (v as num).toDouble()));
}
