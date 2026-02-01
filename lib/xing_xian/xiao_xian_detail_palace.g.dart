// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'xiao_xian_detail_palace.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

XiaoXianDetailPalace _$XiaoXianDetailPalaceFromJson(
        Map<String, dynamic> json) =>
    XiaoXianDetailPalace(
      order: (json['order'] as num).toInt(),
      palace: $enumDecode(_$EnumTwelveGongEnumMap, json['palace']),
      startAge: YearMonth.fromJson(json['startAge'] as Map<String, dynamic>),
      endAge: YearMonth.fromJson(json['endAge'] as Map<String, dynamic>),
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: DateTime.parse(json['endTime'] as String),
      durationYears:
          YearMonth.fromJson(json['durationYears'] as Map<String, dynamic>),
      constellationPassages: (json['constellationPassages'] as List<dynamic>)
          .map((e) => DaXianConstellationPassageInfo.fromJson(
              e as Map<String, dynamic>))
          .toList(),
      totalGongDegreee: (json['totalGongDegreee'] as num).toDouble(),
      xingXianType: $enumDecodeNullable(
              _$EnumXingXianTypeEnumMap, json['xingXianType']) ??
          EnumXingXianType.yang9,
    );

Map<String, dynamic> _$XiaoXianDetailPalaceToJson(
        XiaoXianDetailPalace instance) =>
    <String, dynamic>{
      'order': instance.order,
      'palace': _$EnumTwelveGongEnumMap[instance.palace]!,
      'startAge': instance.startAge,
      'endAge': instance.endAge,
      'startTime': instance.startTime.toIso8601String(),
      'endTime': instance.endTime.toIso8601String(),
      'durationYears': instance.durationYears,
      'totalGongDegreee': instance.totalGongDegreee,
      'constellationPassages': instance.constellationPassages,
      'xingXianType': _$EnumXingXianTypeEnumMap[instance.xingXianType]!,
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

const _$EnumXingXianTypeEnumMap = {
  EnumXingXianType.daXian: 'daXian',
  EnumXingXianType.xian106: 'xian106',
  EnumXingXianType.feiXian: 'feiXian',
  EnumXingXianType.yang9: 'yang9',
};
