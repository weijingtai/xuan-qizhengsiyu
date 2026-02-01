// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'da_xian_panel_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DaXianPanelModel _$DaXianPanelModelFromJson(Map<String, dynamic> json) =>
    DaXianPanelModel(
      starAngleMapper: (json['starAngleMapper'] as Map<String, dynamic>).map(
        (k, e) => MapEntry($enumDecode(_$EnumStarsEnumMap, k),
            StarAngleSpeed.fromJson(e as Map<String, dynamic>)),
      ),
      enteredGongMapper:
          (json['enteredGongMapper'] as Map<String, dynamic>).map(
        (k, e) => MapEntry($enumDecode(_$EnumStarsEnumMap, k),
            EnteredInfo.fromJson(e as Map<String, dynamic>)),
      ),
      fiveStarWalkingTypeMapper:
          (json['fiveStarWalkingTypeMapper'] as Map<String, dynamic>).map(
        (k, e) => MapEntry($enumDecode(_$EnumStarsEnumMap, k),
            BaseFiveStarWalkingInfo.fromJson(e as Map<String, dynamic>)),
      ),
      shenShaMapper: (json['shenShaMapper'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(
            $enumDecode(_$EnumTwelveGongEnumMap, k),
            (e as List<dynamic>)
                .map((e) => ShenSha.fromJson(e as Map<String, dynamic>))
                .toList()),
      ),
      huaYaoItemMapper: (json['huaYaoItemMapper'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(
            $enumDecode(_$EnumStarsEnumMap, k),
            (e as List<dynamic>)
                .map((e) => HuaYaoItem.fromJson(e as Map<String, dynamic>))
                .toList()),
      ),
      twelveZhangShengGongMapper:
          (json['twelveZhangShengGongMapper'] as Map<String, dynamic>).map(
        (k, e) => MapEntry($enumDecode(_$EnumTwelveGongEnumMap, k),
            $enumDecode(_$TwelveZhangShengEnumMap, e)),
      ),
    );

Map<String, dynamic> _$DaXianPanelModelToJson(DaXianPanelModel instance) =>
    <String, dynamic>{
      'starAngleMapper': instance.starAngleMapper
          .map((k, e) => MapEntry(_$EnumStarsEnumMap[k]!, e)),
      'enteredGongMapper': instance.enteredGongMapper
          .map((k, e) => MapEntry(_$EnumStarsEnumMap[k]!, e)),
      'fiveStarWalkingTypeMapper': instance.fiveStarWalkingTypeMapper
          .map((k, e) => MapEntry(_$EnumStarsEnumMap[k]!, e)),
      'shenShaMapper': instance.shenShaMapper
          .map((k, e) => MapEntry(_$EnumTwelveGongEnumMap[k]!, e)),
      'huaYaoItemMapper': instance.huaYaoItemMapper
          .map((k, e) => MapEntry(_$EnumStarsEnumMap[k]!, e)),
      'twelveZhangShengGongMapper': instance.twelveZhangShengGongMapper.map((k,
              e) =>
          MapEntry(_$EnumTwelveGongEnumMap[k]!, _$TwelveZhangShengEnumMap[e]!)),
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

const _$TwelveZhangShengEnumMap = {
  TwelveZhangSheng.ZHANG_SHEN: '长生',
  TwelveZhangSheng.MU_YU: '沐浴',
  TwelveZhangSheng.GUAN_DAI: '冠带',
  TwelveZhangSheng.LIN_GUAN: '临官',
  TwelveZhangSheng.DI_WANG: '帝旺',
  TwelveZhangSheng.SHUAI: '衰',
  TwelveZhangSheng.BING: '病',
  TwelveZhangSheng.SI: '死',
  TwelveZhangSheng.MU: '墓',
  TwelveZhangSheng.JUE: '绝',
  TwelveZhangSheng.TAI: '胎',
  TwelveZhangSheng.YANG: '养',
};
