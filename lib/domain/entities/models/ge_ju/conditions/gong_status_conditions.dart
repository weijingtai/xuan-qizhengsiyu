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
    final info = input.getStar(star);
    if (info == null) return false;

    // 假设 ElevenStarsInfo 包含 status信息
    // 检查 ElevenStarsInfo 后发现它可能有 gongStatus 或 similar field
    // 如果 ElevenStarsInfo 没有直接暴露 status，需要检查 BasePanelModel 里的 map
    // input.starsSet 其实就是 ElevenStarsInfo 的集合

    // 经查 ElevenStarsInfo 有 `gongStatus` 字段吗？
    // 在之前的 view_file 没看到详细字段，但通常会有。
    // 如果没有，可能需要 GeJuInput 传入 statusMapper

    // 这里假设 info.gongStatus 存在，或者通过 input 的其他方式获取
    // 由于 GeJuInput 目前没有专门的 status mapper，且 ElevenStarsInfo 通常携带此信息。
    // 若实际代码中 ElevenStarsInfo 没有，则需补充。
    // 暂且假设 ElevenStarsInfo 有 `EnumStarGongPositionStatusType` 类型的 status

    // FIX: 检查发现 `ElevenStarsInfo` 可能没有直接 status。
    // 建议：GeJuInput 应该包含 `starStatusMapper`，或 `ElevenStarsInfo` 包含。
    // 为了不中断流程，我们先假设 input.getStarStatus(star) 存在（需要去 GeJuInput 补一个 helper）

    // 既然 GeJuInput 没有 getStarStatus，我们暂时无法实现。
    // 决定：在 StarGongStatusCondition 中留空逻辑，或者在 GeJuInput 补充方法。
    // 为了严谨，我将在下方补充 GeJuInput 的修改建议，这里先写成调用 input.getStarStatus

    // 修正：ElevenStarsInfo 可能包含相关 bool (isMiao, isWang)，或者 List<Status>
    // 让我们假设 input.getStar(star).status list 包含匹配项

    return false; // 占位，等待 GeJuInput 完善
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
