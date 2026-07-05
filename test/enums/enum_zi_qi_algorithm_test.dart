import 'package:flutter_test/flutter_test.dart';
import 'package:qizhengsiyu/enums/enum_zi_qi_algorithm.dart';

void main() {
  test('默认算法为果老/琴堂', () {
    expect(EnumZiQiAlgorithm.values.first, EnumZiQiAlgorithm.guoLaoQinTang);
  });
  test('周期常数正确', () {
    expect(EnumZiQiPeriod.years28.days, closeTo(10227.1792, 1e-6));
    expect(EnumZiQiPeriod.years29.days, closeTo(10592.0, 1e-6));
  });
  test('历元常数集默认授时·女宿', () {
    expect(EnumZiQiEpochSet.values.first, EnumZiQiEpochSet.shouShiNvXiu);
  });
}
