// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ge_ju_deletion_record.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GeJuDeletionRecord _$GeJuDeletionRecordFromJson(Map<String, dynamic> json) =>
    GeJuDeletionRecord(
      id: json['id'] as String,
      deletedEntityType: json['deletedEntityType'] as String,
      deletedEntityId: json['deletedEntityId'] as String,
      deletedAt: DateTime.parse(json['deletedAt'] as String),
      reason: json['reason'] as String,
      snapshotJson: json['snapshotJson'] as String,
    );

Map<String, dynamic> _$GeJuDeletionRecordToJson(GeJuDeletionRecord instance) =>
    <String, dynamic>{
      'id': instance.id,
      'deletedEntityType': instance.deletedEntityType,
      'deletedEntityId': instance.deletedEntityId,
      'deletedAt': instance.deletedAt.toIso8601String(),
      'reason': instance.reason,
      'snapshotJson': instance.snapshotJson,
    };
