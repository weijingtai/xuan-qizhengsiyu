// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gong_constellation_mapping.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ConstellationSegment _$ConstellationSegmentFromJson(
        Map<String, dynamic> json) =>
    ConstellationSegment(
      palaceName: $enumDecode(_$EnumTwelveGongEnumMap, json['palaceName']),
      startInPalaceDeg: (json['startInPalaceDeg'] as num).toDouble(),
      endInPalaceDeg: (json['endInPalaceDeg'] as num).toDouble(),
      startInConstellationDeg:
          (json['startInConstellationDeg'] as num).toDouble(),
      endInConstellationDeg: (json['endInConstellationDeg'] as num).toDouble(),
      segmentLengthDeg: (json['segmentLengthDeg'] as num).toDouble(),
      crossesPalaceAtConstellationDeg:
          (json['crossesPalaceAtConstellationDeg'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$ConstellationSegmentToJson(
        ConstellationSegment instance) =>
    <String, dynamic>{
      'palaceName': _$EnumTwelveGongEnumMap[instance.palaceName]!,
      'startInPalaceDeg': instance.startInPalaceDeg,
      'endInPalaceDeg': instance.endInPalaceDeg,
      'startInConstellationDeg': instance.startInConstellationDeg,
      'endInConstellationDeg': instance.endInConstellationDeg,
      'segmentLengthDeg': instance.segmentLengthDeg,
      'crossesPalaceAtConstellationDeg':
          instance.crossesPalaceAtConstellationDeg,
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

ConstellationMappingResult _$ConstellationMappingResultFromJson(
        Map<String, dynamic> json) =>
    ConstellationMappingResult(
      constellationName:
          $enumDecode(_$Enum28ConstellationsEnumMap, json['constellationName']),
      absStartDeg: (json['absStartDeg'] as num).toDouble(),
      absEndDeg: (json['absEndDeg'] as num).toDouble(),
      totalWidthDeg: (json['totalWidthDeg'] as num).toDouble(),
      segments: (json['segments'] as List<dynamic>)
          .map((e) => ConstellationSegment.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ConstellationMappingResultToJson(
        ConstellationMappingResult instance) =>
    <String, dynamic>{
      'constellationName':
          _$Enum28ConstellationsEnumMap[instance.constellationName]!,
      'absStartDeg': instance.absStartDeg,
      'absEndDeg': instance.absEndDeg,
      'totalWidthDeg': instance.totalWidthDeg,
      'segments': instance.segments,
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

PalaceConstellationSegment _$PalaceConstellationSegmentFromJson(
        Map<String, dynamic> json) =>
    PalaceConstellationSegment(
      constellationName:
          $enumDecode(_$Enum28ConstellationsEnumMap, json['constellationName']),
      startInConstellationDeg:
          (json['startInConstellationDeg'] as num).toDouble(),
      endInConstellationDeg: (json['endInConstellationDeg'] as num).toDouble(),
      startInPalaceDeg: (json['startInPalaceDeg'] as num).toDouble(),
      endInPalaceDeg: (json['endInPalaceDeg'] as num).toDouble(),
      segmentLengthDeg: (json['segmentLengthDeg'] as num).toDouble(),
      crossesConstellationAtPalaceDeg:
          (json['crossesConstellationAtPalaceDeg'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$PalaceConstellationSegmentToJson(
        PalaceConstellationSegment instance) =>
    <String, dynamic>{
      'constellationName':
          _$Enum28ConstellationsEnumMap[instance.constellationName]!,
      'startInConstellationDeg': instance.startInConstellationDeg,
      'endInConstellationDeg': instance.endInConstellationDeg,
      'startInPalaceDeg': instance.startInPalaceDeg,
      'endInPalaceDeg': instance.endInPalaceDeg,
      'segmentLengthDeg': instance.segmentLengthDeg,
      'crossesConstellationAtPalaceDeg':
          instance.crossesConstellationAtPalaceDeg,
    };

PalaceMappingResult _$PalaceMappingResultFromJson(Map<String, dynamic> json) =>
    PalaceMappingResult(
      palaceName: $enumDecode(_$EnumTwelveGongEnumMap, json['palaceName']),
      absStartDeg: (json['absStartDeg'] as num).toDouble(),
      absEndDeg: (json['absEndDeg'] as num).toDouble(),
      totalWidthDeg: (json['totalWidthDeg'] as num).toDouble(),
      segments: (json['segments'] as List<dynamic>)
          .map((e) =>
              PalaceConstellationSegment.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$PalaceMappingResultToJson(
        PalaceMappingResult instance) =>
    <String, dynamic>{
      'palaceName': _$EnumTwelveGongEnumMap[instance.palaceName]!,
      'absStartDeg': instance.absStartDeg,
      'absEndDeg': instance.absEndDeg,
      'totalWidthDeg': instance.totalWidthDeg,
      'segments': instance.segments,
    };
