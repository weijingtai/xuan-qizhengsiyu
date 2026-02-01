// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hua_yao.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HuaYao _$HuaYaoFromJson(Map<String, dynamic> json) => HuaYao(
      json['name'] as String,
      $enumDecode(_$JiXiongEnumEnumMap, json['jiXiong']),
      (json['descriptionList'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      (json['locationDescriptionList'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      $enumDecode(_$ShenShaTypeEnumMap, json['type']),
    );

Map<String, dynamic> _$HuaYaoToJson(HuaYao instance) => <String, dynamic>{
      'name': instance.name,
      'jiXiong': _$JiXiongEnumEnumMap[instance.jiXiong]!,
      'descriptionList': instance.descriptionList,
      'locationDescriptionList': instance.locationDescriptionList,
      'type': _$ShenShaTypeEnumMap[instance.type]!,
    };

const _$JiXiongEnumEnumMap = {
  JiXiongEnum.DA_JI: '大吉',
  JiXiongEnum.JI: '吉',
  JiXiongEnum.XIAO_JI: '小吉',
  JiXiongEnum.PING: '平',
  JiXiongEnum.XIAO_XIONG: '小凶',
  JiXiongEnum.XIONG: '凶',
  JiXiongEnum.DA_XIONG: '大凶',
  JiXiongEnum.WEI_ZHI: '未知',
};

const _$ShenShaTypeEnumMap = {
  ShenShaType.TianGan: '天干',
  ShenShaType.DiZhi_year: '年地支',
  ShenShaType.DiZhi_month: '月地支',
  ShenShaType.MingGong: '命宫',
  ShenShaType.NaYin: '纳音',
  ShenShaType.NaJia: '纳甲',
  ShenShaType.Others: '其他',
  ShenShaType.GuoLao: '果老',
};

HuaYaoItem _$HuaYaoItemFromJson(Map<String, dynamic> json) => HuaYaoItem(
      name: json['name'] as String,
      jiXiong: $enumDecode(_$JiXiongEnumEnumMap, json['jiXiong']),
      type: $enumDecode(_$ShenShaTypeEnumMap, json['type']),
    )
      ..descriptionList = (json['descriptionList'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList()
      ..locationDescriptionList =
          (json['locationDescriptionList'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList();

Map<String, dynamic> _$HuaYaoItemToJson(HuaYaoItem instance) =>
    <String, dynamic>{
      'name': instance.name,
      'jiXiong': _$JiXiongEnumEnumMap[instance.jiXiong]!,
      'descriptionList': instance.descriptionList,
      'locationDescriptionList': instance.locationDescriptionList,
      'type': _$ShenShaTypeEnumMap[instance.type]!,
    };

OthersHuaYao _$OthersHuaYaoFromJson(Map<String, dynamic> json) => OthersHuaYao(
      json['name'] as String,
      $enumDecode(_$JiXiongEnumEnumMap, json['jiXiong']),
      (json['descriptionList'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      (json['locationDescriptionList'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      $enumDecode(_$ShenShaTypeEnumMap, json['type']),
    );

Map<String, dynamic> _$OthersHuaYaoToJson(OthersHuaYao instance) =>
    <String, dynamic>{
      'name': instance.name,
      'jiXiong': _$JiXiongEnumEnumMap[instance.jiXiong]!,
      'descriptionList': instance.descriptionList,
      'locationDescriptionList': instance.locationDescriptionList,
      'type': _$ShenShaTypeEnumMap[instance.type]!,
    };

TianGanHuaYao _$TianGanHuaYaoFromJson(Map<String, dynamic> json) =>
    TianGanHuaYao(
      json['name'] as String,
      $enumDecode(_$JiXiongEnumEnumMap, json['jiXiong']),
      (json['descriptionList'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      (json['locationDescriptionList'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      $enumDecode(_$ShenShaTypeEnumMap, json['type']),
      (json['locationMapper'] as Map<String, dynamic>).map(
        (k, e) => MapEntry($enumDecode(_$TianGanEnumMap, k),
            $enumDecode(_$EnumStarsEnumMap, e)),
      ),
    );

Map<String, dynamic> _$TianGanHuaYaoToJson(TianGanHuaYao instance) =>
    <String, dynamic>{
      'name': instance.name,
      'jiXiong': _$JiXiongEnumEnumMap[instance.jiXiong]!,
      'descriptionList': instance.descriptionList,
      'locationDescriptionList': instance.locationDescriptionList,
      'type': _$ShenShaTypeEnumMap[instance.type]!,
      'locationMapper': instance.locationMapper.map(
          (k, e) => MapEntry(_$TianGanEnumMap[k]!, _$EnumStarsEnumMap[e]!)),
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

const _$TianGanEnumMap = {
  TianGan.JIA: '甲',
  TianGan.YI: '乙',
  TianGan.BING: '丙',
  TianGan.DING: '丁',
  TianGan.WU: '戊',
  TianGan.JI: '己',
  TianGan.GENG: '庚',
  TianGan.XIN: '辛',
  TianGan.REN: '壬',
  TianGan.GUI: '癸',
  TianGan.KONG_WANG: '空亡',
};

DiZhiHuaYao _$DiZhiHuaYaoFromJson(Map<String, dynamic> json) => DiZhiHuaYao(
      json['name'] as String,
      $enumDecode(_$JiXiongEnumEnumMap, json['jiXiong']),
      (json['descriptionList'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      (json['locationDescriptionList'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      $enumDecode(_$ShenShaTypeEnumMap, json['type']),
      (json['locationMapper'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(
            $enumDecode(_$DiZhiEnumMap, k), $enumDecode(_$EnumStarsEnumMap, e)),
      ),
    );

Map<String, dynamic> _$DiZhiHuaYaoToJson(DiZhiHuaYao instance) =>
    <String, dynamic>{
      'name': instance.name,
      'jiXiong': _$JiXiongEnumEnumMap[instance.jiXiong]!,
      'descriptionList': instance.descriptionList,
      'locationDescriptionList': instance.locationDescriptionList,
      'type': _$ShenShaTypeEnumMap[instance.type]!,
      'locationMapper': instance.locationMapper
          .map((k, e) => MapEntry(_$DiZhiEnumMap[k]!, _$EnumStarsEnumMap[e]!)),
    };

const _$DiZhiEnumMap = {
  DiZhi.ZI: '子',
  DiZhi.CHOU: '丑',
  DiZhi.YIN: '寅',
  DiZhi.MAO: '卯',
  DiZhi.CHEN: '辰',
  DiZhi.SI: '巳',
  DiZhi.WU: '午',
  DiZhi.WEI: '未',
  DiZhi.SHEN: '申',
  DiZhi.YOU: '酉',
  DiZhi.XU: '戌',
  DiZhi.HAI: '亥',
};

HuaYaoStarPair _$HuaYaoStarPairFromJson(Map<String, dynamic> json) =>
    HuaYaoStarPair(
      HuaYao.fromJson(json['huaYao'] as Map<String, dynamic>),
      $enumDecode(_$EnumStarsEnumMap, json['star']),
    );

Map<String, dynamic> _$HuaYaoStarPairToJson(HuaYaoStarPair instance) =>
    <String, dynamic>{
      'huaYao': instance.huaYao,
      'star': _$EnumStarsEnumMap[instance.star]!,
    };
