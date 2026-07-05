import 'package:flutter_test/flutter_test.dart';
import 'package:qizhengsiyu/enums/enum_rahu_ketu_convention.dart';
import 'package:qizhengsiyu/domain/engines/siyu/rahu_ketu_definition.dart';

double _diff(double a, double b) {
  var d = (a - b).abs() % 360;
  if (d > 180) d = 360 - d;
  return d;
}

void main() {
  const oldWay = EnumRahuKetuConvention.luoJiangJiSheng;
  const newWay = EnumRahuKetuConvention.luoShengJiJiang;

  test('旧法：罗睺=降交点(N+180)，计都=升交点(N)', () {
    final r = RahuKetuDefinition.assign(northNode: 30, convention: oldWay);
    expect(r.ji, closeTo(30, 1e-9));
    expect(r.luo, closeTo(210, 1e-9));
  });

  test('新法：罗睺=升交点(N)，计都=降交点(N+180)', () {
    final r = RahuKetuDefinition.assign(northNode: 30, convention: newWay);
    expect(r.luo, closeTo(30, 1e-9));
    expect(r.ji, closeTo(210, 1e-9));
  });

  test('降交点越界归一化：N=200 -> 降=20', () {
    final r = RahuKetuDefinition.assign(northNode: 200, convention: oldWay);
    expect(r.luo, closeTo(20, 1e-9)); // 降交点
    expect(r.ji, closeTo(200, 1e-9)); // 升交点
  });

  test('罗计恒对冲 180°（两流派、任意角度）', () {
    for (final n in [0.0, 30.0, 123.4, 200.0, 359.9]) {
      for (final c in EnumRahuKetuConvention.values) {
        final r = RahuKetuDefinition.assign(northNode: n, convention: c);
        expect(_diff(r.luo, r.ji), closeTo(180, 1e-6));
      }
    }
  });

  test('新法与旧法的罗睺黄经恰好相差 180°', () {
    final o = RahuKetuDefinition.assign(northNode: 77, convention: oldWay);
    final n = RahuKetuDefinition.assign(northNode: 77, convention: newWay);
    expect(_diff(o.luo, n.luo), closeTo(180, 1e-6));
  });
}
