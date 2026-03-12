// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'yuan_le_panel_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

YuanLePanel _$YuanLePanelFromJson(Map<String, dynamic> json) => YuanLePanel(
      natalStars: (json['natalStars'] as List<dynamic>)
          .map((e) => YuanLeStarInfo.fromJson(e as Map<String, dynamic>))
          .toList(),
      transitStars: (json['transitStars'] as List<dynamic>?)
          ?.map((e) => YuanLeStarInfo.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$YuanLePanelToJson(YuanLePanel instance) =>
    <String, dynamic>{
      'natalStars': instance.natalStars,
      'transitStars': instance.transitStars,
    };

YuanLeStarInfo _$YuanLeStarInfoFromJson(Map<String, dynamic> json) =>
    YuanLeStarInfo(
      star: $enumDecode(_$EnumStarsEnumMap, json['star']),
      constellationName: json['constellationName'] as String,
      degree: (json['degree'] as num).toDouble(),
      minutes: (json['minutes'] as num).toInt(),
      gongDegree: (json['gongDegree'] as num).toDouble(),
      gongName: json['gongName'] as String,
      positionStatus: $enumDecodeNullable(
          _$EnumStarGongPositionStatusTypeEnumMap, json['positionStatus']),
      walkingStatus: json['walkingStatus'] as String?,
      isBodyLifeMaster: json['isBodyLifeMaster'] as bool? ?? false,
      label: json['label'] as String? ?? '',
    );

Map<String, dynamic> _$YuanLeStarInfoToJson(YuanLeStarInfo instance) =>
    <String, dynamic>{
      'star': _$EnumStarsEnumMap[instance.star]!,
      'constellationName': instance.constellationName,
      'degree': instance.degree,
      'minutes': instance.minutes,
      'positionStatus':
          _$EnumStarGongPositionStatusTypeEnumMap[instance.positionStatus],
      'walkingStatus': instance.walkingStatus,
      'isBodyLifeMaster': instance.isBodyLifeMaster,
      'label': instance.label,
      'gongDegree': instance.gongDegree,
      'gongName': instance.gongName,
    };

const _$EnumStarsEnumMap = {
  EnumStars.Sun: '日',
  EnumStars.Moon: '月',
  EnumStars.Mercury: '水',
  EnumStars.Mars: '火',
  EnumStars.Saturn: '土',
  EnumStars.Venus: '金',
  EnumStars.Jupiter: '木',
  EnumStars.Qi: '炁',
  EnumStars.Luo: '罗',
  EnumStars.Ji: '计',
  EnumStars.Bei: '孛',
};

const _$EnumStarGongPositionStatusTypeEnumMap = {
  EnumStarGongPositionStatusType.Miao: '庙',
  EnumStarGongPositionStatusType.Wang: '旺',
  EnumStarGongPositionStatusType.Xi: '喜',
  EnumStarGongPositionStatusType.Le: '乐',
  EnumStarGongPositionStatusType.Nu: '怒',
  EnumStarGongPositionStatusType.Xian: '凶',
  EnumStarGongPositionStatusType.Zheng: '正',
  EnumStarGongPositionStatusType.Pian: '偏',
  EnumStarGongPositionStatusType.Yuan: '垣',
  EnumStarGongPositionStatusType.Dian: '殿',
  EnumStarGongPositionStatusType.Xiong: '凶',
  EnumStarGongPositionStatusType.Gui: '贵',
};
