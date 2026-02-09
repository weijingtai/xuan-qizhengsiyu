import 'package:json_annotation/json_annotation.dart';

part 'ge_ju_deletion_record.g.dart';

/// 删除审计记录
/// 记录用户删除操作的详细信息，用于审计和恢复
@JsonSerializable()
class GeJuDeletionRecord {
  /// 审计记录 ID
  final String id;

  /// 被删除实体类型: 'annotation' | 'conditionSet' | 'rule'
  final String deletedEntityType;

  /// 被删除实体 ID
  final String deletedEntityId;

  /// 删除时间
  final DateTime deletedAt;

  /// 删除原因（必填）
  final String reason;

  /// 删除前的完整内容快照 JSON
  final String snapshotJson;

  const GeJuDeletionRecord({
    required this.id,
    required this.deletedEntityType,
    required this.deletedEntityId,
    required this.deletedAt,
    required this.reason,
    required this.snapshotJson,
  });

  factory GeJuDeletionRecord.fromJson(Map<String, dynamic> json) =>
      _$GeJuDeletionRecordFromJson(json);

  Map<String, dynamic> toJson() => _$GeJuDeletionRecordToJson(this);
}
