import 'package:metaphysics_core/enums.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:qizhengsiyu/domain/entities/models/ge_ju_model.dart';
import 'ge_ju_source.dart';

part 'ge_ju_annotation.g.dart';

/// 格局注解（文字层）
/// 对格局含义的文字阐述，独立于判断逻辑
@JsonSerializable(explicitToJson: true)
class GeJuAnnotation {
  // ══ 身份 ══
  final String id;
  final String ruleId;

  // ══ 来源 ══
  final List<String>? schools;
  final GeJuSource? source;

  // ══ 作者 ══
  /// 'built-in' | 'user'
  final String authorType;

  // ══ 版本 ══
  /// "V.v" 格式，如 "1.0"
  @JsonKey(defaultValue: '1.0')
  final String version;

  // ══ 内容 ══
  final String? description;
  final JiXiongEnum? jiXiong;
  final GeJuType? geJuType;
  final String? className;

  // ══ 谱系（占位，本期不启用逻辑） ══
  final String? parentAnnotationId;
  final int? parentMajorVersion;
  /// quote/annotate/revise/contradict
  final String? relationToParent;
  @JsonKey(defaultValue: [])
  final List<String> references;

  // ══ 关联 ══
  @JsonKey(defaultValue: [])
  final List<String> relatedConditionSetIds;

  // ══ 预埋 ══
  @JsonKey(defaultValue: 'private')
  final String visibility;
  @JsonKey(defaultValue: 'zh-Hans')
  final String locale;
  final DateTime createdAt;
  final DateTime updatedAt;

  const GeJuAnnotation({
    required this.id,
    required this.ruleId,
    this.schools,
    this.source,
    required this.authorType,
    this.version = '1.0',
    this.description,
    this.jiXiong,
    this.geJuType,
    this.className,
    this.parentAnnotationId,
    this.parentMajorVersion,
    this.relationToParent,
    this.references = const [],
    this.relatedConditionSetIds = const [],
    this.visibility = 'private',
    this.locale = 'zh-Hans',
    required this.createdAt,
    required this.updatedAt,
  });

  /// 是否为内置注解
  bool get isBuiltIn => authorType == 'built-in';

  /// 是否为用户注解
  bool get isUser => authorType == 'user';

  /// 创建副本，可覆盖部分字段
  GeJuAnnotation copyWith({
    String? id,
    String? ruleId,
    List<String>? schools,
    GeJuSource? source,
    String? authorType,
    String? version,
    String? description,
    JiXiongEnum? jiXiong,
    GeJuType? geJuType,
    String? className,
    String? parentAnnotationId,
    int? parentMajorVersion,
    String? relationToParent,
    List<String>? references,
    List<String>? relatedConditionSetIds,
    String? visibility,
    String? locale,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return GeJuAnnotation(
      id: id ?? this.id,
      ruleId: ruleId ?? this.ruleId,
      schools: schools ?? this.schools,
      source: source ?? this.source,
      authorType: authorType ?? this.authorType,
      version: version ?? this.version,
      description: description ?? this.description,
      jiXiong: jiXiong ?? this.jiXiong,
      geJuType: geJuType ?? this.geJuType,
      className: className ?? this.className,
      parentAnnotationId: parentAnnotationId ?? this.parentAnnotationId,
      parentMajorVersion: parentMajorVersion ?? this.parentMajorVersion,
      relationToParent: relationToParent ?? this.relationToParent,
      references: references ?? this.references,
      relatedConditionSetIds: relatedConditionSetIds ?? this.relatedConditionSetIds,
      visibility: visibility ?? this.visibility,
      locale: locale ?? this.locale,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory GeJuAnnotation.fromJson(Map<String, dynamic> json) =>
      _$GeJuAnnotationFromJson(json);

  Map<String, dynamic> toJson() => _$GeJuAnnotationToJson(this);
}
