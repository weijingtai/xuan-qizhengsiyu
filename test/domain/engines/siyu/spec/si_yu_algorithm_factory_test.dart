import 'package:flutter_test/flutter_test.dart';
import 'package:metaphysics_core/enums.dart';
import 'package:qizhengsiyu/domain/engines/siyu/spec/si_yu_group_spec.dart';
import 'package:qizhengsiyu/domain/engines/siyu/spec/si_yu_algorithm_factory.dart';

void main() {
  final ctx = CoordinateContext(totalDegree: 360, ephemerisSource: null);
  test('build linear_ziqi', () {
    final f = SiYuAlgorithmFactory.withDefaults();
    final algo = f.build(const SiYuGroupSpec(kind: 'linear_ziqi', params: {
      'totalDegree': 360, 'dailyMotion': 0.0352, 'direction': 1,
      'epochJulianDay': 1000, 'epochPosition': 5,
    }), ctx);
    final p = algo.computePositions(julianDay: 2000, datetime: DateTime.utc(2000));
    expect(p[EnumStars.Qi], closeTo((5 + 0.0352 * 1000) % 360, 1e-6));
  });
  test('分段 spec 组装 Piecewise', () {
    final f = SiYuAlgorithmFactory.withDefaults();
    final algo = f.build(SiYuGroupSpec(kind: 'linear_ziqi', params: const {
      'totalDegree':360,'dailyMotion':0.0352,'direction':1,'epochJulianDay':1000,'epochPosition':5},
      segments: [SiYuSegmentSpec(fromJulianDay: 3000, spec: const SiYuGroupSpec(kind:'linear_ziqi',params:{
        'totalDegree':360,'dailyMotion':0.0352,'direction':1,'epochJulianDay':3000,'epochPosition':99}))]), ctx);
    expect(algo.computePositions(julianDay: 3500, datetime: DateTime.utc(2000))[EnumStars.Qi], closeTo(99 + 0.0352*500, 1e-6));
  });
  test('未知 kind 抛错', () {
    expect(() => SiYuAlgorithmFactory.withDefaults().build(
        const SiYuGroupSpec(kind: 'nope', params: {}), ctx), throwsArgumentError);
  });
}
