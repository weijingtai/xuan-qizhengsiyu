// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gong_star_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GongStarInfo _$GongStarInfoFromJson(Map<String, dynamic> json) => GongStarInfo(
      positionType:
          $enumDecode(_$StarGongPositionTypeEnumMap, json['positionType']),
      mapper: (json['mapper'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(
            $enumDecode(_$EnumTwelveGongEnumMap, k),
            (e as List<dynamic>)
                .map((e) => $enumDecode(_$EnumStarsEnumMap, e))
                .toList()),
      ),
    );

Map<String, dynamic> _$GongStarInfoToJson(GongStarInfo instance) =>
    <String, dynamic>{
      'positionType': _$StarGongPositionTypeEnumMap[instance.positionType]!,
      'mapper': instance.mapper.map((k, e) => MapEntry(
          _$EnumTwelveGongEnumMap[k]!,
          e.map((e) => _$EnumStarsEnumMap[e]!).toList())),
    };

const _$StarGongPositionTypeEnumMap = {
  StarGongPositionType.tongGong: '同宫',
  StarGongPositionType.duiGong: '对宫',
  StarGongPositionType.sanFang: '三方',
  StarGongPositionType.siZheng: '四正',
  StarGongPositionType.tongLuo: '同络',
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

ConstellationStarInfo _$ConstellationStarInfoFromJson(
        Map<String, dynamic> json) =>
    ConstellationStarInfo(
      constellationStar:
          $enumDecode(_$EnumStarsEnumMap, json['constellationStar']),
      mapper: (json['mapper'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(
            $enumDecode(_$Enum28ConstellationsEnumMap, k),
            (e as List<dynamic>)
                .map((e) => $enumDecode(_$EnumStarsEnumMap, e))
                .toList()),
      ),
      positionType: $enumDecode(
          _$StarConstellationPositionTypeEnumMap, json['positionType']),
    );

Map<String, dynamic> _$ConstellationStarInfoToJson(
        ConstellationStarInfo instance) =>
    <String, dynamic>{
      'constellationStar': _$EnumStarsEnumMap[instance.constellationStar]!,
      'positionType':
          _$StarConstellationPositionTypeEnumMap[instance.positionType]!,
      'mapper': instance.mapper.map((k, e) => MapEntry(
          _$Enum28ConstellationsEnumMap[k]!,
          e.map((e) => _$EnumStarsEnumMap[e]!).toList())),
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

const _$StarConstellationPositionTypeEnumMap = {
  StarConstellationPositionType.tongJing: '同经',
};

SameLuoStarInfo _$SameLuoStarInfoFromJson(Map<String, dynamic> json) =>
    SameLuoStarInfo(
      star: $enumDecode(_$EnumStarsEnumMap, json['star']),
      sameLuoStars: (json['sameLuoStars'] as List<dynamic>)
          .map((e) => $enumDecode(_$EnumStarsEnumMap, e))
          .toList(),
    );

Map<String, dynamic> _$SameLuoStarInfoToJson(SameLuoStarInfo instance) =>
    <String, dynamic>{
      'star': _$EnumStarsEnumMap[instance.star]!,
      'sameLuoStars':
          instance.sameLuoStars.map((e) => _$EnumStarsEnumMap[e]!).toList(),
    };
