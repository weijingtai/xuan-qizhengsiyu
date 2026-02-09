import 'package:json_annotation/json_annotation.dart';

part 'ge_ju_source.g.dart';

/// 典籍信息
/// 记录格局定义的出处典籍
@JsonSerializable()
class GeJuSource {
  /// 书名（如《星学大成》）
  final String bookName;

  /// 所属流派 ID
  final String school;

  /// 篇章（可选）
  final String? section;

  const GeJuSource({
    required this.bookName,
    required this.school,
    this.section,
  });

  factory GeJuSource.fromJson(Map<String, dynamic> json) =>
      _$GeJuSourceFromJson(json);

  Map<String, dynamic> toJson() => _$GeJuSourceToJson(this);
}
