// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'star_position_raw_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StarPositionRawData _$StarPositionRawDataFromJson(Map<String, dynamic> json) =>
    StarPositionRawData(
      starType: $enumDecode(_$EnumStarsEnumMap, json['starType']),
      angleRawInfoSet: (json['angleRawInfoSet'] as List<dynamic>)
          .map((e) => StarAngleRawInfo.fromJson(e as Map<String, dynamic>))
          .toSet(),
    );

Map<String, dynamic> _$StarPositionRawDataToJson(
        StarPositionRawData instance) =>
    <String, dynamic>{
      'starType': _$EnumStarsEnumMap[instance.starType]!,
      'angleRawInfoSet': instance.angleRawInfoSet.toList(),
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
