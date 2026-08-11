import 'package:flutter_test/flutter_test.dart';
import 'package:qizhengsiyu/domain/usecases/evaluate_qizheng_ge_ju_usecase.dart';
import 'package:qizhengsiyu/enums/enum_star_position_status.dart';
import 'package:qizhengsiyu/enums/enum_twelve_gong.dart';
import 'package:metaphysics_core/enums.dart';
import 'package:repository_interface_qizhengsiyu/repository_interface_qizhengsiyu.dart';

/// 星曜庙旺状态 contract → 领域模型转换测试（2026-08-10）。
///
/// XRAP `qizheng.star_position_status` 数据为中文值（star='日'、
/// starPositionStatusType='庙'、positionList=['戌']），转换须按枚举中文名
/// 匹配。数据接入后 `starGongStatus` 类条件不再恒 false。
void main() {
  test('转换：中文数据 → 领域模型', () {
    final contracts = [
      QiZhengStarPositionStatusContract({
        'id': 1,
        'className': '果老',
        'star': '日',
        'starPositionStatusType': '庙',
        'positionList': ['戌'],
      }),
      QiZhengStarPositionStatusContract({
        'id': 2,
        'className': '果老',
        'star': '月',
        'starPositionStatusType': '旺',
        'positionList': ['酉', '戌'],
      }),
    ];
    final models = convertStarPositionStatusContracts(contracts);
    expect(models.length, 2);
    expect(models[0].star, EnumStars.Sun);
    expect(models[0].starPositionStatusType,
        EnumStarGongPositionStatusType.Miao);
    expect(models[0].positionList, [EnumTwelveGong.Xu]);
    expect(models[1].star, EnumStars.Moon);
    expect(models[1].starPositionStatusType,
        EnumStarGongPositionStatusType.Wang);
    expect(models[1].positionList, [EnumTwelveGong.You, EnumTwelveGong.Xu]);
  });
}
