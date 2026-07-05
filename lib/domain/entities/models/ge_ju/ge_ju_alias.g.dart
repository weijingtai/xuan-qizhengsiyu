// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ge_ju_alias.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GeJuAlias _$GeJuAliasFromJson(Map<String, dynamic> json) => GeJuAlias(
  name: json['name'] as String,
  schools: (json['schools'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  source: json['source'] == null
      ? null
      : GeJuSource.fromJson(json['source'] as Map<String, dynamic>),
);

Map<String, dynamic> _$GeJuAliasToJson(GeJuAlias instance) => <String, dynamic>{
  'name': instance.name,
  'schools': instance.schools,
  'source': instance.source,
};
