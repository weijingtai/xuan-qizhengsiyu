// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'panel_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BasePanelConfig _$BasePanelConfigFromJson(
  Map<String, dynamic> json,
) => BasePanelConfig(
  celestialCoordinateSystem: $enumDecode(
    _$CelestialCoordinateSystemEnumMap,
    json['celestialCoordinateSystem'],
  ),
  houseDivisionSystem: $enumDecode(
    _$HouseDivisionSystemEnumMap,
    json['houseDivisionSystem'],
  ),
  panelSystemType: $enumDecode(
    _$PanelSystemTypeEnumMap,
    json['panelSystemType'],
  ),
  constellationSystemType: $enumDecode(
    _$ConstellationSystemTypeEnumMap,
    json['constellationSystemType'],
  ),
  settleLifeType: $enumDecode(
    _$EnumSettleLifeTypeEnumMap,
    json['settleLifeType'],
  ),
  settleBodyType: $enumDecode(
    _$EnumSettleBodyTypeEnumMap,
    json['settleBodyType'],
  ),
  islifeGongBySunRealTimeLocation:
      json['islifeGongBySunRealTimeLocation'] as bool,
  lifeCountingToGong:
      $enumDecodeNullable(
        _$EnumTwelveGongEnumMap,
        json['lifeCountingToGong'],
      ) ??
      EnumTwelveGong.Mao,
  bodyCountingToGong:
      $enumDecodeNullable(
        _$EnumTwelveGongEnumMap,
        json['bodyCountingToGong'],
      ) ??
      EnumTwelveGong.You,
  rahuKetuConvention:
      $enumDecodeNullable(
        _$EnumRahuKetuConventionEnumMap,
        json['rahuKetuConvention'],
      ) ??
      EnumRahuKetuConvention.luoJiangJiSheng,
  ziQiAlgorithm:
      $enumDecodeNullable(_$EnumZiQiAlgorithmEnumMap, json['ziQiAlgorithm']) ??
      EnumZiQiAlgorithm.guoLaoQinTang,
  ziQiPeriod:
      $enumDecodeNullable(_$EnumZiQiPeriodEnumMap, json['ziQiPeriod']) ??
      EnumZiQiPeriod.years28,
  ziQiEpochSet:
      $enumDecodeNullable(_$EnumZiQiEpochSetEnumMap, json['ziQiEpochSet']) ??
      EnumZiQiEpochSet.shouShiNvXiu,
  ziQiChiDaoStandard:
      $enumDecodeNullable(
        _$EnumZiQiChiDaoStandardEnumMap,
        json['ziQiChiDaoStandard'],
      ) ??
      EnumZiQiChiDaoStandard.moira,
  siYuProfileId: json['siYuProfileId'] as String? ?? 'guolao_ecliptic',
  siYuOverrides:
      (json['siYuOverrides'] as Map<String, dynamic>?)?.map(
        (k, e) =>
            MapEntry(k, SiYuGroupSpec.fromJson(e as Map<String, dynamic>)),
      ) ??
      {},
  siYuCoordinateOverride: $enumDecodeNullable(
    _$CelestialCoordinateSystemEnumMap,
    json['siYuCoordinateOverride'],
  ),
  zhouTianModelOverride: $enumDecodeNullable(
    _$EnumZhouTianModelEnumMap,
    json['zhouTianModelOverride'],
  ),
  projectionOverride: json['projectionOverride'] == null
      ? null
      : ProjectionConfig.fromJson(
          json['projectionOverride'] as Map<String, dynamic>,
        ),
);

