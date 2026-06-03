import 'package:flutter_test/flutter_test.dart';
import 'package:qizhengsiyu/utils/math/spline_interpolator.dart';

void main() {
  group('MonotonicCubicSpline Unit Tests', () {
    test('Strict Monotonicity: Increasing', () {
      final x = [0.0, 180.0, 360.0];
      final y = [0.0, 100.0, 365.25];
      final spline = MonotonicCubicSpline(x, y);

      double prev = -1.0;
      for (double i = 0; i <= 360; i += 0.1) {
        final val = spline.interpolate(i);
        expect(val >= prev, isTrue, reason: "Non-monotonic at $i: $val < $prev");
        prev = val;
      }
    });

    test('Passes through control points', () {
      final x = [0.0, 90.0, 180.0, 270.0, 360.0];
      final y = [0.0, 85.0, 190.0, 260.0, 365.25];
      final spline = MonotonicCubicSpline(x, y);

      for (int i = 0; i < x.length; i++) {
        expect(spline.interpolate(x[i]), closeTo(y[i], 1e-9));
      }
    });

    test('Boundary handling: out of range', () {
      final x = [0.0, 360.0];
      final y = [0.0, 365.25];
      final spline = MonotonicCubicSpline(x, y);

      expect(spline.interpolate(-10.0), 0.0);
      expect(spline.interpolate(400.0), 365.25);
    });

    test('Error handling: non-increasing X', () {
      expect(() => MonotonicCubicSpline([0, 100, 50], [0, 10, 20]), throwsArgumentError);
    });

    test('Error handling: mismatched length', () {
      expect(() => MonotonicCubicSpline([0, 100], [0, 10, 20]), throwsArgumentError);
    });
  });
}
