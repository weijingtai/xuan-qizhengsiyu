import 'package:common/enums.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:qizhengsiyu/domain/entities/models/star_angle_raw_info.dart';

part 'star_position_raw_data.g.dart';

/// 星体位置数据模型
///
/// 用于存储从Sweph类库获取的星体数据，包括星体类型、参考系统、角度和速度等信息
///
@JsonSerializable()
class StarPositionRawData {
  /// 星体类型（太阳、月亮、五星等）
  final EnumStars starType;
  final Set<StarAngleRawInfo> angleRawInfoSet;

  /// 构造函数
  const StarPositionRawData({
    required this.starType,
    required this.angleRawInfoSet,
  });
  factory StarPositionRawData.fromJson(Map<String, dynamic> json) =>
      _$StarPositionRawDataFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$StarPositionRawDataToJson(this);
}
