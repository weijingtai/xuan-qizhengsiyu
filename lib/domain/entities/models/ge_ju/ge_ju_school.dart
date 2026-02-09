import 'package:json_annotation/json_annotation.dart';

part 'ge_ju_school.g.dart';

/// 格局流派定义
/// 代表不同的学术传承体系，如果老派、琴堂派等
@JsonSerializable()
class GeJuSchool {
  /// 唯一标识 (如 "guolao")
  final String id;

  /// 显示名称 (如 "果老星宗")
  final String name;

  /// 简报/简介
  final String? brief;

  /// 特点描述列表
  @JsonKey(defaultValue: [])
  final List<String> features;

  const GeJuSchool({
    required this.id,
    required this.name,
    this.brief,
    this.features = const [],
  });

  factory GeJuSchool.fromJson(Map<String, dynamic> json) =>
      _$GeJuSchoolFromJson(json);

  Map<String, dynamic> toJson() => _$GeJuSchoolToJson(this);

  // --- 系统内置流派 System Built-in Schools ---

  static const GeJuSchool guoLao = GeJuSchool(
    id: "guolao",
    name: "果老星宗",
    brief: "以《果老星宗》为核心的传统主流派别，重星格、神煞与纳音。",
    features: ["重视神煞", "强调星格", "纳音论命"],
  );

  static const GeJuSchool qinTang = GeJuSchool(
    id: "qintang",
    name: "琴堂五星",
    brief: "琴堂派五星术，重五星生克制化与十二宫强弱。",
    features: ["五星生克", "宫位强弱", "虚局实局"],
  );

  static const GeJuSchool tianGuan = GeJuSchool(
    id: "tianguan",
    name: "天官五星",
    brief: "天官派，强调天官赐福与星曜的特定组合。",
    features: ["天官赐福", "星曜组合", "独特神煞"],
  );

  /// 获取系统内置列表
  static List<GeJuSchool> get builtInSchools => [guoLao, qinTang, tianGuan];

  /// 根据ID获取流派（默认为果老）
  static GeJuSchool fromId(String? id) {
    return builtInSchools.firstWhere(
      (s) => s.id == id,
      orElse: () => guoLao,
    );
  }
}
