// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ge_ju_user_preference.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GeJuUserPreference _$GeJuUserPreferenceFromJson(Map<String, dynamic> json) =>
    GeJuUserPreference(
      hiddenConditionSetIds:
          (json['hiddenConditionSetIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      conditionSetSchools: (json['conditionSetSchools'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      hiddenAnnotationIds:
          (json['hiddenAnnotationIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      annotationSchools: (json['annotationSchools'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$GeJuUserPreferenceToJson(GeJuUserPreference instance) =>
    <String, dynamic>{
      'hiddenConditionSetIds': instance.hiddenConditionSetIds,
      'conditionSetSchools': instance.conditionSetSchools,
      'hiddenAnnotationIds': instance.hiddenAnnotationIds,
      'annotationSchools': instance.annotationSchools,
    };