Map<String, dynamic> _$BasePanelConfigToJson(
  BasePanelConfig instance,
) => <String, dynamic>{
  'celestialCoordinateSystem':
      _$CelestialCoordinateSystemEnumMap[instance.celestialCoordinateSystem]!,
  'panelSystemType': _$PanelSystemTypeEnumMap[instance.panelSystemType]!,
  'constellationSystemType':
      _$ConstellationSystemTypeEnumMap[instance.constellationSystemType]!,
  'houseDivisionSystem':
      _$HouseDivisionSystemEnumMap[instance.houseDivisionSystem]!,
  'settleLifeType': _$EnumSettleLifeTypeEnumMap[instance.settleLifeType]!,
  'lifeCountingToGong': _$EnumTwelveGongEnumMap[instance.lifeCountingToGong]!,
  'settleBodyType': _$EnumSettleBodyTypeEnumMap[instance.settleBodyType]!,
  'bodyCountingToGong': _$EnumTwelveGongEnumMap[instance.bodyCountingToGong]!,
  'islifeGongBySunRealTimeLocation': instance.islifeGongBySunRealTimeLocation,
  'rahuKetuConvention':
      _$EnumRahuKetuConventionEnumMap[instance.rahuKetuConvention]!,
  'ziQiAlgorithm': _$EnumZiQiAlgorithmEnumMap[instance.ziQiAlgorithm]!,
  'ziQiPeriod': _$EnumZiQiPeriodEnumMap[instance.ziQiPeriod]!,
  'ziQiEpochSet': _$EnumZiQiEpochSetEnumMap[instance.ziQiEpochSet]!,
  'ziQiChiDaoStandard':
      _$EnumZiQiChiDaoStandardEnumMap[instance.ziQiChiDaoStandard]!,
  'siYuProfileId': instance.siYuProfileId,
  'siYuOverrides': instance.siYuOverrides,
  'siYuCoordinateOverride':
      _$CelestialCoordinateSystemEnumMap[instance.siYuCoordinateOverride],
  'zhouTianModelOverride':
      _$EnumZhouTianModelEnumMap[instance.zhouTianModelOverride],
  'projectionOverride': instance.projectionOverride,
};

const _$CelestialCoordinateSystemEnumMap = {
  CelestialCoordinateSystem.Ecliptic: '黄道制',
  CelestialCoordinateSystem.Equatorial: '赤道制',
  CelestialCoordinateSystem.SkyEquatorial: '天赤道制',
  CelestialCoordinateSystem.PseudoEcliptic: '似黄道恒星制',
};

const _$HouseDivisionSystemEnumMap = {
  HouseDivisionSystem.equal: '等宫制',
  HouseDivisionSystem.equatorialEqual: '赤道等宫制',
  HouseDivisionSystem.unequal: '不等宫制',
  HouseDivisionSystem.equatorialFourZheng: '四正',
  HouseDivisionSystem.equatorialSunMoon: '日月',
  HouseDivisionSystem.equatorialZiWu: 'equatorialZiWu',
};

const _$PanelSystemTypeEnumMap = {
  PanelSystemType.Tropical: '回归制',
  PanelSystemType.Sidereal: '恒星制',
};

const _$ConstellationSystemTypeEnumMap = {
  ConstellationSystemType.Classical: '古宿制',
  ConstellationSystemType.AdjustedClassical: '矫正古宿制',
  ConstellationSystemType.Modern: '今宿制',
};

const _$EnumSettleLifeTypeEnumMap = {
  EnumSettleLifeType.Mao: 'byMao',
  EnumSettleLifeType.YinMaoChen: 'byYinMaoChen',
  EnumSettleLifeType.Mannual: 'byMannual',
  EnumSettleLifeType.Ascendant: 'byAscendant',
};

const _$EnumSettleBodyTypeEnumMap = {
  EnumSettleBodyType.moon: 'byTaiYin',
  EnumSettleBodyType.you: 'byYou',
};

const _$EnumTwelveGongEnumMap = {
  EnumTwelveGong.Zi: '子',
  EnumTwelveGong.Chou: '丑',
  EnumTwelveGong.Yin: '寅',
  EnumTwelveGong.Mao: '卯',
  EnumTwelveGong.Chen: '辰',
  EnumTwelveGong.Si: '巳',
  EnumTwelveGong.Wu: '午',
  EnumTwelveGong.Wei: '未',
  EnumTwelveGong.Shen: '申',
  EnumTwelveGong.You: '酉',
  EnumTwelveGong.Xu: '戌',
  EnumTwelveGong.Hai: '亥',
};

