// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'four_season_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StarAndReason _$StarAndReasonFromJson(Map<String, dynamic> json) =>
    StarAndReason(
      $enumDecode(_$EnumStarsEnumMap, json['star']),
      (json['reason'] as List<dynamic>).map((e) => e as String).toList(),
    );

Map<String, dynamic> _$StarAndReasonToJson(StarAndReason instance) =>
    <String, dynamic>{
      'star': _$EnumStarsEnumMap[instance.star]!,
      'reason': instance.reason,
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

FourSeasonStar _$FourSeasonStarFromJson(Map<String, dynamic> json) =>
    FourSeasonStar(
      $enumDecode(_$EnumStarsEnumMap, json['star']),
      (json['fourSeasonRelationshipMapper'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(
            $enumDecode(_$FourSeasonsEnumMap, k),
            (e as Map<String, dynamic>).map(
              (k, e) => MapEntry(
                  $enumDecode(_$FourSeasonRelationshipTypeEnumMap, k),
                  (e as List<dynamic>)
                      .map((e) =>
                          StarAndReason.fromJson(e as Map<String, dynamic>))
                      .toSet()),
            )),
      ),
    );

Map<String, dynamic> _$FourSeasonStarToJson(FourSeasonStar instance) =>
    <String, dynamic>{
      'star': _$EnumStarsEnumMap[instance.star]!,
      'fourSeasonRelationshipMapper': instance.fourSeasonRelationshipMapper.map(
          (k, e) => MapEntry(
              _$FourSeasonsEnumMap[k]!,
              e.map((k, e) => MapEntry(
                  _$FourSeasonRelationshipTypeEnumMap[k]!, e.toList())))),
    };

const _$FourSeasonRelationshipTypeEnumMap = {
  FourSeasonRelationshipType.Xi: '喜',
  FourSeasonRelationshipType.Ji: '忌',
  FourSeasonRelationshipType.TiaoHou: '调候',
  FourSeasonRelationshipType.Unknown: '无',
};

const _$FourSeasonsEnumMap = {
  FourSeasons.SPRING: '春',
  FourSeasons.SUMMER: '夏',
  FourSeasons.AUTUMN: '秋',
  FourSeasons.WINTER: '冬',
  FourSeasons.EARTH: '土',
};
