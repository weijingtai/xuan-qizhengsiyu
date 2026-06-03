import 'package:json_annotation/json_annotation.dart';

part 'projection_config.g.dart';

enum MappingStrategy {
  @JsonValue('linear')
  linear,
  @JsonValue('piecewise')
  piecewise,
}

@JsonSerializable()
class ProjectionConfig {
  final MappingStrategy strategy;
  
  // For linear strategy
  final double? offset;
  
  // For piecewise strategy
  final List<double>? sourcePoints;
  final List<double>? targetPoints;

  ProjectionConfig({
    required this.strategy,
    this.offset,
    this.sourcePoints,
    this.targetPoints,
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
