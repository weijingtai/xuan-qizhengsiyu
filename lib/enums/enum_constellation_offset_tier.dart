import 'package:json_annotation/json_annotation.dart';

/// 星宿偏移档位；各档带默认偏移度数，用户可再用数值微调覆盖。
enum ConstellationOffsetTier {
  /// 古宿：不偏移
  @JsonValue('guXiu')
  guXiu('古宿', 0.0),

  /// 矫正古宿：默认 +14°（古今宿差经验值）
  @JsonValue('adjusted')
  adjusted('矫正古宿', 14.0),

  /// 今宿：不偏移
  @JsonValue('modern')
  modern('今宿', 0.0);

  const ConstellationOffsetTier(this.label, this.defaultOffsetDeg);
  final String label;
  final double defaultOffsetDeg;
}
