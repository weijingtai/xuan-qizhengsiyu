import 'package:json_annotation/json_annotation.dart';
import 'package:qizhengsiyu/enums/enum_panel_system_type.dart';

part 'star_angle_raw_info.g.dart';

/// 星体坐标系统信息
///
/// 封装星体的坐标系统、星制、角度和速度等基本信息
@JsonSerializable()
class StarAngleRawInfo {
  /// 使用的星制（恒星制、回归制）
  final PanelSystemType panelSystemType;

  /// 使用的参考面（黄道、赤道）
  final CelestialCoordinateSystem coordinateSystem;

  /// 当前角度（度数）
  final double angle;

  /// 当前运行速度（度/日）
  final double speed;

  /// 构造函数
  const StarAngleRawInfo({
    required this.panelSystemType,
    required this.coordinateSystem,
    required this.angle,
    required this.speed,
  });

  /// 创建此对象的副本，但使用提供的值替换指定的属性
  StarAngleRawInfo copyWith({
    PanelSystemType? starInnSystem,
    CelestialCoordinateSystem? coordinateSystem,
    double? angle,
    double? speed,
  }) {
    return StarAngleRawInfo(
      panelSystemType: starInnSystem ?? this.panelSystemType,
      coordinateSystem: coordinateSystem ?? this.coordinateSystem,
      angle: angle ?? this.angle,
      speed: speed ?? this.speed,
    );
  }

  factory StarAngleRawInfo.fromJson(Map<String, dynamic> json) =>
      _$StarAngleRawInfoFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$StarAngleRawInfoToJson(this);
}
