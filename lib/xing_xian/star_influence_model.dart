import 'package:common/enums.dart';
import 'package:common/module.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:qizhengsiyu/enums/enum_twelve_gong.dart';

part 'star_influence_model.g.dart';

enum EnumInfluenceType {
  /// 同宫 - 在同一个宫位内
  @JsonValue("同宫")
  same(false),

  /// 对宫 - 相对的宫位
  @JsonValue("对宫")
  opposite(false),

  /// 三方 - 三方会照
  @JsonValue("三方")
  triangle(false),

  /// 四正 - 四正位
  @JsonValue("四正")
  square(false),

  /// 同络 - 同一络脉
  @JsonValue("同络")
  luo(false),

  /// 同经 - 同一经度（宿的概念）
  @JsonValue("同经")
  jing(true);

  final bool isConstellationInfluence;
  const EnumInfluenceType(this.isConstellationInfluence);
}

class StarInfluenceModel<E> {
  /// 影响力类型
  final EnumInfluenceType influenceType;

  /// 星体名称
  final EnumStars star;

  /// 星体所在的宫位或星宿
  final E location;

  /// 度数 在其中角度位置
  final double entryDegree;

  StarInfluenceModel({
    required this.influenceType,
    required this.star,
    required this.location,
    required this.entryDegree,
  });

  @override
  String toString() {
    return 'StarInfluenceModel(influenceType: $influenceType, starName: ${star.starName}, location: ${location}, entryDegree: $entryDegree)';
  }
}

// 为宫位创建具体类型
@JsonSerializable()
class PalaceStarInfluenceModel extends StarInfluenceModel<EnumTwelveGong> {
  double degreeDiff; // 同络时必须提供
  double defaultRangeDegree;

  PalaceStarInfluenceModel({
    required super.influenceType,
    required super.star,
    required super.location,
    required super.entryDegree,
    this.degreeDiff = 0,
    this.defaultRangeDegree = 0,
  });

  factory PalaceStarInfluenceModel.fromJson(Map<String, dynamic> json) =>
      _$PalaceStarInfluenceModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$PalaceStarInfluenceModelToJson(this);
}

// 为星宿创建具体类型
@JsonSerializable()
class ConstellationStarInfluenceModel
    extends StarInfluenceModel<Enum28Constellations> {
  final bool inSameConstellation; // 只有当星体在同星座时为true

  ConstellationStarInfluenceModel({
    super.influenceType = EnumInfluenceType.jing,
    required super.star,
    required super.location,
    required super.entryDegree,
    this.inSameConstellation = false,
  });

  factory ConstellationStarInfluenceModel.fromJson(Map<String, dynamic> json) =>
      _$ConstellationStarInfluenceModelFromJson(json);

  Map<String, dynamic> toJson() =>
      _$ConstellationStarInfluenceModelToJson(this);
}

@JsonSerializable()
class DingStarInfluenceModel extends PalaceStarInfluenceModel {
  DateTime startTime; // 开始时间
  DateTime endTime; // 结束时间
  YearMonth startAge;
  YearMonth endAge;
  bool get isClear => influenceType == EnumInfluenceType.same; // 是否为明顶

  // 同络没有参与暗顶
  bool get isUnclear => {
        EnumInfluenceType.opposite,
        EnumInfluenceType.triangle,
        EnumInfluenceType.square
      }.contains(influenceType); // 是否为暗顶
  DingStarInfluenceModel({
    required super.influenceType,
    required super.star,
    required super.location,
    required super.entryDegree,
    required super.degreeDiff,
    required super.defaultRangeDegree,
    required this.startTime,
    required this.endTime,
    required this.startAge,
    required this.endAge,
  });
  factory DingStarInfluenceModel.fromJson(Map<String, dynamic> json) =>
      _$DingStarInfluenceModelFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$DingStarInfluenceModelToJson(this);
}
