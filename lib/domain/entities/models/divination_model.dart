import 'package:metaphysics_core/datamodel/location.dart';
import 'package:metaphysics_core/datamodel/basic_diviation_info.dart';
import 'package:json_annotation/json_annotation.dart';

part 'divination_model.g.dart';

@JsonSerializable()
class QiZhengSiYuDivination extends BasicDivination {
  // 求测人所在位置，可选
  Address? divinationPersonLocation;
  // 占卜师卜问时的位置
  final Address divinationLocation;
  QiZhengSiYuDivination({
    required this.divinationLocation,
    required String question,
    required DateTime divinationAt,
    String? details,
    DivinationPerson? divinationPerson,
    this.divinationPersonLocation,
  }) : super(
          question: question,
          divinationAt: divinationAt,
          details: details,
          divinationPerson: divinationPerson,
        );

  factory QiZhengSiYuDivination.fromJson(Map<String, dynamic> json) =>
      _$QiZhengSiYuDivinationFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$QiZhengSiYuDivinationToJson(this);
}
