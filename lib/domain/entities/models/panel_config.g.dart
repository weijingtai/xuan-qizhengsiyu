// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'panel_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BasePanelConfig _$BasePanelConfigFromJson(Map<String, dynamic> json) =>
    BasePanelConfig(
      celestialCoordinateSystem: $enumDecode(_$CelestialCoordinateSystemEnumMap,
          json['celestialCoordinateSystem']),
      houseDivisionSystem: $enumDecode(
          _$HouseDivisionSystemEnumMap, json['houseDivisionSystem']),
      panelSystemType:
          $enumDecode(_$PanelSystemTypeEnumMap, json['panelSystemType']),
      constellationSystemType: $enumDecode(
          _$ConstellationSystemTypeEnumMap, json['constellationSystemType']),
      settleLifeType:
          $enumDecode(_$EnumSettleLifeTypeEnumMap, json['settleLifeType']),
      settleBodyType:
          $enumDecode(_$EnumSettleBodyTypeEnumMap, json['settleBodyType']),
      islifeGongBySunRealTimeLocation:
          json['islifeGongBySunRealTimeLocation'] as bool,
      lifeCountingToGong: $enumDecodeNullable(
              _$EnumTwelveGongEnumMap, json['lifeCountingToGong']) ??
          EnumTwelveGong.Mao,
      bodyCountingToGong: $enumDecodeNullable(
              _$EnumTwelveGongEnumMap, json['bodyCountingToGong']) ??
          EnumTwelveGong.You,
    );

Map<String, dynamic> _$BasePanelConfigToJson(BasePanelConfig instance) =>
    <String, dynamic>{
      'celestialCoordinateSystem': _$CelestialCoordinateSystemEnumMap[
          instance.celestialCoordinateSystem]!,
      'panelSystemType': _$PanelSystemTypeEnumMap[instance.panelSystemType]!,
      'constellationSystemType':
          _$ConstellationSystemTypeEnumMap[instance.constellationSystemType]!,
      'houseDivisionSystem':
          _$HouseDivisionSystemEnumMap[instance.houseDivisionSystem]!,
      'settleLifeType': _$EnumSettleLifeTypeEnumMap[instance.settleLifeType]!,
      'lifeCountingToGong':
          _$EnumTwelveGongEnumMap[instance.lifeCountingToGong]!,
      'settleBodyType': _$EnumSettleBodyTypeEnumMap[instance.settleBodyType]!,
      'bodyCountingToGong':
          _$EnumTwelveGongEnumMap[instance.bodyCountingToGong]!,
      'islifeGongBySunRealTimeLocation':
          instance.islifeGongBySunRealTimeLocation,
    };

const _$CelestialCoordinateSystemEnumMap = {
  CelestialCoordinateSystem.ecliptic: '黄道制',
  CelestialCoordinateSystem.equatorial: '赤道制',
  CelestialCoordinateSystem.skyEquatorial: '天赤道制',
  CelestialCoordinateSystem.pseudoEcliptic: '似黄道恒星制',
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
  PanelSystemType.tropical: '回归制',
  PanelSystemType.sidereal: '恒星制',
};

const _$ConstellationSystemTypeEnumMap = {
  ConstellationSystemType.classical: '古宿制',
  ConstellationSystemType.adjustedClassical: '矫正古宿制',
  ConstellationSystemType.modern: '今宿制',
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

FatePanelConfig _$FatePanelConfigFromJson(Map<String, dynamic> json) =>
    FatePanelConfig(
      mingCountingType: $enumDecode(
          _$DongWeiDaXianMingGongCountingTypeEnumMap, json['mingCountingType']),
    );

Map<String, dynamic> _$FatePanelConfigToJson(FatePanelConfig instance) =>
    <String, dynamic>{
      'mingCountingType': _$DongWeiDaXianMingGongCountingTypeEnumMap[
          instance.mingCountingType]!,
    };

const _$DongWeiDaXianMingGongCountingTypeEnumMap = {
  DongWeiDaXianMingGongCountingType.HundredSix: 'hundredSix',
  DongWeiDaXianMingGongCountingType.Ancient: 'Ancient',
  DongWeiDaXianMingGongCountingType.Modern: 'Modern',
};

PanelConfig _$PanelConfigFromJson(Map<String, dynamic> json) => PanelConfig(
      celestialCoordinateSystem: $enumDecode(_$CelestialCoordinateSystemEnumMap,
          json['celestialCoordinateSystem']),
      houseDivisionSystem: $enumDecode(
          _$HouseDivisionSystemEnumMap, json['houseDivisionSystem']),
      panelSystemType:
          $enumDecode(_$PanelSystemTypeEnumMap, json['panelSystemType']),
      constellationSystemType: $enumDecode(
          _$ConstellationSystemTypeEnumMap, json['constellationSystemType']),
      settleLifeType:
          $enumDecode(_$EnumSettleLifeTypeEnumMap, json['settleLifeType']),
      settleBodyType:
          $enumDecode(_$EnumSettleBodyTypeEnumMap, json['settleBodyType']),
      islifeGongBySunRealTimeLocation:
          json['islifeGongBySunRealTimeLocation'] as bool,
      lifeCountingToGong: $enumDecodeNullable(
              _$EnumTwelveGongEnumMap, json['lifeCountingToGong']) ??
          EnumTwelveGong.Mao,
      bodyCountingToGong: $enumDecodeNullable(
              _$EnumTwelveGongEnumMap, json['bodyCountingToGong']) ??
          EnumTwelveGong.You,
    );

Map<String, dynamic> _$PanelConfigToJson(PanelConfig instance) =>
    <String, dynamic>{
      'celestialCoordinateSystem': _$CelestialCoordinateSystemEnumMap[
          instance.celestialCoordinateSystem]!,
      'panelSystemType': _$PanelSystemTypeEnumMap[instance.panelSystemType]!,
      'constellationSystemType':
          _$ConstellationSystemTypeEnumMap[instance.constellationSystemType]!,
      'houseDivisionSystem':
          _$HouseDivisionSystemEnumMap[instance.houseDivisionSystem]!,
      'settleLifeType': _$EnumSettleLifeTypeEnumMap[instance.settleLifeType]!,
      'lifeCountingToGong':
          _$EnumTwelveGongEnumMap[instance.lifeCountingToGong]!,
      'settleBodyType': _$EnumSettleBodyTypeEnumMap[instance.settleBodyType]!,
      'bodyCountingToGong':
          _$EnumTwelveGongEnumMap[instance.bodyCountingToGong]!,
      'islifeGongBySunRealTimeLocation':
          instance.islifeGongBySunRealTimeLocation,
    };
