import 'package:json_annotation/json_annotation.dart';

part 'ge_ju_user_preference.g.dart';

/// 用户偏好设置
/// 管理用户对格局系统的个性化设置
@JsonSerializable()
class GeJuUserPreference {
  /// 隐藏的判断方案 ID 列表
  @JsonKey(defaultValue: [])
  final List<String> hiddenConditionSetIds;

  /// 判断方案的流派偏好
  final List<String>? conditionSetSchools;

  /// 隐藏的注解 ID 列表
  @JsonKey(defaultValue: [])
  final List<String> hiddenAnnotationIds;

  /// 注解的流派偏好
  final List<String>? annotationSchools;

  const GeJuUserPreference({
    this.hiddenConditionSetIds = const [],
    this.conditionSetSchools,
    this.hiddenAnnotationIds = const [],
    this.annotationSchools,
  });

  /// 默认偏好
  static const GeJuUserPreference defaultPreference = GeJuUserPreference();

  GeJuUserPreference copyWith({
    List<String>? hiddenConditionSetIds,
    List<String>? conditionSetSchools,
    List<String>? hiddenAnnotationIds,
    List<String>? annotationSchools,
  }) {
    return GeJuUserPreference(
      hiddenConditionSetIds: hiddenConditionSetIds ?? this.hiddenConditionSetIds,
      conditionSetSchools: conditionSetSchools ?? this.conditionSetSchools,
      hiddenAnnotationIds: hiddenAnnotationIds ?? this.hiddenAnnotationIds,
      annotationSchools: annotationSchools ?? this.annotationSchools,
    );
  }

  factory GeJuUserPreference.fromJson(Map<String, dynamic> json) =>
      _$GeJuUserPreferenceFromJson(json);

  Map<String, dynamic> toJson() => _$GeJuUserPreferenceToJson(this);
}
