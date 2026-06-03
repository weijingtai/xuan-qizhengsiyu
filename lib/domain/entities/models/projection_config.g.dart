// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'projection_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProjectionConfig _$ProjectionConfigFromJson(Map<String, dynamic> json) =>
    ProjectionConfig(
      strategy: $enumDecode(_$MappingStrategyEnumMap, json['strategy']),
      offset: (json['offset'] as num?)?.toDouble(),
      sourcePoints: (json['sourcePoints'] as List<dynamic>?)
          ?.map((e) => (e as num).toDouble())
          .toList(),
      targetPoints: (json['targetPoints'] as List<dynamic>?)
          ?.map((e) => (e as num).toDouble())
          .toList(),
    );

Map<String, dynamic> _$ProjectionConfigToJson(ProjectionConfig instance) =>
    <String, dynamic>{
      'strategy': _$MappingStrategyEnumMap[instance.strategy]!,
      'offset': instance.offset,
      'sourcePoints': instance.sourcePoints,
      'targetPoints': instance.targetPoints,
    };

const _$MappingStrategyEnumMap = {
  MappingStrategy.linear: 'linear',
  MappingStrategy.piecewise: 'piecewise',
};
