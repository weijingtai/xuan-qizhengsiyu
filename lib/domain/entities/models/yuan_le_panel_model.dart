import 'package:common/enums.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:qizhengsiyu/enums/enum_star_position_status.dart';

part 'yuan_le_panel_model.g.dart';

/// 垣乐展示面板 - 星体垣位与庙旺喜乐等状态
@JsonSerializable()
class YuanLePanel {
  /// 本命盘星体信息
  final List<YuanLeStarInfo> natalStars;

  /// 流年盘星体信息（可选）
  final List<YuanLeStarInfo>? transitStars;

  YuanLePanel({
    required this.natalStars,
    this.transitStars,
  });

  factory YuanLePanel.fromJson(Map<String, dynamic> json) =>
      _$YuanLePanelFromJson(json);

  Map<String, dynamic> toJson() => _$YuanLePanelToJson(this);

  YuanLePanel copyWith({
    List<YuanLeStarInfo>? natalStars,
    List<YuanLeStarInfo>? transitStars,
  }) {
    return YuanLePanel(
      natalStars: natalStars ?? this.natalStars,
      transitStars: transitStars ?? this.transitStars,
    );
  }
}

/// 星体垣乐信息
@JsonSerializable()
class YuanLeStarInfo {
  /// 星体
  final EnumStars star;

  /// 星宿名称（如"井木"）
  final String constellationName;

  /// 星体进入星宿的度数
  final double degree;

  /// 分数部分（0-59）
  final int minutes;

  /// 庙旺落陷等状态（如"庙"、"旺"、"喜"、"乐"、"怒"、"凶"）
  final EnumStarGongPositionStatusType? positionStatus;

  /// 星体运行状态（迟/留/伏/逆）
  final String? walkingStatus;

  /// 是否是命主/身主（特殊星体）
  final bool isBodyLifeMaster;

  /// 标签（如"命主"、"身主"，普通星体为空）
  final String label;

  /// 星体进入宫位的度数（入宫度数）
  final double gongDegree;

  /// 星体进入的宫位名称
  final String gongName;

  YuanLeStarInfo({
    required this.star,
    required this.constellationName,
    required this.degree,
    required this.minutes,
    required this.gongDegree,
    required this.gongName,
    this.positionStatus,
    this.walkingStatus,
    this.isBodyLifeMaster = false,
    this.label = '',
  });

  /// 格式化显示：星宿:度.分
  String get formattedDegree {
    final degInt = degree.toInt();
    final minutesFrac = ((degree - degInt) * 60).toInt();
    return '$constellationName:$degInt.${minutesFrac.toString().padLeft(2, '0')}';
  }

  /// 格式化入宫度数：宫位度.分
  String get formattedGongDegree {
    final degInt = gongDegree.toInt();
    final minutesFrac = ((gongDegree - degInt) * 60).toInt();
    return '$gongName${degInt.toString().padLeft(2, '0')}.${minutesFrac.toString().padLeft(2, '0')}';
  }

  factory YuanLeStarInfo.fromJson(Map<String, dynamic> json) =>
      _$YuanLeStarInfoFromJson(json);

  Map<String, dynamic> toJson() => _$YuanLeStarInfoToJson(this);

  YuanLeStarInfo copyWith({
    EnumStars? star,
    String? constellationName,
    double? degree,
    int? minutes,
    double? gongDegree,
    String? gongName,
    EnumStarGongPositionStatusType? positionStatus,
    String? walkingStatus,
    bool? isBodyLifeMaster,
    String? label,
  }) {
    return YuanLeStarInfo(
      star: star ?? this.star,
      constellationName: constellationName ?? this.constellationName,
      degree: degree ?? this.degree,
      minutes: minutes ?? this.minutes,
      gongDegree: gongDegree ?? this.gongDegree,
      gongName: gongName ?? this.gongName,
      positionStatus: positionStatus ?? this.positionStatus,
      walkingStatus: walkingStatus ?? this.walkingStatus,
      isBodyLifeMaster: isBodyLifeMaster ?? this.isBodyLifeMaster,
      label: label ?? this.label,
    );
  }
}
