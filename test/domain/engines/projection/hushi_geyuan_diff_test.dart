import 'dart:math' as math;
import 'package:flutter_test/flutter_test.dart';
import 'package:qizhengsiyu/domain/engines/projection/huang_chi_dao_diff.dart';
import 'package:qizhengsiyu/utils/math/arc_circle.dart';

void main() {
  const zhou = 365.2575;
  final geyuan = HushiGeyuan(zhouTian: zhou, daJu: 23.9030, piRatio: math.pi);
  final diff = HushiGeyuanDiff(zhouTian: zhou, epsilonDeg: 23.9030);

  test('两端(分点/至点)黄赤道差为 0', () {
    expect(diff.diff(0.0), closeTo(0.0, 1e-6));
    expect(diff.diff(diff.quadrant), closeTo(0.0, 5e-4));
  });

  test('diff(c) 反演与 rightAscension 自洽：对给定 lam，令 c=alpha(lam) 应得 d≈lam-c', () {
    for (final lam in [10.0, 30.0, 60.0, 85.0]) {
      final alpha = geyuan.rightAscension(lam);
      final d = diff.diff(alpha);
      expect(alpha + d, closeTo(lam, 1e-3),
          reason: 'lam=$lam: 赤道+差 应还原黄道');
    }
  });

  test('象限内 d>=0 且最大 ≈2.5°（授时实测量级）', () {
    double maxD = 0;
    for (double c = 0; c <= diff.quadrant; c += 1) {
      final d = diff.diff(c);
      expect(d, greaterThanOrEqualTo(-1e-6));
      if (d > maxD) maxD = d;
    }
    expect(maxD, closeTo(2.5, 0.4));
  });
}
