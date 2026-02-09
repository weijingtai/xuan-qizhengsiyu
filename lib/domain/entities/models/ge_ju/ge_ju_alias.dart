import 'package:json_annotation/json_annotation.dart';
import 'ge_ju_source.dart';

part 'ge_ju_alias.g.dart';

/// 格局别名
/// 同一个格局在不同典籍/流派中可能有不同名称
@JsonSerializable()
class GeJuAlias {
  /// 别名
  final String name;

  /// 使用该别名的流派列表
  final List<String>? schools;

  /// 出处典籍
  final GeJuSource? source;

  const GeJuAlias({
    required this.name,
    this.schools,
    this.source,
  });

  factory GeJuAlias.fromJson(Map<String, dynamic> json) =>
      _$GeJuAliasFromJson(json);

  Map<String, dynamic> toJson() => _$GeJuAliasToJson(this);
}
