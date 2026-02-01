// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stars_angle.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BaseFiveStarWalkingInfo _$BaseFiveStarWalkingInfoFromJson(
        Map<String, dynamic> json) =>
    BaseFiveStarWalkingInfo(
      star: $enumDecode(_$EnumStarsEnumMap, json['star']),
      speed: (json['speed'] as num).toDouble(),
      walkingType:
          $enumDecode(_$FiveStarWalkingTypeEnumMap, json['walkingType']),
      threshold: StarWalkingTypeThreshold.fromJson(
          json['threshold'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$BaseFiveStarWalkingInfoToJson(
        BaseFiveStarWalkingInfo instance) =>
    <String, dynamic>{
      'star': _$EnumStarsEnumMap[instance.star]!,
      'speed': instance.speed,
      'walkingType': _$FiveStarWalkingTypeEnumMap[instance.walkingType]!,
      'threshold': instance.threshold,
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

const _$FiveStarWalkingTypeEnumMap = {
  FiveStarWalkingType.Fast: '速',
  FiveStarWalkingType.Normal: '常',
  FiveStarWalkingType.Slow: '迟',
  FiveStarWalkingType.Stay: '留',
  FiveStarWalkingType.Retrograde: '逆',
};
