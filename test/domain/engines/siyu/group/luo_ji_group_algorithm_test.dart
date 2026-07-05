import 'package:flutter_test/flutter_test.dart';
import 'package:metaphysics_core/enums.dart';
import 'package:qizhengsiyu/enums/enum_rahu_ketu_convention.dart';
import 'package:qizhengsiyu/domain/engines/siyu/group/linear_parallel_core.dart';
import 'package:qizhengsiyu/domain/engines/siyu/group/luo_ji_group_algorithm.dart';

double _diff(double a, double b) { var d=(a-b).abs()%360; return d>180?360-d:d; }

void main() {
  test('古法平行罗计：罗降计升(默认)，逆行，180°对冲', () {
    final algo = LinearNodePairAlgorithm(
      nodeCore: const LinearParallelCore(
          totalDegree: 360, dailyMotion: 0.052993, direction: -1,
          epochJulianDay: 1000, epochPosition: 30),
      convention: EnumRahuKetuConvention.luoJiangJiSheng,
    );
    final p = algo.computePositions(julianDay: 1000, datetime: DateTime.utc(2000));
    // N=30(升交点)=计都；罗睺=降交点=210
    expect(p[EnumStars.Ji], closeTo(30, 1e-6));
    expect(p[EnumStars.Luo], closeTo(210, 1e-6));
    expect(_diff(p[EnumStars.Luo]!, p[EnumStars.Ji]!), closeTo(180, 1e-6));
  });
  test('convention=罗升计降 时罗计互换', () {
    final algo = LinearNodePairAlgorithm(
      nodeCore: const LinearParallelCore(
          totalDegree: 360, dailyMotion: 0.052993, direction: -1,
          epochJulianDay: 1000, epochPosition: 30),
      convention: EnumRahuKetuConvention.luoShengJiJiang,
    );
    final p = algo.computePositions(julianDay: 1000, datetime: DateTime.utc(2000));
    expect(p[EnumStars.Luo], closeTo(30, 1e-6));
    expect(p[EnumStars.Ji], closeTo(210, 1e-6));
  });
}
