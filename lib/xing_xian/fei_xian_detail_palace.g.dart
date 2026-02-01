// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fei_xian_detail_palace.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FeiXianDetailPalace _$FeiXianDetailPalaceFromJson(Map<String, dynamic> json) =>
    FeiXianDetailPalace(
      palace: $enumDecode(_$EnumTwelveGongEnumMap, json['palace']),
      startAge: YearMonth.fromJson(json['startAge'] as Map<String, dynamic>),
      endAge: YearMonth.fromJson(json['endAge'] as Map<String, dynamic>),
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: DateTime.parse(json['endTime'] as String),
      durationYears:
          YearMonth.fromJson(json['durationYears'] as Map<String, dynamic>),
      order: (json['order'] as num).toInt(),
      feiXianGongType:
          $enumDecode(_$FeiXianGongTypeEnumMap, json['feiXianGongType']),
      triangleIndex: (json['triangleIndex'] as num?)?.toInt(),
    );

Map<String, dynamic> _$FeiXianDetailPalaceToJson(
        FeiXianDetailPalace instance) =>
    <String, dynamic>{
      'order': instance.order,
      'palace': _$EnumTwelveGongEnumMap[instance.palace]!,
      'feiXianGongType': _$FeiXianGongTypeEnumMap[instance.feiXianGongType]!,
      'triangleIndex': instance.triangleIndex,
      'startAge': instance.startAge,
      'endAge': instance.endAge,
      'startTime': instance.startTime.toIso8601String(),
      'endTime': instance.endTime.toIso8601String(),
      'durationYears': instance.durationYears,
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

const _$FeiXianGongTypeEnumMap = {
  FeiXianGongType.current: '本宫',
  FeiXianGongType.opposite: '对宫',
  FeiXianGongType.yang_triangle: '阳三合',
  FeiXianGongType.yin_triangle: '阴三合',
};
