// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ge_ju_annotation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GeJuAnnotation _$GeJuAnnotationFromJson(Map<String, dynamic> json) =>
    GeJuAnnotation(
      id: json['id'] as String,
      ruleId: json['ruleId'] as String,
      schools:
          (json['schools'] as List<dynamic>?)?.map((e) => e as String).toList(),
      source: json['source'] == null
          ? null
          : GeJuSource.fromJson(json['source'] as Map<String, dynamic>),
      authorType: json['authorType'] as String,
      version: json['version'] as String? ?? '1.0',
      description: json['description'] as String?,
      jiXiong: $enumDecodeNullable(_$JiXiongEnumEnumMap, json['jiXiong']),
      geJuType: $enumDecodeNullable(_$GeJuTypeEnumMap, json['geJuType']),
      className: json['className'] as String?,
      parentAnnotationId: json['parentAnnotationId'] as String?,
      parentMajorVersion: (json['parentMajorVersion'] as num?)?.toInt(),
      relationToParent: json['relationToParent'] as String?,
      references: (json['references'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      relatedConditionSetIds: (json['relatedConditionSetIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      visibility: json['visibility'] as String? ?? 'private',
      locale: json['locale'] as String? ?? 'zh-Hans',
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$GeJuAnnotationToJson(GeJuAnnotation instance) =>
    <String, dynamic>{
      'id': instance.id,
      'ruleId': instance.ruleId,
      'schools': instance.schools,
      'source': instance.source,
      'authorType': instance.authorType,
      'version': instance.version,
      'description': instance.description,
      'jiXiong': _$JiXiongEnumEnumMap[instance.jiXiong],
      'geJuType': _$GeJuTypeEnumMap[instance.geJuType],
      'className': instance.className,
      'parentAnnotationId': instance.parentAnnotationId,
      'parentMajorVersion': instance.parentMajorVersion,
      'relationToParent': instance.relationToParent,
      'references': instance.references,
      'relatedConditionSetIds': instance.relatedConditionSetIds,
      'visibility': instance.visibility,
      'locale': instance.locale,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
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