const _$EnumRahuKetuConventionEnumMap = {
  EnumRahuKetuConvention.luoJiangJiSheng: '罗降计升',
  EnumRahuKetuConvention.luoShengJiJiang: '罗升计降',
};

const _$EnumZiQiAlgorithmEnumMap = {
  EnumZiQiAlgorithm.guoLaoQinTang: '果老琴堂',
  EnumZiQiAlgorithm.yelvTianguan: '耶律天官',
  EnumZiQiAlgorithm.shixian: '清时宪',
};

const _$EnumZiQiPeriodEnumMap = {
  EnumZiQiPeriod.years28: 'years28',
  EnumZiQiPeriod.years29: 'years29',
};

const _$EnumZiQiEpochSetEnumMap = {
  EnumZiQiEpochSet.shouShiNvXiu: '授时女宿',
  EnumZiQiEpochSet.fuTianJiXiu: '符天箕宿',
};

const _$EnumZiQiChiDaoStandardEnumMap = {
  EnumZiQiChiDaoStandard.shouShiOrthodox: '授时正典',
  EnumZiQiChiDaoStandard.moira: 'Moira实测',
};

const _$EnumZhouTianModelEnumMap = {
  EnumZhouTianModel.degree360: 'degree360',
  EnumZhouTianModel.degree36525: 'degree36525',
};

FatePanelConfig _$FatePanelConfigFromJson(Map<String, dynamic> json) =>
    FatePanelConfig(
      mingCountingType: $enumDecode(
        _$DongWeiDaXianMingGongCountingTypeEnumMap,
        json['mingCountingType'],
      ),
    );

Map<String, dynamic> _$FatePanelConfigToJson(
  FatePanelConfig instance,
) => <String, dynamic>{
  'mingCountingType':
      _$DongWeiDaXianMingGongCountingTypeEnumMap[instance.mingCountingType]!,
};

const _$DongWeiDaXianMingGongCountingTypeEnumMap = {
  DongWeiDaXianMingGongCountingType.HundredSix: 'hundredSix',
  DongWeiDaXianMingGongCountingType.Ancient: 'Ancient',
  DongWeiDaXianMingGongCountingType.Modern: 'Modern',
};

