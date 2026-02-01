// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stars_four_relationship.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StarsFourRelationship _$StarsFourRelationshipFromJson(
        Map<String, dynamic> json) =>
    StarsFourRelationship(
      $enumDecode(_$EnumStarsEnumMap, json['star']),
      json['className'] as String,
      (json['fourRelationshipMapper'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(
            $enumDecode(_$EnumStarsFourTypeEnumMap, k),
            (e as List<dynamic>)
                .map((e) => $enumDecode(_$EnumStarsEnumMap, e))
                .toSet()),
      ),
    );

Map<String, dynamic> _$StarsFourRelationshipToJson(
        StarsFourRelationship instance) =>
    <String, dynamic>{
      'star': _$EnumStarsEnumMap[instance.star]!,
      'className': instance.className,
      'fourRelationshipMapper': instance.fourRelationshipMapper.map((k, e) =>
          MapEntry(_$EnumStarsFourTypeEnumMap[k]!,
              e.map((e) => _$EnumStarsEnumMap[e]!).toList())),
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

const _$EnumStarsFourTypeEnumMap = {
  EnumStarsFourType.En: '恩',
  EnumStarsFourType.Nan: '难',
  EnumStarsFourType.Chou: '仇',
  EnumStarsFourType.Yong: '用',
  EnumStarsFourType.Unknown: '无',
};
