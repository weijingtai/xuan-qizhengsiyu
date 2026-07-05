import 'dart:math' as math;
import 'package:flutter_test/flutter_test.dart';
import 'package:qizhengsiyu/utils/math/arc_circle.dart';

void main() {
  group('A. 会圆术地基 (TestHuiyuanCore)', () {
    late HushiGeyuan g;
    late double r;

    setUp(() {
      g = const HushiGeyuan();
      r = g.r;
    });

    test('test_prime_anchors_zero: 矢 0 → 弦 0, 弧 0', () {
      expect(g.chordFromSagitta(0.0), closeTo(0.0, 1e-12));
      expect(g.arcFromSagitta(0.0), closeTo(0.0, 1e-12));
    });

    test('test_semicircle_anchor: 矢 = r → 半圆：弦 = 直径 = 2r，弧 = 3r (古率 π=3)', () {
      expect(g.chordFromSagitta(r), closeTo(2 * r, 1e-12));
      expect(g.arcFromSagitta(r), closeTo(3 * r, 1e-12));
      expect(g.arcFromSagitta(r), closeTo(g.huiyuanMaxArc, 1e-12));
    });

    test('test_pythagoras_identity: 勾股：r² = (r−v)² + 半弦²', () {
      final values = [0.5, 5.0, 20.0, r * 0.9, r];
      for (final v in values) {
        final hc = g.halfChordFromSagitta(v);
        expect(math.pow(r - v, 2) + math.pow(hc, 2), closeTo(r * r, 1e-9));
      }
    });

    test('test_chord_is_twice_half_chord', () {
      final values = [1.0, 10.0, 30.0, r];
      for (final v in values) {
        expect(g.chordFromSagitta(v), closeTo(2 * g.halfChordFromSagitta(v), 1e-12));
      }
    });

    test('test_sagitta_halfchord_roundtrip: 矢 → 半弦 → 矢 精确往返 (minor arc)', () {
      final values = [0.0, 0.3, 7.0, 25.0, r * 0.5, r];
      for (final v in values) {
        final hc = g.halfChordFromSagitta(v);
        final v2 = g.sagittaFromHalfChord(hc);
        expect(v, closeTo(v2, 1e-9));
      }
    });

    test('test_sagitta_chord_roundtrip', () {
      final values = [0.2, 4.0, 18.0, r * 0.7];
      for (final v in values) {
        final c = g.chordFromSagitta(v);
        expect(g.sagittaFromChord(c), closeTo(v, 1e-9));
      }
    });

    test('test_halfchord_domain_error', () {
      expect(() => g.sagittaFromHalfChord(r * 1.01), throwsA(isA<GeyuanException>()));
      expect(() => g.halfChordFromSagitta(-1.0), throwsA(isA<GeyuanException>()));
    });
  });

  group('B. 割圆求矢 (TestGeyuanQiushi)', () {
    late HushiGeyuan g;
    late double r;

    setUp(() {
      g = const HushiGeyuan();
      r = g.r;
    });

    test('test_arc_sagitta_roundtrip: 矢 → 弧 → 矢，二分迭代应精确复原', () {
      final values = [0.0, 0.5, 3.0, 12.0, 30.0, r * 0.6, r];
      for (final v in values) {
        final arc = g.arcFromSagitta(v);
        final v2 = g.sagittaFromArc(arc);
        expect(v, closeTo(v2, 1e-8));
      }
    });

    test('test_sagitta_arc_roundtrip: 弧 → 矢 → 弧', () {
      final values = [0.0, 1.0, 15.0, 60.0, 91.31, g.huiyuanMaxArc];
      for (final arc in values) {
        final v = g.sagittaFromArc(arc);
        final arc2 = g.arcFromSagitta(v);
        expect(arc, closeTo(arc2, 1e-7));
      }
    });

    test('test_forward_monotonic_increasing: arcFromSagitta 在 [0, r] 严格单调递增 (二分收敛前提)', () {
      double prev = -1.0;
      double v = 0.0;
      final step = r / 200.0;
      while (v <= r + 1e-9) {
        final cur = g.arcFromSagitta(math.min(v, r));
        expect(cur > prev - 1e-12, isTrue);
        prev = cur;
        v += step;
      }
    });

    test('test_semicircle_arc_gives_radius_sagitta', () {
      expect(g.sagittaFromArc(g.huiyuanMaxArc), closeTo(r, 1e-7));
    });

    test('test_arc_domain_error', () {
      expect(() => g.sagittaFromArc(-0.001), throwsA(isA<GeyuanException>()));
      expect(() => g.sagittaFromArc(g.huiyuanMaxArc + 1.0), throwsA(isA<GeyuanException>()));
    });
  });

  group('C. 黄赤道换算 (TestHuangchidao)', () {
    late HushiGeyuan g;
    late double r;
    late double q;

    setUp(() {
      g = const HushiGeyuan();
      r = g.r;
      q = g.quadrant;
    });

    test('test_dec_boundaries: 二分点 λ=0 → 赤纬 0；二至 λ=象限 → 赤纬 = 大距 (精确)', () {
      expect(g.declination(0.0), closeTo(0.0, 1e-9));
      expect(g.declination(q), closeTo(g.daJu, 1e-6));
    });

    test('test_ra_boundaries: 二分点 λ=0 → 赤道积度 0；二至 λ=象限 → 赤道积度 = 象限 (精确)', () {
      expect(g.rightAscension(0.0), closeTo(0.0, 1e-9));
      expect(g.rightAscension(q), closeTo(q, 1e-6));
    });

    test('test_proportion_p2_equals_p1_peps_over_R: 显式核对比例 p2 = p1·p_eps/R，即 sinδ = sinε·sinλ', () {
      final values = [10.0, 30.0, 60.0, 80.0];
      for (final lam in values) {
        final p1 = g.sineOfArc(lam); // r·sinλ
        final pEps = g.sineOfArc(g.daJu); // r·sinε
        final p2Expected = p1 * pEps / r; // r·sinδ
        final dec = g.declination(lam);
        final p2Actual = g.sineOfArc(dec); // 由赤纬反算其正弦
        expect(p2Actual, closeTo(p2Expected, 1e-7));
      }
    });

    test('test_dec_monotonic: 赤纬随黄道积度单调递增 (0 → 象限)', () {
      double prev = -1.0;
      for (int i = 0; i <= 30; i++) {
        final lam = i * q / 30.0;
        final cur = g.declination(lam);
        expect(cur >= prev - 1e-9, isTrue);
        prev = cur;
      }
    });

    test('test_ra_monotonic', () {
      double prev = -1.0;
      for (int i = 0; i <= 30; i++) {
        final lam = i * q / 30.0;
        final cur = g.rightAscension(lam);
        expect(cur >= prev - 1e-9, isTrue);
        prev = cur;
      }
    });

    test('test_dec_vs_modern_spherical: 弧矢/勾股投影精确，赤纬应与现代球面三角机器精度一致', () {
      double maxErr = 0.0;
      for (int i = 0; i <= 20; i++) {
        final lam = i * q / 20.0;
        final err = (g.declination(lam) - g.declinationModern(lam)).abs();
        maxErr = math.max(maxErr, err);
      }
      expect(maxErr < 1e-6, isTrue, reason: "最大赤纬误差 $maxErr 度超限");
    });

    test('test_ra_vs_modern_spherical', () {
      double maxErr = 0.0;
      for (int i = 1; i < 20; i++) {
        final lam = i * q / 20.0;
        final err = (g.rightAscension(lam) - g.rightAscensionModern(lam)).abs();
        maxErr = math.max(maxErr, err);
      }
      expect(maxErr < 1e-6, isTrue, reason: "最大赤经误差 $maxErr 度超限");
    });

    test('test_huiyuan_arc_approximation_error: 沈括会圆术弧长近似: 小弧精确, 近象限渐失真', () {
      final values = [5.0, 15.0, 30.0];
      for (final arc in values) {
        final exact = g.sineOfArc(arc);
        final approx = g.sineOfArcHuiyuan(arc);
        expect((exact - approx).abs() < 0.5, isTrue, reason: "arc=$arc 会圆术正弦误差过大");
      }
      final errQuad = (g.sineOfArc(q) - g.sineOfArcHuiyuan(q)).abs();
      expect(errQuad > 0.1, isTrue, reason: "近象限会圆术误差应显著 (印证古法失真)");
    });

    test('test_ecliptic_to_equatorial_tuple', () {
      final (alpha, delta) = g.eclipticToEquatorial(45.0);
      expect(alpha, closeTo(g.rightAscension(45.0), 1e-9));
      expect(delta, closeTo(g.declination(45.0), 1e-9));
    });

    test('test_ra_le_lam_in_first_quadrant: 第一象限内 (春分→夏至方向) 赤经 ≤ 黄经 (cosε<1 收缩)', () {
      final values = [10.0, 40.0, 70.0];
      for (final lam in values) {
        expect(g.rightAscension(lam) <= lam + 1e-6, isTrue);
      }
    });

    test('test_dec_domain_error', () {
      expect(() => g.declination(q + 5.0), throwsA(isA<GeyuanException>()));
      expect(() => g.rightAscension(-1.0), throwsA(isA<GeyuanException>()));
    });
  });

  group('D. 授时历常数与锚点 (TestConstants)', () {
    test('test_zhou_tian_and_radius', () {
      final g = const HushiGeyuan();
      expect(g.zhouTian, zhouTianConst);
      expect(g.r, closeTo(zhouTianConst / (2 * math.pi), 1e-9));

      // 古率 π=3 时半径 = 周天/6 = 60.87625 (授时历原值)
      final g3 = const HushiGeyuan(piRatio: 3.0);
      expect(g3.r, closeTo(60.87625, 1e-5));
    });

    test('test_quadrant', () {
      final g = const HushiGeyuan();
      expect(g.quadrant, closeTo(365.2575 / 4.0, 1e-6));
      expect(g.quadrant, closeTo(91.314375, 1e-6));
    });

    test('test_custom_constants', () {
      // 可替换为其它刻本常数；古率 π=3, 周天=360 ⇒ r=60
      final g = const HushiGeyuan(zhouTian: 360.0, daJu: 24.0, piRatio: 3.0);
      expect(g.r, closeTo(60.0, 1e-9));
      expect(g.declination(0.0), closeTo(0.0, 1e-9));
    });

    test('test_diameter', () {
      final g = const HushiGeyuan();
      expect(g.diameter, closeTo(2 * g.r, 1e-12));
    });
  });
}
