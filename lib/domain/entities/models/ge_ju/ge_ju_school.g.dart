// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ge_ju_school.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GeJuSchool _$GeJuSchoolFromJson(Map<String, dynamic> json) => GeJuSchool(
  id: json['id'] as String,
  name: json['name'] as String,
  brief: json['brief'] as String?,
  features:
      (json['features'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      [],
);

Map<String, dynamic> _$GeJuSchoolToJson(GeJuSchool instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'brief': instance.brief,
      'features': instance.features,
    };
