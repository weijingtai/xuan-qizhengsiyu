// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'eleven_stars_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ElevenStarsInfo _$ElevenStarsInfoFromJson(Map<String, dynamic> json) =>
    ElevenStarsInfo(
      star: $enumDecode(_$EnumStarsEnumMap, json['star']),
      angle: (json['angle'] as num).toDouble(),
      enterInfo:
          EnteredInfo.fromJson(json['enterInfo'] as Map<String, dynamic>),
      fiveStarWalkingType: $enumDecode(
          _$FiveStarWalkingTypeEnumMap, json['fiveStarWalkingType']),
      walkingSpeed: (json['walkingSpeed'] as num).toDouble(),
      priority: $enumDecode(_$EnumStarsPriorityEnumMap, json['priority']),
    );

Map<String, dynamic> _$ElevenStarsInfoToJson(ElevenStarsInfo instance) =>
    <String, dynamic>{
      'star': _$EnumStarsEnumMap[instance.star]!,
      'angle': instance.angle,
      'enterInfo': instance.enterInfo,
      'fiveStarWalkingType':
          _$FiveStarWalkingTypeEnumMap[instance.fiveStarWalkingType]!,
      'walkingSpeed': instance.walkingSpeed,
      'priority': _$EnumStarsPriorityEnumMap[instance.priority]!,
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

const _$EnumStarsPriorityEnumMap = {
  EnumStarsPriority.Primary: 'Primary',
  EnumStarsPriority.Secondary: 'Secondary',
  EnumStarsPriority.Normal: 'Normal',
  EnumStarsPriority.Lowest: 'Lowest',
};

FiveStarsInfo _$FiveStarsInfoFromJson(Map<String, dynamic> json) =>
    FiveStarsInfo(
      star: $enumDecode(_$EnumStarsEnumMap, json['star']),
      angle: (json['angle'] as num).toDouble(),
      enterInfo:
          EnteredInfo.fromJson(json['enterInfo'] as Map<String, dynamic>),
      fiveStarWalkingType: $enumDecode(
          _$FiveStarWalkingTypeEnumMap, json['fiveStarWalkingType']),
      walkingSpeed: (json['walkingSpeed'] as num).toDouble(),
    );

Map<String, dynamic> _$FiveStarsInfoToJson(FiveStarsInfo instance) =>
    <String, dynamic>{
      'star': _$EnumStarsEnumMap[instance.star]!,
      'angle': instance.angle,
      'enterInfo': instance.enterInfo,
      'fiveStarWalkingType':
          _$FiveStarWalkingTypeEnumMap[instance.fiveStarWalkingType]!,
      'walkingSpeed': instance.walkingSpeed,
    };

SunInfo _$SunInfoFromJson(Map<String, dynamic> json) => SunInfo(
      angle: (json['angle'] as num).toDouble(),
      enterInfo:
          EnteredInfo.fromJson(json['enterInfo'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$SunInfoToJson(SunInfo instance) => <String, dynamic>{
      'angle': instance.angle,
      'enterInfo': instance.enterInfo,
    };

MoonInfo _$MoonInfoFromJson(Map<String, dynamic> json) => MoonInfo(
      angle: (json['angle'] as num).toDouble(),
      enterInfo:
          EnteredInfo.fromJson(json['enterInfo'] as Map<String, dynamic>),
      moonPhase: $enumDecode(_$EnumMoonPhasesEnumMap, json['moonPhase']),
    );

Map<String, dynamic> _$MoonInfoToJson(MoonInfo instance) => <String, dynamic>{
      'angle': instance.angle,
      'enterInfo': instance.enterInfo,
      'moonPhase': _$EnumMoonPhasesEnumMap[instance.moonPhase]!,
    };

const _$EnumMoonPhasesEnumMap = {
  EnumMoonPhases.New: 'New',
  EnumMoonPhases.E_Mei: 'E_Mei',
  EnumMoonPhases.Shang_Xian: 'Shang_Xian',
  EnumMoonPhases.Ying_Tu: 'Ying_Tu',
  EnumMoonPhases.Full: 'Full',
  EnumMoonPhases.Kui_Tu: 'Kui_Tu',
  EnumMoonPhases.Xia_Xian: 'Xia_Xian',
  EnumMoonPhases.Can_Yue: 'Can_Yue',
};

FourSlaveStarInfo _$FourSlaveStarInfoFromJson(Map<String, dynamic> json) =>
    FourSlaveStarInfo(
      star: $enumDecode(_$EnumStarsEnumMap, json['star']),
      angle: (json['angle'] as num).toDouble(),
      enterInfo:
          EnteredInfo.fromJson(json['enterInfo'] as Map<String, dynamic>),
      walkingSpeed: (json['walkingSpeed'] as num).toDouble(),
    );

Map<String, dynamic> _$FourSlaveStarInfoToJson(FourSlaveStarInfo instance) =>
    <String, dynamic>{
      'star': _$EnumStarsEnumMap[instance.star]!,
      'angle': instance.angle,
      'enterInfo': instance.enterInfo,
      'walkingSpeed': instance.walkingSpeed,
    };

LouJiStarsInfo _$LouJiStarsInfoFromJson(Map<String, dynamic> json) =>
    LouJiStarsInfo(
      star: $enumDecode(_$EnumStarsEnumMap, json['star']),
      angle: (json['angle'] as num).toDouble(),
      enterInfo:
          EnteredInfo.fromJson(json['enterInfo'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$LouJiStarsInfoToJson(LouJiStarsInfo instance) =>
    <String, dynamic>{
      'star': _$EnumStarsEnumMap[instance.star]!,
      'angle': instance.angle,
      'enterInfo': instance.enterInfo,
    };
