// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'di_zhi_shen_sha.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MonthDiZhiShenSha _$MonthDiZhiShenShaFromJson(Map<String, dynamic> json) =>
    MonthDiZhiShenSha(
      json['name'] as String,
      $enumDecode(_$JiXiongEnumEnumMap, json['jiXiong']),
      (json['descriptionList'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      (json['locationDescriptionList'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      (json['locationMapper'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(
            $enumDecode(_$DiZhiEnumMap, k), $enumDecode(_$DiZhiEnumMap, e)),
      ),
    );

Map<String, dynamic> _$MonthDiZhiShenShaToJson(MonthDiZhiShenSha instance) =>
    <String, dynamic>{
      'name': instance.name,
      'jiXiong': _$JiXiongEnumEnumMap[instance.jiXiong]!,
      'descriptionList': instance.descriptionList,
      'locationDescriptionList': instance.locationDescriptionList,
      'locationMapper': instance.locationMapper
          .map((k, e) => MapEntry(_$DiZhiEnumMap[k]!, _$DiZhiEnumMap[e]!)),
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

YearDiZhiShenSha _$YearDiZhiShenShaFromJson(Map<String, dynamic> json) =>
    YearDiZhiShenSha(
      json['name'] as String,
      $enumDecode(_$JiXiongEnumEnumMap, json['jiXiong']),
      (json['descriptionList'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      (json['locationDescriptionList'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      (json['locationMapper'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(
            $enumDecode(_$DiZhiEnumMap, k), $enumDecode(_$DiZhiEnumMap, e)),
      ),
    );

Map<String, dynamic> _$YearDiZhiShenShaToJson(YearDiZhiShenSha instance) =>
    <String, dynamic>{
      'name': instance.name,
      'jiXiong': _$JiXiongEnumEnumMap[instance.jiXiong]!,
      'descriptionList': instance.descriptionList,
      'locationDescriptionList': instance.locationDescriptionList,
      'locationMapper': instance.locationMapper
          .map((k, e) => MapEntry(_$DiZhiEnumMap[k]!, _$DiZhiEnumMap[e]!)),
    };

JiaZiShenSha _$JiaZiShenShaFromJson(Map<String, dynamic> json) => JiaZiShenSha(
      json['name'] as String,
      $enumDecode(_$JiXiongEnumEnumMap, json['jiXiong']),
      (json['descriptionList'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      (json['locationDescriptionList'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      (json['locationMapper'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(
            $enumDecode(_$JiaZiEnumMap, k),
            (e as List<dynamic>)
                .map((e) => $enumDecode(_$DiZhiEnumMap, e))
                .toSet()),
      ),
    );

Map<String, dynamic> _$JiaZiShenShaToJson(JiaZiShenSha instance) =>
    <String, dynamic>{
      'name': instance.name,
      'jiXiong': _$JiXiongEnumEnumMap[instance.jiXiong]!,
      'descriptionList': instance.descriptionList,
      'locationDescriptionList': instance.locationDescriptionList,
      'locationMapper': instance.locationMapper.map((k, e) => MapEntry(
          _$JiaZiEnumMap[k]!, e.map((e) => _$DiZhiEnumMap[e]!).toList())),
    };

const _$JiaZiEnumMap = {
  JiaZi.JIA_ZI: '甲子',
  JiaZi.YI_CHOU: '乙丑',
  JiaZi.BING_YIN: '丙寅',
  JiaZi.DING_MAO: '丁卯',
  JiaZi.WU_CHEN: '戊辰',
  JiaZi.JI_SI: '己巳',
  JiaZi.GENG_WU: '庚午',
  JiaZi.XIN_WEI: '辛未',
  JiaZi.REN_SHEN: '壬申',
  JiaZi.GUI_YOU: '癸酉',
  JiaZi.JIA_XU: '甲戌',
  JiaZi.YI_HAI: '乙亥',
  JiaZi.BING_ZI: '丙子',
  JiaZi.DING_CHOU: '丁丑',
  JiaZi.WU_YIN: '戊寅',
  JiaZi.JI_MAO: '己卯',
  JiaZi.GENG_CHEN: '庚辰',
  JiaZi.XIN_SI: '辛巳',
  JiaZi.REN_WU: '壬午',
  JiaZi.GUI_WEI: '癸未',
  JiaZi.JIA_SHEN: '甲申',
  JiaZi.YI_YOU: '乙酉',
  JiaZi.BING_XU: '丙戌',
  JiaZi.DING_HAI: '丁亥',
  JiaZi.WU_ZI: '戊子',
  JiaZi.JI_CHOU: '己丑',
  JiaZi.GENG_YIN: '庚寅',
  JiaZi.XIN_MAO: '辛卯',
  JiaZi.REN_CHEN: '壬辰',
  JiaZi.GUI_SI: '癸巳',
  JiaZi.JIA_WU: '甲午',
  JiaZi.YI_WEI: '乙未',
  JiaZi.BING_SHEN: '丙申',
  JiaZi.DING_YOU: '丁酉',
  JiaZi.WU_XU: '戊戌',
  JiaZi.JI_HAI: '己亥',
  JiaZi.GENG_ZI: '庚子',
  JiaZi.XIN_CHOU: '辛丑',
  JiaZi.REN_YIN: '壬寅',
  JiaZi.GUI_MAO: '癸卯',
  JiaZi.JIA_CHEN: '甲辰',
  JiaZi.YI_SI: '乙巳',
  JiaZi.BING_WU: '丙午',
  JiaZi.DING_WEI: '丁未',
  JiaZi.WU_SHEN: '戊申',
  JiaZi.JI_YOU: '己酉',
  JiaZi.GENG_XU: '庚戌',
  JiaZi.XIN_HAI: '辛亥',
  JiaZi.REN_ZI: '壬子',
  JiaZi.GUI_CHOU: '癸丑',
  JiaZi.JIA_YIN: '甲寅',
  JiaZi.YI_MAO: '乙卯',
  JiaZi.BING_CHEN: '丙辰',
  JiaZi.DING_SI: '丁巳',
  JiaZi.WU_WU: '戊午',
  JiaZi.JI_WEI: '己未',
  JiaZi.GENG_SHEN: '庚申',
  JiaZi.XIN_YOU: '辛酉',
  JiaZi.REN_XU: '壬戌',
  JiaZi.GUI_HAI: '癸亥',
};
