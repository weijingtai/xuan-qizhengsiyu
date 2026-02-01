// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'enum_qi_zheng.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StarWalkingTypeThreshold _$StarWalkingTypeThresholdFromJson(
        Map<String, dynamic> json) =>
    StarWalkingTypeThreshold(
      star: $enumDecode(_$EnumStarsEnumMap, json['star']),
      thresholdName: json['thresholdName'] as String,
      maxSpeed: (json['maxSpeed'] as num).toDouble(),
      maxRetrogradeThreshold:
          (json['maxRetrogradeThreshold'] as num).toDouble(),
      retrogradeThreshold: (json['retrogradeThreshold'] as num).toDouble(),
      stayThreshold: (json['stayThreshold'] as num).toDouble(),
      fastThreshold: (json['fastThreshold'] as num?)?.toDouble(),
      slowThreshold: (json['slowThreshold'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$StarWalkingTypeThresholdToJson(
        StarWalkingTypeThreshold instance) =>
    <String, dynamic>{
      'star': _$EnumStarsEnumMap[instance.star]!,
      'thresholdName': instance.thresholdName,
      'maxSpeed': instance.maxSpeed,
      'maxRetrogradeThreshold': instance.maxRetrogradeThreshold,
      'retrogradeThreshold': instance.retrogradeThreshold,
      'stayThreshold': instance.stayThreshold,
      'fastThreshold': instance.fastThreshold,
      'slowThreshold': instance.slowThreshold,
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
