// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'projection_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProjectionConfig _$ProjectionConfigFromJson(Map<String, dynamic> json) =>
    ProjectionConfig(
      strategy: $enumDecode(_$MappingStrategyEnumMap, json['strategy']),
      offset: (json['offset'] as num?)?.toDouble(),
      sourceTotal: (json['sourceTotal'] as num?)?.toDouble(),
      sourcePoints: (json['sourcePoints'] as List<dynamic>?)
          ?.map((e) => (e as num).toDouble())
          .toList(),
      targetPoints: (json['targetPoints'] as List<dynamic>?)
          ?.map((e) => (e as num).toDouble())
          .toList(),
      huangChiDaoDiffType: $enumDecodeNullable(
        _$HuangChiDaoDiffTypeEnumMap,
        json['huangChiDaoDiffType'],
      ),
      epsilonDeg: (json['epsilonDeg'] as num?)?.toDouble(),
      springEquinoxAnchor: (json['springEquinoxAnchor'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$ProjectionConfigToJson(ProjectionConfig instance) =>
    <String, dynamic>{
      'strategy': _$MappingStrategyEnumMap[instance.strategy]!,
      'offset': instance.offset,
      'sourceTotal': instance.sourceTotal,
      'sourcePoints': instance.sourcePoints,
      'targetPoints': instance.targetPoints,
      'huangChiDaoDiffType':
          _$HuangChiDaoDiffTypeEnumMap[instance.huangChiDaoDiffType],
      'epsilonDeg': instance.epsilonDeg,
      'springEquinoxAnchor': instance.springEquinoxAnchor,
    };

const _$MappingStrategyEnumMap = {
  MappingStrategy.linear: 'linear',
  MappingStrategy.piecewise: 'piecewise',
  MappingStrategy.tuiBianHuangDao: 'tuiBianHuangDao',
};

const _$HuangChiDaoDiffTypeEnumMap = {
  HuangChiDaoDiffType.daren: 'daren',
  HuangChiDaoDiffType.jiyuan: 'jiyuan',
  HuangChiDaoDiffType.shoushi: 'shoushi',
  HuangChiDaoDiffType.hushi: 'hushi',
};
