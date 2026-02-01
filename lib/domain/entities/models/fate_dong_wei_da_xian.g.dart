// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fate_dong_wei_da_xian.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DaXianGong _$DaXianGongFromJson(Map<String, dynamic> json) => DaXianGong(
      order: (json['order'] as num).toInt(),
      destinyGong:
          $enumDecode(_$EnumDestinyTwelveGongEnumMap, json['destinyGong']),
      gong: $enumDecode(_$EnumTwelveGongEnumMap, json['gong']),
      start: YearMonth.fromJson(json['start'] as Map<String, dynamic>),
      end: YearMonth.fromJson(json['end'] as Map<String, dynamic>),
      totalYears:
          YearMonth.fromJson(json['totalYears'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$DaXianGongToJson(DaXianGong instance) =>
    <String, dynamic>{
      'order': instance.order,
      'destinyGong': _$EnumDestinyTwelveGongEnumMap[instance.destinyGong]!,
      'gong': _$EnumTwelveGongEnumMap[instance.gong]!,
      'start': instance.start,
      'end': instance.end,
      'totalYears': instance.totalYears,
    };

const _$EnumDestinyTwelveGongEnumMap = {
  EnumDestinyTwelveGong.Ming: '命宫',
  EnumDestinyTwelveGong.CaiBo: '财帛',
  EnumDestinyTwelveGong.XiongDi: '兄弟',
  EnumDestinyTwelveGong.TianZhai: '田宅',
  EnumDestinyTwelveGong.NanNv: '男女',
  EnumDestinyTwelveGong.NuPu: '奴仆',
  EnumDestinyTwelveGong.FuQi: '夫妻',
  EnumDestinyTwelveGong.JiE: '疾厄',
  EnumDestinyTwelveGong.QianYi: '迁移',
  EnumDestinyTwelveGong.GuanLu: '官禄',
  EnumDestinyTwelveGong.FuDe: '福德',
  EnumDestinyTwelveGong.XiangMao: '相貌',
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

DaXianFeiXianGong _$DaXianFeiXianGongFromJson(Map<String, dynamic> json) =>
    DaXianFeiXianGong(
      order: (json['order'] as num).toInt(),
      gong: $enumDecode(_$EnumTwelveGongEnumMap, json['gong']),
      start: YearMonth.fromJson(json['start'] as Map<String, dynamic>),
      end: YearMonth.fromJson(json['end'] as Map<String, dynamic>),
      totalYears:
          YearMonth.fromJson(json['totalYears'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$DaXianFeiXianGongToJson(DaXianFeiXianGong instance) =>
    <String, dynamic>{
      'order': instance.order,
      'gong': _$EnumTwelveGongEnumMap[instance.gong]!,
      'start': instance.start,
      'end': instance.end,
      'totalYears': instance.totalYears,
    };

DongWeiFate _$DongWeiFateFromJson(Map<String, dynamic> json) => DongWeiFate(
      type:
          $enumDecode(_$DongWeiDaXianMingGongCountingTypeEnumMap, json['type']),
      daXianGongs: (json['daXianGongs'] as List<dynamic>)
          .map((e) => DaXianGong.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$DongWeiFateToJson(DongWeiFate instance) =>
    <String, dynamic>{
      'type': _$DongWeiDaXianMingGongCountingTypeEnumMap[instance.type]!,
      'daXianGongs': instance.daXianGongs,
    };

const _$DongWeiDaXianMingGongCountingTypeEnumMap = {
  DongWeiDaXianMingGongCountingType.HundredSix: 'hundredSix',
  DongWeiDaXianMingGongCountingType.Ancient: 'Ancient',
  DongWeiDaXianMingGongCountingType.Modern: 'Modern',
};
