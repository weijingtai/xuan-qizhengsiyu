import 'package:json_annotation/json_annotation.dart';

/// 周天 0° 原点的参考点（每年起始点）。
enum EnumZeroPointRef {
  /// 春分点（回归制常用）
  @JsonValue('chunfen')
  chunfen('春分点'),

  /// 冬至点（古历常用）
  @JsonValue('dongzhi')
  dongzhi('冬至点');

  const EnumZeroPointRef(this.label);
  final String label;
}
