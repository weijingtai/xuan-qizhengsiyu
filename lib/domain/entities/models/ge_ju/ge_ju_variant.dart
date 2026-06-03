import 'package:metaphysics_core/enums.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:qizhengsiyu/domain/entities/models/ge_ju_model.dart';
import 'ge_ju_condition.dart';

part 'ge_ju_variant.g.dart';

/// 格局变体定义
/// 代表同一个格局名称下，不同来源或流派的具体定义
@JsonSerializable()
class GeJuVariant {
  /// 来源（具体篇章或作者）
  final String source;

  /// 描述/诗诀
  final String description;

  /// 核心判断条件
  final GeJuCondition? conditions;

  /// 所属典籍（如《果老星宗》）
  final String books;

  /// 分类名称
  @JsonKey(defaultValue: "未分类")
  final String className;

  /// 吉凶
  @JsonKey(defaultValue: JiXiongEnum.PING)
  final JiXiongEnum jiXiong;

  /// 格局类型（富贵贫贱等）
  @JsonKey(defaultValue: GeJuType.pin)
  final GeJuType geJuType;

  /// 关联的流派ID列表 (如 ["guolao", "qintang"])
  /// 默认为 ["guolao"]
  @JsonKey(defaultValue: ["guolao"])
  final List<String> schools;

  GeJuVariant({
    required this.source,
    required this.description,
    this.conditions,
    this.books = "",
    this.className = "未分类",
    this.jiXiong = JiXiongEnum.PING,
    this.geJuType = GeJuType.pin,
    this.schools = const ["guolao"],
  });

  factory GeJuVariant.fromJson(Map<String, dynamic> json) =>
      _$GeJuVariantFromJson(json);

  Map<String, dynamic> toJson() => _$GeJuVariantToJson(this);
}
