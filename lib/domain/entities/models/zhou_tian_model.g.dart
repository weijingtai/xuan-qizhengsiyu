// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'zhou_tian_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ZhouTianModel _$ZhouTianModelFromJson(Map<String, dynamic> json) =>
    ZhouTianModel(
      systemType:
          $enumDecode(_$CelestialCoordinateSystemEnumMap, json['systemType']),
      constellationSystemType: $enumDecode(
          _$ConstellationSystemTypeEnumMap, json['constellationSystemType']),
      panelSystemType:
          $enumDecode(_$PanelSystemTypeEnumMap, json['panelSystemType']),
      epochCorrection: json['epochCorrection'] as String,
      totalDegree: (json['totalDegree'] as num).toDouble(),
      gongDegreeSeq: (json['gongDegreeSeq'] as List<dynamic>)
          .map((e) => GongDegree.fromJson(e as Map<String, dynamic>))
          .toList(),
      starInnDegreeSeq: (json['starInnDegreeSeq'] as List<dynamic>)
          .map((e) => ConstellationDegree.fromJson(e as Map<String, dynamic>))
          .toList(),
      alignmentPointAtConstellation: ConstellationDegree.fromJson(
          json['alignmentPointAtConstellation'] as Map<String, dynamic>),
      alignmentPointAtGong: GongDegree.fromJson(
          json['alignmentPointAtGong'] as Map<String, dynamic>),
      zeroPointJieQi:
          $enumDecode(_$TwentyFourJieQiEnumMap, json['zeroPointJieQi']),
      zeroPointAtConstellation: ConstellationDegree.fromJson(
          json['zeroPointAtConstellation'] as Map<String, dynamic>),
      zeroPointAtGong:
          GongDegree.fromJson(json['zeroPointAtGong'] as Map<String, dynamic>),
      celestialLongitude: (json['celestialLongitude'] as num).toDouble(),
      zeroPointOffsetToNow: (json['zeroPointOffsetToNow'] as num).toDouble(),
      rightAscension: (json['rightAscension'] as num).toDouble(),
      specificationList: (json['specificationList'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      gongOrder: (json['gongOrder'] as List<dynamic>)
          .map((e) => $enumDecode(_$EnumTwelveGongEnumMap, e))
          .toList(),
      starInnOrder: (json['starInnOrder'] as List<dynamic>)
          .map((e) => $enumDecode(_$Enum28ConstellationsEnumMap, e))
          .toList(),
    );

Map<String, dynamic> _$ZhouTianModelToJson(ZhouTianModel instance) =>
    <String, dynamic>{
      'systemType': _$CelestialCoordinateSystemEnumMap[instance.systemType]!,
      'constellationSystemType':
          _$ConstellationSystemTypeEnumMap[instance.constellationSystemType]!,
      'panelSystemType': _$PanelSystemTypeEnumMap[instance.panelSystemType]!,
      'epochCorrection': instance.epochCorrection,
      'totalDegree': instance.totalDegree,
      'gongDegreeSeq': instance.gongDegreeSeq,
      'starInnDegreeSeq': instance.starInnDegreeSeq,
      'alignmentPointAtConstellation': instance.alignmentPointAtConstellation,
      'alignmentPointAtGong': instance.alignmentPointAtGong,
      'zeroPointJieQi': _$TwentyFourJieQiEnumMap[instance.zeroPointJieQi]!,
      'zeroPointAtConstellation': instance.zeroPointAtConstellation,
      'zeroPointAtGong': instance.zeroPointAtGong,
      'celestialLongitude': instance.celestialLongitude,
      'zeroPointOffsetToNow': instance.zeroPointOffsetToNow,
      'rightAscension': instance.rightAscension,
      'gongOrder':
          instance.gongOrder.map((e) => _$EnumTwelveGongEnumMap[e]!).toList(),
      'starInnOrder': instance.starInnOrder
          .map((e) => _$Enum28ConstellationsEnumMap[e]!)
          .toList(),
      'specificationList': instance.specificationList,
    };

const _$CelestialCoordinateSystemEnumMap = {
  CelestialCoordinateSystem.ecliptic: '黄道制',
  CelestialCoordinateSystem.equatorial: '赤道制',
  CelestialCoordinateSystem.skyEquatorial: '天赤道制',
  CelestialCoordinateSystem.pseudoEcliptic: '似黄道恒星制',
};

const _$ConstellationSystemTypeEnumMap = {
  ConstellationSystemType.classical: '古宿制',
  ConstellationSystemType.adjustedClassical: '矫正古宿制',
  ConstellationSystemType.modern: '今宿制',
};

const _$PanelSystemTypeEnumMap = {
  PanelSystemType.tropical: '回归制',
  PanelSystemType.sidereal: '恒星制',
};

const _$TwentyFourJieQiEnumMap = {
  TwentyFourJieQi.DONG_ZHI: '冬至',
  TwentyFourJieQi.XIAO_HAN: '小寒',
  TwentyFourJieQi.DA_HAN: '大寒',
  TwentyFourJieQi.LI_CHUN: '立春',
  TwentyFourJieQi.YU_SHUI: '雨水',
  TwentyFourJieQi.JING_ZHE: '惊蛰',
  TwentyFourJieQi.CHUN_FEN: '春分',
  TwentyFourJieQi.QING_MING: '清明',
  TwentyFourJieQi.GU_YU: '谷雨',
  TwentyFourJieQi.LI_XIA: '立夏',
  TwentyFourJieQi.XIAO_MAN: '小满',
  TwentyFourJieQi.MANG_ZHONG: '芒种',
  TwentyFourJieQi.XIA_ZHI: '夏至',
  TwentyFourJieQi.XIAO_SHU: '小暑',
  TwentyFourJieQi.DA_SHU: '大暑',
  TwentyFourJieQi.LI_QIU: '立秋',
  TwentyFourJieQi.CHU_SHU: '处暑',
  TwentyFourJieQi.BAI_LU: '白露',
  TwentyFourJieQi.QIU_FEN: '秋分',
  TwentyFourJieQi.HAN_LU: '寒露',
  TwentyFourJieQi.SHUANG_JIANG: '霜降',
  TwentyFourJieQi.LI_DONG: '立冬',
  TwentyFourJieQi.XIAO_XUE: '小雪',
  TwentyFourJieQi.DA_XUE: '大雪',
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
