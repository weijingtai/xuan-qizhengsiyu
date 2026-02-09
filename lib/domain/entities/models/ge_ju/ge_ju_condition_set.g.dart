// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ge_ju_condition_set.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GeJuConditionSet _$GeJuConditionSetFromJson(Map<String, dynamic> json) =>
    GeJuConditionSet(
      id: json['id'] as String,
      ruleId: json['ruleId'] as String,
      label: json['label'] as String,
      schools:
          (json['schools'] as List<dynamic>?)?.map((e) => e as String).toList(),
      source: json['source'] == null
          ? null
          : GeJuSource.fromJson(json['source'] as Map<String, dynamic>),
      authorType: json['authorType'] as String,
      conditions: json['conditions'] == null
          ? null
          : GeJuCondition.fromJson(json['conditions'] as Map<String, dynamic>),
      derivedFrom: json['derivedFrom'] as String?,
      changeNote: json['changeNote'] as String?,
      relatedAnnotationIds: (json['relatedAnnotationIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      visibility: json['visibility'] as String? ?? 'private',
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$GeJuConditionSetToJson(GeJuConditionSet instance) =>
    <String, dynamic>{
      'id': instance.id,
      'ruleId': instance.ruleId,
      'label': instance.label,
      'schools': instance.schools,
      'source': instance.source,
      'authorType': instance.authorType,
      'conditions': instance.conditions,
      'derivedFrom': instance.derivedFrom,
      'changeNote': instance.changeNote,
      'relatedAnnotationIds': instance.relatedAnnotationIds,
      'visibility': instance.visibility,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
