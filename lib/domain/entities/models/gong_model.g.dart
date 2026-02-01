// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gong_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GongModel _$GongModelFromJson(Map<String, dynamic> json) => GongModel(
      gong: $enumDecode(_$EnumTwelveGongEnumMap, json['gong']),
      destinyGong:
          $enumDecode(_$EnumDestinyTwelveGongEnumMap, json['destinyGong']),
      enteredStars: (json['enteredStars'] as List<dynamic>)
          .map((e) => ElevenStarsInfo.fromJson(e as Map<String, dynamic>))
          .toList(),
      masterStars:
          ElevenStarsInfo.fromJson(json['masterStars'] as Map<String, dynamic>),
      zhangSheng: $enumDecode(_$TwelveZhangShengEnumMap, json['zhangSheng']),
      beforeTaiSuiCirclingSha: $enumDecode(
          _$EnumBeforeTaiSuiShenShaEnumMap, json['beforeTaiSuiCirclingSha']),
      afterTaiSuiCirclingSha: $enumDecode(
          _$EnumAfterTaiSuiShenShaEnumMap, json['afterTaiSuiCirclingSha']),
      diZhiShenShaSet: (json['diZhiShenShaSet'] as List<dynamic>)
          .map((e) => DiZhiShenSha.fromJson(e as Map<String, dynamic>))
          .toSet(),
      tianGanShenShaSet: (json['tianGanShenShaSet'] as List<dynamic>)
          .map((e) => TianGanShenSha.fromJson(e as Map<String, dynamic>))
          .toSet(),
      otherShenShaSet: (json['otherShenShaSet'] as List<dynamic>)
          .map((e) => ShenSha.fromJson(e as Map<String, dynamic>))
          .toSet(),
    );

Map<String, dynamic> _$GongModelToJson(GongModel instance) => <String, dynamic>{
      'gong': _$EnumTwelveGongEnumMap[instance.gong]!,
      'destinyGong': _$EnumDestinyTwelveGongEnumMap[instance.destinyGong]!,
      'enteredStars': instance.enteredStars,
      'masterStars': instance.masterStars,
      'zhangSheng': _$TwelveZhangShengEnumMap[instance.zhangSheng]!,
      'beforeTaiSuiCirclingSha':
          _$EnumBeforeTaiSuiShenShaEnumMap[instance.beforeTaiSuiCirclingSha]!,
      'afterTaiSuiCirclingSha':
          _$EnumAfterTaiSuiShenShaEnumMap[instance.afterTaiSuiCirclingSha]!,
      'tianGanShenShaSet': instance.tianGanShenShaSet.toList(),
      'diZhiShenShaSet': instance.diZhiShenShaSet.toList(),
      'otherShenShaSet': instance.otherShenShaSet.toList(),
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

const _$EnumDestinyTwelveGongEnumMap = {
  EnumDestinyTwelveGong.Ming: '命宫',
  EnumDestinyTwelveGong.CaiBo: '财帛',
  EnumDestinyTwelveGong.XiongDi: '兄弟',
  EnumDestinyTwelveGong.TianZhai: '田宅',
  EnumDestinyTwelveGong.NanNv: '男女',
  EnumDestinyTwelveGong.NuPu: '奴仆',
  EnumDestinyTwelveGong.FuQi: '夫妻',
  EnumDestinyTwelveGong.JiE: '疾厄',
  EnumDestinyTwelveGong.QianYi: '迁移',
  EnumDestinyTwelveGong.GuanLu: '官禄',
  EnumDestinyTwelveGong.FuDe: '福德',
  EnumDestinyTwelveGong.XiangMao: '相貌',
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

const _$EnumBeforeTaiSuiShenShaEnumMap = {
  EnumBeforeTaiSuiShenSha.JianFeng: 'JianFeng',
  EnumBeforeTaiSuiShenSha.FuShi: 'FuShi',
  EnumBeforeTaiSuiShenSha.SuiJia: 'SuiJia',
  EnumBeforeTaiSuiShenSha.TianKong: 'TianKong',
  EnumBeforeTaiSuiShenSha.TaiYang: 'TaiYang',
  EnumBeforeTaiSuiShenSha.DiCi: 'DiCi',
  EnumBeforeTaiSuiShenSha.SangMen: 'SangMen',
  EnumBeforeTaiSuiShenSha.DiSang: 'DiSang',
  EnumBeforeTaiSuiShenSha.TaiYin: 'TaiYin',
  EnumBeforeTaiSuiShenSha.GouShen: 'GouShen',
  EnumBeforeTaiSuiShenSha.GuanSuo: 'GuanSuo',
  EnumBeforeTaiSuiShenSha.GuanFu: 'GuanFu',
  EnumBeforeTaiSuiShenSha.FeiFu: 'FeiFu',
  EnumBeforeTaiSuiShenSha.NianFu: 'NianFu',
  EnumBeforeTaiSuiShenSha.WuGui: 'WuGui',
  EnumBeforeTaiSuiShenSha.WuShen: 'WuShen',
  EnumBeforeTaiSuiShenSha.SiFu: 'SiFu',
  EnumBeforeTaiSuiShenSha.XiaoHao: 'XiaoHao',
  EnumBeforeTaiSuiShenSha.DaHao: 'DaHao',
  EnumBeforeTaiSuiShenSha.SuiPo: 'SuiPo',
  EnumBeforeTaiSuiShenSha.LanGan: 'LanGan',
  EnumBeforeTaiSuiShenSha.LongDe: 'LongDe',
  EnumBeforeTaiSuiShenSha.ZiWei: 'ZiWei',
  EnumBeforeTaiSuiShenSha.BaoBai: 'BaoBai',
  EnumBeforeTaiSuiShenSha.TianE: 'TianE',
  EnumBeforeTaiSuiShenSha.TianXiong: 'TianXiong',
  EnumBeforeTaiSuiShenSha.BaiHu: 'BaiHu',
  EnumBeforeTaiSuiShenSha.TianDe: 'TianDe',
  EnumBeforeTaiSuiShenSha.JuanShe: 'JuanShe',
  EnumBeforeTaiSuiShenSha.JiaoSha: 'JiaoSha',
  EnumBeforeTaiSuiShenSha.TianGou: 'TianGou',
  EnumBeforeTaiSuiShenSha.DiaoKe: 'DiaoKe',
  EnumBeforeTaiSuiShenSha.BingFu: 'BingFu',
  EnumBeforeTaiSuiShenSha.MoYue: 'MoYue',
};

const _$EnumAfterTaiSuiShenShaEnumMap = {
  EnumAfterTaiSuiShenSha.HongLuan: 'HongLuan',
  EnumAfterTaiSuiShenSha.TianXi: 'TianXi',
  EnumAfterTaiSuiShenSha.XueRen: 'XueRen',
  EnumAfterTaiSuiShenSha.FuChen: 'FuChen',
  EnumAfterTaiSuiShenSha.JieShen: 'JieShen',
  EnumAfterTaiSuiShenSha.TianKu: 'TianKu',
  EnumAfterTaiSuiShenSha.PiTou: 'PiTou',
};
