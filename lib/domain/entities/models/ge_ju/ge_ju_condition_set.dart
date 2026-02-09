import 'package:json_annotation/json_annotation.dart';
import 'ge_ju_condition.dart';
import 'ge_ju_source.dart';

part 'ge_ju_condition_set.g.dart';

/// 格局判断方案（逻辑层）
/// 包含可执行的判断条件集合，独立于文字描述
@JsonSerializable()
class GeJuConditionSet {
  // ══ 身份 ══
  final String id;
  final String ruleId;

  // ══ 标识 ══
  final String label;

  // ══ 来源 ══
  final List<String>? schools;
  final GeJuSource? source;

  // ══ 作者 ══
  /// 'built-in' | 'user'
  final String authorType;

  // ══ 条件（核心） ══
  final GeJuCondition? conditions;

  // ══ 溯源 ══
  /// 如果是基于某个已有方案 Fork 的，记录原始方案 ID
  final String? derivedFrom;
  /// 修改说明
  final String? changeNote;

  // ══ 关联 ══
  @JsonKey(defaultValue: [])
  final List<String> relatedAnnotationIds;

  // ══ 预埋 ══
  @JsonKey(defaultValue: 'private')
  final String visibility;
  final DateTime createdAt;
  final DateTime updatedAt;

  const GeJuConditionSet({
    required this.id,
    required this.ruleId,
    required this.label,
    this.schools,
    this.source,
    required this.authorType,
    this.conditions,
    this.derivedFrom,
    this.changeNote,
    this.relatedAnnotationIds = const [],
    this.visibility = 'private',
    required this.createdAt,
    required this.updatedAt,
  });

  /// 是否为内置方案
  bool get isBuiltIn => authorType == 'built-in';

  /// 是否为用户方案
  bool get isUser => authorType == 'user';

  /// 创建副本，可覆盖部分字段
  GeJuConditionSet copyWith({
    String? id,
    String? ruleId,
    String? label,
    List<String>? schools,
    GeJuSource? source,
    String? authorType,
    GeJuCondition? conditions,
    String? derivedFrom,
    String? changeNote,
    List<String>? relatedAnnotationIds,
    String? visibility,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return GeJuConditionSet(
      id: id ?? this.id,
      ruleId: ruleId ?? this.ruleId,
      label: label ?? this.label,
      schools: schools ?? this.schools,
      source: source ?? this.source,
      authorType: authorType ?? this.authorType,
      conditions: conditions ?? this.conditions,
      derivedFrom: derivedFrom ?? this.derivedFrom,
      changeNote: changeNote ?? this.changeNote,
      relatedAnnotationIds: relatedAnnotationIds ?? this.relatedAnnotationIds,
      visibility: visibility ?? this.visibility,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory GeJuConditionSet.fromJson(Map<String, dynamic> json) =>
      _$GeJuConditionSetFromJson(json);

  Map<String, dynamic> toJson() => _$GeJuConditionSetToJson(this);
}
