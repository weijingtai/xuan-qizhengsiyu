import 'package:flutter_test/flutter_test.dart';
import 'package:qizhengsiyu/domain/engines/siyu/group/linear_parallel_core.dart';

void main() {
  test('顺行：epoch后1000日 = epoch + daily*1000，mod totalDegree', () {
    const c = LinearParallelCore(
        totalDegree: 360, dailyMotion: 0.0352, direction: 1,
        epochJulianDay: 1000, epochPosition: 10);
    expect(c.positionAt(2000), closeTo((10 + 0.0352 * 1000) % 360, 1e-9));
  });
  test('逆行：direction=-1 递减并按框架归一到[0,total)', () {
    const c = LinearParallelCore(
        totalDegree: 365.25, dailyMotion: 0.05299, direction: -1,
        epochJulianDay: 1000, epochPosition: 5);
    final v = c.positionAt(1100); // 5 - 0.05299*100 = -0.299 → +365.25 = 364.951
    expect(v, greaterThanOrEqualTo(0));
    expect(v, lessThan(365.25));
    expect(v, closeTo(365.25 + (5 - 0.05299 * 100), 1e-6)); // 364.951
  });
}
