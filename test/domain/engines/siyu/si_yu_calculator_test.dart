import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;
import 'package:qizhengsiyu/domain/engines/siyu/si_yu_calculator.dart';
import 'package:qizhengsiyu/domain/engines/siyu/ziqi/zi_qi_algorithm.dart';

class _FakeSource implements ISiYuEphemerisSource {
  final double node;
  final double apogee;
  _FakeSource(this.node, this.apogee);
  @override
  double meanNodeLongitude(double jd) => node;
  @override
  double meanApogeeLongitude(double jd) => apogee;
}

class _ConstZiQi implements ZiQiAlgorithm {
  final double value;
  const _ConstZiQi(this.value);
  @override
  String get id => 'const';
  @override
  double computeLongitude({required double julianDay, required DateTime datetime}) => value;
}

void main() {
  setUpAll(() => tzdata.initializeTimeZones());

  test('降交点=升交点+180，月孛=远地点直传', () {
    final calc = SiYuCalculator(
      source: _FakeSource(30, 123),
      ziQiAlgorithm: const _ConstZiQi(50),
    );
    final r = calc.compute(
        julianDay: 2451545.0,
        birthDate: DateTime.utc(2000, 1, 1));
    expect(r.northNode, closeTo(30, 1e-9));
    expect(r.southNode, closeTo(210, 1e-9));
    expect(r.lilith, closeTo(123, 1e-9));
    expect(r.qi, closeTo(50, 1e-9));
  });

  test('升交点越界归一化：N=350 -> 降=170', () {
    final calc = SiYuCalculator(
      source: _FakeSource(350, 0),
      ziQiAlgorithm: const _ConstZiQi(0),
    );
    final r = calc.compute(
        julianDay: 2451545.0, birthDate: DateTime.utc(2000, 1, 1));
    expect(r.southNode, closeTo(170, 1e-9));
  });
}
