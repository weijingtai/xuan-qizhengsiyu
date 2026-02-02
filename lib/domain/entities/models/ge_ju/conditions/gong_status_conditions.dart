import 'package:common/enums/enum_stars.dart';
import 'package:qizhengsiyu/domain/entities/models/ge_ju/ge_ju_condition.dart';
import 'package:qizhengsiyu/domain/entities/models/ge_ju/ge_ju_input.dart';
import 'package:qizhengsiyu/enums/enum_star_position_status.dart';

/// T-025: 星曜庙旺状态条件
class StarGongStatusCondition extends GeJuCondition {
  final EnumStars star;
  final List<EnumStarGongPositionStatusType> statuses;

  StarGongStatusCondition(this.star, this.statuses);

  @override
  bool evaluate(GeJuInput input) {
    return input.hasAnyStarGongStatus(star, statuses);
  }

  @override
  String describe() {
    return "${star.singleName}入${statuses.map((e) => e.name).join("/")}";
  }

  factory StarGongStatusCondition.fromJson(Map<String, dynamic> json) {
    final star = EnumStars.getBySingleName(json['star']) ??
        EnumStars.values.byName(json['star']);
    final statuses = (json['statuses'] as List)
        .map((e) => EnumStarGongPositionStatusType.values.firstWhere(
            (v) => v.name == e || v.toString().split('.').last == e))
        .toList();
    return StarGongStatusCondition(star, statuses);
  }
  @override
  Map<String, dynamic> toJson() => {
        'type': 'starGongStatus',
        'star': star.name,
        'statuses': statuses.map((e) => e.name).toList(),
      };
}
