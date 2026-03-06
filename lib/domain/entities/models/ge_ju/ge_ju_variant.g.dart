// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ge_ju_variant.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GeJuVariant _$GeJuVariantFromJson(Map<String, dynamic> json) => GeJuVariant(
      source: json['source'] as String,
      description: json['description'] as String,
      conditions: json['conditions'] == null
          ? null
          : GeJuCondition.fromJson(json['conditions'] as Map<String, dynamic>),
      books: json['books'] as String? ?? "",
      className: json['className'] as String? ?? '未分类',
      jiXiong: $enumDecodeNullable(_$JiXiongEnumEnumMap, json['jiXiong']) ??
          JiXiongEnum.PING,
      geJuType: $enumDecodeNullable(_$GeJuTypeEnumMap, json['geJuType']) ??
          GeJuType.pin,
      schools: (json['schools'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          ['guolao'],
    );

Map<String, dynamic> _$GeJuVariantToJson(GeJuVariant instance) =>
    <String, dynamic>{
      'source': instance.source,
      'description': instance.description,
      'conditions': instance.conditions,
      'books': instance.books,
      'className': instance.className,
      'jiXiong': _$JiXiongEnumEnumMap[instance.jiXiong]!,
      'geJuType': _$GeJuTypeEnumMap[instance.geJuType]!,
      'schools': instance.schools,
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

const _$GeJuTypeEnumMap = {
  GeJuType.pin: '贫',
  GeJuType.jian: '贱',
  GeJuType.fu: '富',
  GeJuType.gui: '贵',
  GeJuType.yao: '夭',
  GeJuType.shou: '寿',
  GeJuType.xian: '贤',
  GeJuType.yu: '愚',
  GeJuType.other: '其他',
};
