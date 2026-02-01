import 'package:json_annotation/json_annotation.dart';
import 'package:qizhengsiyu/enums/enum_panel_system_type.dart';

part 'star_angle_speed.g.dart';

/// 星体坐标系统信息
///
/// 封装星体的坐标系统、星制、角度和速度等基本信息
@JsonSerializable()
class StarAngleSpeed {
  /// 当前角度（度数）
  final double angle;

  /// 当前运行速度（度/日）
  final double speed;

  /// 构造函数
  const StarAngleSpeed({
    required this.angle,
    required this.speed,
  });

  /// 创建此对象的副本，但使用提供的值替换指定的属性
  StarAngleSpeed copyWith({
    double? angle,
    double? speed,
  }) {
    return StarAngleSpeed(
      angle: angle ?? this.angle,
      speed: speed ?? this.speed,
    );
  }

  factory StarAngleSpeed.fromJson(Map<String, dynamic> json) =>
      _$StarAngleSpeedFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$StarAngleSpeedToJson(this);
}
