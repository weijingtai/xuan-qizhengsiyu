import 'package:common/enums.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import '../enums/enum_twelve_gong.dart';

part 'gong_constellation_mapping.g.dart';

/// 天体对象类，用于表示宫位或星宿
/// [E] 可以是 [EnumTwelveGong] 或 [Enum28Constellations]
/// [name] 天体名称
/// [absStartContinuous] 连续的绝对起始角度 (可能 > totalDegree)
/// [absEndContinuous] 连续的绝对结束角度 (absStart + width)
/// [width] 天体宽度(度数)
class CelestialObject<E> {
  E name;
  double absStartContinuous; // 连续的绝对起始角度 (可能 > totalDegree)
  double absEndContinuous; // 连续的绝对结束角度 (absStart + width)
  double width;
  CelestialObject(
      this.name, this.absStartContinuous, this.absEndContinuous, this.width);

  @override
  String toString() {
    String nameStr = name is EnumTwelveGong
        ? (name as EnumTwelveGong).name
        : name is Enum28Constellations
            ? (name as Enum28Constellations).name
            : name.toString();
    return '$nameStr: [${absStartContinuous.toStringAsFixed(2)}°, ${absEndContinuous.toStringAsFixed(2)}°) width ${width.toStringAsFixed(2)}°';
  }
}

/// 星宿在宫位中的分段信息
/// [palaceName] 宫位名称
/// [startInPalaceDeg] 在宫位中的起始度数
/// [endInPalaceDeg] 在宫位中的结束度数
/// [startInConstellationDeg] 在星宿中的起始度数
/// [endInConstellationDeg] 在星宿中的结束度数
/// [segmentLengthDeg] 分段长度(度数)
/// [crossesPalaceAtConstellationDeg] 星宿跨越宫位的度数点(如果跨越)
@JsonSerializable()
class ConstellationSegment extends Equatable {
  EnumTwelveGong palaceName; // 替换为EnumTwelveGong
  double startInPalaceDeg;
  double endInPalaceDeg;
  double startInConstellationDeg;
  double endInConstellationDeg;
  double segmentLengthDeg;
  double? crossesPalaceAtConstellationDeg;

  ConstellationSegment({
    required this.palaceName,
    required this.startInPalaceDeg,
    required this.endInPalaceDeg,
    required this.startInConstellationDeg,
    required this.endInConstellationDeg,
    required this.segmentLengthDeg,
    this.crossesPalaceAtConstellationDeg,
  });

  @override
  String toString() {
    String base =
        '  - In ${palaceName.name}: [${startInPalaceDeg.toStringAsFixed(2)}°-${endInPalaceDeg.toStringAsFixed(2)}°)] '
        ' (Constellation segment: [${startInConstellationDeg.toStringAsFixed(2)}°-${endInConstellationDeg.toStringAsFixed(2)}°]) '
        'Length: ${segmentLengthDeg.toStringAsFixed(2)}°';
    if (crossesPalaceAtConstellationDeg != null) {
      base +=
          ' -> Crosses into next palace at ${crossesPalaceAtConstellationDeg!.toStringAsFixed(2)}° of constellation.';
    }
    return base;
  }

  @override
  List<Object?> get props => [
        palaceName,
        startInPalaceDeg,
        endInPalaceDeg,
        startInConstellationDeg,
        endInConstellationDeg,
        segmentLengthDeg,
        crossesPalaceAtConstellationDeg,
      ];

  factory ConstellationSegment.fromJson(Map<String, dynamic> json) =>
      _$ConstellationSegmentFromJson(json);
  Map<String, dynamic> toJson() => _$ConstellationSegmentToJson(this);
}

/// 星宿映射到宫位的结果
/// [constellationName] 星宿名称
/// [absStartDeg] 绝对起始度数
/// [absEndDeg] 绝对结束度数
/// [totalWidthDeg] 总宽度(度数)
/// [segments] 在各宫位中的分段信息列表
@JsonSerializable()
class ConstellationMappingResult extends Equatable {
  Enum28Constellations constellationName; // 替换为Enum28Constellations
  double absStartDeg;
  double absEndDeg;
  double totalWidthDeg;
  List<ConstellationSegment> segments;

  ConstellationMappingResult({
    required this.constellationName,
    required this.absStartDeg,
    required this.absEndDeg,
    required this.totalWidthDeg,
    required this.segments,
  });

