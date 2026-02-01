// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'da_xian_constellation_passage_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DaXianConstellationPassageInfo _$DaXianConstellationPassageInfoFromJson(
        Map<String, dynamic> json) =>
    DaXianConstellationPassageInfo(
      constellation:
          $enumDecode(_$Enum28ConstellationsEnumMap, json['constellation']),
      startDegreeInConstellation:
          (json['startDegreeInConstellation'] as num).toDouble(),
      endDegreeInConstellation:
          (json['endDegreeInConstellation'] as num).toDouble(),
      segmentAngularSpanDegrees:
          (json['segmentAngularSpanDegrees'] as num).toDouble(),
      passageDurationYears: YearMonth.fromJson(
          json['passageDurationYears'] as Map<String, dynamic>),
      entryTime: DateTime.parse(json['entryTime'] as String),
      exitTime: DateTime.parse(json['exitTime'] as String),
      entryAge: YearMonth.fromJson(json['entryAge'] as Map<String, dynamic>),
      exitAge: YearMonth.fromJson(json['exitAge'] as Map<String, dynamic>),
      constellationStarInfluences:
          (json['constellationStarInfluences'] as List<dynamic>?)
              ?.map((e) => ConstellationStarInfluenceModel.fromJson(
                  e as Map<String, dynamic>))
              .toList(),
    );

Map<String, dynamic> _$DaXianConstellationPassageInfoToJson(
        DaXianConstellationPassageInfo instance) =>
    <String, dynamic>{
      'constellation': _$Enum28ConstellationsEnumMap[instance.constellation]!,
      'startDegreeInConstellation': instance.startDegreeInConstellation,
      'endDegreeInConstellation': instance.endDegreeInConstellation,
      'segmentAngularSpanDegrees': instance.segmentAngularSpanDegrees,
      'passageDurationYears': instance.passageDurationYears,
      'entryTime': instance.entryTime.toIso8601String(),
      'exitTime': instance.exitTime.toIso8601String(),
      'entryAge': instance.entryAge,
      'exitAge': instance.exitAge,
      'constellationStarInfluences': instance.constellationStarInfluences,
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