PanelConfig _$PanelConfigFromJson(Map<String, dynamic> json) => PanelConfig(
  celestialCoordinateSystem: $enumDecode(
    _$CelestialCoordinateSystemEnumMap,
    json['celestialCoordinateSystem'],
  ),
  houseDivisionSystem: $enumDecode(
    _$HouseDivisionSystemEnumMap,
    json['houseDivisionSystem'],
  ),
  panelSystemType: $enumDecode(
    _$PanelSystemTypeEnumMap,
    json['panelSystemType'],
  ),
  constellationSystemType: $enumDecode(
    _$ConstellationSystemTypeEnumMap,
    json['constellationSystemType'],
  ),
  settleLifeType: $enumDecode(
    _$EnumSettleLifeTypeEnumMap,
    json['settleLifeType'],
  ),
  settleBodyType: $enumDecode(
    _$EnumSettleBodyTypeEnumMap,
    json['settleBodyType'],
  ),
  islifeGongBySunRealTimeLocation:
      json['islifeGongBySunRealTimeLocation'] as bool,
  lifeCountingToGong:
      $enumDecodeNullable(
        _$EnumTwelveGongEnumMap,
        json['lifeCountingToGong'],
      ) ??
      EnumTwelveGong.Mao,
  bodyCountingToGong:
      $enumDecodeNullable(
        _$EnumTwelveGongEnumMap,
        json['bodyCountingToGong'],
      ) ??
      EnumTwelveGong.You,
  rahuKetuConvention:
      $enumDecodeNullable(
        _$EnumRahuKetuConventionEnumMap,
        json['rahuKetuConvention'],
      ) ??
      EnumRahuKetuConvention.luoJiangJiSheng,
  ziQiAlgorithm:
      $enumDecodeNullable(_$EnumZiQiAlgorithmEnumMap, json['ziQiAlgorithm']) ??
      EnumZiQiAlgorithm.guoLaoQinTang,
  ziQiPeriod:
      $enumDecodeNullable(_$EnumZiQiPeriodEnumMap, json['ziQiPeriod']) ??
      EnumZiQiPeriod.years28,
  ziQiEpochSet:
      $enumDecodeNullable(_$EnumZiQiEpochSetEnumMap, json['ziQiEpochSet']) ??
      EnumZiQiEpochSet.shouShiNvXiu,
  ziQiChiDaoStandard:
      $enumDecodeNullable(
        _$EnumZiQiChiDaoStandardEnumMap,
        json['ziQiChiDaoStandard'],
      ) ??
      EnumZiQiChiDaoStandard.moira,
  siYuProfileId: json['siYuProfileId'] as String? ?? 'guolao_ecliptic',
  siYuOverrides:
      (json['siYuOverrides'] as Map<String, dynamic>?)?.map(
        (k, e) =>
            MapEntry(k, SiYuGroupSpec.fromJson(e as Map<String, dynamic>)),
      ) ??
      {},
  siYuCoordinateOverride: $enumDecodeNullable(
    _$CelestialCoordinateSystemEnumMap,
    json['siYuCoordinateOverride'],
  ),
  zhouTianModelOverride: $enumDecodeNullable(
    _$EnumZhouTianModelEnumMap,
    json['zhouTianModelOverride'],
  ),
  projectionOverride: json['projectionOverride'] == null
      ? null
      : ProjectionConfig.fromJson(
          json['projectionOverride'] as Map<String, dynamic>,
        ),
);

Map<String, dynamic> _$PanelConfigToJson(
  PanelConfig instance,
) => <String, dynamic>{
  'celestialCoordinateSystem':
      _$CelestialCoordinateSystemEnumMap[instance.celestialCoordinateSystem]!,
  'panelSystemType': _$PanelSystemTypeEnumMap[instance.panelSystemType]!,
  'constellationSystemType':
      _$ConstellationSystemTypeEnumMap[instance.constellationSystemType]!,
  'houseDivisionSystem':
      _$HouseDivisionSystemEnumMap[instance.houseDivisionSystem]!,
  'settleLifeType': _$EnumSettleLifeTypeEnumMap[instance.settleLifeType]!,
  'lifeCountingToGong': _$EnumTwelveGongEnumMap[instance.lifeCountingToGong]!,
  'settleBodyType': _$EnumSettleBodyTypeEnumMap[instance.settleBodyType]!,
  'bodyCountingToGong': _$EnumTwelveGongEnumMap[instance.bodyCountingToGong]!,
  'islifeGongBySunRealTimeLocation': instance.islifeGongBySunRealTimeLocation,
  'rahuKetuConvention':
      _$EnumRahuKetuConventionEnumMap[instance.rahuKetuConvention]!,
  'ziQiAlgorithm': _$EnumZiQiAlgorithmEnumMap[instance.ziQiAlgorithm]!,
  'ziQiPeriod': _$EnumZiQiPeriodEnumMap[instance.ziQiPeriod]!,
  'ziQiEpochSet': _$EnumZiQiEpochSetEnumMap[instance.ziQiEpochSet]!,
  'ziQiChiDaoStandard':
      _$EnumZiQiChiDaoStandardEnumMap[instance.ziQiChiDaoStandard]!,
  'siYuProfileId': instance.siYuProfileId,
  'siYuOverrides': instance.siYuOverrides,
  'siYuCoordinateOverride':
      _$CelestialCoordinateSystemEnumMap[instance.siYuCoordinateOverride],
  'zhouTianModelOverride':
      _$EnumZhouTianModelEnumMap[instance.zhouTianModelOverride],
  'projectionOverride': instance.projectionOverride,
};
