import 'package:flutter_test/flutter_test.dart';
import 'package:qizhengsiyu/domain/engines/siyu/si_yu_calculator.dart';
import 'package:qizhengsiyu/domain/engines/siyu/ziqi/zi_qi_algorithm.dart';

class _FakeSource implements ISiYuEphemerisSource {
  @override
  double meanNodeLongitude(double jd) => 0;
  @override
  double meanApogeeLongitude(double jd) => 0;
}

class _ConstZiQi implements ZiQiAlgorithm {
  @override
  String get id => 'const';
  @override
  double computeLongitude({required double julianDay, required DateTime datetime}) => 88.0;
}

void main() {
  test('紫气取自注入的算法', () {
    final calc = SiYuCalculator(
      source: _FakeSource(),
      ziQiAlgorithm: _ConstZiQi(),
    );
    final r = calc.compute(julianDay: 123, birthDate: DateTime.utc(2000));
    expect(r.qi, closeTo(88.0, 1e-9));
  });
}