  @override
  String toString() {
    return 'Constellation: ${constellationName.name} (Abs: [${absStartDeg.toStringAsFixed(2)}°-${absEndDeg.toStringAsFixed(2)}°), Width: ${totalWidthDeg.toStringAsFixed(2)}°)\n'
        '${segments.map((s) => s.toString()).join('\n')}';
  }

  @override
  List<Object?> get props => [
        constellationName,
        absStartDeg,
        absEndDeg,
        totalWidthDeg,
        segments,
      ];

  factory ConstellationMappingResult.fromJson(Map<String, dynamic> json) =>
      _$ConstellationMappingResultFromJson(json);
  Map<String, dynamic> toJson() => _$ConstellationMappingResultToJson(this);
}

/// 宫位中的星宿分段信息 (与 ConstellationSegment 对称)
/// [constellationName] 星宿名称
/// [startInConstellationDeg] 在星宿中的起始度数
/// [endInConstellationDeg] 在星宿中的结束度数
/// [startInPalaceDeg] 在宫位中的起始度数
/// [endInPalaceDeg] 在宫位中的结束度数
/// [segmentLengthDeg] 分段长度(度数)
/// [crossesConstellationAtPalaceDeg] 宫位跨越星宿的度数点(如果跨越)
@JsonSerializable()
class PalaceConstellationSegment extends Equatable {
  final Enum28Constellations constellationName;
  final double startInConstellationDeg;
  final double endInConstellationDeg;
  final double startInPalaceDeg;
  final double endInPalaceDeg;
  final double segmentLengthDeg;
  final double? crossesConstellationAtPalaceDeg;

  PalaceConstellationSegment({
    required this.constellationName,
    required this.startInConstellationDeg,
    required this.endInConstellationDeg,
    required this.startInPalaceDeg,
    required this.endInPalaceDeg,
    required this.segmentLengthDeg,
    this.crossesConstellationAtPalaceDeg,
  });

  @override
  String toString() {
    String base =
        '  - Constellation ${constellationName.name}: [${startInConstellationDeg.toStringAsFixed(2)}°-${endInConstellationDeg.toStringAsFixed(2)}°)] '
        ' (Palace segment: [${startInPalaceDeg.toStringAsFixed(2)}°-${endInPalaceDeg.toStringAsFixed(2)}°]) '
        'Length: ${segmentLengthDeg.toStringAsFixed(2)}°';
    if (crossesConstellationAtPalaceDeg != null) {
      base +=
          ' -> Crosses into next constellation at ${crossesConstellationAtPalaceDeg!.toStringAsFixed(2)}° of palace.';
    }
    return base;
  }

  @override
  List<Object?> get props => [
        constellationName,
        startInConstellationDeg,
        endInConstellationDeg,
        startInPalaceDeg,
        endInPalaceDeg,
        segmentLengthDeg,
        crossesConstellationAtPalaceDeg,
      ];

  factory PalaceConstellationSegment.fromJson(Map<String, dynamic> json) =>
      _$PalaceConstellationSegmentFromJson(json);
  Map<String, dynamic> toJson() => _$PalaceConstellationSegmentToJson(this);
}

/// 宫位映射到星宿的结果 (与 ConstellationMappingResult 对称)
/// [palaceName] 宫位名称
/// [absStartDeg] 绝对起始度数
/// [absEndDeg] 绝对结束度数
/// [totalWidthDeg] 总宽度(度数)
/// [segments] 在各星宿中的分段信息列表
@JsonSerializable()
class PalaceMappingResult extends Equatable {
  final EnumTwelveGong palaceName;
  final double absStartDeg;
  final double absEndDeg;
  final double totalWidthDeg;
  final List<PalaceConstellationSegment> segments;

  PalaceMappingResult({
    required this.palaceName,
    required this.absStartDeg,
    required this.absEndDeg,
    required this.totalWidthDeg,
    required this.segments,
  });

  @override
  String toString() {
    return 'Palace: ${palaceName.name} (Abs: [${absStartDeg.toStringAsFixed(2)}°-${absEndDeg.toStringAsFixed(2)}°), Width: ${totalWidthDeg.toStringAsFixed(2)}°)\n'
        '${segments.map((s) => s.toString()).join('\n')}';
  }

  @override
  List<Object?> get props => [
        palaceName,
        absStartDeg,
        absEndDeg,
        totalWidthDeg,
        segments,
      ];

  factory PalaceMappingResult.fromJson(Map<String, dynamic> json) =>
      _$PalaceMappingResultFromJson(json);
  Map<String, dynamic> toJson() => _$PalaceMappingResultToJson(this);
}
