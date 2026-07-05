import 'package:flutter_test/flutter_test.dart';
import 'package:qizhengsiyu/domain/engines/siyu/ziqi/guolao_zi_qi_algorithm.dart';

void main() {
  const algo = GuoLaoZiQiAlgorithm(
    totalDegree: 360.0,
    periodDays: 10227.1792,
    epochJulianDay: 1000.0, // 测试用抽象历元
    epochLongitude: 0.0,
  );

  test('历元时刻返回历元黄经', () {
    expect(
        algo.computeLongitude(julianDay: 1000.0, datetime: DateTime.utc(2000)),
        closeTo(0.0, 1e-9));
  });

  test('顺行：历元后 1000 日 = 1000*360/10227.1792', () {
    final expected = (360.0 / 10227.1792) * 1000.0;
    expect(
        algo.computeLongitude(julianDay: 2000.0, datetime: DateTime.utc(2000)),
        closeTo(expected, 1e-6));
  });

  test('越界归一化到 [0,360)', () {
    final v = algo.computeLongitude(
        julianDay: 1000.0 + 10227.1792 + 500, datetime: DateTime.utc(2000));
    expect(v, greaterThanOrEqualTo(0));
    expect(v, lessThan(360));
    expect(v, closeTo((360.0 / 10227.1792) * 500, 1e-6));
  });

  test('天赤道 365.25 框架：日行≈0.035714 古度，mod 365.25', () {
    const eq = GuoLaoZiQiAlgorithm(
      totalDegree: 365.25,
      periodDays: 10227.1792,
      epochJulianDay: 1000.0,
      epochLongitude: 0.0,
    );
    expect(
        eq.computeLongitude(julianDay: 2000.0, datetime: DateTime.utc(2000)),
        closeTo((365.25 / 10227.1792) * 1000.0, 1e-6));
    // 越界按 365.25 归一
    final v = eq.computeLongitude(
        julianDay: 1000.0 + 10227.1792 + 200, datetime: DateTime.utc(2000));
    expect(v, lessThan(365.25));
    expect(v, closeTo((365.25 / 10227.1792) * 200, 1e-6));
  });
}
