// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'da_xian_palace_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DaXianPalaceInfo _$DaXianPalaceInfoFromJson(Map<String, dynamic> json) =>
    DaXianPalaceInfo(
      order: (json['order'] as num).toInt(),
      palace: $enumDecode(_$EnumTwelveGongEnumMap, json['palace']),
      durationYears:
          YearMonth.fromJson(json['durationYears'] as Map<String, dynamic>),
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: DateTime.parse(json['endTime'] as String),
      startAge: YearMonth.fromJson(json['startAge'] as Map<String, dynamic>),
      endAge: YearMonth.fromJson(json['endAge'] as Map<String, dynamic>),
      rateYearsPerDegree: YearMonth.fromJson(
          json['rateYearsPerDegree'] as Map<String, dynamic>),
      constellationPassages: (json['constellationPassages'] as List<dynamic>)
          .map((e) => DaXianConstellationPassageInfo.fromJson(
              e as Map<String, dynamic>))
          .toList(),
      totalGongDegreee: (json['totalGongDegreee'] as num).toDouble(),
      starGongInfluence: json['starGongInfluence'] == null
          ? null
          : StarGongInfluence.fromJson(
              json['starGongInfluence'] as Map<String, dynamic>),
      dingStarMapper: (json['dingStarMapper'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(
            $enumDecode(_$EnumInfluenceTypeEnumMap, k),
            (e as List<dynamic>)
                .map((e) =>
                    DingStarInfluenceModel.fromJson(e as Map<String, dynamic>))
                .toList()),
      ),
      xingXianType: $enumDecodeNullable(
              _$EnumXingXianTypeEnumMap, json['xingXianType']) ??
          EnumXingXianType.daXian,
    );

Map<String, dynamic> _$DaXianPalaceInfoToJson(DaXianPalaceInfo instance) =>
    <String, dynamic>{
      'order': instance.order,
      'palace': _$EnumTwelveGongEnumMap[instance.palace]!,
      'durationYears': instance.durationYears,
      'startTime': instance.startTime.toIso8601String(),
      'endTime': instance.endTime.toIso8601String(),
      'startAge': instance.startAge,
      'endAge': instance.endAge,
      'rateYearsPerDegree': instance.rateYearsPerDegree,
      'constellationPassages': instance.constellationPassages,
      'totalGongDegreee': instance.totalGongDegreee,
      'starGongInfluence': instance.starGongInfluence,
      'dingStarMapper': instance.dingStarMapper
          ?.map((k, e) => MapEntry(_$EnumInfluenceTypeEnumMap[k]!, e)),
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

const _$EnumInfluenceTypeEnumMap = {
  EnumInfluenceType.same: '同宫',
  EnumInfluenceType.opposite: '对宫',
  EnumInfluenceType.triangle: '三方',
  EnumInfluenceType.square: '四正',
  EnumInfluenceType.luo: '同络',
  EnumInfluenceType.jing: '同经',
};

const _$EnumXingXianTypeEnumMap = {
  EnumXingXianType.daXian: 'daXian',
  EnumXingXianType.xian106: 'xian106',
  EnumXingXianType.feiXian: 'feiXian',
  EnumXingXianType.yang9: 'yang9',
};

StarGongInfluence _$StarGongInfluenceFromJson(Map<String, dynamic> json) =>
    StarGongInfluence(
      sameGongInfluence: (json['sameGongInfluence'] as List<dynamic>?)
          ?.map((e) =>
              PalaceStarInfluenceModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      oppositeGongInfluence: (json['oppositeGongInfluence'] as List<dynamic>?)
          ?.map((e) =>
              PalaceStarInfluenceModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      triangleGongInfluence:
          (json['triangleGongInfluence'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(
            $enumDecode(_$EnumTwelveGongEnumMap, k),
            (e as List<dynamic>)
                .map((e) => PalaceStarInfluenceModel.fromJson(
                    e as Map<String, dynamic>))
                .toList()),
      ),
      squareGongInfluence:
          (json['squareGongInfluence'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(
            $enumDecode(_$EnumTwelveGongEnumMap, k),
            (e as List<dynamic>)
                .map((e) => PalaceStarInfluenceModel.fromJson(
                    e as Map<String, dynamic>))
                .toList()),
      ),
      sameLuoInfluence:
          (json['sameLuoInfluence'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(
            $enumDecode(_$EnumTwelveGongEnumMap, k),
            (e as List<dynamic>)
                .map((e) => PalaceStarInfluenceModel.fromJson(
                    e as Map<String, dynamic>))
                .toList()),
      ),
    );

Map<String, dynamic> _$StarGongInfluenceToJson(StarGongInfluence instance) =>
    <String, dynamic>{
      'sameGongInfluence': instance.sameGongInfluence,
      'oppositeGongInfluence': instance.oppositeGongInfluence,
      'triangleGongInfluence': instance.triangleGongInfluence
          ?.map((k, e) => MapEntry(_$EnumTwelveGongEnumMap[k]!, e)),
      'squareGongInfluence': instance.squareGongInfluence
          ?.map((k, e) => MapEntry(_$EnumTwelveGongEnumMap[k]!, e)),
      'sameLuoInfluence': instance.sameLuoInfluence
          ?.map((k, e) => MapEntry(_$EnumTwelveGongEnumMap[k]!, e)),
    };
