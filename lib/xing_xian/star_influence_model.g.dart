// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'star_influence_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PalaceStarInfluenceModel _$PalaceStarInfluenceModelFromJson(
        Map<String, dynamic> json) =>
    PalaceStarInfluenceModel(
      influenceType:
          $enumDecode(_$EnumInfluenceTypeEnumMap, json['influenceType']),
      star: $enumDecode(_$EnumStarsEnumMap, json['star']),
      location: $enumDecode(_$EnumTwelveGongEnumMap, json['location']),
      entryDegree: (json['entryDegree'] as num).toDouble(),
      degreeDiff: (json['degreeDiff'] as num?)?.toDouble() ?? 0,
      defaultRangeDegree: (json['defaultRangeDegree'] as num?)?.toDouble() ?? 0,
    );

Map<String, dynamic> _$PalaceStarInfluenceModelToJson(
        PalaceStarInfluenceModel instance) =>
    <String, dynamic>{
      'influenceType': _$EnumInfluenceTypeEnumMap[instance.influenceType]!,
      'star': _$EnumStarsEnumMap[instance.star]!,
      'location': _$EnumTwelveGongEnumMap[instance.location]!,
      'entryDegree': instance.entryDegree,
      'degreeDiff': instance.degreeDiff,
      'defaultRangeDegree': instance.defaultRangeDegree,
    };

const _$EnumInfluenceTypeEnumMap = {
  EnumInfluenceType.same: '同宫',
  EnumInfluenceType.opposite: '对宫',
  EnumInfluenceType.triangle: '三方',
  EnumInfluenceType.square: '四正',
  EnumInfluenceType.luo: '同络',
  EnumInfluenceType.jing: '同经',
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

ConstellationStarInfluenceModel _$ConstellationStarInfluenceModelFromJson(
        Map<String, dynamic> json) =>
    ConstellationStarInfluenceModel(
      influenceType: $enumDecodeNullable(
              _$EnumInfluenceTypeEnumMap, json['influenceType']) ??
          EnumInfluenceType.jing,
      star: $enumDecode(_$EnumStarsEnumMap, json['star']),
      location: $enumDecode(_$Enum28ConstellationsEnumMap, json['location']),
      entryDegree: (json['entryDegree'] as num).toDouble(),
      inSameConstellation: json['inSameConstellation'] as bool? ?? false,
    );

Map<String, dynamic> _$ConstellationStarInfluenceModelToJson(
        ConstellationStarInfluenceModel instance) =>
    <String, dynamic>{
      'influenceType': _$EnumInfluenceTypeEnumMap[instance.influenceType]!,
      'star': _$EnumStarsEnumMap[instance.star]!,
      'location': _$Enum28ConstellationsEnumMap[instance.location]!,
      'entryDegree': instance.entryDegree,
      'inSameConstellation': instance.inSameConstellation,
    };

const _$Enum28ConstellationsEnumMap = {
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
};

DingStarInfluenceModel _$DingStarInfluenceModelFromJson(
        Map<String, dynamic> json) =>
    DingStarInfluenceModel(
      influenceType:
          $enumDecode(_$EnumInfluenceTypeEnumMap, json['influenceType']),
      star: $enumDecode(_$EnumStarsEnumMap, json['star']),
      location: $enumDecode(_$EnumTwelveGongEnumMap, json['location']),
      entryDegree: (json['entryDegree'] as num).toDouble(),
      degreeDiff: (json['degreeDiff'] as num).toDouble(),
      defaultRangeDegree: (json['defaultRangeDegree'] as num).toDouble(),
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: DateTime.parse(json['endTime'] as String),
      startAge: YearMonth.fromJson(json['startAge'] as Map<String, dynamic>),
      endAge: YearMonth.fromJson(json['endAge'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$DingStarInfluenceModelToJson(
        DingStarInfluenceModel instance) =>
    <String, dynamic>{
      'influenceType': _$EnumInfluenceTypeEnumMap[instance.influenceType]!,
      'star': _$EnumStarsEnumMap[instance.star]!,
      'location': _$EnumTwelveGongEnumMap[instance.location]!,
      'entryDegree': instance.entryDegree,
      'degreeDiff': instance.degreeDiff,
      'defaultRangeDegree': instance.defaultRangeDegree,
      'startTime': instance.startTime.toIso8601String(),
      'endTime': instance.endTime.toIso8601String(),
      'startAge': instance.startAge,
      'endAge': instance.endAge,
    };
