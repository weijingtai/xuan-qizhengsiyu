import 'package:flutter_test/flutter_test.dart';
import 'package:metaphysics_core/enums.dart';
import 'package:qizhengsiyu/domain/engines/siyu/group/si_yu_group_algorithm.dart';
import 'package:qizhengsiyu/domain/engines/siyu/group/piecewise_group_algorithm.dart';

class _Fixed implements SiYuGroupAlgorithm {
  final double v; _Fixed(this.v);
  @override String get id => 'f$v';
  @override Set<EnumStars> get bodies => {EnumStars.Qi};
  @override Map<EnumStars,double> computePositions({required double julianDay, required DateTime datetime}) => {EnumStars.Qi: v};
}

void main() {
  final pw = PiecewiseGroupAlgorithm([
    PiecewiseSegment(fromJulianDay: double.negativeInfinity, algorithm: _Fixed(10)),
    PiecewiseSegment(fromJulianDay: 2000, algorithm: _Fixed(20)),
  ]);
  test('节点前用段0', () {
    expect(pw.computePositions(julianDay: 1999, datetime: DateTime.utc(2000))[EnumStars.Qi], 10);
  });
  test('节点起(含)用段1', () {
    expect(pw.computePositions(julianDay: 2000, datetime: DateTime.utc(2000))[EnumStars.Qi], 20);
    expect(pw.computePositions(julianDay: 5000, datetime: DateTime.utc(2000))[EnumStars.Qi], 20);
  });
}
