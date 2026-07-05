import 'package:flutter_test/flutter_test.dart';
import 'package:qizhengsiyu/domain/engines/siyu/ziqi/shixian_zi_qi_algorithm.dart';
import 'package:qizhengsiyu/domain/engines/siyu/ziqi/tianguan_zi_qi_algorithm.dart';

void main() {
  test('时宪：日行≈0.0352°，历元后 100 日累进', () {
    const algo = ShixianZiQiAlgorithm(
      dailyMotionDegrees: 126.720777 / 3600,
      epochJulianDay: 5000,
      epochLongitude: 197.8333,
    );
    final v = algo.computeLongitude(
        julianDay: 5100, datetime: DateTime.utc(2000));
    expect(v, closeTo(197.8333 + (126.720777 / 3600) * 100, 1e-6));
  });

  test('天官：逐年 +13°05′，输出截断到宫度(30°整数倍)', () {
    const algo = TianguanZiQiAlgorithm(
      epochYear: 2000,
      epochLongitude: 0.0,
      yearlyIncrementDegrees: 13 + 5 / 60,
    );
    // 3 年后原始 = 39.25° -> 落在 30° 宫
    final v = algo.computeLongitude(
        julianDay: 0, datetime: DateTime.utc(2003, 6, 1));
    expect(v % 30, closeTo(0, 1e-9));
    expect(v, closeTo(30, 1e-9));
  });
}
