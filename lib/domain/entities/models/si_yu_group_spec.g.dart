// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'si_yu_group_spec.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SiYuGroupSpec _$SiYuGroupSpecFromJson(Map<String, dynamic> json) =>
    SiYuGroupSpec(
      kind: json['kind'] as String,
      params:
          (json['params'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, (e as num).toDouble()),
          ) ??
          const {},
      segments: (json['segments'] as List<dynamic>?)
          ?.map((e) => SiYuSegmentSpec.fromJson(e as Map<String, dynamic>))
          .toList(),
      rahuKetuConventionIndex: (json['rahuKetuConventionIndex'] as num?)
          ?.toInt(),
    );

Map<String, dynamic> _$SiYuGroupSpecToJson(SiYuGroupSpec instance) =>
    <String, dynamic>{
      'kind': instance.kind,
      'params': instance.params,
      'segments': instance.segments?.map((e) => e.toJson()).toList(),
      'rahuKetuConventionIndex': instance.rahuKetuConventionIndex,
    };

SiYuSegmentSpec _$SiYuSegmentSpecFromJson(Map<String, dynamic> json) =>
    SiYuSegmentSpec(
      fromJulianDay: (json['fromJulianDay'] as num).toDouble(),
      spec: SiYuGroupSpec.fromJson(json['spec'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$SiYuSegmentSpecToJson(SiYuSegmentSpec instance) =>
    <String, dynamic>{
      'fromJulianDay': instance.fromJulianDay,
      'spec': instance.spec.toJson(),
    };
