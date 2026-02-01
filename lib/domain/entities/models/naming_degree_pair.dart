import 'package:common/enums.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:qizhengsiyu/enums/enum_twelve_gong.dart';
import 'package:sweph/sweph.dart';

part 'naming_degree_pair.g.dart';

@JsonSerializable()
class ConstellationDegree {
  final Enum28Constellations constellation;
  final double degree;

  ConstellationDegree({required this.constellation, required this.degree});

  factory ConstellationDegree.fromJson(Map<String, dynamic> json) =>
      _$ConstellationDegreeFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$ConstellationDegreeToJson(this);
}

// gong degree
@JsonSerializable()
class GongDegree {
  final EnumTwelveGong gong;
  final double degree;
  GongDegree({required this.gong, required this.degree});

  factory GongDegree.fromJson(Map<String, dynamic> json) =>
      _$GongDegreeFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$GongDegreeToJson(this);
}

@JsonSerializable()
class StarDegree {
  final EnumStars star;
  final double degree;
  StarDegree({required this.star, required this.degree});

  factory StarDegree.fromJson(Map<String, dynamic> json) =>
      _$StarDegreeFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$StarDegreeToJson(this);
}

@JsonSerializable()
class ConstellationPosition {
  final Enum28Constellations constellation;
  final double degree;
  final double startAtDegree;
  final double endAtDegree;
  ConstellationPosition(
      {required this.constellation,
      required this.degree,
      required this.startAtDegree,
      required this.endAtDegree});

  factory ConstellationPosition.fromJson(Map<String, dynamic> json) =>
      _$ConstellationPositionFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$ConstellationPositionToJson(this);
}

@JsonSerializable()
class GongPosition {
  final EnumTwelveGong gong;
  final double degree;
  final double startAtDegree;
  final double endAtDegree;
  GongPosition(
      {required this.gong,
      required this.degree,
      required this.startAtDegree,
      required this.endAtDegree});

  factory GongPosition.fromJson(Map<String, dynamic> json) =>
      _$GongPositionFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$GongPositionToJson(this);
}
