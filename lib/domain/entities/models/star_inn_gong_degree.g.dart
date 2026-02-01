// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'star_inn_gong_degree.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ConstellationGongDegreeInfo _$ConstellationGongDegreeInfoFromJson(
        Map<String, dynamic> json) =>
    ConstellationGongDegreeInfo(
      starType: $enumDecode(_$StarPanelTypeEnumMap, json['starType']),
      starXiu: $enumDecode(_$Enum28ConstellationsEnumMap, json['starXiu']),
      degreeStartAt: (json['degreeStartAt'] as num).toDouble(),
      totalDegree: (json['totalDegree'] as num).toDouble(),
      startAtGongDegree: GongDegree.fromJson(
          json['startAtGongDegree'] as Map<String, dynamic>),
      endAtGongDegree:
          GongDegree.fromJson(json['endAtGongDegree'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ConstellationGongDegreeInfoToJson(
        ConstellationGongDegreeInfo instance) =>
    <String, dynamic>{
      'starType': _$StarPanelTypeEnumMap[instance.starType]!,
      'starXiu': _$Enum28ConstellationsEnumMap[instance.starXiu]!,
      'degreeStartAt': instance.degreeStartAt,
      'startAtGongDegree': instance.startAtGongDegree,
      'endAtGongDegree': instance.endAtGongDegree,
      'totalDegree': instance.totalDegree,
    };

const _$StarPanelTypeEnumMap = {
  StarPanelType.ZodiacTropicalOriginalClassicStarsInnSystemMapper: '黄道回归制古宿',
  StarPanelType.ZodiacTropicalCorrectedClassicStarsInnSystemMapper: '黄道回归制矫正古宿',
  StarPanelType.EquatorialSiderealStarsInnSystemMapper: '赤道恒星制',
  StarPanelType.ZodiacSiderealStarsInnSystemMapper: '黄道恒星制',
  StarPanelType.ZodiacTropicalModernStarsInnSystemMapper: '黄道回归制今宿',
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
