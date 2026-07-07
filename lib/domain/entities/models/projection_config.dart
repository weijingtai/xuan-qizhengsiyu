import 'package:json_annotation/json_annotation.dart';

part 'projection_config.g.dart';

enum MappingStrategy {
  @JsonValue('linear')
  linear,
  @JsonValue('piecewise')
  piecewise,
  @JsonValue('tuiBianHuangDao')
  tuiBianHuangDao,
}

/// 推变黄道三算法的枚举标签。
enum HuangChiDaoDiffType {
  @JsonValue('daren')
  daren,
  @JsonValue('jiyuan')
  jiyuan,
  @JsonValue('shoushi')
  shoushi,
  @JsonValue('hushi')
  hushi,
}

@JsonSerializable()
class ProjectionConfig {
  final MappingStrategy strategy;

  // For linear strategy
  final double? offset;
  /// 源周天（默认 360），设 365.2575 可做 identity 投影。
  final double? sourceTotal;

  // For piecewise strategy
  final List<double>? sourcePoints;
  final List<double>? targetPoints;

  // ---- tuiBianHuangDao 子参 ----
  /// 黄赤道差算法类型。
  final HuangChiDaoDiffType? huangChiDaoDiffType;
  /// 黄赤交角 (度)，仅授时球面三角用。
  final double? epsilonDeg;
  /// 春分历元锚点 (赤道度，古周天)。
  final double? springEquinoxAnchor;

  ProjectionConfig({
    required this.strategy,
    this.offset,
    this.sourceTotal,
    this.sourcePoints,
    this.targetPoints,
    this.huangChiDaoDiffType,
    this.epsilonDeg,
    this.springEquinoxAnchor,
  });

  factory ProjectionConfig.fromJson(Map<String, dynamic> json) =>
      _$ProjectionConfigFromJson(json);

  Map<String, dynamic> toJson() => _$ProjectionConfigToJson(this);

  /// Default linear 360 -> 360 mapping
  factory ProjectionConfig.defaultLinear() => ProjectionConfig(
        strategy: MappingStrategy.linear,
        offset: 0,
      );
}
